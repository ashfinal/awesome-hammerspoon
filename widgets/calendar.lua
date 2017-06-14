caltodaycolor = hs.drawing.color.white
calcolor = {red=235/255,blue=235/255,green=235/255}
calbgcolor = {red=0,blue=0,green=0,alpha=0.3}
weeknumcolor = {red=246/255,blue=246/255,green=246/255,alpha=0.5}

if not caltopleft then
    local mainScreen = hs.screen.mainScreen()
    local mainRes = mainScreen:fullFrame()
    caltopleft = {mainRes.w-230-20,mainRes.h-161-44}
end

function drawToday()
    -- Offset +1 for start week from Sunday
    local todayyearweek = hs.execute("date -v+1d +'%W'")
    -- Year week of the first day of current month with offset +1
    local fdcmyearweek = hs.execute("date -v1d -v+1d +'%W'")
    local rowofcurrentmonth = todayyearweek - fdcmyearweek + 1
    local columnofcurrentmonth = os.date("*t").wday
    local splitw = 205
    local splith = 141
    local todaycoverrect = hs.geometry.rect(caltopleft[1]+10+splitw/7*(columnofcurrentmonth-1),caltopleft[2]+10+splith/7*(rowofcurrentmonth+1),splitw/7,splith/7)
    if not todaycover then
        todaycover = hs.drawing.rectangle(todaycoverrect)
        todaycover:setStroke(false)
        todaycover:setRoundedRectRadii(3,3)
        todaycover:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        todaycover:setLevel(hs.drawing.windowLevels.desktopIcon)
        todaycover:setFillColor(caltodaycolor)
        todaycover:setAlpha(0.3)
        todaycover:show()
    else
        todaycover:setFrame(todaycoverrect)
    end
end

function drawWeeknum()
    local fdcmyearweek = hs.execute("date -v1d -v+1d +'%W'")
    weeknumstr = tonumber(fdcmyearweek)
    for i=weeknumstr+1,weeknumstr+4 do
        weeknumstr = weeknumstr .. "\r" .. i
    end
    local weeknumrect = hs.geometry.rect(caltopleft[1]-205/7+15,caltopleft[2]+141/7*2+10,205/7,141/7*5)
    local styledwknum = hs.styledtext.new(weeknumstr,{font={name="Courier",size=16},color=weeknumcolor})
    if not weeknumdraw then
        weeknumdraw = hs.drawing.text(weeknumrect,styledwknum)
        weeknumdraw:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        weeknumdraw:setLevel(hs.drawing.windowLevels.desktopIcon)
        weeknumdraw:show()
    else
        weeknumdraw:setStyledText(styledwknum)
    end
end

function updateCal()
    local caltext = hs.styledtext.ansi(hs.execute("cal"),{font={name="Courier",size=16},color=calcolor})
    caldraw:setStyledText(caltext)
    drawWeeknum()
    drawToday()
end

function showCalendar()
    if not calbg then
        local bgrect = hs.geometry.rect(caltopleft[1]-205/7,caltopleft[2],230+205/7,161)
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

        drawWeeknum()
        drawToday()
        if caltimer == nil then
            caltimer = hs.timer.doEvery(1800,function() updateCal() end)
        else
            caltimer:start()
        end
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
