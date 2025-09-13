
M = {}
local pressedDebug, lastPressedDebug = 0,0

local function pauseGame()
    if IsPaused ~= nil then
        IsPaused = not IsPaused
    end
end

local lastPressedDebugInfo = nil
local amountPressedDebugInfo = 0

function M.keypressed(k, gridFactor, grid)
    if k == 'f8' then
        if amountPressedDebugInfo >= 5 then
            DEBUG = not DEBUG
            amountPressedDebugInfo = 0
            lastPressedDebugInfo = nil
        elseif lastPressedDebugInfo == nil then
            amountPressedDebugInfo = 1
            lastPressedDebugInfo = os.time()
            return
        elseif os.time() - lastPressedDebugInfo <= 1 then
            amountPressedDebugInfo = amountPressedDebugInfo + 1
            lastPressedDebugInfo = os.time()
        else
            amountPressedDebugInfo = 1
            lastPressedDebugInfo = os.time()
        end
    end

    if not DEBUG then return end
    if k == 'f5' then
        --
    elseif k == 'f6' then
        pauseGame()
        print("Game paused:", IsPaused)
    elseif k == 'f7' then
        local avg = PerformanceMonitor.getAvg()
        PerformanceMonitor.saveToFile()
        PerformanceMonitor.clearEntries()
        print("Avg: "..avg)
        print("Performance entries saved and cleared.")
    end
end

return M