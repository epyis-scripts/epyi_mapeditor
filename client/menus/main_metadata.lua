---truncate → Truncate a text to show it in a menu
---@param text string
---@param length integer
---@return string
local function truncate(text, length)
	local textLength = utf8.len(text)
	if textLength and textLength > length then
		return text:sub(1, utf8.offset(text, length + 1) - 1) .. "..."
	elseif not textLength and #text > length then
		return text:sub(1, length) .. "..."
	end
	return text
end

---main_metadata_showContentThisFrame → Function to show the main/metadata menu content
---@return void
function main_metadata_showContentThisFrame()
	local map = _var.map.current
	RageUI.ButtonWithStyle(_U("main_metadata_name"), _U("main_metadata_current", map.name), { RightLabel = truncate(map.name, 20) }, true, function(_h, _a, Selected)
		if Selected then
			local name = textEntry(_U("textentry_map_name"), map.name, 50)
			if name ~= nil and name ~= "" then
				map.name = name
			end
		end
	end)
	RageUI.ButtonWithStyle(_U("main_metadata_creator"), _U("main_metadata_current", map.creator), { RightLabel = truncate(map.creator, 20) }, true, function(_h, _a, Selected)
		if Selected then
			local creator = textEntry(_U("textentry_map_creator"), map.creator, 50)
			if creator ~= nil and creator ~= "" then
				map.creator = creator
			end
		end
	end)
	RageUI.ButtonWithStyle(_U("main_metadata_description"), _U("main_metadata_current", map.description), { RightLabel = truncate(map.description, 20) }, true, function(_h, _a, Selected)
		if Selected then
			local description = textEntry(_U("textentry_map_description"), map.description, 200)
			if description ~= nil and description ~= "" then
				map.description = description
			end
		end
	end)
end
