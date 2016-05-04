module("GameManager", package.seeall)
require "Constant"
require "system.LayerManager"
require "manager.UIManager"
require "entity.EntityManager"
require "util.Util"


function initGame()
	InitAllEntities();

	local scene = display.newScene();
	scene:retain();
	display.runScene(scene);
	createGameLayers(scene);
	UIManager.loadMainUI();
	UIManager.openUI("MainLayerUI");
end

function gotoGameFromMain()
	UIManager.removeMainUI();
	UIManager.loadGameUI();
	UIManager.openUI("GameLayerUI");
end