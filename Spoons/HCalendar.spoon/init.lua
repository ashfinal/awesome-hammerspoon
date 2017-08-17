--- === HCalendar ===
---
--- A horizonal calendar inset into the desktop
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/HCalendar.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/HCalendar.spoon.zip)

local obj={}
obj.__index = obj

-- Metadata
obj.name = "HCalendar"
obj.version = "1.0"
obj.author = "ashfinal <ashfinal@gmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.hcalw = 31*24+20
obj.hcalh = 100

local function updateHcalCanvas()
    local titlestr = os.date("%B %Y")
    obj.canvas[2].text = titlestr
    local currentyear = os.date("%Y")
    local currentmonth = os.date("%m")
    local currentday = os.date("%d")
    local weeknames = {"Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"}
    local firstdayofnextmonth = os.time{year=currentyear, month=currentmonth+1, day=1}
    local lastdayofcurrentmonth = os.date("*t", firstdayofnextmonth-24*60*60).day
    for i=1,31 do
        local weekdayofqueriedday = os.date("*t", os.time{year=currentyear, month=currentmonth, day=i}).wday
        local mappedweekdaystr = weeknames[weekdayofqueriedday]
        obj.canvas[2+i].text = mappedweekdaystr
        obj.canvas[64+i].text = i
        if mappedweekdaystr == "Sa" or mappedweekdaystr == "Su" then
            obj.canvas[2+i].textColor = {hex="#FF7878"}
            obj.canvas[33+i].fillColor = {hex="#FF7878"}
            obj.canvas[64+i].textColor = {hex="#FF7878"}
        end
        if i == math.tointeger(currentday) then
            obj.canvas[33+i].fillColor = {hex="#00BAFF", alpha=0.8}
            obj.canvas[96].frame.x = tostring((10+24*(i-1))/obj.hcalw)
        end
        -- hide extra day
        if i > lastdayofcurrentmonth then
            obj.canvas[2+i].textColor.alpha = 0
            obj.canvas[33+i].fillColor.alpah = 0
            obj.canvas[64+i].textColor.alpah = 0
        end
    end
    -- trim the canvas
    obj.canvas:size({
        w = lastdayofcurrentmonth*24+20,
        h = 100
    })
end

function obj:init()
    local hcalbgcolor = {red=0, blue=0, green=0, alpha=0.3}
    local hcaltitlecolor = {red=1, blue=1, green=1, alpha=0.3}
    local todaycolor = {red=1, blue=1, green=1, alpha=0.2}
    local midlinecolor = {red=1, blue=1, green=1, alpha=0.5}
    local cscreen = hs.screen.mainScreen()
    local cres = cscreen:fullFrame()
    obj.canvas = hs.canvas.new({
        x = 40,
        y = cres.h-obj.hcalh-40,
        w = obj.hcalw,
        h = obj.hcalh,
    }):show()

    obj.canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
    obj.canvas:level(hs.canvas.windowLevels.desktopIcon)

    obj.canvas[1] = {
        id = "hcal_bg",
        type = "rectangle",
        action = "fill",
        fillColor = hcalbgcolor,
        roundedRectRadii = {xRadius = 10, yRadius = 10},
    }

    obj.canvas[2] = {
        id = "hcal_title",
        type = "text",
        text = "",
        textSize = 18,
        textColor = hcaltitlecolor,
        textAlignment = "left",
        frame = {
            x = tostring(10/obj.hcalw),
            y = tostring(10/obj.hcalh),
            w = tostring(1-20/obj.hcalw),
            h = "30%"
        }
    }

    -- upside weekday string
    for i=3, 3+30 do
        obj.canvas[i] = {
            type = "text",
            text = "",
            textFont = "Courier-Bold",
            textSize = 13,
            textAlignment = "center",
            frame = {
                x = tostring((10+24*(i-3))/obj.hcalw),
                y = "45%",
                w = tostring(24/(obj.hcalw-20)),
                h = "23%"
            }
        }
    end

    -- midline rectangle
    for i=34, 34+30 do
        obj.canvas[i] = {
            type = "rectangle",
            action = "fill",
            fillColor = midlinecolor,
            frame = {
                x = tostring((10+24*(i-34))/obj.hcalw),
                y = "65%",
                w = tostring(24/(obj.hcalw-20)),
                h = "4%"
            }
        }
    end

    -- downside day string
    for i=65, 65+30 do
        obj.canvas[i] = {
            type = "text",
            text = "",
            textFont = "Courier-Bold",
            textSize = 13,
            textAlignment = "center",
            frame = {
                x = tostring((10+24*(i-65))/obj.hcalw),
                y = "70%",
                w = tostring(24/(obj.hcalw-20)),
                h = "23%"
            }
        }
    end

    -- today cover rectangle
    obj.canvas[96] = {
        type = "rectangle",
        action = "fill",
        fillColor = todaycolor,
        roundedRectRadii = {xRadius = 3, yRadius = 3},
        frame = {
            x = tostring(10/obj.hcalw),
            y = "44%",
            w = tostring(24/(obj.hcalw-20)),
            h = "46%"
        }
    }

    if obj.timer == nil then
        obj.timer = hs.timer.doEvery(1800, function() updateHcalCanvas() end)
        obj.timer:setNextTrigger(0)
    else
        obj.timer:start()
    end

end

return obj
