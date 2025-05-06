--[[
	ROYALE HIGH ACCESSORY PRESERVER V2		|
	PROUDLY MADE BY XANE MYERS IN APRIL 2025|
	LAST UPDATED MAY 6TH, 2025				|
	----------------------------------------/
	An amazing psuedo-sequel to an already powerful script, used for saving various (mostly 3D) assets from Roblox experiences,
	including but no longer limited to Royale High! Run this script (preferably using Infinite Fun's 'rhsave' command) then tap
	the second button (the "list" button) to open the main window. Here, you can tap any orange button near its top to scan for
	any Instances, Models, or GUI elements that match that "category"'s  criteria.
	
	Pick something from the list then tap either "save" button to copy it to a folder in Lighting, a container Roblox games
	barely use. Everything is placed in a sub-folder, but you can enter a name using the text box at the top of the window to
	organize your saved items into specific sub-folders!
	
	Once you've saved everything you wanted (or start worrying you could get disconnected or kicked soon), you have a couple of
	options to keep everything you took the time to copy/save:
	
	1. INFINITE FUN & UNIVERSALSYNSAVEINSTANCE (HIGHLY RECOMMENDED AND SIMPLE)
	Run this LoadString to launch Infinite Fun. (I recommend putting this in a file, then moving it to your executor's
	"autoexec" folder so it always appears as you spawn into any game!)
	
	loadstring(game:HttpGet('https://raw.githubusercontent.com/Xane123/InfiniteFun_IY/master/source'))()
	
	When Infinite Fun's GUI appears, press the semicolon (;) key (on a computer) or tap the "IF" button (for mobile devices) to
	make its "command line" appear. Write "saveplace external" (without the quotation marks) then press ENTER to launch
	UniversalSynSaveInstance, which will do the rest of the work, putting everything in a large RBXLX file. When it's done
	(check the white text in the upper-right corner of the screen), check your executor's workspace folder.
	
	Transfer the new RBXLX file to your computer and open it in Roblox Studio to check out the place/realm you saved. Anything
	you saved using RH Accessory Preserver is placed in 💡Lighting, in the "Saved Items" folder.
	
	2. UNIVERSALSYNSAVEINSTANCE ('saveplace external' in Infinite Fun)
	The easiest option, which I HIGHLY recommend! Run the script (use Infinite Fun to make it super easy, running that command)
	then wait until the message in the top-right corner turns green and says that the file was written.
	
	From there, check your executor's workspace folder, transfer the RBXLX file to the computer, open it in Roblox Studio, then
	check the Lighting service in the Explorer pane. Your saved items/models/GUI will be inside the "Saved Items" folder!
	
	3. XANE'S MODEL RECREATOR ('xmr' in Infinite Fun)
	Close RH Accessory Preserver then open Xane's Model Recreator. Tap the "select" button at the top of your screen, then tap
	the "Lighting" button. When the list appears, select the "lighting" list item or the "Saved Items" folder by tapping on its
	icon/emoji. Once the checkmark emoji appears, enter a name in the text box at the bottom, then tap the "save" button.
	
	Unfortunately, this process isn't as quick as it could be. Install the "Xane's Asset Importer" plugin by following these
	steps:
	
	1.	Download its RBXM file from this URL:
		https://www.dropbox.com/scl/fi/xrv2mx9gpjlvks3vnisz4/XMDLRecreator_ImportTool.rbxm?rlkey=ltv22ona3z1r1uxz946zw9mdy&dl=1
	2.	In Roblox Studio, open your Plugins Folder (in the new GUI, go to Plugins > Plugins Folder). Drag or move the RBXM file
		into this folder.
	3.	Close then re-open your current place/RBXL file. As your place opens, a new panel named "Xane's Asset Importer" should
		appear, either in the middle of the screen or in your left sidebar.
	4.	Check your executor's workspace folder, and transfer the JSON files with the name you entered in Xane's Model Recreator
		to your computer.
	5.	Open all of the files in a text editor, preferably one with tabs.
	6.	For each file, copy its text, paste it into the sidebar, then press ENTER/click off, starting with #_header.json, then
		advancing through each #_piece#.json file.
	7.	Customize your import, click the "start" button, then wait until your import is complete.
	
	DONE! Everything below this is just a personal note-to-self because my memory has become a complete JOKE in 2025...
	
	TODO: Finish programming the ScanTypes and SaveTypes:
	
	ScanTypes:
	•	DormRH		Tries to find the active dorm, and allows the user to save the full room or any item in it, individually.
	•	(DTI or It Girl character type that would replace WeldConstraints with Welds, trying to maintain offsets and links?)
	
	SaveTypes:
	•	Tool		Clones a matching tool found in a player's Backpack, character model, or StarterPack.
	•	CharaRH		Temporarily moves EquippedStorage subfolders into the character then clones it, maintaining Weld links.
	•	ItemRH		For accessories, skirts, wings, and hair Models. Tries to find each piece's "main Weld", disconnects, then clones it.
	•	HeelsRH		Saves this Player's character model, then replaces their skin tone, name, and face with generic alternatives.
	•	DormRH		Re-locates the loaded dorm room, then clones the full model.
	•	FurniRH		Tries to find either an item with a matching debug ID or name within the loaded dorm, cloning and anonymizing it.
	
	LAST TODO: Start working on the missing SaveTypes! The RH-specific SaveTypes (CharaRH and DormRH) are implemented, and can list
	instances, but nothing they list can be previewed or saved until those types are defined.
]]--

if not game:IsLoaded() then game.Loaded:Wait() end

-- SERVICES
local Players							= game:GetService("Players")
local Lighting							= game:GetService("Lighting")
local ReplicatedStorage					= game:GetService("ReplicatedStorage")
local StarterPack						= game:GetService("StarterPack")
local TweenService						= game:GetService("TweenService")
local Debris							= game:GetService("Debris")

local CamScriptURL						=	-- URL for this script's "3D preview" camera script. Could be expanded to check 2 URLs.
	"https://raw.githubusercontent.com/Xane123/Roblox-Scripts/main/RHAccessoryPreserver/new_camScript.luau"

-- REFERENCES
local LocalPlayer						= Players.LocalPlayer
local PlayerGui : PlayerGui?			= LocalPlayer:WaitForChild("PlayerGui")

local function FindPlayerGui()
	while not PlayerGui do
		PlayerGui						= LocalPlayer.PlayerGui
		task.wait(0.333)
	end
	
	return PlayerGui
end
LocalPlayer.CharacterRemoving:Connect(function()
	PlayerGui							= nil
end)
LocalPlayer.CharacterAppearanceLoaded:Connect(function(_char)
	_ = FindPlayerGui()
end)
_ = FindPlayerGui()

-- CONSTRUCT RH ACCESSORY PRESERVER V2'S GUI (this code was made by Roblox2Lua and modified by me)
local hiddenUI = get_hidden_gui or gethui
if not hiddenUI then error("Your executor doesn't support hiding GUI's, so it's too unsafe to use this script. Sorry!") end

-- CONSTANTS (PART 1, FOR GUI INITIALIZATION AND EXECUTION)
local DEF_PREVIEW_MSG	= "Select an item from the left-side list to preview it here!"

local DEF_GROUP_NAME	= "Untitled Group"	-- Initial save sub-folder's name

local COLOR_WHITE		= Color3.new(1, 1, 1)
local COLOR_ANON_SKIN	= Color3.new(192, 192, 192)

local R15_BODY_PARTS	= {	-- The standard R15 body part names
	"LowerTorso",
	"UpperTorso",
	"Head",
	"LeftUpperArm",
	"LeftLowerArm",
	"LeftHand",
	"RightUpperArm",
	"RightLowerArm",
	"RightHand",
	"LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot",
	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot"
}

local RH_FACE_DECALS	= {	-- Royale High's "custom face" layers
	"eyes",
	"mouth",
	"extra"
}

local RH_UNWANTED_ICONS	= {	-- Names of unwanted overhead status indicators like the Dress Up/try on/shopping icons.
	"CharacterCreationIcon",	-- Dressing up
	"ShopIcon",					-- Shopping
	"PreviewIcon",				-- Trying on store clothing
	"TypingGui"					-- Chatting/typing a message
}

local RH_ES_FOLDER_NAMES= {
	"Accessories",
	"Hair",
	"Heels",
	"Skirts",
	"Wings"
}


--[[
	Roblox2Lua
	----------
	
	This code was generated using
	Deluct's Roblox2Lua plugin.
]]--

--// Instances
local temp_z_newGUI1 : Instance?		= nil	-- Temporary variables for GUI elements that aren't referenced in code after creation.
local temp_z_newGUI2 : Instance?		= nil
local temp_z_newGUI3 : Instance?		= nil

local GUI_Base = Instance.new("ScreenGui")
GUI_Base.IgnoreGuiInset = false
GUI_Base.ResetOnSpawn = true
GUI_Base.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI_Base.Name = "NewRHAccessoryPreserver"
GUI_Base.Parent = hiddenUI()

local GUICarrier_Commands = Instance.new("Frame")
GUICarrier_Commands.Active = true
GUICarrier_Commands.AnchorPoint = Vector2.yAxis / 2
GUICarrier_Commands.BackgroundColor3 = Color3.new(0.15, 0.145, 0.176475)
GUICarrier_Commands.BorderSizePixel = 0
GUICarrier_Commands.Position = UDim2.fromScale(0.625, 0.1)
GUICarrier_Commands.Size = UDim2.fromScale(0.225, 0.1125)
GUICarrier_Commands.Visible = true
GUICarrier_Commands.ZIndex = 2	-- Ensure this GUI stays visible over toasts (brief notifications).
GUICarrier_Commands.Name = "CommandPalette"
GUICarrier_Commands.Parent = GUI_Base

temp_z_newGUI1 = Instance.new("Frame")
temp_z_newGUI1.BackgroundTransparency = 1
temp_z_newGUI1.BorderSizePixel = 0
temp_z_newGUI1.Size = UDim2.fromScale(1, 0.775)
temp_z_newGUI1.Visible = false
temp_z_newGUI1.ZIndex = 0
temp_z_newGUI1.Name = "DragBounds"
temp_z_newGUI1.Parent = GUI_Base

temp_z_newGUI2 = Instance.new("UIDragDetector")
temp_z_newGUI2.BoundingBehavior = Enum.UIDragDetectorBoundingBehavior.EntireObject
temp_z_newGUI2.BoundingUI = temp_z_newGUI1
temp_z_newGUI2.DragRelativity = Enum.UIDragDetectorDragRelativity.Relative
temp_z_newGUI2.DragSpace = Enum.UIDragDetectorDragSpace.LayerCollector
temp_z_newGUI2.ResponseStyle = Enum.UIDragDetectorResponseStyle.Scale
temp_z_newGUI2.SelectionModeDragSpeed = UDim2.fromScale(0.15, 0.2)
temp_z_newGUI2.Parent = GUICarrier_Commands

temp_z_newGUI1 = Instance.new("Frame")
temp_z_newGUI1.BackgroundTransparency = 1
temp_z_newGUI1.BorderSizePixel = 0
temp_z_newGUI1.Size = UDim2.fromScale(0.125, 1)
temp_z_newGUI1.Visible = true
temp_z_newGUI1.Name = "FakeDragArea"
temp_z_newGUI1.Parent = GUICarrier_Commands

temp_z_newGUI2 = Instance.new("Frame")
temp_z_newGUI2.AnchorPoint = Vector2.one / 2
temp_z_newGUI2.BackgroundColor3 = COLOR_WHITE
temp_z_newGUI2.BackgroundTransparency = 0.75
temp_z_newGUI2.BorderSizePixel = 0
temp_z_newGUI2.Position = UDim2.fromScale(0.167, 0.5)
temp_z_newGUI2.Size = UDim2.new(0, 2, 0.75, 0)
temp_z_newGUI2.Visible = true
temp_z_newGUI2.Name = "StripeLeft"
temp_z_newGUI2.Parent = temp_z_newGUI1

temp_z_newGUI3 = Instance.new("UICorner")
temp_z_newGUI3.CornerRadius = UDim.new(1, 0)
temp_z_newGUI3.Name = "StripeCurve"
temp_z_newGUI3.Parent = temp_z_newGUI2

temp_z_newGUI2 = Instance.new("Frame")
temp_z_newGUI2.AnchorPoint = Vector2.one / 2
temp_z_newGUI2.BackgroundColor3 = COLOR_WHITE
temp_z_newGUI2.BackgroundTransparency = 0.75
temp_z_newGUI2.BorderSizePixel = 0
temp_z_newGUI2.Position = UDim2.fromScale(0.333, 0.5)
temp_z_newGUI2.Size = UDim2.new(0, 2, 0.75, 0)
temp_z_newGUI2.Visible = true
temp_z_newGUI2.Name = "StripeRight"
temp_z_newGUI2.Parent = temp_z_newGUI1

temp_z_newGUI3 = Instance.new("UICorner")
temp_z_newGUI3.CornerRadius = UDim.new(1, 0)
temp_z_newGUI3.Name = "StripeCurve"
temp_z_newGUI3.Parent = temp_z_newGUI2

temp_z_newGUI1 = Instance.new("UIListLayout")
temp_z_newGUI1.HorizontalFlex = Enum.UIFlexAlignment.Fill
temp_z_newGUI1.Padding = UDim.new(0, 3)
temp_z_newGUI1.FillDirection = Enum.FillDirection.Horizontal
temp_z_newGUI1.HorizontalAlignment = Enum.HorizontalAlignment.Center
temp_z_newGUI1.SortOrder = Enum.SortOrder.LayoutOrder
temp_z_newGUI1.VerticalAlignment = Enum.VerticalAlignment.Center
temp_z_newGUI1.Parent = GUICarrier_Commands

local Button_CloseCmd = Instance.new("TextButton")
Button_CloseCmd.Font = Enum.Font.Ubuntu
Button_CloseCmd.Text = "❌"
Button_CloseCmd.TextColor3 = COLOR_WHITE
Button_CloseCmd.TextScaled = true
Button_CloseCmd.TextStrokeTransparency = 0.5
Button_CloseCmd.TextWrapped = true
Button_CloseCmd.TextYAlignment = Enum.TextYAlignment.Bottom
Button_CloseCmd.BackgroundColor3 = Color3.new(0.901961, 0.458824, 0.717647)
Button_CloseCmd.BorderSizePixel = 0
Button_CloseCmd.LayoutOrder = 3
Button_CloseCmd.Size = UDim2.fromScale(0.333, 1)
Button_CloseCmd.Visible = true
Button_CloseCmd.Name = "ButtonExit"
Button_CloseCmd:SetAttribute("DisabledColor", Color3.fromRGB(177, 118, 102))
Button_CloseCmd:SetAttribute("EnabledColor", Color3.fromRGB(235, 160, 137))
Button_CloseCmd.Parent = GUICarrier_Commands

temp_z_newGUI1 = Instance.new("UICorner")
temp_z_newGUI1.CornerRadius = UDim.new(0.125, 0)
temp_z_newGUI1.Parent = Button_CloseCmd

temp_z_newGUI1 = Instance.new("UIPadding")
temp_z_newGUI1.PaddingBottom = UDim.new(0.1, 0)
temp_z_newGUI1.PaddingLeft = UDim.new(0.1, 0)
temp_z_newGUI1.PaddingRight = UDim.new(0.1, 0)
temp_z_newGUI1.PaddingTop = UDim.new(0.1, 0)
temp_z_newGUI1.Parent = Button_CloseCmd

local Button_ListCmd = Instance.new("TextButton")
Button_ListCmd.Font = Enum.Font.Ubuntu
Button_ListCmd.Text = "📃"
Button_ListCmd.TextColor3 = COLOR_WHITE
Button_ListCmd.TextScaled = true
Button_ListCmd.TextStrokeTransparency = 0.5
Button_ListCmd.TextWrapped = true
Button_ListCmd.TextYAlignment = Enum.TextYAlignment.Bottom
Button_ListCmd.BackgroundColor3 = Color3.new(0.5, 0.68225, 0.941175)
Button_ListCmd.BorderSizePixel = 0
Button_ListCmd.LayoutOrder = 1
Button_ListCmd.Size = UDim2.fromScale(0.333, 1)
Button_ListCmd.Visible = true
Button_ListCmd.Name = "ButtonList"
Button_ListCmd:SetAttribute("DisabledColor", Color3.fromRGB(102, 118, 177))
Button_ListCmd:SetAttribute("EnabledColor", Color3.fromRGB(137, 160, 235))
Button_ListCmd.Parent = GUICarrier_Commands

temp_z_newGUI1 = Instance.new("UICorner")
temp_z_newGUI1.CornerRadius = UDim.new(0.125, 0)
temp_z_newGUI1.Parent = Button_ListCmd

temp_z_newGUI1 = Instance.new("UIPadding")
temp_z_newGUI1.PaddingBottom = UDim.new(0.1, 0)
temp_z_newGUI1.PaddingLeft = UDim.new(0.1, 0)
temp_z_newGUI1.PaddingRight = UDim.new(0.1, 0)
temp_z_newGUI1.PaddingTop = UDim.new(0.1, 0)
temp_z_newGUI1.Parent = Button_ListCmd

local Button_SaveCmd = Instance.new("TextButton")
Button_SaveCmd.Font = Enum.Font.Ubuntu
Button_SaveCmd.Text = "💾"
Button_SaveCmd.TextColor3 = COLOR_WHITE
Button_SaveCmd.TextScaled = true
Button_SaveCmd.TextStrokeTransparency = 0.5
Button_SaveCmd.TextWrapped = true
Button_SaveCmd.TextYAlignment = Enum.TextYAlignment.Bottom
Button_SaveCmd.BackgroundColor3 = Color3.new(0.5, 0.68225, 0.941175)
Button_SaveCmd.Active = false
Button_SaveCmd.BorderSizePixel = 0
Button_SaveCmd.LayoutOrder = 2
Button_SaveCmd.Size = UDim2.fromScale(0.333, 1)
Button_SaveCmd.Visible = true
Button_SaveCmd.Name = "ButtonSave"
Button_SaveCmd:SetAttribute("DisabledColor", Color3.fromRGB(102, 118, 177))
Button_SaveCmd:SetAttribute("EnabledColor", Color3.fromRGB(137, 160, 235))
Button_SaveCmd.Parent = GUICarrier_Commands

temp_z_newGUI1 = Instance.new("UICorner")
temp_z_newGUI1.CornerRadius = UDim.new(0.125, 0)
temp_z_newGUI1.Parent = Button_SaveCmd

temp_z_newGUI1 = Instance.new("UIPadding")
temp_z_newGUI1.PaddingBottom = UDim.new(0.1, 0)
temp_z_newGUI1.PaddingLeft = UDim.new(0.1, 0)
temp_z_newGUI1.PaddingRight = UDim.new(0.1, 0)
temp_z_newGUI1.PaddingTop = UDim.new(0.1, 0)
temp_z_newGUI1.Parent = Button_SaveCmd

temp_z_newGUI1 = Instance.new("UICorner")
temp_z_newGUI1.CornerRadius = UDim.new(0.2, 0)
temp_z_newGUI1.Parent = GUICarrier_Commands

temp_z_newGUI1 = Instance.new("UIAspectRatioConstraint")
temp_z_newGUI1.AspectRatio = 3.5
temp_z_newGUI1.Parent = GUICarrier_Commands

local GUI_ToastBounds = Instance.new("Frame")
GUI_ToastBounds.AnchorPoint = Vector2.new(1, 1)
GUI_ToastBounds.BackgroundTransparency = 1
GUI_ToastBounds.BorderSizePixel = 0
GUI_ToastBounds.ClipsDescendants = true
GUI_ToastBounds.Active = false
GUI_ToastBounds.Interactable = true
GUI_ToastBounds.Position = UDim2.new(1, -8, 1, -8)
GUI_ToastBounds.Size = UDim2.new(0.5, 0, 0.75, 0)
GUI_ToastBounds.Visible = true
GUI_ToastBounds.ZIndex = 3
GUI_ToastBounds.Name = "ToastBounds"
GUI_ToastBounds.Parent = GUI_Base

temp_z_newGUI1 = Instance.new("UIListLayout")
temp_z_newGUI1.Padding = UDim.new(0, 3)
temp_z_newGUI1.HorizontalAlignment = Enum.HorizontalAlignment.Center
temp_z_newGUI1.SortOrder = Enum.SortOrder.LayoutOrder
temp_z_newGUI1.VerticalAlignment = Enum.VerticalAlignment.Bottom
temp_z_newGUI1.Name = "ToastList"
temp_z_newGUI1.Parent = GUI_ToastBounds

local Template_Toast = Instance.new("CanvasGroup")
Template_Toast.Active = true
Template_Toast.AutomaticSize = Enum.AutomaticSize.XY
Template_Toast.BackgroundColor3 = Color3.new(0.141176, 0.145098, 0.156863)
Template_Toast.BorderSizePixel = 0
Template_Toast.GroupTransparency = 1
Template_Toast.Size = UDim2.fromScale(0.25, 0.075)
Template_Toast.Visible = false
Template_Toast.Name = "Template"
Template_Toast.Parent = GUI_Base

temp_z_newGUI1 = Instance.new("UIPadding")
temp_z_newGUI1.PaddingBottom = UDim.new(0, 5)
temp_z_newGUI1.PaddingLeft = UDim.new(0, 5)
temp_z_newGUI1.PaddingRight = UDim.new(0, 5)
temp_z_newGUI1.PaddingTop = UDim.new(0, 5)
temp_z_newGUI1.Parent = Template_Toast

temp_z_newGUI1 = Instance.new("UICorner")
temp_z_newGUI1.CornerRadius = UDim.new(0.25, 0)
temp_z_newGUI1.Parent = Template_Toast

temp_z_newGUI1 = Instance.new("UIListLayout")
temp_z_newGUI1.HorizontalFlex = Enum.UIFlexAlignment.Fill
temp_z_newGUI1.Padding = UDim.new(0, 5)
temp_z_newGUI1.FillDirection = Enum.FillDirection.Horizontal
temp_z_newGUI1.Parent = Template_Toast

temp_z_newGUI1 = Instance.new("TextLabel")
temp_z_newGUI1.Font = Enum.Font.Highway
temp_z_newGUI1.Text = "Placeholder message. (If you see this, please report it as an issue on GitHub: Xane123/Roblox-Scripts"
temp_z_newGUI1.TextColor3 = COLOR_WHITE
temp_z_newGUI1.TextSize = 15
temp_z_newGUI1.TextTruncate = Enum.TextTruncate.AtEnd
temp_z_newGUI1.TextWrapped = true
temp_z_newGUI1.TextXAlignment = Enum.TextXAlignment.Left
temp_z_newGUI1.AutomaticSize = Enum.AutomaticSize.XY
temp_z_newGUI1.BackgroundColor3 = COLOR_WHITE
temp_z_newGUI1.BackgroundTransparency = 1
temp_z_newGUI1.BorderSizePixel = 0
temp_z_newGUI1.Size = UDim2.new(1, 0, 0, 15)
temp_z_newGUI1.Visible = true
temp_z_newGUI1.Name = "Message"
temp_z_newGUI1.Parent = Template_Toast

temp_z_newGUI1 = Instance.new("TextButton")
temp_z_newGUI1.Font = Enum.Font.Highway
temp_z_newGUI1.Text = "⛔"
temp_z_newGUI1.TextColor3 = COLOR_WHITE
temp_z_newGUI1.TextScaled = true
temp_z_newGUI1.TextWrapped = true
temp_z_newGUI1.BackgroundTransparency = 1
temp_z_newGUI1.BorderSizePixel = 0
temp_z_newGUI1.Size = UDim2.fromOffset(15, 15)
temp_z_newGUI1.SizeConstraint = Enum.SizeConstraint.RelativeYY
temp_z_newGUI1.Visible = true
temp_z_newGUI1.Name = "Icon"
temp_z_newGUI1.Parent = Template_Toast

local GUI_Window = Instance.new("Frame")
GUI_Window.Active = true
GUI_Window.AnchorPoint = Vector2.one / 2
GUI_Window.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.196078)
GUI_Window.BorderSizePixel = 0
GUI_Window.Position = UDim2.fromScale(0.5, 0.5)
GUI_Window.Size = UDim2.fromScale(0.725, 0.9)
GUI_Window.Visible = false
GUI_Window.ZIndex = 2
GUI_Window.Name = "WindowBack"
GUI_Window.Parent = GUI_Base

