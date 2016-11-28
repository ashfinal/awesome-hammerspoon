-- DONOT USE THIS! Heavy system load.

DayColor = hs.drawing.color.white
ContainerColor = {red=0,blue=0,green=0,alpha=0.3}
TitleColor = {red=1,blue=1,green=1,alpha=0.3}
OffdayColor = {red=255/255,blue=120/255,green=120/255,alpha=1}
TodayColor = {red=1,blue=1,green=1,alpha=0.2}
MidlineColor = {red=1,blue=1,green=1,alpha=0.5}
MidlineTodayColor = {red=0,blue=1,green=186/255,alpha=0.8}
MidlineOffColor = {red=1,blue=119/255,green=119/255,alpha=0.5}
TranparentColor = {red=0,blue=0,green=0,alpha=0}

CalTopleftXY = {40,658}

WeekNames = {"Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"}
CalTitleFontsize = 22
CalTitleWH = {180,32}
CalDayFontsize = 12
CalDayWH = {28,40}

function drawSketch()
    local container_rect = hs.geometry.rect(CalTopleftXY[1],CalTopleftXY[2],CalDayWH[1]*31+20,CalDayWH[2]+20+CalTitleWH[2]+10)
    CalContainer = hs.drawing.rectangle(container_rect)
    CalContainer:setFillColor(ContainerColor)
    CalContainer:setStroke(false)
    CalContainer:setRoundedRectRadii(10,10)
    CalContainer:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
    CalContainer:setLevel(hs.drawing.windowLevels.desktopIcon)
    CalContainer:show()

    local title_rect = hs.geometry.rect(CalTopleftXY[1]+10,CalTopleftXY[2]+15,CalTitleWH[1],CalTitleWH[2])
    CalTitle = hs.drawing.text(title_rect,"")
    CalTitle:setFillColor(TitleColor)
    CalTitle:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
    CalTitle:setLevel(hs.drawing.windowLevels.desktopIcon)
    CalTitle:show()
    -- TitleFrame = hs.drawing.rectangle(title_rect)
    -- TitleFrame:setFillColor(ContainerColor)
    -- TitleFrame:show()

    days_holder_tbl={}
    line_holder_tbl={}

    for i=1,31 do
        local midlineb = hs.geometry.point(CalTopleftXY[1]+10+CalDayWH[1]*(i-1),CalTopleftXY[2]+CalTitleWH[2]+20+(CalDayWH[2]/2))
        local midlinee = hs.geometry.point(CalTopleftXY[1]+10+CalDayWH[1]*(i),CalTopleftXY[2]+CalTitleWH[2]+20+(CalDayWH[2]/2))
        table.insert(line_holder_tbl, hs.drawing.line(midlineb,midlinee))
        line_holder_tbl[i]:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        line_holder_tbl[i]:setLevel(hs.drawing.windowLevels.desktopIcon)
        line_holder_tbl[i]:show()

        local dayrect = hs.geometry.rect(CalTopleftXY[1]+10+CalDayWH[1]*(i-1),CalTopleftXY[2]+CalTitleWH[2]+25,CalDayWH[1],CalDayWH[2])
        table.insert(days_holder_tbl, hs.drawing.text(dayrect,""))
        days_holder_tbl[i]:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        days_holder_tbl[i]:setLevel(hs.drawing.windowLevels.desktopIcon)
        days_holder_tbl[i]:show()
    end
end

function updateCal()
    local titlestr = os.date("%B %Y")
    local styledtitle = hs.styledtext.new(titlestr,{font={size=CalTitleFontsize},color=TitleColor,backgroundColor=nil,paragraphStyle={alignment="left"}})
    CalTitle:setStyledText(styledtitle)

    local currentyear = os.date("%Y")
    local currentmonth = os.date("%m")
    local today = math.tointeger(os.date("%d"))
    local firstdayofnextmonth = os.time{year=currentyear, month=currentmonth+1, day=1}
    local maxdayofcurrentmonth = os.date("*t", firstdayofnextmonth-24*60*60).day
    for i=1,maxdayofcurrentmonth do
        weekdayofquery = os.date("*t", os.time{year=currentyear, month=currentmonth, day=i}).wday
        weekstr = WeekNames[weekdayofquery]
        composedstr = weekstr.."\n"..i
        if weekdayofquery == 1 or weekdayofquery == 7 then
            daystyledtext = hs.styledtext.new(composedstr,{font={name="Helvetica",size=CalDayFontsize},color=OffdayColor,backgroundColor=nil,paragraphStyle={alignment="center"}})
            line_holder_tbl[i]:setStrokeWidth(4)
            line_holder_tbl[i]:setStrokeColor(MidlineOffColor)
        else
            daystyledtext = hs.styledtext.new(composedstr,{font={name="Helvetica",size=CalDayFontsize},color=DayColor,backgroundColor=nil,paragraphStyle={alignment="center"}})
            line_holder_tbl[i]:setStrokeWidth(4)
            line_holder_tbl[i]:setStrokeColor(MidlineColor)
        end
        days_holder_tbl[i]:setStyledText(daystyledtext)
        if i == today then
            line_holder_tbl[i]:setStrokeWidth(4)
            line_holder_tbl[i]:setStrokeColor(MidlineTodayColor)
            todayrect = hs.geometry.rect(CalTopleftXY[1]+10+CalDayWH[1]*(i-1),CalTopleftXY[2]+CalTitleWH[2]+20,CalDayWH[1],CalDayWH[2])
            todayframe = hs.drawing.rectangle(todayrect)
            todayframe:setFillColor(TodayColor)
            todayframe:setStroke(false)
            todayframe:setRoundedRectRadii(3,3)
            todayframe:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
            todayframe:setLevel(hs.drawing.windowLevels.desktopIcon)
            todayframe:show()
        end
    end

    for i=maxdayofcurrentmonth+1,31 do
        days_holder_tbl[i]:setText("")
        line_holder_tbl[i]:setStrokeColor(TranparentColor)
    end

    local new_container_rect = hs.geometry.rect(CalTopleftXY[1],CalTopleftXY[2],CalDayWH[1]*maxdayofcurrentmonth+20,CalDayWH[2]+20+CalTitleWH[2]+10)
    CalContainer:setFrame(new_container_rect)
end

drawSketch()
updateCal()
caltimer = hs.timer.doEvery(1800, function() updateCal() end)
