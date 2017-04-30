function data_diff()
    local in_seq1 = hs.execute(netspeed_in_str)
    local out_seq1 = hs.execute(netspeed_out_str)
    if gainagain == nil then
        gainagain = hs.timer.doAfter(1,function()
            in_seq2 = hs.execute(netspeed_in_str)
            out_seq2 = hs.execute(netspeed_out_str)
        end)
    else
        gainagain:start()
    end

    if out_seq2 ~= nil then
        local in_diff = in_seq1 - in_seq2
        local out_diff = out_seq1 - out_seq2
        if in_diff/1024 > 1024 then
            kbin = string.format("%6.2f",in_diff/1024/1024) .. ' mb/s'
        else
            kbin = string.format("%6.2f",in_diff/1024) .. ' kb/s'
        end
        if out_diff/1024 > 1024 then
            kbout = string.format("%6.2f",out_diff/1024/1024) .. ' mb/s'
        else
            kbout = string.format("%6.2f",out_diff/1024) .. ' kb/s'
        end
        local disp_str = '⥄ '..kbout..'\n⥂ '..kbin
        if darkmode_status then
            styled_disp_str = hs.styledtext.new(disp_str,{font={size=9.0,color=white}})
        else
            styled_disp_str = hs.styledtext.new(disp_str,{font={size=9.0,color=black}})
        end
        if not netspeed_menubar then
            netspeed_menubar = hs.menubar.new()
        end
        netspeed_menubar:setTitle(styled_disp_str)
    end
end

local active_interface = hs.network.primaryInterfaces()
local darkmode_status = hs.osascript.applescript('tell application "System Events"\nreturn dark mode of appearance preferences\nend tell')
if active_interface ~= false then
    netspeed_in_str = 'netstat -ibn | grep -e ' .. active_interface .. ' -m 1 | awk \'{print $7}\''
    netspeed_out_str = 'netstat -ibn | grep -e ' .. active_interface .. ' -m 1 | awk \'{print $10}\''
    data_diff()
    if nettimer == nil then
        nettimer = hs.timer.doEvery(1,data_diff)
    else
        nettimer:start()
    end
end
