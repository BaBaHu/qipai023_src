
local LoadLayer = class("LoadLayer", cc.load("mvc").DialogBase)

LoadLayer.RESOURCE_FILENAME = "load_layer.csb"

function LoadLayer:onCreate()
    local rep = cc.RepeatForever:create(cc.RotateBy:create(0.1,-30))
    self._children["effect"]:runAction(rep)

    local action = cc.Sequence:create(
        cc.DelayTime:create(15),
        cc.CallFunc:create(function() 
            app:backDialog()
        end)
    )
    self._children["panel"]:runAction(action)
end

return LoadLayer
