local UIS = game:GetService("UserInputService")

local Crouching = false
local Character = script.Parent
local Humanoid = Character:WaitForChild("Humanoid")

local ProneMoveAnimation = script.ProneMoveAnimation
local ProneIdleAnimation = script.ProneIdleAnimation

local MoveTrack = nil
local IdleTrack = nil

local function toggleCrouch()
	if Crouching == false then
		Crouching = true

		if not IdleTrack then
			IdleTrack = Humanoid:LoadAnimation(ProneIdleAnimation)
		end
		IdleTrack:Play()

		Humanoid.HipHeight -= 2.1
		Humanoid.WalkSpeed = 8
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	else
		Crouching = false

		if MoveTrack then MoveTrack:Stop() end
		if IdleTrack then IdleTrack:Stop() end

		Humanoid.HipHeight += 2.1
		Humanoid.WalkSpeed = 16
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	end
end

UIS.InputBegan:Connect(function(key)
	if key.KeyCode == Enum.KeyCode.X then
		toggleCrouch()
	end
end)

Humanoid.Running:Connect(function(speed)
	if Crouching then
		if speed > 1 then
			if IdleTrack and IdleTrack.IsPlaying then
				IdleTrack:Stop()
			end
			if not MoveTrack then
				MoveTrack = Humanoid:LoadAnimation(ProneMoveAnimation)
			end
			if not MoveTrack.IsPlaying then
				MoveTrack:Play()
			end
		else
			if MoveTrack and MoveTrack.IsPlaying then
				MoveTrack:Stop()
			end
			if IdleTrack and not IdleTrack.IsPlaying then
				IdleTrack:Play()
			end
		end
	end
end)
