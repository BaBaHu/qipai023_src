local ViewBase = import(".ViewBase")
local DialogBase = class("DialogBase", ViewBase)

function DialogBase:ctor(name, params)
	self:setVisible(false)
    self.inOutEffect_ = false
    ViewBase.ctor(self, name, params)
end

function DialogBase:open(params)
	if self:isVisible() then return end
	self:setVisible(true)

	local panel = self._children["panel"]
	local nPos = cc.p(panel:getPosition() )
	local to = cc.pAdd(nPos, app:getSceneCenteroffset())
	panel:setPosition(to)

	if self.inOutEffect_ then
		self:inEffect()
	end
end

--[[注意不能直接使用此接口关闭对话框]]
function DialogBase:close()
	self:onClose()
	if self.inOutEffect_ then
		self:outEffect()
	else
		self:removeFromParent()
	end
end

function DialogBase:hideDialog()
	print("Hide Dialog! %s", self.inOutEffect_)
	if self.inOutEffect_ then
		self:outEffect(true)
	else
		self:setVisible(false)
	end
end

function DialogBase:showDialog()
	print("Show Dialog!")
	if self.inOutEffect_ then
		self:inEffect()
	else
		self:setVisible(true)
	end
end

function DialogBase:setInOutEffectEnable(enable)
	self.inOutEffect_ = enable
end

function DialogBase:getInOutEffectEnable()
	return self.inOutEffect_
end

function DialogBase:inEffect()
	local panel = self._children["panel"]
	self:setVisible(true)
	panel:stopAllActions()
	panel:setScale(0.5)
	local scaleTo = cc.ScaleTo:create(0.30, 1)
	local easing = transition.newEasing(scaleTo, "BACKOUT")
	panel:runAction(easing)
end

function DialogBase:outEffect(noRelease)
	local scaleTo = cc.ScaleTo:create(0.20, 0.01)
	local easing = transition.newEasing(scaleTo, "BACKINOUT")
	local panel = self._children["panel"]
	local seq
	if noRelease then
		seq = cc.Sequence:create(easing, cc.CallFunc:create(function()
			self:setVisible(false)
		end))
	else
		seq = cc.Sequence:create(easing, cc.CallFunc:create(function()
			self:removeFromParent()
		end))
	end
	panel:runAction(seq)
end

--[[function DialogBase:onEnter_()
	--ViewBase.onEnter_(self)
end
]]

function DialogBase:onOpen()
end

function DialogBase:onClose()
end

function DialogBase:onExit_()
	print("DialogBase:onExit_() -----------------------------------")
    ViewBase.onExit_(self)
    app:onDialogClosed(self)
end


return DialogBase