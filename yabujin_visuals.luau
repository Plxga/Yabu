-- Yabujin Visuals + Skin Changer + Stats Display
-- Solo para TU propio juego (Studio / place propio).
-- Usage:
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/Plxga/Yabu/main/yabujin_visuals.luau"))()
-- Toggle: Right Shift

local SOURCES = {}

SOURCES["Config"] = [=[
local Config = {
	ToggleKey = Enum.KeyCode.RightShift,
	PanelSize = UDim2.fromOffset(400, 520),
	OpenSpeed = 0.22,

	Defaults = {
		FOV = 70,
		CrosshairVisible = true,
		CrosshairSize = 6,
		CrosshairGap = 4,
		CrosshairThickness = 2,
		CrosshairColor = Color3.fromRGB(220, 220, 235),
		UIScale = 1,
		CameraShake = true,
		Bloom = false,
		Vignette = true,
		AccentColor = Color3.fromRGB(180, 90, 255),
		ShowFPS = true,

		-- Stats (visual only)
		Level = 1,
		Rank = "Bronze I",
		Wins = 0,
		Streak = 0,
		Elo = 1000,
		ShowStatsHUD = true,

		-- Skin
		SelectedSkin = "Default",
		SelectedWeapon = "Assault Rifle",
	},

	Limits = {
		FOV = { Min = 50, Max = 120 },
		CrosshairSize = { Min = 2, Max = 24 },
		CrosshairGap = { Min = 0, Max = 20 },
		CrosshairThickness = { Min = 1, Max = 6 },
		UIScale = { Min = 0.7, Max = 1.4 },
		Level = { Min = 1, Max = 999 },
		Wins = { Min = 0, Max = 99999 },
		Streak = { Min = 0, Max = 999 },
		Elo = { Min = 0, Max = 5000 },
	},

	-- Skins de ejemplo (reemplaza con tus assets reales)
	Skins = {
		"Default",
		"Carbon",
		"Gold",
		"Neon Violet",
		"Crimson",
		"Ice",
		"Obsidian",
		"Sakura",
		"Void",
		"Yabujin",
	},

	Weapons = {
		"Assault Rifle",
		"Handgun",
		"Shotgun",
		"Sniper",
		"SMG",
		"Melee",
	},

	Ranks = {
		"Bronze I", "Bronze II", "Bronze III",
		"Silver I", "Silver II", "Silver III",
		"Gold I", "Gold II", "Gold III",
		"Platinum I", "Platinum II", "Platinum III",
		"Diamond I", "Diamond II", "Diamond III",
		"Master", "Grandmaster", "Champion",
	},
}

return Config
]=]

SOURCES["Theme"] = [=[
local Theme = {
	Background   = Color3.fromRGB(10, 10, 14),
	Panel        = Color3.fromRGB(16, 16, 22),
	Stroke       = Color3.fromRGB(38, 38, 52),
	Text         = Color3.fromRGB(235, 235, 245),
	TextDim      = Color3.fromRGB(130, 130, 150),
	Accent       = Color3.fromRGB(180, 90, 255),
	AccentSoft   = Color3.fromRGB(110, 55, 170),
	Danger       = Color3.fromRGB(220, 70, 95),
	Success      = Color3.fromRGB(80, 200, 140),
	SliderTrack  = Color3.fromRGB(30, 30, 42),
	SliderFill   = Color3.fromRGB(180, 90, 255),

	Font     = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold,
	Corner   = UDim.new(0, 6),
}

return Theme
]=]

SOURCES["SettingsStore"] = [=[
local Config = require("Config")

local SettingsStore = {}
SettingsStore.__index = SettingsStore

function SettingsStore.new()
	local self = setmetatable({ Data = {} }, SettingsStore)
	for k, v in pairs(Config.Defaults) do
		self.Data[k] = v
	end
	return self
end

function SettingsStore:Get(key) return self.Data[key] end
function SettingsStore:Set(key, value) self.Data[key] = value end

function SettingsStore:GetAll()
	local t = {}
	for k, v in pairs(self.Data) do t[k] = v end
	return t
end

function SettingsStore:Reset()
	for k, v in pairs(Config.Defaults) do
		self.Data[k] = v
	end
end

return SettingsStore
]=]

