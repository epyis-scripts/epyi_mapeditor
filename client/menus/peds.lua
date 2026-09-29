---loadPedsList → Load the list of the ped models available in the game
---@return void
local function loadPedsList()
	if _var.peds.isLoaded then
		return
	end
	_var.peds.isLoaded = true
	for _, model in ipairs(_var.peds.list) do
		local hash = getModelHash(model)
		if IsModelInCdimage(hash) and IsModelAPed(hash) then
			table.insert(_var.peds.models, { model = model, hash = hash })
		end
	end
end

---spawnPed → Create a ped at the 3D cursor position and select it
---@param ped table
---@return void
local function spawnPed(ped)
	Citizen.CreateThread(function()
		local record = createPed(ped.hash, _var.editor.cursorPosition, 0.0, 26, _var.settings.networkObjects)
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
				if search == nil or search == "" then
					_var.menu.pedsFilter = ""
					return
				end
				_var.menu.pedsFilter = search
			end
		end
	)
	RageUI.Separator(_U("filter_result"))
	local count = 0
	for _k, ped in ipairs(_var.peds.models) do
		if _var.menu.pedsFilter == "" or string.find(ped.model, string.lower(_var.menu.pedsFilter), 1, true) ~= nil then
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
