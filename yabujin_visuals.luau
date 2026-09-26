-- Yabujin Visuals (fixed)
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Plxga/Yabu/main/yabujin_visuals.luau"))()
-- Toggle: RightShift  |  also opens automatically on load

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = player:WaitForChild("PlayerGui")

-- ── Settings ──
local settings = {
	FOV = 70,
	CrosshairVisible = true,
	CrosshairSize = 6,
	CrosshairGap = 4,
	CrosshairThickness = 2,
	Bloom = false,
	Vignette = true,
	ShowFPS = true,
	ShowStatsHUD = true,
	Level = 12,
	Rank = "Gold II",
	Wins = 48,
	Streak = 3,
	Elo = 1340,
	SelectedSkin = "Neon Violet",
	SelectedWeapon = "Assault Rifle",
}

local SKINS = { "Default", "Carbon", "Gold", "Neon Violet", "Crimson", "Ice", "Obsidian", "Sakura", "Void", "Yabujin" }
local WEAPONS = { "Assault Rifle", "Handgun", "Shotgun", "Sniper", "SMG", "Melee" }
local RANKS = {
	"Bronze I","Bronze II","Bronze III",
	"Silver I","Silver II","Silver III",
	"Gold I","Gold II","Gold III",
	"Platinum I","Platinum II","Platinum III",
	"Diamond I","Diamond II","Diamond III",
	"Master","Grandmaster","Champion",
}
local SKIN_COLORS = {
	["Default"] = Color3.fromRGB(180,180,190),
	["Carbon"] = Color3.fromRGB(40,40,45),
	["Gold"] = Color3.fromRGB(255,200,60),
	["Neon Violet"] = Color3.fromRGB(180,70,255),
	["Crimson"] = Color3.fromRGB(200,40,60),
	["Ice"] = Color3.fromRGB(140,210,255),
	["Obsidian"] = Color3.fromRGB(20,20,28),
	["Sakura"] = Color3.fromRGB(255,160,200),
	["Void"] = Color3.fromRGB(60,20,90),
	["Yabujin"] = Color3.fromRGB(160,80,255),
}

local Theme = {
	Bg = Color3.fromRGB(10,10,14),
	Panel = Color3.fromRGB(16,16,22),
	Stroke = Color3.fromRGB(40,40,55),
	Text = Color3.fromRGB(235,235,245),
	Dim = Color3.fromRGB(130,130,150),
	Accent = Color3.fromRGB(180,90,255),
	AccentSoft = Color3.fromRGB(110,55,170),
	Track = Color3.fromRGB(30,30,42),
}

-- ── helpers ──
local function corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 6)
	c.Parent = p
end
local function stroke(p, col, th)
	local s = Instance.new("UIStroke")
	s.Color = col or Theme.Stroke
	s.Thickness = th or 1
	s.Parent = p
end

-- ── clean old ──
for _, name in ipairs({ "YabujinVisuals", "YabujinStatsHUD" }) do
	local old = playerGui:FindFirstChild(name)
	if old then old:Destroy() end
end

-- ── Stats HUD ──
local statsGui = Instance.new("ScreenGui")
statsGui.Name = "YabujinStatsHUD"
statsGui.ResetOnSpawn = false
statsGui.IgnoreGuiInset = true
statsGui.Parent = playerGui

local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.fromOffset(190, 112)
statsFrame.Position = UDim2.fromOffset(14, 54)
statsFrame.BackgroundColor3 = Theme.Panel
statsFrame.BackgroundTransparency = 0.12
statsFrame.BorderSizePixel = 0
statsFrame.Parent = statsGui
corner(statsFrame, 6)
stroke(statsFrame)

local function mkStat(y)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -14, 0, 18)
	l.Position = UDim2.fromOffset(8, y)
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.GothamMedium
	l.TextSize = 13
	l.TextColor3 = Theme.Text
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = statsFrame
	return l
end
local lblLevel  = mkStat(6)
local lblRank   = mkStat(26)
local lblWins   = mkStat(46)
local lblStreak = mkStat(66)
local lblElo    = mkStat(86)

