
local NoticeLayer = class("NoticeLayer", cc.load("mvc").DialogBase)
NoticeLayer.RESOURCE_FILENAME = "notice_layer.csb"

function NoticeLayer:onCreate()   
    self:setInOutEffectEnable(true)
    self:initUI()
end

function NoticeLayer:initUI()
    local function removeSelf(pSender)
        app:backDialog()
    end
    self._children["btn_close"]:addClickEventListener(removeSelf)
    
    self:registerKeyboardListener(function ( ... )
        -- body
        removeSelf()
    end)
end

return NoticeLayer
