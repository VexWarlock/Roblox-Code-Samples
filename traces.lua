--StarterCharacterScripts -> Localscript
local rainbowColors= 
{
	Color3.fromRGB(255, 0, 0),      -- red
	Color3.fromRGB(255, 63, 0),     -- red-orange
	Color3.fromRGB(255, 127, 0),    -- orange
	Color3.fromRGB(255, 191, 0),    -- orange-yellow
	Color3.fromRGB(255, 255, 0),    -- yellow
	Color3.fromRGB(127, 255, 0),    -- yellow-green
	Color3.fromRGB(0, 255, 0),      -- green
	Color3.fromRGB(0, 255, 127),    -- green-blue
	Color3.fromRGB(0, 255, 255),    -- cyan
	Color3.fromRGB(0, 191, 255),    -- aqua
	Color3.fromRGB(0, 0, 255),      -- blue
	Color3.fromRGB(75, 0, 130),     -- indigo
	Color3.fromRGB(138, 0, 255),    -- indigo-violet
	Color3.fromRGB(148, 0, 211)     -- violet
}

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local runService = game:GetService("RunService")
local colorIndex = 1
local lastPosition = character.HumanoidRootPart.Position
local speedThreshold = 0.1

local function createClone()
	if not character or not character.PrimaryPart then return end

	local cloneModel = Instance.new("Model")
	cloneModel.Name = "RainbowClone"
	cloneModel.Parent = workspace

	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") and not part:IsA("UnionOperation") then
			local clonedPart = Instance.new("Part")
			clonedPart.Name = part.Name
			clonedPart.Size = part.Size
			clonedPart.CFrame = part.CFrame
			clonedPart.Color = rainbowColors[colorIndex]
			clonedPart.Material = Enum.Material.Neon
			clonedPart.Anchored = true
			clonedPart.CanCollide = false
			clonedPart.CanTouch = false
			clonedPart.Parent = cloneModel
		end
	end

	colorIndex = colorIndex + 1
	if colorIndex > #rainbowColors then
		colorIndex = 1
	end

	game.Debris:AddItem(cloneModel, 3)
end

local function isMoving()
	local currentPosition = character.HumanoidRootPart.Position
	local distance = (currentPosition - lastPosition).Magnitude
	lastPosition = currentPosition
	return distance > speedThreshold
end

while task.wait(0.05) do
	if isMoving() then
		createClone()
	end
end