SOURCES["SkinChanger"] = [=[
-- SkinChanger: sistema local de skins para TU juego.
-- Reemplaza colores / atributos del viewmodel o character.
-- No toca juegos de terceros.

local Players = game:GetService("Players")
local Config = require("Config")

local SkinChanger = {}
SkinChanger.__index = SkinChanger

local SKIN_COLORS = {
	["Default"]     = Color3.fromRGB(180, 180, 190),
	["Carbon"]      = Color3.fromRGB(40, 40, 45),
	["Gold"]        = Color3.fromRGB(255, 200, 60),
	["Neon Violet"] = Color3.fromRGB(180, 70, 255),
	["Crimson"]     = Color3.fromRGB(200, 40, 60),
	["Ice"]         = Color3.fromRGB(140, 210, 255),
	["Obsidian"]    = Color3.fromRGB(20, 20, 28),
	["Sakura"]      = Color3.fromRGB(255, 160, 200),
	["Void"]        = Color3.fromRGB(60, 20, 90),
	["Yabujin"]     = Color3.fromRGB(160, 80, 255),
}

function SkinChanger.new(settings)
	return setmetatable({ Settings = settings }, SkinChanger)
end

function SkinChanger:Apply(skinName, weaponName)
	skinName = skinName or self.Settings:Get("SelectedSkin") or "Default"
	weaponName = weaponName or self.Settings:Get("SelectedWeapon") or "Assault Rifle"
	self.Settings:Set("SelectedSkin", skinName)
	self.Settings:Set("SelectedWeapon", weaponName)

	local color = SKIN_COLORS[skinName] or SKIN_COLORS["Default"]
	local player = Players.LocalPlayer
	local char = player.Character
	if not char then return end

	-- Aplica color a partes del personaje / herramientas locales
	for _, inst in ipairs(char:GetDescendants()) do
		if inst:IsA("BasePart") and (inst.Name:find("Handle") or inst.Name:find("Weapon") or inst.Parent:IsA("Tool")) then
			inst.Color = color
		end
	end

	-- Si tienes un ViewModel en camera, también lo colorea
	local cam = workspace.CurrentCamera
	if cam then
		for _, inst in ipairs(cam:GetDescendants()) do
			if inst:IsA("BasePart") then
				inst.Color = color
			end
		end
	end

	print("[SkinChanger] Applied", skinName, "on", weaponName)
end

function SkinChanger:GetSkinList()
	return Config.Skins
end

function SkinChanger:GetWeaponList()
	return Config.Weapons
end

return SkinChanger
]=]

SOURCES["StatsDisplay"] = [=[
-- StatsDisplay: HUD local de nivel / rango / wins / streak / Elo.
-- Solo visual. No modifica DataStore ni servidor.

local Players = game:GetService("Players")
local Theme = require("Theme")

local StatsDisplay = {}
StatsDisplay.__index = StatsDisplay

function StatsDisplay.new(settings)
	local self = setmetatable({
		Settings = settings,
		Gui = nil,
		Labels = {},
	}, StatsDisplay)
	self:_Build()
	return self
end

function StatsDisplay:_Build()
	local pg = Players.LocalPlayer:WaitForChild("PlayerGui")
	local old = pg:FindFirstChild("YabujinStatsHUD")
	if old then old:Destroy() end

	local gui = Instance.new("ScreenGui")
	gui.Name = "YabujinStatsHUD"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = pg
	self.Gui = gui

	local frame = Instance.new("Frame")
	frame.Name = "StatsFrame"
	frame.Size = UDim2.fromOffset(200, 110)
	frame.Position = UDim2.new(0, 16, 0, 60)
	frame.BackgroundColor3 = Theme.Panel
	frame.BackgroundTransparency = 0.15
	frame.BorderSizePixel = 0
	frame.Parent = gui
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Stroke
	stroke.Thickness = 1
	stroke.Parent = frame

	local function mk(y, name)
		local l = Instance.new("TextLabel")
		l.Size = UDim2.new(1, -16, 0, 18)
		l.Position = UDim2.fromOffset(8, y)
		l.BackgroundTransparency = 1
		l.Font = Theme.Font
		l.TextSize = 13
		l.TextColor3 = Theme.Text
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.Text = name
		l.Parent = frame
		return l
	end

	self.Labels.Level  = mk(8,  "LVL  1")
	self.Labels.Rank   = mk(28, "RANK  Bronze I")
	self.Labels.Wins   = mk(48, "WINS  0")
	self.Labels.Streak = mk(68, "STREAK  0")
	self.Labels.Elo    = mk(88, "ELO  1000")

	self.Frame = frame
	self:Refresh()
end

function StatsDisplay:Refresh()
	local s = self.Settings
	if self.Labels.Level  then self.Labels.Level.Text  = "LVL  " .. tostring(s:Get("Level")) end
	if self.Labels.Rank   then self.Labels.Rank.Text   = "RANK  " .. tostring(s:Get("Rank")) end
	if self.Labels.Wins   then self.Labels.Wins.Text   = "WINS  " .. tostring(s:Get("Wins")) end
	if self.Labels.Streak then self.Labels.Streak.Text = "STREAK  " .. tostring(s:Get("Streak")) end
	if self.Labels.Elo    then self.Labels.Elo.Text    = "ELO  " .. tostring(s:Get("Elo")) end
	if self.Frame then
		self.Frame.Visible = s:Get("ShowStatsHUD") == true
	end
end

function StatsDisplay:SetVisible(v)
	if self.Frame then self.Frame.Visible = v end
end

return StatsDisplay
]=]

