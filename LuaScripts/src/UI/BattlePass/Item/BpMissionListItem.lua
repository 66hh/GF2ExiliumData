require("UI.MessageBox.MessageBoxPanel")
BpMissionListItem = class("BpMissionListItem", UIBaseCtrl)
function BpMissionListItem:ctor(go)
  self.ui = UIUtils.GetUIBindTable(go.transform)
  self:SetRoot(go.transform)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnGoto.gameObject, function()
    local excute = self:CompareIsNextDay(self.refreshTime)
    if excute then
      return
    end
    self:onClickGoto()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Receive.gameObject, function()
    local excute = self:CompareIsNextDay(self.refreshTime)
    if excute then
      return
    end
    self:onClickReceive()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Add.gameObject, function()
    local excute = self:CompareIsNextDay(self.refreshTime)
    if excute then
      return
    end
    self:onClickAdd()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_LookOver.gameObject, function()
    local outTime = self:CheckIsOutTime()
    if outTime then
      return
    end
    local excute = self:CompareIsNextDay(self.refreshTime)
    if excute then
      return
    end
    self:onClickLookOver()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Refresh.gameObject, function()
    local outTime = self:CheckIsOutTime()
    if outTime then
      return
    end
    local excute = self:CompareIsNextDay(self.refreshTime)
    if excute then
      return
    end
    self:onClickRefresh()
  end)
  function self.refreshTimeFun(sender)
    self.refreshTime = sender.Sender
  end
  MessageSys:AddListener(UIEvent.BPRefreshTime, self.refreshTimeFun)
  self.refreshTime = nil
  self.bpTaskPackData = nil
  self.index = nil
  self.onReceiveCallback = nil
  self.itemTable = {}
  self.maxnum = 0
  self.nowCostAddExtra = 0
  self.stcData = {}
  self.needNum = {}
  self.costItemNum = 0
end
function BpMissionListItem:SetData(bpTaskPackData, index, onReceiveCallback, addTaskDialogConfirm, refreshTime)
  self.bpTaskPackData = bpTaskPackData
  self.index = index
  self.onReceiveCallback = onReceiveCallback
  self.addTaskDialogConfirm = addTaskDialogConfirm
  self.refreshTime = refreshTime
  self:Refresh()
end
function BpMissionListItem:Release()
  self:ReleaseCtrlTable(self.itemTable)
  MessageSys:RemoveListener(UIEvent.BPRefreshTime, self.refreshTimeFun)
  self.bpTaskPackData = nil
  self.refreshTime = nil
  self.index = nil
  self.onReceiveCallback = nil
  self.ui = nil
end
function BpMissionListItem:CompareIsNextDay(refreshTime)
  local nowTime = CS.CGameTime.ConvertLongToDateTime(CGameTime:GetTimestamp())
  if refreshTime < nowTime then
    MessageBox.ShowMidBtn(TableData.GetHintById(208), TableData.GetHintById(192099), nil, nil, function()
      UIManager.JumpToMainPanel()
    end)
    NetCmdBattlePassData:ClearPlayerPrefs()
    return true
  end
  return false
end
function BpMissionListItem:CheckIsOutTime()
  if self.bpTaskPackData.isAcceptedTaskInfo then
    local endTime = CS.CGameTime.ConvertLongToDateTime(self.bpTaskPackData.bpAcceptedTaskInfo.AcceptTask.EndTime)
    local nowTime = CS.CGameTime.ConvertLongToDateTime(CGameTime:GetTimestamp())
    if self.bpTaskPackData.isComplete then
      return false
    end
    if endTime < nowTime then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(192049))
      NetCmdBattlePassData:RemoveOutTimeTask(self.bpTaskPackData)
      MessageSys:SendMessage(UIEvent.BPRefreshShareOutTime, nil)
      return true
    end
  end
  return false
end
function BpMissionListItem:OnCommanderCenter()
  UIManager.JumpToMainPanel()
