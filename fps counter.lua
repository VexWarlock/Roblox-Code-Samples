--ReplicatedFirst -> ModuleScript
local RunService = game:GetService("RunService")

local FPSCounter = {}
FPSCounter.__index = FPSCounter

local DEFAULT_SAMPLE_WINDOW = 0.5

function FPSCounter.new(sampleWindow: number?)
	local self = setmetatable({}, FPSCounter)

	self.sampleWindow = sampleWindow or DEFAULT_SAMPLE_WINDOW
	self._enabled = false

	self._accumulatedTime = 0
	self._frameCount = 0
	self._fps = 0

	self._connection = nil
	self._onUpdate = nil

	return self
end

function FPSCounter:_step(dt)
	self._accumulatedTime += dt
	self._frameCount += 1

	if self._accumulatedTime >= self.sampleWindow then
		self._fps = self._frameCount / self._accumulatedTime
		
		self._accumulatedTime = 0
		self._frameCount = 0
		
		if self._onUpdate then
			self._onUpdate(self._fps)
		end
	end
end

function FPSCounter:Enable(onUpdateCallback: ((number) -> ())?)
	if self._enabled then
		return
	end

	self._enabled = true
	self._onUpdate = onUpdateCallback

	self._accumulatedTime = 0
	self._frameCount = 0

	self._connection = RunService.RenderStepped:Connect(function(dt)
		self:_step(dt)
	end)
end

function FPSCounter:Disable()
	if not self._enabled then
		return
	end

	self._enabled = false

	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end
end

function FPSCounter:GetFPS(): number
	return self._fps
end

function FPSCounter:IsEnabled(): boolean
	return self._enabled
end

return FPSCounter
