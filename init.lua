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
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")

-- Window sizing:halfscreen

hs.hotkey.bind({"cmd", "ctrl"}, "Left", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "ctrl"}, "Right", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w / 2)
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "ctrl"}, "Up", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "ctrl"}, "Down", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y + (max.h / 2)
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f)
end)

-- Window sizing:quarterscreen

hs.hotkey.bind({"cmd", "ctrl", "shift"}, "Left", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h / 2
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "ctrl", "shift"}, "Up", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w / 2)
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h / 2
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "ctrl", "shift"}, "Right", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w / 2)
  f.y = max.y + (max.h / 2)
  f.w = max.w / 2
  f.h = max.h / 2
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "ctrl", "shift"}, "Down", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y + (max.h / 2)
  f.w = max.w / 2
  f.h = max.h / 2
  win:setFrame(f)
end)

-- Window sizing:fixedsize & center

hs.hotkey.bind({"cmd", "ctrl", "alt"}, "C", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()
  local stepw = max.w / 50
  local steph = max.h / 50

  f.x = max.x + (stepw * 10)
  f.y = max.y + (steph * 10)
  f.w = stepw * 30
  f.h = steph * 30
  win:setFrame(f)
end)

-- Window sizing:fullscreen

hs.hotkey.bind({"cmd", "ctrl", "alt"}, "M", function()
  local win = hs.window.focusedWindow()
  local screen = win:screen()
  local max = screen:frame()
  win:setFrame(max)
end)

-- Window sizing:expand & shrink

hs.hotkey.bind({"alt"}, "Right", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()
  local step = max.w / 30

  f.w = f.w + step
  win:setFrame(f)
end)

hs.hotkey.bind({"alt"}, "Left", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()
  local step = max.w / 30

  f.w = f.w - step
  win:setFrame(f)
end)

hs.hotkey.bind({"alt"}, "Down", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()
  local step = max.h / 30

  f.h = f.h + step
  win:setFrame(f)
end)

hs.hotkey.bind({"alt"}, "Up", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()
  local step = max.h / 30

  f.h = f.h - step
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "ctrl", "shift"}, "=", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()
  local stepw = max.w / 100
  local steph = max.h / 100

  f.x = f.x - stepw
  f.y = f.y - steph
  f.w = f.w + (stepw * 2)
  f.h = f.h + (steph * 2)
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "ctrl", "shift"}, "-", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()
  local stepw = max.w / 100
  local steph = max.h / 100

  f.x = f.x + stepw
  f.y = f.y + steph
  f.w = f.w - (stepw * 2)
  f.h = f.h - (steph * 2)
  win:setFrame(f)
end)

-- Window movement

hs.hotkey.bind({"alt","shift"}, "Right", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()
  local step = max.w / 30

  f.x = f.x + step
  win:setFrame(f)
end)

hs.hotkey.bind({"alt","shift"}, "Left", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()
  local step = max.w / 30

  f.x = f.x - step
  win:setFrame(f)
end)

hs.hotkey.bind({"alt","shift"}, "Up", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()
  local step = max.h / 30

  f.y = f.y - step
  win:setFrame(f)
end)

hs.hotkey.bind({"alt","shift"}, "Down", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()
  local step = max.h / 30

  f.y = f.y + step
  win:setFrame(f)
end)

-- Window movement:center

hs.hotkey.bind({"alt", "ctrl"}, "C", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = (max.w - f.w) / 2
  f.y = (max.h - f.h) / 2
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "ctrl"}, "L", function()
    hs.caffeinate.lockScreen()
end)

hs.hotkey.bind("Alt", "Space", hs.hints.windowHints)

caffeine = hs.menubar.new()
function setCaffeineDisplay(state)
    local result
    if state then
        result = caffeine:setTitle("♨︎")
    else
        result = caffeine:setTitle("♺")
    end
end

function caffeineClicked()
    setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end

if caffeine then
    caffeine:setClickCallback(caffeineClicked)
    setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end

hs.hotkey.bind({"cmd", "ctrl", "alt"}, "L", function() caffeineClicked() end)
