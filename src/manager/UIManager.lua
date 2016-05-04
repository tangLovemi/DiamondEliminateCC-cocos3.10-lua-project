module("UIManager", package.seeall)

require "ui.MainLayerUI"
require "ui.GameLayerUI"


local m_createdUIName = {};
local m_mainUI = {"MainLayerUI"};
local m_gameUI = {"GameLayerUI"};

function loadMainUI()
	for i,uiName in ipairs(m_mainUI) do
		crateUI(uiName);
	end
end
function removeMainUI()
	for i,uiName in ipairs(m_mainUI) do
		removeUI(uiName);
	end
end

function loadGameUI()
	for i,uiName in ipairs(m_gameUI) do
		crateUI(uiName);
	end
end
function removeGameUI()
	for i,uiName in ipairs(m_gameUI) do
		removeUI(uiName);
	end
end

function crateUI( uiName )
	_G[uiName].create();
	m_createdUIName[uiName] = uiName;
end

function openUI( uiName )
	if(m_createdUIName[uiName] ~= nil) then
		_G[uiName].open();
	else
		crateUI(uiName);
		openUI(uiName);
	end
end

function closeUI( uiName )
	_G[uiName].close();
end

function removeUI( uiName )
	_G[uiName].remove();
	m_createdUIName[uiName] = nil;
end
