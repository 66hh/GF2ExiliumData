require("UI.UIBasePanel")
require("UI.MonopolyActivity.SelectInfo.ActivityTourGridDetailItem")
require("UI.MonopolyActivity.SelectInfo.ActivityTourInfoItem")
require("UI.MonopolyActivity.TaskInfo.ActivityTourTaskInfo")
require("UI.MonopolyActivity.CharInfo.ActivityTourChrInfo")
require("UI.MonopolyActivity.ActivityTourGlobal")
require("UI.MonopolyActivity.RightTips.ActivityTourTips")
require("UI.MonopolyActivity.RandomMovePoint.ActivityTourPointRandomItem")
require("UI.MonopolyActivity.ActionTimeLine.ActionTimeLine")
require("UI.MonopolyActivity.Command.ActivityTourCommand")
ActivityTourMainPanel = class("ActivityTourMainPanel", UIBasePanel)
ActivityTourMainPanel.__index = ActivityTourMainPanel
function ActivityTourMainPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
  csPanel.Is3DPanel = true
end
function ActivityTourMainPanel:OnInit(root)
  ActivityTourGlobal.SetGlobalValue()
  self.super.SetRoot(self, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:RegisterEvent()
  self:RegisterMessage()
  self:InitGM()
  self:InitPoints()
  if not MonopolyWorld.MpData.isStart then
    self:OnHideActivityTourMainPanel()
    return
  end
  self:InitAll()
  self:OnHideActivityTourMainPanel()
end
function ActivityTourMainPanel:OnTop()
  self:RefreshStamina()
end
function ActivityTourMainPanel:InitGM()
  if CS.DebugCenter.Instance:IsOn(CS.DebugToggleType.ShowGMButton) then
    local GMItem = instantiate(UIUtils.GetGizmosPrefab("GameCommand/Btn_GMActivityTour.prefab", self), self.mUIRoot.transform)
    GMItem.transform:SetParent(self.mUIRoot, true)
    UIUtils.GetButtonListener(GMItem.gameObject).onClick = function()
      if CS.UI.Monopoly.UIMonopolyGMDialog.IsOpen() then
        CS.UI.Monopoly.UIMonopolyGMDialog.CloseSelf()
      else
        CS.UI.Monopoly.UIMonopolyGMDialog.Open()
      end
    end
  end
end
function ActivityTourMainPanel:InitAll()
  ActivityTourGlobal.MaxCommandNum = MonopolyWorld.MpData.levelData.max_order_number
  self:InitHud()
  self:InitAllCtrl()
  self:InitCurrency()
  ActivityTourGlobal.ReplaceAllColor(self.mUIRoot)
end
function ActivityTourMainPanel:InitCurrency()
  if self.mTopCurrency == nil then
    self.mTopCurrency = ResourcesCommonItem.New()
    self.mTopCurrency:InitCtrlWithObj(self.ui.mTrans_Stamina)
    local showCommandItemID = CS.GF2.Data.StaminaResourceType.Stamina:GetHashCode()
    local itemData = TableData.GetItemData(showCommandItemID)
    self.mTopCurrency:SetData({
      id = itemData.id,
      jumpID = 2
    })
    self:AddMessageListener(CS.GF2.Message.ModelDataEvent.StaminaChange, self.RefreshStamina)
  end
end
function ActivityTourMainPanel:InitPoints()
  self.ui.mImg_PointsIcon.sprite = IconUtils.GetActivityTourIcon(MonopolyWorld.MpData.levelData.token_icon)
  self.currency = MonopolyWorld.MpData.Points
  self.ui.mText_Currency.text = self.currency
end
function ActivityTourMainPanel:RefreshStamina()
  if self.mTopCurrency ~= nil then
    self.mTopCurrency:UpdateData()
  end
end
function ActivityTourMainPanel:InitHud()
  if not self.mHudCtrl then
    self.mHudCtrl = CS.UI.Monopoly.UIMonopolyHudCtrl()
    self.mHudCtrl:InitCtrl(self.ui.mTrans_HudNameRoot.childItem.gameObject, self.ui.mTrans_HudNameRoot.transform)
  end
end
function ActivityTourMainPanel.CloseSelf()
  UIManager.CloseUI(UIDef.ActivityTourMainPanel)
end
function ActivityTourMainPanel:RegisterEvent()
  UIUtils.GetButtonListener(self.ui.mBtn_Quit.gameObject).onClick = function()
    if MonopolyWorld.IsGmMode then
      NetCmdMonopolyData:ReturnToMainPanel()
    else
      UIManager.OpenUIByParam(UIDef.ActivityTourDoubleCheckDialog, {
        themeId = NetCmdMonopolyData.themID
      })
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_MapInfo.gameObject).onClick = function()
    self:OnBtnMapInfo()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_PPT.gameObject).onClick = function()
    self:ShowPPT()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Points.gameObject).onClick = function()
    UITipsPanel.Open(TableData.GetItemData(ActivityTourGlobal.PointsId))
  end
