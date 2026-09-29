local xmlEntities = {
	["&lt;"] = "<",
	["&gt;"] = ">",
	["&quot;"] = '"',
	["&apos;"] = "'",
	["&amp;"] = "&",
}

---xmlUnescape → Replace the xml entities of a string by their characters
---@param value string
---@return string
local function xmlUnescape(value)
	value = value:gsub("&#x(%x+);", function(code)
		return utf8.char(tonumber(code, 16))
	end)
	value = value:gsub("&#(%d+);", function(code)
		return utf8.char(tonumber(code))
	end)
	return (value:gsub("&%a+;", xmlEntities))
end

---xmlEscape → Replace the special characters of a string by their xml entities
---@param value any
---@return string
function xmlEscape(value)
	return (tostring(value):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
end

---xmlParseAttributes → Parse the attributes of a xml tag
---@param content string
---@return table
local function xmlParseAttributes(content)
	local attributes = {}
	for key, _quote, value in content:gmatch("([%w_:%.%-]+)%s*=%s*([\"'])(.-)%2") do
		attributes[key] = xmlUnescape(value)
	end
	return attributes
end

---xmlFindTagEnd → Find the end of a xml tag, ignoring the ">" characters between quotes
---@param data string
---@param position integer
---@return integer|nil
local function xmlFindTagEnd(data, position)
	local quote = nil
	for index = position, #data do
		local char = data:sub(index, index)
		if quote then
			if char == quote then
				quote = nil
			end
		elseif char == '"' or char == "'" then
			quote = char
		elseif char == ">" then
			return index
		end
	end
	return nil
end

---xmlParse → Parse a xml string into a tree of elements ({ name, attr, children, text })
---@param data string
---@return table|nil
function xmlParse(data)
	if type(data) ~= "string" then
		return nil
	end
	local document = { name = "#document", attr = {}, children = {}, text = "" }
	local stack = { document }
	local position = 1
	while true do
		local tagStart = data:find("<", position, true)
		local current = stack[#stack]
		local text = data:sub(position, (tagStart or (#data + 1)) - 1)
		if text:find("%S") then
			current.text = current.text .. xmlUnescape(text)
		end
		if not tagStart then
			break
		end
		if data:sub(tagStart, tagStart + 3) == "<!--" then -- if the tag is a comment
			local commentEnd = data:find("-->", tagStart + 4, true)
			if not commentEnd then
				return nil
			end
			position = commentEnd + 3
		elseif data:sub(tagStart, tagStart + 8) == "<![CDATA[" then -- if the tag is a cdata section
			local cdataEnd = data:find("]]>", tagStart + 9, true)
			if not cdataEnd then
				return nil
			end
			current.text = current.text .. data:sub(tagStart + 9, cdataEnd - 1)
			position = cdataEnd + 3
		elseif data:sub(tagStart, tagStart + 1) == "<?" then -- if the tag is a processing instruction
			local instructionEnd = data:find("?>", tagStart + 2, true)
			if not instructionEnd then
				return nil
			end
			position = instructionEnd + 2
		elseif data:sub(tagStart, tagStart + 1) == "<!" then -- if the tag is a doctype
			local doctypeEnd = xmlFindTagEnd(data, tagStart + 2)
			if not doctypeEnd then
				return nil
			end
			position = doctypeEnd + 1
		else
			local tagEnd = xmlFindTagEnd(data, tagStart + 1)
			if not tagEnd then
				return nil
			end
			local content = data:sub(tagStart + 1, tagEnd - 1)
			if content:sub(1, 1) == "/" then -- if the tag is a closing tag
				local name = content:match("^/%s*([^%s]+)%s*$")
				if #stack == 1 or name ~= current.name then
					return nil
				end
				current.text = current.text:match("^%s*(.-)%s*$")
				table.remove(stack)
			else
				local name, attributes = content:match("^([^%s/]+)(.-)$")
				if not name then
					return nil
				end
				local selfClosing = attributes:sub(-1) == "/"
				if selfClosing then
					attributes = attributes:sub(1, -2)
				end
				local element = { name = name, attr = xmlParseAttributes(attributes), children = {}, text = "" }
				table.insert(current.children, element)
				if not selfClosing then
					table.insert(stack, element)
				end
			end
			position = tagEnd + 1
		end
	end
	if #stack ~= 1 or not document.children[1] then
		return nil
	end
	return document.children[1]
end

---xmlChild → Get the first child element with the given name
---@param element table
---@param name string
---@return table|nil
function xmlChild(element, name)
	if not element then
		return nil
	end
	for _, child in ipairs(element.children) do
		if child.name == name then
			return child
		end
	end
	return nil
end

---xmlChildren → Get all the child elements with the given name
---@param element table
---@param name string
---@return table
function xmlChildren(element, name)
	local children = {}
	if not element then
		return children
	end
	for _, child in ipairs(element.children) do
		if child.name == name then
			table.insert(children, child)
		end
	end
	return children
end

---xmlValue → Get the text of the first child element with the given name
---@param element table
---@param name string
---@return string|nil
function xmlValue(element, name)
	local child = xmlChild(element, name)
	return child and child.text or nil
end

---xmlDescendant → Get the first descendant element with the given name
---@param element table
---@param name string
---@return table|nil
function xmlDescendant(element, name)
	if not element then
		return nil
	end
	for _, child in ipairs(element.children) do
		if child.name == name then
			return child
		end
		local descendant = xmlDescendant(child, name)
		if descendant then
			return descendant
		end
	end
	return nil
end

---xmlVector → Get a vector3 from a child element containing X, Y and Z elements
---@param element table
---@param name string
---@return vector3|nil
function xmlVector(element, name)
	local child = xmlChild(element, name)
	local x, y, z = tonumber(xmlValue(child, "X")), tonumber(xmlValue(child, "Y")), tonumber(xmlValue(child, "Z"))
	if not x or not y or not z then
		return nil
	end
	return vector3(x, y, z)
end
