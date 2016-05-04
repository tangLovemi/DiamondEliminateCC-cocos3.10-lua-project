
TAG_GAME_LAYER_UI = 1;
local m_scene = nil;

function createGameLayers( scene )
	m_scene = scene;
	local uiLayer = display.newLayer();
	uiLayer:setTag(1);
	m_scene:addChild(uiLayer);
    -- m_scene:addChild(uiLayer, 1, TAG_GAME_LAYER_UI);
end

function getGameLayer(tag)
    local layer = m_scene:getChildByTag(tag);
    return tolua.cast(layer, "cc.Layer");
end