end
function ActivityTourMainPanel:ShowPPT()
  local pptId = MonopolyWorld.MpData.levelData.PptId
  if pptId <= 0 then
    print("配置的PPT ID为0")
    return
  end
  local pptData = TableData.GetSysGuidePagesByGroupId(pptId)
  if pptData == null then
    print_error("没有找到对应的PPT数据")
    return
  end
  UIManager.OpenUIByParam(UIDef.UISysGuideWindow, pptData)
end
function ActivityTourMainPanel:RegisterMessage()
  self:AddMessageListener(MonopolyEvent.OnShowSelectDetail, self.OnShowSelectDetail)
  self:AddMessageListener(MonopolyEvent.OnHideSelectDetail, self.OnHideSelectDetail)
  self:AddMessageListener(MonopolyEvent.ShowActivityTourMainPanel, self.OnShowActivityTourMainPanel)
  self:AddMessageListener(MonopolyEvent.HideActivityTourMainPanel, self.OnHideActivityTourMainPanel)
  self:AddMessageListener(MonopolyEvent.BlockActivityTourMainPanel, self.OnBlockActivityTourMainPanel)
  self:AddMessageListener(MonopolyEvent.CancelBlockActivityTourMainPanel, self.OnCancelBlockActivityTourMainPanel)
  self:AddMessageListener(MonopolyEvent.OnShowPointTip, self.OnShowPointTip)
  self:AddMessageListener(MonopolyEvent.RefreshAndResetPoints, self.RefreshAndResetPoints)
  self:AddMessageListener(MonopolyEvent.OnShowInspirationTip, self.OnShowInspirationTip)
  self:AddMessageListener(MonopolyEvent.OnShowRandomPoint, self.OnShowRandomPoint)
  self:AddMessageListener(MonopolyEvent.OnFleetComplete, self.OnFleetComplete)
  self:AddMessageListener(MonopolyEvent.OnRefreshCommand, self.OnRefreshCommand)
  self:AddMessageListener(MonopolyEvent.MoveNextActionTimeLine, self.MoveNextActionTimeLine)
  self:AddMessageListener(MonopolyEvent.ResetActionTimeLine, self.ResetActionTimeLine)
  self:AddMessageListener(MonopolyEvent.HideActionTimeLine, self.HideActionTimeLine)
  self:AddMessageListener(MonopolyEvent.OnRefreshRoundCount, self.OnRefreshRoundCount)
  self:AddMessageListener(MonopolyEvent.OnUpdateTaskProgress, self.OnUpdateTaskProgress)
  self:AddMessageListener(MonopolyEvent.OnTeamPropChange, self.OnTeamPropChange)
  self:AddMessageListener(MonopolyEvent.RefreshActorMainPanelState, self.RefreshActorMainPanelState)
  self:AddMessageListener(MonopolyEvent.EnterSelectDirectionGrid, self.EnterSelectDirectionGrid)
  self:AddMessageListener(MonopolyEvent.LeaveSelectDirectionGrid, self.LeaveSelectDirectionGrid)
end
function ActivityTourMainPanel:InitAllCtrl()
  self.mUITaskInfo = ActivityTourTaskInfo.New()
  self.mUITaskInfo:InitCtrl(self.ui)
  self.mUICharInfo = ActivityTourChrInfo.New()
  self.mUICharInfo:InitCtrl(self.ui)
  self.mUIActionTimeLine = ActionTimeLine.New()
  self.mUIActionTimeLine:InitCtrl(self.ui)
  self.mUIActivityTourCommand = ActivityTourCommand.New()
  self.mUIActivityTourCommand:InitCtrl(self.ui, self)
