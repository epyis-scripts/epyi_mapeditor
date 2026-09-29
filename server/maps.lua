---isMapInList
---@param fileName string
---@return boolean
---@private
local function isMapInList(fileName)
	for _, listedFileName in ipairs(_var.maps.list) do
		if listedFileName == fileName then
			return true
		end
	end
	return false
end

---refreshMapsList
---@return void
---@private
local function refreshMapsList()
	local files = getMapsFiles()
	local hasChanged = #files ~= #_var.maps.list
	if not hasChanged then
		for index, fileName in ipairs(files) do
			if _var.maps.list[index] ~= fileName then
				hasChanged = true
				break
			end
		end
	end
	if hasChanged then -- only send updates when needed
		_var.maps.list = files
		for _, playerId in ipairs(GetPlayers()) do
			if hasAccess(playerId) then
				TriggerClientEvent("epyi_mapeditor:mapsList", tonumber(playerId), _var.maps.list)
			end
		end
	end
end

RegisterNetEvent("epyi_mapeditor:getMapsList", function()
	local source = source
	updateAccess(source)
	if not hasAccess(source) then
		return
	end
	TriggerClientEvent("epyi_mapeditor:mapsList", source, _var.maps.list)
end)

RegisterNetEvent("epyi_mapeditor:saveMap", function(data)
	local source = source
	if not hasAccess(source) then
		log(_("log_insuficient_permissions", GetPlayerName(source), source))
		return
	end
	if type(data) ~= "string" or #data > Config.Maps.MaxSize then
		TriggerClientEvent("epyi_mapeditor:saveMapResult", source, false)
		return
	end
	local root = xmlParse(data)
	local nameElement = root and xmlDescendant(root, "Name")
	local fileName = nameElement and sanitizeFileName(nameElement.text) or ""
	if fileName == "" then
		TriggerClientEvent("epyi_mapeditor:saveMapResult", source, false)
		return
	end
	log(_("log_map_saving", fileName, GetPlayerName(source)))
	local success = SaveResourceFile(GetCurrentResourceName(), _var.maps.folder .. "/" .. fileName .. ".xml", data, -1)
	if success then
		refreshMapsList()
	end
	TriggerClientEvent("epyi_mapeditor:saveMapResult", source, success == true)
end)

RegisterNetEvent("epyi_mapeditor:loadMap", function(fileName)
	local source = source
	if not hasAccess(source) then
		log(_("log_insuficient_permissions", GetPlayerName(source), source))
		return
	end
	if not isValidFileName(fileName) or not isMapInList(fileName) then
		TriggerClientEvent("epyi_mapeditor:mapLoaded", source, nil)
		return
	end
	local data = LoadResourceFile(GetCurrentResourceName(), _var.maps.folder .. "/" .. fileName)
	if not data then
		log(_("log_map_sending_error", fileName, GetPlayerName(source)))
		TriggerClientEvent("epyi_mapeditor:mapLoaded", source, nil)
		return
	end
	log(_("log_map_sending", GetPlayerName(source), fileName, math.floor(#data / 1000)))
	TriggerClientEvent("epyi_mapeditor:mapLoaded", source, data)
end)

AddEventHandler("playerJoining", function()
	updateAccess(source)
end)

Citizen.CreateThread(function()
	while true do
		refreshMapsList()
		for _, playerId in ipairs(GetPlayers()) do
			updateAccess(tonumber(playerId))
		end
		Citizen.Wait(Config.Maps.RefreshInterval)
	end
end)
