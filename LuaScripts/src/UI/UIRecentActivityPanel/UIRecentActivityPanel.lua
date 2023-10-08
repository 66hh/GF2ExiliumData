require("UI.UIRecentActivityPanel.UIRecentActivityTab")
require("UI.UIRecentActivityPanel.UIRecentActivityFirstOpenedDialog")
UIRecentActivityPanel = class("UIRecentActivityPanel", UIBasePanel)
function UIRecentActivityPanel:OnAwake(root, data)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnBack.gameObject, function()
    self:OnClickBack()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnHome.gameObject, function()
    self:OnClickHome()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_DarkzoneEnter.gameObject, function()
    self:OnClickDarkZoneEnter()
  end)
  setactivewithcheck(self.ui.mTrans_TIme, false)
  self.tabTable = {}
end
function UIRecentActivityPanel:OnInit(root, data, behaviourId)
end
function UIRecentActivityPanel:OnShowStart()
  self:SetVisible(false)
  self.last = false
  self.showMessBox = false
  self:Refresh()
end
function UIRecentActivityPanel:OnBackFrom()
  self:SetVisible(false)
  self:Refresh()
end
function UIRecentActivityPanel:OnTop()
  self:Refresh()
end
function UIRecentActivityPanel:OnReconnectSuc()
  self:Refresh()
end
function UIRecentActivityPanel:CleanTime()
  if self.delayTime then
    self.delayTime:Stop()
    self.delayTime = nil
  end
end
function UIRecentActivityPanel:OnShowFinish()
  self:CleanTime()
  self.delayTime = TimerSys:DelayCall(3.5, function()
    if self.showMessBox then
      return
    end
    if self.planActivityDataList == nil then
      return
    end
    for i = 0, self.planActivityDataList.Count - 1 do
      local enterID = self.planActivityDataList[i].id
      local activityPlayState = NetCmdThemeData:GetThemeAnimState(enterID)
      if activityPlayState < 1 then
        NetCmdThemeData:SetShowAniIndex(i)
        self:Refresh()
        break
      end
    end
  end)
end
function UIRecentActivityPanel:OnSave()
end
function UIRecentActivityPanel:OnRecover()
  self:Refresh()
end
function UIRecentActivityPanel:IsReadyToStartTutorial()
  self.planActivityDataList = NetCmdRecentActivityData:GetRequestedPlanActivityDataList()
  self:InitAllRecentActivityTab()
  for i, tab in ipairs(self.tabTable) do
    if tab:IsFirstOpen() then
      return false
    end
  end
  return true
end
function UIRecentActivityPanel:OnHideFinish()
  self.planActivityDataList = nil
  self.isDarkZoneOpenTime = nil
  if self.timer_FadeIn1 then
    self.timer_FadeIn1:Stop()
    self.timer_FadeIn1 = nil
  end
  self:ReleaseCtrlTable(self.tabTable, true)
end
function UIRecentActivityPanel:OnClose()
  self:CleanFinishTime()
  self:CleanTime()
  self.last = false
end
function UIRecentActivityPanel:OnRelease()
  self.tabTable = nil
  self.ui = nil
  self:CleanFinishTime()
  self.super.OnRelease(self)
end
function UIRecentActivityPanel:Refresh()
  self:RefreshRecentActivityTab()
  self:RefreshDarkZoneEntrance()
end
function UIRecentActivityPanel:GetEndParam()
  local endCount = 0
  local endTime = 0
  for i, tab in ipairs(self.tabTable) do
    if tab.activityModuleData.stage_type == 3 then
      endCount = endCount + 1
      if endTime < tab.planActivityData.close_time then
        endTime = tab.planActivityData.close_time
      end
    end
  end
  if endCount == self.planActivityDataList.Count then
    return true, endTime
  end
  return false, 0
