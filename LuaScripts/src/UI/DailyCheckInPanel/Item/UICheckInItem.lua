require("UI.UIBaseCtrl")
UICheckInItem = class("UICheckInItem", UIBaseCtrl)
UICheckInItem.__index = UICheckInItem
UICheckInItem.mImage_Picture = nil
UICheckInItem.mText_Count = nil
UICheckInItem.mText_CheckInCount = nil
UICheckInItem.mText_CheckInDateText = nil
UICheckInItem.mTrans_CheckInItemInfor = nil
UICheckInItem.mTrans_CheckInMask = nil
function UICheckInItem:__InitCtrl()
end
UICheckInItem.mPath_item = "CheckIn/Btn_CheckInItem.prefab"
UICheckInItem.mData = nil
UICheckInItem.mButtonSelf = nil
UICheckInItem.mAnimator = nil
function UICheckInItem:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab(UICheckInItem.mPath_item, self))
  self:SetRoot(obj.transform)
  obj.transform:SetParent(parent, false)
  obj.transform.localScale = vectorone
  self:SetRoot(obj.transform)
  self:__InitCtrl()
  self.mButtonSelf = self:GetSelfButton()
  self.mAnimator = obj:GetComponent(typeof(CS.UnityEngine.Animator))
end
function UICheckInItem:InitData(data)
  self.mData = data
  local stcData = TableData.GetItemData(data.ItemId)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:UpdateBtnState(false)
  self.ui.mText_CheckInCount.text = string.format("-", data.Day)
  self.ui.mText_Count.text = data.ItemNum
  self.ui.mImage_Picture.sprite = UIUtils.GetIconSprite("Icon/Item", stcData.icon)
  TipsManager.Add(self:GetRoot().gameObject, stcData, nil, false)
  setactive(self.ui.mTrans_AvailableMask.gameObject, false)
end
function UICheckInItem:UpdateBtnState(isCanClick)
  self.ui.mBtn_CheckInItem.interactable = isCanClick
end
function UICheckInItem:SetMask()
  setactive(self.ui.mTrans_AvailableMask.gameObject, true)
end
function UICheckInItem:SetTransparent()
  setactive(self.ui.mTrans_AvailableMask.gameObject, true)
end
function UICheckInItem:SetChecked(callback)
  setactive(self.ui.mTrans_AvailableMask.gameObject, true)
  self.mAnimator:SetTrigger("Finished")
  if callback then
    callback()
  end
end