end
function BpMissionListItem:Refresh()
  local showName = ""
  if self.bpTaskPackData.type.value__ == UIBattlePassGlobal.BpTaskTypeShow.Daily or self.bpTaskPackData.type.value__ == UIBattlePassGlobal.BpTaskTypeShow.TaskNew then
    showName = TableData.GetHintById(192073)
  elseif self.bpTaskPackData.type.value__ == UIBattlePassGlobal.BpTaskTypeShow.Weekly then
    showName = TableData.GetHintById(192074)
  elseif self.bpTaskPackData.type.value__ == UIBattlePassGlobal.BpTaskTypeShow.TaskCooperation then
    showName = TableData.GetHintById(192075)
  end
  if showName then
    self.ui.mText_Tittle.text = showName .. self.bpTaskPackData.name
  else
    self.ui.mText_Tittle.text = self.bpTaskPackData.name
  end
  if self.bpTaskPackData.conditionNum ~= 0 then
    self.ui.mText_Progress.text = self.bpTaskPackData:GetRatioStr()
    setactive(self.ui.mText_Progress.gameObject, true)
    setactive(self.ui.mTrans_Assist.gameObject, false)
  else
    setactive(self.ui.mText_Progress.gameObject, false)
    setactive(self.ui.mTrans_Assist.gameObject, true)
  end
  self.ui.mImg_Progress.fillAmount = self.bpTaskPackData:GetProgressPercent()
  setactive(self.ui.mText_TaskDes, true)
  setactive(self.ui.mTrans_Consume, false)
  self.ui.mText_TaskDes.text = self.bpTaskPackData.description
  if 0 < #self.itemTable then
    self:ReleaseCtrlTable(self.itemTable, true)
  end
  self.itemTable = {}
  if self.bpTaskPackData.Reward ~= nil then
    for itemId, num in pairs(self.bpTaskPackData.Reward) do
      local item = UICommonItem.New()
      item:InitCtrl(self.ui.mScrollChild_AwardItem.transform)
      item:SetItemData(itemId, num)
      item.mUIRoot:SetAsLastSibling()
      if self.bpTaskPackData.isReleasedTask then
        if self.bpTaskPackData.bpReleasedTask.State == 0 or self.bpTaskPackData.bpReleasedTask.State == nil then
          setactive(item.ui.mTrans_ReceivedIcon, false)
        elseif self.bpTaskPackData.bpReleasedTask.State == 2 then
          setactive(item.ui.mTrans_ReceivedIcon, true)
        elseif self.bpTaskPackData.bpReleasedTask.State == 1 then
          setactive(item.ui.mTrans_ReceivedIcon, false)
        end
      elseif self.bpTaskPackData.isAcceptedTaskInfo then
        if not self.bpTaskPackData.isComplete then
          setactive(item.ui.mTrans_ReceivedIcon, false)
        elseif self.bpTaskPackData.isReceived then
          setactive(item.ui.mTrans_ReceivedIcon, true)
        elseif self.bpTaskPackData.isComplete and not self.bpTaskPackData.isReceived then
          setactive(item.ui.mTrans_ReceivedIcon, false)
        end
      elseif self.bpTaskPackData.isCooperationTask then
        setactive(item.ui.mTrans_ReceivedIcon, false)
      elseif self.bpTaskPackData.isReceived then
        setactive(item.ui.mTrans_ReceivedIcon, true)
      else
        setactive(item.ui.mTrans_ReceivedIcon, false)
      end
      local stcData = TableData.GetItemData(itemId)
      TipsManager.Add(item.mUIRoot, stcData)
      table.insert(self.itemTable, item)
    end
  end
  setactive(self.ui.mTrans_Finished, false)
  setactive(self.ui.mTrans_Released, false)
  setactive(self.ui.mBtn_BtnGoto, false)
  setactive(self.ui.mBtn_Receive, false)
  setactive(self.ui.mBtn_Add, false)
  setactive(self.ui.mBtn_LookOver, false)
  setactive(self.ui.mTrans_Refresh, false)
  setactive(self.ui.mTrans_LookOverRedPoint0, false)
  setactive(self.ui.mBtn_BtnGoto.transform.parent, false)
  setactive(self.ui.mBtn_Receive.transform.parent, false)
  setactive(self.ui.mBtn_Add.transform.parent, false)
  setactive(self.ui.mBtn_LookOver.transform.parent, false)
  if self.bpTaskPackData.isNullstc then
    self:onAddStd()
    return
  end
  if self.bpTaskPackData.isReleasedTask then
    setactive(self.ui.mTrans_Released, true)
    if self.bpTaskPackData.bpReleasedTask.State == 0 or self.bpTaskPackData.bpReleasedTask.State == nil then
      setactive(self.ui.mBtn_LookOver, true)
      setactive(self.ui.mBtn_LookOver.transform.parent, true)
    elseif self.bpTaskPackData.bpReleasedTask.State == 2 then
      setactive(self.ui.mBtn_LookOver, true)
      setactive(self.ui.mBtn_LookOver.transform.parent, true)
    elseif self.bpTaskPackData.bpReleasedTask.State == 1 then
      setactive(self.ui.mBtn_Receive, true)
      setactive(self.ui.mBtn_Receive.transform.parent, true)
    end
    return
  elseif self.bpTaskPackData.isAcceptedTaskInfo then
    if self.bpTaskPackData.isNewAddAllTypeFlag then
      self.bpTaskPackData.isNewAddAllTypeFlag = false
      self.ui.mAnimator_Refresh:SetTrigger("New_Refresh")
      NetCmdBattlePassData.newAllTypeList:Remove(self.bpTaskPackData.bpAcceptedTaskInfo.AcceptTask.TaskId)
    end
    if self.bpTaskPackData.isNewAddFlag then
      setactive(self.ui.mTrans_LookOverRedPoint0, true)
    end
    if not self.bpTaskPackData.isComplete then
      setactive(self.ui.mBtn_LookOver, true)
      setactive(self.ui.mBtn_LookOver.transform.parent, true)
    elseif self.bpTaskPackData.isReceived then
      setactive(self.ui.mBtn_LookOver, true)
      setactive(self.ui.mBtn_LookOver.transform.parent, true)
    elseif self.bpTaskPackData.isComplete and not self.bpTaskPackData.isReceived then
      setactive(self.ui.mBtn_Receive, true)
      setactive(self.ui.mBtn_Receive.transform.parent, true)
    end
    return
  end
  if self.bpTaskPackData.isNewAddAllTypeFlag then
    self.bpTaskPackData.isNewAddAllTypeFlag = false
    self.ui.mAnimator_Refresh:SetTrigger("New_Refresh")
    NetCmdBattlePassData.newAllTypeList:Remove(self.bpTaskPackData.Id)
  end
  if self.bpTaskPackData.isReceived then
    if self.bpTaskPackData.isCooperationTask then
      setactive(self.ui.mTrans_Released, true)
      setactive(self.ui.mBtn_LookOver, true)
      setactive(self.ui.mBtn_LookOver.transform.parent, true)
    else
      setactive(self.ui.mTrans_Finished, true)
    end
  else
    if self.bpTaskPackData.isComplete then
      if self.bpTaskPackData.isCooperationTask then
        setactive(self.ui.mTrans_Released, true)
        setactive(self.ui.mBtn_Receive, false)
        setactive(self.ui.mBtn_Receive.transform.parent, false)
        setactive(self.ui.mBtn_LookOver, true)
        setactive(self.ui.mBtn_LookOver.transform.parent, true)
      else
        setactive(self.ui.mBtn_Receive, true)
        setactive(self.ui.mBtn_Receive.transform.parent, true)
      end
    elseif self.bpTaskPackData.isCooperationTask then
      setactive(self.ui.mTrans_Released, true)
      setactive(self.ui.mTrans_Refresh, false)
      setactive(self.ui.mBtn_LookOver, true)
      setactive(self.ui.mBtn_LookOver.transform.parent, true)
    elseif self.bpTaskPackData.link == "" then
      setactive(self.ui.mTrans_Refresh, true)
    else
      setactive(self.ui.mTrans_Refresh, true)
      setactive(self.ui.mBtn_BtnGoto, true)
      setactive(self.ui.mBtn_BtnGoto.transform.parent, true)
    end
    if self.bpTaskPackData.isNewAddFlag then
      setactive(self.ui.mTrans_LookOverRedPoint0, true)
    end
  end
