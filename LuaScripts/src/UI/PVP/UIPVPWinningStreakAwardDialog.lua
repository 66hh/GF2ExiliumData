require("UI.UIBasePanel")
require("UI.Common.UICommonItem")
UIPVPWinningStreakAwardDialog = class("UIPVPWinningStreakAwardDialog", UIBasePanel)
UIPVPWinningStreakAwardDialog.__index = UIPVPWinningStreakAwardDialog
local self = UIPVPWinningStreakAwardDialog
function UIPVPWinningStreakAwardDialog:ctor(obj)
  UIPVPWinningStreakAwardDialog.super.ctor(self)
  obj.Type = UIBasePanelType.Dialog
end
function UIPVPWinningStreakAwardDialog:OnInit(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.showRewardType = data
  if self.showRewardType == 1 then
    self.ui.mText_Title.text = TableData.GetHintById(120057)
    local count = math.max(0, TableData.GlobalSystemData.PvpContinuityWeeknumber - NetCmdPVPData.BonusRewardTime)
    if 0 < count then
      self.ui.mText_Content.text = string_format(TableData.GetHintById(120091), count)
    else
      self.ui.mText_Content.text = TableData.GetHintById(120165)
    end
  else
    self.ui.mText_Title.text = TableData.GetHintById(120150)
    local times = CGameTime:GetLastWeek()
    self.ui.mText_Content.text = string_format(TableData.GetHintById(120149), times[0], times[1], UIPVPGlobal.GetLevel(NetCmdPVPData.PvpInfo.level))
  end
  self.rewardItemList = {}
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    if self.showRewardType == 2 then
      NetCmdPVPData:ReqNrtPvpTakeWeekReward(function(ret)
        if ret == ErrorCodeSuc then
          UIManager.CloseUI(UIDef.UIPVPWinningStreakAwardDialog)
          UIManager.OpenUI(UIDef.UICommonReceivePanel)
        end
      end)
    else
      UIManager.CloseUI(UIDef.UIPVPWinningStreakAwardDialog)
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    if self.showRewardType == 2 then
      NetCmdPVPData:ReqNrtPvpTakeWeekReward(function(ret)
        if ret == ErrorCodeSuc then
          UIManager.CloseUI(UIDef.UIPVPWinningStreakAwardDialog)
          UIManager.OpenUI(UIDef.UICommonReceivePanel)
        end
      end)
    else
      UIManager.CloseUI(UIDef.UIPVPWinningStreakAwardDialog)
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    if self.showRewardType == 2 then
      NetCmdPVPData:ReqNrtPvpTakeWeekReward(function(ret)
        if ret == ErrorCodeSuc then
          UIManager.CloseUI(UIDef.UIPVPWinningStreakAwardDialog)
          UIManager.OpenUI(UIDef.UICommonReceivePanel)
        end
      end)
    else
      UIManager.CloseUI(UIDef.UIPVPWinningStreakAwardDialog)
    end
  end
  self:UpdateListPanel()
end
function UIPVPWinningStreakAwardDialog:UpdateListPanel()
  local rewardList = {}
  if self.showRewardType == 1 then
    reward = TableData.GlobalSystemData.PvpContinuityReward
    for i, v in pairs(reward) do
      table.insert(rewardList, {id = i, rewardData = v})
    end
  elseif self.showRewardType == 2 then
    local pvpId = NetCmdPVPData.seasonData.type * 100 + NetCmdPVPData.PvpInfo.level
    local pvpData = TableDataBase.listNrtpvpLevelDatas:GetDataById(pvpId)
    if pvpData then
      for i = 1, pvpData.week_reward.Key.Count do
        table.insert(rewardList, {
          id = pvpData.week_reward.Key[i - 1],
          rewardData = pvpData.week_reward.Value[i - 1]
        })
      end
    end
  end
  table.sort(rewardList, function(a, b)
    return a.id < b.id
  end)
  for i, v in ipairs(rewardList) do
    local item
    if i <= #self.rewardItemList then
      item = self.rewardItemList[i]
    else
      item = UICommonItem.New()
      item:InitCtrl(self.ui.mScrollListChild_Content)
      table.insert(self.rewardItemList, item)
    end
    item:SetItemData(v.id, v.rewardData)
  end
end
function UIPVPWinningStreakAwardDialog:OnClose()
  self:ReleaseCtrlTable(self.rewardItemList, true)
end
