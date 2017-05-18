hsearch_loaded = true
if youdaokeyfrom == nil then youdaokeyfrom = 'hsearch' end
if youdaoapikey == nil then youdaoapikey = '1199732752' end
chooserSourceTable = {}
chooserSourceOverview = {}

function switchSource()
    local function isInKeywords(value, tbl)
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
                local selected_content = search_chooser:selectedRowContents()
                local source_kw = selected_content.sourceKeyword or ""
                if isInKeywords(source_kw, chooserSourceTable) then
                    search_chooser:query('')
                    chooser_data = {}
                    search_chooser:choices(chooser_data)
                    search_chooser:queryChangedCallback()
                    chooserSourceTable[sourcetable_index].func()
                else
                    sourcetable_index = nil
                    chooser_data = {}
                    local source_desc = {text="No source found!", subText="Maybe misspelled the keyword?"}
                    table.insert(chooser_data, 1, source_desc)
                    local more_tips = {text="Want to add your own source?", subText="Feel free to read the code and open PRs. :)"}
                    table.insert(chooser_data, 2, more_tips)
                    search_chooser:choices(chooser_data)
                    search_chooser:queryChangedCallback()
                    hs.eventtap.keyStroke({"cmd"}, "a")
                end
            end
        else
            sourcetable_index = nil
            chooser_data = {}
            local source_desc = {text="Invalid Keyword", subText="Trigger keyword must only consist of alphanumeric characters."}
            table.insert(chooser_data, 1, source_desc)
            search_chooser:choices(chooser_data)
            search_chooser:queryChangedCallback()
            hs.eventtap.keyStroke({"cmd"}, "a")
        end
    else
        local selected_content = search_chooser:selectedRowContents()
        local source_kw = selected_content.sourceKeyword or ""
        if isInKeywords(source_kw, chooserSourceTable) then
            search_chooser:query('')
            chooser_data = {}
            search_chooser:choices(chooser_data)
            search_chooser:queryChangedCallback()
            chooserSourceTable[sourcetable_index].func()
        else
            sourcetable_index = nil
            chooser_data = chooserSourceOverview
            search_chooser:choices(chooser_data)
            search_chooser:queryChangedCallback()
        end
    end
    if hs_emoji_data then hs_emoji_data:close() hs_emoji_data = nil end
    if sourcetable_index == nil then
        if justnotetrigger then justnotetrigger:disable() end
    else
        if chooserSourceTable[sourcetable_index].kw ~= "n" then
            if justnotetrigger then justnotetrigger:disable() end
        end
    end
end

function launchChooser()
    if sourcetrigger == nil then
        sourcetrigger = hs.hotkey.bind("","tab",nil,switchSource)
    else
        sourcetrigger:enable()
    end
    if chooserSourceTable[sourcetable_index] then
        if chooserSourceTable[sourcetable_index].kw == "n" then
            if justnotetrigger then justnotetrigger:enable() end
        end
    end
    if search_chooser == nil then
        chooser_data = {}
        search_chooser = hs.chooser.new(function(chosen)
            sourcetrigger:disable()
            if justnotetrigger then justnotetrigger:disable() end
            if chosen ~= nil then
                if chosen.outputType == "safari" then
                    hs.urlevent.openURLWithBundle(chosen.url,"com.apple.Safari")
                elseif chosen.outputType == "chrome" then
                    hs.urlevent.openURLWithBundle(chosen.url,"com.google.Chrome")
                elseif chosen.outputType == "firefox" then
                    hs.urlevent.openURLWithBundle(chosen.url,"org.mozilla.firefox")
                elseif chosen.outputType == "browser" then
                    local defaultbrowser = hs.urlevent.getDefaultHandler('http')
                    hs.urlevent.openURLWithBundle(chosen.url,defaultbrowser)
                elseif chosen.outputType == "clipboard" then
                    hs.pasteboard.setContents(chosen.clipText)
                elseif chosen.outputType == "keystrokes" then
                    hs.window.orderedWindows()[1]:focus()
                    hs.eventtap.keyStrokes(chosen.typingText)
                elseif chosen.outputType == "taskkill" then
                    os.execute("kill -9 "..chosen.pid)
                elseif chosen.outputType == "menuclick" then
                    hs_belongto_app:activate()
                    hs_belongto_app:selectMenuItem(chosen.menuitem)
                elseif chosen.outputType == "noteremove" then
                    justnotetrigger:disable()
                    for idx,val in pairs(hs_justnote_history) do
                        if val.uuid == chosen.uuid then
                            table.remove(hs_justnote_history,idx)
                            hs.settings.set("just.another.note", hs_justnote_history)
                        end
                    end
                    justNoteRequest()
                    search_chooser:choices(chooser_data)
                end
            end
        end)
        search_chooser:query('')
        search_chooser:queryChangedCallback()
        chooser_data = chooserSourceOverview
        search_chooser:choices(chooser_data)
        search_chooser:rows(9)
    end
    search_chooser:show()
