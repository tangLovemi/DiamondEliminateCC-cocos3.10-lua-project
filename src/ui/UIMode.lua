module("UIMode", package.seeall)

-- 加载csb文件
local RESOURCE_FILENAME = "ui/UIMode.csb"
local m_isCreate = false;
local m_isOpen = false;
local m_rootNode = nil;

local function createResoueceNode()
    m_rootNode = cc.CSLoader:createNode(RESOURCE_FILENAME);
    m_rootNode:retain();
end

local function createResoueceBinding()

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