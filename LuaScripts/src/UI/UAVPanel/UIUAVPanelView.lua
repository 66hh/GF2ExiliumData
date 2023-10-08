require("UI.UIBaseView")
UIUAVPanelView = class("UIUAVPanelView", UIBaseView)
UIUAVPanelView.__index = UIUAVPanelView
function UIUAVPanelView.ctor()
  UIUAVPanelView.super.ctor(self)
end
function UIUAVPanelView:__InitCtrl()
  self.mAnimator = self.ui.mAnimator
  self.mAnimator:SetInteger("UAVInfo", 0)
  self.mAnimator:SetInteger("List", 3)
  self.mTrans_UAVInfo = self.ui.mTrans_UAVInfo
  self.mTrans_UAVPartsInfo = self.ui.mTrans_UAVPartsInfo
  self.mTrans_GrpPartsInfo = self.ui.mTrans_GrpPartsInfo
  self.mCanvasgroup = self.ui.mCanvasgroup
  self.mTrans_GrpSKill = self.ui.mTrans_GrpSKill
  self.mBtn_Close = self.ui.mBtn_Close
  self.mBtn_CommandCenter = self.ui.mBtn_CommandCenter
  self.mBtn_Fuel = self.ui.mBtn_Fuel
  self.mImage_FuelProgress = self.ui.mImage_FuelProgress
  self.mText_FuelName = self.ui.mText_FuelName
  self.mText_NowFuelNum = self.ui.mText_NowFuelNum
  self.mText_TotalFuelNum = self.ui.mText_TotalFuelNum
  self.mTrans_LevelUp = self.ui.mTrans_LevelUp
  self.mTrans_Break = self.ui.mTrans_Break
  self.mTrans_MaxLevel = self.ui.mTrans_MaxLevel
  self.mTrans_Skill = self.ui.mTrans_Skill
  self.mTrans_Cost = self.ui.mTrans_Cost
  self.mText_CostName = self.ui.mText_CostName
  self.mTrans_RightSkillContent = self.ui.mTrans_RightSkillContent
  self.mText_UAVName = self.ui.mText_UAVName
  self.mText_UAVLevel = self.ui.mText_UAVLevel
  self.mTrans_AttributeList = self.ui.mTrans_AttributeList
  self.mText_HPName = self.ui.mText_HPName
  self.mText_HPNum = self.ui.mText_HPNum
  self.mText_ATKName = self.ui.mText_ATKName
  self.mText_ATKNum = self.ui.mText_ATKNum
  self.mText_DEFName = self.ui.mText_DEFName
  self.mText_DEFNum = self.ui.mText_DEFNum
  self.mText_HasEquipedSkill = self.ui.mText_HasEquipedSkill
  self.mText_ContrastName = self.ui.mText_ContrastName
  self.mToggle_Contrast = self.ui.mToggle_Contrast
  self.mText_SkllName = self.ui.mText_SkllName
  self.mText_SkillLevel = self.ui.mText_SkillLevel
  self.mText_RangeName = self.ui.mText_RangeName
  self.mToggle_Range = self.ui.mToggle_Range
  self.mText_OilCost = self.ui.mText_OilCost
  self.mText_OilCostNum = self.ui.mText_OilCostNum
  self.mText_UseTimesDes = self.ui.mText_UseTimesDes
  self.mText_UseTimesNum = self.ui.mText_UseTimesNum
  self.mText_SkillDes = self.ui.mText_SkillDes
  self.mTrans_BtnReplace = self.ui.mTrans_BtnReplace
  self.mTrans_BtnUnistall = self.ui.mTrans_BtnUnistall
  self.mTrans_BtnEquip = self.ui.mTrans_BtnEquip
  self.mTrans_BtnPowerUp = self.ui.mTrans_BtnPowerUp
  self.mTrans_BtnUnLock = self.ui.mTrans_BtnUnLock
  self.mTrans_ArmMaxLevel = self.ui.mTrans_ArmMaxLevel
  self.mText_MaxLevelName = self.ui.mText_MaxLevelName
  self.mTrans_LeftSkillList = self.ui.mTrans_LeftSkillList
  self.mCanvas_ScrollBar = self.ui.mCanvas_ScrollBar
  self.mTrans_LeftSkillListContent = self.ui.mTrans_LeftSkillListContent
  self.mTrans_NoEquip = self.ui.mTrans_NoEquip
  self.mTrans_RightSKiillInfo = self.ui.mTrans_RightSKiillInfo
  self.mTrans_ArmLock = self.ui.mTrans_ArmLock
  self.mImage_RightLeftUpIcon = self.ui.mImage_RightLeftUpIcon
  self.mImage_RightSkillIcon = self.ui.mImage_RightSkillIcon
  self.mText_RightCostNum = self.ui.mText_RightCostNum
  self.mTrans_UnlockItem = self.ui.mTrans_UnlockItem
  self.mTrans_GrpSkill = self.ui.mTrans_GrpSkill
  self.mTrans_BtnSave = self.ui.mTrans_BtnSave
  self.mAnim = self.ui.mAnim
  self.mTrans_ScrollContent = self.ui.mTrans_ScrollContent
  self.mTrans_LevelUpContentParent = self.ui.mTrans_LevelUpContentParent
  self.mTrans_SkillRange = self.ui.mTrans_SkillRange
  self.mBtn_CloseRange = self.ui.mBtn_CloseRange
  self.mTrans_ContrastDialogParent = self.ui.mTrans_ContrastDialogParent
  self.mLayoutlist = {}
  self.mTrans_layout1 = self.ui.mTrans_layout1
  self.mTrans_layout2 = self.ui.mTrans_layout2
  self.mTrans_layout3 = self.ui.mTrans_layout3
  self.mTotalFuelNum = self.ui.mText_TotalNum
  self.mNowFuelNum = self.ui.mText_NowNum
  self.mImgProgress = self.ui.mImg_Progress1
  table.insert(self.mLayoutlist, getcomponent(self.mTrans_layout1, typeof(CS.GridLayout)))
  table.insert(self.mLayoutlist, getcomponent(self.mTrans_layout2, typeof(CS.GridLayout)))
  table.insert(self.mLayoutlist, getcomponent(self.mTrans_layout3, typeof(CS.GridLayout)))
end
function UIUAVPanelView:InitCtrl(root)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:__InitCtrl()
end
