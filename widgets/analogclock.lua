local loopcolor = {red=1, blue=1, green=1, alpha=0.1}
local secfillcolor = {red=158/255, blue=158/255, green=158/255, alpha=0.1}
local seccolor = {red=158/255, blue=158/255, green=158/255, alpha=0.3}
local mincolor = {red=24/255, blue=195/255, green=145/255, alpha=0.75}
local hourcolor = {red=236/255, blue=39/255, green=109/255, alpha=0.75}

if not aclocktopleft then
    local mainScreen = hs.screen.mainScreen()
    local mainRes = mainScreen:fullFrame()
    aclocktopleft = {mainRes.w-300-20,100}
end

analogclockCanvas = hs.canvas.new({
    x = aclocktopleft[1],
    y = aclocktopleft[2],
    w = 200,
    h = 200
}):show()

analogclockCanvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
analogclockCanvas:level(hs.canvas.windowLevels.desktopIcon)

analogclockCanvas[1] = {
    id = "watch_image",
    type = "image",
    image = hs.image.imageFromPath(hs.configdir .. "/resources/watchbg.png"),
}

analogclockCanvas[2] = {
    id = "watch_circle",
    type = "circle",
    radius = "40%",
    action = "stroke",
    strokeColor = seccolor,
}

analogclockCanvas[3] = {
    id = "watch_sechand",
    type = "arc",
    radius = "40%",
    fillColor = secfillcolor,
    strokeColor = seccolor,
    endAngle = 0,
}

analogclockCanvas[4] = {
    id = "watch_hourcircle",
    type = "circle",
    action = "stroke",
    radius = "20%",
    strokeWidth = 3,
    strokeColor = loopcolor,
}

analogclockCanvas[5] = {
    id = "watch_hourarc",
    type = "arc",
    action = "stroke",
    radius = "20%",
    arcRadii = false,
    strokeWidth = 3,
    strokeColor = hourcolor,
    endAngle = 0,
}

analogclockCanvas[6] = {
    id = "watch_mincircle",
    type = "circle",
    action = "stroke",
    radius = "27%",
    strokeWidth = 3,
    strokeColor = loopcolor,
}

analogclockCanvas[7] = {
    id = "watch_minarc",
    type = "arc",
    action = "stroke",
    radius = "27%",
    arcRadii = false,
    strokeWidth = 3,
    strokeColor = mincolor,
    endAngle = 0,
}

if aclocktimer == nil then
    aclocktimer = hs.timer.doEvery(1,function() updateClock() end)
else
    aclocktimer:start()
end

function updateClock()
    local secnum = math.tointeger(os.date("%S"))
    local minnum = math.tointeger(os.date("%M"))
    local hournum = math.tointeger(os.date("%I"))
    local secangle = 6*secnum
    local minangle = 6*minnum + 6/60*secnum
    local hourangle = 30*hournum + 30/60*minnum + 30/60/60*secnum

    analogclockCanvas[3].endAngle = secangle
    analogclockCanvas[7].endAngle = minangle
    -- hourangle may be larger than 360 at 12pm-1pm
    if hourangle >= 360 then
        hourangle = hourangle - 360
    end
    analogclockCanvas[5].endAngle = hourangle
end
