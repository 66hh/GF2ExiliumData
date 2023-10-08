require("UI.UICommonUnlockPanel.UICommonUnlockPanelView")
require("UI.UIBasePanel")
UICommonUnlockPanel = class("UICommonUnlockPanel", UIBasePanel)
UICommonUnlockPanel.__index = UICommonUnlockPanel
UICommonUnlockPanel.callback = nil
function UICommonUnlockPanel.Open(centerPanel, data, callback)
  local param = {}
  param[1] = data
  if callback ~= nil then
    param[2] = callback
  end
  param[3] = centerPanel
  UIManager.OpenUIByParam(UIDef.UICommonUnlockPanel, param)
end
function UICommonUnlockPanel:ctor(csPanel)
  UICommonUnlockPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UICommonUnlockPanel:OnInit(root, data)
  AccountNetCmdHandler.IsLevelUpdate = false
  UICommonUnlockPanel.super.SetPosZ(UICommonUnlockPanel)
  UICommonUnlockPanel.super.SetRoot(UICommonUnlockPanel, root)
  self.mView = UICommonUnlockPanelView.New()
  self.ui = {}
  self.mView:InitCtrl(root, self.ui)
  self.isClosed = false
  if data then
    self.data = data[1]
    self.callback = data[2]
    self.centerPanel = data[3]
  end
  self:UpdatePanel()
end
function UICommonUnlockPanel:OnShowStart()
  self.centerPanel.isHide = true
  if CS.LuaUtils.IsNullOrDestroyed(self.ui.mBtn_Close) == false then
    UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
      self:Close()
    end
    self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Close)
  else
    self:Close()
  end
end
function UICommonUnlockPanel:Close()
  if self.isClosed then
    return
  elseif not self:StopAnimator() then
    self.isClosed = true
    AccountNetCmdHandler:SendReqSystemUnlocks(self.data.id, function()
      UIManager.CloseUI(UIDef.UICommonUnlockPanel)
      if not AccountNetCmdHandler:ContainsUnlockId(self.data.interface_id) and self.data.interface_id ~= UIDef.UICommandCenterPanel then
        gfdebug("AccountNetCmdHandler's temporary list contains NONE of the unlock ids of this interface !!")
        if self.callback then
          self.callback()
        end
      else
        if self.callback then
          self.callback()
        end
        gfdebug("AccountNetCmdHandler's temporary list contains unlock ids of this interface !!")
      end
    end)
  end
end
function UICommonUnlockPanel:OnUpdate()
end
function UICommonUnlockPanel:OnClose()
  if AccountNetCmdHandler.tempUnlockList.Count == 0 then
    self.centerPanel.isHide = false
  end
end
function UICommonUnlockPanel:OnRelease()
  self:UnRegistrationKeyboard(KeyCode.Escape)
end
function UICommonUnlockPanel:UpdatePanel()
  self.ui.mImg_Icon.sprite = IconUtils.GetUnlockIcon(self.data.icon)
  self.ui.mText_Tittle.text = self.data.unlock_name.str
  self.ui.mText_Unlock.text = TableData.GetHintById(901024)
end
function UICommonUnlockPanel:StopAnimator()
  if self.ui.mAnimator then
    local animationState = self.ui.mAnimator:GetCurrentAnimatorStateInfo(0)
    if animationState:IsName("FadeIn") and animationState.normalizedTime < 1 then
      return true
    end
  end
  return false
end
