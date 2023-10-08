require("UI.UIBasePanel")
UIPVPRankChangeDialog = class("UIPVPRankChangeDialog", UIBasePanel)
UIPVPRankChangeDialog.__index = UIPVPRankChangeDialog
local self = UIPVPRankChangeDialog
function UIPVPRankChangeDialog:ctor(obj)
  UIPVPRankChangeDialog.super.ctor(self)
  obj.Type = UIBasePanelType.Dialog
end
function UIPVPRankChangeDialog:OnInit(root)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  UIUtils.GetButton(self.ui.mBtn_Close.transform).enabled = false
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:OnClickGradeUpClose()
  end
end
function UIPVPRankChangeDialog:OnShowStart()
  UIPVPGlobal.IsOpenPVPRankChangeDialog = true
  local hint1 = TableData.GetHintById(120017)
  local hint2 = TableData.GetHintById(120018)
  local lastLevel = NetCmdPVPData.LastPvpLevel
  local currentLevel = NetCmdPVPData.PvpInfo.level
  UIPVPGlobal.GetRankImage(lastLevel, self.ui.mImg_IconOld, self.ui.mImg_IconBgOld)
  UIPVPGlobal.GetRankNumImage(lastLevel, self.ui.mImg_StarNumOld)
  UIPVPGlobal.GetRankImage(currentLevel, self.ui.mImg_Icon, self.ui.mImg_IconBg)
  UIPVPGlobal.GetRankNumImage(currentLevel, self.ui.mImg_StarNum)
  local currentLevelStr = UIPVPGlobal.GetLevel(currentLevel)
  local isGradeUp = lastLevel < currentLevel
  if isGradeUp then
    self.ui.mAnimator_Root:SetInteger("Level", 0)
    self.ui.mText_RankChange.text = string_format(hint1, currentLevelStr)
  else
    self.ui.mAnimator_Root:SetInteger("Level", 1)
    self.ui.mText_RankChange.text = string_format(hint2, currentLevelStr)
  end
  self:ReleaseAnimatCDTimer()
  local tmpTime = CSUIUtils.GetClipLengthByEndsWith(self.ui.mAnimator_Root, "Level")
  local animatDelayTime = 0 < tmpTime and tmpTime or 3
  self.animatCDTimer = TimerSys:DelayCall(animatDelayTime, function()
    UIUtils.GetButton(self.ui.mBtn_Close.transform).enabled = true
  end)
  local isNewLevel = NetCmdPVPData.HasNewMaxLevel
  setactive(self.ui.mTrans_TextMailTips, isNewLevel)
  setactive(self.ui.mTrans_TextNextTips, not isNewLevel)
  NetCmdPVPData.HasNewMaxLevel = false
end
function UIPVPRankChangeDialog:ReleaseAnimatCDTimer()
  if self.animatCDTimer then
    self.animatCDTimer:Stop()
    self.animatCDTimer = nil
  end
end
function UIPVPRankChangeDialog:OnHide()
  self.isHide = true
  self:ReleaseAnimatCDTimer()
end
function UIPVPRankChangeDialog:OnClickGradeUpClose()
  UIPVPGlobal.IsOpenPVPRankChangeDialog = false
  NetCmdPVPData.PvpLevelChangeFlag = false
  UIManager.CloseUI(UIDef.UIPVPRankChangeDialog)
  MessageSys:SendMessage(CS.GF2.Message.UIEvent.PvpLevelChangePanelClose, nil)
  NetCmdPVPData:SetCurrentLevel(NetCmdPVPData.PvpInfo.level)
  NetCmdPVPData:ReqGetUpgradeReward(NetCmdPVPData.PvpInfo.level, function(ret)
  end)
  if UIPVPGlobal.SeasonCallback ~= nil then
    UIPVPGlobal.SeasonCallback()
    UIPVPGlobal.SeasonCallback = nil
  end
end
