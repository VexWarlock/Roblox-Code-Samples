--StarterGUI -> ScreenGUI -> Frame -> Localscript
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")

local minimapFrame = script.Parent
local viewport = minimapFrame:WaitForChild("ViewportFrame")

-- Camera pentru minimap
local camera = Instance.new("Camera")
viewport.CurrentCamera = camera
camera.FieldOfView = 20

local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- Clonăm TOT Workspace-ul (cu excepții)
local clonedMap = Instance.new("Folder")
clonedMap.Name = "MinimapMap"
clonedMap.Parent = viewport

for _, obj in ipairs(workspace:GetChildren()) do
	-- Excludem obiectele care NU pot fi clonate sau NU vrem sa apară în minimap
	if
		obj ~= character and         -- nu clonăm playerul
		not obj:IsA("Terrain") and   -- terrain nu poate fi clonat
		not obj:IsA("Camera") and
		not obj:IsA("Folder") and obj.Name ~= "MinimapIgnore" and
		obj ~= viewport and
		obj ~= minimapFrame and
		obj ~= script
	then
		local clone
		pcall(function()
			clone = obj:Clone()      -- clone poate da erori -> protejat cu pcall
		end)

		if clone then
			clone.Parent = clonedMap
		end
	end
end

-- Actualizare camera minimap
runService.RenderStepped:Connect(function()
	if not hrp then return end

	local height = 300

	camera.CFrame =
		CFrame.new(
			hrp.Position.X,
			hrp.Position.Y + height,
			hrp.Position.Z
		) * CFrame.Angles(math.rad(-90), 0, 0)

	-- Rotire minimap după player
	local _, ry, _ = hrp.CFrame:ToEulerAnglesYXZ()
	viewport.Rotation = math.deg(ry)
end)
