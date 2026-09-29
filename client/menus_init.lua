-- Menu texture initialization
-- create the menu texture with the config parameters
if Config.MenuStyle.BannerStyle.ImageUrl ~= nil then
	local runtimeTXD = CreateRuntimeTxd("custom_menu_header")
	local Object = CreateDui(Config.MenuStyle.BannerStyle.ImageUrl, Config.MenuStyle.BannerStyle.ImageSize.Width, Config.MenuStyle.BannerStyle.ImageSize.Height)
	_G.Object = Object
	local objectTexture = GetDuiHandle(Object)
	local Texture = CreateRuntimeTextureFromDuiHandle(runtimeTXD, "custom_menu_header", objectTexture)
	_var.menus.editor.bannerTexture = "custom_menu_header"
end

-- Menu controls initialization
-- go back with ESC/BACKSPACE only (the default back control also uses the right mouse button, used to look around)
RageUI.Settings.Controls.Back.Keys = {
	{ 0, 202 },
	{ 1, 202 },
	{ 2, 202 },
}

---applyMenuStyle → Apply the config style to some RageUI menus
---@param menus table
---@return void
local function applyMenuStyle(menus)
	for _k, rageObject in pairs(menus) do
		-- Set the offset
		rageObject:SetStyleSize(Config.MenuStyle.BannerStyle.widthOffset)

		-- Set color if no custom banner
		if Config.MenuStyle.BannerStyle.ImageUrl == nil then
			rageObject:SetRectangleBanner(Config.MenuStyle.BannerStyle.Color.r, Config.MenuStyle.BannerStyle.Color.g, Config.MenuStyle.BannerStyle.Color.b, Config.MenuStyle.BannerStyle.Color.a)
		end
	end
end

---openMenu → Function to open the map editor main menu
---@return void
function openMenu()
	-- Check if the menu is already opened
	if _var.menus.editor.isOpened then
		_var.menus.editor.isOpened = false
		_var.menus.closedFrame = GetFrameCount()
		return
	end

	-- Return if player does not have the permission
	if not hasAccess() then
		showNotification(_U("insuficient_permissions"), 6)
		return
	end

	-- RageUI menu initialization
	-- init the rageui menu with the config parameters
	_var.menus.editor.objects.main = RageUI.CreateMenu(_("menu_title"), _("main_subtitle"), Config.MenuStyle.Margins.left, Config.MenuStyle.Margins.top, _var.menus.editor.bannerTexture, _var.menus.editor.bannerTexture)

	_var.menus.editor.objects.main.Closed = function()
		_var.menus.editor.isOpened = false
		_var.menus.closedFrame = GetFrameCount()
	end

	_var.menus.editor.objects.mainMaps = RageUI.CreateSubMenu(_var.menus.editor.objects.main, _U("menu_title"), _U("main_maps_subtitle"), Config.MenuStyle.Margins.left, Config.MenuStyle.Margins.top, _var.menus.editor.bannerTexture, _var.menus.editor.bannerTexture)
	_var.menus.editor.objects.mainMetadata = RageUI.CreateSubMenu(_var.menus.editor.objects.main, _U("menu_title"), _U("main_metadata_subtitle"), Config.MenuStyle.Margins.left, Config.MenuStyle.Margins.top, _var.menus.editor.bannerTexture, _var.menus.editor.bannerTexture)
	_var.menus.editor.objects.mainSettings = RageUI.CreateSubMenu(_var.menus.editor.objects.main, _U("menu_title"), _U("main_settings_subtitle"), Config.MenuStyle.Margins.left, Config.MenuStyle.Margins.top, _var.menus.editor.bannerTexture, _var.menus.editor.bannerTexture)
	_var.menus.editor.objects.mainEntities = RageUI.CreateSubMenu(_var.menus.editor.objects.main, _U("menu_title"), _U("main_entities_subtitle"), Config.MenuStyle.Margins.left, Config.MenuStyle.Margins.top, _var.menus.editor.bannerTexture, _var.menus.editor.bannerTexture)

	applyMenuStyle(_var.menus.editor.objects)

	_var.menus.editor.isOpened = true
	RageUI.Visible(_var.menus.editor.objects.main, true)

	-- Menu pools
	while _var.menus.editor.isOpened do
		RageUI.IsVisible(_var.menus.editor.objects.main, true, Config.MenuStyle.BannerStyle.UseGlareEffect, Config.MenuStyle.BannerStyle.UseInstructionalButtons, function()
			main_showContentThisFrame()
		end)
		RageUI.IsVisible(_var.menus.editor.objects.mainMaps, true, Config.MenuStyle.BannerStyle.UseGlareEffect, Config.MenuStyle.BannerStyle.UseInstructionalButtons, function()
			main_maps_showContentThisFrame()
		end)
		RageUI.IsVisible(_var.menus.editor.objects.mainMetadata, true, Config.MenuStyle.BannerStyle.UseGlareEffect, Config.MenuStyle.BannerStyle.UseInstructionalButtons, function()
			main_metadata_showContentThisFrame()
		end)
		RageUI.IsVisible(_var.menus.editor.objects.mainSettings, true, Config.MenuStyle.BannerStyle.UseGlareEffect, Config.MenuStyle.BannerStyle.UseInstructionalButtons, function()
			main_settings_showContentThisFrame()
		end)
		RageUI.IsVisible(_var.menus.editor.objects.mainEntities, true, Config.MenuStyle.BannerStyle.UseGlareEffect, Config.MenuStyle.BannerStyle.UseInstructionalButtons, function()
			main_entities_showContentThisFrame()
		end)
		Citizen.Wait(0)
	end
	if isEditorMenuVisible() then
		RageUI.CloseAll()
	end
