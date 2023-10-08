require("UI.BattleIndexPanel.Content.UIBattleIndexHardSubPanel")
require("UI.BattleIndexPanel.Item.UIBattleIndexModeListItem")
require("UI.BattleIndexPanel.Content.UIBattleIndexSimCombatSubPanel")
require("UI.UIBasePanel")
require("UI.BattleIndexPanel.UIBattleIndexPanelV2View")
require("UI.BattleIndexPanel.Content.UIChapterInfoPanel")
require("UI.BattleIndexPanel.Content.UIBattleIndexStorySubPanel")
require("UI.BattleIndexPanel.Content.UIBattleIndexResourcesSubPanel")
require("UI.SimCombatPanel.ResourcesCombat.UISimCombatGlobal")
require("UI.BattleIndexPanel.Item.UIBattleIndexResourcesCard")
require("UI.BattleIndexPanel.Content.UIBattleIndexBranchStorySubPanel")
UIBattleIndexPanelV2 = class("UIBattleIndexPanelV2", UIBasePanel)
UIBattleIndexPanelV2.__index = UIBattleIndexPanelV2
UIBattleIndexPanelV2.tabList = {}
UIBattleIndexPanelV2.mView = nil
UIBattleIndexPanelV2.currentType = -1
UIBattleIndexPanelV2.SUB_PANEL_ID = {
  STORY = 1,
  HARD = 3,
  SIM_COMBAT = 2,
  SIM_RESOURCES = 4,
  BRANCH_STORY = 5
}
function UIBattleIndexPanelV2:OnSave()
  self:OnRelease()
end
function UIBattleIndexPanelV2:ctor()
  UIBattleIndexPanelV2.super.ctor(self)
end
function UIBattleIndexPanelV2:Close()
  UIManager.CloseUI(UIDef.UIBattleIndexPanel)
  self:OnRelease()
end
function UIBattleIndexPanelV2:OnBackFrom()
  for id, item in pairs(self.tabList) do
    item:SetData(TableData.listStageIndexDatas:GetDataById(id))
  end
  self.mStorySubView:RefreshTabs()
  self.mSimCombatSubView:RefreshTabs()
  if self.mStorySubView.OnBackFrom then
    self.mStorySubView:OnBackFrom()
  end
  if self.mBranchStorySubView then
    self.mBranchStorySubView:OnBackFrom()
  end
  if self.currentType == self.SUB_PANEL_ID.SIM_RESOURCES then
    UIBattleIndexPanelV2.mSimResourcesSubView:OnBackFrom()
  end
  self:InitRecentData()
end
function UIBattleIndexPanelV2:OnRecover()
  self:OnShowStart(true)
end
function UIBattleIndexPanelV2:OnShowStart(isRecover)
  for id, item in pairs(self.tabList) do
    item:SetData(TableData.listStageIndexDatas:GetDataById(id))
  end
  self.mStorySubView:RefreshTabs()
  self.mSimCombatSubView:RefreshTabs()
  if self.mStorySubView.OnShowStart then
    self.mStorySubView:OnShowStart(isRecover)
  end
  if self.currentType == self.SUB_PANEL_ID.SIM_RESOURCES then
    UIBattleIndexPanelV2.mSimResourcesSubView:OnShow()
  end
end
function UIBattleIndexPanelV2:OnShowFinish()
  if self.mStorySubView.OnShowFinish then
    self.mStorySubView:OnShowFinish()
  end
