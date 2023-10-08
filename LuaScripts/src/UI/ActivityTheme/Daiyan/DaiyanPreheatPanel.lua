require("UI.UIBasePanel")
DaiyanPreheatPanel = class("DaiyanPreheatPanel", UIBasePanel)
DaiyanPreheatPanel.__index = DaiyanPreheatPanel
function DaiyanPreheatPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
end
function DaiyanPreheatPanel:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.ThemeWarmUp = NetCmdThemeData:GetThemeRewardType()
  self:ManualUI()
  self:AddBtnListen()
end
function DaiyanPreheatPanel:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.DaiyanPreheatPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Video.gameObject).onClick = function()
    CS.AVGController.PlayAvgByPlotId(self.activityConfigData.prologue, function()
    end, true)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ScoreBtn.gameObject).onClick = function()
    if self.scoreState == 0 then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(80092))
      return
    end
    NetCmdCommonQuestData:ReqGetQuestReward(self.ThemeWarmUp, self.scoreId, function(ret)
      if ret == ErrorCodeSuc then
        self:UpdateScoreInfo()
      end
    end)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_QuestBtn.gameObject).onClick = function()
    if self.questState == 0 then
      UIManager.OpenUIByParam(UIDef.ActivityThemeQandADialog, {
        entraId = self.activityEntranceData.id,
        groupId = self.processModuleId
      })
    else
      NetCmdCommonQuestData:ReqGetQuestReward(self.ThemeWarmUp, self.questId, function(ret)
        if ret == ErrorCodeSuc then
          self:UpdateQuestInfo()
        end
      end)
    end
  end
end
function DaiyanPreheatPanel:ManualUI()
  self.rewardUIList = {}
  for i = 1, self.ui.mTrans_Item.childCount do
    local item = self.ui.mTrans_Item:GetChild(i - 1)
    local cell = {}
    cell.btn = item.gameObject
    cell.Text_Num = item.transform:Find("Text_Num"):GetComponent(typeof(CS.UnityEngine.UI.Text))
    cell.Trans_Finished = item.transform:Find("GrpState/Trans_Finished").gameObject
    cell.Trans_RedPoint = item.transform:Find("GrpState/Trans_RedPoint").gameObject
    cell.Trans_Lighted = item.transform:Find("GrpState/Trans_Lighted").gameObject
    cell.isFinish = false
    cell.isCanGet = false
    UIUtils.GetButtonListener(cell.btn).onClick = function()
      self:OnClickIndex(i)
    end
    table.insert(self.rewardUIList, cell)
  end
  self.ui.mText_ScoreState.text = TableData.GetHintById(120193)
end
function DaiyanPreheatPanel:OnClickIndex(index)
  local cell = self.rewardUIList[index]
  if cell.isFinish then
    if self.processModuleId then
      UIManager.OpenUIByParam(UIDef.ActivityThemeRewardPreviewDialog, {
        groupId = self.processModuleId
      })
    end
  elseif cell.isCanGet then
    local rewardIDList = NetCmdThemeData:GetRewardIdList(self.processModuleId)
    if index <= rewardIDList.Count then
      NetCmdThemeData:SendTakeWarmUpPhaseReward(self.activityEntranceData.id, {
        rewardIDList[index - 1]
      }, function(ret)
        if ret == ErrorCodeSuc then
          UIManager.OpenUI(UIDef.UICommonReceivePanel)
          self:UpdateProcess()
        end
      end)
    end
  elseif self.processModuleId then
    UIManager.OpenUIByParam(UIDef.ActivityThemeRewardPreviewDialog, {
      groupId = self.processModuleId
    })
  end
