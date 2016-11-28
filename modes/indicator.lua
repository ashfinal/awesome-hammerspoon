indicator_joinallspaces = true
red = hs.drawing.color.osx_red
green = hs.drawing.color.osx_green

function timer_indicator(timelen)
    if not indicator_used then
        indicator_used = hs.drawing.rectangle({0,0,0,0})
        indicator_used:setStroke(false)
        indicator_used:setFill(true)
        indicator_used:setFillColor(red)
        indicator_used:setAlpha(0.35)
        indicator_used:setLevel(hs.drawing.windowLevels.modalPanel)
        if indicator_joinallspaces == true then
            indicator_used:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        end
        indicator_used:show()

        indicator_left = hs.drawing.rectangle({0,0,0,0})
        indicator_left:setStroke(false)
        indicator_left:setFill(true)
        indicator_left:setFillColor(green)
        indicator_left:setAlpha(0.35)
        indicator_left:setLevel(hs.drawing.windowLevels.modalPanel)
        if indicator_joinallspaces == true then
            indicator_left:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        end
        indicator_left:show()

        totaltime=timelen
        if totaltime > 45*60 then
            time_interval = 5
        else
            time_interval = 1
        end
        indict_timer = hs.timer.doEvery(time_interval,updateused)
        used_slice = 0
    else
        indict_timer:stop()
        indicator_used:delete()
        indicator_used=nil
        indicator_left:delete()
        indicator_left=nil
    end
end

function updateused()
    local mainScreen = hs.screen.mainScreen()
    local mainRes = mainScreen:fullFrame()
    local timeslice = mainRes.w/(60*totaltime/time_interval)
    used_slice = used_slice + timeslice*time_interval
    if used_slice > mainRes.w then
        indict_timer:stop()
        indicator_used:delete()
        indicator_used=nil
        indicator_left:delete()
        indicator_left=nil
        hs.notify.new({title="Time("..totaltime.." mins) is up!", informativeText="Now is "..os.date("%X")}):send()
    else
        left_slice = mainRes.w - used_slice
        local used_rect = hs.geometry.rect(0,mainRes.h-5,used_slice,5)
        local left_rect = hs.geometry.rect(used_slice,mainRes.h-5,left_slice,5)
        indicator_used:setFrame(used_rect)
        indicator_left:setFrame(left_rect)
    end
end

timerM = hs.hotkey.modal.new({'cmd','alt','ctrl'}, 'I')
table.insert(modal_list, timerM)
function timerM:entered() modal_stat('timer',tomato) end
function timerM:exited()
    if dock_launched then
        modal_stat('dock',black)
    else
        modal_bg:hide()
        modal_show:hide()
    end
end
timerM:bind('alt', 'I', function() timerM:exit() end)
timerM:bind('', 'escape', function() timerM:exit() end)
timerM:bind('', 'Q', function() timerM:exit() end)
timerM:bind('', '1', function() timer_indicator(10) timerM:exit() end)
timerM:bind('', '2', function() timer_indicator(20) timerM:exit() end)
timerM:bind('', '3', function() timer_indicator(30) timerM:exit() end)
timerM:bind('', '4', function() timer_indicator(40) timerM:exit() end)
timerM:bind('', '5', function() timer_indicator(50) timerM:exit() end)
timerM:bind('', '6', function() timer_indicator(60) timerM:exit() end)
timerM:bind('', '7', function() timer_indicator(70) timerM:exit() end)
timerM:bind('', '8', function() timer_indicator(80) timerM:exit() end)
timerM:bind('', '9', function() timer_indicator(90) timerM:exit() end)
timerM:bind('', '0', function() timer_indicator(5) timerM:exit() end)
timerM:bind('', 'return', function() timer_indicator(25) timerM:exit() end)
