local axes = { "x", "y", "z" }

---askNumber → Open a popup to write a number
---@param title string
---@param value number
---@return number|nil
local function askNumber(title, value)
	local result = textEntry(title, string.format("%.3f", value), 20)
	if result == nil or result == "" then
		return nil
	end
	local number = tonumber((result:gsub(",", ".")))
	if not number then
		showNotification(_U("notif_invalid_number"), 6)
	end
	return number
end

---gizmoModesLabels → Get the labels of the gizmo modes
---@return table
function gizmoModesLabels()
	return { _U("gizmo_mode_translate"), _U("gizmo_mode_rotate") }
end

---getEntityName → Get the name of a map entity
---@param record table
---@return string
function getEntityName(record)
	local model = record.model
	if type(model) ~= "string" and DoesEntityExist(record.handle) then
		local archetypeName = GetEntityArchetypeName(record.handle)
		model = (archetypeName and archetypeName ~= "") and archetypeName or tostring(GetEntityModel(record.handle))
	end
	if record.type == "prop" then
		return getPropLabel(model)
	end
	return tostring(model)
end

---entity_showContentThisFrame → Function to show the selected entity menu content
---@return void
function entity_showContentThisFrame()
	local selected = _var.editor.selected
	if not selected or not DoesEntityExist(selected.handle) then
		RageUI.Separator("")
		RageUI.Separator(_U("no_result"))
		RageUI.Separator("")
		return
	end
	local handle = selected.handle
	local position = GetEntityCoords(handle)
	local rotation = GetEntityRotation(handle, 2)
	RageUI.Separator(_U("entity_type_" .. selected.type) .. " ~r~" .. getEntityName(selected))

	-- Gizmo
	if _var.settings.useGizmo then
		RageUI.List(_U("entity_gizmo_mode"), gizmoModesLabels(), _var.editor.gizmo.mode == "rotate" and 2 or 1, _U("entity_gizmo_mode_desc"), {}, true, function() end, function(Index)
			setGizmoMode(Index == 2 and "rotate" or "translate")
		end)
	end
	RageUI.Checkbox(_U("entity_relative_axes"), _U("entity_relative_axes_desc"), _var.settings.relativeTranslation, {}, function(_h, _a, _s, Checked)
		_var.settings.relativeTranslation = Checked
	end)

	-- Position and rotation
	for _, axis in ipairs(axes) do
		RageUI.ButtonWithStyle(_U("entity_position", string.upper(axis)), _U("entity_position_desc", string.upper(axis)), { RightLabel = ("%.2f"):format(position[axis]) }, true, function(_h, _a, Selected)
			if Selected then
				local value = askNumber(_U("entity_position", string.upper(axis)), position[axis])
				if value and DoesEntityExist(handle) then
					local current = GetEntityCoords(handle)
					local newPosition = { x = current.x, y = current.y, z = current.z }
					newPosition[axis] = value
					SetEntityCoordsNoOffset(handle, newPosition.x, newPosition.y, newPosition.z, true, true, true)
				end
			end
		end)
	end
	for _, axis in ipairs(axes) do
		RageUI.ButtonWithStyle(_U("entity_rotation", string.upper(axis)), _U("entity_rotation_desc", string.upper(axis)), { RightLabel = ("%.2f°"):format(rotation[axis]) }, true, function(_h, _a, Selected)
			if Selected then
				local value = askNumber(_U("entity_rotation", string.upper(axis)), rotation[axis])
				if value and DoesEntityExist(handle) then
					local current = GetEntityRotation(handle, 2)
					local newRotation = { x = current.x, y = current.y, z = current.z }
					newRotation[axis] = value
					SetEntityRotation(handle, newRotation.x, newRotation.y, newRotation.z, 2, true)
				end
			end
		end)
	end

	-- Color of the props
	if selected.type == "prop" then
		local family, colorIndex = getColoredFamily(selected.model)
		if family then -- because R*, the color of these props is in their model name
			local colors = {}
			for index = 0, _var.props.coloredCategoryColors - 1 do
				table.insert(colors, getLabel("MC_SR_PROP_C" .. index))
			end
			RageUI.List(_U("entity_color"), colors, colorIndex or 1, _U("entity_color_desc"), {}, true, function() end, function(Index)
				mapReplacePropModel(selected, family .. Index .. "a")
			end)
		else
			local colors = {}
			for _, label in ipairs(getPropColorLabels(selected.model or GetEntityModel(handle))) do
				table.insert(colors, getLabel(label))
			end
			if #colors > 0 then
				RageUI.List(_U("entity_color"), colors, math.min((selected.textureVariant or 0) + 1, #colors), _U("entity_color_desc"), {}, true, function() end, function(Index)
					selected.textureVariant = Index - 1
					SetObjectTextureVariant(handle, Index - 1)
				end)
			end
		end
	end

	-- Actions
	RageUI.ButtonWithStyle(_U("entity_snap_to_ground"), _U("entity_snap_to_ground_desc"), {}, true, function(_h, _a, Selected)
		if Selected then
			snapEntityToGround(handle)
		end
	end)
	RageUI.ButtonWithStyle(_U("entity_duplicate"), _U("entity_duplicate_desc"), {}, true, function(_h, _a, Selected)
		if Selected then
			cloneEntity(selected, getCloneMovement(handle, "pitch"))
		end
	end)
	RageUI.ButtonWithStyle(_U("entity_delete"), _U("entity_delete_desc"), { RightLabel = "~r~×" }, true, function(_h, _a, Selected)
		if Selected then
			deleteSelectedEntity()
		end
	end)
end
