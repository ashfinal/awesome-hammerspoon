local obj={}
obj.__index = obj

obj.name = "thesaurusDM"
obj.version = "1.0"
obj.author = "ashfinal <ashfinal@gmail.com>"

-- Internal function used to find our location, so we know where to load files from
local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

obj.spoonPath = script_path()

-- Define the source's overview. A unique `keyword` key should exist, so this source can be found.
obj.overview = {text="Type s ⇥ to request English Thesaurus.", image=hs.image.imageFromPath(obj.spoonPath .. "/resources/thesaurus.png"), keyword="s"}
-- Define the notice when a long-time request is being executed. It could be `nil`.
obj.notice = nil

local function dmTips()
    local chooser_data = {
        {text="Datamuse Thesaurus", subText="Type something to get more words like it …", image=hs.image.imageFromPath(obj.spoonPath .. "/resources/thesaurus.png")}
    }
    return chooser_data
end

-- Define the function which will be called when the `keyword` triggers a new source. The returned value is a table. Read more: http://www.hammerspoon.org/docs/hs.chooser.html#choices
obj.init_func = dmTips
-- Insert a friendly tip at the head so users know what to do next.
-- As this source highly relys on queryChangedCallback, we'd better tip users in callback instead of here
obj.description = nil

-- As the user is typing, the callback function will be called for every keypress. The returned value is a table.

local function thesaurusRequest(querystr)
    local datamuse_baseurl = 'http://api.datamuse.com'
    if string.len(querystr) > 0 then
        local encoded_query = hs.http.encodeForQuery(querystr)
        local query_url = datamuse_baseurl .. '/words?ml=' .. encoded_query .. '&max=20'

        hs.http.asyncGet(query_url, nil, function(status, data)
            if status == 200 then
                if pcall(function() hs.json.decode(data) end) then
                    local decoded_data = hs.json.decode(data)
                    if #decoded_data > 0 then
                        local chooser_data = hs.fnutils.imap(decoded_data, function(item)
                            return {text = item.word, image=hs.image.imageFromPath(obj.spoonPath .. "/resources/thesaurus.png"), output="keystrokes", arg=item.word}
                        end)
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
    else
        local chooser_data = {
            {text="Datamuse Thesaurus", subText="Type something to get more words like it …", image=hs.image.imageFromPath(obj.spoonPath .. "/resources/thesaurus.png")}
        }
        if spoon.HSearch then
            spoon.HSearch.chooser:choices(chooser_data)
            spoon.HSearch.chooser:refreshChoicesCallback()
        end
    end
end

obj.callback = thesaurusRequest

return obj
