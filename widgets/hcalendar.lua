local hcalbgcolor = {red=0,blue=0,green=0,alpha=0.3}
local hcaltitlecolor = {red=1,blue=1,green=1,alpha=0.3}
local offdaycolor = {red=255/255,blue=120/255,green=120/255,alpha=1}
local todaycolor = {red=1,blue=1,green=1,alpha=0.2}
local midlinecolor = {red=1,blue=1,green=1,alpha=0.5}
local midlinetodaycolor = {red=0,blue=1,green=186/255,alpha=0.8}
local hcalw = 31 * 24 + 20
local hcalh = 100

if not hcaltopleft then
    local mainScreen = hs.screen.mainScreen()
    local mainRes = mainScreen:fullFrame()
    hcaltopleft = {40, mainRes.h-hcalh-40}
end

hcalendarCanvas = hs.canvas.new({
    x = hcaltopleft[1],
    y = hcaltopleft[2],
    w = hcalw,
    h = hcalh,
}):show()

hcalendarCanvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
hcalendarCanvas:level(hs.canvas.windowLevels.desktopIcon)

hcalendarCanvas[1] = {
    id = "hcal_bg",
    type = "rectangle",
    action = "fill",
    fillColor = hcalbgcolor,
    roundedRectRadii = {xRadius = 10, yRadius = 10},
}

hcalendarCanvas[2] = {
    id = "hcal_title",
    type = "text",
    text = "",
    textSize = 18,
    textColor = hcaltitlecolor,
    textAlignment = "left",
    frame = {
        x = tostring(10/hcalw),
        y = tostring(10/hcalh),
        w = tostring(1-20/hcalw),
        h = "30%"
    }
}

-- upside weekday string
for i=3, 3+30 do
    hcalendarCanvas[i] = {
        type = "text",
        text = "",
        textFont = "Courier-Bold",
        textSize = 13,
        textAlignment = "center",
        frame = {
            x = tostring((10+24*(i-3))/hcalw),
            y = "45%",
            w = tostring(24/(hcalw-20)),
            h = "23%"
        }
    }
end

-- midline rectangle
for i=34, 34+30 do
    hcalendarCanvas[i] = {
        type = "rectangle",
        action = "fill",
        fillColor = midlinecolor,
        frame = {
            x = tostring((10+24*(i-34))/hcalw),
            y = "65%",
            w = tostring(24/(hcalw-20)),
            h = "4%"
        }
    }
end

-- downside day string
for i=65, 65+30 do
    hcalendarCanvas[i] = {
        type = "text",
        text = "",
        textFont = "Courier-Bold",
        textSize = 13,
        textAlignment = "center",
        frame = {
            x = tostring((10+24*(i-65))/hcalw),
            y = "70%",
            w = tostring(24/(hcalw-20)),
            h = "23%"
        }
    }
end

-- today cover rectangle
hcalendarCanvas[96] = {
    type = "rectangle",
    action = "fill",
    fillColor = todaycolor,
    roundedRectRadii = {xRadius = 3, yRadius = 3},
    frame = {
        x = tostring(10/hcalw),
        y = "44%",
        w = tostring(24/(hcalw-20)),
        h = "46%"
    }
}

function updateHcalCanvas()
    local titlestr = os.date("%B %Y")
    hcalendarCanvas[2].text = titlestr
    local currentyear = os.date("%Y")
    local currentmonth = os.date("%m")
    local currentday = os.date("%d")
    local weeknames = {"Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"}
    local firstdayofnextmonth = os.time{year=currentyear, month=currentmonth+1, day=1}
    local lastdayofcurrentmonth = os.date("*t", firstdayofnextmonth-24*60*60).day
    for i=1,31 do
        local weekdayofqueriedday = os.date("*t", os.time{year=currentyear, month=currentmonth, day=i}).wday
        local mappedweekdaystr = weeknames[weekdayofqueriedday]
        hcalendarCanvas[2+i].text = mappedweekdaystr
        hcalendarCanvas[64+i].text = i
        if mappedweekdaystr == "Sa" or mappedweekdaystr == "Su" then
            hcalendarCanvas[2+i].textColor = offdaycolor
            hcalendarCanvas[33+i].fillColor = offdaycolor
            hcalendarCanvas[64+i].textColor = offdaycolor
        end
        if i == math.tointeger(currentday) then
            hcalendarCanvas[33+i].fillColor = midlinetodaycolor
            hcalendarCanvas[96].frame.x = tostring((10+24*(i-1))/hcalw)
        end
        -- hide extra day
        if i > lastdayofcurrentmonth then
            hcalendarCanvas[2+i].textColor.alpha = 0
            hcalendarCanvas[33+i].fillColor.alpah = 0
            hcalendarCanvas[64+i].textColor.alpah = 0
        end
    end
    -- trim the canvas
    hcalendarCanvas:size({
        w = lastdayofcurrentmonth*24+20,
        h = 100
    })
end

if hcaltimer == nil then
    hcaltimer = hs.timer.doEvery(1800, function() updateHcalCanvas() end)
    hcaltimer:setNextTrigger(0)
else
    hcaltimer:start()
end