end
function UIBattleIndexPanelV2:OnInit(root, data)
  UIBattleIndexPanelV2.super.SetRoot(UIBattleIndexPanelV2, root)
  if data then
    if type(data) == "userdata" then
      if data.Length == 2 then
        local chapterID = data[1]
        if 0 < chapterID then
          self.curChapterId = data[1]
        else
          self.curChapterId = NetCmdDungeonData:GetCurrentStoryByType(1).chapter
        end
      end
      self.currentType = data[0]
    elseif data[1] then
      self.currentType = data[1]
      self.curChapterId = NetCmdDungeonData:GetCurrentStoryByType(1).chapter
    end
  else
    self.curChapterId = NetCmdDungeonData:GetCurrentStoryByType(1).chapter
    self.mData = data
  end
  UIBattleIndexPanelV2.mView = UIBattleIndexPanelV2View.New()
  self.Ui = {}
  UIBattleIndexPanelV2.mView:InitCtrl(root, self.Ui)
  UIUtils.GetButtonListener(self.Ui.mBtn_Back.gameObject).onClick = function()
    self:OnClickBack()
  end
  UIUtils.GetButtonListener(self.Ui.mBtn_Home.gameObject).onClick = function()
    self:OnClickHome()
  end
  function self.updateChapter()
    self:UpdateRedPoint()
  end
  function self.showUnlock()
    self.curChapterId = NetCmdDungeonData:GetCurrentStoryByType(1).chapter
    UIBattleIndexPanelV2.mStorySubView:SetCurrentIndex(self.curChapterId)
    UIBattleIndexPanelV2.mStorySubView:OnClickTabByIndex()
  end
  MessageSys:AddListener(UIEvent.UINewChapterItemFinish, self.showUnlock)
  CS.GF2.Message.MessageSys.Instance:AddListener(CS.GF2.Message.UIEvent.RefreshChapterInfo, self.updateChapter)
  UIBattleIndexPanelV2.mSimCombatSubView = UIBattleIndexSimCombatSubPanel.New()
  UIBattleIndexPanelV2.mSimCombatSubView:InitCtrl(self.Ui.mTrans_SimCombat)
  UIBattleIndexPanelV2.mStorySubView = UIBattleIndexStorySubPanel
  if self.curChapterId ~= nil and self.curChapterId == NetCmdDungeonData.NewChapterID then
    self.curChapterId = self.curChapterId - 1
  end
  if self.curChapterId ~= nil and 0 >= self.curChapterId then
    self.curChapterId = 1
  end
  UIBattleIndexPanelV2.mStorySubView:InitCtrl(self.Ui.mTrans_Story, self)
  UIBattleIndexPanelV2.mSimResourcesSubView = UIBattleIndexResourcesSubPanel
  UIBattleIndexPanelV2.mSimResourcesSubView:InitCtrl(self.Ui.mTrans_SimResources)
  self:InitRecentData()
  self:InitSubPanels()
end
function UIBattleIndexPanelV2:InitRecentData()
  self.isCanInitBranchStory = false
  self.isBranchStoryLock = true
  self.recentUnlockid = NetCmdThemeData:GetRecentActivityUnlockid()
  if self.recentUnlockid > 0 then
    self.recentActOpen = AccountNetCmdHandler:CheckSystemIsUnLock(self.recentUnlockid)
  else
    self.recentActOpen = true
  end
  local indexData = TableData.listStageIndexDatas:GetDataById(self.SUB_PANEL_ID.BRANCH_STORY)
  if indexData and 0 < indexData.detail_id.Count then
    for i = 0, indexData.detail_id.Count - 1 do
      local chapterData = TableData.listChapterDatas:GetDataById(indexData.detail_id[i])
      if chapterData then
        local planActivity = TableData.listPlanDatas:GetDataById(chapterData.plan_id)
        if planActivity and CGameTime:GetTimestamp() >= planActivity.open_time and CGameTime:GetTimestamp() < planActivity.close_time then
          self.isCanInitBranchStory = true
          self.isBranchStoryLock = false
          break
        end
      end
    end
  end
  if self.isCanInitBranchStory and self.recentActOpen and UIBattleIndexPanelV2.mBranchStorySubView == nil then
    UIBattleIndexPanelV2.mBranchStorySubView = UIBattleIndexBranchStorySubPanel
    UIBattleIndexPanelV2.mBranchStorySubView:InitCtrl(self.Ui.mTrans_GrpBranch, self.SUB_PANEL_ID.BRANCH_STORY, self.isBranchStoryLock)
  end
