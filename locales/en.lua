locales["en"] = {
	-- Banners
	["menu_title"] = "Map Editor",
	["main_subtitle"] = "Menu of the ~r~map editor",
	["main_maps_subtitle"] = "Load ~r~a map",
	["main_metadata_subtitle"] = "Metadata of ~r~the map",
	["main_settings_subtitle"] = "Editor ~r~settings",
	["objects_subtitle"] = "Add ~r~an object",
	["peds_subtitle"] = "Select a ~r~ped model",
	["vehicles_subtitle"] = "Select a ~r~vehicle model",

	-- Keys
	["keys_menu_description"] = "~r~Open map editor menu",

	-- Global
	["insuficient_permissions"] = "Sorry, but you don't have permission to do that",
	["map_default_name"] = "Nameless Map",
	["default"] = "Default",
	["search"] = "Search",
	["no_filter"] = "No filter",
	["filter_result"] = "↓ Filter ~r~results ~s~↓",
	["no_result"] = "~c~No result",
	["camera_speed_very_slow"] = "Very slow",
	["camera_speed_slow"] = "Slow",
	["camera_speed_normal"] = "Normal",
	["camera_speed_fast"] = "Fast",
	["camera_speed_very_fast"] = "Very fast",
	["rotation_mode_pitch"] = "Pitch",
	["rotation_mode_roll"] = "Roll",
	["rotation_mode_yaw"] = "Yaw",

	-- Editor → Info bars
	["infobar_objects"] = "Objects",
	["infobar_peds"] = "Peds",
	["infobar_vehicles"] = "Vehicles",

	-- Editor → Instructionals buttons
	["button_vehicle"] = "Vehicle",
	["button_ped"] = "Ped",
	["button_object"] = "Object",
	["button_select_entity"] = "Select entity",
	["button_rotate"] = "Rotate",
	["button_rotate_axis"] = "Rotate (%s)",
	["button_align"] = "Align",
	["button_place"] = "Place",
	["button_translate"] = "Translate",
	["button_clone"] = "Clone",
	["button_delete"] = "Delete",
	["button_drag_entity"] = "Drag entity",
	["helptext_selected"] = "%s toggle translation mode\n%s toggle rotation axis\n%s rotate over 15°\n%s de-select",

	-- Elements → Main menu
	["main_menu_editor"] = "~r~Enter/Exit ~s~the editor",
	["main_menu_editor_desc"] = "Enter or exit the editor, once entered you can fly with the camera and edit the map",
	["main_menu_new_map"] = "New ~r~map",
	["main_menu_new_map_desc"] = "Start a new map, the current map will be removed",
	["main_menu_save_map"] = "Save ~r~map",
	["main_menu_save_map_desc"] = "Save the current map ~r~%s ~s~to the server",
	["main_menu_load_map"] = "Load ~r~map",
	["main_menu_load_map_desc"] = "Load a map from the server",
	["main_menu_metadata"] = "Map ~r~metadata",
	["main_menu_metadata_desc"] = "Set the metadata of the current map",
	["main_menu_settings"] = "~r~Settings",
	["main_menu_settings_desc"] = "Change the settings of the editor",

	-- Elements → Main menu → Maps
	["main_maps_list"] = "↓ Maps saved on ~r~the server ~s~↓",
	["main_maps_load_desc"] = "Load the map ~r~%s~s~, the current map will be removed",

	-- Elements → Main menu → Metadata
	["main_metadata_name"] = "Edit ~r~name",
	["main_metadata_creator"] = "Edit ~r~creator",
	["main_metadata_description"] = "Edit ~r~description",
	["main_metadata_current"] = "Currently: ~r~%s",

	-- Elements → Main menu → Settings
	["main_settings_radar"] = "Show radar in editor",
	["main_settings_radar_desc"] = "Show or hide the radar while you are in the editor",
	["main_settings_axis"] = "Show XYZ axes",
	["main_settings_axis_desc"] = "Show or hide the XYZ axes of the selected entity",
	["main_settings_cursor"] = "Show 3D cursor",
	["main_settings_cursor_desc"] = "Show or hide the 3D cursor",
	["main_settings_camera_speed"] = "Camera speed",
	["main_settings_camera_speed_desc"] = "Change the speed of the camera",
	["main_settings_instructional_buttons"] = "Show instructional buttons",
	["main_settings_instructional_buttons_desc"] = "Show or hide the instructional buttons of the editor",
	["main_settings_infobars"] = "Show entity counts",
	["main_settings_infobars_desc"] = "Show or hide the number of objects, peds and vehicles of the map",
	["main_settings_selection_marker"] = "Show rotation axis markers",
	["main_settings_selection_marker_desc"] = "Show or hide the rotation axis markers of the selected entity",
	["main_settings_bounding_box"] = "Show bounding box",
	["main_settings_bounding_box_desc"] = "Show or hide the bounding box of the selected entity",
	["main_settings_network_objects"] = "Network loaded objects",
	["main_settings_network_objects_desc"] = "~o~EXPERIMENTAL~s~: Set if the created map entities should be networked",

	-- Elements → Objects menu
	["objects_category"] = "Category",
	["objects_category_desc"] = "Choose the category of the object",
	["objects_type"] = "Type",
	["objects_type_desc"] = "Choose the object",
	["objects_color"] = "Color",
	["objects_color_desc"] = "Choose the color of the object",

	-- Elements → Peds menu
	["peds_filter_desc"] = "Filter the ped models by name",
	["peds_spawn_desc"] = "Add the ped ~r~%s ~s~to the map",

	-- Elements → Vehicles menu
	["vehicles_filter_desc"] = "Filter the vehicle models by name",
	["vehicles_spawn_desc"] = "Add the vehicle ~r~%s ~s~to the map",

	-- Text entries
	["textentry_map_name"] = "Set map name",
	["textentry_map_creator"] = "Set map creator",
	["textentry_map_description"] = "Set map description",
	["textentry_search"] = "Search",

	-- Notifications
	["notif_map_new"] = "A new map has been started",
	["notif_map_saved"] = "Map saved!",
	["notif_map_save_error"] = "Could not save map!",
	["notif_map_loaded"] = "The map ~r~%s ~s~has been loaded",
	["notif_map_load_error"] = "Could not load map!",
	["notif_entity_not_created"] = "The entity could not be created",

	-- Logs
	["log_insuficient_permissions"] = "The player %s (ID: %s) tried to use the map editor without permission",
	["log_map_saving"] = "Saving map %s for player %s",
	["log_map_sending"] = "Player %s requested the load of map %s. Map size: %s kB",
	["log_map_sending_error"] = "ERROR: Could not send map %s to player %s",
}