end
function ActivityTourMainPanel:OnRelease()
end
function ActivityTourMainPanel:OnClose()
  self.super.OnClose(self)
  if self.mHudCtrl then
    self.mHudCtrl:Destroy()
  end
  self.mHudCtrl = nil
  self.mTopCurrency = nil
  if self.mUITaskInfo then
    self.mUITaskInfo:Release()
    self.mUITaskInfo = nil
  end
  if self.mUICharInfo then
    self.mUICharInfo:Release()
    self.mUICharInfo = nil
  end
  if self.mUIActionTimeLine then
    self.mUIActionTimeLine:Release()
    self.mUIActionTimeLine = nil
  end
  if self.mUIActivityTourCommand then
    self.mUIActivityTourCommand:Release()
    self.mUIActivityTourCommand = nil
  end
  self:OnCloseSelInfo()
end
function ActivityTourMainPanel:OnCloseSelInfo()
  if self.selGridDetail ~= nil then
    self.selGridDetail:OnRelease(true)
  end
  self.selGridDetail = nil
  if self.selRoleDetail ~= nil then
    self.selRoleDetail:OnRelease()
  end
  self.selRoleDetail = nil
  if self.activityTourTips ~= nil then
    self.activityTourTips:OnRelease()
  end
  self.activityTourTips = nil
  self.currencyTimer = nil
  if self.pointsTween ~= nil then
    LuaDOTweenUtils.Kill(self.pointsTween, false)
  end
  self.pointsTween = nil
  if self.randomPoint ~= nil then
    self.randomPoint:OnRelease()
  end
  self.randomPoint = nil
end
function ActivityTourMainPanel:ShowCommandAnimator(isShowCommand)
  if isShowCommand then
    setactive(self.ui.mTrans_CommandInfoRoot, true)
    setactive(self.ui.mAnim_Line01, false)
    setactive(self.ui.mAnim_Line01, true)
  end
  ActivityTourGlobal.ReplaceAllColor(self.ui.mTrans_CommandInfoRoot)
  if self.mUICharInfo.mShowChar then
    self.mUICharInfo:FadeInOut(not isShowCommand)
  end
  self.ui.mCVG_CharInfoRoot.blocksRaycasts = not isShowCommand
  UIUtils.AnimatorFadeInOut(self.ui.mAnimator_Command, isShowCommand)
  self.ui.mCG_CommandInfo.blocksRaycasts = isShowCommand
  UIUtils.AnimatorFadeInOut(self.ui.mAnimator_Top, not isShowCommand)
  if not isShowCommand then
    self.ui.mAnimator_Top:ResetTrigger("GrpAvatarStepList_FadeOut")
    self.ui.mAnimator_Top:SetTrigger("GrpAvatarStepList_FadeIn")
  else
    self.ui.mAnimator_Top:ResetTrigger("GrpAvatarStepList_FadeIn")
    self.ui.mAnimator_Top:SetTrigger("GrpAvatarStepList_FadeOut")
  end
  UIUtils.AnimatorFadeInOut(self.ui.mAnimator_CharOpen, not isShowCommand)
  self.mUITaskInfo:Show(not isShowCommand)
  self.mUIActionTimeLine:FadeInOut(not isShowCommand)
end
function ActivityTourMainPanel:OnShowSelectDetail(msg)
  if not (msg and msg.Sender) or not msg.Content then
    return
  end
  local type = msg.Sender
  local id = msg.Content
  self:ShowSelectGridDetail(id)
  self:ShowSelectRoleDetail(id)
end
function ActivityTourMainPanel:OnShowActivityTourMainPanel(msg)
  local isAnim = true
  if msg.Sender ~= nil then
    isAnim = msg.Sender
  end
  setactive(self.ui.mTrans_Root, true)
  self.mUITaskInfo:RefreshAll()
  self.mUICharInfo:RefreshAll()
  self.mUIActionTimeLine:Reset(true, false)
  self.mUIActivityTourCommand:RefreshAllCommand(isAnim)
  self.mUIActivityTourCommand:HideCommandInfo()
  setactive(self.ui.mTrans_CommandInfoRoot, false)
