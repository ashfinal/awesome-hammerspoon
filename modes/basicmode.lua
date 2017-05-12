viewM = hs.hotkey.modal.new()
local modalpkg = {}
modalpkg.id = "viewM"
modalpkg.modal = viewM
table.insert(modal_list, modalpkg)

function viewM:entered()
    modal_stat(royalblue,0.7)
    for i=1,#modal_list do
        if modal_list[i].id == "viewM" then
            table.insert(activeModals, modal_list[i])
        end
    end
    if hotkeytext then
        hotkeytext:delete()
        hotkeytext=nil
        hotkeybg:delete()
        hotkeybg=nil
    end
end

function viewM:exited()
    modal_tray:hide()
    for i=1,#activeModals do
        if activeModals[i].id == "viewM" then
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

viewM:bind('', 'escape', function() viewM:exit() end)
viewM:bind('', 'Q', function() viewM:exit() end)
viewM:bind('', 'tab', function() showavailableHotkey() end)
viewM:bind('', 'H', 'Scroll Leftward', function() hs.eventtap.scrollWheel({1,0},{},"line") end, nil, function() hs.eventtap.scrollWheel({1,0},{},"line") end)
viewM:bind('', 'L', 'Scroll Rightward', function() hs.eventtap.scrollWheel({-1,0},{},"line") end, nil, function() hs.eventtap.scrollWheel({-1,0},{},"line") end)
viewM:bind('', 'J', 'Scroll Downward', function() hs.eventtap.scrollWheel({0,-1},{},"line") end, nil, function() hs.eventtap.scrollWheel({0,-1},{},"line") end)
viewM:bind('', 'K', 'Scroll Upward', function() hs.eventtap.scrollWheel({0,1},{},"line") end, nil, function() hs.eventtap.scrollWheel({0,1},{},"line") end)
viewM:bind('ctrl', 'H', 'Move Mouse Leftward by 50px', function() moveMouseBy(-50,0) end, nil, function() moveMouseBy(-50,0) end)
viewM:bind('ctrl', 'L', 'Move Mouse Rightward by 50px', function() moveMouseBy(50,0) end, nil, function() moveMouseBy(50,0) end)
viewM:bind('ctrl', 'K', 'Move Mouse Upward by 50px', function() moveMouseBy(0,-50) end, nil, function() moveMouseBy(0,-50) end)
viewM:bind('ctrl', 'J', 'Move Mouse Downward by 50px', function() moveMouseBy(0,50) end, nil, function() moveMouseBy(0,50) end)
viewM:bind('shift', 'H', 'Move Mouse Leftward by 10px', function() moveMouseBy(-10,0) end, nil, function() moveMouseBy(-10,0) end)
viewM:bind('shift', 'L', 'Move Mouse Rightward by 10px', function() moveMouseBy(10,0) end, nil, function() moveMouseBy(10,0) end)
viewM:bind('shift', 'K', 'Move Mouse Upward by 10px', function() moveMouseBy(0,-10) end, nil, function() moveMouseBy(0,-10) end)
viewM:bind('shift', 'J', 'Move Mouse Downward by 10px', function() moveMouseBy(0,10) end, nil, function() moveMouseBy(0,10) end)
viewM:bind({'ctrl','shift'}, 'H', 'Move Mouse Leftward by 1px', function() moveMouseBy(-1,0) end, nil, function() moveMouseBy(-1,0) end)
viewM:bind({'ctrl','shift'}, 'L', 'Move Mouse Rightward by 1px', function() moveMouseBy(1,0) end, nil, function() moveMouseBy(1,0) end)
viewM:bind({'ctrl','shift'}, 'K', 'Move Mouse Upward by 1px', function() moveMouseBy(0,-1) end, nil, function() moveMouseBy(0,-1) end)
viewM:bind({'ctrl','shift'}, 'J', 'Move Mouse Downward by 1px', function() moveMouseBy(0,1) end, nil, function() moveMouseBy(0,1) end)
viewM:bind('', ',', 'Left Mouse Click', function() clickWithMouse('left') end, nil, nil)
viewM:bind('', '.', 'Right Mouse Click', function() clickWithMouse('right') end, nil, nil)

function moveMouseBy(offsetx,offsety)
    local currentpos = hs.mouse.getRelativePosition()
    local newpos = hs.geometry.point(currentpos.x+offsetx,currentpos.y+offsety)
    hs.mouse.setRelativePosition(newpos)
end

function clickWithMouse(opts)
    local currentpos = hs.mouse.getRelativePosition()
    if opts == 'left' then
        hs.eventtap.leftClick(currentpos)
    elseif opts == 'right' then
        hs.eventtap.rightClick(currentpos)
    end
end

resizeM = hs.hotkey.modal.new()
local modalpkg = {}
modalpkg.id = "resizeM"
modalpkg.modal = resizeM
table.insert(modal_list, modalpkg)

function resizeM:entered()
    modal_stat(firebrick,0.7)
    resize_current_winnum = 1
    resize_win_list = hs.window.visibleWindows()
    for i=1,#modal_list do
        if modal_list[i].id == "resizeM" then
            table.insert(activeModals, modal_list[i])
        end
    end
    if hotkeytext then
        hotkeytext:delete()
        hotkeytext=nil
        hotkeybg:delete()
        hotkeybg=nil
    end
    if show_resize_tips == nil then show_resize_tips = true end
    if show_resize_tips == true then showavailableHotkey() end
