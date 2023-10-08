require("UI.BattleIndexPanel.UIBattleDetailDialog")
require("UI.SimCombatPanel.Tutorial.Item.UISimCombatTutorialChapterItem")
require("UI.UIBasePanel")
require("UI.SimCombatPanel.Tutorial.UISimCombatTutorialChapterPanelView")
UISimCombatTutorialChapterPanel = class("UISimCombatTutorialChapterPanel", UIBasePanel)
UISimCombatTutorialChapterPanel.__index = UISimCombatTutorialChapterPanel
UISimCombatTutorialChapterPanel.mView = nil
UISimCombatTutorialChapterPanel.levelItemList = {}
UISimCombatTutorialChapterPanel.mLastSelectItem = nil
function UISimCombatTutorialChapterPanel:ctor()
  UISimCombatTutorialChapterPanel.super.ctor(self)
end
function UISimCombatTutorialChapterPanel.Open()
end
function UISimCombatTutorialChapterPanel.Close()
  UIManager.CloseUI(UIDef.UISimCombatTutorialChapterPanel)
end
function UISimCombatTutorialChapterPanel.Hide()
end
function UISimCombatTutorialChapterPanel:OnInit(root, data)
  self.RedPointType = {
    RedPointConst.ChapterReward
  }
  UISimCombatTutorialChapterPanel.super.SetRoot(UISimCombatTutorialChapterPanel, root)
  UISimCombatTutorialChapterPanel.mData = data
  UISimCombatTutorialChapterPanel.mView = UISimCombatTutorialChapterPanelView
  self.ui = {}
  UISimCombatTutorialChapterPanel.mView:InitCtrl(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function(gObj)
    self.lastUnfinishedId = nil
    UISimCombatTutorialChapterPanel.Close()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    self.lastUnfinishedId = nil
    UIManager.JumpToMainPanel()
  end
  self.ui.mText_TextTitle.text = data.StcData.chapter_name.str
  self.rewardItem = UICommonItem.New()
  self.rewardItem:InitCtrl(self.ui.mTrans_IconItem)
  for itemId, num in pairs(data.StcData.chapter_reward) do
    self.rewardItem:SetItemData(itemId, num)
  end
  UIUtils.GetButtonListener(self.rewardItem.ui.mBtn_Select.gameObject).onClick = function()
    self:OnReceiveItem(self.rewardItem)
  end
  self.data = data
  local levelDataList = data.LevelDataList
  for i = 0, levelDataList.Count - 1 do
    local item
    if self.levelItemList[i + 1] == nil then
      item = UISimCombatTutorialChapterItem.New()
      item:InitCtrl(self.ui.mTrans_Content)
      table.insert(self.levelItemList, item)
      UIUtils.GetButtonListener(item.ui.mBtn_Self.gameObject).onClick = function(gObj)
        self:OnClickLevel(item)
      end
    end
  end
  function self.OnItemShow(index)
    self.levelItemList[index + 1]:SetData(levelDataList[index])
  end
  self.ui.mFade_Content:onShow("+", self.OnItemShow)
  function self.InitFade()
    self.ui.mFade_Content:InitFade()
  end
  MessageSys:AddListener(CS.GF2.Message.UIEvent.OnLoadingEnd, self.InitFade)
  self.panelWidth = UISystem.UICanvas.transform.sizeDelta.x
end
function UISimCombatTutorialChapterPanel:OnReceiveItem(item)
  self.skipFade = true
  if not self.data.IsCompleted or self.data.IsReceived then
    UITipsPanel.Open(TableData.GetItemData(item.itemId), item.itemNum)
    return
  end
  for itemId, num in pairs(self.data.StcData.chapter_reward) do
    if TipsManager.CheckItemIsOverflowAndStop(itemId, num) then
      return
    end
  end
  NetCmdSimulateBattleData:ReqSimCombatTutorialTakeChapterReward(self.data.StcData.id, function()
    self:TakeQuestRewardCallBack()
  end)
end
function UISimCombatTutorialChapterPanel:TakeQuestRewardCallBack()
  UIManager.OpenUIByParam(UIDef.UICommonReceivePanel)
  MessageSys:SendMessage(CS.GF2.Message.UIEvent.RefreshChapterInfo, nil)
end
function UISimCombatTutorialChapterPanel:OnShowStart()
  self:InitLevelData(self.data)
  if self.data.IsReceived then
    self.ui.mText_ItemState.text = TableData.GetHintById(103085)
    self.ui.mText_Text.text = TableData.GetHintById(103090)
  else
    if self.data.IsCompleted then
      self.ui.mText_Text.text = TableData.GetHintById(103090)
    else
      self.ui.mText_Text.text = TableData.GetHintById(103092)
    end
    self.ui.mText_ItemState.text = TableData.GetHintById(103076)
  end
  self.ui.mText_TextNum.text = self.data.Progress .. "%"
  self.ui.mSlider_Bar.FillAmount = self.data.Progress / 100
  self.rewardItem:SetRedPoint(self.data.IsCompleted and not self.data.IsReceived)
  for index = 0, self.data.LevelDataList.Count - 1 do
    local levelData = self.data.LevelDataList[index]
    if not levelData.IsCompleted and levelData.IsUnlocked then
      self.ui.mVirtualListEx_List.horizontalNormalizedPosition = index == 0 and 0 or (index + 1) / #self.levelItemList
    elseif index + 1 == #self.levelItemList and levelData.IsCompleted then
      self.ui.mVirtualListEx_List.horizontalNormalizedPosition = 1
    end
  end
end
function UISimCombatTutorialChapterPanel:InitLevelData(data)
  if self.lastUnfinishedId ~= nil and NetCmdSimulateBattleData:CheckHasNewLevelUnlocked(self.lastUnfinishedId) then
    TimerSys:DelayCall(1.5, function()
      PopupMessageManager.PopupStateChangeString(TableData.GetHintById(103091))
      for i = 1, #self.levelItemList do
        if self.lastUnfinishedId == self.levelItemList[i].mData.StcData.id then
          self.levelItemList[i]:TriggerGuide()
        end
      end
      self.lastUnfinishedId = nil
    end)
  end
  if self.skipFade == true then
    self.skipFade = nil
  else
    self.ui.mFade_Content:InitFade()
  end
end
function UISimCombatTutorialChapterPanel:OnClickLevel(item)
  local record = NetCmdStageRecordData:GetStageRecordById(item.mData.StageData.id)
  UIBattleDetailDialog.OpenBySimTeachingData(UIDef.UISimCombatTutorialChapterPanel, item.mData, record, true, function()
    self.skipFade = true
    self:ResetScroll()
    if self.mLastSelectItem ~= nil then
      self.mLastSelectItem:SetSelected(false)
    end
  end)
  self:ScrollMoveToMid(item.mUIRoot.transform.localPosition.x, true)
  if self.mLastSelectItem ~= nil then
    self.mLastSelectItem:SetSelected(false)
  end
  item:SetSelected(true)
  self.mLastSelectItem = item
end
function UISimCombatTutorialChapterPanel:ScrollMoveToMid(toPosX, needSlide)
  local toX = (self.panelWidth - 420) / 2 - toPosX - self.ui.mTrans_Content.anchoredPosition.x
  local toPos = Vector3(toX, self.ui.mTrans_List.localPosition.y, 0)
  if needSlide then
    CS.UITweenManager.PlayLocalPositionTween(self.ui.mTrans_List, self.ui.mTrans_List.localPosition, toPos, 0.3)
  else
    self.ui.mTrans_List.localPosition = toPos
  end
end
function UISimCombatTutorialChapterPanel:ResetScroll()
  local toPos = Vector3(0, self.ui.mTrans_List.anchoredPosition.y, 0)
  CS.UITweenManager.PlayLocalPositionTween(self.ui.mTrans_List.transform, self.ui.mTrans_List.transform.localPosition, toPos, 0.3)
end
function UISimCombatTutorialChapterPanel:OnClose()
  if self.mLastSelectItem ~= nil and self.mLastSelectItem.mData.IsCompleted == false then
    self.lastUnfinishedId = self.mLastSelectItem.mData.StcData.id
  end
  self.ui.mFade_Content:onShow("-", self.OnItemShow)
  self.mLastSelectItem = nil
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.OnLoadingEnd, self.InitFade)
  for i = 1, #self.levelItemList do
    gfdestroy(self.levelItemList[i]:GetRoot())
  end
  gfdestroy(self.rewardItem:GetRoot())
  self.levelItemList = {}
end
function UISimCombatTutorialChapterPanel:UpdateRewardRedPoint()
  setactive(self.ui.mTrans_RedPoint, NetCmdSimulateBattleData:CheckTeachingNoteReadRedPoint() or NetCmdSimulateBattleData:CheckTeachingNoteProgressRedPoint())
end
function UISimCombatTutorialChapterPanel:OnTop()
  self:OnShowStart()
end
function UISimCombatTutorialChapterPanel:OnRecover()
  self:OnShowStart()
end
function UISimCombatTutorialChapterPanel:OnBackFrom()
  self:OnShowStart()
end
function UISimCombatTutorialChapterPanel:OnSave()
  self:OnRelease()
end
function UISimCombatTutorialChapterPanel:OnRelease()
  self.levelItemList = {}
end