end
function UIRecentActivityPanel:checkRecentActivityFirstOpened()
  for i, tab in ipairs(self.tabTable) do
    if tab:IsFirstOpen() then
      local param = {}
      param.activityEntranceData = tab:GetActivityEntranceData()
      param.activityConfigData = tab:GetActivityConfigData()
      param.activityModuleData = tab:GetActivityModuleData()
      UISystem:OpenUI(UIDef.UIRecentActivityFirstOpenedDialog, param)
      self.showMessBox = true
      break
    else
      local isAllend, endTime = self:GetEndParam()
      if isAllend then
        self:UpdateFinishTime(endTime)
      end
    end
  end
end
function UIRecentActivityPanel:CleanFinishTime()
  if self.finishTime then
    self.finishTime:Stop()
    self.finishTime = nil
  end
end
function UIRecentActivityPanel:UpdateFinishTime(endTime)
  self:CleanFinishTime()
  local repeatCount = endTime - CGameTime:GetTimestamp()
  if 0 < repeatCount then
    self.finishTime = TimerSys:DelayCall(1, function()
      if CGameTime:GetTimestamp() >= endTime then
        self:CleanFinishTime()
        self:SetAllRecentActivityTabVisible(false)
      end
    end, nil, repeatCount)
  end
end
function UIRecentActivityPanel:RefreshRecentActivityTab()
  NetCmdRecentActivityData:ReqPlanActivityData(PlanType.PlanFunctionActivityThematic, function(ret)
    if ret ~= ErrorCodeSuc then
      self:SetVisible(true)
      self:SetAllRecentActivityTabVisible(false)
      setactivewithcheck(self.ui.mTrans_Mask, false)
      return
    end
    self:SetVisible(true)
    self.planActivityDataList = NetCmdRecentActivityData:GetRequestedPlanActivityDataList()
    if self.planActivityDataList.Count > 0 then
      local showAniIndex = NetCmdThemeData:GetShowAniIndex()
      if showAniIndex >= self.planActivityDataList.Count then
        self.last = true
        NetCmdThemeData:SetShowAniIndex(0)
        showAniIndex = 0
      end
      local enterID = self.planActivityDataList[showAniIndex].id
      local activityPlayState = NetCmdThemeData:GetThemeAnimState(enterID)
      self:InitAllRecentActivityTab()
      self:RefreshActivityPoint()
      self:RefreshAllRecentActivityTab()
      setactivewithcheck(self.ui.mTrans_Mask, activityPlayState < 1 and enterID ~= 0)
      if 0 < activityPlayState then
        self.ui.mAnimator_Root:SetTrigger("FadeIn_0")
        self:checkRecentActivityFirstOpened()
        return
      end
      local length = 0
      if self.timer_FadeIn1 then
        self.ui.mAnimator_Root:SetBool("Sweep", true)
        length = LuaUtils.GetAnimationClipLength(self.ui.mAnimator_Root, "Sweep")
      else
        self.ui.mAnimator_Root:SetTrigger("FadeIn_1")
        self.ui.mAnimator_Root:SetBool("Sweep", true)
        length = LuaUtils.GetAnimationClipLength(self.ui.mAnimator_Root, "FadeIn_1")
      end
      self.timer_FadeIn1 = TimerSys:DelayCall(length, function(data)
        self:checkRecentActivityFirstOpened()
      end)
    else
      self.ui.mAnimator_Root:SetTrigger("FadeIn_0")
      setactivewithcheck(self.ui.mTrans_Mask, false)
    end
  end)
