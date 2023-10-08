require("UI.UIBasePanel")
UIRepositoryDecomposingDialog = class("UIRepositoryDecomposingDialog", UIBasePanel)
UIRepositoryDecomposingDialog.__index = UIRepositoryDecomposingDialog
function UIRepositoryDecomposingDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIRepositoryDecomposingDialog:OnInit(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.closeBack = data
  local length = LuaUtils.GetAnimationClipLengthByAnimation(self.ui.mAnimation, "Ani_RepositoryDecomposingDialog_FadeInOut")
  TimerSys:DelayCall(length, function()
    UIManager.CloseUI(UIDef.UIRepositoryDecomposingDialog)
  end)
end
function UIRepositoryDecomposingDialog:OnClose()
  if self.closeBack then
    self.closeBack()
  end
end
