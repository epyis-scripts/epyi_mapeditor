Config = {}
Config.locale = GetConvar("epyi_mapeditor:locale", "en")

Config.MenuStyle = {
	Margins = { left = 10, top = 10 }, -- [table] → Set the menu margins
	BannerStyle = {
		Color = { r = 150, g = 50, b = 50, a = 100 }, -- [table] → Set the banner color if no custom banner image is set
		UseGlareEffect = false, -- [boolean] → Use the glare effect or not
		UseInstructionalButtons = false, -- [boolean] → Use the menu instructionals buttons or not (the editor already shows its own instructionals buttons)
		ImageUrl = nil, -- [nil/string] → Set a custom image url if you want (if set, it will disable the Color configuration)
		ImageSize = { Width = 512, Height = 128 }, -- [table] → Set the image (ImageUrl) size in pixels
		widthOffset = 0, -- [integer] → Offset of the menu (default: 0, max: 100)
	},
}

Config.Keys = { -- [table] → The menu keys
	Menu = "F10",
}

Config.Permissions = {
	UseAce = false, -- [boolean] → Restrict the map editor to the players who have the ace permission below
	Ace = "epyi_mapeditor.access", -- [string] → The ace permission needed to use the map editor (only used if UseAce is true)
}

Config.Maps = {
	RefreshInterval = 5000, -- [integer] → Interval in milliseconds between two checks of the maps folder
	MaxSize = 5000000, -- [integer] → Maximum size in characters of a map sent to the server
}

Config.Settings = { -- [table] → Default editor settings (they can be changed in game in the settings menu)
	ShowRadar = true, -- [boolean] → Show the radar in the editor
	ShowXYZAxis = true, -- [boolean] → Show the XYZ axes of the selected entity
	Show3DCursor = true, -- [boolean] → Show the 3D cursor
	CameraSpeedIndex = 3, -- [integer] → Default camera speed (1: very slow, 2: slow, 3: normal, 4: fast, 5: very fast)
	ShowInstructionalButtons = true, -- [boolean] → Show the editor instructionals buttons
	ShowInfoBars = true, -- [boolean] → Show the entities counts
	ShowSelectionMarker = true, -- [boolean] → Show the rotation axis markers of the selected entity
	ShowBoundingBox = true, -- [boolean] → Show the bounding box of the selected entity
	RelativeTranslation = true, -- [boolean] → Move the selected entity relatively to its own axes (false: world axes)
	NetworkObjects = false, -- [boolean] → EXPERIMENTAL: Network the created map entities
}

Config.Controls = { -- [table] → Editor controls (list of controls: https://docs.fivem.net/docs/game-references/controls/)
	-- Map controls
	ObjectCreate = 166, -- [integer] → Add an object (default: F5)
	PedCreate = 167, -- [integer] → Add a ped (default: F6)
	VehicleCreate = 168, -- [integer] → Add a vehicle (default: F7)
	SelectEntity = 24, -- [integer] → Select the entity under the cursor (default: LEFT MOUSE BUTTON)
	AlignItem = 73, -- [integer] → Align the entity on the surface or the entity under the cursor (default: X)
	PlaceItem = 176, -- [integer] → Place the object being added (default: ENTER)
	DeselectEntity = 200, -- [integer] → Deselect the selected entity (default: ESC)
	FreemoveEntity = 25, -- [integer] → Drag the selected entity with the cursor (default: RIGHT MOUSE BUTTON)
	DeleteEntity = 256, -- [integer] → Delete the selected entity (default: DELETE)
	CloneEntity = 26, -- [integer] → Hold and press the Y translation keys to clone the selected entity (default: C)
	ChangeTranslationMode = 157, -- [integer] → Toggle the relative/absolute translation mode (default: 1)
	ChangeRotationAxis = 158, -- [integer] → Change the rotation axis (default: 2)
	RotateOverAngle = 160, -- [integer] → Rotate the selected entity over 15° (default: 3)
	RotateCW = 85, -- [integer] → Rotate clockwise (default: Q)
	RotateACW = 51, -- [integer] → Rotate anticlockwise (default: E)
	TranslateZUp = 45, -- [integer] → Move up (default: R)
	TranslateZDown = 75, -- [integer] → Move down (default: F)
	TranslateXUp = 175, -- [integer] → Move right (default: ARROW RIGHT)
	TranslateXDown = 174, -- [integer] → Move left (default: ARROW LEFT)
	TranslateYUp = 172, -- [integer] → Move forward (default: ARROW UP)
	TranslateYDown = 173, -- [integer] → Move backward (default: ARROW DOWN)

	-- Camera controls
	CamForward = 71, -- [integer] → Move the camera forward (default: W)
	CamBackward = 72, -- [integer] → Move the camera backward (default: S)
	CamLeft = 63, -- [integer] → Move the camera to the left (default: A)
	CamRight = 64, -- [integer] → Move the camera to the right (default: D)
	CamUp = 22, -- [integer] → Move the camera up (default: SPACEBAR)
	CamDown = 132, -- [integer] → Move the camera down (default: LEFT CTRL)

	-- Speed controls
	GottaGoFast = 21, -- [integer] → Hold to go faster (default: LEFT SHIFT)
	GottaGoSlow = 19, -- [integer] → Hold to go slower (default: LEFT ALT)
}
