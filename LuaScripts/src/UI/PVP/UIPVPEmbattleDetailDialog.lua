require("UI.UIBasePanel")
require("UI.PVP.UIPVPDefenseTeamDialog")
require("UI.Common.UICommonPlayerAvatarItem")
UIPVPEmbattleDetailDialog = class("UIPVPEmbattleDetailDialog", UIBasePanel)
UIPVPEmbattleDetailDialog.__index = UIPVPEmbattleDetailDialog
local self = UIPVPEmbattleDetailDialog
function UIPVPEmbattleDetailDialog:ctor(obj)
  UIPVPEmbattleDetailDialog.super.ctor(self)
  obj.Type = UIBasePanelType.Dialog
end
function UIPVPEmbattleDetailDialog:OnInit(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.curDetailType = data.detailType
  self.pvpHistoryInfo = nil
  self.pvpOpponentInfo = nil
  self.tmpData = data.tmpData
  self.pvpMapData = nil
  self.curTeam = UIPVPDefenseTeamDialog.TeamType.TeamA
  self.index = data.index
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIPVPEmbattleDetailDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnTeamA.gameObject).onClick = function()
    self.curTeam = UIPVPDefenseTeamDialog.TeamType.TeamA
    self:ChangeDefenseTeam()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnTeamB.gameObject).onClick = function()
    self.curTeam = UIPVPDefenseTeamDialog.TeamType.TeamB
    self:ChangeDefenseTeam()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpStart.gameObject).onClick = function()
    self:StartPVP()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpAuto.gameObject).onClick = function()
    self:StartPVP(true)
  end
  self:SetData(self.tmpData, self.curDetailType)
  NetCmdPVPData:InitPvpDatas()
end
function UIPVPEmbattleDetailDialog:SetData(data, detailType)
  if detailType == UIPVPGlobal.ButtonType.Challenge then
    self.pvpOpponentInfo = data
  elseif detailType == UIPVPGlobal.ButtonType.History then
    self.pvpHistoryInfo = data
    self.pvpOpponentInfo = self.pvpHistoryInfo.opponent
  end
  self.pvpMapData = TableData.listNrtpvpMapDatas:GetDataById(self.pvpOpponentInfo.mapId)
  self.ui.mText_Title.text = self.pvpMapData.MapName
  self.ui.mText_Num2.text = UIPVPGlobal.PvpCostNum
  if self.pvpMapData.map_type == 1 then
    self.ui.mText_NormalType.text = TableData.GetHintById(120126 + self.pvpMapData.map_level)
    self.ui.mText_UPType.text = ""
  else
    self.ui.mText_UPType.text = TableData.GetHintById(120130 + self.pvpMapData.map_level)
    self.ui.mText_NormalType.text = ""
  end
  self:SetOpponentInfo()
  self:ChangeDefenseTeam()
end
function UIPVPEmbattleDetailDialog:SetOpponentInfo()
  self.ui.mText_Rank.text = UIPVPGlobal.GetLevel(self.pvpOpponentInfo.level)
  UIPVPGlobal.GetRankImage(self.pvpOpponentInfo.level, self.ui.mImg_Icon, self.ui.mImg_IconBg)
  UIPVPGlobal.GetRankNumImage(self.pvpOpponentInfo.level, self.ui.mImg_StarNum)
  self.ui.mText_PlayerName.text = self.pvpOpponentInfo.user.Name
  self.ui.mText_ScoreNum.text = self.pvpOpponentInfo.points
  self.ui.mText_EffectNum.text = self.pvpOpponentInfo:GetEffectNum()
  self.playerAvatar = UICommonPlayerAvatarItem.New()
  self.playerAvatar:InitCtrl(self.ui.mScrollListChild_GrpPlayerAvatar.transform)
  if self.pvpOpponentInfo.uid > 0 then
    self.playerAvatar:SetData(TableData.GetPlayerAvatarIconById(self.pvpOpponentInfo.user.Portrait, self.pvpOpponentInfo.user.Sex.value__))
    self.ui.mText_LV.text = string_format(TableData.GetHintById(102250), self.pvpOpponentInfo.user.Level)
  else
    local pvpDummyData = TableData.listPvpDummyDatas:GetDataById(self.pvpOpponentInfo.DummyId)
    local playerAvatarData = TableData.listPlayerAvatarDatas:GetDataById(pvpDummyData.portrait)
    self.playerAvatar:SetData(playerAvatarData.Icon)
    self.ui.mText_LV.text = string_format(TableData.GetHintById(102250), pvpDummyData.level)
  end
  self.playerAvatar:AddBtnListener(function()
    UIManager.OpenUIByParam(UIDef.UIPlayerInfoDialog, {
      AccountNetCmdHandler:GetRoleInfoData()
    })
  end)
  UIUtils.GetButton(self.playerAvatar.ui.mBtn_Avatar.transform).enabled = false
