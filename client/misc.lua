---textEntry → Open a popup to write some text
---@param textEntry string
---@param inputText string
---@param maxLength integer
---@return string
function textEntry(textEntry, inputText, maxLength)
	_var.freecam.isPaused = true
	AddTextEntry("FMMC_KEY_TIP1", textEntry)
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", inputText, "", "", "", maxLength)
	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end
	local result = nil
	if UpdateOnscreenKeyboard() ~= 2 then
		result = GetOnscreenKeyboardResult()
	end
	Citizen.Wait(500)
	_var.freecam.isPaused = false
	return result
end

---showNotification → Show a notification above the minimap
---@param message string
---@param color integer
---@return void
function showNotification(message, color)
	if color then
		ThefeedSetNextPostBackgroundColor(color)
	end
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName(message)
	EndTextCommandThefeedPostTicker(false, false)
end

---showHelpText → Show a help text for this frame
---@param text string
---@return void
function showHelpText(text)
	BeginTextCommandDisplayHelp("CELL_EMAIL_BCON")
	for index = 1, #text, 99 do
		AddTextComponentSubstringPlayerName(text:sub(index, index + 98))
	end
	EndTextCommandDisplayHelp(0, false, false, -1)
end

---hasAccess → Check if the client can use the map editor
---@return boolean
function hasAccess()
	if not Config.Permissions.UseAce then
		return true
	end
	return LocalPlayer.state["epyi_mapeditor:access"] == true
end

---isControlPressed → Check if a control is pressed, even if the controls are disabled
---@param control integer
---@return boolean
function isControlPressed(control)
	return IsDisabledControlPressed(0, control)
end

---isControlJustPressed → Check if a control has just been pressed, even if the controls are disabled
---@param control integer
---@return boolean
function isControlJustPressed(control)
	return IsDisabledControlJustPressed(0, control)
end

---getInstructionalButton → Get the instructional button string of a control
---@param control integer
---@return string
function getInstructionalButton(control)
	return GetControlInstructionalButton(1, control, true)
end

---getControlHelpToken → Get the help text token of a control (the key icon, or the key name if the control is unknown)
---@param control integer
---@return string
function getControlHelpToken(control)
	if _var.editor.controlsNames[control] then
		return "~" .. _var.editor.controlsNames[control] .. "~"
	end
	local button = GetControlInstructionalButton(0, control, true)
	return "~b~" .. button:gsub("^t_", "") .. "~s~"
end

---getLabel → Get the text of a game label (GXT), or a fallback if the label does not exist
---@param label string
---@param fallback string
---@return string
function getLabel(label, fallback)
	if label and DoesTextLabelExist(label) then
		return GetLabelText(label)
	end
	return fallback or label
end

---toSignedHash → Convert a model hash to a signed 32 bits integer
---@param hash integer
---@return integer
function toSignedHash(hash)
	hash = math.tointeger(hash) & 0xFFFFFFFF
	if hash >= 0x80000000 then
		hash = hash - 0x100000000
	end
	return hash
end

---getModelHash → Get the signed hash of a model name or of a model hash
---@param model string|integer
---@return integer
function getModelHash(model)
	if type(model) == "number" then
		return toSignedHash(model)
	end
	local numericModel = tonumber(model)
	if numericModel then
		return toSignedHash(numericModel)
	end
	return toSignedHash(joaat(model))
end

---requestModel → Load a model, return false if the model does not exist or can't be loaded
---@param hash integer
---@return boolean
function requestModel(hash)
	if not IsModelInCdimage(hash) then
		return false
	end
	RequestModel(hash)
	local timeout = GetGameTimer() + 5000
	while not HasModelLoaded(hash) do
		if GetGameTimer() > timeout then
			return false
		end
		Citizen.Wait(0)
	end
	return true
end

---rotationToDirection → Get the direction vector of a rotation
---@param rotation vector3
---@return vector3
function rotationToDirection(rotation)
	local z = math.rad(rotation.z)
	local x = math.rad(rotation.x)
	local absX = math.abs(math.cos(x))
	return norm(vector3(-math.sin(z) * absX, math.cos(z) * absX, math.sin(x)))
end

---crossProduct → Get the cross product of two vectors
---@param a vector3
---@param b vector3
---@return vector3
function crossProduct(a, b)
	return vector3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
end

---rightVector → Get the right vector of a direction vector
---@param vector vector3
---@return vector3
function rightVector(vector)
	return norm(crossProduct(vector, vector3(0.0, 0.0, 1.0)))
