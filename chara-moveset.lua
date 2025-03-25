--SCRIPT MADE BY XLAYSPLAYS
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local humanoid, character = nil, nil
local tpTool = nil
local AztechTeam = {}

-- Inicializa personagem e humanoide
function AztechTeam.initializeCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
end

AztechTeam.initializeCharacter()
player.CharacterAdded:Connect(AztechTeam.initializeCharacter)

-- 🛠️ Criar e dar ferramenta de teleporte (Dash)
function AztechTeam.giveTpTool()
    if not tpTool then
        tpTool = Instance.new("Tool")
        tpTool.Name = "tp"
        tpTool.RequiresHandle = false -- Dash doesn't need a handle
        tpTool.Parent = player.Backpack

        tpTool.Activated:Connect(AztechTeam.dashForward)
    end
end

-- 🚀 Dash (teleport forward based on the camera facing direction)
function AztechTeam.dashForward()
    -- Create BodyVelocity to push the player forward without modifying walk speed
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)  -- High force for the dash
    bodyVelocity.Velocity = character.HumanoidRootPart.CFrame.LookVector * 100  -- Dash in the direction the camera is facing
    bodyVelocity.Parent = character.HumanoidRootPart

    -- Remove BodyVelocity after 0.1 seconds
    game:GetService("Debris"):AddItem(bodyVelocity, 0.1)
end

-- 🚀 Teleportar para o local do clique
function AztechTeam.teleportToClick()
    local mouse = player:GetMouse()
    if mouse.Target then
        character:SetPrimaryPartCFrame(CFrame.new(mouse.Hit.Position))

        -- 🖤 Tela preta rápida
        local blackScreen = Instance.new("Frame")
        blackScreen.Size = UDim2.new(1, 0, 1, 0)
        blackScreen.BackgroundColor3 = Color3.new(0, 0, 0)
        blackScreen.BackgroundTransparency = 0
        blackScreen.Parent = playerGui
        blackScreen.ZIndex = 999

        wait(0.5)
        blackScreen.BackgroundTransparency = 1
        wait(0.5)
        blackScreen:Destroy()
    end
end

-- Dá a ferramenta ao jogador ao entrar no jogo
player.CharacterAdded:Connect(function()
    task.wait(1)
    AztechTeam.giveTpTool()
end)

-- 🔥 Substituição de Animações
local birdUSuck = {
    [10469493270] = {replacementId = "15259161390", startTime = 0, speed = 1},  -- M1_1
    [10469630950] = {replacementId = "18716475828", startTime = 1.0, speed = 1}, -- Downslam
    [10469639222] = {replacementId = "15240176873", startTime = 0, speed = 1},  -- Uppercut
    [10469643643] = {replacementId = "18716001119", startTime = 1.0, speed = 1}, -- Move 1
    [10468665991] = {replacementId = "12509505723", startTime = 0.1, speed = 1}, -- Move 2
    [10466974800] = {replacementId = "15290930205", startTime = 0.3, speed = 1.3}, -- Move 3
    [10471336737] = {replacementId = "17838006839", startTime = 0.5, speed = 1},  -- Move 4
    [10469493271] = {replacementId = "15259161390", startTime = 0, speed = 1},  -- M1_2
    [10469493272] = {replacementId = "15259161390", startTime = 0, speed = 1},  -- M1_3
    [10469493273] = {replacementId = "15259161390", startTime = 0, speed = 1}   -- M1_4
}

-- Interrompe todas as animações antes de substituir
function AztechTeam.stopAllAnimations()
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        track:Stop()
    end
end

-- Substitui a animação
function AztechTeam.playReplacementAnimation(config)
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. config.replacementId
    local track = humanoid:LoadAnimation(anim)
    track:Play()
    track:AdjustSpeed(0)
    track.TimePosition = config.startTime
    track:AdjustSpeed(config.speed)
end

-- Verifica se uma animação precisa ser substituída
humanoid.AnimationPlayed:Connect(function(animationTrack)
    local animId = tonumber(animationTrack.Animation.AnimationId:match("%d+"))
    local config = birdUSuck[animId]
    if config then
        AztechTeam.stopAllAnimations()
        AztechTeam.playReplacementAnimation(config)
    end
end)

-- 📌 Corrigir velocidade do BodyVelocity
character.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("BodyVelocity") then
        descendant.Velocity = Vector3.new(descendant.Velocity.X, 0, descendant.Velocity.Z)
    end
end)

-- 🌈 Barra de Ultimate RGB
local ultimateBar = playerGui:WaitForChild("ScreenGui"):WaitForChild("UltimateBar")

local function checkUltimateBar()
    local bar = ultimateBar:FindFirstChild("Bar")
    if bar and bar.Size.X.Scale >= 1 then
        bar.BackgroundColor3 = Color3.fromHSV(tick() % 10 / 10, 1, 1)  
    end
end

game:GetService("RunService").Heartbeat:Connect(checkUltimateBar)

-- 🔪 Carregar e anexar a faca ao braço esquerdo do jogador
function AztechTeam.attachKnife()
    local knifeId = "rbxassetid://9273918981"  -- Chara Knife ID
    local knife = game:GetService("InsertService"):LoadAsset(knifeId):GetChildren()[1]
    knife.Parent = character:WaitForChild("LeftHand")  -- Attach to left hand

    -- Fixing the knife orientation and position to be properly aligned
    knife.CFrame = character.LeftHand.CFrame * CFrame.new(0, 0, -1)  -- Adjust position to fit nicely in the hand
end

-- Attach the knife when the character is added
player.CharacterAdded:Connect(function()
    task.wait(1)
    AztechTeam.attachKnife()
end)
