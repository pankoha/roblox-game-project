local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local progressEvent = remotesFolder:WaitForChild("BridgeProgress")

local billboards = Workspace:FindFirstChild("Billboards")

local function updateBillboardText(text)
	if not billboards then
		return
	end

	for _, descendant in ipairs(billboards:GetDescendants()) do
		if descendant:IsA("TextLabel") then
			descendant.Text = text
		end
	end
end

progressEvent.OnClientEvent:Connect(function(placedCount, totalCount, bridgeComplete, finisherName)
	if finisherName then
		updateBillboardText(("%s さんがゴールしました！"):format(finisherName))
		return
	end

	if bridgeComplete then
		updateBillboardText("橋が完成しました！Cabinsへ進もう")
	else
		updateBillboardText(("橋の素材設置状況: %d / %d"):format(placedCount, totalCount))
	end
end)
