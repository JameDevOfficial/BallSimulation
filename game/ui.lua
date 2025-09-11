local M = {}

M.drawFrame = function(screen, ball)
    love.graphics.setBackgroundColor(1, 1, 1)
    Suit.layout:reset(((screen.X - screen.minSize) / 2))
    love.graphics.setColor(ball.color[1], ball.color[2], ball.color[3], ball.color[4])
    love.graphics.circle("fill", ball.position.X, ball.position.Y, ball.radius)
    Suit.Label(love.timer.getFPS(), { align = "right" }, Suit.layout:row(screen.minSize, 30))
    --print("drew ball at ", ball.position.X, ball.position.Y, ball.radius)
end

M.windowResized = function()
    local screen = {
        X = 0,
        Y = 0,
        centerX = 0,
        centerY = 0,
        minSize = 0,
        topLeft = {X=0,Y=0},
        topRight= {X=0,Y=0},
        bottomLeft = {X=0,Y=0},
        bottomRight= {X=0,Y=0}
    }
    screen.X, screen.Y = love.graphics.getDimensions()
    screen.minSize = (screen.Y < screen.X) and screen.Y or screen.X
    screen.centerX = screen.X / 2
    screen.centerY = screen.Y / 2

    local half = screen.minSize / 2
    screen.topLeft.X = screen.centerX - half
    screen.topLeft.Y = screen.centerY - half
    screen.topRight.X = screen.centerX + half
    screen.topRight.Y = screen.centerY - half
    screen.bottomRight.X = screen.centerX + half
    screen.bottomRight.Y = screen.centerY + half
    screen.bottomLeft.X = screen.centerX - half
    screen.bottomLeft.Y = screen.centerY + half

    return screen
end

return M
