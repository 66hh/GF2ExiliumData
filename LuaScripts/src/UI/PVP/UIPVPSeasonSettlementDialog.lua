require("UI.UIBaseCtrl")
UIPVPSeasonSettlementDialog = class("UIPVPSeasonSettlementDialog", UIBasePanel)
UIPVPSeasonSettlementDialog.__index = UIPVPSeasonSettlementDialog
local self = UIPVPSeasonSettlementDialog
function UIPVPSeasonSettlementDialog:ctor(obj)
  UIPVPSeasonSettlementDialog.super.ctor(self)
  obj.Type = UIBasePanelType.Dialog
end
function UIPVPSeasonSettlementDialog:OnInit(root)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  TimerSys:DelayCall(4, function()
    UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
      self:OnBtnClose()
    end
  end)
  local lastPlan = NetCmdPVPData:GetLastSeasonPlan()
  local openTime = CS.CGameTime.ConvertLongToDateTime(lastPlan.OpenTime):ToString("yyyy.MM.dd")
  local closeTime = CS.CGameTime.ConvertLongToDateTime(lastPlan.CloseTime):ToString("yyyy.MM.dd")
  local openTimeAndCloseTime = string_format(TableData.GetHintById(120157), openTime, closeTime)
  self.ui.mText_Date.text = openTimeAndCloseTime
  local seasonData = TableDataBase.listNrtpvpSeasonDatas:GetDataById(lastPlan.Id)
  if seasonData.season_id == 1 then
    self.seasonType = 1
    self.ui.mText_Tittle.text = TableData.GetHintById(120158)
    self.ui.mText_Date1.text = TableData.GetHintById(120159)
  else
    self.seasonType = 2
    self.ui.mText_Tittle.text = string_format(TableData.GetHintById(120156), seasonData.name)
    self.ui.mText_Date1.text = openTimeAndCloseTime
  end
  local settleLevel = NetCmdPVPData.settleLevel
  if settleLevel == 0 then
    settleLevel = 35
  end
  UIPVPGlobal.GetRankImage(settleLevel, self.ui.mImg_Icon, self.ui.mImg_IconBg)
  UIPVPGlobal.GetRankNumImage(settleLevel, self.ui.mImg_StarNum)
  self.ui.mText_Num.text = NetCmdPVPData.LastPvpInfo.points
  if 0 < NetCmdPVPData.LastPvpInfo.rank and NetCmdPVPData.LastPvpInfo.rank <= 100 then
    self.ui.mText_Num1.text = NetCmdPVPData.LastPvpInfo.rank
  else
    local result = TableData.GetHintById(130006)
    self.ui.mText_Num1.text = result
  end
  self.ui.mText_Num2.text = TableData.GetHintById(120008) .. NetCmdPVPData.LastPvpInfo.seasonAtkWin .. "/" .. NetCmdPVPData.LastPvpInfo.seasonAtkTotal
  self.ui.mText_Num3.text = TableData.GetHintById(120009) .. NetCmdPVPData.LastPvpInfo.seasonDefWin .. "/" .. NetCmdPVPData.LastPvpInfo.seasonDefTotal
end
function UIPVPSeasonSettlementDialog:OnBtnClose()
  UIManager.CloseUI(UIDef.UIPVPSeasonSettlementDialog)
  if UIPVPGlobal.SeasonCallback ~= nil then
    UIPVPGlobal.SeasonCallback()
    UIPVPGlobal.SeasonCallback = nil
  end
  NetCmdPVPData:ReqNrtPvpWeeklySettleAcquire(function()
    if UIPVPGlobal.SeasonCallback ~= nil then
      UIPVPGlobal.SeasonCallback()
      UIPVPGlobal.SeasonCallback = nil
    end
    NetCmdPVPData:ClearBattleSettle()
  end)
  NetCmdPVPData:ReqGetUpgradeReward(NetCmdPVPData.PvpInfo.level, function(ret)
  end)
end
