require("UI.UICharacterPropPanel.UICharacterPropPanelView")
require("UI.UIBasePanel")
UIWeaponPropPanel = class("UIWeaponPropPanel", UIBasePanel)
UIWeaponPropPanel.__index = UIWeaponPropPanel
UIWeaponPropPanel.weaponData = nil
function UIWeaponPropPanel:ctor(csPanel)
  UIWeaponPropPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIWeaponPropPanel:Close()
  UIManager.CloseUI(UIDef.UIWeaponPropPanel)
end
function UIWeaponPropPanel:OnInit(root, data)
  self = UIWeaponPropPanel
  self.weaponData = NetCmdWeaponData:GetWeaponById(data)
  UIWeaponPropPanel.super.SetRoot(UIWeaponPropPanel, root)
  UIWeaponPropPanel.mView = UICharacterPropPanelView.New()
  UIWeaponPropPanel.mView:InitCtrl(root)
  UIWeaponPropPanel.super.SetPosZ(UIWeaponPropPanel)
  UIUtils.GetButtonListener(self.mView.mBtn_Close.gameObject).onClick = function()
    self:Close()
  end
  self:UpdatePanel()
end
function UIWeaponPropPanel:UpdatePanel()
  if self.weaponData then
    self:UpdateProp()
  end
end
function UIWeaponPropPanel:UpdateProp()
  local count = 0
  local propList = self:GetBarrackShowPropList()
  for i, prop in ipairs(propList) do
    local item = UICommonPropertyItem.New()
    item:InitCtrl(self.mView.mTrans_PropList)
    local value = self:GetPropValueByName(prop.sys_name)
    local addValue = self:GetWeaponPartValue(prop.sys_name)
    if value == 0 and addValue == 0 then
      item:SetWeaponProp(nil)
    else
      count = count + 1
      item:SetWeaponProp(prop, value, addValue, count % 2 == 0)
    end
  end
end
function UIWeaponPropPanel:GetBarrackShowPropList()
  local propList = {}
  for i = 0, TableData.listLanguagePropertyDatas.Count - 1 do
    local propData = TableData.listLanguagePropertyDatas[i]
    if propData and propData.barrack_show ~= 0 then
      table.insert(propList, propData)
    end
  end
  table.sort(propList, function(a, b)
    return a.barrack_show < b.barrack_show
  end)
  return propList
end
function UIWeaponPropPanel:GetPropValueByName(name)
  return self.weaponData:GetPropertyByLevelAndSysName(name, self.weaponData.Level, self.weaponData.BreakTimes, false)
end
function UIWeaponPropPanel:GetWeaponPartValue(name)
  return self.weaponData:GetWeaponPartPropertyBySysName(name)
end
