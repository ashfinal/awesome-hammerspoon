--- === WinWin ===
---
--- Windows manipulation
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/WinWin.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/WinWin.spoon.zip)

local obj={}
obj.__index = obj

-- Metadata
obj.name = "WinWin"
obj.version = "1.0"
obj.author = "ashfinal <ashfinal@gmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Windows manipulation history. Only the last operation is stored.
obj.history = {}

--- WinWin.gridparts
--- Variable
--- An integer specifying how many gridparts the screen should be divided into. Defaults to 30.
obj.gridparts = 30

--- WinWin:stepMove(direction)
--- Method
--- Move the focused window in the `direction` by on step. The step scale equals to the width/height of one gridpart.
---
--- Parameters:
---  * direction - A string specifying the direction, valid strings are: `left`, `right`, `up`, `down`.
function obj:stepMove(direction)
    local cwin = hs.window.focusedWindow()
    if cwin then
        local cscreen = cwin:screen()
        local cres = cscreen:fullFrame()
        local stepw = cres.w/obj.gridparts
        local steph = cres.h/obj.gridparts
        local wtopleft = cwin:topLeft()
        if direction == "left" then
            cwin:setTopLeft({x=wtopleft.x-stepw, y=wtopleft.y})
        elseif direction == "right" then
            cwin:setTopLeft({x=wtopleft.x+stepw, y=wtopleft.y})
        elseif direction == "up" then
            cwin:setTopLeft({x=wtopleft.x, y=wtopleft.y-steph})
        elseif direction == "down" then
            cwin:setTopLeft({x=wtopleft.x, y=wtopleft.y+steph})
        end
    else
        hs.alert.show("No focused window!")
    end
end

--- WinWin:stepResize(direction)
--- Method
--- Resize the focused window in the `direction` by on step.
---
--- Parameters:
---  * direction - A string specifying the direction, valid strings are: `left`, `right`, `up`, `down`.
function obj:stepResize(direction)
    local cwin = hs.window.focusedWindow()
    if cwin then
        local cscreen = cwin:screen()
        local cres = cscreen:fullFrame()
        local stepw = cres.w/obj.gridparts
        local steph = cres.h/obj.gridparts
        local wsize = cwin:size()
        if direction == "left" then
            cwin:setSize({w=wsize.w-stepw, h=wsize.h})
        elseif direction == "right" then
            cwin:setSize({w=wsize.w+stepw, h=wsize.h})
        elseif direction == "up" then
            cwin:setSize({w=wsize.w, h=wsize.h-steph})
        elseif direction == "down" then
            cwin:setSize({w=wsize.w, h=wsize.h+steph})
        end
    else
        hs.alert.show("No focused window!")
    end
end

--- WinWin:stash()
--- Method
--- Stash current windows's position and size.
---

local function isInHistory(windowid)
    for idx,val in ipairs(obj.history) do
        if val[1] == windowid then
            return idx
        end
    end
    return false
end

function obj:stash()
    local cwin = hs.window.focusedWindow()
    local winid = cwin:id()
    local winf = cwin:frame()
    local id_idx = isInHistory(winid)
    if id_idx then
        -- Bring recently used window id up, so they wouldn't get removed because of exceeding capacity
        if id_idx == 100 then
            local tmptable = obj.history[id_idx]
            table.remove(obj.history, id_idx)
            table.insert(obj.history, 1, tmptable)
            -- Make sure the history for each application doesn't reach the maximum (100 items)
            local id_history = obj.history[1][2]
            if #id_history > 100 then table.remove(id_history) end
            table.insert(id_history, 1, winf)
        else
            local id_history = obj.history[id_idx][2]
            if #id_history > 100 then table.remove(id_history) end
            table.insert(id_history, 1, winf)
        end
    else
        -- Make sure the history of window id doesn't reach the maximum (100 items).
        if #obj.history > 100 then table.remove(obj.history) end
        -- Stash new window id and its first history
        local newtable = {winid, {winf}}
        table.insert(obj.history, 1, newtable)
    end
end

--- WinWin:moveAndResize(option)
--- Method
--- Move and resize the focused window.
---
--- Parameters:
---  * option - A string specifying the option, valid strings are: `halfleft`, `halfright`, `halfup`, `halfdown`, `cornerNW`, `cornerSW`, `cornerNE`, `cornerSE`, `center`, `fullscreen`, `expand`, `shrink`.

