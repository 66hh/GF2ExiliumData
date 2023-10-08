require("UI.UIBaseCtrl")
require("UI.SimCombatPanelV2.SimCombatMythicConfig")
require("UI.SimCombatPanelV2.Items.SimCombatMythicPeriodicRewardSubItem")
SimCombatMythicPeriodicRewardItem = class("SimCombatMythicPeriodicRewardItem", UIBaseCtrl)
local self = SimCombatMythicPeriodicRewardItem
function SimCombatMythicPeriodicRewardItem:ctor()
end
function SimCombatMythicPeriodicRewardItem:__InitCtrl()
  self.mText_Name = self:GetText("GrpTop/TextTitle")
  self.mTrans_State = self:GetRectTransform("GrpTop/GrpState")
  self.mTrans_State_Img = self:GetRectTransform("GrpTop/GrpState/Trans_ImgEquiped")
  self.mText_State_Text = self:GetText("GrpTop/GrpState/Trans_Text")
  self.rewardIconItemParent = self:GetRectTransform("Content")
  local itemPrefab = self.rewardIconItemparent:GetComponent(typeof(CS.ScrollListChild))
end
function SimCombatMythicPeriodicRewardItem:InitCtrl(parent)
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
  self.subItems = {}
  self.subItemCount = 0
  self.canvasGroup = instObj.gameObject:GetComponent(typeof(CS.UnityEngine.CanvasGroup))
  self.canvasGroup.alpha = 0
  self.fadeInInterval = 0.05
end
function SimCombatMythicPeriodicRewardItem:SetData(data)
  self.ui.mText_Title.text = data.goup_name.str
  local curStageGroupId = NetCmdSimCombatMythicData:GetStageGroupLevelGroupId(data.id)
  local stageConfig = TableData.listSimCombatMythicConfigDatas:GetDataById(curStageGroupId)
  local stages = stageConfig.stage
  self.subItemCount = stages.Length
  for i = 1, self.subItemCount do
    local stageId = stages[i - 1]
    local item
    if self.subItems[i] == nil then
      item = SimCombatMythicPeriodicRewardSubItem.New()
      item:InitCtrl(self.ui.mScrollListChild_GrpItem.gameObject)
      table.insert(self.subItems, item)
    else
      item = self.subItems[i]
    end
    item:SetData(data.id, i, stageId)
  end
  local isFinish = NetCmdSimCombatMythicData:CheckStageGroupIsAllFinish(data.id)
  setactive(self.ui.mTran_StateComplete.gameObject, isFinish)
  self.ui.mAnimator:SetBool("Finshed", isFinish)
  if data.id >= 10 then
    self.ui.mText_LeftTitleNum.text = "//.0" .. tostring(data.id)
  else
    self.ui.mText_LeftTitleNum.text = "//.00" .. tostring(data.id)
  end
end
function SimCombatMythicPeriodicRewardItem:PlayFadeIn()
  CS.UITweenManager.CanvasGroupDoFade(self.canvasGroup.transform, self.fadeInInterval, 0, 1)
  self.ui.mAnimator:Play("Ani_SimCombatMythiComInfoItem_FadeIn", 1, 0)
  self.fadeInTimer = TimerSys:DelayCall(self.fadeInInterval, function()
    self:PlaySubItemFadeIn(1)
  end)
end
function SimCombatMythicPeriodicRewardItem:PlaySubItemFadeIn(index)
  if index > self.subItemCount then
    return
  end
  local item = self.subItems[index]
  item:PlayFadeIn()
  self.fadeInTimer = TimerSys:DelayCall(self.fadeInInterval, function()
    self:PlaySubItemFadeIn(index + 1)
  end)
end
function SimCombatMythicPeriodicRewardItem:GetFadeInTime()
  return (self.subItemCount + 1) * self.fadeInInterval
end
function SimCombatMythicPeriodicRewardItem:CloseFadeInTime()
  if self.fadeInTimer ~= nil then
    self.fadeInTimer:Abort()
    self.fadeInTimer = nil
  end
end
function SimCombatMythicPeriodicRewardItem:OnRelease()
  self:DestroySelf()
  self:CloseFadeInTime()
end
