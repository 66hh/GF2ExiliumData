UIFakeLoadingPanel = class("UIFakeLoadingPanel", UIBasePanel)
function UIFakeLoadingPanel:OnAwake(root)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root)
end
function UIFakeLoadingPanel:OnInit(root, data)
end
function UIFakeLoadingPanel:OnShowStart()
  local duration = LuaUtils.GetAnimationClipLength(self.ui.mAnimator, "FadeIn")
  TimerSys:DelayCall(duration, function(data)
    UISystem:CloseUI(self.mCSPanel)
    MessageSys:SendMessage(UIEvent.OnLoadingEnd, nil)
  end)
end
function UIFakeLoadingPanel:OnHide()
end
function UIFakeLoadingPanel:OnClose()
  local topUI = UISystem:GetTopUI(UIGroupType.Default)
  if not topUI then
    return
  end
  if topUI:IsReadyToStartTutorial() then
    MessageSys:SendMessage(GuideEvent.UIShowStart, nil, topUI.UIDefine)
  end
end
function UIFakeLoadingPanel:OnRelease()
  self.ui = nil
  self.super.OnRelease(self)
end
