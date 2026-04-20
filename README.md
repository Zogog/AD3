# Adopt Me Research Workspace (Delta Edition)

A safe, modular, client‑side research environment for studying how Adopt Me structures its UI, remotes, and modules.  
Designed specifically for **Delta running inside an emulator**, which exposes more debugging features than PC executors.

## 🚀 Features

- ThreadIdentity tester  
- Universal remote logger  
- Module dumper  
- Safe UI-only pet spoofer  
- Modular architecture for adding your own tools  

## 📦 Usage

```lua
local ws = loadstring(game:HttpGet("https://raw.githubusercontent.com/<user>/<repo>/main/adoptme_workspace.lua"))()

ws.run("identity_test")
ws.run("remote_logger")
ws.run("module_dumper")
ws.run("ui_pet_spoofer")
