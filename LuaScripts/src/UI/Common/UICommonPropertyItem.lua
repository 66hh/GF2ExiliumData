require("UI.UIBaseCtrl")
UICommonPropertyItem = class("UICommonPropertyItem", UIBaseCtrl)
UICommonPropertyItem.__index = UICommonPropertyItem
function UICommonPropertyItem:ctor()
  self.mData = nil
  self.value = 0
  self.upValue = 0
  self.needPlus = false
  self.recordValue = 0
  self.timer = nil
  self.qualityList = {}
end
function UICommonPropertyItem:__InitCtrl()
  self.mTrans_Bg = self:GetRectTransform("GrpContent/Trans_GrpBg")
  self.mTrans_Icon = self:GetRectTransform("GrpContent/GrpList/Trans_GrpIcon")
  self.mImage_Icon = self:GetImage("GrpContent/GrpList/Trans_GrpIcon/Img_Icon")
  self.mText_Name = self:GetText("GrpContent/GrpList/Text_Name")
  self.mText_Num = self:GetText("GrpContent/Text_Num")
  self.mTrans_Line = self:GetRectTransform("GrpContent/Trans_GrpLine")
  self.mTrans_ValueChange = self:GetRectTransform("GrpContent/Trans_GrpNumRight")
  self.mText_ValueNow = self:GetText("GrpContent/Trans_GrpNumRight/Text_NumNow")
  self.mText_ValueUp = self:GetText("GrpContent/Trans_GrpNumRight/Text_NumAfter")
  self.mTrans_New = self:GetRectTransform("Trans_GrpNew")
  self.mTrans_Quailty = self:GetRectTransform("GrpContent/Trans_GrpQuality")
  self.mAniRoot = UIUtils.GetAnimator(self.mUIRoot)
  self:InitQuality()
end
function UICommonPropertyItem:InitQuality()
  for i = 1, 4 do
    local item = {}
    local obj = self:GetRectTransform("GrpContent/Trans_GrpQuality/GrpQuality" .. i)
    item.obj = obj
    item.imgOn = UIUtils.GetImage(obj, "Trans_On")
    item.transOff = UIUtils.GetRectTransform(obj, "Trans_Off")
    table.insert(self.qualityList, item)
  end
end
function UICommonPropertyItem:InitObj(obj)
  self:SetRoot(obj.transform)
  self:__InitCtrl()
end
function UICommonPropertyItem:InitCtrl(parent, useScrollListChild)
  local obj
  if useScrollListChild then
    local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
    obj = instantiate(itemPrefab.childItem)
    UIUtils.AddListItem(obj.gameObject, parent.gameObject)
  else
    obj = self:Instantiate("UICommonFramework/ComAttributeUpListItem.prefab", parent)
  end
  self:InitObj(obj)
end
function UICommonPropertyItem:SetData(data, value, needLine, needIcon, needBg, needPlus)
  needPlus = needPlus == nil and true or needPlus
  needLine = needLine == nil and true or needLine
  needIcon = needIcon == nil and true or needIcon
  needBg = needBg == nil and true or needBg
  self.needPlus = needPlus
  if data then
    self.mData = data
    self.value = value
    self.mText_Name.text = data.show_name.str
    if self.mData.show_type == 2 then
      value = self:PercentValue(value)
    end
    if needPlus then
      self.mText_Num.text = "+" .. value
      self.mText_ValueNow.text = "+" .. value
    else
      self.mText_Num.text = value
      self.mText_ValueNow.text = value
    end
    if needIcon then
      self.mImage_Icon.sprite = IconUtils.GetAttributeIcon(self.mData.icon)
    end
    setactive(self.mTrans_Bg, needBg)
    setactive(self.mTrans_Icon, needIcon)
    setactive(self.mTrans_Line, needLine)
    setactive(self.mText_Num.gameObject, true)
    setactive(self.mTrans_New, false)
    setactive(self.mUIRoot, true)
  else
    self.mData = nil
    setactive(self.mUIRoot, false)
  end
