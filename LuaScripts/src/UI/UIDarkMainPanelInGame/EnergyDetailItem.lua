require("UI.UIBaseCtrl")
EnergyDetailItem = class("EnergyDetailItem", UIBaseCtrl)
EnergyDetailItem.__index = EnergyDetailItem
local EnumDarkzoneProperty = require("UI.UIDarkMainPanelInGame.DarkzoneProperty")
function EnergyDetailItem:InitCtrl(root, energyID, last)
  self.obj = instantiate(root.childItem, root.transform)
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  setactive(self.ui.mTran_Line.gameObject, not last)
  self.ui.mText_Title.text = TableData.listPropertyDescDatas:GetDataById(energyID).name.str
  if energyID == EnumDarkzoneProperty.Property.DzEnergy1Now then
    self.maxEnum = EnumDarkzoneProperty.Property.DzEnergy1
    setactive(self.ui.mTran_Blue.gameObject, false)
    setactive(self.ui.mTran_Red.gameObject, true)
  elseif energyID == EnumDarkzoneProperty.Property.DzEnergy2Now then
    self.maxEnum = EnumDarkzoneProperty.Property.DzEnergy2
    setactive(self.ui.mTran_Blue.gameObject, true)
    setactive(self.ui.mTran_Red.gameObject, false)
  end
  local max = TableData.listDarkzonePropertyDescDatas:GetDataById(self.maxEnum).maximum_effect
  local cur = CS.SysMgr.dzPlayerMgr.MainPlayer:GetProperty(energyID)
  self.ui.mText_Num.text = cur .. "/" .. max
end
function EnergyDetailItem:SetValue(value)
  local max = TableData.listDarkzonePropertyDescDatas:GetDataById(self.maxEnum).maximum_effect
  self.ui.mText_Num.text = value .. "/" .. max
end
function EnergyDetailItem:OnRelease()
  self.ui = nil
  self.maxEnum = nil
  gfdestroy(self.obj.gameObject)
end
