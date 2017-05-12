aria2_loaded = true
if not aria2_host then aria2_host = "http://localhost:6800/jsonrpc" end
if not aria2_token then aria2_token = "token" end
if not aria2_show_items_max then aria2_show_items_max = 5 end
if not aria2_refresh_interval then aria2_refresh_interval = 1 end

local function pathToName(path)
    local tmptbl = {}
    for w in string.gmatch(path,"[^/]+") do table.insert(tmptbl,w) end
    return tmptbl[#tmptbl]
end

local function formatData(datanum)
    if datanum/1024 < 1024 then
        return string.format("%.2f",datanum/1024) .. ' KB'
    elseif datanum/1024/1024 < 1024 then
        return string.format("%.2f",datanum/1024/1024) .. ' MB'
    elseif datanum/1024/1024/1024 < 1024 then
        return string.format("%.2f",datanum/1024/1024/1024) .. ' GB'
    end
end

local function formatTime(secnum)
    local hourcount = math.modf(secnum/3600)
    local mincount = math.modf(math.fmod(secnum,3600)/60)
    local seccount = math.fmod(secnum,60)
    return string.format("%02d",hourcount)..":"..string.format("%02d",mincount)..":"..string.format("%02d",seccount)
end

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

function aria2_NewTask(tasktype,fileaddr)
    local task_req = {
        id = hs.hash.SHA1(os.time()),
        jsonrpc = "2.0",
        method = "aria2."..tasktype
    }
    if tasktype == "addUri" then
        if type(fileaddr) == "string" then
            task_req["params"] = { "token:"..aria2_token,{fileaddr} }
        elseif type(fileaddr) == "table" then
            task_req = {}
            for _,val in pairs(fileaddr) do
                local task_item = {
                    id = hs.hash.SHA1(os.time()),
                    jsonrpc = "2.0",
                    method = "aria2."..tasktype,
                    params = { "token:"..aria2_token,{val} }
                }
                table.insert(task_req,task_item)
            end
        end
    elseif tasktype == "addTorrent" or tasktype == "addMetalink" then
        local file_handle = io.open(fileaddr):read('a')
        if file_handle ~= nil then
            local encoded_file = hs.base64.encode(file_handle)
            task_req["params"] = { "token:"..aria2_token,encoded_file }
        end
    end
    if aria2_timer ~= nil then
        aria2_timer:stop()
        hs.http.asyncPost(aria2_host,hs.json.encode(task_req),nil,function(status,data)
            if status == 200 then
                if aria2_timer:nextTrigger() > aria2_refresh_interval then
                    aria2_DrawCanvas()
                end
            end
            aria2_timer:start()
            aria2_timer:setNextTrigger(aria2_refresh_interval)
        end)
    end
end

function aria2_Commands(action,gid)
    local action_req = {
        id = hs.hash.SHA1(os.time()),
        jsonrpc = "2.0",
        method = "aria2."..action
    }
    if gid then
        action_req["params"] = { "token:"..aria2_token, gid }
    else
        action_req["params"] = { "token:"..aria2_token }
    end
    if aria2_timer ~= nil then
        aria2_timer:stop()
        hs.http.asyncPost(aria2_host,hs.json.encode(action_req),nil,function(status,data)
            if status == 200 then
                if aria2_timer:nextTrigger() > aria2_refresh_interval then
                    aria2_DrawCanvas()
                end
            end
            aria2_timer:start()
        end)
    end
end

function aria2_DrawCanvas()
    local alltasks_req = {
        {
            id = hs.hash.SHA1(os.time()),
            jsonrpc = "2.0",
            method = "aria2.tellActive",
            params = { "token:"..aria2_token }
        },
        {
            id = hs.hash.SHA1(os.time()),
            jsonrpc = "2.0",
            method = "aria2.tellWaiting",
            params = { "token:"..aria2_token, 0, 5 }
        },
        {
            id = hs.hash.SHA1(os.time()),
            jsonrpc = "2.0",
            method = "aria2.tellStopped",
            params = { "token:"..aria2_token, 0, 5 }
        },
    }

    hs.http.asyncPost(aria2_host,hs.json.encode(alltasks_req),nil,function(status,data)
        if status == 200 then
            local decoded_data = hs.json.decode(data)
            aria2_canvas_holder = nil
            aria2_canvas_holder = {}
            aria2_items_count = 0
            aria2_active_items_count = 0
            for idx,tbl in pairs(decoded_data) do
                if type(tbl.result) == "table" then
                    local result_tbl = tbl.result
                    for key,val in pairs(result_tbl) do
                        if aria2_items_count >= aria2_show_items_max then break end
                        if val.files[1].path ~= "" then
                            aria2_file_path = pathToName(val.files[1].path)
                        else
                            aria2_file_path = val.files[1].uris[1].uri
                        end
                        local file_size = formatData(val.totalLength)
                        if val.status == "paused" then
                            aria2_download_speed = formatData(0).."/s"
                        else
                            aria2_download_speed = formatData(val.downloadSpeed).."/s"
                        end
                        if val.totalLength == "0" then
                            aria2_download_progress = string.format("%.4f",0)
                        else
                            aria2_download_progress = string.format("%.4f",val.completedLength/val.totalLength)
                        end
                        local progress_percent = tostring(aria2_download_progress*100).."%"
                        local connection_number = val.connections
                        if val.downloadSpeed == "0" or val.status == "paused" then
                            aria2_remain_time = "--:--:--"
                        else
                            aria2_remain_time = formatTime(string.format("%.0f",(val.totalLength-val.completedLength)/val.downloadSpeed))
                        end
                        local aria2_canvas = hs.canvas.new({x=0,y=0,w=400,h=50})
                        aria2_canvas._default.textSize = 12
                        aria2_canvas._default.textColor = black
                        aria2_canvas._default.trackMouseDown = true
                        if val.status == "active" then
                            aria2_canvas[1] = {type="rectangle",fillColor=osx_green}
                        elseif val.status == "paused" then
                            aria2_canvas[1] = {type="rectangle",fillColor=osx_yellow}
                        elseif val.status == "complete" then
                            aria2_canvas[1] = {type="rectangle",fillColor=black}
                        elseif val.status == "error" or val.status == "removed" then
                            aria2_canvas[1] = {type="rectangle",fillColor=osx_red}
                        end
                        aria2_canvas[1].fillColor.alpha = 0.1
                        aria2_canvas[2] = {type="text",text=aria2_file_path,frame={x="2%",y="10%",w="60%",h="45%"},textAlignment="left",textLineBreak="truncateMiddle"}
                        aria2_canvas[3] = {type="text",text=file_size,frame={x="64%",y="10%",w="15%",h="45%"},textAlignment="right"}
                        aria2_canvas[4] = {type="text",text=aria2_download_speed,frame={x="83%",y="15%",w="15%",h="45%"},textSize=10,textAlignment="right"}
                        aria2_canvas[5] = {action="fill",type="rectangle",fillColor=gray,frame={x="2%",y="55%",w="60%",h="25%"}}
                        aria2_canvas[6] = {action="fill",type="rectangle",fillColor=dodgerblue,frame={x="2%",y="55%",w=tostring(0.6*aria2_download_progress),h="25%"}}
                        aria2_canvas[7] = {type="text",text=progress_percent,frame={x="2%",y="55%",w="60%",h="45%"},textSize=10,textAlignment="right"}
                        aria2_canvas[8] = {type="text",text=connection_number,frame={x="64%",y="55%",w="15%",h="45%"},textSize=10,textAlignment="center"}
                        aria2_canvas[9] = {type="text",text=aria2_remain_time,frame={x="83%",y="55%",w="15%",h="45%"},textSize=10,textAlignment="right"}
                        aria2_canvas:mouseCallback(function(canvas,event,id,x,y)
                            if canvas == aria2_canvas and event == "mouseDown" then
                                local modifiers_status = hs.eventtap.checkKeyboardModifiers()
                                if modifiers_status.cmd == true then
                                    if val.status == "complete" or val.status == "removed" or val.status == "error" then
                                        aria2_Commands("removeDownloadResult",val.gid)
                                    else
                                        aria2_Commands("remove",val.gid)
                                    end
                                else
                                    if val.status == "complete" then
                                        hs.execute("open -g "..val.files[1].path)
                                    elseif val.status == "active" then
                                        aria2_Commands("pause",val.gid)
                                    elseif val.status == "paused" then
                                        aria2_Commands("unpause",val.gid)
                                    end
                                end
                            end
                        end)
                        table.insert(aria2_canvas_holder,{gid=val.gid,status=val.status,canvas=aria2_canvas})
                        if val.status == "active" then
                            aria2_active_items_count = aria2_active_items_count + 1
                        end
                        aria2_items_count = aria2_items_count + 1
                    end
                end
            end
            if aria2_drawer == nil then
                aria2_init_in_screen = hs.screen.mainScreen()
                local mainRes = aria2_init_in_screen:fullFrame()
                local localMainRes = aria2_init_in_screen:absoluteToLocal(mainRes)
                aria2_drawer = hs.canvas.new(aria2_init_in_screen:localToAbsolute({x=localMainRes.w-400,y=localMainRes.h-50*#aria2_canvas_holder-52,w=400,h=50*#aria2_canvas_holder}))
                aria2_drawer[1] = {type="rectangle",fillColor=white}
                aria2_drawer[1].fillColor.alpha = 0.8
                aria2_drawer:level(hs.canvas.windowLevels.tornOffMenu)
                aria2_drawer:clickActivating(false)
                aria2_drawer._default.trackMouseDown = true
            else
                for i=2,#aria2_drawer do
                    aria2_drawer:removeElement(2)
                end
                local mainRes = aria2_init_in_screen:fullFrame()
                local localMainRes = aria2_init_in_screen:absoluteToLocal(mainRes)
                aria2_drawer:frame(aria2_init_in_screen:localToAbsolute({x=localMainRes.w-400,y=localMainRes.h-50*#aria2_canvas_holder-52,w=400,h=50*#aria2_canvas_holder}))
            end
            aria2_drawer:show()
            for idx,val in pairs(aria2_canvas_holder) do
                aria2_drawer[idx+1]={type="canvas",canvas=val.canvas,frame={x="0%",y=tostring(1/#aria2_canvas_holder*(idx-1)),w="100%",h=tostring(1/#aria2_canvas_holder)}}
            end
            -- TODO: Figure out why this is needed
            aria2_drawer:mouseCallback(function(canvas,event,id,x,y)
                print(canvas,event,id,x,y)
            end)
        end
        if aria2_timer ~= nil then aria2_timer:start() end
    end)
end


function aria2_IntervalRequest()
    local globalstat_req = {
        {
            id = hs.hash.SHA1(os.time()),
            jsonrpc = "2.0",
            method = "aria2.getGlobalStat",
            params = { "token:"..aria2_token }
        },
    }
    if not stopped_queue_cached then stopped_request_required = true end
    if stopped_request_required then
        local tmptbl = {
            id = hs.hash.SHA1(os.time()),
            jsonrpc = "2.0",
            method = "aria2.tellStopped",
            params = { "token:"..aria2_token, 0, 100 }
        }
        table.insert(globalstat_req,tmptbl)
        stopped_request_added = true
    else
        stopped_request_added = false
    end

    if aria2_drawer ~= nil then
        if aria2_drawer:isShowing() then
            if aria2_active_items_count and aria2_active_items_count > 0 then
                active_request_required = true
            else
                active_request_required = false
            end
        else
            active_request_required = false
        end
    else
        active_request_required = false
    end

    if active_request_required then
        for i=1,aria2_active_items_count do
            local tmptbl = {
                id = hs.hash.SHA1(os.time()),
                jsonrpc = "2.0",
                method = "aria2.tellStatus",
                params = { "token:"..aria2_token, aria2_canvas_holder[i].gid, {"totalLength","completedLength","downloadSpeed","connections"} }
            }
            table.insert(globalstat_req,tmptbl)
        end
        active_request_added = true
    else
        active_request_added = false
    end

    hs.http.asyncPost(aria2_host,hs.json.encode(globalstat_req),nil,function(status,data)
        if status == 200 then
            local decoded_data = hs.json.decode(data)
            local stoppednum = tonumber(decoded_data[1].result.numStopped)
            local activenum = tonumber(decoded_data[1].result.numActive)
            local waitingnum = tonumber(decoded_data[1].result.numWaiting)
            if not aria2_global_stoppednum then aria2_global_stoppednum = stoppednum end
            if not aria2_global_activenum then aria2_global_activenum = activenum end
            if not aria2_global_waitingnum then aria2_global_waitingnum = waitingnum end
            if stoppednum == 0 and activenum == 0 and waitingnum == 0 then
                if not aria2_lazy_request_interval then
                    aria2_lazy_request_interval = aria2_refresh_interval + 1
                else
                    aria2_lazy_request_interval = aria2_lazy_request_interval + 1
                end
                aria2_timer:setNextTrigger(aria2_lazy_request_interval)
            else
                aria2_timer:setNextTrigger(aria2_refresh_interval)
            end
            if activenum ~= aria2_global_activenum or waitingnum ~= aria2_global_waitingnum or stoppednum ~= aria2_global_stoppednum then
                if aria2_drawer ~= nil then
                    if aria2_drawer:isShowing() then
                        if aria2_timer ~= nil then
                            aria2_timer:stop()
                            aria2_DrawCanvas()
                        end
                    end
                end
            end
            if stoppednum ~= aria2_global_stoppednum then
                stopped_request_required = true
            else
                stopped_request_required = false
            end
            aria2_global_activenum = activenum
            aria2_global_waitingnum = waitingnum
            aria2_global_stoppednum = stoppednum
            if stopped_request_added then
                if stopped_queue_cached then
                    local function isInStoppedQueue(value, tbl)
                        for i=1,#tbl do
                            if tbl[i] == value then
                                return true
                            end
                        end
                        return false
                    end
                    for idx,val in pairs(decoded_data[2].result) do
                        if not isInStoppedQueue(val.gid,stopped_queue_list) then
                            if val.files[1].path ~= "" then
                                aria2_file_path = pathToName(val.files[1].path)
                            else
                                aria2_file_path = val.files[1].uris[1].uri
                            end
                            if val.errorCode == "0" then
                                if val.status == "complete" then
                                    aria2_notify_title = "Download Succeed."
                                end
                            elseif val.errorCode == "31" then
                                if val.status == "removed" then
                                    aria2_notify_title = ""
                                end
                            else
                                aria2_notify_title = "Download Error! "..val.errorMessage
                            end
                            if aria2_notify_title ~= "" then
                                hs.notify.new({title=aria2_notify_title, informativeText=aria2_file_path}):send()
                            end
                        end
                    end
                end
                stopped_queue_list = {}
                for idx,val in pairs(decoded_data[2].result) do
                    table.insert(stopped_queue_list,val.gid)
                end
                stopped_queue_cached = true
            end
            if active_request_added then
                if stopped_request_added then
                    aria2_activerep_tbl_pos = 3
                else
                    aria2_activerep_tbl_pos = 2
                end
                for i=aria2_activerep_tbl_pos,#decoded_data do
                    local download_speed = formatData(decoded_data[i].result.downloadSpeed).."/s"
                    if decoded_data[i].result.totalLength == "0" then
                        aria2_download_progress = string.format("%.4f",0)
                    else
                        aria2_download_progress = string.format("%.4f",decoded_data[i].result.completedLength/decoded_data[i].result.totalLength)
                    end
                    local progress_percent = tostring(aria2_download_progress*100).."%"
                    local connection_number = decoded_data[i].result.connections
                    if decoded_data[i].result.downloadSpeed == "0" then
                        aria2_remain_time = "--:--:--"
                    else
                        aria2_remain_time = formatTime(string.format("%.0f",(decoded_data[i].result.totalLength-decoded_data[i].result.completedLength)/decoded_data[i].result.downloadSpeed))
                    end
                    aria2_canvas_holder[i-(aria2_activerep_tbl_pos-1)].canvas[4].text = download_speed
                    aria2_canvas_holder[i-(aria2_activerep_tbl_pos-1)].canvas[6].frame = {x="2%",y="55%",w=tostring(0.6*aria2_download_progress),h="25%"}
                    aria2_canvas_holder[i-(aria2_activerep_tbl_pos-1)].canvas[7].text = progress_percent
                    aria2_canvas_holder[i-(aria2_activerep_tbl_pos-1)].canvas[8].text = connection_number
                    aria2_canvas_holder[i-(aria2_activerep_tbl_pos-1)].canvas[9].text = aria2_remain_time
                end
            end
        end
    end)
end

function aria2_DrawToolbar()
    if not aria2_toolbar then
        local mainScreen = hs.screen.mainScreen()
        local mainRes = mainScreen:fullFrame()
        local localMainRes = mainScreen:absoluteToLocal(mainRes)
        aria2_toolbar = hs.canvas.new(mainScreen:localToAbsolute({x=localMainRes.w-165,y=localMainRes.h-42,w=120,h=24}))
        aria2_toolbar:level(hs.canvas.windowLevels.tornOffMenu)
        aria2_toolbar:clickActivating(false)
        aria2_toolbar[1] = {action="fill",type="rectangle",fillColor=lightseagreen,roundedRectRadii={xRadius=3,yRadius=3}}
        aria2_toolbar[1].fillColor.alpha=0.3
        aria2_toolbar[2] = {type="text",text="➲",frame={x=0,y=0,w=tostring(1/4),h="100%"},textSize=20,textAlignment="center"}
        aria2_toolbar[3] = {type="text",text="❒",frame={x=tostring(1/4),y=0,w=tostring(1/4),h="100%"},textSize=20,textAlignment="center"}
        aria2_toolbar[4] = {type="text",text="♻︎",frame={x=tostring(2/4),y=0,w=tostring(1/4),h="100%"},textSize=20,textAlignment="center"}
        aria2_toolbar[5] = {type="text",text="✖︎",frame={x=tostring(3/4),y=0,w=tostring(1/4),h="100%"},textSize=20,textAlignment="center"}
        aria2_toolbar._default.trackMouseDown = true

        aria2_toolbar:mouseCallback(function(canvas,event,id,x,y)
            if event == "mouseDown" and id == 2 then
                local strfromclip = hs.pasteboard.readString()
                local single_url_or_batch_urls = splitByLine(strfromclip)
                aria2_NewTask("addUri",single_url_or_batch_urls)
            elseif event == "mouseDown" and id == 3 then
                status, data = hs.osascript.applescript('set filechooser to choose file with prompt "Select BT file(*.torrent) or Metafile(*.metafile|*.meta4)" of type {"torrent", "metafile", "meta4"}\nreturn POSIX path of filechooser')
                if status then
                    local function extensionoffile(path)
                        local tmptbl = {}
                        for w in string.gmatch(path,"[^%.]+") do table.insert(tmptbl,w) end
                        return tmptbl[#tmptbl]
                    end
                    if extensionoffile(data) == "torrent" then
                        aria2_NewTask("addTorrent",data)
                    elseif extensionoffile(data) == ".metafile" or extensionoffile(data) == ".meta4" then
                        aria2_NewTask("addMetalink",data)
                    end
                end
            elseif event == "mouseDown" and id == 4 then
                aria2_Commands("purgeDownloadResult")
            elseif event == "mouseDown" and id == 5 then
                aria2_toolbar:hide()
                aria2_drawer:hide()
            end
        end)
    end
    local mainScreen = hs.screen.mainScreen()
    local mainRes = mainScreen:fullFrame()
    local localMainRes = mainScreen:absoluteToLocal(mainRes)
    aria2_toolbar:frame(mainScreen:localToAbsolute({x=localMainRes.w-165,y=localMainRes.h-42,w=120,h=24}))
    aria2_toolbar:show()
end

function aria2_Init()
    local init_req = {
        id = hs.hash.SHA1(os.time()),
        jsonrpc = "2.0",
        method = "aria2.getVersion",
        params = { "token:"..aria2_token }
    }
    hs.http.asyncPost(aria2_host,hs.json.encode(init_req),nil,function(status,data)
        if status == 200 then
            aria2_DrawToolbar()
            aria2_DrawCanvas()
            if aria2_timer ~= nil then
                aria2_timer:start()
                aria2_timer:setNextTrigger(aria2_refresh_interval)
            else
                aria2_timer = hs.timer.doEvery(aria2_refresh_interval,aria2_IntervalRequest)
            end
        else
            hs.notify.new({title="aria2 not ready.", informativeText="Please check your configuration."}):send()
        end
    end)
end

