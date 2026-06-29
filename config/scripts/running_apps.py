#!/usr/bin/env python3
import os
import sys
import json
import subprocess
import time
import glob

CACHE_FILE = os.path.expanduser("~/.config/polybar/scripts/cache.json")
ICONS_FILE = os.path.expanduser("~/.config/polybar/scripts/icons.json")

PINNED_APPS = {
    "kitty", "kitty.kitty", 
    "firefox", "navigator.firefox", 
    "discord", "com.discordapp.discord", 
    "nemo", "nemo.nemo",
    "polybar"
}

def load_json(path):
    if os.path.exists(path):
        try:
            with open(path, "r", encoding="utf-8") as f:
                return json.load(f)
        except:
            pass
    return {}

def save_json(path, data):
    try:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=4)
    except:
        pass

def parse_desktop_files():
    apps = {}
    search_paths = [
        "/usr/share/applications/*.desktop",
        os.path.expanduser("~/.local/share/applications/*.desktop")
    ]
    for path_pattern in search_paths:
        for filepath in glob.glob(path_pattern):
            try:
                with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
                    content = f.read()
                
                name, icon, wm_class, exec_name = "", "", "", ""
                for line in content.splitlines():
                    if line.startswith("Name="):
                        name = line.split("=", 1)[1].strip()
                    elif line.startswith("Icon="):
                        icon = line.split("=", 1)[1].strip()
                    elif line.startswith("StartupWMClass="):
                        wm_class = line.split("=", 1)[1].strip()
                    elif line.startswith("Exec="):
                        raw_exec = line.split("=", 1)[1].strip()
                        exec_name = raw_exec.split()[0].split("/")[-1].replace('"', '').replace("'", "")

                app_data = {"name": name, "icon": icon, "wm_class": wm_class, "exec": exec_name}
                
                if wm_class:
                    apps[wm_class.lower()] = app_data
                if exec_name:
                    apps[exec_name.lower()] = app_data
                
                filename = os.path.basename(filepath).replace(".desktop", "").lower()
                apps[filename] = app_data
            except:
                pass
    return apps

def get_apps_cache():
    cache = load_json(CACHE_FILE)
    if not cache:
        cache = parse_desktop_files()
        save_json(CACHE_FILE, cache)
    return cache

def resolve_app(wm_class, cache):
    class_lower = wm_class.lower()
    if class_lower in cache:
        return cache[class_lower]
    
    parts = wm_class.split(".")
    for part in parts:
        if part.lower() in cache:
            return cache[part.lower()]
                        
    name_fallback = parts[-1] if len(parts) > 1 else parts[0].capitalize()
    return {"name": name_fallback, "icon": "", "wm_class": wm_class, "exec": parts[0]}

def get_running_windows():
    try:
        output = subprocess.check_output(["wmctrl", "-lx"], stderr=subprocess.DEVNULL).decode("utf-8", errors="ignore")
    except:
        return []
    
    windows = []
    for line in output.strip().splitlines():
        parts = line.split(None, 4)
        if len(parts) < 4:
            continue
        
        window_id = parts[0]
        wm_class = parts[2]
        
        if wm_class == "N/A":
            continue
            
        class_lower = wm_class.lower()
        is_pinned = False
        for pinned in PINNED_APPS:
            if pinned in class_lower or class_lower in pinned:
                is_pinned = True
                break
                
        if is_pinned:
            continue
            
        windows.append({"id": window_id, "class": wm_class})
    return windows

def main():
    apps_cache = get_apps_cache()
    icons_map = load_json(ICONS_FILE)
    last_output = ""
    
    while True:
        windows = get_running_windows()
        groups = {}
        
        for win in windows:
            app_info = resolve_app(win["class"], apps_cache)
            app_key = app_info["wm_class"] if app_info["wm_class"] else app_info["exec"]
            app_key = app_key.lower()
            
            if app_key not in groups:
                groups[app_key] = {
                    "info": app_info,
                    "ids": [],
                    "class": win["class"]
                }
            groups[app_key]["ids"].append(win["id"])
            
        output_parts = []
        for app_key, group in groups.items():
            info = group["info"]
            win_count = len(group["ids"])
            first_id = group["ids"][0]
            
            icon_char = ""
            lookup_keys = [app_key, info.get("icon", "").lower(), info.get("exec", "").lower(), group["class"].lower()]
            for key in lookup_keys:
                if key and key in icons_map:
                    icon_char = icons_map[key]
                    break
            
            if not icon_char:
                icon_char = ""
                
            app_name = info.get("name", "").strip()
            if not app_name:
                cls_parts = group["class"].split(".")
                raw_name = cls_parts[-1] if len(cls_parts) > 1 else cls_parts[0]
                app_name = raw_name.strip().capitalize()
                
            display_text = icon_char + " " + app_name
            
            if win_count > 1:
                display_text += " %{T2}" + str(win_count) + "%{T-}"
                
            fmt = "%{A1:wmctrl -ia " + first_id + ":}" + display_text + "%{A}"
            output_parts.append(fmt)
            
        current_output = "  ".join(output_parts)
        if current_output != last_output:
            print(current_output, flush=True)
            last_output = current_output
            
        time.sleep(0.5)

if __name__ == "__main__":
    main()
