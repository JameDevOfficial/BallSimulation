local M = {}

M.drawFrame = function(screen, balls, rects)
    love.graphics.setBackgroundColor(1, 1, 1)
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
end


M.drawSuit = function()
    --Label
    Suit.layout:reset(((Screen.X - Screen.minSize) / 2))
    Suit.Label(love.timer.getFPS(), { align = "right" }, Suit.layout:row(Screen.minSize, 30))
    Suit.Label(#Balls, { align = "right" }, Suit.layout:row(Screen.minSize, 30))
    --Buttons
    local button = { width = 100, height = 30, padding = 10 }
    local availableWidth = Screen.minSize - 300
    local buttonsPerRow = math.floor((availableWidth + button.padding) / (button.width + button.padding))
    if buttonsPerRow < 1 then buttonsPerRow = 1 end
    Suit.layout:reset()

    Suit.layout:row(0, button.height)
    local clearButton = Suit.Button("Clear", Colors.getButtonOpt(nil, { 128, 128, 128 }),
        Suit.layout:row(button.width, button.height))
    local splitButton = Suit.Button("Toggle Splitting", Colors.getButtonOpt(nil, { 128, 128, 128 }),
        Suit.layout:row(button.width * 2, button.height))

    --Handle clicks and Hover
    if splitButton.hit then
        SplitBalls = not SplitBalls
    end
    if splitButton.hovered then
        HoveringUIElement = true
    end
    if clearButton.hit then
        print("Clear")
        -- Clear the tables in place
        for i = #Balls, 1, -1 do
            Balls[i].fixture:destroy()
            table.remove(Balls, i)
        end
        for i = #Rects, 1, -1 do
            Rects[i].fixture:destroy()
            table.remove(Rects, i)
        end
    end
    if clearButton.hovered then
        HoveringUIElement = true
    end
end

M.windowResized = function()
    local screen = {
        X = 0,
        Y = 0,
        centerX = 0,
        centerY = 0,
        minSize = 0,
        topLeft = { X = 0, Y = 0 },
        topRight = { X = 0, Y = 0 },
        bottomLeft = { X = 0, Y = 0 },
        bottomRight = { X = 0, Y = 0 }
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
