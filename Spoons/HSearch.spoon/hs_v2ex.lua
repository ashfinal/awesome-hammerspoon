local obj={}
obj.__index = obj

obj.name = "v2exPosts"
obj.version = "1.0"
obj.author = "ashfinal <ashfinal@gmail.com>"

-- Internal function used to find our location, so we know where to load files from
local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

obj.spoonPath = script_path()

-- Define the source's overview. A unique `keyword` key should exist, so this source can be found.
obj.overview = {text="Type v ⇥ to fetch v2ex posts.", image=hs.image.imageFromPath(obj.spoonPath .. "/resources/v2ex.png"), keyword="v"}
-- Define the notice when a long-time request is being executed. It could be `nil`.
obj.notice = {text="Requesting data, please wait a while …"}

local function v2exRequest()
    local query_url = 'https://www.v2ex.com/api/topics/latest.json'
    local stat, body = hs.http.asyncGet(query_url, nil, function(status, data)
        if status == 200 then
            if pcall(function() hs.json.decode(data) end) then
                local decoded_data = hs.json.decode(data)
                if #decoded_data > 0 then
                    local chooser_data = hs.fnutils.imap(decoded_data, function(item)
                        local sub_content = string.gsub(item.content, "\r\n", " ")
                        local function trim_content()
                            if utf8.len(sub_content) > 40 then
                                return string.sub(sub_content, 1, utf8.offset(sub_content, 40)-1)
                            else
                                return sub_content
                            end
                        end
                        local final_content = trim_content()
                        return {text=item.title, subText=final_content, image=hs.image.imageFromPath(obj.spoonPath .. "/resources/v2ex.png"), outputType="browser", arg=item.url}
                    end)
                    local source_desc = {text="v2ex Posts", subText="Select some item to get it opened in default browser …", image=hs.image.imageFromPath(obj.spoonPath .. "/resources/v2ex.png")}
                    table.insert(chooser_data, 1, source_desc)
                    -- Because we don't know when asyncGet will return data, we have to refresh hs.chooser choices in this callback.
                    if spoon.HSearch then
                        -- Make sure HSearch spoon is running now
                        spoon.HSearch.chooser:choices(chooser_data)
                        spoon.HSearch.chooser:refreshChoicesCallback()
                    end
                end
            end
        end
    end)
end
-- Define the function which will be called when the `keyword` triggers a new source. The returned value is a table. Read more: http://www.hammerspoon.org/docs/hs.chooser.html#choices
obj.init_func = v2exRequest
-- Insert a friendly tip at the head so users know what to do next.
-- As this source highly relys on queryChangedCallback, we'd better tip users in callback instead of here
obj.description = nil

-- As the user is typing, the callback function will be called for every keypress. The returned value is a table.

obj.callback = nil

return obj
