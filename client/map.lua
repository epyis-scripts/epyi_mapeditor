local entityListsByType = {
	prop = "props",
	ped = "peds",
	vehicle = "vehicles",
}

---formatNumber → Format a number for the xml files
---@param value number
---@return string
local function formatNumber(value)
	local formatted = string.format("%.6f", value):gsub("0+$", ""):gsub("%.$", "")
	if formatted == "-0" then
		return "0"
	end
	return formatted
end

---getSpeedBoostDuration → Get the duration of a speed boost prop (from the R* creator)
---@param sba integer
---@return number
local function getSpeedBoostDuration(sba)
	if sba == 1 then
		return 0.3
	elseif sba == 2 then
		return 0.4
	elseif sba == 3 or sba == 4 or sba == 5 then
		return 0.5
	end
	return 0.4
end

---getSpeedBoostSpeed → Get the speed of a speed boost prop (from the R* creator)
---@param sba integer
---@return integer
local function getSpeedBoostSpeed(sba)
	if sba == 1 then
		return 15
	elseif sba == 2 then
		return 25
	elseif sba == 3 then
		return 35
	elseif sba == 4 then
		return 45
	elseif sba == 5 then
		return 100
	end
	return 25
end

---getSlowDownSpeed → Get the speed of a slow down prop (from the R* creator)
---@param sba integer
---@return integer
local function getSlowDownSpeed(sba)
	if sba == 1 then
		return 44
	elseif sba == 2 then
		return 30
	elseif sba == 3 then
		return 16
	end
	return 30
end

local slowDownHashes = {
	[346059280] = true,
	[620582592] = true,
	[85342060] = true,
	[483832101] = true,
	[930976262] = true,
	[1677872320] = true,
	[708828172] = true,
	[950795200] = true,
	[-1260656854] = true,
	[-1875404158] = true,
	[-864804458] = true,
	[-1302470386] = true,
	[1518201148] = true,
	[384852939] = true,
	[117169896] = true,
	[-1479958115] = true,
}

---setPropSpeedBoost → Set the speed boost (SBA) of a stunt prop
---@param handle integer
---@param sba integer
---@return void
local function setPropSpeedBoost(handle, sba)
	local hash = toSignedHash(GetEntityModel(handle))
	if hash == getModelHash("stt_prop_track_speedup") or hash == getModelHash("stt_prop_track_speedup_t1") or hash == getModelHash("stt_prop_track_speedup_t2") or hash == getModelHash("stt_prop_stunt_tube_speed") or hash == getModelHash("stt_prop_stunt_tube_speedb") then
		Citizen.InvokeNative(0x7BAC110ED504814D, handle, getSpeedBoostSpeed(sba))
		Citizen.InvokeNative(0x4E91E2848E9525BB, handle, getSpeedBoostDuration(sba))
	elseif hash == getModelHash("stt_prop_track_slowdown") or hash == getModelHash("stt_prop_track_slowdown_t1") or hash == getModelHash("stt_prop_track_slowdown_t2") or slowDownHashes[hash] then
		Citizen.InvokeNative(0x7BAC110ED504814D, handle, getSlowDownSpeed(sba))
	end
end

---startPropParticles → Start a looped particle effect on a prop (without blocking the current thread)
---@param handle integer
---@param dictionary string
---@param name string
---@param offset vector3
---@param rotation vector3
---@param scale number
---@return void
local function startPropParticles(handle, dictionary, name, offset, rotation, scale)
	Citizen.CreateThread(function()
		RequestNamedPtfxAsset(dictionary)
		local timeout = GetGameTimer() + 1000
		while not HasNamedPtfxAssetLoaded(dictionary) and GetGameTimer() < timeout do
			Citizen.Wait(0)
		end
		if HasNamedPtfxAssetLoaded(dictionary) and DoesEntityExist(handle) then
			UseParticleFxAssetNextCall(dictionary)
			Citizen.InvokeNative(0x2FBC377D2B29B60F, name, handle, offset.x, offset.y, offset.z, rotation.x, rotation.y, rotation.z, scale, false, false, false)
		end
	end)
end

---setPropEffects → Set the particle effects of the stunt hoops
---@param handle integer
---@param hash integer
---@return void
local function setPropEffects(handle, hash)
	if hash == getModelHash("stt_prop_hoop_constraction_01a") then
		startPropParticles(handle, "scr_stunts", "scr_stunts_fire_ring", vector3(0.0, 0.0, 25.0), vector3(-12.5, 0.0, 0.0), 1.0)
	elseif hash == getModelHash("stt_prop_hoop_small_01") then
		startPropParticles(handle, "core", "ent_amb_fire_ring", vector3(0.0, 0.0, 4.5), vector3(0.0, 0.0, 90.0), 3.5)
	end
