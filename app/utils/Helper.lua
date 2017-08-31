Helper = {}

require("crypt")

function Helper:scheduleOnce(delay, fn)
    local scheduleID = nil
    local function callfunc(delta)
        local ret, errmsg = pcall(fn, delta)
        if errmsg then
            printError(errmsg)
        end
        if scheduleID then
            me.Scheduler:unscheduleScriptEntry(scheduleID)
        end
    end
    scheduleID = me.Scheduler:scheduleScriptFunc(callfunc, delay, false)
    return scheduleID
end


function Helper:md5sum(k)
    k = crypt.md5(k)


    return (string.gsub(k, ".", function (c)
               return string.format("%02x", string.byte(c))
             end))
end


function Helper:getFileNameByUrl(srcUrl, md5)
    local ext = me.FileUtils:getFileExtension(srcUrl)
    if string.len(ext) ~= 4 then
        ext = ".png"
    end
    local filename = md5 .. ext
    return filename
end


function Helper:GetTupleTableFormat( stringTab )
    -- body
    local ret = {}
    local t = string.split(stringTab, "+")
    for k,v in pairs(t) do
        ret[k] = tonumber(v)
    end
    return ret
end

function Helper:stringFormatRoomID(roomId)
    return string.format("%06d", roomId)
end

return Helper
