require("UI.UIBasePanel")
UIDarkZoneMakingDialog = class("UIDarkZoneMakingDialog", UIBasePanel)
UIDarkZoneMakingDialog.__index = UIDarkZoneMakingDialog
function UIDarkZoneMakingDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneMakingDialog:OnAwake(root, callback)
  self:SetRoot(root)
  self.ui = {}
  self.callback = callback
  self:LuaUIBindTable(root, self.ui)
end
function UIDarkZoneMakingDialog:OnInit(root)
end
function UIDarkZoneMakingDialog:OnShowStart()
  local length = 0
  if DarkNetCmdMakeTableData.PerfectMake then
    self.ui.mAnimator:Play("PerfectMake_FadeInOut", 0, 0)
    length = LuaUtils.GetAnimationClipLength(self.ui.mAnimator, "PerfectMake_FadeInOut")
  else
    self.ui.mAnimator:Play("NormalMake_FadeInOut", 0, 0)
    length = LuaUtils.GetAnimationClipLength(self.ui.mAnimator, "NormalMake_FadeInOut")
  end
  TimerSys:DelayCall(length - 0.3, function()
    self.ui.mGrabScren:PlayBlurEffect(false)
  end)
  TimerSys:DelayCall(length, function()
    UIManager.CloseUI(UIDef.UIDarkZoneMakingDialog)
    UIManager.OpenUI(UIDef.UICommonReceivePanel)
  end)
end
function UIDarkZoneMakingDialog:OnShowFinish()
end
function UIDarkZoneMakingDialog:OnBackFrom()
end
function UIDarkZoneMakingDialog:OnClose()
  if self.callback then
    self.callback()
  end
end
function UIDarkZoneMakingDialog:OnHide()
end
function UIDarkZoneMakingDialog:OnHideFinish()
end
function UIDarkZoneMakingDialog:OnRelease()
  self.ui = nil
  self.mData = nil
end
function UIDarkZoneMakingDialog:OnRecover()
end
function UIDarkZoneMakingDialog:OnSave()
end
