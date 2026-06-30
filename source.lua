

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local Highlights = {}

-- Config
local Config = {
    WalkSpeed = 80,
    JumpPower = 100,
    ESPDistance = 200, -- Jangan terlalu besar!
    VillainColor = Color3.fromRGB(255, 50, 50),
    SurvivorColor = Color3.fromRGB(0, 255, 100),
    CrateColor = Color3.fromRGB(255, 200, 0),

    -- Powers
    Flight = {Enabled = false, Key = Enum.KeyCode.F, Speed = 80, Active = false},
    Superspeed = {Enabled = false, Key = Enum.KeyCode.X, Speed = 100, Stamina = 10, Infinite = false, Active = false, CurrentStamina = 10},
    Phasing = {Enabled = false, Key = Enum.KeyCode.Z, Active = false},
    Invisibility = {Enabled = false, Key = Enum.KeyCode.I, Active = false, Decoy = nil},

    -- Movement
    Noclip = false,
    InfiniteJump = true, -- Auto on
    TPWalk = {Enabled = false, Distance = 3},
}

-- UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HideUI"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 220, 0, 35)
Main.Position = UDim2.new(0, 20, 0, 20)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Main.BackgroundTransparency = 0.2
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -10, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "HIDE VILLAIN - FULL"
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

ScreenGui.Parent = game:GetService("CoreGui")

-- Speed
local function SetupChar(char)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = Config.WalkSpeed
    hum.JumpPower = Config.JumpPower
    hum.Died:Connect(function()
        Config.Flight.Active = false
        Config.Superspeed.Active = false
        Config.Phasing.Active = false
        Config.Invisibility.Active = false
    end)
end

if LocalPlayer.Character then
    SetupChar(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(SetupChar)

-- Check Villain
local function IsVillain(character)
    if not character then return false end
    for _, obj in pairs(character:GetDescendants()) do
        if obj.Name:lower():find("villaincostume") then
            return true
        end
    end
    return false
end

-- Create Highlight
local function CreateHighlight(part, color)
    if not part or part:FindFirstChild("ESP") then return end
    local h = Instance.new("Highlight")
    h.Name = "ESP"
    h.FillColor = color
    h.OutlineColor = Color3.fromRGB(255, 255, 255)
    h.FillTransparency = 0.5
    h.Adornee = part
    h.Parent = part
    table.insert(Highlights, h)
end

-- Clear Highlights
local function ClearHighlights()
    for _, h in ipairs(Highlights) do
        if h and h.Parent then
            h:Destroy()
        end
    end
    Highlights = {}
end

-- Get Position
local function GetPos()
    if LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        return hrp and hrp.Position or Vector3.new()
    end
    return Vector3.new()
end

-- Teleport Functions
local function TeleportNearest(targetType)
    local pos = GetPos()
    local nearest = nil
    local dist = math.huge

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            local shouldTeleport = false

            if targetType == "Crate" and (name:find("voughtcrate") or name:find("crate")) then
                shouldTeleport = true
            elseif targetType == "Medkit" and (name:find("medkit") or name:find("health")) then
                shouldTeleport = true
            elseif targetType == "TempV" and (name:find("tempv") or name:find("vaccine")) then
                shouldTeleport = true
            elseif targetType == "Phone" and name:find("phone") then
                shouldTeleport = true
            end

            if shouldTeleport then
                local d = (obj.Position - pos).Magnitude
                if d < dist and d < 500 then
                    dist = d
                    nearest = obj
                end
            end
        end
    end

    if nearest and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = nearest.CFrame * CFrame.new(0, 3, 0)
        end
    end
end

-- TP Tool
local TPTool = nil
local function CreateTPTool()
    if TPTool then TPTool:Destroy() end
    TPTool = Instance.new("Tool")
    TPTool.Name = "TP Tool"
    local Handle = Instance.new("Part")
    Handle.Name = "Handle"
    Handle.Size = Vector3.new(1, 0.5, 1)
    Handle.BrickColor = BrickColor.new("Bright blue")
    Handle.Parent = TPTool
    TPTool.Parent = LocalPlayer.Backpack
    TPTool.Activated:Connect(function()
        if LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(Mouse.Hit.Position)
            end
        end
    end)
end

-- ESP Loop (OPTIMIZED - every 0.5 seconds)
local lastESP = 0
RunService.Heartbeat:Connect(function(dt)
    lastESP = lastESP + dt
    if lastESP < 0.5 then return end
    lastESP = 0

    local pos = GetPos()
    ClearHighlights()

    -- Players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - pos).Magnitude
                if d < Config.ESPDistance then
                    local isVillain = IsVillain(player.Character)
                    local color = isVillain and Config.VillainColor or Config.SurvivorColor

                    local torso = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")
                    if torso then
                        CreateHighlight(torso, color)
                    end
                end
            end
        end
    end

    -- Crates
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("voughtcrate") then
            local d = (obj.Position - pos).Magnitude
            if d < Config.ESPDistance then
                CreateHighlight(obj, Config.CrateColor)
            end
        end
    end
end)

