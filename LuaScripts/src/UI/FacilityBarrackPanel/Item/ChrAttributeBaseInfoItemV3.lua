ChrAttributeBaseInfoItemV3 = class("ChrAttributeBaseInfoItemV3", UIBaseCtrl)
ChrAttributeBaseInfoItemV3.__index = ChrAttributeBaseInfoItemV3
function ChrAttributeBaseInfoItemV3:ctor()
  self.mLanguagePropertyData = nil
  self.value = 0
end
function ChrAttributeBaseInfoItemV3:InitCtrl(parent, obj)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj
  if obj == nil then
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
function ChrAttributeBaseInfoItemV3:SetProp(data, value, hint)
  if data and 0 < value then
    self.mLanguagePropertyData = data
    self.value = value
    self.ui.mText_Name.text = TableData.GetHintById(hint)
    local strValue = 0
    if self.mLanguagePropertyData.show_type == 2 then
      strValue = FacilityBarrackGlobal.PercentValue(value, 2)
    else
      local formatted_num = string.format("%.2f", value)
      strValue = formatted_num
    end
    if self.mLanguagePropertyData.sys_name == "max_ap" then
      strValue = PropertyHelper.CastGunMaxAp(value)
      local formatted_num = string.format("%.0f", strValue)
      strValue = formatted_num
    end
    self.ui.mText_Num.text = strValue
    setactive(self.mUIRoot, true)
  else
    self.mLanguagePropertyData = nil
    setactive(self.mUIRoot, false)
  end
end
function ChrAttributeBaseInfoItemV3:OnRelease()
  self.super.OnRelease(self)
end
