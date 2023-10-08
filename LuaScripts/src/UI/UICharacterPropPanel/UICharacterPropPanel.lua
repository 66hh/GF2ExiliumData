require("UI.UIBasePanel")
UICharacterPropPanel = class("UICharacterPropPanel", UIBasePanel)
UICharacterPropPanel.__index = UICharacterPropPanel
function UICharacterPropPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  self.gunData = nil
  self.isLockGun = false
end
function UICharacterPropPanel:OnClickClose()
  UIManager.CloseUI(UIDef.UICharacterPropPanel)
end
function UICharacterPropPanel:OnClose()
  self:ReleaseCtrlTable(self.propItemTable)
end
function UICharacterPropPanel:OnAwake(root, data)
end
function UICharacterPropPanel:OnInit(root, data)
  self:SetRoot(root)
  self:SetPosZ()
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:OnClickClose()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    self:OnClickClose()
  end
  self.gunData = NetCmdTeamData:GetGunByID(data)
  if self.gunData == nil then
    self.isLockGun = true
    self.gunData = NetCmdTeamData:GetLockGunData(data)
  end
  self.propItemTable = {}
  self:UpdatePanel()
end
function UICharacterPropPanel:UpdatePanel()
  if self.gunData then
    self:UpdateProp()
  end
end
function UICharacterPropPanel:UpdateProp()
  local propList = self:GetBarrackShowPropList()
  for i, prop in ipairs(propList) do
    local item = UICommonPropertyItem.New()
    item:InitCtrl(self.ui.mTrans_PropList)
    local value = self:GetTotalPropValueByName(prop.sys_name)
    local addValue = 0
    if not self.isLockGun then
    end
    item:SetGunProp(prop, value, addValue, i % 2 == 0, self.gunData.AttackType)
    table.insert(self.propItemTable, item)
  end
end
function UICharacterPropPanel:GetBarrackShowPropList()
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
function UICharacterPropPanel:GetTotalPropValueByName(name)
  return self.gunData:GetGunPropertyValueWithPercentByType(name)
end
function UICharacterPropPanel:GetEquipWeaponValue(name)
  local equipValue = self.gunData:GetGunEquipValueByName(name)
  local weaponValue = self.gunData:GetWeaponValueByName(name)
  return equipValue + weaponValue
end
