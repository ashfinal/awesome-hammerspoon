--- === UnsplashZ ===
---
--- Use unsplash images as wallpaper
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/UnsplashZ.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/UnsplashZ.spoon.zip)

local obj={}
obj.__index = obj

-- Metadata
obj.name = "UnsplashZ"
obj.version = "1.0"
obj.author = "ashfinal <ashfinal@gmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function curl_callback(exitCode, stdOut, stdErr)
    if exitCode == 0 then
        obj.task = nil
        obj.last_pic = hs.http.urlParts(obj.pic_url).lastPathComponent
        local localpath = os.getenv("HOME") .. "/.Trash/" .. hs.http.urlParts(obj.pic_url).lastPathComponent

        hs.screen.mainScreen():desktopImageURL("file://" .. localpath)
    else
        print(stdOut, stdErr)
    end
end

local function unsplashRequest()
    local user_agent_str = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/603.2.4 (KHTML, like Gecko) Version/10.1.1 Safari/603.2.4"
    obj.pic_url = hs.execute([[ /usr/bin/curl 'https://source.unsplash.com/1600x900/?nature' |  perl -ne ' print "$1" if /href="([^"]+)"/ ' ]])
    if obj.last_pic ~= obj.pic_url then
        if obj.task then
            obj.task:terminate()
            obj.task = nil
        end
        local localpath = os.getenv("HOME") .. "/.Trash/" .. hs.http.urlParts(obj.pic_url).lastPathComponent
        obj.task = hs.task.new("/usr/bin/curl", curl_callback, {"-A", user_agent_str, obj.pic_url, "-o", localpath})
        obj.task:start()
    end
end

function obj:init()
    if obj.timer == nil then
        obj.timer = hs.timer.doEvery(3*60*60, function() unsplashRequest() end)
        obj.timer:setNextTrigger(5)
    else
        obj.timer:start()
    end
end

return obj
