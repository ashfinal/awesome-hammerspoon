hs.window.animationDuration = 0
launch_modalmgr = true
idleto_netspeed = true
launch_resizeM = false

white = hs.drawing.color.white
black = hs.drawing.color.black
blue = hs.drawing.color.blue
red = hs.drawing.color.osx_red
green = hs.drawing.color.osx_green
yellow = hs.drawing.color.osx_yellow
tomato = hs.drawing.color.x11.tomato
dodgerblue = hs.drawing.color.x11.dodgerblue
firebrick = hs.drawing.color.x11.firebrick
lawngreen = hs.drawing.color.x11.lawngreen
lightseagreen = hs.drawing.color.x11.lightseagreen
purple = hs.drawing.color.x11.purple
royalblue = hs.drawing.color.x11.royalblue
sandybrown = hs.drawing.color.x11.sandybrown
gray = {red=0,blue=0,green=0,alpha=0.5}


modal_list = {}

function modal_stat(modal, color)
    if not modal_show then
        local mainScreen = hs.screen.mainScreen()
        local mainRes = mainScreen:fullFrame()
        local modal_bg_rect = hs.geometry.rect(mainRes.w-170,mainRes.h-24,170,19)
        local modal_text_rect = hs.geometry.rect(mainRes.w-170,mainRes.h-24,170,19)
        modal_bg = hs.drawing.rectangle(modal_bg_rect)
        modal_bg:setStroke(false)
        modal_bg:setFillColor(black)
        modal_bg:setRoundedRectRadii(2,2)
        modal_bg:setLevel(hs.drawing.windowLevels.modalPanel)
        modal_bg:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        local styledText = hs.styledtext.new("init...",{font={size=14.0,color=white},paragraphStyle={alignment="center"}})
        modal_show = hs.drawing.text(modal_text_rect,styledText)
        modal_show:setLevel(hs.drawing.windowLevels.modalPanel)
        modal_show:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
    end
    modal_bg:show()
    modal_bg:setFillColor(color)
    modal_show:show()
    modal_text = string.upper(modal .. ' mode')
    modal_show:setText(modal_text)
end

function exit_others(except)
    for i = 1, #modal_list do
        if modal_list[i] ~= except then
            modal_list[i]:exit()
        end
    end
end

function check_idle()
    if modal_text == 'DOCK MODE' then
        netspeedM:enter()
    end
end

modalmgr = hs.hotkey.modal.new('alt', 'space')
function modalmgr:entered()
    dock_launched = true
    modal_stat('dock',black)
    if launch_resizeM == true then resizeM:enter() end
    if idleto_netspeed == true then
        idletimer = hs.timer.doEvery(5,check_idle)
    end
end
function modalmgr:exited()
    exit_others(nil)
    dock_launched = nil
    modal_bg:hide()
    modal_show:hide()
    if idletimer ~= nil then idletimer:stop() end
end
modalmgr:bind('alt', 'space', function() modalmgr:exit() end)
modalmgr:bind('alt', 'A', nil, function() exit_others(appM) appM:enter() end)
modalmgr:bind('alt', 'C', nil, function() exit_others(clipboardM) clipboardM:enter() end)
modalmgr:bind('alt', 'D', nil, function() exit_others(downloadM) downloadM:enter() end)
modalmgr:bind('alt', 'E', nil, function() showCalendar() end)
modalmgr:bind('alt', 'I', nil, function() exit_others(timerM) timerM:enter() end)
modalmgr:bind('alt', 'K', nil, function() showAnalogClock() end)
modalmgr:bind('alt', 'N', nil, function() exit_others(netspeedM) netspeedM:enter() end)
modalmgr:bind('alt', 'R', nil, function() exit_others(resizeM) resizeM:enter() end)
modalmgr:bind('alt', 'S', nil, function() exit_others(cheatsheetM) cheatsheetM:enter() end)
modalmgr:bind('alt', 'T', nil, function() show_time() end)
modalmgr:bind('alt', 'V', nil, function() exit_others(viewM) viewM:enter() end)
modalmgr:bind('alt', 'Z', nil, function() hs.openConsole() end)
modalmgr:bind('alt', 'tab', nil, function() exit_others(nil) hs.hints.windowHints() end)

if launch_modalmgr == true then
    modalmgr:enter()
end


viewM = hs.hotkey.modal.new({'cmd','alt','ctrl'}, 'v')
table.insert(modal_list, viewM)
function viewM:entered() modal_stat('view',royalblue) end
function viewM:exited() if dock_launched then modal_stat('dock',black) else modal_bg:hide() modal_show:hide() end end
viewM:bind('alt', 'V', function() viewM:exit() end)
viewM:bind('', 'escape', function() viewM:exit() end)
viewM:bind('', 'H', nil, function() hs.eventtap.keyStroke({},'left') end, function() hs.eventtap.keyStroke({},'left') end)
viewM:bind('', 'L', nil, function() hs.eventtap.keyStroke({},'right') end, function() hs.eventtap.keyStroke({},'right') end)
viewM:bind('', 'J', nil, function() hs.eventtap.keyStroke({},'down') end, function() hs.eventtap.keyStroke({},'down') end)
viewM:bind('', 'K', nil, function() hs.eventtap.keyStroke({},'up') end, function() hs.eventtap.keyStroke({},'up') end)
viewM:bind('', '/', nil, function() hs.eventtap.keyStroke({'cmd'},'f') end)


