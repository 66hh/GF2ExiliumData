UIPropertyCtrl = class("UICommonProperty", UIBaseCtrl)
function UIPropertyCtrl:InitRoot(root)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root)
end
function UIPropertyCtrl:ShowAdd(propertyType, addValue)
  local propertyData = TableData.GetPropertyDataByName(propertyType:ToString())
  if not propertyData then
    return
  end
  if propertyData.show_type == 2 then
    self.ui.mText_Num.text = propertyData.ShowName.str .. "+" .. self:PercentValue(addValue)
  else
    self.ui.mText_Num.text = propertyData.ShowName.str .. "+" .. addValue
  end
end
function UIPropertyCtrl:ShowDiff(propertyType, prevValue, curValue, index)
  local propertyData = TableData.GetPropertyDataByName(propertyType:ToString())
  if propertyData == nil then
    return
  end
  self.ui.mText_Name.text = propertyData.show_name.str
  if propertyData.show_type == 2 then
    self.ui.mText_NumBefore.text = self:PercentValue(prevValue)
    self.ui.mText_NumNow.text = self:PercentValue(curValue)
  else
    self.ui.mText_NumBefore.text = prevValue
    self.ui.mText_NumNow.text = curValue
  end
end
function UIPropertyCtrl:PercentValue(value)
  value = value / 10
  value = math.floor(value * 10 + 0.5) / 10
  return value .. "%"
end
function UIPropertyCtrl:OnRelease(isDestroy)
  self.ui = nil
  self.super.OnRelease(self, isDestroy)
end
