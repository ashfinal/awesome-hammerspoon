hsearch_loaded = true
if youdaokeyfrom == nil then youdaokeyfrom = 'hsearch' end
if youdaoapikey == nil then youdaoapikey = '1199732752' end
chooserSourceTable = {}
chooserSourceOverview = {}

function switchSource()
    function isInKeywords(value, tbl)
        for i=1,#tbl do
            if tbl[i].kw == value then
                sourcetable_index = i
                return true
            end
        end
        return false
    end
    local querystr = search_chooser:query()
    if string.len(querystr) > 0 then
        local matchstr = string.match(querystr,"^%w+")
        if matchstr == querystr then
            if isInKeywords(querystr, chooserSourceTable) then
                search_chooser:query('')
                chooser_data = {}
                search_chooser:choices(chooser_data)
                search_chooser:queryChangedCallback()
                chooserSourceTable[sourcetable_index].func()
            else
                chooser_data = {}
                local source_desc = {text="No source found!", subText="Maybe misspelled the keyword?"}
                table.insert(chooser_data, 1, source_desc)
                local more_tips = {text="Want to add your own source?", subText="Feel free to read the code and open PRs. :)"}
                table.insert(chooser_data, 2, more_tips)
                search_chooser:choices(chooser_data)
                search_chooser:queryChangedCallback()
                outputtype = "other"
            end
        else
            chooser_data = {}
            local source_desc = {text="Invalid Keyword", subText="Trigger keyword must only consist of alphanumeric characters."}
            table.insert(chooser_data, 1, source_desc)
            search_chooser:choices(chooser_data)
            search_chooser:queryChangedCallback()
            outputtype = "other"
        end
    else
        chooser_data = chooserSourceOverview
        search_chooser:choices(chooser_data)
        search_chooser:queryChangedCallback()
        outputtype = "other"
    end
end

function launchChooser()
    chooser_data = {}
    if sourcetrigger == nil then
        sourcetrigger = hs.hotkey.bind("","tab",nil,switchSource)
    else
        sourcetrigger:enable()
    end
    if search_chooser == nil then
        search_chooser = hs.chooser.new(function(chosen)
            sourcetrigger:disable()
            if chosen ~= nil then
                if outputtype == "safari" then
                    hs.urlevent.openURLWithBundle(chosen.subText,"com.apple.Safari")
                elseif outputtype == "pasteboard" then
                    hs.pasteboard.setContents(chosen.text)
                elseif outputtype == "keystroke" then
                    hs.eventtap.keyStrokes(chosen.text)
                end
            end
        end)
    end
    search_chooser:query('')
    search_chooser:queryChangedCallback()
    chooser_data = chooserSourceOverview
    search_chooser:choices(chooser_data)
    search_chooser:rows(9)
    outputtype = 'other'
    search_chooser:show()
end

function safariTabsRequest()
    local stat, data= hs.osascript.applescript('tell application "Safari"\nset winlist to tabs of windows\nset tablist to {}\nrepeat with i in winlist\nif (count of i) > 0 then\nrepeat with currenttab in i\nset tabinfo to {name of currenttab as unicode text, URL of currenttab}\ncopy tabinfo to the end of tablist\nend repeat\nend if\nend repeat\nreturn tablist\nend tell')
    if stat then
        chooser_data = hs.fnutils.imap(data, function(item)
            return {text = item[1],subText = item[2]}
        end)
    end
end

function safariSource()
    local safarisource_overview = {text="Type sa<tab> to search Safari Tabs."}
    table.insert(chooserSourceOverview,safarisource_overview)
    function safariFunc()
        safariTabsRequest()
        local source_desc = {text="Safari Tabs Search", subText="Search and select one item below to open in Safari."}
        table.insert(chooser_data, 1, source_desc)
        search_chooser:choices(chooser_data)
        search_chooser:searchSubText(true)
        outputtype = 'safari'
    end
    local sourcepkg = {}
    sourcepkg.kw = "sa"
    sourcepkg.func = safariFunc
    table.insert(chooserSourceTable,sourcepkg)
end

safariSource()

function youdaoInstantTrans(querystr)
    youdao_baseurl = 'http://fanyi.youdao.com/openapi.do?keyfrom='..youdaokeyfrom..'&key='..youdaoapikey..'&type=data&doctype=json&version=1.1&q='
    if string.len(querystr) > 0 then
        local encoded_query = hs.http.encodeForQuery(querystr)
        local query_url = youdao_baseurl..encoded_query

        hs.http.asyncGet(query_url,nil,function(status,data)
            if status == 200 then
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
                            search_chooser:choices(chooser_data)
                            search_chooser:refreshChoicesCallback()
                        end
                    end
                end
            end
        end)
    else
        chooser_data = {}
        local source_desc = {text="Youdao Dictionary", subText="Type something to get it translated …"}
        table.insert(chooser_data, 1, source_desc)
        search_chooser:choices(chooser_data)
    end
end

function youdaoSource()
    local youdaosource_overview = {text="Type yd<tab> to use Yaodao Dictionary."}
    table.insert(chooserSourceOverview,youdaosource_overview)
    function youdaoFunc()
        local source_desc = {text="Youdao Dictionary", subText="Type something to get it translated …"}
        table.insert(chooser_data, 1, source_desc)
        search_chooser:choices(chooser_data)
        search_chooser:queryChangedCallback(youdaoInstantTrans)
        outputtype = 'pasteboard'
    end
    local sourcepkg = {}
    sourcepkg.kw = "yd"
    sourcepkg.func = youdaoFunc
    table.insert(chooserSourceTable,sourcepkg)
end

youdaoSource()
