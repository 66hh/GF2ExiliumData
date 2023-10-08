require("UI.UIBasePanel")
require("UI.ChapterPanel.UIChapterGlobal")
require("UI.ActivityTheme.Daiyan.DaiyanGlobal")
require("UI.ActivityGachaPanel.ActivityGachaGlobal")
DaiyanMainPanel = class("DaiyanMainPanel", UIBasePanel)
DaiyanMainPanel.__index = DaiyanMainPanel
function DaiyanMainPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
end
function DaiyanMainPanel:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.firstStageData = nil
  self.secondStageData = nil
  self:AddBtnListen()
end
function DaiyanMainPanel:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.DaiyanMainPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Video.gameObject).onClick = function()
    CS.AVGController.PlayAvgByPlotId(self.activityConfigData.prologue, function()
    end, true)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Exchange.gameObject).onClick = function()
    local collectionData = TableData.listCollectionThemeDatas:GetDataById(self.collectId)
    if collectionData and not AccountNetCmdHandler:CheckSystemIsUnLock(collectionData.unlock) then
      local unlockData = TableDataBase.listUnlockDatas:GetDataById(collectionData.unlock)
      if unlockData then
        local str = UIUtils.CheckUnlockPopupStr(unlockData)
        PopupMessageManager.PopupString(str)
      end
      return
    end
    if self.btnStateList[5001] == 2 then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(260007))
      return
    end
    UIManager.OpenUIByParam(UIDef.ActivityMusePanel, {
      themeId = self.activityEntranceData.id
    })
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Barrier.gameObject).onClick = function()
    local monopolyData = TableData.listMonopolyConfigDatas:GetDataById(self.monopolyId)
    if monopolyData and not AccountNetCmdHandler:CheckSystemIsUnLock(monopolyData.unlock) then
      local unlockData = TableDataBase.listUnlockDatas:GetDataById(monopolyData.unlock)
      if unlockData then
        local str = UIUtils.CheckUnlockPopupStr(unlockData)
        PopupMessageManager.PopupString(str)
      end
      return
    end
    if self.btnStateList[3002] == 2 then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(260007))
      return
    end
    NetCmdThemeData:SetCurrLevelIndex(0, true)
    UIManager.OpenUI(UIDef.ActivityTourDifficultySelectPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Gacha.gameObject).onClick = function()
    if self.btnStateList[4001] == 2 then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(260007))
      return
    end
    self:EnterGacha()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ChapterEntry.gameObject).onClick = function()
    if self.btnStateList[2001] == 2 then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(260007))
      return
    end
    if self.chapterId == nil then
      return
    end
    local chapterData = TableData.listChapterDatas:GetDataById(self.chapterId)
    if chapterData == nil then
      return
    end
    UIManager.OpenUIByParam(UIDef.DaiyanChapterPanel, {chapterData = chapterData})
  end
end
function DaiyanMainPanel:OnInit(root, data)
  if data == nil then
    self:OnServerReq()
  else
    self.activityEntranceData = data.activityEntranceData
    self.activityModuleData = data.activityModuleData
    self.activityConfigData = data.activityConfigData
    self.activityPlanData = TableData.listPlanDatas:GetDataById(self.activityEntranceData.plan_id)
    self:UpdateInfo()
    self:UpdateCD()
  end
end
function DaiyanMainPanel:OnServerReq()
  NetCmdRecentActivityData:ReqPlanActivityData(PlanType.PlanFunctionActivityThematic, function(ret)
    if ret == ErrorCodeSuc then
      local planActivityId = NetCmdRecentActivityData:GetCurrPlanId()
      self.activityPlanData = TableData.listPlanDatas:GetDataById(planActivityId, true)
      if self.activityPlanData == nil then
        UIManager.CloseUI(UIDef.DaiyanMainPanel)
        return
      end
      self.activityEntranceData = TableData.listActivityEntranceDatas:GetDataById(self.activityPlanData.args[0])
      self.activityModuleData = TableData.listActivityModuleDatas:GetDataById(self.activityEntranceData.module_id)
      self.activityConfigData = NetCmdThemeData:GetActivityDataByEntranceId(self.activityEntranceData.id)
      NetCmdThemeData:SendThemeActivityInfo(self.activityEntranceData.id, function(ret)
        self:UpdateInfo()
        self:UpdateCD()
      end)
    end
  end)
