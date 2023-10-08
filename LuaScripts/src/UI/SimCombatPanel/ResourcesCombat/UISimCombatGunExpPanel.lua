require("UI.SimCombatPanel.ResourcesCombat.UISimCombatResourcePanelBase")
UISimCombatGunExpPanel = class("UISimCombatGunExpPanel", UISimCombatResourcePanelBase)
function UISimCombatGunExpPanel:OnInit(root, data, behaviourId)
  self.simEntranceId = StageType.ExpStage.value__
  self.super.OnInit(self, root, data, behaviourId)
end
