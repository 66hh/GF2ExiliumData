require("UI.UIBaseCtrl")
require("UI.SimCombatPanelV2.SimCombatMythicConfig")
UISimCombatMythicStageLevelDetailItem = class("UISimCombatMythicStageLevelDetailItem", UIBaseCtrl)
local self = UISimCombatMythicStageLevelDetailItem
function UISimCombatMythicStageLevelDetailItem:ctor()
end
function UISimCombatMythicStageLevelDetailItem:__InitCtrl()
  self.mText_Name = self:GetText("GrpTop/TextTitle")
  self.mImage_LV = self:GetImage("GrpTop/Img_Lv")
  self.mTrans_State = self:GetRectTransform("GrpTop/GrpState")
  self.mTrans_State_Img = self:GetRectTransform("GrpTop/GrpState/Trans_ImgEquiped")
  self.mText_State_Text = self:GetText("GrpTop/GrpState/Trans_Text")
  self.rewardIconItemParent = self:GetRectTransform("Content")
  local itemPrefab = self.rewardIconItemparent:GetComponent(typeof(CS.ScrollListChild))
end
function UISimCombatMythicStageLevelDetailItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  self.ui.mAnimator.keepAnimatorControllerStateOnDisable = true
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  self.rewardIconItems = {}
  self.enemyIconItems = {}
end
function UISimCombatMythicStageLevelDetailItem:SetData(stageTaskId, stageTaskIndex, isComplete)
  local mythicStageTaskConfig = TableData.listSimCombatMythicStagesDatas:GetDataById(stageTaskId)
  self.ui.mImage_Num.sprite = SimCombatMythicConfig.GetStageLevelNumICon(stageTaskIndex)
  if 1 < stageTaskIndex then
    self.ui.mText_Title.text = TableData.GetHintById(103106)
  else
    self.ui.mText_Title.text = TableData.GetHintById(103105)
  end
  self.ui.mText_Content.text = mythicStageTaskConfig.require_desc.str
  if 10 <= stageTaskIndex then
    self.ui.mText_LeftTitleNum.text = "//.0" .. tostring(stageTaskIndex)
  else
    self.ui.mText_LeftTitleNum.text = "//.00" .. tostring(stageTaskIndex)
  end
  self.ui.mAnimator:SetBool("Finshed", isComplete)
  setactive(self.ui.mTran_State_Complete.gameObject, isComplete)
  setactive(self.ui.mTran_State_UnComplete.gameObject, not isComplete)
  self.itemCount = 0
  self:SetTaskEnemyInfo(stageTaskId)
  self:SetTaskRewardInfo(stageTaskId)
end
function UISimCombatMythicStageLevelDetailItem:SetTaskEnemyInfo(stageTaskId)
  local stageData = TableData.listStageDatas:GetDataById(stageTaskId)
  local stageConfig = TableData.listStageConfigDatas:GetDataById(stageData.stage_config)
  local enemiesCount = stageConfig.enemies.Count
  self.itemCount = self.itemCount + enemiesCount
  for i = 1, enemiesCount do
    do
      local item
      if self.enemyIconItems[i] == nil then
        item = UICommonEnemyItem.New()
        item:InitCtrl(self.ui.mScrollListChild_GrpEnemy.gameObject)
        table.insert(self.enemyIconItems, item)
      else
        item = self.enemyIconItems[i]
      end
      local enemyId = stageConfig.enemies[enemiesCount - i]
      local enemyData = TableData.GetEnemyData(enemyId)
      item:SetData(enemyData, stageData.stage_class)
      item:EnableLv(true)
      UIUtils.GetButtonListener(item.mBtn_OpenDetail.gameObject).onClick = function()
        CS.RoleInfoCtrlHelper.Instance:InitSysEnemyData(enemyData, stageData.stage_class + enemyData.add_level)
      end
    end
  end
end
function UISimCombatMythicStageLevelDetailItem:SetTaskRewardInfo(stageTaskId)
  local mythicStageTaskConfig = TableData.listSimCombatMythicStagesDatas:GetDataById(stageTaskId)
  local reward = mythicStageTaskConfig.reward
  local index = 1
  for k, v in pairs(reward) do
    local item
    if self.rewardIconItems[index] == nil then
      item = UICommonItem.New()
      item:InitCtrl(self.ui.mScrollListChild_GrpReward.gameObject, true)
      table.insert(self.rewardIconItems, item)
    else
      item = self.rewardIconItems[index]
    end
    item:SetItemData(k, v, false, false)
    index = index + 1
  end
end
function UISimCombatMythicStageLevelDetailItem:SetSelected(boolean)
end
function UISimCombatMythicStageLevelDetailItem:OnRelease()
  self:DestroySelf()
end
