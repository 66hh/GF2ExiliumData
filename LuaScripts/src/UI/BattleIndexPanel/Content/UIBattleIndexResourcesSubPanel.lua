UIBattleIndexResourcesSubPanel = class("UIBattleIndexResourcesSubPanel", UIBaseView)
UIBattleIndexResourcesSubPanel.numStr = {
  "987.19054.30",
  "554.26543.25",
  "715.32467.64",
  "428.49359.96",
  "038.80383.73",
  "124.61712.62"
}
function UIBattleIndexResourcesSubPanel:InitCtrl(root, parentPanel)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root)
  self.parentPanel = parentPanel
  function self.ui.mVirtualList.itemRenderer(...)
    self:itemRenderer(...)
  end
  function self.ui.mVirtualList.itemProvider()
    return self:itemProvider()
  end
end
function UIBattleIndexResourcesSubPanel:OnShow()
  self:Refresh()
end
function UIBattleIndexResourcesSubPanel:OnBackFrom()
  self:Refresh()
end
function UIBattleIndexResourcesSubPanel:Refresh()
  self.cardDataList = self:getCardDataList()
  if not self.cardDataList or self.cardDataList.Count == 0 then
    return
  end
  self.ui.mVirtualList.numItems = self.cardDataList.Count
  self.ui.mVirtualList:Refresh()
end
function UIBattleIndexResourcesSubPanel:OnRelease()
  self.ui = nil
  self.parentPanel = nil
  self.cardDataList = nil
end
function UIBattleIndexResourcesSubPanel:getCardDataList()
  local simCombatEntranceDataList = TableData.GetStageIndexSimResourcesList()
  if not simCombatEntranceDataList then
    return
  end
  return simCombatEntranceDataList
end
function UIBattleIndexResourcesSubPanel:itemProvider()
  local card = UIBattleIndexResourcesCard.New()
  card:InitCtrl(self.ui.mScrollElement_Card.transform, self.ui.mScrollElement_Card.childItem)
  local renderDataItem = RenderDataItem()
  renderDataItem.renderItem = card:GetRoot().gameObject
  renderDataItem.data = card
  return renderDataItem
end
function UIBattleIndexResourcesSubPanel:itemRenderer(index, renderData)
  local slotData = self.cardDataList[index]
  local card = renderData.data
  card:SetData(slotData, index + 1)
  card:SetNumShow(self.numStr[index + 1])
  card:Refresh()
  card:AddClickListener(function(tempSimCombatEntranceData)
    self:onClickCard(tempSimCombatEntranceData)
  end)
end
function UIBattleIndexResourcesSubPanel:onClickCard(simCombatEntranceData)
  if TipsManager.NeedLockTips(simCombatEntranceData.unlock) then
    return
  end
  self:openSimCombatUI(simCombatEntranceData.id)
end
function UIBattleIndexResourcesSubPanel:openSimCombatUI(simId)
  if simId == StageType.CashStage.value__ then
    UIManager.OpenUIByParam(UIDef.UISimCombatGoldPanel, simId)
  elseif simId == StageType.ExpStage.value__ then
    UIManager.OpenUIByParam(UIDef.UISimCombatGunExpPanel, simId)
  elseif simId == StageType.WeaponExpStage.value__ then
    UIManager.OpenUIByParam(UIDef.UISimCombatWeaponExpPanel, simId)
  elseif simId == StageType.DailyStage.value__ then
    UIManager.OpenUIByParam(UIDef.UISimCombatDailyPanel, simId)
  elseif simId == StageType.WeaponModStage.value__ then
    UIManager.OpenUIByParam(UIDef.UISimCombatWeaponModPanel, simId)
  end
end