end

function resizeM:exited()
    modal_tray:hide()
    for i=1,#activeModals do
        if activeModals[i].id == "resizeM" then
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

resizeM:bind('', 'escape', function() resizeM:exit() end)
resizeM:bind('', 'Q', function() resizeM:exit() end)
resizeM:bind('', 'tab', function() showavailableHotkey() end)
resizeM:bind('shift', 'Y', 'Shrink Leftward', function() resize_win('left') end, nil, function() resize_win('left') end)
resizeM:bind('shift', 'O', 'Stretch Rightward', function() resize_win('right') end, nil, function() resize_win('right') end)
resizeM:bind('shift', 'U', 'Stretch Downward', function() resize_win('down') end, nil, function() resize_win('down') end)
resizeM:bind('shift', 'I', 'Shrink Upward', function() resize_win('up') end, nil, function() resize_win('up') end)
resizeM:bind('', 'F', 'Fullscreen', function() resize_win('fullscreen') end, nil, nil)
resizeM:bind('', 'C', 'Center Window', function() resize_win('center') end, nil, nil)
resizeM:bind('shift', 'C', 'Resize & Center', function() resize_win('fcenter') end, nil, nil)
resizeM:bind('', 'H', 'Lefthalf of Screen', function() resize_win('halfleft') end, nil, nil)
resizeM:bind('', 'J', 'Downhalf of Screen', function() resize_win('halfdown') end, nil, nil)
resizeM:bind('', 'K', 'Uphalf of Screen', function() resize_win('halfup') end, nil, nil)
resizeM:bind('', 'L', 'Righthalf of Screen', function() resize_win('halfright') end, nil, nil)
resizeM:bind('', 'Y', 'NorthWest Corner', function() resize_win('cornerNW') end, nil, nil)
resizeM:bind('', 'U', 'SouthWest Corner', function() resize_win('cornerSW') end, nil, nil)
resizeM:bind('', 'I', 'SouthEast Corner', function() resize_win('cornerSE') end, nil, nil)
resizeM:bind('', 'O', 'NorthEast Corner', function() resize_win('cornerNE') end, nil, nil)
resizeM:bind('', '=', 'Stretch Outward', function() resize_win('expand') end, nil, function() resize_win('expand') end)
resizeM:bind('', '-', 'Shrink Inward', function() resize_win('shrink') end, nil, function() resize_win('shrink') end)
resizeM:bind('shift', 'H', 'Move Leftward', function() resize_win('mleft') end, nil, function() resize_win('mleft') end)
resizeM:bind('shift', 'L', 'Move Rightward', function() resize_win('mright') end, nil, function() resize_win('mright') end)
resizeM:bind('shift', 'J', 'Move Downward', function() resize_win('mdown') end, nil, function() resize_win('mdown') end)
resizeM:bind('shift', 'K', 'Move Upward', function() resize_win('mup') end, nil, function() resize_win('mup') end)
resizeM:bind('', '`', 'Center Cursor', function() resize_win('ccursor') end, nil, nil)
resizeM:bind('', '[', 'Focus Westward', function() cycle_wins_pre() end, nil, function() cycle_wins_pre() end)
resizeM:bind('', ']', 'Focus Eastward', function() cycle_wins_next() end, nil, function() cycle_wins_next() end)
resizeM:bind('', 'up', 'Move to monitor above', function() move_win('up') end, nil, nil)
resizeM:bind('', 'down', 'Move to monitor below', function() move_win('down') end, nil, nil)
resizeM:bind('', 'right', 'Move to monitor right', function() move_win('right') end, nil, nil)
resizeM:bind('', 'left', 'Move to monitor left', function() move_win('left') end, nil, nil)
resizeM:bind('', 'space', 'Move to next monitor', function() move_win('next') end, nil, nil)

function cycle_wins_next()
    resize_win_list[resize_current_winnum]:focus()
    resize_current_winnum = resize_current_winnum + 1
    if resize_current_winnum > #resize_win_list then resize_current_winnum = 1 end
end

function cycle_wins_pre()
    resize_win_list[resize_current_winnum]:focus()
    resize_current_winnum = resize_current_winnum - 1
    if resize_current_winnum < 1 then resize_current_winnum = #resize_win_list end
end

appM = hs.hotkey.modal.new()
local modalpkg = {}
modalpkg.id = "appM"
modalpkg.modal = appM
table.insert(modal_list, modalpkg)

function appM:entered()
    for i=1,#modal_list do
        if modal_list[i].id == "appM" then
            table.insert(activeModals, modal_list[i])
        end
    end
    if hotkeytext then
        hotkeytext:delete()
        hotkeytext=nil
        hotkeybg:delete()
        hotkeybg=nil
    end
    if show_applauncher_tips == nil then show_applauncher_tips = true end
    if show_applauncher_tips == true then showavailableHotkey() end
end

function appM:exited()
    for i=1,#activeModals do
        if activeModals[i].id == "appM" then
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
