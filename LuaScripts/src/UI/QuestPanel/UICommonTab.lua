UICommonTab = class("UICommonTab", UIBaseCtrl)
function UICommonTab:ctor(go)
  self:SetRoot(go.transform)
  self.ui = UIUtils.GetUIBindTable(go)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Tab.gameObject, function()
    self:onClickSelf()
  end)
end
function UICommonTab:InitByTaskTypeData(taskTypeData, tabIndex, onClickCallback)
  if taskTypeData then
    self:SetUnlockId(taskTypeData.Unlock)
    local spriteAsset = IconUtils.GetBtnFunctionIcon(taskTypeData.TypeTaskIcon)
    self:CacheLoadedAsset(spriteAsset)
    self:SetMainIcon(spriteAsset)
    self:SetTitle(taskTypeData.type_name.str)
    self:SetType(taskTypeData.Type)
  end
  self:Init(tabIndex, onClickCallback)
end
function UICommonTab:InitByBpTaskTypeData(BpTaskTypeData, tabIndex, onClickCallback)
  if BpTaskTypeData then
    self.ui.mText_Name.text = BpTaskTypeData.name.str
    self:SetType(BpTaskTypeData.id)
  end
  self:Init(tabIndex, onClickCallback)
end
function UICommonTab:Init(tabIndex, onClickCallback)
  self.tabIndex = tabIndex
  self.onClickCallback = onClickCallback
end
function UICommonTab:SetTitle(str)
  if self.ui.mText_Title then
    self.ui.mText_Title.text = str
  end
end
function UICommonTab:SetMainIcon(sprite)
  if self.ui.mImage_MainIcon then
    self.ui.mImage_MainIcon.sprite = sprite
  end
end
function UICommonTab:SetUnlockId(unlockId)
  self.unlockId = unlockId
end
function UICommonTab:GetUnlockId()
  return self.unlockId
end
function UICommonTab:SetBg(sprite)
  if self.ui.mImage_Bg then
    self.ui.mImage_Bg.sprite = sprite
  end
end
function UICommonTab:SetMainIconVisible(visible)
  setactive(self.ui.mImage_MainIcon, visible)
end
function UICommonTab:SetRedPointVisible(visible)
  setactive(self.ui.mTrans_RedPoint, visible)
end
function UICommonTab:SetLockIconVisible(visible)
  setactive(self.ui.mTrans_LockIcon, visible)
end
function UICommonTab:GetType()
  return self.tabType
end
function UICommonTab:SetType(tabType)
  self.tabType = tabType
end
function UICommonTab:OnRelease(...)
  self.tabIndex = nil
  self.tabType = nil
  self.unlockId = nil
  self.onClickCallback = nil
  self.ui = nil
  self.super.OnRelease(self, ...)
end
function UICommonTab:Select()
  self.ui.mBtn_Tab.interactable = false
end
function UICommonTab:Deselect()
  self.ui.mBtn_Tab.interactable = true
end
function UICommonTab:GetTabIndex()
  return self.tabIndex
end
function UICommonTab:onClickSelf()
  if self.onClickCallback then
    self.onClickCallback(self.tabIndex)
  end
end