end
function DaiyanMainPanel:UpdateCD()
  self:ReleaseTimer()
  if self.activityModuleData.stage_type == 2 then
    local repeatCount = self.activityPlanData.close_time - CGameTime:GetTimestamp() + 1
    local cdCount = 0
    if 0 < repeatCount then
      self.cdTimer = TimerSys:DelayCall(1, function()
        cdCount = cdCount + 1
        if cdCount >= repeatCount then
          self:ReleaseTimer()
          self:OnStageChange()
        end
      end, nil, repeatCount)
    end
  end
end
function DaiyanMainPanel:ReleaseTimer()
  if self.cdTimer then
    self.cdTimer:Stop()
    self.cdTimer = nil
  end
end
function DaiyanMainPanel:OnStageChange()
  NetCmdRecentActivityData:ReqPlanActivityData(PlanType.PlanFunctionActivityThematic, function(ret)
    if ret == ErrorCodeSuc then
      local planId = NetCmdRecentActivityData:GetPlanActivityId(3)
      if 0 < planId then
        self.activityPlanData = TableData.listPlanDatas:GetDataById(planId)
        if self.activityPlanData then
          self.activityEntranceData = TableData.listActivityEntranceDatas:GetDataById(self.activityPlanData.args[0])
          if self.activityEntranceData then
            self.activityModuleData = TableData.listActivityModuleDatas:GetDataById(self.activityEntranceData.module_id)
            self:UpdateInfo()
          end
        end
      end
    end
  end)
