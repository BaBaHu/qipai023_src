
local MaJiangJieSanLayer = class("MaJiangJieSanLayer", cc.load("mvc").DialogBase)
MaJiangJieSanLayer.RESOURCE_FILENAME = "game_erhzb/jiesan_set_layer.csb"

function MaJiangJieSanLayer:onCreate(params)
    self:setInOutEffectEnable(true)
    self:init(params)
    self:initUI()
end

function MaJiangJieSanLayer:init(params)
    -- body
    self.params = params
    cc.MENetUtil:clearGameClock(cc.MENetUtil:getChairID() )
    cc.MENetUtil:setEnableGameClock(false)
    print("MaJiangJieSanLayer:init...............", self.params)
    self:setTargetUIChair()
    self:addEventListener(EventMsgDefine.DismissVoteNotify,self.DismissVoteNotify,self)
end

function MaJiangJieSanLayer:onClear()
    print("MaJiangJieSanLayer:onClear() -----------------------------------------")
    if self.schedulerID ~= nil then
        me.Scheduler:unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil
    end
end

function MaJiangJieSanLayer:StartTimer()
    if self.schedulerID ~= nil then
        me.Scheduler:unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil
    end
    local nCurTime = 300
    local function tick()
        nCurTime = nCurTime - 1
        print("nCurTime =======================", nCurTime)
        self._children["labelTime"]:setString(nCurTime)
        if nCurTime <= 0 then
            if self.schedulerID ~= nil then
                me.Scheduler:unscheduleScriptEntry(self.schedulerID)
                self.schedulerID = nil
            end
            if self.params.dwRequesterID ~= cc.MENetUtil:getChairID() then
                cc.MENetUtil:dismisCustomServerVote(1)
            end
        end
    end
    self.schedulerID = me.Scheduler:scheduleScriptFunc(tick, 1.0, false)
end

function MaJiangJieSanLayer:initUI()
    self._children["labelText"]:setString("玩家[" .. cc.MENetUtil:getUserNameByID(self.params.dwRequesterID) .. "]申请解散房间，请等待其他玩家选择（超过5分钟没有选择，则默认同意）")

    self._children["btn_age"]:addClickEventListener(function() 
        cc.MENetUtil:dismisCustomServerVote(1)
        self._children["btn_age"]:setVisible(false)
        self._children["btn_def"]:setVisible(false)
    end)

    self._children["btn_def"]:addClickEventListener(function()
        cc.MENetUtil:dismisCustomServerVote(2)
        self._children["btn_age"]:setVisible(false)
        self._children["btn_def"]:setVisible(false)
    end)

    if self.params.dwRequesterID == cc.MENetUtil:getChairID() then
        self._children["btn_age"]:setVisible(false)
        self._children["btn_def"]:setVisible(false)
    end

    for i=1,3 do
        self._children["labelTips" .. i]:setString("") 
    end

    if self.params.nType == 1 then
        local strResult = ""
        if self.params.cbStatus == 0 then
            strResult = " 等待选择"
        elseif self.params.cbStatus == 1 then
            strResult = " 同意"
        elseif self.params.cbStatus == 2 then
            strResult = " 拒绝"
        end
        self._children["labelTips1"]:setString("[" .. self.params.nickName .. "]" .. strResult)
    else
        for i=0,3 do
            local user = self.params.users[i+1]
            if i ~= self.params.dwRequesterID and user ~= nil then
                local nIdx = self:getTargetUIChair( i )
                local strResult = ""
                if self.params.cbStatus[i+1] == 0 then
                    strResult = " 等待选择"
                elseif self.params.cbStatus[i+1] == 1 then
                    strResult = " 同意"
                elseif self.params.cbStatus[i+1] == 2 then
                    strResult = " 拒绝"
                end
                self._children["labelTips" .. nIdx]:setString("[" .. user.nickName .. "]" .. strResult)
            end
        end
    end
    self:StartTimer() 
end

function MaJiangJieSanLayer:setTargetUIChair()
    -- body
    self.tUIChairList = {}
    local nChairID = self.params.dwRequesterID
    if nChairID == 0 then
        self.tUIChairList[1] = 1
        self.tUIChairList[2] = 2
        self.tUIChairList[3] = 3
        self.tUIChairList[3] = 3
    elseif nChairID == 1 then
        self.tUIChairList[1] = 2
        self.tUIChairList[2] = 3
        self.tUIChairList[3] = 0
    elseif nChairID == 2 then
        self.tUIChairList[1] = 3
        self.tUIChairList[2] = 0
        self.tUIChairList[3] = 1
    elseif nChairID == 3 then
        self.tUIChairList[1] = 0
        self.tUIChairList[2] = 1
        self.tUIChairList[3] = 2
    end
end

function MaJiangJieSanLayer:getTargetUIChair( nChairID )
    -- body
    for k,v in pairs(self.tUIChairList) do
        if v == nChairID then
            return k
        end
    end
    return nil
end

function MaJiangJieSanLayer:DismissVoteNotify( data )
    -- body
    if self.params.nType == 1 then
        for i=0,1 do
            if i ~= self.params.dwRequesterID then
                local strResult = ""
                if data.cbStatus[i+1] == 0 then
                    strResult = "等待选择"
                elseif data.cbStatus[i+1] == 1 then
                    strResult = "同意"
                elseif data.cbStatus[i+1] == 2 then
                    strResult = "拒绝"
                end
                self._children["labelTips1"]:setString("[" .. self.params.nickName .. "]" .. strResult)
            end
        end
    else
        for i=0,3 do
            local user = self.params.users[i+1]
            if i ~= self.params.dwRequesterID and user ~= nil then
                local nIdx = self:getTargetUIChair( i )
                local strResult = ""
                if data.cbStatus[i+1] == 0 then
                    strResult = "等待选择"
                elseif data.cbStatus[i+1] == 1 then
                    strResult = "同意"
                elseif data.cbStatus[i+1] == 2 then
                    strResult = "拒绝"
                end
                self._children["labelTips" .. nIdx]:setString("[" .. user.nickName .. "]" .. strResult) 
            end
        end
    end
end

return MaJiangJieSanLayer