temp_z_newGUI2 = Instance.new("UICorner")
temp_z_newGUI2.CornerRadius = UDim.new(0, 15)
temp_z_newGUI2.Parent = GUI_Window

temp_z_newGUI2 = Instance.new("TextLabel")
temp_z_newGUI2.Font = Enum.Font.FredokaOne
temp_z_newGUI2.Text = "📦 Target Selector"
temp_z_newGUI2.TextColor3 = COLOR_WHITE
temp_z_newGUI2.TextScaled = true
temp_z_newGUI2.TextStrokeTransparency = 0.6
temp_z_newGUI2.TextWrapped = true
temp_z_newGUI2.TextXAlignment = Enum.TextXAlignment.Left
temp_z_newGUI2.AnchorPoint = Vector2.xAxis / 2
temp_z_newGUI2.BackgroundColor3 = Color3.new(0.686275, 0.678431, 0.658824)
temp_z_newGUI2.BorderSizePixel = 0
temp_z_newGUI2.Position = UDim2.fromScale(0.5, 0)
temp_z_newGUI2.Size = UDim2.new(1, 0, 0, 30)
temp_z_newGUI2.Visible = true
temp_z_newGUI2.Name = "TitleBar"
temp_z_newGUI2.Parent = GUI_Window

temp_z_newGUI3 = Instance.new("UICorner")
temp_z_newGUI3.CornerRadius = UDim.new(0, 15)
temp_z_newGUI3.Parent = temp_z_newGUI2

temp_z_newGUI3 = Instance.new("UIGradient")
temp_z_newGUI3.Color = ColorSequence.new(Color3.new(0.396078, 0.607843, 1), Color3.new(1, 0.741176, 0.482353))
temp_z_newGUI3.Name = "WindowTitleGradient"
temp_z_newGUI3.Parent = temp_z_newGUI2

temp_z_newGUI3 = Instance.new("UIPadding")
temp_z_newGUI3.PaddingBottom = UDim.new(0, 5)
temp_z_newGUI3.PaddingLeft = UDim.new(0, 5)
temp_z_newGUI3.PaddingRight = UDim.new(0, 5)
temp_z_newGUI3.PaddingTop = UDim.new(0, 5)
temp_z_newGUI3.Parent = temp_z_newGUI2

local Button_CloseWindow = Instance.new("TextButton")
Button_CloseWindow.Font = Enum.Font.FredokaOne
Button_CloseWindow.Text = "X"
Button_CloseWindow.TextColor3 = Color3.new(0.490196, 0.188235, 0.0862745)
Button_CloseWindow.TextScaled = true
Button_CloseWindow.TextStrokeColor3 = Button_CloseWindow.TextColor3
Button_CloseWindow.TextWrapped = true
Button_CloseWindow.AnchorPoint = Vector2.new(1, 0.5)
Button_CloseWindow.BackgroundColor3 = Color3.new(1, 0.529412, 0.294118)
Button_CloseWindow.BorderSizePixel = 0
Button_CloseWindow.Position = UDim2.new(1, 2, 0.5, 0)
Button_CloseWindow.Size = UDim2.new(1, 2, 1, 2)
Button_CloseWindow.SizeConstraint = Enum.SizeConstraint.RelativeYY
Button_CloseWindow.Visible = true
Button_CloseWindow.Name = "CloseButton"
Button_CloseWindow.Parent = temp_z_newGUI2

temp_z_newGUI3 = Instance.new("UICorner")
temp_z_newGUI3.CornerRadius = UDim.new(1, 0)
temp_z_newGUI3.Parent = Button_CloseWindow

temp_z_newGUI3 = Instance.new("UIPadding")
temp_z_newGUI3.PaddingLeft = UDim.new(0.03125, 0)
temp_z_newGUI3.Parent = Button_CloseWindow

temp_z_newGUI3 = Instance.new("UIAspectRatioConstraint")
temp_z_newGUI3.AspectRatio = 1.425
temp_z_newGUI3.DominantAxis = Enum.DominantAxis.Height
temp_z_newGUI3.Parent = GUI_Window

local GUI_GroupNameBox = Instance.new("TextBox")
GUI_GroupNameBox.Font = Enum.Font.FredokaOne
GUI_GroupNameBox.PlaceholderText = "Custom folder name for saved items..."
GUI_GroupNameBox.Text = ""
GUI_GroupNameBox.TextColor3 = Color3.fromRGB(56, 72, 120)
GUI_GroupNameBox.PlaceholderColor3 = Color3.fromRGB(85, 58, 58)
GUI_GroupNameBox.TextScaled = true
GUI_GroupNameBox.TextWrapped = true
GUI_GroupNameBox.AnchorPoint = Vector2.new(1, 0.5)
GUI_GroupNameBox.BackgroundColor3 = COLOR_WHITE
GUI_GroupNameBox.BackgroundTransparency = 0.725
GUI_GroupNameBox.BorderSizePixel = 0
GUI_GroupNameBox.Position = UDim2.new(0.9425, 2, 0.5, 0)
GUI_GroupNameBox.Size = UDim2.new(10, 2, 1, 2)
GUI_GroupNameBox.SizeConstraint = Enum.SizeConstraint.RelativeYY
GUI_GroupNameBox.Visible = true
GUI_GroupNameBox.Name = "GroupName"
GUI_GroupNameBox.Parent = temp_z_newGUI2

temp_z_newGUI3 = Instance.new("UICorner")
temp_z_newGUI3.CornerRadius = UDim.new(1, 0)
temp_z_newGUI3.Parent = GUI_GroupNameBox

temp_z_newGUI3 = Instance.new("UIPadding")
temp_z_newGUI3.PaddingRight = UDim.new(0.0125, 0)
temp_z_newGUI3.Parent = GUI_GroupNameBox

local GUI_WinContents = Instance.new("Frame")
GUI_WinContents.AnchorPoint = Vector2.new(0.5, 1)
GUI_WinContents.BackgroundColor3 = COLOR_WHITE
GUI_WinContents.BackgroundTransparency = 1
GUI_WinContents.BorderSizePixel = 0
GUI_WinContents.Position = UDim2.new(0.5, 0, 1, -7)
GUI_WinContents.Size = UDim2.new(0.975, 0, 1, -45)
GUI_WinContents.Visible = true
GUI_WinContents.Name = "Contents"
GUI_WinContents.Parent = GUI_Window

-- First half of text shown in the window. This guides the player through each step (selecting a category, item, then saving it).
local GUIText_Part1 = Instance.new("TextLabel")
GUIText_Part1.Font = Enum.Font.Highway
GUIText_Part1.Text = "Please tap a 'type' from the top row, then tap the character/item you would like to save." ..
	" You can preview it in the 3D area or click either save button to add it to Lighting."
GUIText_Part1.TextColor3 = COLOR_WHITE
GUIText_Part1.TextSize = 13
GUIText_Part1.TextTruncate = Enum.TextTruncate.AtEnd
GUIText_Part1.TextWrapped = true
GUIText_Part1.TextXAlignment = Enum.TextXAlignment.Left
GUIText_Part1.TextYAlignment = Enum.TextYAlignment.Top
GUIText_Part1.BackgroundTransparency = 1
GUIText_Part1.BorderSizePixel = 0
GUIText_Part1.Size = UDim2.new(1, 0, 0.100000001, 0)
GUIText_Part1.Visible = true
GUIText_Part1.Name = "InfoGlobal"
GUIText_Part1.Parent = GUI_WinContents

-- Second half of text shown in the window. This paragraph can be set by specific categories to give additional info or context as needed.
local GUIText_Part2 = Instance.new("TextLabel")
GUIText_Part2.Font = Enum.Font.Highway
GUIText_Part2.Text = ""
GUIText_Part2.TextColor3 = COLOR_WHITE
GUIText_Part2.TextSize = 13
GUIText_Part2.TextTruncate = Enum.TextTruncate.AtEnd
GUIText_Part2.TextWrapped = true
GUIText_Part2.TextXAlignment = Enum.TextXAlignment.Left
GUIText_Part2.TextYAlignment = Enum.TextYAlignment.Top
GUIText_Part2.BackgroundTransparency = 1
GUIText_Part2.BorderSizePixel = 0
GUIText_Part2.Position = UDim2.fromScale(0, 0.1)
GUIText_Part2.Size = UDim2.fromScale(1, 0.1)
GUIText_Part2.Visible = true
GUIText_Part2.Name = "InfoAdditional"
GUIText_Part2.Parent = GUI_WinContents

local GUI_ItemList = Instance.new("ScrollingFrame")
GUI_ItemList.AutomaticCanvasSize = Enum.AutomaticSize.Y
GUI_ItemList.CanvasSize = UDim2.fromOffset(0, 15)
GUI_ItemList.ScrollBarThickness = 6
GUI_ItemList.ScrollingDirection = Enum.ScrollingDirection.Y
GUI_ItemList.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
GUI_ItemList.Active = true
GUI_ItemList.AnchorPoint = Vector2.yAxis
GUI_ItemList.BackgroundColor3 = Color3.new(0.313726, 0.305882, 0.301961)
GUI_ItemList.BorderSizePixel = 0
GUI_ItemList.Position = UDim2.fromScale(0, 0.925)
GUI_ItemList.Size = UDim2.new(0.6, -3, 0.625, 0)
GUI_ItemList.Visible = true
GUI_ItemList.Name = "List"
GUI_ItemList.Parent = GUI_WinContents

temp_z_newGUI1 = Instance.new("UIListLayout")
temp_z_newGUI1.HorizontalAlignment = Enum.HorizontalAlignment.Center
temp_z_newGUI1.SortOrder = Enum.SortOrder.LayoutOrder
temp_z_newGUI1.Parent = GUI_ItemList

-- Item template: Header (used as a divider between categories, mostly used for RH characters)
local Template_Header = Instance.new("TextLabel")
Template_Header.Font = Enum.Font.FredokaOne
Template_Header.Text = "Accessories"
Template_Header.TextColor3 = COLOR_WHITE
Template_Header.TextScaled = true
Template_Header.TextSize = 14
Template_Header.TextWrapped = true
Template_Header.BackgroundColor3 = COLOR_WHITE
Template_Header.BackgroundTransparency = 0.875
Template_Header.BorderSizePixel = 0
Template_Header.LayoutOrder = 1
Template_Header.Size = UDim2.new(1, 0, 0, 15)
Template_Header.Visible = false
Template_Header.Name = "TemplateHeader"
Template_Header.Parent = GUI_Base

