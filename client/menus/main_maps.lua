---main_maps_showContentThisFrame → Function to show the main/maps menu content
---@return void
function main_maps_showContentThisFrame()
	RageUI.Separator(_U("main_maps_list"))
	local count = 0
	for _k, fileName in ipairs(_var.maps.list) do
		count = count + 1
		local mapName = fileName:gsub("%.xml$", "")
		RageUI.ButtonWithStyle(mapName, _U("main_maps_load_desc", mapName), { RightLabel = "→" }, true, function(_h, _a, Selected)
			if Selected then
				TriggerServerEvent("epyi_mapeditor:loadMap", fileName)
			end
		end)
	end
	if count == 0 then
		RageUI.Separator("")
		RageUI.Separator(_U("no_result"))
		RageUI.Separator("")
	end
end
