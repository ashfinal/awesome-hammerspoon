if usesuggest == nil then usesuggest = true end

function safariTabinfoRequest()
    local stat, data= hs.osascript.applescript('tell application "Safari"\nset winlist to tabs of windows\nset tablist to {}\nrepeat with i in winlist\nif (count of i) > 0 then\nrepeat with currenttab in i\nset tabinfo to {name of currenttab as unicode text, URL of currenttab}\ncopy tabinfo to the end of tablist\nend repeat\nend if\nend repeat\nreturn tablist\nend tell')
    if stat then
        chooser_data = hs.fnutils.imap(data, function(item)
            return {text = item[1],subText = item[2]}
        end)
    end
end

function youdaosTranslate()
    local datamuse_baseurl = 'http://fanyi.youdao.com/openapi.do?keyfrom=wufeifei&key=716426270&type=data&doctype=json&version=1.1&q='
    local querystr = string.gsub(search_chooser:query(),'%s+$','')
    if string.len(querystr) > 0 then
        local encoded_query = hs.http.encodeForQuery(querystr)
        local query_url = datamuse_baseurl..encoded_query
        local stat,data = hs.http.get(query_url,nil)
        if stat > 0 then
            local decoded_data = hs.json.decode(data)
            if decoded_data.basic then
                local basictrans = decoded_data.basic.explains
            end
            if decoded_data.web then
                local webtrans = hs.fnutils.imap(decoded_data.web,function(item) return item.key..' '..table.concat(item.value,',') end)
            end
            chooser_data = hs.fnutils.imap(hs.fnutils.concat(basictrans,webtrans), function(item)
                return {text = item}
            end)
        end
    end
end

function youdaoInstantTrans()
     local datamuse_baseurl = 'http://fanyi.youdao.com/openapi.do?keyfrom=wufeifei&key=716426270&type=data&doctype=json&version=1.1&q='
    local querystr = string.gsub(search_chooser:query(),'%s+$','')
    if string.len(querystr) > 0 then
         local encoded_query = hs.http.encodeForQuery(querystr)
         local query_url = datamuse_baseurl..encoded_query

        hs.http.asyncGet(query_url,nil,function(status,data)
            if status < 0 then
                return
            else
                 local decoded_data = hs.json.decode(data)
                if decoded_data.basic then
                    basictrans = decoded_data.basic.explains
                end
                if decoded_data.web then
                     webtrans = hs.fnutils.imap(decoded_data.web,function(item) return item.key..' '..table.concat(item.value,',') end)
                end
                chooser_data = hs.fnutils.imap(hs.fnutils.concat(basictrans,webtrans), function(item)
                    return {text = item}
                end)
            end
        end)
    else
       chooser_data={}
       return chooser_data
    end
end

function datamuseSuggest()
    local datamuse_baseurl = 'https://api.datamuse.com'
    if string.len(search_chooser:query()) > 0 then
        local querystr = string.gsub(search_chooser:query(),'%s+$','')
        local encoded_query = hs.http.encodeForQuery(querystr)
        local query_url = datamuse_baseurl..'/sug?s='..encoded_query..'&max=5'

        hs.http.asyncGet(query_url,nil,function(stat,data)
            if stat < 0 then
                return
            else
                local decoded_data = hs.json.decode(data)
                local suggest_data = hs.fnutils.imap(decoded_data, function(item)
                    return item.word
                end)
                suggeststr = table.concat(suggest_data,' ')
            end
        end)
    end
end

