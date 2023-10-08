require("UI.UIBaseView")
UICommonUnlockPanelView = class("UICommonUnlockPanelView", UIBaseView)
UICommonUnlockPanelView.__index = UICommonUnlockPanelView
UICommonUnlockPanelView.mBtn_Close = nil
UICommonUnlockPanelView.mImg_Icon = nil
UICommonUnlockPanelView.mText_Tittle = nil
UICommonUnlockPanelView.mText_Unlock = nil
UICommonUnlockPanelView.mText_Next = nil
UICommonUnlockPanelView.mContent_ = nil
function UICommonUnlockPanelView:__InitCtrl()
end
function UICommonUnlockPanelView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
