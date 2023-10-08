require("UI.UIBaseCtrl")
ChrWeaponAttributeListItemV3 = class("ChrWeaponAttributeListItemV3", UIBaseCtrl)
ChrWeaponAttributeListItemV3.__index = ChrWeaponAttributeListItemV3
function ChrWeaponAttributeListItemV3:ctor()
  self.mLanguagePropertyData = nil
  self.mData = nil
end
function ChrWeaponAttributeListItemV3:InitCtrl(parent, obj)
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
function ChrWeaponAttributeListItemV3:SetData(data, value, needLine, needIcon, needBg, needPlus)
  needPlus = needPlus == nil and true or needPlus
  needLine = needLine == nil and true or needLine
  needIcon = needIcon == nil and true or needIcon
  needBg = needBg == nil and true or needBg
  self.needPlus = needPlus
  if data then
    self.mLanguagePropertyData = data
    self.mData = data
    self.value = value
    self.ui.mText_Name.text = data.show_name.str
    if self.mLanguagePropertyData.show_type == 2 then
      value = self:PercentValue(value)
    end
    if needPlus then
      self.ui.mText_Num.text = "+" .. value
      self.ui.mText_NumNow.text = "+" .. value
    else
      self.ui.mText_Num.text = value
      self.ui.mText_NumNow.text = value
    end
    setactive(self.mUIRoot, true)
  else
    self.mLanguagePropertyData = nil
    self.mData = nil
    setactive(self.mUIRoot, false)
  end
end
function ChrWeaponAttributeListItemV3:PercentValue(value)
  value = value / 10
  value = math.floor(value * 10 + 0.5) / 10
  return value .. "%"
end
function ChrWeaponAttributeListItemV3:SetPropQuality(rankList)
  local tmpQualityTransform = self.ui.mTrans_Quality.transform
  setactive(tmpQualityTransform, true)
  for i = 0, tmpQualityTransform.childCount - 1 do
    setactive(tmpQualityTransform:GetChild(i):GetChild(1).gameObject, false)
  end
  for i = 1, #rankList do
    local tmpParent = tmpQualityTransform:GetChild(i - 1)
    local tmpOnObj = tmpParent:GetChild(1).gameObject
    setactive(tmpOnObj, true)
    local tmpImg = tmpOnObj:GetComponent(typeof(CS.UnityEngine.UI.Image))
    tmpImg.color = TableData.GetGlobalGun_Quality_Color2(rankList[i], tmpImg.color.a)
  end
end
function ChrWeaponAttributeListItemV3:SetValueUp(upValue, needShow)
  if needShow == nil then
    needShow = true
  end
  self.upValue = upValue
  if self.value ~= self.upValue and needShow then
    setactive(self.ui.mTrans_NumRight, upValue ~= 0)
    setactive(self.ui.mText_Num, upValue == 0)
    if upValue ~= 0 then
      local value = upValue
      if self.mLanguagePropertyData.show_type == 2 then
        value = self:PercentValue(value)
      end
      self.ui.mText_NumBefore.text = self.ui.mText_Num.text
      self.ui.mText_NumNow.text = "+" .. value
    end
  else
    setactive(self.ui.mTrans_NumRight, false)
    setactive(self.ui.mText_Num, true)
  end
end
