-- Threads pre init
_threads = {
	freecam = {},
	editor = {},
}

-- Thread initialization
-- Thread → Freecam
_threads.freecam.isActivated = false
_threads.freecam.generation = 0
_threads.freecam.enable = function()
	if _threads.freecam.isActivated then
		return
	end
	_threads.freecam.isActivated = true
	local ped = PlayerPedId()
	local coords = GetEntityCoords(ped)
	DestroyAllCams(true)
	_var.freecam.cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords.x, coords.y, coords.z, 0.0, 0.0, GetEntityHeading(ped), 60.0, false, 2)
	SetCamActive(_var.freecam.cam, true)
	RenderScriptCams(true, false, 0, true, true)
	FreezeEntityPosition(ped, true)
	SetEntityVisible(ped, false, false)
	SetEntityCollision(ped, false, false)
	SetEntityInvincible(ped, true)
	_threads.freecam.generation = _threads.freecam.generation + 1
	local generation = _threads.freecam.generation
	Citizen.CreateThread(function()
		while _threads.freecam.isActivated and generation == _threads.freecam.generation do
			if not _var.freecam.isPaused then
				_threads.freecam.update()
			end
			Citizen.Wait(0)
		end
	end)
end
_threads.freecam.update = function()
	local ped = PlayerPedId()
	local cam = _var.freecam.cam
	DisableAllControlActions(0)
	EnableControlAction(0, 249, true) -- PUSH TO TALK
	HideHudComponentThisFrame(2) -- WEAPON ICON
	HideHudComponentThisFrame(19) -- WEAPON WHEEL
	HideHudComponentThisFrame(20) -- WEAPON WHEEL STATS
	HideHudComponentThisFrame(9) -- STREET NAME
	HideHudComponentThisFrame(7) -- AREA NAME
	if not _var.settings.showRadar then
		HideHudAndRadarThisFrame()
	end

	local position = GetCamCoord(cam)
	local rotation = GetCamRot(cam, 2)
	SetEntityCoordsNoOffset(ped, position.x, position.y, position.z, false, false, false)
	SetEntityRotation(ped, rotation.x, rotation.y, rotation.z, 2, true)
	SetEntityCollision(ped, false, false)
	_var.freecam.forwardVector = rotationToDirection(rotation)

	-- Speed control
	local speedModifier = 0.6
	if isControlPressed(Config.Controls.GottaGoFast) then
		speedModifier = 3.0
	elseif isControlPressed(Config.Controls.GottaGoSlow) then
		speedModifier = 0.2
	end

	-- Camera position control
	local positionUpdate = vector3(0.0, 0.0, 0.0)
	local right = rightVector(_var.freecam.forwardVector)
	if isControlPressed(Config.Controls.CamForward) then
		positionUpdate = positionUpdate + _var.freecam.forwardVector
	end
	if isControlPressed(Config.Controls.CamBackward) then
		positionUpdate = positionUpdate - _var.freecam.forwardVector
	end
	if isControlPressed(Config.Controls.CamLeft) then
		positionUpdate = positionUpdate - right
	end
	if isControlPressed(Config.Controls.CamRight) then
		positionUpdate = positionUpdate + right
	end
	if isControlPressed(Config.Controls.CamUp) then
		positionUpdate = positionUpdate + vector3(0.0, 0.0, 1.0)
	end
	if isControlPressed(Config.Controls.CamDown) then
		positionUpdate = positionUpdate - vector3(0.0, 0.0, 1.0)
	end
	local newPosition = position + positionUpdate * speedModifier * _var.settings.cameraSpeed
	SetCamCoord(cam, newPosition.x, newPosition.y, newPosition.z)

	-- Camera rotation control
	local rightAxisX = GetDisabledControlNormal(0, 220)
	local rightAxisY = GetDisabledControlNormal(0, 221)
	if not _var.editor.cursorMode and (rightAxisX ~= 0.0 or rightAxisY ~= 0.0) then
		local newX = math.max(-89.0, math.min(89.0, rotation.x - rightAxisY * _var.freecam.mouseSensitivity))
		local newZ = rotation.z - rightAxisX * _var.freecam.mouseSensitivity
		SetCamRot(cam, newX, 0.0, newZ, 2)
	end
