require("UI.UIBaseCtrl")
UICommanderReputationItem = class("UICommanderReputationItem", UIBaseCtrl)
UICommanderReputationItem.__index = UICommanderReputationItem
function UICommanderReputationItem:ctor()
  self.data = nil
  self.reputationItem = nil
end
function UICommanderReputationItem:__InitCtrl()
end
function UICommanderReputationItem:InitCtrl(parent)
  local obj = self:Instantiate("CommanderInfo/CommanderReputationTitleItem.prefab", parent)
  self:SetRoot(obj.transform)
  self:__InitCtrl()
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.reputationItem = UICommonReputationItem.New()
  self.reputationItem:InitCtrl(self.ui.mTrans_ReputationItem)
end
function UICommanderReputationItem:SetData(data)
  self.reputationItem:SetData(data.title, data.icon)
end
function UICommanderReputationItem:SetRedPoint(needShow)
  setactive(self.ui.mTrans_RedPoint, needShow)
end
function UICommanderReputationItem:SetLockState(isLock)
  setactive(self.ui.mTrans_Lock, isLock)
end
function UICommanderReputationItem:SetEquipState(isEquipped)
  setactive(self.ui.mTrans_Equipped, isEquipped)
end
function UICommanderReputationItem:EnableBtn(enable)
  self.ui.mBtn_Reputation.interactable = enable
  setactive(self.ui.mTrans_Sel, enable)
end
function UICommanderReputationItem:OnRelease()
  self.super.OnRelease(self)
end
function UICommanderReputationItem:AddBtnListener(callback)
  self.reputationClickCallback = callback
end
function UICommanderReputationItem:OnClickBtnReputation()
  if self.reputationClickCallback then
    self.reputationClickCallback()
  end
end
