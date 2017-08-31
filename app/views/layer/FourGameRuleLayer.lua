
local FourGameRuleLayer = class("FourGameRuleLayer", cc.load("mvc").DialogBase)
FourGameRuleLayer.RESOURCE_FILENAME = "fourmj_rule_layer.csb"

function FourGameRuleLayer:onCreate()   
    self:setInOutEffectEnable(true)
    self:initUI()
end

function FourGameRuleLayer:initUI()
    local function removeSelf(pSender)
        app:backDialog()
    end
    self._children["panel"]:addClickEventListener(removeSelf)
    
    self:registerKeyboardListener(function ( ... )
        -- body
        removeSelf()
    end)
end

return FourGameRuleLayer
