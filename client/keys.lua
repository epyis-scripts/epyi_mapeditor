-- Key registering
-- register the key to open the map editor menu
Keys.Register(Config.Keys.Menu, "-openMapEditorMenu", _("keys_menu_description"), function()
	openMenu()
end)
