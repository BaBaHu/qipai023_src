NoticeMessageListener = {}

--初始化
function NoticeMessageListener:setup()
    if self._isValid == nil or self._isValid == false then
        self._isValid = true --是否有效
        
        self.msg_list = {}
        self.isFirst = true
        self:initEvent()
    end
end 

function NoticeMessageListener:initEvent()
    -- body
    if self.schedulerID ~= nil then
        me.Scheduler:unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil
    end
    local function tick()
        self:notify()
    end
    self.schedulerID = me.Scheduler:scheduleScriptFunc(tick, 14.0, false)

    local function OnNoticeMsgBackListener(msg)
        -- body
        self.msg_list[#self.msg_list + 1] = msg
        print("self.msg_list add count = ", #self.msg_list)
        if self.isFirst then
            self.isFirst = false
            self:notify()
        end
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onNoticeMsgBack", OnNoticeMsgBackListener)
end


function NoticeMessageListener:dispose()
    -- body
    --print("NoticeMessageListener:dispose ......................................")
    if self.schedulerID ~= nil then
        me.Scheduler:unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil
    end
    
    self.msg_list = {}
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onNoticeMsgBack")
    self._isValid = false
end

function NoticeMessageListener:notify()
    -- body
    --print("NoticeMessageListener:notify()..........................")
    if #self.msg_list <= 0 then
        self.isFirst = true
        return
    end
    self.isFirst = false
    local data = self.msg_list[1]
    if data ~= nil then
        EventDispatcher:dispatchEvent(EventMsgDefine.ShowNoticeMsg, data)
        table.remove(self.msg_list, 1)
    end
    print("self.msg_list remove count = ", #self.msg_list)
end

return NoticeMessageListener