end
_threads.freecam.disable = function()
	if not _threads.freecam.isActivated then
		return
	end
	_threads.freecam.isActivated = false
	local ped = PlayerPedId()
	RenderScriptCams(false, false, 0, true, true)
	if _var.freecam.cam then
		DestroyCam(_var.freecam.cam, false)
		_var.freecam.cam = nil
	end
	FreezeEntityPosition(ped, false)
	SetEntityVisible(ped, true, false)
	SetEntityCollision(ped, true, true)
	SetEntityInvincible(ped, false)
	local coords = GetEntityCoords(ped)
	SetEntityRotation(ped, 0.0, 0.0, GetEntityHeading(ped), 2, true)
	SetEntityCoords(ped, coords.x, coords.y, coords.z - (GetEntityHeightAboveGround(ped) - 1.0), false, false, false, false)
end

-- Thread initialization
-- Thread → Editor
_threads.editor.isActivated = false
_threads.editor.generation = 0
_threads.editor.enable = function()
	if _threads.editor.isActivated then
		return
	end
	_threads.editor.isActivated = true
	_threads.editor.generation = _threads.editor.generation + 1
	local generation = _threads.editor.generation
	Citizen.CreateThread(function()
		while _threads.editor.isActivated and generation == _threads.editor.generation do
			_threads.editor.update()
			Citizen.Wait(0)
		end
	end)
