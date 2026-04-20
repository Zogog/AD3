--[[
    Adopt Me Research Workspace (Delta Edition)
    main.lua — Core Entry File
    Purpose: Provide a clean foundation before adding modules.
]]

-----------------------------
-- Utility
-----------------------------

local function log(...)
    print("[AM-CORE]", ...)
end

log("main.lua initialized")

-----------------------------
-- Environment Detection
-----------------------------

local env = {
    executor = identifyexecutor and identifyexecutor() or "Unknown",
    setIdentity = setthreadidentity or (syn and syn.set_thread_identity),
    getIdentity = getthreadidentity or (syn and syn.get_thread_identity),
}

-----------------------------
-- GUI Setup
-----------------------------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove old GUI if reloaded
local old = playerGui:FindFirstChild("AM_DebugGUI")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "AM_DebugGUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 160)
frame.Position = UDim2.new(0, 20, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Title bar
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 24)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.Text = "Adopt Me Debug Panel"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

-- Info text
local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -10, 1, -30)
info.Position = UDim2.new(0, 5, 0, 28)
info.BackgroundTransparency = 1
info.TextColor3 = Color3.fromRGB(200, 200, 200)
info.Font = Enum.Font.Code
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextYAlignment = Enum.TextYAlignment.Top
info.TextSize = 14
info.Text = "Loading..."
info.Parent = frame

-----------------------------
-- Live Update Loop
-----------------------------

RunService.RenderStepped:Connect(function()
    local identity = "N/A"
    if env.getIdentity then
        local ok, result = pcall(env.getIdentity)
        if ok then identity = result end
    end

    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
    local mem = Stats:GetTotalMemoryUsageMb()

    info.Text = string.format([[
Executor: %s
ThreadIdentity: %s

FPS: %s
Ping: %s
Memory: %s MB
]], env.executor, identity, fps, ping, math.floor(mem))
end)

log("Debug GUI loaded")
log("main.lua ready")