-- Flight
RunService.Heartbeat:Connect(function()
    if not Config.Flight.Enabled or not Config.Flight.Active then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    hum.PlatformStand = true
    local bv = hrp:FindFirstChild("FlightBV") or Instance.new("BodyVelocity")
    bv.Name = "FlightBV"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Parent = hrp

    local dir = Vector3.new(0, 0, 0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end

    bv.Velocity = dir * Config.Flight.Speed
end)

-- Superspeed
RunService.Heartbeat:Connect(function(dt)
    if not Config.Superspeed.Enabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if Config.Superspeed.Active then
        hum.WalkSpeed = Config.Superspeed.Speed
        if not Config.Superspeed.Infinite then
            Config.Superspeed.CurrentStamina = Config.Superspeed.CurrentStamina - dt
            if Config.Superspeed.CurrentStamina <= 0 then
                Config.Superspeed.Active = false
                Config.Superspeed.CurrentStamina = 0
                hum.WalkSpeed = Config.WalkSpeed
            end
        end
    else
        hum.WalkSpeed = Config.WalkSpeed
        if Config.Superspeed.CurrentStamina < Config.Superspeed.Stamina then
            Config.Superspeed.CurrentStamina = Config.Superspeed.CurrentStamina + dt * 2
        end
    end
end)

-- Phasing
RunService.Heartbeat:Connect(function()
    if not Config.Phasing.Enabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not Config.Phasing.Active
        end
    end
end)

-- Invisibility
RunService.Heartbeat:Connect(function()
    if not Config.Invisibility.Enabled or not Config.Invisibility.Active then return end
    local char = LocalPlayer.Character
    if not char then return end

    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = 1
        end
    end
end)

-- Infinite Jump
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Space then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Noclip
RunService.Heartbeat:Connect(function()
    if not Config.Noclip then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end)

-- TP Walk
RunService.Heartbeat:Connect(function()
    if not Config.TPWalk.Enabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local dist = Config.TPWalk.Distance
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * dist
    elseif UserInputService:IsKeyDown(Enum.KeyCode.S) then
        hrp.CFrame = hrp.CFrame - hrp.CFrame.LookVector * dist
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        hrp.CFrame = hrp.CFrame - hrp.CFrame.RightVector * dist
    elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
        hrp.CFrame = hrp.CFrame + hrp.CFrame.RightVector * dist
    end
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- Teleports
    if input.KeyCode == Enum.KeyCode.G then TeleportNearest("Crate") end
    if input.KeyCode == Enum.KeyCode.H then TeleportNearest("Medkit") end
    if input.KeyCode == Enum.KeyCode.J then TeleportNearest("TempV") end
    if input.KeyCode == Enum.KeyCode.K then TeleportNearest("Phone") end

    -- Powers
    if input.KeyCode == Config.Flight.Key then
        Config.Flight.Active = not Config.Flight.Active
        if not Config.Flight.Active then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = false end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local bv = hrp:FindFirstChild("FlightBV")
                    if bv then bv:Destroy() end
                end
            end
        end
    end

    if input.KeyCode == Config.Superspeed.Key then
        if not Config.Superspeed.Infinite then
            Config.Superspeed.CurrentStamina = Config.Superspeed.Stamina
        end
        Config.Superspeed.Active = not Config.Superspeed.Active
    end

    if input.KeyCode == Config.Phasing.Key then
        Config.Phasing.Active = not Config.Phasing.Active
    end

    if input.KeyCode == Config.Invisibility.Key then
        Config.Invisibility.Active = not Config.Invisibility.Active
    end

    -- Movement
    if input.KeyCode == Enum.KeyCode.N then
        Config.Noclip = not Config.Noclip
    end

    if input.KeyCode == Enum.KeyCode.T then
        Config.TPWalk.Enabled = not Config.TPWalk.Enabled
    end

    -- UI
    if input.KeyCode == Enum.KeyCode.RightShift then
        ScreenGui:Destroy()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Config.Superspeed.Key then
        Config.Superspeed.Active = false
    end
    if input.KeyCode == Config.Phasing.Key then
        Config.Phasing.Active = false
    end
end)

print("[HIDE VILLAIN] Script Loaded!")

