require("UI.UIBaseCtrl")
require("UI.SimCombatPanelV2.SimCombatMythicConfig")
UISimCombatMythicStageLevelDotItem = class("UISimCombatMythicStageLevelDetailItem", UIBaseCtrl)
local self = UISimCombatMythicStageLevelDotItem
function UISimCombatMythicStageLevelDotItem:ctor()
end
function UISimCombatMythicStageLevelDotItem:__InitCtrl()
  self.mTrans_State_UnComplete = self:GetRectTransform("ImgUnComplete")
  self.mTrans_State_Complete = self:GetRectTransform("ImgComplete")
  self.mTrans_State_Complete_Shadow = self:GetRectTransform("ImgComplete/ImShadow")
  self.mTrans_State_Complete_Image = self:GetRectTransform("ImgComplete/ImgComplete")
  self.mTrans_Slc = self:GetRectTransform("ImgNow")
  self.mTrans_Dot = self:GetRectTransform("ImgDot")
  self.mAnimator = self:GetSelfAnimator()
  self.mAnimator:SetBool("Uncomplete", true)
end
function UISimCombatMythicStageLevelDotItem:InitCtrl(transform)
  self:SetRoot(transform)
  self:__InitCtrl()
end
function UISimCombatMythicStageLevelDotItem:SetState(state, playFinishAnim)
  if state == 1 then
    setactive(self.mTrans_State_UnComplete.gameObject, true)
    setactive(self.mTrans_State_Complete.gameObject, true)
    setactive(self.mTrans_Slc.gameObject, false)
  elseif state == 2 then
    setactive(self.mTrans_State_UnComplete.gameObject, true)
    setactive(self.mTrans_State_Complete.gameObject, false)
    setactive(self.mTrans_Slc.gameObject, true)
  else
    setactive(self.mTrans_State_UnComplete.gameObject, true)
    setactive(self.mTrans_State_Complete.gameObject, false)
    setactive(self.mTrans_Slc.gameObject, false)
  end
end
function UISimCombatMythicStageLevelDotItem:PlayCompleteAnim()
  TimerSys:DelayFrameCall(3, function()
    self.mAnimator:SetBool("Uncomplete", false)
  end)
end
function UISimCombatMythicStageLevelDotItem:OnRelease()
  self:DestroySelf()
end
