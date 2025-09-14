local M = {}

M.mergeHandler = function(a, b, coll)
    print("[MERGE] mergeHandler Checkpoint 0:", a, b)
    if (a:getShape():getType() ~= "circle" or b:getShape():getType() ~= "circle") then return end
    print("[MERGE] mergeHandler Checkpoint 1:", a, b)
    local ballA = a:getUserData()
    local ballB = b:getUserData()
    if not ballA or not ballB then
        return
    end
    print("[MERGE] mergeHandler Checkpoint 2 (radius):", a:getShape():getRadius(), b:getShape():getRadius(),
        ballB.canInteract and ballA.canInteract)
    if ballA.canInteract == false or ballB.canInteract == false
        or a:getShape():getRadius() >= Ball.maxRadius or b:getShape():getRadius() >= Ball.maxRadius then
        return
    end
    -- Only enqueue if ballA's address is less than ballB's
    print("[MERGE] mergeHandler Checkpoint 3:", ballA, ballB)
    if tostring(ballA) < tostring(ballB) then
        print("[MERGE] mergeHandler Checkpoint 4:", ballA, ballB)
        local x, y = coll:getPositions()
        local collisionPoint = {
            x = x or ((ballA.position.X + ballB.position.X) * (2 / 3)),
            y = y or ((ballA.position.Y + ballB.position.Y) / 2)
        }
        local newBalls = { ballA, ballB }
        print("[MERGE] Enqueue merge for balls:", ballA, ballB)
        table.insert(PendingBallMerges, { balls = newBalls, collisionPoint = collisionPoint })
    end
end

M.mergeBall = function(balls, collisionPoint)
    print("[MERGE] Creating merged ball from:", balls[1], balls[2])
    local toRemove = {}
    local toAdd = {}
    for i, ball in ipairs(balls) do
        table.insert(PendingBallRemovals, ball)
    end
    local rand = math.random(1, 2)
    local randBall = balls[rand]
    local newBall = Core.getTempBall(randBall, Screen, collisionPoint)
    newBall.radius = randBall.radius * 2

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
