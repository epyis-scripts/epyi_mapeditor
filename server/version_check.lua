function checkVersion(err, responseText, headers)
	local resource = GetInvokingResource() or GetCurrentResourceName()
	local currentVersion = GetResourceMetadata(resource, "version", 0)
	if currentVersion == nil then
		log("It looks like your ressource's version checker is broken. This does not prevent the resource from working.")
		return
	end
	if err == 404 then -- if the resource is not referenced in the versions repository yet
		return
	end
	if responseText == nil then
		log("It looks like github is offline. The resource uses github to check if it's up to date. This does not prevent the resource from working.")
		return
	end

	local lines = {}
	for line in responseText:gmatch("([^\n]*)\n?") do
		table.insert(lines, line)
	end

	if #lines < 2 then
		log("It looks like your ressource's version checker is broken. This does not prevent the resource from working.")
		return
	end

	local latestVersion = lines[1]:gsub("%s+", "")
	local updateUrl = lines[2]:gsub("%s+", "")

	if currentVersion:gsub("%s+", "") ~= latestVersion then
		log("^0" .. GetCurrentResourceName() .. " is not up to date. The latest release is " .. latestVersion .. " but you are on release " .. currentVersion .. " -- > " .. updateUrl .. "^0")
	end
end

local function performVersionCheck()
	PerformHttpRequest("https://raw.githubusercontent.com/epyidev/lyre-framework-versions/main/" .. GetCurrentResourceName(), checkVersion, "GET")
end

performVersionCheck()
