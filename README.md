<h1 align='center'>Epyi's Scripts → Map Editor</h1>
<p align='center'><a href='https://discord.gg/VyRPheG6Es'>Discord</a> - <a href='#'>Website</a></p>

<p align='center'><b>FiveM RageUI standalone map editor</b></p>

```diff
- EPYI_MAPEDITOR is under development and therefore cannot be used at this time. The official and stable versions are given as a release.
```
## 💾 Dependencies
- **None**, the script is standalone and works without any framework
## 🔧 Installation guide
1. Go download a **release of the script**
2. Extract the downloaded zip
3. Drag and drop the **epyi_mapeditor** folder into your server
4. Start the resource folder by using **ensure epyi_mapeditor** in your server.cfg
5. **OPTIONAL →** Configure the script by editing the **config.lua** file
6. **OPTIONAL →** Restrict the map editor with the ace permission **epyi_mapeditor.access** by setting **Config.Permissions.UseAce** to **true** and adding **add_ace group.admin epyi_mapeditor.access allow** in your server.cfg
7. **OPTIONAL →** Set the language with **setr epyi_mapeditor:locale "fr"** in your server.cfg (available: **en**, **fr**)
## 🎮 Usage
- Press **F9** to open the main menu, then **enter the editor** to fly with the camera (**SPACE/LEFT CTRL** → up/down, **MOUSE WHEEL** → camera speed)
- **F5** → objects, **F6** → peds, **F7** → vehicles: each list has a **search** and **categories** (with the **recently used** objects), and any object can be added with its **model name**
- **LEFT MOUSE BUTTON** → select the entity under the crosshair, the **Entities of the map** menu lists and selects all the entities
- When adding an object (it follows the crosshair):
  - **LEFT MOUSE BUTTON/ENTER** → place, hold **LEFT SHIFT** while placing to keep adding the same object
  - **Q/E** or **MOUSE WHEEL** → rotate, **X** → align on the surface, **ESC** → cancel
- When an entity is selected:
  - Drag the **3D gizmo** with the mouse cursor, **TAB** → switch the gizmo between move and rotate, hold **RIGHT MOUSE BUTTON** → look around
  - **ENTER** → entity menu (gizmo mode, relative axes, exact position and rotation, color, put on the ground, duplicate, delete)
  - **ARROWS** → move on X/Y, **R/F** → move on Z, **Q/E** → rotate, hold **G** → move to the crosshair, **Z** → put on the ground
  - **1** → relative/world axes, **2** → rotation axis, **3** → rotate over 15°, **C + ARROW UP/DOWN** → clone
  - **DELETE** → delete, **ESC** → deselect
- **LEFT SHIFT** → go faster, **LEFT ALT** → go slower
- The editor controls can be changed in the **config.lua** file, and the gizmo keys (mouse buttons and **TAB**) in the FiveM key bindings settings
## 🗺️ Maps
- The maps are saved in the **maps** folder of the resource, in the **5me** xml format (the file name is the map name, without accents and special characters)
- The editor can also load the maps of the **Guadmaz's Map Editor** and the **races** in the 5me format
- The maps can be loaded in the world by the other resources with the client exports:
```lua
local mapId = exports["epyi_mapeditor"]:loadMap(xmlData) -- load a map from its xml content, return its id (the map name)
exports["epyi_mapeditor"]:unloadMap(mapId) -- unload a map
exports["epyi_mapeditor"]:unloadAllMaps() -- unload all the maps
```
- Or by the server with the client events **epyi_mapeditor:loader:load** (xml content), **epyi_mapeditor:loader:unload** (map id) and **epyi_mapeditor:loader:unloadAll** (use **TriggerLatentClientEvent** to send big maps)
## 📜 License
    Copyright (C) 2026 Epyi's Scripts

    This program Is free software: you can redistribute it And/Or modify it under the terms Of the MIT License.
[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/epyis-scripts/epyi_mapeditor/blob/main/LICENSE)