end

---createProp → Create a prop and return its map entity
---@param model string|integer
---@param position vector3
---@param rotation vector3
---@param textureVariant integer
---@param isNetwork boolean
---@param isDynamic boolean
---@return table|nil
function createProp(model, position, rotation, textureVariant, isNetwork, isDynamic)
	local hash = getModelHash(model)
	if not requestModel(hash) then
		return nil
	end
	local handle = CreateObjectNoOffset(hash, position.x, position.y, position.z, isNetwork, true, isDynamic or false)
	SetModelAsNoLongerNeeded(hash)
	SetEntityRotation(handle, rotation.x, rotation.y, rotation.z, 2, true)
	SetObjectTextureVariant(handle, textureVariant or 0)
	setPropEffects(handle, hash)
	return { handle = handle, type = "prop", textureVariant = textureVariant or 0 }
end

---createPed → Create a ped and return its map entity
---@param model string|integer
---@param position vector3
---@param heading number
---@param pedType integer
---@param isNetwork boolean
---@return table|nil
function createPed(model, position, heading, pedType, isNetwork)
	local hash = getModelHash(model)
	if not requestModel(hash) then
		return nil
	end
	local handle = CreatePed(pedType or 26, hash, position.x, position.y, position.z, heading, isNetwork, false)
	SetModelAsNoLongerNeeded(hash)
	return { handle = handle, type = "ped" }
end

---createVehicle → Create a vehicle and return its map entity
---@param model string|integer
---@param position vector3
---@param heading number
---@param isNetwork boolean
---@return table|nil
function createVehicle(model, position, heading, isNetwork)
	local hash = getModelHash(model)
	if not requestModel(hash) then
		return nil
	end
	local handle = CreateVehicle(hash, position.x, position.y, position.z, heading, isNetwork, false)
	SetModelAsNoLongerNeeded(hash)
	return { handle = handle, type = "vehicle" }
end

---setupEditorEntity → Freeze and protect a map entity while it is edited
---@param record table
---@return void
function setupEditorEntity(record)
	FreezeEntityPosition(record.handle, true)
	SetEntityInvincible(record.handle, true)
	if record.type == "ped" then
		TaskSetBlockingOfNonTemporaryEvents(record.handle, true)
	end
end

---deleteMapEntity → Delete the entity of a map entity
---@param record table
---@return void
function deleteMapEntity(record)
	if record.blip and DoesBlipExist(record.blip) then
		RemoveBlip(record.blip)
	end
	record.blip = nil
	if DoesEntityExist(record.handle) then
		SetEntityAsMissionEntity(record.handle, true, true)
		DeleteEntity(record.handle)
	end
end

---mapNew → Create a new empty map as the current map
---@return void
function mapNew()
	_var.map.current = {
		name = _("map_default_name"),
		creator = GetPlayerName(PlayerId()),
		description = "",
		props = {},
		peds = {},
		vehicles = {},
		checkpoints = {},
	}
end

---mapAddEntity → Add an entity to the current map
---@param record table
---@return void
function mapAddEntity(record)
	if record.type == "prop" and not record.blip then
		record.blip = AddBlipForEntity(record.handle)
		SetBlipColour(record.blip, 3)
	end
	table.insert(_var.map.current[entityListsByType[record.type]], record)
end

---mapContainsEntity → Check if an entity is in the current map
---@param record table
---@return boolean
function mapContainsEntity(record)
	for _, mapRecord in ipairs(_var.map.current[entityListsByType[record.type]]) do
		if mapRecord == record then
			return true
		end
	end
	return false
end

---mapRemoveEntity → Remove an entity from the current map
---@param record table
---@return void
function mapRemoveEntity(record)
	local list = _var.map.current[entityListsByType[record.type]]
	for index, mapRecord in ipairs(list) do
		if mapRecord == record then
			table.remove(list, index)
			break
		end
	end
	if record.blip and DoesBlipExist(record.blip) then
		RemoveBlip(record.blip)
	end
	record.blip = nil
end

---mapFindEntity → Find the map entity of an entity handle
---@param handle integer
---@return table|nil
function mapFindEntity(handle)
	for _, listName in pairs(entityListsByType) do
		for _, record in ipairs(_var.map.current[listName]) do
			if record.handle == handle then
				return record
			end
		end
	end
	return nil
