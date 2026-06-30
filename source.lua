-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local Highlights = {}
local ESPLabels = {}

-- Config
local Config = {
    ESP = {
        Enabled = true,
        VillainTransparency = 0.5,
        SurvivalTransparency = 0.5,
        CrateTransparency = 0.5,
        ShowNames = true,
        ShowHealth = true,
        ShowDistance = true,
        VillainColor = Color3.fromRGB(255, 50, 50),
        SurvivalColor = Color3.fromRGB(0, 255, 100),
        CrateColor = Color3.fromRGB(255, 200, 0),
        MaxDistance = 500,
    },
    Player = {
        Noclip = false,
        TPWalk = false,
        TPWalkDistance = 3,
        InfiniteJump = false,
        InstantPrompts = false,
        WalkSpeed = 80,
        JumpPower = 100,
        SpeedEnabled = false,
    },
    Powers = {
        Phasing = {Enabled = false, Key = Enum.KeyCode.Z, Stamina = 10, Infinite = false, Active = false, CurrentStamina = 10},
        Invisibility = {Enabled = false, Key = Enum.KeyCode.I, Active = false, Decoy = nil},
        Superspeed = {Enabled = false, Key = Enum.KeyCode.X, Speed = 100, Stamina = 10, Infinite = false, Active = false, CurrentStamina = 10},
        Flight = {Enabled = false, Key = Enum.KeyCode.F, Active = false, Speed = 50},
        Teleportation = {Enabled = false, Key = Enum.KeyCode.T, Active = false},
    },
    TeleportTargets = {
        Crate = true,
        Medkit = true,
        TempV = true,
        Phone = true,
    },
    Hotkeys = {
        ToggleUI = Enum.KeyCode.RightShift,
        ToggleESP = Enum.KeyCode.F,
        ToggleSpeed = Enum.KeyCode.V,
        TeleportNearest = Enum.KeyCode.G,
        ToggleNoclip = Enum.KeyCode.N,
        ToggleInfiniteJump = Enum.KeyCode.J,
        ToggleFlight = Enum.KeyCode.F,
        ToggleTeleport = Enum.KeyCode.T,
        TPWalkUp = Enum.KeyCode.W,
        TPWalkDown = Enum.KeyCode.S,
        TPWalkLeft = Enum.KeyCode.A,
        TPWalkRight = Enum.KeyCode.D,
    }
}

local TPTool = nil

