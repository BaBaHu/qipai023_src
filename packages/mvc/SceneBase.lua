local ViewBase = import(".ViewBase")
local SceneBase = class("SceneBase", ViewBase)

function SceneBase:ctor(name, params)
    SceneBase.super.ctor(self, name, params)
end

function SceneBase:adaptor()
	local panel = self._children["panel"]
	if panel ~= nil then
		panel:setPosition(app:getSceneCenteroffset())
	end
end

function SceneBase:onExit_()
	print("SceneBase:onExit_() -----------------------------------")
    ViewBase.onExit_(self)
end

return SceneBase
