require("UI.DarkZonePanel.UIDarkZoneSeasonQuestPanel.UIDarkZoneNewSeasonOpenDialogView")
require("UI.UIBasePanel")
UIDarkZoneNewSeasonOpenDialog = class("UIDarkZoneNewSeasonOpenDialog", UIBasePanel)
UIDarkZoneNewSeasonOpenDialog.__index = UIDarkZoneNewSeasonOpenDialog
function UIDarkZoneNewSeasonOpenDialog:ctor(csPanel)
  UIDarkZoneNewSeasonOpenDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneNewSeasonOpenDialog:OnInit(root, data)
  UIDarkZoneNewSeasonOpenDialog.super.SetRoot(UIDarkZoneNewSeasonOpenDialog, root)
  self:InitBaseData(root)
  self:AddBtnListen()
  self:AddMsgListener()
  self:InitUI()
end
function UIDarkZoneNewSeasonOpenDialog:InitBaseData(root)
  self.mView = UIDarkZoneNewSeasonOpenDialogView.New()
  self.ui = {}
  self.mView:InitCtrl(root, self.ui)
  function self.CloseFun()
    if self.canClose == true then
      PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. "PlanID", self.planID)
      UIManager.CloseUI(UIDef.UIDarkZoneNewSeasonOpenDialog)
    end
  end
  self.planID = NetCmdRecentActivityData:GetCurDarkZonePlanActivityData()
end
function UIDarkZoneNewSeasonOpenDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = self.CloseFun
end
function UIDarkZoneNewSeasonOpenDialog:AddMsgListener()
end
function UIDarkZoneNewSeasonOpenDialog:InitUI()
  local seasonId = NetCmdDarkZoneSeasonData.SeasonID
  self.seasonData = TableData.listDarkzoneSeasonDatas:GetDataById(seasonId)
  self.ui.mText_Title.text = self.seasonData.name.str
end
function UIDarkZoneNewSeasonOpenDialog:OnShowStart()
  self:DelayCall(2.5, function()
    self.canClose = true
  end)
end
function UIDarkZoneNewSeasonOpenDialog:OnHide()
  PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. "PlanID", self.planID)
end
function UIDarkZoneNewSeasonOpenDialog:OnClose()
  self.CloseFun = nil
  self.ui = nil
  self.mView = nil
  self.canClose = nil
end
