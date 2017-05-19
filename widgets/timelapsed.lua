if not timelapsetopleft then timelapsetopleft = {980,400} end

timelapsed_canvas = hs.canvas.new({x=timelapsetopleft[1],y=timelapsetopleft[2],w=280,h=125}):show()
timelapsed_canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
timelapsed_canvas:level(hs.canvas.windowLevels.desktopIcon)

-- canvas background
timelapsed_canvas[1] = {
    action = "fill",
    type = "rectangle",
    fillColor = black,
    roundedRectRadii = {xRadius=5, yRadius=5},
}
timelapsed_canvas[1].fillColor.alpha = .2
-- title
timelapsed_canvas[2] = {
    type = "text",
    text = "Time Elapsed",
    textSize = 14,
    textColor = white,
    frame = {
        x = tostring(10/280),
        y = tostring(10/125),
        w = tostring(260/280),
        h = tostring(25/125),
    }
}
timelapsed_canvas[2].textColor.alpha = .3
-- time
timelapsed_canvas[3] = {
    type = "text",
    text = "",
    textColor = {hex="#A6AAC3"},
    textSize = 17,
    textAlignment = "center",
    frame = {
        x = tostring(0/280),
        y = tostring(35/125),
        w = tostring(280/280),
        h = tostring(25/125),
    }
}
-- indicator background
timelapsed_canvas[4] = {
    type = "image",
    image = hs.image.imageFromPath("./resources/timebg.png"),
    frame = {
        x = tostring(10/280),
        y = tostring(65/125),
        w = tostring(260/280),
        h = tostring(50/125),
    }
}
-- light indicator
timelapsed_canvas[5] = {
    action = "fill",
    type = "rectangle",
    fillColor = white,
    frame = {
        x = tostring(20/280),
        y = tostring(75/125),
        w = tostring(240/280),
        h = tostring(20/125),
    }
}
timelapsed_canvas[5].fillColor.alpha = .2
-- indicator mask
timelapsed_canvas[6] = {
    action = "fill",
    type = "rectangle",
    frame = {
        x = tostring(20/280),
        y = tostring(75/125),
        w = tostring(240/280),
        h = tostring(20/125),
    }
}
-- color indicator
timelapsed_canvas[7] = {
    action = "fill",
    type = "rectangle",
    frame = {
        x = tostring(20/280),
        y = tostring(75/125),
        w = tostring(240/280),
        h = tostring(20/125),
    },
    fillGradient="linear",
    fillGradientColors = {
        {hex = "#00A0F7"},
        {hex = "#92D2E5"},
        {hex = "#4BE581"},
        {hex = "#EAF25E"},
        {hex = "#F4CA55"},
        {hex = "#E04E4E"},
    },
}
timelapsed_canvas[7].compositeRule = "sourceAtop"

function updateElapsedCanvas()
   local nowtable = os.date("*t")
   local nowyday = nowtable.yday
   local nowhour = string.format("%2s", nowtable.hour)
   local nowmin = string.format("%2s", nowtable.min)
   local nowsec = string.format("%2s", nowtable.sec)
   local timestr = nowyday.." days "..nowhour.." hours "..nowmin.." min "..nowsec.." sec"
   local secs_since_epoch = os.time()
   local nowyear = nowtable.year
   local yearstartsecs_since_epoch = os.time({year=nowyear, month=1, day=1, hour=0})
   local nowyear_elapsed_secs = secs_since_epoch - yearstartsecs_since_epoch
   local yearendsecs_since_epoch = os.time({year=nowyear+1, month=1, day=1, hour=0})
   local nowyear_total_secs = yearendsecs_since_epoch - yearstartsecs_since_epoch
   local elapsed_percent = nowyear_elapsed_secs/nowyear_total_secs
   if timelapsed_canvas:isShowing() then
       timelapsed_canvas[3].text = timestr
       timelapsed_canvas[6].frame.w = tostring(240/280*elapsed_percent)
   end

end

if elapsedTimer == nil then
    elapsedTimer = hs.timer.doEvery(1, function() updateElapsedCanvas() end)
else
    elapsedTimer:start()
end
