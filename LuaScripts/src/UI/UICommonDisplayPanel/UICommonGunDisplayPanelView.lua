require("UI.UIBaseView")
UICommonGunDisplayPanelView = class("UICommonGunDisplayPanelView", UIBaseView)
UICommonGunDisplayPanelView.__index = UICommonGunDisplayPanelView
function UICommonGunDisplayPanelView:ctor()
end
function UICommonGunDisplayPanelView:__InitCtrl()
end
function UICommonGunDisplayPanelView:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
