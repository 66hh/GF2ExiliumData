require("UI.UIBaseCtrl")
UICommonMedalItem = class("UICommonMedalItem", UIBaseCtrl)
UICommonMedalItem.__index = UICommonMedalItem
function UICommonMedalItem:ctor()
  self.data = nil
end
function UICommonMedalItem:__InitCtrl()
end
function UICommonMedalItem:InitCtrl(obj, parent)
  local obj = instantiate(obj, parent)
  self:SetRoot(obj.transform)
  self:__InitCtrl()
  self.ui = {}
  self:LuaUIBindTable(obj.transform, self.ui)
  self.ui.mBtn_Medal.onClick:AddListener(function()
    self:OnClickBtnMedal()
  end)
end
function UICommonMedalItem:SetData(medal)
  if medal ~= "" then
    self.ui.mImage_Medal.sprite = IconUtils.GetIconV2("Item", medal)
  end
end
function UICommonMedalItem:SetRedPoint(needShow)
  setactive(self.ui.mTrans_RedPoint, needShow)
end
function UICommonMedalItem:SetLockState(isLock)
  setactive(self.ui.mTrans_Lock, isLock)
end
function UICommonMedalItem:SetEquipState(isEquipped)
  setactive(self.ui.mTrans_Equipped, isEquipped)
end
function UICommonMedalItem:EnableBtn(enable)
  self.ui.mBtn_Medal.interactable = enable
  setactive(self.ui.mTrans_Sel, enable)
end
function UICommonMedalItem:OnRelease()
  self.super.OnRelease(self)
end
function UICommonMedalItem:AddBtnListener(callback)
  self.medalClickCallback = callback
end
function UICommonMedalItem:OnClickBtnMedal()
  if self.medalClickCallback then
    self.medalClickCallback()
  end
end
