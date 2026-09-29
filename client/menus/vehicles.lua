---loadVehiclesList → Load the list of the vehicle models available in the game
---@return void
local function loadVehiclesList()
	if _var.vehicles.isLoaded then
		return
	end
	_var.vehicles.isLoaded = true
	for _, model in ipairs(GetAllVehicleModels()) do
		local hash = getModelHash(model)
		table.insert(_var.vehicles.models, {
			model = string.lower(model),
			hash = hash,
			label = getLabel(GetDisplayNameFromVehicleModel(hash), string.lower(model)),
		})
	end
	table.sort(_var.vehicles.models, function(a, b)
		return a.model < b.model
	end)
end

---spawnVehicle → Create a vehicle at the 3D cursor position and select it
---@param vehicle table
---@return void
local function spawnVehicle(vehicle)
	Citizen.CreateThread(function()
		local record = createVehicle(vehicle.hash, _var.editor.cursorPosition, 0.0, _var.settings.networkObjects)
		if not record then
			showNotification(_U("notif_entity_not_created"), 6)
			return
		end
		if _var.editor.state ~= _var.editor.states.flying then
			deleteMapEntity(record)
			return
		end
		setupEditorEntity(record)
		mapAddEntity(record)
		_var.editor.selected = record
		_var.editor.state = _var.editor.states.selected
		closeSpawnMenu()
	end)
end

---vehicles_showContentThisFrame → Function to show the vehicles menu content
---@return void
function vehicles_showContentThisFrame()
	loadVehiclesList()
	RageUI.ButtonWithStyle(
		_U("search"),
		_U("vehicles_filter_desc"),
		{
			RightLabel = (_var.menu.vehiclesFilter ~= "" and _var.menu.vehiclesFilter or _U("no_filter")),
		},
		true,
		function(_h, _a, Selected)
			if Selected then
				local search = textEntry(_U("textentry_search"), _var.menu.vehiclesFilter, 30)
				if search == nil or search == "" then
					_var.menu.vehiclesFilter = ""
					return
				end
				_var.menu.vehiclesFilter = search
			end
		end
	)
	RageUI.Separator(_U("filter_result"))
	local count = 0
	for _k, vehicle in ipairs(_var.vehicles.models) do
		if _var.menu.vehiclesFilter == "" or string.find(string.lower(vehicle.label .. vehicle.model), string.lower(_var.menu.vehiclesFilter), 1, true) ~= nil then
			count = count + 1
			RageUI.ButtonWithStyle(vehicle.label .. " ~c~[" .. vehicle.model .. "]", _U("vehicles_spawn_desc", vehicle.label), { RightBadge = RageUI.BadgeStyle.Car }, true, function(_h, _a, Selected)
				if Selected then
					spawnVehicle(vehicle)
				end
			end)
		end
	end
	if count == 0 then
		RageUI.Separator("")
		RageUI.Separator(_U("no_result"))
		RageUI.Separator("")
	end
end
