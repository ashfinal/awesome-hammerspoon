--- === KSheet ===
---
--- Keybindings cheatsheet for current application
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/KSheet.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/KSheet.spoon.zip)

local obj={}
obj.__index = obj

-- Metadata
obj.name = "KSheet"
obj.version = "1.0"
obj.author = "ashfinal <ashfinal@gmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Workaround for "Dictation" menuitem
hs.application.menuGlyphs[148]="fn fn"

obj.commandEnum = {
    cmd = '⌘',
    shift = '⇧',
    alt = '⌥',
    ctrl = '⌃',
}

function obj:init()
    self.sheetView = hs.webview.new({x=0, y=0, w=0, h=0})
    self.sheetView:windowTitle("CheatSheets")
    self.sheetView:windowStyle("utility")
    self.sheetView:allowGestures(true)
    self.sheetView:allowNewWindows(false)
    self.sheetView:level(hs.drawing.windowLevels.modalPanel)
end

local function processMenuItems(menustru)
    local menu = ""
        for pos,val in pairs(menustru) do
            if type(val) == "table" then
                -- TODO: Remove menubar items with no shortcuts in them
                if val.AXRole == "AXMenuBarItem" and type(val.AXChildren) == "table" then
                    menu = menu .. "<ul class='col col" .. pos .. "'>"
                    menu = menu .. "<li class='title'><strong>" .. val.AXTitle .. "</strong></li>"
                    menu = menu .. processMenuItems(val.AXChildren[1])
                    menu = menu .. "</ul>"
                elseif val.AXRole == "AXMenuItem" and not val.AXChildren then
                    if not (val.AXMenuItemCmdChar == '' and val.AXMenuItemCmdGlyph == '') then
                        local CmdModifiers = ''
                        for key, value in pairs(val.AXMenuItemCmdModifiers) do
                            CmdModifiers = CmdModifiers .. obj.commandEnum[value]
                        end
                        local CmdChar = val.AXMenuItemCmdChar
                        local CmdGlyph = hs.application.menuGlyphs[val.AXMenuItemCmdGlyph] or ''
                        local CmdKeys = CmdChar .. CmdGlyph
                        menu = menu .. "<li><div class='cmdModifiers'>" .. CmdModifiers .. " " .. CmdKeys .. "</div><div class='cmdtext'>" .. " " .. val.AXTitle .. "</div></li>"
                    end
                elseif val.AXRole == "AXMenuItem" and type(val.AXChildren) == "table" then
                    menu = menu .. processMenuItems(val.AXChildren[1])
                end
            end
        end
    return menu
end

local function generateHtml(application)
    local app_title = application:title()
    local menuitems_tree = application:getMenuItems()
    local allmenuitems = processMenuItems(menuitems_tree)

    local html = [[
        <!DOCTYPE html>
        <html>
        <head>
        <style type="text/css">
            *{margin:0; padding:0;}
            html, body{
              background-color:#eee;
              font-family: arial;
              font-size: 13px;
            }
            a{
              text-decoration:none;
              color:#000;
              font-size:12px;
            }
            li.title{ text-align:center;}
            ul, li{list-style: inside none; padding: 0 0 5px;}
            footer{
              position: fixed;
              left: 0;
              right: 0;
              height: 48px;
              background-color:#eee;
            }
            header{
              position: fixed;
              top: 0;
              left: 0;
              right: 0;
              height:48px;
              background-color:#eee;
              z-index:99;
            }
            footer{ bottom: 0; }
            header hr,
            footer hr {
              border: 0;
              height: 0;
              border-top: 1px solid rgba(0, 0, 0, 0.1);
              border-bottom: 1px solid rgba(255, 255, 255, 0.3);
            }
            .title{
                padding: 15px;
            }
            li.title{padding: 0  10px 15px}
            .content{
              padding: 0 0 15px;
              font-size:12px;
              overflow:hidden;
            }
            .content.maincontent{
            position: relative;
              height: 577px;
              margin-top: 46px;
            }
            .content > .col{
              width: 23%;
              padding:20px 0 20px 20px;
            }

            li:after{
              visibility: hidden;
              display: block;
              font-size: 0;
              content: " ";
              clear: both;
              height: 0;
            }
            .cmdModifiers{
              width: 60px;
              padding-right: 15px;
              text-align: right;
              float: left;
              font-weight: bold;
            }
            .cmdtext{
              float: left;
              overflow: hidden;
              width: 165px;
            }
        </style>
        </head>
          <body>
            <header>
              <div class="title"><strong>]] .. app_title .. [[</strong></div>
              <hr />
            </header>
            <div class="content maincontent">]] .. allmenuitems .. [[</div>
            <br>

          <footer>
            <hr />
              <div class="content" >
                <div class="col">
                  by <a href="https://github.com/dharmapoudel" target="_parent">dharma poudel</a>
                </div>
              </div>
          </footer>
          <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.isotope/2.2.2/isotope.pkgd.min.js"></script>
            <script type="text/javascript">
              var elem = document.querySelector('.content');
              var iso = new Isotope( elem, {
                // options
                itemSelector: '.col',
                layoutMode: 'masonry'
              });
            </script>
          </body>
        </html>
        ]]

    return html
end

--- KSheet:show()
--- Method
--- Show current application's keybindings in a webview
---

function obj:show()
    local capp = hs.application.frontmostApplication()
    local cscreen = hs.screen.mainScreen()
    local cres = cscreen:fullFrame()
    self.sheetView:frame({
        x = cres.x+cres.w*0.15/2,
        y = cres.y+cres.h*0.25/2,
        w = cres.w*0.85,
        h = cres.h*0.75
    })
    local webcontent = generateHtml(capp)
    self.sheetView:html(webcontent)
    self.sheetView:show()
end

--- KSheet:hide()
--- Method
--- Hide the cheatsheet webview
---

function obj:hide()
    self.sheetView:hide()
end

return obj