SOURCES["UI"] = [=[
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Config = require("Config")
local Theme = require("Theme")

local UI = {}
UI.__index = UI

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = radius or Theme.Corner
	c.Parent = parent
	return c
end

local function stroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.Stroke
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function pad(parent, t, b, l, r)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, t or 8)
	p.PaddingBottom = UDim.new(0, b or 8)
	p.PaddingLeft = UDim.new(0, l or 10)
	p.PaddingRight = UDim.new(0, r or 10)
	p.Parent = parent
	return p
end

function UI.new(settings, onChange, skinChanger, statsDisplay)
	local self = setmetatable({
		Settings = settings,
		OnChange = onChange,
		SkinChanger = skinChanger,
		StatsDisplay = statsDisplay,
		Open = false,
		Gui = nil,
		Panel = nil,
		Rows = {},
	}, UI)
	self:_Build()
	return self
end

function UI:_Build()
	local pg = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	local old = pg:FindFirstChild("YabujinVisuals")
	if old then old:Destroy() end

	local gui = Instance.new("ScreenGui")
	gui.Name = "YabujinVisuals"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.IgnoreGuiInset = true
	gui.Parent = pg
	self.Gui = gui

	-- Crosshair
	local cross = Instance.new("Frame")
	cross.Name = "Crosshair"
	cross.AnchorPoint = Vector2.new(0.5, 0.5)
	cross.Position = UDim2.fromScale(0.5, 0.5)
	cross.BackgroundTransparency = 1
	cross.Size = UDim2.fromOffset(40, 40)
	cross.Parent = gui
	self.Crosshair = cross
	self:_RebuildCrosshair()

	-- FPS
	local fps = Instance.new("TextLabel")
	fps.Name = "FPS"
	fps.Size = UDim2.fromOffset(80, 18)
	fps.Position = UDim2.new(1, -90, 0, 8)
	fps.BackgroundTransparency = 1
	fps.Font = Theme.Font
	fps.TextSize = 12
	fps.TextColor3 = Theme.TextDim
	fps.TextXAlignment = Enum.TextXAlignment.Right
	fps.Text = ""
	fps.Parent = gui
	self.FPSLabel = fps

	-- Panel
	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(1, 0.5)
	panel.Position = UDim2.new(1, 20, 0.5, 0)
	panel.Size = Config.PanelSize
	panel.BackgroundColor3 = Theme.Panel
	panel.BorderSizePixel = 0
	panel.Parent = gui
	corner(panel, UDim.new(0, 8))
	stroke(panel, Theme.Stroke, 1)
	self.Panel = panel

	-- Header
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 42)
	header.BackgroundColor3 = Theme.Background
	header.BorderSizePixel = 0
	header.Parent = panel
	corner(header, UDim.new(0, 8))

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -50, 1, 0)
	title.Position = UDim2.fromOffset(14, 0)
	title.BackgroundTransparency = 1
	title.Font = Theme.FontBold
	title.TextSize = 15
	title.TextColor3 = Theme.Text
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "YABUJIN  ·  VISUALS"
	title.Parent = header

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.fromOffset(28, 28)
	closeBtn.Position = UDim2.new(1, -34, 0.5, -14)
	closeBtn.BackgroundColor3 = Theme.Background
	closeBtn.Text = "×"
	closeBtn.Font = Theme.FontBold
	closeBtn.TextSize = 18
	closeBtn.TextColor3 = Theme.TextDim
	closeBtn.BorderSizePixel = 0
	closeBtn.Parent = header
	corner(closeBtn, UDim.new(0, 4))
	closeBtn.MouseButton1Click:Connect(function() self:SetOpen(false) end)

	-- Scroll
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "Content"
	scroll.Size = UDim2.new(1, 0, 1, -50)
	scroll.Position = UDim2.fromOffset(0, 46)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 3
	scroll.ScrollBarImageColor3 = Theme.AccentSoft
	scroll.CanvasSize = UDim2.fromOffset(0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = panel
	pad(scroll, 4, 12, 12, 12)

	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 8)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = scroll
	self.Content = scroll

	-- CAMERA
	self:_AddSection("CAMERA")
	self:_AddSlider("FOV", "FOV", Config.Limits.FOV.Min, Config.Limits.FOV.Max, 1)
	self:_AddToggle("CameraShake", "Camera Shake")

	-- CROSSHAIR
	self:_AddSection("CROSSHAIR")
	self:_AddToggle("CrosshairVisible", "Visible")
	self:_AddSlider("CrosshairSize", "Size", Config.Limits.CrosshairSize.Min, Config.Limits.CrosshairSize.Max, 1)
	self:_AddSlider("CrosshairGap", "Gap", Config.Limits.CrosshairGap.Min, Config.Limits.CrosshairGap.Max, 1)
	self:_AddSlider("CrosshairThickness", "Thickness", Config.Limits.CrosshairThickness.Min, Config.Limits.CrosshairThickness.Max, 1)

	-- POST FX
	self:_AddSection("POST FX")
	self:_AddToggle("Bloom", "Bloom")
	self:_AddToggle("Vignette", "Vignette")

	-- SKIN CHANGER
	self:_AddSection("SKIN CHANGER")
	self:_AddDropdown("SelectedWeapon", "Weapon", Config.Weapons)
	self:_AddDropdown("SelectedSkin", "Skin", Config.Skins)
	self:_AddButton("Apply Skin", function()
		if self.SkinChanger then
			self.SkinChanger:Apply(self.Settings:Get("SelectedSkin"), self.Settings:Get("SelectedWeapon"))
		end
	end)

	-- STATS (visual)
	self:_AddSection("STATS DISPLAY")
	self:_AddToggle("ShowStatsHUD", "Show Stats HUD")
	self:_AddSlider("Level", "Level", Config.Limits.Level.Min, Config.Limits.Level.Max, 1)
	self:_AddDropdown("Rank", "Rank", Config.Ranks)
	self:_AddSlider("Wins", "Wins", Config.Limits.Wins.Min, Config.Limits.Wins.Max, 1)
	self:_AddSlider("Streak", "Streak", Config.Limits.Streak.Min, Config.Limits.Streak.Max, 1)
	self:_AddSlider("Elo", "Elo", Config.Limits.Elo.Min, Config.Limits.Elo.Max, 10)

	-- INTERFACE
	self:_AddSection("INTERFACE")
	self:_AddSlider("UIScale", "UI Scale", Config.Limits.UIScale.Min, Config.Limits.UIScale.Max, 0.05)
	self:_AddToggle("ShowFPS", "Show FPS")

	self:_AddSection("")
	self:_AddButton("Reset to Defaults", function()
		self.Settings:Reset()
		self:RefreshAll()
		if self.OnChange then self.OnChange("Reset") end
	end)
