
local HZBGameRuleLayer = class("HZBGameRuleLayer", cc.load("mvc").DialogBase)
HZBGameRuleLayer.RESOURCE_FILENAME = "hzb_rule_layer.csb"

function HZBGameRuleLayer:onCreate()   
    self:setInOutEffectEnable(true)
    self:initUI()
end

function HZBGameRuleLayer:initUI()
    local function removeSelf(pSender)
        app:backDialog()
    end
    self._children["panel"]:addClickEventListener(removeSelf)
    
    self:registerKeyboardListener(function ( ... )
        -- body
        removeSelf()
    end)
end

return HZBGameRuleLayer