-- UI Creator
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "HideFullUI_Optimized"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 320, 0, 500)
    Main.Position = UDim2.new(0, 20, 0.5, -250)
    Main.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(80, 80, 120)
    MainStroke.Thickness = 2
    MainStroke.Parent = Main

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    Header.BorderSizePixel = 0
    Header.Parent = Main

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 12)
    HeaderCorner.Parent = Header

    local HeaderFix = Instance.new("Frame")
    HeaderFix.Size = UDim2.new(1, 0, 0, 12)
    HeaderFix.Position = UDim2.new(0, 0, 1, -12)
    HeaderFix.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    HeaderFix.BorderSizePixel = 0
    HeaderFix.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "HIDE FROM VILLAIN - FULL"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -33, 0.5, -14)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = Header
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseBtn

    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, -16, 0, 35)
    TabContainer.Position = UDim2.new(0, 8, 0, 50)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = Main

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.Parent = TabContainer

    local Tabs = {"ESP", "Player", "Powers", "Teleport", "Settings"}
    local TabButtons = {}
    
    for i, tabName in ipairs(Tabs) do
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tabName .. "Tab"
        TabBtn.Size = UDim2.new(0, 60, 0, 28)
        TabBtn.BackgroundColor3 = tabName == "ESP" and Color3.fromRGB(80, 80, 120) or Color3.fromRGB(45, 45, 60)
        TabBtn.Text = tabName
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabBtn.TextSize = 11
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.Parent = TabContainer
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabBtn
        TabButtons[tabName] = TabBtn
    end

    local Content = Instance.new("ScrollingFrame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -16, 1, -100)
    Content.Position = UDim2.new(0, 8, 0, 90)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 4
    Content.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Content.Parent = Main

    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 8)
    ContentLayout.Parent = Content

    local function Section(name, tabName)
        local Sec = Instance.new("Frame")
        Sec.Name = name
        Sec.Size = UDim2.new(1, 0, 0, 0)
        Sec.AutomaticSize = Enum.AutomaticSize.Y
        Sec.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        Sec.BorderSizePixel = 0
        Sec.Visible = tabName == "ESP"
        Sec.Parent = Content
        local SecCorner = Instance.new("UICorner")
        SecCorner.CornerRadius = UDim.new(0, 8)
        SecCorner.Parent = Sec
        local SecLayout = Instance.new("UIListLayout")
        SecLayout.SortOrder = Enum.SortOrder.LayoutOrder
        SecLayout.Padding = UDim.new(0, 6)
        SecLayout.Parent = Sec
        local SecPadding = Instance.new("UIPadding")
        SecPadding.PaddingLeft = UDim.new(0, 10)
        SecPadding.PaddingRight = UDim.new(0, 10)
        SecPadding.PaddingTop = UDim.new(0, 10)
        SecPadding.PaddingBottom = UDim.new(0, 10)
        SecPadding.Parent = Sec
        local HeaderLbl = Instance.new("TextLabel")
        HeaderLbl.Size = UDim2.new(1, 0, 0, 22)
        HeaderLbl.BackgroundTransparency = 1
        HeaderLbl.Text = name
        HeaderLbl.TextColor3 = Color3.fromRGB(140, 150, 200)
        HeaderLbl.TextSize = 12
        HeaderLbl.Font = Enum.Font.GothamBold
        HeaderLbl.TextXAlignment = Enum.TextXAlignment.Left
        HeaderLbl.Parent = Sec
        return Sec
    end

    local function Toggle(parent, name, default, callback)
        local ToggleF = Instance.new("Frame")
        ToggleF.Size = UDim2.new(1, 0, 0, 30)
        ToggleF.BackgroundTransparency = 1
        ToggleF.Parent = parent
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -50, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.TextColor3 = Color3.fromRGB(220, 220, 240)
        Label.TextSize = 12
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleF
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0, 42, 0, 22)
        Btn.Position = UDim2.new(1, -44, 0.5, -11)
        Btn.BackgroundColor3 = default and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(55, 55, 75)
        Btn.Text = ""
        Btn.Parent = ToggleF
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 11)
        BtnCorner.Parent = Btn
        local Circle = Instance.new("Frame")
        Circle.Size = UDim2.new(0, 18, 0, 18)
        Circle.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Circle.Parent = Btn
        local CircleCorner = Instance.new("UICorner")
        CircleCorner.CornerRadius = UDim.new(0, 9)
        CircleCorner.Parent = Circle
        local enabled = default
        Btn.MouseButton1Click:Connect(function()
            enabled = not enabled
            Btn.BackgroundColor3 = enabled and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(55, 55, 75)
            Circle.Position = enabled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
            callback(enabled)
        end)
        return ToggleF
    end

    local function Slider(parent, name, min, max, default, callback)
        local SliderF = Instance.new("Frame")
        SliderF.Size = UDim2.new(1, 0, 0, 45)
        SliderF.BackgroundTransparency = 1
        SliderF.Parent = parent
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -40, 0, 18)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.TextColor3 = Color3.fromRGB(220, 220, 240)
        Label.TextSize = 12
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = SliderF
        local Value = Instance.new("TextLabel")
        Value.Size = UDim2.new(0, 40, 0, 18)
        Value.Position = UDim2.new(1, -42, 0, 0)
        Value.BackgroundTransparency = 1
        Value.Text = tostring(default)
        Value.TextColor3 = Color3.fromRGB(100, 200, 255)
        Value.TextSize = 12
        Value.Font = Enum.Font.GothamBold
        Value.TextXAlignment = Enum.TextXAlignment.Right
        Value.Parent = SliderF
        local Track = Instance.new("Frame")
        Track.Size = UDim2.new(1, 0, 0, 8)
        Track.Position = UDim2.new(0, 0, 0, 28)
        Track.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        Track.BorderSizePixel = 0
        Track.Parent = SliderF
        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(0, 4)
        TrackCorner.Parent = Track
        local Fill = Instance.new("Frame")
        local percent = (default - min) / (max - min)
        Fill.Size = UDim2.new(percent, 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
        Fill.BorderSizePixel = 0
        Fill.Parent = Track
        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(0, 4)
        FillCorner.Parent = Fill
        local Thumb = Instance.new("Frame")
        Thumb.Size = UDim2.new(0, 14, 0, 14)
        Thumb.Position = UDim2.new(percent, -7, 0.5, -7)
        Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Thumb.Parent = Track
        local ThumbCorner = Instance.new("UICorner")
        ThumbCorner.CornerRadius = UDim.new(0, 7)
        ThumbCorner.Parent = Thumb
        local dragging = false
        local function update(input)
            local relX = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + relX * (max - min))
            Fill.Size = UDim2.new(relX, 0, 1, 0)
            Thumb.Position = UDim2.new(relX, -7, 0.5, -7)
            Value.Text = tostring(val)
            callback(val)
        end
        Thumb.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
        end)
        Track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                update(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                update(input)
            end
        end)
        return SliderF
    end

    local function Keybind(parent, name, default, callback)
        local KeyF = Instance.new("Frame")
        KeyF.Size = UDim2.new(1, 0, 0, 32)
        KeyF.BackgroundTransparency = 1
        KeyF.Parent = parent
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -75, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.TextColor3 = Color3.fromRGB(220, 220, 240)
        Label.TextSize = 12
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = KeyF
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0, 60, 0, 24)
        Btn.Position = UDim2.new(1, -62, 0.5, -12)
        Btn.BackgroundColor3 = Color3.fromRGB(55, 55, 80)
        Btn.Text = default
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.TextSize = 11
        Btn.Font = Enum.Font.GothamBold
        Btn.Parent = KeyF
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = Btn
        local waiting = false
        Btn.MouseButton1Click:Connect(function()
            waiting = true
            Btn.Text = "..."
            Btn.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
        end)
        UserInputService.InputBegan:Connect(function(input, processed)
            if waiting and not processed then
                local key = input.KeyCode
                if key ~= Enum.KeyCode.Unknown then
                    waiting = false
                    Btn.Text = key.Name
                    Btn.BackgroundColor3 = Color3.fromRGB(55, 55, 80)
                    callback(key)
                end
            end
        end)
        return KeyF
    end

    -- Tab Switching
    for tabName, TabBtn in pairs(TabButtons) do
        TabBtn.MouseButton1Click:Connect(function()
            for name, btn in pairs(TabButtons) do
                btn.BackgroundColor3 = name == tabName and Color3.fromRGB(80, 80, 120) or Color3.fromRGB(45, 45, 60)
            end
            for _, child in pairs(Content:GetChildren()) do
                if child:IsA("Frame") then
                    child.Visible = false
                end
            end
            local sectionName = tabName == "ESP" and "ESP Settings" or tabName == "Player" and "Player" or tabName == "Powers" and "Powers" or tabName == "Teleport" and "Teleport" or "Settings"
            local sec = Content:FindFirstChild(sectionName)
            if sec then sec.Visible = true end
        end)
    end

    -- ESP Section
    local ESPSec = Section("ESP Settings", "ESP")
    Toggle(ESPSec, "Enable ESP", Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end)
    Toggle(ESPSec, "Show Names", Config.ESP.ShowNames, function(v) Config.ESP.ShowNames = v end)
    Toggle(ESPSec, "Show Health", Config.ESP.ShowHealth, function(v) Config.ESP.ShowHealth = v end)
    Toggle(ESPSec, "Show Distance", Config.ESP.ShowDistance, function(v) Config.ESP.ShowDistance = v v = v end)
    Slider(ESPSec, "Max Distance", 100, 1000, Config.ESP.MaxDistance, function(v) Config.ESP.MaxDistance = v end)

    -- Player Section
    local PlayerSec = Section("Player", "Player")
    Toggle(PlayerSec, "Enable Speed", Config.Player.SpeedEnabled, function(v)
        Config.Player.SpeedEnabled = v
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = v and Config.Player.WalkSpeed or 16
            hum.JumpPower = v and Config.Player.JumpPower or 50
        end
    end)
    Slider(PlayerSec, "Walk Speed", 16, 200, Config.Player.WalkSpeed, function(v)
        Config.Player.WalkSpeed = v
        if Config.Player.SpeedEnabled then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end
    end)
    Slider(PlayerSec, "Jump Power", 0, 200, Config.Player.JumpPower, function(v)
        Config.Player.JumpPower = v
        if Config.Player.SpeedEnabled then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = v end
        end
    end)
    Toggle(PlayerSec, "Noclip (N)", Config.Player.Noclip, function(v) Config.Player.Noclip = v end)
    Toggle(PlayerSec, "Infinite Jump (J)", Config.Player.InfiniteJump, function(v) Config.Player.InfiniteJump = v end)
    Toggle(PlayerSec, "TP Walk", Config.Player.TPWalk, function(v) Config.Player.TPWalk = v end)
    Slider(PlayerSec, "TP Walk Distance", 1, 10, Config.Player.TPWalkDistance, function(v) Config.Player.TPWalkDistance = v end)
    Toggle(PlayerSec, "Instant Prompts", Config.Player.InstantPrompts, function(v) Config.Player.InstantPrompts = v end)

    -- Powers Section
    local PowersSec = Section("Powers", "Powers")
    Toggle(PowersSec, "Flight (F)", Config.Powers.Flight.Enabled, function(v)
        Config.Powers.Flight.Enabled = v
        Config.Powers.Flight.Active = v
    end)
    Keybind(PowersSec, "Flight Key", Config.Powers.Flight.Key.Name, function(k) Config.Powers.Flight.Key = k end)
    Slider(PowersSec, "Flight Speed", 10, 150, Config.Powers.Flight.Speed, function(v) Config.Powers.Flight.Speed = v end)
    
    Toggle(PowersSec, "Superspeed (X)", Config.Powers.Superspeed.Enabled, function(v)
        Config.Powers.Superspeed.Enabled = v
        Config.Powers.Superspeed.Active = v
    end)
    Keybind(PowersSec, "Speed Key", Config.Powers.Superspeed.Key.Name, function(k) Config.Powers.Superspeed.Key = k end)
    Slider(PowersSec, "Speed Amount", 50, 200, Config.Powers.Superspeed.Speed, function(v) Config.Powers.Superspeed.Speed = v end)
    
    Toggle(PowersSec, "Teleportation (T)", Config.Powers.Teleportation.Enabled, function(v) Config.Powers.Teleportation.Enabled = v end)
    Keybind(PowersSec, "Teleport Key", Config.Powers.Teleportation.Key.Name, function(k) Config.Powers.Teleportation.Key = k end)
    
    Toggle(PowersSec, "Phasing (Z)", Config.Powers.Phasing.Enabled, function(v) Config.Powers.Phasing.Enabled = v end)
    Keybind(PowersSec, "Phase Key", Config.Powers.Phasing.Key.Name, function(k) Config.Powers.Phasing.Key = k end)
    
    Toggle(PowersSec, "Invisibility (I)", Config.Powers.Invisibility.Enabled, function(v)
        Config.Powers.Invisibility.Enabled = v
        if not v and Config.Powers.Invisibility.Decoy then
            Config.Powers.Invisibility.Decoy:Destroy()
            Config.Powers.Invisibility.Decoy = nil
        end
    end)
    Keybind(PowersSec, "Invis Key", Config.Powers.Invisibility.Key.Name, function(k) Config.Powers.Invisibility.Key = k end)

    -- Teleport Section
    local TeleportSec = Section("Teleport", "Teleport")
    Toggle(TeleportSec, "Teleport to Crate", Config.TeleportTargets.Crate, function(v) Config.TeleportTargets.Crate = v end)
    Toggle(TeleportSec, "Teleport to Medkit", Config.TeleportTargets.Medkit, function(v) Config.TeleportTargets.Medkit = v end)
    Toggle(TeleportSec, "Teleport to TempV", Config.TeleportTargets.TempV, function(v) Config.TeleportTargets.TempV = v end)
    Toggle(TeleportSec, "Teleport to Phone", Config.TeleportTargets.Phone, function(v) Config.TeleportTargets.Phone = v end)
    Keybind(TeleportSec, "Teleport Nearest", Config.Hotkeys.TeleportNearest.Name, function(k) Config.Hotkeys.TeleportNearest = k end)
    
    local TPButton = Instance.new("TextButton")
    TPButton.Size = UDim2.new(1, 0, 0, 35)
    TPButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
    TPButton.Text = "Equip TP Tool"
    TPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TPButton.TextSize = 14
    TPButton.Font = Enum.Font.GothamBold
    TPButton.Parent = TeleportSec
    local TPCorner = Instance.new("UICorner")
    TPCorner.CornerRadius = UDim.new(0, 8)
    TPCorner.Parent = TPButton
    TPButton.MouseButton1Click:Connect(function() CreateTPTool() end)

    -- Settings Section
    local SettingsSec = Section("Settings", "Settings")
    Keybind(SettingsSec, "Toggle UI", Config.Hotkeys.ToggleUI.Name, function(k) Config.Hotkeys.ToggleUI = k end)
    Keybind(SettingsSec, "Toggle ESP", Config.Hotkeys.ToggleESP.Name, function(k) Config.Hotkeys.ToggleESP = k end)
    Keybind(SettingsSec, "Toggle Speed", Config.Hotkeys.ToggleSpeed.Name, function(k) Config.Hotkeys.ToggleSpeed = k end)

    CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Config.Hotkeys.ToggleUI then Main.Visible = not Main.Visible end
    end)

    -- Draggable Frame Script
    local dragging, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true dragStart = input.Position startPos = Main.Position
        end
    end)
    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    return ScreenGui
