------------------------------------------------------------------------
--/ Cheatsheet Copycat /--
------------------------------------------------------------------------

hs.application.menuGlyphs[148]="fn fn"

commandEnum = {
    cmd = '⌘',
    shift = '⇧',
    alt = '⌥',
    ctrl = '⌃',
}

function getAllMenuItems(t)
    local menu = ""
        for pos,val in pairs(t) do
            if type(val)=="table" then
                -- TODO: Remove menubar items with no shortcuts in them
                if val.AXRole =="AXMenuBarItem" and type(val.AXChildren) == "table" then
                    menu = menu.."<ul class='col col"..pos.."'>"
                    menu = menu.."<li class='title'><strong>"..val.AXTitle.."</strong></li>"
                    menu = menu.. getAllMenuItems(val.AXChildren[1])
                    menu = menu.."</ul>"
                elseif val.AXRole =="AXMenuItem" and not val.AXChildren then
                    if not (val.AXMenuItemCmdChar == '' and val.AXMenuItemCmdGlyph == '') then
                        local CmdModifiers = ''
                        for key, value in pairs(val.AXMenuItemCmdModifiers) do
                            CmdModifiers = CmdModifiers..commandEnum[value]
                        end
                        local CmdChar = val.AXMenuItemCmdChar
                        local CmdGlyph = hs.application.menuGlyphs[val.AXMenuItemCmdGlyph] or ''
                        local CmdKeys = CmdChar..CmdGlyph
                        menu = menu.."<li><div class='cmdModifiers'>"..CmdModifiers.." "..CmdKeys.."</div><div class='cmdtext'>".." "..val.AXTitle.."</div></li>"
                    end
                elseif val.AXRole == "AXMenuItem" and type(val.AXChildren) == "table" then
                    menu = menu..getAllMenuItems(val.AXChildren[1])
                end

            end
        end
    return menu
end

function generateHtml()
    local focusedApp = hs.application.frontmostApplication()
    local appTitle = focusedApp:title()
    local allMenuItems = focusedApp:getMenuItems()
    local myMenuItems = getAllMenuItems(allMenuItems)

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
              <div class="title"><strong>]]..appTitle..[[</strong></div>
              <hr />
            </header>
            <div class="content maincontent">]]..myMenuItems..[[</div>
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

function showCheatsheet()
    if not cheatsheet_view then
        local mainScreen = hs.screen.mainScreen()
        local mainRes = mainScreen:fullFrame()
        local localMainRes = mainScreen:absoluteToLocal(mainRes)
        local cheatsheet_rect = mainScreen:localToAbsolute({
              x = (localMainRes.w-1080)/2,
              y = (localMainRes.h-600)/2,
              w = 1080,
              h = 600,
        })
        cheatsheet_view = hs.webview.new(cheatsheet_rect)
        :windowTitle("CheatSheets")
        :windowStyle("utility")
        :allowGestures(true)
        :allowNewWindows(false)
        :level(hs.drawing.windowLevels.modalPanel)
    end
    if cstimer ~= nil and cstimer:running() then
        cstimer:stop()
    end
    cheatsheet_view:show()
    cheatsheet_view:html(generateHtml())
end

cheatsheetM = hs.hotkey.modal.new()
local modalpkg = {}
modalpkg.id = "cheatsheetM"
modalpkg.modal = cheatsheetM
table.insert(modal_list, modalpkg)

function cheatsheetM:entered()
    for i=1,#modal_list do
        if modal_list[i].id == "cheatsheetM" then
            table.insert(activeModals, modal_list[i])
        end
    end
    showCheatsheet()
end

function cheatsheetM:exited()
    for i=1,#activeModals do
        if activeModals[i].id == "cheatsheetM" then
            table.remove(activeModals, i)
        end
    end
    if cheatsheet_view ~= nil then
        cheatsheet_view:hide()
        if cstimer == nil then
            cstimer = hs.timer.doAfter(10*60, function()
                if cheatsheet_view ~= nil then
                    cheatsheet_view:delete()
                    cheatsheet_view = nil
                end
            end)
        else
            cstimer:start()
        end
    end
end

cheatsheetM:bind('', 'escape', function() cheatsheetM:exit() end)
cheatsheetM:bind('', 'Q', function() cheatsheetM:exit() end)
