
local LoadingLayer = class("LoadingLayer", cc.load("mvc").DialogBase)

LoadingLayer.RESOURCE_FILENAME = "loading_layer.csb"

function LoadingLayer:onCreate() 
    local s = self._children["panel"]:getContentSize()
    local function OnLoad( ... )
        -- body
        local armature = ccs.Armature:create("MJLoad")
        if armature ~= nil then
            armature:getAnimation():playWithIndex(0)
            armature:setPosition(cc.p(s.width/2, s.height/2))
            self._children["panel"]:addChild(armature)
        end
    end
    ResLoadControl:instance():loadArmatureModelResAsync("res/effect/MJLoad/MJLoad.ExportJson", OnLoad, true)

    local action = cc.Sequence:create(
        cc.DelayTime:create(15),
        cc.CallFunc:create(function() 
            app:backDialog()
        end)
    )
    self._children["panel"]:runAction(action)
end

return LoadingLayer
