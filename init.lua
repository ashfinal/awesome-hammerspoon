hs.hotkey.alertDuration=0
hs.hints.showTitleThresh = 0
hs.window.animationDuration = 0

white = hs.drawing.color.white
black = hs.drawing.color.black
blue = hs.drawing.color.blue
osx_red = hs.drawing.color.osx_red
osx_green = hs.drawing.color.osx_green
osx_yellow = hs.drawing.color.osx_yellow
tomato = hs.drawing.color.x11.tomato
dodgerblue = hs.drawing.color.x11.dodgerblue
firebrick = hs.drawing.color.x11.firebrick
lawngreen = hs.drawing.color.x11.lawngreen
lightseagreen = hs.drawing.color.x11.lightseagreen
purple = hs.drawing.color.x11.purple
royalblue = hs.drawing.color.x11.royalblue
sandybrown = hs.drawing.color.x11.sandybrown
black50 = {red=0,blue=0,green=0,alpha=0.5}
darkblue = {red=24/255,blue=195/255,green=145/255,alpha=1}
gray = {red=246/255,blue=246/255,green=246/255,alpha=0.3}

privatepath = hs.fs.pathToAbsolute(hs.fs.currentDir()..'/private')
if privatepath == nil then
    hs.fs.mkdir(hs.fs.currentDir()..'/private')
end
privateconf = hs.fs.pathToAbsolute(hs.fs.currentDir()..'/private/awesomeconfig.lua')
if privateconf ~= nil then
    require('private/awesomeconfig')
end

hsreload_keys = hsreload_keys or {{"cmd", "shift", "ctrl"}, "R"}
if string.len(hsreload_keys[2]) > 0 then
    hs.hotkey.bind(hsreload_keys[1], hsreload_keys[2], "Reload Configuration", function() hs.reload() end)
end

lockscreen_keys = lockscreen_keys or {{"cmd", "shift", "ctrl"}, "L"}
if string.len(lockscreen_keys[2]) > 0 then
    hs.hotkey.bind(lockscreen_keys[1], lockscreen_keys[2],"Lock Screen", function() hs.caffeinate.lockScreen() end)
end

if modalmgr == nil then
    showtime_lkeys = showtime_lkeys or {{"cmd", "shift", "ctrl"}, "T"}
    if string.len(showtime_lkeys[2]) > 0 then
        hs.hotkey.bind(showtime_lkeys[1], showtime_lkeys[2], 'Show Digital Clock', function() show_time() end)
    end
end

function show_time()
    if time_draw == nil then
        local mainScreen = hs.screen.mainScreen()
        local mainRes = mainScreen:fullFrame()
        local time_str = hs.styledtext.new(os.date("%H:%M"),{font={name="Impact",size=120},color=darkblue,paragraphStyle={alignment="center"}})
        local timeframe = hs.geometry.rect((mainRes.w-300)/2,(mainRes.h-200)/2,300,150)
        time_draw = hs.drawing.text(timeframe,time_str)
        time_draw:setLevel(hs.drawing.windowLevels.overlay)
        time_draw:show()
        if ttimer == nil then
            ttimer = hs.timer.doAfter(4, function() time_draw:delete() time_draw=nil end)
        else
            ttimer:start()
        end
    else
        ttimer:stop()
        time_draw:delete()
        time_draw=nil
    end
end

showhotkey_keys = showhotkey_keys or {{"cmd", "shift", "ctrl"}, "space"}
if string.len(showhotkey_keys[2]) > 0 then
    hs.hotkey.bind(showhotkey_keys[1], showhotkey_keys[2], "Toggle Hotkeys Cheatsheet", function() showavailableHotkey() end)
end

