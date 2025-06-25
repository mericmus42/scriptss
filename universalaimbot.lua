local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Toggles = {
	Aimlock = false,
	TeamCheck = false,
	VisibleCheck = false,
	FOVToggle = true,
	Chams = false,
	NameESP = false,
	TeamCheck2 = false,
	KillAll = false,
	KillEnemies = false,
	Fly = false,
	FlyEnabled = false,
	NoClip = false,
	InfiniteJump = false,
	SpinBot = false,
	FakeLag = false,
}
local Settings = {
	FOVRadius = 100,
	Smoothness = 0.5,
	FlySpeed = 50,
	SpinBotSpeed = 20,
	FakeLagDelay = 0.08,
}
local LockedTarget = nil
local TpOnClickEnabled = false
local noClipConn
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.new(1, 0, 0)
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Visible = false

local Window = Rayfield:CreateWindow({
	Name = "mericmus42's Aimbot&ESP&More",
	LoadingTitle = "Loading...",
	LoadingSubtitle = "The fun shit (:",
	ConfigurationSaving = { Enabled = false }
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local TeleportTab = Window:CreateTab("Teleport", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)
local FunTab = Window:CreateTab("Fun", 4483362458)

-- Combat UI
CombatTab:CreateToggle({
	Name = "Enable Aimlock",
	CurrentValue = false,
	Callback = function(v) Toggles.Aimlock = v end
})
CombatTab:CreateToggle({
	Name = "Team Check",
	CurrentValue = false,
	Callback = function(v) Toggles.TeamCheck = v end
})
CombatTab:CreateToggle({
	Name = "Visible Check",
	CurrentValue = false,
	Callback = function(v) Toggles.VisibleCheck = v end
})
CombatTab:CreateToggle({
	Name = "FOV Circle",
	CurrentValue = true,
	Callback = function(v) Toggles.FOVToggle = v end
})
CombatTab:CreateSlider({
	Name = "FOV Radius",
	Range = {50, 300},
	Increment = 1,
	CurrentValue = Settings.FOVRadius,
	Callback = function(v) Settings.FOVRadius = v end
})
CombatTab:CreateSlider({
	Name = "Smoothness",
	Range = {0, 1},
	Increment = 0.01,
	CurrentValue = Settings.Smoothness,
	Callback = function(v) Settings.Smoothness = v end
})

-- Visuals UI
VisualsTab:CreateToggle({
	Name = "Chams",
	CurrentValue = false,
	Callback = function(v) Toggles.Chams = v end
})
VisualsTab:CreateToggle({
	Name = "Name ESP",
	CurrentValue = false,
	Callback = function(v) Toggles.NameESP = v end
})
VisualsTab:CreateToggle({
	Name = "Team Check (Enable before chams)",
	CurrentValue = false,
	Callback = function(v) Toggles.TeamCheck2 = v end
})


-- Aimlock Functions
local function isAlive(plr)
	local char = plr.Character
	return char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0
end

local function isVisible(part)
	local origin = Camera.CFrame.Position
	local direction = (part.Position - origin)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	local result = workspace:Raycast(origin, direction, raycastParams)
	return result and result.Instance and result.Instance:IsDescendantOf(part.Parent)
end

local function getNearestTarget()
	local mousePos = UserInputService:GetMouseLocation()
	local closest, shortest = nil, math.huge
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and isAlive(player) then
			if Toggles.TeamCheck and player.Team == LocalPlayer.Team then
				continue
			end
			local char = player.Character
			local part = char and char:FindFirstChild("Head")
			if part then
				local screen, onScreen = Camera:WorldToViewportPoint(part.Position)
				if onScreen then
					local dist = (Vector2.new(screen.X, screen.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
					if dist < shortest and (not Toggles.FOVToggle or dist <= Settings.FOVRadius) then
						if not Toggles.VisibleCheck or isVisible(part) then
							shortest = dist
							closest = player
						end
					end
				end
			end
		end
	end
	return closest
end

RunService.RenderStepped:Connect(function()
	if Toggles.Aimlock then
		if not LockedTarget or not isAlive(LockedTarget) then
			LockedTarget = getNearestTarget()
		end
		if LockedTarget and isAlive(LockedTarget) and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			local root = LockedTarget.Character and LockedTarget.Character:FindFirstChild("Head")
			if root and (not Toggles.VisibleCheck or isVisible(root)) then
				local targetCFrame = CFrame.new(Camera.CFrame.Position, root.Position)
				Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 - Settings.Smoothness)
			end
		else
			LockedTarget = nil
		end
	else
		LockedTarget = nil
	end
end)

RunService.RenderStepped:Connect(function()
	FOVCircle.Position = UserInputService:GetMouseLocation()
	FOVCircle.Radius = Settings.FOVRadius
	FOVCircle.Visible = Toggles.FOVToggle and Toggles.Aimlock
end)

-- Chams & Name ESP
local function applyHighlight(player)
	local char = player.Character
	if not char or char:FindFirstChild("Highlight") then return end

	local h = Instance.new("Highlight")
	h.Name = "Highlight"

	if Toggles.TeamCheck2 and player.Team == LocalPlayer.Team then
		h.FillColor = Color3.fromRGB(0, 150, 255) -- Blue
	else
		h.FillColor = Color3.fromRGB(255, 0, 0) -- Red
	end


	h.OutlineColor = Color3.new(1, 1, 1)
	h.FillTransparency = 0.5
	h.OutlineTransparency = 0
	h.Adornee = char
	h.Parent = char
end

local function removeHighlight(player)
	local char = player.Character
	if char then
		local h = char:FindFirstChild("Highlight")
		if h then h:Destroy() end
	end
end

local function applyNameESP(player)
	local char = player.Character
	local head = char and char:FindFirstChild("Head")
	if head and not head:FindFirstChild("NameESP") then
		local gui = Instance.new("BillboardGui")
		gui.Name = "NameESP"
		gui.Adornee = head
		gui.Size = UDim2.new(0, 100, 0, 30)
		gui.StudsOffset = Vector3.new(0, 2.5, 0)
		gui.AlwaysOnTop = true
		gui.MaxDistance = 10000  -- Ensures visibility from far away
		gui.Parent = head

		local text = Instance.new("TextLabel")
		text.Size = UDim2.new(1, 0, 1, 0)
		text.BackgroundTransparency = 1
		text.Text = player.Name
		text.TextColor3 = Color3.new(1, 1, 1)
		text.TextStrokeTransparency = 0.5
		text.Font = Enum.Font.SourceSansBold
		text.TextScaled = false
		text.TextSize = 14  -- ✅ Fixed size
		text.Parent = gui
	end
end

local function removeNameESP(player)
	local char = player.Character
	local gui = char and char:FindFirstChild("Head") and char.Head:FindFirstChild("NameESP")
	if gui then gui:Destroy() end
end

RunService.RenderStepped:Connect(function()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and isAlive(player) then
			if Toggles.Chams then applyHighlight(player) else removeHighlight(player) end
			if Toggles.NameESP then applyNameESP(player) else removeNameESP(player) end
		else
			removeHighlight(player)
			removeNameESP(player)
		end
	end
end)

-- WalkSpeed, JumpPower, Camera FOV
MiscTab:CreateSlider({
	Name = "WalkSpeed",
	Range = {16, 200},
	Increment = 1,
	CurrentValue = 16,
	Callback = function(v)
		local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
		if h then h.WalkSpeed = v end
	end
})
MiscTab:CreateSlider({
	Name = "JumpPower",
	Range = {50, 200},
	Increment = 1,
	CurrentValue = 50,
	Callback = function(v)
		local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
		if h then h.JumpPower = v end
	end
})
MiscTab:CreateSlider({
	Name = "Camera FOV",
	Range = {70, 120},
	Increment = 1,
	CurrentValue = 70,
	Callback = function(v) Camera.FieldOfView = v end
})

-- Fly
MiscTab:CreateToggle({
	Name = "Enable Fly (Toggle E)",
	CurrentValue = false,
	Callback = function(v)
		Toggles.Fly = v
		if not v then
			Toggles.FlyEnabled = false
		end
	end
})
MiscTab:CreateSlider({
	Name = "Fly Speed",
	Range = {10, 300},
	Increment = 5,
	CurrentValue = Settings.FlySpeed,
	Callback = function(v) Settings.FlySpeed = v end
})

UserInputService.InputBegan:Connect(function(input, gp)
	if not gp and input.KeyCode == Enum.KeyCode.E and Toggles.Fly then
		Toggles.FlyEnabled = not Toggles.FlyEnabled
	end
end)

RunService.RenderStepped:Connect(function()
	if Toggles.Fly and Toggles.FlyEnabled and LocalPlayer.Character then
		local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local dir = Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end
			hrp.Velocity = dir.Magnitude > 0 and dir.Unit * Settings.FlySpeed or Vector3.zero
		end
	end
end)

-- NoClip
MiscTab:CreateToggle({
	Name = "NoClip (Jump after disabling)",
	CurrentValue = false,
	Callback = function(v)
		Toggles.NoClip = v
		if noClipConn then noClipConn:Disconnect() end
		if v then
			noClipConn = RunService.Stepped:Connect(function()
				local char = LocalPlayer.Character
				if char then
					for _, part in pairs(char:GetDescendants()) do
						if part:IsA("BasePart") then part.CanCollide = false end
					end
				end
			end)
		end
	end
})

-- Infinite Jump
MiscTab:CreateToggle({
	Name = "Infinite Jump",
	CurrentValue = false,
	Callback = function(v) Toggles.InfiniteJump = v end
})
UserInputService.JumpRequest:Connect(function()
	if Toggles.InfiniteJump and LocalPlayer.Character then
		local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

-- FPS Boost
local originalSettings = {
	GlobalShadows = Lighting.GlobalShadows,
	FogEnd = Lighting.FogEnd,
	Materials = {},
	Decals = {},
	Textures = {}
}

local originalSettings = {
	GlobalShadows = Lighting.GlobalShadows,
	FogEnd = Lighting.FogEnd,
	Materials = {},
}

local boostApplied = false

MiscTab:CreateButton({
	Name = "Apply FPS Boost",
	Callback = function()
		if boostApplied then
			warn("FPS Boost already applied.")
			return
		end
		boostApplied = true

		-- Save original lighting
		originalSettings.GlobalShadows = Lighting.GlobalShadows
		originalSettings.FogEnd = Lighting.FogEnd
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 100000

		-- Save and apply material overrides
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") then
				originalSettings.Materials[obj] = obj.Material
				obj.Material = Enum.Material.SmoothPlastic
			elseif obj:IsA("Decal") or obj:IsA("Texture") then
				obj:Destroy()
			end
		end
	end
})

MiscTab:CreateButton({
	Name = "Restore FPS Settings",
	Callback = function()
		if not boostApplied then
			warn("FPS Boost has not been applied yet.")
			return
		end
		boostApplied = false

		-- Restore lighting
		Lighting.GlobalShadows = originalSettings.GlobalShadows
		Lighting.FogEnd = originalSettings.FogEnd

		-- Restore materials
		for part, mat in pairs(originalSettings.Materials) do
			if part and part:IsDescendantOf(workspace) then
				part.Material = mat
			end
		end
		originalSettings.Materials = {}
	end
})



-- SpinBot (Fun tab)
FunTab:CreateToggle({
	Name = "SpinBot",
	CurrentValue = false,
	Callback = function(v) Toggles.SpinBot = v end
})
FunTab:CreateSlider({
	Name = "SpinBot Speed",
	Range = {1, 100},
	Increment = 1,
	CurrentValue = Settings.SpinBotSpeed,
	Callback = function(v) Settings.SpinBotSpeed = v end
})
RunService.RenderStepped:Connect(function()
	if Toggles.SpinBot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local hrp = LocalPlayer.Character.HumanoidRootPart
		hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Settings.SpinBotSpeed), 0)
	end
end)

-- Fake Lag (Fun tab)
local lastLagTime = 0
FunTab:CreateToggle({
	Name = "Fake Lag",
	CurrentValue = false,
	Callback = function(v) Toggles.FakeLag = v end
})
FunTab:CreateSlider({
	Name = "Fake Lag Delay",
	Range = {0.05, 0.50},
	Increment = 0.01,
	CurrentValue = Settings.FakeLagDelay,
	Callback = function(v) Settings.FakeLagDelay = v end
})
RunService.RenderStepped:Connect(function(dt)
	if Toggles.FakeLag and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local currentTime = tick()
		if currentTime - lastLagTime < Settings.FakeLagDelay then
			LocalPlayer.Character.HumanoidRootPart.Anchored = true
		else
			LocalPlayer.Character.HumanoidRootPart.Anchored = false
			lastLagTime = currentTime
		end
	elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		LocalPlayer.Character.HumanoidRootPart.Anchored = false
	end
end)

-- Teleport
local savedCFrame
TeleportTab:CreateButton({
	Name = "Save Location",
	Callback = function()
		local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if root then savedCFrame = root.CFrame end
	end
})
TeleportTab:CreateButton({
	Name = "Teleport to Saved",
	Callback = function()
		local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if root and savedCFrame then root.CFrame = savedCFrame end
	end
})
TeleportTab:CreateToggle({
	Name = "Teleport On Click",
	CurrentValue = false,
	Callback = function(v) TpOnClickEnabled = v end
})
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and TpOnClickEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
		local mouse = LocalPlayer:GetMouse()
		local targetPos = mouse.Hit and mouse.Hit.p
		if targetPos and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
		end
	end
end)

TeleportTab:CreateToggle({
	Name = "Kill All",
	CurrentValue = false,
	Callback = function(v)
		Toggles.KillAll = v
		if v then Toggles.KillEnemies = false end
	end
})

TeleportTab:CreateToggle({
	Name = "Kill Enemies",
	CurrentValue = false,
	Callback = function(v)
		Toggles.KillEnemies = v
		if v then Toggles.KillAll = false end
	end
})

local currentTarget = nil

RunService.RenderStepped:Connect(function()
	if not Toggles.KillAll and not Toggles.KillEnemies then
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.Anchored = false
		end
		currentTarget = nil
		return
	end

	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local root = char.HumanoidRootPart

	-- Select new target if needed
	if not currentTarget or not isAlive(currentTarget) then
		local candidates = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and isAlive(player) then
				if Toggles.KillEnemies and player.Team == LocalPlayer.Team then
					continue
				end
				table.insert(candidates, player)
			end
		end
		currentTarget = #candidates > 0 and candidates[math.random(1, #candidates)] or nil
	end

	-- Hover and face target
	if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
		local targetHRP = currentTarget.Character.HumanoidRootPart
		local backOffset = -targetHRP.CFrame.LookVector * 4 + Vector3.new(0, 3, 0) -- behind and above
		local hoverPosition = targetHRP.Position + backOffset
		local faceTarget = CFrame.lookAt(hoverPosition, targetHRP.Position)

		root.Anchored = true
		root.CFrame = faceTarget
		root.Velocity = Vector3.zero

		-- Camera follows the target
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHRP.Position)
	else
		root.Anchored = false
	end
end)