end
function DaiyanPreheatPanel:OnInit(root, data)
  if data == nil then
    NetCmdRecentActivityData:ReqPlanActivityData(PlanType.PlanFunctionActivityThematic, function(ret)
      if ret == ErrorCodeSuc then
        local planActivityId = NetCmdRecentActivityData:GetPlanActivityId(1)
        self.activityPlanData = TableData.listPlanDatas:GetDataById(planActivityId)
        self.activityEntranceData = TableData.listActivityEntranceDatas:GetDataById(self.activityPlanData.args[0])
        self.activityModuleData = TableData.listActivityModuleDatas:GetDataById(self.activityEntranceData.module_id)
        self.activityConfigData = NetCmdThemeData:GetActivityDataByEntranceId(self.activityEntranceData.id)
        NetCmdThemeData:SendThemeActivityInfo(self.activityEntranceData.id, function(ret)
          self:UpdateScoreProcess()
          self:UpdateInfo()
          self:UpdateScoreInfo()
          self:UpdateQuestInfo()
          self:UpdateProcess()
        end)
      end
    end)
  else
    self.activityEntranceData = data.activityEntranceData
    self.activityModuleData = data.activityModuleData
    self.activityConfigData = data.activityConfigData
    self.activityPlanData = TableData.listPlanDatas:GetDataById(self.activityEntranceData.plan_id)
    self:UpdateInfo()
    self:UpdateScoreInfo()
    self:UpdateQuestInfo()
    self:UpdateProcess()
  end
  self.isRefresh = false
  function DaiyanPreheatPanel.RefreshQuestChange(type)
    if not self.isRefresh then
      self.isRefresh = true
      DaiyanPreheatPanel:OnQuestChange()
    end
  end
  MessageSys:AddListener(CS.GF2.Message.QuestEvent.OnQuestReset, DaiyanPreheatPanel.RefreshQuestChange)
  function DaiyanPreheatPanel.RefreshPanel()
    DaiyanPreheatPanel:UpdateProcess()
  end
  MessageSys:AddListener(CS.GF2.Message.UIEvent.ThemeWarmUpPointUpdate, DaiyanPreheatPanel.RefreshPanel)
  function DaiyanPreheatPanel.RefreshThemeInfo()
    DaiyanPreheatPanel:OnQuestChange()
  end
  MessageSys:AddListener(CS.GF2.Message.UIEvent.ThemeActivityUpdate, DaiyanPreheatPanel.RefreshThemeInfo)
end
function DaiyanPreheatPanel:UpdateInfo()
  setactive(self.ui.mBtn_Video.gameObject, self.activityConfigData.prologue > 0)
  self.ui.mText_Title.text = self.activityEntranceData.name.str
  local currOpenTime = CS.CGameTime.ConvertLongToDateTime(self.activityPlanData.open_time):ToString("MM/dd HH:mm")
  local currCloseTime = CS.CGameTime.ConvertLongToDateTime(self.activityPlanData.close_time):ToString("MM/dd HH:mm")
  self.ui.mText_LastTime.text = TableData.GetHintById(270020) .. currOpenTime .. " - " .. currCloseTime
  self.ui.mImg_Avatar.sprite = IconUtils.GetCharacterHeadFullName(self.activityModuleData.activity_role.str)
  self.ui.mImg_Bg.sprite = IconUtils.GetUIResSprite("ActivityTheme/Daiyan/" .. self.activityModuleData.activity_main_bg.str)
  self.ui.mText_ActivityState.text = self.activityEntranceData.activity_desc.str
  for k, v in pairs(self.activityModuleData.activity_submodule) do
    self.processModuleId = v
    break
  end
  local warmUpQuestIdList = NetCmdThemeData:GetActivityIdList(self.processModuleId)
  if 0 < warmUpQuestIdList.Count then
    self.scoreId = warmUpQuestIdList[0]
    self.questId = warmUpQuestIdList[1]
    self.scoreData = TableData.listWarmUpQuestDatas:GetDataById(self.scoreId)
    self.questData = TableData.listWarmUpQuestDatas:GetDataById(self.questId)
  end
  self:ReleaseTimer()
  local repeatCount = self.activityPlanData.close_time - CGameTime:GetTimestamp() + 1
  if repeatCount <= 0 then
    local content = MessageContent.New(TableData.GetHintById(270144), MessageContent.MessageType.SingleBtn, function()
      UIManager.CloseUI(UIDef.DaiyanPreheatPanel)
    end)
    MessageBoxPanel.Show(content)
  end
  self.closeTimer = TimerSys:DelayCall(1, function()
    if CGameTime:GetTimestamp() >= self.activityPlanData.close_time then
      self:ReleaseTimer()
      local content = MessageContent.New(TableData.GetHintById(270144), MessageContent.MessageType.SingleBtn, function()
        UIManager.CloseUI(UIDef.DaiyanPreheatPanel)
      end)
      MessageBoxPanel.Show(content)
    end
  end, nil, repeatCount)
end
function DaiyanPreheatPanel:ReleaseTimer()
  if self.closeTimer then
    self.closeTimer:Stop()
    self.closeTimer = nil
  end
end
function DaiyanPreheatPanel:UpdateScoreInfo()
  self.scoreState = NetCmdCommonQuestData:GetReceivedRewardState(self.ThemeWarmUp, self.scoreId)
  setactive(self.ui.mTrans_ScoreRedPoint.gameObject, self.scoreState == 1)
  if self.scoreState == 0 then
    self.ui.mText_Score.text = self.scoreData.desc .. string_format(TableData.GetHintById(270143), 0, 1)
    setactive(self.ui.mTrans_ScoreFinished.gameObject, false)
    setactive(self.ui.mBtn_ScoreBtn.gameObject, true)
  else
    self.ui.mText_Score.text = self.scoreData.desc .. "<color=#dcc173>" .. string_format(TableData.GetHintById(270143), 1, 1) .. "</color>"
    if self.scoreState == 1 then
      setactive(self.ui.mTrans_ScoreFinished.gameObject, false)
      setactive(self.ui.mBtn_ScoreBtn.gameObject, true)
    else
      setactive(self.ui.mTrans_ScoreFinished.gameObject, true)
      setactive(self.ui.mBtn_ScoreBtn.gameObject, false)
    end
  end
  self:UpdateProcess()
