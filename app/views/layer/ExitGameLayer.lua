
local ExitGameLayer = class("ExitGameLayer", cc.load("mvc").DialogBase)

ExitGameLayer.RESOURCE_FILENAME = "exit_game_layer.csb"

function ExitGameLayer:onCreate()
    self:setInOutEffectEnable(true)
    self:setLocalZOrder(2048)
    local function removeSelf()
        app:backDialog()
    end
    self._children["btn_exit"]:addClickEventListener(removeSelf)
    self._children["btn_close"]:addClickEventListener(removeSelf)

    local function OnOk()
        app:exit()
    end
    self._children["btn_ok"]:addClickEventListener(OnOk)
    local targetPlatform = me.Application:getTargetPlatform()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        self._children["btn_ok"]:setVisible(false)
    end

    local function OnChangeAccount()
        if cc.MENetUtil:getUserType() == 1 then
            cc.MEWeiXinHelper:qqlogout()
        end
        app:gotologin()
    end
    self._children["btn_change_account"]:addClickEventListener(OnChangeAccount)
end


return ExitGameLayer