end

function browserTabsRequest()
    local safari_running = hs.application'com.apple.Safari'
    if safari_running then
        local stat, data= hs.osascript.applescript('tell application "Safari"\nset winlist to tabs of windows\nset tablist to {}\nrepeat with i in winlist\nif (count of i) > 0 then\nrepeat with currenttab in i\nset tabinfo to {name of currenttab as unicode text, URL of currenttab}\ncopy tabinfo to the end of tablist\nend repeat\nend if\nend repeat\nreturn tablist\nend tell')
        if stat then
            chooser_data = hs.fnutils.imap(data, function(item)
                return {text=item[1], subText=item[2], image=hs.image.imageFromPath("./resources/safari.png"), outputType="safari", url=item[2]}
            end)
        end
    end
    local chrome_running = hs.application'com.google.Chrome'
    if chrome_running then
        local stat, data= hs.osascript.applescript('tell application "Google Chrome"\nset winlist to tabs of windows\nset tablist to {}\nrepeat with i in winlist\nif (count of i) > 0 then\nrepeat with currenttab in i\nset tabinfo to {name of currenttab as unicode text, URL of currenttab}\ncopy tabinfo to the end of tablist\nend repeat\nend if\nend repeat\nreturn tablist\nend tell')
        if stat then
            for idx,val in pairs(data) do
                table.insert(chooser_data, {text=val[1], subText=val[2], image=hs.image.imageFromPath("/Applications/Google Chrome.app/Contents/Resources/document.icns"), outputType="chrome", url=val[2]})
            end
        end
    end
end

function browserSource()
    local browsersource_overview = {text="Type t ⇥ to search safari/chrome Tabs.", image=hs.image.imageFromPath("./resources/tabs.png"), sourceKeyword="t"}
    table.insert(chooserSourceOverview,browsersource_overview)
    function browserFunc()
        local source_desc = {text="Requesting data, please wait a while …"}
        table.insert(chooser_data, 1, source_desc)
        search_chooser:choices(chooser_data)
        browserTabsRequest()
        local source_desc = {text="Browser Tabs Search", subText="Search and select one item to open in corresponding browser.", image=hs.image.imageFromPath("./resources/tabs.png")}
        table.insert(chooser_data, 1, source_desc)
        search_chooser:choices(chooser_data)
        search_chooser:queryChangedCallback()
        search_chooser:searchSubText(true)
    end
    local sourcepkg = {}
    sourcepkg.kw = "t"
    sourcepkg.func = browserFunc
    table.insert(chooserSourceTable,sourcepkg)
end

browserSource()

