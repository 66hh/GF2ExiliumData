require("UI.UIBaseCtrl")
UICommonPlayerAvatarItem = class("UICommonPlayerAvatarItem", UIBaseCtrl)
UICommonPlayerAvatarItem.__index = UICommonPlayerAvatarItem
function UICommonPlayerAvatarItem:ctor()
  self.data = nil
end
function UICommonPlayerAvatarItem:__InitCtrl()
end
function UICommonPlayerAvatarItem:InitObj(obj)
  self:SetRoot(obj.transform)
  self:__InitCtrl()
  self.ui = {}
  self:LuaUIBindTable(obj.transform, self.ui)
  self.ui.mBtn_Avatar.onClick:AddListener(function()
    self:OnClickBtnAvatar()
  end)
end
function UICommonPlayerAvatarItem:InitCtrl(parent)
  local obj = self:Instantiate("UICommonFramework/ComPlayerAvatarItemV2.prefab", parent)
  self:InitObj(obj)
end
function UICommonPlayerAvatarItem:InitCtrlByScrollChild(obj, parent)
  local obj = instantiate(obj, parent)
  self:InitObj(obj)
end
function UICommonPlayerAvatarItem:SetData(avatar)
  if avatar ~= "" then
    self.ui.mImage_Avatar.sprite = IconUtils.GetPlayerAvatar(avatar)
  end
end
function UICommonPlayerAvatarItem:SetFrameData(avatar)
  self.ui.mImage_Avatar.sprite = IconUtils.GetPlayerAvatarFrame(avatar)
end
function UICommonPlayerAvatarItem:SetFrameDataOut(avatar)
  setactive(self.ui.mImage_AvatarFrame, true)
  self.ui.mImage_AvatarFrame.sprite = IconUtils.GetPlayerAvatarFrame(avatar)
end
function UICommonPlayerAvatarItem:SetRedPoint(needShow)
  setactive(self.ui.mTrans_RedPoint, needShow)
end
function UICommonPlayerAvatarItem:SetLockState(isLock)
  setactive(self.ui.mTrans_Lock, isLock)
end
function UICommonPlayerAvatarItem:SetEquipState(isEquipped)
  setactive(self.ui.mTrans_Equipped, isEquipped)
end
function UICommonPlayerAvatarItem:EnableBtn(enable)
  self.ui.mBtn_Avatar.interactable = enable
  setactive(self.ui.mTrans_Sel, enable)
end
function UICommonPlayerAvatarItem:SetGender(isMan)
  setactive(self.ui.mTrans_GrpGender.gameObject, true)
  setactive(self.ui.mTrans_Man.gameObject, isMan)
  setactive(self.ui.mTrans_Woman.gameObject, not isMan)
end
function UICommonPlayerAvatarItem:OnRelease()
  gfdestroy(self:GetRoot())
  self.super.OnRelease(self)
end
function UICommonPlayerAvatarItem:AddBtnListener(callback)
  self.avatarClickCallback = callback
end
function UICommonPlayerAvatarItem:OnClickBtnAvatar()
  if self.avatarClickCallback then
    self.avatarClickCallback()
  end
end
