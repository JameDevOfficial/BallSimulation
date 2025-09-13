local M = {}

local pendingBallCreations = {}
M.getTempBall = function(originalBall, screen, pos)
    local ball = {
        position = {
            X = screen.centerX,
            Y = screen.centerY
        },
        color = { originalBall.color[1], originalBall.color[2], originalBall.color[3] or { 1, 1, 1, 1 } },
        radius = originalBall.radius or 20,
        startVelocity = originalBall.startVelocity or 100,
        splitCooldown = 5,
        canSplit = false,
        collisionPoint = pos -- store collision point for velocity calculation
    }
    return ball
end
M.processPendingBallCreations = function()
    for _, split in ipairs(pendingBallCreations) do
        -- was: M.splitBall(split.balls, split.amount)
        M.splitBall(split.balls, split.amount, split.collisionPoint)
    end
    pendingBallCreations = {}
end

M.handleSplittingCooldown = function(balls, dt)
    for _, ball in ipairs(balls) do
        if not ball.canSplit then
            ball.splitCooldown = ball.splitCooldown - dt
            if ball.splitCooldown <= 0 then
                ball.canSplit = true
            end
        end
    end
end

M.accelerateAllBalls = function(balls, dt)
    for i, ball in ipairs(balls) do
        ball.position.X, ball.position.Y = ball.body:getPosition()
        PhysicsCore.accelerateBall(ball, dt)
    end
end

M.createBall = function(screen, world, ball)
    -- Use the position already set in ball.position
    ball.shape = love.physics.newCircleShape(ball.radius)
    ball.body = love.physics.newBody(world.world, ball.position.X, ball.position.Y, "dynamic")
    ball.fixture = love.physics.newFixture(ball.body, ball.shape, 1)
    ball.fixture:setRestitution(1)
    ball.fixture:setUserData(ball)
    if ball.splitCooldown == nil then ball.splitCooldown = 1 end
    if ball.canSplit == nil then ball.canSplit = false end

    ball.body:setLinearVelocity(ball.startVelocity, ball.startVelocity * math.pi)
    return ball
end

M.createRect = function(screen, world, originalRect)
    local rect = originalRect
    local x, y = love.mouse.getPosition()
    rect.position = { X = x, Y = y }
    rect.shape = love.physics.newRectangleShape(originalRect.width, originalRect.height)
    rect.body = love.physics.newBody(world.world, rect.position.X, rect.position.Y, "static")
    rect.fixture = love.physics.newFixture(rect.body, rect.shape, 1)
    rect.fixture:setRestitution(1)
    rect.fixture:setUserData(rect)
    return rect
end

M.splitBall = function(balls, splitIntoAmount, collisionPoint)
    local toRemove = {}
    local toAdd = {}
    for i, ball in ipairs(balls) do
        for j = 1, splitIntoAmount do
            local newBall = M.getTempBall(ball, Screen, collisionPoint)
            newBall.radius = ball.radius / 2

            -- Ensure a unique position table per new ball
            local px = (collisionPoint and collisionPoint.x) or ball.position.X
            local py = (collisionPoint and collisionPoint.y) or ball.position.Y
            newBall.position = { X = px, Y = py }

            newBall = M.createBall(Screen, World, newBall)
            table.insert(toAdd, newBall)
        end
        -- Mark for removal
        table.insert(toRemove, ball)
        if ball.fixture then
            ball.fixture:destroy()
            ball.fixture = nil
        end
    end
    -- Remove old balls
    for _, oldBall in ipairs(toRemove) do
        for i = #Balls, 1, -1 do
            if Balls[i] == oldBall then
                table.remove(Balls, i)
            end
        end
    end
    -- Add new balls
    for _, newBall in ipairs(toAdd) do
        table.insert(Balls, newBall)
    end
end

M.createBorder = function(screen, world)
    local border = {}
    local points = { 0, 0, screen.X, 0, screen.X, screen.Y, 0, screen.Y }
    border.body = love.physics.newBody(world.world, 0, 0, "static")
    border.shape = love.physics.newChainShape(true, points)
    border.fixture = love.physics.newFixture(border.body, border.shape, 1)
    border.fixture:setFriction(0)
    border.fixture:setUserData(border)
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
    end
end

M.beginContact = function(a, b, coll)

end

M.endContact = function(a, b, coll)

end

M.preContact = function(a, b, coll)

end

M.postSolve = function(a, b, coll, normalimpulse, tangentimpulse)
    local success, err = pcall(function()
        local ballA = a:getUserData()
        local ballB = b:getUserData()
        if not ballA or not ballB then
            return
        end
        if ballA.canSplit == false or ballB.canSplit == false 
            or a:getShape():getRadius() <= 5 or b:getShape():getRadius() <= 10 then
            return
        end
        if (a:getShape():getType() == "circle" and b:getShape():getType() == "circle") then
            local x, y = coll:getPositions()
            local collisionPoint = { x = x or ((ballA.position.X + ballB.position.X) * (2/3)), y = y or
            ((ballA.position.Y + ballB.position.Y) / 2) }
            local newBalls = { ballA, ballB }
            table.insert(pendingBallCreations,
                { balls = newBalls, amount = math.random(1, 4), collisionPoint = collisionPoint })
        end
    end)
    if not success then
        print("Error getting user data: " .. err)
    end
end


return M
