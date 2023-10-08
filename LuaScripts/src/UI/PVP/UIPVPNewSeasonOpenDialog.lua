require("UI.UIBasePanel")
UIPVPNewSeasonOpenDialog = class("UIPVPNewSeasonOpenDialog", UIBasePanel)
UIPVPNewSeasonOpenDialog.__index = UIPVPNewSeasonOpenDialog
local self = UIPVPNewSeasonOpenDialog
function UIPVPNewSeasonOpenDialog:ctor(obj)
  UIPVPNewSeasonOpenDialog.super.ctor(self)
  obj.Type = UIBasePanelType.Dialog
end
function UIPVPNewSeasonOpenDialog:OnInit(root)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.ui.mBtn_Close.enabled = false
  TimerSys:DelayCall(4, function()
    self.ui.mBtn_Close.enabled = true
    UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
      UIManager.CloseUI(UIDef.UIPVPNewSeasonOpenDialog)
    end
  end)
  self.ui.mText_Tittle.text = NetCmdPVPData.seasonData.name.str
  NetCmdPVPData:SetPvpNewSeasonOpen()
end
