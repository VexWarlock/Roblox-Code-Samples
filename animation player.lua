--Rig -> script

--Pentru Rig-uri cu Humanoid+Animator
local model=script.Parent
local humanoid=model:WaitForChild("Humanoid")
local animator=humanoid:FindFirstChildOfClass("Animator")
local animation=animator:WaitForChild("Animation")

local track=animator:LoadAnimation(animation)


track.Looped = true
track:Play()


--Pentru Rig-uri cu AnimationController
local model=script.Parent
local controller=model:WaitForChild("AnimationController")
local animation=controller:WaitForChild("Animation")

local track=controller:LoadAnimation(animation)


track.Looped = true
track:Play()
