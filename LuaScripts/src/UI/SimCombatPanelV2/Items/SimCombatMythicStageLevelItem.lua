require("UI.UIBaseCtrl")
require("UI.SimCombatPanelV2.SimCombatMythicConfig")
SimCombatMythicStageLevelItem = class("SimCombatMythicStageItem", UIBaseCtrl)
local self = SimCombatMythicStageLevelItem
function SimCombatMythicStageLevelItem:ctor()
  self.mClickCallBack = nil
  self.mStageLevelId = 0
end
function SimCombatMythicStageLevelItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  UIUtils.GetButtonListener(self.ui.mBtn_SimCombatMythicLeftTabItem.gameObject).onClick = function()
    self:OnClickItem()
  end
end
function SimCombatMythicStageLevelItem:SetData(groupId, stageLevelId, stageLevelIndex)
  self.groupId = groupId
  self.mStageLevelId = stageLevelId
  self.mStageLevelIndex = stageLevelIndex
  local levelCfg = TableData.listSimCombatMythicLevelDatas:GetDataById(self.mStageLevelId)
  self.ui.mText_Name.text = levelCfg.level_name
  self.ui.mText_Num.text = "0" .. tostring(stageLevelIndex)
  self:UpdateItemState()
end
function SimCombatMythicStageLevelItem:UpdateItemState()
  local state = NetCmdSimCombatMythicData:GetStageLevelState(self.groupId, self.mStageLevelIndex)
  setactive(self.ui.mTans_ImgBg.gameObject, true)
  if state == SimCombatMythicConfig.StageLevelState.LOCK then
    setactive(self.ui.mTrans_Lock.gameObject, true)
    setactive(self.ui.mTran_Complete1.gameObject, false)
  elseif state == SimCombatMythicConfig.StageLevelState.FINISH_ADVANCE then
    setactive(self.ui.mTran_Complete1.gameObject, true)
    setactive(self.ui.mTrans_Lock.gameObject, false)
  else
    setactive(self.ui.mTran_Complete1.gameObject, false)
    setactive(self.ui.mTrans_Lock.gameObject, false)
  end
end
function SimCombatMythicStageLevelItem:GetStageLevelId()
  return self.mStageLevelId
end
function SimCombatMythicStageLevelItem:GetStageLevelIndex()
  return self.mStageLevelIndex
end
function SimCombatMythicStageLevelItem:SetSelected(boolean)
  self.ui.mBtn_SimCombatMythicLeftTabItem.interactable = not boolean
end
function SimCombatMythicStageLevelItem:SetClickCallBack(callback)
  self.mClickCallBack = callback
end
function SimCombatMythicStageLevelItem:OnClickItem()
  if self.mClickCallBack ~= nil then
    self.mClickCallBack()
  end
end
function SimCombatMythicStageLevelItem:SetMode(itemState, itemMode, picId)
end
function SimCombatMythicStageLevelItem:OnRelease()
  self:DestroySelf()
end
