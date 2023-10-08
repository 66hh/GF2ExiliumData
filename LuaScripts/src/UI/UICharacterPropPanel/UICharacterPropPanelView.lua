require("UI.UIBaseView")
UICharacterPropPanelView = class("UICharacterPropPanelView", UIBaseView)
UICharacterPropPanelView.__index = UICharacterPropPanelView
function UICharacterPropPanelView:ctor()
end
function UICharacterPropPanelView:__InitCtrl()
  self.mBtn_Close = UIUtils.GetTempBtn(self:GetRectTransform("Root/GrpDialog/GrpTop/GrpClose"))
  self.mTrans_PropList = self:GetRectTransform("Root/GrpDialog/GrpCenter/AttributeList/Viewport/Content/GrpAttribute")
end
function UICharacterPropPanelView:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
