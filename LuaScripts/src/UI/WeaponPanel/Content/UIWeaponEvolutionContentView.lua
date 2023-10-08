require("UI.UIBaseView")
UIWeaponEvolutionContentView = class("UIWeaponEvolutionContentView", UIBaseView)
UIWeaponEvolutionContentView.__index = UIWeaponEvolutionContentView
function UIWeaponEvolutionContentView:ctor()
  UIWeaponEvolutionContentView.super.ctor(self)
  self.ui = {}
  self.stageItem = nil
  self.skillItem = {}
  self.addBtnList = {}
end
function UIWeaponEvolutionContentView:__InitCtrl(weaponList)
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.mBtn_LevelUp = self.ui.mBtn_LevelUp
  self.mText_Name = self.ui.mText_Name
  self.mText_Type = self.ui.mText_Type
  self.mText_Level = self.ui.mText_Level
  self.mTrans_PropList = self.ui.mTrans_GrpAttribute
  self.mTrans_SkillList = self.ui.mTrans_GrpSkill
  self.mImg_Line = self.ui.mImg_Line
  self.mTrans_Stage = self.ui.mTrans_GrpStage
  self.mToggle_DetailCompare = self.ui.mToggle_DetailCompare
  self.mTrans_CompareDetail = self.ui.mTrans_CompareDetail
  self.mTrans_ItemBrief = self.ui.mTrans_CompareDetail
  self.mTrans_Mask = UIWeaponPanelView.mTrans_Mask
  local obj = self:InstanceUIPrefab("Character/ChrWeaponSkillItemV2.prefab", self.mTrans_SkillList, true)
  self.skillItem = self:InitSkillItem(obj)
  self:InitStageItem()
end
function UIWeaponEvolutionContentView:InitCtrl(root, weaponList)
  self:SetRoot(root)
  self:__InitCtrl(weaponList)
end
function UIWeaponEvolutionContentView:InitSkillItem(obj)
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
function UIWeaponEvolutionContentView:InitStageItem()
  if self.stageItem == nil then
    self.stageItem = UICommonStageItem.New(GlobalConfig.MaxStar)
    self.stageItem:InitCtrl(self.mTrans_Stage)
  end
end