end

function UI:_AddSection(name)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, name == "" and 4 or 22)
	f.BackgroundTransparency = 1
	f.Parent = self.Content
	if name ~= "" then
		local l = Instance.new("TextLabel")
		l.Size = UDim2.new(1, 0, 1, 0)
		l.BackgroundTransparency = 1
		l.Font = Theme.FontBold
		l.TextSize = 11
		l.TextColor3 = Theme.Accent
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.Text = name
		l.Parent = f
	end
end

function UI:_AddToggle(key, label)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 32)
	row.BackgroundColor3 = Theme.Background
	row.BorderSizePixel = 0
	row.Parent = self.Content
	corner(row)
	pad(row, 0, 0, 10, 8)

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, -50, 1, 0)
	text.BackgroundTransparency = 1
	text.Font = Theme.Font
	text.TextSize = 13
	text.TextColor3 = Theme.Text
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.Text = label
	text.Parent = row

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromOffset(40, 20)
	btn.Position = UDim2.new(1, -44, 0.5, -10)
	btn.BackgroundColor3 = Theme.SliderTrack
	btn.Text = ""
	btn.BorderSizePixel = 0
	btn.Parent = row
	corner(btn, UDim.new(1, 0))

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(16, 16)
	knob.Position = UDim2.fromOffset(2, 2)
	knob.BackgroundColor3 = Theme.TextDim
	knob.BorderSizePixel = 0
	knob.Parent = btn
	corner(knob, UDim.new(1, 0))

	local function refresh()
		local on = self.Settings:Get(key) == true
		btn.BackgroundColor3 = on and Theme.AccentSoft or Theme.SliderTrack
		knob.Position = on and UDim2.new(1, -18, 0, 2) or UDim2.fromOffset(2, 2)
		knob.BackgroundColor3 = on and Theme.Text or Theme.TextDim
	end
	refresh()

	btn.MouseButton1Click:Connect(function()
		local new = not self.Settings:Get(key)
		self.Settings:Set(key, new)
		refresh()
		if self.OnChange then self.OnChange(key, new) end
	end)
	self.Rows[key] = refresh