function showavailableHotkey()
    if not hotkeytext then
        local hotkey_list=hs.hotkey.getHotkeys()
        local mainScreen = hs.screen.mainScreen()
        local mainRes = mainScreen:fullFrame()
        local hkbgrect = hs.geometry.rect(mainRes.w/5,mainRes.h/5,mainRes.w/5*3,mainRes.h/5*3)
        hotkeybg = hs.drawing.rectangle(hkbgrect)
        -- hotkeybg:setStroke(false)
        if not hotkey_tips_bg then hotkey_tips_bg = "light" end
        if hotkey_tips_bg == "light" then
            hotkeybg:setFillColor({red=238/255,blue=238/255,green=238/255,alpha=0.95})
        elseif hotkey_tips_bg == "dark" then
            hotkeybg:setFillColor({red=0,blue=0,green=0,alpha=0.95})
        end
        hotkeybg:setRoundedRectRadii(10,10)
        hotkeybg:setLevel(hs.drawing.windowLevels.modalPanel)
        hotkeybg:behavior(hs.drawing.windowBehaviors.stationary)
        local hktextrect = hs.geometry.rect(hkbgrect.x+40,hkbgrect.y+30,hkbgrect.w-80,hkbgrect.h-60)
        hotkeytext = hs.drawing.text(hktextrect,"")
        hotkeytext:setLevel(hs.drawing.windowLevels.modalPanel)
        hotkeytext:behavior(hs.drawing.windowBehaviors.stationary)
        hotkeytext:setClickCallback(nil,function() hotkeytext:delete() hotkeytext=nil hotkeybg:delete() hotkeybg=nil end)
        hotkey_filtered = {}
        for i=1,#hotkey_list do
            if hotkey_list[i].idx ~= hotkey_list[i].msg then
                table.insert(hotkey_filtered,hotkey_list[i])
            end
        end
        local availablelen = 70
        local hkstr = ''
        for i=2,#hotkey_filtered,2 do
            local tmpstr = hotkey_filtered[i-1].msg .. hotkey_filtered[i].msg
            if string.len(tmpstr)<= availablelen then
                local tofilllen = availablelen-string.len(hotkey_filtered[i-1].msg)
                hkstr = hkstr .. hotkey_filtered[i-1].msg .. string.format('%'..tofilllen..'s',hotkey_filtered[i].msg) .. '\n'
            else
                hkstr = hkstr .. hotkey_filtered[i-1].msg .. '\n' .. hotkey_filtered[i].msg .. '\n'
            end
        end
        if math.fmod(#hotkey_filtered,2) == 1 then hkstr = hkstr .. hotkey_filtered[#hotkey_filtered].msg end
        local hkstr_styled = hs.styledtext.new(hkstr, {font={name="Courier-Bold",size=16}, color=dodgerblue, paragraphStyle={lineSpacing=12.0,lineBreak='truncateMiddle'}, shadow={offset={h=0,w=0},blurRadius=0.5,color=darkblue}})
        hotkeytext:setStyledText(hkstr_styled)
        hotkeybg:show()
        hotkeytext:show()
    else
        hotkeytext:delete()
        hotkeytext=nil
        hotkeybg:delete()
        hotkeybg=nil
    end
end

modal_list = {}

function modal_stat(color,alpha)
    if not modal_tray then
        local mainScreen = hs.screen.mainScreen()
        local mainRes = mainScreen:fullFrame()
        modal_tray = hs.canvas.new({x=mainRes.w-40,y=mainRes.h-40,w=20,h=20})
        modal_tray[1] = {action="fill",type="circle",fillColor=white}
        modal_tray[1].fillColor.alpha=0.7
        modal_tray[2] = {action="fill",type="circle",fillColor=white,radius="40%"}
        modal_tray:level(hs.canvas.windowLevels.status)
        modal_tray:clickActivating(false)
        modal_tray:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces + hs.canvas.windowBehaviors.stationary)
        modal_tray._default.trackMouseDown = true
    end
    modal_tray:show()
    modal_tray[2].fillColor = color
    modal_tray[2].fillColor.alpha = alpha
end

activeModals = {}
function exit_others(excepts)
    function isInExcepts(value,tbl)
        for i=1,#tbl do
           if tbl[i] == value then
               return true
           end
        end
        return false
    end
    if excepts == nil then excepts = {} end
    for i = 1, #activeModals do
        if not isInExcepts(activeModals[i].id, excepts) then
            activeModals[i].modal:exit()
        end
    end
end

function move_win(direction)
    local win = hs.window.focusedWindow()
    local screen = win:screen()
    if win then
        if direction == 'up' then win:moveOneScreenNorth() end
        if direction == 'down' then win:moveOneScreenSouth() end
        if direction == 'left' then win:moveOneScreenWest() end
        if direction == 'right' then win:moveOneScreenEast() end
        if direction == 'next' then win:moveToScreen(screen:next()) end
    end
end