end

---mapUnload → Delete all the entities and checkpoints of the current map
---@return void
function mapUnload()
	for _, listName in pairs(entityListsByType) do
		for _, record in ipairs(_var.map.current[listName]) do
			deleteMapEntity(record)
		end
		_var.map.current[listName] = {}
	end
	for _, checkpoint in ipairs(_var.map.current.checkpoints) do
		DeleteCheckpoint(checkpoint)
	end
	_var.map.current.checkpoints = {}
end

---mapSerializeVector → Serialize a vector in the 5me xml format
---@param name string
---@param vector vector3
---@return string
local function mapSerializeVector(name, vector)
	return ("\t\t\t<%s>\n\t\t\t\t<X>%s</X>\n\t\t\t\t<Y>%s</Y>\n\t\t\t\t<Z>%s</Z>\n\t\t\t</%s>\n"):format(name, formatNumber(vector.x), formatNumber(vector.y), formatNumber(vector.z), name)
end

---mapSerialize → Serialize the current map in the 5me xml format
---@return string
function mapSerialize()
	local map = _var.map.current
	local lines = {
		'<?xml version="1.0" encoding="utf-8"?>\n',
		'<Map version="5me-v1">\n',
		("\t<Name>%s</Name>\n"):format(xmlEscape(map.name)),
		("\t<Creator>%s</Creator>\n"):format(xmlEscape(map.creator)),
		("\t<Description>%s</Description>\n"):format(xmlEscape(map.description)),
		"\t<Peds>\n",
	}
	for _, record in ipairs(map.peds) do
		if DoesEntityExist(record.handle) then
			table.insert(lines, "\t\t<Ped>\n")
			table.insert(lines, ("\t\t\t<Hash>%d</Hash>\n"):format(toSignedHash(GetEntityModel(record.handle))))
			table.insert(lines, ("\t\t\t<Type>%d</Type>\n"):format(GetPedType(record.handle)))
			table.insert(lines, mapSerializeVector("Pos", GetEntityCoords(record.handle)))
			table.insert(lines, mapSerializeVector("Rot", GetEntityRotation(record.handle, 2)))
			table.insert(lines, "\t\t</Ped>\n")
		end
	end
	table.insert(lines, "\t</Peds>\n")
	table.insert(lines, "\t<Vehicles>\n")
	for _, record in ipairs(map.vehicles) do
		if DoesEntityExist(record.handle) then
			table.insert(lines, "\t\t<Vehicle>\n")
			table.insert(lines, ("\t\t\t<Hash>%d</Hash>\n"):format(toSignedHash(GetEntityModel(record.handle))))
			table.insert(lines, mapSerializeVector("Pos", GetEntityCoords(record.handle)))
			table.insert(lines, mapSerializeVector("Rot", GetEntityRotation(record.handle, 2)))
			table.insert(lines, "\t\t</Vehicle>\n")
		end
	end
	table.insert(lines, "\t</Vehicles>\n")
	table.insert(lines, "\t<Props>\n")
	for _, record in ipairs(map.props) do
		if DoesEntityExist(record.handle) then
			table.insert(lines, "\t\t<Prop>\n")
			table.insert(lines, ("\t\t\t<Hash>%d</Hash>\n"):format(toSignedHash(GetEntityModel(record.handle))))
			table.insert(lines, mapSerializeVector("Pos", GetEntityCoords(record.handle)))
			table.insert(lines, mapSerializeVector("Rot", GetEntityRotation(record.handle, 2)))
			table.insert(lines, ("\t\t\t<Color>%d</Color>\n"):format(record.textureVariant or 0))
			if record.sba then
				table.insert(lines, ("\t\t\t<SBA>%d</SBA>\n"):format(record.sba))
			end
			table.insert(lines, "\t\t</Prop>\n")
		end
	end
	table.insert(lines, "\t</Props>\n")
	table.insert(lines, "</Map>\n")
	return table.concat(lines)
end

