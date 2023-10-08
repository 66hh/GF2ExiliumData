require("UI.UIBaseCtrl")
GashaponOddsDeatailsItemV2 = class("GashaponOddsDeatailsItemV2", UIBaseCtrl)
GashaponOddsDeatailsItemV2.__Index = GashaponOddsDeatailsItemV2
function GashaponOddsDeatailsItemV2:__InitCtrl()
end
function GashaponOddsDeatailsItemV2:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("Gashapon/GashaponOddsDeatailsItemV2.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
  end
  self:SetRoot(obj.transform)
  self:__InitCtrl()
  self.ui = {}
  self:LuaUIBindTable(obj.transform, self.ui)
  self.elementItem = UICommonElementItem.New()
  self.elementItem:InitCtrl(self.ui.mTrans_GrpElement)
  self.dutyItem = UICommonDutyItem.New()
  self.dutyItem:InitCtrl(self.ui.mTrans_GrpDuty)
end
function GashaponOddsDeatailsItemV2:SetData(data)
  self.ui.mText_Name.text = data.name.str
  if data.type == GlobalConfig.ItemType.GunType then
    local gunData = TableData.listGunDatas:GetDataById(data.args[0])
    local dutyData = TableData.listGunDutyDatas:GetDataById(gunData.duty)
    self.dutyItem:SetData(dutyData)
  elseif data.type == GlobalConfig.ItemType.Weapon then
    local weaponData = TableData.listGunWeaponDatas:GetDataById(data.args[0])
    local weaponTypeData = TableData.listGunWeaponTypeDatas:GetDataById(weaponData.type)
    self.dutyItem.mImage_Duyt.sprite = IconUtils.GetGunGashaponPic(weaponTypeData.icon)
  end
  setactive(self.ui.mTrans_GrpDuty, data.type == GlobalConfig.ItemType.GunType or data.type == GlobalConfig.ItemType.Weapon)
  setactive(self.ui.mTrans_GrpElement, false)
end
function GashaponOddsDeatailsItemV2:SetSelect(isSelect)
end
