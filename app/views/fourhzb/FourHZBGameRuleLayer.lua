
local FourHZBGameRuleLayer = class("FourHZBGameRuleLayer", cc.load("mvc").DialogBase)
FourHZBGameRuleLayer.RESOURCE_FILENAME = "fourhzb_rule_layer.csb"

function FourHZBGameRuleLayer:onCreate()   
    self:setInOutEffectEnable(true)
    self:initUI()
end

function FourHZBGameRuleLayer:initUI()
    local function removeSelf(pSender)
        app:backDialog()
    end
    self._children["panel"]:addClickEventListener(removeSelf)
    
    self:registerKeyboardListener(function ( ... )
        -- body
        removeSelf()
    end)
end

return FourHZBGameRuleLayer
