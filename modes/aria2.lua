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
local modalpkg = {}
modalpkg.id = "downloadM"
modalpkg.modal = downloadM
table.insert(modal_list, modalpkg)

function downloadM:entered()
    modal_stat('download',osx_green)
    for i=1,#modal_list do
        if modal_list[i].id == "downloadM" then
            table.insert(activeModals, modal_list[i])
        end
    end
    aria2ctl()
    if nettimer~=nil and nettimer:running() then nettimer:stop() end
end

function downloadM:exited()
    for i=1,#activeModals do
        if activeModals[i].id == "downloadM" then
            table.remove(activeModals, i)
        end
    end
    if dock_launched then
        if idle_to_which == "netspeed" then
            modal_stat('netspeed',black50)
            disp_netspeed()
        elseif idle_to_which == "hide" then
            modal_show:hide()
            modal_bg:hide()
        elseif idle_to_which == "never" then
            modal_stat('dock',black)
        end
    end
    if aria2GUI ~= nil then aria2GUI:hide() end
end
downloadM:bind('', 'escape', function() downloadM:exit() end)
downloadM:bind('', 'Q', function() downloadM:exit() end)
downloadM:bind('ctrl', 'escape', nil, function() downloadM:exit() aria2GUI:delete() aria2GUI=nil end)
