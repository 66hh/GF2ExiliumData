require("UI.UIDef")
UIManager = {}
local this = UIManager
UISystem = CS.UISystem.Instance
UIManager.mUpdateUIs = nil
UIManager.ModelPanel = {
  UIDef.UICharacterWeaponPanel,
  UIDef.UIWeaponPanel,
  UIDef.UICharacterDetailPanel,
  UIDef.UIWeaponPartLvUpSuccPanel
}
function UIManager.Init()
  UIManager.mUpdateUIs = List:New("UpdateUIs")
end
function UIManager.OpenUIByParam(uiType, param, uiGroupType)
  if uiGroupType ~= nil then
    UISystem:OpenUI(uiType, param, 0, uiGroupType)
  else
    UISystem:OpenUI(uiType, param)
  end
end
function UIManager.OpenUI(uiType)
  UISystem:OpenUI(uiType, nil)
end
function UIManager.JumpUI(uiType)
  UISystem:JumpUI(uiType, nil)
end
function UIManager.JumpUIByParam(uiType, param)
  UISystem:JumpUI(uiType, param)
end
function UIManager.CloseUI(uiType)
  UISystem:CloseUI(uiType)
end
function UIManager.CloseUIByGroup(uiType, uiGroupType)
  UISystem:CloseUI(uiType, uiGroupType)
end
function UIManager.CloseUISelf(this)
  UISystem:CloseUI(this.mCSPanel)
end
function UIManager.CloseUISelf2(this)
  UISystem:CloseUI(this.super.mCSPanel)
end
function UIManager.CloseUIByChangeScene(uiType)
  UISystem:CloseUI(uiType)
end
function UIManager.CloseUIByCallback(uiType, callback)
  UISystem:CloseUI(uiType)
end
function UIManager.Set3DUICamera()
  UISystem:Set3DUICamera()
end
function UIManager.ClearUIStacks()
  UISystem:ClearUIStacks()
end
function UIManager.Update()
  for i = 1, UIManager.mUpdateUIs:Count() do
    UIManager.mUpdateUIs[i]:Update()
  end
end
function UIManager.RegisterUpdate(ui)
  if not UIManager.mUpdateUIs:Contains(ui) then
    UIManager.mUpdateUIs:Add(ui)
  end
end
function UIManager.UnregisterUpdate(ui)
  UIManager.mUpdateUIs:Remove(ui)
end
function UIManager.JumpToMainPanel()
  UISystem:JumpToMainPanel()
end
function UIManager.EnableFacilityBarrack(enable)
  UISystem:EnableFacilityBarrack(enable)
end
function UIManager.EnableStore(enable)
  UISystem:EnableStore(enable)
end
function UIManager.EnableDarkZoneTeam(enable)
  UISystem:EnableDarkZoneTeam(enable)
end
function UIManager.EnableLounge(enable)
  UISystem:EnableLounge(enable)
end
function UIManager.EnableBattlePass(enable)
  UISystem:EnableBattlePass(enable)
end
function UIManager.GetResourceBarSortOrder()
  return UISystem:GetResourceBarSortOrder()
end
function UIManager.GetTopPanelSortOrder()
  return UISystem:GetTopPanelSortOrder()
end
function UIManager.ChangeCacheUIData(uiDef, uiParam)
  UISystem:ChangeCacheUIData(uiDef, uiParam)
end
function UIManager.SetCharacterCameraScaleModelId(modelId)
  UISystem:SetCharacterCameraScaleModelId(modelId)
end
function UIManager.GetTopPanelId()
  return UISystem:GetTopPanelUI()
end
function UIManager.IsPanelOpen(uiType)
  return UISystem:PanelIsOpen(uiType)
end
function UIManager.IsModelPanel()
  local id = UIManager.GetTopPanelId()
  for _, panelId in ipairs(UIManager.ModelPanel) do
    if id == panelId then
      return true
    end
  end
  return false
end
