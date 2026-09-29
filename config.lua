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

Config.Keys = { -- [table] → The keys (they can be changed by each player in the FiveM key bindings settings)
	Menu = "F9", -- [string] → Open the map editor menu
	Gizmo = "MOUSE_LEFT", -- [string] → Drag the gizmo of the selected entity
	LookAround = "MOUSE_RIGHT", -- [string] → Hold to look around when an entity is selected
	GizmoMode = "TAB", -- [string] → Switch the gizmo between move and rotate
}

Config.Permissions = {
	UseAce = false, -- [boolean] → Restrict the map editor to the players who have the ace permission below
	Ace = "epyi_mapeditor.access", -- [string] → The ace permission needed to use the map editor (only used if UseAce is true)
}

Config.Maps = {
	RefreshInterval = 5000, -- [integer] → Interval in milliseconds between two checks of the maps folder
	MaxSize = 5000000, -- [integer] → Maximum size in characters of a map sent to the server
	TransferSpeed = 500000, -- [integer] → Speed in bytes per second of the maps transfers between the server and the clients
}

Config.Settings = { -- [table] → Default editor settings (they can be changed in game in the settings menu)
	UseGizmo = true, -- [boolean] → Show a 3D gizmo (with the mouse cursor) to move and rotate the selected entity
	ShowRadar = true, -- [boolean] → Show the radar in the editor
	ShowXYZAxis = true, -- [boolean] → Show the XYZ axes of the selected entity (only when the gizmo is disabled)
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
	SelectEntity = 24, -- [integer] → Select the entity under the crosshair, or place the object being added (default: LEFT MOUSE BUTTON)
	AlignItem = 73, -- [integer] → Align the entity on the surface or the entity under the crosshair (default: X)
	PlaceItem = 176, -- [integer] → Place the object being added (default: ENTER)
	StampModifier = 21, -- [integer] → Hold while placing an object to keep adding the same object (default: LEFT SHIFT)
	CancelAdding = 200, -- [integer] → Cancel the object being added (default: ESC)
	ScrollUp = 241, -- [integer] → Increase the camera speed, or rotate the object being added (default: MOUSE WHEEL UP)
	ScrollDown = 242, -- [integer] → Decrease the camera speed, or rotate the object being added (default: MOUSE WHEEL DOWN)
	DeselectEntity = 200, -- [integer] → Deselect the selected entity (default: ESC)
	EditEntity = 176, -- [integer] → Open the menu of the selected entity (default: ENTER)
	FreemoveEntity = 47, -- [integer] → Hold to move the selected entity to the crosshair (default: G)
	SnapToGround = 20, -- [integer] → Put the selected entity on the ground (default: Z)
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
