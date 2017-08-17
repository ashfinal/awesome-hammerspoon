local obj={}
obj.__index = obj

obj.name = "browserTabs"
obj.version = "1.0"
obj.author = "ashfinal <ashfinal@gmail.com>"

-- Internal function used to find our location, so we know where to load files from
local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

obj.spoonPath = script_path()

-- Define the source's overview. A unique `keyword` key should exist, so this source can be found.
obj.overview = {text="Type t ⇥ to search safari/chrome Tabs.", image=hs.image.imageFromPath(obj.spoonPath .. "/resources/tabs.png"), keyword="t"}
-- Define the notice when a long-time request is being executed. It could be `nil`.
obj.notice = {text="Requesting data, please wait a while …"}

local function browserTabsRequest()
    local safari_running = hs.application.applicationsForBundleID("com.apple.Safari")
    local chooser_data = {}
    if #safari_running > 0 then
        local stat, data= hs.osascript.applescript('tell application "Safari"\nset winlist to tabs of windows\nset tablist to {}\nrepeat with i in winlist\nif (count of i) > 0 then\nrepeat with currenttab in i\nset tabinfo to {name of currenttab as unicode text, URL of currenttab}\ncopy tabinfo to the end of tablist\nend repeat\nend if\nend repeat\nreturn tablist\nend tell')
        -- Notice `output` key and its `arg`. The built-in output contains `browser`, `safari`, `chrome`, `firefon`, `clipboard`, `keystrokes`. You can define new output type if you like.
        if stat then
            chooser_data = hs.fnutils.imap(data, function(item)
                return {text=item[1], subText=item[2], image=hs.image.imageFromPath(obj.spoonPath .. "/resources/safari.png"), output="safari", arg=item[2]}
            end)
        end
    end
    local chrome_running = hs.application.applicationsForBundleID("com.google.Chrome")
    if #chrome_running > 0 then
        local stat, data= hs.osascript.applescript('tell application "Google Chrome"\nset winlist to tabs of windows\nset tablist to {}\nrepeat with i in winlist\nif (count of i) > 0 then\nrepeat with currenttab in i\nset tabinfo to {name of currenttab as unicode text, URL of currenttab}\ncopy tabinfo to the end of tablist\nend repeat\nend if\nend repeat\nreturn tablist\nend tell')
        if stat then
            for idx,val in pairs(data) do
                -- Usually we want to open chrome tabs in Google Chrome.
                table.insert(chooser_data, {text=val[1], subText=val[2], image=hs.image.imageFromPath(obj.spoonPath .. "/resources/chrome.png"), output="chrome", arg=val[2]})
            end
        end
    end
    -- Return specific table as hs.chooser's data, other keys except for `text` could be optional.
    return chooser_data
end

-- Define the function which will be called when the `keyword` triggers a new source. The returned value is a table. Read more: http://www.hammerspoon.org/docs/hs.chooser.html#choices
obj.init_func = browserTabsRequest
-- Insert a friendly tip at the head so users know what to do next.
obj.description = {text="Browser Tabs Search", subText="Search and select one item to open in corresponding browser.", image=hs.image.imageFromPath(obj.spoonPath .. "/resources/tabs.png")}

-- As the user is typing, the callback function will be called for every keypress. The returned value is a table.
obj.callback = nil

return obj
