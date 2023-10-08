require("UI.UIBaseView")
UIWeaponBreakContentView = class("UIWeaponBreakContentView", UIBaseView)
UIWeaponBreakContentView.__index = UIWeaponBreakContentView
function UIWeaponBreakContentView:ctor()
  UIWeaponBreakContentView.super.ctor(self)
  self.skillList = {}
  self.addBtnList = {}
  self.stageItem = nil
end
function UIWeaponBreakContentView:__InitCtrl(weaponList)
  self.mBtn_LevelUp = UIUtils.GetTempBtn(self:GetRectTransform("GrpAction/BtnBreak"))
  self.mBtn_MaxLevelUp = self:GetRectTransform("GrpAction/Trans_MaxLevel")
  self.mText_Name = self:GetText("GrpWeaponInfo/GrpTextName/Text_Name")
  self.mText_Type = self:GetText("GrpWeaponInfo/GrpType/Text_Name")
  self.mTrans_PropList = self:GetRectTransform("GrpAttributeList/Viewport/Content/GrpAttribute")
  self.mTrans_SkillList = self:GetRectTransform("GrpAttributeList/Viewport/Content/GrpSkill")
  self.mTrans_MaterialList = self:GetRectTransform("GrpItemConsume/Trans_GrpItemWeapon/Content")
  self.mTrans_AddItemList = self:GetRectTransform("GrpItemConsume/GrpItemAdd/Content")
  self.mTrans_CostItemContent = self:GetRectTransform("GrpItemConsume")
  self.mTrans_CostHint = self:GetRectTransform("GrpTextConsume")
  self.mTrans_EnhanceContent = weaponList.ui.mUIRoot
  self.mBtn_CloseList = weaponList.ui.mBtn_CloseList
  self.mTrans_WeaponScroll = weaponList.ui.mTrans_WeaponScroll
  self.mTrans_ItemBrief = weaponList.ui.mTrans_ItemBrief
  self.mTrans_Empty = weaponList.ui.mTrans_Empty
  self.mVirtualList = weaponList.ui.mVirtualList
  self.mListAnimator = weaponList.ui.mListAnimator
  self.mListAniTime = weaponList.ui.mListAniTime
  for i = 1, 2 do
    local obj = self:InitScrollListChild(self.mTrans_SkillList, true)
    local item = self:InitSkillItem(obj, i)
    table.insert(self.skillList, item)
  end
  for i = 1, UIWeaponGlobal.MaxBreakCount do
    local obj = self:InitScrollListChild(self.mTrans_AddItemList, true)
    table.insert(self.addBtnList, obj)
  end
  self:InitStageItem()
end
function UIWeaponBreakContentView:InitCtrl(root, weaponList)
  self:SetRoot(root)
  self:__InitCtrl(weaponList)
end
function UIWeaponBreakContentView:InitSkillItem(obj, index)
  if obj then
    local skill = {}
    skill.obj = obj
    skill.txtName = UIUtils.GetText(obj, "GrpNameInfo/GrpTextName/Text_SkillName")
    skill.transBreak = UIUtils.GetRectTransform(obj, "GrpNameInfo/GrpTextName/Trans_GrpBreakText")
    skill.transLv = UIUtils.GetRectTransform(obj, "GrpNameInfo/GrpTextName/Trans_Text_Lv")
    skill.txtLv = UIUtils.GetText(obj, "GrpNameInfo/GrpTextName/Trans_GrpBreakText/Text_Lv")
    skill.imgSkillBg = UIUtils.GetImage(obj, "GrpNameInfo/GrpTextName/Trans_GrpBreakText/ImgBg")
    skill.transBg = UIUtils.GetRectTransform(obj, "Trans_ImgBg")
    skill.transBg2 = UIUtils.GetRectTransform(obj, "ImgBgW")
    skill.txtDesc = UIUtils.GetText(obj, "Text_Describe")
    if index == 2 then
      skill.imgSkillBg.color = ColorUtils.OrangeColor
      skill.txtLv.color = ColorUtils.WhiteColor
      setactive(skill.transBg, true)
    end
    setactive(skill.transBg2, true)
    setactive(skill.transBreak, true)
    setactive(skill.transLv, false)
    return skill
  end
end
function UIWeaponBreakContentView:InitStageItem()
  if self.stageItem == nil then
    local parent = self:GetRectTransform("GrpWeaponInfo/GrpStage")
    self.stageItem = UICommonStageItem.New(GlobalConfig.MaxStar)
    self.stageItem:InitCtrl(parent, true)
  end
end
function UIWeaponBreakContentView:InitScrollListChild(parent, isFullScreen)
  isFullScreen = isFullScreen or false
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(itemPrefab.childItem)
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
  end
  return obj
end
function UIWeaponBreakContentView:OnClose()
  for _, skill in pairs(self.skillList) do
    if skill then
      gfdestroy(skill.obj)
    end
  end
  self.skillList = {}
  for _, addBtn in pairs(self.addBtnList) do
    if addBtn then
      gfdestroy(addBtn)
    end
  end
  self.addBtnList = {}
end
