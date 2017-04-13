netspeed_loaded = true
function gain_after()
    in_seq2 = hs.execute(in_str)
    out_seq2 = hs.execute(out_str)
end

function data_diff()
    in_seq1 = hs.execute(in_str)
    out_seq1 = hs.execute(out_str)
    if gainagain == nil then
        gainagain = hs.timer.doAfter(1,function() in_seq2 = hs.execute(in_str) out_seq2 = hs.execute(out_str) end)
    else
        gainagain:start()
    end

    if out_seq2 ~= nil then
        in_diff = in_seq1 - in_seq2
        out_diff = out_seq1 - out_seq2
        if in_diff/1024 > 1024 then
            kbin = string.format("%.2f",in_diff/1024/1024) .. 'mb/s'
        else
            kbin = string.format("%.1f",in_diff/1024) .. 'kb/s'
        end
        if out_diff/1024 > 1024 then
            kbout = string.format("%.2f",out_diff/1024/1024) .. 'mb/s'
        else
            kbout = string.format("%.1f",out_diff/1024) .. 'kb/s'
        end
        disp_str = ' ⥂ '..kbin..' ⥄ '..kbout..' '
        modal_show:setText(disp_str)
    end
end

function disp_netspeed()
    activeInterface = hs.network.primaryInterfaces()
    if activeInterface ~= false then
        in_str = 'netstat -ibn | grep -e ' .. activeInterface .. ' -m 1 | awk \'{print $7}\''
        out_str = 'netstat -ibn | grep -e ' .. activeInterface .. ' -m 1 | awk \'{print $10}\''
        data_diff()
        if nettimer == nil then
            nettimer = hs.timer.doEvery(1,data_diff)
        else
            nettimer:start()
        end
    end
end

if not launch_netspeed then launch_netspeed=true end
if launch_netspeed == true then modal_stat('netspeed',black50) disp_netspeed() end