end
function UIPVPEmbattleDetailDialog:SetChallengeData()
  setactive(self.ui.mTrans_Challenge.gameObject, true)
  setactive(self.ui.mTrans_Record.gameObject, false)
  local defendGunList = self.pvpOpponentInfo:GetLineUpDetailByTeam(self.curTeam)
  local hasTeam = self.pvpMapData.BarrierId.Count > 1
  setactive(self.ui.mTrans_HasTeamText.gameObject, hasTeam)
  setactive(self.ui.mTrans_HasTeamSwitch.gameObject, hasTeam)
  self.ui.mText_Text.text = ""
  setactive(self.ui.mScrollListChild_GrpContent.gameObject, false)
  UIPVPGlobal.SetPvpGunCmdDatas(self.ui.mScrollListChild_GrpContent, defendGunList, self.pvpOpponentInfo, UIPVPGlobal.LineUpType.Attack)
  setactive(self.ui.mScrollListChild_GrpContent.gameObject, true)
  setactive(self.ui.mTrans_AddScore.gameObject, false)
  local robotList = self.pvpOpponentInfo:GetRobotIDByTeam(self.curTeam)
end
function UIPVPEmbattleDetailDialog:SetRecordData()
  setactive(self.ui.mTrans_Challenge.gameObject, false)
  setactive(self.ui.mTrans_Record.gameObject, true)
  local hasTeam = self.pvpMapData.BarrierId.Count > 1
  local TeamType = ""
  local teamTypeHint = 0
  if hasTeam then
    teamTypeHint = self.pvpHistoryInfo.LineDouble == 0 and 120037 or 120038
    TeamType = TableData.GetHintById(teamTypeHint)
  end
  local hint1 = TableData.GetHintById(120047)
  local hint2 = TableData.GetHintById(120048)
  local hint3 = TableData.GetHintById(120049)
  local hint4 = TableData.GetHintById(120050)
  if self.pvpHistoryInfo.positive then
    self.ui.mText_AttackTeam.text = string_format(hint2, hint3)
    setactive(self.ui.mTrans_AttackImgG.gameObject, true)
    setactive(self.ui.mTrans_AttackImgR.gameObject, false)
    self.ui.mText_DefenseTeam.text = string_format(hint1, hint4, TeamType)
    setactive(self.ui.mTrans_DefenseImgG.gameObject, false)
    setactive(self.ui.mTrans_DefenseImgR.gameObject, true)
  else
    self.ui.mText_AttackTeam.text = string_format(hint1, hint3, TeamType)
    setactive(self.ui.mTrans_AttackImgG.gameObject, false)
    setactive(self.ui.mTrans_AttackImgR.gameObject, true)
    self.ui.mText_DefenseTeam.text = string_format(hint2, hint4)
    setactive(self.ui.mTrans_DefenseImgG.gameObject, true)
    setactive(self.ui.mTrans_DefenseImgR.gameObject, false)
  end
  UIPVPGlobal.SetPvpGunCmdDatas(self.ui.mScrollListChild_GrpAttack, self.pvpHistoryInfo:GetLineUpDetail(), self.pvpHistoryInfo, UIPVPGlobal.LineUpType.Defend)
  setactive(self.ui.mScrollListChild_GrpDefense.gameObject, false)
  UIPVPGlobal.SetPvpGunCmdDatas(self.ui.mScrollListChild_GrpDefense, self.pvpOpponentInfo:GetLineUpDetailByTeam(self.pvpHistoryInfo.LineDouble), self.pvpOpponentInfo, UIPVPGlobal.LineUpType.Attack)
  setactive(self.ui.mScrollListChild_GrpDefense.gameObject, true)
  UIPVPGlobal.GetResult(self.pvpHistoryInfo, self.ui.mText_Time, self.ui.mText_Score)
  setactive(self.ui.mTrans_Fail.gameObject, not self.pvpHistoryInfo.result)
  setactive(self.ui.mTrans_Win.gameObject, self.pvpHistoryInfo.result)
  setactive(self.ui.mTrans_HasTeamText.gameObject, hasTeam)
  setactive(self.ui.mTrans_HasTeamSwitch.gameObject, hasTeam)