end

---isEditorMenuVisible → Check if one of the main menus is visible
---@return boolean
function isEditorMenuVisible()
	for _k, rageObject in pairs(_var.menus.editor.objects) do
		if RageUI.Visible(rageObject) then
			return true
		end
	end
	return false
end

---loadCreatorTexts → Load the game texts used by the R* creator (props and categories labels)
---@return boolean
function loadCreatorTexts()
	if not HasThisAdditionalTextLoaded("FMMC", 7) then
		RequestAdditionalText("FMMC", 7)
		local timeout = GetGameTimer() + 5000
		while not HasThisAdditionalTextLoaded("FMMC", 7) and GetGameTimer() < timeout do
			Citizen.Wait(0)
		end
	end
	return HasThisAdditionalTextLoaded("FMMC", 7)
end

---resetMenuPosition → Go back to the first item of a menu
---@param menu table
---@return void
function resetMenuPosition(menu)
	menu.Index = 1
	menu.Pagination.Minimum = 1
	menu.Pagination.Maximum = menu.Pagination.Total
end

---initSpawnMenus → Create the menus used to add entities in the map
---@return void
local function initSpawnMenus()
	if _var.menus.spawn.objects.objects then
		return
	end

	loadCreatorTexts()

	-- RageUI menu initialization
	-- init the rageui menu with the config parameters
	_var.menus.spawn.objects.objects = RageUI.CreateMenu(_("menu_title"), _("objects_subtitle"), Config.MenuStyle.Margins.left, Config.MenuStyle.Margins.top, _var.menus.editor.bannerTexture, _var.menus.editor.bannerTexture)
	_var.menus.spawn.objects.peds = RageUI.CreateMenu(_("menu_title"), _("peds_subtitle"), Config.MenuStyle.Margins.left, Config.MenuStyle.Margins.top, _var.menus.editor.bannerTexture, _var.menus.editor.bannerTexture)
	_var.menus.spawn.objects.vehicles = RageUI.CreateMenu(_("menu_title"), _("vehicles_subtitle"), Config.MenuStyle.Margins.left, Config.MenuStyle.Margins.top, _var.menus.editor.bannerTexture, _var.menus.editor.bannerTexture)
	_var.menus.spawn.objects.entity = RageUI.CreateMenu(_("menu_title"), _("entity_subtitle"), Config.MenuStyle.Margins.left, Config.MenuStyle.Margins.top, _var.menus.editor.bannerTexture, _var.menus.editor.bannerTexture)

	for _k, rageObject in pairs(_var.menus.spawn.objects) do
		rageObject.Closed = function()
			saveSpawnMenuIndex()
			_var.menus.closedFrame = GetFrameCount()
		end
	end

	applyMenuStyle(_var.menus.spawn.objects)