function youdaoInstantTrans(querystr)
    local youdao_baseurl = 'http://fanyi.youdao.com/openapi.do?keyfrom='..youdaokeyfrom..'&key='..youdaoapikey..'&type=data&doctype=json&version=1.1&q='
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
                                return {text=item, image=hs.image.imageFromPath("./resources/youdao.png"), outputType="clipboard", clipText=item}
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
        local source_desc = {text="Youdao Dictionary", subText="Type something to get it translated …", image=hs.image.imageFromPath("./resources/youdao.png")}
        table.insert(chooser_data, 1, source_desc)
        search_chooser:choices(chooser_data)
    end
end

function youdaoSource()
    local youdaosource_overview = {text="Type y ⇥ to use Yaodao dictionary.", image=hs.image.imageFromPath("./resources/youdao.png"), sourceKeyword="y"}
    table.insert(chooserSourceOverview,youdaosource_overview)
    function youdaoFunc()
        local source_desc = {text="Youdao Dictionary", subText="Type something to get it translated …", image=hs.image.imageFromPath("./resources/youdao.png")}
        table.insert(chooser_data, 1, source_desc)
        search_chooser:choices(chooser_data)
        search_chooser:queryChangedCallback(youdaoInstantTrans)
    end
    local sourcepkg = {}
    sourcepkg.kw = "y"
    sourcepkg.func = youdaoFunc
    table.insert(chooserSourceTable,sourcepkg)
end

youdaoSource()

--------------------------------------------------------------------------------
-- Add a new source - kill processes
-- First request processes info and store them into $chooser_data$

local function splitByLine(str)
    local tailtrimmedstr = string.gsub(str,"%s+$","")
    local tmptbl = {}
    for w in string.gmatch(tailtrimmedstr,"[^\n]+") do table.insert(tmptbl,w) end
    if #tmptbl == 1 then
        local trimmedstr = string.gsub(tmptbl[1],"%s","")
        return trimmedstr
    else
        local tmptbl2 = {}
        for _,val in pairs(tmptbl) do
            local trimmedstr = string.gsub(val,"%s","")
            table.insert(tmptbl2,trimmedstr)
        end
        return tmptbl2
    end
end

function appsInfoRequest()
    local taskname_tbl = splitByLine(hs.execute("ps -ero ucomm"))
    local pid_tbl = splitByLine(hs.execute("ps -ero pid"))
    local comm_tbl = splitByLine(hs.execute("ps -ero command"))
    for i=2,#taskname_tbl do
        local taskname = taskname_tbl[i]
        local pid = tonumber(pid_tbl[i])
        local comm = comm_tbl[i]
        local appbundle = hs.application.applicationForPID(pid)
        local function getBundleID()
            if appbundle then
                return appbundle:bundleID()
            end
        end
        local bundleid = getBundleID() or "nil"
        local function getAppImage()
            if bundleid ~= "nil" then
                return hs.image.imageFromAppBundle(bundleid)
            else
                return hs.image.iconForFileType("public.unix-executable")
            end
        end
        local appimage = getAppImage()
        local appinfoitem = {text=taskname.."#"..pid.."  "..bundleid, subText=comm, image=appimage, outputType="taskkill", pid=pid}
        table.insert(chooser_data,appinfoitem)
    end
end

-- Then we wrap the worker into appkillSource

function appKillSource()
    -- Give some tips for this source
    local appkillsource_overview = {text="Type k ⇥ to Kill running process.", image=hs.image.imageFromPath("./resources/taskkill.png"), sourceKeyword="k"}
    table.insert(chooserSourceOverview,appkillsource_overview)
    -- Run the function below when triggered.
    function appkillFunc()
        -- Request appsinfo
        appsInfoRequest()
        -- More tips
        local source_desc = {text="Kill Processes", subText="Search and select some items to get them killed.", image=hs.image.imageFromPath("./resources/taskkill.png")}
        table.insert(chooser_data, 1, source_desc)
        -- Make $chooser_data$ appear in search_chooser
        search_chooser:choices(chooser_data)
        -- Run some code or do nothing while querystring changed
        search_chooser:queryChangedCallback()
        -- Do something when select one item in search_chooser
    end
    local sourcepkg = {}
    -- Give this source a trigger keyword
    sourcepkg.kw = "k"
    sourcepkg.func = appkillFunc
    -- Add this source to SourceTable
    table.insert(chooserSourceTable,sourcepkg)
