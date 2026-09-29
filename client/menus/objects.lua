local objectRequestId = 0
local recentKvp = "epyi_mapeditor:recentProps"

---loadPropsList → Build the list of the props and their categories (once the game texts are loaded)
---@return void
local function loadPropsList()
	if _var.props.list then
		return
	end
	_var.props.list = {}
	_var.props.byModel = {}
	_var.props.coloredFamilies = {}
	_var.props.categoriesLabels = { _("objects_category_all"), _("objects_category_recent") }
	for categoryIndex, category in ipairs(_var.props.categories) do
		table.insert(_var.props.categoriesLabels, getLabel(category.name, category.name))
		for _, prop in ipairs(category.props) do
			local model = tostring(prop.model)
			local entry = {
				model = model,
				label = getLabel(prop.label, model),
				categoryIndex = categoryIndex,
			}
			entry.search = string.lower(entry.label .. " " .. model)
			table.insert(_var.props.list, entry)
			_var.props.byModel[string.lower(model)] = entry
			if category.name == _var.props.coloredCategory then -- because R*, the color of these props is in their model name
				_var.props.coloredFamilies[string.lower(model):sub(1, -3)] = true
			end
		end
	end
	local recent = json.decode(GetResourceKvpString(recentKvp) or "[]")
	_var.props.recent = type(recent) == "table" and recent or {}
end

---addRecentProp → Add a prop model at the top of the recently used props
---@param model string
---@return void
local function addRecentProp(model)
	model = tostring(model)
	for index, recentModel in ipairs(_var.props.recent) do
		if string.lower(recentModel) == string.lower(model) then
			table.remove(_var.props.recent, index)
			break
		end
	end
	table.insert(_var.props.recent, 1, model)
	while #_var.props.recent > _var.props.recentMax do
		table.remove(_var.props.recent)
	end
	SetResourceKvp(recentKvp, json.encode(_var.props.recent))
end

---getPropLabel → Get the label of a prop model
---@param model string|integer
---@return string
function getPropLabel(model)
	loadPropsList()
	local entry = _var.props.byModel[string.lower(tostring(model))]
	return entry and entry.label or tostring(model)
end

---getColoredFamily → Get the family of a prop which has its color in its model name (because R*)
---@param model string|integer
---@return string|nil, integer|nil
function getColoredFamily(model)
	loadPropsList()
	if type(model) ~= "string" then
		return nil, nil
	end
	local family = string.lower(model):sub(1, -3)
	if not _var.props.coloredFamilies[family] then
		return nil, nil
	end
	return family, tonumber(model:sub(-2, -2))
end

---selectNewObject → Replace the object being added by a new object model
---@param model string|integer
---@param rotation vector3
---@param textureVariant integer
---@return void
function selectNewObject(model, rotation, textureVariant)
	objectRequestId = objectRequestId + 1
	local requestId = objectRequestId
	Citizen.CreateThread(function()
		local hash = getModelHash(model)
		if not requestModel(hash) then
			if requestId == objectRequestId then
				showNotification(_U("notif_entity_not_created"), 6)
				cancelObjectAdding(false)
			end
			return
		end
		if requestId ~= objectRequestId or _var.editor.state ~= _var.editor.states.adding then
			return
		end
		if _var.editor.selected then
			deleteMapEntity(_var.editor.selected)
		end
		_var.editor.selected = createProp(model, _var.editor.cursorPosition, rotation or vector3(0.0, 0.0, 0.0), textureVariant or 0, _var.settings.networkObjects, false)
	end)
end

---startAddingObject → Close the objects menu and add an object at the crosshair position
---@param model string
---@return void
function startAddingObject(model)
	closeSpawnMenu()
	if _var.editor.state == _var.editor.states.selected then
		deselectEntity()
	end
	_var.editor.state = _var.editor.states.adding
	_var.props.addingModel = model
	selectNewObject(model, vector3(0.0, 0.0, 0.0), 0)
