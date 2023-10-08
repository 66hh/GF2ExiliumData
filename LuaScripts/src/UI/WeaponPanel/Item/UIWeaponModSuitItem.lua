require("UI.UIBaseCtrl")
UIWeaponModSuitItem = class("UIWeaponModSuitItem", UIBaseCtrl)
UIWeaponModSuitItem.__index = UIWeaponModSuitItem
UIWeaponModSuitItem.suitUnActive = {
  Text = Color(0.9372549019607843, 0.9372549019607843, 0.9372549019607843, 0.5490196078431373),
  BG = Color(0.10196078431372549, 0.17254901960784313, 0.2, 0.7058823529411765)
}
UIWeaponModSuitItem.suitActive = {
  Text = Color(1, 1, 1, 1),
  BG = Color(0.34509803921568627, 0.5372549019607843, 0.803921568627451, 1.0)
}
function UIWeaponModSuitItem:ctor()
  self.ui = {}
  self.suitData = nil
  self.activeColor = CS.GF2.UI.UITool.StringToColor("5889CD")
  self.unactiveColor = CS.GF2.UI.UITool.StringToColor("1A2C33")
end
function UIWeaponModSuitItem:__InitCtrl()
end
function UIWeaponModSuitItem:InitCtrl(parent, useScrollListChild, needWhite)
  local obj
  if useScrollListChild then
    local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
    obj = instantiate(itemPrefab.childItem)
  elseif needWhite then
    obj = self:Instantiate("Character/ChrWeaponPartsSkillItemV2_W.prefab", parent)
  else
    obj = self:Instantiate("Character/ChrWeaponPartsSkillItemV2.prefab", parent)
  end
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
  end
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self:__InitCtrl()
end
function UIWeaponModSuitItem:SetData(data, count, hideunactiveSuit)
  if data then
    if hideunactiveSuit == nil then
      hideunactiveSuit = false
    end
    local suitData = TableData.listModPowerDatas:GetDataById(data)
    self.ui.mImg_Icon.sprite = IconUtils.GetWeaponPartIconSprite(suitData.image, false)
    self.ui.mText_SkillName.text = suitData.name.str
    self:UpdateSuitInfo(suitData, count, hideunactiveSuit)
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UIWeaponModSuitItem:UpdateSuitInfo(suitData, suitCount, hideunactiveSuit)
  self.suitData = suitData
  if self.suitData then
    for num, propId in pairs(suitData.power_suit) do
      local prop = PropertyHelper.GetOnlyOnePropty(propId)
      local value = PropertyHelper.GetPropertyValueByString(propId, prop)
      local propData = TableData.GetPropertyDataByName(prop)
      setactive(self.ui.mTrans_Suit2, false)
      self.ui.mText_Num2.text = num
      if propData ~= nil then
        if propData.show_type == 2 then
          self.ui.mText_Describe2.text = propData.show_name.str .. "+" .. math.ceil(value / 10) .. "%"
        else
          self.ui.mText_Describe2.text = propData.show_name.str .. "+" .. value
        end
      end
      self.ui.mText_Num2.text = num
      if hideunactiveSuit then
        setactive(self.ui.mTrans_Suit2, num <= suitCount)
      elseif suitCount < num then
        self.ui.mImage_Bg2.color = UIWeaponModSuitItem.suitUnActive.BG
        self.ui.mText_Describe2.color = UIWeaponModSuitItem.suitUnActive.Text
        self.ui.mText_Num2.color = UIWeaponModSuitItem.suitUnActive.Text
      else
        self.ui.mImage_Bg2.color = UIWeaponModSuitItem.suitActive.BG
        self.ui.mText_Describe2.color = UIWeaponModSuitItem.suitActive.Text
        self.ui.mText_Num2.color = UIWeaponModSuitItem.suitActive.Text
      end
    end
    for num, skillId in pairs(suitData.power_skill) do
      local skillData = TableData.GetSkillData(skillId)
      self.ui.mText_Num4.text = num
      self.ui.mText_Describe4.text = skillData.description.str
      if hideunactiveSuit then
        setactive(self.ui.mTrans_Suit4, num <= suitCount)
      elseif suitCount < num then
        self.ui.mImage_Bg4.color = UIWeaponModSuitItem.suitUnActive.BG
        self.ui.mText_Describe4.color = UIWeaponModSuitItem.suitUnActive.Text
        self.ui.mText_Num4.color = UIWeaponModSuitItem.suitUnActive.Text
      else
        self.ui.mImage_Bg4.color = UIWeaponModSuitItem.suitActive.BG
        self.ui.mText_Describe4.color = UIWeaponModSuitItem.suitActive.Text
        self.ui.mText_Num4.color = UIWeaponModSuitItem.suitActive.Text
      end
    end
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
