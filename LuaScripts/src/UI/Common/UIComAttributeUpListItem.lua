UIComAttributeUpListItem = class("UIComAttributeUpListItem", UIBaseCtrl)
function UIComAttributeUpListItem:Init(parent)
  local go = UIUtils.Instantiate(self, "UICommonFramework/ComAttributeUpListItem.prefab", parent)
  self:InitByInstance(go)
end
function UIComAttributeUpListItem:InitByTemplate(parent, template)
  local go = UIUtils.InstantiateByTemplate(template, parent)
  self:InitByInstance(go)
end
function UIComAttributeUpListItem:InitByInstance(go)
  self.ui = UIUtils.GetUIBindTable(go)
  self:SetRoot(go.transform)
  self.animator = self:GetSelfAnimator()
  setactive(self.ui.mText_Num, false)
  setactive(self.ui.mTrans_GrpNumRight, false)
  setactive(self.ui.mTrans_IconRoot, false)
  self.curValue = -1
end
function UIComAttributeUpListItem:ShowDiff(name, nowValue, afterValue)
  setactive(self.ui.mText_Num, false)
  setactive(self.ui.mTrans_GrpNumRight, true)
  self.ui.mLayoutElement_GrpList.minWidth = 0
  self.ui.mText_Name.text = name
  self.ui.mText_NumNow.text = nowValue
  self.ui.mText_NumAfter.text = afterValue
end
function UIComAttributeUpListItem:ShowNow(name, nowValue)
  setactive(self.ui.mTrans_GrpNumRight, false)
  setactive(self.ui.mText_Num, true)
  self.ui.mText_Name.text = name
  self.ui.mText_Num.text = nowValue
  if self.curValue ~= -1 then
  end
  self.curValue = nowValue
end
function UIComAttributeUpListItem:ResetState()
  self.animator.enabled = false
  setactive(self.ui.mTrans_FxRoot, false)
  self.animator.enabled = true
end
function UIComAttributeUpListItem:SetIconVisible(visible)
  setactive(self.ui.mTrans_IconRoot, visible)
end
function UIComAttributeUpListItem:SetName(name)
  self.ui.mText_Name.text = name
end
function UIComAttributeUpListItem:SetIconSprite(path)
  self.ui.mImage_Icon.sprite = IconUtils.GetAttributeIcon(path)
end
function UIComAttributeUpListItem:ResetCurValue()
  self.curValue = -1
end
function UIComAttributeUpListItem:PlayLevelUpAnim(delay)
  if not self.animator then
    return
  end
  if 0 < delay then
    self.timer = TimerSys:DelayCall(delay, function()
      self.animator:SetTrigger("Trigger")
    end)
  else
    TimerSys:DelayFrameCall(1, function()
      self.animator:SetTrigger("Trigger")
    end)
  end
end
function UIComAttributeUpListItem:SetVisible(visible)
  self:SetActive(visible)
end
function UIComAttributeUpListItem:OnRelease()
  if self.timer then
    self.timer:Abort()
  end
  self.timer = nil
  self.curValue = nil
  self.animator = nil
  self.ui = nil
  self.super.OnRelease(self)
end
