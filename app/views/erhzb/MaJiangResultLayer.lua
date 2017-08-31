
local MaJiangResultLayer = class("MaJiangResultLayer", cc.load("mvc").DialogBase)
local helper   = require("app.views.erhzb.helper")
local DDMaJiang = require("app.views.erhzb.DDMaJiang")
MaJiangResultLayer.RESOURCE_FILENAME = "game_erhzb/result_layer.csb"

function MaJiangResultLayer:onCreate(data) 
    print("MaJiangResultLayer:onCreate(data).............", data)

    local nPos = cc.p(self._children["panel"]:getPosition())
    local s = self._children["panel"]:getContentSize()
    self._children["panel"]:setPosition(cc.p(nPos.x, display.height + s.height))
    local seq = cc.Sequence:create(
        cc.MoveTo:create(0.5, nPos),
        cc.CallFunc:create(function()
            self:showButtonEffect()
        end)
    )
    self._children["panel"]:runAction(seq) 

    for i=1,4 do
        self._children["lab_name" .. i]:setString("")
        self._children["lab_gang_score" .. i]:setString("")
        self._children["lab_score" .. i]:setString("")
        self._children["lab_zimo" .. i]:setString("")
    end
    
    self._children["lab_pai_type"]:setString(data.str_hu)
    for i=1, data.playerCount do
        self._children["lab_name" .. i]:setString(data.name[i])
        self._children["lab_gang_score" .. i]:setString(data.lGangScore[i])
        self._children["lab_score" .. i]:setString(data.lGameScore[i])
        self._children["lab_zimo" .. i]:setString(data.result[i])
    end

    if data.isWin then
        self._children["ImgTitle"]:loadTexture("titlebg.png", ccui.TextureResType.plistType)
        self._children["ImgResult"]:loadTexture("u_win.png", ccui.TextureResType.plistType)
    else
        self._children["ImgTitle"]:loadTexture("grey_top.png", ccui.TextureResType.plistType)
        self._children["ImgResult"]:loadTexture("u_lose.png", ccui.TextureResType.plistType)
    end
    local nChairID = cc.MENetUtil:getChairID()

    --显示麻将
    local s = self._children["cardPanel"]:getContentSize()
    local n = 1
    local x = 0
    for k,v in pairs(data.state_list.peng) do
        for i=1, 3 do
            local p_mj = DDMaJiang.new(true,1, k)
            p_mj:setScale(0.7)
            p_mj:setPosition((n-1)*p_mj:getContentSize().width*0.7 - x, s.height/2)
            self._children["cardPanel"]:addChild(p_mj)
            n = n + 1
        end
        n = n + 1
        x = x + 70
    end

    for k,v in pairs(data.state_list.an_gang) do
        for i=1, 3 do
            local p_mj = DDMaJiang.new(true,2, k)
            p_mj:setScale(0.7)
            p_mj:setPosition((n-1)*p_mj:getContentSize().width*0.7 - x, s.height/2)
            self._children["cardPanel"]:addChild(p_mj)

            if i == 2 then
                local bg_pai2 = DDMaJiang.new(true,1, k)
                bg_pai2:setPosition(p_mj:getContentSize().width/2, p_mj:getContentSize().height/2+15)
                p_mj:addChild(bg_pai2,10)
            end
            n = n + 1
        end
        n = n + 1
        x = x + 70
    end

    for k,v in pairs(data.state_list.ming_gang) do
        for i=1, 3 do
            local p_mj = DDMaJiang.new(true,1, k)
            p_mj:setScale(0.7)
            p_mj:setPosition((n-1)*p_mj:getContentSize().width*0.7 - x, s.height/2)
            self._children["cardPanel"]:addChild(p_mj)

            if i == 2 then
                local bg_pai2 = DDMaJiang.new(true,1, k)
                bg_pai2:setPosition(p_mj:getContentSize().width/2, p_mj:getContentSize().height/2+15)
                p_mj:addChild(bg_pai2,10)
            end
            n = n + 1
        end
        n = n + 1
        x = x + 70
    end

    for i=1,#data.paiList do
        if data.paiList[i] > 0 then
            local p_mj = DDMaJiang.new(true,1, helper.getPaiByIndex(data.paiList[i]) )
            p_mj:setScale(0.7)
            p_mj:setPosition((n-1)*p_mj:getContentSize().width*0.7 - x, s.height/2)
            self._children["cardPanel"]:addChild(p_mj)
            n = n + 1
        end
    end

    local function change(pSender)
        local tag = pSender:getTag()
        app:backDialog()
        print("tag ====================================", tag)
        if tag == 1 then
            EventDispatcher:dispatchEvent(EventMsgDefine.GameRoomOut)
        elseif tag == 2 then
            EventDispatcher:dispatchEvent(EventMsgDefine.GameShowCustomResult)
        end
    end
    self.bShowCustomResult = data.bShowCustomResult
    if data.bShowCustomResult then
        self._children["btn_ChangeRoom"]:loadTextures("btnover.png","btnover2.png","", ccui.TextureResType.plistType)
        self._children["btn_ChangeRoom"]:setTag(2)
    else
        self._children["btn_ChangeRoom"]:setTag(1)
    end
    self._children["btn_ChangeRoom"]:setVisible(false)
    self._children["btn_ChangeRoom"]:addClickEventListener(change)

    self._children["btn_share"]:setVisible(false)
    self._children["btn_share"]:addClickEventListener(function()
        if cc.MENetUtil:getUserType() == 2 then
            GameLogicManager:WeiXinShareScreen()
        else
            self:showTips("请切换微信登录，再使用分享功能！")
        end
    end)

    self._children["btn_Next"]:setVisible(false)
    self._children["btn_Next"]:addClickEventListener(function()
        app:backDialog()
        EventDispatcher:dispatchEvent(EventMsgDefine.GameNext)
    end)
    local seq = cc.Sequence:create(
        cc.DelayTime:create(1.3),
        cc.CallFunc:create(function()
            EventDispatcher:dispatchEvent(EventMsgDefine.GameReset)    
        end)
    )
    self._children["panel"]:runAction(seq)
