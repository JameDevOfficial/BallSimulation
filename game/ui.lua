local M = {}

M.drawFrame = function(screen, balls, rects)
    love.graphics.setBackgroundColor(1, 1, 1)
    Suit.layout:reset(((screen.X - screen.minSize) / 2))
    for i, ball in ipairs(balls) do
        love.graphics.setColor(ball.color[1], ball.color[2], ball.color[3], ball.color[4])
        love.graphics.circle("fill", ball.position.X, ball.position.Y, ball.radius)
    end
    for _, rect in ipairs(rects) do
        love.graphics.setColor(rect.color[1], rect.color[2], rect.color[3], rect.color[4])
        love.graphics.rectangle("fill", rect.position.X - rect.width / 2, rect.position.Y - rect.height / 2,
        rect.width,
        rect.height)
    end
    Suit.Label(love.timer.getFPS(), { align = "right" }, Suit.layout:row(screen.minSize, 30))
    

    local buttonCount = 0
    ButtonRows = 0
    local button = {width=100, height=30, padding = 10}
    local availableWidth = screen.minSize - 300
    local buttonsPerRow = math.floor((availableWidth + button.padding) / (button.width + button.padding))
    if buttonsPerRow < 1 then buttonsPerRow = 1 end
    Suit.layout:reset(
        ((screen.X - screen.minSize) / 2) +
        ((screen.minSize - (buttonsPerRow * button.width + (buttonsPerRow - 1) * button.padding)) / 2),
        0, button.padding)
    local clearButton = Suit.Button("Clear", Colors.getButtonOpt(nil, { 128, 128, 128 }), Suit.layout:col(button.width, button.height))
    if clearButton.hit then
        print("Clear")
        -- Clear the tables in place
        while #balls > 0 do table.remove(balls) end
        while #rects > 0 do table.remove(rects) end
    end
    if clearButton.hovered then
        print("hovering")
    end
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
