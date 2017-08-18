local obj={}
obj.__index = obj

obj.name = "MLemoji"
obj.version = "1.0"
obj.author = "ashfinal <ashfinal@gmail.com>"

-- Internal function used to find our location, so we know where to load files from
local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

obj.spoonPath = script_path()

-- Define the source's overview. A unique `keyword` key should exist, so this source can be found.
obj.overview = {text="Type e ⇥ to find relevant Emoji.", image=hs.image.imageFromPath(obj.spoonPath .. "/resources/emoji.png"), keyword="e"}
-- Define the notice when a long-time request is being executed. It could be `nil`.
obj.notice = nil

local function emojiTips()
    local chooser_data = {
        {text="Relevant Emoji", subText="Type something to find relevant emoji from text …", image=hs.image.imageFromPath(obj.spoonPath .. "/resources/emoji.png")}
    }
    return chooser_data
end
-- Define the function which will be called when the `keyword` triggers a new source. The returned value is a table. Read more: http://www.hammerspoon.org/docs/hs.chooser.html#choices
obj.init_func = emojiTips
-- Insert a friendly tip at the head so users know what to do next.
-- As this source highly relys on queryChangedCallback, we'd better tip users in callback instead of here
obj.description = nil

-- As the user is typing, the callback function will be called for every keypress. The returned value is a table.

-- Some global objects
local emoji_database_path = "/System/Library/Input Methods/CharacterPalette.app/Contents/Resources/CharacterDB.sqlite3"
obj.database = hs.sqlite3.open(emoji_database_path)
obj.canvas = hs.canvas.new({x=0, y=0, w=96, h=96})

local function getEmojiDesc(arg)
    for w in obj.database:rows("SELECT info FROM unihan_dict WHERE uchr=\'" .. arg .. "\'") do
        return w[1]
    end
end

local function emojiRequest(querystr)
    local emoji_baseurl = 'https://emoji.getdango.com'
    if string.len(querystr) > 0 then
        local encoded_query = hs.http.encodeForQuery(querystr)
        local query_url = emoji_baseurl .. '/api/emoji?q=' .. encoded_query

        hs.http.asyncGet(query_url, nil, function(status, data)
            if status == 200 then
                if pcall(function() hs.json.decode(data) end) then
                    local decoded_data = hs.json.decode(data)
                    if decoded_data.results and #decoded_data.results > 0 then
                        local chooser_data = hs.fnutils.imap(decoded_data.results, function(item)
                            obj.canvas[1] = {type="text", text=item.text, textSize=64, frame={x="15%", y="10%", w="100%", h="100%"}}
                            local hexcode = string.format("%#X", utf8.codepoint(item.text))
                            local emoji_description = getEmojiDesc(item.text)
                            local formatted_desc = string.gsub(emoji_description, "|||||||||||||||", "")
                            return {text = formatted_desc, image=obj.canvas:imageFromCanvas(), subText="Hex Code: " .. hexcode, outputType="keystrokes", arg=item.text}
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
            {text="Relevant Emoji", subText="Type something to find relevant emoji from text …", image=hs.image.imageFromPath(obj.spoonPath .. "/resources/emoji.png")}
        }
        if spoon.HSearch then
            spoon.HSearch.chooser:choices(chooser_data)
            spoon.HSearch.chooser:refreshChoicesCallback()
        end
    end
end

obj.callback = emojiRequest

return obj
