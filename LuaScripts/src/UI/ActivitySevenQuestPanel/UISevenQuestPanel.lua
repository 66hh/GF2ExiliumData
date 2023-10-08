require("UI.UIBasePanel")
require("UI.Common.UICommonItem")
require("UI.ActivitySevenQuestPanel.Item.UISevenQuestTabItem")
require("UI.ActivitySevenQuestPanel.Item.UIActivitySevenQuestTaskItem")
UISevenQuestPanel = class("UISevenQuestPanel", UIBasePanel)
UISevenQuestPanel.__index = UISevenQuestPanel
function UISevenQuestPanel:ctor(csPanel)
  self.super:ctor(csPanel)
  csPanel.Type = UIBasePanelType.Panel
end
function UISevenQuestPanel:OnInit(root, data)
  self.super.SetRoot(UISevenQuestPanel, root)
  self.ui = {}
  self.closeTime = data.closeTime
  self:LuaUIBindTable(root, self.ui)
  self:RegisterEvent()
  self:InitTopTab()
  function self.onQuestReceived()
    NetCmdActivitySevenQuestData:DirtyRedPoint()
    UIManager.OpenUI(UIDef.UICommonReceivePanel)
  end
  function self.onPhaseQuestReceived()
    NetCmdActivitySevenQuestData:DirtyRedPoint()
    UIManager.OpenUI(UIDef.UICommonReceivePanel)
  end
  function self.onSevenQuestReset()
    UIUtils.PopupPositiveHintMessage(260010)
    self.CloseSelf()
  end
  MessageSys:AddListener(CS.GF2.Message.UIEvent.OnSevenQuestReset, self.onSevenQuestReset)
  MessageSys:AddListener(CS.GF2.Message.QuestEvent.OnPhaseQuestReceived, self.onPhaseQuestReceived)
  MessageSys:AddListener(CS.GF2.Message.QuestEvent.OnQuestReceived, self.onQuestReceived)
end
function UISevenQuestPanel:OnTop()
  self:UpdateProgress()
end
function UISevenQuestPanel:OnBackFrom()
  self:UpdateTask()
end
function UISevenQuestPanel:InitTopTab()
  if self.topTabTable ~= nil then
    self:ReleaseCtrlTable(self.topTabTable)
  end
  self.topTabTable = {}
  self.ui.mText_Time:StartCountdown(self.closeTime)
  self.ui.mText_Time:AddFinishCallback(function(suc)
    UIUtils.PopupPositiveHintMessage(260007)
    self.CloseSelf()
  end)
  self.currDay = NetCmdActivitySevenQuestData:GetActivityNewbee().CurrDay
  for i = 1, 7 do
    local tabItem = UISevenQuestTabItem.New()
    self.topTabTable[i] = tabItem
    local dayData = TableData.listEventSevendayGroupDatas:GetDataById(i)
    local data = {
      index = i,
      name = dayData.name
    }
    tabItem:InitCtrl(self.ui.mTrans_GrpTabBtn.gameObject, data)
    tabItem:SetLockVisible(i > self.currDay)
    tabItem:SetRedPointVisible(NetCmdActivitySevenQuestData:IsDayXCanReceive(i))
    tabItem:AddClickListener(function()
      if self.currDay < i then
        local nowTime = CS.CGameTime.ConvertLongToDateTime(CGameTime:GetTimestamp())
        if nowTime.Hour >= 5 then
          nowTime = CS.CGameTime.ConvertLongToDateTime(CGameTime:GetTimestamp() + 86400 * (i - self.currDay))
        else
          nowTime = CS.CGameTime.ConvertLongToDateTime(CGameTime:GetTimestamp() + 86400 * (i - self.currDay - 1))
        end
        CS.PopupMessageManager.PopupString(string_format(TableData.GetHintById(260021), nowTime.Month, nowTime.Day))
        return
      end
      if self.selectedItem then
        self.selectedItem:SetBtnInteractable(true)
      end
      tabItem:SetBtnInteractable(false)
      self.selectedItem = tabItem
      self:UpdateTask()
    end)
  end
  self.topTabTable[math.min(7, self.currDay)]:SetBtnInteractable(false)
  self.selectedItem = self.topTabTable[math.min(7, self.currDay)]
  self:UpdateTask()
end
function UISevenQuestPanel:UpdateTask()
  if self.taskTable ~= nil then
    self:ReleaseCtrlTable(self.taskTable)
  end
  self.taskTable = {}
  local taskIdTab = {}
  local dayData = TableData.listEventSevendayGroupDatas:GetDataById(self.selectedItem.index)
  for i = 0, dayData.theme_quests.Count - 1 do
    local taskId = dayData.theme_quests[i]
    table.insert(taskIdTab, taskId)
  end
  table.sort(taskIdTab, function(a, b)
    local stateA = NetCmdActivitySevenQuestData:GetTaskState(a)
    local stateB = NetCmdActivitySevenQuestData:GetTaskState(b)
    if stateA == stateB then
      return a < b
    else
      return stateB == 2 or stateA == 1
    end
  end)
  for _, taskId in pairs(taskIdTab) do
    local taskData = TableData.listEventSevendayTasklistDatas:GetDataById(taskId)
    local item = UIActivitySevenQuestTaskItem.New()
    table.insert(self.taskTable, item)
    item:InitCtrl(self.ui.mTrans_TaskContent.gameObject, {
      taskData = taskData,
      day = self.selectedItem.index
    })
  end
  self.ui.mTrans_TaskContent.enabled = false
  self.ui.mTrans_TaskContent.enabled = true
  self:UpdateProgress()