end

-- TP Tool Creator
function CreateTPTool()
    if TPTool then TPTool:Destroy() end
    TPTool = Instance.new("Tool")
    TPTool.Name = "TP Tool"
    TPTool.RequiresHandle = true
    local Handle = Instance.new("Part")
    Handle.Name = "Handle"
    Handle.Size = Vector3.new(1, 0.5, 1)
    Handle.BrickColor = BrickColor.new("Bright blue")
    Handle.Parent = TPTool
    TPTool.Parent = LocalPlayer.Backpack
    TPTool.Activated:Connect(function()
        local target = Mouse.Hit.Position
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(target) end
    end)
end

function GetPlayerPos()
    if LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        return hrp and hrp.Position or Vector3.new()
    end
    return Vector3.new()
end

-- Memory Leaks Safe Highlight
function ApplyHighlight(model, color, transparency)
    local highlight = model:FindFirstChild("ESP_Highlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
        highlight.Parent = model
        table.insert(Highlights, highlight)
    end
    highlight.FillColor = color
    highlight.FillTransparency = transparency
    highlight.Adornee = model
end

function ClearAllESP()
    for _, h in ipairs(Highlights) do if h and h.Parent then h:Destroy() end end
    for _, l in ipairs(ESPLabels) do if l and l.Parent then l:Destroy() end end
    Highlights = {}
    ESPLabels = {}
end

-- Create ESP Label
function CreateESPLabel(target, name, health, maxHealth, color, distance)
    if not target then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Label"
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = target
    billboard.AlwaysOnTop = true
    billboard.Parent = target
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 15)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name or "Player"
    nameLabel.TextColor3 = color
    nameLabel.TextSize = 12
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = billboard
    
    if Config.ESP.ShowHealth and health and maxHealth then
        local healthBar = Instance.new("Frame")
        healthBar.Size = UDim2.new(0.8, 0, 0, 4)
        healthBar.Position = UDim2.new(0.1, 0, 0, 18)
        healthBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        healthBar.BorderSizePixel = 0
        healthBar.Parent = billboard
        
        local healthFill = Instance.new("Frame")
        healthFill.Size = UDim2.new(math.clamp(health/maxHealth, 0, 1), 0, 1, 0)
        healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        healthFill.BorderSizePixel = 0
        healthFill.Parent = healthBar
    end
    
    if Config.ESP.ShowDistance and distance then
        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 0, 12)
        distLabel.Position = UDim2.new(0, 0, 0, 26)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = math.floor(distance) .. "m"
        distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        distLabel.TextSize = 10
        distLabel.Font = Enum.Font.Gotham
        distLabel.Parent = billboard
    end
    
    table.insert(ESPLabels, billboard)
