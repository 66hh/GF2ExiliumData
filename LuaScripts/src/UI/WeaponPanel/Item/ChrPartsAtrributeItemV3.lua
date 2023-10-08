require("UI.UIBaseCtrl")
ChrPartsAtrributeItemV3 = class("ChrPartsAtrributeItemV3", UIBaseCtrl)
ChrPartsAtrributeItemV3.__index = ChrPartsAtrributeItemV3
function ChrPartsAtrributeItemV3:ctor()
  self.mLanguagePropertyData = nil
  self.mData = nil
  self.rankList = {}
end
function ChrPartsAtrributeItemV3:InitCtrl(parent, obj)
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
function ChrPartsAtrributeItemV3:SetData(data, value, needLine, needIcon, needBg, needPlus)
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
    self.ui.mText_TotalNum.text = value
    setactive(self.mUIRoot, true)
  else
    self.mLanguagePropertyData = nil
    self.mData = nil
    setactive(self.mUIRoot, false)
  end
end
function ChrPartsAtrributeItemV3:PercentValue(value)
  value = value / 10
  value = math.floor(value * 10 + 0.5) / 10
  return value .. "%"
end
function ChrPartsAtrributeItemV3:SetPropQualityWithValue(rankList)
  self.rankList = rankList
  local tmpQualityTransform = self.ui.mTrans_Quality.transform
  setactive(tmpQualityTransform, true)
  for i = 1, #rankList do
    local transQuality = tmpQualityTransform:GetChild(i - 1)
    local rankWithValue = rankList[i]
    setactive(transQuality, true)
    local num = transQuality:GetChild(2).gameObject
    num:SetActive(true)
    num:GetComponent("Text").text = rankWithValue.value
    local bg = transQuality:GetChild(0).gameObject
    local bgImg = bg:GetComponent("Image")
    local bgColorList = bg:GetComponent("TextImgColorList")
    if bgColorList ~= nil then
      bgImg.color = bgColorList.ImageColor[rankWithValue.rank - 1]
    else
      bgImg.color = TableData.GetGlobalGun_Quality_Color2(rankWithValue.rank, bgImg.color.a)
    end
    local frame = transQuality:GetChild(1).gameObject
    local frameImg = frame:GetComponent("Image")
    local frameColorList = frame:GetComponent("TextImgColorList")
    if frameColorList ~= nil then
      frameImg.color = frameColorList.ImageColor[rankWithValue.rank - 1]
    else
      frameImg.color = TableData.GetGlobalGun_Quality_Color2(rankWithValue.rank, frameImg.color.a)
    end
    local maskGlow = transQuality:GetChild(3).gameObject
    setactive(maskGlow, false)
  end
end
function ChrPartsAtrributeItemV3:SetPartNewProp()
  setactive(self.ui.mTrans_New, true)
end
function ChrPartsAtrributeItemV3:SetPartAffixNew(boolean)
  if boolean then
    local tmpQualityTransform = self.ui.mTrans_Quality.transform
    local transQuality = tmpQualityTransform:GetChild(#self.rankList - 1)
    local maskGlow = transQuality:GetChild(3).gameObject
    setactive(maskGlow, true)
  end
end