end
function ActivityTourMainPanel:OnHideActivityTourMainPanel(msg)
  setactive(self.ui.mTrans_Root, false)
end
function ActivityTourMainPanel:OnBlockActivityTourMainPanel(msg)
  self.ui.mCG_Root.blocksRaycasts = false
  self.ui.mCVG_CommandInfo.blocksRaycasts = false
end
function ActivityTourMainPanel:OnCancelBlockActivityTourMainPanel(msg)
  self.ui.mCG_Root.blocksRaycasts = true
  self.ui.mCVG_CommandInfo.blocksRaycasts = true
end
function ActivityTourMainPanel:OnHideSelectDetail(msg)
  self:ShowSelectGridDetail(0)
  self:ShowSelectRoleDetail(0)
end
function ActivityTourMainPanel:ShowSelectGridDetail(gridId)
  if not MonopolySelectManager:IfShowGridDetail() or gridId <= 0 then
    setactive(self.ui.mTrans_GridDetail.gameObject, false)
    return
  end
  setactive(self.ui.mTrans_GridDetail.gameObject, true)
  if not self.selGridDetail then
    self.selGridDetail = ActivityTourGridDetailItem.New()
    self.selGridDetail:InitCtrl(self.ui.mTrans_GridDetail.transform)
  else
  end
  self.selGridDetail:Refresh(gridId)
end
function ActivityTourMainPanel:ShowSelectRoleDetail(gridId)
  if not MonopolySelectManager:IfShowActorDetail() or gridId <= 0 then
    setactive(self.ui.mTrans_SelInfo.gameObject, false)
    return
  end
  local role = MonopolyWorld:GetActorByGridID(gridId)
  if not role then
    setactive(self.ui.mTrans_SelInfo.gameObject, false)
    return
  end
  self:ShowSelectRoleDetailInternal(role.id)
end
function ActivityTourMainPanel:ShowSelectRoleDetailInternal(roleId)
  setactive(self.ui.mTrans_SelInfo.gameObject, true)
  if not self.selRoleDetail then
    self.selRoleDetail = ActivityTourInfoItem.New()
    self.selRoleDetail:InitCtrl(self.ui.mTrans_SelInfo.transform)
  else
  end
  self.selRoleDetail:Refresh(roleId)
end
function ActivityTourMainPanel:RefreshAndResetPoints(msg)
  self:RefreshPoints()
end
function ActivityTourMainPanel:OnShowPointTip(msg)
  self:RefreshPointsAni(msg)
end
function ActivityTourMainPanel:RefreshPoints()
  self:ResetPointsTimer()
  self.currency = MonopolyWorld.MpData.Points
  self.ui.mText_Currency.text = self.currency
end
function ActivityTourMainPanel:RefreshPointsAfterAni(newPoints, msg)
  self.currency = newPoints
  self.ui.mText_Currency.text = self.currency
  if msg.Content then
    msg.Content()
  end
end
function ActivityTourMainPanel:ResetPointsTimer()
  if self.currencyTimer then
    self.currencyTimer:Stop()
  end
  if self.pointsTween then
    LuaDOTweenUtils.Kill(self.pointsTween, false)
  end
end
function ActivityTourMainPanel:RefreshPointsAni(msg)
  self:ResetPointsTimer()
  self:RefreshPointsAniInternal(msg)
end
function ActivityTourMainPanel:RefreshPointsAniInternal(msg)
  local getter = function(tempSelf)
    return tempSelf.currency
  end
  local setter = function(tempSelf, value)
    tempSelf.ui.mText_Currency.text = math.floor(value)
  end
  local newPoints = self.currency + msg.Sender
  newPoints = math.max(newPoints, 0)
  self.pointsTween = LuaDOTweenUtils.ToOfFloat(self, getter, setter, newPoints, 0.5, function()
    self:RefreshPointsAfterAni(newPoints, msg)
  end)
end
function ActivityTourMainPanel:OnShowInspirationTip(msg)
  if not self.activityTourTips then
    self.activityTourTips = ActivityTourTips.New()
    self.activityTourTips:InitCtrl(self.mUIRoot.parent)
  end
  self.activityTourTips:RefreshInspiration(msg)
