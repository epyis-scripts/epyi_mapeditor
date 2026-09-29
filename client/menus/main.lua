---main_showContentThisFrame → Function to show the main menu content
---@return void
function main_showContentThisFrame()
	RageUI.Checkbox(_U("main_menu_editor"), _U("main_menu_editor_desc"), _var.editor.state ~= _var.editor.states.inactive, {}, function() end, function()
		enterEditor()
	end, function()
		exitEditor()
	end)
	RageUI.Separator("")
	RageUI.ButtonWithStyle(_U("main_menu_new_map"), _U("main_menu_new_map_desc"), {}, true, function(_h, _a, Selected)
		if Selected then
			resetEditorSelection()
			mapUnload()
			mapNew()
			showNotification(_U("notif_map_new"), 20)
		end
	end)
	RageUI.ButtonWithStyle(_U("main_menu_save_map"), _U("main_menu_save_map_desc", _var.map.current.name), {}, true, function(_h, _a, Selected)
		if Selected then
			saveMap()
		end
	end)
	RageUI.ButtonWithStyle(_U("main_menu_load_map"), _U("main_menu_load_map_desc"), { RightLabel = "→" }, true, function(_h, _a, Selected)
		if Selected then
			TriggerServerEvent("epyi_mapeditor:getMapsList")
		end
	end, _var.menus.editor.objects.mainMaps)
	RageUI.ButtonWithStyle(_U("main_menu_entities"), _U("main_menu_entities_desc"), { RightLabel = "→" }, true, function(_h, _a, _s) end, _var.menus.editor.objects.mainEntities)
	RageUI.ButtonWithStyle(_U("main_menu_metadata"), _U("main_menu_metadata_desc"), { RightLabel = "→" }, true, function(_h, _a, _s) end, _var.menus.editor.objects.mainMetadata)
	RageUI.ButtonWithStyle(_U("main_menu_settings"), _U("main_menu_settings_desc"), { RightLabel = "→" }, true, function(_h, _a, _s) end, _var.menus.editor.objects.mainSettings)
end
