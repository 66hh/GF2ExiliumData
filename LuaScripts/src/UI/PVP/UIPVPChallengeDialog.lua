require("UI.PVP.Item.UIPVPChallengeItemV2")
require("UI.UIBasePanel")
UIPVPChallengeDialog = class("UIPVPChallengeDialog", UIBasePanel)
UIPVPChallengeDialog.__index = UIPVPChallengeDialog
local self = UIPVPChallengeDialog
local receveDelayTime = 2
function UIPVPChallengeDialog:ctor(obj)
  UIPVPChallengeDialog.super.ctor(self)
  obj.Type = UIBasePanelType.Dialog
end
function UIPVPChallengeDialog:OnInit(root)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.itemCost = TableData.GlobalSystemData.PvpChallengelistRenewCost
  self.pvpMatchInfo = nil
  self.cdTimer = nil
  self.isRefreshCD = false
  self.refreshBtnTimer = nil
  self.refreshCdNum = 0
  self.refreshText = nil
  self.tmpRefreshTextStr = ""
  self.secondText = TableData.GetHintById(50)
  self.bonusCdTimer = nil
  self.isBonusCd = false
  self.isAllComplete = false
  self.needBonusAnim = false
  self.pvpContinuityTimes = TableData.GlobalSystemData.PvpContinuityTimes
  self.tmpRefreshTextStr = TableData.GetHintById(901057)
  self.uiTemplate = self.ui.mBtn_Refresh.transform:GetComponent(typeof(CS.UITemplate))
  if self.uiTemplate == nil or 0 >= self.uiTemplate.Texts.Length then
    return
  end
  self.refreshText = self.uiTemplate.Texts[0]
end
function UIPVPChallengeDialog:OnShowStart()
  self:RefreshListAnim()
end
function UIPVPChallengeDialog:OnShowFinish()
  self:UpdateListPanel()
  self:CheckCanAutoRefreshMatchList()
  self:UpdateCountDownTime()
  self:SetBonusData()
  self.ui.mAnimator_Root:SetBool("Receive", false)
  self:UpdateBonusAnimation()
end
function UIPVPChallengeDialog:AddBtnOnClick()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIPVPChallengeDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIPVPGlobal.IsOpenPVPChallengeDialog = 0
    UIManager.CloseUI(UIDef.UIPVPChallengeDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Refresh.gameObject).onClick = function()
    self:OnClickRefreshMatchList()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_RewardItem.gameObject).onClick = function()
    self:OnClickReward()
  end
end
function UIPVPChallengeDialog:UpdateListPanel()
  self.pvpMatchInfo = NetCmdPVPData.PvpMatchInfo
  setactive(self.ui.mTrans_GrpRefresh, true)
  local opponentList = NetCmdPVPData.PvpMatchInfo.opponentList
  local tmpTeamContent = self.ui.mScrollListChild_List.transform
  for i = 0, opponentList.Length - 1 do
    local pvpChallengeItemV2, tmpGunAvatarObj
    if i < tmpTeamContent.childCount then
      tmpGunAvatarObj = tmpTeamContent:GetChild(i).gameObject
    end
    local pvpOpponentInfo = opponentList[i]
    pvpChallengeItemV2 = UIPVPChallengeItemV2.New()
    pvpChallengeItemV2:InitCtrl(tmpTeamContent, tmpGunAvatarObj)
    pvpChallengeItemV2:SetData(pvpOpponentInfo, UIPVPGlobal.ButtonType.Challenge, i + 1)
    local tmpAddPoint = UIPVPGlobal.GetChallengeAddPoint(NetCmdPVPData.PvpInfo.level, i + 1)
    pvpChallengeItemV2:SetAddPointText(tmpAddPoint)
  end
  CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(tmpTeamContent)
end
function UIPVPChallengeDialog:RefreshListAnim()
  setactive(self.ui.mGrp_List.gameObject, false)
  setactive(self.ui.mGrp_List.gameObject, true)