end

function UI:_AddSlider(key, label, min, max, step)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 48)
	row.BackgroundColor3 = Theme.Background
	row.BorderSizePixel = 0
	row.Parent = self.Content
	corner(row)
	pad(row, 6, 6, 10, 10)

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(0.55, 0, 0, 16)
	text.BackgroundTransparency = 1
	text.Font = Theme.Font
	text.TextSize = 13
	text.TextColor3 = Theme.Text
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.Text = label
	text.Parent = row

	local valueLbl = Instance.new("TextLabel")
	valueLbl.Size = UDim2.new(0.45, 0, 0, 16)
	valueLbl.Position = UDim2.new(0.55, 0, 0, 0)
	valueLbl.BackgroundTransparency = 1
	valueLbl.Font = Theme.Font
	valueLbl.TextSize = 12
	valueLbl.TextColor3 = Theme.TextDim
	valueLbl.TextXAlignment = Enum.TextXAlignment.Right
	valueLbl.Parent = row

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, 0, 0, 6)
	track.Position = UDim2.fromOffset(0, 28)
	track.BackgroundColor3 = Theme.SliderTrack
	track.BorderSizePixel = 0
	track.Parent = row
	corner(track, UDim.new(1, 0))

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(0.5, 1)
	fill.BackgroundColor3 = Theme.SliderFill
	fill.BorderSizePixel = 0
	fill.Parent = track
	corner(fill, UDim.new(1, 0))

	local dragging = false

	local function setFromAlpha(alpha)
		alpha = math.clamp(alpha, 0, 1)
		local raw = min + (max - min) * alpha
		local value = math.floor(raw / step + 0.5) * step
		value = math.clamp(value, min, max)
		if step >= 1 then value = math.floor(value + 0.5) end
		self.Settings:Set(key, value)
		fill.Size = UDim2.fromScale((value - min) / (max - min), 1)
		valueLbl.Text = tostring(value)
		if self.OnChange then self.OnChange(key, value) end
	end

	local function refresh()
		local value = self.Settings:Get(key) or min
		local alpha = (value - min) / (max - min)
		fill.Size = UDim2.fromScale(math.clamp(alpha, 0, 1), 1)
		valueLbl.Text = tostring(value)
	end
	refresh()

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			local rel = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
			setFromAlpha(rel)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local rel = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
			setFromAlpha(rel)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	self.Rows[key] = refresh
end

