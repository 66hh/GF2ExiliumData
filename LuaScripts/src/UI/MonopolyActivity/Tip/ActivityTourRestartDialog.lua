require("UI.UIBasePanel")
require("UI.MonopolyActivity.ActivityTourGlobal")
ActivityTourRestartDialog = class("ActivityTourRestartDialog", UIBasePanel)
ActivityTourRestartDialog.__index = ActivityTourRestartDialog
function ActivityTourRestartDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function ActivityTourRestartDialog:OnInit(root, callback)
  self.super.SetRoot(self, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  ActivityTourGlobal.ReplaceAllColor(self.mUIRoot)
  self:DelayCall(2.1, function()
    self:CloseSelf()
    if callback then
      callback()
    end
  end)
end
function ActivityTourRestartDialog:CloseSelf()
  UIManager.CloseUI(UIDef.ActivityTourRestartDialog, self.mCSPanel.UIGroupType)
end
