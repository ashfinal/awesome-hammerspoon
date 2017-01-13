function clipshow()
    if clipDrawn == nil then
        local mainScreen = hs.screen.mainScreen()
        local mainRes = mainScreen:fullFrame()
        clipType = hs.pasteboard.typesAvailable()
        if clipType.image == true then
            local imagedata = hs.pasteboard.readImage()
            local imagesize = imagedata:size()
            if imagesize.w < 480 and imagesize.h < 480 then
                centerimgframe = hs.geometry.rect((mainRes.w-480)/2,(mainRes.h-480)/2,480,480)
            else
                centerimgframe = hs.geometry.rect((mainRes.w-imagesize.w)/2,(mainRes.h-imagesize.h)/2,imagesize.w,imagesize.h)
            end
            imageshow = hs.drawing.image(centerimgframe,imagedata)
            imageshow:setLevel(hs.drawing.windowLevels.modalPanel)
            imageshow:setBehavior(hs.drawing.windowBehaviors.stationary)
            imageshow:show()
            clipDrawn = true
            imageshow:setClickCallback(nil,function() imageshow:delete() clipboardM:exit() clipDrawn=nil end)
        elseif clipType.URL == true then
            local URLdata = hs.pasteboard.readURL()
            local defaultbrowser = hs.urlevent.getDefaultHandler('http')
            hs.urlevent.openURLWithBundle(URLdata,defaultbrowser)
            clipboardM:exit()
        elseif clipType.styledText == true then
            local textdata = hs.pasteboard.readString()
            -- textdata = hs.pasteboard.readStyledText()
            local matchurl = string.match(textdata,'https?://%w[-.%w]*:?%d*/?[%w_.~!*:@&+$/?%%#=-]*')
            if matchurl == textdata then
                local defaultbrowser = hs.urlevent.getDefaultHandler('http')
                hs.urlevent.openURLWithBundle(textdata,defaultbrowser)
                clipboardM:exit()
            else
                local bgframe = hs.geometry.rect(0,mainRes.h/5,mainRes.w,mainRes.h/5*3)
                clipbackground = hs.drawing.rectangle(bgframe)
                clipbackground:setLevel(hs.drawing.windowLevels.modalPanel)
                clipbackground:setBehavior(hs.drawing.windowBehaviors.stationary)
                clipbackground:setFill(true)
                clipbackground:setFillColor({red=0,blue=0,green=0,alpha=0.75})
                clipbackground:show()
                textframe = hs.geometry.rect(bgframe.x+20,bgframe.y+20,bgframe.w-40,bgframe.h-40)
                textshow = hs.drawing.text(textframe,textdata)
                textshow:setLevel(hs.drawing.windowLevels.modalPanel)
                textshow:setBehavior(hs.drawing.windowBehaviors.stationary)
                if string.len(textdata) < 180 then
                    textshow:setTextSize(80.0)
                else
                    textshow:setTextSize(50.0)
                end
                textshow:show()
                clipDrawn = true
                clipbackground:setClickCallback(nil,function() clipbackground:delete() textshow:delete() clipboardM:exit() clipDrawn=nil end)
            end
        else
            hs.alert.show("Empty clipboard or unsupported type.")
            if clipboardM then clipboardM:exit() end
        end
    end
end

function clipshowclear()
    if clipDrawn == true then
       if imageshow ~= nil then imageshow:delete() imageshow=nil end
       if clipbackground ~= nil then clipbackground:delete() clipbackground=nil textshow:delete() textshow=nil end
       clipDrawn = nil
    end
end

clipboardM = hs.hotkey.modal.new()
table.insert(modal_list, clipboardM)
function clipboardM:entered() modal_stat('clipboard',purple) clipshow() end
function clipboardM:exited()
    clipshowclear()
    if dock_launched then
        modal_stat('dock',black)
    else
        modal_bg:hide()
        modal_show:hide()
    end
    if idle_to_which == "hide" then
        modal_bg:hide()
        modal_show:hide()
    end
end
clipboardM:bind('', 'escape', function() clipboardM:exit() end)
clipboardM:bind('', 'Q', function() clipboardM:exit() end)
