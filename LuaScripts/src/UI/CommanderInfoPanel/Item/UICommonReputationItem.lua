require("UI.UIBaseCtrl")
UICommonReputationItem = class("UICommonReputationItem", UIBaseCtrl)
UICommonReputationItem.__index = UICommonReputationItem
function UICommonReputationItem:ctor()
  self.data = nil
end
function UICommonReputationItem:__InitCtrl()
end
function UICommonReputationItem:InitCtrl(parent)
  local prefab = UIUtils.GetGizmosPrefab("UICommonFramework/ComReputationTitleItem.prefab", self)
  local obj = instantiate(prefab, parent)
  self:SetRoot(obj.transform)
  self:__InitCtrl()
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  setactive(self.ui.mTrans_RedPoint, false)
end
function UICommonReputationItem:SetData(title, icon)
  self.ui.mText_Reputation.text = title
  if icon ~= "" then
    self.ui.mImg_Bg.sprite = IconUtils.GetPlayerTitlePic(icon)
  end
end
function UICommonReputationItem:SetRedPoint(needShow)
  setactive(self.ui.mTrans_RedPoint, needShow)
end
function UICommonReputationItem:EnableBtn(enable)
  self.ui.mBtn_Reputation.interactable = enable
end
function UICommonReputationItem:OnRelease()
  gfdestroy(self:GetRoot())
  self.super.OnRelease(self)
end
