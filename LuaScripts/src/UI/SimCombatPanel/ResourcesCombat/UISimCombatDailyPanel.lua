require("UI.SimCombatPanel.ResourcesCombat.UISimCombatResourcePanelBase")
UISimCombatDailyPanel = class("UISimCombatDailyPanel", UISimCombatResourcePanelBase)
function UISimCombatDailyPanel:OnInit(root, data, behaviourId)
  self.simEntranceId = StageType.DailyStage.value__
  self.super.OnInit(self, root, data, behaviourId)
end
