
local FourXZGameRuleLayer = class("FourXZGameRuleLayer", cc.load("mvc").DialogBase)
FourXZGameRuleLayer.RESOURCE_FILENAME = "fourxz_rule_layer.csb"

function FourXZGameRuleLayer:onCreate()   
    self:setInOutEffectEnable(true)
    self:initUI()
end

function FourXZGameRuleLayer:initUI()
    local function removeSelf(pSender)
        app:backDialog()
    end
    self._children["panel"]:addClickEventListener(removeSelf)
    
    self:registerKeyboardListener(function ( ... )
        -- body
        removeSelf()
    end)
end

return FourXZGameRuleLayer