end

function MaJiangResultLayer:showButtonEffect()
    -- body
    if cc.MENetUtil:isCustomServer() then
        if not self.bShowCustomResult then
            self._children["btn_share"]:setPosition(cc.p(self._children["btn_ChangeRoom"]:getPosition() ))
            self._children["btn_share"]:setScale(0) 
            self._children["btn_share"]:setVisible(true)
            local seq = cc.Sequence:create(
                cc.DelayTime:create(1),
                cc.ScaleTo:create(0.3,1.1),
                cc.ScaleTo:create(0.1,0.95),
                cc.ScaleTo:create(0.05,1))
            self._children["btn_share"]:runAction(seq)

            self._children["btn_Next"]:setScale(0) 
            self._children["btn_Next"]:setVisible(true)
            local seq = cc.Sequence:create(
                cc.DelayTime:create(1),
                cc.ScaleTo:create(0.3,1.1),
                cc.ScaleTo:create(0.1,0.95),
                cc.ScaleTo:create(0.05,1))
            self._children["btn_Next"]:runAction(seq)
        else
            self._children["btn_share"]:setPosition(cc.p(self._children["btn_Next"]:getPosition() ))
            self._children["btn_share"]:setScale(0) 
            self._children["btn_share"]:setVisible(true)
            local seq = cc.Sequence:create(
                cc.DelayTime:create(1),
                cc.ScaleTo:create(0.3,1.1),
                cc.ScaleTo:create(0.1,0.95),
                cc.ScaleTo:create(0.05,1))
            self._children["btn_share"]:runAction(seq)

            self._children["btn_ChangeRoom"]:setScale(0) 
            self._children["btn_ChangeRoom"]:setVisible(true)
            local seq = cc.Sequence:create(
                cc.DelayTime:create(1),
                cc.ScaleTo:create(0.3,1.1),
                cc.ScaleTo:create(0.1,0.95),
                cc.ScaleTo:create(0.05,1))
            self._children["btn_ChangeRoom"]:runAction(seq)
        end
    else
        self._children["btn_ChangeRoom"]:setScale(0) 
        self._children["btn_ChangeRoom"]:setVisible(true)
        local seq = cc.Sequence:create(
            cc.DelayTime:create(1),
            cc.ScaleTo:create(0.3,1.1),
            cc.ScaleTo:create(0.1,0.95),
            cc.ScaleTo:create(0.05,1))
        self._children["btn_ChangeRoom"]:runAction(seq)

        self._children["btn_share"]:setScale(0) 
        self._children["btn_share"]:setVisible(true)
        local seq = cc.Sequence:create(
            cc.DelayTime:create(1),
            cc.ScaleTo:create(0.3,1.1),
            cc.ScaleTo:create(0.1,0.95),
            cc.ScaleTo:create(0.05,1))
        self._children["btn_share"]:runAction(seq)

        self._children["btn_Next"]:setScale(0) 
        self._children["btn_Next"]:setVisible(true)
        local seq = cc.Sequence:create(
            cc.DelayTime:create(1),
            cc.ScaleTo:create(0.3,1.1),
            cc.ScaleTo:create(0.1,0.95),
            cc.ScaleTo:create(0.05,1))
        self._children["btn_Next"]:runAction(seq)
    end
end

return MaJiangResultLayer