end
function UICommonPropertyItem:SetDataByName(name, value, needLine, needIcon, needBg, needPlus)
  needPlus = needPlus == nil and true or needPlus
  needLine = needLine == nil and true or needLine
  needIcon = needIcon == nil and true or needIcon
  needBg = needBg == nil and true or needBg
  if name then
    self.mData = TableData.GetPropertyDataByName(name, 1)
    if self.mData == nil then
      self.mData = TableData.GetPropertyDataByName(name, 2)
    end
    self.value = value
    self.mText_Name.text = self.mData.show_name.str
    if self.mData.show_type == 2 then
      value = self:PercentValue(value)
    end
    if needPlus then
      self.mText_Num.text = "+" .. value
      self.mText_ValueNow.text = "+" .. value
    else
      self.mText_Num.text = value
      self.mText_ValueNow.text = value
    end
    if needIcon then
      self.mImage_Icon.sprite = IconUtils.GetAttributeIcon(self.mData.icon)
    end
    setactive(self.mTrans_Bg, needBg)
    setactive(self.mTrans_Icon, needIcon)
    setactive(self.mTrans_Line, needLine)
    setactive(self.mText_Num.gameObject, true)
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UICommonPropertyItem:SetGunProp(data, value, addValue, needBg, showShield)
  if data then
    self.mData = data
    self.value = value
    self.mText_Name.text = data.show_name.str
    local strValue = 0
    local strAddValue = 0
    if self.mData.show_type == 2 then
      strValue = self:PercentValue(value)
      strAddValue = self:PercentValue(addValue)
    else
      strValue = value
      strAddValue = addValue
    end
    if 0 < addValue then
      self.mText_Num.text = string_format(TableData.GetHintById(809), strValue, strAddValue)
    else
      self.mText_Num.text = strValue
    end
    self.mImage_Icon.sprite = IconUtils.GetAttributeIcon(self.mData.icon)
    if showShield ~= nil and self.mData.sys_name == "max_shield_hp" then
      local shieldData = TableData.listLanguageShieldDatas:GetDataById(showShield)
      self.mText_Name.text = shieldData.name.str
      self.mImage_Icon.sprite = IconUtils.GetAttributeIcon(shieldData.icon)
    end
    setactive(self.mTrans_Bg, needBg)
    setactive(self.mTrans_Icon, true)
    setactive(self.mTrans_Line, false)
    setactive(self.mText_Num.gameObject, true)
    setactive(self.mUIRoot, true)
  else
    self.mData = nil
    setactive(self.mUIRoot, false)
  end
end
function UICommonPropertyItem:SetWeaponProp(data, value, addValue, needBg)
  if data then
    self.mData = data
    self.value = value
    self.mText_Name.text = data.show_name.str
    local strValue = 0
    local strAddValue = 0
    if self.mData.show_type == 2 then
      value = math.ceil(value / 10)
      addValue = math.ceil(addValue / 10)
      strValue = value .. "%"
      strAddValue = addValue .. "%"
    else
      strValue = value
      strAddValue = addValue
    end
    if 0 < addValue then
      self.mText_Num.text = string_format(TableData.GetHintById(809), strValue, strAddValue)
    else
      self.mText_Num.text = strValue
    end
    self.mImage_Icon.sprite = IconUtils.GetAttributeIcon(self.mData.icon)
    setactive(self.mTrans_Bg, needBg)
    setactive(self.mTrans_Icon, true)
    setactive(self.mTrans_Line, false)
    setactive(self.mText_Num.gameObject, true)
    setactive(self.mUIRoot, true)
  else
    self.mData = nil
    setactive(self.mUIRoot, false)
  end
end
function UICommonPropertyItem:SetUAVProp(data, value, addValue, needBg)
  if data then
    self.mData = data
    self.value = value
    self.mText_Name.text = data.show_name.str
    local strValue = 0
    local strAddValue = 0
    if self.mData.show_type == 2 then
      value = math.ceil(value / 10)
      addValue = math.ceil(addValue / 10)
      strValue = value .. "%"
      strAddValue = addValue .. "%"
    else
      strValue = value
      strAddValue = addValue
    end
    if 0 < addValue then
      self.mText_Num.text = string_format(TableData.GetHintById(809), strValue, strAddValue)
    else
      self.mText_Num.text = strValue
    end
    self.mImage_Icon.sprite = IconUtils.GetAttributeIcon(self.mData.icon)
    if showShield ~= nil and self.mData.sys_name == "max_shield_hp" then
      local shieldData = TableData.listLanguageShieldDatas:GetDataById(showShield)
      self.mText_Name.text = shieldData.name.str
      self.mImage_Icon.sprite = IconUtils.GetAttributeIcon(shieldData.icon)
    end
    setactive(self.mTrans_Bg, needBg)
    setactive(self.mTrans_Icon, true)
    setactive(self.mTrans_Line, false)
    setactive(self.mText_Num.gameObject, true)
    setactive(self.mUIRoot, true)
  else
    self.mData = nil
    setactive(self.mUIRoot, false)
  end
