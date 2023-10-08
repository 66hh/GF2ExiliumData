require("UI.UIBaseCtrl")
ChrWeaponAttributeListItemV4 = class("ChrWeaponAttributeListItemV4", UIBaseCtrl)
ChrWeaponAttributeListItemV4.__index = ChrWeaponAttributeListItemV4
function ChrWeaponAttributeListItemV4:ctor()
  self.mLanguagePropertyData = nil
  self.mData = nil
end
function ChrWeaponAttributeListItemV4:InitCtrl(parent, obj)
  local instObj
  if obj == nil then
    local itemPrefab = parent.gameObject:GetComponent(typeof(CS.ScrollListChild))
    instObj = instantiate(itemPrefab.childItem)
  else
    instObj = obj
  end
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
end
function ChrWeaponAttributeListItemV4:SetData(data, value)
  if data then
    self.mLanguagePropertyData = data
    self.mData = data
    self.value = value
    self.ui.mText_Name.text = data.show_name.str
    if self.mLanguagePropertyData.show_type == 2 then
      value = self:PercentValue(value)
    end
    self.ui.mText_Num.text = value
    self:IsEmpty(false)
  else
    self.mLanguagePropertyData = nil
    self.mData = nil
    self:IsEmpty(true)
  end
end
function ChrWeaponAttributeListItemV4:PercentValue(value)
  value = value / 10
  value = math.floor(value * 10 + 0.5) / 10
  return value .. "%"
end
function ChrWeaponAttributeListItemV4:IsEmpty(boolean)
  setactive(self.ui.mTrans_Empty.gameObject, boolean)
  setactive(self.ui.mTrans_Full.gameObject, not boolean)
end
