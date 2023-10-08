require("UI.SimCombatPanel.ResourcesCombat.UISimCombatResourcePanelBase")
UISimCombatGoldPanel = class("UISimCombatGoldPanel", UISimCombatResourcePanelBase)
function UISimCombatGoldPanel:OnInit(root, data, behaviourId)
  self.simEntranceId = StageType.CashStage.value__
  self.super.OnInit(self, root, data, behaviourId)
end
