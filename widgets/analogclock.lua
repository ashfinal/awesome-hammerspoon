seccolor = {red=158/255,blue=158/255,green=158/255,alpha=0.5}
tofilledcolor = {red=1,blue=1,green=1,alpha=0.1}
secfillcolor = {red=158/255,blue=158/255,green=158/255,alpha=0.1}
mincolor = {red=24/255,blue=195/255,green=145/255,alpha=0.75}
hourcolor = {red=236/255,blue=39/255,green=109/255,alpha=0.75}

if not aclockcenter then
    local mainScreen = hs.screen.mainScreen()
    local mainRes = mainScreen:fullFrame()
    aclockcenter = {x=mainRes.w-200-20,y=200}
end

function showAnalogClock()
    if not bgcirle then
        imagerect = hs.geometry.rect(aclockcenter.x-100,aclockcenter.y-100,200,200)
        imagedisp = hs.drawing.image(imagerect,"./resources/watchbg.png")
        imagedisp:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        imagedisp:setLevel(hs.drawing.windowLevels.desktopIcon)
        imagedisp:show()

        bgcirle = hs.drawing.arc(aclockcenter,80,0,360)
        bgcirle:setFill(false)
        bgcirle:setStrokeWidth(1)
        bgcirle:setStrokeColor(seccolor)
        bgcirle:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        bgcirle:setLevel(hs.drawing.windowLevels.desktopIcon)
        bgcirle:show()

        mincirle = hs.drawing.arc(aclockcenter,55,0,360)
        mincirle:setFill(false)
        mincirle:setStrokeWidth(3)
        mincirle:setStrokeColor(tofilledcolor)
        mincirle:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        mincirle:setLevel(hs.drawing.windowLevels.desktopIcon)
        mincirle:show()

        hourcirle = hs.drawing.arc(aclockcenter,40,0,360)
        hourcirle:setFill(false)
        hourcirle:setStrokeWidth(3)
        hourcirle:setStrokeColor(tofilledcolor)
        hourcirle:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        hourcirle:setLevel(hs.drawing.windowLevels.desktopIcon)
        hourcirle:show()

        sechand = hs.drawing.arc(aclockcenter,80,0,0)
        sechand:setFillColor(secfillcolor)
        sechand:setStrokeWidth(1)
        sechand:setStrokeColor(seccolor)
        sechand:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        sechand:setLevel(hs.drawing.windowLevels.desktopIcon)
        sechand:show()

        minhand1 = hs.drawing.arc(aclockcenter,55,0,0)
        minhand1:setFill(false)
        -- minhand:setStrokeWidth(3)
        minhand1:setStrokeColor(mincolor)
        minhand1:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        minhand1:setLevel(hs.drawing.windowLevels.desktopIcon)
        minhand1:show()
        minhand2 = hs.drawing.arc(aclockcenter,54,0,0)
        minhand2:setFill(false)
        minhand2:setStrokeColor(mincolor)
        minhand2:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        minhand2:setLevel(hs.drawing.windowLevels.desktopIcon)
        minhand2:show()
        minhand3 = hs.drawing.arc(aclockcenter,53,0,0)
        minhand3:setFill(false)
        minhand3:setStrokeColor(mincolor)
        minhand3:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        minhand3:setLevel(hs.drawing.windowLevels.desktopIcon)
        minhand3:show()

        hourhand1 = hs.drawing.arc(aclockcenter,40,0,0)
        hourhand1:setFill(false)
        hourhand1:setStrokeColor(hourcolor)
        hourhand1:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        hourhand1:setLevel(hs.drawing.windowLevels.desktopIcon)
        hourhand1:show()
        hourhand2 = hs.drawing.arc(aclockcenter,39,0,0)
        hourhand2:setFill(false)
        hourhand2:setStrokeColor(hourcolor)
        hourhand2:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        hourhand2:setLevel(hs.drawing.windowLevels.desktopIcon)
        hourhand2:show()
        hourhand3 = hs.drawing.arc(aclockcenter,38,0,0)
        hourhand3:setFill(false)
        hourhand3:setStrokeColor(hourcolor)
        hourhand3:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        hourhand3:setLevel(hs.drawing.windowLevels.desktopIcon)
        hourhand3:show()

        if clocktimer == nil then
            clocktimer = hs.timer.doEvery(1,function() updateClock() end)
        else
            clocktimer:start()
        end
    else
        clocktimer:stop()
        clocktimer=nil
        imagedisp:delete()
        imagedisp=nil
        bgcirle:delete()
        bgcirle=nil
        mincirle:delete()
        mincirle=nil
        hourcirle:delete()
        hourcirle=nil
        sechand:delete()
        sechand=nil
        minhand1:delete()
        minhand1=nil
        minhand2:delete()
        minhand2=nil
        minhand3:delete()
        minhand3=nil
        hourhand1:delete()
        hourhand1=nil
        hourhand2:delete()
        hourhand2=nil
        hourhand3:delete()
        hourhand3=nil
    end
end

function updateClock()
    local secnum = math.tointeger(os.date("%S"))
    local minnum = math.tointeger(os.date("%M"))
    local hournum = math.tointeger(os.date("%I"))
    local seceangle = 6*secnum
    local mineangle = 6*minnum+6/60*secnum
    local houreangle = 30*hournum+30/60*minnum+30/60/60*secnum

    sechand:setArcAngles(0,seceangle)
    minhand1:setArcAngles(0,mineangle)
    minhand2:setArcAngles(0,mineangle)
    minhand3:setArcAngles(0,mineangle)
    if houreangle >= 360 then
        houreangle = houreangle - 360
    end
    hourhand1:setArcAngles(0,houreangle)
    hourhand2:setArcAngles(0,houreangle)
    hourhand3:setArcAngles(0,houreangle)
end

if not launch_analogclock then launch_analogclock = true end
if launch_analogclock == true then showAnalogClock() end
