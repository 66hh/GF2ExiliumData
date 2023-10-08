require("UI.UIBaseCtrl")
require("UI.SimCombatPanelV2.SimCombatMythicConfig")
SimCombatMythicRewardPreviewItem = class("SimCombatMythicChapterItemV2", UIBaseCtrl)
local self = SimCombatMythicRewardPreviewItem
function SimCombatMythicRewardPreviewItem:ctor()
end
function SimCombatMythicRewardPreviewItem:__InitCtrl()
  self.mText_Name = self:GetText("GrpTop/TextTitle")
  self.mImage_LV = self:GetImage("GrpTop/Img_Lv")
  self.mTrans_State = self:GetRectTransform("GrpTop/GrpState")
  self.mTrans_State_Img = self:GetRectTransform("GrpTop/GrpState/Trans_ImgEquiped")
  self.mText_State_Text = self:GetText("GrpTop/GrpState/Trans_Text")
  self.rewardIconItemParent = self:GetRectTransform("Content")
  local itemPrefab = self.rewardIconItemparent:GetComponent(typeof(CS.ScrollListChild))
end
function SimCombatMythicRewardPreviewItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  self.ui.mAnimator.keepAnimatorControllerStateOnDisable = true
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  setactive(self.ui.mScrollListChild_GrpItem.gameObject, true)
  setactive(self.ui.mScrollListChild_GrpEnemy.gameObject, false)
  self.rewardIconItems = {}
end
function SimCombatMythicRewardPreviewItem:SetData(stageTaskId, stageTaskIndex, isComplete)
  local mythicStageTaskConfig = TableData.listSimCombatMythicStagesDatas:GetDataById(stageTaskId)
  self.ui.mImage_Num.sprite = SimCombatMythicConfig.GetStageLevelNumICon(stageTaskIndex)
  self.ui.mText_Title.text = string_format(TableData.GetHintById(103110), stageTaskIndex)
  self.ui.mText_Content.text = mythicStageTaskConfig.require_desc.str
  local reward = mythicStageTaskConfig.reward
  for k, v in pairs(reward) do
    local item
    if self.rewardIconItems[i] == nil then
      item = UICommonItem.New()
      item:InitCtrl(self.ui.mScrollListChild_GrpItem.gameObject, true)
    else
      item = self.rewardIconItems[i]
    end
    item:SetItemData(k, v, false, true)
  end
  self.ui.mAnimator:SetBool("Finshed", isComplete)
  self.ui.mText_TextComplete.text = TableData.GetHintById(103109)
  self.ui.mText_TextUnComplete.text = TableData.GetHintById(103116)
end
function SimCombatMythicRewardPreviewItem:SetSelected(boolean)
end
function SimCombatMythicRewardPreviewItem:OnRelease()
  self:DestroySelf()
end
