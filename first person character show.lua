--StarterCharacterScripts -> localscript
local Players=game:GetService("Players")


local Camera=workspace.CurrentCamera
local Player=Players.LocalPlayer
local Character=script.Parent
local Humanoid=Character.Humanoid


Player.CameraMode=Enum.CameraMode.LockFirstPerson
Camera.FieldOfView=100
Humanoid.CameraOffset=Vector3.new(0,0,-1.5)

for _,child in pairs(Character:GetChildren()) do
	if child:IsA("BasePart") and child.Name~="Head" then

		child:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
			child.LocalTransparencyModifier=child.Transparency
		end)

		child.LocalTransparencyModifier=child.Transparency
	end
end

Ccamera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
	if Camera.CameraSubject:IsA("VehicleSeat") then
		Camera.CameraSubject=Humanoid
	end
end)
