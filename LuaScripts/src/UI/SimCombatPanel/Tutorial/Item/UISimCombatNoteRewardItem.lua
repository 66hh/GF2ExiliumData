require("UI.UIBaseCtrl")
UISimCombatNoteRewardItem = class("UISimCombatNoteRewardItem", UIBaseCtrl)
UISimCombatNoteRewardItem.__index = UISimCombatNoteRewardItem
function UISimCombatNoteRewardItem:__InitCtrl()
end
function UISimCombatNoteRewardItem:ctor()
  self.itemList = {}
end
function UISimCombatNoteRewardItem:InitCtrl(parent)
  self.parent = parent
  local obj = instantiate(UIUtils.GetGizmosPrefab("SimCombatTutoria/SimCombatNoteRewardItem.prefab", self))
  self:SetRoot(obj.transform)
  obj.transform:SetParent(parent, false)
  obj.transform.localScale = vectorone
  self:__InitCtrl()
  self.ui = {}
  self:LuaUIBindTable(obj.transform, self.ui)
  self.noteList = {}
  if self.rewardItem == nil then
    self.rewardItem = UICommonItem.New()
    self.rewardItem:InitObj(self.ui.mObj_GrpReward)
  end
end
function UISimCombatNoteRewardItem:SetData(data)
  self.mData = data
  self.ui.mText_Num.text = string.format("-", data.ppt_progress)
  for itemId, num in pairs(data.progress_reward) do
    self.rewardItem:SetItemData(itemId, num)
  end
end
function UISimCombatNoteRewardItem:SetComplete(complete)
  setactive(self.ui.mTrans_ReceivedIcon, complete)
end
function UISimCombatNoteRewardItem:SetLocked(locked)
  self.ui.mAnimator_Self:SetBool("Locked", locked)
end
