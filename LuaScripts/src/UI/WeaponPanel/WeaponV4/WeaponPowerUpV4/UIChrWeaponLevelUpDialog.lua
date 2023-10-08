require("UI.UIBasePanel")
UIChrWeaponLevelUpDialog = class("UIChrWeaponLevelUpDialog", UIBasePanel)
UIChrWeaponLevelUpDialog.__index = UIChrWeaponLevelUpDialog
function UIChrWeaponLevelUpDialog:ctor(csPanel)
  UIChrWeaponLevelUpDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIChrWeaponLevelUpDialog:OnHide()
  UIChrWeaponLevelUpDialog.attributeList = {}
end
function UIChrWeaponLevelUpDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
end
function UIChrWeaponLevelUpDialog:OnInit(root, param)
  self.param = param
  local length = CSUIUtils.GetClipLengthByEndsWith(self.ui.mAnimator_Root, "FadeIn")
  TimerSys:DelayCall(length, function()
    if self.param.beforeCloseCallback ~= nil then
      self.param.beforeCloseCallback()
    end
    UIManager.CloseUI(UIDef.UIChrWeaponLevelUpDialog)
  end)
end
function UIChrWeaponLevelUpDialog:OnShowStart()
  self.super.SetPosZ(self)
  self:UpdatePanel()
end
function UIChrWeaponLevelUpDialog:UpdatePanel()
  if self.param then
    self.ui.mText_Title.text = self.param.title
  end
end
function UIChrWeaponLevelUpDialog:OnHide()
  if self.param.hideCallback ~= nil then
    self.param.hideCallback()
  end
end
function UIChrWeaponLevelUpDialog:OnClose()
  if self.param.callback ~= nil then
    self.param.callback()
  end
end
