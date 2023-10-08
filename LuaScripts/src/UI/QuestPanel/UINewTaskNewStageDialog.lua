require("UI.UIBasePanel")
UINewTaskNewStageDialog = class("UINewTaskNewStageDialog", UIBasePanel)
UINewTaskNewStageDialog.__index = UINewTaskNewStageDialog
function UINewTaskNewStageDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UINewTaskNewStageDialog:OnInit(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.data = data
end
function UINewTaskNewStageDialog:OnShowFinish()
  self.ui.mAnimator_Stage:SetInteger("Number", self.data)
  TimerSys:DelayCall(3.33, function()
    UIManager.CloseUI(UIDef.UINewTaskNewStageDialog)
  end)
end