end
function UIBattleIndexPanelV2:InitSubPanels()
  self:InitStorySubPanel()
  self:InitBranchStorySubPanel()
  self:InitHardPanel()
  self:InitSimResourcesPanel()
  self:InitSimCombatPanel()
  if UIBattleIndexPanelV2.currentType > 0 then
    self:EnableSubPanel(UIBattleIndexPanelV2.currentType)
  elseif UIBattleIndexGlobal.CachedTabIndex and 0 < UIBattleIndexGlobal.CachedTabIndex then
    self:EnableSubPanel(UIBattleIndexGlobal.CachedTabIndex)
  else
    self:EnableSubPanel(self.SUB_PANEL_ID.STORY)
  end
end
function UIBattleIndexPanelV2:InitStorySubPanel()
  self:AddSubPanel(self.SUB_PANEL_ID.STORY)
end
function UIBattleIndexPanelV2:InitBranchStorySubPanel()
  self:AddSubPanel(self.SUB_PANEL_ID.BRANCH_STORY)
end
function UIBattleIndexPanelV2:InitHardPanel()
end
function UIBattleIndexPanelV2:InitSimCombatPanel()
  self:AddSubPanel(self.SUB_PANEL_ID.SIM_COMBAT)
end
function UIBattleIndexPanelV2:InitSimResourcesPanel()
  self:AddSubPanel(self.SUB_PANEL_ID.SIM_RESOURCES)
end
function UIBattleIndexPanelV2:AddSubPanel(id)
  local item
  if self.tabList[id] == nil then
    item = UIBattleIndexModeListItem.New()
    item:InitCtrl(self.Ui.mTrans_Content, self.Ui.mScrollChild_Content.childItem)
    self.tabList[id] = item
  else
    item = self.tabList[id]
  end
  item:SetData(TableData.listStageIndexDatas:GetDataById(id))
  UIUtils.GetButtonListener(item.ui.mBtn_Item.gameObject).onClick = function()
    self:EnableSubPanel(id)
  end
end
function UIBattleIndexPanelV2:EnableSubPanel(index)
  if self.tabList[index].mIsLock and self.tabList[index].mData.unlock > 0 then
    local unlockData = TableData.listUnlockDatas:GetDataById(self.tabList[index].mData.unlock)
    local str = UIUtils.CheckUnlockPopupStr(unlockData)
    PopupMessageManager.PopupString(str)
    MessageSys:SendMessage(GuideEvent.OnTabSwitchFail, nil)
    return
  end
  if index == self.SUB_PANEL_ID.BRANCH_STORY then
    if not self.isCanInitBranchStory then
      PopupMessageManager.PopupString(TableData.GetHintById(210005))
      MessageSys:SendMessage(GuideEvent.OnTabSwitchFail, nil)
      return
    end
    if not self.recentActOpen then
      local unlockData = TableDataBase.listUnlockDatas:GetDataById(self.recentUnlockid, true)
      if unlockData then
        local str = UIUtils.CheckUnlockPopupStr(unlockData)
        PopupMessageManager.PopupString(str)
      end
      MessageSys:SendMessage(GuideEvent.OnTabSwitchFail, nil)
      return
    end
  end
  UIBattleIndexPanelV2.currentType = index
  for i, item in pairs(self.tabList) do
    item.ui.mBtn_Item.interactable = i ~= index
  end
  if index == self.SUB_PANEL_ID.STORY then
    self.Ui.mAnimator_Root:SetInteger("SwitchTab", 0)
  elseif index == self.SUB_PANEL_ID.HARD then
    self.Ui.mAnimator_Root:SetInteger("SwitchTab", 1)
  elseif index == self.SUB_PANEL_ID.SIM_COMBAT then
    self.Ui.mAnimator_Root:SetInteger("SwitchTab", 2)
  elseif index == self.SUB_PANEL_ID.SIM_RESOURCES then
    self.Ui.mAnimator_Root:SetInteger("SwitchTab", 3)
  elseif index == self.SUB_PANEL_ID.BRANCH_STORY then
    self.Ui.mAnimator_Root:SetInteger("SwitchTab", 4)
  end
  setactive(self.Ui.mTrans_Story, index == self.SUB_PANEL_ID.STORY)
  setactive(self.Ui.mTrans_Hard, index == self.SUB_PANEL_ID.HARD)
  setactive(self.Ui.mTrans_SimCombat, index == self.SUB_PANEL_ID.SIM_COMBAT)
  setactive(self.Ui.mTrans_SimResources, index == self.SUB_PANEL_ID.SIM_RESOURCES)
  setactive(self.Ui.mTrans_GrpBranch, index == self.SUB_PANEL_ID.BRANCH_STORY)
  if index == self.SUB_PANEL_ID.SIM_RESOURCES then
    UIBattleIndexPanelV2.mSimResourcesSubView:Refresh()
  end
  if index == self.SUB_PANEL_ID.STORY or index == self.SUB_PANEL_ID.HARD then
    self.Ui.mAnimator_Root:SetTrigger("FX")
  end
  UIBattleIndexGlobal.CachedTabIndex = index
  MessageSys:SendMessage(GuideEvent.OnTabSwitched, UIDef.UIBattleIndexPanel, self.tabList[index]:GetGlobalTab())
