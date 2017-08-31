
local FourMJResultLayer = class("FourMJResultLayer", cc.load("mvc").DialogBase)
local helper   = require("app.views.fourxz.helper")
local DDMaJiang = require("app.views.fourxz.DDMaJiang")
FourMJResultLayer.RESOURCE_FILENAME = "game_fourmj/fourmj_result_layer.csb"

function FourMJResultLayer:onCreate(data) 
    print("FourMJResultLayer:onCreate(data).............", data)

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

    local function change(pSender)
        local tag = pSender:getTag()
        app:backDialog()
        print("tag ==============================", tag)
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

    local nIdx = 2
    for i=0, 3 do
        if i == cc.MENetUtil:getChairID() then
            self:showPlayerResult(1, i+1, data)
        else
            self:showPlayerResult(nIdx, i+1, data)
            nIdx = nIdx + 1
        end
    end

    --先检测流局，再检测输赢
    local nCount = 0
    for k,v in pairs(data.dwChiHuRight) do
        if v > 0 then
            nCount = nCount + 1
        end
    end
    if data.wLeftUser ~= 65535 then
        self._children["ImgResult"]:loadTexture("u_win.png", ccui.TextureResType.plistType)
    else
        if nCount >= 3 then
            local score = data.lGameScore[cc.MENetUtil:getChairID() + 1]
            if score >= 0 then
                self._children["ImgResult"]:loadTexture("u_win.png", ccui.TextureResType.plistType)
            else
                self._children["ImgResult"]:loadTexture("u_lose.png", ccui.TextureResType.plistType)
            end
        else
            --流局
            self._children["ImgResult"]:loadTexture("u_flow.png", ccui.TextureResType.plistType)
        end
    end
    local seq = cc.Sequence:create(
        cc.DelayTime:create(1.3),
        cc.CallFunc:create(function()
            EventDispatcher:dispatchEvent(EventMsgDefine.GameReset)    
        end)
    )
    self._children["panel"]:runAction(seq)
end

function FourMJResultLayer:getHuString( dwChiHuRight )
    -- body
    local str_hu = ""
    if dwChiHuRight == 0 then
        return str_hu
    end
    local data_type = helper.getHuPaiType()
    for i,v in ipairs(data_type) do
        print(dwChiHuRight, string.format("%x", dwChiHuRight) )
        local result = cc.MEFileUtil:IsValidRight(dwChiHuRight, v)
        if result then
            local name = helper.getHuPaiName(i)
            if name ~= "" then
                str_hu = str_hu .. name .."  "
            end
        end
    end
    print("FourMJResultLayer:getHuString( dwChiHuRight )", dwChiHuRight, str_hu)
    return str_hu
end