end
function DaiyanPreheatPanel:UpdateQuestInfo()
  self.questState = NetCmdCommonQuestData:GetReceivedRewardState(self.ThemeWarmUp, self.questId)
  setactive(self.ui.mTrans_QuestRedPoint.gameObject, self.questState == 1)
  setactive(self.ui.mTrans_ReceiveBg.gameObject, self.questState == 1)
  if self.questState == 0 then
    self.ui.mText_Quest.text = self.questData.desc .. string_format(TableData.GetHintById(270143), 0, 1)
    self.ui.mText_QuestState.text = TableData.GetHintById(20)
    setactive(self.ui.mTrans_QuestFinished.gameObject, false)
    setactive(self.ui.mBtn_QuestBtn.gameObject, true)
  else
    if self.questState == 1 then
      setactive(self.ui.mTrans_QuestFinished.gameObject, false)
      setactive(self.ui.mBtn_QuestBtn.gameObject, true)
    else
      setactive(self.ui.mTrans_QuestFinished.gameObject, true)
      setactive(self.ui.mBtn_QuestBtn.gameObject, false)
    end
    self.ui.mText_QuestState.text = TableData.GetHintById(120193)
    self.ui.mText_Quest.text = self.questData.desc .. "<color=#dcc173>" .. string_format(TableData.GetHintById(270143), 1, 1) .. "</color>"
  end
  self:UpdateProcess()
end
function DaiyanPreheatPanel:UpdateProcess()
  local curValue = NetCmdThemeData:GetTotalPoint()
  self.ui.mText_Point.text = string_format(TableData.GetHintById(270006), curValue)
  local maxValue = 100
  local rewardIDList = NetCmdThemeData:GetRewardIdList(self.processModuleId)
  local pointList = {}
  if rewardIDList then
    for i = 1, rewardIDList.Count do
      local data = TableData.listWarmUpRewardDatas:GetDataById(rewardIDList[i - 1])
      local cell = self.rewardUIList[i]
      if data and cell then
        table.insert(pointList, data.point)
        cell.Text_Num.text = data.point
        local state = NetCmdThemeData:GetPhaseRewardState(rewardIDList[i - 1])
        cell.isFinish = state == 2
        cell.isCanGet = state == 1
        setactive(cell.Trans_Finished, cell.isFinish)
        setactive(cell.Trans_RedPoint, cell.isCanGet)
        setactive(cell.Trans_Lighted, cell.isCanGet)
      end
    end
    local offSetList = {
      0.14553990610328638,
      0.5023474178403756,
      0.8685446009389671
    }
    local process = 0
    if curValue <= pointList[1] then
      process = curValue / maxValue
    elseif curValue <= pointList[2] then
      process = offSetList[1] + (curValue - pointList[1]) / (pointList[2] - pointList[1]) * 152 / 426
    else
      process = offSetList[2] + (curValue - pointList[2]) / (pointList[3] - pointList[2]) * 156 / 426
    end
    self.ui.mSlider_ProgressBar.FillAmount = process
  end
end
function DaiyanPreheatPanel:OnShowStart()
end
function DaiyanPreheatPanel:OnShowFinish()
end
function DaiyanPreheatPanel:CleanTime()
  if self.refreshTime then
    self.refreshTime:Stop()
    self.refreshTime = nil
  end
end
function DaiyanPreheatPanel:OnQuestChange()
  self:CleanTime()
  self.refreshTime = TimerSys:DelayCall(1, function()
    self:CleanTime()
    self:UpdateScoreInfo()
    self:UpdateQuestInfo()
  end)
end
function DaiyanPreheatPanel:OnTop()
  self:UpdateScoreInfo()
  self:UpdateQuestInfo()
end
function DaiyanPreheatPanel:OnBackFrom()
  self:UpdateScoreInfo()
  self:UpdateInfo()
  self:UpdateQuestInfo()
end
function DaiyanPreheatPanel:OnClose()
  self:ReleaseTimer()
  self:CleanTime()
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.ThemeWarmUpPointUpdate, DaiyanPreheatPanel.RefreshPanel)
  MessageSys:RemoveListener(CS.GF2.Message.QuestEvent.OnQuestReset, DaiyanPreheatPanel.RefreshQuestChange)
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.ThemeActivityUpdate, DaiyanPreheatPanel.RefreshThemeInfo)
end
function DaiyanPreheatPanel:OnHide()
end
function DaiyanPreheatPanel:OnHideFinish()
end
function DaiyanPreheatPanel:OnRelease()
end
