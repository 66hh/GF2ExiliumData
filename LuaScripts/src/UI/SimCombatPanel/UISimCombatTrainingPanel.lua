require("UI.UIBasePanel")
require("UI.SimCombatPanel.UISimCombatTrainingPanelView")
require("UI.SimCombatPanel.Item.SimCombatTrainingListItem")
require("UI.BattleIndexPanel.UIBattleDetailDialog")
UISimCombatTrainingPanel = class("UISimCombatTrainingPanel", UIBasePanel)
UISimCombatTrainingPanel.__index = UISimCombatTrainingPanel
UISimCombatTrainingPanel.mView = nil
UISimCombatTrainingPanel.stageDataList = {}
UISimCombatTrainingPanel.curStage = nil
UISimCombatTrainingPanel.lastIndex = 0
UISimCombatTrainingPanel.maxLevel = 0
UISimCombatTrainingPanel.nowLevelItem = nil
UISimCombatTrainingPanel.isPlayAni = false
UISimCombatTrainingPanel.jumpID = nil
UISimCombatTrainingPanel.currentNum = 0
UISimCombatTrainingPanel.itemsTab = nil
function UISimCombatTrainingPanel:ctor()
  UISimCombatTrainingPanel.super.ctor(self)
end
function UISimCombatTrainingPanel.Open()
  self = UISimCombatTrainingPanel
end
function UISimCombatTrainingPanel:CloseUISimCombatTrainingPanel()
  UIManager.CloseUI(UIDef.UISimCombatTrainingPanel)
  self:OnReleaseUISimCombatTrainingPanel()
end
function UISimCombatTrainingPanel:OnHide()
  self = UISimCombatTrainingPanel
  self:Show(false)
end
function UISimCombatTrainingPanel:OnInit(root, data)
  self:InitData()
  UISimCombatTrainingPanel.mData = data
  UISimCombatTrainingPanel.mView = UISimCombatTrainingPanelView
  UISimCombatTrainingPanel.mView:InitCtrl(root)
  UISimCombatTrainingPanel.stageDataList = {}
  UISimCombatTrainingPanel.curStage = nil
  UISimCombatTrainingPanel.itemsTab = nil
  UIUtils.GetButtonListener(self.mView.mBtn_Close.gameObject).onClick = function(gObj)
    UISimCombatTrainingPanel:onClickExit()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_Info.gameObject).onClick = function()
    UISimCombatTrainingPanel:OnClickRewardInfo()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_CommanderCenter.gameObject).onClick = function()
    UIBattleIndexPanelV2.currentType = -1
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_Return.gameObject).onClick = function()
    UISimCombatTrainingPanel:OnReturnCurrentLevel()
  end
  self:InitData()
  NetCmdStageRecordData:RequestStageRecordByType(CS.GF2.Data.StageType.TowerStage, function(ret)
    if ret == ErrorCodeSuc then
      UISimCombatTrainingPanel:UpdatePanel()
      UISimCombatTrainingPanel:SetEnableMask(false)
    end
  end)
  if self.mData then
    if type(self.mData) == "number" then
      local data = TableData.listSimCombatEntranceDatas:GetDataById(self.mData)
      self.mView.mText_Title.text = data.name.str
    elseif type(self.mData) == "userdata" then
      local data = TableData.listSimCombatEntranceDatas:GetDataById(23)
      self.mView.mText_Title.text = data.name.str
      if self.mData[0] ~= nil then
        self.jumpID = self.mData[0]
      end
    end
  end
end
function UISimCombatTrainingPanel:OnShowStart()
  self = UISimCombatTrainingPanel
  self:PlayListFadeIn()
end
function UISimCombatTrainingPanel:OnReleaseUISimCombatTrainingPanel()
  UISimCombatTrainingPanel.stageDataList = {}
  UISimCombatTrainingPanel.curStage = nil
  UISimCombatTrainingPanel.isPlayAni = false
