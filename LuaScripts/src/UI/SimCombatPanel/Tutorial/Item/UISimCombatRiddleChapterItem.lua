require("UI.UIBaseCtrl")
UISimCombatRiddleChapterItem = class("UISimCombatRiddleChapterItem", UIBaseCtrl)
UISimCombatRiddleChapterItem.__index = UISimCombatRiddleChapterItem
UISimCombatRiddleChapterItem.mImg_Icon = nil
UISimCombatRiddleChapterItem.mText_Name = nil
UISimCombatRiddleChapterItem.mText_Sub = nil
function UISimCombatRiddleChapterItem:__InitCtrl()
end
function UISimCombatRiddleChapterItem:ctor()
  self.itemList = {}
end
function UISimCombatRiddleChapterItem:InitCtrl(parent)
  self.parent = parent
  local obj = instantiate(UIUtils.GetGizmosPrefab("SimCombatTutoria/Btn_SimCombatRiddleChapterItem.prefab", self))
  self:SetRoot(obj.transform)
  obj.transform:SetParent(parent, false)
  obj.transform.localScale = vectorone
  self:__InitCtrl()
  self.ui = {}
  self:LuaUIBindTable(obj.transform, self.ui)
end
function UISimCombatRiddleChapterItem:SetData(data)
  self.mData = data
  self.ui.mText_Num.text = data.StcData.number.str
  self.ui.mText_Name.text = data.StageData.name.str
  setactive(self.ui.mObj_RedPoint, false)
  if data.IsCompleted then
    self.ui.mAnimator_Root:SetInteger("Switch", 2)
    self.ui.mText_State.text = TableData.GetHintById(103084)
  elseif data.IsUnlocked then
    self.ui.mAnimator_Root:SetInteger("Switch", 1)
    self.ui.mText_State.text = TableData.GetHintById(103083)
  else
    self.ui.mAnimator_Root:SetInteger("Switch", 0)
    self.ui.mText_State.text = TableData.GetHintById(103073)
  end
  setactive(self.ui.mTrans_Now, data.IsUnlocked and not data.IsCompleted)
end
function UISimCombatRiddleChapterItem:SetSelected(isChoose)
  self.ui.mBtn_Self.interactable = not isChoose
end