-- Item template: Option (used for any selectable detected objects/models)
local Template_Item = Instance.new("TextButton")
Template_Item.Font = Enum.Font.Highway
Template_Item.Text = ""
Template_Item.TextTransparency = 1
Template_Item.BackgroundColor3 = Color3.new(0.275, 0.5765, 1)
Template_Item.BackgroundTransparency = 1	-- Fade in the background when an item is selected.
Template_Item.BorderSizePixel = 0
Template_Item.Size = UDim2.new(1, 0, 0, 25)
Template_Item.Visible = false
Template_Item.Name = "TemplateOption"
Template_Item.Parent = GUI_Base

temp_z_newGUI1 = Instance.new("TextLabel")
temp_z_newGUI1.Font = Enum.Font.Highway
temp_z_newGUI1.Text = "🙍"
temp_z_newGUI1.TextColor3 = Color3.new(1, 0.964706, 0.862745)
temp_z_newGUI1.TextScaled = true
temp_z_newGUI1.TextWrapped = true 
temp_z_newGUI1.BackgroundTransparency = 1
temp_z_newGUI1.BorderSizePixel = 0
temp_z_newGUI1.Selectable = true
temp_z_newGUI1.Size = UDim2.new(0, 25, 0, 25)
temp_z_newGUI1.Visible = true
temp_z_newGUI1.Name = "Icon"
temp_z_newGUI1.Parent = Template_Item

temp_z_newGUI1 = Instance.new("TextLabel")
temp_z_newGUI1.Font = Enum.Font.Highway
temp_z_newGUI1.Text = "Untitled (placeholder not meant to be seen by the user)"
temp_z_newGUI1.TextColor3 = Color3.new(1, 0.964706, 0.862745)
temp_z_newGUI1.TextScaled = true
temp_z_newGUI1.TextWrapped = true
temp_z_newGUI1.TextXAlignment = Enum.TextXAlignment.Left
temp_z_newGUI1.BackgroundTransparency = 1
temp_z_newGUI1.BorderSizePixel = 0
temp_z_newGUI1.LayoutOrder = 1
temp_z_newGUI1.Position = UDim2.new(0, 25, 0, 0)
temp_z_newGUI1.Selectable = true
temp_z_newGUI1.Size = UDim2.new(1, -25, 0, 25)
temp_z_newGUI1.Visible = true
temp_z_newGUI1.Name = "Title"
temp_z_newGUI1.Parent = Template_Item

-- 3D Viewport/model previewer, allowing the user to look around their selected model to make sure it's correct.
local GUI_Viewer3D = Instance.new("ViewportFrame")
GUI_Viewer3D.Active = true
GUI_Viewer3D.AnchorPoint = Vector2.one
GUI_Viewer3D.BackgroundColor3 = Color3.new(0.152941, 0.188235, 0.235294)
GUI_Viewer3D.BorderSizePixel = 0
GUI_Viewer3D.Position = UDim2.fromScale(1, 1)
GUI_Viewer3D.Size = UDim2.new(0.4, -2, 0.8, 0)
GUI_Viewer3D.Visible = false
GUI_Viewer3D.Name = "PreviewModel"
GUI_Viewer3D.Parent = GUI_WinContents

local GUI_ModelViewer = Instance.new("WorldModel")
GUI_ModelViewer.WorldPivot = CFrame.fromMatrix(Vector3.yAxis*45.256961822509766,Vector3.xAxis,Vector3.yAxis,Vector3.zAxis)
GUI_ModelViewer.Parent = GUI_Viewer3D

temp_z_newGUI2 = Instance.new("UICorner")
temp_z_newGUI2.CornerRadius = UDim.new(0.0625, 0)
temp_z_newGUI2.Parent = GUI_Viewer3D

-- This basic TextLabel is shown before the player selects/previews an item, or if a SaveType can't retrieve a Model or GUI content.
local GUI_ViewerMessage = Instance.new("TextLabel")
GUI_ViewerMessage.Font = Enum.Font.Highway
GUI_ViewerMessage.Text = ""
GUI_ViewerMessage.TextColor3 = COLOR_WHITE
GUI_ViewerMessage.TextScaled = true
GUI_ViewerMessage.TextStrokeTransparency = 0
GUI_ViewerMessage.TextWrapped = true
GUI_ViewerMessage.AnchorPoint = Vector2.one
GUI_ViewerMessage.BackgroundColor3 = GUI_Viewer3D.BackgroundColor3
GUI_ViewerMessage.BackgroundTransparency = 0
GUI_ViewerMessage.BorderSizePixel = 0
GUI_ViewerMessage.Position = UDim2.fromScale(1, 1)
GUI_ViewerMessage.Size = UDim2.new(0.4, -2, 0.8, 0)
GUI_ViewerMessage.ZIndex = 2
GUI_ViewerMessage.Visible = true
GUI_ViewerMessage.Name = "NoPreviewMessage"
GUI_ViewerMessage.Parent = GUI_WinContents

local GUI_Viewer2D = Instance.new("Frame")
GUI_Viewer2D.AnchorPoint = Vector2.one
GUI_Viewer2D.BackgroundColor3 = GUI_Viewer3D.BackgroundColor3
GUI_Viewer2D.BackgroundTransparency = 0
GUI_Viewer2D.BorderSizePixel = 0
GUI_Viewer2D.Position = UDim2.fromScale(1, 1)
GUI_Viewer2D.Size = UDim2.new(0.4, -2, 0.8, 0)
GUI_Viewer2D.Visible = false
GUI_Viewer2D.Name = "PreviewGUI"
GUI_Viewer2D.Parent = GUI_WinContents

temp_z_newGUI1 = nil
temp_z_newGUI2 = nil
temp_z_newGUI3 = nil

temp_z_newGUI2 = game:GetService("InsertService"):CreateMeshPartAsync(
	"rbxassetid://93824511643777",
	Enum.CollisionFidelity.Box,
	Enum.RenderFidelity.Precise
)
if not temp_z_newGUI2 then
	wait(5)	-- If the MeshPart can't be created, wait five seconds then try again. (It isn't REQUIRED, so just skip it if it doesn't show.)
	temp_z_newGUI2 = game:GetService("InsertService"):CreateMeshPartAsync(
		"rbxassetid://93824511643777",
		Enum.CollisionFidelity.Box,
		Enum.RenderFidelity.Precise
	)
end
if temp_z_newGUI2 then	-- If the scene model couldn't load above, ignore it and skip initializing its properties.
	temp_z_newGUI2.TextureID = "rbxassetid://82696798973473"
	temp_z_newGUI2.Anchored = true
	temp_z_newGUI2.CanCollide = false
	temp_z_newGUI2.CanQuery = false
	temp_z_newGUI2.CanTouch = false
	temp_z_newGUI2.BrickColor = BrickColor.White()
	temp_z_newGUI2.CFrame = CFrame.identity
	temp_z_newGUI2.Massless = true
	temp_z_newGUI2.Material = Enum.Material.SmoothPlastic
	temp_z_newGUI2.PivotOffset = CFrame.new(Vector3.yAxis * -50)
	-- temp_z_newGUI2.Size = Vector3.new(193.9214324951172, 175, 193.92144775390625)
	temp_z_newGUI2.Transparency = 1	-- Hide the 3D scene, since the camera script isn't doing a good job aligning it to 3D models.
	temp_z_newGUI2.Name = "PreviewScene"
	temp_z_newGUI2.Parent = GUI_ModelViewer
end

temp_z_newGUI1 = Instance.new("UIPadding")
temp_z_newGUI1.PaddingBottom = UDim.new(0.25, 0)
temp_z_newGUI1.PaddingTop = UDim.new(0.25, 0)
temp_z_newGUI1.Parent = GUI_ViewerMessage

GUI_DetectTypeList = Instance.new("Frame")
GUI_DetectTypeList.BackgroundColor3 = Color3.new(0.352941, 0.376471, 0.45098)
GUI_DetectTypeList.BackgroundTransparency = 1
GUI_DetectTypeList.BorderSizePixel = 0
GUI_DetectTypeList.Position = UDim2.fromScale(0, 0.2)
GUI_DetectTypeList.Size = UDim2.new(0.6, -3, 0.1, -3)
GUI_DetectTypeList.Visible = true
GUI_DetectTypeList.Name = "Types"
GUI_DetectTypeList.Parent = GUI_WinContents

temp_z_newGUI1 = Instance.new("UIListLayout")
temp_z_newGUI1.HorizontalFlex = Enum.UIFlexAlignment.Fill
temp_z_newGUI1.Padding = UDim.new(0, 3)
temp_z_newGUI1.FillDirection = Enum.FillDirection.Horizontal
temp_z_newGUI1.HorizontalAlignment = Enum.HorizontalAlignment.Center
temp_z_newGUI1.SortOrder = Enum.SortOrder.LayoutOrder
temp_z_newGUI1.VerticalAlignment = Enum.VerticalAlignment.Bottom
temp_z_newGUI1.Parent = GUI_DetectTypeList

local Template_DetectType = Instance.new("TextButton")
Template_DetectType.Font = Enum.Font.Highway
Template_DetectType.Text = "Characters"
Template_DetectType.TextColor3 = Color3.new(0.996078, 1, 0.901961)
Template_DetectType.TextSize = 14
Template_DetectType.TextStrokeTransparency = 0.25
Template_DetectType.TextWrapped = true
Template_DetectType.BackgroundColor3 = Color3.new(0.831373, 0.658824, 0.537255)
Template_DetectType.BorderSizePixel = 0
Template_DetectType.Size = UDim2.fromScale(1, 1)
Template_DetectType.Visible = false
Template_DetectType.Name = "Template"
Template_DetectType.Parent = GUI_Base

temp_z_newGUI1 = Instance.new("UICorner")
temp_z_newGUI1.CornerRadius = UDim.new(0.25, 0)
temp_z_newGUI1.Parent = Template_DetectType

local GUI_EmptyItemListText = Instance.new("TextLabel")
GUI_EmptyItemListText.Font = Enum.Font.Highway
GUI_EmptyItemListText.TextColor3 = Color3.new(1, 0.976471, 0.901961)
GUI_EmptyItemListText.TextScaled = true
GUI_EmptyItemListText.TextWrapped = true
GUI_EmptyItemListText.AnchorPoint = Vector2.yAxis
GUI_EmptyItemListText.BackgroundColor3 = Color3.new(0.168627, 0.203922, 0.372549)
GUI_EmptyItemListText.BorderSizePixel = 0
GUI_EmptyItemListText.ClipsDescendants = true
GUI_EmptyItemListText.Position = UDim2.fromScale(0, 1)
GUI_EmptyItemListText.Selectable = true
GUI_EmptyItemListText.Size = UDim2.new(0.6, -3, 0.7, 0)
GUI_EmptyItemListText.Visible = false
GUI_EmptyItemListText.SelectionGroup = true
GUI_EmptyItemListText.Name = "NoList"
GUI_EmptyItemListText.ZIndex = 2
GUI_EmptyItemListText.Parent = GUI_WinContents

temp_z_newGUI1 = Instance.new("UIPadding")
temp_z_newGUI1.PaddingBottom = UDim.new(0.25, 0)
temp_z_newGUI1.PaddingLeft = UDim.new(0.0625, 0)
temp_z_newGUI1.PaddingRight = UDim.new(0.0625, 0)
temp_z_newGUI1.PaddingTop = UDim.new(0.25, 0)
temp_z_newGUI1.Parent = GUI_EmptyItemListText

temp_z_newGUI1 = Instance.new("Frame")
temp_z_newGUI1.AnchorPoint = Vector2.new(0, 1)
temp_z_newGUI1.BackgroundColor3 = Color3.new(0.352941, 0.376471, 0.45098)
temp_z_newGUI1.BackgroundTransparency = 1
temp_z_newGUI1.BorderSizePixel = 0
temp_z_newGUI1.Position = UDim2.new(0, 0, 1, 0)
temp_z_newGUI1.Size = UDim2.new(0.6, -3, 0.1, -3)
temp_z_newGUI1.Visible = true
temp_z_newGUI1.Name = "Actions"
temp_z_newGUI1.Parent = GUI_WinContents

temp_z_newGUI2 = Instance.new("UIListLayout")
temp_z_newGUI2.HorizontalFlex = Enum.UIFlexAlignment.Fill
temp_z_newGUI2.Padding = UDim.new(0, 3)
temp_z_newGUI2.FillDirection = Enum.FillDirection.Horizontal
temp_z_newGUI2.HorizontalAlignment = Enum.HorizontalAlignment.Center
temp_z_newGUI2.SortOrder = Enum.SortOrder.LayoutOrder
temp_z_newGUI2.VerticalAlignment = Enum.VerticalAlignment.Bottom
temp_z_newGUI2.Parent = temp_z_newGUI1

Button_SaveWindow = Instance.new("TextButton")
Button_SaveWindow.Font = Enum.Font.Highway
Button_SaveWindow.Text = "Save Selected Now"
Button_SaveWindow.TextColor3 = Color3.new(0.803922, 0.952941, 1)
Button_SaveWindow.TextSize = 14
Button_SaveWindow.TextStrokeTransparency = 0.25
Button_SaveWindow.TextWrapped = true
Button_SaveWindow.BackgroundColor3 = Color3.new(0.537255, 0.627451, 0.921569)
Button_SaveWindow.BorderSizePixel = 0
Button_SaveWindow.Size = UDim2.new(1, 0, 1, 0)
Button_SaveWindow.Visible = false
Button_SaveWindow.Name = "Save"
Button_SaveWindow.Parent = temp_z_newGUI1

temp_z_newGUI2 = Instance.new("UICorner")
temp_z_newGUI2.CornerRadius = UDim.new(0.25, 0)
temp_z_newGUI2.Parent = Button_SaveWindow

Button_RefreshWindow = Instance.new("TextButton")
Button_RefreshWindow.Font = Enum.Font.Highway
Button_RefreshWindow.Text = "Refresh"
Button_RefreshWindow.TextColor3 = Color3.new(0.803922, 0.952941, 1)
Button_RefreshWindow.TextSize = 14
Button_RefreshWindow.TextStrokeTransparency = 0.25
Button_RefreshWindow.TextWrapped = true
Button_RefreshWindow.BackgroundColor3 = Color3.new(0.537255, 0.627451, 0.921569)
Button_RefreshWindow.BorderSizePixel = 0
Button_RefreshWindow.LayoutOrder = 1
Button_RefreshWindow.Size = UDim2.new(1, 0, 1, 0)
Button_RefreshWindow.Visible = true
Button_RefreshWindow.Name = "Refresh"
Button_RefreshWindow.Parent = temp_z_newGUI1

temp_z_newGUI2 = Instance.new("UICorner")
temp_z_newGUI2.CornerRadius = UDim.new(0.25, 0)
temp_z_newGUI2.Parent = Button_RefreshWindow

--[[
	Annoyingly, ScreenGui instances' children don't render inside OF a ScreenGui, since it "cloaks" or claims them. Because of
	how they work, any 3D or 2D content shown in the window GUI is first copied to this Folder verbatim, then can be freely
	modified when it's shown in the preview pane. This makes it EASIER to check if a Model is "cached"; Just check if this
	Folder has any children, then use the first Instance inside it!
]]--
local GUI_CurrentCache						= Instance.new("Folder")
GUI_CurrentCache.Name						= "PreviewContent"
-- GUI_CurrentCache.Parent					= GUI_Base

local function TryOrCreateFolder(_parent : Instance, _name : string) : Folder
	local FolderRef : Folder?	= _parent:FindFirstChild(_name)
	if not FolderRef then
		FolderRef				= Instance.new("Folder")
		FolderRef.Name			= _name
		FolderRef.Parent		= _parent
	end
	return FolderRef
end

--[[
	Starting at the given Instance, recursively checks if each of the given child names exist within each
	instance. For example, if the array contained "Mary" then "Character", it would check for if "Mary"
	is within the starting point, then if "Character" is within "Mary". If any of the children don't
	exist, this will return false. (This is the same as a chain of ":FindFirstChild()" checks.)
]]--
local function IterateChildHierarchy(_startInstance : Instance, _details : {{ Name : string, Type : string }}) : Instance?
	if not _startInstance then return nil end	-- A starting Instance must be provided.
	local CurrentLocation = _startInstance	-- This tracks the current Instance as we move down the hierarchy.
	
	if _startInstance and typeof(_startInstance) == "Instance" and _details and type(_details) == "table" and
		_details[1].Name and type(_details[1].Name) == "string" and _details[1].Type and type(_details[1].Type) == "string"
	then
		-- The recursion begins! Do a ":FindFirstChild()"" check for each string in order, each time moving deeper into the hierarchy.
		for _, level in _details do
			-- Check which type of scan to do, then do it based on "Type". If certain keywords aren't found, assume it's FindFirstChild().
			if string.find(string.lower(level.Type), "wait") then CurrentLocation = CurrentLocation:WaitForChild(level.Name, level.Time or 45)
			elseif string.find(string.lower(level.Type), "class") then CurrentLocation = CurrentLocation:FindFirstChildOfClass(level.Name)
			else CurrentLocation = CurrentLocation:FindFirstChild(level.Name)
			end
			
			-- If this check caused the variable to become nil, that child Instance didn't exist, so it ends early.
			if not CurrentLocation then break end
		end
	end
	
	return CurrentLocation	-- This will be nil if any child isn't found, and will conveniently BE the last child if everything passes.
