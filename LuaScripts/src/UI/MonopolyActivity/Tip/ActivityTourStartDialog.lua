require("UI.UIBasePanel")
require("UI.MonopolyActivity.ActivityTourGlobal")
ActivityTourStartDialog = class("ActivityTourStartDialog", UIBasePanel)
ActivityTourStartDialog.__index = ActivityTourStartDialog
function ActivityTourStartDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function ActivityTourStartDialog:OnInit(root, isNewStart)
  self.super.SetRoot(self, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:UpdateAll(isNewStart)
  ActivityTourGlobal.ReplaceAllColor(self.mUIRoot)
end
function ActivityTourStartDialog:OnFadeInFinish()
  self:DelayCall(1, function()
    self:RegisterEvent()
  end)
end
function ActivityTourStartDialog:RegisterEvent()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:CloseSelf()
  end
end
function ActivityTourStartDialog:UpdateAll(isNewStart)
  self.mIsNewStart = isNewStart
  if isNewStart then
    self.ui.mText_Title.text = UIUtils.GetHintStr(270156)
    self.ui.mText_Desc.text = UIUtils.GetHintStr(270157)
  else
    self.ui.mText_Title.text = UIUtils.GetHintStr(270158)
    self.ui.mText_Desc.text = UIUtils.GetHintStr(270159)
  end
  self.ui.mCanvasGroup_Root.blocksRaycasts = false
  self:DelayCall(2, function()
    self.ui.mCanvasGroup_Root.blocksRaycasts = true
  end)
  self:DelayCall(4, function()
    self:CloseSelf()
  end)
end
function ActivityTourStartDialog:CloseSelf()
  UIManager.CloseUI(UIDef.ActivityTourStartDialog)
end
function ActivityTourStartDialog:OnClose()
  self:ReleaseTimers()
end
