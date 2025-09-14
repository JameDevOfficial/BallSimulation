local M = {}

M.pendingMergeKeys = {}

M.mergeHandler = function(a, b, coll)
    --print("[MERGE] mergeHandler Checkpoint 0:", a, b)
    if (a:getShape():getType() ~= "circle" or b:getShape():getType() ~= "circle") then return end
    --print("[MERGE] mergeHandler Checkpoint 1:", a, b)
    local ballA = a:getUserData()
    local ballB = b:getUserData()
    if not ballA or not ballB then
        return
    end
    -- Check if balls are pending removal
    for _, removedBall in ipairs(PendingBallRemovals) do
        if ballA == removedBall or ballB == removedBall then
            return
        end
    end
    --print("[MERGE] mergeHandler Checkpoint 2 (radius):", a:getShape():getRadius(), b:getShape():getRadius(),
        --ballB.canInteract and ballA.canInteract)
    if ballA.canInteract == false or ballB.canInteract == false
        or a:getShape():getRadius() >= Ball.maxRadius or b:getShape():getRadius() >= Ball.maxRadius then
        return
    end
    -- Sort balls by their string representation for consistent ordering
    local ball1, ball2 = ballA, ballB
    if tostring(ballA) > tostring(ballB) then
        ball1, ball2 = ballB, ballA
    end
    --print("[MERGE] mergeHandler Checkpoint 3:", ball1, ball2)
    --print(tostring(ball1) < tostring(ball2), tostring(ball1), tostring(ball2))
    local key = tostring(ball1) .. tostring(ball2)
    if not M.pendingMergeKeys[key] then
        M.pendingMergeKeys[key] = true
        --print("[MERGE] mergeHandler Checkpoint 4:", ball1, ball2)
        local x, y = coll:getPositions()
        local collisionPoint = {
            x = x or ((ball1.position.X + ball2.position.X) * (2 / 3)),
            y = y or ((ball1.position.Y + ball2.position.Y) / 2)
        }
        local newBalls = { ball1, ball2 }
        --print("[MERGE] Enqueue merge for balls:", ball1, ball2)
        table.insert(PendingBallMerges, { balls = newBalls, collisionPoint = collisionPoint })
    end
end

M.mergeBall = function(balls, collisionPoint)
    --print("[MERGE] Creating merged ball from:", balls[1], balls[2])
    local toRemove = {}
    local toAdd = {}
    for i, ball in ipairs(balls) do
        table.insert(PendingBallRemovals, ball)
    end
    local rand = math.random(1, 2)
    local other = rand == 2 and 1 or 2
    local randBall = balls[rand]
    local newBall = Core.getTempBall(randBall, Screen, collisionPoint)
    newBall.radius = (randBall.radius + balls[other].radius) * 2/3
    if newBall.radius < randBall.radius or newBall.radius < balls[other].radius then
        newBall.radius = newBall.radius * 4/3
    end

    local px = (collisionPoint and collisionPoint.x) or randBall.position.X
    local py = (collisionPoint and collisionPoint.y) or randBall.position.Y
    newBall.position = { X = px, Y = py }

    newBall = Core.createBall(Screen, World, newBall)
    Core.accelerateBall(newBall, nil)
    table.insert(toAdd, newBall)
    table.insert(PendingBallRemovals, balls[1])
    table.insert(PendingBallRemovals, balls[2])

    for _, newBall in ipairs(toAdd) do
        table.insert(Balls, newBall)
    end
end

return M
