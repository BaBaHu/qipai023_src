
local ShareLayer = class("ShareLayer", cc.load("mvc").DialogBase)
ShareLayer.RESOURCE_FILENAME = "share_layer.csb"

function ShareLayer:onCreate()   
    self:setInOutEffectEnable(true)
    self:init()
    self:initUI()
end

function ShareLayer:init()
    -- body
    --注册ShareResult监听回调
    local function OnShareResultBackListener(strDesc)
        -- body
        print("OnShareResultBackListener...............................", strDesc)
        if strDesc ~= nil and strDesc ~= "" then
            self:showTips(strDesc)
        end
        EventDispatcher:dispatchEvent(EventMsgDefine.UpdateBankData)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onShareResultBack", OnShareResultBackListener)

    --注册WxShareResultState监听回调
    local function OnWxShareResultStateBackListener(iCode)
        -- body
        print("OnWxShareResultStateBackListener...............................", iCode)
        GameLogicManager:share()
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onWxShareResultStateBack", OnWxShareResultStateBackListener)

end

function ShareLayer:onClear()
    print("ShareLayer:onClear() -----------------------------------------")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onShareResultBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onWxShareResultStateBack")
end

function ShareLayer:initUI()
    local function removeSelf(pSender)
        app:backDialog()
    end
    self._children["btn_close"]:addClickEventListener(removeSelf)
    
    self:registerKeyboardListener(function ( ... )
        -- body
        removeSelf()
    end)
    
    local function OnShareHuiHua()
        if cc.MENetUtil:getUserType() == 2 then
            GameLogicManager:WeiXinShareUrl(SHARE_MAIN_TITLE, SHARE_MAIN_DESC, 0)
        else
            self:showTips("请切换微信登录，再使用分享功能！")
        end
    end

    self._children["btn_share_0"]:addClickEventListener(OnShareHuiHua)

    local function OnSharePengYouQuan()
       if cc.MENetUtil:getUserType() == 2 then
            GameLogicManager:WeiXinShareUrl(SHARE_MAIN_TITLE, SHARE_MAIN_DESC, 1)
        else
            self:showTips("请切换微信登录，再使用分享功能！")
        end
    end
    self._children["btn_share_1"]:addClickEventListener(OnSharePengYouQuan)

end

return ShareLayer