end

-- Run the function once, so search_chooser can actually see the new source
appKillSource()

-- New source - kill processes End here
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- New source - Datamuse thesaurus

function thesaurusRequest(querystr)
    local datamuse_baseurl = 'http://api.datamuse.com'
    if string.len(querystr) > 0 then
        local encoded_query = hs.http.encodeForQuery(querystr)
        local query_url = datamuse_baseurl..'/words?ml='..encoded_query..'&max=20'

        hs.http.asyncGet(query_url,nil,function(status,data)
            if status == 200 then
                if pcall(function() hs.json.decode(data) end) then
                    local decoded_data = hs.json.decode(data)
                    if #decoded_data > 0 then
                        chooser_data = hs.fnutils.imap(decoded_data, function(item)
                            return {text = item.word, image=hs.image.imageFromPath("./resources/thesaurus.png"), outputType="keystrokes", typingText=item.word}
                        end)
                        search_chooser:choices(chooser_data)
                        search_chooser:refreshChoicesCallback()
                    end
                end
            end
        end)
    else
        chooser_data = {}
        local source_desc = {text="Datamuse Thesaurus", subText="Type something to get more words like it …", image=hs.image.imageFromPath("./resources/thesaurus.png")}
        table.insert(chooser_data, 1, source_desc)
        search_chooser:choices(chooser_data)
    end
end

function thesaurusSource()
  local thesaurus_overview = {text="Type s ⇥ to request English Thesaurus.", image=hs.image.imageFromPath("./resources/thesaurus.png"), sourceKeyword="s"}
    table.insert(chooserSourceOverview,thesaurus_overview)
    function thesaurusFunc()
      local source_desc = {text="Datamuse Thesaurus", subText="Type something to get more words like it …", image=hs.image.imageFromPath("./resources/thesaurus.png")}
        table.insert(chooser_data, 1, source_desc)
        search_chooser:choices(chooser_data)
        search_chooser:queryChangedCallback(thesaurusRequest)
    end
    local sourcepkg = {}
    sourcepkg.kw = "s"
    sourcepkg.func = thesaurusFunc
    -- Add this source to SourceTable
    table.insert(chooserSourceTable,sourcepkg)
end

thesaurusSource()

-- New source - Datamuse Thesaurus End here
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- New source - Menuitems Search

function table.clone(org)
    return {table.unpack(org)}
end

function getMenuChain(t)
    for pos,val in pairs(t) do
        if type(val) == "table" then
            if type(val.AXChildren) == "table" then
                hs_currentlevel = hs_currentlevel + 1
                hs_currententry[hs_currentlevel] = val.AXTitle
                getMenuChain(val.AXChildren[1])
                hs_currentlevel = hs_currentlevel - 1
                for i=hs_currentlevel+1,#hs_currententry do
                    table.remove(hs_currententry,i)
                end
            elseif val.AXRole == "AXMenuItem" and not val.AXChildren then
                if val.AXTitle ~= "" then
                    local upperlevel = table.clone(hs_currententry)
                    table.insert(upperlevel,val.AXTitle)
                    table.insert(hs_menuchain,upperlevel)
                end
            end
        end
    end
end

