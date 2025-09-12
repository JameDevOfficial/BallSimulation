UserInterface = require("game.ui")
Core = require("game.core")
Suit = require("game.suit")
PhysicsCore = require("game.physicsCore")
DebugWorldDraw = require("game.debugWorldDraw")

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
local border = {}

function love.load()
    screen = UserInterface.windowResized()
    print(screen.topLeft.X, screen.topLeft.Y, screen.topRight.X, screen.topRight.Y, screen.bottomRight.X, screen.bottomRight.Y, screen.bottomLeft.X, screen.bottomLeft.Y)
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
    UserInterface.drawFrame(screen, balls)
    love.graphics.setColor(1, 0, 0)
    Suit.draw()

    --DebugWorldDraw(world.world, ((screen.X - screen.minSize) / 2), ((screen.Y - screen.minSize) / 2), screen.minSize, screen.minSize)
end

function love.resize()
    screen = UserInterface.windowResized()
    border.fixture:destroy()
    border = PhysicsCore.createBorder(screen, world)
end

function love.mousepressed(x, y, button)    
    local newBall = {
        position = { X = screen.centerX, Y = screen.centerY },
        color = { math.random(), math.random(), math.random(), 1 },
        radius = math.random(10,50),
        startVelocity = 100,
    }
    newBall = PhysicsCore.createBall(screen, world, newBall)
    newBall.body:setLinearVelocity(ball.startVelocity, ball.startVelocity * math.pi)
    table.insert(balls, newBall)
    print("made new ball ("..#balls..")")
end