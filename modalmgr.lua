modalmgr = hs.hotkey.modal.new('alt', 'space', 'Modal supervisor')
function modalmgr:entered()
    dock_launched = true
    modal_stat('dock',black)
    if resizeM then
        if launch_resizeM == nil then launch_resizeM = false end
        if launch_resizeM == true then resizeM:enter() end
    end
    if idle_to_which == nil then idle_to_which = "netspeed" end
    if idle_to_which ~= "never" then
        idletimer = hs.timer.doEvery(5,check_idle)
    end
end
function modalmgr:exited()
    exit_others(nil)
    dock_launched = nil
    modal_bg:hide()
    modal_show:hide()
    if idletimer ~= nil then idletimer:stop() end
    if hotkeytext then
        hotkeytext:delete()
        hotkeytext=nil
        hotkeybg:delete()
        hotkeybg=nil
    end
end
modalmgr:bind('alt', 'space', function() modalmgr:exit() end)
if appM then
    modalmgr:bind('alt', 'A', 'Enter Application Mode', function() exit_others(appM) appM:enter() end)
end
if clipboardM then
    modalmgr:bind('alt', 'C', 'Enter Clipboard Mode', function() exit_others(clipboardM) clipboardM:enter() end)
end
if downloadM then
    modalmgr:bind('alt', 'D', 'Enter Download Mode', function() exit_others(downloadM) downloadM:enter() end)
end
if caldraw then
    modalmgr:bind('alt', 'E', nil, function() showCalendar() end)
end
if timerM then
    modalmgr:bind('alt', 'I', 'Enter Timer Mode', function() exit_others(timerM) timerM:enter() end)
end
if mincirle then
    modalmgr:bind('alt', 'K', nil, function() showAnalogClock() end)
end
if netspeedM then
    modalmgr:bind('alt', 'N', nil, function() exit_others(netspeedM) netspeedM:enter() end)
end
if resizeM then
    modalmgr:bind('alt', 'R', 'Enter Resize Mode', function() exit_others(resizeM) resizeM:enter() end)
end
if cheatsheetM then
    modalmgr:bind('alt', 'S', 'Enter Cheatsheet Mode', function() exit_others(cheatsheetM) cheatsheetM:enter() end)
end
modalmgr:bind('alt', 'T', 'Show Digital Clock', function() show_time() end)
if viewM then
    modalmgr:bind('alt', 'V', 'Enter View Mode', function() exit_others(viewM) viewM:enter() end)
end
modalmgr:bind('alt', 'Z', 'Open Hammerspoon Console', function() hs.toggleConsole() end)
modalmgr:bind('alt', 'tab', 'Show Windows Hint', function() exit_others(nil) hs.hints.windowHints() end)

if modalmgr then
    if launch_modalmgr == nil then launch_modalmgr = true end
    if launch_modalmgr == true then modalmgr:enter() end
end
