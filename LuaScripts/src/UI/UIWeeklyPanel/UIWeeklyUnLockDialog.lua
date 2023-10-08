require("UI.UIBasePanel")
UIWeeklyUnLockDialog = class("UIWeeklyUnLockDialog", UIBasePanel)
UIWeeklyUnLockDialog.__index = UIWeeklyUnLockDialog
function UIWeeklyUnLockDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIWeeklyUnLockDialog:OnInit(root, onCloseCallBack)
  self.super.SetRoot(UIWeeklyUnLockDialog, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.mOnCloseCallBack = onCloseCallBack
  self.mData = NetCmdSimulateBattleData:GetSimCombatWeeklyData()
  self:Refresh()
end
function UIWeeklyUnLockDialog:Refresh()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIWeeklyUnLockDialog)
  end
  local currentDegreeData = self.mData.degreeData
  local preDegreeId = self.mData.cycleData.LevelId[self.mData.currentChallengeLevel - 2]
  local preDegreeData = TableDataBase.listWeeklyDegreeDatas:GetDataById(preDegreeId)
  self.ui.mText_Now.text = preDegreeData.name.str
  self.ui.mText_Next.text = currentDegreeData.name.str
  self.mTimer = TimerSys:DelayCall(3, function()
    UIManager.CloseUI(UIDef.UIWeeklyUnLockDialog)
  end)
end
function UIWeeklyUnLockDialog:OnShowStart()
end
function UIWeeklyUnLockDialog:OnClose()
  self.ui = nil
  if self.mTimer ~= nil then
    self.mTimer:Stop()
    self.mTimer = nil
  end
  if self.mOnCloseCallBack then
    self.mOnCloseCallBack(true)
  end
end