function MenuitemsRequest()
    local frontmost_win = hs.window.orderedWindows()[1]
    hs_belongto_app = frontmost_win:application()
    local all_menuitems = hs_belongto_app:getMenuItems()
    hs_menuchain = {}
    hs_currententry = {}
    hs_currentlevel = 0
    getMenuChain(all_menuitems)
    for idx,val in pairs(hs_menuchain) do
      local menuitem = {text=val[#val], subText=table.concat(val," | "), image=hs.image.imageFromAppBundle(hs_belongto_app:bundleID()), outputType="menuclick", menuitem=val}
        table.insert(chooser_data,menuitem)
    end
end

function MenuitemsSource()
    local menuitems_overview = {text="Type m ⇥ to search Menuitems.", image=hs.image.imageFromPath("./resources/menus.png"), sourceKeyword="m"}
    table.insert(chooserSourceOverview,menuitems_overview)
    function menuitemsFunc()
        MenuitemsRequest()
        local source_desc = {text="Menuitems Search", subText="Search and select some menuitem to get it clicked.", image=hs.image.imageFromPath("./resources/menus.png")}
        table.insert(chooser_data, 1, source_desc)
        search_chooser:choices(chooser_data)
        search_chooser:queryChangedCallback()
        search_chooser:searchSubText(true)
    end
    local sourcepkg = {}
    sourcepkg.kw = "m"
    sourcepkg.func = menuitemsFunc
    -- Add this source to SourceTable
    table.insert(chooserSourceTable,sourcepkg)
end

MenuitemsSource()

-- New source - Menuitems Search End here
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- New source - v2ex Posts

function v2exRequest()
    local query_url = 'https://www.v2ex.com/api/topics/latest.json'
    local stat, body = hs.http.asyncGet(query_url,nil,function(status,data)
        if status == 200 then
            if pcall(function() hs.json.decode(data) end) then
                local decoded_data = hs.json.decode(data)
                if #decoded_data > 0 then
                    chooser_data = hs.fnutils.imap(decoded_data, function(item)
                        local sub_content = string.gsub(item.content,"\r\n"," ")
                        local function trim_content()
                            if utf8.len(sub_content) > 40 then
                                return string.sub(sub_content,1,utf8.offset(sub_content,40)-1)
                            else
                                return sub_content
                            end
                        end
                        local final_content = trim_content()
                        return {text=item.title, subText=final_content, image=hs.image.imageFromPath("./resources/v2ex.png"), outputType="browser", url=item.url}
                    end)
                    local source_desc = {text="v2ex Posts", subText="Select some item to get it opened in default browser …", image=hs.image.imageFromPath("./resources/v2ex.png")}
                    table.insert(chooser_data, 1, source_desc)
                    search_chooser:choices(chooser_data)
                    search_chooser:refreshChoicesCallback()
                end
            end
        end
    end)
end

function v2exSource()
    local v2ex_overview = {text="Type v ⇥ to fetch v2ex posts.", image=hs.image.imageFromPath("./resources/v2ex.png"), sourceKeyword="v"}
    table.insert(chooserSourceOverview,v2ex_overview)
    function v2exFunc()
        local source_desc = {text="Requesting data, please wait a while …"}
        table.insert(chooser_data, 1, source_desc)
        search_chooser:choices(chooser_data)
        v2exRequest()
        search_chooser:queryChangedCallback()
        search_chooser:searchSubText(true)
    end
    local sourcepkg = {}
    sourcepkg.kw = "v"
    sourcepkg.func = v2exFunc
    table.insert(chooserSourceTable,sourcepkg)
end

v2exSource()

-- New source - v2ex Posts End here
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- New source - Emoji Source

function emojiRequest(querystr)
    local emoji_baseurl = 'https://emoji.getdango.com'
    if string.len(querystr) > 0 then
        local encoded_query = hs.http.encodeForQuery(querystr)
        local query_url = emoji_baseurl..'/api/emoji?q='..encoded_query

        hs.http.asyncGet(query_url,nil,function(status,data)
            if status == 200 then
                if pcall(function() hs.json.decode(data) end) then
                    local decoded_data = hs.json.decode(data)
                    if decoded_data.results and #decoded_data.results > 0 then
                        if not hs_emoji_data then
                            local emoji_database_path = "/System/Library/Input Methods/CharacterPalette.app/Contents/Resources/CharacterDB.sqlite3"
                            hs_emoji_data = hs.sqlite3.open(emoji_database_path)
                        end
                        if hs_emoji_canvas then hs_emoji_canvas:delete() hs_emoji_canvas=nil end
                        local hs_emoji_canvas = hs.canvas.new({x=0,y=0,w=96,h=96})
                        chooser_data = hs.fnutils.imap(decoded_data.results, function(item)
                            hs_emoji_canvas[1] = {type="text",text=item.text,textSize=64,frame={x="15%",y="10%",w="100%",h="100%"}}
                            local hexcode = string.format("%#X",utf8.codepoint(item.text))
                            local function getEmojiDesc()
                                for w in hs_emoji_data:rows("SELECT info FROM unihan_dict WHERE uchr=\'"..item.text.."\'") do
                                    return w[1]
                                end
                            end
                            local emoji_description = getEmojiDesc()
                            local formatted_desc = string.gsub(emoji_description,"|||||||||||||||","")
                            return {text = formatted_desc, image=hs_emoji_canvas:imageFromCanvas(), subText="Hex Code: "..hexcode, outputType="keystrokes", typingText=item.text}
                        end)
                        search_chooser:choices(chooser_data)
                        search_chooser:refreshChoicesCallback()
                    end
                end
            end
        end)
    else
        chooser_data = {}
        local source_desc = {text="Relevant Emoji", subText="Type something to find relevant emoji from text …", image=hs.image.imageFromPath("./resources/emoji.png")}
        table.insert(chooser_data, 1, source_desc)
        search_chooser:choices(chooser_data)
    end
end

function emojiSource()
  local emoji_overview = {text="Type e ⇥ to find relevant Emoji.", image=hs.image.imageFromPath("./resources/emoji.png"), sourceKeyword="e"}
    table.insert(chooserSourceOverview,emoji_overview)
    function emojiFunc()
        local source_desc = {text="Relevant Emoji", subText="Type something to find relevant emoji from text …", image=hs.image.imageFromPath("./resources/emoji.png")}
        table.insert(chooser_data, 1, source_desc)
        search_chooser:choices(chooser_data)
        search_chooser:queryChangedCallback(emojiRequest)
    end
    local sourcepkg = {}
    sourcepkg.kw = "e"
    sourcepkg.func = emojiFunc
    -- Add this source to SourceTable
    table.insert(chooserSourceTable,sourcepkg)
end

emojiSource()

-- New source - Emoji Source End here
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- New source - Time Source

function timeRequest()
    hs_time_commands = {
        '+"%Y-%m-%d"',
        '+"%H:%M:%S %p"',
        '+"%A, %B %d, %Y"',
        '+"%Y-%m-%d %H:%M:%S %p"',
        '+"%a, %b %d, %y"',
        '+"%m/%d/%y %H:%M %p"',
        '',
        '-u',
    }
    chooser_data = hs.fnutils.imap(hs_time_commands, function(item)
        local exec_result = hs.execute("date "..item)
        return {text=exec_result, subText="date "..item, image=hs.image.imageFromPath("./resources/time.png"), outputType="keystrokes", typingText=exec_result}
    end)
end

local function splitBySpace(str)
    local tmptbl = {}
    for w in string.gmatch(str,"[+-]?%d+[ymdwHMS]") do table.insert(tmptbl,w) end
    return tmptbl
end

function timeDeltaRequest(querystr)
    if string.len(querystr) > 0 then
        local valid_inputs = splitBySpace(querystr)
        if #valid_inputs > 0 then
            local addv_before = hs.fnutils.imap(valid_inputs, function(item)
                return "-v"..item
            end)
            local vv_var = table.concat(addv_before," ")
            for idx,val in pairs(hs_time_commands) do
                local new_exec_command = "date "..vv_var.." "..val
                local new_exec_result = hs.execute(new_exec_command)
                chooser_data[idx+1].text = new_exec_result
                chooser_data[idx+1].subText = new_exec_command
                chooser_data[idx+1].typingText = new_exec_result
                search_chooser:choices(chooser_data)
            end
        else
            timeRequest()
            local source_desc = {text="Date Query", subText="Type +/-1d (or y, m, w, H, M, S) to query date forward or backward.", image=hs.image.imageFromPath("./resources/time.png")}
            table.insert(chooser_data, 1, source_desc)
            search_chooser:choices(chooser_data)
        end
    else
        timeRequest()
        local source_desc = {text="Date Query", subText="Type +/-1d (or y, m, w, H, M, S) to query date forward or backward.", image=hs.image.imageFromPath("./resources/time.png")}
        table.insert(chooser_data, 1, source_desc)
        search_chooser:choices(chooser_data)
    end
end

function timeSource()
    local time_overview = {text="Type d ⇥ to format/query Date.", image=hs.image.imageFromPath("./resources/time.png"), sourceKeyword="d"}
    table.insert(chooserSourceOverview,time_overview)
    function timeFunc()
        timeRequest()
        local source_desc = {text="Date Query", subText="Type +/-1d (or y, m, w, H, M, S) to query date forward or backward.", image=hs.image.imageFromPath("./resources/time.png")}
        table.insert(chooser_data, 1, source_desc)
        search_chooser:choices(chooser_data)
        search_chooser:queryChangedCallback(timeDeltaRequest)
    end
    local sourcepkg = {}
    sourcepkg.kw = "d"
    sourcepkg.func = timeFunc
    -- Add this source to SourceTable
    table.insert(chooserSourceTable,sourcepkg)
end

timeSource()

-- New source - Time Source End here
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- New source - Just Note Source

local function isInNoteHistory(value, tbl)
    for idx,val in pairs(tbl) do
        if val.uuid == value then
            return true
        end
    end
    return false
end

function justNoteRequest()
    hs_justnote_history = hs.settings.get("just.another.note") or {}
    if #hs_justnote_history == 0 then
        chooser_data = {{text="Write something and press Enter.", subText="Your notes is automatically saved, selected item will be erased.", image=hs.image.imageFromPath("./resources/justnote.png")}}
    else
        chooser_data = hs.fnutils.imap(hs_justnote_history, function(item)
            return {uuid=item.uuid, text=item.content, subText=item.ctime, image=hs.image.imageFromPath("./resources/justnote.png"), outputType="noteremove"}
        end)
    end
end

function justNoteStore()
    local querystr = string.gsub(search_chooser:query(),"%s+$","")
    if string.len(querystr) > 0 then
        local query_hash = hs.hash.SHA1(querystr)
        if not isInNoteHistory(query_hash, hs_justnote_history) then
            table.insert(hs_justnote_history,{uuid=query_hash, ctime="Created at "..os.date(), content=querystr})
            hs.settings.set("just.another.note",hs_justnote_history)
            justNoteRequest()
            search_chooser:choices(chooser_data)
            search_chooser:query("")
        end
    end
end

function justNoteSource()
    local justnote_overview = {text="Type n ⇥ to Note something.", image=hs.image.imageFromPath("./resources/justnote.png"), sourceKeyword="n"}
    table.insert(chooserSourceOverview,justnote_overview)
    function justnoteFunc()
        justNoteRequest()
        if justnotetrigger == nil then
            justnotetrigger = hs.hotkey.bind("","return",nil,justNoteStore)
        else
            justnotetrigger:enable()
        end
        search_chooser:choices(chooser_data)
        search_chooser:queryChangedCallback()
    end
    local sourcepkg = {}
    sourcepkg.kw = "n"
    sourcepkg.func = justnoteFunc
    -- Add this source to SourceTable
    table.insert(chooserSourceTable,sourcepkg)
end

justNoteSource()

-- New source - Just Note Source End here
--------------------------------------------------------------------------------
