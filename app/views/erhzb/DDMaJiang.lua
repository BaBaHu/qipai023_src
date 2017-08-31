
local DDMaJiang = class("DDMaJiang", cc.Sprite)

function DDMaJiang:ctor(isSelf,type,id)
	-- 1碰 2盖 3出 4正常
	self.type = type
	self.isSelf = isSelf
	if isSelf then
		if type == 1 then
			self:initWithSpriteFrameName("hzb_table_"..id..".png")
		elseif type == 2 then
			self:initWithSpriteFrameName("sparrow_self_gai.png")
		elseif type == 3 then
			self:initWithSpriteFrameName("hzb_ud_"..id..".png")
		elseif type == 4 then
			self:initWithSpriteFrameName("hzb_me_"..id..".png")
		end
	else
		if type == 1 then
			self:initWithSpriteFrameName("hzb_ud_"..id..".png")
		elseif type == 2 then
			self:initWithSpriteFrameName("sparrow_target_gai.png")
		elseif type == 3 then
			self:initWithSpriteFrameName("hzb_ud_"..id..".png")
		elseif type == 4 then
			self:initWithSpriteFrameName("sparrow_target_nrmal.png")
		end
	end
	self:setTag(id)
end

function DDMaJiang:reSetMJPai(id)
	self:setTag(id)
	self:setSpriteFrame("hzb_me_"..id..".png")
end

function DDMaJiang:addGaiAction()
    self:setSpriteFrame("sparrow_self_gai.png")
    local action = cc.Sequence:create(
    	cc.DelayTime:create(0.5),
        cc.CallFunc:create(function() 
        	self:setSpriteFrame("hzb_me_"..self:getTag()..".png")
        end)
    )
    self:runAction(action)
end

function DDMaJiang:setSameOutFlag(isSelfHand)
	self:clearSameOutFlag()
	local s = self:getContentSize()
	local filename
	if isSelfHand then
		filename = "majmb.png"
	else
		filename = "majmb2.png"
	end 
	local imgFlag = display.newSprite("#" .. filename)
	imgFlag:setName("imgSameFlag")
    self:addChild(imgFlag)
    imgFlag:setPosition(cc.p(s.width/2, s.height/2))
end

function DDMaJiang:clearSameOutFlag()
	-- body
	local imgFlag = self:getChildByName("imgSameFlag")
	if imgFlag ~= nil then
		imgFlag:removeFromParent()
	end
end

--1 碰 2暗框 3 吃 4 三杠一 5 明杠
function DDMaJiang:setCurState(type)
	self.curState = type
end

function DDMaJiang:getCurState()
	return self.curState
end

function DDMaJiang:setIndex(index)
	self.curIndex = index
end

function DDMaJiang:getIndex()
	return self.curIndex
end

function DDMaJiang:setIsMove(index)
	self.curIsMove = index
end

function DDMaJiang:getIsMove()
	return self.curIsMove
end

return DDMaJiang
