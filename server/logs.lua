---log
---@param message string
---@return void
---@public
function log(message)
	print("^5(^2" .. string.upper(GetCurrentResourceName()) .. "^5) ^4- ^0" .. message)
end
