-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local menuVisible = true
local cachedWeapons = {}
local isReturning, isJumping, isAltHeld = false, false, false
local lastUpdateTime, lastJumpCheckTime = 0, 0
local targetCFrame = camera.CFrame
local peakWaypoints, peakMarker = {}, nil

-- Settings
local settings = {
    esp = {
        Enabled = true,
        ShowNames = true,
        ShowHP = true,
        Highlight = true,
        TracersEnabled = false,
        Team = { Enabled = true, Color = Color3.fromRGB(0, 255, 0) },
        Enemy = { Enabled = true, Color = Color3.fromRGB(255, 0, 0) }
    },
    aimbot = {
        Enabled = false,
        fovAngle = 10,
        smoothness = 0.5,
        targetingMethod = "Nearest",
        selectedHitboxes = {"Head"},
        lockedTarget = nil
    },
    misc = {
        BHopEnabled = false,
        AutoPeakEnabled = false,
        AutoPeakReturnMode = "KeyRelease",
        TeleportEnabled = false,
        TeleportBind = Enum.KeyCode.Tilde,
        ThirdPersonEnabled = false,
        ThirdPersonBind = Enum.UserInputType.MouseButton3,
        UnhookEnabled = false
    },
    weapon = {
        NoSpreadEnabled = false,
        WallHackEnabled = false,
        CustomAmmoEnabled = false,
        CustomDamageEnabled = false,
        CustomDamageValue = 100,
        RapidFireEnabled = false,
        InstantReloadEnabled = false,
        InstantEquipEnabled = false
    },
    visual = {
        RemoveFlashEnabled = false
    }
}

-- Utility Functions
local function isValidPosition(pos)
    return pos and not (pos.X ~= pos.X or pos.Y ~= pos.Y or pos.Z ~= pos.Z)
end

local function isSameTeam(otherPlayer)
    return player.Team and otherPlayer.Team and player.Team == otherPlayer.Team
end

local function updateWeaponSettings()
    if settings.misc.UnhookEnabled then return end
    local weaponsFolder = cachedWeapons.WeaponsFolder or ReplicatedStorage:FindFirstChild("Weapons")
    if not weaponsFolder then return end
    cachedWeapons.WeaponsFolder = weaponsFolder

    for _, weapon in pairs(weaponsFolder:GetDescendants()) do
        if weapon:IsA("NumberValue") then
            if settings.weapon.NoSpreadEnabled and weapon.Name == "Spread" then
                weapon.Value = 0
            elseif settings.weapon.WallHackEnabled and weapon.Name == "Penetration" then
                weapon.Value = 888
            elseif settings.weapon.CustomDamageEnabled and weapon.Name == "DMG" then
                weapon.Value = settings.weapon.CustomDamageValue
            elseif settings.weapon.RapidFireEnabled and weapon.Name == "FireRate" then
                weapon.Value = 0
            elseif settings.weapon.InstantReloadEnabled and weapon.Name == "ReloadTime" then
                weapon.Value = 0
            elseif settings.weapon.InstantEquipEnabled and weapon.Name == "EquipTime" then
                weapon.Value = 0
            end
        elseif weapon:IsA("IntValue") and settings.weapon.CustomAmmoEnabled and (weapon.Name == "Ammo" or weapon.Name == "MaxAmmo") then
            weapon.Value = 888
        end
    end
end

local function resetWeaponCache()
    cachedWeapons = {}
end

local function addVisualsToCharacter(character, otherPlayer)
    if not character or not character:FindFirstChild("Humanoid") or character == player.Character or not settings.esp.Enabled or settings.misc.UnhookEnabled then
        for _, obj in pairs(character:GetChildren()) do
            if obj.Name == "NameBillboard" or obj.Name == "HpBillboard" or obj:IsA("Highlight") then
                obj:Destroy()
            end
        end
        return
    end

    local head = character:FindFirstChild("Head")
    local humanoid = character:FindFirstChild("Humanoid")
    local teamColor = isSameTeam(otherPlayer) and settings.esp.Team.Color or settings.esp.Enemy.Color
    local isTeamEnabled = isSameTeam(otherPlayer) and settings.esp.Team.Enabled or settings.esp.Enemy.Enabled

    if not isTeamEnabled then return end

    -- Name Billboard
    if settings.esp.ShowNames and not character:FindFirstChild("NameBillboard") then
        local nameBillboard = Instance.new("BillboardGui", character)
        nameBillboard.Name = "NameBillboard"
        nameBillboard.Adornee = head
        nameBillboard.Size = UDim2.new(0, 100, 0, 30)
        nameBillboard.StudsOffset = Vector3.new(0, 2, 0)
        nameBillboard.AlwaysOnTop = true
        local nameLabel = Instance.new("TextLabel", nameBillboard)
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = otherPlayer.Name
        nameLabel.TextColor3 = teamColor
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.Gotham
    end

    -- Highlight
    if settings.esp.Highlight and not character:FindFirstChildOfClass("Highlight") then
        local highlight = Instance.new("Highlight", character)
        highlight.FillColor = teamColor
        highlight.OutlineColor = teamColor
        highlight.FillTransparency = 0.7
    end
end

local function updateAllVisuals()
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer.Character then
            addVisualsToCharacter(otherPlayer.Character, otherPlayer)
        end
    end
end

-- Event Connections
Players.PlayerAdded:Connect(function(newPlayer)
    newPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.1)
        addVisualsToCharacter(character, newPlayer)
    end)
end)

RunService.RenderStepped:Connect(function()
    if settings.esp.Enabled and not settings.misc.UnhookEnabled then
        updateAllVisuals()
    end
end)

-- Initial Setup
updateAllVisuals()

