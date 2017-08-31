NetWorkManager = {}

function NetWorkManager:setup()
    print("NetWorkManager:setup() !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    if self._isValid == nil or not self._isValid then
        self._isValid = true
        self:check()
    end
end

function NetWorkManager:dispose()
    -- body
    self:close()
    self._isValid = false
    print("NetWorkManager:dispose() !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
end


function NetWorkManager:check()
    -- body
    if self._isValid then

        if self.schedulerID ~= nil then
            me.Scheduler:unscheduleScriptEntry(self.schedulerID)
            self.schedulerID = nil
        end
        local function tick()
           local ret = cc.MENetUtil:checkNetWork()
           print("ret =============================", ret)
        end
        self.schedulerID = me.Scheduler:scheduleScriptFunc(tick, 5, false)
    end
end


function NetWorkManager:close()
    -- body
    if self._isValid then
        
        if self.schedulerID ~= nil then
            me.Scheduler:unscheduleScriptEntry(self.schedulerID)
            self.schedulerID = nil
        end
    end
end

return NetWorkManager