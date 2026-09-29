---loadVehiclesList → Load the list of the vehicle models available in the game, sorted by class
---@return void
local function loadVehiclesList()
	if _var.vehicles.isLoaded then
		return
	end
	_var.vehicles.isLoaded = true
	local classes = {}
	for _, model in ipairs(GetAllVehicleModels()) do
		local hash = getModelHash(model)
		local class = GetVehicleClassFromName(hash)
		classes[class] = true
		table.insert(_var.vehicles.models, {
			model = string.lower(model),
			hash = hash,
			class = class,
			label = getLabel(GetDisplayNameFromVehicleModel(hash), string.lower(model)),
		})
	end
	table.sort(_var.vehicles.models, function(a, b)
		return a.model < b.model
	end)
	_var.vehicles.categoriesLabels = { _("vehicles_category_all") }
	for class = 0, 30 do
		if classes[class] then
			table.insert(_var.vehicles.classes, class)
			table.insert(_var.vehicles.categoriesLabels, getLabel("VEH_CLASS_" .. class, _("vehicles_category_class", class)))
		end
	end
end

---spawnVehicle → Create a vehicle at the crosshair position and select it
---@param vehicle table
---@return void
local function spawnVehicle(vehicle)
	Citizen.CreateThread(function()
		local record = createVehicle(vehicle.model, _var.editor.cursorPosition, GetCamRot(_var.freecam.cam, 2).z, _var.settings.networkObjects)
		if not record then
			showNotification(_U("notif_entity_not_created"), 6)
			return
		end
		if _var.editor.state ~= _var.editor.states.flying then
			deleteMapEntity(record)
			return
		end
		mapAddEntity(record)
		selectEntity(record)
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
				_var.menu.vehiclesFilter = search or ""
				resetSpawnMenuIndex("vehicles")
			end
		end
	)
	RageUI.List(_U("vehicles_category"), _var.vehicles.categoriesLabels, _var.menu.vehiclesCategoryArrayIndex, _U("vehicles_category_desc"), {}, true, function(_h, _a, _s, Index)
		if Index ~= _var.menu.vehiclesCategoryArrayIndex then
			_var.menu.vehiclesCategoryArrayIndex = Index
			resetSpawnMenuIndex("vehicles")
		end
	end)
	RageUI.Separator(_U("filter_result"))
	local filter = string.lower(_var.menu.vehiclesFilter)
	local class = _var.vehicles.classes[_var.menu.vehiclesCategoryArrayIndex - 1]
	local count = 0
	for _k, vehicle in ipairs(_var.vehicles.models) do
		if (class == nil or vehicle.class == class) and (filter == "" or string.find(string.lower(vehicle.label .. vehicle.model), filter, 1, true) ~= nil) then
			count = count + 1
			RageUI.ButtonWithStyle(vehicle.label .. " ~m~→ ~c~" .. vehicle.model, _U("vehicles_spawn_desc", vehicle.label), { RightBadge = RageUI.BadgeStyle.Car }, true, function(_h, _a, Selected)
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
