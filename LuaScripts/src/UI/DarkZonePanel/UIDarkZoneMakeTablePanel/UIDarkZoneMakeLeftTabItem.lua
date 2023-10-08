require("UI.UIBaseCtrl")
require("UI.DarkZonePanel.UIDarkZoneMakeTablePanel.DarkZoneMakeGlobal")
UIDarkZoneMakeLeftTabItem = class("UIDarkZoneMakeLeftTabItem", UIBaseCtrl)
UIDarkZoneMakeLeftTabItem.__index = UIDarkZoneMakeLeftTabItem
UIDarkZoneMakeLeftTabItem.ui = nil
UIDarkZoneMakeLeftTabItem.mData = nil
function UIDarkZoneMakeLeftTabItem:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function UIDarkZoneMakeLeftTabItem:InitCtrl(parent)
  local com = parent:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, true)
  end
  self:SetRoot(obj.transform)
  self.ui = {}
  self.mData = nil
  self.callBack = nil
  self.questID = 0
  self:LuaUIBindTable(obj, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Select.gameObject).onClick = function()
    self:OnBtnSelect()
  end
end
function UIDarkZoneMakeLeftTabItem:SetData(data, callBack)
  self.mData = data
  self.callBack = callBack
  self:RefreshContent()
end
function UIDarkZoneMakeLeftTabItem:RefreshContent()
  if not self.mData then
    return
  end
  self.ui.mText_Name.text = UIUtils.GetItemName(self.mData.Data.id)
  self.ui.mImage_Icon.sprite = UIUtils.GetItemIcon(self.mData.Data.id)
  setactive(self.ui.mTrans_CanMake.gameObject, self.mData.State == DarkZoneMakeGlobal.State_CanProduce)
  setactive(self.ui.mTrans_UnMake.gameObject, self.mData.State == DarkZoneMakeGlobal.State_IsNotEnough)
  setactive(self.ui.mTrans_Lock.gameObject, self.mData.State == DarkZoneMakeGlobal.State_IsLock)
  self.ui.mAni_Root:SetBool("Bool", self.mData.State ~= DarkZoneMakeGlobal.State_IsLock)
  local args = TableData.listJumpListContentnewDatas:GetDataById(self.mData.Data.jump_id).args
  local argsList = string.split(args, ":")
  self.questID = tonumber(argsList[2])
  local isShowRedPoint = PlayerPrefs.GetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.MakeTableRedPointKey .. self.questID) == 1
  self:RefreshRedPoint(isShowRedPoint)
end
function UIDarkZoneMakeLeftTabItem:RefreshRedPoint(needShow)
  setactive(self.ui.mTrans_RedPoint, needShow)
  setactive(self.ui.mTrans_RedPoint.parent, needShow)
end
function UIDarkZoneMakeLeftTabItem:OnBtnSelect()
  if not self.callBack or not self.mData then
    return
  end
  PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.MakeTableRedPointKey .. tostring(self.questID), 2)
  self:RefreshRedPoint(false)
  self.callBack(self.mData)
end
function UIDarkZoneMakeLeftTabItem:SetSelect(selectId)
  if not self.mData then
    return
  end
  self.ui.mBtn_Select.interactable = selectId ~= self.mData.Data.id
end
function UIDarkZoneMakeLeftTabItem:OnRelease()
  self.mData = nil
  self.callBack = nil
  self.ui = nil
  self.super.OnRelease(self, true)
end