end
function BpMissionListItem:PlayUnlockFx()
  TimerSys:DelayFrameCall(10, function()
    self.ui.mAnimator:SetTrigger("Fx")
  end)
end
function BpMissionListItem:onClickGoto()
  TimerSys:DelayCall(0.2, function()
    UIManager.EnableBattlePass(false)
  end)
  SceneSwitch:SwitchByID(tonumber(self.bpTaskPackData.link))
end
function BpMissionListItem:onClickReceive()
  self.bpTaskPackData.isNewAddFlag = false
  local cacheKey = AccountNetCmdHandler:GetUID() .. NetCmdBattlePassData.BpTaskStr .. tostring(self.bpTaskPackData.Id)
  if PlayerPrefs.HasKey(cacheKey) then
    setactive(self.ui.mTrans_LookOverRedPoint0, false)
    PlayerPrefs.DeleteKey(cacheKey)
    MessageSys:SendMessage(UIEvent.BpOnLookClick, NetCmdBattlePassData:GetTaskIndex(self.bpTaskPackData))
  end
  local taskid
  if self.bpTaskPackData.isReleasedTask then
    taskid = self.bpTaskPackData.bpReleasedTask.TaskId
    NetCmdBattlePassData:SendBattlepassGetShareTaskReward(taskid, function(ret)
      self:onReceivedCallback(ret)
    end)
  elseif self.bpTaskPackData.isAcceptedTaskInfo then
    taskid = self.bpTaskPackData.bpAcceptedTaskInfo.UniqueId
    NetCmdBattlePassData:SendCS_BattlepassGetUniqueQuestReward(taskid, function(ret)
      self:onReceivedCallback(ret)
    end)
  else
    NetCmdBattlePassData:Sendtake_quest_rewardCmd(self.bpTaskPackData.commonType, {
      self.bpTaskPackData.Id
    }, function(ret)
      self:onReceivedCallback(ret)
    end)
  end
  for itemId, num in pairs(self.bpTaskPackData.Reward) do
    if itemId < 601 or 612 < itemId then
      UIManager.OpenUIByParam(UIDef.UICommonReceivePanel)
      break
    end
  end
