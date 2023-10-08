UIDarkBubbleMsgSlot = class("UIDarkBubbleMsgSlot", UIBaseCtrl)
function UIDarkBubbleMsgSlot:ctor()
end
function UIDarkBubbleMsgSlot:SetRoot(root)
  self.ui = UIUtils.GetUIBindTable(root)
  self.super.SetRoot(self, root)
end
function UIDarkBubbleMsgSlot:SetData(text, time)
  self.text = text
  self.time = time
end
function UIDarkBubbleMsgSlot:Show()
  self.ui.mText_Content.text = self.text
  local time = self.time
  TimerSys:DelayCall(time, function(data)
    self:StartHide()
  end)
  setactivewithcheck(self:GetRoot(), true)
end
function UIDarkBubbleMsgSlot:StartHide()
  local time = LuaUtils.GetAnimationClipLength(self.ui.mAnimator, "FadeOut")
  TimerSys:DelayCall(time, function(data)
    self:FinishHide()
  end)
end
function UIDarkBubbleMsgSlot:FinishHide()
  setactivewithcheck(self:GetRoot(), false)
  if self.onHideEndCallback then
    self.onHideEndCallback(self)
  end
end
function UIDarkBubbleMsgSlot:SetIndex(index)
  self.index = index
end
function UIDarkBubbleMsgSlot:GetIndex()
  return self.index
end
function UIDarkBubbleMsgSlot:AddHideEndListener(callback)
  self.onHideEndCallback = callback
end
function UIDarkBubbleMsgSlot:Release()
  self.text = nil
  self.ui = nil
end
