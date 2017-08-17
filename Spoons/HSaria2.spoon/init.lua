--- === HSaria2 ===
---
--- Communicate with [aria2](https://github.com/aria2/aria2), an interactive panel included.
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/HSaria2.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/HSaria2.spoon.zip)

local obj={}
obj.__index = obj

-- Metadata
obj.name = "HSaria2"
obj.version = "1.0"
obj.author = "ashfinal <ashfinal@gmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- HSaria2.max_items
--- Variable
--- How many items should be created on aria2 panel? Defaults to 5.
obj.max_items = 5

--- HSaria2.refresh_interval
--- Variable
--- How often should HSaria2 retrieve data from RPC server? Defaults to 1 (second).
obj.refresh_interval = 1

--- HSaria2:connectToHost(hostaddr, secret)
--- Method
--- Try connect to `hostaddr` with `secret`. If succeed, they will become default values for following-up oprations.
---
--- Parameters:
---  * hostaddr - A sring specifying aria2 RPC host, including host name and port address. e.g. "http://localhost:6800/jsonrpc".
---  * secret - A string specifying host secret
function obj:connectToHost(hostaddr, secret)
    local jsonreq = {
        id = hs.hash.SHA1(os.time()),
        jsonrpc = "2.0",
        method = "aria2.getVersion",
        params = { "token:" .. secret }
    }
    hs.http.asyncPost(hostaddr, hs.json.encode(jsonreq), nil, function(status, data)
        if status == 200 then
            obj.rpc_host = hostaddr
            obj.rpc_secret = secret
            print("-- HSaria2: RPC connection succeed!")
            if obj.timer then
                obj.timer:setNextTrigger(obj.refresh_interval)
            else
                obj.timer = hs.timer.doEvery(obj.refresh_interval, function() obj:intervalRequest() end)
            end
        else
            print("-- HSaria2: Invalid RPC host!")
        end
    end)
end