end

---placeObject → Place the object being added in the map
---@param keepAdding boolean
---@return void
function placeObject(keepAdding)
	local placed = _var.editor.selected
	if not placed then
		return
	end
	mapAddEntity(placed)
	addRecentProp(_var.props.addingModel)
	if keepAdding then
		_var.editor.selected = nil
		selectNewObject(_var.props.addingModel, GetEntityRotation(placed.handle, 2), placed.textureVariant)
		return
	end
	_var.editor.state = _var.editor.states.selected
end

---cancelObjectAdding → Delete the object being added and go back to the flying mode
---@param reopenMenu boolean
---@return void
function cancelObjectAdding(reopenMenu)
	if _var.editor.state ~= _var.editor.states.adding then
		return
	end
	objectRequestId = objectRequestId + 1
	if _var.editor.selected then
		deleteMapEntity(_var.editor.selected)
	end
	_var.editor.selected = nil
	_var.editor.state = _var.editor.states.flying
	if reopenMenu then
		openSpawnMenu("objects")
	end
end

---objects_showContentThisFrame → Function to show the objects menu content
---@return void
function objects_showContentThisFrame()
	loadPropsList()
	RageUI.ButtonWithStyle(
		_U("search"),
		_U("objects_filter_desc"),
		{
			RightLabel = (_var.menu.objectsFilter ~= "" and _var.menu.objectsFilter or _U("no_filter")),
		},
		true,
		function(_h, _a, Selected)
			if Selected then
				local search = textEntry(_U("textentry_search"), _var.menu.objectsFilter, 30)
				_var.menu.objectsFilter = search or ""
				resetSpawnMenuIndex("objects")
			end
		end
	)
	RageUI.List(_U("objects_category"), _var.props.categoriesLabels, _var.menu.objectsCategoryArrayIndex, _U("objects_category_desc"), {}, true, function(_h, _a, _s, Index)
		if Index ~= _var.menu.objectsCategoryArrayIndex then
			_var.menu.objectsCategoryArrayIndex = Index
			resetSpawnMenuIndex("objects")
		end
	end)
	RageUI.ButtonWithStyle(_U("objects_custom_model"), _U("objects_custom_model_desc"), { RightLabel = "→" }, true, function(_h, _a, Selected)
		if Selected then
			local model = textEntry(_U("textentry_model"), "", 60)
			if model == nil or model == "" then
				return
			end
			local hash = getModelHash(model)
			if not IsModelInCdimage(hash) or IsModelAVehicle(hash) or IsModelAPed(hash) then
				showNotification(_U("notif_invalid_model", model), 6)
				return
			end
			startAddingObject(model)
		end
	end)
	RageUI.Separator(_U("filter_result"))

	-- Props of the selected category (all, recently used or a R* creator category)
	local props = _var.props.list
	if _var.menu.objectsCategoryArrayIndex == 2 then
		props = {}
		for _, model in ipairs(_var.props.recent) do
			local entry = _var.props.byModel[string.lower(model)] or { model = model, label = model }
			if not entry.search then
				entry.search = string.lower(model)
			end
			table.insert(props, entry)
		end
	end
	local filter = string.lower(_var.menu.objectsFilter)
	local categoryIndex = _var.menu.objectsCategoryArrayIndex - 2
	local count = 0
	for _k, prop in ipairs(props) do
		if (categoryIndex < 1 or prop.categoryIndex == categoryIndex) and (filter == "" or string.find(prop.search, filter, 1, true) ~= nil) then
			count = count + 1
			RageUI.ButtonWithStyle(prop.label .. " ~m~→ ~c~" .. prop.model, _U("objects_spawn_desc", prop.label, prop.model), { RightBadge = RageUI.BadgeStyle.Michael }, true, function(_h, _a, Selected)
				if Selected then
					startAddingObject(prop.model)
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
