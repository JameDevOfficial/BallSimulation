UserInterface = require("game.ui")
Core = require("game.core")
Suit = require("game.suit")
PhysicsCore = require("game.physicsCore")
DebugWorldDraw = require("game.debugWorldDraw")

local screen = {}
local world = {
    world = love.physics.newWorld(0, 0, true)
}
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
    ball.body:setLinearVelocity(ball.startVelocity, ball.startVelocity)
end

function love.update(dt)
    world.world.update(world.world, dt)
    ball.position.X, ball.position.Y = ball.body:getPosition()
    PhysicsCore.accelerateBall(ball, dt)
end

function love.draw()
    UserInterface.drawFrame(screen, ball)
    love.graphics.setColor(1, 0, 0)
    Suit.draw()

    --DebugWorldDraw(world.world, ((screen.X - screen.minSize) / 2), ((screen.Y - screen.minSize) / 2), screen.minSize, screen.minSize)
end

function love.resize()
    screen = UserInterface.windowResized()
    border.fixture:destroy()
    border = PhysicsCore.createBorder(screen, world)
end