local function processPath(files)
    if files[1].path == "" then
        return files[1].uris[1].uri
    else
        local filepath = files[1].path
        local tmptbl = {}
        for w in string.gmatch(filepath,"[^/]+") do table.insert(tmptbl,w) end
        return tmptbl[#tmptbl]
    end
end

local function processData(ptype, pnumber, status)
    local function formatNumber(fnumber)
        if fnumber/1024 < 1024 then
            return string.format("%.2f",fnumber/1024) .. ' KB'
        elseif fnumber/1024/1024 < 1024 then
            return string.format("%.2f",fnumber/1024/1024) .. ' MB'
        elseif fnumber/1024/1024/1024 < 1024 then
            return string.format("%.2f",fnumber/1024/1024/1024) .. ' GB'
        end
    end
    if status == "paused" then pnumber = 0 end
    local formatted_data = formatNumber(pnumber)
    if ptype == "data" then
        return formatted_data
    elseif ptype == "speed" then
        return formatted_data .. "/s"
    end
end

local function processDownloadProgress(completed, total)
    if total == "0" then
        return string.format("%.4f", 0)
    else
        return string.format("%.4f", completed/total)
    end
end

local function processRemainTime(completed, total, speed, status)
    local function formatTime(secnum)
        local hourcount = math.modf(secnum/3600)
        local mincount = math.modf(math.fmod(secnum, 3600)/60)
        local seccount = math.fmod(secnum, 60)
        return string.format("%02d", hourcount) .. ":" .. string.format("%02d", mincount) .. ":" .. string.format("%02d", seccount)
    end
    if speed == "0" or status == "paused" then
        return "--:--:--"
    else
        local presecs = string.format("%.0f", (total-completed)/speed)
        return formatTime(presecs)
    end
end

function obj:createAndRefreshPanel()
    if obj.rpc_host and obj.rpc_secret then
        local tasks_overview_req = {
            {
                id = hs.hash.SHA1(os.time()),
                jsonrpc = "2.0",
                method = "aria2.tellActive",
                params = { "token:" .. obj.rpc_secret }
            },
            {
                id = hs.hash.SHA1(os.time()),
                jsonrpc = "2.0",
                method = "aria2.tellWaiting",
                params = { "token:" .. obj.rpc_secret, 0, 5 }
            },
            {
                id = hs.hash.SHA1(os.time()),
                jsonrpc = "2.0",
                method = "aria2.tellStopped",
                params = { "token:" .. obj.rpc_secret, 0, 5 }
            },
        }
        hs.http.asyncPost(obj.rpc_host, hs.json.encode(tasks_overview_req), nil, function(status,data)
            if status == 200 then
                obj:drawToolbar()
                local decoded_data = hs.json.decode(data)
                obj.panelItems = nil
                obj.panelItems = {}
                obj.itemcount = 0
                obj.activeitemcount = 0
                for idx,val in ipairs(decoded_data) do
                    if type(val.result) == "table" then
                        for _,k in ipairs(val.result) do
                            if obj.itemcount >= obj.max_items then break end
                            local file_path = processPath(k.files)
                            local file_size = processData("data", k.totalLength)
                            local download_speed = processData("speed", k.downloadSpeed)
                            local download_progress = processDownloadProgress(k.completedLength, k.totalLength)
                            local progress_percent = tostring(download_progress*100) .. "%"
                            local connection_number = k.connections
                            local remain_time = processRemainTime(k.completedLength, k.totalLength, k.downloadSpeed, k.status)
                            -- Create task items
                            local aria2_taskitem = hs.canvas.new({x=0, y=0, w=400, h=50})
                            aria2_taskitem._default.textSize = 12
                            aria2_taskitem._default.textColor = {hex="#000000"}
                            aria2_taskitem._default.trackMouseDown = true
                            if k.status == "active" then
                                aria2_taskitem[1] = {type="rectangle", id="background", fillColor={hex="#26C83F", alpha=0.1}}
                            elseif k.status == "paused" then
                                aria2_taskitem[1] = {type="rectangle", id="background", fillColor={hex="#FFBB2D", alpha=0.1}}
                            elseif k.status == "complete" then
                                aria2_taskitem[1] = {type="rectangle", id="background", fillColor={hex="#000000", alpha=0.1}}
                            elseif k.status == "error" or k.status == "removed" then
                                aria2_taskitem[1] = {type="rectangle", id="background", fillColor={hex="#FE534C", alpha=0.1}}
                            end
                            aria2_taskitem[2] = {type="text", id="filepath", text=file_path, frame={x="2%", y="10%", w="60%", h="45%"}, textAlignment="left", textLineBreak="truncateMiddle"}
                            aria2_taskitem[3] = {type="text", id="filesize", text=file_size, frame={x="64%", y="10%", w="15%", h="45%"}, textAlignment="right"}
                            aria2_taskitem[4] = {type="text", id="speed", text=download_speed, frame={x="83%", y="15%", w="15%", h="45%"}, textSize=10, textAlignment="right"}
                            aria2_taskitem[5] = {action="fill", id="progressbg", type="rectangle", fillColor={hex="#F6F6F6", alpha=0.3}, frame={x="2%", y="55%", w="60%", h="25%"}}
                            aria2_taskitem[6] = {action="fill", id="progressfg", type="rectangle", fillColor={hex="#1E90FF", alpha=0.7}, frame={x="2%", y="55%", w=tostring(0.6*download_progress), h="25%"}}
                            aria2_taskitem[7] = {type="text", id="dpercent", text=progress_percent, frame={x="2%", y="55%", w="60%", h="45%"}, textSize=10, textAlignment="right"}
                            aria2_taskitem[8] = {type="text", text=connection_number, frame={x="64%", y="55%", w="15%", h="45%"}, textSize=10, textAlignment="center"}
                            aria2_taskitem[9] = {type="text", text=remain_time, frame={x="83%", y="55%", w="15%", h="45%"}, textSize=10, textAlignment="right"}
                            -- Set mouse callback for task items
                            aria2_taskitem:mouseCallback(function(canvas, event, id, x, y)
                                if canvas == aria2_taskitem and event == "mouseDown" then
                                    local modifiers_status = hs.eventtap.checkKeyboardModifiers()
                                    if modifiers_status.cmd == true then
                                        if k.status == "complete" or k.status == "removed" or k.status == "error" then
                                            obj:sendCommand("removeDownloadResult", k.gid)
                                        else
                                            obj:sendCommand("remove", k.gid)
                                        end
                                    else
                                        if k.status == "complete" then
                                            hs.execute("open -g " .. k.files[1].path)
                                        elseif k.status == "active" then
                                            obj:sendCommand("pause", k.gid)
                                        elseif k.status == "paused" then
                                            obj:sendCommand("unpause", k.gid)
                                        end
                                    end
                                end
                            end)
                            -- Store those task info for following-up request
                            table.insert(obj.panelItems, {gid=k.gid, status=k.status, canvas=aria2_taskitem})
                            if k.status == "active" then
                                obj.activeitemcount = obj.activeitemcount + 1
                            end
                            obj.itemcount = obj.itemcount + 1
                        end
                    end
                end
                if obj.panel == nil then
                    -- Create aria2 panel
                    obj.panel = hs.canvas.new({x=0, y=0, w=0, h=0}):show()
                    obj.panel[1] = {type="rectangle", fillColor={hex="#FFFFFF", alpha=0.8}}
                    obj.panel:level(hs.canvas.windowLevels.tornOffMenu)
                    obj.panel:clickActivating(false)
                    obj.panel._default.trackMouseDown = true
                else
                    -- Remove existing elements
                    if obj.panel:isShowing() then
                        for i=2,#obj.panel do
                            obj.panel:removeElement(2)
                        end
                    end
                end
                local cscreen = hs.screen.mainScreen()
                local cres = cscreen:fullFrame()
                obj.panel:frame({x=cres.x+cres.w-400, y=cres.y+cres.h-50*#obj.panelItems-52, w=400, h=50*#obj.panelItems})
                -- Add task items to aria2 panel
                for idx,val in ipairs(obj.panelItems) do
                    obj.panel[idx+1] = {type="canvas", canvas=val.canvas, frame={x="0%", y=tostring(1/#obj.panelItems*(idx-1)), w="100%", h=tostring(1/#obj.panelItems)}}
                end
                -- TODO: Figure out why this is needed
                obj.panel:mouseCallback(function(canvas, event, id, x, y)
                    print(canvas, event, id, x, y)
                end)
            end
            if obj.timer then
                obj.timer:setNextTrigger(obj.refresh_interval)
            else
                obj.timer = hs.timer.doEvery(obj.refresh_interval, function() obj:intervalRequest() end)
            end
        end)
    else
        hs.notify.new({title="aria2 is NOT ready", informativeText="Please check your configuration."}):send()
    end
end

function obj:intervalRequest()
    -- Compose all requests into one, so we don't have to request too frequently from rpc server
    local req_package = {}
    local globalstat_req = {
        id = hs.hash.SHA1(os.time()),
        jsonrpc = "2.0",
        method = "aria2.getGlobalStat",
        params = { "token:" .. obj.rpc_secret }
    }
    table.insert(req_package, globalstat_req)
    if not obj.stopped_queue_cached then obj.stopped_request_required = true end
    if obj.stopped_request_required then
        local stopped_req = {
            id = hs.hash.SHA1(os.time()),
            jsonrpc = "2.0",
            method = "aria2.tellStopped",
            params = { "token:" .. obj.rpc_secret, 0, 100 }
        }
        table.insert(req_package, stopped_req)
        obj.stopped_request_added = true
    else
        obj.stopped_request_added = false
    end
    -- If aria2 panel is showing and there are active download items, then request more details and update the canvas.
    if obj.panel then
        if obj.panel:isShowing() then
            if obj.activeitemcount and obj.activeitemcount > 0 then
                obj.active_request_required = true
            else
                obj.active_request_required = false
            end
        else
            obj.active_request_required = false
        end
    else
        obj.active_request_required = false
    end
    -- Add all requests of active download items
    if obj.active_request_required then
        for i=1,obj.activeitemcount do
            local tmptbl = {
                id = hs.hash.SHA1(os.time()),
                jsonrpc = "2.0",
                method = "aria2.tellStatus",
                params = { "token:" .. obj.rpc_secret, obj.panelItems[i].gid }
            }
            table.insert(req_package,tmptbl)
        end
        obj.active_request_added = true
    else
        obj.active_request_added = false
    end

    hs.http.asyncPost(obj.rpc_host, hs.json.encode(req_package), nil, function(status,data)
        if status == 200 then
            local decoded_data = hs.json.decode(data)
            local stoppednum = tonumber(decoded_data[1].result.numStopped)
            local activenum = tonumber(decoded_data[1].result.numActive)
            local waitingnum = tonumber(decoded_data[1].result.numWaiting)
            if not obj.global_stoppednum then obj.global_stoppednum = stoppednum end
            if not obj.global_activenum then obj.global_activenum = activenum end
            if not obj.global_waitingnum then obj.global_waitingnum = waitingnum end
            if stoppednum == 0 and activenum == 0 and waitingnum == 0 then
                -- When there is no task, increase the request interval (lazy request)
                if not obj.lazy_request_interval then
                    obj.lazy_request_interval = obj.refresh_interval + 1
                else
                    obj.lazy_request_interval = obj.lazy_request_interval + 1
                end
                obj.timer:setNextTrigger(obj.lazy_request_interval)
            else
                -- But if there is any task existing, restore the request interval immediately.
                obj.timer:setNextTrigger(obj.refresh_interval)
            end
            if activenum ~= obj.global_activenum or waitingnum ~= obj.global_waitingnum or stoppednum ~= obj.global_stoppednum then
                -- If any changes, and aria2 panel is showing, we refresh the panel.
                if obj.panel ~= nil then
                    if obj.panel:isShowing() then
                        if obj.timer then obj.timer:stop() end
                        obj:createAndRefreshPanel()
                    end
                end
            end
            if stoppednum ~= obj.global_stoppednum then
                -- If the stopped number doesn't match, we will request stopped tasks.
                obj.stopped_request_required = true
            else
                obj.stopped_request_required = false
            end
            obj.global_activenum = activenum
            obj.global_waitingnum = waitingnum
            obj.global_stoppednum = stoppednum
            if obj.stopped_request_added then
                if obj.stopped_queue_cached then
                    local function isInStoppedQueue(value, tbl)
                        for i=1,#tbl do
                            if tbl[i] == value then
                                return true
                            end
                        end
                        return false
                    end
                    for idx,val in ipairs(decoded_data[2].result) do
                        if not isInStoppedQueue(val.gid, obj.stopped_queue_list) then
                            local file_path = processPath(val.files)
                            if val.errorCode == "0" then
                                if val.status == "complete" then
                                    hs.notify.new({title="Download Succeed.", informativeText=file_path}):send()
                                end
                            elseif val.errorCode == "31" then
                                if val.status == "removed" then
                                    -- do something
                                end
                            else
                                hs.notify.new({title="Download Error! " .. val.errorMessage, informativeText=file_path}):send()
                            end
                        end
                    end
                end
                -- Cache current stopped tasks
                obj.stopped_queue_list = {}
                for idx,val in ipairs(decoded_data[2].result) do
                    table.insert(obj.stopped_queue_list,val.gid)
                end
                obj.stopped_queue_cached = true
            end
            if obj.active_request_added then
                if obj.stopped_request_added then
                    obj.active_pos = 3
                else
                    obj.active_pos = 2
                end
                for i=obj.active_pos,#decoded_data do
                    local file_path = processPath(decoded_data[i].result.files)
                    local file_size = processData("data", decoded_data[i].result.totalLength)
                    local download_speed = processData("speed", decoded_data[i].result.downloadSpeed)
                    local download_progress = processDownloadProgress(decoded_data[i].result.completedLength, decoded_data[i].result.totalLength)
                    local progress_percent = tostring(download_progress*100) .. "%"
                    local connection_number = decoded_data[i].result.connections
                    local remain_time = processRemainTime(decoded_data[i].result.completedLength, decoded_data[i].result.totalLength, decoded_data[i].result.downloadSpeed, decoded_data[i].result.status)
                    obj.panelItems[i-(obj.active_pos-1)].canvas[2].text = file_path
                    obj.panelItems[i-(obj.active_pos-1)].canvas[3].text = file_size
                    obj.panelItems[i-(obj.active_pos-1)].canvas[4].text = download_speed
                    obj.panelItems[i-(obj.active_pos-1)].canvas[6].frame = {x="2%", y="55%", w=tostring(0.6*download_progress), h="25%"}
                    obj.panelItems[i-(obj.active_pos-1)].canvas[7].text = progress_percent
                    obj.panelItems[i-(obj.active_pos-1)].canvas[8].text = connection_number
                    obj.panelItems[i-(obj.active_pos-1)].canvas[9].text = remain_time
                end
            end
        end
    end)
end

local function processURLS(str)
    local tailtrimmedstr = string.gsub(str, "%s+$", "")
    local tmptbl = {}
    for w in string.gmatch(tailtrimmedstr, "[^\n]+") do table.insert(tmptbl, w) end
    if #tmptbl == 1 then
        local trimmedstr = string.gsub(tmptbl[1], "%s", "")
        return trimmedstr
    else
        local tmptbl2 = {}
        for _,val in pairs(tmptbl) do
            local trimmedstr = string.gsub(val, "%s", "")
            table.insert(tmptbl2, trimmedstr)
        end
        return tmptbl2
    end
end

function obj:drawToolbar()
    if not obj.toolbar then
        obj.toolbar = hs.canvas.new({x=0, y=0, w=0, h=0}):show()
        obj.toolbar:level(hs.canvas.windowLevels.tornOffMenu)
        obj.toolbar:clickActivating(false)
        obj.toolbar[1] = {action="fill", type="rectangle", fillColor={hex="#20B2AA", alpha=0.3}, roundedRectRadii={xRadius=3, yRadius=3}}
        obj.toolbar[2] = {type="text", id="regular", text="➲", frame={x=0, y=0, w=tostring(1/4), h="100%"}, textSize=20, textAlignment="center"}
        obj.toolbar[3] = {type="text", id="bt", text="❒", frame={x=tostring(1/4), y=0, w=tostring(1/4), h="100%"}, textSize=20, textAlignment="center"}
        obj.toolbar[4] = {type="text", id="clear", text="♻︎", frame={x=tostring(2/4), y=0, w=tostring(1/4), h="100%"}, textSize=20, textAlignment="center"}
        obj.toolbar[5] = {type="text", id="close", text="✖︎", frame={x=tostring(3/4), y=0, w=tostring(1/4), h="100%"}, textSize=20, textAlignment="center"}
        obj.toolbar._default.trackMouseDown = true

        obj.toolbar:mouseCallback(function(canvas, event, id, x, y)
            if event == "mouseDown" and id == "regular" then
                local strfromclip = hs.pasteboard.readString() or ""
                local one_url_or_batch_urls = processURLS(strfromclip)
                obj:newTask("addUri", one_url_or_batch_urls)
            elseif event == "mouseDown" and id == "bt" then
                status, data = hs.osascript.applescript('set filechooser to choose file with prompt "Select BT file(*.torrent) or Metafile(*.metafile|*.meta4)" of type {"torrent", "metafile", "meta4"}\nreturn POSIX path of filechooser')
                if status then
                    local function extensionoffile(path)
                        local tmptbl = {}
                        for w in string.gmatch(path, "[^%.]+") do table.insert(tmptbl, w) end
                        return tmptbl[#tmptbl]
                    end
                    if extensionoffile(data) == "torrent" then
                        obj:newTask("addTorrent", data)
                    elseif extensionoffile(data) == ".metafile" or extensionoffile(data) == ".meta4" then
                        obj:newTask("addMetalink", data)
                    end
                end
            elseif event == "mouseDown" and id == "clear" then
                obj:sendCommand("purgeDownloadResult")
            elseif event == "mouseDown" and id == "close" then
                obj.toolbar:hide()
                obj.panel:hide()
            end
        end)
    end
    local cscreen = hs.screen.mainScreen()
    local cres = cscreen:fullFrame()
    local lcres = cscreen:absoluteToLocal(cres)
    obj.toolbar:frame(cscreen:localToAbsolute({x=lcres.w-165, y=lcres.h-42, w=120, h=24}))
end

--- HSaria2:newTask(tasktype, urls, hostaddr, secret)
--- Method
--- Create new regular/bt/metalink task, and send notification when done.
---
--- Parameters:
---  * tasktype - A string specifying task type. The value is one of these: `addUri`, `addTorrent`, `addMetalink`, `nil`. When tasktype is `nil`, aria2 will create a regular download task.
---  * urls - A string or a table specifying URL. Multi URLs (table) are only available when tasktype is `addUri` or `nil`.
---  * hostaddr - A optional sring specifying aria2 RPC host
---  * secret - A optional string specifying host secret
function obj:newTask(tasktype, urls, hostaddr, secret)
    local hostaddr = hostaddr or obj.rpc_host
    local secret = secret or obj.rpc_secret
    if hostaddr and secret then
        local task_req = {
            id = hs.hash.SHA1(os.time()),
            jsonrpc = "2.0",
            method = "aria2." .. tasktype
        }
        if tasktype == "addUri" or tasktype == nil then
            if type(urls) == "string" then
                task_req["params"] = { "token:" .. secret, {urls} }
            elseif type(urls) == "table" then
                local task_req = {}
                for _,val in pairs(urls) do
                    local task_item = {
                        id = hs.hash.SHA1(os.time()),
                        jsonrpc = "2.0",
                        method = "aria2." .. tasktype,
                        params = { "token:" .. secret, {val} }
                    }
                    table.insert(task_req, task_item)
                end
            end
        elseif tasktype == "addTorrent" or tasktype == "addMetalink" then
            local file_handler = io.open(urls):read('a')
            if file_handler ~= nil then
                local encoded_file = hs.base64.encode(file_handler)
                task_req["params"] = { "token:" .. secret, encoded_file }
            end
        end
        hs.http.asyncPost(hostaddr, hs.json.encode(task_req), nil, function(status,data)
            if status == 200 then
                if obj.timer then
                    obj.timer:setNextTrigger(obj.refresh_interval)
                else
                    obj.timer = hs.timer.doEvery(obj.refresh_interval, function() obj:intervalRequest() end)
                end
            else
                print("-- HSaria2: Error, adding new task fails.")
            end
        end)
    else
        print("-- HSaria2: Error, RPC connection fails!")
    end
end

--- HSaria2:sendCommand(command, gid, hostaddr, secret)
--- Method
--- Send a command to `hostaddr`, only limited commands are supported.
---
--- Parameters:
---  * command - A string specifying sending command. The value is one of these: `remove`, `forceRemove`, `pause`, `pauseAll`, `forcePause`, `forcePauseAll`, `unpause`, `unpauseAll`, `purgeDownloadResult`, `removeDownloadResult`.
---  * gid - A string specifying GID (aria2 identifies each download by the ID called GID). This Parameter can be optional or not according to the value of `command`.
---  * hostaddr - A optional sring specifying aria2 RPC host
---  * secret - A optional string specifying host secret
function obj:sendCommand(command, gid, hostaddr, secret)
    local hostaddr = hostaddr or obj.rpc_host
    local secret = secret or obj.rpc_secret
    if hostaddr and secret then
        local action_req = {
            id = hs.hash.SHA1(os.time()),
            jsonrpc = "2.0",
            method = "aria2." .. command
        }
        if gid then
            action_req["params"] = { "token:" .. secret, gid }
        else
            action_req["params"] = { "token:" .. secret }
        end
        hs.http.asyncPost(hostaddr, hs.json.encode(action_req), nil, function(status,data)
            if status == 200 then
                if obj.timer then
                    obj.timer:setNextTrigger(obj.refresh_interval)
                else
                    obj.timer = hs.timer.doEvery(obj.refresh_interval, function() obj:intervalRequest() end)
                end
            else
                print("-- HSaria2: Error, invalid command or variable.")
            end
        end)
    else
        print("-- HSaria2: Error, RPC connection fails!")
    end
end

--- HSaria2:togglePanel()
--- Method
--- Toggle the display of aria2 panel. The panel allows users to interact with aria2, add new tasks, pause them, or remove, purge … etc.
---

function obj:togglePanel()
    if obj.panel == nil then
        obj:createAndRefreshPanel()
    else
        if obj.panel:isShowing() then
            obj.panel:hide()
            obj.toolbar:hide()
        else
            obj:createAndRefreshPanel()
            obj.panel:show()
            obj.toolbar:show()
        end
    end
end

return obj
