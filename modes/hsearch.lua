hsearch_loaded = true
if youdaokeyfrom == nil then youdaokeyfrom = 'hsearch' end
if youdaoapikey == nil then youdaoapikey = '1199732752' end
if usesuggest == nil then usesuggest = true end

function safariTabinfoRequest()
    local stat, data= hs.osascript.applescript('tell application "Safari"\nset winlist to tabs of windows\nset tablist to {}\nrepeat with i in winlist\nif (count of i) > 0 then\nrepeat with currenttab in i\nset tabinfo to {name of currenttab as unicode text, URL of currenttab}\ncopy tabinfo to the end of tablist\nend repeat\nend if\nend repeat\nreturn tablist\nend tell')
    if stat then
        chooser_data = hs.fnutils.imap(data, function(item)
            return {text = item[1],subText = item[2]}
        end)
    end
end

function youdaoInstantTrans(querystr)
    local youdao_baseurl = 'http://fanyi.youdao.com/openapi.do?keyfrom='..youdaokeyfrom..'&key='..youdaoapikey..'&type=data&doctype=json&version=1.1&q='
    if string.len(querystr) > 0 then
        local encoded_query = hs.http.encodeForQuery(querystr)
        local query_url = youdao_baseurl..encoded_query

        hs.http.asyncGet(query_url,nil,function(status,data)
            if status == 200 then
                youdaostatus = true
                if pcall(function() hs.json.decode(data) end) then
                    local decoded_data = hs.json.decode(data)
                    if decoded_data.errorCode == 0 then
                        if decoded_data.basic then
                            basictrans = decoded_data.basic.explains
                        else
                            basictrans = {}
                        end
                        if decoded_data.web then
                            webtrans = hs.fnutils.imap(decoded_data.web,function(item) return item.key..' '..table.concat(item.value,',') end)
                        else
                            webtrans = {}
                        end
                        dictpool = hs.fnutils.concat(basictrans,webtrans)
                        if #dictpool > 0 then
                            chooser_data = hs.fnutils.imap(dictpool, function(item)
                                return {text = item}
                            end)
                        end
                    end
                end
            else
                youdaostatus = false
            end
        end)
    else
        oldquerystr = ""
        chooser_data = {}
    end
end

function datamuseSuggest(querystr)
    local datamuse_baseurl = 'http://api.datamuse.com'
    if string.len(querystr) > 0 then
        local encoded_query = hs.http.encodeForQuery(querystr)
        local query_url = datamuse_baseurl..'/sug?s='..encoded_query..'&max=5'

        hs.http.asyncGet(query_url,nil,function(stat,data)
            if stat == 200 then
                datamusestatus = true
                if pcall(function() hs.json.decode(data) end) then
                    local decoded_data = hs.json.decode(data)
                    if #decoded_data > 0 then
                        suggest_data = hs.fnutils.imap(decoded_data, function(item)
                            return item.word
                        end)
                        suggeststr = table.concat(suggest_data,' ')
                    end
                end
            else
                datamusestatus = false
            end
        end)
    else
        suggeststr = ""
    end
end

function drawSuggest(querystr)
    if not suggestframe then
        local chooserwin = hs.window'Chooser'
        if chooserwin ~= nil then
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
        end
    else
        if  suggeststr ~= "" and string.len(querystr) ~= 0 then
            suggestframe:show()
            suggesttext:show()
            suggesttext:setText(suggeststr)
        else
            oldquerystr = ""
            suggestframe:hide()
            suggesttext:hide()
        end
    end
end

function thesaurusRequest()
    local datamuse_baseurl = 'http://api.datamuse.com'
    local querystr = string.gsub(search_chooser:query(),'%s+$','')
    if string.len(querystr) > 0 then
        local encoded_query = hs.http.encodeForQuery(querystr)
        local query_url = datamuse_baseurl..'/words?ml='..encoded_query..'&max=20'

        local stat, data = hs.http.get(query_url,nil)
        if stat == 200 then
            if pcall(function() hs.json.decode(data) end) then
                local decoded_data = hs.json.decode(data)
                if #decoded_data > 0 then
                    chooser_data = hs.fnutils.imap(decoded_data, function(item)
                        return {text = item.word}
                    end)
                end
            end
        else
            chooser_data={}
        end
    end
    search_chooser:choices(chooser_data)
end

function launchChooser()
    chooser_data = {}
    suggeststr = ''
    currentsource = 1
    choosersourcetable = {}
    switcher = nil
    meanlike = nil
    search_chooser = hs.chooser.new(function(chosen)
        if suggestframe then suggestframe:hide() end
        if suggesttext then suggesttext:hide() end
        if meanlike then meanlike:delete() end
        if switcher then switcher:delete() end
        if choosertimer then choosertimer:stop() choosertimer=nil end
        if chosen ~= nil then
            if outputtype == "safari" then
                local defaultbrowser = hs.urlevent.getDefaultHandler('http')
                hs.urlevent.openURLWithBundle(chosen.subText,defaultbrowser)
            elseif outputtype == "pasteboard" then
                hs.pasteboard.setContents(chosen.text)
            end
        end
    end)
    function dictSource()
        oldquerystr = ""
        if youdaokeyfrom ~= nil and youdaoapikey ~= nil then
            choosertimer = hs.timer.delayed.new(0.3,function()
                if datamusestatus then
                    drawSuggest(trimmedstr)
                    oldquerystr = trimmedstr
                end
                if youdaostatus then
                    search_chooser:choices(chooser_data)
                    oldquerystr = trimmedstr
                end
            end)
            search_chooser:queryChangedCallback(function(str)
                trimmedstr = string.gsub(str,'%s+$','')
                if trimmedstr ~= oldquerystr then
                    if usesuggest == true then
                        datamuseSuggest(trimmedstr)
                        drawSuggest(trimmedstr)
                    end
                    youdaoInstantTrans(trimmedstr)
                    choosertimer:start()
                end
            end)
            search_chooser:searchSubText(false)
            outputtype = 'other'
        else
            if usesuggest == true then
                choosertimer = hs.timer.delayed.new(0.3,function()
                    if datamusestatus then
                        drawSuggest(trimmedstr)
                        oldquerystr = trimmedstr
                    end
                end)
                search_chooser:queryChangedCallback(function(str)
                    trimmedstr = string.gsub(str,'%s+$','')
                    if trimmedstr ~= oldquerystr then
                        print("oldquerystr="..oldquerystr.."\ntrimmedstr="..trimmedstr)
                            datamuseSuggest(trimmedstr)
                            drawSuggest(trimmedstr)
                        choosertimer:start()
                    end
                end)
            end
            chooser_data = {
                {
                    text = "Please apply for your own youdao API key.",
                    subText = "http://fanyi.youdao.com/openapi?path=data-mode"
                },
            }
            search_chooser:choices(chooser_data)
            outputtype = "safari"
        end
    end
    dictSource()
    search_chooser:rows(9)
    search_chooser:show()

    function safariSource()
        search_chooser:queryChangedCallback()
        safariTabinfoRequest()
        search_chooser:choices(chooser_data)
        search_chooser:searchSubText(true)
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

    switcher = hs.hotkey.bind('ctrl','tab',function() switchSource() end)

    meanlike = hs.hotkey.bind('ctrl','d',function()
        thesaurusRequest()
        search_chooser:refreshChoicesCallback()
        outputtype = 'pasteboard'
    end)
end
