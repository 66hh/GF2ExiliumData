require("UI.DarkZonePanel.UIDarkZoneSeasonQuestPanel.UIDarkZoneSeasonRewardDialogView")
require("UI.Common.UICommonItem")
require("UI.UIBasePanel")
UIDarkZoneSeasonRewardDialog = class("UIDarkZoneSeasonRewardDialog", UIBasePanel)
UIDarkZoneSeasonRewardDialog.__index = UIDarkZoneSeasonRewardDialog
function UIDarkZoneSeasonRewardDialog:ctor(csPanel)
  UIDarkZoneSeasonRewardDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneSeasonRewardDialog:OnInit(root, data)
  UIDarkZoneSeasonRewardDialog.super.SetRoot(UIDarkZoneSeasonRewardDialog, root)
  self:InitBaseData(root)
  self.planID = data
  self:AddBtnListen()
  self:AddMsgListener()
  self:InitUI()
end
function UIDarkZoneSeasonRewardDialog:InitBaseData(root)
  self.mView = UIDarkZoneSeasonRewardDialogView.New()
  self.ui = {}
  self.mView:InitCtrl(root, self.ui)
  self.rewardItemList = {}
end
function UIDarkZoneSeasonRewardDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIDarkZoneSeasonRewardDialog)
  end
end
function UIDarkZoneSeasonRewardDialog:AddMsgListener()
end
function UIDarkZoneSeasonRewardDialog:InitUI()
  if self.planID > 0 then
    local planData = TableData.listPlanDatas:GetDataById(self.planID)
    local openTime = CS.CGameTime.ConvertLongToDateTime(planData.open_time):ToString("yyyy/MM/dd")
    local closeTime = CS.CGameTime.ConvertLongToDateTime(planData.close_time):ToString("yyyy/MM/dd")
    self.ui.mText_RewardTime.text = openTime .. "-" .. closeTime
    if 0 < planData.args.Count then
      local seasonId = planData.args[0]
      self.seasonData = TableData.listDarkzoneSeasonDatas:GetDataById(seasonId)
      self.ui.mText_RewardTitle.text = self.seasonData.name.str
    end
  end
end
function UIDarkZoneSeasonRewardDialog:OnShowStart()
  local dList = NetCmdDarkZoneSeasonData.finishQuestList
  self.rewardDataList = {}
  for i = 0, dList.Count - 1 do
    local id = dList[i]
    local td = TableData.listDarkzoneSeasonQuestDatas:GetDataById(id)
    for id, v in pairs(td.reward_list) do
      if self.rewardDataList[id] == nil then
        self.rewardDataList[id] = 0
      end
      self.rewardDataList[id] = self.rewardDataList[id] + v
    end
  end
  for i = 1, #self.rewardItemList do
    self.rewardItemList[i]:SetActive(false)
  end
  local index = 1
  for i, v in pairs(self.rewardDataList) do
    if self.rewardItemList[index] == nil then
      self.rewardItemList[index] = UICommonItem.New()
      self.rewardItemList[index]:InitCtrl(self.ui.mTrans_ItemList)
    end
    self.rewardItemList[index]:SetItemData(i, v)
    index = index + 1
  end
end
function UIDarkZoneSeasonRewardDialog:OnClose()
  self:ReleaseCtrlTable(self.rewardItemList, true)
  self.rewardItemList = nil
  self.ui = nil
  self.mView = nil
  UIManager.OpenUI(UIDef.UIDarkZoneNewSeasonOpenDialog)
end
