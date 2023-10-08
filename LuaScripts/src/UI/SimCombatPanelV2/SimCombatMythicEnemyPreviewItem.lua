require("UI.UIBaseCtrl")
require("UI.SimCombatPanelV2.SimCombatMythicConfig")
SimCombatMythicEnemyPreviewItem = class("SimCombatMythicEnemyPreviewItem", UIBaseCtrl)
local self = SimCombatMythicEnemyPreviewItem
function SimCombatMythicEnemyPreviewItem:ctor()
end
function SimCombatMythicEnemyPreviewItem:__InitCtrl()
  self.mText_Name = self:GetText("GrpTop/TextTitle")
  self.mImage_LV = self:GetImage("GrpTop/Img_Lv")
  self.mTrans_State = self:GetRectTransform("GrpTop/GrpState")
  self.mTrans_State_Img = self:GetRectTransform("GrpTop/GrpState/Trans_ImgEquiped")
  self.mText_State_Text = self:GetText("GrpTop/GrpState/Trans_Text")
  self.enemyItemParent = self:GetRectTransform("Content")
  local itemPrefab = self.enemyItemparent:GetComponent(typeof(CS.ScrollListChild))
end
function SimCombatMythicEnemyPreviewItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  self.ui.mAnimator.keepAnimatorControllerStateOnDisable = true
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  setactive(self.ui.mScrollListChild_GrpItem.gameObject, false)
  setactive(self.ui.mScrollListChild_GrpEnemy.gameObject, true)
  self.enemyIconItems = {}
end
function SimCombatMythicEnemyPreviewItem:SetData(stageTaskId, stageTaskIndex, isComplete)
  self.stageTaskId = stageTaskId
  local mythicStageTaskConfig = TableData.listSimCombatMythicStagesDatas:GetDataById(stageTaskId)
  self.ui.mImage_Num.sprite = SimCombatMythicConfig.GetStageLevelNumICon(stageTaskIndex)
  self.ui.mText_Title.text = string_format(TableData.GetHintById(103110), stageTaskIndex)
  self.ui.mText_Content.text = mythicStageTaskConfig.require_desc.str
  self.ui.mAnimator:SetBool("Finshed", isComplete)
  self.ui.mText_TextComplete.text = TableData.GetHintById(103109)
  self.ui.mText_TextUnComplete.text = TableData.GetHintById(103116)
  local stageData = TableData.listStageDatas:GetDataById(stageTaskId)
  local stageConfig = TableData.listStageConfigDatas:GetDataById(stageData.stage_config)
  for i = 1, stageConfig.enemies.Count do
    do
      local item
      if self.enemyIconItems[i] == nil then
        item = UICommonEnemyItem.New()
        item:InitCtrl(self.ui.mScrollListChild_GrpEnemy.gameObject)
      else
        item = self.enemyIconItems[i]
      end
      local enemyId = stageConfig.enemies[i - 1]
      local enemyData = TableData.GetEnemyData(enemyId)
      item:SetData(enemyData, stageData.stage_class)
      item:EnableLv(true)
      UIUtils.GetButtonListener(item.mBtn_OpenDetail.gameObject).onClick = function()
        CS.RoleInfoCtrlHelper.Instance:InitSysEnemyData(enemyData, stageData.stage_class + enemyData.add_level)
      end
    end
  end
end
function SimCombatMythicEnemyPreviewItem:SetSelected(boolean)
end
function SimCombatMythicEnemyPreviewItem:SetClickCallBack(callback)
  self.mClickCallBack = callback
end
function SimCombatMythicEnemyPreviewItem:OnClickItem()
  if self.mClickCallBack ~= nil then
    self.mClickCallBack()
  end
end
function SimCombatMythicEnemyPreviewItem:SetMode(itemState, itemMode, picId)
end
function SimCombatMythicEnemyPreviewItem:OnRelease()
  self:DestroySelf()
end
