DarkZoneModeTopItem = class("DarkZoneModeTopItem", UIBaseCtrl)
DarkZoneModeTopItem.__index = DarkZoneModeTopItem
function DarkZoneModeTopItem:ctor()
end
function DarkZoneModeTopItem:InitCtrl(prefab, parent)
  local obj = instantiate(prefab, parent)
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self.index = 0
  self.callBack = nil
  self.ui.mAnimator.keepAnimatorControllerStateOnDisable = true
  UIUtils.GetButtonListener(self.ui.mBtn_TopItem.gameObject).onClick = function()
    self.callBack(self.index, false)
  end
end
function DarkZoneModeTopItem:SetData(index, callBack, name)
  self.index = index
  self.callBack = callBack
  self.ui.mText_Name.text = name
end
function DarkZoneModeTopItem:OnClick(isBackFrom, isOnRecover)
  self.callBack(self.index, isBackFrom, isOnRecover)
end
function DarkZoneModeTopItem:SetUnLock(unlock)
  self.ui.mAnimator:SetBool("Unlock", unlock)
end
function DarkZoneModeTopItem:SetRedPoint(isShow)
  setactive(self.ui.mTrans_RedPoint, isShow)
  setactive(self.ui.mTrans_RedPoint.parent, isShow)
end
function DarkZoneModeTopItem:SetGlobalTabId(globalTabId)
  self.globalTab = GetOrAddComponent(self:GetRoot().gameObject, (typeof(GlobalTab)))
  self.globalTab:SetGlobalTabId(globalTabId)
end
function DarkZoneModeTopItem:GetGlobalTab()
  return self.globalTab
end
function DarkZoneModeTopItem:Release()
end
