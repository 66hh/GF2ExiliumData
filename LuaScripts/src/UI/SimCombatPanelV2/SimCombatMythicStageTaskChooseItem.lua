require("UI.UIBaseCtrl")
require("UI.SimCombatPanelV2.SimCombatMythicConfig")
SimCombatMythicStageTaskChooseItem = class("SimCombatMythicStageTaskChooseItem", UIBaseCtrl)
local self = SimCombatMythicStageTaskChooseItem
function SimCombatMythicStageTaskChooseItem:ctor()
  self.mClickCallBack = nil
end
function SimCombatMythicStageTaskChooseItem:InitCtrl(parent)
  local itemPrefab = parent.gameObject:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  UIUtils.GetButtonListener(self.ui.mBtn_SimCombatMythicInfoItem.gameObject).onClick = function()
    if self.state ~= SimCombatMythicConfig.StageTaskState.UNLOCK then
      return
    end
    self:OnClickItem()
  end
  self.stageTaskId = 0
  self.state = 0
  self.stageTaskIndex = 0
end
function SimCombatMythicStageTaskChooseItem:SetData(groupId, stageLevelIndex, stageTaskIndex, stageTaskId)
  self.stageTaskId = stageTaskId
  self.groupId = groupId
  self.stageLevelIndex = stageLevelIndex
  self.stageTaskIndex = stageTaskIndex
  local mythicStageConfig = TableData.listSimCombatMythicStagesDatas:GetDataById(stageTaskId)
  self.ui.mText_Content.text = mythicStageConfig.require_desc.str
  self.ui.mImage_Lv.sprite = SimCombatMythicConfig.GetStageTaskLevelNumICon(stageTaskIndex)
  self.ui.mText_Num.text = tostring(stageTaskIndex)
  setactive(self.ui.mTrans_Slc.gameObject, false)
  self:UpdateItemState()
end
function SimCombatMythicStageTaskChooseItem:GetStageTaskId()
  return self.stageTaskId
end
function SimCombatMythicStageTaskChooseItem:GetStageTaskIndex()
  return self.stageTaskIndex
end
function SimCombatMythicStageTaskChooseItem:SetSelected(isSlc)
  if self.state ~= SimCombatMythicConfig.StageTaskState.UNLOCK then
    return
  end
  setactive(self.ui.mTrans_Slc.gameObject, isSlc)
end
function SimCombatMythicStageTaskChooseItem:UpdateItemState()
  self.state = NetCmdSimCombatMythicData:GetStageLevelTaskState(self.groupId, self.stageLevelIndex, self.stageTaskIndex)
  local isFinish = self.state == SimCombatMythicConfig.StageTaskState.FINISH
  local isLock = self.state == SimCombatMythicConfig.StageTaskState.LOCK
  if isFinish or isLock then
    setactive(self.ui.mTrans_Slc.gameObject, false)
  end
  self.ui.mBtn_SimCombatMythicInfoItem.enabled = not isLock
  self.ui.mAnimator:SetBool("Bool", isFinish)
end
function SimCombatMythicStageTaskChooseItem:SetClickCallBack(callback)
  self.mClickCallBack = callback
end
function SimCombatMythicStageTaskChooseItem:OnClickItem()
  if self.mClickCallBack ~= nil then
    self.mClickCallBack()
  end
end
function SimCombatMythicStageTaskChooseItem:OnRelease()
  self:DestroySelf()
end
