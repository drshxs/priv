local coreGui = game:GetService("CoreGui")
if coreGui:FindFirstChild("ScreenGui") then
    coreGui:FindFirstChild("ScreenGui"):Destroy()
end

loadstring(game:HttpGet('https://raw.githubusercontent.com/drillygzzly/Roblox-UI-Libs/main/Yun%20V2%20Lib/Yun%20V2%20Lib%20Source.lua'))()

local Library = initLibrary()
local Window = Library:Load({name = "Signal", sizeX = 425, sizeY = 512, color = Color3.fromRGB(150, 40, 32)})

local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera

local aimTab = Window:Tab("Aiming")
local visualTab = Window:Tab("Visuals")
local miscTab = Window:Tab("Miscellaneous")

local Aimingsec1 = aimTab:Section{name = "Aimbot", column = 1}
local Visualssec1 = visualTab:Section{name = "ESP", column = 1}
local MiscSec = miscTab:Section{name = "UI Controls", column = 1}

local holdingRMB = false
local aimingEnabled = false
local teamCheckEnabled = false
local targetPart = "Head"
local smoothing = 0
local lockedTarget = nil
local lineESPEnabled = false
local lineTransparency = 1
local headESPEnabled = false
local headTransparency = 1
local boxESPEnabled = false
local boxTransparency = 1
local lineESP = {}
local headESP = {}
local boxESP = {}

Aimingsec1:Toggle {
    Name = "Enabled",
    flag = "aimEnabled",
    callback = function(bool)
        aimingEnabled = bool
    end
}

Aimingsec1:Toggle {
    Name = "Team Check",
    flag = "teamCheck",
    callback = function(bool)
        teamCheckEnabled = bool
    end
}

Aimingsec1:Slider {
    Name = "Smoothing",
    Default = 0,
    Min = 0,
    Max = 50,
    Decimals = 1,
    Flag = "smoothValue",
    callback = function(value)
        smoothing = value
    end
}

Aimingsec1:Dropdown {
    Name = "Target Part",
    content = {"Head", "Torso", "HumanoidRootPart"},
    multichoice = false,
    callback = function(selected)
        targetPart = selected
    end
}

Visualssec1:Toggle {
    Name = "Line ESP",
    flag = "lineESP",
    callback = function(bool)
        lineESPEnabled = bool
        if not lineESPEnabled then
            for _, esp in pairs(lineESP) do
                if esp then
                    esp:Remove()
                end
            end
            lineESP = {}
        end
    end
}

Visualssec1:Slider {
    Name = "Transparency",
    Default = 1,
    Min = 0,
    Max = 1,
    Decimals = 2,
    Flag = "lineESPTransparency",
    callback = function(value)
        lineTransparency = value
        for _, line in pairs(lineESP) do
            line.Transparency = lineTransparency
        end
    end
}

Visualssec1:Toggle {
    Name = "Head ESP",
    flag = "headESP",
    callback = function(bool)
        headESPEnabled = bool
        if not headESPEnabled then
            for _, esp in pairs(headESP) do
                if esp then
                    esp:Remove()
                end
            end
            headESP = {}
        end
    end
}

Visualssec1:Slider {
    Name = "Transparency",
    Default = 1,
    Min = 0,
    Max = 1,
    Decimals = 2,
    Flag = "headESPTransparency",
    callback = function(value)
        headTransparency = value
        for _, circle in pairs(headESP) do
            circle.Transparency = headTransparency
        end
    end
}

Visualssec1:Toggle {
    Name = "2D Box ESP",
    flag = "boxESP",
    callback = function(bool)
        boxESPEnabled = bool
        if not boxESPEnabled then
            for _, box in pairs(boxESP) do
                if box then
                    box:Remove()
                end
            end
            boxESP = {}
        end
    end
}

Visualssec1:Slider {
    Name = "Box Transparency",
    Default = 1,
    Min = 0,
    Max = 1,
    Decimals = 2,
    Flag = "boxESPTransparency",
    callback = function(value)
        boxTransparency = value
        for _, box in pairs(boxESP) do
            box.Transparency = boxTransparency
        end
    end
}

MiscSec:Button {
    Name = "Unload UI",
    callback = function()
        if coreGui:FindFirstChild("ScreenGui") then
            coreGui:FindFirstChild("ScreenGui"):Destroy()
        end

        lineESPEnabled = false
        headESPEnabled = false
        boxESPEnabled = false

        for _, esp in pairs(lineESP) do
            if esp then
                esp:Remove()
            end
        end
        for _, esp in pairs(headESP) do
            if esp then
                esp:Remove()
            end
        end
        for _, esp in pairs(boxESP) do
            if esp then
                esp:Remove()
            end
        end

        lineESP = {}
        headESP = {}
        boxESP = {}

        aimingEnabled = false
        teamCheckEnabled = false
        smoothing = 0
        targetPart = "Head"
    end
}

players.PlayerRemoving:Connect(function(player)
    if lineESP[player] then
        lineESP[player]:Remove()
        lineESP[player] = nil
    end
    if headESP[player] then
        headESP[player]:Remove()
        headESP[player] = nil
    end
    if boxESP[player] then
        boxESP[player]:Remove()
        boxESP[player] = nil
    end
end)

