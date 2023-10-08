require("UI.Common.UICommonItem")
require("UI.Common.UICommonReceivePanel")
require("UI.QuestPanel.UIQuestNewbieSlot")
require("UI.QuestPanel.UIQuestSubPanelBase")
UIQuestNewbiePanel = class("UIQuestNewbiePanel", UIQuestSubPanelBase)
UIQuestNewbiePanel.InOutCirc = CS.DG.Tweening.Ease.InOutCirc
function UIQuestNewbiePanel:ctor(go, parentPanel)
  self.ui = UIUtils.GetUIBindTable(go)
  self:SetRoot(go.transform)
  function self.ui.mVirtualListEx.itemRenderer(...)
    self:itemRenderer(...)
  end
  function self.ui.mVirtualListEx.itemProvider()
    return self:itemProvider()
  end
  UIUtils.AddBtnClickListener(self.ui.mContainer_ReceiveAll, function()
    self:onClickReceiveAll()
  end)
  function self.onPhaseChangedCallback(msg)
    self:onPhaseChanged(msg)
  end
  MessageSys:AddListener(UIEvent.OnNewbieQuestPhaseChanged, self.onPhaseChangedCallback)
  self.parentPanel = parentPanel
  self.curPhaseSlotDataList = nil
  self.previewRewardItemTable = self:initProgressRewardPreview()
  self.isPhaseChanged = false
end
function UIQuestNewbiePanel:Show()
  self.super.Show(self)
  local isAllPhaseComplete = NetCmdQuestData:CheckNewbiePhaseIsReceived(self:getMaxPhaseId())
  if isAllPhaseComplete then
    setactive(self.ui.mTrans_LeftPanel, false)
    setactive(self.ui.mTrans_RightPanel, false)
    setactive(self.ui.mTrans_GrpComplete, true)
    return
  else
    self.ui.mImage_CurPhaseProgress.fillAmount = 0
    self:Refresh()
  end
end
function UIQuestNewbiePanel:OnPanelBack()
  if self.isPhaseChanged then
    self.isPhaseChanged = false
    self.parentPanel.ui.mAnimator:SetTrigger("GrpNoviceTask_1_Refresh")
  end
  self:Refresh()
end
function UIQuestNewbiePanel:OnDialogBack()
  if self.isPhaseChanged then
    self.isPhaseChanged = false
    self.parentPanel.ui.mAnimator:SetTrigger("GrpNoviceTask_1_Refresh")
  end
  self:Refresh()
end
function UIQuestNewbiePanel:Hide()
  self.super.Hide(self)
end
function UIQuestNewbiePanel:Release()
  MessageSys:RemoveListener(UIEvent.OnNewbieQuestPhaseChanged, self.onPhaseChangedCallback)
  if self.progressTween then
    LuaDOTweenUtils.Kill(self.progressTween, false)
    self.progressTween = nil
  end
  self:ReleaseCtrlTable(self.previewRewardItemTable, true)
  self.curPhaseSlotDataList = nil
  self.isOpenShow = nil
  self.ui = nil
  self.parentPanel = nil
  self.isPhaseChanged = nil
end
function UIQuestNewbiePanel:Refresh()
  self.parentPanel:Refresh()
  self:refreshAllSlot()
  self:refreshLeftPanel()
end
function UIQuestNewbiePanel:GetTaskTypeId()
  return 3
end
function UIQuestNewbiePanel:GetAnimPageSwitchInt()
  return 1
end
function UIQuestNewbiePanel:initProgressRewardPreview()
  local tempTable = {}
  local template = self.ui.mScrollItem_RewardItem.childItem
  local guideQuestPhaseData = TableData.listGuideQuestPhaseDatas:GetDataById(self:getCurPhaseId())
  local rewards = UIUtils.GetKVSortItemTable(guideQuestPhaseData.reward_list)
  for index, pair in pairs(rewards) do
    local id = pair.id
    local num = pair.num
    local itemView = UICommonItem.New()
    itemView:InitCtrl(self.ui.mScrollItem_RewardItem.transform)
    itemView:SetItemData(id, num)
    table.insert(tempTable, itemView)
  end
  return tempTable
end
function UIQuestNewbiePanel:itemProvider()
  local template = self.ui.mScrollItem_NoviceItem.childItem
  local slot = UIQuestNewbieSlot.New(instantiate(template, self.ui.mScrollItem_NoviceItem.transform))
  local renderDataItem = RenderDataItem()
  renderDataItem.renderItem = slot:GetRoot().gameObject
  renderDataItem.data = slot
  return renderDataItem
end
function UIQuestNewbiePanel:itemRenderer(index, renderData)
  local slotData = self.curPhaseSlotDataList[index]
  local slot = renderData.data
  slot:SetData(slotData, index + 1, function()
    self:onSlotReceived()
  end)
