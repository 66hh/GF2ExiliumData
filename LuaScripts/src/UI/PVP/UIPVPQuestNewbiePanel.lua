require("UI.PVP.Item.UIPVPQuestNewbieSlot")
require("UI.PVP.Item.UIPVPQuestDotItem")
require("UI.QuestPanel.UIQuestSubPanelBase")
require("UI.Common.UICommonItem")
UIPVPQuestNewbiePanel = class("UIPVPQuestNewbiePanel", UIQuestSubPanelBase)
UIPVPQuestNewbiePanel.InOutCirc = CS.DG.Tweening.Ease.InOutCirc
function UIPVPQuestNewbiePanel:ctor(go, parentPanel)
  self.ui = UIUtils.GetUIBindTable(go)
  self:SetRoot(go.transform)
  function self.ui.mVirtualListEx.itemRenderer(...)
    self:itemRenderer(...)
  end
  function self.ui.mVirtualListEx.itemProvider()
    return self:itemProvider()
  end
  self.receiveRedPoint = instantiate(self.ui.mScrollItem_RedPoint.childItem, self.ui.mScrollItem_RedPoint.transform)
  UIUtils.AddBtnClickListener(self.ui.mContainer_ReceiveAll, function()
    self:onClickReceiveAll()
  end)
  function self.onPhaseChangedCallback(msg)
    self:onPhaseChanged(msg)
  end
  MessageSys:AddListener(UIEvent.OnPVPNewbieQuestPhaseChanged, self.onPhaseChangedCallback)
  self.IsFirstOpen = true
  self.popString = nil
  self.parentPanel = parentPanel
  self.curPhaseSlotDataList = nil
  self.previewRewardItemTable = self:initProgressRewardPreview()
  self.isPhaseChanged = false
  self.dotList = {}
end
function UIPVPQuestNewbiePanel:Show()
  self.super.Show(self)
  local isAllPhaseComplete = NetCmdPVPQuestData:CheckNewbiePhaseIsReceived(self:getMaxPhaseId())
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
function UIPVPQuestNewbiePanel:OnPanelBack()
  if self.isPhaseChanged then
    self.isPhaseChanged = false
    self.parentPanel.ui.mAnimator:SetTrigger("GrpNoviceTask_1_Refresh")
  end
  self:Refresh()
end
function UIPVPQuestNewbiePanel:OnDialogBack()
  if self.isPhaseChanged then
    self.isPhaseChanged = false
    self.parentPanel.ui.mAnimator:SetTrigger("GrpNoviceTask_1_Refresh")
  end
  self:Refresh()
end
function UIPVPQuestNewbiePanel:Hide()
  self.super.Hide(self)
end
function UIPVPQuestNewbiePanel:Release()
  MessageSys:RemoveListener(UIEvent.OnNewbieQuestPhaseChanged, self.onPhaseChangedCallback)
  if self.progressTween then
    LuaDOTweenUtils.Kill(self.progressTween, false)
    self.progressTween = nil
  end
  self:ReleaseCtrlTable(self.dotList, true)
  self.dotList = nil
  self:ReleaseCtrlTable(self.previewRewardItemTable, true)
  if self.receiveRedPoint then
    gfdestroy(self.receiveRedPoint)
  end
  self.receiveRedPoint = nil
  self.curPhaseSlotDataList = nil
  self.isOpenShow = nil
  self.ui = nil
  self.parentPanel = nil
  self.isPhaseChanged = nil
end
function UIPVPQuestNewbiePanel:Refresh()
  self.parentPanel:Refresh()
  self:refreshAllSlot()
  self:refreshLeftPanel()
end
function UIPVPQuestNewbiePanel:GetTaskTypeId()
  return 1
end
function UIPVPQuestNewbiePanel:GetAnimPageSwitchInt()
  return 1
end
function UIPVPQuestNewbiePanel:initProgressRewardPreview()
  local tempTable = {}
  local template = self.ui.mScrollItem_RewardItem.childItem
  local guideQuestPhaseData = TableData.listNrtpvpTaskGuideDatas:GetDataById(self:getCurPhaseId())
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
function UIPVPQuestNewbiePanel:itemProvider()
  local template = self.ui.mScrollItem_NoviceItem.childItem
  local slot = UIPVPQuestNewbieSlot.New(instantiate(template, self.ui.mScrollItem_NoviceItem.transform))
  local renderDataItem = RenderDataItem()
  renderDataItem.renderItem = slot:GetRoot().gameObject
  renderDataItem.data = slot
  return renderDataItem
end
function UIPVPQuestNewbiePanel:itemRenderer(index, renderData)
  if self.curPhaseSlotDataList then
    local slotData = self.curPhaseSlotDataList[index]
    local slot = renderData.data
    slot:SetData(slotData, index + 1, function()
      self:onSlotReceived()
    end)
  end
end
function UIPVPQuestNewbiePanel:refreshAllSlot()
  self.curPhaseSlotDataList = self:getCurPhaseSlotDataList()
  if not self.curPhaseSlotDataList or self.curPhaseSlotDataList.Count == 0 then
    return
  end
  self.ui.mVirtualListEx.numItems = self.curPhaseSlotDataList.Count
  self.ui.mVirtualListEx:Refresh()
end
function UIPVPQuestNewbiePanel:refreshLeftPanel()
  self:refreshProgress()
  self:refreshLeftReceiveBtn()