end
function DaiyanMainPanel:UpdateInfo()
  self.btnStateList = {}
  for k, v in pairs(self.activityModuleData.activity_submodule) do
    if k == 2001 then
      self.chapterId = v
    elseif k == 4001 then
      self.gachaponId = v
    elseif k == 3002 then
      self.monopolyId = v
    elseif k == 5001 then
      self.collectId = v
    end
  end
  for k, v in pairs(self.activityModuleData.entrance_type) do
    self.btnStateList[k] = v
  end
  if self.gachaponId == nil then
    self.gachaponId = 101
  end
  if self.monopolyId == nil then
    self.monopolyId = 101
  end
  if self.chapterId == nil then
    self.chapterId = 4001
  end
  if self.collectId == nil then
    self.collectId = 101
  end
  self.chapterData = TableData.listChapterDatas:GetDataById(self.chapterId)
  local gachaponData = TableData.listActivityGachaConfigDatas:GetDataById(self.gachaponId)
  if gachaponData then
    self.ui.mText_GachaName.text = gachaponData.activity_name.str
  end
  local monopolyData = TableData.listMonopolyConfigDatas:GetDataById(self.monopolyId)
  if monopolyData then
    self.ui.mText_BarrierName.text = monopolyData.monopoly_name.str
    self.ui.mText_BarrierDescribe.text = monopolyData.monopoly_des.str
  end
  local collectionData = TableData.listCollectionThemeDatas:GetDataById(self.collectId)
  if collectionData then
    self.ui.mText_ExchangeName.text = collectionData.name
    self.ui.mText_ExchangeDescribe.text = collectionData.theme_desc
  end
  self:UpdateStageState()
  self.ui.mText_Title.text = self.activityEntranceData.name.str
  self.ui.mText_Describe.text = self.activityModuleData.activity_information.str
  setactive(self.ui.mTrans_ExchangeRedPoint.gameObject, AccountNetCmdHandler:CheckSystemIsUnLock(collectionData.unlock) and NetCmdThemeData:ThemeCollectRed() or NetCmdThemeData:ThemeExchangeRed())
  setactive(self.ui.mTrans_BarrierRedPoint.gameObject, AccountNetCmdHandler:CheckSystemIsUnLock(monopolyData.unlock) and NetCmdThemeData:MissionRed())
  if self.chapterData then
    self.ui.mText_ChapterName.text = self.chapterData.name.str
    NetCmdThemeData:UpdateLevelInfo(self.chapterData.stage_group)
    local currLevelId = NetCmdThemeData:GetCurrCompLevel()
    local storyData = TableData.listStoryDatas:GetDataById(currLevelId)
    local stageData = TableData.listStageDatas:GetDataById(storyData.stage_id)
    if storyData and stageData then
      self.ui.mText_Chapter.text = "<color=#dcc173>" .. storyData.name.str .. "</color>" .. stageData.name.str
    else
      self.ui.mText_Chapter.text = "<color=#dcc173> 1-1 </color>" .. " 黛烟活动-主线1"
    end
    if self.activityModuleData.stage_type == 2 then
      if self.chapterData.chapter_reward_value.Count > 0 then
        local stars = NetCmdDungeonData:GetCurStarsByChapterID(self.chapterData.id)
        local totalCount = self.chapterData.chapter_reward_value[self.chapterData.chapter_reward_value.Count - 1]
        if stars == 0 or totalCount == 0 then
          self.ui.mText_Per.text = "0%"
        else
          self.ui.mText_Per.text = math.ceil(stars / totalCount * 100) .. "%"
        end
        setactive(self.ui.mTrans_ChapterRedPoint.gameObject, 0 < NetCmdDungeonData:UpdateChatperRewardRedPoint(4001))
      else
        local chapterInfo = TableData.GetStorysByChapterID(self.chapterData.id)
        local compCount = NetCmdDungeonData:GetChapterCompteCount(self.chapterData.id)
        if chapterInfo then
          self.ui.mText_Per.text = math.ceil(compCount / chapterInfo.Count * 100) .. "%"
        else
          self.ui.mText_Per.text = "0%"
        end
        setactive(self.ui.mTrans_ChapterRedPoint.gameObject, false)
      end
    else
      self.ui.mText_Per.text = TableData.GetHintById(192046)
      setactive(self.ui.mTrans_ChapterRedPoint.gameObject, false)
    end
    setactive(self.ui.mTrans_TopText.gameObject, true)
  else
    self.ui.mText_Per.text = TableData.GetHintById(192046)
    self.ui.mText_Chapter.text = "<color=#dcc173> 1-1 </color>" .. " 黛烟活动-主线1"
    setactive(self.ui.mTrans_TopText.gameObject, false)
    setactive(self.ui.mTrans_ChapterRedPoint.gameObject, false)
  end
  setactive(self.ui.mBtn_Video.gameObject, 0 < self.activityConfigData.prologue)
  self.ui.mImg_Bg.sprite = IconUtils.GetActivityThemeSprite("ActivityTheme/Daiyan/" .. self.activityModuleData.activity_main_bg.str)
  self:RefreshGachaButton()
  setactive(self.ui.mTrans_Locked, not AccountNetCmdHandler:CheckSystemIsUnLock(collectionData.unlock))
  setactive(self.ui.mTrans_Locked1, not AccountNetCmdHandler:CheckSystemIsUnLock(monopolyData.unlock))
  self.ui.mBtn_Exchange.interactable = self.btnStateList[5001] ~= 3
  self.ui.mBtn_Barrier.interactable = self.btnStateList[3002] ~= 3
  self.ui.mBtn_Gacha.interactable = self.btnStateList[4001] ~= 3
  self.ui.mBtn_ChapterEntry.interactable = self.btnStateList[2001] ~= 3
  setactive(self.ui.mBtn_Exchange.gameObject, self.btnStateList[5001] ~= 4)
  setactive(self.ui.mBtn_Barrier.gameObject, self.btnStateList[3002] ~= 4)
  setactive(self.ui.mBtn_Gacha.gameObject, self.btnStateList[4001] ~= 4)
  setactive(self.ui.mBtn_ChapterEntry.gameObject, self.btnStateList[2001] ~= 4)
  if self.btnStateList[5001] == 2 or self.btnStateList[5001] == 3 then
    self.ui.mText_ExchangeDescribe.text = TableData.GetHintById(192046)
  end
  if self.btnStateList[3002] == 2 or self.btnStateList[3002] == 3 then
    self.ui.mText_BarrierDescribe.text = TableData.GetHintById(192046)
  end
  if self.btnStateList[2001] == 2 or self.btnStateList[2001] == 3 then
    self.ui.mText_Per.text = TableData.GetHintById(192046)
  end
