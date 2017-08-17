--- === ClipShow ===
---
--- Show the content of system clipboard
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/ClipShow.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/ClipShow.spoon.zip)

local obj={}
obj.__index = obj

-- Metadata
obj.name = "ClipShow"
obj.version = "1.0"
obj.author = "ashfinal <ashfinal@gmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.canvas = nil
obj.ccount = nil
obj.lastsession = nil


function obj:init()
    obj.canvas = hs.canvas.new({x=0, y=0, w=0, h=0})
    obj.canvas[1] = {
        type = "rectangle",
        action = "fill",
        fillColor = {hex="#000000", alpha=0.75}
    }
    obj.canvas[2] = {
        type = "segments",
        strokeColor = {hex = "#FFFFFF", alpha = 0.1},
        coordinates = {
            {x="1%", y="72%"},
            {x="72%", y="72%"}
        }
    }
    obj.canvas[3] = {
        type = "segments",
        strokeColor = {hex = "#FFFFFF", alpha = 0.1},
        coordinates = {
            {x="72%", y="1%"},
            {x="72%", y="99%"}
        }
    }
    obj.canvas[4] = {type = "text", text = ""}
    obj.canvas[5] = {type = "text"}
    obj.canvas:level(hs.canvas.windowLevels.tornOffMenu)
end

local function isFileKinds(val, tbl)
    for _, v in ipairs(tbl) do
        if val == v then
            return true
        end
    end
    return false
end

-- Resize the ClipShow canvas
function obj:adjustCanvas()
    local cscreen = hs.screen.mainScreen()
    local cres = cscreen:fullFrame()
    obj.canvas:frame({
        x = cres.x+cres.w*0.15/2,
        y = cres.y+cres.h*0.25/2,
        w = cres.w*0.85,
        h = cres.h*0.75
    })
end

-- Fill clipshowM's keybindings in sidebar
function obj:fillModalKeys()
    if #obj.canvas < 6 then
        local modal = spoon.ModalMgr.modal_list["clipshowM"]
        if modal then
            local keys_pool = {}
            for _, v in ipairs(modal.keys) do
                table.insert(keys_pool, v.msg)
            end
            for idx, val in ipairs(keys_pool) do
                obj.canvas[idx + 5] = {
                    type = "text",
                    text = val,
                    textFont = "Courier-Bold",
                    textSize = 16,
                    textColor = {hex = "#2390FF", alpha = 1},
                    frame = {
                        x = "74%",
                        y = tostring(idx * 30 / (obj.canvas:frame().h - 60)),
                        w = "24%",
                        h = tostring(30 / (obj.canvas:frame().h - 60))
                    }
                }
            end
        end
    end
end

--- ClipShow:toggleShow()
--- Method
--- Process the content of system clipboard and show/hide the canvas
---

function obj:processClipboard()
    local clip_type = hs.pasteboard.typesAvailable()
    if clip_type.image then
        if clip_type.URL then
            local urltbl = hs.pasteboard.readURL()
            if urltbl.filePath then
                -- local file
                local fex = urltbl.filePath:match(".*%.(%w+)$") or ""
                local image_ex = {"jpeg", "jpg", "gif", "png", "bmp", "tiff", "icns"}
                local text_ex = {"", "txt", "md", "markdown", "mkd", "rst", "org", "sh", "zsh", "json", "yml", "mk", "config", "conf", "pub", "gitignore"}
                if isFileKinds(fex:lower(), image_ex) then
                    local imagedata = hs.image.imageFromPath(urltbl.filePath)
                    obj.canvas[4] = {
                        type = "image",
                        image = imagedata,
                        frame = {
                            x = "1%",
                            y = "1%",
                            w = "70%",
                            h = "70%"
                        }
                    }
                elseif isFileKinds(fex:lower(), text_ex) then
                    -- text file format
                    local file_handler = io.open(urltbl.filePath)
                    if file_handler then
                        local file_content = file_handler:read(1000)
                        if file_content then
                            obj.canvas[4] = {
                                type = "text",
                                text = file_content,
                                textSize = 20,
                                frame = {
                                    x = "1%",
                                    y = "1%",
                                    w = "70%",
                                    h = "70%"
                                }
                            }
                            file_handler:close()
                        else
                            -- Maybe directory
                            local dir_name = urltbl.filePath
                            obj.canvas[4] = {
                                type = "text",
                                text = dir_name,
                                frame = {
                                    x = "1%",
                                    y = "1%",
                                    w = "70%",
                                    h = "70%"
                                }
                            }
                        end
                    else
                        print("-- ClipShow: No access to this file!")
                    end
                else
                    local stringdata = table.concat(hs.pasteboard.readString(nil, true))
                    obj.canvas[4] = {
                        type = "text",
                        text = stringdata,
                        frame = {
                            x = "1%",
                            y = "1%",
                            w = "70%",
                            h = "70%"
                        }
                    }
                end
            else
                -- Remote image
                local imagedata = hs.pasteboard.readImage()
                obj.canvas[4] = {
                    type = "image",
                    image = imagedata,
                    frame = {
                        x = "1%",
                        y = "1%",
                        w = "70%",
                        h = "70%"
                    }
                }
            end
        else
            -- Image fragement
            local imagedata = hs.pasteboard.readImage()
            obj.canvas[4] = {
                type = "image",
                image = imagedata,
                frame = {
                    x = "1%",
                    y = "1%",
                    w = "70%",
                    h = "70%"
                }
            }
        end
        obj:adjustCanvas()
        obj:fillModalKeys()
        obj.canvas:show()
    elseif clip_type.URL then
        local urltbl = hs.pasteboard.readURL(nil, true)
        if urltbl then
            if #urltbl > 1 then
                local stringdata = table.concat(hs.pasteboard.readString(nil, true))
                obj.canvas[4] = {
                    type = "text",
                    text = stringdata,
                    frame = {
                        x = "1%",
                        y = "1%",
                        w = "70%",
                        h = "70%"
                    }
                }
                obj:adjustCanvas()
                obj:fillModalKeys()
                obj.canvas:show()
            else
                local browser = hs.urlevent.getDefaultHandler("http")
                hs.urlevent.openURLWithBundle(urltbl[1].url, browser)
            end
        else
            local browser = hs.urlevent.getDefaultHandler("http")
            hs.urlevent.openURLWithBundle(urltbl[1].url, browser)
        end
    elseif clip_type.string then
        local stringdata = table.concat(hs.pasteboard.readString(nil, true))
        obj.canvas[4] = {
            type = "text",
            text = stringdata,
            frame = {
                x = "1%",
                y = "1%",
                w = "70%",
                h = "70%"
            }
        }
        obj:adjustCanvas()
        obj:fillModalKeys()
        obj.canvas:show()
    end