local player = game.Players.LocalPlayer
local players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
-- Настройки
local espSettings = {
    Enabled = true,
    ShowNames = true,
    ShowHP = true,
    Highlight = true,
    TracersEnabled = false,
    Team = { Enabled = true, Color = Color3.fromRGB(0, 255, 0) },
    Enemy = { Enabled = true, Color = Color3.fromRGB(255, 0, 0) }
}
local aimbotSettings = {
    Enabled = false,
    fovAngle = 10,
    updateInterval = 0.05,
    jumpCheckInterval = 0.1,
    maxCameraDistance = 10000,
    jumpAimVariants = 10,
    aimLerpSpeed = 0.85,
    autoStopEnabled = false,
    selectedHitboxes = {"Head"},
    smoothness = 0.5,
    targetingMethod = "Nearest",
    lockedTarget = nil
}
local miscSettings = {
    BHopEnabled = false,
    AutoPeakEnabled = false,
    AutoPeakReturnMode = "KeyRelease",
    TeleportEnabled = false,
    TeleportBind = Enum.KeyCode.Tilde,
    ThirdPersonEnabled = false,
    ThirdPersonBind = Enum.UserInputType.MouseButton3,
    UnhookEnabled = false
}
local visualSettings = {
    RemoveFlashEnabled = false,
    OriginalFlashValues = {Value1 = nil, Value2 = nil}
}
local weaponSettings = {
    NoSpreadEnabled = false,
    WallHackEnabled = false,
    CustomAmmoEnabled = false,
    LockedAmmo = false, -- Не используется, но оставлено для совместимости GUI
    CustomDamageEnabled = false,
    CustomDamageValue = 100,
    RapidFireEnabled = false,      -- Новый параметр
    InstantReloadEnabled = false,  -- Новый параметр
    InstantEquipEnabled = false,   -- Новый параметр
    OriginalWeaponValues = {}
}
local menuVisible = true
local altButtonActive = false
local peakMarker = nil
local playerWalkSpeed = 16
local isAltHeld = false
local initialPosition = nil
local initialCFrame = nil
local lastAnchorTime = 0
local thirdPersonState = false
local targetCFrame = camera.CFrame
local isJumping = false
local lastUpdateTime = 0
local lastJumpCheckTime = 0
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.IgnoreWater = true
local isReturning = false
local peakWaypoints = {}
local hitboxMenuOpen = false
-- Создание GUI-меню
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "MainMenu"
ScreenGui.ResetOnSpawn = false
local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 400, 0, 400)
Frame.Position = UDim2.new(0.322795, 0, 0.15377, 0)
Frame.BackgroundColor3 = Color3.new(0, 0, 0)
Frame.BackgroundTransparency = 0.25
Frame.Active = true
Frame.Draggable = true
Frame.Visible = menuVisible
local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = Frame
local FrameStroke = Instance.new("UIStroke")
FrameStroke.Thickness = 1
FrameStroke.Color = Color3.new(1, 1, 1)
FrameStroke.Transparency = 0.8
FrameStroke.Parent = Frame
-- Draggable Window
local NameWindow = Instance.new("Frame")
NameWindow.Parent = ScreenGui
NameWindow.Size = UDim2.new(0, 250, 0, 50)
NameWindow.Position = UDim2.new(0.1, 0, 0, 5)
NameWindow.BackgroundColor3 = Color3.new(0, 0, 0)
NameWindow.BackgroundTransparency = 0
NameWindow.Active = true
NameWindow.Visible = true
local NameWindowCorner = Instance.new("UICorner")
NameWindowCorner.CornerRadius = UDim.new(0, 8)
NameWindowCorner.Parent = NameWindow
local NameImage = Instance.new("ImageLabel")
NameImage.Parent = NameWindow
NameImage.Size = UDim2.new(0, 40, 0, 40) -- Reduced size to fit
NameImage.Position = UDim2.new(0, 5, 0, 5) -- Aligned to the left
NameImage.BackgroundTransparency = 1
NameImage.Image = "rbxassetid://120914505895019"
NameImage.ImageRectOffset = Vector2.new(0, 0)
NameImage.ImageRectSize = Vector2.new(512, 512)
NameImage.ScaleType = Enum.ScaleType.Fit
-- Исправлено: Установка масштаба и смещения Y для изображения
NameImage.ScaleType = Enum.ScaleType.Fit
NameImage.SliceCenter = Rect.new(0, 0, 0, 0) -- Убедимся, что нет обрезки
-- Для корректного масштабирования можно использовать AspectRatioConstraint, но здесь просто установим размер
NameImage.Size = UDim2.new(0, 40, 0, 40) -- Уже установлено, но подчеркнем
NameImage.Position = UDim2.new(0, 5, 0, 5) -- Уже установлено, но подчеркнем
local NameLabel = Instance.new("TextLabel")
NameLabel.Parent = NameWindow
NameLabel.Size = UDim2.new(0, 190, 0, 40) -- Уменьшено, чтобы поместиться
NameLabel.Position = UDim2.new(0, 50, 0, 5) -- Adjusted to start after image
NameLabel.BackgroundTransparency = 1
NameLabel.Text = "Arithmetic · " .. player.Name
NameLabel.TextColor3 = Color3.new(1, 1, 1)
NameLabel.TextSize = 14 -- Уменьшен размер шрифта
NameLabel.Font = Enum.Font.GothamBlack
NameLabel.TextXAlignment = Enum.TextXAlignment.Left
NameLabel.TextYAlignment = Enum.TextYAlignment.Center
NameLabel.TextTruncate = Enum.TextTruncate.AtEnd -- Обрезка текста, если он слишком длинный
NameWindow.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and menuVisible then
        local initialPos = input.Position
        local initialFramePos = NameWindow.Position
        local connection
        connection = UserInputService.InputChanged:Connect(function(inputChanged)
            if inputChanged.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = inputChanged.Position - initialPos
                NameWindow.Position = UDim2.new(
                    initialFramePos.X.Scale,
                    initialFramePos.X.Offset + delta.X,
                    initialFramePos.Y.Scale,
                    initialFramePos.Y.Offset + delta.Y
                )
            end
        end)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                connection:Disconnect()
            end
        end)
    end
end)
-- Вкладки (исправлены отступы)
local function createTabButton(text, xScale)
    local tab = Instance.new("TextButton")
    tab.Parent = Frame
    tab.Size = UDim2.new(0, 60, 0, 30)
    tab.Position = UDim2.new(xScale, 0, 0.02, 0)
    tab.Text = text
    tab.TextColor3 = Color3.new(1, 1, 1)
    tab.BackgroundTransparency = 1
    tab.TextSize = 14 -- Уменьшен размер шрифта
    tab.Font = Enum.Font.Gotham
    tab.TextXAlignment = Enum.TextXAlignment.Center
    local tabStroke = Instance.new("UIStroke")
    tabStroke.Thickness = 1
    tabStroke.Color = Color3.new(0.5, 0.5, 0.5)
    tabStroke.Parent = tab
    return tab
end
-- Исправлены позиции вкладок, чтобы они не перекрывались
local aimbotTab = createTabButton("Aimbot", 0.02)
local espTab = createTabButton("ESP", 0.18) -- Изменено
local miscTab = createTabButton("Misc", 0.34) -- Изменено
local otherTab = createTabButton("Other", 0.50) -- Изменено
local visualTab = createTabButton("Visual", 0.66) -- Изменено
local weaponTab = createTabButton("Weapon", 0.82) -- Изменено
local BottomLine = Instance.new("Frame")
BottomLine.Parent = Frame
BottomLine.Size = UDim2.new(0, 390, 0, 1)
BottomLine.Position = UDim2.new(0.01, 0, 0.1, 0)
BottomLine.BackgroundColor3 = Color3.new(1, 1, 1)
BottomLine.BackgroundTransparency = 0.7
local contentFrame = Instance.new("Frame")
contentFrame.Parent = Frame
contentFrame.Size = UDim2.new(0.95, 0, 0.85, 0)
contentFrame.Position = UDim2.new(0.025, 0, 0.12, 0)
contentFrame.BackgroundTransparency = 1
local aimbotContent = Instance.new("Frame")
aimbotContent.Parent = contentFrame
aimbotContent.Size = UDim2.new(1, 0, 1, 0)
aimbotContent.BackgroundTransparency = 1
aimbotContent.Visible = false
local espContent = Instance.new("Frame")
espContent.Parent = contentFrame
espContent.Size = UDim2.new(1, 0, 1, 0)
espContent.BackgroundTransparency = 1
espContent.Visible = true
local miscContent = Instance.new("Frame")
miscContent.Parent = contentFrame
miscContent.Size = UDim2.new(1, 0, 1, 0)
miscContent.BackgroundTransparency = 1
miscContent.Visible = false
local otherContent = Instance.new("Frame")
otherContent.Parent = contentFrame
otherContent.Size = UDim2.new(1, 0, 1, 0)
otherContent.BackgroundTransparency = 1
otherContent.Visible = false
local visualContent = Instance.new("Frame")
visualContent.Parent = contentFrame
visualContent.Size = UDim2.new(1, 0, 1, 0)
visualContent.BackgroundTransparency = 1
visualContent.Visible = false
local weaponContent = Instance.new("Frame")
weaponContent.Parent = contentFrame
weaponContent.Size = UDim2.new(1, 0, 1, 0)
weaponContent.BackgroundTransparency = 1
weaponContent.Visible = false
local function createCheckbox(parent, text, yScale, setting, callback)
    local checkbox = Instance.new("TextButton")
    checkbox.Parent = parent
    checkbox.Size = UDim2.new(0, 20, 0, 20)
    checkbox.Position = UDim2.new(0.1, 0, yScale, 0)
    checkbox.BackgroundColor3 = setting and Color3.fromRGB(255, 165, 0) or Color3.new(0.2, 0.2, 0.2)
    checkbox.BackgroundTransparency = 0.3
    checkbox.Text = ""
    local checkboxCorner = Instance.new("UICorner")
    checkboxCorner.CornerRadius = UDim.new(0, 4)
    checkboxCorner.Parent = checkbox
    local checkboxStroke = Instance.new("UIStroke")
    checkboxStroke.Thickness = 1
    checkboxStroke.Color = Color3.new(0.5, 0.5, 0.5)
    checkboxStroke.Parent = checkbox
    local checkboxLabel = Instance.new("TextLabel")
    checkboxLabel.Parent = parent
    checkboxLabel.Size = UDim2.new(0, 180, 0, 20)
    checkboxLabel.Position = UDim2.new(0.2, 0, yScale, 0)
    checkboxLabel.BackgroundTransparency = 1
    checkboxLabel.Text = text
    checkboxLabel.TextColor3 = Color3.new(1, 1, 1)
    checkboxLabel.TextSize = 14 -- Уменьшен размер шрифта
    checkboxLabel.Font = Enum.Font.Gotham
    checkboxLabel.TextXAlignment = Enum.TextXAlignment.Left
    checkbox.MouseButton1Click:Connect(function()
        setting = not setting
        checkbox.BackgroundColor3 = setting and Color3.fromRGB(255, 165, 0) or Color3.new(0.2, 0.2, 0.2)
        if callback then
            callback(setting)
        end
    end)
    return checkbox