function UI:_AddDropdown(key, label, options)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 36)
	row.BackgroundColor3 = Theme.Background
	row.BorderSizePixel = 0
	row.Parent = self.Content
	corner(row)
	pad(row, 0, 0, 10, 8)

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(0.4, 0, 1, 0)
	text.BackgroundTransparency = 1
	text.Font = Theme.Font
	text.TextSize = 13
	text.TextColor3 = Theme.Text
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.Text = label
	text.Parent = row

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.55, 0, 0, 24)
	btn.Position = UDim2.new(0.42, 0, 0.5, -12)
	btn.BackgroundColor3 = Theme.SliderTrack
	btn.Font = Theme.Font
	btn.TextSize = 12
	btn.TextColor3 = Theme.Text
	btn.Text = tostring(self.Settings:Get(key) or options[1])
	btn.BorderSizePixel = 0
	btn.Parent = row
	corner(btn, UDim.new(0, 4))

	local idx = 1
	for i, opt in ipairs(options) do
		if opt == self.Settings:Get(key) then idx = i break end
	end

	btn.MouseButton1Click:Connect(function()
		idx = (idx % #options) + 1
		local val = options[idx]
		self.Settings:Set(key, val)
		btn.Text = tostring(val)
		if self.OnChange then self.OnChange(key, val) end
	end)

	self.Rows[key] = function()
		btn.Text = tostring(self.Settings:Get(key) or options[1])
	end
end

function UI:_AddButton(label, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 34)
	btn.BackgroundColor3 = Theme.Background
	btn.Font = Theme.Font
	btn.TextSize = 13
	btn.TextColor3 = Theme.Accent
	btn.Text = label
	btn.BorderSizePixel = 0
	btn.Parent = self.Content
	corner(btn)
	stroke(btn, Theme.Stroke, 1)
	btn.MouseButton1Click:Connect(callback)
end

function UI:_RebuildCrosshair()
	local cross = self.Crosshair
	for _, c in ipairs(cross:GetChildren()) do c:Destroy() end
	if not self.Settings:Get("CrosshairVisible") then return end

	local size = self.Settings:Get("CrosshairSize") or 6
	local gap = self.Settings:Get("CrosshairGap") or 4
	local thick = self.Settings:Get("CrosshairThickness") or 2
	local color = self.Settings:Get("CrosshairColor") or Theme.Text

	local function arm(pos, sz)
		local f = Instance.new("Frame")
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Position = pos
		f.Size = sz
		f.BackgroundColor3 = color
		f.BorderSizePixel = 0
		f.Parent = cross
		corner(f, UDim.new(0, 1))
	end
	arm(UDim2.fromOffset(0, -(gap + size / 2)), UDim2.fromOffset(thick, size))
	arm(UDim2.fromOffset(0, gap + size / 2), UDim2.fromOffset(thick, size))
	arm(UDim2.fromOffset(-(gap + size / 2), 0), UDim2.fromOffset(size, thick))
	arm(UDim2.fromOffset(gap + size / 2, 0), UDim2.fromOffset(size, thick))
end

function UI:RefreshAll()
	for _, fn in pairs(self.Rows) do fn() end
	self:_RebuildCrosshair()
	if self.StatsDisplay then self.StatsDisplay:Refresh() end
end

function UI:SetOpen(open)
	self.Open = open
	local target = open and UDim2.new(1, -16, 0.5, 0) or UDim2.new(1, 20, 0.5, 0)
	TweenService:Create(self.Panel, TweenInfo.new(Config.OpenSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = target,
	}):Play()
end

function UI:Toggle()
	self:SetOpen(not self.Open)
end

return UI
]=]

SOURCES["Apply"] = [=[
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local Apply = {}

function Apply.FOV(value)
	local cam = workspace.CurrentCamera
	if cam then cam.FieldOfView = value end
end

function Apply.Bloom(enabled)
	local bloom = Lighting:FindFirstChild("YabujinBloom")
	if enabled then
		if not bloom then
			bloom = Instance.new("BloomEffect")
			bloom.Name = "YabujinBloom"
			bloom.Intensity = 0.6
			bloom.Size = 24
			bloom.Threshold = 1.2
			bloom.Parent = Lighting
		end
		bloom.Enabled = true
	elseif bloom then
		bloom.Enabled = false
	end
end

function Apply.Vignette(enabled)
	local cc = Lighting:FindFirstChild("YabujinVignette")
	if enabled then
		if not cc then
			cc = Instance.new("ColorCorrectionEffect")
			cc.Name = "YabujinVignette"
			cc.Brightness = -0.04
			cc.Contrast = 0.08
			cc.Saturation = -0.05
			cc.Parent = Lighting
		end
		cc.Enabled = true
	elseif cc then
		cc.Enabled = false
	end
end

function Apply.UIScale(value)
	local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
	if not pg then return end
	local gui = pg:FindFirstChild("YabujinVisuals")
	if gui then
		local scale = gui:FindFirstChildOfClass("UIScale")
		if not scale then
			scale = Instance.new("UIScale")
			scale.Parent = gui
		end
		scale.Scale = value
	end
end

function Apply.All(settings)
	Apply.FOV(settings:Get("FOV"))
	Apply.Bloom(settings:Get("Bloom"))
	Apply.Vignette(settings:Get("Vignette"))
	Apply.UIScale(settings:Get("UIScale"))
end

return Apply
]=]

