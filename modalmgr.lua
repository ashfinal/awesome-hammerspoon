modalmgr_keys = modalmgr_keys or {{"alt"}, "space"}
modalmgr = hs.hotkey.modal.new(modalmgr_keys[1], modalmgr_keys[2], 'Toggle Modal Supervisor')
function modalmgr:entered()
    dock_launched = true
    modal_stat('dock',black)
    if resizeM then
        if launch_resizeM == nil then launch_resizeM = false end
        if launch_resizeM == true then resizeM:enter() end
    end
    if idle_to_which == nil then idle_to_which = "netspeed" end
    if idle_to_which == "netspeed" then
        idletimer = hs.timer.doEvery(5,function()
            if modal_text == 'DOCK MODE' and netspeedM then
                netspeedM:enter()
            end
        end)
    elseif idle_to_which == "hide" then
        modal_show:hide()
        modal_bg:hide()
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
modalmgr:bind(modalmgr_keys[1], modalmgr_keys[2], "Toggle Modal Supervisor", function() modalmgr:exit() end)

if appM then
    appM_keys = appM_keys or {"alt", "A"}
    if string.len(appM_keys[2]) > 0 then
        modalmgr:bind(appM_keys[1], appM_keys[2], 'Enter Application Mode', function() exit_others(appM) appM:enter() end)
    end
end
if clipboardM then
    clipboardM_keys = clipboardM_keys or {"alt", "C"}
    if string.len(clipboardM_keys[2]) > 0 then
        modalmgr:bind(clipboardM_keys[1], clipboardM_keys[2], 'Enter Clipboard Mode', function() exit_others(clipboardM) clipboardM:enter() end)
    end
end
if downloadM then
    downloadM_keys = downloadM_keys or {"alt", "D"}
    if string.len(downloadM_keys[2]) > 0 then
        modalmgr:bind('alt', 'D', 'Enter Download Mode', function() exit_others(downloadM) downloadM:enter() end)
    end
end
if hsearch_loaded == true then
    hsearch_keys = hsearch_keys or {"alt", "G"}
    if string.len(hsearch_keys[2]) > 0 then
        modalmgr:bind(hsearch_keys[1], hsearch_keys[2], 'Launch Hammer Search', function() launchChooser() end)
    end
end
if timerM then
    timerM_keys = timerM_keys or {"alt", "I"}
    if string.len(timerM_keys[2]) > 0 then
        modalmgr:bind(timerM_keys[1], timerM_keys[2], 'Enter Timer Mode', function() exit_others(timerM) timerM:enter() end)
    end
end
if resizeM then
    resizeM_keys = resizeM_keys or {"alt", "R"}
    if string.len(resizeM_keys[2]) > 0 then
        modalmgr:bind(resizeM_keys[1], resizeM_keys[2], 'Enter Resize Mode', function() exit_others(resizeM) resizeM:enter() end)
    end
end
if cheatsheetM then
    cheatsheetM_keys = cheatsheetM_keys or {"alt", "S"}
    if string.len(cheatsheetM_keys[2]) > 0 then
        modalmgr:bind(cheatsheetM_keys[1], cheatsheetM_keys[2], 'Enter Cheatsheet Mode', function() exit_others(cheatsheetM) cheatsheetM:enter() end)
    end
end
showtime_keys = showtime_keys or {"alt", "T"}
if string.len(showtime_keys[2]) > 0 then
    modalmgr:bind(showtime_keys[1], showtime_keys[2], 'Show Digital Clock', function() show_time() end)
end
if viewM then
    viewM_keys = viewM_keys or {"alt", "V"}
    if string.len(viewM_keys[2]) > 0 then
        modalmgr:bind(viewM_keys[1], viewM_keys[2], 'Enter View Mode', function() exit_others(viewM) viewM:enter() end)
    end
end
toggleconsole_keys = toggleconsole_keys or {"alt", "Z"}
if string.len(toggleconsole_keys[2]) > 0 then
    modalmgr:bind(toggleconsole_keys[1], toggleconsole_keys[2], 'Toggle Hammerspoon Console', function() hs.toggleConsole() end)
end
winhints_keys = winhints_keys or {"alt", "tab"}
if string.len(winhints_keys[2]) > 0 then
    modalmgr:bind(winhints_keys[1], winhints_keys[2], 'Show Windows Hint', function() exit_others(nil) hs.hints.windowHints() end)
end

if modalmgr then
    if launch_modalmgr == nil then launch_modalmgr = true end
    if launch_modalmgr == true then modalmgr:enter() end
end
