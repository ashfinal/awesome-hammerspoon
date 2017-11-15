--- === CountDown ===
---
--- Tiny countdown with visual indicator
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/CountDown.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/CountDown.spoon.zip)

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "CountDown"
obj.version = "1.0"
obj.author = "ashfinal <ashfinal@gmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.canvas = nil
obj.timer = nil

function obj:init()
    self.canvas = hs.canvas.new({x=0, y=0, w=0, h=0}):show()
    self.canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
    self.canvas:level(hs.canvas.windowLevels.status)
    self.canvas:alpha(0.35)
    self.canvas[1] = {
        type = "rectangle",
        action = "fill",
        fillColor = hs.drawing.color.osx_red,
        frame = {x="0%", y="0%", w="0%", h="100%"}
    }
    self.canvas[2] = {
        type = "rectangle",
        action = "fill",
        fillColor = hs.drawing.color.osx_green,
        frame = {x="0%", y="0%", w="0%", h="100%"}
    }
end

--- CountDown:startFor(minutes)
--- Method
--- Start a countdown for `minutes` minutes immediately. Calling this method again will kill the existing countdown instance.
---
--- Parameters:
---  * minutes - How many minutes

local function canvasCleanup()
    if obj.timer then
        obj.timer:stop()
        obj.timer = nil
    end
    obj.canvas[1].frame.w = "0%"
    obj.canvas[2].frame.x = "0%"
    obj.canvas[2].frame.w = "0%"
    obj.canvas:frame({x=0, y=0, w=0, h=0})
end

function obj:startFor(minutes)
    if obj.timer then
        canvasCleanup()
    else
        local mainScreen = hs.screen.mainScreen()
        local mainRes = mainScreen:fullFrame()
        obj.canvas:frame({x=mainRes.x, y=mainRes.y+mainRes.h-5, w=mainRes.w, h=5})
        -- Set minimum visual step to 2px (i.e. Make sure every trigger updates 2px on screen at least.)
        local minimumStep = 2
        local secCount = math.ceil(60*minutes)
        obj.loopCount = 0
        if mainRes.w/secCount >= 2 then
            obj.timer = hs.timer.doEvery(1, function()
                obj.loopCount = obj.loopCount+1/secCount
                obj:setProgress(obj.loopCount, minutes)
            end)
        else
            local interval = 2/(mainRes.w/secCount)
            obj.timer = hs.timer.doEvery(interval, function()
                obj.loopCount = obj.loopCount+1/mainRes.w*2
                obj:setProgress(obj.loopCount, minutes)
            end)
        end
    end

    return self
end

--- CountDown:pauseOrResume()
--- Method
--- Pause or resume the existing countdown.
---

function obj:pauseOrResume()
    if obj.timer then
        if obj.timer:running() then
            obj.timer:stop()
        else
            obj.timer:start()
        end
    end
end

--- CountDown:setProgress(progress)
--- Method
--- Set the progress of visual indicator to `progress`.
---
--- Parameters:
---  * progress - an number specifying the value of progress (0.0 - 1.0)

function obj:setProgress(progress, notifystr)
    if obj.canvas:frame().h == 0 then
        -- Make the canvas actully visible
        local mainScreen = hs.screen.mainScreen()
        local mainRes = mainScreen:fullFrame()
        obj.canvas:frame({x=mainRes.x, y=mainRes.y+mainRes.h-5, w=mainRes.w, h=5})
    end
    if progress >= 1 then
        canvasCleanup()
        if notifystr then
            hs.notify.new({
                title = "Time(" .. notifystr .. " mins) is up!",
                informativeText = "Now is " .. os.date("%X")
            }):send()
        end
    else
        obj.canvas[1].frame.w = tostring(progress)
        obj.canvas[2].frame.x = tostring(progress)
        obj.canvas[2].frame.w = tostring(1-progress)
    end
end

return obj