end

function IsVillain(character)
    if not character then return false end
    return character:FindFirstChild("VillainCostume") ~= nil or character.Name:lower():find("villain")
end

-- OPTIMIZED ESP LOOP
local cachedObjects = {}
local lastObjectScan = 0

function UpdateESP()
    if not Config.ESP.Enabled then 
        ClearAllESP() 
        return 
    end

    local pos = GetPlayerPos()

    -- Hapus label lama secara aman
    for _, label in ipairs(ESPLabels) do if label and label.Parent then label:Destroy() end end
    ESPLabels = {}

    -- Scanning Objek Statis diatur berkala (Mengurangi LAG drastis)
    if os.clock() - lastObjectScan > 3 then
        lastObjectScan = os.clock()
        cachedObjects = {}
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local name = obj.Name:lower()
                if name:find("crate") or name:find("box") or name:find("phone") or name:find("medkit") then
                    table.insert(cachedObjects, obj)
                end
            end
        end
    end

    -- Render Objek Terpilih (SUDAH DIPERBAIKI)
    for _, obj in ipairs(cachedObjects) do
        if obj and obj.Parent then
            -- Menggunakan GetPivot() sebagai pengaman jika PrimaryPart tidak diset oleh game
            local objPos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
            local dist = (objPos - pos).Magnitude
            if dist <= Config.ESP.MaxDistance then
                ApplyHighlight(obj, Config.ESP.CrateColor, Config.ESP.CrateTransparency)
            end
        end
    end

    -- Render Player Terfokus
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local dist = (hrp.Position - pos).Magnitude

            if dist <= Config.ESP.MaxDistance then
                local isVil = IsVillain(player.Character)
                local color = isVil and Config.ESP.VillainColor or Config.ESP.SurvivalColor
                local transparency = isVil and Config.ESP.VillainTransparency or Config.ESP.SurvivalTransparency
                
                ApplyHighlight(player.Character, color, transparency)

                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                local health = humanoid and humanoid.Health or 100
                local maxHealth = humanoid and humanoid.MaxHealth or 100
                CreateESPLabel(hrp, player.Name, health, maxHealth, color, dist)
            end
        end
    end
