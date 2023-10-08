require("UI.UIBaseCtrl")
UIComTabBtn1Item = class("UIComTabBtn1Item", UIBaseCtrl)
UIComTabBtn1Item.__index = UIComTabBtn1Item
function UIComTabBtn1Item:__InitCtrl()
  self.mText_Name = self:GetText("Root/GrpText/Text_Name")
  self.mBtn_Item = self:GetSelfButton()
  self.mTrans_Lock = self:GetRectTransform("Root/GrpLock")
end
UIComTabBtn1Item.mData = nil
UIComTabBtn1Item.mObj = nil
function UIComTabBtn1Item:InitCtrl(root)
  local obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComTabBtn1ItemV2.prefab", self))
  self.mObj = obj
  self.ui = UIUtils.GetUIBindTable(obj)
  self:SetRoot(obj.transform)
  obj.transform:SetParent(root, false)
  obj.transform.localScale = vectorone
  self:__InitCtrl()
end
function UIComTabBtn1Item:SetData(data)
  self.mData = data
  if data.name.str ~= nil then
    self.ui.mText_Name.text = data.name.str
  else
    self.ui.mText_Name.text = data.name
  end
  self:UpdateLock()
end
function UIComTabBtn1Item:SetLock(IsLocked)
  setactive(self.ui.mTrans_Locked, IsLocked)
end
function UIComTabBtn1Item:UpdateLock()
  if self:IsLocked() then
    setactive(self.ui.mTrans_Locked, true)
  else
    setactive(self.ui.mTrans_Locked, false)
  end
end
function UIComTabBtn1Item:IsLocked()
  if self.mData.id > 1 and not NetCmdQuestData:CheckNewbiePhaseIsReceived(self.mData.id - 1) then
    return true
  end
  return false
end
function UIComTabBtn1Item:SetRedPoint(isShow)
  setactive(self.ui.mTrans_RedPoint, isShow)
end
function UIComTabBtn1Item:SetSelect(isSelected)
  self.ui.mBtn_Self.interactable = not isSelected
end
function UIComTabBtn1Item:GetGlobalTab()
  return self.globalTab
end
function UIComTabBtn1Item:SetGlobalTabId(globalTabId)
  self.globalTab = GetOrAddComponent(self:GetRoot().gameObject, (typeof(GlobalTab)))
  self.globalTab:SetGlobalTabId(globalTabId)
end
function UIComTabBtn1Item:OnRelease()
  gfdestroy(self.mObj)
end
