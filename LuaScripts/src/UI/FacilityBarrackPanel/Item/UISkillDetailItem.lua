require("UI.UIBaseCtrl")
UISkillDetailItem = class("UISkillDetailItem", UIBaseCtrl)
UISkillDetailItem.__index = UISkillDetailItem
UISkillDetailItem.StarList = {}
UISkillDetailItem.mData = nil
UISkillDetailItem.PrefabPath = "UICommonFramework/ChrSkillDescriptionItem.prefab"
function UISkillDetailItem:ctor()
  UISkillDetailItem.super.ctor(self)
end
function UISkillDetailItem:__InitCtrl()
  self.mTrans_Level = self:GetRectTransform("GrpLevel")
  self.mImage_Statue = self:GetImage("GrpLevel/ImgBg")
  self.mText_Lv = self:GetText("GrpLevel/Text_Num")
  self.mText_Desc = self:GetText("Text_Describe")
  self.animator = self:GetSelfAnimator()
end
function UISkillDetailItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  self:SetRoot(instObj.transform)
  self:__InitCtrl()
  setactive(self.mUIRoot, false)
end
function UISkillDetailItem:SetData(skillData, curLevel, textColor, showBottomBtn)
  self.showBottomBtn = showBottomBtn
  if type(skillData) == "number" then
    self.mText_Desc.text = TableData.GetHintById(skillData)
    setactive(self.mUIRoot, true)
    return
  elseif type(skillData) == "string" then
    self.mText_Desc.text = skillData
    setactive(self.mUIRoot, true)
    return
  end
  textColor = textColor == nil and ColorUtils.WhiteColor or ColorUtils.BlackColor
  self.mData = skillData
  if skillData then
    setactive(self.mText_Lv.gameObject, true)
    self.mText_Lv.text = string_format(TableData.GetHintById(102111), skillData.level)
    self.mText_Desc.text = skillData.upgrade_description.str
    local enable = curLevel >= skillData.level
    self:SetColorWithColorList(skillData.level, curLevel)
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UISkillDetailItem:InitData(armLevel, skillLevel, strDesc, textColor)
  textColor = textColor == nil and ColorUtils.WhiteColor or ColorUtils.BlackColor
  self.mText_Lv.text = string_format(TableData.GetHintById(102111), skillLevel)
  self.mText_Desc.text = strDesc
  local enable = skillLevel <= armLevel
  self:SetColorEnable(enable)
  setactive(self.mUIRoot, true)
end
function UISkillDetailItem:SetColorEnable(enable)
  local alpha = enable and 1 or 0.47
  local color = self.mImage_Statue.color
  color.a = alpha
  self.mImage_Statue.color = color
  color = self.mText_Desc.color
  color.a = alpha
  self.mText_Desc.color = color
end
function UISkillDetailItem:SetColorWithColorList(level, curLevel)
  local mImage_StatueColorList = self.mImage_Statue.gameObject:GetComponent("TextImgColorList")
  local mText_LvColorList = self.mText_Lv.gameObject:GetComponent("TextImgColorList")
  local mText_DescColorList = self.mText_Desc.gameObject:GetComponent("TextImgColorList")
  if mImage_StatueColorList == nil or mText_LvColorList == nil then
    self:SetColorEnable(level <= curLevel)
    return
  end
  local levelColor = {
    isActived = 0,
    curActive = 1,
    unActive = 2
  }
  if level < curLevel then
    self.mImage_Statue.color = mImage_StatueColorList.ImageColor[levelColor.isActived]
    self.mText_Lv.color = mText_LvColorList.ImageColor[levelColor.isActived]
    self.mText_Desc.color = mText_DescColorList.ImageColor[levelColor.isActived]
  elseif level == curLevel then
    local targetIndex = levelColor.curActive
    if self.showBottomBtn then
      targetIndex = levelColor.isActived
    end
    self.mImage_Statue.color = mImage_StatueColorList.ImageColor[targetIndex]
    self.mText_Lv.color = mText_LvColorList.ImageColor[targetIndex]
    self.mText_Desc.color = mText_DescColorList.ImageColor[targetIndex]
  else
    self.mImage_Statue.color = mImage_StatueColorList.ImageColor[levelColor.unActive]
    self.mText_Lv.color = mText_LvColorList.ImageColor[levelColor.unActive]
    self.mText_Desc.color = mText_DescColorList.ImageColor[levelColor.unActive]
  end
end
function UISkillDetailItem:OnRelease()
  gfdestroy(self.mUIRoot.gameObject)
end