end
function BpMissionListItem:onAddStd()
  local maxnum = 0
  local nowCostAddExtra = 0
  local stcData = {}
  local needNum = {}
  local costItemNum = 0
  local ipairTable = {}
  setactive(self.ui.mTrans_Consume, true)
  setactive(self.ui.mText_TaskDes, false)
  if self.bpTaskPackData.isAddShareSlotui then
    maxnum = TableData.GlobalSystemData.BattlepassTaskShareToplimit1
    nowCostAddExtra = NetCmdBattlePassData.CostShareCount
    ipairTable = TableData.GlobalSystemData.BattlepassTaskShareItem
    setactive(self.ui.mImg_AssistIcon, true)
    setactive(self.ui.mImg_NewIcon, false)
  end
  if self.bpTaskPackData.isAddSlotui then
    maxnum = TableData.GlobalSystemData.BattlepassTaskExtraToplimit
    nowCostAddExtra = NetCmdBattlePassData.CostExtraCount
    ipairTable = TableData.GlobalSystemData.BattlepassTaskExtraItem
    setactive(self.ui.mImg_AssistIcon, false)
    setactive(self.ui.mImg_NewIcon, true)
  end
  for itemId, num in pairs(ipairTable) do
    stcData = TableData.GetItemData(itemId)
    needNum = num
    costItemNum = NetCmdItemData:GetItemCountById(itemId)
    self.ui.mImg_Item.sprite = IconUtils.GetItemIconSprite(itemId)
  end
  self.ui.mText_Cost.text = string_format(TableData.GetHintById(192045), costItemNum, needNum)
  self.ui.mText_CostStc.text = TableData.GetHintById(192067)
  self.maxnum = maxnum
  self.needNum = needNum
  self.costItemNum = costItemNum
  self.nowCostAddExtra = nowCostAddExtra
  self.stcData = stcData
  setactive(self.ui.mBtn_Add, true)
  setactive(self.ui.mBtn_Add.transform.parent, true)
