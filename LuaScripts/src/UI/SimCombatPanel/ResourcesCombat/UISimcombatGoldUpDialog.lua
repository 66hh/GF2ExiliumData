require("UI.UIBasePanel")
UISimcombatGoldUpDialog = class("UISimcombatGoldUpDialog", UIBasePanel)
UISimcombatGoldUpDialog.__index = UISimcombatGoldUpDialog
function UISimcombatGoldUpDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  self.mCSPanel = csPanel
end
function UISimcombatGoldUpDialog:OnInit(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.from = data.from
  self.target = data.target
  self:InitShow()
end
function UISimcombatGoldUpDialog:InitShow()
  self.ui.mImg_RateFrom.sprite = IconUtils.GetSimCombatGoldSprite(self.from)
  self.ui.mImg_RateTarget.sprite = IconUtils.GetSimCombatGoldSprite(self.target)
  local gradeShowDataFrom = TableDataBase.listGradeShowDatas:GetDataById(self.from)
  local gradeShowDataTarget = TableDataBase.listGradeShowDatas:GetDataById(self.target)
  self.ui.mText_RateFrom.text = gradeShowDataFrom.grade_name.str
  self.ui.mText_RateTarget.text = gradeShowDataTarget.grade_name.str
  self.ui.mText_Content.text = TableData.GetHintById(103160)
  TimerSys:DelayCall(2.22, function()
    UIManager.CloseUI(UIDef.UISimcombatGoldUpDialog)
  end)
end
function UISimcombatGoldUpDialog:OnClose()
end
