local M = {}

local timer = 0
local accelerateInterval = 1 --seconds
local accelerateFactor = 1.1

PendingBallSplits = {}
PendingBallRemovals = {}
PendingBallMerges = {}
M.getTempBall = function(originalBall, screen, pos)
    local ball = {
        position = {
            X = screen.centerX,
            Y = screen.centerY
        },
        color = { originalBall.color[1], originalBall.color[2], originalBall.color[3] or { 1, 1, 1, 1 } },
        radius = originalBall.radius or 20,
        startVelocity = originalBall.startVelocity or 100,
        interactCooldown = 5,
        canInteract = false,
        collisionPoint = pos
    }
    return ball
end

M.processPendingBallSplits = function()
    for _, split in ipairs(PendingBallSplits) do
        SplitModule.splitBall(split.balls, split.amount, split.collisionPoint)
        break
    end
    PendingBallSplits = {}
end

M.processPendingBallMerges = function()
    if #PendingBallMerges > 0 then
        local merge = table.remove(PendingBallMerges, 1)
        print("[MERGE] Processing merge for balls:", merge.balls[1], merge.balls[2])
        MergeModule.mergeBall(merge.balls, merge.collisionPoint)
        for i = #PendingBallMerges, 1, -1 do
            local balls = PendingBallMerges[i].balls
            if balls[1] == merge.balls[1] or balls[1] == merge.balls[2]
                or balls[2] == merge.balls[1] or balls[2] == merge.balls[2] then
                table.remove(PendingBallMerges, i)
            end
        end
    end
    PendingBallMerges = {}
end

M.processPendingBallRemovals = function()
    for _, ball in ipairs(PendingBallRemovals) do
        print("Removing ", ball, ball.fixture)
        if ball.fixture then
            ball.fixture:destroy()
            ball.fixture = nil
        end
        for i = #Balls, 1, -1 do
            if Balls[i] == ball then
                table.remove(Balls, i)
                break
            end
        end
    end
    PendingBallRemovals = {}
end

M.accelerateAllBalls = function(balls, dt)
    for i, ball in ipairs(balls) do
        ball.position.X, ball.position.Y = ball.body:getPosition()
        Core.accelerateBall(ball, dt)
    end
end

M.accelerateBall = function(ball, dt)
    if dt then
        timer = timer + dt
        if timer >= accelerateInterval then
            local vx, vy = ball.body:getLinearVelocity()
            ball.body:setLinearVelocity(vx * accelerateFactor, vy * accelerateFactor)
            timer = timer - accelerateInterval
        end
    else
        local vx, vy = ball.body:getLinearVelocity()
        ball.body:setLinearVelocity(vx * accelerateFactor, vy * accelerateFactor)
    end
end

M.createBall = function(screen, world, ball)
    ball.shape = love.physics.newCircleShape(ball.radius)
    ball.body = love.physics.newBody(world.world, ball.position.X, ball.position.Y, "dynamic")
    ball.fixture = love.physics.newFixture(ball.body, ball.shape, 1)
    ball.fixture:setRestitution(1)
    ball.fixture:setUserData(ball)
    if ball.interactCooldown == nil then ball.interactCooldown = 1 end
    if ball.canInteract == nil then ball.canInteract = false end

    -- Set velocity based on angle (in degrees)
    ball.angle = math.random(0, 360)
    local angleRad = math.rad(ball.angle or 0)
    local vx = ball.startVelocity * math.cos(angleRad)
    local vy = ball.startVelocity * math.sin(angleRad)
    ball.body:setLinearVelocity(vx, vy)
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

M.handleInteractCooldown = function(balls, dt)
    for _, ball in ipairs(balls) do
        if not ball.canInteract then
            ball.interactCooldown = ball.interactCooldown - dt
            if ball.interactCooldown <= 0 then
                ball.canInteract = true
            end
        end
    end
end

M.handleCollision = function(a, b, coll)
    if SplitBalls then
        SplitModule.splitHandler(a, b, coll)
    elseif MergeBalls then
        MergeModule.mergeHandler(a, b, coll)
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
        M.handleCollision(a, b, coll)
    end)
    if not success then
        print("Error while splitting balls: " .. err)
    end
end


return M