end
function ActivityTourMainPanel:OnShowRandomPoint(msg)
  if not self.randomPoint then
    self.randomPoint = ActivityTourPointRandomItem.New()
    self.randomPoint:InitCtrl(self.ui.mTrans_PointRandom)
  end
  local routeInfo = msg.Sender
  local config = TableDataBase.listMonopolyOrderDatas:GetDataById(routeInfo.InstructionId)
  if not config then
    return
  end
  local minPoint = 0
  local maxPoint = 0
  local showResult = false
  if config.order_type == ActivityTourGlobal.CommandType_ManualMovePoint then
    minPoint = config.section[0]
    maxPoint = config.section[1]
    showResult = true
  elseif config.section.Count == 1 then
    minPoint = config.section[0]
    maxPoint = minPoint
    showResult = true
  else
    minPoint = config.section[0]
    maxPoint = config.section[1]
    showResult = minPoint == maxPoint
  end
  if not (minPoint and maxPoint) or minPoint > maxPoint or minPoint < 1 then
    return
  end
  setactive(self.randomPoint:GetRoot(), true)
  self.randomPoint:Refresh(minPoint, maxPoint, routeInfo.MovePoints, routeInfo.BuffTrigger, showResult)
end
function ActivityTourMainPanel:OnBtnMapInfo()
  local stageData = NetCmdThemeData:GetLevelStageData(MonopolyWorld.MpData.levelData.id)
  UIManager.OpenUIByParam(UIDef.ActivityTourMapInfoDialog, {openIndex = 2, levelStageData = stageData})
end
function ActivityTourMainPanel:OnFleetComplete()
  self:InitAll()
end
function ActivityTourMainPanel:OnRefreshCommand(msg)
  local slotIndex = msg.Sender
  if self.mUIActivityTourCommand then
    self.mUIActivityTourCommand:RefreshCommand(slotIndex)
  end
end
function ActivityTourMainPanel:MoveNextActionTimeLine(msg)
  self.mUIActionTimeLine:MoveNext()
end
function ActivityTourMainPanel:ResetActionTimeLine(msg)
  local isSaveIndex = msg.Sender
  local isInsertNull = msg.Content
  if msg.Sender == nil then
    isSaveIndex = false
  end
  if msg.Content == nil then
    isInsertNull = false
  end
  self.mUIActionTimeLine:Reset(isSaveIndex, isInsertNull)
end
function ActivityTourMainPanel:HideActionTimeLine(msg)
  self.mUIActionTimeLine:Hide()
end
function ActivityTourMainPanel:OnRefreshRoundCount(msg)
  self.mUITaskInfo:RefreshRoundInfo()
end
function ActivityTourMainPanel:OnUpdateTaskProgress(msg)
  local taskID = msg.Sender
  self.mUITaskInfo:RefreshWinTaskList(taskID)
  self.mUITaskInfo:RefreshFailedTaskList(taskID)
end
function ActivityTourMainPanel:OnTeamPropChange(msg)
  self.mUICharInfo:RefreshPropChange()
end
function ActivityTourMainPanel:RefreshActorMainPanelState(msg)
  local actor = msg.Sender
  if actor == nil then
    return
  end
  local isMainPlayer = actor.actorType == CS.GF2.Monopoly.MonopolyActorDefine.ActorType.MainPlayer
  if not isMainPlayer then
    self:OnBlockActivityTourMainPanel()
  end
  setactive(self.ui.mScrollListChild_Command, isMainPlayer)
  if self.mUICharInfo.mShowChar then
    self.mUICharInfo:FadeInOut(isMainPlayer)
  end
  self.ui.mCVG_CharInfoRoot.blocksRaycasts = isMainPlayer
  UIUtils.AnimatorFadeInOut(self.ui.mAnimator_Top, isMainPlayer)
  UIUtils.AnimatorFadeInOut(self.ui.mAnimator_CharOpen, isMainPlayer)
end
function ActivityTourMainPanel:EnterSelectDirectionGrid(msg)
  self:OnCancelBlockActivityTourMainPanel()
  self.ui.mCVG_CommandInfo.blocksRaycasts = false
end
function ActivityTourMainPanel:LeaveSelectDirectionGrid(msg)
  self:OnBlockActivityTourMainPanel()
end
function ActivityTourMainPanel:IsReadyToStartTutorial()
  return MonopolyWorld:IsInTheRoundState()
end
