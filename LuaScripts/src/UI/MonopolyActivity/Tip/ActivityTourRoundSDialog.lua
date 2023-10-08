require("UI.UIBasePanel")
ActivityTourRoundSDialog = class("ActivityTourRoundSDialog", UIBasePanel)
ActivityTourRoundSDialog.__index = ActivityTourRoundSDialog
function ActivityTourRoundSDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function ActivityTourRoundSDialog:OnInit(root, isEnemyAction)
  self.super.SetRoot(self, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.ui.mAnim_Root.keepAnimatorControllerStateOnDisable = true
  local isMainPlayerAction = not isEnemyAction
  setactive(self.ui.mTrans_Blue1, isMainPlayerAction)
  setactive(self.ui.mTrans_Blue2, isMainPlayerAction)
  setactive(self.ui.mTrans_Red1, not isMainPlayerAction)
  setactive(self.ui.mTrans_Red2, not isMainPlayerAction)
  self.ui.mCVG_Root.alpha = 0
  self:DelayCall(0.1, function()
    self.ui.mCVG_Root.alpha = 1
    if isMainPlayerAction then
      self.ui.mAnim_Root:SetInteger("Color", 1)
    else
      self.ui.mAnim_Root:SetInteger("Color", 0)
    end
    self.ui.mAnim_Root:SetTrigger("FadeInOut")
    self:DelayCall(1.3, function()
      UIManager.CloseUI(UIDef.ActivityTourRoundSDialog)
    end)
  end)
end
function ActivityTourRoundSDialog:OnClose()
  self:ReleaseTimers()
end