end
function UISimCombatTrainingPanel.ClearUIRecordData()
  UIBattleIndexPanel.currentType = -1
  UIChapterInfoPanel.curDiff = 1
end
function UISimCombatTrainingPanel:InitData()
  for i = 0, TableData.listAdvancedTrainingDatas.Count - 1 do
    local data = TableData.listAdvancedTrainingDatas[i]
    if data then
      table.insert(self.stageDataList, data)
    end
  end
end
function UISimCombatTrainingPanel:UpdatePanel()
  self.maxLevel = NetCmdSimulateBattleData:GetAdvancedMaxLevel()
  if self.jumpID then
    self.currentNum = self.jumpID <= self.currentNum and self.jumpID or self.currentNum
    self.jumpID = nil
  end
  self.mView.mText_CurrentLevel.text = self.maxLevel < 10 and "0" .. self.maxLevel or self.maxLevel
  self.mView.mText_TotalLevel.text = #self.stageDataList
  self:InitTrainingList()
  self:InitRewardList()
end
function UISimCombatTrainingPanel:OnClickStage(item)
  if item then
    if UISimCombatTrainingPanel.curStage and UISimCombatTrainingPanel.curStage.mData.id == item.mData.id then
      return
    end
    local record = NetCmdStageRecordData:GetStageRecordById(item.stageData.id)
    self:ShowStageInfo(item.stageData, record, item)
    for k, v in ipairs(self.itemsTab) do
      if v == item.mObj then
        UIUtils.GetButton(v, "Trans_Btn_GrpCompleted").interactable = false
        UIUtils.GetButton(v, "Trans_Btn_GrpNow").interactable = false
        UIUtils.GetButton(v, "Trans_Btn_GrpLocked").interactable = false
      else
        UIUtils.GetButton(v, "Trans_Btn_GrpCompleted").interactable = true
        UIUtils.GetButton(v, "Trans_Btn_GrpNow").interactable = true
        UIUtils.GetButton(v, "Trans_Btn_GrpLocked").interactable = true
      end
    end
  end
end
function UISimCombatTrainingPanel:ShowNowTraining()
  if self.nowLevelItem then
    self.curStage = nil
    self:OnClickStage(self.nowLevelItem)
    self.isPlayAni = false
    self:SetEnableMask(self.isPlayAni)
  end
end
function UISimCombatTrainingPanel:OnClickRewardInfo()
  UIManager.OpenUIByParam(UIDef.UICommonReadmePanel, UIDef.UISimCombatTrainingPanel)
end
function UISimCombatTrainingPanel:InitTrainingList()
  function self.mView.mVirtualList.itemProvider()
    local item = self:TrainingProvider()
    return item
  end
  function self.mView.mVirtualList.itemRenderer(index, renderDataItem)
    self:TrainingRenderer(index, renderDataItem)
  end
  self:UpdateTrainingPanel()
end
function UISimCombatTrainingPanel:TrainingProvider()
  local itemView = SimCombatTrainingListItem.New()
  itemView:InitCtrl(self.mView.mTrans_TrainingList.transform)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView.mUIRoot.gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UISimCombatTrainingPanel:TrainingRenderer(index, renderDataItem)
  local itemData = self.stageDataList[index + 1]
  local item = renderDataItem.data
  item:SetData(itemData, self.maxLevel)
  if self.currentNum > 0 and self.currentNum == item.mData.id then
    self.nowLevelItem = item
  end
  item:SetButtonCallback(function()
    self:OnClickStage(item)
  end)
  if item.isUnLock then
    self.lastIndex = item.mData.sequence
  end
  table.insert(self.itemsTab, item.mObj)
end
function UISimCombatTrainingPanel:UpdateTrainingPanel()
  self.itemsTab = {}
  self.mView.mVirtualList.numItems = #self.stageDataList
  self.mView.mVirtualList:Refresh()
  TimerSys:DelayCall(1, function()
    local num = self.currentNum > 0 and self.currentNum or self.maxLevel + 1
    self:ScrollToPos(num, false)
    self:ShowNowTraining()
  end)
