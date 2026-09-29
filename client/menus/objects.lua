local categoriesLabels = nil
local typesLabels = {}
local objectRequestId = 0

---getCategoriesLabels → Get the labels of the props categories
---@return table
local function getCategoriesLabels()
	if not categoriesLabels then
		categoriesLabels = {}
		for _, category in ipairs(_var.props.categories) do
			table.insert(categoriesLabels, getLabel(category.name, category.name))
		end
	end
	return categoriesLabels
end

---getTypesLabels → Get the labels of the props of a category
---@param categoryIndex integer
---@return table
local function getTypesLabels(categoryIndex)
	if not typesLabels[categoryIndex] then
		typesLabels[categoryIndex] = {}
		for _, prop in ipairs(_var.props.categories[categoryIndex].props) do
			table.insert(typesLabels[categoryIndex], getLabel(prop.label, tostring(prop.model)))
		end
	end
	return typesLabels[categoryIndex]
end

---isColoredCategory → Check if the selected category changes the model of the props with the color (because R*)
---@return boolean
local function isColoredCategory()
	return _var.props.categories[_var.props.categoryArrayIndex].name == _var.props.coloredCategory
end

---getColorsLabels → Get the labels of the colors of the selected prop
---@return table, boolean
local function getColorsLabels()
	local labels = {}
	if isColoredCategory() then
		for index = 0, _var.props.coloredCategoryColors - 1 do
			table.insert(labels, getLabel("MC_SR_PROP_C" .. index))
		end
		return labels, true
	end
	local category = _var.props.categories[_var.props.categoryArrayIndex]
	for _, label in ipairs(getPropColorLabels(category.props[_var.props.typeArrayIndex].model)) do
		table.insert(labels, getLabel(label))
	end
	if #labels == 0 then
		return { getLabel("FMMC_SEL_DEF", _("default")) }, false
	end
	return labels, true
end

---getSelectedPropModel → Get the model of the selected prop in the objects menu
---@return string|integer
function getSelectedPropModel()
	local category = _var.props.categories[_var.props.categoryArrayIndex]
	local model = category.props[_var.props.typeArrayIndex].model
	if isColoredCategory() then -- because R*
		model = tostring(model):sub(1, -3) .. _var.props.colorArrayIndex .. "a"
	end
	return model
end

---selectNewObject → Replace the object being added by a new object model
---@param model string|integer
---@return void
function selectNewObject(model)
	objectRequestId = objectRequestId + 1
	local requestId = objectRequestId
	Citizen.CreateThread(function()
		local hash = getModelHash(model)
		if not requestModel(hash) then
			if requestId == objectRequestId then
				showNotification(_U("notif_entity_not_created"), 6)
			end
			return
		end
		if requestId ~= objectRequestId or _var.editor.state ~= _var.editor.states.adding then
			return
		end
		local rotation = vector3(0.0, 0.0, 0.0)
		if _var.editor.selected then
			if DoesEntityExist(_var.editor.selected.handle) then
				rotation = GetEntityRotation(_var.editor.selected.handle, 2)
			end
			deleteMapEntity(_var.editor.selected)
		end
		_var.editor.selected = createProp(hash, _var.editor.cursorPosition, rotation, _var.props.colorArrayIndex - 1, _var.settings.networkObjects, false)
	end)
end

---cancelObjectAdding → Delete the object being added and go back to the flying mode
---@return void
function cancelObjectAdding()
	if _var.editor.state ~= _var.editor.states.adding then
		return
	end
	objectRequestId = objectRequestId + 1
	if _var.editor.selected then
		deleteMapEntity(_var.editor.selected)
	end
	_var.editor.selected = nil
	_var.editor.state = _var.editor.states.flying
end

---objects_showContentThisFrame → Function to show the objects menu content
---@return void
function objects_showContentThisFrame()
	RageUI.List(_U("objects_category"), getCategoriesLabels(), _var.props.categoryArrayIndex, _U("objects_category_desc"), {}, true, function() end, function(Index)
		_var.props.categoryArrayIndex = Index
		_var.props.typeArrayIndex = 1
		_var.props.colorArrayIndex = 1
		selectNewObject(getSelectedPropModel())
	end)
	RageUI.List(_U("objects_type"), getTypesLabels(_var.props.categoryArrayIndex), _var.props.typeArrayIndex, _U("objects_type_desc"), {}, true, function() end, function(Index)
		_var.props.typeArrayIndex = Index
		if _var.props.colorArrayIndex > #getColorsLabels() then
			_var.props.colorArrayIndex = 1
		end
		selectNewObject(getSelectedPropModel())
	end)
	local colorsLabels, hasColors = getColorsLabels()
	RageUI.List(_U("objects_color"), colorsLabels, _var.props.colorArrayIndex, _U("objects_color_desc"), {}, hasColors, function() end, function(Index)
		if not hasColors then
			return
		end
		_var.props.colorArrayIndex = Index
		if isColoredCategory() then
			selectNewObject(getSelectedPropModel())
		elseif _var.editor.selected and DoesEntityExist(_var.editor.selected.handle) then
			_var.editor.selected.textureVariant = Index - 1
			SetObjectTextureVariant(_var.editor.selected.handle, Index - 1)
		end
	end)
end
