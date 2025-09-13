UserInterface = require("game.ui")
Core = require("game.core")
Suit = require("game.suit")
PhysicsCore = require("game.physicsCore")
DebugWorldDraw = require("game.libs.debugWorldDraw")
Colors = require("game.libs.colors")
Debug = require("game.libs.debug")
PerformanceMonitor = require("game.libs.performance")

IsPaused = false
local screen = {}
local world = {
    world = love.physics.newWorld(0, 100, true)
}
local balls = {}
local ball = {
    position = { X = screen.centerX, Y = screen.centerY },
    color = { 0.2, 1, 0.2, 1 },
    radius = 50,
    startVelocity = 100,
}
local rects = {}
local rect = {
    position = { X = screen.centerX, Y = screen.centerY },
    color = { 0.2, 1, 0.2, 1 },
    height = 200,
    width = 50,
    startVelocity = 0,
}
local border = {}

function love.load(dt)
    if IsPaused then return end
    PerformanceMonitor.addEntry(dt)

    screen = UserInterface.windowResized()
    print(screen.topLeft.X, screen.topLeft.Y, screen.topRight.X, screen.topRight.Y, screen.bottomRight.X,
        screen.bottomRight.Y, screen.bottomLeft.X, screen.bottomLeft.Y)
    ball = PhysicsCore.createBall(screen, world, ball)
    border = PhysicsCore.createBorder(screen, world)
    ball.body:setLinearVelocity(ball.startVelocity, ball.startVelocity * math.pi)
    table.insert(balls, ball)
end

function love.update(dt)
    world.world.update(world.world, dt)
    for i, ball in ipairs(balls) do
        ball.position.X, ball.position.Y = ball.body:getPosition()
        PhysicsCore.accelerateBall(ball, dt)
    end
end

function love.draw()
    love.graphics.setColor(1, 0, 0)
    UserInterface.drawFrame(screen, balls, rects)
    Suit.draw()

    --DebugWorldDraw(world.world, ((screen.X - screen.minSize) / 2), ((screen.Y - screen.minSize) / 2), screen.minSize,screen.minSize)
end

function love.resize()
    screen = UserInterface.windowResized()
    border.fixture:destroy()
    border = PhysicsCore.createBorder(screen, world)
end

function love.mousepressed(x, y, button)
    if button == 1 then
        local newBall = {
            position = {},
            color = { math.random(), math.random(), math.random(), 1 },
            radius = math.random(10, 50),
            startVelocity = 100,
            angle = math.random(0, 360)
        }
        newBall = PhysicsCore.createBall(screen, world, newBall)
        -- Set velocity based on angle (in degrees)
        local angleRad = math.rad(newBall.angle or 0)
        local vx = newBall.startVelocity * math.cos(angleRad)
        local vy = newBall.startVelocity * math.sin(angleRad)
        newBall.body:setLinearVelocity(vx, vy)
        table.insert(balls, newBall)
        print("made new ball (" .. #balls .. ")")
    elseif button == 2 then
        local newRect = {
            position = {},
            color = { math.random(), math.random(), math.random(), 1 },
            width = math.random(10, 100),
            height = math.random(10, 100),
            startVelocity = 0,
        }
        newRect = PhysicsCore.createRect(screen, world, newRect)
        newRect.body:setLinearVelocity(rect.startVelocity, rect.startVelocity * math.pi)
        table.insert(rects, newRect)
        print("made new rect (" .. #rects .. ")")
    end
end

--Keypressed
function love.keypressed(k)
    Debug.keypressed(k, balls, rects)
    Suit.keypressed(k)
end

-- forward keyboard events
function love.textinput(t)
    Suit.textinput(t)
end