end

---openSpawnMenu → Function to open a menu used to add entities in the map
---@param name string
---@return void
function openSpawnMenu(name)
	initSpawnMenus()
	saveSpawnMenuIndex()
	_var.menus.spawn.current = name
	local menu = _var.menus.spawn.objects[name]
	RageUI.Visible(menu, true)

	-- Restore the position of the menu when it has been closed by an action
	local savedIndex = _var.menus.spawn.savedIndexes[name]
	if savedIndex and name ~= "entity" then
		menu.Index = savedIndex.index
		menu.Pagination.Minimum = savedIndex.minimum
		menu.Pagination.Maximum = savedIndex.maximum
	else
		resetMenuPosition(menu)
	end

	-- Check if the menu pool is already running
	if _var.menus.spawn.isOpened then
		return
	end
	_var.menus.spawn.isOpened = true

	-- Menu pools
	Citizen.CreateThread(function()
		while _var.menus.spawn.isOpened do
			RageUI.IsVisible(_var.menus.spawn.objects.objects, true, Config.MenuStyle.BannerStyle.UseGlareEffect, Config.MenuStyle.BannerStyle.UseInstructionalButtons, function()
				objects_showContentThisFrame()
			end)
			RageUI.IsVisible(_var.menus.spawn.objects.peds, true, Config.MenuStyle.BannerStyle.UseGlareEffect, Config.MenuStyle.BannerStyle.UseInstructionalButtons, function()
				peds_showContentThisFrame()
			end)
			RageUI.IsVisible(_var.menus.spawn.objects.vehicles, true, Config.MenuStyle.BannerStyle.UseGlareEffect, Config.MenuStyle.BannerStyle.UseInstructionalButtons, function()
				vehicles_showContentThisFrame()
			end)
			RageUI.IsVisible(_var.menus.spawn.objects.entity, true, Config.MenuStyle.BannerStyle.UseGlareEffect, Config.MenuStyle.BannerStyle.UseInstructionalButtons, function()
				entity_showContentThisFrame()
			end)
			if not isSpawnMenuVisible() then
				_var.menus.spawn.isOpened = false
			end
			Citizen.Wait(0)
		end
		_var.menus.spawn.current = nil
	end)
end

---openSpawnMenuNextFrame → Open a spawn menu on the next frame (the key used to open it is not used by the menu)
---@param name string
---@return void
function openSpawnMenuNextFrame(name)
	Citizen.CreateThread(function()
		Citizen.Wait(0)
		openSpawnMenu(name)
	end)
end

---isSpawnMenuVisible → Check if one of the menus used to add entities is visible
---@return boolean
function isSpawnMenuVisible()
	for _k, rageObject in pairs(_var.menus.spawn.objects) do
		if RageUI.Visible(rageObject) then
			return true
		end
	end
	return false
end

---saveSpawnMenuIndex → Save the position of the visible spawn menu, to restore it when the menu is opened again
---@return void
function saveSpawnMenuIndex()
	for name, rageObject in pairs(_var.menus.spawn.objects) do
		if RageUI.Visible(rageObject) then
			_var.menus.spawn.savedIndexes[name] = {
				index = rageObject.Index,
				minimum = rageObject.Pagination.Minimum,
				maximum = rageObject.Pagination.Maximum,
			}
		end
	end
end

---resetSpawnMenuIndex → Go back to the first item of a spawn menu (used when its filters change)
---@param name string
---@return void
function resetSpawnMenuIndex(name)
	resetMenuPosition(_var.menus.spawn.objects[name])
	_var.menus.spawn.savedIndexes[name] = nil
end

---closeSpawnMenu → Close the menu used to add entities without cancelling the action
---@return void
function closeSpawnMenu()
	if isSpawnMenuVisible() then
		saveSpawnMenuIndex()
		RageUI.CloseAll()
		_var.menus.closedFrame = GetFrameCount()
	end
	_var.menus.spawn.isOpened = false
end