---loadFiveMapEditorProps → Create the props of a 5me map (or of the map of a race)
---@param element table
---@param result table
---@param isNetwork boolean
---@return void
local function loadFiveMapEditorProps(element, result, isNetwork)
	for _, prop in ipairs(xmlChildren(xmlChild(element, "Props"), "Prop")) do
		local position, rotation = xmlVector(prop, "Pos"), xmlVector(prop, "Rot")
		local hash = tonumber(xmlValue(prop, "Hash"))
		if hash and position and rotation then
			local record = createProp(hash, position, rotation, math.floor(tonumber(xmlValue(prop, "Color")) or 0), isNetwork, false)
			if record then
				local sba = tonumber(xmlValue(prop, "SBA"))
				if sba then
					sba = math.floor(sba)
					record.sba = sba
					setPropSpeedBoost(record.handle, sba)
				end
				table.insert(result.entities, record)
			end
		end
	end
end

---loadFiveMapEditorMetadata → Read the metadata of a 5me map (or of the map of a race)
---@param element table
---@param result table
---@return void
local function loadFiveMapEditorMetadata(element, result)
	result.name = xmlValue(element, "Name") or ""
	result.creator = xmlValue(element, "Creator") or ""
	result.description = xmlValue(element, "Description") or ""
end

---mapLoadFromXml → Create the entities of a map from its xml (5me, race or Guadmaz format)
---@param data string
---@param isNetwork boolean
---@return table|nil
function mapLoadFromXml(data, isNetwork)
	local root = xmlParse(data)
	if not root then
		return nil
	end
	local result = { name = "", creator = "", description = "", entities = {}, checkpoints = {}, startPosition = nil }
	if root.name == "Race" then -- if the map is a race
		local map = xmlChild(root, "Map")
		loadFiveMapEditorMetadata(map, result)
		loadFiveMapEditorProps(map, result, isNetwork)
		local previousPosition = nil
		for _, checkpoint in ipairs(xmlChildren(xmlChild(root, "Checkpoints"), "Checkpoint")) do
			local position = xmlVector(checkpoint, "Pos")
			if position then
				if previousPosition then
					table.insert(result.checkpoints, CreateCheckpoint(0, previousPosition.x, previousPosition.y, previousPosition.z, position.x, position.y, position.z, 10.0, 180, 180, 50, 150, 0))
				end
				previousPosition = position
			end
		end
		result.startPosition = xmlVector(xmlChild(root, "Grid"), "Pos")
	elseif root.name == "Map" and root.attr["version"] then -- if the map is a 5me map
		loadFiveMapEditorMetadata(root, result)
		loadFiveMapEditorProps(root, result, isNetwork)
		for _, ped in ipairs(xmlChildren(xmlChild(root, "Peds"), "Ped")) do
			local position, rotation = xmlVector(ped, "Pos"), xmlVector(ped, "Rot")
			local hash = tonumber(xmlValue(ped, "Hash"))
			if hash and position and rotation then
				local pedType = tonumber(xmlValue(ped, "Type"))
				local record = createPed(hash, position, rotation.z, pedType and math.floor(pedType), isNetwork)
				if record then
					table.insert(result.entities, record)
				end
			end
		end
		for _, vehicle in ipairs(xmlChildren(xmlChild(root, "Vehicles"), "Vehicle")) do
			local position, rotation = xmlVector(vehicle, "Pos"), xmlVector(vehicle, "Rot")
			local hash = tonumber(xmlValue(vehicle, "Hash"))
			if hash and position and rotation then
				local record = createVehicle(hash, position, 0.0, isNetwork)
				if record then
					SetEntityRotation(record.handle, rotation.x, rotation.y, rotation.z, 2, true)
					table.insert(result.entities, record)
				end
			end
		end
	elseif root.name == "Map" then -- if the map is a Guadmaz's Map Editor map
		local metadata = xmlChild(root, "Metadata")
		if metadata then
			loadFiveMapEditorMetadata(metadata, result)
		end
		for _, object in ipairs(xmlChildren(xmlChild(root, "Objects"), "MapObject")) do
			local position, rotation = xmlVector(object, "Position"), xmlVector(object, "Rotation")
			local hash = tonumber(xmlValue(object, "Hash"))
			if xmlValue(object, "Type") == "Prop" and hash and position and rotation then
				local record = createProp(hash, position, rotation, 0, isNetwork, xmlValue(object, "Dynamic") == "true")
				if record then
					table.insert(result.entities, record)
				end
			end
		end
	else
		return nil
	end
	return result
end

---unloadLoadedMap → Delete the entities and checkpoints created by mapLoadFromXml
---@param result table
---@return void
function unloadLoadedMap(result)
	for _, record in ipairs(result.entities) do
		deleteMapEntity(record)
	end
	for _, checkpoint in ipairs(result.checkpoints) do
		DeleteCheckpoint(checkpoint)
	end