end
function UIPVPEmbattleDetailDialog:IsSetPVPDefend()
  local gunCmdDatas = NetCmdPVPData:GetGunCmdDatasByPvpMapIdWithType(NetCmdPVPData.CurMapId, UIPVPDefenseTeamDialog.TeamType.TeamA)
  if gunCmdDatas == nil or gunCmdDatas.Count == 0 then
    CS.PopupMessageManager.PopupString(TableData.GetHintById(120207))
    return false
  end
  local gunCount = 0
  for i = 1, gunCmdDatas.Count do
    if gunCmdDatas[i - 1] ~= nil then
      gunCount = gunCount + 1
    end
  end
  if gunCount == 0 then
    CS.PopupMessageManager.PopupString(TableData.GetHintById(120207))
    return false
  end
  return true
end
function UIPVPEmbattleDetailDialog:StartPVP(isAutoFight)
  if not self:IsSetPVPDefend() then
    return
  end
  if isAutoFight == nil then
    isAutoFight = false
  end
  local pvpStageParam = CS.PvpStageParam()
  pvpStageParam.PvpOpponentId = self.pvpOpponentInfo.opponentId
  pvpStageParam.PvpOpponentMapId = self.pvpOpponentInfo.mapId
  pvpStageParam.PvpIsAutoFight = isAutoFight
  if GlobalData.GetStaminaResourceItemCount(UIPVPGlobal.NrtPvpTicket) < 1 then
    CS.PopupMessageManager.PopupString(TableData.GetHintById(120211))
    return
  end
  NetCmdPVPData:ReqNrtPvpRandDefend(self.pvpOpponentInfo.opponentId, function(ret)
    if ret == ErrorCodeSuc then
      NetCmdPVPData:OpenBattleSceneForPVP(pvpStageParam)
      UIManager.CloseUI(UIDef.UIPVPEmbattleDetailDialog)
    end
  end)
end
function UIPVPEmbattleDetailDialog:ChangeDefenseTeam()
  if self.curTeam == UIPVPDefenseTeamDialog.TeamType.TeamA then
    self.ui.mBtn_BtnTeamA.interactable = false
    self.ui.mBtn_BtnTeamB.interactable = true
  elseif self.curTeam == UIPVPDefenseTeamDialog.TeamType.TeamB then
    self.ui.mBtn_BtnTeamA.interactable = true
    self.ui.mBtn_BtnTeamB.interactable = false
  end
  if self.curDetailType == UIPVPGlobal.ButtonType.Challenge then
    self:SetChallengeData()
  elseif self.curDetailType == UIPVPGlobal.ButtonType.History then
    self:SetRecordData()
  end
end
function UIPVPEmbattleDetailDialog:OnClose()
  if self.playerAvatar then
    self.playerAvatar:OnRelease()
    self.playerAvatar = nil
  end
end
