hs.hotkey.alertDuration=0
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


hs.hotkey.bind({"cmd", "shift", "ctrl"}, "R", "Reload Hammerspoon Configuration", function()
    hs.reload()
    -- hs.notify.new({title="Hammerspoon", informativeText="Config loaded"}):send()
    hs.alert.show("Config loaded")
end)

function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end

-- hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
-- hs.alert.show("Config loaded")

privatepath = hs.fs.pathToAbsolute(hs.fs.currentDir()..'/private')
if privatepath == nil then
    hs.fs.mkdir(hs.fs.currentDir()..'/private')
end
privateconf = hs.fs.pathToAbsolute(hs.fs.currentDir()..'/private/awesomeconfig.lua')
if privateconf ~= nil then
    require('private/awesomeconfig')
end

-- Toggle files on Desktop hidden
hs.hotkey.bind({"cmd", "ctrl"}, "H", "Show/Hide Files on Desktop", function()
    if hadHidden == nil then
        os.execute("chflags hidden ~/Desktop/*")
        hadHidden = 1
        hs.alert.show(" ⚑ Set hidden")
    else
        os.execute("chflags nohidden ~/Desktop/*")
        hadHidden = nil
        hs.alert.show(" ⚐ Set unhidden")
    end
end)
-- In case reboot or hammerspoon relaunch
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "H", "Force Show Files on Desktop ", function()
    os.execute("chflags nohidden ~/Desktop/*")
    hadHidden = nil
    hs.alert.show(" ⚐ Set unhidden")
end)

hs.hotkey.bind({"cmd", "ctrl", "shift"}, "L", function()
    hs.caffeinate.lockScreen()
end)

darkblue = {red=24/255,blue=195/255,green=145/255,alpha=1}
function show_time()
    if not time_draw then
        local mainScreen = hs.screen.mainScreen()
        local mainRes = mainScreen:fullFrame()
        local time_str = hs.styledtext.new(os.date("%H:%M"),{font={name="Impact",size=120},color=darkblue,paragraphStyle={alignment="center"}})
        local timeframe = hs.geometry.rect((mainRes.w-300)/2,(mainRes.h-200)/2,300,150)
        time_draw = hs.drawing.text(timeframe,time_str)
        time_draw:setLevel(hs.drawing.windowLevels.overlay)
        time_draw:show()
        ttimer = hs.timer.doAfter(4, function() time_draw:delete() time_draw=nil end)
    else
        time_draw:delete()
        time_draw=nil
    end
end

function showavailableHotkey()
    if not hotkeytext then
        local hotkey_list=hs.hotkey.getHotkeys()
        local mainScreen = hs.screen.mainScreen()
        local mainRes = mainScreen:fullFrame()
        local hkbgrect = hs.geometry.rect(mainRes.w/5,mainRes.h/5,mainRes.w/5*3,mainRes.h/5*3)
        hotkeybg = hs.drawing.rectangle(hkbgrect)
        -- hotkeybg:setStroke(false)
        hotkeybg:setFillColor({red=0,blue=0,green=0,alpha=0.5})
        hotkeybg:setRoundedRectRadii(10,10)
        hotkeybg:setLevel(hs.drawing.windowLevels.modalPanel)
        local hktextrect = hs.geometry.rect(hkbgrect.x+40,hkbgrect.y+30,hkbgrect.w-80,hkbgrect.h-60)
        hotkeytext = hs.drawing.text(hktextrect,"")
        hotkeytext:setLevel(hs.drawing.windowLevels.modalPanel)
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
        local hkstr_styled = hs.styledtext.new(hkstr, {font={name="Courier-Bold",size=16}, color=white, paragraphStyle={lineSpacing=12.0,lineBreak='truncateMiddle'}})
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
        if idle_to_which == "netspeed" and netspeedM then
            netspeedM:enter()
        elseif idle_to_which == "hide" then
            modal_show:hide()
            modal_bg:hide()
        end
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

hs.hotkey.bind({"cmd", "alt"}, "left", "Lefthalf of Screen", function() resize_win('halfleft') end)
hs.hotkey.bind({"cmd", "alt"}, "right", "Righthalf of Screen", function() resize_win('halfright') end)
hs.hotkey.bind({"cmd", "alt"}, "up", "Fullscreen", function() resize_win('fullscreen') end)
hs.hotkey.bind({"cmd", "alt"}, "down", "Resize & Center", function() resize_win('fcenter') end)
hs.hotkey.bind({"cmd", "alt"}, "return", "Center Window", function() resize_win('center') end)


-- caffeine = hs.menubar.new()
-- function setCaffeineDisplay(state)
    -- local result
    -- if state then
        -- result = caffeine:setTitle("♨︎")
    -- else
        -- result = caffeine:setTitle("♺")
    -- end
-- end

-- function caffeineClicked()
    -- setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
-- end

-- if caffeine then
    -- caffeine:setClickCallback(caffeineClicked)
    -- setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
-- end

-- hs.hotkey.bind({"cmd", "ctrl", "alt"}, "L", function() caffeineClicked() end)


if not module_list then
    module_list = {
        "basicmode",
        "widgets/netspeed",
        "widgets/calendar",
        "widgets/analogclock",
        "modes/indicator",
        "modes/clipshow",
        "modes/cheatsheet",
        "modes/hsearch",
    }
end

for i=1,#module_list do
    require(module_list[i])
end

if #modal_list > 0 then require("modalmgr") end
