-- Key registering
-- register the key to open the map editor menu
Keys.Register(Config.Keys.Menu, "-openMapEditorMenu", _("keys_menu_description"), function()
	openMenu()
end)

-- Key registering
-- register the mouse button used to drag the gizmo (key mappings still work when the cursor is shown)
RegisterCommand("+epyi_mapeditor_gizmo", function()
	if _var.editor.cursorMode then
		ExecuteCommand("+gizmoSelect")
	end
end, false)
RegisterCommand("-epyi_mapeditor_gizmo", function()
	ExecuteCommand("-gizmoSelect")
end, false)
RegisterKeyMapping("+epyi_mapeditor_gizmo", _("keys_gizmo_description"), "MOUSE_BUTTON", Config.Keys.Gizmo)

-- Key registering
-- register the key used to switch the gizmo between move and rotate
RegisterCommand("epyi_mapeditor_gizmo_mode", function()
	if _var.editor.state == _var.editor.states.selected and _var.settings.useGizmo then
		setGizmoMode(_var.editor.gizmo.mode == "translate" and "rotate" or "translate")
	end
end, false)
RegisterKeyMapping("epyi_mapeditor_gizmo_mode", _("keys_gizmo_mode_description"), "keyboard", Config.Keys.GizmoMode)

-- Key registering
-- register the mouse button used to look around when the cursor is shown
RegisterCommand("+epyi_mapeditor_look", function()
	_var.editor.isLooking = true
end, false)
RegisterCommand("-epyi_mapeditor_look", function()
	_var.editor.isLooking = false
end, false)
RegisterKeyMapping("+epyi_mapeditor_look", _("keys_look_description"), "MOUSE_BUTTON", Config.Keys.LookAround)
