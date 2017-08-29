local obj={}
obj.__index = obj

obj.name = "timeDelta"
obj.version = "1.0"
obj.author = "ashfinal <ashfinal@gmail.com>"

-- Internal function used to find our location, so we know where to load files from
local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

obj.spoonPath = script_path()

-- Define the source's overview. A unique `keyword` key should exist, so this source can be found.
obj.overview = {text="Type d ⇥ to format/query Date.", image=hs.image.imageFromPath(obj.spoonPath .. "/resources/time.png"), keyword="d"}
-- Define the notice when a long-time request is being executed. It could be `nil`.
obj.notice = nil

-- Some global objects
obj.exec_args = {
    '+"%Y-%m-%d"',
    '+"%H:%M:%S %p"',
    '+"%A, %B %d, %Y"',
    '+"%Y-%m-%d %H:%M:%S %p"',
    '+"%a, %b %d, %y"',
    '+"%m/%d/%y %H:%M %p"',
    '',
    '-u',
}

local function timeRequest()
    local chooser_data = hs.fnutils.imap(obj.exec_args, function(item)
        local exec_result = hs.execute("date " .. item)
        return {text=exec_result, subText="date " .. item, image=hs.image.imageFromPath(obj.spoonPath .. "/resources/time.png"), output="keystrokes", arg=exec_result}
    end)
    return chooser_data
end
-- Define the function which will be called when the `keyword` triggers a new source. The returned value is a table. Read more: http://www.hammerspoon.org/docs/hs.chooser.html#choices
obj.init_func = timeRequest
-- Insert a friendly tip at the head so users know what to do next.
-- As this source highly relys on queryChangedCallback, we'd better tip users in callback instead of here
obj.description = {text="Date Query", subText="Type +/-1d (or y, m, w, H, M, S) to query date forward or backward.", image=hs.image.imageFromPath(obj.spoonPath .. "/resources/time.png")}

-- As the user is typing, the callback function will be called for every keypress. The returned value is a table.

local function splitBySpace(str)
    local tmptbl = {}
    for w in string.gmatch(str,"[+-]?%d+[ymdwHMS]") do table.insert(tmptbl,w) end
    return tmptbl
end

local function timeDeltaRequest(querystr)
    if string.len(querystr) > 0 then
        local valid_inputs = splitBySpace(querystr)
        if #valid_inputs > 0 then
            local addv_before = hs.fnutils.imap(valid_inputs, function(item)
                return "-v" .. item
            end)
            local vv_var = table.concat(addv_before, " ")
            local chooser_data = hs.fnutils.imap(obj.exec_args, function(item)
                local new_exec_command = "date " .. vv_var .. " " .. item
                local new_exec_result = hs.execute(new_exec_command)
                return {text=new_exec_result, subText=new_exec_command, image=hs.image.imageFromPath(obj.spoonPath .. "/resources/time.png"), output="keystrokes", arg=new_exec_result}
            end)
            local source_desc = {text="Date Query", subText="Type +/-1d (or y, m, w, H, M, S) to query date forward or backward.", image=hs.image.imageFromPath(obj.spoonPath .. "/resources/time.png")}
            table.insert(chooser_data, 1, source_desc)
            if spoon.HSearch then
                -- Make sure HSearch spoon is running now
                spoon.HSearch.chooser:choices(chooser_data)
            end
        end
    else
        local chooser_data = timeRequest()
        local source_desc = {text="Date Query", subText="Type +/-1d (or y, m, w, H, M, S) to query date forward or backward.", image=hs.image.imageFromPath(obj.spoonPath .. "/resources/time.png")}
        table.insert(chooser_data, 1, source_desc)
        if spoon.HSearch then
            -- Make sure HSearch spoon is running now
            spoon.HSearch.chooser:choices(chooser_data)
        end
    end
end

obj.callback = timeDeltaRequest

return obj