function obj:moveAndResize(option)
    local cwin = hs.window.focusedWindow()
    if cwin then
        local cscreen = cwin:screen()
        local cres = cscreen:fullFrame()
        local stepw = cres.w/obj.gridparts
        local steph = cres.h/obj.gridparts
        local wf = cwin:frame()
        if option == "halfleft" then
            cwin:setFrame({x=cres.x, y=cres.y, w=cres.w/2, h=cres.h})
        elseif option == "halfright" then
            cwin:setFrame({x=cres.x+cres.w/2, y=cres.y, w=cres.w/2, h=cres.h})
        elseif option == "halfup" then
            cwin:setFrame({x=cres.x, y=cres.y, w=cres.w, h=cres.h/2})
        elseif option == "halfdown" then
            cwin:setFrame({x=cres.x, y=cres.y+cres.h/2, w=cres.w, h=cres.h/2})
        elseif option == "cornerNW" then
            cwin:setFrame({x=cres.x, y=cres.y, w=cres.w/2, h=cres.h/2})
        elseif option == "cornerNE" then
            cwin:setFrame({x=cres.x+cres.w/2, y=cres.y, w=cres.w/2, h=cres.h/2})
        elseif option == "cornerSW" then
            cwin:setFrame({x=cres.x, y=cres.y+cres.h/2, w=cres.w/2, h=cres.h/2})
        elseif option == "cornerSE" then
            cwin:setFrame({x=cres.x+cres.w/2, y=cres.y+cres.h/2, w=cres.w/2, h=cres.h/2})
        elseif option == "fullscreen" then
            cwin:setFrame({x=cres.x, y=cres.y, w=cres.w, h=cres.h})
        elseif option == "center" then
            cwin:centerOnScreen()
        elseif option == "expand" then
            cwin:setFrame({x=wf.x-stepw, y=wf.y-steph, w=wf.w+(stepw*2), h=wf.h+(steph*2)})
        elseif option == "shrink" then
            cwin:setFrame({x=wf.x+stepw, y=wf.y+steph, w=wf.w-(stepw*2), h=wf.h-(steph*2)})
        end
    else
        hs.alert.show("No focused window!")
    end
end

--- WinWin:moveToScreen(direction)
--- Method
--- Move the focused window between all of the screens in the `direction`.
---
--- Parameters:
---  * direction - A string specifying the direction, valid strings are: `left`, `right`, `up`, `down`, `next`.
function obj:moveToScreen(direction)
    local cwin = hs.window.focusedWindow()
    if cwin then
        local cscreen = cwin:screen()
        if direction == "up" then
            cwin:moveOneScreenNorth()
        elseif direction == "down" then
            cwin:moveOneScreenSouth()
        elseif direction == "left" then
            cwin:moveOneScreenWest()
        elseif direction == "right" then
            cwin:moveOneScreenEast()
        elseif direction == "next" then
            cwin:moveToScreen(cscreen:next())
        end
    else
        hs.alert.show("No focused window!")
    end
end

--- WinWin:undo()
--- Method
--- Undo the last window manipulation. Only those "moveAndResize" manipulations can be undone.
---

function obj:undo()
    local cwin = hs.window.focusedWindow()
    local winid = cwin:id()
    -- Has this window been stored previously?
    local id_idx = isInHistory(winid)
    if id_idx then
        -- Bring recently used window id up, so they wouldn't get removed because of exceeding capacity
        if id_idx == 100 then
            local tmptable = obj.history[id_idx]
            table.remove(obj.history, id_idx)
            table.insert(obj.history, 1, tmptable)
            local id_history = obj.history[1][2]
            cwin:setFrame(id_history[1])
            -- Rewind the history
            local tmpframe = id_history[1]
            table.remove(id_history, 1)
            table.insert(id_history, tmpframe)
        else
            local id_history = obj.history[id_idx][2]
            cwin:setFrame(id_history[1])
            local tmpframe = id_history[1]
            table.remove(id_history, 1)
            table.insert(id_history, tmpframe)
        end
    end
end

--- WinWin:redo()
--- Method
--- Redo the window manipulation. Only those "moveAndResize" manipulations can be undone.
---

function obj:redo()
    local cwin = hs.window.focusedWindow()
    local winid = cwin:id()
    -- Has this window been stored previously?
    local id_idx = isInHistory(winid)
    if id_idx then
        -- Bring recently used window id up, so they wouldn't get removed because of exceeding capacity
        if id_idx == 100 then
            local tmptable = obj.history[id_idx]
            table.remove(obj.history, id_idx)
            table.insert(obj.history, 1, tmptable)
            local id_history = obj.history[1][2]
            cwin:setFrame(id_history[#id_history])
            -- Play the history
            local tmpframe = id_history[#id_history]
            table.remove(id_history)
            table.insert(id_history, 1, tmpframe)
        else
            local id_history = obj.history[id_idx][2]
            cwin:setFrame(id_history[#id_history])
            local tmpframe = id_history[#id_history]
            table.remove(id_history)
            table.insert(id_history, 1, tmpframe)
        end
    end
end

--- WinWin:centerCursor()
--- Method
--- Center the cursor on the focused window.
---

function obj:centerCursor()
    local cwin = hs.window.focusedWindow()
    local wf = cwin:frame()
    local cscreen = cwin:screen()
    local cres = cscreen:fullFrame()
    if cwin then
        -- Center the cursor one the focused window
        hs.mouse.setAbsolutePosition({x=wf.x+wf.w/2, y=wf.y+wf.h/2})
    else
        -- Center the cursor on the screen
        hs.mouse.setAbsolutePosition({x=cres.x+cres.w/2, y=cres.y+cres.h/2})
    end
end

return obj
