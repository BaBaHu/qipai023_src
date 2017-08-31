
local DDMaJiang = class("DDMaJiang", cc.Sprite)

function DDMaJiang:ctor(type, id)
	-- 1正常 2盖
	self.type = type
	if type == 1 then
		self:initWithSpriteFrameName("bjl_card"..id..".png")
	elseif type == 2 then
		self:initWithSpriteFrameName("bjl_card_bk.png")
	end
	self:setTag(id)
end

function DDMaJiang:showCard()
	self:setSpriteFrame("bjl_card"..self:getTag()..".png")
end

return DDMaJiang