end

---loadMapInEditor → Replace the current map of the editor by a map from its xml
---@param data string
---@return void
function loadMapInEditor(data)
	_var.map.loadRequestId = _var.map.loadRequestId + 1
	local requestId = _var.map.loadRequestId
	Citizen.CreateThread(function()
		resetEditorSelection()
		mapUnload()
		local result = mapLoadFromXml(data, _var.settings.networkObjects)
		if requestId ~= _var.map.loadRequestId then -- if another map has been loaded in the meantime
			if result then
				unloadLoadedMap(result)
			end
			return
		end
		if not result then
			showNotification(_U("notif_map_load_error"), 6)
			return
		end
		resetEditorSelection()
		mapUnload()
		mapNew()
		_var.map.current.name = result.name ~= "" and result.name or _var.map.current.name
		_var.map.current.creator = result.creator ~= "" and result.creator or _var.map.current.creator
		_var.map.current.description = result.description
		_var.map.current.checkpoints = result.checkpoints
		for _, record in ipairs(result.entities) do
			if record.type ~= "prop" then
				setupEditorEntity(record)
			end
			mapAddEntity(record)
		end
		showNotification(_U("notif_map_loaded", _var.map.current.name), 20)
		if result.startPosition then
			Citizen.Wait(2000)
			if _var.freecam.cam then
				SetCamCoord(_var.freecam.cam, result.startPosition.x, result.startPosition.y, result.startPosition.z)
			else
				SetEntityCoords(PlayerPedId(), result.startPosition.x, result.startPosition.y, result.startPosition.z, true, false, false, false)
			end
		end
	end)
end

---saveMap → Send the current map to the server to save it
---@return void
function saveMap()
	TriggerLatentServerEvent("epyi_mapeditor:saveMap", Config.Maps.TransferSpeed, mapSerialize())
end

---loadMap → Load a map in the world outside of the editor (used by the exports)
---@param data string
---@return string|nil
function loadMap(data)
	local result = mapLoadFromXml(data, false)
	if not result then
		return nil
	end
	local mapId = result.name ~= "" and result.name or tostring(_var.loader.nextId)
	_var.loader.nextId = _var.loader.nextId + 1
	unloadMap(mapId)
	_var.loader.maps[mapId] = result
	return mapId
end

---unloadMap → Unload a map loaded with loadMap
---@param mapId string
---@return void
function unloadMap(mapId)
	local map = _var.loader.maps[mapId]
	if not map then
		return
	end
	unloadLoadedMap(map)
	_var.loader.maps[mapId] = nil
end

---unloadAllMaps → Unload all the maps loaded with loadMap
---@return void
function unloadAllMaps()
	for mapId, _ in pairs(_var.loader.maps) do
		unloadMap(mapId)
	end
end

exports("loadMap", loadMap)
exports("unloadMap", unloadMap)
exports("unloadAllMaps", unloadAllMaps)

---loader:load → Load a map in the world (can be triggered by the server)
---@param data string
---@return void
RegisterNetEvent("epyi_mapeditor:loader:load", function(data)
	loadMap(data)
end)

---loader:unload → Unload a map loaded in the world
---@param mapId string
---@return void
RegisterNetEvent("epyi_mapeditor:loader:unload", function(mapId)
	unloadMap(mapId)
end)

---loader:unloadAll → Unload all the maps loaded in the world
---@return void
RegisterNetEvent("epyi_mapeditor:loader:unloadAll", function()
	unloadAllMaps()
end)

---mapsList → Receive the list of the maps saved on the server
---@param list table
---@return void
RegisterNetEvent("epyi_mapeditor:mapsList", function(list)
	_var.maps.list = list
end)

---saveMapResult → Receive the result of a map saving
---@param success boolean
---@return void
RegisterNetEvent("epyi_mapeditor:saveMapResult", function(success)
	if success then
		showNotification(_U("notif_map_saved"), 20)
	else
		showNotification(_U("notif_map_save_error"), 6)
	end
end)

---mapLoaded → Receive the content of a map requested to the server
---@param data string|nil
---@return void
RegisterNetEvent("epyi_mapeditor:mapLoaded", function(data)
	if not data then
		showNotification(_U("notif_map_load_error"), 6)
		return
	end
	loadMapInEditor(data)
end)

-- Map initialization
-- create the default map and ask the maps list to the server
mapNew()
TriggerServerEvent("epyi_mapeditor:getMapsList")
