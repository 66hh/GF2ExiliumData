require("UI.UIBaseView")
UIWeaponEnhanceContentView = class("UIWeaponEnhanceContentView", UIBaseView)
UIWeaponEnhanceContentView.__index = UIWeaponEnhanceContentView
function UIWeaponEnhanceContentView:ctor()
  UIWeaponEnhanceContentView.super.ctor(self)
  self.ui = {}
  self.stageItem = nil
  self.skillItem = {}
  self.addBtnList = {}
end
function UIWeaponEnhanceContentView:__InitCtrl(weaponList)
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.mBtn_LevelUp = self.ui.mBtn_LevelUp
  self.mBtn_AddItem = self.ui.mBtn_AddItem
  self.mText_Name = self.ui.mText_Name
  self.mText_Type = self.ui.mText_Type
  self.mText_LevelNow = self.ui.mText_LevelNow
  self.mText_LevelMax = self.ui.mText_LevelMax
  self.mText_Exp = self.ui.mText_Exp
  self.mText_AddExp = self.ui.mText_AddExp
  self.mImage_ExpAfter = self.ui.mImage_ExpAfter
  self.mImage_ExpBefore = self.ui.mImage_ExpBefore
  self.mTrans_PropList = self.ui.mTrans_PropList
  self.mTrans_SkillList = self.ui.mTrans_SkillList
  self.mTrans_MaterialList = self.ui.mTrans_MaterialList
  self.mTrans_AddItemList = self.ui.mTrans_AddItemList
  self.mTrans_ExpAdd = self.ui.mTrans_ExpAdd
  self.mTrans_Stage = self.ui.mTrans_Stage
  self.mTrans_CostCoin = self.ui.mTrans_CostCoin
  self.mTrans_BtnLevelUp = self.ui.mTrans_BtnLevelUp
  self.mTrans_MaxLevel = self.ui.mTrans_MaxLevel
  self.mText_CostCoin = self.ui.mText_CostCoin
  self.mTrans_AddItem = self.ui.mTrans_AddItem
  self.mTrans_Mask = UIWeaponPanelView.mTrans_Mask
  self.mTrans_EnhanceContent = weaponList.ui.mUIRoot
  self.mBtn_CloseList = weaponList.ui.mBtn_CloseList
  self.mBtn_AutoSelect = weaponList.ui.mBtn_AutoSelect
  self.mTrans_Sort = weaponList.ui.mTrans_Sort
  self.mTrans_SortList = weaponList.ui.mTrans_SortList
  self.mTrans_WeaponScroll = weaponList.ui.mTrans_WeaponScroll
  self.mTrans_ItemBrief = weaponList.ui.mTrans_ItemBrief
  self.mTrans_AutoSelect = weaponList.ui.mTrans_AutoSelect
  self.mTrans_Empty = weaponList.ui.mTrans_Empty
  self.mVirtualList = weaponList.ui.mVirtualList
  self.mListAnimator = weaponList.ui.mListAnimator
  self.mListAniTime = weaponList.ui.mListAniTime
  self.mText_TypeName = weaponList.ui.mText_TypeName
  self.mText_SelectNum = self.ui.mText_SelectNum
  self.mTrans_SelectNum = self.ui.mTrans_SelectNum
  self.mTrans_ChrMaxLevel = self.ui.mTrans_ChrMaxLevel
  self:InitStageItem()
end
function UIWeaponEnhanceContentView:InitCtrl(root, weaponList)
  self:SetRoot(root)
  self:__InitCtrl(weaponList)
end
function UIWeaponEnhanceContentView:InitSkillItem(obj)
  if obj then
    local skill = {}
    skill.obj = obj
    skill.txtName = UIUtils.GetText(obj, "GrpNameInfo/GrpTextName/Text_SkillName")
    skill.txtLv = UIUtils.GetText(obj, "GrpNameInfo/GrpTextName/Trans_Text_Lv")
    skill.txtNum = UIUtils.GetText(obj, "GrpNameInfo/GrpTextName/Trans_Text_Num")
    skill.txtDesc = UIUtils.GetText(obj, "Text_Describe")
    return skill
  end
end
function UIWeaponEnhanceContentView:InitStageItem()
  if self.stageItem == nil then
    self.stageItem = UICommonStageItem.New(GlobalConfig.MaxStar)
    self.stageItem:InitCtrl(self.mTrans_Stage, true)
  end
end
function UIWeaponEnhanceContentView:OnClose()
  if self.stageItem == nil then
    self.stageItem:OnRelease()
  end
end