end
function UISimCombatTrainingPanel:ShowStageInfo(stageData, stageRecord, item)
  UISimCombatTrainingPanel.curStage = item
  UIBattleDetailDialog.OpenBySimTrainingData(UIDef.UISimCombatTrainingPanel, stageData, stageRecord, item.mData, self.maxLevel, function()
    UISimCombatTrainingPanel:onClickCloseLauncher()
  end)
end
function UISimCombatTrainingPanel:onClickCloseLauncher()
  if UISimCombatTrainingPanel.curStage then
    UISimCombatTrainingPanel.curStage = nil
  end
  for k, v in ipairs(self.itemsTab) do
    UIUtils.GetButton(v, "Trans_Btn_GrpCompleted").interactable = true
    UIUtils.GetButton(v, "Trans_Btn_GrpNow").interactable = true
    UIUtils.GetButton(v, "Trans_Btn_GrpLocked").interactable = true
  end
end
function UISimCombatTrainingPanel:InitRewardList()
  local rewardList = self:GetRaidRewardList()
  if rewardList then
    for i, reward in ipairs(rewardList) do
      local item = UICommonItem.New()
      item:InitObj(self.mView.mTrans_RewardItem)
      item:SetItemData(reward.itemId, reward.num)
    end
  else
    setactive(self.mView.mTrans_RewardItem, false)
  end
end
function UISimCombatTrainingPanel:GetRaidRewardList()
  local count = NetCmdItemData:GetResItemCount(GlobalConfig.TrainingTicket)
  if 0 < count then
    if 0 >= self.maxLevel then
      return nil
    end
    local data = TableData.listAdvancedTrainingDatas:GetDataById(self.maxLevel)
    if data then
      local rewardList = {}
      local strReward = data.unlock_raid_reward
      for item, num in pairs(strReward) do
        local reward = {
          itemId = tonumber(item),
          num = tonumber(num)
        }
        table.insert(rewardList, reward)
      end
      return rewardList
    end
  end
  return nil
end
function UISimCombatTrainingPanel:onClickExit()
  self:CloseUISimCombatTrainingPanel()
end
function UISimCombatTrainingPanel:SetEnableMask(enable)
  if self.mView.mTrans_Mask then
    setactive(self.mView.mTrans_Mask.gameObject, enable)
  end
end
function UISimCombatTrainingPanel:OnReturnCurrentLevel()
  self:ScrollToPos(self.maxLevel + 1, true)
end
function UISimCombatTrainingPanel:PlayListFadeIn()
  self:SetEnableMask(true)
  DOTween.DoCanvasFade(self.mView.Scroll_TrainingList, 0, 1, 0.3, 0.5, function()
    self:SetEnableMask(false)
  end)
end
function UISimCombatTrainingPanel:ScrollToPos(index, needAni, callback)
  local virtual = self.mView.mVirtualList
  local viewport = virtual.viewport
  local content = virtual.content
  local verticallayout = getcomponent(self.mView.mTrans_TrainingList, typeof(CS.UnityEngine.UI.VerticalLayoutGroup))
  local offset = virtual.paddingHeight + verticallayout.spacing
  local halfView = viewport.rect.size.y / 2
  local movedis = offset * (index - 1) + halfView
  if math.abs(movedis) > content.rect.size.y - halfView then
    movedis = content.rect.size.y - halfView
  end
  if halfView > math.abs(movedis) then
    movedis = halfView
  end
  movedis = movedis - viewport.localPosition.y
  if needAni then
    UITweenManager.PlayAnchoredPositionYTween(content, movedis, 0.5)
  else
    content.anchoredPosition = Vector2(content.anchoredPosition.x, movedis)
  end
end