end
function UIRecentActivityPanel:RefreshDarkZoneEntrance()
  self.ui.mBtn_DarkzoneEnter.interactable = false
  setactivewithcheck(self.ui.mCountdown, false)
  NetCmdRecentActivityData:ReqPlanActivityData(PlanType.PlanFunctionDarkzone, function(ret)
    if ret ~= ErrorCodeSuc then
      return
    end
    self.ui.mBtn_DarkzoneEnter.interactable = true
    local sc_planActivityData = NetCmdRecentActivityData:GetPlanActivityData()
    local planActivityIdList = sc_planActivityData.ActiveIds
    local nextPlanActivityIdList = sc_planActivityData.NextIds
    self.isDarkZoneOpenTime = planActivityIdList.Count > 0
    if planActivityIdList.Count > 1 then
      gferror("同时开启两个暗区活动!!!")
    end
    for i = 0, planActivityIdList.Count - 1 do
      local planActivityId = planActivityIdList[i]
      local planActivityData = TableDataBase.listPlanDatas:GetDataById(planActivityId)
      gfdebug("RefreshDarkZoneEntrance closeTime" .. planActivityData.close_time)
      break
    end
    local isOpenTime = self.isDarkZoneOpenTime
    local isUnlock = AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.Darkzone)
    local canEnter = isOpenTime and isUnlock
    self.ui.mAnimator_DarkZoneEnter:SetBool("Unlock", canEnter)
    if not isOpenTime and nextPlanActivityIdList.Count > 0 then
      local nextPlanActivityId = nextPlanActivityIdList[0]
      local nextPlanActivityData = TableDataBase.listPlanDatas:GetDataById(nextPlanActivityId)
      gfdebug("RefreshDarkZoneEntrance openTime" .. nextPlanActivityData.open_time)
    end
    local isNeedRedPoint = NetCmdRecentActivityData:CheckRecentActivityDarkZoneRedPoint() and canEnter
    setactivewithcheck(self.ui.mObj_RedPoint, isNeedRedPoint)
    setactivewithcheck(self.ui.mObj_RedPoint.parent.transform, isNeedRedPoint)
  end)
end
function UIRecentActivityPanel:InitAllRecentActivityTab()
  local showAniIndex = NetCmdThemeData:GetShowAniIndex()
  local dataCount = self.planActivityDataList.Count
  for i = dataCount + 1, #self.tabTable do
    local tab = self.tabTable[i]
    tab:SetVisible(false)
  end
  local showIndex = 0
  if self.last then
    local enterID = self.planActivityDataList[showAniIndex].id
    local activityPlayState = NetCmdThemeData:GetThemeAnimState(enterID)
    if 0 < activityPlayState then
      showIndex = self.planActivityDataList.Count
    else
      showIndex = self.planActivityDataList.Count - 1
    end
  elseif 0 < showAniIndex then
    showAniIndex = showAniIndex - 1
    local enterID = self.planActivityDataList[showAniIndex].id
    local activityPlayState = NetCmdThemeData:GetThemeAnimState(enterID)
    if 0 < activityPlayState then
      showIndex = showAniIndex + 1
    else
      showIndex = showAniIndex
    end
  else
    isEndCount = 0
    for i = 0, self.planActivityDataList.Count - 1 do
      local enterID = self.planActivityDataList[i].id
      local activityPlayState = NetCmdThemeData:GetThemeAnimState(enterID)
      if 0 < activityPlayState then
        isEndCount = isEndCount + 1
      end
    end
    if isEndCount >= self.planActivityDataList.Count then
      showIndex = self.planActivityDataList.Count
    else
      showIndex = isEndCount
    end
  end
  for i = 0, self.planActivityDataList.Count - 1 do
    local tab = self.tabTable[i + 1]
    if not tab then
      tab = UIRecentActivityTab.New()
      tab:InitCtrl(self.ui.mScrollListChild_GrpRight.transform)
      table.insert(self.tabTable, i + 1, tab)
    end
    tab:SetVisible(i < showIndex)
    tab:SetData(self.planActivityDataList[i], i + 1, function(index)
      self:OnClickTab(index)
    end)
    tab:AddActivityEndCallback(function(tabIndex)
      self:OnActivityTimerEnd(tabIndex)
    end)
  end
end
function UIRecentActivityPanel:RefreshAllRecentActivityTab()
  for i = 0, self.planActivityDataList.Count - 1 do
    local tab = self.tabTable[i + 1]
    tab:SetData(self.planActivityDataList[i], i + 1, function(index)
      self:OnClickTab(index)
    end)
    tab:AddActivityEndCallback(function(tabIndex)
      self:OnActivityTimerEnd(tabIndex)
    end)
    tab:Refresh()
  end
end
function UIRecentActivityPanel:SetAllRecentActivityTabVisible(visible)
  if self.tabTable == nil then
    return
  end
  for i, tab in ipairs(self.tabTable) do
    tab:SetVisible(visible)
  end
