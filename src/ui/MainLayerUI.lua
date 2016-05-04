module("MainLayerUI", package.seeall)

-- 加载csb文件
local RESOURCE_FILENAME = "ui/MainScene.csb"
local m_isCreate = false;
local m_isOpen = false;
local m_rootNode = nil;


local function startButtonOnTouch( sender, touchType )
	-- printInfo("************** startButtonOnTouch touchType = " .. touchType);
	if(TOUCH_EVENT_BEGAN == touchType) then
	elseif(TOUCH_EVENT_MOVED ==  touchType) then
		-- local movePos = sender:getTouchMovePosition();
		-- printInfo("movePos.x = " .. movePos.x .. ", movePos.y = " .. movePos.y);
		-- printInfo("x = " .. checkint(movePos.x) .. ", y = " .. checkint(movePos.y));
		-- local beginPos = sender:getTouchBeganPosition();
		-- printInfo("beginPos.x = " .. beginPos.x .. ", beginPos.y = " .. beginPos.y);
	elseif(TOUCH_EVENT_ENDED == touchType) then
		-- local zhang = Zhang:createZhang();
		-- zhang:show();
	end
end

local function startButtonOnClick( sender )
	GameManager.gotoGameFromMain();
end




local function createResoueceNode()
    m_rootNode = cc.CSLoader:createNode(RESOURCE_FILENAME);
    m_rootNode:retain();
end

local function createResoueceBinding()
	local startButton = m_rootNode:getChildByName("Button_1");
	startButton:setTag(12345);
 	--onTouch和onClick都绑定的时，会先执行onTouch，onClick只回调end
 	startButton:addTouchEventListener(startButtonOnTouch);
 	startButton:addClickEventListener(startButtonOnClick);
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