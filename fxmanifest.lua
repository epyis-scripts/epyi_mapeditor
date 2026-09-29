fx_version("cerulean")
game("gta5")
use_experimental_fxv2_oal("yes")
lua54("yes")

name("epyi_mapeditor")
description("A RageUI standalone map editor for FiveM")
author("Epyi")
version("0.1.0")

shared_scripts({
	"shared/locale.lua",
	"locales/*.lua",

	"config.lua",
	"shared/xml.lua",
})

client_scripts({
	"src/RMenu.lua",
	"src/menu/RageUI.lua",
	"src/menu/Menu.lua",
	"src/menu/MenuController.lua",
	"src/components/*.lua",
	"src/menu/elements/*.lua",
	"src/menu/items/*.lua",
	"src/menu/panels/*.lua",
	"src/menu/windows/*.lua",

	"client/var_init.lua",
	"client/instructionnal.lua",
	"client/menus_init.lua",
	"client/keys.lua",
	"client/misc.lua",
	"client/map.lua",
	"client/threads.lua",
	"client/menus/*.lua",
})

server_scripts({
	"server/logs.lua",
	"server/version_check.lua",
	"server/var_init.lua",
	"server/misc.lua",
	"server/maps.lua",
})