runService.Heartbeat:Connect(function()
    -- Line ESP
    if lineESPEnabled then
        for _, player in pairs(players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local line = lineESP[player]
                
                if teamCheckEnabled and player.Team == localPlayer.Team then
                    if lineESP[player] then
                        lineESP[player].Visible = false
                    end
                    continue
                end

                if not line then
                    line = Drawing.new("Line")
                    line.Thickness = 1
                    line.Transparency = lineTransparency
                    line.Color = Color3.fromRGB(255, 255, 255)
                    lineESP[player] = line
                end

                local character = player.Character
                local head = character:FindFirstChild("Head")
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                
                if head and humanoidRootPart then
                    local headPos = head.Position
                    local rootPos = humanoidRootPart.Position
                    local screenPos, onScreen = camera:WorldToViewportPoint(headPos)
                    local rootScreenPos, rootOnScreen = camera:WorldToViewportPoint(rootPos)

                    if onScreen then
                        if boxESP[player] and boxESP[player].Visible then
                            -- If Box ESP is enabled, draw the line to the center bottom of the box
                            local box = boxESP[player]
                            local boxBottomCenter = Vector2.new(box.Position.X + box.Size.X / 2, box.Position.Y + box.Size.Y)
                            line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                            line.To = boxBottomCenter
                        else
                            -- If Box ESP is off, draw the line to the head
                            line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                            line.To = Vector2.new(screenPos.X, screenPos.Y)
                        end
                        line.Visible = true
                    else
                        line.Visible = false
                    end
                end
            elseif lineESP[player] then
                lineESP[player]:Remove()
                lineESP[player] = nil
            end
        end
    end

    -- Head ESP
    if headESPEnabled then
        for _, player in pairs(players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
                if teamCheckEnabled and player.Team == localPlayer.Team then
                    if headESP[player] then
                        headESP[player].Visible = false
                    end
                    continue
                end

                if not headESP[player] then
                    local circle = Drawing.new("Circle")
                    circle.Thickness = 1
                    circle.Transparency = headTransparency
                    circle.Color = Color3.fromRGB(255, 255, 255)
                    circle.Filled = false
                    headESP[player] = circle
                end

                local head = player.Character.Head
                local headPos = head.Position
                local screenPos, onScreen = camera:WorldToViewportPoint(headPos)
                local circle = headESP[player]

                if onScreen then
                    local distance = (camera.CFrame.Position - headPos).Magnitude
                    local scaleFactor = 425 
                    local headSize = (head.Size.X + head.Size.Y + head.Size.Z) / 3
                    circle.Position = Vector2.new(screenPos.X, screenPos.Y)
                    circle.Radius = (headSize * scaleFactor) / distance
                    circle.Visible = true
                else
                    circle.Visible = false
                end
            elseif headESP[player] then
                headESP[player]:Remove()
                headESP[player] = nil
            end
        end
    end

    -- Box ESP
    if boxESPEnabled then
        for _, player in pairs(players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if teamCheckEnabled and player.Team == localPlayer.Team then
                    if boxESP[player] then
                        boxESP[player].Visible = false
                    end
                    continue
                end
        
                if not boxESP[player] then
                    local box = Drawing.new("Square")
                    box.Thickness = 1
                    box.Transparency = boxTransparency
                    box.Color = Color3.fromRGB(255, 255, 255)
                    box.Filled = false
                    boxESP[player] = box
                end
        
                local character = player.Character
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    local rootPos = humanoidRootPart.Position
                    local screenPos, onScreen = camera:WorldToViewportPoint(rootPos)
        
                    if onScreen then
                        -- Dynamically adjust scale factor based on the player's distance
                        local distance = (camera.CFrame.Position - rootPos).Magnitude
                        local scaleFactor = math.max(1000 / distance, 0.5)  -- Adjust scaleFactor based on distance
                        local extentsSize = character:GetExtentsSize()
                        local width = extentsSize.X * scaleFactor
                        local height = extentsSize.Y * scaleFactor
        
                        local box = boxESP[player]
                        local characterPos = Vector2.new(screenPos.X - width / 2, screenPos.Y - height / 2)
        
                        box.Position = characterPos
                        box.Size = Vector2.new(width, height)
                        box.Visible = true
                    else
                        if boxESP[player] then
                            boxESP[player].Visible = false
                        end
                    end
                end
            elseif boxESP[player] then
                boxESP[player]:Remove()
                boxESP[player] = nil
            end
        end
    end


    -- Aiming
    if holdingRMB and lockedTarget then
        local targetChar = lockedTarget.Character
        if targetChar and targetChar:FindFirstChild(targetPart) then
            local targetPos = targetChar[targetPart].Position
            local direction = (targetPos - camera.CFrame.Position).Unit
            local smoothFactor = math.max(0.1, (50 - smoothing) / 50)

            camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + camera.CFrame.LookVector:Lerp(direction, smoothFactor))
        else
            lockedTarget = nil
        end
    end
end)

-- Input Handling
userInput.InputBegan:Connect(function(input, gameProcessed)
    if aimingEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 then
        if not holdingRMB then
            holdingRMB = true
            lockedTarget = getClosestPlayerToCursor()
        end
    end
end)

userInput.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holdingRMB = false
        lockedTarget = nil
    end
end)

-- Helper Functions
function getClosestPlayerToCursor()
    local mouse = localPlayer:GetMouse()
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if teamCheckEnabled and player.Team == localPlayer.Team then
                continue
            end

            local screenPos, onScreen = camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if distance < closestDistance then
                    closestPlayer = player
                    closestDistance = distance
                end
            end
        end
    end

    return closestPlayer
end