end

-- Also create a folder in Lighting (where I dump all of my Instances). If it's already there, use it instead of making a new one.
local SaveBaseFolder : Folder				= TryOrCreateFolder(game:GetService("Lighting"), "Saved Items")

-- Free up the temporary variables' values again, in case Roblox garbage-collects these Instance references.
temp_z_newGUI1 = nil
temp_z_newGUI2 = nil

-- VARIABLES
type ToastDefinition						= {
	GUIElement								: CanvasGroup,
	Tween									: Tween?
}

local IsBusy								= false	-- Set to TRUE while the script is scanning or "saving" instances.
local CurrentDetectTypes					= {}	-- List of detection types to display in the window, gathered from the arrays above.
local LastScanType							= ""	-- Set to the last ScanType the user's looked for. Used by the refresh button.
local ItemList : {DetectedItemEntry}		= {}	-- An array containing data about each click-able item entry in the list (no headers).
local VisibleListSize						= 0		-- Counts how many header and item templates have been added to the visible list.
local SelectedIndex							= 0		-- The currently-selected ItemList index, used by the save buttons.
local HighestToastNumber					= 0		-- Number incremented with each displayed toast to keep them in order, top to bottom.

local SaveGroupName							= DEF_GROUP_NAME	-- Sub-folder to place the next saved item into.
local ToastData : {ToastDefinition}
											= {}	-- Array of references to visible, un-dismissed toast notification CanvasGroups.
local ActiveToasts : number					= 0		-- A basic counter that tracks how many toasts are being shown to the user now.

type TypeDataStorageTypes					= {	-- Type definition for the table below.
	RHRefs									: {
		GUIBase_Clothing					: Frame?,
		GUIBase_Furniture					: Frame?,
		EquippedStorage						: Folder?
	}
}

--[[
	A weird, hackish table used for types that let the user pick a target player first. Since this reuses the existing list/indexing
	logic, it has to override the normal "current type" value to trick it into listing players. Once a player is selected, the info
	here is used to "restore" logic and proceed to scan for instances relating to the selected Player. "SelectedPlayer" isn't reset
	until another "scan type" button is clicked/tappped, so the player can be stored in all entries for context.
]]--
local PlayerSelectParams						: {
	SelectedPlayer								: Player?,
	RealScanType								: string
}
	= {
		SelectedPlayer							= nil,	-- Player the user picked.
		RealScanType							= "",	-- The intended ScanType that requested this Player selection.
}

--[[
	<custom><nb>
	Checks for Royale High's "EquippedStorage" folder, its standard "category" sub-folders, then a specific player's folders within
	those. If any of them are found, references to them will be included in the returned dictionary entry.
]]--
local function GetESFolders(_playerName : string) :
	{
		Accessories							: Folder?,
		Hair								: Folder?,
		Heels								: Folder?,
		Skirts								: Folder?,
		Wings								: Folder?
	}?
	local FoundFolders						= {}
	local EquippedStorage:Folder?			= workspace:FindFirstChild("EquippedStorage")
	
	-- Try to find all of this Player's folders. If a single one isn't there, bail and return nil to the caller.
	if EquippedStorage then
		FoundFolders.Accessories			= IterateChildHierarchy(EquippedStorage, {
			{Name = "Accessories",							Type = "FindFirstChild"},
			{Name = PlayerSelectParams.SelectedPlayer.Name,	Type = "FindFirstChild"}
		})
		if not FoundFolders.Accessories then return nil end
		FoundFolders.Hair				= IterateChildHierarchy(EquippedStorage, {
			{Name = "Hair",									Type = "FindFirstChild"},
			{Name = PlayerSelectParams.SelectedPlayer.Name,	Type = "FindFirstChild"}
		})
		if not FoundFolders.Hair then return nil end
		FoundFolders.Heels				= IterateChildHierarchy(EquippedStorage, {
			{Name = "Heels",								Type = "FindFirstChild"},
			{Name = PlayerSelectParams.SelectedPlayer.Name,	Type = "FindFirstChild"}
		})
		if not FoundFolders.Heels then return nil end
		FoundFolders.Skirts				= IterateChildHierarchy(EquippedStorage, {
			{Name = "Skirts",								Type = "FindFirstChild"},
			{Name = PlayerSelectParams.SelectedPlayer.Name,	Type = "FindFirstChild"}
		})
		if not FoundFolders.Skirts then return nil end
		FoundFolders.Wings				= IterateChildHierarchy(EquippedStorage, {
			{Name = "Wings",								Type = "FindFirstChild"},
			{Name = PlayerSelectParams.SelectedPlayer.Name,	Type = "FindFirstChild"}
		})
		if not FoundFolders.Wings then return nil end
	else DisplayToast("Somehow, EquippedStorage just isn't here...?", "❔", 4)
	end
	
	return FoundFolders
end

