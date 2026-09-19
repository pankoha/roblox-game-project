local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local ConstructionZone = Workspace:WaitForChild("ConstructionZone")
local BuildingMaterials = ConstructionZone:WaitForChild("BuildingMaterials")
local Bridge = ConstructionZone:WaitForChild("Bridge")
local Cabins = Workspace:WaitForChild("Cabins")

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local progressEvent = remotesFolder:WaitForChild("BridgeProgress")

local totalMaterialCount = 0
local placedCount = 0
local bridgeComplete = false

local heldParts = {} -- [player] = part
local partHolders = {} -- [part] = player
local reachedCabin = {} -- [player] = true

local function getBridgeCenter()
	local parts = {}
	for _, descendant in ipairs(Bridge:GetDescendants()) do
		if descendant:IsA("BasePart") then
			table.insert(parts, descendant)
		end
	end

	if #parts > 0 then
		local sum = Vector3.new()
		for _, p in ipairs(parts) do
			sum += p.Position
		end
		return sum / #parts
	end

	-- Bridgeフォルダにまだパーツがない場合のフォールバック。
	-- 実際の橋の位置とズレる可能性があるので、Bridge配下に目印のパーツを
	-- 置いてもらうと判定精度が上がる。
	warn("[BridgeGame] Bridgeフォルダにパーツが見つかりません。ConstructionZoneの位置を基準に使います。")
	if ConstructionZone:IsA("PVInstance") then
		return ConstructionZone:GetPivot().Position
	end
	return Vector3.new()
end

local function broadcastProgress(finisherName)
	progressEvent:FireAllClients(placedCount, totalMaterialCount, bridgeComplete, finisherName)
end

local function dropPart(player)
	local part = heldParts[player]
	if not part then
		return
	end

	local weld = part:FindFirstChild("CarryWeld")
	if weld then
		weld:Destroy()
	end
	part.CanCollide = true
	part.Massless = false
	part.Anchored = true

	heldParts[player] = nil
	partHolders[part] = nil

	if not part:GetAttribute("PlacedInBridge") then
		local distance = (part.Position - getBridgeCenter()).Magnitude
		if distance <= GameConfig.BridgePlacementRadius then
			part:SetAttribute("PlacedInBridge", true)
			placedCount += 1
			if placedCount >= totalMaterialCount then
				bridgeComplete = true
			end
			broadcastProgress()
		end
	end

	local prompt = part:FindFirstChildOfClass("ProximityPrompt")
	if prompt then
		prompt.ActionText = GameConfig.PickupPromptText
	end
end

local function pickUpPart(player, part)
	if partHolders[part] or heldParts[player] then
		return
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	part.Anchored = false
	part.CanCollide = false
	part.Massless = true
	part.CFrame = root.CFrame * CFrame.new(GameConfig.CarryOffset)

	local weld = Instance.new("WeldConstraint")
	weld.Name = "CarryWeld"
	weld.Part0 = part
	weld.Part1 = root
	weld.Parent = part

	heldParts[player] = part
	partHolders[part] = player

	local prompt = part:FindFirstChildOfClass("ProximityPrompt")
	if prompt then
		prompt.ActionText = GameConfig.CarryPromptText
	end
end

local function setupMaterial(part)
	if not part:IsA("BasePart") then
		return
	end

	totalMaterialCount += 1

	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = "建材"
	prompt.ActionText = GameConfig.PickupPromptText
	prompt.MaxActivationDistance = GameConfig.PickupMaxDistance
	prompt.RequiresLineOfSight = false
	prompt.Parent = part

	prompt.Triggered:Connect(function(player)
		local holder = partHolders[part]
		if holder == player then
			dropPart(player)
		elseif not holder then
			pickUpPart(player, part)
		end
	end)
end

for _, child in ipairs(BuildingMaterials:GetChildren()) do
	setupMaterial(child)
end

local function onCabinTouched(hit)
	local character = hit.Parent
	if not character or not character:FindFirstChildOfClass("Humanoid") then
		return
	end

	local player = Players:GetPlayerFromCharacter(character)
	if not player or reachedCabin[player] or not bridgeComplete then
		return
	end

	reachedCabin[player] = true

	local leaderstats = player:FindFirstChild("leaderstats")
	local goals = leaderstats and leaderstats:FindFirstChild("Goals")
	if goals then
		goals.Value += 1
	end

	broadcastProgress(player.Name)
end

for _, descendant in ipairs(Cabins:GetDescendants()) do
	if descendant:IsA("BasePart") then
		descendant.Touched:Connect(onCabinTouched)
	end
end

Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local goals = Instance.new("IntValue")
	goals.Name = "Goals"
	goals.Value = 0
	goals.Parent = leaderstats

	player.CharacterRemoving:Connect(function()
		if heldParts[player] then
			dropPart(player)
		end
		reachedCabin[player] = nil
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	if heldParts[player] then
		dropPart(player)
	end
end)

broadcastProgress()
