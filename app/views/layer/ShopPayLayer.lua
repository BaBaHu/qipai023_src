
local ShopPayLayer = class("ShopPayLayer", cc.load("mvc").DialogBase)
ShopPayLayer.RESOURCE_FILENAME = "shop_pay_layer.csb"

function ShopPayLayer:onCreate(params)   
    self:setInOutEffectEnable(true)
    self:init(params)
    self:initUI()
end

function ShopPayLayer:init(params)
    -- body
    self.params = params
    print("ShopPayLayer:init...............", self.params)

    --注册ApplyPayResultState监听回调
    local function OnApplyPayResultStateBackListener(iCode)
        -- body
        print("OnApplyPayResultStateBackListener...........................", iCode)
        app:closeDialog("LoadLayer")
        if iCode == 1 then
            cc.MENetUtil:setUserGoldOrRoomCard(self.params[4], self.params[2])
            EventDispatcher:dispatchEvent(EventMsgDefine.UpdateMoneyData)
            app:backDialog()
        elseif iCode == 2 then
            app:backDialog()
        elseif iCode == 3 then
            app:backDialog()
        end
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onApplyPayResultStateBack", OnApplyPayResultStateBackListener)
end

function ShopPayLayer:onClear()
    print("ShopPayLayer:onClear() -----------------------------------------")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onApplyPayResultStateBack")
end

function ShopPayLayer:initUI()
    local function removeSelf(pSender)
        app:backDialog()
    end
    self._children["btn_close"]:addClickEventListener(removeSelf)
    
    self:registerKeyboardListener(function ( ... )
        -- body
        removeSelf()
    end)

    local title = self.params[3]
    if self.params[4] == 1 then
        title = title .. "金币"
    else
        title = title .. "钻石"
    end

    self._children["labelNum"]:setString(title)
    local price = self.params[1]
    if self.params[4] == 2 then
        price = price * 0.5
    end
    self._children["labelPrice"]:setString(price .. "元")

    local function OnWenXiPay(pSender)
        --cc.MEWeiXinHelper:getInstance():wxPay("")
        local params = {}
        params["zorder"] = 1024
        app:openDialog("LoadLayer", params)

        GameLogicManager:payByWx(self.params[4], title, tostring(price), self.params[2], function ( order )
            -- body
            cc.MEWeiXinHelper:getInstance():wxPayByOrder(order)
        end)
    end
    self._children["btn_weixin_pay"]:addClickEventListener(OnWenXiPay)

    local function OnApplyPay(pSender)
        --cc.MEWeiXinHelper:getInstance():applyPay(title, title, self.params[1])
        local params = {}
        params["zorder"] = 1024
        app:openDialog("LoadLayer", params)

        GameLogicManager:payByApplay(self.params[4], title, title, tostring(price), self.params[2], function ( order )
            -- body
            cc.MEWeiXinHelper:getInstance():applyPayByOrder(order)
        end)
    end
    self._children["btn_apply_pay"]:addClickEventListener(OnApplyPay)

end

return ShopPayLayer
