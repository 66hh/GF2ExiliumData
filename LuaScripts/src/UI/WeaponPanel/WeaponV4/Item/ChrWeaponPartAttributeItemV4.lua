require("UI.UIBaseCtrl")
ChrWeaponPartAttributeItemV4 = class("ChrWeaponPartAttributeItemV4", UIBaseCtrl)
ChrWeaponPartAttributeItemV4.__index = ChrWeaponPartAttributeItemV4
function ChrWeaponPartAttributeItemV4:ctor()
  self.mLanguagePropertyData = nil
  self.mData = nil
end
function ChrWeaponPartAttributeItemV4:InitCtrl(parent, obj)
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
function ChrWeaponPartAttributeItemV4:SetData(data, value)
  if data then
    self.mLanguagePropertyData = data
    self.mData = data
    self.value = value
    self.ui.mText_Name.text = data.show_name.str
    if self.mLanguagePropertyData.show_type == 2 then
      value = self:PercentValue(value)
    end
    self.ui.mText_Num.text = value
    setactive(self.mUIRoot.gameObject, true)
  else
    self.mLanguagePropertyData = nil
    self.mData = nil
    setactive(self.mUIRoot.gameObject, false)
  end
end
function ChrWeaponPartAttributeItemV4:PercentValue(value)
  value = value / 10
  value = math.floor(value * 10 + 0.5) / 10
  return value .. "%"
end
