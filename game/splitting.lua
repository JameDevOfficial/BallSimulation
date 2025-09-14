local M = {}

M.splitHandler = function(a,b,coll)
    local ballA = a:getUserData()
    local ballB = b:getUserData()
    if not ballA or not ballB then
        return
    end
    if ballA.canSplit == false or ballB.canSplit == false
        or a:getShape():getRadius() <= Ball.minRadius or b:getShape():getRadius() <= Ball.minRadius then
        return
    end
    if (a:getShape():getType() == "circle" and b:getShape():getType() == "circle") then
        local x, y = coll:getPositions()
        local collisionPoint = {
            x = x or ((ballA.position.X + ballB.position.X) * (2 / 3)),
            y = y or
                ((ballA.position.Y + ballB.position.Y) / 2)
        }
        local newBalls = { ballA, ballB }
        table.insert(PendingBallCreations,
            { balls = newBalls, amount = math.random(3, 5), collisionPoint = collisionPoint })
    end
end

M.splitBall = function(balls, splitIntoAmount, collisionPoint)
    local toRemove = {}
    local toAdd = {}
    for i, ball in ipairs(balls) do
        for j = 1, splitIntoAmount do
            local newBall = PhysicsCore.getTempBall(ball, Screen, collisionPoint)
            newBall.radius = ball.radius / 2

            local px = (collisionPoint and collisionPoint.x) or ball.position.X
            local py = (collisionPoint and collisionPoint.y) or ball.position.Y
            newBall.position = { X = px, Y = py }

            newBall = PhysicsCore.createBall(Screen, World, newBall)
            PhysicsCore.accelerateBall(newBall, nil)
            table.insert(toAdd, newBall)
        end
        table.insert(toRemove, ball)
        if ball.fixture then
            ball.fixture:destroy()
            ball.fixture = nil
        end
    end
    for _, oldBall in ipairs(toRemove) do
        for i = #Balls, 1, -1 do
            if Balls[i] == oldBall then
                table.remove(Balls, i)
            end
        end
    end
    for _, newBall in ipairs(toAdd) do
        table.insert(Balls, newBall)
    end
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

return M
