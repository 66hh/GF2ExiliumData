require("UI.UIBaseCtrl")
require("UI.DarkZonePanel.UIDarkZoneModePanel.DarkZoneGlobal")
UIDarkZoneEndlessTopTypeItem = class("UIDarkZoneEndlessTopTypeItem", UIBaseCtrl)
UIDarkZoneEndlessTopTypeItem.__index = UIDarkZoneEndlessTopTypeItem
function UIDarkZoneEndlessTopTypeItem:__InitCtrl()
end
function UIDarkZoneEndlessTopTypeItem:InitCtrl(root)
  if root == nil then
    return
  end
  local itemPrefab = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(itemPrefab.childItem)
  CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self.mData = nil
  self.isUnLock = true
  self.clickFunction = nil
  self.ui.mAnim_Self.keepAnimatorControllerStateOnDisable = true
  UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
    if self.isUnLock then
      PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.EndlessItemRedPointKey .. self.mData.unlock[0], 2)
      self:SetRedPoint(false)
      if self.clickFunction and self.mData then
        self.clickFunction(self.mData.type)
      end
    else
      PopupMessageManager.PopupString(self.mData.unlock_des.str)
    end
  end
end
function UIDarkZoneEndlessTopTypeItem:SetData(data, rewardData)
  self.mData = data
  self.mRewardData = rewardData
  if data.icon and string.len(data.icon) > 0 then
    self.ui.mImg_Icon.sprite = IconUtils.GetDarkZoneModelIcon(data.icon)
  end
  self.ui.mText_Name.text = data.title.str
  self.ui.mText_Describe.text = data.sub_title.str
  local isShowRedPoint = PlayerPrefs.GetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.EndlessItemRedPointKey .. self.mData.unlock[0]) == 1
  self:SetRedPoint(isShowRedPoint)
end
function UIDarkZoneEndlessTopTypeItem:SetLockState(parentLock)
  local maxCount = self.mData.unlock.Count - 1
  for i = 0, maxCount do
    local id = self.mData.unlock[i]
    if NetCmdDarkZoneSeasonData:IsQuestFinish(id) == false or parentLock == false then
      self.isUnLock = false
      break
    end
  end
  self.ui.mAnim_Self:SetBool("Unlock", self.isUnLock)
end
function UIDarkZoneEndlessTopTypeItem:SetClickFunction(func)
  self.clickFunction = func
end
function UIDarkZoneEndlessTopTypeItem:SetRedPoint(isShow)
  setactive(self.ui.mTrans_RedPoint, isShow)
end
function UIDarkZoneEndlessTopTypeItem:OnRelease()
  self.ui = nil
  self.mData = nil
  self.clickFunction = nil
  self.super.OnRelease(self, true)
end
