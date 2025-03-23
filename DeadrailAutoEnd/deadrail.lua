local player = game.Players.LocalPlayer
local noclipEnabled = false
local ownerUserId = 1161675904
local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local function sendNotification(title, text, duration)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 4
        })
    end)
end

if player.UserId == ownerUserId then
    sendNotification("Welcome Owner", "Welcome " .. player.Name, 5)
end

local function toggleNoclip(state)
    if state ~= nil then
        noclipEnabled = state
    else
        noclipEnabled = not noclipEnabled
    end

    for _, part in pairs(player.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not noclipEnabled
        end
    end
end

RunService.Stepped:Connect(function()
    if noclipEnabled and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

local success, library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/librarynew", true))()
end)

if not success or not library then
    sendNotification("Error", "Failed to load Tora Library", 5)
    return
end

local window = library:CreateWindow("DEAD RAILS")

window:AddButton({
    text = "Bypass To End",
    callback = function()
        sendNotification("Spam Button If Not Teleported", "Keep clicking if teleport fails", 4)
        wait(1)
        player.Character:PivotTo(CFrame.new(-346, -69, -49060))
    end
})

window:AddButton({
    text = "Toggle NoClip",
    callback = function()
        toggleNoclip()
        local status = noclipEnabled and "Enabled" or "Disabled"
        sendNotification("NoClip Status", "NoClip is now " .. status, 4)
    end
})

window:AddButton({
    text = "CHANGE SERVER",
    callback = function()
        sendNotification("Changing Server...", "Searching for a new server...", 3)
        local servers
        local success, response = pcall(function()
            return game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        end)

        if success then
            servers = HttpService:JSONDecode(response)
        else
            sendNotification("Server Hop", "Failed to fetch server data!", 4)
            return
        end

        for _, server in ipairs(servers.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                TeleportService:TeleportToPlaceInstance(PlaceId, server.id, player)
                return
            end
        end

        sendNotification("Server Hop", "No new servers found!", 4)
    end
})

window:AddLabel({ text = "Skid LOL", type = "label" })
library:Init()

local function createTimerUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player.PlayerGui

    local timerFrame = Instance.new("Frame")
    timerFrame.Parent = screenGui
    timerFrame.Size = UDim2.new(0, 220, 0, 60)
    timerFrame.Position = UDim2.new(0.5, -110, 0, 10)
    timerFrame.AnchorPoint = Vector2.new(0.5, 0)
    timerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    timerFrame.BorderSizePixel = 2
    timerFrame.BorderColor3 = Color3.fromRGB(255, 85, 85)

    local timerLabel = Instance.new("TextLabel")
    timerLabel.Parent = timerFrame
    timerLabel.Size = UDim2.new(1, 0, 1, 0)
    timerLabel.Text = "10:00"
    timerLabel.TextColor3 = Color3.fromRGB(255, 85, 85)
    timerLabel.Font = Enum.Font.GothamBlack
    timerLabel.TextSize = 32
    timerLabel.BackgroundTransparency = 1

    return timerLabel
end

local timerLabel = createTimerUI()

local function startTimer(duration)
    local startTime = tick()
    local endTime = startTime + duration

    while tick() < endTime do
        local remaining = endTime - tick()
        local minutes = math.floor(remaining / 60)
        local seconds = math.floor(remaining % 60)
        timerLabel.Text = string.format("%02d:%02d", minutes, seconds)
        wait(0.1)
    end

    timerLabel.Text = "00:00"
end

startTimer(600)

local function handleCommand(command)
    local args = {}
    for arg in command:gmatch("%S+") do
        table.insert(args, arg)
    end

    local cmd = args[1]
    local target = args[2] or "."

    if cmd == "!kick" then
        local targetPlayer = game.Players:FindFirstChild(target)
        if targetPlayer then
            targetPlayer:Kick("Kicked by Owner")
        else
            sendNotification("Error", "Player not found: " .. target, 5)
        end
    elseif cmd == "!notify" then
        local message = table.concat(args, " ", 2)
        for _, plr in pairs(game.Players:GetPlayers()) do
            sendNotification("Notification", message, 5)
        end
    elseif cmd == "!say" then
        local message = table.concat(args, " ", 2)
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
    end
end

player.Chatted:Connect(function(message)
    if player.UserId == ownerUserId then
        handleCommand(message)
    end
end)