end

-- Power Logics Fix
function HandleFlight()
    local character = LocalPlayer.Character
    if not character or not Config.Powers.Flight.Enabled then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end
    
    if Config.Powers.Flight.Active then
        humanoid.PlatformStand = true
        local bVel = hrp:FindFirstChild("FlightVelocity")
        if not bVel then
            bVel = Instance.new("BodyVelocity")
            bVel.Name = "FlightVelocity"
            bVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bVel.Parent = hrp
        end
        
        local moveDir = humanoid.MoveDirection
        bVel.Velocity = moveDir * Config.Powers.Flight.Speed + Vector3.new(0, 0.1, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            bVel.Velocity = bVel.Velocity + Vector3.new(0, Config.Powers.Flight.Speed, 0)
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            bVel.Velocity = bVel.Velocity - Vector3.new(0, Config.Powers.Flight.Speed, 0)
        end
    else
        humanoid.PlatformStand = false
        if hrp:FindFirstChild("FlightVelocity") then hrp.FlightVelocity:Destroy() end
    end
end

function HandleInvisibility()
    local character = LocalPlayer.Character
    if not character or not Config.Powers.Invisibility.Enabled then return end
    
    if Config.Powers.Invisibility.Active then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 1
            elseif part:IsA("Decal") then
                part.Transparency = 1
            end
        end
        if not Config.Powers.Invisibility.Decoy then
            character.Archivable = true
            local clone = character:Clone()
            for _, v in pairs(clone:GetDescendants()) do
                if v:IsA("LocalScript") or v:IsA("Script") or v.Name == "Animate" then v:Destroy() end
            end
            clone.Parent = workspace
            Config.Powers.Invisibility.Decoy = clone
        end
    else
        if Config.Powers.Invisibility.Decoy then
            Config.Powers.Invisibility.Decoy:Destroy()
            Config.Powers.Invisibility.Decoy = nil
        end
    end
end

function HandlePhasing()
    local character = LocalPlayer.Character
    if not character or not Config.Powers.Phasing.Active then return end
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = false
        end
    end
end

function HandleNoclip()
    local character = LocalPlayer.Character
    if not character or not Config.Player.Noclip then return end
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
end

function HandleTPWalk()
    if not Config.Player.TPWalk then return end
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    if hrp and hum and hum.MoveDirection.Magnitude > 0 then
        hrp.CFrame = hrp.CFrame + (hum.MoveDirection * Config.Player.TPWalkDistance)
    end
end

function HandleInstantPrompts()
    if not Config.Player.InstantPrompts then return end
    for _, prompt in pairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then prompt.HoldDuration = 0 end
    end
end

-- Teleport Nearest Function Fix
function TeleportToNearest()
    local pos = GetPlayerPos()
    local nearest = nil
    local nearestDist = math.huge
    
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local name = obj.Name:lower()
            local p = obj:IsA("Model") and obj:GetPrimaryPartCFrame().Position or obj.Position
            local dist = (p - pos).Magnitude
            
            if dist < nearestDist and dist < 1000 then
                if Config.TeleportTargets.Crate and (name:find("crate") or name:find("box")) then
                    nearest = obj nearestDist = dist
                end
            end
        end
    end
    
    if nearest and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local targetCF = nearest:IsA("Model") and nearest:GetPrimaryPartCFrame() or nearest.CFrame
            hrp.CFrame = targetCF * CFrame.new(0, 4, 0)
        end
    end
end

-- Input Bindings
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Config.Hotkeys.ToggleESP then Config.ESP.Enabled = not Config.ESP.Enabled end
    if input.KeyCode == Config.Hotkeys.ToggleNoclip then Config.Player.Noclip = not Config.Player.Noclip end
    if input.KeyCode == Config.Hotkeys.TeleportNearest then TeleportToNearest() end
    if input.KeyCode == Config.Powers.Flight.Key then Config.Powers.Flight.Active = not Config.Powers.Flight.Active end
    if input.KeyCode == Config.Powers.Invisibility.Key then Config.Powers.Invisibility.Active = not Config.Powers.Invisibility.Active end
    if input.KeyCode == Config.Powers.Phasing.Key then Config.Powers.Phasing.Active = not Config.Powers.Phasing.Active end
    if input.KeyCode == Enum.KeyCode.Space and Config.Player.InfiniteJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Main RunService Thread
local lastESPUpdate = 0
RunService.Heartbeat:Connect(function(dt)
    HandleFlight()
    HandlePhasing()
    HandleNoclip()
    HandleInvisibility()
    HandleTPWalk()
    
    if os.clock() - lastESPUpdate > 0.15 then  -- Kecepatan refresh ESP optimal (60hz down to ~7hz)
        lastESPUpdate = os.clock()
        UpdateESP()
    end
end)

-- Character Loading Setup
local function SetupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        Config.Powers.Flight.Active = false
        Config.Powers.Invisibility.Active = false
        if Config.Powers.Invisibility.Decoy then
            Config.Powers.Invisibility.Decoy:Destroy()
            Config.Powers.Invisibility.Decoy = nil
        end
    end)
end

if LocalPlayer.Character then SetupCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(SetupCharacter)

-- Initialize UI
local UI = CreateUI()
UI.Parent = CoreGui

print("[HIDE FROM VILLAIN] Script Loaded & Optimized Without Lag!")
