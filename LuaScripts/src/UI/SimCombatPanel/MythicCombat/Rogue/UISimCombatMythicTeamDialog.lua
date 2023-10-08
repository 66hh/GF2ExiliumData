require("UI.UIBasePanel")
UISimCombatMythicTeamDialog = class("UISimCombatMythicTeamDialog", UIBasePanel)
UISimCombatMythicTeamDialog.__index = UISimCombatMythicTeamDialog
local self = UISimCombatMythicTeamDialog
function UISimCombatMythicTeamDialog:ctor(obj)
  UISimCombatMythicTeamDialog.super.ctor(self)
  obj.Type = UIBasePanelType.Dialog
end
function UISimCombatMythicTeamDialog:OnInit(root, data)
  self.super.SetRoot(UISimCombatMythicTeamDialog, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.curSelBuff = nil
  self.tier = data
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UISimCombatMythicTeamDialog)
  end
  self:SetTeamList()
end
function UISimCombatMythicTeamDialog:OnHide()
  self.isHide = true
end
function UISimCombatMythicTeamDialog:SetTeamList()
  local rogueLevelCofigData = TableData.listRogueLevelCofigDatas:GetDataById(self.tier)
  local curPreGuns = rogueLevelCofigData.ChallengeModeGunsList
  for i = 0, curPreGuns.Count - 1 do
    local item = SimCombatMythicTeamItem.New()
    item:InitCtrl(self.ui.mScrollListChild_List)
    item:SetData(curPreGuns[i])
  end
end
function UISimCombatMythicTeamDialog:OnClose()
  UISimCombatRogueGlobal.ExcuteChallengeFuncList()
end
