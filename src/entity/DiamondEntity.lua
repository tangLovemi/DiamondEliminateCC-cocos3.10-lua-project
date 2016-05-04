local DiamondEntity = class("DiamondEntity", cc.Sprite)

DiamondEntity.x = 0;
DiamondEntity.y = 0;
DiamondEntity.type = 0;



function DiamondEntity:ctor()
    self:init();
end

function DiamondEntity:init()
	self:initRandomType();
	self:setSpriteFrame(display.newSpriteFrame("#DiamondEliminate/jewel" .. self.type .. ".png"));
	self:align(cc.p(0, 0), 0, 0);
end

function DiamondEntity:initRandomType()
	self.type = Util.random(DIAMOND_TYPE_COUNT);
end

function DiamondEntity:createByRandomType( type, x, y )
	local diamond = self:create();
	diamond:setType(type);
	diamond:setX(x);
	diamond:setY(y);
	diamond:setSpriteFrame(display.newSpriteFrame("#DiamondEliminate/jewel" .. diamond:getType() .. ".png"));
	diamond:align(cc.p(0, 0), 0, 0);
	return diamond;
end








function DiamondEntity:getX()
	return self.x;
end
function DiamondEntity:getY()
	return self.y;
end
function DiamondEntity:setX(x)
	self.x = x;
end
function DiamondEntity:setY(y)
	self.y = y;
end
function DiamondEntity:getType()
	return self.type;
end
function DiamondEntity:setType(type)
	self.type = type;
end





return DiamondEntity