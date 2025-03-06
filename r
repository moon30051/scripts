


task.spawn(function()
game["Run Service"].Stepped:Connect(function()
game.Players.LocalPlayer.MaximumSimulationRadius = math.huge
game.Players.LocalPlayer.SimulationRadius = 999999999
end)
end)


loadstring(game:HttpGet(('https://pastebin.com/raw/uUQi691t'),true))()


--[[
    FE Fly Script 
    Required Accessory:
    https://www.roblox.com/catalog/6311978305
    By MyWorld
    discord.gg/pYVHtSJmEY
]]

local rst = game.Players.RespawnTime + 0.07 -- 1/15
local pdloadedtime = "hi"

replicatesignal(game.Players.LocalPlayer.ConnectDiedSignalBackend)

pdloadedtime = os.clock() + rst
task.wait(pdloadedtime - os.clock())

game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(15)

local speed = 20
local lp = game:GetService("Players").LocalPlayer
local c = lp.Character
if not (c and c.Parent) then return nil end
local uis = game:GetService("UserInputService")

local ws = game:GetService("Workspace")
if not c:IsDescendantOf(ws) then return nil end
local hat = c:FindFirstChildOfClass("Accessory")
local handle = hat and hat:FindFirstChild("Handle")
if not handle then return "skill issue" end

local pos = handle.Position
local bg = nil

local function getNetlessVelocity(realPartVelocity)
    local mag = realPartVelocity.Magnitude
    if mag > 1 then
        local unit = realPartVelocity.Unit
        if (unit.Y > 0.25) or (unit.Y < -0.75) then
            return realPartVelocity * (25.1 / realPartVelocity.Y)
        end
        realPartVelocity = unit * 125
    end
    return realPartVelocity * Vector3.new(1, 0, 1) + Vector3.new(0, 25.1, 0)
end

local function movementUpdate(delta)
    if not handle then return end
    ws.CurrentCamera.CameraSubject = handle
    if not uis:GetFocusedTextBox() then
        if uis:IsKeyDown(Enum.KeyCode.W) then
            pos += ws.CurrentCamera.CFrame.LookVector * speed * delta
        end
        if uis:IsKeyDown(Enum.KeyCode.S) then
            pos -= ws.CurrentCamera.CFrame.LookVector * speed * delta
        end
        if uis:IsKeyDown(Enum.KeyCode.D) then
            pos += ws.CurrentCamera.CFrame.RightVector * speed * delta
        end
        if uis:IsKeyDown(Enum.KeyCode.A) then
            pos -= ws.CurrentCamera.CFrame.RightVector * speed * delta
        end
    end
    handle.Velocity = (pos - handle.Position) / delta
    if not bg then
        bg = Instance.new("BodyGyro")
        bg.D = 50
        bg.P = 200
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.Parent = handle
    end
    bg.CFrame = ws.CurrentCamera.CFrame
end

game:GetService("RunService").RenderStepped:Connect(movementUpdate)

game:GetService("RunService").Heartbeat:Connect(function()
    if handle then
        handle.Velocity = getNetlessVelocity(handle.Velocity)
        if bg then bg:Destroy() bg = nil end
    end
end)

handle.AncestryChanged:Connect(function()
    if not handle.Parent or not c:IsDescendantOf(ws) then
        handle = nil
    end
end)

-- Mobile Touch Controls Integration
local thumbstick = { EndX = 0, StartY = 0, SizeMultiplier = 0 }
local jump = { StartX = 0, StartY = 0, EndX = 0, EndY = 0 }

local inputObjects = { Thumbstick = nil, Jump = nil }
local touchStart = { Thumbstick = Vector3.new() }

local function onTouchStarted(input)
    if game:GetService("GuiService").MenuIsOpen or uis:GetFocusedTextBox() then return end
    local touchPos = input.Position
    local touchX, touchY = touchPos.X, touchPos.Y
    if not inputObjects.Thumbstick and touchX < thumbstick.EndX and touchY > thumbstick.StartY then
        inputObjects.Thumbstick = input
        touchStart.Thumbstick = touchPos
    elseif not inputObjects.Jump and touchY > jump.StartY and touchX > jump.StartX and touchX < jump.EndX and touchY < jump.EndY then
        inputObjects.Jump = input
    end
end

local function onTouchMoved(input)
    if input == inputObjects.Thumbstick then
        local direction = input.Position - touchStart.Thumbstick
        local directionMag = direction.Magnitude / thumbstick.SizeMultiplier
        if directionMag > 0.05 then
            direction = direction.Unit * math.min(1, (directionMag - 0.05) / 0.95)
            pos += ws.CurrentCamera.CFrame.LookVector * -direction.Y * speed
            pos += ws.CurrentCamera.CFrame.RightVector * direction.X * speed
        end
    end
end

local function onTouchEnded(input)
    if input == inputObjects.Thumbstick then
        inputObjects.Thumbstick = nil
    elseif input == inputObjects.Jump then
        inputObjects.Jump = nil
    end
end

uis.TouchStarted:Connect(onTouchStarted)
uis.TouchMoved:Connect(onTouchMoved)
uis.TouchEnded:Connect(onTouchEnded)

local function refreshTouchRegions()
    local sX, sY = game:GetService("UserInputService").Mouse.ViewSizeX, game:GetService("UserInputService").Mouse.ViewSizeY
    local isSmallScreen = math.min(sX, sY) <= 500
    sY = sY + game:GetService("GuiService").TopbarInset.Height
    thumbstick.EndX, thumbstick.StartY = sX * 0.4, sY * 0.333
    if isSmallScreen then
        thumbstick.SizeMultiplier = 35
        jump.StartX, jump.StartY, jump.EndX, jump.EndY = sX - 95, sY - 90, sX - 25, sY - 20
    else
        thumbstick.SizeMultiplier = 60
        jump.StartX, jump.StartY, jump.EndX, jump.EndY = sX - 170, sY - 210, sX - 50, sY - 90
    end
end