end
local function createButton(parent, text, yScale, callback, font)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(0, 150, 0, 30)
    btn.Position = UDim2.new(0.1, 0, yScale, 0)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    btn.BackgroundTransparency = 0.2
    btn.TextSize = 14
    btn.Font = font or Enum.Font.Gotham
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Thickness = 1
    btnStroke.Color = Color3.new(0.6, 0.6, 0.6)
    btnStroke.Parent = btn
    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    return btn
end
-- Aimbot Hitbox Dropdown
local hitboxButton = createButton(aimbotContent, "Hitboxes: " .. (aimbotSettings.selectedHitboxes[1] or "None"), 0.2, function()
    hitboxMenuOpen = not hitboxMenuOpen
    hitboxMenu.Visible = hitboxMenuOpen
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local goal = hitboxMenuOpen and {BackgroundTransparency = 0.3} or {BackgroundTransparency = 1}
    TweenService:Create(hitboxMenu, tweenInfo, goal):Play()
    for _, btn in pairs(hitboxMenu:GetChildren()) do
        if btn:IsA("TextButton") then
            local btnGoal = hitboxMenuOpen and {BackgroundTransparency = 0.2, TextTransparency = 0} or {BackgroundTransparency = 1, TextTransparency = 1}
            TweenService:Create(btn, tweenInfo, btnGoal):Play()
        end
    end
end)
local hitboxMenu = Instance.new("Frame")
hitboxMenu.Parent = aimbotContent
hitboxMenu.Size = UDim2.new(0, 150, 0, 180)
hitboxMenu.Position = UDim2.new(0.1, 0, 0.25, 0)
hitboxMenu.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
hitboxMenu.BackgroundTransparency = 1
hitboxMenu.Visible = false
local hitboxMenuCorner = Instance.new("UICorner")
hitboxMenuCorner.CornerRadius = UDim.new(0, 6)
hitboxMenuCorner.Parent = hitboxMenu
local hitboxMenuStroke = Instance.new("UIStroke")
hitboxMenuStroke.Thickness = 1
hitboxMenuStroke.Color = Color3.new(0.6, 0.6, 0.6)
hitboxMenuStroke.Parent = hitboxMenu
local hitboxList = {"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}
for i, hitbox in ipairs(hitboxList) do
    local btn = Instance.new("TextButton")
    btn.Parent = hitboxMenu
    btn.Size = UDim2.new(0, 140, 0, 25)
    btn.Position = UDim2.new(0.033, 0, (i-1) * 0.167 + 0.05, 0)
    btn.Text = hitbox
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = aimbotSettings.selectedHitboxes[1] == hitbox and Color3.fromRGB(255, 165, 0) or Color3.new(0.3, 0.3, 0.3)
    btn.BackgroundTransparency = 1
    btn.TextTransparency = 1
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    btn.MouseButton1Click:Connect(function()
        aimbotSettings.selectedHitboxes = {hitbox}
        hitboxButton.Text = "Hitboxes: " .. hitbox
        for _, otherBtn in pairs(hitboxMenu:GetChildren()) do
            if otherBtn:IsA("TextButton") then
                otherBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        hitboxMenuOpen = false
        hitboxMenu.Visible = false
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        TweenService:Create(hitboxMenu, tweenInfo, {BackgroundTransparency = 1}):Play()
        for _, otherBtn in pairs(hitboxMenu:GetChildren()) do
            if otherBtn:IsA("TextButton") then
                TweenService:Create(otherBtn, tweenInfo, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            end
        end
    end)
end
-- Targeting Method Dropdown
local targetingButton = createButton(aimbotContent, "Targeting: " .. aimbotSettings.targetingMethod, 0.3, function()
    local targetingMenu = Instance.new("Frame")
    targetingMenu.Parent = aimbotContent
    targetingMenu.Size = UDim2.new(0, 150, 0, 60)
    targetingMenu.Position = UDim2.new(0.1, 0, 0.35, 0)
    targetingMenu.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    targetingMenu.BackgroundTransparency = 0.3
    local targetingMenuCorner = Instance.new("UICorner")
    targetingMenuCorner.CornerRadius = UDim.new(0, 6)
    targetingMenuCorner.Parent = targetingMenu
    local targetingMenuStroke = Instance.new("UIStroke")
    targetingMenuStroke.Thickness = 1
    targetingMenuStroke.Color = Color3.new(0.6, 0.6, 0.6)
    targetingMenuStroke.Parent = targetingMenu
    local targetingList = {"Nearest", "Locked"}
    for i, method in ipairs(targetingList) do
        local btn = Instance.new("TextButton")
        btn.Parent = targetingMenu
        btn.Size = UDim2.new(0, 140, 0, 25)
        btn.Position = UDim2.new(0.033, 0, (i-1) * 0.5 + 0.05, 0)
        btn.Text = method
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.BackgroundColor3 = aimbotSettings.targetingMethod == method and Color3.fromRGB(255, 165, 0) or Color3.new(0.3, 0.3, 0.3)
        btn.BackgroundTransparency = 0.2
        btn.TextSize = 14
        btn.Font = Enum.Font.Gotham
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = btn
        btn.MouseButton1Click:Connect(function()
            aimbotSettings.targetingMethod = method
            aimbotSettings.lockedTarget = nil
            targetingButton.Text = "Targeting: " .. method
            for _, otherBtn in pairs(targetingMenu:GetChildren()) do
                if otherBtn:IsA("TextButton") then
                    otherBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
            targetingMenu:Destroy()
        end)
    end
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    TweenService:Create(targetingMenu, tweenInfo, {BackgroundTransparency = 0.3}):Play()
    for _, btn in pairs(targetingMenu:GetChildren()) do
        if btn:IsA("TextButton") then
            TweenService:Create(btn, tweenInfo, {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
        end
    end
end)
-- FOV Input
local fovLabel = Instance.new("TextLabel")
fovLabel.Parent = aimbotContent
fovLabel.Size = UDim2.new(0, 180, 0, 20)
fovLabel.Position = UDim2.new(0.1, 0, 0.4, 0)
fovLabel.Text = "FOV Angle: " .. aimbotSettings.fovAngle
fovLabel.TextColor3 = Color3.new(1, 1, 1)
fovLabel.TextSize = 14
fovLabel.Font = Enum.Font.Gotham
fovLabel.BackgroundTransparency = 1
local fovInput = Instance.new("TextBox")
fovInput.Parent = aimbotContent
fovInput.Size = UDim2.new(0, 180, 0, 30)
fovInput.Position = UDim2.new(0.1, 0, 0.45, 0)
fovInput.Text = tostring(aimbotSettings.fovAngle)
fovInput.TextColor3 = Color3.new(1, 1, 1)
fovInput.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
fovInput.BackgroundTransparency = 0.3
fovInput.TextSize = 14
fovInput.Font = Enum.Font.Gotham
local fovInputCorner = Instance.new("UICorner")
fovInputCorner.CornerRadius = UDim.new(0, 6)
fovInputCorner.Parent = fovInput
local fovInputStroke = Instance.new("UIStroke")
fovInputStroke.Thickness = 1
fovInputStroke.Color = Color3.new(0.6, 0.6, 0.6)
fovInputStroke.Parent = fovInput
fovInput.Changed:Connect(function()
    local fov = tonumber(fovInput.Text)
    if fov then
        aimbotSettings.fovAngle = math.clamp(fov, 5, 180)
        fovLabel.Text = "FOV Angle: " .. aimbotSettings.fovAngle
    end
end)
-- Smoothness Slider
local smoothnessLabel = Instance.new("TextLabel")
smoothnessLabel.Parent = aimbotContent
smoothnessLabel.Size = UDim2.new(0, 180, 0, 20)
smoothnessLabel.Position = UDim2.new(0.1, 0, 0.55, 0)
smoothnessLabel.Text = "Smoothness: " .. math.floor(aimbotSettings.smoothness * 100) .. "%"
smoothnessLabel.TextColor3 = Color3.new(1, 1, 1)
smoothnessLabel.TextSize = 14
smoothnessLabel.Font = Enum.Font.Gotham
smoothnessLabel.BackgroundTransparency = 1
local smoothnessSlider = Instance.new("TextButton")
smoothnessSlider.Parent = aimbotContent
smoothnessSlider.Size = UDim2.new(0, 180, 0, 20)
smoothnessSlider.Position = UDim2.new(0.1, 0, 0.6, 0)
smoothnessSlider.Text = ""
smoothnessSlider.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
smoothnessSlider.BackgroundTransparency = 0.3
smoothnessSlider.TextSize = 14
smoothnessSlider.Font = Enum.Font.Gotham
local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 6)
sliderCorner.Parent = smoothnessSlider
local sliderStroke = Instance.new("UIStroke")
sliderStroke.Thickness = 1
sliderStroke.Color = Color3.new(0.6, 0.6, 0.6)
sliderStroke.Parent = smoothnessSlider
smoothnessSlider.MouseButton1Down:Connect(function()
    local connection
    connection = RunService.RenderStepped:Connect(function()
        local mousePos = UserInputService:GetMouseLocation()
        local relativePos = (mousePos - Vector2.new(Frame.AbsolutePosition.X + 40, Frame.AbsolutePosition.Y + 240)).X / 180
        aimbotSettings.smoothness = math.clamp(relativePos, 0, 1)
        smoothnessLabel.Text = "Smoothness: " .. math.floor(aimbotSettings.smoothness * 100) .. "%"
        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            connection:Disconnect()
        end
    end)
end)
-- Auto Peak Return Mode
local autoPeakModeLabel = Instance.new("TextLabel")
autoPeakModeLabel.Parent = miscContent
autoPeakModeLabel.Size = UDim2.new(0, 180, 0, 20)
autoPeakModeLabel.Position = UDim2.new(0.1, 0, 0.55, 0)
autoPeakModeLabel.Text = "Auto Peak Return: " .. miscSettings.AutoPeakReturnMode
autoPeakModeLabel.TextColor3 = Color3.new(1, 1, 1)
autoPeakModeLabel.TextSize = 14
autoPeakModeLabel.Font = Enum.Font.Gotham
autoPeakModeLabel.BackgroundTransparency = 1
local autoPeakModeButton = createButton(miscContent, "Toggle Return Mode", 0.6, function()
    miscSettings.AutoPeakReturnMode = miscSettings.AutoPeakReturnMode == "KeyRelease" and "Shoot" or "KeyRelease"
    autoPeakModeLabel.Text = "Auto Peak Return: " .. miscSettings.AutoPeakReturnMode
end)
-- Кнопки и чекбоксы для ESP
createCheckbox(espContent, "ESP Enabled", 0.1, espSettings.Enabled, function(val) espSettings.Enabled = val end)
createCheckbox(espContent, "Toggle Names", 0.2, espSettings.ShowNames, function(val) espSettings.ShowNames = val end)
createCheckbox(espContent, "Toggle HP", 0.3, espSettings.ShowHP, function(val) espSettings.ShowHP = val end)
createCheckbox(espContent, "Toggle Highlight", 0.4, espSettings.Highlight, function(val) espSettings.Highlight = val end)
createCheckbox(espContent, "Toggle Tracers", 0.5, espSettings.TracersEnabled, function(val) espSettings.TracersEnabled = val end)
createCheckbox(espContent, "Team ESP On/Off", 0.6, espSettings.Team.Enabled, function(val) espSettings.Team.Enabled = val end)
createCheckbox(espContent, "Enemy ESP On/Off", 0.7, espSettings.Enemy.Enabled, function(val) espSettings.Enemy.Enabled = val end)
local teamColorInput = Instance.new("TextBox")
teamColorInput.Parent = espContent
teamColorInput.Size = UDim2.new(0, 180, 0, 30)
teamColorInput.Position = UDim2.new(0.1, 0, 0.8, 0)
teamColorInput.Text = "Team Color (R,G,B)"
teamColorInput.TextColor3 = Color3.new(1, 1, 1)
teamColorInput.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
teamColorInput.BackgroundTransparency = 0.3
teamColorInput.TextSize = 14
teamColorInput.Font = Enum.Font.Gotham
local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = teamColorInput
local inputStroke = Instance.new("UIStroke")
inputStroke.Thickness = 1
inputStroke.Color = Color3.new(0.6, 0.6, 0.6)
inputStroke.Parent = teamColorInput
teamColorInput.Changed:Connect(function()
    local r, g, b = teamColorInput.Text:match("(%d+),(%d+),(%d+)")
    if r and g and b then
        espSettings.Team.Color = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
        updateAllVisuals()
    end
end)
local enemyColorInput = Instance.new("TextBox")
enemyColorInput.Parent = espContent
enemyColorInput.Size = UDim2.new(0, 180, 0, 30)
enemyColorInput.Position = UDim2.new(0.1, 0, 0.9, 0)
enemyColorInput.Text = "Enemy Color (R,G,B)"
enemyColorInput.TextColor3 = Color3.new(1, 1, 1)
enemyColorInput.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
enemyColorInput.BackgroundTransparency = 0.3
enemyColorInput.TextSize = 14
enemyColorInput.Font = Enum.Font.Gotham
local enemyInputCorner = Instance.new("UICorner")
enemyInputCorner.CornerRadius = UDim.new(0, 6)
enemyInputCorner.Parent = enemyColorInput
local enemyInputStroke = Instance.new("UIStroke")
enemyInputStroke.Thickness = 1
enemyInputStroke.Color = Color3.new(0.6, 0.6, 0.6)
enemyInputStroke.Parent = enemyColorInput
enemyColorInput.Changed:Connect(function()
    local r, g, b = enemyColorInput.Text:match("(%d+),(%d+),(%d+)")
    if r and g and b then
        espSettings.Enemy.Color = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
        updateAllVisuals()
    end
end)
-- Чекбоксы для Aimbot
createCheckbox(aimbotContent, "Aimbot Enabled", 0.1, aimbotSettings.Enabled, function(val)
    aimbotSettings.Enabled = val
    if not val then
        aimbotSettings.lockedTarget = nil
    end
end)
createCheckbox(aimbotContent, "Auto Stop", 0.65, aimbotSettings.autoStopEnabled, function(val) aimbotSettings.autoStopEnabled = val end)
-- Чекбоксы и кнопки для Misc
createCheckbox(miscContent, "Toggle BHop", 0.1, miscSettings.BHopEnabled, function(val) miscSettings.BHopEnabled = val end)
createCheckbox(miscContent, "Toggle Auto Peak", 0.2, miscSettings.AutoPeakEnabled, function(val) miscSettings.AutoPeakEnabled = val end)
createCheckbox(miscContent, "Toggle Teleport", 0.3, miscSettings.TeleportEnabled, function(val) miscSettings.TeleportEnabled = val end)
local teleportBindButton = createButton(miscContent, "Change Teleport Bind: " .. miscSettings.TeleportBind.Name, 0.4, function()
    local userInput = UserInputService.InputBegan:Wait()
    if userInput.UserInputType == Enum.UserInputType.Keyboard then
        miscSettings.TeleportBind = userInput.KeyCode
        teleportBindButton.Text = "Change Teleport Bind: " .. userInput.KeyCode.Name
    end
end, Enum.Font.GothamBlack)
local altButton = createButton(miscContent, "Alt Toggle", 0.65, function()
    altButtonActive = not altButtonActive
    altButton.BackgroundColor3 = altButtonActive and Color3.fromRGB(255, 165, 0) or Color3.new(0.3, 0.3, 0.3)
end)
createCheckbox(miscContent, "Toggle Third Person", 0.75, miscSettings.ThirdPersonEnabled, function(val)
    miscSettings.ThirdPersonEnabled = val
    thirdPersonState = val
    if val then
        forceThirdPerson()
    else
        player.CameraMode = Enum.CameraMode.Classic
        player.CameraMinZoomDistance = 0.5
        player.CameraMaxZoomDistance = 128
    end
end)
local thirdPersonBindButton = createButton(miscContent, "Change ThirdPerson Bind: " .. miscSettings.ThirdPersonBind.Name, 0.8, function()
    local userInput = UserInputService.InputBegan:Wait()
    if userInput.UserInputType == Enum.UserInputType.Keyboard or userInput.UserInputType.Name:match("MouseButton") then
        miscSettings.ThirdPersonBind = userInput.UserInputType == Enum.UserInputType.Keyboard and userInput.KeyCode or userInput.UserInputType
        thirdPersonBindButton.Text = "Change ThirdPerson Bind: " .. (userInput.UserInputType == Enum.UserInputType.Keyboard and userInput.KeyCode.Name or userInput.UserInputType.Name)
    end
end)
-- Unhook Checkbox in Other tab
createCheckbox(otherContent, "Unhook Cheats", 0.1, miscSettings.UnhookEnabled, function(val)
    miscSettings.UnhookEnabled = val
    if val then
        unhookCheats()
    end
end)
-- Remove Flash in Visual tab
createCheckbox(visualContent, "Remove Flash", 0.1, visualSettings.RemoveFlashEnabled, function(val)
    visualSettings.RemoveFlashEnabled = val
end)
-- Weapon Tab Controls
createCheckbox(weaponContent, "No Spread", 0.1, weaponSettings.NoSpreadEnabled, function(val) weaponSettings.NoSpreadEnabled = val; updateWeaponSettings() end)
createCheckbox(weaponContent, "Wall Hack", 0.2, weaponSettings.WallHackEnabled, function(val)
    weaponSettings.WallHackEnabled = val
    updateWeaponSettings()
end)
createCheckbox(weaponContent, "Custom Ammo", 0.3, weaponSettings.CustomAmmoEnabled, function(val)
    weaponSettings.CustomAmmoEnabled = val
    updateWeaponSettings()
end)
createCheckbox(weaponContent, "Custom Damage", 0.4, weaponSettings.CustomDamageEnabled, function(val)
    weaponSettings.CustomDamageEnabled = val
    updateWeaponSettings()
end)
createCheckbox(weaponContent, "Rapid Fire", 0.45, weaponSettings.RapidFireEnabled, function(val) -- Новый чекбокс
    weaponSettings.RapidFireEnabled = val
    updateWeaponSettings()
end)
createCheckbox(weaponContent, "Instant Reload", 0.5, weaponSettings.InstantReloadEnabled, function(val) -- Новый чекбокс
    weaponSettings.InstantReloadEnabled = val
    updateWeaponSettings()
end)
createCheckbox(weaponContent, "Instant Equip", 0.55, weaponSettings.InstantEquipEnabled, function(val) -- Новый чекбокс
    weaponSettings.InstantEquipEnabled = val
    updateWeaponSettings()
end)
-- Удалена кнопка Lock Ammo
-- local lockAmmoButton = createButton(weaponContent, "Lock Ammo", 0.5, function()
--     weaponSettings.LockedAmmo = not weaponSettings.LockedAmmo
--     lockAmmoButton.BackgroundColor3 = weaponSettings.LockedAmmo and Color3.fromRGB(255, 165, 0) or Color3.new(0.3, 0.3, 0.3)
--     updateWeaponSettings()
-- end)
local damageInputLabel = Instance.new("TextLabel")
damageInputLabel.Parent = weaponContent
damageInputLabel.Size = UDim2.new(0, 180, 0, 20)
damageInputLabel.Position = UDim2.new(0.1, 0, 0.6, 0) -- Сдвинуты вниз
damageInputLabel.Text = "Damage: " .. weaponSettings.CustomDamageValue
damageInputLabel.TextColor3 = Color3.new(1, 1, 1)
damageInputLabel.TextSize = 14
damageInputLabel.Font = Enum.Font.Gotham
damageInputLabel.BackgroundTransparency = 1
local damageInput = Instance.new("TextBox")
damageInput.Parent = weaponContent
damageInput.Size = UDim2.new(0, 180, 0, 30)
damageInput.Position = UDim2.new(0.1, 0, 0.65, 0) -- Сдвинуты вниз
damageInput.Text = tostring(weaponSettings.CustomDamageValue)
damageInput.TextColor3 = Color3.new(1, 1, 1)
damageInput.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
damageInput.BackgroundTransparency = 0.3
damageInput.TextSize = 14
damageInput.Font = Enum.Font.Gotham
local damageInputCorner = Instance.new("UICorner")
damageInputCorner.CornerRadius = UDim.new(0, 6)
damageInputCorner.Parent = damageInput
local damageInputStroke = Instance.new("UIStroke")
damageInputStroke.Thickness = 1
damageInputStroke.Color = Color3.new(0.6, 0.6, 0.6)
damageInputStroke.Parent = damageInput
damageInput.Changed:Connect(function()
    local damage = tonumber(damageInput.Text)
    if damage then
        weaponSettings.CustomDamageValue = math.clamp(damage, 1, 1000000) -- Увеличен максимальный урон
        damageInputLabel.Text = "Damage: " .. weaponSettings.CustomDamageValue
        updateWeaponSettings()
    end
end)
-- Обновленная функция updateWeaponSettings
local cachedWeapons = {} -- Кэш для найденных объектов оружия
local function updateWeaponSettings()
    if miscSettings.UnhookEnabled then return end

    -- Получаем ReplicatedStorage только один раз
    local replicatedStorage = game:GetService("ReplicatedStorage")

    -- Кэшируем папку Weapons
    local weaponsFolder = cachedWeapons.WeaponsFolder or replicatedStorage:FindFirstChild("Weapons")
    if not weaponsFolder then
        return -- Если папки нет, выходим
    end
    cachedWeapons.WeaponsFolder = weaponsFolder -- Сохраняем в кэш

    -- Получаем список всех потомков только один раз, если кэш пуст
    local weaponDescendants = cachedWeapons.Descendants
    if not weaponDescendants then
        weaponDescendants = weaponsFolder:GetDescendants()
        cachedWeapons.Descendants = weaponDescendants -- Сохраняем в кэш
    end

    -- Итерируемся по кэшированному списку
    for _, weapon in pairs(weaponDescendants) do
        -- Проверяем тип объекта один раз
        local weaponType = weapon.ClassName

        -- No Spread
        if weaponSettings.NoSpreadEnabled and weaponType == "NumberValue" and weapon.Name == "Spread" then
            if weapon.Value ~= 0 then -- Устанавливаем только если значение отличается
                weapon.Value = 0
            end
            -- Обновляем дочерние NumberValue, если они есть (и если они не те же самые)
            for _, child in pairs(weapon:GetChildren()) do
                if child.ClassName == "NumberValue" and child.Value ~= 0 then
                    child.Value = 0
                end
            end
        end

        -- Wall Hack (Penetration)
        if weaponSettings.WallHackEnabled and weaponType == "NumberValue" and weapon.Name == "Penetration" and weapon.Value ~= 888 then
            weapon.Value = 888
        end

        -- Custom Ammo (Ammo и MaxAmmo)
        if weaponSettings.CustomAmmoEnabled and weaponType == "IntValue" and (weapon.Name == "Ammo" or weapon.Name == "MaxAmmo") and weapon.Value ~= 888 then
            weapon.Value = 888
        end

        -- Custom Damage (DMG)
        if weaponSettings.CustomDamageEnabled and weaponType == "NumberValue" and weapon.Name == "DMG" and weapon.Value ~= weaponSettings.CustomDamageValue then
            weapon.Value = weaponSettings.CustomDamageValue
        end

        -- Rapid Fire (FireRate)
        if weaponSettings.RapidFireEnabled and weaponType == "NumberValue" and weapon.Name == "FireRate" and weapon.Value ~= 0 then
            weapon.Value = 0
        end

        -- Instant Reload (ReloadTime)
        if weaponSettings.InstantReloadEnabled and weaponType == "NumberValue" and weapon.Name == "ReloadTime" and weapon.Value ~= 0 then
            weapon.Value = 0
        end

        -- Instant Equip (EquipTime)
        if weaponSettings.InstantEquipEnabled and weaponType == "NumberValue" and weapon.Name == "EquipTime" and weapon.Value ~= 0 then
            weapon.Value = 0
        end
    end
end

-- Функция для сброса кэша при необходимости (например, при отключении читов)
local function resetWeaponCache()
    cachedWeapons = {}
end

local function switchTab(activeFrame)
    aimbotContent.Visible = false
    espContent.Visible = false
    miscContent.Visible = false
    otherContent.Visible = false
    visualContent.Visible = false
    weaponContent.Visible = false
    activeFrame.Visible = true
    hitboxMenuOpen = false
    hitboxMenu.Visible = false
    hitboxMenu.BackgroundTransparency = 1
    for _, btn in pairs(hitboxMenu:GetChildren()) do
        if btn:IsA("TextButton") then
            btn.BackgroundTransparency = 1
            btn.TextTransparency = 1
        end
    end
end
aimbotTab.MouseButton1Click:Connect(function() switchTab(aimbotContent) end)
espTab.MouseButton1Click:Connect(function() switchTab(espContent) end)
miscTab.MouseButton1Click:Connect(function() switchTab(miscContent) end)
otherTab.MouseButton1Click:Connect(function() switchTab(otherContent) end)
visualTab.MouseButton1Click:Connect(function() switchTab(visualContent) end)
weaponTab.MouseButton1Click:Connect(function() switchTab(weaponContent) end)
-- Flashbang Removal Loop
spawn(function()
    while RunService.RenderStepped:Wait() do
        if visualSettings.RemoveFlashEnabled and not miscSettings.UnhookEnabled then
            local flashbang = player.PlayerGui:FindFirstChild("GUI") and player.PlayerGui.GUI:FindFirstChild("Flashbang")
            if flashbang and flashbang.BackgroundTransparency < 1 then
                flashbang.BackgroundTransparency = 1
            end
        end
    end
end)
local function forceThirdPerson()
    if miscSettings.ThirdPersonEnabled then
        player.CameraMode = Enum.CameraMode.Classic
        player.CameraMinZoomDistance = 18
        player.CameraMaxZoomDistance = 18
        camera.CameraSubject = player.Character and player.Character:WaitForChild("Humanoid")
    end
end
player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.1)
    if miscSettings.ThirdPersonEnabled then
        forceThirdPerson()
    end
end)
spawn(function()
    while task.wait(0.5) do
        if miscSettings.ThirdPersonEnabled then
            if player.CameraMode ~= Enum.CameraMode.Classic then
                player.CameraMode = Enum.CameraMode.Classic
            end
            if player.CameraMinZoomDistance < 18 then
                player.CameraMinZoomDistance = 18
            end
            if player.CameraMaxZoomDistance < 18 then
                player.CameraMaxZoomDistance = 18
            end
        end
    end
end)
local function unhookCheats()
    espSettings.Enabled = false
    aimbotSettings.Enabled = false
    miscSettings.BHopEnabled = false
    miscSettings.AutoPeakEnabled = false
    miscSettings.TeleportEnabled = false
    miscSettings.ThirdPersonEnabled = false
    visualSettings.RemoveFlashEnabled = false
    espSettings.TracersEnabled = false
    weaponSettings.NoSpreadEnabled = false
    weaponSettings.WallHackEnabled = false
    weaponSettings.CustomAmmoEnabled = false
    -- weaponSettings.LockedAmmo = false -- Не используется
    weaponSettings.CustomDamageEnabled = false
    player.CameraMode = Enum.CameraMode.Classic
    player.CameraMinZoomDistance = 0.5
    player.CameraMaxZoomDistance = 128
    ScreenGui:Destroy()
    for _, otherPlayer in pairs(players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            for _, obj in pairs(otherPlayer.Character:GetChildren()) do
                if obj.Name == "NameBillboard" or obj.Name == "HpBillboard" or obj.Name == "TracerBeam" or obj:IsA("Highlight") then
                    obj:Destroy()
                end
            end
        end
    end
    if peakMarker then
        peakMarker:Destroy()
        peakMarker = nil
    end
    -- Отключение всех соединений RunService
    for _, connection in pairs(getconnections(RunService.Heartbeat)) do
        connection:Disconnect()
    end
    for _, connection in pairs(getconnections(RunService.RenderStepped)) do
        connection:Disconnect()
    end
    for _, connection in pairs(getconnections(UserInputService.InputBegan)) do
        connection:Disconnect()
    end
    for _, connection in pairs(getconnections(UserInputService.InputChanged)) do
        connection:Disconnect()
    end
    for _, connection in pairs(getconnections(UserInputService.InputEnded)) do
        connection:Disconnect()
    end
    for _, connection in pairs(getconnections(players.PlayerAdded)) do
        connection:Disconnect()
    end
    for _, connection in pairs(getconnections(players.PlayerRemoving)) do
        connection:Disconnect()
    end
    for _, connection in pairs(getconnections(player.CharacterAdded)) do
        connection:Disconnect()
    end
    -- Сбрасываем кэш оружия при отключении
    resetWeaponCache()
end
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Insert and not gameProcessed then
        menuVisible = not menuVisible
        Frame.Visible = menuVisible
        hitboxMenuOpen = false
        hitboxMenu.Visible = false
        hitboxMenu.BackgroundTransparency = 1
        for _, btn in pairs(hitboxMenu:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundTransparency = 1
                btn.TextTransparency = 1
            end
        end
    elseif (input.KeyCode == miscSettings.ThirdPersonBind or input.UserInputType == miscSettings.ThirdPersonBind) and not gameProcessed then
        miscSettings.ThirdPersonEnabled = not miscSettings.ThirdPersonEnabled
        thirdPersonState = miscSettings.ThirdPersonEnabled
        for _, child in pairs(miscContent:GetChildren()) do
            if child:IsA("TextButton") and child.Position.Y.Scale == 0.75 then
                child.BackgroundColor3 = miscSettings.ThirdPersonEnabled and Color3.fromRGB(255, 165, 0) or Color3.new(0.3, 0.3, 0.3)
            end
        end
        if miscSettings.ThirdPersonEnabled then
            forceThirdPerson()
        else
            player.CameraMode = Enum.CameraMode.Classic
            player.CameraMinZoomDistance = 0.5
            player.CameraMaxZoomDistance = 128
        end
    end
end)
local function isValidPosition(pos)
    if not pos then return false end
    return not (pos.X ~= pos.X or pos.Y ~= pos.Y or pos.Z ~= pos.Z or pos.Magnitude > aimbotSettings.maxCameraDistance)
end
local function isSameTeam(otherPlayer)
    if not player.Team or not otherPlayer.Team then
        return false
    end
    return player.Team == otherPlayer.Team
end
local function isInFOV(targetPos)
    if not isValidPosition(targetPos) then return false end
    local cameraDirection = camera.CFrame.LookVector
    local toTarget = (targetPos - camera.CFrame.Position).Unit
    local angle = math.deg(math.acos(cameraDirection:Dot(toTarget)))
    return angle <= aimbotSettings.fovAngle / 2
end
local function isWallBetween(startPos, endPos)
    if not isValidPosition(startPos) or not isValidPosition(endPos) then return true end
    raycastParams.FilterDescendantsInstances = {player.Character, workspace:FindFirstChild("Terrain") or workspace.Terrain}
    local raycastResult = workspace:Raycast(startPos, (endPos - startPos), raycastParams)
    if raycastResult then
        local hitPart = raycastResult.Instance
        if hitPart and hitPart:IsDescendantOf(workspace) and not hitPart:IsDescendantOf(player.Character) then
            return true
        end
    end
    return false
end
local function canHitPart(startPos, targetPart)
    if not isValidPosition(startPos) or not isValidPosition(targetPart.Position) then return false end
    local direction = (targetPart.Position - startPos)
    local raycastResult = workspace:Raycast(startPos, direction, raycastParams)
    if raycastResult then
        local hitPart = raycastResult.Instance
        return hitPart == targetPart
    end
    return false
end
local function getClosestToCrosshair()
    local closestPlayer, closestAngle = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local humanoid = otherPlayer.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 and not isSameTeam(otherPlayer) then
                local head = otherPlayer.Character:FindFirstChild("Head")
                if head and isValidPosition(head.Position) and isInFOV(head.Position) then
                    local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local angle = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if angle < closestAngle then
                            closestAngle = angle
                            closestPlayer = otherPlayer
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end
local function getBestEnemyInFOV()
    if aimbotSettings.targetingMethod == "Locked" and aimbotSettings.lockedTarget then
        local target = aimbotSettings.lockedTarget
        if target.Character and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 then
            local head = target.Character:FindFirstChild("Head")
            if head and isValidPosition(head.Position) and isInFOV(head.Position) then
                local playerPos = camera.CFrame.Position
                local blocked = isWallBetween(playerPos, head.Position)
                return target, not blocked
            end
        end
        aimbotSettings.lockedTarget = nil
    end
    local nearestVisible, nearestVisibleDist = nil, math.huge
    local nearestInvisible, nearestInvisibleDist = nil, math.huge
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local humanoid = otherPlayer.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if not isSameTeam(otherPlayer) then
                    local head = otherPlayer.Character:FindFirstChild("Head")
                    if head and isValidPosition(head.Position) and isInFOV(head.Position) then
                        local playerPos = camera.CFrame.Position
                        local distance = (playerPos - head.Position).Magnitude
                        local blocked = isWallBetween(playerPos, head.Position)
                        if not blocked then
                            if distance < nearestVisibleDist then
                                nearestVisibleDist = distance
                                nearestVisible = otherPlayer
                            end
                        else
                            if distance < nearestInvisibleDist then
                                nearestInvisibleDist = distance
                                nearestInvisible = otherPlayer
                            end
                        end
                    end
                end
            end
        end
    end
    if aimbotSettings.targetingMethod == "Locked" and nearestVisible then
        aimbotSettings.lockedTarget = nearestVisible
    elseif aimbotSettings.targetingMethod == "Locked" and nearestInvisible then
        aimbotSettings.lockedTarget = nearestInvisible
    end
    if nearestVisible then
        return nearestVisible, true
    elseif nearestInvisible then
        return nearestInvisible, false
    end
    return nil, false
end
local function getBestJumpAim(targetPart)
    local bestAimPos = targetPart.Position
    local playerPos = camera.CFrame.Position
    for i = 1, aimbotSettings.jumpAimVariants do
        local randomAngleX = math.rad(math.random(-1, 1) * 0.01)
        local randomAngleY = math.rad(math.random(-1, 1) * 0.01)
        local aimDir = (targetPart.Position - playerPos).Unit
        aimDir = CFrame.Angles(randomAngleX, randomAngleY, 0) * aimDir
        local aimPos = playerPos + aimDir * (targetPart.Position - playerPos).Magnitude
        if canHitPart(playerPos, targetPart) then
            local score = - (aimPos - targetPart.Position).Magnitude
            if score > -(targetPart.Position - playerPos).Magnitude then
                bestAimPos = aimPos
            end
        end
    end
    return bestAimPos
end
local function aimBot()
    if not aimbotSettings.Enabled or miscSettings.UnhookEnabled then return end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChild("Humanoid")
    if not root or not root.Parent or not humanoid or humanoid.Health <= 0 then
        aimbotSettings.lockedTarget = nil
        return
    end
    local currentTime = tick()
    if currentTime - lastUpdateTime < aimbotSettings.updateInterval then return end
    lastUpdateTime = currentTime
    isJumping = humanoid:GetState() == Enum.HumanoidStateType.Jumping or humanoid:GetState() == Enum.HumanoidStateType.Freefall
    if aimbotSettings.targetingMethod == "Locked" and not aimbotSettings.lockedTarget then
        aimbotSettings.lockedTarget = getClosestToCrosshair()
    end
    local bestEnemy, isVisible = getBestEnemyInFOV()
    if bestEnemy and bestEnemy.Character then
        local targetPart = bestEnemy.Character:FindFirstChild(aimbotSettings.selectedHitboxes[1])
        if not targetPart then
            for _, part in pairs(bestEnemy.Character:GetChildren()) do
                if part:IsA("BasePart") and isValidPosition(part.Position) then
                    targetPart = part
                    break
                end
            end
        end
        if targetPart and isValidPosition(targetPart.Position) then
            local aimPosition = targetPart.Position
            if isJumping and currentTime - lastJumpCheckTime >= aimbotSettings.jumpCheckInterval then
                lastJumpCheckTime = currentTime
                local bestAimPos = getBestJumpAim(targetPart)
                if bestAimPos then
                    aimPosition = bestAimPos
                end
            end
            if aimbotSettings.autoStopEnabled and isVisible and canHitPart(camera.CFrame.Position, targetPart) then
                local torso = player.Character and player.Character:FindFirstChild("Torso")
                if torso then
                    torso.Anchored = true
                end
            else
                local torso = player.Character and player.Character:FindFirstChild("Torso")
                if torso and torso.Anchored then
                    torso.Anchored = false
                end
            end
            local newCFrame = CFrame.new(camera.CFrame.Position, aimPosition)
            targetCFrame = targetCFrame:Lerp(newCFrame, aimbotSettings.smoothness)
            camera.CFrame = targetCFrame
            if isVisible and canHitPart(camera.CFrame.Position, targetPart) then
                VirtualUser:ClickButton1(Vector2.new())
                local torso = player.Character and player.Character:FindFirstChild("Torso")
                if torso and torso.Anchored then
                    torso.Anchored = false
                end
                if miscSettings.AutoPeakEnabled and miscSettings.AutoPeakReturnMode == "Shoot" and isAltHeld then
                    isReturning = true
                    if peakMarker then peakMarker:Destroy() end
                    peakMarker = nil
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid and initialPosition and initialCFrame and (root.Position - initialPosition).Magnitude > 1 then
                        humanoid.WalkSpeed = playerWalkSpeed
                        humanoid.CFrame = initialCFrame
                        local connection
                        connection = RunService.Heartbeat:Connect(function()
                            if (root.Position - initialPosition).Magnitude < 1 then
                                connection:Disconnect()
                                isReturning = false
                            end
                        end)
                    end
                end
            end
        end
    else
        targetCFrame = camera.CFrame
        aimbotSettings.lockedTarget = nil
    end
end
local originalWalkSpeed = player.Character and player.Character.Humanoid and player.Character.Humanoid.WalkSpeed or 16
local isSpaceHeld = false
local lastJumpTime = 0
local jumpCooldown = 0.1
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Space and not gameProcessed then
        isSpaceHeld = true
        local currentTime = tick()
        if miscSettings.BHopEnabled and player.Character and player.Character:FindFirstChild("Humanoid") and (currentTime - lastJumpTime) >= jumpCooldown then
            local humanoid = player.Character.Humanoid
            if humanoid.FloorMaterial ~= Enum.Material.Air then
                humanoid.Jump = true
                isJumping = true
                lastJumpTime = currentTime
                humanoid.WalkSpeed = 100
            end
        end
    elseif input.KeyCode == Enum.KeyCode.LeftAlt and not gameProcessed and miscSettings.AutoPeakEnabled and player.Character then
        isAltHeld = true
        if not peakMarker then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                peakWaypoints = {}
                initialPosition = rootPart.Position
                initialCFrame = rootPart.CFrame
                table.insert(peakWaypoints, rootPart.Position)
                peakMarker = Instance.new("Part")
                peakMarker.Size = Vector3.new(1, 1, 1)
                peakMarker.Position = rootPart.Position - Vector3.new(0, 0.5, 0)
                peakMarker.Anchored = true
                peakMarker.CanCollide = false
                peakMarker.Transparency = 0.5
                peakMarker.BrickColor = BrickColor.new("Orange")
                peakMarker.Parent = game.Workspace
            end
        end
    elseif input.KeyCode == miscSettings.TeleportBind and not gameProcessed and miscSettings.TeleportEnabled then
        local enemies = {}
        for _, otherPlayer in pairs(players:GetPlayers()) do
            if otherPlayer ~= player and not isSameTeam(otherPlayer) and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(enemies, otherPlayer)
            end
        end
        if #enemies > 0 then
            local randomEnemy = enemies[math.random(1, #enemies)]
            if randomEnemy.Character and randomEnemy.Character:FindFirstChild("HumanoidRootPart") then
                local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.CFrame = randomEnemy.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftAlt and miscSettings.AutoPeakEnabled and player.Character and peakMarker then
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            peakMarker.Position = rootPart.Position - Vector3.new(0, 0.5, 0)
            if #peakWaypoints == 0 or (rootPart.Position - peakWaypoints[#peakWaypoints]).Magnitude > 0.5 then
                table.insert(peakWaypoints, rootPart.Position)
            end
        end
    end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Space and not gameProcessed then
        isSpaceHeld = false
        if miscSettings.BHopEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
            isJumping = false
        end
    elseif input.KeyCode == Enum.KeyCode.LeftAlt and not gameProcessed and miscSettings.AutoPeakEnabled and player.Character and miscSettings.AutoPeakReturnMode == "KeyRelease" then
        isAltHeld = false
        if peakMarker then peakMarker:Destroy() end
        peakMarker = nil
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if humanoid and rootPart and initialPosition and initialCFrame and (rootPart.Position - initialPosition).Magnitude > 1 then
            isReturning = true
            humanoid.WalkSpeed = playerWalkSpeed
            humanoid.CFrame = initialCFrame
            local connection
            connection = RunService.Heartbeat:Connect(function()
                if (rootPart.Position - initialPosition).Magnitude < 1 then
                    connection:Disconnect()
                    isReturning = false
                end
            end)
        end
    end
end)
RunService.Heartbeat:Connect(function()
    if miscSettings.AutoPeakEnabled and player.Character and isAltHeld and not isReturning then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if humanoid and rootPart then
            humanoid.WalkSpeed = playerWalkSpeed * 2
            local targetPos = peakWaypoints[#peakWaypoints] or rootPart.Position
            local distance = (rootPart.Position - targetPos).Magnitude
            if distance > 0.5 then
                humanoid.WalkToPoint = targetPos
            end
        end
    end
    if not miscSettings.UnhookEnabled then
        aimBot()
        -- Обновление оружия в Heartbeat вместо отдельного spawn
        updateWeaponSettings()
    end
end)
player.CharacterAdded:Connect(function(character)
    if character and character:FindFirstChild("Humanoid") then
        originalWalkSpeed = character.Humanoid.WalkSpeed
        playerWalkSpeed = originalWalkSpeed
        character.Humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
            if miscSettings.BHopEnabled and character.Humanoid.FloorMaterial ~= Enum.Material.Air then
                local currentTime = tick()
                if isSpaceHeld and character.Humanoid and (currentTime - lastJumpTime) >= jumpCooldown then
                    character.Humanoid.Jump = true
                    isJumping = true
                    lastJumpTime = currentTime
                    character.Humanoid.WalkSpeed = 100
                elseif isJumping and character.Humanoid then
                    isJumping = false
                end
            end
        end)
        peakWaypoints = {}
        isReturning = false
        if peakMarker then peakMarker:Destroy() end
        peakMarker = nil
        initialPosition = character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Position
        initialCFrame = character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.CFrame
    end
end)
RunService.Heartbeat:Connect(function()
    if miscSettings.BHopEnabled and player.Character and player.Character:FindFirstChild("Humanoid") and isJumping and player.Character.Humanoid.FloorMaterial == Enum.Material.Air then
        local humanoid = player.Character.Humanoid
        if humanoid.WalkSpeed ~= 100 then
            humanoid.WalkSpeed = 100
        end
    elseif player.Character and player.Character:FindFirstChild("Humanoid") and not miscSettings.BHopEnabled then
        player.Character.Humanoid.WalkSpeed = miscSettings.WalkSpeed
    end
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        playerWalkSpeed = player.Character.Humanoid.WalkSpeed
    end
end)
-- Список оружия (добавь в начало файла, до всех функций)
local weaponList = {
    "AK47", "AUG", "AWP", "Bizon", "DesertEagle", "DualBerettas", "Famas", "FiveSeven",
    "G3SG1", "Galil", "Glock", "M249", "M4A1", "M4A4", "MAC10", "MAG7", "MP7",
    "MP7-SD", "MP9", "Negev", "Nova", "P2000", "P250", "P90", "R8", "SG",
    "SawedOff", "Scout", "Tec9", "UMP", "USP", "XM"
}
local function addVisualsToCharacter(character, otherPlayer)
    if not character or not character:FindFirstChild("Humanoid") or character == player.Character or not settings.esp.Enabled or settings.misc.UnhookEnabled then
        if character and character ~= player.Character then
            for _, obj in pairs(character:GetChildren()) do
                if obj.Name == "NameBillboard" or obj.Name == "HpBillboard" or obj.Name == "TracerBeam" or obj:IsA("Highlight") then
                    obj:Destroy()
                end
            end
        end
        return
    end
    local head = character:FindFirstChild("Head")
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not head or not humanoid or not rootPart then return end
    local teamColor = isSameTeam(otherPlayer) and espSettings.Team.Color or espSettings.Enemy.Color
    local isTeamEnabled = isSameTeam(otherPlayer) and espSettings.Team.Enabled or espSettings.Enemy.Enabled
    if not isTeamEnabled then
        for _, obj in pairs(character:GetChildren()) do
            if obj.Name == "NameBillboard" or obj.Name == "HpBillboard" or obj.Name == "TracerBeam" or obj:IsA("Highlight") then
                obj:Destroy()
            end
        end
        return
    end
    -- Name Billboard
    if espSettings.ShowNames then
        local nameBillboard = character:FindFirstChild("NameBillboard")
        if not nameBillboard then
            nameBillboard = Instance.new("BillboardGui")
            nameBillboard.Name = "NameBillboard"
            nameBillboard.Parent = character
            nameBillboard.Adornee = head
            nameBillboard.Size = UDim2.new(0, 100, 0, 30)
            nameBillboard.StudsOffset = Vector3.new(0, 2, 0)
            nameBillboard.AlwaysOnTop = true
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Parent = nameBillboard
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = otherPlayer.Name
            nameLabel.TextColor3 = teamColor
            nameLabel.TextSize = 14
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextStrokeTransparency = 0.5
        end
    else
        local nameBillboard = character:FindFirstChild("NameBillboard")
        if nameBillboard then
            nameBillboard:Destroy()
        end
    end
    -- HP Billboard
    if espSettings.ShowHP then
        local hpBillboard = character:FindFirstChild("HpBillboard")
        if not hpBillboard then
            hpBillboard = Instance.new("BillboardGui")
            hpBillboard.Name = "HpBillboard"
            hpBillboard.Parent = character
            hpBillboard.Adornee = head
            hpBillboard.Size = UDim2.new(0, 100, 0, 30)
            hpBillboard.StudsOffset = Vector3.new(0, 1, 0)
            hpBillboard.AlwaysOnTop = true
            local hpLabel = Instance.new("TextLabel")
            hpLabel.Parent = hpBillboard
            hpLabel.Size = UDim2.new(1, 0, 1, 0)
            hpLabel.BackgroundTransparency = 1
            hpLabel.Text = "HP: " .. math.floor(humanoid.Health)
            hpLabel.TextColor3 = teamColor
            hpLabel.TextSize = 14
            hpLabel.Font = Enum.Font.Gotham
            hpLabel.TextStrokeTransparency = 0.5
        else
            local hpLabel = hpBillboard:FindFirstChildOfClass("TextLabel")
            if hpLabel then
                hpLabel.Text = "HP: " .. math.floor(humanoid.Health)
            end
        end
    else
        local hpBillboard = character:FindFirstChild("HpBillboard")
        if hpBillboard then
            hpBillboard:Destroy()
        end
    end
    -- Highlight
    if espSettings.Highlight then
        local highlight = character:FindFirstChildOfClass("Highlight")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Parent = character
            highlight.Adornee = character
            highlight.FillColor = teamColor
            highlight.OutlineColor = teamColor
            highlight.FillTransparency = 0.7
            highlight.OutlineTransparency = 0
        end
    else
        local highlight = character:FindFirstChildOfClass("Highlight")
        if highlight then
            highlight:Destroy()
        end
    end
    -- Tracers
    if espSettings.TracersEnabled then
        local tracerBeam = character:FindFirstChild("TracerBeam")
        if not tracerBeam then
            tracerBeam = Instance.new("Beam")
            tracerBeam.Name = "TracerBeam"
            tracerBeam.Parent = character
            tracerBeam.Color = ColorSequence.new(teamColor)
            tracerBeam.Width0 = 0.1
            tracerBeam.Width1 = 0.1
            tracerBeam.LightEmission = 1
            tracerBeam.LightInfluence = 0
            tracerBeam.TextureMode = Enum.TextureMode.Stretch
            tracerBeam.Enabled = true
            local attachment0 = Instance.new("Attachment")
            attachment0.Parent = camera
            attachment0.WorldPosition = camera.CFrame.Position
            local attachment1 = Instance.new("Attachment")
            attachment1.Parent = rootPart
            attachment1.WorldPosition = rootPart.Position
            tracerBeam.Attachment0 = attachment0
            tracerBeam.Attachment1 = attachment1
        else
            local attachment0 = tracerBeam.Attachment0
            local attachment1 = tracerBeam.Attachment1
            if attachment0 and attachment1 then
                attachment0.WorldPosition = camera.CFrame.Position
                attachment1.WorldPosition = rootPart.Position
            end
        end
    else
        local tracerBeam = character:FindFirstChild("TracerBeam")
        if tracerBeam then
            tracerBeam:Destroy()
        end
    end
end
local function updateAllVisuals()
    for _, otherPlayer in pairs(players:GetPlayers()) do
        if otherPlayer.Character then
            addVisualsToCharacter(otherPlayer.Character, otherPlayer)
        end
    end
end
players.PlayerAdded:Connect(function(newPlayer)
    newPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.1)
        addVisualsToCharacter(character, newPlayer)
    end)
end)
players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer.Character then
        for _, obj in pairs(leavingPlayer.Character:GetChildren()) do
            if obj.Name == "NameBillboard" or obj.Name == "HpBillboard" or obj.Name == "TracerBeam" or obj:IsA("Highlight") then
                obj:Destroy()
            end
        end
    end
end)
RunService.RenderStepped:Connect(function()
    if espSettings.Enabled and not miscSettings.UnhookEnabled then
        updateAllVisuals()
    else
        for _, otherPlayer in pairs(players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                for _, obj in pairs(otherPlayer.Character:GetChildren()) do
                    if obj.Name == "NameBillboard" or obj.Name == "HpBillboard" or obj.Name == "TracerBeam" or obj:IsA("Highlight") then
                        obj:Destroy()
                    end
                end
            end
        end
    end
end)
-- Ensure visuals are applied to existing players
for _, otherPlayer in pairs(players:GetPlayers()) do
    if otherPlayer.Character then
        addVisualsToCharacter(otherPlayer.Character, otherPlayer)
    end
end
