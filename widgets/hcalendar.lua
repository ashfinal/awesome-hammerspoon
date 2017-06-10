hcalbgcolor = {red=0,blue=0,green=0,alpha=0.3}
hcaltitlecolor = {red=1,blue=1,green=1,alpha=0.3}
offdaycolor = {red=255/255,blue=120/255,green=120/255,alpha=1}
hcaltodaycolor = {red=1,blue=1,green=1,alpha=0.2}
midlinecolor = {red=1,blue=1,green=1,alpha=0.5}
midlinetodaycolor = {red=0,blue=1,green=186/255,alpha=0.8}
midlineoffcolor = {red=1,blue=119/255,green=119/255,alpha=0.5}

if not hcaltopleft then
    local mainScreen = hs.screen.mainScreen()
    local mainRes = mainScreen:fullFrame()
    hcaltopleft = {40,mainRes.h-102-40}
end

weeknames = {"Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"}
hcaltitlewh = {180,32}
hcaldaywh = {23.43,24}
function showHCalendar()
    local titlestr = os.date("%B %Y")
    if not hcaltitle then
        local styledtitle = hs.styledtext.new(titlestr,{font={size=18},color=hcaltitlecolor,paragraphStyle={alignment="left"}})
        local title_rect = hs.geometry.rect(hcaltopleft[1]+10,hcaltopleft[2]+15,hcaltitlewh[1],hcaltitlewh[2])
        hcaltitle = hs.drawing.text(title_rect,styledtitle)
        hcaltitle:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        hcaltitle:setLevel(hs.drawing.windowLevels.desktopIcon)
        hcaltitle:show()
    else
        hcaltitle:setText(titlestr)
    end

    local currentyear = os.date("%Y")
    local currentmonth = os.date("%m")
    local firstdayofnextmonth = os.time{year=currentyear, month=currentmonth+1, day=1}
    local maxdayofcurrentmonth = os.date("*t", firstdayofnextmonth-24*60*60).day
    weekdayup = ""
    daydown = ""
    offday = {}
    for i=1,maxdayofcurrentmonth do
        local weekdayofquery = os.date("*t", os.time{year=currentyear, month=currentmonth, day=i}).wday
        local weekstr = weeknames[weekdayofquery]
        weekdayup = weekdayup .. weekstr .. ' '
        daydown = daydown .. string.format('%2s',i)..' '
        if weekstr == 'Sa' or weekstr == 'Su' then
            table.insert(offday,{i,weekstr..'\n'..string.format('%2s',i)})
        end
    end
    local caltext = weekdayup..'\n'..daydown
    if not hcaltextdraw then
        local styledcaltext = hs.styledtext.new(caltext,{font={name="Courier-Bold",size=13},paragraphStyle={lineSpacing=8.0}})
        local caltextrect = hs.geometry.rect(hcaltopleft[1]+10,hcaltopleft[2]+15+hcaltitlewh[2],hcaldaywh[1]*maxdayofcurrentmonth,43)
        hcaltextdraw = hs.drawing.text(caltextrect,styledcaltext)
        hcaltextdraw:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        hcaltextdraw:setLevel(hs.drawing.windowLevels.desktopIcon)
        hcaltextdraw:show()
    else
        hcaltextdraw:setText(caltext)
    end

    local midlinerect = hs.geometry.rect(hcaltopleft[1]+10,hcaltopleft[2]+15+hcaltitlewh[2]+20,hcaldaywh[1]*maxdayofcurrentmonth-3,4)
    if not midlinedraw then
        midlinedraw = hs.drawing.rectangle(midlinerect)
        midlinedraw:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        midlinedraw:setLevel(hs.drawing.windowLevels.desktopIcon)
        midlinedraw:setFillColor(midlinecolor)
        midlinedraw:setStroke(false)
        midlinedraw:show()
    else
        midlinedraw:setFrame(midlinerect)
    end

    local hcalbgrect = hs.geometry.rect(hcaltopleft[1],hcaltopleft[2],hcaldaywh[1]*maxdayofcurrentmonth+20-3,102)
    if not hcalbg then
        hcalbg = hs.drawing.rectangle(hcalbgrect)
        hcalbg:setFillColor(hcalbgcolor)
        hcalbg:setStroke(false)
        hcalbg:setRoundedRectRadii(10,10)
        hcalbg:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        hcalbg:setLevel(hs.drawing.windowLevels.desktopIcon)
        hcalbg:show()
    else
        hcalbg:setFrame(hcalbgrect)
    end

    if offday_holder and #offday_holder > 0 then
        for i=1,#offday_holder do
            offday_holder[i]:delete()
            offdaymidline_holder[i]:delete()
        end
    end

    offday_holder = {}
    offdaymidline_holder = {}
    for i=1,#offday do
        local offdayrect = hs.geometry.rect(hcaltopleft[1]+10+hcaldaywh[1]*(offday[i][1]-1),hcaltopleft[2]+15+hcaltitlewh[2],hcaldaywh[1],43)
        local offdaytext = hs.styledtext.new(offday[i][2],{font={name="Courier-Bold",size=13},color=offdaycolor,paragraphStyle={lineSpacing=8.0}})
        table.insert(offday_holder,hs.drawing.text(offdayrect,offdaytext))
        offday_holder[i]:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        offday_holder[i]:setLevel(hs.drawing.windowLevels.desktopIcon)
        offday_holder[i]:show()
        local offdaymidlinerect = hs.geometry.rect(hcaltopleft[1]+10+hcaldaywh[1]*(offday[i][1]-1)-3,hcaltopleft[2]+15+hcaltitlewh[2]+20,hcaldaywh[1],4)
        table.insert(offdaymidline_holder,hs.drawing.rectangle(offdaymidlinerect))
        offdaymidline_holder[i]:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        offdaymidline_holder[i]:setLevel(hs.drawing.windowLevels.desktopIcon)
        offdaymidline_holder[i]:setFillColor(midlineoffcolor)
        offdaymidline_holder[i]:setStroke(false)
        offdaymidline_holder[i]:show()
    end

    local today = math.tointeger(os.date("%d"))
    local todayrect = hs.geometry.rect(hcaltopleft[1]+10+hcaldaywh[1]*(today-1)-3,hcaltopleft[2]+15+hcaltitlewh[2],hcaldaywh[1],43)
    if not todaydraw then
        todaydraw = hs.drawing.rectangle(todayrect)
        todaydraw:setFillColor(hcaltodaycolor)
        todaydraw:setStroke(false)
        todaydraw:setRoundedRectRadii(3,3)
        todaydraw:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        todaydraw:setLevel(hs.drawing.windowLevels.desktopIcon)
        todaydraw:show()
    else
        todaydraw:setFrame(todayrect)
    end

    todaymidlinerect = hs.geometry.rect(hcaltopleft[1]+10+hcaldaywh[1]*(today-1)-3,hcaltopleft[2]+15+hcaltitlewh[2]+20,hcaldaywh[1],4)
    -- Don't know why the draw order is not correct
    if todaymidlinedraw then
        todaymidlinedraw:delete()
        todaymidlinedraw=nil
    end
    todaymidlinedraw = hs.drawing.rectangle(todaymidlinerect)
    todaymidlinedraw:setFillColor(midlinetodaycolor)
    todaymidlinedraw:setStroke(false)
    todaymidlinedraw:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
    todaymidlinedraw:setLevel(hs.drawing.windowLevels.desktopIcon)
    todaymidlinedraw:show()
end

if not launch_hcalendar then launch_hcalendar=true end
if launch_hcalendar == true then
    showHCalendar()
    if hcaltimer == nil then
        hcaltimer = hs.timer.doEvery(1800, function() showHCalendar() end)
    else
        hcaltimer:start()
    end
end