end
function UICommonPropertyItem:UpdateAttrValue(value, showShield)
  self.value = value
  if self.mData.show_type == 2 then
    value = math.ceil(value / 10) .. "%"
  end
  if self.needPlus then
    self.mText_Num.text = "+" .. value
  else
    self.mText_Num.text = value
  end
  if showShield ~= nil and self.mData.sys_name == "max_shield_hp" then
    local shieldData = TableData.listLanguageShieldDatas:GetDataById(showShield)
    self.mText_Name.text = shieldData.name.str
    self.mImage_Icon.sprite = IconUtils.GetAttributeIcon(shieldData.icon)
  end
end
function UICommonPropertyItem:SetValueUp(upValue)
  self.upValue = upValue
  if self.value ~= self.upValue then
    setactive(self.mTrans_ValueChange, upValue ~= 0)
    setactive(self.mText_Num.gameObject, upValue == 0)
    if upValue ~= 0 then
      local value = upValue
      if self.mData.show_type == 2 then
        value = math.ceil(upValue / 10) .. "%"
      end
      self.mText_ValueUp.text = value
    end
  else
    setactive(self.mTrans_ValueChange, false)
  end
end
function UICommonPropertyItem:SetEquipNewProp()
  setactive(self.mTrans_ValueChange, false)
  setactive(self.mText_Num.gameObject, true)
  setactive(self.mTrans_New, true)
  local color = self.mText_ValueUp.color
  self.mText_Name.color = color
  self.mText_Num.color = color
end
function UICommonPropertyItem:SetPartNewProp()
  setactive(self.mTrans_ValueChange, false)
  setactive(self.mText_Num.gameObject, true)
  setactive(self.mTrans_New, true)
end
function UICommonPropertyItem:SetTipsName(hintId, param)
  if hintId then
    local hint = TableData.GetHintById(hintId)
    if param then
      hint = string_format(hint, param)
    end
    self.mText_Name.text = hint
    setactive(self.mTrans_ValueChange, false)
    setactive(self.mText_Num.gameObject, false)
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UICommonPropertyItem:SetTextColor(color)
  if color == nil then
    color = ColorUtils.BlackColor
  end
  self.mText_Name.color = color
  self.mText_Num.color = color
end
function UICommonPropertyItem:SetTextFont(font)
  local f
  if font == nil then
    f = CS.CommonResUtils.GetCommonFont(CS.enumFont.eNOTOSANSHANS_MEDIUM)
  else
    f = CS.CommonResUtils.GetCommonFont(font)
  end
  self.mText_Name.font = f
end
function UICommonPropertyItem:SetPropQuality(rankList)
  setactive(self.mTrans_Quailty, true)
  for i, item in ipairs(self.qualityList) do
    setactive(item.imgOn.gameObject, false)
    setactive(item.transOff, true)
  end
  for i, item in ipairs(self.qualityList) do
    local rank = rankList[i]
    if rank then
      item.imgOn.color = TableData.GetGlobalGun_Quality_Color2(rank)
    end
    setactive(item.imgOn.gameObject, rank ~= nil)
    setactive(item.transOff, rank == nil)
  end
end
function UICommonPropertyItem:RecordValue()
  self.recordValue = self.value
end
function UICommonPropertyItem:PercentValue(value)
  value = value / 10
  value = math.floor(value * 10 + 0.5) / 10
  return value .. "%"
end
function UICommonPropertyItem:PlayGroupAni(delay)
  if 0 < delay then
    self.timer = TimerSys:DelayCall(delay, function()
      if self.mAniRoot then
        self.mAniRoot:SetTrigger("Trigger")
        UIUtils.InitUITextGroupUp(self.mText_Num.gameObject, self.recordValue, self.value)
      end
    end)
  else
    self.mAniRoot:SetTrigger("Trigger")
    UIUtils.InitUITextGroupUp(self.mText_Num.gameObject, self.recordValue, self.value)
  end
end
function UICommonPropertyItem:Release()
  if self.timer then
    self.timer:Stop()
    UIUtils.StopUITextGroupUp(self.mText_Num.gameObject)
  end
  self.super.OnRelease(self)
end