function resize_win(direction)
    local win = hs.window.focusedWindow()
    if win then
        local f = win:frame()
        local screen = win:screen()
        local max = screen:fullFrame()
        local stepw = max.w/30
        local steph = max.h/30
        if direction == "right" then f.w = f.w+stepw end
        if direction == "left" then f.w = f.w-stepw end
        if direction == "up" then f.h = f.h-steph end
        if direction == "down" then f.h = f.h+steph end
        if direction == "halfright" then f.x = max.w/2 f.y = 0 f.w = max.w/2 f.h = max.h end
        if direction == "halfleft" then f.x = 0 f.y = 0 f.w = max.w/2 f.h = max.h end
        if direction == "halfup" then f.x = 0 f.y = 0 f.w = max.w f.h = max.h/2 end
        if direction == "halfdown" then f.x = 0 f.y = max.h/2 f.w = max.w f.h = max.h/2 end
        if direction == "cornerNE" then f.x = max.w/2 f.y = 0 f.w = max.w/2 f.h = max.h/2 end
        if direction == "cornerSE" then f.x = max.w/2 f.y = max.h/2 f.w = max.w/2 f.h = max.h/2 end
        if direction == "cornerNW" then f.x = 0 f.y = 0 f.w = max.w/2 f.h = max.h/2 end
        if direction == "cornerSW" then f.x = 0 f.y = max.h/2 f.w = max.w/2 f.h = max.h/2 end
        if direction == "center" then f.x = (max.w-f.w)/2 f.y = (max.h-f.h)/2 end
        if direction == "fcenter" then f.x = stepw*5 f.y = steph*5 f.w = stepw*20 f.h = steph*20 end
        if direction == "fullscreen" then f = max end
        if direction == "shrink" then f.x = f.x+stepw f.y = f.y+steph f.w = f.w-(stepw*2) f.h = f.h-(steph*2) end
        if direction == "expand" then f.x = f.x-stepw f.y = f.y-steph f.w = f.w+(stepw*2) f.h = f.h+(steph*2) end
        if direction == "mright" then f.x = f.x+stepw end
        if direction == "mleft" then f.x = f.x-stepw end
        if direction == "mup" then f.y = f.y-steph end
        if direction == "mdown" then f.y = f.y+steph end
        win:setFrame(f)
    else
        hs.alert.show("No focused window!")
    end
end

resizeextra_lefthalf_keys = resizeextra_lefthalf_keys or {{"cmd", "alt"}, "left"}
if string.len(resizeextra_lefthalf_keys[2]) > 0 then
    hs.hotkey.bind(resizeextra_lefthalf_keys[1], resizeextra_lefthalf_keys[2], "Lefthalf of Screen", function() resize_win('halfleft') end)
end
resizeextra_righthalf_keys = resizeextra_righthalf_keys or {{"cmd", "alt"}, "right"}
if string.len(resizeextra_righthalf_keys[2]) > 0 then
    hs.hotkey.bind(resizeextra_righthalf_keys[1], resizeextra_righthalf_keys[2], "Righthalf of Screen", function() resize_win('halfright') end)
end
resizeextra_fullscreen_keys = resizeextra_fullscreen_keys or {{"cmd", "alt"}, "up"}
if string.len(resizeextra_fullscreen_keys[2]) > 0 then
    hs.hotkey.bind(resizeextra_fullscreen_keys[1], resizeextra_fullscreen_keys[2], "Fullscreen", function() resize_win('fullscreen') end)
end
resizeextra_fcenter_keys = resizeextra_fcenter_keys or {{"cmd", "alt"}, "down"}
if string.len(resizeextra_fcenter_keys[2]) > 0 then
    hs.hotkey.bind(resizeextra_fcenter_keys[1], resizeextra_fcenter_keys[2], "Resize & Center", function() resize_win('fcenter') end)
end
resizeextra_center_keys = resizeextra_center_keys or {{"cmd", "alt"}, "return"}
if string.len(resizeextra_center_keys[2]) > 0 then
    hs.hotkey.bind(resizeextra_center_keys[1], resizeextra_center_keys[2], "Center Window", function() resize_win('center') end)
end

if not module_list then
    module_list = {
        "widgets/netspeed",
        "widgets/hcalendar",
        "widgets/analogclock",
        "widgets/aria2",
        "modes/basicmode",
        "modes/indicator",
        "modes/clipshow",
        "modes/hsearch",
    }
end

for i=1,#module_list do
    require(module_list[i])
end

if #modal_list > 0 then require("modalmgr") end

globalGC = hs.timer.doEvery(180, collectgarbage)
