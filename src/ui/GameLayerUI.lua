module("GameLayerUI", package.seeall)

-- 加载csb文件
local RESOURCE_FILENAME = "ui/GameScene.csb"
local m_isCreate = false;
local m_isOpen = false;
local m_rootNode = nil;
local m_rootPanel = nil;

local m_mapPos_x = 0;
local m_mapPos_y = 0;
local m_diamonds = {}; --存储棋盘中的钻石，二维的
local m_curTouchDiamond = nil;
local m_canMove = true;
local m_curIndex_x = 0;
local m_curIndex_Y = 0;
local m_nextIndex_x = 0;
local m_nextIndex_y = 0;
local m_crushDiamonds = {};--消除盒子，临时存储要消除的钻石


local M_COUNT_ROW = 8;--行数，对应y
local M_COUNT_COL = 8;--列数，对应x
local M_SPACE_WIDTH = 40;--格子宽度


--统计需要删除的钻石
local function calcShouldEliminate()
	m_crushDiamonds = {};
	--遍历每一列
	for x=1,M_COUNT_COL do
		local y = 1;
		while(y <= M_COUNT_ROW - 1) do
			local count = 1;
			local begin = m_diamonds[x][y];
			local next = m_diamonds[x][y + 1];
			while(begin:getType() == next:getType()) do
				count = count + 1;
				if(y + count > M_COUNT_ROW) then
					break;
				end
				next = m_diamonds[x][y + count];
			end
			if(count >= 3) then
				for i=1,count do
					local dia = m_diamonds[x][y + i - 1];
					table.insert(m_crushDiamonds, dia);
				end
			end
			y = y + count;
			-- printInfo("------------------ count = " .. count .. " ,y = " .. y);
		end
		-- printInfo("************************************************");
	end

		-- printInfo("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
	--遍历每一行
	for y=1,M_COUNT_ROW do
		local x = 1;
		while(x <= M_COUNT_COL - 1) do
			local count = 1;
			local begin = m_diamonds[x][y];
			local next = m_diamonds[x + 1][y];
			while(begin:getType() == next:getType()) do
				count = count + 1;
				if(x + count > M_COUNT_COL) then
					break;
				end
				next = m_diamonds[x + count][y];
			end
			if(count >= 3) then
				for i=1,count do
					local dia = m_diamonds[x + i - 1][y];
					local isHave = false;
					--加一部判断，是否已经存在
					for j,v in ipairs(m_crushDiamonds) do
						if(v:getX() == dia:getX() and v:getY() == dia:getY()) then
							isHave = true;
							break;
						end
					end
					if(not isHave) then
						table.insert(m_crushDiamonds, dia);
					end
				end
			end
			x = x + count;
			-- printInfo("------------------ count = " .. count .. " ,x = " .. x);
		end
		-- printInfo("************************************************");
	end
end

local function createNewDiamond(x, y)
	while(true) do
		local diamond = Diamond:createByRandomType(Util.random(DIAMOND_TYPE_COUNT), x, y);
		return diamond;
	end
end

local function eliminate()
	--从table中删除要清除的元素
	for i=1,#m_diamonds do
		local j = 1;
		while(j <= #m_diamonds[i]) do
			local isIn = false;
			local dia = m_diamonds[i][j];
			for k,v in ipairs(m_crushDiamonds) do
				if(dia:getX() == v:getX() and dia:getY() == v:getY()) then
					isIn = true;
					break;
				end
			end
			if(isIn) then
				table.remove(m_diamonds[i], j);
			else
				j = j + 1;
			end
		end
	end

	--剩余元素重新编号
	for i,v in ipairs(m_diamonds) do
		for j,v2 in ipairs(v) do
			v2:setX(i);
			v2:setY(j);
		end
	end

	--从屏幕移除钻石
	for i,v in ipairs(m_crushDiamonds) do
		v:removeSelf();
	end
	m_crushDiamonds = {};

	--补充新元素
	for x,v in ipairs(m_diamonds) do
		if(#v < M_COUNT_ROW) then
			for y=#v + 1,M_COUNT_ROW do
				local diamond = createNewDiamond(x, y);
				diamond:move(M_SPACE_WIDTH*(x - 1) + m_mapPos_x, M_SPACE_WIDTH*(y - 1) + display.height - m_mapPos_y);
				diamond:addTo(m_rootPanel);
				m_diamonds[x][y] = diamond;
			end
		end
	end

	local function recheck()
		calcShouldEliminate();
		if(#m_crushDiamonds > 0) then
			eliminate();
		else
			m_canMove = true;
		end
	end

	local count = 0;
	local function moveEnd()
		count = count + 1;
		if(count >= M_COUNT_ROW*M_COUNT_COL) then
			--间隔一小段时间后重新检测能否可以继续自动删除
			performWithDelay(m_rootNode, recheck, 0.15);
		end
	end

	--同时移动到合适位置
	local t = 0.5;
	for x,v in ipairs(m_diamonds) do
		for y,v2 in ipairs(v) do
			v2:moveTo({time = t, x = M_SPACE_WIDTH*(x - 1) + m_mapPos_x, y = M_SPACE_WIDTH*(y - 1) + m_mapPos_y, onComplete = moveEnd});
		end
	end

	-- for x,v in ipairs(m_diamonds) do
	-- 	for y,v2 in ipairs(v) do
	-- 		printInfo("x = " .. v2:getX() .. " ,y = " .. v2:getY() .. " , type = " .. v2:getType());
	-- 	end
	-- end

end


--模拟对调，查看是否可以消除
local function checkCanEliminate(x, y)
	local m_curIndex_x = m_curTouchDiamond:getX();
	local m_curIndex_Y = m_curTouchDiamond:getY();
	local curPosX = m_curTouchDiamond:getPositionX();
	local curPosY = m_curTouchDiamond:getPositionY();
	local nextDiamond = m_diamonds[m_nextIndex_x][m_nextIndex_y];
	local nextPosX = nextDiamond:getPositionX();
	local nextPosY = nextDiamond:getPositionY();
	local t = 0.2;
	m_curTouchDiamond:moveTo({time = t, x = nextPosX, y = nextPosY});

	local function moveEnd1()
		--交换
		m_curTouchDiamond:setX(m_nextIndex_x);
		m_curTouchDiamond:setY(m_nextIndex_y);
		nextDiamond:setX(m_curIndex_x);
		nextDiamond:setY(m_curIndex_Y);
		local tempDiamond = m_diamonds[m_curIndex_x][m_curIndex_Y];
		m_diamonds[m_curIndex_x][m_curIndex_Y] = m_diamonds[m_nextIndex_x][m_nextIndex_y];
		m_diamonds[m_nextIndex_x][m_nextIndex_y] = tempDiamond;

		calcShouldEliminate();
		if(#m_crushDiamonds > 0) then
			eliminate();
		else
			local function moveEnd2()
				m_canMove = true;
			end
			--交换回来
			m_curTouchDiamond:setX(m_curIndex_x);
			m_curTouchDiamond:setY(m_curIndex_Y);
			nextDiamond:setX(m_nextIndex_x);
			nextDiamond:setY(m_nextIndex_y);
			local tempDiamond = m_diamonds[m_curIndex_x][m_curIndex_Y];
			m_diamonds[m_curIndex_x][m_curIndex_Y] = m_diamonds[m_nextIndex_x][m_nextIndex_y];
			m_diamonds[m_nextIndex_x][m_nextIndex_y] = tempDiamond;
			m_curTouchDiamond:moveTo({time = t, x = curPosX, y = curPosY});
			nextDiamond:moveTo({time = t, x = nextPosX, y = nextPosY, onComplete = moveEnd2});	
		end
	end
	nextDiamond:moveTo({time = t, x = curPosX, y = curPosY, onComplete = moveEnd1});	
end


local function rootPanelOnTouch( sender, touchType )
	if(TOUCH_EVENT_BEGAN == touchType) then
		if(m_canMove) then
			local beginPos = sender:getTouchBeganPosition();
			local disX = checkint(beginPos.x) - m_mapPos_x;
			local disY = checkint(beginPos.y) - m_mapPos_y;
			local indexX = math.ceil(disX/M_SPACE_WIDTH);
			local indexY = math.ceil(disY/M_SPACE_WIDTH);
			if(indexX > 0 and indexY > 0) then
				m_curTouchDiamond = m_diamonds[indexX][indexY];
				m_curIndex_x = indexX;
				m_curIndex_Y = indexY;
			end
		end
	elseif(TOUCH_EVENT_MOVED ==  touchType) then
		if(m_canMove) then
			local movePos = sender:getTouchMovePosition();
			local disX = checkint(movePos.x) - m_mapPos_x;
			local disY = checkint(movePos.y) - m_mapPos_y;
			local indexX = math.ceil(disX/M_SPACE_WIDTH);
			local indexY = math.ceil(disY/M_SPACE_WIDTH);
			if(indexX > 0 and indexY > 0) then
				if(indexX ~= m_curTouchDiamond:getX() or indexY ~= m_curTouchDiamond:getY()) then
					m_canMove = false;
					m_nextIndex_x = indexX;
					m_nextIndex_y = indexY;
					checkCanEliminate(m_nextIndex_x, m_nextIndex_y);
				end
			end
		end
	elseif(TOUCH_EVENT_ENDED == touchType) then
		
	end
end

--判断一个位置的钻石是否合法，是否和下方左方不可消除
local function isDiamondLegal(diamond, x, y)
	local isX = true;
	local isY = true;
	if(x > 2) then
		if(diamond:getType() == m_diamonds[x - 1][y]:getType() and diamond:getType() == m_diamonds[x - 2][y]:getType()) then
			isX = false;
		end
	end
	if(y > 2) then
		if(diamond:getType() == m_diamonds[x][y - 1]:getType() and diamond:getType() == m_diamonds[x][y - 2]:getType()) then
			isY = false;
		end
	end
	return (isX and isY);
end

local function createOneDiamond(x, y)
	while(true) do
		local diamond = Diamond:createByRandomType(Util.random(DIAMOND_TYPE_COUNT), x, y);
		if(isDiamondLegal(diamond, x, y)) then
			return diamond;
		end
	end
end

--创建钻石棋盘
local function createDiamonds()
	-- 注意此棋盘中每一个钻石和上下左右都不可消除
	for x=1,M_COUNT_COL do
		local diamonds_row = {};
		table.insert(m_diamonds, diamonds_row);
	end
	for x=1,M_COUNT_COL do
		for y=1,M_COUNT_ROW do
			local diamond = createOneDiamond(x, y);
			diamond:move(M_SPACE_WIDTH*(x - 1) + m_mapPos_x, M_SPACE_WIDTH*(y - 1) + m_mapPos_y);
			diamond:addTo(m_rootPanel);
			m_diamonds[x][y] = diamond;
		end
	end
end



local function createResoueceNode()
    m_rootNode = cc.CSLoader:createNode(RESOURCE_FILENAME);
    m_rootNode:retain();
    m_rootPanel = m_rootNode:getChildByName("root_panel");

    local mapImg = m_rootPanel:getChildByName("map_img");
    m_mapPos_x = mapImg:getPositionX();
    m_mapPos_y = mapImg:getPositionY();
end

local function createResoueceBinding()
	m_rootPanel:addTouchEventListener(rootPanelOnTouch);
end

local function init()
	createDiamonds();
end


function create()
	if(not m_isCreate) then
		m_isCreate = true;
        createResoueceNode();
        createResoueceBinding();
	end
end

function open()
	if(not m_isOpen) then
		m_isOpen = true;
		local uiLayer = getGameLayer(TAG_GAME_LAYER_UI);
		uiLayer:addChild(m_rootNode, 1);

		init();
	end
end

function close()
	if(m_isOpen) then
		m_isOpen = false;
		if(m_rootNode) then
			m_rootNode:removeFromParentAndCleanup(false);
		end
	end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
		if(m_rootNode) then
			m_rootNode:removeSelf();
			m_rootNode:release();
			m_rootNode = nil;
		end
	end
end