require("UI.UIBaseCtrl")
UICommonLockItem = class("UICommonLockItem", UIBaseCtrl)
UICommonLockItem.__index = UICommonLockItem
function UICommonLockItem:ctor()
  self.ui = {}
  self.clickCallback = nil
  self.toggle = nil
end
function UICommonLockItem:__InitCtrl()
  self.toggle = self.ui.mToggle_ComLockItemV2
end
function UICommonLockItem:InitCtrl(parent, obj)
  if obj == nil then
    obj = self:Instantiate("UICommonFramework/ComLockItemV2.prefab", parent.transform)
  end
  self:SetRoot(obj.transform)
  self:LuaUIBindTable(obj, self.ui)
  self:__InitCtrl()
end
function UICommonLockItem:InitToggle(toggle, mTrans_LockState)
  self.toggle = toggle
  self.mTrans_LockState = mTrans_LockState
end
function UICommonLockItem:InitObj(obj)
  self:SetRoot(obj.transform)
  self:LuaUIBindTable(obj, self.ui)
  self:__InitCtrl()
end
function UICommonLockItem:AddClickListener(callback)
  self.toggle:ResetListener()
  self.clickCallback = callback
  self.toggle.onValueChanged:AddListener(self.clickCallback)
end
function UICommonLockItem:SetLock(isLock)
  if self.toggle.isOn == isLock then
    return
  end
  self.toggle:SetIsOnWithoutNotify(isLock)
  self.toggle:OnToggleValueChanged(isLock)
end
function UICommonLockItem:SetActive(boolean)
  self.super.SetActive(self, boolean)
  if self.mTrans_LockState ~= nil then
    setactive(self.mTrans_LockState, boolean)
    local parentTrans = self.mTrans_LockState.parent
    if parentTrans == nil then
      return
    end
    local gfToggle = parentTrans.gameObject:GetComponent(typeof(CS.UnityEngine.UI.GFToggle))
    if gfToggle == nil then
      return
    end
    gfToggle.interactable = boolean
  end
end
function UICommonLockItem:OnRelease(isDestroy)
  self.ui = nil
  self.clickCallback = nil
  self:ReleaseSelf()
end