end
function UIPVPChallengeDialog:CheckCanAutoRefreshMatchList()
  if self.pvpMatchInfo == nil then
    NetCmdPVPData:ReqRefreshMatch(false, function()
      self:OnRefreshMatchCallBack()
    end)
    return
  end
  self:ReleaseAutoRefreshTime()
  if self.pvpMatchInfo.isAllWin then
    self.isAllComplete = true
    self.autoRefreshTimer = TimerSys:DelayCall(0.5, function()
      NetCmdPVPData:ReqRefreshMatch(false, function()
        self:OnRefreshMatchCallBack()
      end)
    end)
  end
end
function UIPVPChallengeDialog:OnClickRefreshMatchList()
  if self.isRefreshCD then
    return
  end
  local freeTimes = self.pvpMatchInfo.FreeRefreshTimes
  if freeTimes <= 0 then
    local itemData = TableData.listItemDatas:GetDataById(1)
    local hint = string_format(TableData.GetHintById(201), itemData.name.str, self.itemCost)
    local resNum = NetCmdItemData:GetResItemCount(1)
    if resNum < self.itemCost then
      local itemData = TableData.listItemDatas:GetDataById(1)
      if itemData then
        local desc = string_format(TableData.GetHintById(108059), itemData.name.str)
        CS.PopupMessageManager.PopupString(desc)
      end
    else
      local content = MessageContent.New(hint, MessageContent.MessageType.DoubleBtn, function()
        NetCmdPVPData:ReqRefreshMatch(true, function()
          self:OnRefreshMatchCallBack()
        end)
      end)
      MessageBoxPanel.Show(content)
    end
  else
    self:InitOnClickRefreshTimer()
    NetCmdPVPData:ReqRefreshMatch(false, function()
      self:OnRefreshMatchCallBack()
    end)
  end
end
function UIPVPChallengeDialog:RefreshMatchList(itemId, costNum)
  local resNum = NetCmdItemData:GetResItemCount(itemId)
  if costNum > resNum then
    local itemData = TableData.listItemDatas:GetDataById(itemId)
    if itemData then
      hint = string_format(TableData.GetHintById(108059), itemData.name.str)
      CS.PopupMessageManager.PopupString(hint)
    end
    return
  else
    NetCmdPVPData:ReqRefreshMatch(true, function()
      self:OnRefreshMatchCallBack()
    end)
  end
end
function UIPVPChallengeDialog:OnRefreshMatchCallBack()
  self.pvpMatchInfo = NetCmdPVPData.PvpMatchInfo
  if self.isAllComplete then
    CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(120059))
  else
    CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(901060))
  end
  self.isAllComplete = false
  self:RefreshListAnim()
  self:UpdateListPanel()
  self:UpdateCountDownTime()
