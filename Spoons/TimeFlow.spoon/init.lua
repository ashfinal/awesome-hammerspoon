--- === TimeFlow ===
---
--- A widget showing time flown in one year.
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/TimeFlow.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/TimeFlow.spoon.zip)

local obj={}
obj.__index = obj

-- Metadata
obj.name = "TimeFlow"
obj.version = "1.0"
obj.author = "ashfinal <ashfinal@gmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Internal function used to find our location, so we know where to load files from
local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

obj.spoonPath = script_path()

local function updateElapsedCanvas()
   local nowtable = os.date("*t")
   local nowyday = nowtable.yday
   local nowhour = string.format("%2s", nowtable.hour)
   local nowmin = string.format("%2s", nowtable.min)
   local nowsec = string.format("%2s", nowtable.sec)
   local timestr = nowyday.." days "..nowhour.." hours "..nowmin.." min "..nowsec.." sec"
   local secs_since_epoch = os.time()
   local nowyear = nowtable.year
   local yearstartsecs_since_epoch = os.time({year=nowyear, month=1, day=1, hour=0})
   local nowyear_elapsed_secs = secs_since_epoch - yearstartsecs_since_epoch
   local yearendsecs_since_epoch = os.time({year=nowyear+1, month=1, day=1, hour=0})
   local nowyear_total_secs = yearendsecs_since_epoch - yearstartsecs_since_epoch
   local elapsed_percent = nowyear_elapsed_secs/nowyear_total_secs
   if obj.canvas:isShowing() then
       obj.canvas[3].text = timestr
       obj.canvas[6].frame.w = tostring(240/280*elapsed_percent)
   end
end

function obj:init()
    local cscreen = hs.screen.mainScreen()
    local cres = cscreen:fullFrame()
    obj.canvas = hs.canvas.new({
        x = cres.w-280-20,
        y = 400,
        w = 280,
        h = 125
    }):show()
    obj.canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
    obj.canvas:level(hs.canvas.windowLevels.desktopIcon)
    -- canvas background
    obj.canvas[1] = {
        action = "fill",
        type = "rectangle",
        fillColor = {hex="#000000", alpha=0.2},
        roundedRectRadii = {xRadius=5, yRadius=5},
    }
    -- title
    obj.canvas[2] = {
        type = "text",
        text = "Time Elapsed",
        textSize = 14,
        textColor = {hex="#FFFFFF", alpha=0.3},
        frame = {
            x = tostring(10/280),
            y = tostring(10/125),
            w = tostring(260/280),
            h = tostring(25/125),
        }
    }
    -- time
    obj.canvas[3] = {
        type = "text",
        text = "",
        textColor = {hex="#A6AAC3"},
        textSize = 17,
        textAlignment = "center",
        frame = {
            x = tostring(0/280),
            y = tostring(35/125),
            w = tostring(280/280),
            h = tostring(25/125),
        }
    }
    -- indicator background
    obj.canvas[4] = {
        type = "image",
        image = hs.image.imageFromPath(self.spoonPath .. "/timebg.png"),
        frame = {
            x = tostring(10/280),
            y = tostring(65/125),
            w = tostring(260/280),
            h = tostring(50/125),
        }
    }
    -- light indicator
    obj.canvas[5] = {
        action = "fill",
        type = "rectangle",
        fillColor = {hex="#FFFFFF", alpha=0.2},
        frame = {
            x = tostring(20/280),
            y = tostring(75/125),
            w = tostring(240/280),
            h = tostring(20/125),
        }
    }
    -- indicator mask
    obj.canvas[6] = {
        action = "fill",
        type = "rectangle",
        frame = {
            x = tostring(20/280),
            y = tostring(75/125),
            w = tostring(240/280),
            h = tostring(20/125),
        }
    }
    -- color indicator
    obj.canvas[7] = {
        action = "fill",
        type = "rectangle",
        frame = {
            x = tostring(20/280),
            y = tostring(75/125),
            w = tostring(240/280),
            h = tostring(20/125),
        },
        fillGradient="linear",
        fillGradientColors = {
            {hex = "#00A0F7"},
            {hex = "#92D2E5"},
            {hex = "#4BE581"},
            {hex = "#EAF25E"},
            {hex = "#F4CA55"},
            {hex = "#E04E4E"},
        },
    }
    obj.canvas[7].compositeRule = "sourceAtop"

    if obj.timer == nil then
        obj.timer = hs.timer.doEvery(1, function() updateElapsedCanvas() end)
    else
        obj.timer:start()
    end
end

return obj
