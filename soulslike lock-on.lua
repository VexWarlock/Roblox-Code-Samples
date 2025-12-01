--StarterPlayerScripts -> localscript
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")


local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local LOCKON_KEY = Enum.UserInputType.MouseButton3
local LOCK_RANGE = 100
local isLocked = false
local lockedTarget = nil
local arrowGui = nil
local targetDiedConnection = nil


local function releaseLock()
	isLocked = false
	Camera.CameraType = Enum.CameraType.Custom
	lockedTarget = nil

	local char = LocalPlayer.Character
	if char then
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.AutoRotate = true
		end
	end

	if arrowGui then
		arrowGui:Destroy()
		arrowGui = nil
	end

	if targetDiedConnection then
		targetDiedConnection:Disconnect()
		targetDiedConnection = nil
	end
end

local function createArrow()
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "LockOnArrow"
	billboard.Size = UDim2.new(0, 32, 0, 32)
	billboard.StudsOffset = Vector3.new(0, 5, 0)
	billboard.AlwaysOnTop = true

	local image = Instance.new("ImageLabel")
	image.Size = UDim2.new(1, 0, 1, 0)
	image.BackgroundTransparency = 1
	image.Image = "rbxassetid://140700456064009"
	image.Parent = billboard

	return billboard
end

local function isTargetVisible(targetPart)
	local origin = Camera.CFrame.Position
	local direction = (targetPart.Position - origin)

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart:FindFirstAncestorOfClass("Model")}
	rayParams.IgnoreWater = true

	local rayResult = workspace:Raycast(origin, direction, rayParams)
	if rayResult then
		if rayResult.Instance and not rayResult.Instance:IsDescendantOf(targetPart.Parent) then
			return false
		end
	end
	return true
end

local function getNearestVisibleHumanoid()
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end

	local minDist = LOCK_RANGE
	local closestHRP = nil

	local function checkModel(model)
		local humanoid = model:FindFirstChildOfClass("Humanoid")
		local hrp = model:FindFirstChild("HumanoidRootPart")
		if humanoid and hrp and humanoid.Health > 0 then
			local dist = (hrp.Position - char.HumanoidRootPart.Position).Magnitude
			if dist < minDist and isTargetVisible(hrp) then
				minDist = dist
				closestHRP = hrp
			end
		end
	end

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			checkModel(player.Character)
		end
	end

	for _, model in ipairs(workspace:GetDescendants()) do
		if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
			if not Players:GetPlayerFromCharacter(model) then
				checkModel(model)
			end
		end
	end

	return closestHRP
end

local function lockOnTarget(target)
	if not target then return end
	local char = LocalPlayer.Character
	if not char then return end

	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	isLocked = true
	lockedTarget = target
	Camera.CameraType = Enum.CameraType.Scriptable
	humanoid.AutoRotate = false

	if arrowGui then
		arrowGui:Destroy()
		arrowGui = nil
	end

	arrowGui = createArrow()
	arrowGui.Parent = target

	local targetModel = target:FindFirstAncestorOfClass("Model")
	if targetModel then
		local targetHumanoid = targetModel:FindFirstChildOfClass("Humanoid")
		if targetHumanoid then
			if targetDiedConnection then
				targetDiedConnection:Disconnect()
				targetDiedConnection = nil
			end
			targetDiedConnection = targetHumanoid.Died:Connect(function()
				releaseLock()
				local nextTarget = getNearestVisibleHumanoid()
				if nextTarget then
					lockOnTarget(nextTarget)
				end
			end)
		end
	end
end

local function monitorPlayerDeath()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local humanoid = char:WaitForChild("Humanoid", 5)
	if humanoid then
		humanoid.Died:Connect(function()
			releaseLock()
		end)
	end
end

LocalPlayer.CharacterAdded:Connect(function()
	monitorPlayerDeath()
end)

if LocalPlayer.Character then
	monitorPlayerDeath()
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == LOCKON_KEY then
		local char = LocalPlayer.Character
		if not char then return end
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then return end

		if isLocked then
			releaseLock()
		else
			local target = getNearestVisibleHumanoid()
			if target then
				lockOnTarget(target)
			end
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if isLocked and lockedTarget and lockedTarget.Parent and lockedTarget:IsDescendantOf(workspace) then
		local char = LocalPlayer.Character
		if not char or not char:FindFirstChild("HumanoidRootPart") then
			releaseLock()
			return
		end

		local myHRP = char.HumanoidRootPart
		local targetPos = lockedTarget.Position + Vector3.new(0, 2, 0)

		local ignoreList = {
			char,
			lockedTarget:FindFirstAncestorOfClass("Model")
		}
		local rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Blacklist
		rayParams.FilterDescendantsInstances = ignoreList
		rayParams.IgnoreWater = true

		local origin = Camera.CFrame.Position
		local direction = (targetPos - origin)
		local rayResult = workspace:Raycast(origin, direction, rayParams)

		if rayResult then
			local hit = rayResult.Instance
			if hit and hit:IsA("BasePart") and hit.CanCollide and hit.Transparency <= 0.5 then
				releaseLock()
				return
			end
		end

		local distToTarget = (lockedTarget.Position - myHRP.Position).Magnitude
		if distToTarget > LOCK_RANGE then
			releaseLock()
			return
		end

		local offset = Vector3.new(0, 5, 12)
		local cameraPos = myHRP.Position - myHRP.CFrame.LookVector * offset.Z + Vector3.new(0, offset.Y, 0)
		Camera.CFrame = CFrame.new(cameraPos, targetPos)

		local lookDir = (targetPos - myHRP.Position).Unit
		local desiredRotation = CFrame.new(myHRP.Position, myHRP.Position + Vector3.new(lookDir.X, 0, lookDir.Z))
		myHRP.CFrame = myHRP.CFrame:Lerp(desiredRotation, 0.15)

	elseif Camera.CameraType == Enum.CameraType.Scriptable then
		Camera.CameraType = Enum.CameraType.Custom
	end
end)