local function refreshStats()
	lblLevel.Text  = "LVL   " .. tostring(settings.Level)
	lblRank.Text   = "RANK  " .. tostring(settings.Rank)
	lblWins.Text   = "WINS  " .. tostring(settings.Wins)
	lblStreak.Text = "STREAK  " .. tostring(settings.Streak)
	lblElo.Text    = "ELO   " .. tostring(settings.Elo)
	statsFrame.Visible = settings.ShowStatsHUD
end
refreshStats()

-- ── Main GUI ──
local gui = Instance.new("ScreenGui")
gui.Name = "YabujinVisuals"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- Crosshair
local cross = Instance.new("Frame")
cross.Name = "Crosshair"
cross.AnchorPoint = Vector2.new(0.5, 0.5)
cross.Position = UDim2.fromScale(0.5, 0.5)
cross.Size = UDim2.fromOffset(50, 50)
cross.BackgroundTransparency = 1
cross.Parent = gui

local function rebuildCrosshair()
	for _, c in ipairs(cross:GetChildren()) do c:Destroy() end
	if not settings.CrosshairVisible then return end
	local size, gap, thick = settings.CrosshairSize, settings.CrosshairGap, settings.CrosshairThickness
	local function arm(pos, sz)
		local f = Instance.new("Frame")
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Position = pos
		f.Size = sz
		f.BackgroundColor3 = Color3.fromRGB(230, 230, 240)
		f.BorderSizePixel = 0
		f.Parent = cross
		corner(f, 1)
	end
	arm(UDim2.fromOffset(0, -(gap + size/2)), UDim2.fromOffset(thick, size))
	arm(UDim2.fromOffset(0, gap + size/2), UDim2.fromOffset(thick, size))
	arm(UDim2.fromOffset(-(gap + size/2), 0), UDim2.fromOffset(size, thick))
	arm(UDim2.fromOffset(gap + size/2, 0), UDim2.fromOffset(size, thick))
end
rebuildCrosshair()

-- FPS
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.fromOffset(80, 16)
fpsLabel.Position = UDim2.new(1, -90, 0, 8)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Font = Enum.Font.GothamMedium
fpsLabel.TextSize = 12
fpsLabel.TextColor3 = Theme.Dim
fpsLabel.TextXAlignment = Enum.TextXAlignment.Right
fpsLabel.Text = ""
fpsLabel.Parent = gui

-- Panel
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(1, 0.5)
panel.Position = UDim2.new(1, -16, 0.5, 0) -- start OPEN
panel.Size = UDim2.fromOffset(390, 500)
panel.BackgroundColor3 = Theme.Panel
panel.BorderSizePixel = 0
panel.Parent = gui
corner(panel, 8)
stroke(panel)

local open = true
local function setOpen(v)
	open = v
	local target = v and UDim2.new(1, -16, 0.5, 0) or UDim2.new(1, 24, 0.5, 0)
	TweenService:Create(panel, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = target
	}):Play()
end

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Theme.Bg
header.BorderSizePixel = 0
header.Parent = panel
corner(header, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.fromOffset(14, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Theme.Text
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "YABUJIN  ·  VISUALS"
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(28, 28)
closeBtn.Position = UDim2.new(1, -34, 0.5, -14)
closeBtn.BackgroundColor3 = Theme.Bg
closeBtn.Text = "×"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = Theme.Dim
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header
corner(closeBtn, 4)
closeBtn.MouseButton1Click:Connect(function() setOpen(false) end)

-- Scroll
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, -48)
scroll.Position = UDim2.fromOffset(0, 44)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Theme.AccentSoft
scroll.CanvasSize = UDim2.fromOffset(0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = panel

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 6)
pad.PaddingBottom = UDim.new(0, 14)
pad.PaddingLeft = UDim.new(0, 12)
pad.PaddingRight = UDim.new(0, 12)
pad.Parent = scroll

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 7)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = scroll

-- UI builders
local function addSection(name)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, 20)
	f.BackgroundTransparency = 1
	f.Parent = scroll
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 1, 0)
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.GothamBold
	l.TextSize = 11
	l.TextColor3 = Theme.Accent
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Text = name
	l.Parent = f
end

