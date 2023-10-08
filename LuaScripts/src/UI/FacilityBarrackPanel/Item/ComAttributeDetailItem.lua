ComAttributeDetailItem = class("ComAttributeDetailItem", UIBaseCtrl)
ComAttributeDetailItem.__index = ComAttributeDetailItem
function ComAttributeDetailItem:ctor()
  self.mLanguagePropertyData = nil
end
function ComAttributeDetailItem:InitCtrl(parent, obj)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj
  if obj ~= nil then
    instObj = obj
  else
    instObj = instantiate(itemPrefab.childItem)
  end
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
end
function ComAttributeDetailItem:InitByTemplate(template, parent)
  local go = UIUtils.InstantiateByTemplate(template, parent)
  self:SetRoot(go.transform)
  self.ui = UIUtils.GetUIBindTable(go)
end
function ComAttributeDetailItem:SetDataByName(name, value, needLine, needIcon, needBg, needPlus)
  needPlus = needPlus == nil and true or needPlus
  needLine = needLine == nil and true or needLine
  needIcon = needIcon == nil and true or needIcon
  needBg = needBg == nil and true or needBg
  if name then
    self.mLanguagePropertyData = TableData.GetPropertyDataByName(name, 1)
    self.ui.mText_AttrName.text = self.mLanguagePropertyData.show_name.str
    if self.mLanguagePropertyData.show_type == 2 then
      value = self:PercentValue(value)
    end
    self.ui.mText_AttrNum.text = value
    if needIcon then
      self.ui.mImg_AttrIcon.sprite = IconUtils.GetAttributeIcon(self.mLanguagePropertyData.icon)
    end
    setactive(self.ui.mTrans_Bg, needBg)
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function ComAttributeDetailItem:UpdateAttrValue(value, showShield)
  if self.mLanguagePropertyData.show_type == 2 then
    value = self:PercentValue(value)
  end
  self.ui.mText_AttrNum.text = value
end
function ComAttributeDetailItem:PercentValue(value)
  value = value / 10
  value = math.floor(value * 10 + 0.5) / 10
  return value .. "%"
end
function ComAttributeDetailItem:ShowDiff(index, propertyType, prevValue, curValue, needIcon)
  local propertyData = TableData.GetPropertyDataByName(propertyType:ToString())
  self.ui.mText_AttrName.text = propertyData.show_name.str
  if propertyData.show_type == 2 then
    self.ui.mText_AttrNumBefore.text = self:PercentValue(prevValue)
    self.ui.mText_AttrNumNow.text = self:PercentValue(curValue)
  else
    self.ui.mText_AttrNumBefore.text = prevValue
    self.ui.mText_AttrNumNow.text = curValue
  end
  if needIcon then
    self.ui.mImg_AttrIcon.sprite = IconUtils.GetAttributeIcon(propertyData.icon)
  end
  setactive(self.ui.mTrans_Bg, index % 2 == 1)
  setactive(self.ui.mImg_AttrIcon, needIcon)
  setactive(self.ui.mTrans_DiffRoot, true)
  setactive(self.ui.mTrans_NowRoot, false)
end
function ComAttributeDetailItem:OnClose()
end
function ComAttributeDetailItem:OnRelease(isDestroy)
  self.super.OnRelease(self, isDestroy)
end
