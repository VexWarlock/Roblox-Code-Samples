local PathfindingService = game:GetService("PathfindingService")


local RANGE = 60
local DAMAGE = 0


local npc = script.Parent
local humanoid = npc:WaitForChild("Humanoid")
local hrp = npc:WaitForChild("HumanoidRootPart")
hrp:SetNetworkOwner(nil)

local walkAnim = humanoid.Animator:LoadAnimation(script.Walk)
local attackAnim = humanoid.Animator:LoadAnimation(script.Attack)

local pathParams=
{
	AgentHeight = 5,
	AgentRadius = 3,
	AgentCanJump = true,
}

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist
rayParams.FilterDescendantsInstances = {npc}

local lastPos
local animPlaying = false


local function canSeeTarget(target)
	local orgin = hrp.Position
	local direction = (target.HumanoidRootPart.Position - hrp.Position).Unit * RANGE
	local ray = workspace:Raycast(orgin, direction, rayParams)
	
	if ray and ray.Instance then
		if ray.Instance:IsDescendantOf(target) then
			return true
		else
			return false
		end
	else
		return false
	end
end

local function findTarget()
	local players = game.Players:GetPlayers()
	local maxDistance = RANGE
	local nearestTarget
	
	for i, player in pairs(players) do
		if player.Character then
			local target = player.Character
			local distance = (hrp.Position - target.HumanoidRootPart.Position).Magnitude
			
			if distance < maxDistance and canSeeTarget(target) then
				nearestTarget = target
				maxDistance = distance
			end
		end
	end
	
	return nearestTarget
end

local function getPath(destination)
	local path = PathfindingService:CreatePath(pathParams)
	
	path:ComputeAsync(hrp.Position, destination.Position)
	
	return path	
end

local function attack(target)
	local distance = (hrp.Position - target.HumanoidRootPart.Position).Magnitude
	local debounce = false
	
	if distance > 5 then
		humanoid:MoveTo(target.HumanoidRootPart.Position)
	else
		if debounce == false then
			debounce = true
			
			npc.Head.AttackSound:Play()
			attackAnim:Play()
			target.Humanoid.Health -= DAMAGE
			task.wait(0.5)
			debounce = false
		end
	end
end

local function walkTo(destination)
	local path = getPath(destination)
	
	if path.Status == Enum.PathStatus.Success then
		for i, waypoint in pairs(path:GetWaypoints()) do
			path.Blocked:Connect(function()
				path:Destroy()
			end)
			
			if animPlaying == false then
				walkAnim:Play()
				animPlaying = true
			end
			
			attackAnim:Stop()
			
			local target = findTarget()
			
			if target and target.Humanoid.Health > 0 then
				lastPos = target.HumanoidRootPart.Position
				attack(target)
				break
			else
				if waypoint.Action == Enum.PathWaypointAction.Jump then
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
				
				if lastPos then
					humanoid:MoveTo(lastPos)
					humanoid.MoveToFinished:Wait()
					lastPos = nil
					break
				else
					humanoid:MoveTo(waypoint.Position)
					humanoid.MoveToFinished:Wait()
				end
			end
		end
	else
		return
	end
end

local function patrol()
	local waypoints = workspace.Waypoints:GetChildren()
	local randomNum = math.random(1, #waypoints)
	walkTo(waypoints[randomNum])
end


while task.wait(0.2) do
	patrol()
end