local function addToggle(key, label, onChanged)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundColor3 = Theme.Bg
	row.BorderSizePixel = 0
	row.Parent = scroll
	corner(row)

	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, -50, 1, 0)
	t.Position = UDim2.fromOffset(10, 0)
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.GothamMedium
	t.TextSize = 13
	t.TextColor3 = Theme.Text
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Text = label
	t.Parent = row

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromOffset(40, 20)
	btn.Position = UDim2.new(1, -46, 0.5, -10)
	btn.BackgroundColor3 = Theme.Track
	btn.Text = ""
	btn.BorderSizePixel = 0
	btn.Parent = row
	corner(btn, 10)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(16, 16)
	knob.Position = UDim2.fromOffset(2, 2)
	knob.BackgroundColor3 = Theme.Dim
	knob.BorderSizePixel = 0
	knob.Parent = btn
	corner(knob, 8)

	local function refresh()
		local on = settings[key] == true
		btn.BackgroundColor3 = on and Theme.AccentSoft or Theme.Track
		knob.Position = on and UDim2.new(1, -18, 0, 2) or UDim2.fromOffset(2, 2)
		knob.BackgroundColor3 = on and Theme.Text or Theme.Dim
	end
	refresh()

	btn.MouseButton1Click:Connect(function()
		settings[key] = not settings[key]
		refresh()
		if onChanged then onChanged(settings[key]) end
	end)
end

local function addSlider(key, label, min, max, step, onChanged)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 46)
	row.BackgroundColor3 = Theme.Bg
	row.BorderSizePixel = 0
	row.Parent = scroll
	corner(row)

	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(0.55, 0, 0, 16)
	t.Position = UDim2.fromOffset(10, 6)
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.GothamMedium
	t.TextSize = 13
	t.TextColor3 = Theme.Text
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Text = label
	t.Parent = row

	local val = Instance.new("TextLabel")
	val.Size = UDim2.new(0.4, 0, 0, 16)
	val.Position = UDim2.new(0.55, 0, 0, 6)
	val.BackgroundTransparency = 1
	val.Font = Enum.Font.GothamMedium
	val.TextSize = 12
	val.TextColor3 = Theme.Dim
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Parent = row

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -20, 0, 6)
	track.Position = UDim2.fromOffset(10, 30)
	track.BackgroundColor3 = Theme.Track
	track.BorderSizePixel = 0
	track.Parent = row
	corner(track, 3)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(0.5, 1)
	fill.BackgroundColor3 = Theme.Accent
	fill.BorderSizePixel = 0
	fill.Parent = track
	corner(fill, 3)

	local dragging = false
	local function apply(alpha)
		alpha = math.clamp(alpha, 0, 1)
		local raw = min + (max - min) * alpha
		local v = math.floor(raw / step + 0.5) * step
		v = math.clamp(v, min, max)
		if step >= 1 then v = math.floor(v + 0.5) end
		settings[key] = v
		fill.Size = UDim2.fromScale((v - min) / (max - min), 1)
		val.Text = tostring(v)
		if onChanged then onChanged(v) end
	end
	apply((settings[key] - min) / (max - min))

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			apply((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1))
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			apply((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1))
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

