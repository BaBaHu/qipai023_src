
local MajiangGameRankLayer = class("MajiangGameRankLayer", cc.load("mvc").DialogBase)
MajiangGameRankLayer.RESOURCE_FILENAME = "rank_layer.csb"

function MajiangGameRankLayer:onCreate(kindID)   
    self:setInOutEffectEnable(true)
    self:initData(kindID)
    self:initUI()
end

function MajiangGameRankLayer:initData(kindID)
    self.kindID = kindID
end

function MajiangGameRankLayer:initUI()
    local function removeSelf(pSender)
        app:backDialog()
    end
    self._children["btn_close"]:addClickEventListener(removeSelf)
    
    self:registerKeyboardListener(function ( ... )
        -- body
        removeSelf()
    end)

    if self.kindID == 351 then
        self._children["imgTitle"]:loadTexture("errenhzb.png", ccui.TextureResType.plistType)
    elseif self.kindID == 350 then
        self._children["imgTitle"]:loadTexture("sirhzb.png", ccui.TextureResType.plistType)
    elseif self.kindID == 301 then
        self._children["imgTitle"]:loadTexture("xzyj_title.png", ccui.TextureResType.plistType)
    elseif self.kindID == 302 then
        self._children["imgTitle"]:loadTexture("xzmj.png", ccui.TextureResType.plistType)
    end
    self._children["labTime"]:setString("")
    self._children["labelRule"]:setString("")
    self._children["labelPrizeRule"]:setString("")
    for i=1,10 do
        self._children["Panel" .. i]:setVisible(false)
    end

    GameLogicManager:getRank(self.kindID, function(event)
        -- body
        print("event = ", event)
        self:initView(event)
    end)
end

function MajiangGameRankLayer:initView(data)
    -- body
    self._children["labTime"]:setString("活动时间：" .. data.RoomAwardConfig.AwardTime)
    self._children["labelRule"]:setString("排名规则：根据用户在" .. data.RoomAwardConfig.KindName .. "麻将中，碰杠数量进行排名。")
    
    local prizeRule = "奖励规则："
    if data.RoomAwardConfig.Prize1 > 0 then
        prizeRule = prizeRule .. "第一名" .. data.RoomAwardConfig.Prize1 .. "金币"
    end
    if data.RoomAwardConfig.Prize2 > 0 then
        prizeRule = prizeRule .. "，第二名" .. data.RoomAwardConfig.Prize2 .. "金币"
    end
    if data.RoomAwardConfig.Prize3 > 0 then
        prizeRule = prizeRule .. "，第三名" .. data.RoomAwardConfig.Prize3 .. "金币"
    end
    local n = 0
    if data.RoomAwardConfig.Prize4 > 0 then
        n = data.RoomAwardConfig.Prize4
    end
    if data.RoomAwardConfig.Prize5 > 0 then
        n = data.RoomAwardConfig.Prize5
    end
    if data.RoomAwardConfig.Prize6 > 0 then
        n = data.RoomAwardConfig.Prize6
    end
    if n > 0 then
        prizeRule = prizeRule .. "，第4-6名" .. n .. "金币"
    end

    n = 0
    if data.RoomAwardConfig.Prize7 > 0 then
        n = data.RoomAwardConfig.Prize7
    end
    if data.RoomAwardConfig.Prize8 > 0 then
        n = data.RoomAwardConfig.Prize8
    end
    if data.RoomAwardConfig.Prize9 > 0 then
        n = data.RoomAwardConfig.Prize9
    end
    if data.RoomAwardConfig.Prize10 > 0 then
        n = data.RoomAwardConfig.Prize10
    end
    if n > 0 then
        prizeRule = prizeRule .. "，第7-10名" .. n .. "金币"
    end
    self._children["labelPrizeRule"]:setString(prizeRule)

    for i=1,10 do
        local tData = data.UserRoomAwardInfo[i]
        if tData ~= nil then
            self._children["Panel" .. i]:setVisible(true)
            self._children["Panel" .. i]:getChildByName("labName"):setString(tData.Accounts)
            self._children["Panel" .. i]:getChildByName("labCount"):setString(tData.Grade)
            self._children["Panel" .. i]:getChildByName("labRank"):setString(tData.Prize)
        end
    end
end

return MajiangGameRankLayer
