function gain_after()
    in_seq2 = hs.execute(in_str)
    out_seq2 = hs.execute(out_str)
end

function data_diff()
    in_seq1 = hs.execute(in_str)
    out_seq1 = hs.execute(out_str)
    gainagain = hs.timer.doAfter(1,function() in_seq2 = hs.execute(in_str) out_seq2 = hs.execute(out_str) end)

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
    ActiveInterface = hs.network.primaryInterfaces()
    if ActiveInterface ~= false then
        in_str = 'netstat -ibn | grep -e ' .. ActiveInterface .. ' -m 1 | awk \'{print $7}\''
        out_str = 'netstat -ibn | grep -e ' .. ActiveInterface .. ' -m 1 | awk \'{print $10}\''
        data_diff()
        nettimer = hs.timer.doEvery(1,data_diff)
    end
end

netspeedM = hs.hotkey.modal.new({'cmd','alt','ctrl'}, 'N')
table.insert(modal_list, netspeedM)
function netspeedM:entered() modal_stat('netspeed',gray) disp_netspeed() end
function netspeedM:exited()
    if dock_launched then
        modal_stat('dock',black)
    else
        modal_bg:hide()
        modal_show:hide()
    end
    if nettimer ~= nil then nettimer:stop() end
end
netspeedM:bind('alt', 'N', function() netspeedM:exit() end)
