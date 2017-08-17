--- === SpeedMenu ===
---
--- Menubar netspeed meter
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SpeedMenu.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SpeedMenu.spoon.zip)

local obj={}
obj.__index = obj

-- Metadata
obj.name = "SpeedMenu"
obj.version = "1.0"
obj.author = "ashfinal <ashfinal@gmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

function obj:init()
    self.menubar = hs.menubar.new()
    obj:rescan()
end

local function data_diff()
    local in_seq = hs.execute(obj.instr)
    local out_seq = hs.execute(obj.outstr)
    local in_diff = in_seq - obj.inseq
    local out_diff = out_seq - obj.outseq
    if in_diff/1024 > 1024 then
        obj.kbin = string.format("%6.2f", in_diff/1024/1024) .. ' mb/s'
    else
        obj.kbin = string.format("%6.2f", in_diff/1024) .. ' kb/s'
    end
    if out_diff/1024 > 1024 then
        obj.kbout = string.format("%6.2f", out_diff/1024/1024) .. ' mb/s'
    else
        obj.kbout = string.format("%6.2f", out_diff/1024) .. ' kb/s'
    end
    local disp_str = '⥄ ' .. obj.kbout .. '\n⥂ ' .. obj.kbin
    if obj.darkmode then
        obj.disp_str = hs.styledtext.new(disp_str, {font={size=9.0, color={hex="#FFFFFF"}}})
    else
        obj.disp_str = hs.styledtext.new(disp_str, {font={size=9.0, color={hex="#000000"}}})
    end
    obj.menubar:setTitle(obj.disp_str)
    obj.inseq = in_seq
    obj.outseq = out_seq
end

--- SpeedMenu:rescan()
--- Method
--- Redetect the active interface, darkmode …And redraw everything.
---

function obj:rescan()
    obj.interface = hs.network.primaryInterfaces()
    obj.darkmode = hs.osascript.applescript('tell application "System Events"\nreturn dark mode of appearance preferences\nend tell')
    local menuitems_table = {}
    if obj.interface then
        -- Inspect active interface and create menuitems
        local interface_detail = hs.network.interfaceDetails(obj.interface)
        if interface_detail.AirPort then
            local ssid = interface_detail.AirPort.SSID
            table.insert(menuitems_table, {
                title = "SSID: " .. ssid,
                tooltip = "Copy SSID to clipboard",
                fn = function() hs.pasteboard.setContents(ssid) end
            })
        end
        if interface_detail.IPv4 then
            local ipv4 = interface_detail.IPv4.Addresses[1]
            table.insert(menuitems_table, {
                title = "IPv4: " .. ipv4,
                tooltip = "Copy IPv4 to clipboard",
                fn = function() hs.pasteboard.setContents(ipv4) end
            })
        end
        if interface_detail.IPv6 then
            local ipv6 = interface_detail.IPv6.Addresses[1]
            table.insert(menuitems_table, {
                title = "IPv6: " .. ipv6,
                tooltip = "Copy IPv6 to clipboard",
                fn = function() hs.pasteboard.setContents(ipv6) end
            })
        end
        local macaddr = hs.execute('ifconfig ' .. obj.interface .. ' | grep ether | awk \'{print $2}\'')
        table.insert(menuitems_table, {
            title = "MAC Addr: " .. macaddr,
            tooltip = "Copy MAC Address to clipboard",
            fn = function() hs.pasteboard.setContents(macaddr) end
        })
        -- Start watching the netspeed delta
        obj.instr = 'netstat -ibn | grep -e ' .. obj.interface .. ' -m 1 | awk \'{print $7}\''
        obj.outstr = 'netstat -ibn | grep -e ' .. obj.interface .. ' -m 1 | awk \'{print $10}\''

        obj.inseq = hs.execute(obj.instr)
        obj.outseq = hs.execute(obj.outstr)

        if obj.timer then
            obj.timer:stop()
            obj.timer = nil
        end
        obj.timer = hs.timer.doEvery(1, data_diff)
    end
    table.insert(menuitems_table, {
        title = "Rescan Network Interfaces",
        fn = function() obj:rescan() end
    })
    obj.menubar:setTitle("⚠︎")
    obj.menubar:setMenu(menuitems_table)
end

return obj