function drawSuggest()
    if not suggestframe then
        local chooserwin = hs.window'Chooser'
        local chooserframe = chooserwin:frame()
        local framerect = hs.geometry.rect(chooserframe.x,chooserframe.y-50,chooserframe.w,50)
        suggestframe = hs.drawing.rectangle(framerect)
        local framebgcolor = {red=235/255,green=235/255,blue=235/255,alpha=0.90}
        suggestframe:setFillColor(framebgcolor)
        -- suggestframe:setFillGradient(framebgcolor,sugtextcolor,270)
        suggestframe:setStroke(false)
        local textrect = hs.geometry.rect(chooserframe.x+5,chooserframe.y-45,chooserframe.w,40)
        suggesttext = hs.drawing.text(textrect,'')
        -- suggesttext:setTextSize(20)
        local sugtextcolor = {red=181/255,green=181/255,blue=181/255}
        suggesttext:setTextColor(sugtextcolor)
    elseif  suggeststr == "" or string.len(search_chooser:query()) == 0 then
        suggestframe:hide()
        suggesttext:hide()
    else
        suggestframe:show()
        suggesttext:show()
    end
    if suggesttext then
        datamuseSuggest()
        suggesttext:setText(suggeststr)
    end
end

function thesaurusRequest()
    local datamuse_baseurl = 'https://api.datamuse.com'
    local querystr = string.gsub(search_chooser:query(),'%s+$','')
    if string.len(querystr) > 0 then
        local encoded_query = hs.http.encodeForQuery(querystr)
        local query_url = datamuse_baseurl..'/words?ml='..encoded_query..'&max=20'

        local stat, data = hs.http.get(query_url,nil)
        if stat > 0 then
            local decoded_data = hs.json.decode(data)
            chooser_data = hs.fnutils.imap(decoded_data, function(item)
                return {text = item.word}
            end)
        else
            chooser_data={}
            return chooser_data
        end
    end
end

function launchChooser()
    chooser_data = {}
    suggeststr = ''
    currentsource = 1
    choosersourcetable = {}
    swither = nil
    meanlike = nil
    search_chooser = hs.chooser.new(function(chosen)
        if suggestframe then suggestframe:hide() end
        if suggesttext then suggesttext:hide() end
        if meanlike then meanlike:delete() end
        if swither then swither:delete() end
        if outputtype == "safari" then
            local defaultbrowser = hs.urlevent.getDefaultHandler('http')
            hs.urlevent.openURLWithBundle(chosen.subText,defaultbrowser)
        elseif outputtype == "pasteboard" then
            hs.pasteboard.setContents(chosen.text)
        end
    end)
    search_chooser:queryChangedCallback(function()
       if usesuggest == true then drawSuggest() end
       youdaoInstantTrans()
       search_chooser:choices(chooser_data)
    end)
    outputtype = 'pasteboard'
    search_chooser:rows(9)
    search_chooser:searchSubText(true)
    search_chooser:show()

    function dictSource()
        search_chooser:queryChangedCallback(function()
           if usesuggest == true then drawSuggest() end
           youdaoInstantTrans()
           search_chooser:choices(chooser_data)
        end)
        outputtype = 'other'
    end

    function safariSource()
        safariTabinfoRequest()
        search_chooser:choices(chooser_data)
        search_chooser:queryChangedCallback()
        outputtype = 'safari'
    end

    table.insert(choosersourcetable,dictSource)
    table.insert(choosersourcetable,safariSource)

    function switchSource()
        currentsource = currentsource + 1
        if currentsource > #choosersourcetable then
            currentsource = 1
        end
        search_chooser:choices(function() chooser_data={} return chooser_data end)
        search_chooser:query('')
        if suggesttext then suggesttext:setText('') end
        choosersourcetable[currentsource]()
    end

    swither = hs.hotkey.bind('ctrl','tab',function() switchSource() end)

    meanlike = hs.hotkey.bind('ctrl','d',function()
        thesaurusRequest()
        search_chooser:choices(chooser_data)
        search_chooser:refreshChoicesCallback()
        outputtype = 'pasteboard'
    end)

    -- youdao = hs.hotkey.bind('ctrl','y',function()
        -- search_chooser:queryChangedCallback()
        -- youdaosTranslate()
        -- search_chooser:choices(chooser_data)
        -- outputtype = 'pasteboard'
    -- end)

end
