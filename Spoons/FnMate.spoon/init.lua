--- === FnMate ===
---
--- Use Fn + `h/l/j/k` as arrow keys, `y/u/i/o` as mouse wheel, `,/.` as left/right click.
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/FnMate.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/FnMate.spoon.zip)

local obj={}
obj.__index = obj

-- Metadata
obj.name = "FnMate"
obj.version = "1.0"
obj.author = "ashfinal <ashfinal@gmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

function obj:init()
    local function catcher(event)
        if event:getFlags()['fn'] and event:getCharacters() == "h" then
            return true, {hs.eventtap.event.newKeyEvent({}, "left", true)}
        elseif event:getFlags()['fn'] and event:getCharacters() == "l" then
            return true, {hs.eventtap.event.newKeyEvent({}, "right", true)}
        elseif event:getFlags()['fn'] and event:getCharacters() == "j" then
            return true, {hs.eventtap.event.newKeyEvent({}, "down", true)}
        elseif event:getFlags()['fn'] and event:getCharacters() == "k" then
            return true, {hs.eventtap.event.newKeyEvent({}, "up", true)}
        elseif event:getFlags()['fn'] and event:getCharacters() == "y" then
            return true, {hs.eventtap.event.newScrollEvent({3, 0}, {}, "line")}
        elseif event:getFlags()['fn'] and event:getCharacters() == "o" then
            return true, {hs.eventtap.event.newScrollEvent({-3, 0}, {}, "line")}
        elseif event:getFlags()['fn'] and event:getCharacters() == "u" then
            return true, {hs.eventtap.event.newScrollEvent({0, -3}, {}, "line")}
        elseif event:getFlags()['fn'] and event:getCharacters() == "i" then
            return true, {hs.eventtap.event.newScrollEvent({0, 3}, {}, "line")}
        elseif event:getFlags()['fn'] and event:getCharacters() == "," then
            local currentpos = hs.mouse.getAbsolutePosition()
            return true, {hs.eventtap.leftClick(currentpos)}
        elseif event:getFlags()['fn'] and event:getCharacters() == "." then
            local currentpos = hs.mouse.getAbsolutePosition()
            return true, {hs.eventtap.rightClick(currentpos)}
        end
    end
    fn_tapper = hs.eventtap.new({hs.eventtap.event.types.keyDown}, catcher):start()
end

return obj