--[[
	<custom><nb>
	Tries to remove any player-specific modifications (other than clothing colors), turning every saved clothing Model
	and full character model into a neutral, light-grey humanoid with a basic name and default Roblox smile face.
	
	This function should only be used when saving individual clothes (and shoes, which can save the whole character),
	since the user probably wants to save full characters/outfits as-is.
	
	If the second parameter is **true**, this function's for loop will do additional Humanoid and R15 body part
	checks, which may slow down this process. For most accessories, it should be kept as **false**, so it just
	recolors extra skin tone parts (which are always named "colored*leg*", even for other body parts).
]]--
type FixRHCharParams	= {
	DoExtraChecks		: boolean,	-- Allows the function to make most changes other than just recoloring "coloredleg" parts.
	SkinTone			: boolean,	-- Recolor all skin-colored R15 parts and "coloredleg" RH clothing parts to a neutral color.
	Face				: boolean,	-- Remove RH-specific face layers and revert the face Decal to the default Roblox smile.
	RPName				: ("hide"|"remove")?,	-- Hides or removes their RP name. Name will be replaced if this is the user's character.
	LowerTorsoFix		: boolean,	-- Forcibly makes all modern shoe LowerTorso meshes visible. (They're hidden when wearing a skirt.)
	AllR15Parts			: boolean,	-- Makes all un-replaced R15 body parts visible, handy for modern shoe character saves.
	HumanoidName		: ("hide"|"change")?,	-- Hides the built-in overhead Humanoid name GUI and repalces it with "Character".
	Clothing2D			: boolean,	-- Removes 2D Roblox clothing Instances (Shirt/Pants/ShirtGraphic).
}

local function FixRHCharacter(_root : Model, _param : FixRHCharParams)
	for _,desc : MeshPart in _root:GetDescendants() do
		if desc:IsA("BasePart") and desc.Name == "coloredleg" and _param.SkinTone then	-- All "coloredleg" parts are always recolored.
			desc.Color = COLOR_ANON_SKIN
		elseif _param.DoExtraChecks then
			if desc:IsA("MeshPart") and	-- Just recolor visible R15 body meshes, not the small blocks used by modern heels.
				table.find(R15_BODY_PARTS, desc.Name) and	-- Is this one of the standard R15 body parts?
				desc.Parent:FindFirstChildOfClass("Humanoid")	-- Is this body part inside a Model with a Humanoid? (R15 body part!)
			then
				if desc.Transparency > 0.999 and _param.AllR15Parts then desc.Transparency = 0 end	-- Reveal every hidden R15 body part.
				if _param.SkinTone then desc.Color = COLOR_ANON_SKIN end	-- Replace this part's skin tone/color if it's allowed.
			elseif desc:IsA("Part") and desc.Name == "LowerTorso" and _param.LowerTorsoFix then
				local Undergarment : Model? = desc:FindFirstChildOfClass("Model")
				if Undergarment and Undergarment.Name == "LowerTorso" then	-- If this seems to be bloomers/shorts, let's make it opaque!
					for _,piece in Undergarment:GetDescendants() do
						if piece:IsA("BasePart") and piece.Transparency > 0.999 then piece.Transparency = 0 end
					end
				end
			elseif desc:IsA("Decal") and desc.Parent and	-- If allowed, change their face texture(s)!
				desc.Parent.Name == "Head" and _param.Face
			then
				if desc.Name == "face" then desc.Texture = "rbxassetid://144080495"	-- Forcibly use the default smile texture.
				elseif table.find(RH_FACE_DECALS, desc.Name) then desc:Destroy()	-- Remove any extra RH face layers.
				end
			elseif desc:IsA("BillboardGui") then
				if desc.Name == "NameTag" and desc.Parent and desc.Parent.Name == "Head" and _param.RPName then
					if _param.RPName == "hide" then
						desc.Enabled = false
						
						--[[
							-- If this is the user's character, hide their name, replacing it with "Character". (This is pointless.)
							local temp_label : TextLabel? = desc:FindFirstChildOfClass("TextLabel")
							if _root.Name == LocalPlayer.Name and temp_label then temp_label.Text = "Character" end
						]]--
					elseif _param.RPName == "remove" then desc:Destroy()
					end
				elseif table.find(RH_UNWANTED_ICONS, desc.Name) then desc:Destroy() end	-- Any other RH icon should be removed.
			elseif desc:IsA("Humanoid") and _param.HumanoidName then
				desc.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None			-- Hide the built-in username display.
				if _param.HumanoidName == "change" then desc.DisplayName = "Character" end	-- Give this character a useless name.
			elseif desc:IsA("Shirt") or desc:IsA("Pants") or desc:IsA("ShirtGraphic") and _param.Clothing2D then desc:Destroy()
			end
		end
	end
end

-- STATIC DATA
type ValidIDValues							= string|number

type DetectedItemEntry						= {
	Title									: string,			-- This item's display name, shown in the list.
	Icon									: string,			-- The emoji representing this item.
	SaveType								: string,			-- This item's SaveType, used when cloning/saving it to Lighting.
	Identifiers								: {ValidIDValues},	-- A list of info used to help the SaveType locate and copy Models.
	Player									: Player?,			-- (Optional) The player assigned to this player-specific instance/object.
	ListInstance							: TextButton,		-- This item's on-screen button/"drop-down entry".
	SelectEvent								: RBXScriptConnection?	-- Event fired when the player taps/clicks on this item.
}

local EMPTY_ITEM_ENTRY : DetectedItemEntry	= {
	Title									= "Unknown",
	Icon									= "❔",
	SaveType								= "",
	Identifiers								= nil,
	Player									= nil,
	ListInstance							= nil,
	SelectEvent								= nil
}

local GAME_ID								= game.GameId
local PLACE_ID								= game.PlaceId

local TI_TOAST_FADEIN						= TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local TI_TOAST_FADEOUT						= TweenInfo.new(0.625, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

local function FindToolChild(_locat : Instance?, _name : string, _debugId : string)
	-- Try to find an exact named match in the requested location first, comparing its name then debug ID to the info given.
	local temp_tool:Tool?					= _locat:FindFirstChild(_name) or _locat:FindFirstChildOfClass("Tool")
	if temp_tool.Name == _name or temp_tool:GetDebugId() == _debugId then 
		return temp_tool:Clone()
	else	-- If a match wasn't found, scan through the Instance's children and try to find a match, in case the Tool was renamed.
		for _,inst : Tool? in _locat:GetChildren() do
			if inst:IsA("Tool") and (inst.Name == _name or inst:GetDebugId() == _debugId) then
				return inst:Clone()	-- If it was found, clone it then give it to the caller.
			end
		end
		DisplayToast("The player isn't carrying that tool anymore.", "⚠️", 3.125)	-- If nothing could be found, error and bail out!
		error("The requested Tool wasn't in that player's hands when saving...x")
	end
end

local function AssignDescriptiveRHItemName(_isFurni : boolean, Target : Model, _heelsModel : Model?)
	if not Target then return false end	-- This function needs a Model, as it will modify it, adding attributes and renaming it.
	local ModelNameSrc : Model				= Target	-- For most clothes, the name StringValue is within the target Model.
	if _heelsModel and _heelsModel.Name == "Heels" then	-- For heels, the target might be a full character, not the dummy "Heels" model
		ModelNameSrc						= _heelsModel	-- that has the HeelName instance we want. If this is that, use ITS name.
	end
	
	-- Set up these reference variables, which were used by the RHAPv1 function this code was imported from.
	local GUI_Base							= nil
	local GUIBase_Clothing : Frame?			= nil
	local GUIBase_Furniture : Frame?		= nil
	local ToggleNum : number				= 0
	local VariationInfo : {any}				= {}
	local SaveName : string					= ""
	
	--[[
		Though it looks like both use the same toggle/variation seleciton GUI, clothes and furniture actually use separate copies of the
		same GUI design; Everything inside both of the frames has the same layout, so this script will change between them depending on
		what it's targetting.
		
		For clothes, it gets worse; Trying on items in the shop and modifying owned clothes use two different copies of the same GUI!
	]]--
	local temp_clothesGUI1					= IterateChildHierarchy(PlayerGui, {	-- Trying out customized clothing in the shop...
		{
			Name = "PreviewToggles",
			Type = "FindFirstChild"
		},
		{
			Name = "PreviewTogglesFrame",
			Type = "FindFirstChild"
		}
	})
	local temp_clothesGUI2					= IterateChildHierarchy(PlayerGui, {	-- Customizing owned/worn clothes...
		{
			Name = "CharacterCreation",
			Type = "FindFirstChild"
		},
		{
			Name = "Inventory",
			Type = "FindFirstChild"
		},
		{
			Name = "TogglesFrameNEW",
			Type = "FindFirstChild"
		}
	})
	
	-- Prioritize the shop's version of the customization GUI, but if it isn't visible, try to use the other copy of it.
	if temp_clothesGUI1 and temp_clothesGUI1.Visible  then
		GUIBase_Clothing					= temp_clothesGUI1
	elseif temp_clothesGUI2 and temp_clothesGUI2.Visible then
		GUIBase_Clothing					= temp_clothesGUI2
	end
	
	local temp_furniDecorModeGui				= IterateChildHierarchy(PlayerGui, {
		{
			Name = "DecorateModeGui",
			Type = "FindFirstChild"
		},
		{
			Name = "TogglesFrameNEW",
			Type = "FindFirstChild"
		}
	})
	if temp_furniDecorModeGui and temp_furniDecorModeGui.Visible then	-- This GUI only exists in Campus 3's Castle Dorms and Campus 4, nil outside of 'em.
		GUIBase_Furniture					= temp_furniDecorModeGui
	end
	
	-- Clear these now-unnecessary variables now, in case it frees up memory.
	temp_furniDecorModeGui					= nil
	temp_clothesGUI1						= nil
	temp_clothesGUI2						= nil
	
	-- Dynamically point the following code to the clothing or furniture toggle/variation customization GUI, depending on our target type.
	GUI_Base								= if not _isFurni then GUIBase_Clothing else GUIBase_Furniture
	
	if GUI_Base then	-- Is the preview GUI visible? We'll grab detailed info from it! (This variable will only be set if one of them was visible.)
		local ItemName : TextLabel			= GUI_Base:FindFirstChild("ItemName")
		
		-- Figure out the player's current toggle number by checking each sub-frame's UIStroke visibility. Selected toggles are outlined.
		for _,toggle in GUI_Base.Inner:GetChildren() do
			if toggle:IsA("Frame") then
				if toggle:FindFirstChild("UIStrokeSelected") and toggle:FindFirstChild("UIStrokeSelected").Enabled then
					ToggleNum = tonumber(toggle.ToggleNumber.Text)	-- Get the small number in its upper left corner and use that.
					break
				end
			end
		end
		
		-- Create and sort a list of all frames in the variation list section of the customization GUI.
		local temp_varUIList = {}
		for _,category : Instance in GUI_Base.DynamicToggleVariants.ToggleCycleFrame:GetChildren() do
			if category:IsA("Frame") then
				table.insert(temp_varUIList, category)
			end
		end
		table.sort(temp_varUIList,function(_instA : Frame,_instB : Frame)	-- Sort the list in ascending "order".
			return _instA.LayoutOrder < _instB.LayoutOrder	-- If A has a lower order, it's placed before B.
		end)
		
		-- Next, iterate through this item's variation "categories" and get their information by using some "string magic".
		for num,category in temp_varUIList do
			local temp_newEntry	= {
				CategoryName	= category.Name:sub(7),	-- Remove the first 6 letters (which are usually "Cycle ").
				VarName			= "Unknown",
				VarNumber		= 0
			}
			
			-- Unfortunately, Royale High crams both the current variation and its name into the same string, so the cryptic-looking
			-- "code" below figures out where the left-most number and name are, and slices the original string up, storing the info.
			local VariationStr:string	= category.CurrentCycleItem.Text	-- This includes both the number and name ("(1/5) Angel").
			local slashPos				= VariationStr:find("/",1,true)		-- The slash separates the current and total variations.
			local _,rightParenLoc		= VariationStr:find(") ",1,true)	-- The right parentheses and space are the name's left bound.
			
			temp_newEntry.VarNumber		= tonumber(VariationStr:sub(2,slashPos-1))
			temp_newEntry.VarName		= VariationStr:sub(rightParenLoc+1)
			
			table.insert(VariationInfo, temp_newEntry)	-- Insert this entry at its position in RH's list.
		end
		
		-- Finally, assemble this Model's final name, starting with its given name and toggle number.
		SaveName = ItemName.Text .. " T" .. ToggleNum
		if #VariationInfo > 0 then
			SaveName ..= " V"	-- Add a separator character before appending the variation information to the Model's name.
			for num,category in VariationInfo do	-- Append each variation's category name, number, and variant name to the name. This is messy.
				SaveName ..= tostring(category.VarNumber)
				
				if num < #VariationInfo then SaveName ..= "/" end	-- If this isn't the last variation, add a separator before continuing.
			end
			
			-- table.clear(VariationInfo)	-- Clear this table to slightly lower memory usage, if it matters here.
		end
	else	-- Otherwise, there's still hope! See if the target contains a StringValue with its name!
		local temp_name:StringValue?	=
			ModelNameSrc:FindFirstChild("HeelName") or
			ModelNameSrc:FindFirstChild("AccessoryName") or
			ModelNameSrc:FindFirstChild("SkirtName") or
			ModelNameSrc:FindFirstChild("NameTag")	-- Dorm furniture
		if temp_name then
			if GUI_Base == GUIBase_Furniture then	-- Dorm furniture can include a NumberValue with its toggle number inside.
				local ToggleValue : NumberValue? = ModelNameSrc:FindFirstChild("ToggleIndex")
				if ToggleValue then	-- If the toggle number Instance exists, use the furniture's name and toggle number as its title.
					ToggleNum = ToggleValue.Value
					SaveName = temp_name.Value .. " T" .. ToggleValue.Value
				else SaveName = "Item"	-- Otherwise, fall back on "Item". We do NOT want to save an ugly GUID string!
				end
			else
				SaveName = temp_name and temp_name.Value or "How did we get here❔"	-- Use the item's name as a fallback, or unused text.
			end
		-- else SetSaveFolder(nil)	-- If a name can't be found, this item just can't be saved.
		end
	end
	
	if SaveName:len() > 0 then
		Target.Name = SaveName
	end
	
	-- If any toggle or variation-related info was gathered above, write it to this clone's attributes.
	if ToggleNum > 0 then Target:SetAttribute("Toggle", ToggleNum) end
	if VariationInfo and VariationInfo[1] then
		for num,category in VariationInfo do
			Target:SetAttribute("Var" .. num .. "Category", category.CategoryName)
			Target:SetAttribute("Var" .. num .. "Choice", category.VarName .. " (" .. tostring(category.VarNumber) .. ")")
		end
	end
	
	-- Lastly, clear the variation info table, just in case it frees memory.
	table.clear(VariationInfo)
	VariationInfo = nil
	return Target	-- Return the modified Model back to the caller, even if this is technically pointless.
end

-- Default detection categories/types, which should work for most Roblox games that use standard characters and tools.
local DefaultDetectTypes					= {
	"Chara",										-- R15 characters linked to players.
	"Tools",										-- Finds all tools in a player's backpack, character model, and StarterPack.
	"GUI"											-- Lets the user save all or any ScreenGui from their PlayerGui.
}

--[[
	An array of game-specific overrides for the default detection type selections. If any entry starts with a '-', the type written
	after it will be removed from the list.
]]--
local GameOverrideData						= {
	[321778215]								= {	-- Royale High (this script's main game!)
		"-Chara",								-- RH characters' worn items are stored separate from their model, so this wouldn't work.
		"CharaRH",								-- RH-specific char. scanning, allowing saving full characters or specific accessories.
	}
}

--[[
	Similar to the array above, this contains place-specific additions/"overrides". The same hyphen ('-') check can be used to remove
	default or game-specific types.
]]--
local PlaceOverrideData						= {
	[735030788]								= {	-- Royale High Campus 4
		"DormRH"								-- Allow saving the currently-loaded dorm room (if one is loaded).
	},
	[1067660288]							= {	-- Royale High Campus 3 Castle Dorms
		"DormRH"								-- Allow saving the currently-loaded dorm room (if one is loaded).
	}
}

--[[
	DETECTION/SCAN TYPES
	This important array contains info about every scan type, a function and some metadata that determines the criteria it will
	look for and add to the list in the target selection window. Some scan types require a player for context, and will switch
	to the "I_Plyrs" definition with special logic before returning to the scheduled scan.
	
	Each ScanType includes 2 functions:
	Scan				The main function, which searches for instances in any container, adding them to the list using
						AddItem(). If this function returns a string, it will be used instead of the default "empty list"
						message.
	MissingItemResponse	Called when the user taps an item, but the SaveType doesn't return an Instance. This function can
						remove any relevant/grouped items from the ItemList, though it should set the missing indices to
						nil instead of using table.remove(), as each item tries to read its index, set when it's added to
						the visible list.
]]
type ScanType								= {
	Title									: string,
	ContentType								: "None"|"2D"|"3D",
	Position								: number,
	PlayerContext							: boolean,
	Scan									: () -> (string?),
	MissingItemResponse						: (_listIndex : number) -> ()
}
local DetectTypeDefs : {ScanType}			= {
	--[[
		I_Plyrs (Player selector)
		THE hackish, internal repurposed ScanType shown/used for any other ScanType that needs "player context" like CharRH. This
		ScanType (and the "item" template) have specific programming for I_Plyrs that updates SelectedPlayer then re-scans using
		the user's original ScanType.
		
		This type doesn't include a "missing item" function because that's handled by the item-selection function's hardcoded check.
	]]--
	["I_Plyrs"]								= {
		-- Title							= "Players (internal)",
		PlayerContext						= false,	-- Obviously, this can't be true or…it would probably cause an infinite loop.
		Position							= 1000,
		ContentType							= "None",
		Scan								= function()
			AddListPart("Select a player!", nil, "Header")
			for _,player in Players:GetPlayers() do
				AddListPart(player.Name .. " (" .. player.DisplayName .. ")", "👤", "I_Plyrs", {player.Name}, player)
			end
			
			return nil	-- Only return a string if specific criteria are needed to index anything, such as dorms in Royale High.
		end
	},
	
	--[[
		Chara (Standard Roblox characters)
		Finds all standard R6/R15 Roblox characters controlled by players (linked in their Character properties). Since some games
		like Royale High put their extra models in another location (like RH's EquippedStorage sub-folders), this type gets
		replaced in games with more complex or non-standard characters. (This will probably still break in games where players
		control skinned mesh ("boned") characters like Care Bears: Caring Quest, so make sure your character looks like something
		similar to a Robloxian, or be prepared to close the Roblox app before using this scan type.
	]]--
	["Chara"]								= {
		Title								= "🧑People",
		PlayerContext						= false,		-- Each player will only add one entry to the list, so they're all listed.
		Position							= 1,
		ContentType							= "3D",
		Scan								= function()
			for _,player in Players:GetPlayers() do
				local temp_char = player.Character
				if temp_char then
					AddListPart(player.Name, "🧑", "Chara",{player.Name}, player)
				end
			end
			
			return nil
		end,
		MissingItemResponse					= function(_listIndex : number)
			ItemList[_listIndex].ListInstance:Destroy()	-- If a player's character can't be previewed outside RH, just remove their entry.
			ItemList[_listIndex]			= nil
		end
	},
	
	--[[
		CharaRH (Royale High player characters)
		Makes it easy and convenient to save any player's character or any of their equipped items in Royale High. After selecting a
		player, all of their items and character model will be listed, including an item they may be trying on in the shop! This
		ScanType makes saving any shop item trivial! Try on your desired item, refresh the list/select yourself, find the item in the
		list, then you can rapidly save toggles and variations by tapping the save button as soon as your clothes update!
	]]--
	["CharaRH"]								= {
		Title								= "💃People",
		PlayerContext						= true,	-- Each player will display all of their clothing items and their character.
		Position							= 1,	-- In RH, this replaces "Chara", so it should appear first, just like it.
		ContentType							= "3D",
		Scan								= function()
			-- First, try to get references to all of this player's folders (their character and EquippedStorage sub-folders)
			local temp_char : Model?		= nil
			-- This script could also support the legacy mermaid tails, but seemingly no one even uses them, so... Ehh.
			
			temp_char						= PlayerSelectParams.SelectedPlayer.Character
			if not temp_char then return "Couldn't find that player's character model reference. Make sure they're visible/loaded." end
			
			AddListPart(
				PlayerSelectParams.SelectedPlayer.Name .. " (" .. PlayerSelectParams.SelectedPlayer.DisplayName .. ")",
				nil,
				"Header"
			)
			AddListPart("Full character...", "🧑", "CharaRH", {}, PlayerSelectParams.SelectedPlayer)
			
			local ESFolder					= GetESFolders(PlayerSelectParams.SelectedPlayer.Name)
			if not ESFolder then
				DisplayToast(
					"One of this player's EquippedStorage folders couldn't be found.",
					"🚫",
					3.5
				)
				return "Couldn't find player's ES folders...x"
			end
			
			-- If we found all of this player's sub-folders, we can finally index their clothes!
			
			-- If they're using RH hair, shoes, and/or a skirt, list those first, as they can't use more than one of each.
			-- Also, some hairstyles use meshes from the weird "ReplicatedHair" folder. They're named "HairLocal" instead.
			local temp_hairModel:Model?	= ESFolder.Hair:FindFirstChild("Hair") or ESFolder.Hair:FindFirstChild("HairLocal")
			if temp_hairModel then
				AddListPart(
					"Hair",
					"🪮",
					"ItemRH",
					{"Hair", temp_hairModel.Name, temp_hairModel:GetDebugId()},
					PlayerSelectParams.SelectedPlayer
				)
			else print("No hair was found...")
			end
			
			if ESFolder.Heels:FindFirstChild("Heels") and ESFolder.Heels:FindFirstChild("Heels"):FindFirstChild("HeelName")
			then
				AddListPart(
					ESFolder.Heels:FindFirstChild("Heels") and
						ESFolder.Heels:FindFirstChild("Heels"):FindFirstChild("HeelName") and
						ESFolder.Heels:FindFirstChild("Heels"):FindFirstChild("HeelName").Value or
						"Heels or Shoes",
					"👠",
					"HeelsRH",
					{
						ESFolder.Heels:FindFirstChild("Heels"):FindFirstChild("HeelName") and
							ESFolder.Heels:FindFirstChild("Heels"):FindFirstChild("HeelName").Value or "Heels"
					},
					PlayerSelectParams.SelectedPlayer
				)
			else print("No heels/shoes were found...")
			end
			
			if ESFolder.Skirts:FindFirstChild("Skirt") and ESFolder.Skirts:FindFirstChild("Skirt"):FindFirstChild("SkirtName")
			then
				AddListPart(
					ESFolder.Skirts:FindFirstChild("Skirt") and
						ESFolder.Skirts:FindFirstChild("Skirt"):FindFirstChild("SkirtName") and
						ESFolder.Skirts:FindFirstChild("Skirt"):FindFirstChild("SkirtName").Value or
						"Skirt",
					"👗",
					"ItemRH",
					{
						"Skirts",
						ESFolder.Skirts:FindFirstChild("Skirt"):FindFirstChild("SkirtName") and
							ESFolder.Skirts:FindFirstChild("Skirt"):FindFirstChild("SkirtName").Value or "Skirt",
						ESFolder.Skirts:FindFirstChild("Skirt"):GetDebugId()},
					PlayerSelectParams.SelectedPlayer
				)
			else print("No skirt was found...")
			end
			
			if ESFolder.Wings:FindFirstChild("Wings") then
				AddListPart(
					"Wings",
					"⚪",
					"ItemRH",
					{"Wings", "Wings", ESFolder.Wings:FindFirstChild("Wings"):GetDebugId()},
					PlayerSelectParams.SelectedPlayer
				)
			else print("No wings were found...")
			end
			
			if #ESFolder.Accessories:GetChildren() > 0 then
				AddListPart("Accessories (most clothes)", nil, "Header")
				for _,item : Model in ESFolder.Accessories:GetChildren() do
					if item:IsA("Model") and item:FindFirstChild("AccessoryName") then
						AddListPart(
							item:FindFirstChild("AccessoryName").Value,
							if item:FindFirstChild("AccessoryName").Value:find("Halo") then "😇" else "🎀",
							"ItemRH",
							{"Accessories",item:FindFirstChild("AccessoryName").Value,item:GetDebugId()},
							PlayerSelectParams.SelectedPlayer
						)	-- TODO: I believe this can detect all character parts, but please look over it and make sure nothing's missing before keeping this!
					else warn(item.Name .. " isn't a standard Accessory, apparently.")
					end
				end
			end
			return nil
		end,
		MissingItemResponse					= function(_listIndex : number)
			if _listIndex == 1 then	-- If the character itself couldn't be found, their clothes are gone too. Clear EVERYTHING.
				DisplayToast(ItemList[1].Player and ItemList[1].Player.Name or "[Unknown]".."'s character was missing. Sorry!","🚫",3.333)
				ClearList()
			end	-- If anything else can't be found, just leave the entry in the list for now.
		end
	},
	
	--[[
		DormRH (RH Campus 3-4 dorms and furniture)
		Tries to find the current active dorm by looking for parts named after players' user IDs, scanning each for a Model named
		"InnerDorm", which only spawns on a client when a player stands just outside of an "open" dorm, or inside of it. (If a
		player has "dorm privacy" enabled, the inner model, annoyingly, won't appear if their door is closed.)
		
		If a loaded dorm is found, the full dorm and all of its furniture will be listed in the GUI! Although any piece of
		furniture can be targetted (using its debug ID), if the player changes that item's toggle or variations, it will get a
		new debug ID since RH spawns a new model instead of modifying the existing one. This makes it impossible to save
		multiple versions of a single item when "trying it out", so make sure this is the only copy of that item in your dorm
		if planning to save different variation and toggle combinations.
	]]--
	["DormRH"]								= {
		Title								= "🏠Dorm",
		PlayerContext						= false,	-- A single dorm is loaded at any time, so there's no point in checking a Player.
		Position							= 2,
		ContentType							= "3D",
		Scan								= function()
			-- Find a Part with a numerical name that contains an "InnerDorm" model. This doesn't exist unless a dorm is loaded, our goal.
			local temp_foundDorm : Model?	= nil
			for _, inst in  workspace:GetChildren() do
				if inst:IsA("Part") and tonumber(inst.Name) and inst:FindFirstChild("InnerDorm") then temp_foundDorm = inst; break end
			end
			
			-- Is a dorm loaded? If so, the list can be filled out!
			if temp_foundDorm then
				local temp_owner:Player?	= Players:GetPlayerByUserId(tonumber(temp_foundDorm.Name))
				
				if temp_owner then
					AddListPart(
						"Everything",
						"🏠",
						"DormRH",
						{"DormAll", tonumber(temp_foundDorm.Name)},
						temp_owner
					)
					AddListPart(
						"Interior only (furniture and inner model)",
						"🕳️",
						"DormRH",
						{"DormInner", tonumber(temp_foundDorm.Name)},
						temp_owner
					)
					AddListPart(
						"Furniture only",
						"🛒",
						"DormRH",
						{"FurniAll", tonumber(temp_foundDorm.Name)},
						temp_owner
					)
					
					--[[
						If this dorm Model has a DormFurnjiture model inside it, and it has more than just the "DormObject"
						ObjectValue instance in it, all of its furniture will be indexed below the "general" save options above.
					]]--
					local FurniFolder : Model?	= temp_foundDorm:FindFirstChild("DormFurniture")
					if FurniFolder and #FurniFolder:GetChildren() > 1 and FurniFolder:FindFirstChildOfClass("Model") then
						for _, furniture : Model in FurniFolder:GetChildren() do
							if furniture:IsA("Model") then
								local temp_name : StringValue? =	-- Pick one of this object's redundant 3 StringValues for its name.
									furniture:FindFirstChild("AliasTag") or		-- For halos, this contains their FULL title...
									furniture:FindFirstChild("NameTag") or		-- ...while this uses its shorter, "internal ID" name...
									furniture:FindFirstChild("FurnitureName")	-- ...and this is just an unhelpful number.
								
								--[[
									Furniture will always appear in the list, but if their name wasn't found above, it won't be included
									in the "identification values", so nothing will be saved/cloned if this specific Model is re-
									constructed (by merely changing its toggle or any of its variations, mind you). I should really
									warn the user when this happens, just in case the user's trying to save variations rapidly like me.
								]]--
								AddListPart(
									temp_name and temp_name.Value or furniture.Name:sub(1,16),
									"🪑",
									"DormRH",
									{
										"FurniOne",
										furniture.Name,
										furniture:GetDebugId(),
										temp_name and temp_name.Value or nil
									},
									temp_owner
								)
							end
						end
					else
						DisplayToast(
							"This dorm's furniture Model was missing, or didn't contain any furniture.",
							"ℹ️",
							4.333
						)
					end
				else return "A loaded dorm was found, but couldn't be associated with a Player. Sorry for this inconvenience."
				end
			else
				return
					"No dorms are loaded. Stand near or inside a dorm, then try again." ..
					'"Private" dorms will not load while their doors are closed.'
			end
		end
	},
	
	--[[
		Tools (standard Roblox tool finder)
		A ScanType that does what it says on its tin. This finds Tool instances inside a player's character model, Backpack, and
		StarterPack (which isn't player-specific).
	]]--
	["Tools"]								= {
		Title								= "🔨Tools",
		PlayerContext						= true,		-- Each player will only add one entry to the list, so they're all listed.
		Position							= 10,
		ContentType							= "3D",
		Scan								= function()
			if PlayerSelectParams.SelectedPlayer then
				local temp_char : Model?	= PlayerSelectParams.SelectedPlayer.Character
				if temp_char and temp_char:FindFirstChildOfClass("Tool") then
					AddListPart("Holding in Hand", nil, "Header")
					AddListPart(
						temp_char:FindFirstChildOfClass("Tool").Name,
						"🖐️",
						"Tools",
						{temp_char:FindFirstChildOfClass("Tool").Name, "Character", temp_char:FindFirstChildOfClass("Tool"):GetDebugId()},
						PlayerSelectParams.SelectedPlayer
					)
				end
				
				local temp_backpack : Backpack? = PlayerSelectParams.SelectedPlayer:FindFirstChildOfClass("Backpack")
				if temp_backpack and #temp_backpack:GetChildren() > 0 then
					AddListPart("In Backpack", nil, "Header")
					for _,tool : Tool in PlayerSelectParams.SelectedPlayer:FindFirstChildOfClass("Backpack"):GetChildren() do
						if tool:IsA("Tool") then
							AddListPart(
								tool.Name,
								"🔨",
								"Tools",
								{tool.Name, "Backpack", tool:GetDebugId()},
								PlayerSelectParams.SelectedPlayer
							)
						end
					end
				end
				
				if StarterPack and #StarterPack:GetChildren() > 0 and StarterPack:FindFirstChildOfClass("Tool") then
					AddListPart("StarterPack tools", nil, "Header")
					for _,tool : Tool in StarterPack:GetChildren() do
						if tool:IsA("Tool") then
							AddListPart(
								tool.Name,
								"🔨",
								"Tools",
								{tool.Name, "StarterPack", tool:GetDebugId()},
								PlayerSelectParams.SelectedPlayer
							)
						end
					end
				end
			else error("No player was selected. If you saw and picked a player from a list before this, report this as a bug!")
			end
			
			return nil
		end,
		MissingItemResponse					= function(_listIndex : number)
			--[[
				When a Tool can't be found, it's removed from the list, which can easily happen if the player (un)equips anything.
				Since tools are grouped based on their container/location, this code tries to find the elements above and below
				this one in the list, so it can delete the header if this was the last item in a section.
			]]--
			
			local VisiblePosition			= ItemList[_listIndex].ListInstance.LayoutOrder
			local Previous : TextButton?	= nil
			local Next : TextButton?		= nil
			for _,item : GuiObject in GUI_ItemList:GetChildren() do
				if item.LayoutOrder == VisiblePosition + 1 then Next = item
				elseif item.LayoutOrder == VisiblePosition - 1 then Previous = item
				end
				if Previous and Next then break end
			end
			
			-- If this is the very last item, or it's surrounded by headers, it's the last item in this group, so remove the header above.
			if Previous.Name:find("Header") and (not Next or (Next and Next.Name:find("Header"))) then
				Previous:Destroy()
			end
			
			-- Always remove this list item.
			ItemList[_listIndex].ListInstance:Destroy()
			ItemList[_listIndex]			= nil
		end
	},
	["GUI"]									= {
		Title								= "🪟GUIs",
		PlayerContext						= false,		-- Only the local player's GUI can be indexed and copied.
		Position							= 20,
		ContentType							= "2D",
		Scan								= function()
			if not PlayerGui then return "Your PlayerGui container doesn't exist. Wait until the game's GUI appears then try again." end
			if not PlayerGui:FindFirstChildWhichIsA("ScreenGui") then return "This game doesn't have any ScreenGui instances!" end
			for _,screen : ScreenGui in PlayerGui:GetChildren() do
				if screen:IsA("ScreenGui") then
					local temp_frames = {}	-- Before building this ScreenGui's entries, see if it has any Frames inside it.
					if #screen:GetChildren() > 0 then
						for _,frame : Frame in screen:GetChildren() do
							if frame:IsA("Frame") then table.insert(temp_frames, frame) end
						end
					end
					
					-- When Frames are found, a "group" is created for this ScreenGui, with options to save everything or just a Frame.
					if #temp_frames > 0 then
						AddListPart(
							screen.Name,
							nil,
							"Header"
						)
						AddListPart(
							"Everything in this GUI…",
							screen.Enabled and "⏹️" or "⬛",
							"GUI",
							{screen.Name, "PlayerGui", screen:GetDebugId()}	-- Instance name, container, then ScreenGui debug ID
						)
						for _,frame : Frame in temp_frames do
							AddListPart(
								frame.Name,
								frame.Visible and "🟨" or "🟧",
								"GUI",	-- Screen name, container, debug ID, frame name, Frame keyword, then the frame's debug ID
								{screen.Name, "PlayerGui", screen:GetDebugId(), frame.Name, frame:GetDebugId()}
							)
						end
					else	-- Otherwise, just a single item is created for the ScreenGui itself.
						AddListPart(
							screen.Name,
							screen.Enabled and "⏹️" or "⬛",
							"GUI",
							{screen.Name, "PlayerGui", screen:GetDebugId()}	-- Instance name, container, then ScreenGui debug ID
						)
					end
				end
			end
		end
	},
}

--[[
	A similar array for all supported SaveTypes, which are responsible for naming and cloning Instances using context-based info
	like the Instance's name, debug ID, and location (but NEVER a direct Instance reference) that a ScanType stored in the ItemList.
	
	Each SaveType includes a function that takes this "context" array and a "preview" flag, which it can detect to clone the model or
	GUI differently when the item is shown in the window's preview in the right column. This function should return a reference to the
	cloned Model, Tool, ScreenGui, or Frame, which will be copied to a destination folder or to the preview (if it's just selected),
	or a string to display as an error instead of the 3D viewport. (If nil is returned, a generic error may be shown instead.)
	
	Unlike ScanTypes, functions referencing the SaveType's "ContentType" property aren't doing much with it. It's only used if the user
	tries to save something using the "save" button in the window when the SaveType's Get() can't find a matching model/GUI in-game at
	that point. (The save button in the Command Palette never references the preview panel.)
]]--
type SaveReturnTypes					= (string?|Model?|Tool?|ScreenGui?|Frame?)

-- Values passed to SaveTypes' Get() to tweak saving functions if appropriate. WindowHasCache can be used to silence "failure" toasts.
type GetFuncParams						= {			-- This is TRUE if the user taps the window's save button and there's a pre-saved
	WindowHasCache						: boolean,	-- "cached" Model/GUI that could be saved instead of saving the "live" version of it.
	Previewing							: boolean,	-- Is this model/GUI clone meant for the window preview? If FALSE, it's a full save.
	-- TODO: Add a fake "checkbox" to the window that toggles a bool variable like the one below, which SaveFlag1 will use the state of.
}
-- In the future, add a fake checkbox to the window that toggles this variable.
local SaveTypeFlag1 : boolean			= true		-- Changes how some SaveTypes clone and modify their targets. (RH types anonymize.)

type SaveType							= {
	ContentType							: "None"|"2D"|"3D",
	Get									: (_saveParams : GetFuncParams, _contextIDs : {ValidIDValues}) -> (SaveReturnTypes)
}
local SaveTypeDefs : {SaveType}			= {
	--[[
		Char (standard R6/R15 Roblox character models)
		
		Expected context values:
		[1]	Username
		
		Temporarily makes the target Player's character "archivable" then clones it, which includes any accessories and their tool.
	]]--
	["Chara"]							= {
		ContentType						= "3D",
		Get								= function(_saveParams : GetFuncParams, _contextIDs : {ValidIDValues})
			-- print("Tried to save a character!", _contextIDs[1])
			local result:SaveReturnTypes= nil
			local temp_player : Player?	= Players:FindFirstChild(_contextIDs[1])
			if temp_player then
				local temp_char:Model?	= temp_player.Character
				if temp_char then
					local OldArchivable	= temp_char.Archivable
					if not temp_char.Archivable then temp_char.Archivable = true end
					
					result				= temp_char:Clone()
					result.Name			= _contextIDs[1]	-- Name the model after the player, in case the game isn't doing that.
					temp_char.Archivable=OldArchivable
				else
					DisplayToast(
						tostring(_contextIDs[1]) .. "'s character wasn't ready. Is their model visible?",
						"⚠️",
						5
					)
				end
			elseif not _saveParams.WindowHasCache then	-- Warn the player if the model couldn't be found, if relevant.
				DisplayToast(
					"Couldn't find " .. tostring(_contextIDs[1]) .. "! Their model may be unloaded or they left the server.",
					"⚠️",
					6.5
				)
			end
			
			return result
		end
	},
	--[[
		Tools (standard Roblox tool instance grabber)
		A self-explanatory SaveType, which tries to find and clone a tool with a specific name in a specific container
		(the player's character, backpack, or the StarterPack).
		
		Expected context values:
		[1]	Tool's name
		[2]	Location ("Character", "Backpack" or "StarterPack")
		[3]	Tool debug ID (as a fallback)
	]]--
	["Tools"]							= {
		ContentType						= "3D",
		Get								= function(_saveParams : GetFuncParams, _contextIDs : {ValidIDValues})
			if not _contextIDs then
				error("No context values were provided to the Tools SaveType. Please report this as an issue on GitHub.")
			elseif type(_contextIDs) ~= "table" then
				error("The context values variable isn't an array.")
			elseif #_contextIDs ~= 3 then
				error("The Tools SaveType requires exactly 3 context values.")
			elseif _contextIDs[2] ~= "Character" and _contextIDs[2] ~= "Backpack" and _contextIDs[2] ~= "StarterPack" then
				error("Unknown tool location given. (Only 'Character', 'Backpack', and 'StarterPack' are accepted.)")
			end
			local result:SaveReturnTypes= nil
			
			if _contextIDs[2] == "Character" then
				local temp_char:Model?	= PlayerSelectParams.SelectedPlayer.Character
				if not temp_char then
					DisplayToast(PlayerSelectParams.SelectedPlayer.DisplayName.."'s character couldn't be found.","❔",3.175)
					error("Couldn't find that player's character.x")
				end
				result					= FindToolChild(temp_char, _contextIDs[1], _contextIDs[3])
			elseif _contextIDs[2] == "Backpack" then
				local temp_backpack		= PlayerSelectParams.SelectedPlayer:FindFirstChildOfClass("Backpack")
				if not temp_backpack then
					DisplayToast(PlayerSelectParams.SelectedPlayer.DisplayName.."'s backpack couldn't be found.","❔",3.175)
					error("Couldn't find that player's backpack.x")
				end
				result					= FindToolChild(temp_backpack, _contextIDs[1], _contextIDs[3])
			elseif _contextIDs[2] == "StarterPack" then
				result					= FindToolChild(StarterPack, _contextIDs[1], _contextIDs[3])
			end
			
			return result
		end
	},
	--[[
		GUI (ScreenGui and child Frames inside PlayerGui)
		
		Expected context values:
		[1]	Base ScreenGui name
		[2]	GUI location (unused, but is always PlayerGui currently, and I could add support for StarterGui using it)
		[3]	ScreenGui debug ID (fallback if ScreenGui can't be found)
		[4]	Child Frame name
		[5]	Child frame's debug ID (also used as a fallback)
	]]--
	["GUI"]								= {
		ContentType						= "2D",
		Get								= function(_saveParams : GetFuncParams, _contextIDs : {ValidIDValues})
			local result:SaveReturnTypes= nil
			if not PlayerGui then
				if not _saveParams.WindowHasCache then
					DisplayToast(
						"PlayerGui doesn't exist at the moment. Wait until the in-game GUI appears then try saving again.",
						"⚠️",
						5
					)
				end
			else	-- First, find the requested ScreenGui; Look for one with its name, and see if its debug ID matches.
				local TargetScreenGUI:ScreenGui?|Frame?	= nil	-- If this is set below, it will be cloned.
				local temp_firstScreenGui : ScreenGui?	= PlayerGui:FindFirstChild(_contextIDs[1])
				if temp_firstScreenGui and temp_firstScreenGui:GetDebugId() == _contextIDs[3] then
					TargetScreenGUI						= temp_firstScreenGui	-- Alright, we got 'em!
				else	-- If we couldn't quickly find it, brute-force every Instance in PlayerGui, looking for an exact match.
					for _,gui : Instance in PlayerGui:GetChildren() do
						if gui:IsA("ScreenGui") and gui.Name == _contextIDs[1] and gui:GetDebugId() == _contextIDs[3] then
							TargetScreenGUI				= gui
							break
						end
					end
				end
				
				--[[
					If a matching ScreenGui could be located, we'll clone it, as long as we aren't actually searching for a
					specific Frame inside of it (context indices 4-5). If those are specified, look for the Frame instead.
				]]--
				if TargetScreenGUI then
					if _contextIDs[4] and _contextIDs[5] then
						
					else	-- Just clone the ScreenGui itself.
						result = TargetScreenGUI:Clone()
					end
				elseif not _saveParams.WindowHasCache then	-- Warn the player if the model couldn't be found, if relevant.
					DisplayToast(
						"The ScreenGUI you selected wasn't inside PlayerGui. Did the game destroy it? Animations don't stay around.",
						"🫥",
						8
					)
				end
			end
			
			return result
		end
	},
	--[[
		ItemRH (General Royale High clothing item capturer)
		Accesses the currently-selected Player's EquippedStorage sub-folders and tries to find matching clothing in a category.
		
		Expected context values:
		[1]	Category/folder name (Accessories / Hair / Skirts / Wings, heels are saved by the HeelsRH SaveType)
		[2]	Item model name
		[3]	Model debug ID (used as fallback if a matching name isn't found)
		
		TODO: Currently, when an item is saved by itself, its main weld(s), which attach it to the player's body parts, are
		removed by Roblox after the model is cloned. It's easy to recreate these welds, since they usually don't have a
		CFrame offset, but they should be maintained if possible. Consider writing code that looks for descendants named
		after the standard R15 body parts (and if it's a Model, look for a BasePart within it ALSO named after a body part),
		stores info about the Weld instance and its Part1, then nil's the Part1 before cloning the item.
		
		This should keep any "main welds", and it's easy to iterate through that array of dictionary entries to re-attach
		any Welds that were briefly disconnected just before it was cloned.
	]]--
	["ItemRH"]							= {
		ContentType						= "3D",
		Get								= function(_saveParams : GetFuncParams, _contextIDs : {ValidIDValues})
			local result : Model?		= nil	-- This contains the final Model, if anything was found/cloned.
			local ESFolder				= GetESFolders(PlayerSelectParams.SelectedPlayer.Name)
			
			if not ESFolder[_contextIDs[1]] then
				if not _saveParams.WindowHasCache then	-- Hide this toast if the player's saving using the in-window save button w/ cache.
					DisplayToast(
						"The requested item, " .. type(_contextIDs[2]) == "string" and _contextIDs[2] or "[Unknown]" ..
							" isn't of a valid type, or its EquippedStorage sub-folder doesn't exist here.",
						"⛔",
						8.125
					)
				end
				error("Couldn't save this RH item.x")
			end
			
			-- First, see if there's a Model with this exact title. (There almost always should be, but y'never know...)
			local temp_model : Model?	= ESFolder[_contextIDs[1]]:FindFirstChild(_contextIDs[2])
			
			-- Couldn't find the Model? Scan every item in the folder, looking for the fallback debug ID.
			if not temp_model then
				for _, item : Model? in ESFolder[_contextIDs[1]]:GetChildren() do
					if item:GetDebugId() == _contextIDs[3] then
						temp_model		= item
						break
					end
				end
			end
			
			if not temp_model then
				if not _saveParams.WindowHasCache then	-- Hide this toast if the player's saving using the in-window save button w/ cache.
					DisplayToast(
						"Apologies, but " .. type(_contextIDs[2]) == "string" and _contextIDs[2] or "[Unknown]" ..
							" couldn't be found. The player may have unequipped it since you scanned them.",
						"⛔",
						8.125
					)
				end
				error("Item wasn't found in the folder.x")
			end
			
			--[[
				Figure out this item's title, toggle, and variation info, and update its name and attributes appropriately.
				Don't do this for hair and wings, which don't include their title in their Model name or a StringValue.
			]]--
			result = temp_model:Clone()
			if _contextIDs[1] ~= "Hair" and _contextIDs[1] ~= "Wings" then AssignDescriptiveRHItemName(false, result) end
			
			--[[
				Before giving the Model to the caller, see if the user wants to "anonymize" the item. For RH clothing (which
				this type saves), this mainly recolors all "skin" parts to a generic light grey mannequin-like color, leaving
				the rest of the model unchanged. (If this was CharaRH, this would also change the character's name and face.)
			]]--
			if SaveTypeFlag1 then
				for _,desc : BasePart in result:GetDescendants() do
					if desc:IsA("BasePart") and desc.Name == "coloredleg" then	-- For some reason, all skin parts have this name. 🙄
						desc.Color = COLOR_ANON_SKIN
					end
				end
			end
			
			return result
		end
	},
	--[[
		HeelsRH (Royale High shoe/heel saver)
		Finds and clones a character's equipped footwear, accounting for both legacy shoes (which attach to your legs
		like most basic accessory models) and modern heels (which completely replace their R15 leg parts). For the
		latter kind of shoes, the character will be reverted into a "woman rig" (since its body parts are always
		there), and if the model should be anonymized, its name, skin tone, and face will be generalized, since the
		replaced leg parts are designed to connect to the character's LowerTorso.
		
		Unlike most SaveTypes, HeelsRH does NOT expect any context values, as heels have a consistent structure. This
		could be problematic if this script is expanded to allow saving NPC character models, since those don't use
		the normal EquippedStorage folder, using an internal clone of it, or just a bunch of Models instead.
	]]--
	["HeelsRH"]							= {
		ContentType						= "3D",
		Get								= function(_saveParams : GetFuncParams, _contextIDs : {ValidIDValues})
			local result : Model?		= nil	-- This contains the final Model, if anything was found/cloned.
			local ESFolder				= GetESFolders(PlayerSelectParams.SelectedPlayer.Name)
			local AreModernShoes		= false
			
			-- After getting the EquippedStorage references, make sure they're actually there before proceeding.
			if not ESFolder then
				if not _saveParams.WindowHasCache then	-- Hide this toast if the player's saving using the in-window save button w/ cache.
					DisplayToast(
						"The EquippedStorage folder or one of its expected sub-folders couldn't be located.",
						"⛔",
						4.375
					)
				end
				error("Couldn't save a character's heels.x")
			end
			
			--[[
				First, find out if this player's wearing modern or legacy shoes. This is easy, though; Simply check their lower leg's
				type! If it's a Part, these are modern shoes.
			]]--
			local PlayerChar			= PlayerSelectParams.SelectedPlayer.Character
			if not PlayerChar then
				if not _saveParams.WindowHasCache then	-- Hide this toast if the player's saving using the in-window save button w/ cache.
					DisplayToast(
						"Couldn't get a reference to the selected Player's character.",
						"⛔",
						3.25
					)
				end
				error("Couldn't find the selected Player's character.x")
			end
			local temp_upperLegPart		= PlayerChar:FindFirstChild("LeftUpperLeg")
			if not temp_upperLegPart then
				if not _saveParams.WindowHasCache then	-- Hide this toast if the player's saving using the in-window save button w/ cache.
					DisplayToast(
						"That character's upper left leg part couldn't be found. Make sure they're rendered/visible to you.",
						"⛔",
						5.675
					)
				end
				error("Couldn't find that player's upper left leg part.x")
			end
			
			-- When this flag's set, the player's character is saved instead of the Heels model.
			AreModernShoes				= PlayerChar:FindFirstChild("LeftUpperLeg") and PlayerChar:FindFirstChild("LeftUpperLeg"):IsA("Part")
			
			local HeelModel : Model?	= ESFolder.Heels:FindFirstChildOfClass("Model")
			if not HeelModel then
				if not _saveParams.WindowHasCache then	-- Hide this toast if the player's saving using the in-window save button w/ cache.
					DisplayToast(
						"That character's Heels model couldn't be found. Make sure they're rendered/visible to you.",
						"⛔",
						5.333
					)
				end
				error("Couldn't find that player's Heels model in EquippedStorage.x")
			end
			
			--[[
				Depending on what kind of shoes this character's wearing, either save their full character model (modern shoes)
				or just the Model in the Heels sub-folder (legacy/classic RH shoes). Since player characters can't be cloned by
				default, it's briefly made "archivable" until it's cloned as this function's "result" Model.
				
				From here, the code flow merges, the clone is given a meaningful name/attributes, then it is anonymized; This
				affects the model's skin tone, but it changes modern shoe model clones even more, turning them into mannequins.
			]]--
			if AreModernShoes then
				local temp_archivable	= PlayerChar.Archivable
				if not temp_archivable then PlayerChar.Archivable = true end
				
				result					= PlayerChar:Clone()
				PlayerChar.Archivable	= temp_archivable
			else
				result					= HeelModel:Clone()
			end
			
			AssignDescriptiveRHItemName(false, result, HeelModel)	-- This call should work for both kinds of shoes...hopefully.
			
			--[[
				Before giving the Model to the caller, see if the user wants to "anonymize" the item. For RH clothing (which
				this type saves), this mainly recolors all "skin" parts to a generic light grey mannequin-like color, leaving
				the rest of the model unchanged. (If this was CharaRH, this would also change the character's name and face.)
			]]--
			if SaveTypeFlag1 then
				FixRHCharacter(
					result, {
						DoExtraChecks	= AreModernShoes,	-- If these are modern shoes, this will more thoroughly modify the Model.
						SkinTone		= true,
						Face			= true,
						RPName			= "remove",
						LowerTorsoFix	= true,	-- I prefer to always show this part, but heel-only characters won't be wearing a skirt.
						AllR15Parts		= true,
						HumanoidName	= "change",
						Clothing2D		= true
					}
				)
			end
			
			return result
		end
	},
	--[[
		CharaRH (Full RH player character models)
		Saves full characters by temporarily moving their EquippedStorage sub-folders into the main model before
		cloning them, maintaining all clothing welds and making the resulting model neater! Although this SaveType
		has a short description, its code is more complex than this suggests.
		
		Unlike most SaveTypes, CharaRH doesn't use any context values, as players' characters and EquippedStorage
		are always found within the workspace at workspace.EquippedStorage and workspace[username].
	]]--
	["CharaRH"]							= {
		ContentType						= "3D",
		Get								= function(_saveParams : GetFuncParams, _contextIDs : {ValidIDValues})
			local result : Model?		= nil	-- This contains the final Model, if anything was found/cloned.
			local ESFolder				= GetESFolders(PlayerSelectParams.SelectedPlayer.Name)
			local FolderParents:{Folder}= {}	-- Will contain references to each ES player folder's parent.
			-- After getting the EquippedStorage references, make sure they're actually there before proceeding.
			if not ESFolder then
				if not _saveParams.WindowHasCache then	-- Hide this toast if the player's saving using the in-window save button w/ cache.
					DisplayToast(
						"The EquippedStorage folder or one of its expected sub-folders couldn't be located.",
						"⛔",
						4.375
					)
				end
				error("Couldn't save a complete character model.x")
			end
			
			local PlayerChar			= PlayerSelectParams.SelectedPlayer.Character
			if not PlayerChar then
				if not _saveParams.WindowHasCache then	-- Hide this toast if the player's saving using the in-window save button w/ cache.
					DisplayToast(
						"Couldn't get a reference to the selected Player's character.",
						"⛔",
						3.25
					)
				end
				error("Couldn't find the selected Player's character.x")
			end
			
			-- Get references to each folder's parent; After cloning, the player's five sub-folders will be returned to these folders.
			for _,name in RH_ES_FOLDER_NAMES do
				table.insert(FolderParents, ESFolder[name].Parent)	-- Store a reference to this category's parent.
				ESFolder[name].Parent	= PlayerChar				-- Move the sub-folder into the character model.
				ESFolder[name].Name		= name						-- Name it after the category (instead of the player's username).
			end
			
			local temp_archivable		= PlayerChar.Archivable		-- Store this Model's original "archivable" value.
			if not PlayerChar.Archivable then PlayerChar.Archivable = true end
			result = PlayerChar:Clone()								-- Clone the player's character now.
			PlayerChar.Archivable		= temp_archivable			-- Revert our archivable flag modification.
			
			-- Finally, revert our changes, moving each ES sub-folder back and renaming them after the player's username again.
			for i,name in RH_ES_FOLDER_NAMES do
				local temp_folder:Folder= PlayerChar:FindFirstChild(name)
				if temp_folder then
					temp_folder.Name	= PlayerSelectParams.SelectedPlayer.Name
					temp_folder.Parent	= FolderParents[i]
				end
			end
			table.clear(FolderParents)
			
			--[[
				Before giving the Model to the caller, see if the user wants to "anonymize" the item. For RH clothing (which
				this type saves), this mainly recolors all "skin" parts to a generic light grey mannequin-like color, leaving
				the rest of the model unchanged. (If this was CharaRH, this would also change the character's name and face.)
			]]--
			if SaveTypeFlag1 then
				FixRHCharacter(
					result, {
						DoExtraChecks	= true,
						SkinTone		= false,
						Face			= false,
						RPName			= "hide",
						LowerTorsoFix	= true,	-- I shouldn't do this for accuracy, but this makes the character look more complete, so...
						AllR15Parts		= false,
						HumanoidName	= "hide",
						Clothing2D		= false
					}
				)
			end
			
			return result	-- And we're done! This SaveType only took just under 25 minutes to code, surprisingly!
		end
	}
}

-- Scans through a game/place-specific "override list", adding/removing ScanTypes as requested.
local function Init_ParseDetectList(_list : {string})
	if _list and #_list > 0 and type(_list[1]) == "string" then
		for _,_name in _list do
			if _name:sub(1,1) == "-" then	-- If any string starts with '-', it's a command to remove a type from the list.
				local temp_index = table.find(CurrentDetectTypes, _name:sub(2,-1))	-- Try to find the type it's referring to…
				if temp_index then table.remove(CurrentDetectTypes, temp_index) end	-- …and remove it if it's anywhere on the list.
			else	-- If this one doesn't have a hyphen prefix, just append it to the list if it isn't already there (and is valid)
				local temp_index = table.find(CurrentDetectTypes, _name)
				if DetectTypeDefs[_name] and not temp_index then table.insert(CurrentDetectTypes, _name) end
			end
		end
	else error("Init_ParseDetectList: The list was invalid!")
	end
end
CurrentDetectTypes = table.clone(DefaultDetectTypes)	-- Initially, just use the default types, then add game/place-specific lists to it.
if GameOverrideData[GAME_ID] then	Init_ParseDetectList(GameOverrideData[GAME_ID])		end
if PlaceOverrideData[PLACE_ID] then	Init_ParseDetectList(PlaceOverrideData[PLACE_ID])	end

-- Hides/dims the window and Command Palette save buttons when disabled, respectively, and the opposite when they're enabled.
local function ChangeSaveButtonState(_enable : boolean)
	Button_SaveCmd.Active			= _enable
	Button_SaveCmd.BackgroundColor3	= Button_SaveCmd:GetAttribute(_enable and "EnabledColor" or "DisabledColor")
	Button_SaveWindow.Visible		= _enable
end

local function DetectItemsOfType(_type : string)
	local ScanType_ReturnMsg : string? = nil	-- If a ScanType can't find anything, it might show a special message.
	PlayerSelectParams.RealScanType = ""	-- This variable isn't necessary after the hackish "player scan" occurs.
	IsBusy = true
	ClearList()
	
	--[[
		Before trying to scan for a type that requires a specific player for "context", temporarily store the intended type in a variable
		then scan for players instead. When the user selects a Player, this function is called AGAIN, but with the stored type. Since the
		player scan stored the selected player in the "SelectedPlayer" variable, this code won't run again.
		
		Only the button's click/tap function clears this variable, so re-selecting the same category WILL prompt for a Player again.
	]]--
	if DetectTypeDefs[_type].PlayerContext and not PlayerSelectParams.SelectedPlayer then
		PlayerSelectParams.RealScanType = _type
		_type = "I_Plyrs"
	end
	local success, errormsg = pcall(function() ScanType_ReturnMsg = DetectTypeDefs[_type].Scan() end)
	IsBusy = false
	
	-- Check how many instances are inside the list Instance. If there's more than 1 (the UIListLayout), hide the message overlay.
	GUI_EmptyItemListText.Visible = #GUI_ItemList:GetChildren() <= 1
	return success, errormsg, ScanType_ReturnMsg
end

local function OnScanTypeButtonClick(_type : string)
	if IsBusy then return false end	-- Don't try to find things if a scan/save is already happening.
	
	LastScanType						= _type
	GUI_EmptyItemListText.Text			= "Scanning for " .. tostring(DetectTypeDefs[_type].Title) .. "…"
	GUI_EmptyItemListText.Visible		= true
	GUI_Viewer3D.Visible				= false
	GUI_Viewer2D.Visible				= false
	GUI_ViewerMessage.Text				= DEF_PREVIEW_MSG
	GUI_ViewerMessage.Visible			= true
	
	PlayerSelectParams.SelectedPlayer	= nil	-- Invalidate the selected Player, so the ScanType may ask the user to pick a target again.
	local done,RobloxError,scanError	= pcall(function() DetectItemsOfType(_type) end)
	if not done then
		IsBusy = false
		DisplayToast(
			"Whoops! Type " ..
				tostring(_type) or "???" ..
				" couldn't complete its scan! Error: " ..
				RobloxError or "[no error message provided]",
			"🚫",
			10
		)
		GUI_EmptyItemListText.Text		= "An error occurred while attempting to scan for "..tostring(DetectTypeDefs[_type].Title).."."
		ClearList()
	elseif #GUI_ItemList:GetChildren() <= 1 then	-- If the list's still empty, show the ScanType's error or a fallback generic message.
		GUI_EmptyItemListText.Text		= scanError or "No results were found of that type. Please try another 'category' (button)."
		GUI_EmptyItemListText.Visible	= true
	else
		GUI_EmptyItemListText.Visible	= false
	end
end

-- Now that all ScanTypes have been added to the list, add their buttons above the list in the window!
local temp_lastPositionValue:number	= 1	-- Updates each time a button is added to the list, so each button has a unique order value.
for _,_type in CurrentDetectTypes do
	if DetectTypeDefs[_type] and DetectTypeDefs[_type].Title and DetectTypeDefs[_type].Scan then
		if DetectTypeDefs[_type].Position then
			temp_lastPositionValue	= DetectTypeDefs[_type].Position
		else temp_lastPositionValue	+= 1	-- Increase the number if this type somehow doesn't have a position defined.
		end
		
		local newTypeBtn			= Template_DetectType:Clone()
		newTypeBtn.Name				= "DetectType_" .. _type
		newTypeBtn.LayoutOrder		= temp_lastPositionValue
		newTypeBtn.Text				= DetectTypeDefs[_type].Title
		newTypeBtn.MouseButton1Click:Connect(function() OnScanTypeButtonClick(_type) end)
		newTypeBtn.Visible			= true
		newTypeBtn.Parent			= GUI_DetectTypeList
	end
end

-- ITEM LIST FUNCTIONS AND CODE
--[[
	<custom><nb>
	Un-highlights all list items other than the requested one, then calls that item's SaveType function to display its
	3D model in the preview area.
]]--
local function SelectAndShowItem(_itemNum : number)
	ChangeSaveButtonState(false)	-- Disable the save button until the selected item is cloned/displayed successfully.
	if _itemNum and _itemNum > 0 and _itemNum <= #ItemList then
		if ItemList[_itemNum].SaveType == "I_Plyrs" then	-- If picking a player HACKISHLY, update SelectedPlayer then start a new scan.
			local temp_player : Player? = Players:FindFirstChild(ItemList[_itemNum].Identifiers[1])
			if temp_player then
				PlayerSelectParams.SelectedPlayer = temp_player
				ClearList()
				DetectItemsOfType(PlayerSelectParams.RealScanType)
			else
				DisplayToast(
					"That player couldn't be found. Maybe they left the server? Try picking someone else.",
					"🚫",
					7.5
				)
				ItemList[_itemNum].ListInstance:Destroy()	-- Remove this player from the list.
				table.remove(ItemList, _itemNum)
			end
		else
			SelectedIndex = _itemNum
			for i,entry : DetectedItemEntry in ItemList do	-- Update all items' backgrounds, only giving the selected item a blue color.
				entry.ListInstance.BackgroundTransparency = if i == _itemNum then 0 else 1
			end
			
			-- Make sure this item's SaveType and its "get" function exist before trying to preview it. If they don't, display a Toast.
			if SaveTypeDefs[ItemList[_itemNum].SaveType] and SaveTypeDefs[ItemList[_itemNum].SaveType].Get then
				-- Clone the relevant content (model, GUI, etc.) and place it in the correct viewer, based on its "ContentType" value.
				local previewContent : SaveReturnTypes = SaveTypeDefs[ItemList[_itemNum].SaveType].Get(
					{Previewing = true, WindowHasCache = false},
					ItemList[_itemNum].Identifiers
				)
				if previewContent then
					if #GUI_CurrentCache:GetChildren() > 0 then GUI_CurrentCache:ClearAllChildren() end
					local cacheContent				= previewContent:Clone()	-- Place the cloned Instance in our cache, first.
					cacheContent.Parent				= GUI_CurrentCache
					
					if SaveTypeDefs[ItemList[_itemNum].SaveType].ContentType == "3D" then
						previewContent:PivotTo(CFrame.identity)	-- Move our clone to the origin before displaying it in the 3D view.
						previewContent.Parent		= GUI_ModelViewer	-- The 3D view camera script removes other Models automatically.
						GUI_ViewerMessage.Visible	= false
						GUI_Viewer2D.Visible		= false
						GUI_Viewer3D.Visible		= true	-- Just show the 3D model viewer.
					elseif SaveTypeDefs[ItemList[_itemNum].SaveType].ContentType == "2D" then
						if #GUI_Viewer2D:GetChildren() > 0 then GUI_Viewer2D:ClearAllChildren() end
						if previewContent:IsA("ScreenGui") then	-- Move everything out of the ScreenGui so it shows in the preview pane.
							for _,child : GuiObject in previewContent:GetChildren() do
								if child:IsA("PackageLink") then child:Destroy()	-- PackageLinks can't be moved, but they're useless.
								else child.Parent = GUI_Viewer2D				-- Any other GUI elements SHOULD be safe to re-parent.
								end
							end
							previewContent:Destroy()	-- Get rid of the empty ScreenGui now.
						else
							previewContent.Parent	= GUI_Viewer2D	-- A Frame (or other GUI element) can be rendered normally.
						end
						
						GUI_ViewerMessage.Visible	= false
						GUI_Viewer3D.Visible		= false
						GUI_Viewer2D.Visible		= true	-- Just show the 2D/GUI preview.
					else
						GUI_Viewer3D.Visible		= false
						GUI_Viewer2D.Visible		= false
						GUI_ViewerMessage.Text		= "This Instance can't be previewed."
						GUI_ViewerMessage.Visible	= true	-- Hide both previews, since this Instance is neither 3D nor 2D.
					end
					
					ChangeSaveButtonState(true)	-- Since the content could be cloned, it should be safe to allow tapping the save buttons now.
				else
					-- If this ScanType has a function for removing useless list items when they aren't found, run it before showing a toast.
					if DetectTypeDefs[LastScanType].MissingItemResponse then
						DetectTypeDefs[LastScanType].MissingItemResponse(_itemNum)
					end
					DisplayToast("For some reason, the content you selected wasn't found. It may have been destroyed.", "⚠️", 5.25)
				end
			else
				DisplayToast(
					"This item can't be previewed. Its SaveType, " .. ItemList[_itemNum].SaveType .. ", isn't valid yet!",
					"⛔",
					5.75
				)
			end
			
		end
	else
		DisplayToast("Attempted to select an item outside of the list (" .. tostring(_itemNum) .. ").","⚠️",4.75)
	end
end

--[[
	<custom><nb>
	Appends a new savable item to the list on the left side of the window and the internal
	list/array (ItemList). Each cloned item template is set up to use the common selection
	behavior, and should work without any additional code.
]]--
function AddListPart(_name:string,_icon:string,_type:string,_identifiers:{ValidIDValues}, _player : Player?)
	VisibleListSize							+= 1
	local temp_selectableItems				= #ItemList
	if _type ~= "Header" then
		if not _icon then _icon = "❔" end
		local newListItem					= Template_Item:Clone()
		newListItem.Name					= "ListItem" .. VisibleListSize
		newListItem.LayoutOrder				= VisibleListSize
		newListItem.Icon.Text				= _icon
		newListItem.Title.Text				= _name or "Unknown"
		newListItem.Visible					= true
		newListItem.Parent					= GUI_ItemList
		
		-- Copy the empty table template, then fill it out with this function call's parameters.
		local newEntry : DetectedItemEntry	= table.clone(EMPTY_ITEM_ENTRY)
		newEntry.Title						= _name
		newEntry.Icon						= _icon
		newEntry.Identifiers				= _identifiers
		newEntry.SaveType					= _type
		newEntry.Player						= _player
		newEntry.ListInstance				= newListItem
		newEntry.SelectEvent				= newListItem.MouseButton1Click:Connect(function()
			SelectAndShowItem(temp_selectableItems + 1)
		end)
		
		table.insert(ItemList, newEntry)	-- Finally, add this entry to the table/array!
	else
		local newHeader						= Template_Header:Clone()
		newHeader.Name						= "HeaderItem" .. VisibleListSize
		newHeader.LayoutOrder				= VisibleListSize
		newHeader.Text						= _name or "Untitled section"
		newHeader.Visible					= true
		newHeader.Parent					= GUI_ItemList
	end
	
	return nil
end

function ClearList()
	ChangeSaveButtonState(false)	-- Disable both save buttons, since there won't be any savable instances soon.
	
	if #ItemList > 0 then table.clear(ItemList) end
	VisibleListSize					= 0
	SelectedIndex					= 0	-- Deselect an item, if it's selected.
	
	-- Also clear the visible list, keeping internal template and list instances in-tact.
	for _,inst : Instance in GUI_ItemList:GetChildren() do
		if not inst.Name:find("Template") and not inst:IsA("UIListLayout") then inst:Destroy() end
	end
	
	GUI_EmptyItemListText.Text		= "Please tap/click a category above! Any detected items will appear here."
	GUI_EmptyItemListText.Visible	= true
	
	-- Hide both content preview areas and show the default message again.
	GUI_Viewer3D.Visible			= false
	GUI_Viewer2D.Visible			= false
	GUI_ViewerMessage.Text			= DEF_PREVIEW_MSG
	GUI_ViewerMessage.Visible		= true
	ChangeSaveButtonState(false)
	return nil
end
ClearList()

-- Tries to close a toast with a specific GUID. Once a toast starts fading out, this won't affect it.
local function CloseToast(_guid)
	if ToastData[_guid] and type(ToastData[_guid]) == "table" and	-- Ensure this toast is linked (usable) before continuing.
		type(ToastData[_guid].GUIElement) == "userdata"
	then
		-- If this toast's fading in, pause that tween, then replace it with a new one that fades out.
		if ToastData[_guid].Tween and ToastData[_guid].Tween.PlaybackState ~= Enum.PlaybackState.Completed then
			ToastData[_guid].Tween:Pause()
			ToastData[_guid].Tween:Destroy()
			ToastData[_guid].Tween = nil
		end
		
		-- Use a Tween to fade out the toast, then destroy it using Debris.
		ToastData[_guid].Tween = TweenService:Create(ToastData[_guid].GUIElement, TI_TOAST_FADEOUT, {GroupTransparency = 1}):Play()
		Debris:AddItem(ToastData[_guid].GUIElement, TI_TOAST_FADEOUT.Time)
		ActiveToasts -= 1	-- Also, stop tracking this toast so it doesn't lead to another old toast closing itself.
		
		-- Remove this GUID from the list ASAP, which should stop DisplayToast()'s delayed CloseToast() call.
		ToastData[_guid].GUIElement = nil
		table.clear(ToastData[_guid])
	end
end

--[[
	<custom><nb>
	A self-explanatory function that shows a momentary notification in the lower-right corner for a set duration. The user can
	dismiss any toast early by clicking/tapping on its icon.
]]--
function DisplayToast(_text : string, _icon : string, _time : number)
	task.defer(function()
		local newGuid			= game:GetService("HttpService"):GenerateGUID(false)
		HighestToastNumber		+= 1
		
		-- Clone and customize the toast template.
		local newToast			= Template_Toast:Clone()
		newToast.Message.Text	= type(_text) == "string" and _text or "No text was specified for this toast."
		newToast.Icon.Text		= _icon	-- (type(_text) == "string" and _icon:len() < 3 and _icon) or "❔"
		newToast.LayoutOrder	= HighestToastNumber
		newToast.Visible		= true
		newToast.Parent			= GUI_ToastBounds
		
		local Tween_FadeIn		= TweenService:Create(newToast, TI_TOAST_FADEIN, {GroupTransparency = 0})
		ToastData[newGuid]	= {
			GUIElement			= newToast,
			Tween				= Tween_FadeIn
		}
		ActiveToasts			+= 1	-- Add this toast to the counter.
		
		-- If there are too many toasts visible, find the oldest one and close it.
		if ActiveToasts > 4 then
			local TargetInfo	= {
				GUID			= nil,
				LowestID		= HighestToastNumber + 1
			}
			for guid : string,toast in ToastData do
				if toast.GUIElement.LayoutOrder < TargetInfo.LowestID then
					TargetInfo.LowestID = toast.GUIElement.LayoutOrder
					TargetInfo.Toast = guid
				end
			end
			if TargetInfo.GUID then
				CloseToast(TargetInfo.GUID)
			end
		end
		
		-- Fade in this toast, but don't let the player click/tap it to hide it early UNTIL this finishes, waiting to connect a function.
		Tween_FadeIn:Play()
		Tween_FadeIn.Completed:Wait()
		Tween_FadeIn:Destroy()
		newToast.Icon.MouseButton1Click:Connect(function() CloseToast(newGuid) end)
		
		task.wait(_time)
		CloseToast(newGuid)	-- All toasts automatically close after a delay. This function won't run if the user closed it before this, too.
	end)
end

-- GUI BUTTON FUNCTIONS
Button_ListCmd.MouseButton1Click:Connect(function()	-- The "list" command button toggles window visibility.
	GUI_Window.Visible			= not GUI_Window.Visible
	GUICarrier_Commands.Visible	= not GUI_Window.Visible
end)
Button_CloseWindow.MouseButton1Click:Connect(function()	-- The window's close button does the same thing, but always hides itself.
	GUI_Window.Visible			= false
	GUICarrier_Commands.Visible	= true
end)

-- Long-tap or right-click the Command Palette close button to close RH Accessory Preserver.
local function ExitAccessoryPreserver()
	ClearList()
	GUI_Window.Visible			= false
	GUICarrier_Commands.Visible	= false
	DisplayToast("Thank you. Have a nice day/night!", "👋", 2.25)
	task.wait(2.5)
	
	GUI_Base:Destroy()
	script:Destroy()
end

local function GetLongTapText() : string
	local temp_inputType = game:GetService("UserInputService"):GetLastInputType()
	return temp_inputType == Enum.UserInputType.Touch and "long-tap" or "right-click"
end

Button_CloseCmd.MouseButton1Click:Connect(function()
	DisplayToast(
		"To close RH Accessory Preserver, please "..GetLongTapText().." the close button.",
		"ℹ️",
		5.25
	)
end)
Button_CloseCmd.MouseButton2Click:Connect(ExitAccessoryPreserver)
Button_CloseCmd.TouchLongPress:Connect(ExitAccessoryPreserver)

-- The refresh button re-scans for the last ScanType the user looked for before, as long as nothing's ongoing.
Button_RefreshWindow.MouseButton1Click:Connect(function()
	if not IsBusy and LastScanType:len() > 0 then
		ClearList()
		OnScanTypeButtonClick(LastScanType)
	end
end)

--[[
	<custom><nb><md>
	One of the major functions in this script, which runs SaveTypes' Get() functions to clone specific Instances, moving them to a
	specific sub-folder in Lighting (which can be saved using UniversalSynSaveInstance or my Recreation API). Although the user
	names the first sub-folder, SaveTypes can request to save their captures to their own sub-folder. For example, RH clothes and
	furniture should create a folder for each unique item, reducing Model name conflicts.
	
	**Parameters**
	_fallbackCache (boolean) - When set, this function will try to grab the content in the preview/cache Folder if the SaveType
	can't find or clone the target when this function runs.
	_override (boolean) - Determines if this save can replace previously-saved models and the like if the new item has the same
	name and folder/location as one. Normally, this will cancel the save, notifying the user about it.
]]--
local function SaveItem(_fallbackCache : boolean, _override : boolean)
	-- Obviously, don't try saving anything if this script's busy or doesn't know what its options are…
	if IsBusy or #ItemList < 1 or SelectedIndex <= 0 then return false end
	if not SaveTypeDefs[ItemList[SelectedIndex].SaveType] then
		DisplayToast(
			"SaveType " .. tostring(ItemList[SelectedIndex].SaveType) .. " hasn't been defined yet! That should be fixed…",
			"⚠️",
			6.75
		)
		return false
	end
	local tryUsingCache							= false	-- Only consider using the preview/cached item if anything is inside the Folder.
	if _fallbackCache and #GUI_CurrentCache:GetChildren() > 0 then tryUsingCache = true end
	IsBusy = true
	ChangeSaveButtonState(false)	-- Disable save buttons until we're done saving this content.
	
	local success, errormsg						= pcall(function()
		local FinalItem : SaveReturnTypes		= nil
		local savedContent : SaveReturnTypes	= SaveTypeDefs[ItemList[SelectedIndex].SaveType].Get(
			{
				WindowHasCache					= _fallbackCache,
				Previewing						= false
			},
			ItemList[SelectedIndex].Identifiers
		)
		
		--[[
			Could the SaveType clone it properly? If it didn't, either throw an error or try to use the preview version as a last
			resort. This is only considered when using the save button in the window if anything's in the hidden "cache" folder.
			This folder (and the visible preview) are cleared if this function can save something to the destination folder and
			isn't stopped because an item with the same name already exists. (This doesn't deselect the target, so the same "item"
			may be saved multiple times, especially if it's RH clothing with multiple toggles/variations, as they use varying names.)
		]]--
		if not savedContent then
			if tryUsingCache then
				FinalItem						= GUI_CurrentCache:GetChildren()[1]:Clone()
				DisplayToast("Using preview fallback " .. FinalItem.ClassName .. ".", "ℹ️", 2.75)
			else
				error("The target couldn't be found/cloned.")
			end
		else
			FinalItem							= savedContent
			-- DisplayToast("Using live " .. FinalItem.ClassName .. ".", "ℹ️", 3)
		end
		
		-- We're almost done! First, see if the user's sub-folder exists, and if it doesn't, create it now.
		if FinalItem then
			local CaptureFolder : Folder		= TryOrCreateFolder(SaveBaseFolder, SaveGroupName)
			
			-- If this specific save's requested to be placed in a level-3 Folder, create it and try to place the clone there.
			if FinalItem:GetAttribute("XReq_ItemFolder") and
				type(FinalItem:GetAttribute("XReq_ItemFolder")) == "string" and FinalItem:GetAttribute("XReq_ItemFolder"):len() > 0
			then
				CaptureFolder					= TryOrCreateFolder(CaptureFolder, FinalItem:GetAttribute("XReq_ItemFolder"))
				FinalItem:SetAttribute("XReq_ItemFolder", nil)	-- Now that it has been referenced, let's remove the "folder" attribute.
			end
			
			-- Before continuing, see if an Instance with the same name is in the Folder. Only replace it if you're allowed to override.
			local temp_duplicate				= CaptureFolder:FindFirstChild(FinalItem.Name)
			if temp_duplicate then
				if not _override then	-- If we can't override the existing Instance, execution ends here.
					DisplayToast(FinalItem.Name .. " is already saved in that sub-folder. To replace it, " ..
						GetLongTapText() .. " the save button.",
						"🙅",
						9.5
					)
					error("Couldn't move the item.x")	-- This error shouldn't appear, as it just stops execution without success.
				else
					temp_duplicate:Destroy()	-- Immediately remove the original item, which is being replaced.
				end
			end
			
			FinalItem.Parent					= CaptureFolder	-- Move our clone to the destination, completing our save!
			
			-- At this point, our job's done, so let's clear the cache and hide preview pane(s).
			local temp_3DItem:(Model|Tool)?=GUI_ModelViewer:FindFirstChildOfClass("Model") or GUI_ModelViewer:FindFirstChildOfClass("Tool")
			if #GUI_CurrentCache:GetChildren() > 0 then	GUI_CurrentCache:ClearAllChildren()	end
			if #GUI_Viewer2D:GetChildren() > 0 then		GUI_Viewer2D:ClearAllChildren()		end
			if temp_3DItem then							temp_3DItem:Destroy()				end
			
			DisplayToast(FinalItem.Name .. " was saved successfully to " .. SaveGroupName .. "!", "✅", 7)
			GUI_Viewer3D.Visible				= false
			GUI_Viewer2D.Visible				= false
			GUI_ViewerMessage.Text				= "This item was saved, so its preview was disabled."
			GUI_ViewerMessage.Visible			= true
		else error("Nothing was cloned, so nothing can be saved.")	-- I don't think FinalItem can be nil at this point, but just in case…
		end
	end)
	
	IsBusy = false
	ChangeSaveButtonState(true)	-- We're done, so the save button should be safe to re-enable.
	
	if not success and errormsg and type(errormsg) == "string" and errormsg:len()>0 and errormsg:sub(-1,-1) ~= "x" then
		DisplayToast("An error occurred while trying to save your target: " .. tostring(errormsg) or "[no error provided]", "🚫", 8.5)
	end
end
Button_SaveWindow.MouseButton1Click:Connect(function()	SaveItem(true, false)	end)
Button_SaveWindow.MouseButton2Click:Connect(function()	SaveItem(true, true)	end)
Button_SaveWindow.TouchLongPress:Connect(function()		SaveItem(true, true)	end)

-- The Command Bar's save button will never use the preview's model, but can forcefully save stuff with a long-tap/right-click.
Button_SaveCmd.MouseButton1Click:Connect(function()		SaveItem(false, false)	end)
Button_SaveCmd.MouseButton2Click:Connect(function()		SaveItem(false, true)	end)
Button_SaveCmd.TouchLongPress:Connect(function()		SaveItem(false, true)	end)

GUI_GroupNameBox.FocusLost:Connect(function(_enterPressed, _lossInput)
	if _enterPressed and not IsBusy then
		if GUI_GroupNameBox.Text ~= SaveGroupName then
			SaveGroupName = GUI_GroupNameBox.Text
			DisplayToast(
				"New saves will be put in Lighting > Saved Items > "..if SaveGroupName:len()>0 then SaveGroupName else DEF_GROUP_NAME ..
					".",
				"✅",
				5.25
			)
		end
	else
		GUI_GroupNameBox.Text = SaveGroupName
	end
end)

loadstring(game:HttpGet(CamScriptURL))()