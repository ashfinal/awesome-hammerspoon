function timer_indicator(timelen)
    if not indicator_used then
        indicator_used = hs.drawing.rectangle({0,0,0,0})
        indicator_used:setStroke(false)
        indicator_used:setFill(true)
        indicator_used:setFillColor(osx_red)
        indicator_used:setAlpha(0.35)
        indicator_used:setLevel(hs.drawing.windowLevels.status)
        indicator_used:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces+hs.drawing.windowBehaviors.stationary)
        indicator_used:show()

        indicator_left = hs.drawing.rectangle({0,0,0,0})
        indicator_left:setStroke(false)
        indicator_left:setFill(true)
        indicator_left:setFillColor(osx_green)
        indicator_left:setAlpha(0.35)
        indicator_left:setLevel(hs.drawing.windowLevels.status)
        indicator_left:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces+hs.drawing.windowBehaviors.stationary)
        indicator_left:show()

        totaltime=timelen
        if totaltime > 45*60 then
            time_interval = 5
        else
            time_interval = 1
        end
        if indict_timer == nil then
            indict_timer = hs.timer.doEvery(time_interval,updateused)
        else
            indict_timer:start()
        end
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
    local localMainRes = mainScreen:absoluteToLocal(mainRes)
    local timeslice = localMainRes.w/(60*totaltime/time_interval)
    used_slice = used_slice + timeslice*time_interval
    if used_slice > localMainRes.w then
        indict_timer:stop()
        indicator_used:delete()
        indicator_used=nil
        indicator_left:delete()
        indicator_left=nil
        hs.notify.new({title="Time("..totaltime.." mins) is up!", informativeText="Now is "..os.date("%X")}):send()
    else
        left_slice = localMainRes.w - used_slice
        local used_rect = mainScreen:localToAbsolute(hs.geometry.rect(localMainRes.x,localMainRes.h-5,used_slice,5))
        local left_rect = mainScreen:localToAbsolute(hs.geometry.rect(localMainRes.x+used_slice,localMainRes.h-5,left_slice,5))
        indicator_used:setFrame(used_rect)
        indicator_left:setFrame(left_rect)
    end
end

timerM = hs.hotkey.modal.new()
local modalpkg = {}
modalpkg.id = "timerM"
modalpkg.modal = timerM
table.insert(modal_list, modalpkg)

function timerM:entered()
    modal_stat(purple,0.7)
    for i=1,#modal_list do
        if modal_list[i].id == "timerM" then
            table.insert(activeModals, modal_list[i])
        end
    end
    if hotkeytext then
        hotkeytext:delete()
        hotkeytext=nil
        hotkeybg:delete()
        hotkeybg=nil
    end
    if show_timer_tips == nil then show_timer_tips = true end
    if show_timer_tips == true then showavailableHotkey() end
end

function timerM:exited()
    modal_tray:hide()
    for i=1,#activeModals do
        if activeModals[i].id == "timerM" then
            table.remove(activeModals, i)
        end
    end
    if hotkeytext then
        hotkeytext:delete()
        hotkeytext=nil
        hotkeybg:delete()
        hotkeybg=nil
    end
end

timerM:bind('', 'escape', function() timerM:exit() end)
timerM:bind('', 'Q', function() timerM:exit() end)
timerM:bind('', 'tab', function() showavailableHotkey() end)
timerM:bind('', '1', '10 minute countdown', function() timer_indicator(10) timerM:exit() end)
timerM:bind('', '2', '20 minute countdown', function() timer_indicator(20) timerM:exit() end)
timerM:bind('', '3', '30 minute countdown', function() timer_indicator(30) timerM:exit() end)
timerM:bind('', '4', '40 minute countdown', function() timer_indicator(40) timerM:exit() end)
timerM:bind('', '5', '50 minute countdown', function() timer_indicator(50) timerM:exit() end)
timerM:bind('', '6', '60 minute countdown', function() timer_indicator(60) timerM:exit() end)
timerM:bind('', '7', '70 minute countdown', function() timer_indicator(70) timerM:exit() end)
timerM:bind('', '8', '80 minute countdown', function() timer_indicator(80) timerM:exit() end)
timerM:bind('', '9', '90 minute countdown', function() timer_indicator(90) timerM:exit() end)
timerM:bind('', '0', '5 minute countdown', function() timer_indicator(5) timerM:exit() end)
timerM:bind('', 'return', '25 minute countdown', function() timer_indicator(25) timerM:exit() end)
