require("UI.UIBasePanel")
require("UI.MonopolyActivity.Settlement.Item.ActivityTourSettlementTaskItem")
require("UI.MonopolyActivity.Settlement.ActivityTourSettlementBase")
require("UI.MonopolyActivity.ActivityTourGlobal")
ActivityTourWinDialog = class("ActivityTourWinDialog", ActivityTourSettlementBase)
ActivityTourWinDialog.__index = ActivityTourWinDialog
function ActivityTourWinDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function ActivityTourWinDialog:OnAwake(root, data)
  self.super.OnAwake(self, root, data)
  self.listExtraReward = {}
end
function ActivityTourWinDialog:OnClose()
  self.super.OnClose(self)
  self:ReleaseCtrlTable(self.listExtraReward, true)
end
function ActivityTourWinDialog:CloseSelf()
  UIManager.CloseUI(UIDef.ActivityTourWinDialog)
end
function ActivityTourWinDialog:RefreshReason()
end
function ActivityTourWinDialog:RefreshInfo()
  self.super.RefreshInfo(self)
  self:RefreshExtraRewardInfo()
end
function ActivityTourWinDialog:RefreshTaskInfo()
  self.super.RefreshTaskInfo(self)
end
function ActivityTourWinDialog:RefreshRewardInfo()
  local config = MonopolyWorld:GetLevelData()
  local listItem = {}
  if config then
    for k, v in pairs(config.RewardItem) do
      table.insert(listItem, {itemId = k, itemNum = v})
    end
  end
  if NetCmdMonopolyData.FirstPass then
    for k, v in pairs(config.FirstRewardItem) do
      local bFind = false
      for i = 1, #listItem do
        if listItem[i].itemId == k then
          listItem[i].itemNum = v + listItem[i].itemNum
          bFind = true
        end
      end
      if not bFind then
        table.insert(listItem, {itemId = k, itemNum = v})
      end
    end
  end
  UIUtils.SortItemTable(listItem)
  setactive(self.ui.mTrans_GrpFirst.gameObject, NetCmdMonopolyData.FirstPass)
  self:RefreshRewardInfoInternal(listItem, self.listReward, self.ui.mTrans_RewardContent)
end
function ActivityTourWinDialog:CloseSelf()
  if SceneSys.CurSceneType == CS.EnumSceneType.Monopoly then
    NetCmdMonopolyData:ReturnToMainPanel()
  else
    UIManager.CloseUI(UIDef.ActivityTourWinDialog)
  end
end
function ActivityTourWinDialog:RefreshExtraRewardInfo()
  local listItem = {}
  for k, v in pairs(NetCmdMonopolyData.BonusItems) do
    table.insert(listItem, {itemId = k, itemNum = v})
  end
  UIUtils.SortItemTable(listItem)
  self:RefreshRewardInfoInternal(listItem, self.listExtraReward, self.ui.mTrans_ExtraRewardContent)
end
function ActivityTourWinDialog:GetTipAnimLength()
  return LuaUtils.GetAnimationClipLength(self.ui.mAnimator_Root, "Ani_ActivityTourWinDialog_GrpTips_FadeInOut")
end
function ActivityTourWinDialog:RefreshChr()
  if MonopolyWorld.IsGmMode then
    local gunId = 1015
    local gunData = TableData.listGunDatas:GetDataById(gunId)
    if gunData then
      self.ui.mImg_Chr.sprite = IconUtils.GetCharacterWholeSprite(gunData.code)
    end
  elseif MonopolyWorld.MpData.configData.UiImage ~= "" then
    self.ui.mImg_Chr.sprite = IconUtils.GetActivityThemeSprite(MonopolyWorld.MpData.configData.UiImage)
  else
    local gunData = TableData.listGunDatas:GetDataById(NetCmdMonopolyData.SettleGunId)
    if gunData then
      self.ui.mImg_Chr.sprite = IconUtils.GetCharacterWholeSprite(gunData.code)
    end
  end
end
