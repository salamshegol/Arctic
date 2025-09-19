local InjectionGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local LoadingMenu = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local ARMFree = Instance.new("Frame")
local LoadButton = Instance.new("TextButton")
local UICorner_2 = Instance.new("UICorner")
local ImageLabel = Instance.new("ImageLabel")
local TextArithmetic = Instance.new("TextLabel")
local LastUpdated = Instance.new("TextLabel")
local UICorner_3 = Instance.new("UICorner")
local ARMFreeButton = Instance.new("TextButton")
local UICorner_4 = Instance.new("UICorner")

InjectionGui.Name = "InjectionGui"
InjectionGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
InjectionGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = InjectionGui
Frame.BackgroundColor3 = Color3.fromRGB(24, 26, 31)
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.30120483, 0, 0.314385146, 0)
Frame.Size = UDim2.new(0, 316, 0, 222)

LoadingMenu.Name = "LoadingMenu"
LoadingMenu.Parent = Frame
LoadingMenu.BackgroundColor3 = Color3.fromRGB(24, 26, 31)
LoadingMenu.BackgroundTransparency = 0.05
LoadingMenu.BorderColor3 = Color3.fromRGB(0, 0, 0)
LoadingMenu.BorderSizePixel = 0
LoadingMenu.Position = UDim2.new(1.02100801, 0, 0.000665613101, 0)
LoadingMenu.Size = UDim2.new(0, 105, 0, 222)

UICorner.CornerRadius = UDim.new(0, 4)
UICorner.Parent = LoadingMenu

ARMFree.Name = "ARMFree"
ARMFree.Parent = LoadingMenu
ARMFree.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ARMFree.BackgroundTransparency = 1.0
ARMFree.BorderColor3 = Color3.fromRGB(0, 0, 0)
ARMFree.BorderSizePixel = 0
ARMFree.Size = UDim2.new(1, 0, 1, 0)
ARMFree.Visible = false 

LoadButton.Name = "LoadButton"
LoadButton.Parent = ARMFree
LoadButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LoadButton.BackgroundTransparency = 0.95
LoadButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
LoadButton.BorderSizePixel = 0
LoadButton.Position = UDim2.new(0.0857142881, 0, 0.837837815, 0)
LoadButton.Size = UDim2.new(0, 86, 0, 27)
LoadButton.Font = Enum.Font.SourceSans
LoadButton.Text = "Load"
LoadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadButton.TextScaled = true
LoadButton.TextSize = 14.0
LoadButton.TextWrapped = true

UICorner_2.CornerRadius = UDim.new(0, 5)
UICorner_2.Parent = LoadButton

ImageLabel.Parent = ARMFree
ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageLabel.BackgroundTransparency = 1.0
ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
ImageLabel.BorderSizePixel = 0
ImageLabel.Position = UDim2.new(0.2, 0, 0.0495495498, 0)
ImageLabel.Size = UDim2.new(0, 62, 0, 62)
ImageLabel.Image = "rbxassetid://95218971049577"
ImageLabel.ScaleType = Enum.ScaleType.Crop

TextArithmetic.Name = "TextArithmetic"
TextArithmetic.Parent = ARMFree
TextArithmetic.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextArithmetic.BackgroundTransparency = 1.0
TextArithmetic.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextArithmetic.BorderSizePixel = 0
TextArithmetic.Position = UDim2.new(0.0857142881, 0, 0.328828841, 0)
TextArithmetic.Size = UDim2.new(0, 86, 0, 21)
TextArithmetic.Font = Enum.Font.SourceSans
TextArithmetic.Text = "Arithmetic (Free)"
TextArithmetic.TextColor3 = Color3.fromRGB(255, 255, 255)
TextArithmetic.TextScaled = true
TextArithmetic.TextSize = 14.0
TextArithmetic.TextWrapped = true

LastUpdated.Name = "LastUpdated"
LastUpdated.Parent = ARMFree
LastUpdated.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LastUpdated.BackgroundTransparency = 1.0
LastUpdated.BorderColor3 = Color3.fromRGB(0, 0, 0)
LastUpdated.BorderSizePixel = 0
LastUpdated.Position = UDim2.new(0.0857142881, 0, 0.711711705, 0)
LastUpdated.Size = UDim2.new(0, 86, 0, 21)
LastUpdated.Font = Enum.Font.SourceSans
LastUpdated.Text = "Last updated: 01.01.0101"
LastUpdated.TextColor3 = Color3.fromRGB(255, 255, 255)
LastUpdated.TextScaled = true
LastUpdated.TextSize = 14.0
LastUpdated.TextWrapped = true

UICorner_3.CornerRadius = UDim.new(0, 3)
UICorner_3.Parent = Frame

ARMFreeButton.Name = "ARMFreeButton"
ARMFreeButton.Parent = Frame
ARMFreeButton.BackgroundColor3 = Color3.fromRGB(30, 33, 39)
ARMFreeButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
ARMFreeButton.BorderSizePixel = 0
ARMFreeButton.Position = UDim2.new(0.03164557, 0, 0.0495495498, 0)
ARMFreeButton.Size = UDim2.new(0, 298, 0, 30)
ARMFreeButton.Font = Enum.Font.SourceSans
ARMFreeButton.Text = "Arithmetic (Free)"
ARMFreeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ARMFreeButton.TextScaled = true
ARMFreeButton.TextSize = 14.0
ARMFreeButton.TextWrapped = true

UICorner_4.CornerRadius = UDim.new(0, 3)
UICorner_4.Parent = ARMFreeButton

local lastUpdated = game:HttpGet("https://raw.githubusercontent.com/salamshegol/Arithmetic/main/ARMFree/lastupdated.txt")
LastUpdated.Text = "Last Updated " .. lastUpdated

ARMFreeButton.MouseButton1Click:Connect(function()
	ARMFree.Visible = not ARMFree.Visible
end)

LoadButton.MouseButton1Click:Connect(function()
	local url = "https://raw.githubusercontent.com/salamshegol/Arithmetic/main/ARMFree/ARMFree.lua"
	local success, result = pcall(function()
		return game:HttpGet(url)
	end)
	if success and result then
		loadstring(result)()
		InjectionGui:Destroy() 
	end
end)