end

function obj:toggleShow()
    if obj.canvas:isShowing() then
        obj.canvas:hide()
    else
        local change_count = hs.pasteboard.changeCount()
        -- Only if content of the clipboard changed then we redraw the canvas
        if change_count ~= obj.ccount then
            obj:processClipboard()
            obj.ccount = change_count
        else
            obj:adjustCanvas()
            obj.canvas:show()
        end
    end
end

--- ClipShow:openInBrowserWithRef(refstr)
--- Method
--- Open content of the clipboard in default browser with specific refstr.
---
--- Parameters:
---  * refstr - A optional string specifying which refstr to use. If nil, then open this content in browser directly. The "refstr" could be something like this: `https://www.bing.com/search?q=`.

local function acquireText()
    if obj.canvas:isShowing() then
        if obj.canvas[4].type == "text" then
            return obj.canvas[4].text
        else
            return hs.pasteboard.readString() or ""
        end
    else
        return hs.pasteboard.readString() or ""
    end
end

function obj:openInBrowserWithRef(refstr)
    local querystr = acquireText()
    if refstr then
        local encoded_query = hs.http.encodeForQuery(refstr .. querystr)
        local defaultbrowser = hs.urlevent.getDefaultHandler("http")
        hs.urlevent.openURLWithBundle(encoded_query, defaultbrowser)
    else
        local defaultbrowser = hs.urlevent.getDefaultHandler("http")
        hs.urlevent.openURLWithBundle(querystr, defaultbrowser)
    end
end

--- ClipShow:saveToSession()
--- Method
--- Save clipboard session so we can restore it later
---

function obj:saveToSession()
    obj.lastsession = hs.pasteboard.readAllData()
    if obj.canvas:isShowing() then
        if obj.canvas[4].type == "text" then
            local cdraw = obj.canvas[4].text
            hs.pasteboard.writeObjects(cdraw)
            obj.canvas[5] = {
                type = "text",
                text = cdraw,
                textSize = 16,
                textAlignment = "center",
                frame = {
                    x = "1%",
                    y = "73%",
                    w = "70%",
                    h = "26%"
                }
            }
        elseif obj.canvas[4].type == "image" then
            local cdraw = obj.canvas[4].image
            hs.pasteboard.writeObjects(cdraw)
            obj.canvas[5] = {
                type = "image",
                image = cdraw,
                frame = {
                    x = "1%",
                    y = "73%",
                    w = "70%",
                    h = "26%"
                }
            }
        end
    end
end

--- ClipShow:restoreLastSession()
--- Method
--- Restore the lastsession of system clipboard
---

function obj:restoreLastSession()
    if obj.lastsession then
        hs.pasteboard.writeAllData(obj.lastsession)
        obj:processClipboard()
        obj.ccount = change_count
    end
end

--- ClipShow:saveToFile()
--- Method
--- Save content of current canvas to a file, the default location is `~/Desktop/`.
---

function obj:saveToFile()
    if obj.canvas:isShowing() then
        if obj.canvas[4].type == "image" then
            local cdraw = obj.canvas[4].image
            local file_name = os.date("%Y-%m-%d %H:%M:%S")
            cdraw:saveToFile("~/Desktop/" .. file_name .. ".png", true)
        elseif obj.canvas[4].type == "text" then
            local ctext = obj.canvas[4].text
            local file_name = os.date("%Y-%m-%d %H:%M:%S")
            local full_path = os.getenv("HOME") .. "/Desktop/" .. file_name .. ".txt"
            local file_handler = io.open(full_path, "w")
            file_handler:write(ctext)
            file_handler:close()
        end
    end
end

--- ClipShow:openWithCommand(command)
--- Method
--- Open local file with specific command.
---
--- Parameters:
---  * command - A string specifying which command to use. The "command" is something like this: `/usr/local/bin/mvim`.

function obj:openWithCommand(command)
    if obj.canvas:isShowing() then
        if obj.canvas[4].type == "text" then
            local urltbl = hs.pasteboard.readURL()
            if urltbl then
                if urltbl.filePath then
                    os.execute(command .. " " .. urltbl.filePath)
                else
                    os.execute(command)
                end
            else
                os.execute(command)
            end
        end
    end
end
return obj