end
function UIPVPQuestNewbiePanel:refreshProgress()
  local completedPhaseNum = self:getCompletedPhaseNum()
  local curPhaseNum = self:getCurPhaseId()
  local totalPhaseNum = self:getMaxPhaseId()
  self.ui.mText_TotalProgress.text = TableData.GetHintById(112016, tostring(completedPhaseNum), tostring(totalPhaseNum))
  self.ui.mText_CurPhaseNum.text = tostring(curPhaseNum)
  local receivedCount = self:getCurPhaseReceivedSlotCount()
  local totalCount = self.curPhaseSlotDataList.Count
  if self.progressTween then
    LuaDOTweenUtils.Kill(self.progressTween, false)
  end
  if self.IsFirstOpen then
    self.ui.mSmoothMask_TotalProgressBar.fillAmount = receivedCount / totalCount
    self.IsFirstOpen = false
    if self.popString then
      TimerSys:DelayCall(0.25, function()
        CS.PopupMessageManager.PopupStateChangeString(self.popString)
      end)
    end
  else
    local getter = function(tempSelf)
      return tempSelf.ui.mImage_CurPhaseProgress.fillAmount
    end
    local setter = function(tempSelf, value)
      tempSelf.ui.mImage_CurPhaseProgress.fillAmount = value
    end
    self.progressTween = LuaDOTweenUtils.ToOfFloat(self, getter, setter, receivedCount / totalCount, 1, nil)
  end
  for i = 1, completedPhaseNum do
    local dotItem = self.dotList[i]
    if not dotItem then
      dotItem = UIPVPQuestDotItem.New()
      dotItem:InitCtrl(self.ui.mTrans_Dot, self.ui.mTrans_DotProgress)
      table.insert(self.dotList, dotItem)
    end
    dotItem:SetActivate(true)
  end
  for i = completedPhaseNum + 1, totalPhaseNum do
    local dotItem = self.dotList[i]
    if not dotItem then
      dotItem = UIPVPQuestDotItem.New()
      dotItem:InitCtrl(self.ui.mTrans_Dot, self.ui.mTrans_DotProgress)
      table.insert(self.dotList, dotItem)
    end
    dotItem:SetActivate(false)
  end
end
function UIPVPQuestNewbiePanel:refreshLeftReceiveBtn()
  setactive(self.ui.mTrans_NotReceive, false)
  setactive(self.ui.mTrans_Received, false)
  setactive(self.ui.mContainer_ReceiveAll, false)
  local receivedCount = self:getCurPhaseReceivedSlotCount()
  local totalCount = self.curPhaseSlotDataList.Count
  if receivedCount == totalCount then
    if NetCmdPVPQuestData:CheckNewbiePhaseIsReceived(self:getCurPhaseId()) then
      setactive(self.ui.mTrans_Received, true)
    else
      setactive(self.ui.mContainer_ReceiveAll, true)
      setactive(self.ui.mContainer_ReceiveAll.transform.parent, true)
      setactive(self.ui.mScrollItem_RedPoint.transform, true)
    end
  else
    setactive(self.ui.mTrans_NotReceive, true)
  end
end
function UIPVPQuestNewbiePanel:getCurPhaseSlotDataList()
  local phaseId = self:getCurPhaseId()
  return NetCmdPVPQuestData:GetGuideQuestListDatasByPhase(phaseId)
end
function UIPVPQuestNewbiePanel:getCurPhaseId()
  return NetCmdPVPQuestData:GetCurPhaseId()
end
function UIPVPQuestNewbiePanel:getCompletedPhaseNum()
  return NetCmdPVPQuestData:GetCompletedPhaseNum()
end
function UIPVPQuestNewbiePanel:getCurPhaseReceivedSlotCount()
  local receivedCount = 0
  for k, newbieQuestData in pairs(self.curPhaseSlotDataList) do
    if newbieQuestData.isReceived then
      receivedCount = receivedCount + 1
    end
  end
  return receivedCount
end
function UIPVPQuestNewbiePanel:getMaxPhaseId()
  local dataList = TableData.listNrtpvpTaskGuideDatas:GetList()
  return dataList[dataList.Count - 1].id
end
function UIPVPQuestNewbiePanel:onClickReceiveAll()
  local receivedCount = self:getCurPhaseReceivedSlotCount()
  local totalCount = self.curPhaseSlotDataList.Count
  local completedPhaseNum = self:getCompletedPhaseNum()
  local totalPhaseNum = self:getMaxPhaseId()
  if completedPhaseNum == totalPhaseNum - 1 then
    self.popString = TableData.GetHintById(120167)
  else
    self.popString = TableData.GetHintById(120166)
  end
  NetCmdPVPQuestData:SendGuideQuestTakePhaseReward(self:getCurPhaseId(), function(ret)
    self.IsFirstOpen = true
    self:onReceivedLeftAll(ret)
  end)
end
function UIPVPQuestNewbiePanel:onReceivedLeftAll(ret)
  if ret ~= ErrorCodeSuc then
    return
  end
  UICommonReceivePanel.OpenWithCheckPopupDownLeftTips()
end
function UIPVPQuestNewbiePanel:onSlotReceived(guideQuestData, index)
  UICommonReceivePanel.OpenWithCheckPopupDownLeftTips()
end
function UIPVPQuestNewbiePanel:onPhaseChanged(msg)
  self.isPhaseChanged = true
end