end
function BpMissionListItem:onClickAdd()
  if self.bpTaskPackData.isAddShareSlotui and self.nowCostAddExtra < self.maxnum then
    if self.costItemNum >= self.needNum then
      UIManager.OpenUIByParam(UIDef.UIBattlePassMissionTransDialogV3, {
        type = UIBattlePassGlobal.BpTaskDialogType.AddShare,
        maxnum = self.maxnum,
        hasNum = self.maxnum - self.nowCostAddExtra,
        addTaskDialogConfirm = self.addTaskDialogConfirm
      })
    else
      MessageBoxPanel.ShowItemNotEnoughMessage(self.stcData.Id, function()
        SceneSwitch:SwitchByID(5002)
      end, nil, 192085)
    end
  else
  end
  if self.bpTaskPackData.isAddSlotui and self.nowCostAddExtra < self.maxnum then
    if self.costItemNum >= self.needNum then
      UIManager.OpenUIByParam(UIDef.UIBattlePassMissionTransDialogV3, {
        type = UIBattlePassGlobal.BpTaskDialogType.AddDaily,
        maxnum = self.maxnum,
        hasNum = self.maxnum - self.nowCostAddExtra,
        addTaskDialogConfirm = self.addTaskDialogConfirm
      })
    else
      MessageBoxPanel.ShowItemNotEnoughMessage(self.stcData.Id, function()
        SceneSwitch:SwitchByID(5002)
      end, nil, 192085)
    end
  else
  end
end
function BpMissionListItem:onClickRefresh()
  local maxnum = 0
  local freeMaxNum = 0
  local nowRefreshCnt = 0
  local nowCostExtra = 0
  local refreshType = UIBattlePassGlobal.BpTaskDialogType.RefreshWeek
  local textRefresh = ""
  if self.bpTaskPackData.isWeekTask then
    freeMaxNum = TableData.GlobalSystemData.BattlepassTaskWeeklyRefreshFrequency
    maxnum = TableData.GlobalSystemData.BattlepassTaskWeeklyToplimit
    refreshType = UIBattlePassGlobal.BpTaskDialogType.RefreshWeek
    nowCostExtra = NetCmdBattlePassData.CostWeekRefreshCount
    nowRefreshCnt = freeMaxNum - nowCostExtra
    textRefresh = string_format(TableData.GetHintById(192042), nowRefreshCnt)
  else
    freeMaxNum = TableData.GlobalSystemData.BattlepassTaskDailyRefreshFrequency
    maxnum = TableData.GlobalSystemData.BattlepassTaskDailyToplimit
    refreshType = UIBattlePassGlobal.BpTaskDialogType.RefreshDaily
    nowCostExtra = NetCmdBattlePassData.CostDailyRefreshCount
    nowRefreshCnt = freeMaxNum - nowCostExtra
    textRefresh = string_format(TableData.GetHintById(192041), nowRefreshCnt)
  end
  if 0 < nowRefreshCnt then
    MessageBox.Show(TableData.GetHintById(192025), textRefresh, nil, function()
      NetCmdBattlePassData:SendCS_BattlepassRefreshTask(self.bpTaskPackData)
    end, nil)
  else
    UIManager.OpenUIByParam(UIDef.UIBattlePassMissionTransDialogV3, {
      type = refreshType,
      maxnum = self.maxnum,
      hasNum = self.maxnum - self.nowCostAddExtra,
      packData = self.bpTaskPackData,
      CompareIsNextDay = self.CompareIsNextDay,
      refreshTime = self.refreshTime
    })
  end
end
function BpMissionListItem:onClickLookOver()
  self.bpTaskPackData.isNewAddFlag = false
  local cacheKey = AccountNetCmdHandler:GetUID() .. NetCmdBattlePassData.BpTaskStr .. tostring(self.bpTaskPackData.Id)
  if PlayerPrefs.HasKey(cacheKey) then
    setactive(self.ui.mTrans_LookOverRedPoint0, false)
    PlayerPrefs.DeleteKey(cacheKey)
    MessageSys:SendMessage(UIEvent.BpOnLookClick, nil)
  end
  if self.bpTaskPackData.bpReleasedTask == nil and self.bpTaskPackData.bpAcceptedTaskInfo == nil then
    UIManager.OpenUIByParam(UIDef.UICollaborationTaskDetailPanel, self.bpTaskPackData)
  else
    NetCmdBattlePassData:SendBattlepassTaskDetail(self.bpTaskPackData.TaskId, function(ret)
      if ret == ErrorCodeSuc then
        UIManager.OpenUIByParam(UIDef.UICollaborationTaskDetailPanel, self.bpTaskPackData)
      end
    end)
  end
end
function BpMissionListItem:onReceivedCallback(ret)
  if ret ~= ErrorCodeSuc then
    return
  end
  self:Refresh()
  if self.onReceiveCallback then
    self.onReceiveCallback(self.bpTaskPackData, self.index)
  end
end
function BpMissionListItem:onBpDetailTask(msg)
  local taskId = msg.Sender
end
