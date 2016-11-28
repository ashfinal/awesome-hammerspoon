hs.hotkey.bind({"cmd", "shift", "ctrl"}, "R", function()
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

-- Toggle files on Desktop hidden
hs.hotkey.bind({"cmd", "ctrl"}, "H", function()
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
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "H", function()
    os.execute("chflags nohidden ~/Desktop/*")
    hadHidden = nil
    hs.alert.show(" ⚐ Set unhidden")
end)

hs.hotkey.bind({"cmd", "shift", "ctrl"}, "Z", function() hs.openConsole() end)

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

hs.hotkey.bind({"cmd", "shift", "ctrl"}, "T", function() show_time() end)

function resize_win(direction)
    local win = hs.window.focusedWindow()
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
    if direction == "fcenter" then f.x = (stepw*5) f.y = (steph*5) f.w = stepw*20 f.h = steph*20 end
    if direction == "fullscreen" then f = max end
    if direction == "shrink" then f.x = f.x+stepw f.y = f.y+steph f.w = f.w-(stepw*2) f.h = f.h-(steph*2) end
    if direction == "expand" then f.x = f.x-stepw f.y = f.y-steph f.w = f.w+(stepw*2) f.h = f.h+(steph*2) end
    if direction == "mright" then f.x = f.x+stepw end
    if direction == "mleft" then f.x = f.x-stepw end
    if direction == "mup" then f.y = f.y-steph end
    if direction == "mdown" then f.y = f.y+steph end
    win:setFrame(f)
end

hs.hotkey.bind({"cmd", "alt"}, "left", function() resize_win('halfleft') end)
hs.hotkey.bind({"cmd", "alt"}, "right", function() resize_win('halfright') end)
hs.hotkey.bind({"cmd", "alt"}, "up", function() resize_win('fullscreen') end)
hs.hotkey.bind({"cmd", "alt"}, "down", function() resize_win('fcenter') end)
hs.hotkey.bind({"cmd", "alt"}, "return", function() resize_win('center') end)


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

require "modalmgr"
require "widgets/netspeed"
require "widgets/calendar"
require "widgets/analogclock"
require "modes/indicator"
require "modes/clipshow"
require "modes/aria2"
require "modes/cheatsheet"

