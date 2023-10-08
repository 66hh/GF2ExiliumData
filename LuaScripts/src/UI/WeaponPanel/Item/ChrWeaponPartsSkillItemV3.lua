require("UI.UIBaseCtrl")
ChrWeaponPartsSkillItemV3 = class("ChrWeaponPartsSkillItemV3", UIBaseCtrl)
ChrWeaponPartsSkillItemV3.__index = ChrWeaponPartsSkillItemV3
function ChrWeaponPartsSkillItemV3:ctor()
  self.suitUnActive = {
    Text = Color(0.9372549019607843, 0.9372549019607843, 0.9372549019607843, 0.5490196078431373),
    BG = Color(0.10196078431372549, 0.17254901960784313, 0.2, 0.7058823529411765)
  }
  self.suitActive = {
    Text = Color(1, 1, 1, 1),
    BG = Color(0.34509803921568627, 0.5372549019607843, 0.803921568627451, 1.0)
  }
  self.skillData = nil
  self.suitData = nil
end
function ChrWeaponPartsSkillItemV3:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
end
function ChrWeaponPartsSkillItemV3:SetData(data, count, hideunactiveSuit)
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
function ChrWeaponPartsSkillItemV3:UpdateSuitInfo(suitData, suitCount, hideunactiveSuit)
  self.suitData = suitData
  if self.suitData then
    for num, propId in pairs(suitData.power_suit) do
      local prop = PropertyHelper.GetOnlyOnePropty(propId)
      local value = PropertyHelper.GetPropertyValueByString(propId, prop)
      local propData = TableData.GetPropertyDataByName(prop)
      self.ui.mText_Num2.text = num
      if propData.show_type == 2 then
        self.ui.mText_Describe2.text = propData.show_name.str .. "+" .. math.ceil(value / 10) .. "%"
      else
        self.ui.mText_Describe2.text = propData.show_name.str .. "+" .. value
      end
      self.ui.mText_Num2.text = num
      if hideunactiveSuit then
        setactive(self.ui.mTrans_Suit2, num <= suitCount)
      elseif suitCount < num then
        self.ui.mImage_Bg2.color = self.suitUnActive.BG
        self.ui.mText_Describe2.color = self.suitUnActive.Text
        self.ui.mText_Num2.color = self.suitUnActive.Text
      else
        self.ui.mImage_Bg2.color = self.suitActive.BG
        self.ui.mText_Describe2.color = self.suitActive.Text
        self.ui.mText_Num2.color = self.suitActive.Text
      end
    end
    for num, skillId in pairs(suitData.power_skill) do
      local skillData = TableData.GetSkillData(skillId)
      self.ui.mText_Num4.text = num
      self.ui.mText_Describe4.text = skillData.description.str
      if hideunactiveSuit then
        setactive(self.ui.mTrans_Suit4, num <= suitCount)
      elseif suitCount < num then
        self.ui.mImage_Bg4.color = self.suitUnActive.BG
        self.ui.mText_Describe4.color = self.suitUnActive.Text
        self.ui.mText_Num4.color = self.suitUnActive.Text
      else
        self.ui.mImage_Bg4.color = self.suitActive.BG
        self.ui.mText_Describe4.color = self.suitActive.Text
        self.ui.mText_Num4.color = self.suitActive.Text
      end
    end
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
