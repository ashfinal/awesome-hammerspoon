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
                    hs.window.orderedWindows()[1]:focus()
                    hs.eventtap.keyStrokes(chosen.text)
                elseif outputtype == "taskkill" then
                    chosen.appID:kill9()
                elseif outputtype == "menuclick" then
                    hs_belongto_app:activate()
                    hs_belongto_app:selectMenuItem(chosen.itemID)
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

--------------------------------------------------------------------------------
-- Add a new source - kill processes
-- First request processes info and store them into $chooser_data$

function appsInfoRequest()
    local appspool = hs.application.runningApplications()
    for i=1,#appspool do
        local appid = appspool[i]
        local apptitle = appspool[i]:title() or "nil"
        local apppid = appspool[i]:pid()
        local appbundle = appspool[i]:bundleID() or "nil"
        local apppath = appspool[i]:path() or "nil"
        local appinfoitem = {text=apptitle.."#"..apppid.."  "..appbundle, subText=apppath, appID=appid}
        table.insert(chooser_data,appinfoitem)
    end
end

-- Then we wrap the worker into appkillSource

function appKillSource()
    -- Give some tips for this source
    local appkillsource_overview = {text="Type kl<tab> to Kill running Process."}
    table.insert(chooserSourceOverview,appkillsource_overview)
    -- Run the function below when triggered.
    function appkillFunc()
        -- Request appsinfo
        appsInfoRequest()
        -- More tips
        local source_desc = {text="Kill Processes", subText="Search and select some items to get them killed."}
        table.insert(chooser_data, 1, source_desc)
        -- Make $chooser_data$ appear in search_chooser
        search_chooser:choices(chooser_data)
        -- Run some code or do nothing while querystring changed
        search_chooser:queryChangedCallback()
        -- Do something when select one item in search_chooser
        outputtype = 'taskkill'
    end
    local sourcepkg = {}
    -- Give this source a trigger keyword
    sourcepkg.kw = "kl"
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
                            return {text = item.word}
                        end)
                        search_chooser:choices(chooser_data)
                        search_chooser:refreshChoicesCallback()
                    end
                end
            end
        end)
    else
        chooser_data = {}
        local source_desc = {text="Datamuse Thesaurus", subText="Type something to get more words like it …"}
        table.insert(chooser_data, 1, source_desc)
        search_chooser:choices(chooser_data)
    end
end

function thesaurusSource()
    local thesaurus_overview = {text="Type th<tab> to use Datamuse Thesaurus."}
    table.insert(chooserSourceOverview,thesaurus_overview)
    function thesaurusFunc()
        local source_desc = {text="Datamuse Thesaurus", subText="Type something to get more words like it …"}
        table.insert(chooser_data, 1, source_desc)
        search_chooser:choices(chooser_data)
        search_chooser:queryChangedCallback(thesaurusRequest)
        outputtype = 'keystroke'
    end
    local sourcepkg = {}
    sourcepkg.kw = "th"
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
            if val.AXRole =="AXMenuBarItem" and type(val.AXChildren) == "table" then
                currententry = {val.AXTitle}
                getMenuChain(val.AXChildren[1])
            elseif val.AXRole == "AXMenuItem" and not val.AXChildren then
                if val.AXTitle ~= "" then
                    local upperlevel = table.clone(currententry)
                    table.insert(upperlevel,val.AXTitle)
                    table.insert(hs_menuchain,upperlevel)
                end
            elseif val.AXRole == "AXMenuItem" and type(val.AXChildren) == "table" then
                table.insert(currententry,val.AXTitle)
                getMenuChain(val.AXChildren[1])
            end
        end
    end
end

function MenuitemsRequest()
    local frontmost_win = hs.window.orderedWindows()[1]
    hs_belongto_app = frontmost_win:application()
    local all_menuitems = hs_belongto_app:getMenuItems()
    hs_menuchain = nil
    hs_menuchain = {}
    getMenuChain(all_menuitems)
    for idx,val in pairs(hs_menuchain) do
        local menuitem = {text=val[#val],subText=table.concat(val," | "),itemID=val}
        table.insert(chooser_data,menuitem)
    end
end

function MenuitemsSource()
    local menuitems_overview = {text="Type me<tab> to Search/Click the Menuitems."}
    table.insert(chooserSourceOverview,menuitems_overview)
    function menuitemsFunc()
        MenuitemsRequest()
        local source_desc = {text="Menuitems Search", subText="Search and select some menuitem to get it clicked."}
        table.insert(chooser_data, 1, source_desc)
        search_chooser:choices(chooser_data)
        search_chooser:queryChangedCallback()
        search_chooser:searchSubText(true)
        outputtype = 'menuclick'
    end
    local sourcepkg = {}
    sourcepkg.kw = "me"
    sourcepkg.func = menuitemsFunc
    -- Add this source to SourceTable
    table.insert(chooserSourceTable,sourcepkg)
end

MenuitemsSource()

-- New source - Menuitems Search End here
--------------------------------------------------------------------------------
