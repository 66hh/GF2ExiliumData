require("UI.SimCombatPanel.ResourcesCombat.UISimCombatResourcePanelBase")
UISimCombatWeaponExpPanel = class("UISimCombatWeaponExpPanel", UISimCombatResourcePanelBase)
function UISimCombatWeaponExpPanel:OnInit(root, data, behaviourId)
  self.simEntranceId = StageType.WeaponExpStage.value__
  self.super.OnInit(self, root, data, behaviourId)
end
