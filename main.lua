UserInterface = require("game.ui")
Core = require("game.core")
Suit = require("game.suit")
PhysicsCore = require("game.physicsCore")
DebugWorldDraw = require("game.libs.debugWorldDraw")
Colors = require("game.libs.colors")
Debug = require("game.libs.debug")
PerformanceMonitor = require("game.libs.performance")

IsPaused = false
Screen = {}
World = {
    world = love.physics.newWorld(0, 100, true)
}
Balls = {}
SplitBalls = false

local ball = {
    position = { X = Screen.centerX, Y = Screen.centerY },
    color = { 0.2, 1, 0.2, 1 },
    radius = 50,
    startVelocity = 100,
    splitCooldown = 0,
    canSplit = true,
}
local rects = {}
local rect = {
    position = { X = Screen.centerX, Y = Screen.centerY },
    color = { 0.2, 1, 0.2, 1 },
    height = 200,
    width = 50,
    startVelocity = 0,
}
local border = {}

function love.load(dt)
    Screen = UserInterface.windowResized()
    World.world:setCallbacks(PhysicsCore.beginContact, PhysicsCore.endContact, PhysicsCore.preContact, PhysicsCore.postSolve)
    print(Screen.topLeft.X, Screen.topLeft.Y, Screen.topRight.X, Screen.topRight.Y, Screen.bottomRight.X,
        Screen.bottomRight.Y, Screen.bottomLeft.X, Screen.bottomLeft.Y)
    ball = PhysicsCore.createBall(Screen, World, ball)
    border = PhysicsCore.createBorder(Screen, World)
    table.insert(Balls, ball)
end

function love.update(dt)
    if IsPaused then return end
    PerformanceMonitor.addEntry(dt)
    PhysicsCore.processPendingBallCreations()
    PhysicsCore.handleSplittingCooldown(Balls, dt)
    PhysicsCore.accelerateAllBalls(Balls, dt)
    World.world.update(World.world, dt)
    
end

function love.draw()
    love.graphics.setColor(1, 0, 0)
    UserInterface.drawFrame(Screen, Balls, rects)
    Suit.draw()

    --DebugWorldDraw(World.world, ((Screen.X - Screen.minSize) / 2), ((Screen.Y - Screen.minSize) / 2), Screen.minSize,Screen.minSize)
end

function love.resize()
    Screen = UserInterface.windowResized()
    border.fixture:destroy()
    border = PhysicsCore.createBorder(Screen, World)
end

function love.mousepressed(x, y, button)
    if button == 1 then
        local x, y = love.mouse.getPosition()
        local newBall = {
            position = {X=x, Y=y},
            color = { math.random(), math.random(), math.random(), 1 },
            radius = math.random(10, 50),
            startVelocity = 100,
            angle = math.random(0, 360)
        }
        newBall = PhysicsCore.createBall(Screen, World, newBall)
        -- Set velocity based on angle (in degrees)
        local angleRad = math.rad(newBall.angle or 0)
        local vx = newBall.startVelocity * math.cos(angleRad)
        local vy = newBall.startVelocity * math.sin(angleRad)
        newBall.body:setLinearVelocity(vx, vy)
        table.insert(Balls, newBall)
        print("made new ball (" .. #Balls .. ")")
    elseif button == 2 then
        local newRect = {
            position = {},
            color = { math.random(), math.random(), math.random(), 1 },
            width = math.random(10, 100),
            height = math.random(10, 100),
            startVelocity = 0,
        }
        newRect = PhysicsCore.createRect(Screen, World, newRect)
        newRect.body:setLinearVelocity(rect.startVelocity, rect.startVelocity * math.pi)
        table.insert(rects, newRect)
        print("made new rect (" .. #rects .. ")")
    end
end

--Keypressed
function love.keypressed(k)
    Debug.keypressed(k, Balls, rects)
    Suit.keypressed(k)
end

-- forward keyboard events
function love.textinput(t)
    Suit.textinput(t)
end
