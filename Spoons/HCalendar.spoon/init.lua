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
    obj.canvas[3].text = titlestr
    local currentyear = os.date("%Y")
    local currentmonth = os.date("%m")
    local currentday = os.date("%d")
    local weeknames = {"Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"}
    local firstdayofnextmonth = os.time{year=currentyear, month=currentmonth+1, day=1}
    local lastdayofcurrentmonth = os.date("*t", firstdayofnextmonth-24*60*60).day
    for i=1,lastdayofcurrentmonth do
        local weekdayofqueriedday = os.date("*t", os.time{year=currentyear, month=currentmonth, day=i}).wday
        local mappedweekdaystr = weeknames[weekdayofqueriedday]
        obj.canvas[3+i].text = mappedweekdaystr
        obj.canvas[65+i].text = i
        if mappedweekdaystr == "Sa" or mappedweekdaystr == "Su" then
            obj.canvas[3+i].textColor = {hex="#FF7878"}
            obj.canvas[34+i].fillColor = {hex="#FF7878"}
            obj.canvas[65+i].textColor = {hex="#FF7878"}
        else
            -- Restore the default colors
            obj.canvas[3+i].textColor = {hex="#FFFFFF"}
            obj.canvas[34+i].fillColor = {hex="#FFFFFF", alpha=0.5}
            obj.canvas[65+i].textColor = {hex="#FFFFFF"}
        end
        if i == math.tointeger(currentday) then
            obj.canvas[34+i].fillColor = {hex="#00BAFF", alpha=0.8}
            obj.canvas[97].frame.x = tostring((10+24*(i-1))/obj.hcalw)
        end
    end
    -- hide extra day
    for i=lastdayofcurrentmonth+1, 31 do
        obj.canvas[3+i].text = ""
        obj.canvas[34+i].fillColor.alpha = 0
        obj.canvas[65+i].text = ""
    end
    -- Adjust the size of clipmask to clip the canvas
    obj.canvas[2].frame.w = tostring((lastdayofcurrentmonth*24+20)/obj.hcalw)
end

function obj:init()
    local hcalbgcolor = {hex="#000000", alpha=0.3}
    local hcaltitlecolor = {hex="#FFFFFF", alpha=0.3}
    local todaycolor = {hex="#FFFFFF", alpha=0.2}
    local midlinecolor = {hex="#FFFFFF", alpha=0.5}
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

    -- Use one pseudo element to clip the canvas
    obj.canvas[1] = {
        type = "rectangle",
        action = "clip",
        roundedRectRadii = {xRadius = 10, yRadius = 10},
    }

    -- *NOW* we can draw our actual "visible" parts
    obj.canvas[2] = {
        id = "hcal_bg",
        type = "rectangle",
        action = "fill",
        fillColor = hcalbgcolor,
        roundedRectRadii = {xRadius = 10, yRadius = 10},
    }

    obj.canvas[3] = {
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
    for i=4, 4+30 do
        obj.canvas[i] = {
            type = "text",
            text = "",
            textFont = "Courier-Bold",
            textSize = 13,
            textAlignment = "center",
            frame = {
                x = tostring((10+24*(i-4))/obj.hcalw),
                y = "45%",
                w = tostring(24/(obj.hcalw-20)),
                h = "23%"
            }
        }
    end

    -- midline rectangle
    for i=35, 35+30 do
        obj.canvas[i] = {
            type = "rectangle",
            action = "fill",
            fillColor = midlinecolor,
            frame = {
                x = tostring((10+24*(i-35))/obj.hcalw),
                y = "65%",
                w = tostring(24/(obj.hcalw-20)),
                h = "4%"
            }
        }
    end

    -- downside day string
    for i=66, 66+30 do
        obj.canvas[i] = {
            type = "text",
            text = "",
            textFont = "Courier-Bold",
            textSize = 13,
            textAlignment = "center",
            frame = {
                x = tostring((10+24*(i-66))/obj.hcalw),
                y = "70%",
                w = tostring(24/(obj.hcalw-20)),
                h = "23%"
            }
        }
    end

    -- today cover rectangle
    obj.canvas[97] = {
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
