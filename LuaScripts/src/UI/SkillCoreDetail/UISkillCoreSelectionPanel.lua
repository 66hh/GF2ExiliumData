require("UI.UIBasePanel")
require("UI.SkillCoreDetail.UISkillCoreSelectionPanelView")
UISkillCoreSelectionPanel = class("UISkillCoreSelectionPanel", UIBasePanel)
UISkillCoreSelectionPanel.__index = UISkillCoreSelectionPanel
UISkillCoreSelectionPanel.mView = nil
UISkillCoreSelectionPanel.MAX_SELECTION_COUNT = 20
UISkillCoreSelectionPanel.mSkillCoreItemList = nil
UISkillCoreSelectionPanel.mParentPanel = nil
UISkillCoreSelectionPanel.mSelectedCoreList = nil
UISkillCoreSelectionPanel.mExcludedCoreList = nil
UISkillCoreSelectionPanel.mPrevSelectedeCount = 0
function UISkillCoreSelectionPanel:ctor()
  UISkillCoreSelectionPanel.super.ctor(self)
end
function UISkillCoreSelectionPanel.Open()
  UISkillCoreSelectionPanel.OpenUI(UIDef.UISkillCoreSelectionPanel)
end
function UISkillCoreSelectionPanel.Close()
  UIManager.CloseUI(UIDef.UISkillCoreSelectionPanel)
end
function UISkillCoreSelectionPanel.Init(root, data)
  UISkillCoreSelectionPanel.super.SetRoot(UISkillCoreSelectionPanel, root)
  self = UISkillCoreSelectionPanel
  self.mParentPanel = data[1]
  self.mSelectedCoreList = data[2]
  self.mExcludedCoreList = data[3]
  self.mView = UISkillCoreSelectionPanelView
  self.mView:InitCtrl(root)
  self.mSkillCoreItemList = List:New()
  self:InitCoreItems()
  UIUtils.GetListener(self.mView.mBtn_Confirm.gameObject).onClick = self.OnConfirmClicked
  UIUtils.GetListener(self.mView.mBtn_Return.gameObject).onClick = self.OnReturnClick
end
function UISkillCoreSelectionPanel:InitCoreItems()
  local itemDataList = NetCmdCoreData:GetSkillCoreList()
  for i = 1, self.mSkillCoreItemList:Count() do
    self.mSkillCoreItemList[i]:SetData(nil)
  end
  for i = 0, itemDataList.Count - 1 do
    if not self.mExcludedCoreList:Contains(itemDataList[i].id) then
      local isSelected = false
      if self.mSelectedCoreList:Contains(itemDataList[i].id) then
        isSelected = true
      end
      if i < self.mSkillCoreItemList:Count() then
        self.mSkillCoreItemList[i + 1]:SetData(itemDataList[i])
        if isSelected == true then
          self.mSkillCoreItemList[i + 1]:SetSelected()
        end
      else
        local uiRepoItem = UIRepoSkillcoreItem:New()
        uiRepoItem:InitCtrl(self.mView.mTrans_CoreList)
        uiRepoItem:SetData(itemDataList[i])
        self.mSkillCoreItemList:Add(uiRepoItem)
        if itemDataList[i].gun_id ~= 0 then
          uiRepoItem:SetEquippedMask()
        else
          uiRepoItem:InitClickEvent(self.OnSkillCoreItemClicked)
        end
        if isSelected == true then
          uiRepoItem:SetSelected()
        end
      end
    end
  end
  local count = self:GetSelectionCount()
  if count >= UISkillCoreSelectionPanel.MAX_SELECTION_COUNT then
    self:SetUnavailableItem(true)
  end
  if 0 < count then
    setactive(self.mView.mBtn_Confirm.gameObject, true)
  else
    setactive(self.mView.mBtn_Confirm.gameObject, false)
  end
end
function UISkillCoreSelectionPanel.OnSkillCoreItemClicked(item)
  self = UISkillCoreSelectionPanel
  local count = self:GetSelectionCount()
  if count < UISkillCoreSelectionPanel.MAX_SELECTION_COUNT or item.mIsSelected == true then
    item:SkillCoreSelection()
  end
  count = self:GetSelectionCount()
  if count >= UISkillCoreSelectionPanel.MAX_SELECTION_COUNT then
    self:SetUnavailableItem(true)
  else
    self:SetUnavailableItem(false)
  end
  if 0 < count then
    setactive(self.mView.mBtn_Confirm.gameObject, true)
  else
    setactive(self.mView.mBtn_Confirm.gameObject, false)
  end
end
function UISkillCoreSelectionPanel:GetSelectionCount()
  local count = 0
  for i = 1, self.mSkillCoreItemList:Count() do
    if self.mSkillCoreItemList[i].mIsSelected == true then
      count = count + 1
    end
  end
  return count + self.mPrevSelectedeCount
end
function UISkillCoreSelectionPanel:SetUnavailableItem(flag)
  for i = 1, self.mSkillCoreItemList:Count() do
    if self.mSkillCoreItemList[i].mIsSelected == false then
      self.mSkillCoreItemList[i]:SetUnavailableMask(flag)
    end
  end
end
function UISkillCoreSelectionPanel.OnConfirmClicked()
  self = UISkillCoreSelectionPanel
  local list = List:New()
  for i = 1, self.mSkillCoreItemList:Count() do
    if self.mSkillCoreItemList[i].mIsSelected == true then
      list:Add(self.mSkillCoreItemList[i].mData.id)
    end
  end
  MessageSys:SendMessage(11003, self.mParentPanel, list)
  self.Close()
end
function UISkillCoreSelectionPanel.OnReturnClick(gameobj)
  self = UISkillCoreSelectionPanel
  self.Close()
end
function UISkillCoreSelectionPanel.UpdateView()
  self = UISkillCoreSelectionPanel
end
function UISkillCoreSelectionPanel.OnShow()
  self = UISkillCoreSelectionPanel
end
function UISkillCoreSelectionPanel.OnRelease()
  self = UISkillCoreSelectionPanel
end
