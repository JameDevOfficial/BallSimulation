local M = {}

M.createBall = function(screen,world, originalBall)
    local ball = originalBall
    ball.position = {}
    ball.position.X = screen.centerX
    ball.position.Y = screen.centerY
    ball.shape = love.physics.newCircleShape(originalBall.radius)
    ball.body = love.physics.newBody(world.world, ball.position.X, ball.position.Y, "dynamic")
    ball.fixture = love.physics.newFixture(ball.body, ball.shape, 1)
    ball.fixture:setRestitution(1)
    return ball
end

M.createBorder = function(screen, world)
    local border = {}

    local border = {}
    local points = {0, 0, screen.X, 0, screen.X, screen.Y, 0, screen.Y}
    border.body = love.physics.newBody(world.world, 0, 0, "static")
    border.shape = love.physics.newChainShape(true, points)
    border.fixture = love.physics.newFixture(border.body, border.shape, 1)
    border.fixture:setFriction(0)
    border.points = points

    return border
end

local timer = 0
local accelerateInterval = 1 --seconds
local accelerateFactor = 1.1

M.accelerateBall = function(ball, dt)
    timer = timer + dt
    if timer >= accelerateInterval then
        local vx, vy = ball.body:getLinearVelocity()
        ball.body:setLinearVelocity(vx * accelerateFactor, vy * accelerateFactor)
        timer = timer - accelerateInterval
        print("speed up to ", vx, vy)
    end

end

return M