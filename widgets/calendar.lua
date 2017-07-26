local caltodaycolor = {red=1, blue=1, green=1, alpha=0.3}
local calcolor = {red=235/255, blue=235/255, green=235/255}
local calbgcolor = {red=0, blue=0, green=0, alpha=0.3}
local weeknumcolor = {red=246/255, blue=246/255, green=246/255, alpha=0.5}
local calw = 260
local calh = 184

if not caltopleft then
    local mainScreen = hs.screen.mainScreen()
    local mainRes = mainScreen:fullFrame()
    caltopleft = {mainRes.w-calw-20,mainRes.h-calh-20}
end

calendarCanvas = hs.canvas.new({
    x = caltopleft[1],
    y = caltopleft[2],
    w = calw,
    h = calh
}):show()

calendarCanvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
calendarCanvas:level(hs.canvas.windowLevels.desktopIcon)

calendarCanvas[1] = {
    id = "cal_bg",
    type = "rectangle",
    action = "fill",
    fillColor = calbgcolor,
    roundedRectRadii = {xRadius = 10, yRadius = 10},
}

calendarCanvas[2] = {
    id = "cal_title",
    type = "text",
    text = "",
    textFont = "Courier",
    textSize = 16,
    textColor = calcolor,
    textAlignment = "center",
    frame = {
        x = tostring(10/calw),
        y = tostring(10/calw),
        w = tostring(1-20/calw),
        h = tostring((calh-20)/8/calh)
    }
}

local weeknames = {"Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"}
for i=1,#weeknames do
    calendarCanvas[2+i] = {
        id = "cal_weekday",
        type = "text",
        text = weeknames[i],
        textFont = "Courier",
        textSize = 16,
        textColor = calcolor,
        textAlignment = "center",
        frame = {
            x = tostring((10+(calw-20)/8*i)/calw),
            y = tostring((10+(calh-20)/8)/calh),
            w = tostring((calw-20)/8/calw),
            h = tostring((calh-20)/8/calh)
        }
    }
end

-- Create 7x6 calendar table
for i=1,6 do
    for k=1,7 do
        calendarCanvas[9+7*(i-1)+k] = {
            type = "text",
            text = "",
            textFont = "Courier",
            textSize = 16,
            textColor = calcolor,
            textAlignment = "center",
            frame = {
                x = tostring((10+(calw-20)/8*k)/calw),
                y = tostring((10+(calh-20)/8*(i+1))/calh),
                w = tostring((calw-20)/8/calw),
                h = tostring((calh-20)/8/calh)
            }
        }
    end
end

-- Create yearweek column
for i=1,6 do
    calendarCanvas[51+i] = {
        type = "text",
        text = "",
        textFont = "Courier",
        textSize = 16,
        textColor = weeknumcolor,
        textAlignment = "center",
        frame = {
            x = tostring(10/calw),
            y = tostring((10+(calh-20)/8*(i+1))/calh),
            w = tostring((calw-20)/8/calw),
            h = tostring((calh-20)/8/calh)
        }
    }
end

-- today cover rectangle
calendarCanvas[58] = {
    type = "rectangle",
    action = "fill",
    fillColor = caltodaycolor,
    roundedRectRadii = {xRadius = 3, yRadius = 3},
    frame = {
        x = tostring((10+(calw-20)/8)/calw),
        y = tostring((10+(calh-20)/8*2)/calh),
        w = tostring((calw-20)/8/calw),
        h = tostring((calh-20)/8/calh)
    }
}

function updateCalCanvas()
    local titlestr = os.date("%B %Y")
    calendarCanvas[2].text = titlestr
    local current_year = os.date("%Y")
    local current_month = os.date("%m")
    local current_day = os.date("%d")
    local firstday_of_nextmonth = os.time{year=current_year, month=current_month+1, day=1}
    local maxday_of_currentmonth = os.date("*t", firstday_of_nextmonth-24*60*60).day
    local weekday_of_firstday = os.date("*t", os.time{year=current_year, month=current_month, day=1}).wday
    local needed_rownum = math.ceil((weekday_of_firstday+maxday_of_currentmonth-1)/7)

    for i=1,needed_rownum do
        for k=1,7 do
            local caltable_idx = 7*(i-1)+k
            local pushbacked_value = caltable_idx-weekday_of_firstday + 2
            if pushbacked_value <= 0 or pushbacked_value > maxday_of_currentmonth then
                calendarCanvas[9+caltable_idx].text = ""
            else
                calendarCanvas[9+caltable_idx].text = pushbacked_value
            end
            if pushbacked_value == math.tointeger(current_day) then
                calendarCanvas[58].frame.x = tostring((10+(calw-20)/8*k)/calw)
                calendarCanvas[58].frame.y = tostring((10+(calh-20)/8*(i+1))/calh)
            end
        end
    end
    -- update yearweek
    local yearweek_of_firstday = hs.execute("date -v1d +'%W'")
    for i=1,6 do
        local yearweek_rowvalue = math.tointeger(yearweek_of_firstday)+i-1
        calendarCanvas[51+i].text = yearweek_rowvalue
        if i > needed_rownum then
            calendarCanvas[51+i].text = ""
        end
    end
    -- trim the canvas
    calendarCanvas:size({
        w = calw,
        h = 20+(calh-20)/8*(needed_rownum+2)
    })
end

if caltimer == nil then
    caltimer = hs.timer.doEvery(1800, function() updateCalCanvas() end)
    caltimer:setNextTrigger(0)
else
    caltimer:start()
end
