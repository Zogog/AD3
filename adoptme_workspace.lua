--[[
    Adopt Me Research Workspace (Delta Edition)
    Environment: Mobile (Delta Emulator)
    Purpose: Safe client-side analysis only (no server-side exploitation)

    Usage example:

        local ws = loadstring(game:HttpGet("https://raw.githubusercontent.com/<user>/<repo>/main/adoptme_workspace.lua"))()
        ws.run("identity_test")
        ws.run("remote_logger")
        ws.run("module_dumper")
        ws.run("ui_pet_spoofer")

    This workspace is modular, safe, and designed for learning how Adopt Me's client works.
]]

-----------------------------
-- Workspace Root
-----------------------------

local WorkspaceRoot = {}

local function log(...)
    print("[AM-LOG]", ...)
end

log("Adopt Me Research Workspace initialized")

WorkspaceRoot.modules = {}

function WorkspaceRoot.register(name, fn)
    if type(name) ~= "string" then
        return log("register: invalid name type", typeof(name))
    end
    if type(fn) ~= "function" then
        return log("register: invalid function for", name)
    end
    WorkspaceRoot.modules[name] = fn
    log("Registered module:", name)
end

function WorkspaceRoot.run(name)
    local m = WorkspaceRoot.modules[name]
    if not m then
        return log("Module not found:", name)
    end
    log("Running module:", name)
    local ok, err = pcall(m)
    if not ok then
        log("Error in module", name, "->", err)
    else
        log("Module finished:", name)
    end
end

-----------------------------
-- Module 1: ThreadIdentity Tester
-----------------------------

WorkspaceRoot.register("identity_test", function()
    log("Starting identity_test")

    local set = setthreadidentity or (syn and syn.set_thread_identity)
    local get = getthreadidentity or (syn and syn.get_thread_identity)

    if not set or not get then
        return log("Thread identity functions not available in this environment")
    end

    for i = 1, 8 do
        local ok, err = pcall(function()
            set(i)
            local current = get()
            print("[IDENTITY]", "set ->", i, "get ->", current)
        end)
        if not ok then
            print("[IDENTITY]", "failed to set identity", i, "error:", err)
        end
    end

    log("identity_test complete")
end)

-----------------------------
-- Module 2: Universal Remote Logger
-----------------------------

WorkspaceRoot.register("remote_logger", function()
    log("Starting remote_logger")

    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local function safeHookConnection(remote, conn)
        if not conn.Function then
            return
        end

        local old
        old = hookfunction(conn.Function, function(...)
            print("[REMOTE]", remote:GetFullName(), "args:", ...)
            return old(...)
        end)
    end

    local function hookRemote(remote)
        local ok, connections = pcall(getconnections, remote.OnClientEvent)
        if not ok or not connections then
            return
        end

        for _, conn in ipairs(connections) do
            local okHook, err = pcall(safeHookConnection, remote, conn)
            if not okHook then
                print("[REMOTE-HOOK-ERROR]", remote.Name, err)
            end
        end
    end

    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            hookRemote(obj)
        end
    end

    log("remote_logger active")
end)

-----------------------------
-- Module 3: Safe UI Pet Spoofer (Client-Only)
-----------------------------

WorkspaceRoot.register("ui_pet_spoofer", function()
    log("Starting ui_pet_spoofer")

    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    if not player then
        return log("ui_pet_spoofer: LocalPlayer not found")
    end

    local fakePet = {
        name = "Shadow Dragon",
        rarity = "Legendary",
        neon = true,
        mega = false,
        source = "ResearchWorkspace"
    }

    print("[UI-PET-SPOOF]", "Spoofing pet in UI:", fakePet.name)

    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    if not playerGui then
        return log("ui_pet_spoofer: PlayerGui not found")
    end

    local candidateEvent = playerGui:FindFirstChild("UIEvent", true)
    if candidateEvent and candidateEvent:IsA("BindableEvent") then
        print("[UI-PET-SPOOF]", "Firing UIEvent with fake pet data")
        candidateEvent:Fire(fakePet)
    else
        print("[UI-PET-SPOOF]", "No suitable UIEvent found; placeholder only")
    end

    log("ui_pet_spoofer complete")
end)

-----------------------------
-- Module 4: Module Dumper
-----------------------------

WorkspaceRoot.register("module_dumper", function()
    log("Starting module_dumper")

    local ok, modules = pcall(getloadedmodules)
    if not ok or not modules then
        return log("module_dumper: getloadedmodules not available")
    end

    for _, m in ipairs(modules) do
        print("[MODULE]", m.Name or "Unnamed", "->", m:GetFullName())
    end

    log("module_dumper complete")
end)

-----------------------------
-- Return WorkspaceRoot
-----------------------------

return WorkspaceRoot