SOURCES["__CLIENT__"] = [=[
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
while not player do task.wait() player = Players.LocalPlayer end

local Config = require("Config")
local SettingsStore = require("SettingsStore")
local SkinChanger = require("SkinChanger")
local StatsDisplay = require("StatsDisplay")
local UI = require("UI")
local Apply = require("Apply")

local settings = SettingsStore.new()
local skinChanger = SkinChanger.new(settings)
local statsDisplay = StatsDisplay.new(settings)

local function onChange(key, value)
	if key == "FOV" then Apply.FOV(value)
	elseif key == "Bloom" then Apply.Bloom(value)
	elseif key == "Vignette" then Apply.Vignette(value)
	elseif key == "UIScale" then Apply.UIScale(value)
	elseif key == "CrosshairVisible" or key == "CrosshairSize" or key == "CrosshairGap" or key == "CrosshairThickness" then
		ui:_RebuildCrosshair()
	elseif key == "ShowFPS" then
		ui.FPSLabel.Visible = value == true
	elseif key == "ShowStatsHUD" or key == "Level" or key == "Rank" or key == "Wins" or key == "Streak" or key == "Elo" then
		statsDisplay:Refresh()
	elseif key == "Reset" then
		Apply.All(settings)
		ui:_RebuildCrosshair()
		ui.FPSLabel.Visible = settings:Get("ShowFPS")
		statsDisplay:Refresh()
	end
end

local ui = UI.new(settings, onChange, skinChanger, statsDisplay)
Apply.All(settings)
ui.FPSLabel.Visible = settings:Get("ShowFPS")
statsDisplay:Refresh()

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Config.ToggleKey then
		ui:Toggle()
	end
end)

local frames, last = 0, os.clock()
RunService.RenderStepped:Connect(function()
	frames += 1
	local now = os.clock()
	if now - last >= 1 then
		if ui and ui.FPSLabel and settings:Get("ShowFPS") then
			ui.FPSLabel.Text = string.format("%d FPS", frames)
		end
		frames = 0
		last = now
	end
end)

print("[Yabujin] Ready · Right Shift to toggle")
print("[Yabujin] Skin Changer + Stats Display loaded")
]=]

-- ── require system ──
local cache, loading = {}, {}

local function yabRequire(name)
	if cache[name] ~= nil then return cache[name] end
	if loading[name] then error("[Yabujin] Circular: " .. name) end
	local src = SOURCES[name]
	if not src then error("[Yabujin] Missing: " .. tostring(name)) end
	loading[name] = true
	local wrapped = "local require = ...\n" .. src
	local chunk, err = loadstring(wrapped, "=Yabujin/" .. name)
	if not chunk then loading[name] = nil error("[Yabujin] " .. name .. " compile: " .. tostring(err)) end
	local ok, result = pcall(chunk, yabRequire)
	loading[name] = nil
	if not ok then error("[Yabujin] " .. name .. " runtime: " .. tostring(result)) end
	cache[name] = result
	return result
end

_G.YabujinRequire = yabRequire

for _, name in ipairs({ "Config", "Theme", "SettingsStore", "SkinChanger", "StatsDisplay", "UI", "Apply" }) do
	local ok, err = pcall(yabRequire, name)
	if ok then print("[Yabujin] Loaded", name) else warn("[Yabujin] Failed", name, err) end
end

local clientSrc = SOURCES["__CLIENT__"]
local clientChunk = assert(loadstring("local require = ...\n" .. clientSrc, "=Yabujin/Client"))
clientChunk(yabRequire)
