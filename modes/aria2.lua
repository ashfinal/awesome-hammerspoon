if not aria2URL then aria2URL = "http://macplay.coding.me/aria/" end
function aria2ctl()
    if not aria2GUI then
        local mainScreen = hs.screen.mainScreen()
        local mainRes = mainScreen:fullFrame()
        local rect = hs.geometry.rect((mainRes.w-502)/2,(mainRes.h-450)/2,502,450)
        aria2GUI = hs.webview.new(rect)
        aria2GUI:url(aria2URL)
        aria2GUI:allowNewWindows(false)
        aria2GUI:allowTextEntry(true)
        aria2GUI:level(hs.drawing.windowLevels.modalPanel)
        -- aria2GUI:sendToBack()
        -- aria2GUI:bringToFront(true)
        -- aria2GUI:alpha(0.9)
    end
    aria2GUI:show()
end

downloadM = hs.hotkey.modal.new()
table.insert(modal_list, downloadM)
function downloadM:entered() modal_stat('download',osx_green) aria2ctl() end
function downloadM:exited()
    if dock_launched then
        modal_stat('dock',black)
    else
        modal_bg:hide()
        modal_show:hide()
    end
    if aria2GUI ~= nil then aria2GUI:hide() end
end
downloadM:bind('', 'escape', function() downloadM:exit() end)
downloadM:bind('', 'Q', function() downloadM:exit() end)
downloadM:bind('ctrl', 'escape', nil, function() downloadM:exit() aria2GUI:delete() aria2GUI=nil end)