end
function UIPVPChallengeDialog:UpdateCountDownTime()
  self:ReleaseTimer()
  local updateRefresh = function(refreshState)
    if refreshState == UIPVPGlobal.RefreshState.AllFree then
      setactive(self.ui.mText_FreeTimes.gameObject, true)
      setactive(self.ui.mTrans_GrpCostNum, false)
      setactive(self.ui.mText_Time.gameObject, false)
    elseif refreshState == UIPVPGlobal.RefreshState.HasFree then
      setactive(self.ui.mText_FreeTimes.gameObject, true)
      setactive(self.ui.mTrans_GrpCostNum, false)
      setactive(self.ui.mText_Time.gameObject, true)
    else
      setactive(self.ui.mTrans_GrpCostNum, true)
      setactive(self.ui.mText_FreeTimes.gameObject, false)
      setactive(self.ui.mText_Time.gameObject, true)
    end
    self.ui.mText_FreeTimes.text = string_format("{0} {1}/{2}", TableData.GetHintById(60013), self.pvpMatchInfo.FreeRefreshTimes, TableData.GlobalSystemData.PvpRefreshMaxtimes)
    self.ui.mText_CostNum.text = string_format(UIPVPGlobal.TextCostRich, self.itemCost)
    if NetCmdItemData:GetResItemCount(1) < self.itemCost then
      self.ui.mText_CostNum.color = ColorUtils.RedColor
    else
      self.ui.mText_CostNum.color = ColorUtils.ChellColor
    end
    if refreshState ~= UIPVPGlobal.RefreshState.AllFree then
      local CDCount = self.pvpMatchInfo.nextRefreshTime - CGameTime:GetTimestamp()
      if 0 < CDCount then
        self.ui.mText_Time.text = CS.LuaUIUtils.GetMSTimeBySecond(CDCount) .. TableData.GetHintById(120023)
      else
        self.ui.mText_Time.text = CS.LuaUIUtils.GetMSTimeBySecond(0) .. TableData.GetHintById(120023)
        self.pvpMatchInfo:RefreshTimes()
        self:UpdateCountDownTime()
      end
    end
    self:UpdateRefreshCountDownTime()
  end
  local timerFunc = function()
    local freeTimes = self.pvpMatchInfo.FreeRefreshTimes
    if freeTimes == TableData.GlobalSystemData.PvpRefreshMaxtimes then
      updateRefresh(UIPVPGlobal.RefreshState.AllFree)
      self:ReleaseTimer()
    elseif freeTimes == 0 then
      updateRefresh(UIPVPGlobal.RefreshState.NoFree)
    else
      updateRefresh(UIPVPGlobal.RefreshState.HasFree)
    end
  end
  timerFunc()
  local repeatCount = TableData.GlobalSystemData.PvpRefreshTime
  self.cdTimer = TimerSys:DelayCall(1, function()
    timerFunc()
  end, nil, repeatCount)
end
function UIPVPChallengeDialog:SetBonusData()
  if TableData.GlobalSystemData.PvpContinuityWeeknumber == 0 then
    setactive(self.ui.mTrans_Reward.gameObject, false)
  else
    if NetCmdPVPData.BonusRewardTime >= TableData.GlobalSystemData.PvpContinuityWeeknumber then
      self.ui.mText_Victories.text = TableData.GetHintById(120165)
      setactive(self.ui.mTrans_Finished.gameObject, true)
      UIUtils.GetButton(self.ui.mBtn_RewardItem.transform).enabled = false
      self:AddBtnOnClick()
    else
      self.ui.mText_Victories.text = string_format(TableData.GetHintById(120056), NetCmdPVPData.PvpInfo.bouns, self.pvpContinuityTimes)
      setactive(self.ui.mTrans_Finished.gameObject, false)
      UIUtils.GetButton(self.ui.mBtn_RewardItem.transform).enabled = true
      if NetCmdPVPData.PvpInfo.IsFullBonus or NetCmdPVPData.PvpInfo.bouns >= self.pvpContinuityTimes then
      else
        self:AddBtnOnClick()
      end
    end
    setactive(self.ui.mTrans_Reward.gameObject, true)
  end