local function addDropdown(key, label, options, onChanged)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 34)
	row.BackgroundColor3 = Theme.Bg
	row.BorderSizePixel = 0
	row.Parent = scroll
	corner(row)

	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(0.38, 0, 1, 0)
	t.Position = UDim2.fromOffset(10, 0)
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.GothamMedium
	t.TextSize = 13
	t.TextColor3 = Theme.Text
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Text = label
	t.Parent = row

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.55, 0, 0, 24)
	btn.Position = UDim2.new(0.42, 0, 0.5, -12)
	btn.BackgroundColor3 = Theme.Track
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 12
	btn.TextColor3 = Theme.Text
	btn.Text = tostring(settings[key] or options[1])
	btn.BorderSizePixel = 0
	btn.Parent = row
	corner(btn, 4)

	local idx = 1
	for i, o in ipairs(options) do
		if o == settings[key] then idx = i break end
	end
	btn.MouseButton1Click:Connect(function()
		idx = (idx % #options) + 1
		settings[key] = options[idx]
		btn.Text = tostring(options[idx])
		if onChanged then onChanged(options[idx]) end
	end)
end

local function addButton(label, color, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.BackgroundColor3 = Theme.Bg
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 13
	btn.TextColor3 = color or Theme.Accent
	btn.Text = label
	btn.BorderSizePixel = 0
	btn.Parent = scroll
	corner(btn)
	stroke(btn)
	btn.MouseButton1Click:Connect(callback)
end

-- ── Apply helpers ──
local function applyFOV(v)
	local cam = workspace.CurrentCamera
	if cam then cam.FieldOfView = v end
end
local function applyBloom(on)
	local b = Lighting:FindFirstChild("YabujinBloom")
	if on then
		if not b then
			b = Instance.new("BloomEffect")
			b.Name = "YabujinBloom"
			b.Intensity = 0.55
			b.Size = 22
			b.Threshold = 1.1
			b.Parent = Lighting
		end
		b.Enabled = true
	elseif b then b.Enabled = false end
end
local function applyVignette(on)
	local c = Lighting:FindFirstChild("YabujinVignette")
	if on then
		if not c then
			c = Instance.new("ColorCorrectionEffect")
			c.Name = "YabujinVignette"
			c.Brightness = -0.04
			c.Contrast = 0.08
			c.Saturation = -0.04
			c.Parent = Lighting
		end
		c.Enabled = true
	elseif c then c.Enabled = false end
end
local function applySkin()
	local color = SKIN_COLORS[settings.SelectedSkin] or SKIN_COLORS.Default
	local char = player.Character
	if char then
		for _, inst in ipairs(char:GetDescendants()) do
			if inst:IsA("BasePart") and (inst.Name:lower():find("handle") or inst.Parent:IsA("Tool")) then
				inst.Color = color
			end
		end
	end
	local cam = workspace.CurrentCamera
	if cam then
		for _, inst in ipairs(cam:GetDescendants()) do
			if inst:IsA("BasePart") then inst.Color = color end
		end
	end
	print("[Yabujin] Skin applied:", settings.SelectedSkin, "→", settings.SelectedWeapon)
end

-- ── Build sections ──
addSection("CAMERA")
addSlider("FOV", "FOV", 50, 120, 1, applyFOV)
addToggle("CameraShake", "Camera Shake")

addSection("CROSSHAIR")
addToggle("CrosshairVisible", "Visible", function() rebuildCrosshair() end)
addSlider("CrosshairSize", "Size", 2, 24, 1, function() rebuildCrosshair() end)
addSlider("CrosshairGap", "Gap", 0, 20, 1, function() rebuildCrosshair() end)
addSlider("CrosshairThickness", "Thickness", 1, 6, 1, function() rebuildCrosshair() end)

addSection("POST FX")
addToggle("Bloom", "Bloom", applyBloom)
addToggle("Vignette", "Vignette", applyVignette)

addSection("SKIN CHANGER")
addDropdown("SelectedWeapon", "Weapon", WEAPONS)
addDropdown("SelectedSkin", "Skin", SKINS)
addButton("Apply Skin", Theme.Accent, applySkin)

addSection("STATS DISPLAY")
addToggle("ShowStatsHUD", "Show Stats HUD", function(v) statsFrame.Visible = v end)
addSlider("Level", "Level", 1, 999, 1, refreshStats)
addDropdown("Rank", "Rank", RANKS, refreshStats)
addSlider("Wins", "Wins", 0, 9999, 1, refreshStats)
addSlider("Streak", "Streak", 0, 999, 1, refreshStats)
addSlider("Elo", "Elo", 0, 5000, 10, refreshStats)

addSection("INTERFACE")
addToggle("ShowFPS", "Show FPS", function(v) fpsLabel.Visible = v end)

addButton("Close Panel", Theme.Dim, function() setOpen(false) end)

-- Apply defaults
applyFOV(settings.FOV)
applyBloom(settings.Bloom)
applyVignette(settings.Vignette)
fpsLabel.Visible = settings.ShowFPS

-- Toggle key (RightShift) + also Insert as backup
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Insert then
		setOpen(not open)
	end
end)

-- FPS counter
local frames, last = 0, os.clock()
RunService.RenderStepped:Connect(function()
	frames += 1
	local now = os.clock()
	if now - last >= 1 then
		if settings.ShowFPS then
			fpsLabel.Text = frames .. " FPS"
		end
		frames = 0
		last = now
	end
end)

print("[Yabujin] Loaded successfully")
print("[Yabujin] Panel is OPEN · RightShift or Insert to toggle")
print("[Yabujin] Skin Changer + Stats HUD ready")
