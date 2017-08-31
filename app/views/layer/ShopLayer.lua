
local ShopLayer = class("ShopLayer", cc.load("mvc").DialogBase)
ShopLayer.RESOURCE_FILENAME = "shop_layer.csb"

function ShopLayer:onCreate()   
    self:setInOutEffectEnable(true)
    self:init()
    self:initUI()
end

local tGold = {
    [1] = {10, 168000 , "16.8万", 1, "com.yibo98.weishui_1001"},
    [2] = {20, 336000 , "33.6万", 1},
    [3] = {50, 840000 , "84万", 1},
    [4] = {100, 1680000 , "168万", 1},
    [5] = {200, 3360000 , "336万", 1},
    [6] = {500, 8400000 , "840万", 1},
    [7] = {1000, 16800000 , "1680万", 1},
    [8] = {2000, 33600000 , "3360万", 1},
    [9] = {5000, 84000000 , "8400万", 1},
    [10] = {10000, 168000000 , "1.68亿", 1},
}

local tZuanshi = {
    [1] = {1000, 2500 , "2500", 2, "com.yibo98.weishui_2001"},
    [2] = {2000, 5000 , "5000", 2},
    [3] = {10000, 25000 , "2.5万", 2},
    [4] = {20000, 50000 , "5万", 2},
}

function ShopLayer:init()
    -- body
    --注册InsureSuccess监听回调
    local function OnInsureSuccessBackListener(strDesc, type, score, insure)
        -- body
        print("OnInsureSuccessBackListener...........................", strDesc, type, score, insure)
        self:showTips(strDesc)
        self:updateData()
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onInsureSuccessBack", OnInsureSuccessBackListener)
    
    --注册InsureFailure监听回调
    local function OnInsureFailureBackListener(strDesc, type)
        -- body
        print("OnInsureFailureBackListener............................", strDesc, type)
        self:showTips(strDesc)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onInsureFailureBack", OnInsureFailureBackListener)

    --注册PayCardResult监听回调
    local function OnPayCardResultBackListener(strDesc)
        -- body
        print("OnPayCardResultBackListener...............................", strDesc)
        if strDesc ~= nil and strDesc ~= "" then
            self:showTips(strDesc)
        end
        app:closeDialog("LoadLayer")
        self:updateData()
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onPayCardResultBack", OnPayCardResultBackListener)

    self:addEventListener(EventMsgDefine.UpdateMoneyData,self.updateData,self)
end

function ShopLayer:onClear()
    print("ShopLayer:onClear() -----------------------------------------")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onInsureSuccessBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onInsureFailureBack")
     MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onPayCardResultBack")
end

function ShopLayer:initUI()
    local function removeSelf(pSender)
        app:backDialog()
    end
    self._children["btn_close"]:addClickEventListener(removeSelf)
    
    self:registerKeyboardListener(function ( ... )
        -- body
        removeSelf()
    end)

    self.listView = self._children["listview"]
    local item = self.listView:getChildByName("item")
    item:setVisible(false)
    self.listView:setItemModel(item)

    self.nSelType = 1
    for i=1,3 do
        self._children["ImgBtn" .. i]:addTouchEventListener(function ( ... )
            --body
            self:onSelType(i)
        end)
    end
    self:onSelType(self.nSelType)

    local function OnPayCard()
        local str_id = self._children["txt_card_id"]:getString()
        local str_pwd = self._children["txt_card_pwd"]:getString()
        print(str_id, str_pwd)
        if str_id == "" then
            self:showTips("请输入正确的充值卡卡号！")
            return
        end
        if str_pwd == "" then
            self:showTips("充值卡密码不能为空！")
            return
        end
        local params = {}
        params["zorder"] = 1024
        app:openDialog("LoadLayer", params)
        GameLogicManager:payCard(str_id, str_pwd)
    end
    self._children["btn_chongzhicard"]:addClickEventListener(OnPayCard)

    self:updateData()
end

