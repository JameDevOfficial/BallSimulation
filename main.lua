UserInterface = require("game.ui")
Suit = require("game.suit")
Core = require("game.core")
DebugWorldDraw = require("game.libs.debugWorldDraw")
Colors = require("game.libs.colors")
Debug = require("game.libs.debug")
PerformanceMonitor = require("game.libs.performance")
SplitModule = require("game.splitting")
MergeModule = require("game.merging")

RENDER_DEBUG = false

IsPaused = false
HoveringUIElement = false
SplitBalls = false
MergeBalls = false

Screen = {}
World = {
    world = love.physics.newWorld(0, 100, true)
}
Balls = {}
Rects = {}
Ball = {
    position = {},
    color = { 0.2, 1, 0.2, 1 },
    radius = 50,
    minRadius = 20,
    maxRadius = 150,
    startVelocity = 100,
    interactCooldown = 0,
    canInteract = true,
}
local rect = {
    position = { X = Screen.centerX, Y = Screen.centerY },
    color = { 0.2, 1, 0.2, 1 },
    height = 200,
    width = 50,
    startVelocity = 0,
}
local border = {}

function love.load(dt)
    --World initialization
    Screen = UserInterface.windowResized()
    World.world:setCallbacks(Core.beginContact, Core.endContact, Core.preContact,
        Core.postSolve)
    border = Core.createBorder(Screen, World)

    -- Other stuff
    Ball.position = { X = Screen.centerX, Y = Screen.centerY }
    Ball = Core.createBall(Screen, World, Ball)
    table.insert(Balls, Ball)
end

function love.update(dt)
    --Pre checks and updates
    if IsPaused then return end
    ---
    Core.processPendingBallSplits()
    Core.processPendingBallRemovals()
    Core.processPendingBallMerges()
    Core.handleInteractCooldown(Balls, dt)
    Core.accelerateAllBalls(Balls, dt)
    World.world.update(World.world, dt)
    HoveringUIElement = false
    UserInterface.drawSuit()
end

function love.draw()
    UserInterface.drawFrame(Screen, Balls, Rects)
    Suit.draw()
    if RENDER_DEBUG then
        DebugWorldDraw(World.world, ((Screen.X - Screen.minSize) / 2), ((Screen.Y - Screen.minSize) / 2), Screen.minSize,
            Screen.minSize)
    end
end

function love.resize()
    Screen = UserInterface.windowResized()
    border.fixture:destroy()
    border = Core.createBorder(Screen, World)
end

function love.mousepressed(x, y, button)
    if HoveringUIElement then return end
    --Create Ball on mouseclick 1
    if button == 1 then
        local x, y = love.mouse.getPosition()
        local newBall = {
            position = { X = x, Y = y },
            color = { math.random(), math.random(), math.random(), 1 },
            radius = math.random(10, 50),
            startVelocity = 100,
            angle = math.random(0, 360)
        }
        newBall = Core.createBall(Screen, World, newBall)
        table.insert(Balls, newBall)
        print("made new ball (" .. #Balls .. ")")
        --Create Rect on mouseclick
    elseif button == 2 then
        local newRect = {
            position = {},
            color = { math.random(), math.random(), math.random(), 1 },
            width = math.random(10, 100),
            height = math.random(10, 100),
            startVelocity = 0,
        }
        newRect = Core.createRect(Screen, World, newRect)
        newRect.body:setLinearVelocity(rect.startVelocity, rect.startVelocity * math.pi)
        table.insert(Rects, newRect)
        print("made new rect (" .. #Rects .. ")")
    end
end

--Keypressed
function love.keypressed(k)
    Debug.keypressed(k, Balls, Rects)
end
