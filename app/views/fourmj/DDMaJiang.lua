
local DDMaJiang = class("DDMaJiang", cc.Sprite)

--flag 4自己 1左侧 2对面 3右侧
function DDMaJiang:ctor(flag, type, id)
	-- 1碰 2盖 3出 4正常
	self.type = type
	self.flag = flag
	if flag == 4 then
		if type == 1 then
			self:initWithSpriteFrameName("sparrow_table_"..id..".png")
		elseif type == 2 then
			self:initWithSpriteFrameName("sparrow_ud_bk.png")
		elseif type == 3 then
			self:initWithSpriteFrameName("sparrow_ud_"..id..".png")
		elseif type == 4 then
			self:initWithSpriteFrameName("sparrow_me_"..id..".png")
			self:setScale(0.9)
		end
	elseif flag == 1 then
		if type == 1 then
			self:initWithSpriteFrameName("sparrow_left_"..id..".png")
		elseif type == 2 then
			self:initWithSpriteFrameName("sparrow_left_bk.png")
		elseif type == 3 then
			self:initWithSpriteFrameName("sparrow_left_"..id..".png")
		elseif type == 4 then
			self:initWithSpriteFrameName("sparrow_left_hand.png")
			self:setScale(0.95)
		end
	elseif flag == 2 then
		if type == 1 then
			self:initWithSpriteFrameName("sparrow_ud_"..id..".png")
		elseif type == 2 then
			self:initWithSpriteFrameName("sparrow_up_bk_t.png")
		elseif type == 3 then
			self:initWithSpriteFrameName("sparrow_ud_"..id..".png")
		elseif type == 4 then
			self:initWithSpriteFrameName("sparrow_ud_bk_hand.png")
			self:setScale(0.55)
		end
	elseif flag == 3 then
		if type == 1 then
			self:initWithSpriteFrameName("sparrow_right_"..id..".png")
		elseif type == 2 then
			self:initWithSpriteFrameName("sparrow_right_bk.png")
		elseif type == 3 then
			self:initWithSpriteFrameName("sparrow_right_"..id..".png")
		elseif type == 4 then
			self:initWithSpriteFrameName("sparrow_right_hand.png")
			self:setScale(0.95)
		end
	else
		print("flag error !!!!!!!!!!!!!!!!!!!!!!!!!!!!!", flag, type, id)
	end
	self:setTag(id)
	if id == 10 then
		self.bCanOperate = true
	else
		self.bCanOperate = false
	end
end

function DDMaJiang:reSetMJPai(id)
	self:setTag(id)
	self:setSpriteFrame("sparrow_me_"..id..".png")
end

function DDMaJiang:reSetMJStatePai(id)
	self:setTag(id)
	if self.flag == 4 then
		self:setSpriteFrame("sparrow_table_"..self:getTag()..".png")
	elseif self.flag == 1 then
		self:setSpriteFrame("sparrow_left_"..self:getTag()..".png")
	elseif self.flag == 2 then
		self:setSpriteFrame("sparrow_ud_"..self:getTag()..".png")
	elseif self.flag == 3 then
		self:setSpriteFrame("sparrow_right_"..self:getTag()..".png")
	end
end

function DDMaJiang:gaiPai()
	if self.flag == 4 then
		self:setSpriteFrame("sparrow_ud_bk.png")
	elseif self.flag == 1 then
		self:setSpriteFrame("sparrow_left_bk.png")
	elseif self.flag == 2 then
		self:setSpriteFrame("sparrow_up_bk_t.png")
		self:setScale(1.2)
	elseif self.flag == 3 then
		self:setSpriteFrame("sparrow_right_bk.png")
	end
end

function DDMaJiang:mingPai()
	if self.flag == 4 then
		self:setSpriteFrame("sparrow_table_"..self:getTag()..".png")
		self:setScale(0.9)
	elseif self.flag == 1 then
		self:setSpriteFrame("sparrow_left_"..self:getTag()..".png")
	elseif self.flag == 2 then
		self:setSpriteFrame("sparrow_ud_"..self:getTag()..".png")
	elseif self.flag == 3 then
		self:setSpriteFrame("sparrow_right_"..self:getTag()..".png")
	end
end

function DDMaJiang:addGaiAction()
    self:setSpriteFrame("sparrow_ud_bk.png")
    local action = cc.Sequence:create(
    	cc.DelayTime:create(0.5),
        cc.CallFunc:create(function() 
        	self:setSpriteFrame("sparrow_me_"..self:getTag()..".png")
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
		if self.flag == 4 or self.flag == 2 then
			filename = "majmb2.png"
		elseif self.flag == 1 or self.flag == 3 then
			filename = "majmb3.png"
		end
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

function DDMaJiang:setStateCard(cardid)
	self.stateCard = cardid
end

function DDMaJiang:getStateCard()
	return self.stateCard
end

function DDMaJiang:setCanOperate(bCan)
	if bCan then
		self:setOpacity(255)
	else
		self:setOpacity(120)
	end
	self.bCanOperate = bCan
end

function DDMaJiang:getCanOperate()
	return self.bCanOperate
end

function DDMaJiang:setIsMove(index)
	self.curIsMove = index
end

function DDMaJiang:getIsMove()
	return self.curIsMove
end

return DDMaJiang
