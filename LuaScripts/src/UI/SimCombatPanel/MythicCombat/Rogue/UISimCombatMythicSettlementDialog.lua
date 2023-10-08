require("UI.UIBasePanel")
UISimCombatMythicSettlementDialog = class("UISimCombatMythicSettlementDialog", UIBasePanel)
UISimCombatMythicSettlementDialog.__index = UISimCombatMythicSettlementDialog
local self = UISimCombatMythicSettlementDialog
function UISimCombatMythicSettlementDialog:ctor(obj)
  UISimCombatMythicSettlementDialog.super.ctor(self)
  obj.Type = UIBasePanelType.Dialog
end
function UISimCombatMythicSettlementDialog:OnInit(root, data)
  self.super.SetRoot(UISimCombatMythicSettlementDialog, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.settlementMode = NetCmdSimCombatRogueData.FinishRogueType
  self.rogueLevelCofigData = TableData.listRogueLevelCofigDatas:GetDataById(NetCmdSimCombatRogueData.FinishRogueTier)
  self.nextRogueLevelCofigData = nil
  if NetCmdSimCombatRogueData.FinishRogueTier + 1 <= TableData.listRogueLevelCofigDatas:GetList().Count then
    self.nextRogueLevelCofigData = TableData.listRogueLevelCofigDatas:GetDataById(NetCmdSimCombatRogueData.FinishRogueTier + 1)
  end
  TimerSys:DelayCall(2, function()
    UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
      UIManager.CloseUI(UIDef.UISimCombatMythicSettlementDialog)
    end
  end)
  self.ui.mText_RogueNameNormal.text = self.rogueLevelCofigData.Name
  self.ui.mText_RogueNameChallenge.text = self.rogueLevelCofigData.Name
  self.ui.mText_ChapteTitleNormal.text = self.rogueLevelCofigData.Chapter
  self.ui.mText_ChapteTitleChallenge.text = self.rogueLevelCofigData.Chapter
  if self.settlementMode == UISimCombatRogueGlobal.RogueMode.Normal then
    setactive(self.ui.mTrans_UnlockMode.gameObject, self.nextRogueLevelCofigData ~= nil)
    local unlockStr
    if self.nextRogueLevelCofigData ~= nil then
      unlockStr = self.nextRogueLevelCofigData.Name .. string_format(UISimCombatRogueGlobal.SettlementTextColor.Normal, TableData.GetHintById(111003))
    end
    self.ui.mText_NormalUnlockText.text = unlockStr
  end
end
function UISimCombatMythicSettlementDialog:OnShowStart()
  self.ui.mAnimator_Root:SetInteger("Switch", 0)
end
function UISimCombatMythicSettlementDialog:OnHide()
  self.isHide = true
end
function UISimCombatMythicSettlementDialog:OnClose()
  NetCmdSimCombatRogueData.FinishRogueTier = 0
end
