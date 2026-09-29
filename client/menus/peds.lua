---getPedCategoryIndex → Get the category of a ped model with the prefix of its name
---@param model string
---@return integer
local function getPedCategoryIndex(model)
	for index, category in ipairs(_var.peds.categories) do
		for _, prefix in ipairs(category.prefixes) do
			if model:sub(1, #prefix) == prefix then
				return index
			end
		end
	end
	return #_var.peds.categories
end

---loadPedsList → Load the list of the ped models available in the game
---@return void
local function loadPedsList()
	if _var.peds.isLoaded then
		return
	end
	_var.peds.isLoaded = true
	_var.peds.categoriesLabels = { _("peds_category_all") }
	for _, category in ipairs(_var.peds.categories) do
		table.insert(_var.peds.categoriesLabels, _(category.label))
	end
	for _, model in ipairs(_var.peds.list) do
		local hash = getModelHash(model)
		if IsModelInCdimage(hash) and IsModelAPed(hash) then
			table.insert(_var.peds.models, { model = model, hash = hash, categoryIndex = getPedCategoryIndex(model) })
		end
	end
end

---spawnPed → Create a ped at the crosshair position and select it
---@param ped table
---@return void
local function spawnPed(ped)
	Citizen.CreateThread(function()
		local record = createPed(ped.model, _var.editor.cursorPosition, GetCamRot(_var.freecam.cam, 2).z + 180.0, 26, _var.settings.networkObjects)
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

---peds_showContentThisFrame → Function to show the peds menu content
---@return void
function peds_showContentThisFrame()
	loadPedsList()
	RageUI.ButtonWithStyle(
		_U("search"),
		_U("peds_filter_desc"),
		{
			RightLabel = (_var.menu.pedsFilter ~= "" and _var.menu.pedsFilter or _U("no_filter")),
		},
		true,
		function(_h, _a, Selected)
			if Selected then
				local search = textEntry(_U("textentry_search"), _var.menu.pedsFilter, 30)
				_var.menu.pedsFilter = search or ""
				resetSpawnMenuIndex("peds")
			end
		end
	)
	RageUI.List(_U("peds_category"), _var.peds.categoriesLabels, _var.menu.pedsCategoryArrayIndex, _U("peds_category_desc"), {}, true, function(_h, _a, _s, Index)
		if Index ~= _var.menu.pedsCategoryArrayIndex then
			_var.menu.pedsCategoryArrayIndex = Index
			resetSpawnMenuIndex("peds")
		end
	end)
	RageUI.Separator(_U("filter_result"))
	local filter = string.lower(_var.menu.pedsFilter)
	local categoryIndex = _var.menu.pedsCategoryArrayIndex - 1
	local count = 0
	for _k, ped in ipairs(_var.peds.models) do
		if (categoryIndex < 1 or ped.categoryIndex == categoryIndex) and (filter == "" or string.find(ped.model, filter, 1, true) ~= nil) then
			count = count + 1
			RageUI.ButtonWithStyle(ped.model, _U("peds_spawn_desc", ped.model), { RightBadge = RageUI.BadgeStyle.Franklin }, true, function(_h, _a, Selected)
				if Selected then
					spawnPed(ped)
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
