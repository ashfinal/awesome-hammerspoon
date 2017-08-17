local obj={}
obj.__index = obj

obj.name = "youdaoDict"
obj.version = "1.0"
obj.author = "ashfinal <ashfinal@gmail.com>"

-- Internal function used to find our location, so we know where to load files from
local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

obj.spoonPath = script_path()

-- Define the source's overview. A unique `keyword` key should exist, so this source can be found.
obj.overview = {text="Type y ⇥ to use Yaodao dictionary.", image=hs.image.imageFromPath(obj.spoonPath .. "/resources/youdao.png"), keyword="y"}
-- Define the notice when a long-time request is being executed. It could be `nil`.
obj.notice = nil

local function youdaoTips()
    local chooser_data = {
        {text="Youdao Dictionary", subText="Type something to get it translated …", image=hs.image.imageFromPath(obj.spoonPath .. "/resources/youdao.png")}
    }
    return chooser_data
end

-- Define the function which will be called when the `keyword` triggers a new source. The returned value is a table. Read more: http://www.hammerspoon.org/docs/hs.chooser.html#choices
obj.init_func = youdaoTips
-- Insert a friendly tip at the head so users know what to do next.
-- As this source highly relys on queryChangedCallback, we'd better tip users in callback instead of here
obj.description = nil

-- As the user is typing, the callback function will be called for every keypress. The returned value is a table.

local function basic_extract(arg)
    if arg then return arg.explains else return {} end
end
local function web_extract(arg)
    if arg then
        local value = hs.fnutils.imap(arg, function(item)
            return item.key .. table.concat(item.value, ",")
        end)
        return value
    else
        return {}
    end
end

local function youdaoInstantTrans(querystr)
    local youdao_keyfrom = 'hsearch'
    local youdao_apikey = '1199732752'
    local youdao_baseurl = 'http://fanyi.youdao.com/openapi.do?keyfrom=' .. youdao_keyfrom .. '&key=' .. youdao_apikey .. '&type=data&doctype=json&version=1.1&q='
    if string.len(querystr) > 0 then
        local encoded_query = hs.http.encodeForQuery(querystr)
        local query_url = youdao_baseurl .. encoded_query

        hs.http.asyncGet(query_url, nil, function(status, data)
            if status == 200 then
                if pcall(function() hs.json.decode(data) end) then
                    local decoded_data = hs.json.decode(data)
                    if decoded_data.errorCode == 0 then
                        local basictrans = basic_extract(decoded_data.basic)
                        local webtrans = web_extract(decoded_data.web)
                        local dictpool = hs.fnutils.concat(basictrans, webtrans)
                        if #dictpool > 0 then
                            local chooser_data = hs.fnutils.imap(dictpool, function(item)
                                return {text=item, image=hs.image.imageFromPath(obj.spoonPath .. "/resources/youdao.png"), output="clipboard", arg=item}
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
            end
        end)
    else
        local chooser_data = {
            {text="Youdao Dictionary", subText="Type something to get it translated …", image=hs.image.imageFromPath(obj.spoonPath .. "/resources/youdao.png")}
        }
        if spoon.HSearch then
            spoon.HSearch.chooser:choices(chooser_data)
            spoon.HSearch.chooser:refreshChoicesCallback()
        end
    end
end

obj.callback = youdaoInstantTrans

return obj