resizeM = hs.hotkey.modal.new({'cmd','alt','ctrl'}, 'r')
table.insert(modal_list, resizeM)
function resizeM:entered() modal_stat('resize',firebrick) end
function resizeM:exited() if dock_launched then modal_stat('dock',black) else modal_bg:hide() modal_show:hide() end end
resizeM:bind('alt', 'R', function() resizeM:exit() end)
resizeM:bind('', 'escape', function() resizeM:exit() end)
resizeM:bind('', 'Q', function() resizeM:exit() end)
resizeM:bind('', 'tab', nil, function() cycle_wins() end, function() cycle_wins() end)
resizeM:bind('', 'H', nil, function() resize_win('left') end, function() resize_win('left') end)
resizeM:bind('', 'L', nil, function() resize_win('right') end, function() resize_win('right') end)
resizeM:bind('', 'J', nil, function() resize_win('down') end, function() resize_win('down') end)
resizeM:bind('', 'K', nil, function() resize_win('up') end, function() resize_win('up') end)
resizeM:bind('', 'F', nil, function() resize_win('fullscreen') end, function() resize_win('fullscreen') end)
resizeM:bind('', 'C', nil, function() resize_win('center') end, function() resize_win('center') end)
resizeM:bind('ctrl', 'C', nil, function() resize_win('fcenter') end, function() resize_win('fcenter') end)
resizeM:bind('ctrl', 'H', nil, function() resize_win('halfleft') end, function() resize_win('halfleft') end)
resizeM:bind('ctrl', 'J', nil, function() resize_win('halfdown') end, function() resize_win('halfdown') end)
resizeM:bind('ctrl', 'K', nil, function() resize_win('halfup') end, function() resize_win('halfup') end)
resizeM:bind('ctrl', 'L', nil, function() resize_win('halfright') end, function() resize_win('halfright') end)
resizeM:bind('ctrl', 'Y', nil, function() resize_win('cornerNW') end, function() resize_win('cornerNW') end)
resizeM:bind('ctrl', 'U', nil, function() resize_win('cornerSW') end, function() resize_win('cornerSW') end)
resizeM:bind('ctrl', 'I', nil, function() resize_win('cornerSE') end, function() resize_win('cornerSE') end)
resizeM:bind('ctrl', 'O', nil, function() resize_win('cornerNE') end, function() resize_win('cornerNE') end)
resizeM:bind('', '=', nil, function() resize_win('expand') end, function() resize_win('expand') end)
resizeM:bind('', '-', nil, function() resize_win('shrink') end, function() resize_win('shrink') end)
resizeM:bind('cmd', 'H', nil, function() resize_win('mleft') end, function() resize_win('mleft') end)
resizeM:bind('cmd', 'L', nil, function() resize_win('mright') end, function() resize_win('mright') end)
resizeM:bind('cmd', 'J', nil, function() resize_win('mdown') end, function() resize_win('mdown') end)
resizeM:bind('cmd', 'K', nil, function() resize_win('mup') end, function() resize_win('mup') end)

current_winnum = 0
function cycle_wins()
    local win_list = hs.window.visibleWindows()
    current_winnum = current_winnum+1
    if current_winnum > #win_list then
        current_winnum = 0
    else
        win_list[current_winnum]:focus()
    end
end

appM = hs.hotkey.modal.new({'cmd','alt','ctrl'}, 'm')
table.insert(modal_list, appM)
function appM:entered() modal_stat('app',yellow) end
function appM:exited() if dock_launched then modal_stat('dock',black) else modal_bg:hide() modal_show:hide() end end
appM:bind('alt', 'A', function() appM:exit() end)
appM:bind('', 'escape', function() appM:exit() end)
appM:bind('', 'Q', function() appM:exit() end)
applist = {
    {shortcut = 'c',appname = 'mColorDesigner'},
    {shortcut = 'd',appname = 'ShadowsocksX'},
    {shortcut = 'f',appname = 'Finder'},
    {shortcut = 'i',appname = 'iTerm'},
    {shortcut = 'k',appname = 'KeyCastr'},
    {shortcut = 'l',appname = 'Sublime Text'},
    {shortcut = 'm',appname = 'MacVim'},
    {shortcut = 'o',appname = 'LibreOffice'},
    {shortcut = 'r',appname = 'Firefox'},
    {shortcut = 's',appname = 'Safari'},
    {shortcut = 't',appname = 'Terminal'},
    {shortcut = 'v',appname = 'Activity Monitor'},
    {shortcut = 'w',appname = 'Mweb'},
    {shortcut = 'y',appname = 'System Preferences'},
}

for i = 1, #applist do
    appM:bind('', applist[i].shortcut, nil, function() hs.application.launchOrFocus(applist[i].appname) appM:exit() end)
end

