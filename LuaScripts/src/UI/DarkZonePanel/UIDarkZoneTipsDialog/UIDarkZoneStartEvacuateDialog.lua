require("UI.DarkZonePanel.UIDarkZoneTipsDialog.UIDarkZoneStartEvacuateDialogView")
require("UI.UIBasePanel")
UIDarkZoneStartEvacuateDialog = class("UIDarkZoneStartEvacuateDialog", UIBasePanel)
UIDarkZoneStartEvacuateDialog.__index = UIDarkZoneStartEvacuateDialog
function UIDarkZoneStartEvacuateDialog:ctor(csPanel)
  UIDarkZoneStartEvacuateDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneStartEvacuateDialog:OnInit(root, data)
  UIDarkZoneStartEvacuateDialog.super.SetRoot(UIDarkZoneStartEvacuateDialog, root)
  self.mview = UIDarkZoneStartEvacuateDialogView.New()
  self.ui = {}
  self.mview:InitCtrl(root, self.ui)
  self.timer = nil
  self.intervalTime = 2.18
  self.missionTime = CS.SysMgr.dzMatchGameMgr:GetGameTimeMinute()
  self:InitBaseData()
end
function UIDarkZoneStartEvacuateDialog:OnClose()
  MessageSys:SendMessage(GuideEvent.EnterDarkZoneMainPanelInGame, nil)
  MessageSys:SendMessage(CS.GF2.Message.DarkMsg.DzStartEvacuateDialogShowFinish, nil)
  self.ui = nil
  self.mview = nil
  self.timer = nil
end
function UIDarkZoneStartEvacuateDialog:InitBaseData()
  self.ui.mText_TipsName.text = UIUtils.StringFormat(TableData.GetHintById(903426), self.missionTime)
  self.ui.mText_Tips.text = TableData.GetHintById(903408)
end
function UIDarkZoneStartEvacuateDialog:OnShowStart()
  self.timer = TimerSys:DelayCall(self.intervalTime, function()
    self.timer = nil
    UIManager.CloseUI(UIDef.UIDarkZoneStartEvacuateDialog)
  end)
end
function UIDarkZoneStartEvacuateDialog:OnRelease()
end