end
function UISevenQuestPanel:InitSteps()
  local steps = TableData.listEventSevendayStepDatas:GetList()
  if self.stepItems ~= nil then
    for _, item in pairs(self.stepItems) do
      gfdestroy(item:GetRoot())
    end
  end
  self.stepItems = {}
  if self.stepRewards ~= nil then
    for _, item in pairs(self.stepRewards) do
      gfdestroy(item)
    end
  end
  self.stepRewards = {}
  for i = 0, steps.Count - 1 do
    self:InitStepReward(steps[i], steps.Count)
  end
end
function UISevenQuestPanel:InitStepReward(data, totalStep)
  local instObj = instantiate(self.ui.mRewardItem.gameObject, self.ui.mTrans_StepRewards)
  table.insert(self.stepRewards, instObj)
  setactive(instObj, true)
  local textNum = instObj.transform:Find("GrpText/Text_Num"):GetComponent(typeof(CS.UnityEngine.UI.Text))
  textNum.text = data.step_num
  local itemContent = instObj.transform:Find("GrpItem")
  local item = UICommonItem.New()
  item:InitCtrl(itemContent)
  local itemId, itemNum
  for k, v in pairs(data.reward) do
    itemId = k
    itemNum = v
    item:SetItemData(k, v)
  end
  local startPosX = -200
  local fullX = 593.0
  instObj.transform.localPosition = Vector3(startPosX + fullX * ((data.id - 1) / (totalStep - 1)), instObj.transform.localPosition.y, 0)
  item:SetRedPoint(false)
  item:SetReceivedIcon(false)
  if self.completeNum >= data.step_num then
    if not NetCmdActivitySevenQuestData:CheckPhaseIsReceived(data.id) then
      item:SetItemData(itemId, itemNum, nil, nil, nil, nil, nil, function()
        NetCmdActivitySevenQuestData:SendGetSevenQuestPhaseReward(data.id)
      end)
      item:SetRedPoint(true)
    else
      item:SetReceivedIcon(true)
    end
  end
end
function UISevenQuestPanel:UpdateProgress()
  for i = 1, 7 do
    if i <= self.currDay then
      self.topTabTable[i]:SetRedPointVisible(NetCmdActivitySevenQuestData:IsDayXCanReceive(i))
      self.topTabTable[i]:SetCheckVisible(NetCmdActivitySevenQuestData:IsDayXChecked(i))
    end
  end
  for _, item in pairs(self.taskTable) do
    item:UpdateTaskState()
  end
  self.totalNum = 0
  self.completeNum = NetCmdActivitySevenQuestData:GetCompleteTaskCount()
  for i = 1, 7 do
    local dayData = TableData.listEventSevendayGroupDatas:GetDataById(i)
    self.totalNum = self.totalNum + dayData.theme_quests.Count
  end
  self.ui.mText_Progress.text = self.completeNum .. "/" .. self.totalNum
  local steps = TableData.listEventSevendayStepDatas:GetList()
  local lastStep = 0
  local fillValues = {}
  fillValues[0] = 0
  fillValues[1] = 0.2455470737913486
  local gap = (1 - fillValues[1]) / 5
  for i = 2, 6 do
    fillValues[i] = fillValues[1] + (i - 1) * gap
  end
  for i = 0, steps.Count - 1 do
    if self.completeNum <= steps[i].step_num then
      self.ui.mImage_ProgressBar.fillAmount = fillValues[i] + (self.completeNum - lastStep) / (steps[i].step_num - lastStep) * (fillValues[i + 1] - fillValues[i])
      self:InitSteps()
      return
    else
      lastStep = steps[i].step_num
    end
  end
end
function UISevenQuestPanel.CloseSelf()
  UIManager.CloseUI(UIDef.UISevenQuestPanel)
end
function UISevenQuestPanel:RegisterEvent()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self.CloseSelf()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Preview.gameObject).onClick = function()
    local list = new_array(typeof(CS.System.Int32), 3)
    list[0] = 1008
    list[1] = FacilityBarrackGlobal.ShowContentType.UIClothesPreview
    list[2] = 1100801
    local jumpParam = CS.BarrackPresetJumpParam(1, 1008, 1100801, list)
    JumpSystem:Jump(EnumSceneType.Barrack, jumpParam)
  end
end
function UISevenQuestPanel:OnClose()
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.OnSevenQuestReset, self.onSevenQuestReset)
  MessageSys:RemoveListener(CS.GF2.Message.QuestEvent.OnQuestReceived, self.onQuestReceived)
  MessageSys:RemoveListener(CS.GF2.Message.QuestEvent.OnPhaseQuestReceived, self.onPhaseQuestReceived)
  self:ReleaseCtrlTable(self.topTabTable)
  self.topTabTable = nil
  self:ReleaseCtrlTable(self.taskTable)
  self.taskTable = nil
  if self.stepItems ~= nil then
    for _, item in pairs(self.stepItems) do
      gfdestroy(item:GetRoot())
    end
  end
  self.stepItems = nil
  if self.stepRewards ~= nil then
    for _, item in pairs(self.stepRewards) do
      gfdestroy(item)
    end
  end
  self.stepRewards = nil
end
