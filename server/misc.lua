---hasAccess
---@param source number
---@return boolean
---@public
function hasAccess(source)
	if not Config.Permissions.UseAce then
		return true
	end
	return IsPlayerAceAllowed(source, Config.Permissions.Ace)
end

---updateAccess
---@param source number
---@return void
---@public
function updateAccess(source)
	local access = hasAccess(source)
	if Player(source).state["epyi_mapeditor:access"] ~= access then
		Player(source).state:set("epyi_mapeditor:access", access, true)
	end
end

local accents = {
	["à"] = "a",
	["á"] = "a",
	["â"] = "a",
	["ã"] = "a",
	["ä"] = "a",
	["å"] = "a",
	["À"] = "a",
	["Á"] = "a",
	["Â"] = "a",
	["Ã"] = "a",
	["Ä"] = "a",
	["Å"] = "a",
	["è"] = "e",
	["é"] = "e",
	["ê"] = "e",
	["ë"] = "e",
	["È"] = "e",
	["É"] = "e",
	["Ê"] = "e",
	["Ë"] = "e",
	["ì"] = "i",
	["í"] = "i",
	["î"] = "i",
	["ï"] = "i",
	["Ì"] = "i",
	["Í"] = "i",
	["Î"] = "i",
	["Ï"] = "i",
	["ò"] = "o",
	["ó"] = "o",
	["ô"] = "o",
	["õ"] = "o",
	["ö"] = "o",
	["Ò"] = "o",
	["Ó"] = "o",
	["Ô"] = "o",
	["Õ"] = "o",
	["Ö"] = "o",
	["ù"] = "u",
	["ú"] = "u",
	["û"] = "u",
	["ü"] = "u",
	["Ù"] = "u",
	["Ú"] = "u",
	["Û"] = "u",
	["Ü"] = "u",
	["ç"] = "c",
	["Ç"] = "c",
	["ñ"] = "n",
	["Ñ"] = "n",
	["ý"] = "y",
	["ÿ"] = "y",
	["Ý"] = "y",
	["œ"] = "oe",
	["Œ"] = "oe",
	["æ"] = "ae",
	["Æ"] = "ae",
	["ß"] = "ss",
}

---sanitizeFileName
---@param name string
---@return string
---@public
function sanitizeFileName(name)
	local fileName = name:gsub(utf8.charpattern, function(char)
		return accents[char]
	end)
	fileName = fileName:lower():gsub("[%s_]", "-"):gsub("[^%w%-]", ""):gsub("%-%-+", "-")
	fileName = fileName:gsub("^%-+", ""):gsub("%-+$", "")
	return fileName
end

---isValidFileName
---@param fileName string
---@return boolean
---@public
function isValidFileName(fileName)
	return type(fileName) == "string" and fileName:match("^[%w%-_ %.%(%)]+%.xml$") ~= nil and not fileName:find("..", 1, true)
end

---getMapsFiles
---@return table
---@public
function getMapsFiles()
	local files = {}
	if not io or not io.popen then
		return files
	end
	local folder = GetResourcePath(GetCurrentResourceName()) .. "/" .. _var.maps.folder
	local command
	if folder:match("^%a:[/\\]") then -- if the server runs on windows
		command = 'dir "' .. folder:gsub("/", "\\") .. '" /b /a-d 2>nul'
	else
		command = 'ls -1 "' .. folder .. '" 2>/dev/null'
	end
	local handle = io.popen(command)
	if not handle then
		return files
	end
	for line in handle:lines() do
		local fileName = line:gsub("[\r\n]", "")
		if isValidFileName(fileName) then
			table.insert(files, fileName)
		end
	end
	handle:close()
	table.sort(files)
	return files
end
