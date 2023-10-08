require("UI.UIBaseCtrl")
ChrWeaponTopBarItemV4 = class("ChrWeaponTopBarItemV4", UIBaseCtrl)
ChrWeaponTopBarItemV4.__index = ChrWeaponTopBarItemV4
function ChrWeaponTopBarItemV4:ctor()
  self.systemId = 0
  self.isLock = false
  self.hintId = 0
end
function ChrWeaponTopBarItemV4:InitCtrl(parent, systemId, hintId, obj, globalTabId)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj
  if obj ~= nil then
    instObj = obj
  else
    instObj = instantiate(itemPrefab.childItem)
  end
  if parent then
    CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject, false)
  end
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  self.systemId = systemId
  self.hintId = hintId
  self:SetRoot(instObj.transform)
  setactive(self.ui.mObj_RedPoint, false)
  self:SetNameByHint(self.hintId)
  self.globalTab = GetOrAddComponent(instObj.gameObject, (typeof(GlobalTab)))
  self.globalTab:SetGlobalTabId(globalTabId, self.systemId)
end
function ChrWeaponTopBarItemV4:OnButtonClick(callback)
  UIUtils.GetButtonListener(self.ui.mBtn_ChrWeaponTopBarItemV4.gameObject).onClick = function()
    if self:IsLock() and TipsManager.NeedLockTips(self.systemId) then
      return
    end
    if callback then
      callback()
    end
  end
end
function ChrWeaponTopBarItemV4:GetGlobalTab()
  return self.globalTab
end
function ChrWeaponTopBarItemV4:SetNameByHint(hintId)
  if hintId then
    self.ui.mText_Name.text = TableData.GetHintById(hintId)
    setactive(self.ui.mText_Name.gameObject, true)
  else
    setactive(self.ui.mText_Name.gameObject, false)
  end
end
function ChrWeaponTopBarItemV4:SetItemState(isSelect)
  self.ui.mBtn_ChrWeaponTopBarItemV4.interactable = not isSelect
end
function ChrWeaponTopBarItemV4:UpdateSystemLock()
  if self.systemId == 0 or self.systemId == nil then
    self.isLock = false
  else
    self.isLock = not AccountNetCmdHandler:CheckSystemIsUnLock(self.systemId)
  end
  self:UpdateLockState(not self.isLock)
end
function ChrWeaponTopBarItemV4:UpdateLockState(boolean)
  self.ui.mAnimator_ChrWeaponTopBarItemV4:ResetTrigger("Unlock")
  self.ui.mAnimator_ChrWeaponTopBarItemV4:SetBool("Unlock", boolean)
end
function ChrWeaponTopBarItemV4:SetEnable(enable)
  setactive(self.mUIRoot, enable)
end
function ChrWeaponTopBarItemV4:SetRedPointEnable(enable)
  setactive(self.ui.mObj_RedPoint.gameObject, enable)
  setactive(self.ui.mObj_RedPoint.transform.parent.gameObject, enable)
end
function ChrWeaponTopBarItemV4:IsLock()
  return self.isLock
end
function ChrWeaponTopBarItemV4:SetSwitchMask(isMask)
  self.ui.mAnimator_ChrWeaponTopBarItemV4:SetBool("SwitchMask", isMask)
end
function ChrWeaponTopBarItemV4:OnRelease()
  self:DestroySelf()
end
