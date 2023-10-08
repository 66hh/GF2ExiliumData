require("UI.UIBaseCtrl")
require("UI.SimCombatPanelV2.SimCombatMythicConfig")
require("UI.Common.UICommonItem")
SimCombatMythicPeriodicRewardSubItem = class("SimCombatMythicPeriodicRewardSubItem", UIBaseCtrl)
local self = SimCombatMythicPeriodicRewardSubItem
function SimCombatMythicPeriodicRewardSubItem:ctor()
end
function SimCombatMythicPeriodicRewardSubItem:__InitCtrl()
  self.mText_Title = self:GetText("Text_Content")
  self.mTrans_State = self:GetRectTransform("GrpState")
  self.mTrans_State_UnComplete = self:GetRectTransform("GrpState/TextUnComplete")
  self.mTrans_State_Complete = self:GetRectTransform("GrpState/ImgComplete")
  local scrollContent = self:GetRectTransform("GrpItem")
  self.mScrollListChild_GrpItem = scrollContent:GetComponent(typeof(CS.ScrollListChild))
end
function SimCombatMythicPeriodicRewardSubItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  self.canvasGroup = instObj.gameObject:GetComponent(typeof(CS.UnityEngine.CanvasGroup))
  self.canvasGroup.alpha = 0
  self.rewardIconItems = {}
  self.fadeInTime = 0.05
end
function SimCombatMythicPeriodicRewardSubItem:SetData(groupId, stageLevelIndex, stageLevelId)
  local stageLevelConfig = TableData.listSimCombatMythicLevelDatas:GetDataById(stageLevelId)
  self.ui.mText_Content.text = string_format(TableData.GetHintById(103119), stageLevelConfig.level_name)
  local wage = stageLevelConfig.wage
  local index = 1
  for k, v in pairs(wage) do
    local item
    if self.rewardIconItems[index] == nil then
      item = UICommonItem.New()
      item:InitCtrl(self.ui.mScrollListChild_GrpItem.gameObject, true)
      table.insert(self.rewardIconItems, item)
    else
      item = self.rewardIconItems[k]
    end
    item:SetItemData(k, v, false, false)
    index = index + 1
  end
  local stageLevelState = NetCmdSimCombatMythicData:GetStageLevelState(groupId, stageLevelIndex)
  local isFinish = false
  if stageLevelState == SimCombatMythicConfig.StageLevelState.FINISH_ADVANCE then
    isFinish = true
  end
  setactive(self.ui.mTrans_State_UnComplete, not isFinish)
  setactive(self.ui.mTrans_State_Complete, isFinish)
end
function SimCombatMythicPeriodicRewardSubItem:PlayFadeIn()
  CS.UITweenManager.CanvasGroupDoFade(self.canvasGroup.transform, self.fadeInTime, 0, 1)
  self.ui.mAnimator:Play("Ani_SimCombatMythicComTargetItem_FadeIn", 0, 0)
end
function SimCombatMythicPeriodicRewardSubItem:OnRelease()
  self:DestroySelf()
  self.rewardIconItems = {}
end
