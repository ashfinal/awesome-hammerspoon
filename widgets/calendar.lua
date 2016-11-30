caltodaycolor = hs.drawing.color.white
calcolor = {red=235/255,blue=235/255,green=235/255}
calbgcolor = {red=0,blue=0,green=0,alpha=0.3}

if not caltopleft then
    local mainScreen = hs.screen.mainScreen()
    local mainRes = mainScreen:fullFrame()
    caltopleft = {mainRes.w-230-20,mainRes.h-161-44}
end

-- task_calendar = hs.styledtext.ansi(hs.execute("/usr/local/opt/task/bin/task calendar"):gsub("-",""),{font={name="Courier",size=16},color=red})

function drawToday()
    if todaycover ~= nil then
        todaycover:delete()
        todaycover=nil
    end
    local currentyear = os.date("%Y")
    local currentmonth = os.date("%m")
    local today = math.tointeger(os.date("%d"))
    local firstdayofcurrentmonth = os.time{year=currentyear, month=currentmonth, day=1}
    local lastdayoflastmonth = os.date("*t", firstdayofcurrentmonth-24*60*60)
    local weekyearoflastday = math.floor(lastdayoflastmonth.yday/7)+1
    local weekyearoftoday = math.floor(os.date("*t").yday/7)+1
    local rowofcurrentmonth = weekyearoftoday-weekyearoflastday+1
    local columnofcurrentmonth = os.date("*t").wday
    local splitw = 205
    local splith = 141
    local todaycoverrect = hs.geometry.rect(caltopleft[1]+10+splitw/7*(columnofcurrentmonth-1),caltopleft[2]+10+splith/7*(rowofcurrentmonth+1),splitw/7,splith/7)
    todaycover = hs.drawing.rectangle(todaycoverrect)
    todaycover:setStroke(false)
    todaycover:setRoundedRectRadii(3,3)
    todaycover:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
    todaycover:setLevel(hs.drawing.windowLevels.desktopIcon)
    todaycover:setFillColor(caltodaycolor)
    todaycover:setAlpha(0.3)
    todaycover:show()
end

function updateCal()
    local caltext = hs.styledtext.ansi(hs.execute("cal"),{font={name="Courier",size=16},color=calcolor})
    caldraw:setStyledText(caltext)
    drawToday()
end

function showCalendar()
    if not calbg then
        local bgrect = hs.geometry.rect(caltopleft[1],caltopleft[2],230,161)
        calbg = hs.drawing.rectangle(bgrect)
        calbg:setFillColor(calbgcolor)
        calbg:setStroke(false)
        calbg:setRoundedRectRadii(10,10)
        calbg:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        calbg:setLevel(hs.drawing.windowLevels.desktopIcon)
        calbg:show()

        local caltext = hs.styledtext.ansi(hs.execute("cal"),{font={name="Courier",size=16},color=calcolor})
        local calrect = hs.geometry.rect(caltopleft[1]+15,caltopleft[2]+10,230,161)
        caldraw = hs.drawing.text(calrect,caltext)
        caldraw:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        caldraw:setLevel(hs.drawing.windowLevels.desktopIcon)
        caldraw:show()

        drawToday()
        caltimer = hs.timer.doEvery(1800,function() updateCal() end)
    else
        caltimer:stop()
        caltimer=nil
        todaycover:delete()
        todaycover=nil
        calbg:delete()
        calbg=nil
        caldraw:delete()
        caldraw=nil
    end
end

if not launch_calendar then launch_calendar=true end
if launch_calendar == true then showCalendar() end

hs.hotkey.bind({"cmd", "shift", "ctrl"}, "K", function() showCalendar() end)