--显示玩家结果
function FourMJResultLayer:showPlayerResult(nIdx, nChairID, data)
    -- body
    local infoPanel = self._children["Panel" .. nIdx]

    local head = infoPanel:getChildByName("head")
    local lab_name = infoPanel:getChildByName("lab_name")
    if nIdx == 1 then
        local url = cc.MENetUtil:getUserIconUrl()
        if cc.MENetUtil:getUserType() == 0 or url == nil or url == "" then
            local faceId = cc.MENetUtil:getFaceID()%20 + 1
            head:loadTexture("s_" ..faceId..".png", ccui.TextureResType.plistType)
        else
            --下载头像
            print("url = ", url)
            local customid = Helper:md5sum(url)
            local filename = Helper:getFileNameByUrl(url, customid)
            print(filename)
            head:loadTexture(filename)
        end
        lab_name:setString(cc.MENetUtil:getNickName() )
    else
        local user = data.users[nChairID]
        if user.type == 0 or user.url == "" then
            local faceId = user.ficeid%20 + 1
            head:loadTexture("s_" ..faceId..".png", ccui.TextureResType.plistType)
        else
            --下载头像
            print("url = ", user.url)
            GameLogicManager:downAvatar(user.url, 
            function ( ... )
                -- body
            end,
            function (filename)
                -- body
                print(filename)
                head:loadTexture(filename)
            end)
        end
        lab_name:setString(user.nickName)
    end

    local imgZhuang = infoPanel:getChildByName("imgZhuang")
    imgZhuang:setVisible(false)
    if nChairID-1 == data.bankerUser then
        imgZhuang:setVisible(true)
    end

    local lab_score = infoPanel:getChildByName("lab_score")
    lab_score:setString(data.lGameScore[nChairID])

    local lab_winOrder = infoPanel:getChildByName("lab_winOrder")
    if data.wWinOrder[nChairID] == 65535 then
        lab_winOrder:setString("")
    else
        lab_winOrder:setString(data.wWinOrder[nChairID] .. "胡")
    end

    --胡牌类型
    local lab_pai_type = infoPanel:getChildByName("lab_pai_type")
    local temp = ""
    local value = data.dwChiHuRight[nChairID]
    local str_hu = self:getHuString(value)
    if value == 0 then
        --无胡牌
        --找到接炮的人
        for k,v in pairs(data.wProvideUser) do
            if v == nChairID -1 then
                --获取接炮人胡牌的顺序
                if data.wWinOrder[k] ~= 65535 and data.dwChiHuRight[k] ~= 0 then
                    temp = temp .. "点" .. data.wWinOrder[k] .. "胡 "
                end
            end
        end
    else
        --检测是自摸还是接炮
        if nChairID-1 == data.wProvideUser[nChairID] then
            if str_hu ~= "" then
                temp = "自摸(" .. str_hu .. ") "
            else
                temp = "自摸 "
            end
        else
            if str_hu ~= "" then
                temp = "接炮(" .. str_hu .. ") "
            else
                temp = "接炮 "
            end
        end

        --找到接炮的人
        for k,v in pairs(data.wProvideUser) do
            if v == nChairID -1 then
                --获取接炮人胡牌的顺序
                if data.wWinOrder[k] ~= 65535 and data.dwChiHuRight[k] ~= 0 and v ~= k-1 then
                    temp = temp .. "点" .. data.wWinOrder[k] .. "胡 "
                end
            end
        end
    end
    --检测杠
    local nCount = 0
    for k,v in pairs(data.state_list[nChairID].an_gang) do
        nCount = nCount + 1 
    end
    if nCount > 0 then
        temp = temp .. "暗杠X" .. nCount .. " "
    end
    nCount = 0
    for k,v in pairs(data.state_list[nChairID].ming_gang) do
        nCount = nCount + 1 
    end
    if nCount > 0 then
        temp = temp .. "巴杠X" .. nCount .. " "
    end
    for k,v in pairs(data.state_list[nChairID].dian_gang) do
        nCount = nCount + 1 
    end
    if nCount > 0 then
        temp = temp .. "点杠X" .. nCount .. " "
    end
    --根 
    if data.cbGenCount[nChairID] > 0 then
        temp = temp .. "根X" .. data.cbGenCount[nChairID] .. " "
    end
    lab_pai_type:setString(temp)

    local lab_fanshu = infoPanel:getChildByName("lab_fanshu")
    lab_fanshu:setString(data.wWinFanShu[nChairID] .. "番")

    --显示牌
    local cardPanel = infoPanel:getChildByName("cardPanel")
    local s = cardPanel:getContentSize()
    local n = 1
    local x = 0
    for k,v in pairs(data.state_list[nChairID].peng) do
        for i=1, 3 do
            local p_mj = DDMaJiang.new(4,1, k)
            p_mj:setScale(0.7)
            p_mj:setPosition((n-1)*p_mj:getContentSize().width*0.7 - x, s.height/2)
            cardPanel:addChild(p_mj)
            n = n + 1
        end
        n = n + 1
        x = x + 70
    end

    for k,v in pairs(data.state_list[nChairID].an_gang) do
        for i=1, 3 do
            local p_mj = DDMaJiang.new(4,2, k)
            p_mj:setScale(0.7)
            p_mj:setPosition((n-1)*p_mj:getContentSize().width*0.7 - x, s.height/2)
            cardPanel:addChild(p_mj)

            if i == 2 then
                local bg_pai2 = DDMaJiang.new(4,1,k )
                bg_pai2:setPosition(p_mj:getContentSize().width/2, p_mj:getContentSize().height/2+15)
                p_mj:addChild(bg_pai2,10)
            end
            n = n + 1
        end
        n = n + 1
        x = x + 70
    end

    for k,v in pairs(data.state_list[nChairID].dian_gang) do
        for i=1, 3 do
            local p_mj = DDMaJiang.new(4,1, k)
            p_mj:setScale(0.7)
            p_mj:setPosition((n-1)*p_mj:getContentSize().width*0.7 - x, s.height/2)
            cardPanel:addChild(p_mj)

            if i == 2 then
                local bg_pai2 = DDMaJiang.new(4,1, k)
                bg_pai2:setPosition(p_mj:getContentSize().width/2, p_mj:getContentSize().height/2+15)
                p_mj:addChild(bg_pai2,10)
            end
            n = n + 1
        end
        n = n + 1
        x = x + 70
    end

    for k,v in pairs(data.state_list[nChairID].ming_gang) do
        for i=1, 3 do
            local p_mj = DDMaJiang.new(4,1, k)
            p_mj:setScale(0.7)
            p_mj:setPosition((n-1)*p_mj:getContentSize().width*0.7 - x, s.height/2)
            cardPanel:addChild(p_mj)

            if i == 2 then
                local bg_pai2 = DDMaJiang.new(4,1, k)
                bg_pai2:setPosition(p_mj:getContentSize().width/2, p_mj:getContentSize().height/2+15)
                p_mj:addChild(bg_pai2,10)
            end
            n = n + 1
        end
        n = n + 1
        x = x + 70
    end
    
    for i=1, data.cbCardCount[nChairID] do
        local p_mj = DDMaJiang.new(4,1, helper.getPaiByIndex(data.cbCardData[nChairID][i]) )
        p_mj:setScale(0.7)
        p_mj:setPosition((n-1)*p_mj:getContentSize().width*0.7 - x, s.height/2)
        cardPanel:addChild(p_mj)
        n = n + 1
    end
end

function FourMJResultLayer:showButtonEffect()
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

return FourMJResultLayer