end
function UIBattleIndexPanelV2:IsReadyToStartTutorial()
  if self.currentType == UIBattleIndexPanelV2.SUB_PANEL_ID.STORY then
    return UIBattleIndexPanelV2.mStorySubView:IsReadyToStartTutorial()
  end
  return true
end
function UIBattleIndexPanelV2:RefreshStoryBg(data)
  self.Ui.mImg_StoryMapBg.sprite = IconUtils.GetStageIcon(data.background)
  self.Ui.mImg_StoryMapBgFx.sprite = IconUtils.GetStageIcon(data.background)
  self.Ui.mAnimator_Root:SetTrigger("FX")
end
function UIBattleIndexPanelV2:RefreshHardBg(data)
  self.Ui.mImg_HardMapBg.sprite = IconUtils.GetStageIcon(data.background)
  self.Ui.mImg_HardMapBgFx.sprite = IconUtils.GetStageIcon(data.background)
  self.Ui.mAnimator_Root:SetTrigger("FX")
end
function UIBattleIndexPanelV2:OnClickBack()
  UIBattleIndexPanelV2.currentType = -1
  UIBattleIndexGlobal.CachedTabIndex = nil
  UIBattleIndexHardSubPanel.OnClose()
  UIBattleIndexStorySubPanel.OnClose()
  UIBattleIndexBranchStorySubPanel.OnClose()
  UIChapterGlobal:RecordChapterId(nil)
  if CS.DebugCenter.Instance.QuickLogInButton then
    UIManager:JumpToMainPanel()
  else
    UIBattleIndexPanelV2:Close()
  end
end
function UIBattleIndexPanelV2:OnClickHome()
  UIBattleIndexPanelV2.currentType = -1
  UIBattleIndexGlobal.CachedTabIndex = nil
  UIBattleIndexHardSubPanel.OnClose()
  UIBattleIndexStorySubPanel.OnClose()
  UIBattleIndexBranchStorySubPanel.OnClose()
  UIChapterGlobal:RecordChapterId(nil)
  UIManager:JumpToMainPanel()
end
function UIBattleIndexPanelV2:OnClose()
  UIBattleIndexPanelV2.currentType = -1
  MessageSys:RemoveListener(UIEvent.UINewChapterItemFinish, self.showUnlock)
  CS.GF2.Message.MessageSys.Instance:RemoveListener(CS.GF2.Message.UIEvent.RefreshChapterInfo, self.updateChapter)
  self:ReleaseCtrlTable(self.tabList)
  self.tabList = {}
  self.mStorySubView:OnRelease()
  self.mSimCombatSubView:OnRelease()
  self.mSimResourcesSubView:OnRelease()
  if self.mBranchStorySubView then
    self.mBranchStorySubView:OnRelease()
  end
  UIBattleIndexPanelV2.mView = nil
end
