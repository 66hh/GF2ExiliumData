require("UI.UIBasePanel")
UISimCombatMythicUnlockDialog = class("UISimCombatMythicUnlockDialog", UIBasePanel)
UISimCombatMythicUnlockDialog.__index = UISimCombatMythicUnlockDialog
local self = UISimCombatMythicUnlockDialog
function UISimCombatMythicUnlockDialog:ctor(obj)
  UISimCombatMythicUnlockDialog.super.ctor(self, obj)
  obj.Type = UIBasePanelType.Dialog
end
function UISimCombatMythicUnlockDialog:OnInit(root, message)
  self.super.SetRoot(UISimCombatMythicUnlockDialog, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.ui.mText_Lock.text = message
  self.ui.mText_next.text = ""
end
function UISimCombatMythicUnlockDialog:OnShowFinish()
end
function UISimCombatMythicUnlockDialog:OnFadeInFinish()
  TimerSys:DelayFrameCall(2, function()
    self:Close()
  end)
end
function UISimCombatMythicUnlockDialog:Close()
  UIManager.CloseUI(UIDef.UISimCombatMythicUnlockDialog)
end
function UISimCombatMythicUnlockDialog:OnHide()
end
function UISimCombatMythicUnlockDialog:OnClose()
end
