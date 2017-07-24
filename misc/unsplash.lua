user_agent_str = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/603.2.4 (KHTML, like Gecko) Version/10.1.1 Safari/603.2.4"

function DailyRequest()
    local pic_url = hs.execute([[ /usr/bin/curl 'https://source.unsplash.com/1600x900/?nature' |  perl -ne ' print "$1" if /href="([^"]+)"/ ' ]])
    downloadImage(pic_url)
end


function downloadImage(url)
    local function curl_callback(exitCode,stdOut,stdErr)
        if exitCode == 0 then
            curl_task = nil
            _last_set_pic = hs.http.urlParts(url).lastPathComponent
            local localpath = os.getenv("HOME").."/.Trash/"..hs.http.urlParts(url).lastPathComponent
            SetAsWallpaper(localpath)
        else
            print(stdOut,stdErr)
        end
    end
    if curl_task then
        curl_task:terminate()
        curl_task = nil
    end
    local localpath = os.getenv("HOME").."/.Trash/"..hs.http.urlParts(url).lastPathComponent
    curl_task = hs.task.new("/usr/bin/curl",curl_callback,{"-A",user_agent_str,url,"-o",localpath})
    curl_task:start()
end

function SetAsWallpaper(filepath)
    local applescript = 'tell application "System Events"\nset picture of current desktop to "'..filepath..'"\nend tell'
    local stat, data= hs.osascript.applescript(applescript)
    if not stat then
        print("AppleScript failed.")
    end
end

if wallPapper_timer == nil then
    wallPapper_timer = hs.timer.doEvery(30*60, function() DailyRequest() end)
    wallPapper_timer:setNextTrigger(5)
else
    wallPapper_timer:start()
end