end
function UIQuestNewbiePanel:refreshAllSlot()
  self.curPhaseSlotDataList = self:getCurPhaseSlotDataList()
  if not self.curPhaseSlotDataList or self.curPhaseSlotDataList.Count == 0 then
    return
  end
  self.ui.mVirtualListEx.numItems = self.curPhaseSlotDataList.Count
  self.ui.mVirtualListEx:Refresh()
end
function UIQuestNewbiePanel:refreshLeftPanel()
  self:refreshProgress()
  self:refreshLeftRewardPreview()
  self:refreshLeftReceiveBtn()
end
function UIQuestNewbiePanel:refreshProgress()
  local completedPhaseNum = self:getCompletedPhaseNum()
  local curPhaseNum = self:getCurPhaseId()
  local totalPhaseNum = self:getMaxPhaseId()
  self.ui.mSmoothMask_TotalProgressBar.FillAmount = completedPhaseNum / totalPhaseNum
  self.ui.mText_TotalProgress.text = TableData.GetHintById(112016, tostring(completedPhaseNum), tostring(totalPhaseNum))
  self.ui.mText_CurPhaseNum.text = tostring(curPhaseNum)
  local receivedCount = self:getCurPhaseReceivedSlotCount()
  local totalCount = self.curPhaseSlotDataList.Count
  if self.progressTween then
    LuaDOTweenUtils.Kill(self.progressTween, false)
  end
  local getter = function(tempSelf)
    return tempSelf.ui.mImage_CurPhaseProgress.fillAmount
  end
  local setter = function(tempSelf, value)
    tempSelf.ui.mImage_CurPhaseProgress.fillAmount = value
  end
  self.progressTween = LuaDOTweenUtils.ToOfFloat(self, getter, setter, receivedCount / totalCount, 1.5, nil)
  self.ui.mText_CurQuestProgress.text = TableData.GetHintById(112013, tostring(receivedCount), tostring(totalCount))
end
function UIQuestNewbiePanel:refreshLeftRewardPreview()
  for i, commonItem in ipairs(self.previewRewardItemTable) do
    commonItem:SetVisible(false)
  end
  local i = 1
  local guideQuestPhaseData = TableData.listGuideQuestPhaseDatas:GetDataById(self:getCurPhaseId())
  for itemId, num in pairs(guideQuestPhaseData.reward_list) do
    if self.previewRewardItemTable[i] == nil then
      local itemView = UICommonItem.New()
      itemView:InitCtrl(self.ui.mScrollItem_RewardItem.transform)
      table.insert(self.previewRewardItemTable, itemView)
    end
    self.previewRewardItemTable[i]:SetItemData(itemId, num)
    self.previewRewardItemTable[i]:SetVisible(true)
    i = i + 1
  end
end
function UIQuestNewbiePanel:refreshLeftReceiveBtn()
  setactive(self.ui.mTrans_NotReceive, false)
  setactive(self.ui.mTrans_Received, false)
  setactive(self.ui.mContainer_ReceiveAll, false)
  local receivedCount = self:getCurPhaseReceivedSlotCount()
  local totalCount = self.curPhaseSlotDataList.Count
  if receivedCount == totalCount then
    if NetCmdQuestData:CheckNewbiePhaseIsReceived(self:getCurPhaseId()) then
      setactive(self.ui.mTrans_Received, true)
    else
      setactive(self.ui.mContainer_ReceiveAll, true)
    end
  else
    setactive(self.ui.mTrans_NotReceive, true)
  end
end
function UIQuestNewbiePanel:getCurPhaseSlotDataList()
  local phaseId = self:getCurPhaseId()
  return NetCmdQuestData:GetGuideQuestListDatasByPhase(phaseId)
end
function UIQuestNewbiePanel:getCurPhaseId()
  return NetCmdQuestData:GetCurPhaseId()
end
function UIQuestNewbiePanel:getCompletedPhaseNum()
  return NetCmdQuestData:GetCompletedPhaseNum()
end
function UIQuestNewbiePanel:getCurPhaseReceivedSlotCount()
  local receivedCount = 0
  for k, newbieQuestData in pairs(self.curPhaseSlotDataList) do
    if newbieQuestData.isReceived then
      receivedCount = receivedCount + 1
    end
  end
  return receivedCount
end
function UIQuestNewbiePanel:getMaxPhaseId()
  local dataList = TableData.listGuideQuestPhaseDatas:GetList()
  return dataList[dataList.Count - 1].id
end
function UIQuestNewbiePanel:onClickReceiveAll()
  NetCmdQuestData:SendGuideQuestTakePhaseReward(self:getCurPhaseId(), function(ret)
    self:onReceivedLeftAll(ret)
  end)
end
function UIQuestNewbiePanel:onReceivedLeftAll(ret)
  if ret ~= ErrorCodeSuc then
    return
  end
  UICommonReceivePanel.OpenWithCheckPopupDownLeftTips()
end
function UIQuestNewbiePanel:onSlotReceived(guideQuestData, index)
  UIManager.OpenUIByParam(UIDef.UICommonReceivePanel)
end
function UIQuestNewbiePanel:onPhaseChanged(msg)
  self.isPhaseChanged = true
end
