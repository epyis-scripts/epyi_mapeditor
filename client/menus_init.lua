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
	end

	_var.menus.editor.objects.mainMaps = RageUI.CreateSubMenu(_var.menus.editor.objects.main, _U("menu_title"), _U("main_maps_subtitle"), Config.MenuStyle.Margins.left, Config.MenuStyle.Margins.top, _var.menus.editor.bannerTexture, _var.menus.editor.bannerTexture)
	_var.menus.editor.objects.mainMetadata = RageUI.CreateSubMenu(_var.menus.editor.objects.main, _U("menu_title"), _U("main_metadata_subtitle"), Config.MenuStyle.Margins.left, Config.MenuStyle.Margins.top, _var.menus.editor.bannerTexture, _var.menus.editor.bannerTexture)
	_var.menus.editor.objects.mainSettings = RageUI.CreateSubMenu(_var.menus.editor.objects.main, _U("menu_title"), _U("main_settings_subtitle"), Config.MenuStyle.Margins.left, Config.MenuStyle.Margins.top, _var.menus.editor.bannerTexture, _var.menus.editor.bannerTexture)

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

---initSpawnMenus → Create the menus used to add entities in the map
---@return void
local function initSpawnMenus()
	if _var.menus.spawn.objects.objects then
		return
	end

	-- Load the game texts used by the R* creator
	RequestAdditionalText("FMMC", 7)
	local timeout = GetGameTimer() + 5000
	while not HasThisAdditionalTextLoaded("FMMC", 7) and GetGameTimer() < timeout do
		Citizen.Wait(0)
	end

	-- RageUI menu initialization
	-- init the rageui menu with the config parameters
	_var.menus.spawn.objects.objects = RageUI.CreateMenu(_("menu_title"), _("objects_subtitle"), Config.MenuStyle.Margins.left, Config.MenuStyle.Margins.top, _var.menus.editor.bannerTexture, _var.menus.editor.bannerTexture)
	_var.menus.spawn.objects.peds = RageUI.CreateMenu(_("menu_title"), _("peds_subtitle"), Config.MenuStyle.Margins.left, Config.MenuStyle.Margins.top, _var.menus.editor.bannerTexture, _var.menus.editor.bannerTexture)
	_var.menus.spawn.objects.vehicles = RageUI.CreateMenu(_("menu_title"), _("vehicles_subtitle"), Config.MenuStyle.Margins.left, Config.MenuStyle.Margins.top, _var.menus.editor.bannerTexture, _var.menus.editor.bannerTexture)

	_var.menus.spawn.objects.objects.Closed = function()
		cancelObjectAdding()
	end

	applyMenuStyle(_var.menus.spawn.objects)
end

---openSpawnMenu → Function to open a menu used to add entities in the map
---@param name string
---@return void
function openSpawnMenu(name)
	initSpawnMenus()
	_var.menus.spawn.current = name
	RageUI.Visible(_var.menus.spawn.objects[name], true)

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
			if not isSpawnMenuVisible() then
				_var.menus.spawn.isOpened = false
			end
			Citizen.Wait(0)
		end
		_var.menus.spawn.current = nil
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

---closeSpawnMenu → Close the menu used to add entities without cancelling the action
---@return void
function closeSpawnMenu()
	if isSpawnMenuVisible() then
		RageUI.CloseAll()
	end
	_var.menus.spawn.isOpened = false
end
