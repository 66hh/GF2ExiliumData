require("UI.UIBaseCtrl")
UISimCombatTutorialChapterItem = class("UISimCombatTutorialChapterItem", UIBaseCtrl)
UISimCombatTutorialChapterItem.__index = UISimCombatTutorialChapterItem
UISimCombatTutorialChapterItem.mImg_Icon = nil
UISimCombatTutorialChapterItem.mText_Name = nil
UISimCombatTutorialChapterItem.mText_Sub = nil
function UISimCombatTutorialChapterItem:__InitCtrl()
end
function UISimCombatTutorialChapterItem:ctor()
  self.itemList = {}
end
function UISimCombatTutorialChapterItem:InitCtrl(parent)
  self.parent = parent
  local obj = instantiate(UIUtils.GetGizmosPrefab("SimCombatTutoria/Btn_SimCombatTeachingChapterItem.prefab", self))
  self:SetRoot(obj.transform)
  obj.transform:SetParent(parent, false)
  obj.transform.localScale = vectorone
  self:__InitCtrl()
  self.ui = {}
  self:LuaUIBindTable(obj.transform, self.ui)
end
function UISimCombatTutorialChapterItem:SetData(data)
  self.mData = data
  self.ui.mText_Num.text = data.StcData.number.str
  self.ui.mText_Title.text = data.StageData.name.str
  setactive(self.ui.mObj_RedPoint, false)
  local showGuide = data.IsUnlocked and not data.IsCompleted and data.StcData.tutorials_mark > 0
  setactive(self.ui.mTrans_ImgGuide, showGuide)
  setactive(self.ui.mTrans_Now, data.IsUnlocked and not data.IsCompleted)
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
end
function UISimCombatTutorialChapterItem:SetSelected(isChoose)
  self.ui.mBtn_Self.interactable = not isChoose
end
function UISimCombatTutorialChapterItem:TriggerGuide()
  setactive(self.ui.mTrans_ImgGuide, true)
  self.ui.mAnimator_Root:SetTrigger("Guide_FadeOut")
end