end

---directionToRotation → Get the rotation of a direction vector
---@param direction vector3
---@param roll number
---@return vector3
function directionToRotation(direction, roll)
	direction = norm(direction)
	local z = -math.deg(math.atan(direction.x, direction.y))
	local x = math.deg(math.atan(direction.z, #vector2(direction.x, direction.y)))
	return vector3(x, roll, z)
end

---quaternionFromYawPitchRoll → Create a quaternion from yaw (y axis), pitch (x axis) and roll (z axis) angles in radians
---@param yaw number
---@param pitch number
---@param roll number
---@return table
function quaternionFromYawPitchRoll(yaw, pitch, roll)
	local sinRoll, cosRoll = math.sin(roll * 0.5), math.cos(roll * 0.5)
	local sinPitch, cosPitch = math.sin(pitch * 0.5), math.cos(pitch * 0.5)
	local sinYaw, cosYaw = math.sin(yaw * 0.5), math.cos(yaw * 0.5)
	return {
		x = (cosYaw * sinPitch * cosRoll) + (sinYaw * cosPitch * sinRoll),
		y = (sinYaw * cosPitch * cosRoll) - (cosYaw * sinPitch * sinRoll),
		z = (cosYaw * cosPitch * sinRoll) - (sinYaw * sinPitch * cosRoll),
		w = (cosYaw * cosPitch * cosRoll) + (sinYaw * sinPitch * sinRoll),
	}
end

---quaternionMultiply → Multiply two quaternions (left * right)
---@param left table
---@param right table
---@return table
function quaternionMultiply(left, right)
	local a = left.y * right.z - left.z * right.y
	local b = left.z * right.x - left.x * right.z
	local c = left.x * right.y - left.y * right.x
	local d = left.x * right.x + left.y * right.y + left.z * right.z
	return {
		x = (left.x * right.w + right.x * left.w) + a,
		y = (left.y * right.w + right.y * left.w) + b,
		z = (left.z * right.w + right.z * left.w) + c,
		w = left.w * right.w - d,
	}
end

---quaternionInvert → Get the inverse of a quaternion
---@param quaternion table
---@return table
function quaternionInvert(quaternion)
	local lengthSquared = quaternion.x * quaternion.x + quaternion.y * quaternion.y + quaternion.z * quaternion.z + quaternion.w * quaternion.w
	if lengthSquared == 0 then
		return quaternion
	end
	return {
		x = -quaternion.x / lengthSquared,
		y = -quaternion.y / lengthSquared,
		z = -quaternion.z / lengthSquared,
		w = quaternion.w / lengthSquared,
	}
end

---rotateEntity → Apply a quaternion rotation to an entity (in the entity space)
---@param entity integer
---@param quaternion table
---@return void
function rotateEntity(entity, quaternion)
	local x, y, z, w = GetEntityQuaternion(entity)
	local result = quaternionMultiply({ x = x, y = y, z = z, w = w }, quaternion)
	SetEntityQuaternion(entity, result.x, result.y, result.z, result.w)
end

---copyEntityQuaternion → Copy the quaternion of an entity to another entity
---@param source integer
---@param target integer
---@return void
function copyEntityQuaternion(source, target)
	local x, y, z, w = GetEntityQuaternion(source)
	SetEntityQuaternion(target, x, y, z, w)
end

---getEntityVectors → Get the right, forward and up vectors of an entity
---@param entity integer
---@return vector3, vector3, vector3
function getEntityVectors(entity)
	local right, forward, up = GetEntityMatrix(entity)
	return right, forward, up
end

---getEntityDimensions → Get the minimum and maximum dimensions of the model of an entity
---@param entity integer
---@return vector3, vector3
function getEntityDimensions(entity)
	return GetModelDimensions(GetEntityModel(entity))
end

---isValidEntity → Check if an entity handle is a ped, a vehicle or an object that exists
---@param entity integer
---@return boolean
function isValidEntity(entity)
	return entity ~= nil and entity ~= 0 and DoesEntityExist(entity) and GetEntityType(entity) ~= 0
end

---drawEntityBox → Draw the bounding box of an entity
---@param entity integer
---@param r integer
---@param g integer
---@param b integer
---@return void
function drawEntityBox(entity, r, g, b)
	local min, max = getEntityDimensions(entity)
	local corners = {
		GetOffsetFromEntityInWorldCoords(entity, min.x, max.y, min.z),
		GetOffsetFromEntityInWorldCoords(entity, min.x, min.y, min.z),
		GetOffsetFromEntityInWorldCoords(entity, max.x, min.y, min.z),
		GetOffsetFromEntityInWorldCoords(entity, max.x, max.y, min.z),
		GetOffsetFromEntityInWorldCoords(entity, min.x, max.y, max.z),
		GetOffsetFromEntityInWorldCoords(entity, min.x, min.y, max.z),
		GetOffsetFromEntityInWorldCoords(entity, max.x, min.y, max.z),
		GetOffsetFromEntityInWorldCoords(entity, max.x, max.y, max.z),
	}
	local edges = {
		{ 1, 2 },
		{ 2, 3 },
		{ 3, 4 },
		{ 4, 1 }, -- ground plane
		{ 5, 6 },
		{ 6, 7 },
		{ 7, 8 },
		{ 8, 5 }, -- top plane
		{ 1, 5 },
		{ 2, 6 },
		{ 3, 7 },
		{ 4, 8 }, -- connecting edges
	}
	for _, edge in ipairs(edges) do
		local from, to = corners[edge[1]], corners[edge[2]]
		DrawLine(from.x, from.y, from.z, to.x, to.y, to.z, r, g, b, 255)
	end
end

---drawLine → Draw a line between two positions
---@param from vector3
---@param to vector3
---@param r integer
---@param g integer
---@param b integer
---@return void
function drawLine(from, to, r, g, b)
	DrawLine(from.x, from.y, from.z, to.x, to.y, to.z, r, g, b, 255)
end

---drawMarker → Draw a marker
---@param markerType integer
---@param position vector3
---@param direction vector3
---@param rotation vector3
---@param scale vector3
---@param r integer
---@param g integer
---@param b integer
---@return void
function drawMarker(markerType, position, direction, rotation, scale, r, g, b)
	DrawMarker(markerType, position.x, position.y, position.z, direction.x, direction.y, direction.z, rotation.x, rotation.y, rotation.z, scale.x, scale.y, scale.z, r, g, b, 255, false, false, 2, false, nil, nil, false)
end

---drawScreenText → Draw a right aligned text on the screen
---@param text string
---@param x number
---@param y number
---@param scale number
---@return void
local function drawScreenText(text, x, y, scale)
	SetTextFont(0)
	SetTextScale(scale, scale)
	SetTextColour(255, 255, 255, 255)
	SetTextJustification(2)
	SetTextWrap(0.0, x)
	BeginTextCommandDisplayText("STRING")
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(x, y)
end

---drawTimerBars → Draw some timer bars in the bottom right corner of the screen
---@param bars table
---@return void
function drawTimerBars(bars)
	if not HasStreamedTextureDictLoaded("timerbars") then
		RequestStreamedTextureDict("timerbars", false)
		return
	end
	local safeZone = (1.0 - GetSafeZoneSize()) * 0.5
	local width = 1080.0 * GetAspectRatio(false)
	local right = 1.0 - safeZone
	local bottom = 1.0 - safeZone
	for index, bar in ipairs(bars) do
		local offset = 4 * index * 10
		DrawSprite("timerbars", "all_black_bg", right - 148.0 / width, bottom - (40.0 + offset - 18.5) / 1080.0, 300.0 / width, 37.0 / 1080.0, 0.0, 255, 255, 255, 180)
		drawScreenText(bar[1], right - 180.0 / width, bottom - (30.0 + offset) / 1080.0, 0.3)
		drawScreenText(bar[2], right - 10.0 / width, bottom - (42.0 + offset) / 1080.0, 0.5)
	end
end

---getPropColorLabels → Get the list of the color labels of a prop model
---@param model string|integer
---@return table
function getPropColorLabels(model)
	if next(_var.props.colorsByModel) == nil then
		for _, colors in ipairs(_var.props.colors) do
			for _, colorModel in ipairs(colors.models) do
				local hash = getModelHash(colorModel)
				if not _var.props.colorsByModel[hash] then
					_var.props.colorsByModel[hash] = colors.labels
				end
			end
		end
	end
	return _var.props.colorsByModel[getModelHash(model)] or {}
end

-- Resource stop handler
-- clean the editor and the loaded maps when the resource stops
AddEventHandler("onResourceStop", function(resourceName)
	if GetCurrentResourceName() ~= resourceName then
		return
	end
	if _var.editor.state ~= _var.editor.states.inactive then
		exitEditor()
	end
	mapUnload()
	unloadAllMaps()
end)
