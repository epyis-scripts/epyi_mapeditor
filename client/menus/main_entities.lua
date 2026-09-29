local sections = {
	{ list = "props", label = "main_entities_objects" },
	{ list = "peds", label = "main_entities_peds" },
	{ list = "vehicles", label = "main_entities_vehicles" },
}

---focusEntity → Move the camera in front of an entity of the map and select it
---@param record table
---@return void
local function focusEntity(record)
	_var.menus.editor.isOpened = false
	_var.menus.closedFrame = GetFrameCount()
	enterEditor()
	local position = GetEntityCoords(record.handle)
	local minDimensions, maxDimensions = getEntityDimensions(record.handle)
	local size = #(maxDimensions - minDimensions)
	local camPosition = position + vector3(0.0, -(size * 1.2 + 3.0), size * 0.6 + 2.0)
	local rotation = directionToRotation(position - camPosition, 0.0)
	SetCamCoord(_var.freecam.cam, camPosition.x, camPosition.y, camPosition.z)
	SetCamRot(_var.freecam.cam, rotation.x, 0.0, rotation.z, 2)
	selectEntity(record)
end

---main_entities_showContentThisFrame → Function to show the main/entities menu content
---@return void
function main_entities_showContentThisFrame()
	local count = 0
	for _, section in ipairs(sections) do
		local list = _var.map.current[section.list]
		if #list > 0 then
			RageUI.Separator(_U(section.label, #list))
		end
		for index, record in ipairs(list) do
			if DoesEntityExist(record.handle) then
				count = count + 1
				local name = getEntityName(record)
				RageUI.ButtonWithStyle(name .. " ~c~#" .. index, _U("main_entities_select_desc", name), { RightLabel = "→" }, true, function(_h, _a, Selected)
					if Selected then
						focusEntity(record)
					end
				end)
			end
		end
	end
	if count == 0 then
		RageUI.Separator("")
		RageUI.Separator(_U("no_result"))
		RageUI.Separator("")
	end
end