end
function UIPVPChallengeDialog.UpdateBonusAnimation()
  if NetCmdPVPData.BonusRewardTime >= TableData.GlobalSystemData.PvpContinuityWeeknumber then
    self.ui.mAnimator_Root:SetBool("Receive", false)
    self:AddBtnOnClick()
    self.ui.mText_Victories.text = TableData.GetHintById(120165)
    setactive(self.ui.mTrans_Finished.gameObject, true)
    setactive(self.ui.mObj_RedPoint.transform.parent.gameObject, false)
  elseif NetCmdPVPData.PvpInfo.IsFullBonus or NetCmdPVPData.PvpInfo.bouns >= self.pvpContinuityTimes then
    NetCmdPVPData:ReqGetBoundsReward()
    self.ui.mAnimator_Root:SetBool("Receive", true)
    self.ui.mText_Victories.text = string_format(TableData.GetHintById(120056), self.pvpContinuityTimes, self.pvpContinuityTimes)
    self.isBonusCd = true
    local tmpTime = CSUIUtils.GetClipLengthByEndsWith(self.ui.mAnimator_Root, "Receive")
    receveDelayTime = 0 < tmpTime and tmpTime or receveDelayTime
    self.bonusCdTimer = TimerSys:DelayCall(receveDelayTime, function()
      self.isBonusCd = false
      self:AddBtnOnClick()
      setactive(self.ui.mTrans_Finished.gameObject, false)
      setactive(self.ui.mObj_RedPoint.transform.parent.gameObject, true)
      UIUtils.GetButton(self.ui.mBtn_RewardItem.transform).enabled = true
      setactive(self.ui.mObj_RedPoint.transform.parent.gameObject, false)
      UICommonReceivePanel.OpenWithCheckPopupDownLeftTips()
    end)
    NetCmdPVPData.PvpInfo.IsFullBonus = false
  else
    self.ui.mAnimator_Root:SetBool("Receive", false)
    self:AddBtnOnClick()
    setactive(self.ui.mTrans_Finished.gameObject, false)
    setactive(self.ui.mObj_RedPoint.transform.parent.gameObject, false)
  end
end
function UIPVPChallengeDialog:OnClickReward()
  UIManager.OpenUIByParam(UIDef.UIPVPWinningStreakAwardDialog, 1)
end
function UIPVPChallengeDialog:InitOnClickRefreshTimer()
  if self.refreshText == nil then
    return
  end
  self.isRefreshCD = true
  self.refreshCdNum = TableData.GlobalSystemData.PvpRefreshMintime
  self.refreshBtnTimer = TimerSys:DelayCall(TableData.GlobalSystemData.PvpRefreshMintime, function()
    self.isRefreshCD = false
    self.refreshCdNum = 0
    self.refreshText.text = self.tmpRefreshTextStr
  end)
end
function UIPVPChallengeDialog:UpdateRefreshCountDownTime()
  if self.uiTemplate == nil or self.uiTemplate.Texts.Length <= 0 or self.refreshText == nil then
    return
  end
  if self.isRefreshCD and 0 <= self.refreshCdNum then
    self.refreshText.text = self.refreshCdNum .. self.secondText
    self.refreshCdNum = self.refreshCdNum - 1
  else
    self.refreshCdNum = 0
    self.refreshText.text = self.tmpRefreshTextStr
  end
end
function UIPVPChallengeDialog:ReleaseTimer()
  if self.cdTimer then
    self.cdTimer:Stop()
    self.cdTimer = nil
  end
end
function UIPVPChallengeDialog:ReleaseRefreshBtnTimer()
  if self.refreshBtnTimer then
    self.refreshBtnTimer:Stop()
    self.refreshBtnTimer = nil
  end
end
function UIPVPChallengeDialog:ReleasebonusCDTimer()
  if self.bonusCdTimer then
    self.bonusCdTimer:Stop()
    self.bonusCdTimer = nil
  end
end
function UIPVPChallengeDialog:ReleaseAutoRefreshTime()
  if self.autoRefreshTimer then
    self.autoRefreshTimer:Stop()
    self.autoRefreshTimer = nil
  end
end
function UIPVPChallengeDialog:OnHide()
  self:ReleaseTimer()
  self:ReleaseRefreshBtnTimer()
  self:ReleasebonusCDTimer()
  self:ReleaseAutoRefreshTime()
end
function UIPVPChallengeDialog:OnClose()
  self:ReleaseTimer()
  self:ReleaseRefreshBtnTimer()
  self:ReleasebonusCDTimer()
  self:ReleaseAutoRefreshTime()
end
function UIPVPChallengeDialog:OnRelease()
  self:ReleaseTimer()
  self:ReleaseRefreshBtnTimer()
  self:ReleasebonusCDTimer()
  self:ReleaseAutoRefreshTime()
end