end
function DaiyanMainPanel:UpdateStageState()
  local data
  for i = 1, self.activityConfigData.activity_entrance.Count do
    local entranceData = TableData.listActivityEntranceDatas:GetDataById(self.activityConfigData.activity_entrance[i - 1])
    if entranceData then
      local moduleData = TableData.listActivityModuleDatas:GetDataById(entranceData.module_id)
      if moduleData and moduleData.stage_type == 2 then
        if self.firstStageData == nil then
          self.firstStageData = entranceData
        else
          self.secondStageData = entranceData
        end
      end
    end
  end
  if self.firstStageData then
    if self.secondStageData then
      if NetCmdRecentActivityData:ThemeActivityIsOpen(self.secondStageData.id) then
        setactive(self.ui.mTrans_SecondOnGoing.gameObject, true)
        self:ShowActivityTime(self.secondStageData.plan_id)
      else
        setactive(self.ui.mTrans_SecondOnGoing.gameObject, false)
        self:ShowActivityTime(self.firstStageData.plan_id)
      end
      setactive(self.ui.mTrans_State.gameObject, true)
    else
      setactive(self.ui.mTrans_State.gameObject, false)
      self:ShowActivityTime(self.firstStageData.plan_id)
    end
  else
    setactive(self.ui.mTrans_State.gameObject, false)
  end
  if self.activityModuleData.stage_type == 3 then
    self.ui.mText_LastTime.text = TableData.GetHintById(192046)
  end
end
function DaiyanMainPanel:ShowActivityTime(planActivityId)
  local planActivityData = TableData.listPlanDatas:GetDataById(planActivityId)
  if planActivityData then
    local currOpenTime = CS.CGameTime.ConvertLongToDateTime(planActivityData.open_time):ToString("yyyy.MM.dd/HH:mm")
    local currCloseTime = CS.CGameTime.ConvertLongToDateTime(planActivityData.close_time):ToString("yyyy.MM.dd/HH:mm")
    self.ui.mText_LastTime.text = currOpenTime .. " - " .. currCloseTime
  end
end
function DaiyanMainPanel:OnShowStart()
end
function DaiyanMainPanel:OnShowFinish()
end
function DaiyanMainPanel:OnTop()
end
function DaiyanMainPanel:OnBackFrom()
  if self.activityPlanData == nil then
    self:OnServerReq()
  elseif CGameTime:GetTimestamp() < self.activityPlanData.open_time or CGameTime:GetTimestamp() >= self.activityPlanData.close_time then
    self:OnServerReq()
  else
    self:UpdateInfo()
    self:UpdateCD()
  end
end
function DaiyanMainPanel:OnClose()
  self.firstStageData = nil
  self.secondStageData = nil
  self:ReleaseTimer()
end
function DaiyanMainPanel:OnHide()
  self.firstStageData = nil
  self.secondStageData = nil
  self:ReleaseTimer()
end
function DaiyanMainPanel:OnHideFinish()
end
function DaiyanMainPanel:OnRelease()
end
function DaiyanMainPanel:RefreshGachaButton()
  setactive(self.ui.mBtn_Gacha.gameObject, false)
  setactive(self.ui.mTrans_GachaRedPoint.gameObject, false)
  if self.gachaponId <= 0 then
    return
  end
  setactive(self.ui.mBtn_Gacha.gameObject, true)
  if not NetCmdActivityGachaData:IfInActTimeAndUnlock(self.gachaponId) then
    return
  end
  NetCmdActivityGachaData:CheckSendCS_ActivityGachaSettle(self.activityConfigData.Id)
  local bShow = NetCmdActivityGachaData:IfShowRedPoint(self.activityModuleData)
  setactive(self.ui.mTrans_GachaRedPoint.gameObject, bShow)
end
function DaiyanMainPanel:EnterGacha()
  if self.gachaponId <= 0 then
    return
  end
  local data = NetCmdActivityGachaData:GetActivityGachaByActId(self.activityConfigData.Id)
  if not data then
    return
  end
  local endTime = NetCmdActivityGachaData:GetActEndTime(self.activityConfigData.Id)
  if endTime < CGameTime:GetTimestamp() then
    PopupMessageManager.PopupString(TableData.GetHintById(260007))
    return
  end
  if self.ui.mTrans_GachaRedPoint.gameObject.activeSelf and NetCmdActivityGachaData:IfShowEnterRedPoint(self.activityModuleData) then
    if not NetCmdActivityGachaData:IfShowRoundRedPoint(self.activityModuleData) then
      setactive(self.ui.mTrans_GachaRedPoint.gameObject, false)
    end
    NetCmdActivityGachaData:SetEntryPrefs(self.gachaponId)
  end
  UIManager.OpenUIByParam(UIDef.UIActivityGachaPanel, {
    actId = self.activityConfigData.Id,
    gachaId = self.gachaponId,
    planId = self.activityEntranceData.plan_id
  })
end