function ShopLayer:onSelType(selType)
    -- body
    print("ShopLayer:onSelType()", selType)
    if selType == nil then
        return
    end
    self.nSelType = selType
    if self.nSelType == 1 then
        self._children["ImgBtn1"]:loadTexture("jinbi1.png", ccui.TextureResType.plistType)
        self._children["ImgBtn2"]:loadTexture("zuanshi2.png", ccui.TextureResType.plistType)
        self._children["ImgBtn3"]:loadTexture("chongz2.png", ccui.TextureResType.plistType)
    elseif self.nSelType == 2 then
        self._children["ImgBtn1"]:loadTexture("jinbi2.png", ccui.TextureResType.plistType)
        self._children["ImgBtn2"]:loadTexture("zuanshi.png", ccui.TextureResType.plistType)
        self._children["ImgBtn3"]:loadTexture("chongz2.png", ccui.TextureResType.plistType)
    elseif self.nSelType == 3 then
        self._children["ImgBtn1"]:loadTexture("jinbi2.png", ccui.TextureResType.plistType)
        self._children["ImgBtn2"]:loadTexture("zuanshi2.png", ccui.TextureResType.plistType)
        self._children["ImgBtn3"]:loadTexture("chongz1.png", ccui.TextureResType.plistType)
    end
    self:initView()
end

function ShopLayer:initView()
    -- body
    if self.nSelType == 1 then
        self._children["Panel1"]:setVisible(true)
        self._children["Panel2"]:setVisible(false)
        self:initListView(tGold)
    elseif self.nSelType == 2 then
        self._children["Panel1"]:setVisible(true)
        self._children["Panel2"]:setVisible(false)
        self:initListView(tZuanshi)
    elseif self.nSelType == 3 then
        self._children["Panel1"]:setVisible(false)
        self._children["Panel2"]:setVisible(true)
    end
end

function ShopLayer:initListView(rankData)
    self.listView:removeAllChildren()

    for i=1, #rankData/2 do
        self.listView:pushBackDefaultItem()
    end

    local nIdx = 1
    for i = 1, #rankData/2 do
        print(i)
        local item       = self.listView:getItem(i - 1)
        item:setVisible(true)

        local ImgItem1   = item:getChildByName("ImgItem1")
        ImgItem1:setTag(nIdx)
        local labNum  = ImgItem1:getChildByName("labNum")
        local labBuy  = ImgItem1:getChildByName("labBuy")
        labNum:setString(rankData[nIdx][3])
        labBuy:setString("￥" .. rankData[nIdx][1])
        nIdx = nIdx + 1

        local ImgItem2   = item:getChildByName("ImgItem2")
        ImgItem2:setTag(nIdx)
        local labNum2  = ImgItem2:getChildByName("labNum")
        local labBuy2  = ImgItem2:getChildByName("labBuy")
        labNum2:setString(rankData[nIdx][3])
        labBuy2:setString("￥" .. rankData[nIdx][1])
        nIdx = nIdx + 1

        if self.nSelType == 1 then
            ImgItem1:loadTexture("chongzhika.png", ccui.TextureResType.plistType)
            ImgItem2:loadTexture("chongzhika.png", ccui.TextureResType.plistType)
        else
            ImgItem1:loadTexture("zuans.png", ccui.TextureResType.plistType)
            ImgItem2:loadTexture("zuans.png", ccui.TextureResType.plistType)
        end

        local function onClicked(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local tag = sender:getTag()
                print("tag ==============================", tag)
                self:OnBuy(tag, rankData[tag])
            end
        end
        ImgItem1:addTouchEventListener(onClicked)

        local function onClicked(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local tag = sender:getTag()
                print("tag ==============================", tag)
                self:OnBuy(tag, rankData[tag])
            end
        end
        ImgItem2:addTouchEventListener(onClicked)
    end
end

function ShopLayer:OnBuy(nIdx, data)
    print("ShopLayer:OnBuy(nIdx)...............", nIdx, data)
    --[[local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        GameLogicManager:payIpa(data[5])
        return
    end]]
    if data[4] == 2 then
        if cc.MENetUtil:getUserDailiOrder() ~= 1 then
            self:showTips("非代理不能充值，请联系您所在群群主充值，到大厅分享可以获得钻石！")
            return
        end
    end
    app:openDialog("ShopPayLayer", data)
end

function ShopLayer:updateData()
    self._children["lab_gold"]:setString(cc.MENetUtil:getUserGold())
    self._children["lab_zuanshi"]:setString(cc.MENetUtil:getRoomGold())

    EventDispatcher:dispatchEvent(EventMsgDefine.UpdateBankData)
end

return ShopLayer
