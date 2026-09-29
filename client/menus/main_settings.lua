---main_settings_showContentThisFrame → Function to show the main/settings menu content
---@return void
function main_settings_showContentThisFrame()
	RageUI.Checkbox(_U("main_settings_radar"), _U("main_settings_radar_desc"), _var.settings.showRadar, {}, function(_h, _a, _s, Checked)
		_var.settings.showRadar = Checked
	end)
	RageUI.Checkbox(_U("main_settings_axis"), _U("main_settings_axis_desc"), _var.settings.showXYZAxis, {}, function(_h, _a, _s, Checked)
		_var.settings.showXYZAxis = Checked
	end)
	RageUI.Checkbox(_U("main_settings_cursor"), _U("main_settings_cursor_desc"), _var.settings.show3DCursor, {}, function(_h, _a, _s, Checked)
		_var.settings.show3DCursor = Checked
	end)
	RageUI.List(_U("main_settings_camera_speed"), _var.menu.cameraSpeedArray, _var.menu.cameraSpeedArrayIndex, _U("main_settings_camera_speed_desc"), {}, true, function(_h, _a, _s, Index)
		_var.menu.cameraSpeedArrayIndex = Index
		_var.settings.cameraSpeed = (2 * (Index - 1) / (#_var.menu.cameraSpeedArray - 1)) + 0.05
	end)
	RageUI.Checkbox(_U("main_settings_instructional_buttons"), _U("main_settings_instructional_buttons_desc"), _var.settings.showInstructionalButtons, {}, function(_h, _a, _s, Checked)
		_var.settings.showInstructionalButtons = Checked
	end)
	RageUI.Checkbox(_U("main_settings_infobars"), _U("main_settings_infobars_desc"), _var.settings.showInfoBars, {}, function(_h, _a, _s, Checked)
		_var.settings.showInfoBars = Checked
	end)
	RageUI.Checkbox(_U("main_settings_selection_marker"), _U("main_settings_selection_marker_desc"), _var.settings.showSelectionMarker, {}, function(_h, _a, _s, Checked)
		_var.settings.showSelectionMarker = Checked
	end)
	RageUI.Checkbox(_U("main_settings_bounding_box"), _U("main_settings_bounding_box_desc"), _var.settings.showBoundingBox, {}, function(_h, _a, _s, Checked)
		_var.settings.showBoundingBox = Checked
	end)
	RageUI.Checkbox(_U("main_settings_network_objects"), _U("main_settings_network_objects_desc"), _var.settings.networkObjects, { LeftBadge = RageUI.BadgeStyle.Alert }, function(_h, _a, _s, Checked)
		_var.settings.networkObjects = Checked
	end)
end