end
_threads.editor.update = function()
	local states = _var.editor.states
	local selected = _var.editor.selected
	local cam = _var.freecam.cam
	if not cam then
		return
	end
	if selected and not DoesEntityExist(selected.handle) then
		selected = nil
	end

	-- Cursor mode (used by the gizmo when an entity is selected, disabled while looking around)
	setCursorMode(_var.editor.state == states.selected and _var.settings.useGizmo and selected ~= nil and not _var.editor.isLooking and not _var.freecam.isPaused)

	-- Outline of the selected entity
	setEntityOutline(selected and selected.handle or nil)

	-- Crosshair
	if not _var.editor.cursorMode then
		drawCrosshair()
	end

	-- Entities counts
	if _var.settings.showInfoBars then
		drawTimerBars({
			{ _U("infobar_objects"), tostring(#_var.map.current.props) },
			{ _U("infobar_peds"), tostring(#_var.map.current.peds) },
			{ _U("infobar_vehicles"), tostring(#_var.map.current.vehicles) },
			{ _U("infobar_camera_speed"), _var.menu.cameraSpeedArray[_var.menu.cameraSpeedArrayIndex] },
		})
	end

	-- Bounding box of the selected entity
	if _var.settings.showBoundingBox and selected then
		drawEntityBox(selected.handle, 255, 0, 0)
	end

	-- Instructional buttons
	if _var.settings.showInstructionalButtons then
		local buttons = {}
		if _var.editor.state == states.flying then
			buttons = {
				{ getInstructionalButton(Config.Controls.VehicleCreate), _U("button_vehicle") },
				{ getInstructionalButton(Config.Controls.PedCreate), _U("button_ped") },
				{ getInstructionalButton(Config.Controls.ObjectCreate), _U("button_object") },
				{ getInstructionalButton(Config.Controls.SelectEntity), _U("button_select_entity") },
				{ getInstructionalButton(Config.Controls.ScrollUp), _U("button_camera_speed") },
			}
		elseif _var.editor.state == states.adding then
			buttons = {
				{ getInstructionalButton(Config.Controls.CancelAdding), _U("button_cancel") },
				{ getInstructionalButton(Config.Controls.RotateCW), "" },
				{ getInstructionalButton(Config.Controls.RotateACW), _U("button_rotate") },
				{ getInstructionalButton(Config.Controls.ScrollUp), _U("button_rotate_15") },
				{ getInstructionalButton(Config.Controls.AlignItem), _U("button_align") },
				{ getInstructionalButton(Config.Controls.StampModifier), _U("button_stamp") },
				{ getInstructionalButton(Config.Controls.PlaceItem), "" },
				{ getInstructionalButton(Config.Controls.SelectEntity), _U("button_place") },
			}
		elseif _var.editor.state == states.selected then
			showHelpText(
				_U(
					"helptext_selected",
					getControlHelpToken(Config.Controls.ChangeTranslationMode),
					getControlHelpToken(Config.Controls.ChangeRotationAxis),
					getControlHelpToken(Config.Controls.RotateOverAngle),
					getControlHelpToken(Config.Controls.FreemoveEntity),
					getControlHelpToken(Config.Controls.SnapToGround),
					getControlHelpToken(Config.Controls.CloneEntity)
				)
			)
			buttons = {
				{ getInstructionalButton(Config.Controls.DeselectEntity), _U("button_deselect") },
				{ getInstructionalButton(Config.Controls.DeleteEntity), _U("button_delete") },
				{ getInstructionalButton(Config.Controls.EditEntity), _U("button_edit_entity") },
				{ getInstructionalButton(Config.Controls.TranslateZDown), "" },
				{ getInstructionalButton(Config.Controls.TranslateZUp), _U("button_translate") },
				{ getInstructionalButton(Config.Controls.RotateCW), "" },
				{ getInstructionalButton(Config.Controls.RotateACW), _U("button_rotate_axis", _U("rotation_mode_" .. _var.editor.rotationModes[_var.editor.rotationModeIndex])) },
			}
			if _var.settings.useGizmo then
				table.insert(buttons, { getKeyMappingButton("+epyi_mapeditor_look"), _U("button_look_around") })
				table.insert(buttons, { getKeyMappingButton("epyi_mapeditor_gizmo_mode"), _U("button_gizmo_mode", _U("gizmo_mode_" .. _var.editor.gizmo.mode)) })
			end
		end
		local signature = ""
		for _, button in ipairs(buttons) do
			signature = signature .. button[1] .. button[2]
		end
		if signature ~= _var.instructionnal.signature then
			_var.instructionnal.signature = signature
			setInstructionnalButtons(buttons, 0)
		end
		drawInstructionnalButtons()
	end

	-- Raycast from the camera to find the 3D cursor position
	local camPosition = GetCamCoord(cam)
	local castTo = camPosition + _var.freecam.forwardVector * 150.0
	local shapeTest = StartExpensiveSynchronousShapeTestLosProbe(camPosition.x, camPosition.y, camPosition.z, castTo.x, castTo.y, castTo.z, -1, selected and selected.handle or 0, 7)
	local _result, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(shapeTest)
	local rayHit = hit == true or hit == 1
	local hitEntity = (rayHit and isValidEntity(entityHit)) and entityHit or nil
	_var.editor.cursorPosition = rayHit and endCoords or castTo
	_var.editor.ray = { hit = rayHit, entity = hitEntity, surfaceNormal = surfaceNormal }
	local cursorPosition = _var.editor.cursorPosition

	-- 3D cursor
	if _var.settings.show3DCursor then
		local maxDimensions = vector3(0.0, 0.0, 0.0)
		if selected then
			local _minDimensions
			_minDimensions, maxDimensions = getEntityDimensions(selected.handle)
		end
		local cursorProp = _var.editor.cursorProp
		if cursorProp and DoesEntityExist(cursorProp) then
			if _var.editor.state == states.flying then
				if IsEntityAttached(cursorProp) then
					DetachEntity(cursorProp, false, false)
				end
				SetEntityCoordsNoOffset(cursorProp, cursorPosition.x, cursorPosition.y, cursorPosition.z, false, false, false)
				SetEntityHeading(cursorProp, GetCamRot(cam, 2).z)
			end
		else
			local hash = getModelHash(_var.editor.cursorModel)
			if requestModel(hash) then
				cursorProp = CreateObject(hash, cursorPosition.x, cursorPosition.y, cursorPosition.z, false, false, false)
				SetModelAsNoLongerNeeded(hash)
				SetEntityVisible(cursorProp, false, false)
				SetEntityCollision(cursorProp, false, false)
				_var.editor.cursorProp = cursorProp
			end
		end
		if cursorProp and DoesEntityExist(cursorProp) then
			if _var.editor.state == states.flying then
				SetEntityLocallyVisible(cursorProp)
				if hitEntity then
					drawMarker(25, cursorPosition + vector3(0.0, 0.0, 0.09), vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0), vector3(4.0, 4.0, 4.0), 163, 255, 183)
					drawEntityBox(hitEntity, 0, 0, 255)
				else
					drawMarker(25, cursorPosition + vector3(0.0, 0.0, 0.09), vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0), vector3(4.0, 4.0, 4.0), 255, 255, 255)
				end
			elseif (_var.editor.state == states.adding or _var.editor.state == states.selected) and selected then
				SetEntityLocallyVisible(cursorProp)
				AttachEntityToEntity(cursorProp, selected.handle, 0, 0.0, 0.0, maxDimensions.z, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
			end
		end
	end

	-- XYZ axes of the selected entity
	if _var.settings.showXYZAxis and _var.editor.state == states.selected and selected and not _var.settings.useGizmo then
		local minDimensions, maxDimensions = getEntityDimensions(selected.handle)
		local dimensions = (maxDimensions - minDimensions) / 2
		local position = GetEntityCoords(selected.handle)
		if _var.settings.relativeTranslation then
			local right, forward, up = getEntityVectors(selected.handle)
			drawLine(position, position + right * (2 + dimensions.x), 255, 0, 0)
			drawLine(position, position + forward * (2 + dimensions.y), 0, 255, 0)
			drawLine(position, position + up * (2 + dimensions.z), 0, 0, 255)
		else
			drawLine(position, position + vector3(dimensions.x, 0.0, 0.0), 255, 0, 0)
			drawLine(position, position + vector3(0.0, dimensions.y, 0.0), 0, 255, 0)
			drawLine(position, position + vector3(0.0, 0.0, dimensions.z), 0, 0, 255)
		end
	end

	-- Rotation axis markers of the selected entity (code courtesy of Rockstar North)
	if _var.settings.showSelectionMarker and _var.editor.state == states.selected and selected then
		local markerRotation = vector3(-90.0, 0.0, 0.0)
		local markerScale = vector3(1.0, 1.0, 1.0)
		local markerOffset = 1.25
		local minDimensions, maxDimensions = getEntityDimensions(selected.handle)
		local size = maxDimensions - minDimensions
		local absoluteSize = vector3(math.abs(size.x), math.abs(size.y), math.abs(size.z))
		local biggestSize = 1.0
		if absoluteSize.x > absoluteSize.y and absoluteSize.x > absoluteSize.z then
			biggestSize = absoluteSize.x
		elseif absoluteSize.y > absoluteSize.x and absoluteSize.y > absoluteSize.z then
			biggestSize = absoluteSize.y
		elseif absoluteSize.z > absoluteSize.x and absoluteSize.z > absoluteSize.y then
			biggestSize = absoluteSize.z
		end
		if biggestSize > 10.0 then
			local factor = biggestSize / 10.0
			markerScale = markerScale * factor
			markerOffset = markerOffset * factor
		end
		local position = GetEntityCoords(selected.handle)
		local rotationMode = _var.editor.rotationModes[_var.editor.rotationModeIndex]
		local axis, firstOffset, secondOffset
		if rotationMode == "pitch" then
			axis = GetOffsetFromEntityInWorldCoords(selected.handle, 1.0, 0.0, 0.0) - position
			firstOffset = vector3(maxDimensions.x + markerOffset, 0.0, 0.0)
			secondOffset = vector3(minDimensions.x - markerOffset, 0.0, 0.0)
		elseif rotationMode == "roll" then
			axis = GetOffsetFromEntityInWorldCoords(selected.handle, 0.0, 1.0, 0.0) - position
			firstOffset = vector3(0.0, maxDimensions.y + markerOffset, 0.0)
			secondOffset = vector3(0.0, minDimensions.y - markerOffset, 0.0)
		else
			axis = GetOffsetFromEntityInWorldCoords(selected.handle, 0.0, 0.0, 1.0) - position
			firstOffset = vector3(0.0, 0.0, maxDimensions.z + markerOffset)
			secondOffset = vector3(0.0, 0.0, minDimensions.z - markerOffset)
		end
		drawMarker(0, GetOffsetFromEntityInWorldCoords(selected.handle, firstOffset.x, firstOffset.y, firstOffset.z), axis, markerRotation, markerScale, 0, 255, 0)
		drawMarker(0, GetOffsetFromEntityInWorldCoords(selected.handle, secondOffset.x, secondOffset.y, secondOffset.z), -axis, markerRotation, markerScale, 0, 0, 255)
	end

	-- Gizmo of the selected entity
	if _var.editor.state == states.selected and selected and _var.settings.useGizmo then
		syncGizmoSpace()
		drawGizmo(selected.handle)
	end

	-- Speed control
	local speedModifier = 0.8
	if isControlPressed(Config.Controls.GottaGoFast) then
		speedModifier = 2.0
	elseif isControlPressed(Config.Controls.GottaGoSlow) then
		speedModifier = 0.03
	end

	-- Controls
	if _var.menus.editor.isOpened or _var.freecam.isPaused or GetFrameCount() - _var.menus.closedFrame <= 1 then
		return
	end
	if _var.editor.state == states.flying then
		-- Camera speed
		if not isSpawnMenuVisible() then
			local scroll = (isControlJustPressed(Config.Controls.ScrollUp) and 1 or 0) - (isControlJustPressed(Config.Controls.ScrollDown) and 1 or 0)
			if scroll ~= 0 then
				setCameraSpeedIndex(_var.menu.cameraSpeedArrayIndex + scroll)
			end
		end

		-- Selection
		if isControlJustPressed(Config.Controls.SelectEntity) and hitEntity then
			local record = mapFindEntity(hitEntity)
			if record then
				selectEntity(record)
			end
		end

		-- Spawn menus
		if isControlJustPressed(Config.Controls.ObjectCreate) then
			openSpawnMenu("objects")
		end
		if isControlJustPressed(Config.Controls.PedCreate) then
			openSpawnMenu("peds")
		end
		if isControlJustPressed(Config.Controls.VehicleCreate) then
			openSpawnMenu("vehicles")
		end
	elseif _var.editor.state == states.adding then
		if not selected then
			if isControlJustPressed(Config.Controls.CancelAdding) then
				cancelObjectAdding(true)
			end
			return
		end
		SetEntityCoordsNoOffset(selected.handle, cursorPosition.x, cursorPosition.y, cursorPosition.z, true, true, true)

		-- Cancelling
		if isControlJustPressed(Config.Controls.CancelAdding) then
			cancelObjectAdding(true)
			return
		end

		-- Alignment
		if isControlJustPressed(Config.Controls.AlignItem) then
			alignEntity(selected.handle)
		end

		-- Placing (hold the stamp modifier to keep adding the same object)
		if isControlJustPressed(Config.Controls.PlaceItem) or isControlJustPressed(Config.Controls.SelectEntity) then
			placeObject(isControlPressed(Config.Controls.StampModifier))
			return
		end

		-- Rotation
		local rotation = quaternionFromYawPitchRoll(0.0, 0.0, 0.03 * speedModifier)
		if isControlPressed(Config.Controls.RotateCW) then
			rotateEntity(selected.handle, rotation)
		end
		if isControlPressed(Config.Controls.RotateACW) then
			rotateEntity(selected.handle, quaternionInvert(rotation))
		end
		if isControlJustPressed(Config.Controls.ScrollUp) then
			rotateEntity(selected.handle, quaternionFromYawPitchRoll(0.0, 0.0, math.rad(15.0)))
		end
		if isControlJustPressed(Config.Controls.ScrollDown) then
			rotateEntity(selected.handle, quaternionFromYawPitchRoll(0.0, 0.0, math.rad(-15.0)))
		end
	elseif _var.editor.state == states.selected then
		if not selected then -- if, for some reason, the selected entity doesn't exist anymore
			if _var.editor.selected and mapContainsEntity(_var.editor.selected) then
				mapRemoveEntity(_var.editor.selected)
			end
			closeSpawnMenu()
			_var.editor.selected = nil
			_var.editor.state = states.flying
			return
		end
		if isSpawnMenuVisible() then -- the controls are used by the entity menu
			return
		end

		-- Deselecting
		if isControlJustPressed(Config.Controls.DeselectEntity) then
			deselectEntity()
			return
		end

		-- Spawn menus (the entity is deselected first)
		for control, menu in pairs({ [Config.Controls.ObjectCreate] = "objects", [Config.Controls.PedCreate] = "peds", [Config.Controls.VehicleCreate] = "vehicles" }) do
			if isControlJustPressed(control) then
				deselectEntity()
				openSpawnMenu(menu)
				return
			end
		end

		-- Entity menu
		if isControlJustPressed(Config.Controls.EditEntity) then
			openSpawnMenuNextFrame("entity")
			return
		end

		-- Translation mode (relative - absolute)
		if isControlJustPressed(Config.Controls.ChangeTranslationMode) then
			_var.settings.relativeTranslation = not _var.settings.relativeTranslation
		end

		-- Rotation axis
		if isControlJustPressed(Config.Controls.ChangeRotationAxis) then
			_var.editor.rotationModeIndex = _var.editor.rotationModeIndex % #_var.editor.rotationModes + 1
		end
		local rotationMode = _var.editor.rotationModes[_var.editor.rotationModeIndex]

		-- Snap to ground
		if isControlJustPressed(Config.Controls.SnapToGround) then
			snapEntityToGround(selected.handle)
		end

		-- Cloning (when the clone key is pressed, no other translation/rotation is allowed)
		if isControlPressed(Config.Controls.CloneEntity) then
			if isControlJustPressed(Config.Controls.TranslateYUp) or isControlJustPressed(Config.Controls.TranslateYDown) then
				local movement = getCloneMovement(selected.handle, rotationMode)
				if isControlJustPressed(Config.Controls.TranslateYDown) then
					movement = -movement
				end
				cloneEntity(selected, movement)
			end
			return
		end

		-- Free dragging/moving
		if isControlPressed(Config.Controls.FreemoveEntity) then
			SetEntityCoords(selected.handle, cursorPosition.x, cursorPosition.y, cursorPosition.z, false, false, false, false)
			if isControlJustPressed(Config.Controls.AlignItem) then
				alignEntity(selected.handle)
			end
		end

		-- Rotate over 15°
		if isControlJustPressed(Config.Controls.RotateOverAngle) then
			if rotationMode == "pitch" then
				rotateEntity(selected.handle, quaternionFromYawPitchRoll(0.0, math.rad(15.0), 0.0))
			elseif rotationMode == "roll" then
				rotateEntity(selected.handle, quaternionFromYawPitchRoll(math.rad(15.0), 0.0, 0.0))
			else
				rotateEntity(selected.handle, quaternionFromYawPitchRoll(0.0, 0.0, math.rad(15.0)))
			end
		end

		-- Rotation
		local rotation
		if rotationMode == "roll" then
			rotation = quaternionFromYawPitchRoll(0.03 * speedModifier, 0.0, 0.0)
		elseif rotationMode == "pitch" then
			rotation = quaternionFromYawPitchRoll(0.0, 0.03 * speedModifier, 0.0)
		else
			rotation = quaternionFromYawPitchRoll(0.0, 0.0, 0.03 * speedModifier)
		end
		if isControlPressed(Config.Controls.RotateCW) then
			rotateEntity(selected.handle, rotation)
		end
		if isControlPressed(Config.Controls.RotateACW) then
			rotateEntity(selected.handle, quaternionInvert(rotation))
		end

		-- Translation
		local translation = vector3(0.0, 0.0, 0.0)
		local right, forward, up = vector3(1.0, 0.0, 0.0), vector3(0.0, 1.0, 0.0), vector3(0.0, 0.0, 1.0)
		if _var.settings.relativeTranslation then
			right, forward, up = getEntityVectors(selected.handle)
		end
		if isControlPressed(Config.Controls.TranslateXUp) then
			translation = translation + right
		end
		if isControlPressed(Config.Controls.TranslateXDown) then
			translation = translation - right
		end
		if isControlPressed(Config.Controls.TranslateYUp) then
			translation = translation + forward
		end
		if isControlPressed(Config.Controls.TranslateYDown) then
			translation = translation - forward
		end
		if isControlPressed(Config.Controls.TranslateZUp) then
			translation = translation + up
		end
		if isControlPressed(Config.Controls.TranslateZDown) then
			translation = translation - up
		end
		if translation ~= vector3(0.0, 0.0, 0.0) then
			local newPosition = GetEntityCoords(selected.handle) + translation * speedModifier
			SetEntityCoordsNoOffset(selected.handle, newPosition.x, newPosition.y, newPosition.z, true, true, true)
		end

		-- Deletion
		if isControlJustPressed(Config.Controls.DeleteEntity) then
			deleteSelectedEntity()
		end
	end
end
_threads.editor.disable = function()
	_threads.editor.isActivated = false
	_var.editor.state = _var.editor.states.inactive
	_var.instructionnal.signature = nil
	_var.editor.isLooking = false
	setCursorMode(false)
	setEntityOutline(nil)
end

---enterEditor → Enable the freecam and the editor
---@return void
function enterEditor()
	if _var.editor.state ~= _var.editor.states.inactive then
		return
	end
	_threads.freecam.enable()
	_var.editor.state = _var.editor.states.flying
	_threads.editor.enable()
end

---exitEditor → Disable the freecam and the editor
---@return void
function exitEditor()
	if _var.editor.state == _var.editor.states.inactive then
		return
	end
	resetEditorSelection()
	closeSpawnMenu()
	deleteCursorProp()
	_threads.editor.disable()
	_threads.freecam.disable()
end

---deleteCursorProp → Delete the 3D cursor prop
---@return void
function deleteCursorProp()
	if _var.editor.cursorProp and DoesEntityExist(_var.editor.cursorProp) then
		DeleteEntity(_var.editor.cursorProp)
	end
	_var.editor.cursorProp = nil
end

---selectEntity → Select an entity of the map
---@param record table
---@return void
function selectEntity(record)
	if _var.editor.state == _var.editor.states.adding then
		cancelObjectAdding()
	elseif _var.editor.state == _var.editor.states.selected then
		deselectEntity()
	end
	closeSpawnMenu()
	if record.type ~= "prop" then
		setupEditorEntity(record)
	end
	_var.editor.selected = record
	_var.editor.state = _var.editor.states.selected
end

---deselectEntity → Deselect the selected entity
---@return void
function deselectEntity()
	local selected = _var.editor.selected
	deleteCursorProp()
	_var.editor.isLooking = false
	if selected and DoesEntityExist(selected.handle) and selected.type ~= "prop" then
		FreezeEntityPosition(selected.handle, false)
	end
	_var.editor.selected = nil
	_var.editor.state = _var.editor.states.flying
end

---deleteSelectedEntity → Delete the selected entity from the map
---@return void
function deleteSelectedEntity()
	local selected = _var.editor.selected
	if not selected then
		return
	end
	closeSpawnMenu()
	if mapContainsEntity(selected) then
		mapRemoveEntity(selected)
	end
	deleteMapEntity(selected)
	_var.editor.selected = nil
	_var.editor.state = _var.editor.states.flying
end

---resetEditorSelection → Cancel the object being added or deselect the selected entity
---@return void
function resetEditorSelection()
	if _var.editor.state == _var.editor.states.adding then
		cancelObjectAdding()
	elseif _var.editor.state == _var.editor.states.selected then
		closeSpawnMenu()
		deselectEntity()
	end
end

---alignEntity → Align an entity on the entity or the surface under the cursor
---@param handle integer
---@return void
function alignEntity(handle)
	if not _var.editor.ray.hit then
		return
	end
	if _var.editor.ray.entity then
		copyEntityQuaternion(_var.editor.ray.entity, handle)
	else
		local rotation = directionToRotation(_var.editor.ray.surfaceNormal, 0.0) + vector3(-90.0, 0.0, 0.0)
		SetEntityRotation(handle, rotation.x, rotation.y, rotation.z, 2, true)
	end
end

---getCloneMovement → Get the offset of a clone according to the rotation axis
---@param handle integer
---@param rotationMode string
---@return vector3
function getCloneMovement(handle, rotationMode)
	local minDimensions, maxDimensions = getEntityDimensions(handle)
	local dimensions = maxDimensions - minDimensions
	local right, forward, up = getEntityVectors(handle)
	if rotationMode == "pitch" then
		return right * dimensions.x
	elseif rotationMode == "roll" then
		return forward * dimensions.y
	end
	return up * dimensions.z
end

---cloneEntity → Clone the selected entity with an offset and select the clone
---@param record table
---@param movement vector3
---@return void
function cloneEntity(record, movement)
	local model = record.model or GetEntityModel(record.handle)
	local position = GetEntityCoords(record.handle) + movement
	local clone
	if record.type == "ped" then
		clone = createPed(model, position, GetEntityHeading(record.handle), GetPedType(record.handle), _var.settings.networkObjects)
	elseif record.type == "prop" then
		clone = createProp(model, position, GetEntityRotation(record.handle, 2), record.textureVariant, _var.settings.networkObjects, false)
	elseif record.type == "vehicle" then
		clone = createVehicle(model, position, GetEntityHeading(record.handle), _var.settings.networkObjects)
	end
	if not clone then
		showNotification(_U("notif_entity_not_created"), 6)
		return
	end
	if clone.type ~= "prop" then
		setupEditorEntity(clone)
	else
		copyEntityQuaternion(record.handle, clone.handle)
	end
	mapAddEntity(clone)
	_var.editor.selected = clone
end