end
function UIRecentActivityPanel:RefreshActivityPoint()
  for i = 1, 2 do
    local tab = self.tabTable[i]
    if tab and tab:IsFirstOpen() then
      for j = i, 2 do
        local point = self.ui["mTrans_ActivityPoint" .. j]
        setactivewithcheck(point, false)
      end
      break
    end
  end
  for i, tab in ipairs(self.tabTable) do
    local point = self.ui["mTrans_ActivityPoint" .. i]
    if point then
      if tab:IsFirstOpen() then
        setactivewithcheck(point, true)
        break
      else
        setactivewithcheck(point, true)
      end
    end
  end
end
function UIRecentActivityPanel:IsHaveFirstOpenActivity()
  local haveFirstOpen = false
  for i, tab in ipairs(self.tabTable) do
    haveFirstOpen = haveFirstOpen or tab:IsFirstOpen()
  end
  return haveFirstOpen
end
function UIRecentActivityPanel:OnActivityTimerEnd(index)
  self:Refresh()
end
function UIRecentActivityPanel:OnDarkZoneTimerEnd(succ)
  if not succ then
    return
  end
  self:RefreshDarkZoneEntrance()
end
function UIRecentActivityPanel:OnClickTab(index)
  local tab = self.tabTable[index]
  local activityConfigData = tab:GetActivityConfigData()
  if activityConfigData then
    if activityConfigData.prologue > 0 and NetCmdThemeData:GetThemeAVGState(activityConfigData.id) < 1 then
      NetCmdThemeData:SendThemeActivityInfo(tab.activityEntranceData.id, function(ret)
        if ret == ErrorCodeSuc then
          if tab.activityModuleData.stage_type == 1 then
            UIManager.OpenUIByParam(UIDef.DaiyanPreheatPanel, {
              activityEntranceData = tab:GetActivityEntranceData(),
              activityModuleData = tab:GetActivityModuleData(),
              activityConfigData = tab:GetActivityConfigData()
            })
          else
            UIManager.OpenUIByParam(UIDef.DaiyanMainPanel, {
              activityEntranceData = tab:GetActivityEntranceData(),
              activityModuleData = tab:GetActivityModuleData(),
              activityConfigData = tab:GetActivityConfigData()
            })
          end
          CS.AVGController.PlayAvgByPlotId(activityConfigData.prologue, function()
            NetCmdThemeData:SetThemeAVGState(activityConfigData.id, 1)
          end, true)
        end
      end)
    else
      NetCmdThemeData:SendThemeActivityInfo(tab.activityEntranceData.id, function(ret)
        if ret == ErrorCodeSuc then
          if tab.activityModuleData.stage_type == 1 then
            UIManager.OpenUIByParam(UIDef.DaiyanPreheatPanel, {
              activityEntranceData = tab:GetActivityEntranceData(),
              activityModuleData = tab:GetActivityModuleData(),
              activityConfigData = tab:GetActivityConfigData()
            })
          else
            UIManager.OpenUIByParam(UIDef.DaiyanMainPanel, {
              activityEntranceData = tab:GetActivityEntranceData(),
              activityModuleData = tab:GetActivityModuleData(),
              activityConfigData = tab:GetActivityConfigData()
            })
          end
        end
      end)
    end
  end
end
function UIRecentActivityPanel:OnClickDarkZoneEnter()
  if TipsManager.NeedLockTips(SystemList.Darkzone) then
    return
  end
  local isOpenTime = self.isDarkZoneOpenTime
  if not isOpenTime then
    local str = TableData.GetHintById(200003)
    CS.PopupMessageManager.PopupString(str)
    MessageSys:SendMessage(GuideEvent.OnTabSwitchFail, nil)
    return
  end
  UIManager.OpenUI(UIDef.UIDarkZoneMainPanel)
end
function UIRecentActivityPanel:OnClickBack()
  UIManager.CloseUI(self.mCSPanel)
end
function UIRecentActivityPanel:OnClickHome()
  UIManager.JumpToMainPanel()
end
