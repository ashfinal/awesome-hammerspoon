viewM = hs.hotkey.modal.new({'cmd','alt','ctrl'}, 'v')
table.insert(modal_list, viewM)
function viewM:entered()
    modal_stat('view',royalblue)
    if hotkeytext then
        hotkeytext:delete()
        hotkeytext=nil
        hotkeybg:delete()
        hotkeybg=nil
    end
end
function viewM:exited()
    if dock_launched then
        modal_stat('dock',black)
    else
        modal_bg:hide()
        modal_show:hide()
    end
    if hotkeytext then
        hotkeytext:delete()
        hotkeytext=nil
        hotkeybg:delete()
        hotkeybg=nil
    end
end
viewM:bind('alt', 'V', function() viewM:exit() end)
viewM:bind('', 'escape', function() viewM:exit() end)
viewM:bind('', 'tab', function() showavailableHotkey() end)
viewM:bind('', 'H', 'Left', function() hs.eventtap.keyStroke({},'left') end, function() hs.eventtap.keyStroke({},'left') end)
viewM:bind('', 'L', 'Right', function() hs.eventtap.keyStroke({},'right') end, function() hs.eventtap.keyStroke({},'right') end)
viewM:bind('', 'J', 'Down', function() hs.eventtap.keyStroke({},'down') end, function() hs.eventtap.keyStroke({},'down') end)
viewM:bind('', 'K', 'Up', function() hs.eventtap.keyStroke({},'up') end, function() hs.eventtap.keyStroke({},'up') end)
viewM:bind('', '/', 'Find', function() hs.eventtap.keyStroke({'cmd'},'f') end)


resizeM = hs.hotkey.modal.new({'cmd','alt','ctrl'}, 'r')
table.insert(modal_list, resizeM)
function resizeM:entered()
    modal_stat('resize',firebrick)
    if hotkeytext then
        hotkeytext:delete()
        hotkeytext=nil
        hotkeybg:delete()
        hotkeybg=nil
    end
end
function resizeM:exited()
    if dock_launched then
        modal_stat('dock',black)
    else
        modal_bg:hide()
        modal_show:hide()
    end
    if hotkeytext then
        hotkeytext:delete()
        hotkeytext=nil
        hotkeybg:delete()
        hotkeybg=nil
    end
end
resizeM:bind('alt', 'R', function() resizeM:exit() end)
resizeM:bind('', 'escape', function() resizeM:exit() end)
resizeM:bind('', 'Q', function() resizeM:exit() end)
resizeM:bind('', 'tab', function() showavailableHotkey() end)
resizeM:bind('', 'H', 'Shrink Leftward', function() resize_win('left') end, function() resize_win('left') end)
resizeM:bind('', 'L', 'Stretch Rightward', function() resize_win('right') end, function() resize_win('right') end)
resizeM:bind('', 'J', 'Stretch Downward', function() resize_win('down') end, function() resize_win('down') end)
resizeM:bind('', 'K', 'Shrink Upward', function() resize_win('up') end, function() resize_win('up') end)
resizeM:bind('', 'F', 'Fullscreen', function() resize_win('fullscreen') end, function() resize_win('fullscreen') end)
resizeM:bind('', 'C', 'Center Window', function() resize_win('center') end, function() resize_win('center') end)
resizeM:bind('ctrl', 'C', 'Resize & Center', function() resize_win('fcenter') end, function() resize_win('fcenter') end)
resizeM:bind('ctrl', 'H', 'Lefthalf of Screen', function() resize_win('halfleft') end, function() resize_win('halfleft') end)
resizeM:bind('ctrl', 'J', 'Downhalf of Screen', function() resize_win('halfdown') end, function() resize_win('halfdown') end)
resizeM:bind('ctrl', 'K', 'Uphalf of Screen', function() resize_win('halfup') end, function() resize_win('halfup') end)
resizeM:bind('ctrl', 'L', 'Righthalf of Screen', function() resize_win('halfright') end, function() resize_win('halfright') end)
resizeM:bind('ctrl', 'Y', 'NorthWest Corner', function() resize_win('cornerNW') end, function() resize_win('cornerNW') end)
resizeM:bind('ctrl', 'U', 'SouthWest Corner', function() resize_win('cornerSW') end, function() resize_win('cornerSW') end)
resizeM:bind('ctrl', 'I', 'SouthEast Corner', function() resize_win('cornerSE') end, function() resize_win('cornerSE') end)
resizeM:bind('ctrl', 'O', 'NorthEast Corner', function() resize_win('cornerNE') end, function() resize_win('cornerNE') end)
resizeM:bind('', '=', 'Stretch Outward', function() resize_win('expand') end, function() resize_win('expand') end)
resizeM:bind('', '-', 'Shrink Inward', function() resize_win('shrink') end, function() resize_win('shrink') end)
resizeM:bind('shift', 'H', 'Move Leftward', function() resize_win('mleft') end, function() resize_win('mleft') end)
resizeM:bind('shift', 'L', 'Move Rightward', function() resize_win('mright') end, function() resize_win('mright') end)
resizeM:bind('shift', 'J', 'Move Downward', function() resize_win('mdown') end, function() resize_win('mdown') end)
resizeM:bind('shift', 'K', 'Move Upward', function() resize_win('mup') end, function() resize_win('mup') end)
resizeM:bind('cmd', 'H', 'Focus Westward', function() hs.window.filter.focusWest() end, function() hs.window.filter.focusWest() end)
resizeM:bind('cmd', 'L', 'Focus Eastward', function() hs.window.filter.focusEast() end, function() hs.window.filter.focusEast() end)
resizeM:bind('cmd', 'J', 'Focus Southward', function() hs.window.filter.focusSouth() end, function() hs.window.filter.focusSouth() end)
resizeM:bind('cmd', 'K', 'Focus Northward', function() hs.window.filter.focusNorth() end, function() hs.window.filter.focusNorth() end)

appM = hs.hotkey.modal.new({'cmd','alt','ctrl'}, 'm')
table.insert(modal_list, appM)
function appM:entered()
    modal_stat('app',osx_yellow)
    if hotkeytext then
        hotkeytext:delete()
        hotkeytext=nil
        hotkeybg:delete()
        hotkeybg=nil
    end
    if not show_applauncher_tips then show_applauncher_tips = true end
    if show_applauncher_tips == true then showavailableHotkey() end
end
function appM:exited()
    if dock_launched then
        modal_stat('dock',black)
    else
        modal_bg:hide()
        modal_show:hide()
    end
    if hotkeytext then
        hotkeytext:delete()
        hotkeytext=nil
        hotkeybg:delete()
        hotkeybg=nil
    end
end
appM:bind('alt', 'A', function() appM:exit() end)
appM:bind('', 'escape', function() appM:exit() end)
appM:bind('', 'Q', function() appM:exit() end)
appM:bind('', 'tab', function() showavailableHotkey() end)

if not applist then
    applist = {
        {shortcut = 'f',appname = 'Finder'},
        {shortcut = 's',appname = 'Safari'},
        {shortcut = 't',appname = 'Terminal'},
        {shortcut = 'v',appname = 'Activity Monitor'},
        {shortcut = 'y',appname = 'System Preferences'},
    }
end

for i = 1, #applist do
    appM:bind('', applist[i].shortcut, applist[i].appname, function()
        hs.application.launchOrFocus(applist[i].appname)
        appM:exit()
        if hotkeytext then
            hotkeytext:delete()
            hotkeytext=nil
            hotkeybg:delete()
            hotkeybg=nil
        end
    end)
end
