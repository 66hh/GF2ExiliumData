require("UI.UIBaseCtrl")
UISimCombatRiddleItem = class("UISimCombatRiddleItem", UIBaseCtrl)
UISimCombatRiddleItem.__index = UISimCombatRiddleItem
UISimCombatRiddleItem.mImg_Icon = nil
UISimCombatRiddleItem.mText_Name = nil
UISimCombatRiddleItem.mText_Sub = nil
function UISimCombatRiddleItem:__InitCtrl()
end
function UISimCombatRiddleItem:ctor()
  self.itemList = {}
end
function UISimCombatRiddleItem:InitCtrl(parent)
  self.parent = parent
  local obj = instantiate(UIUtils.GetGizmosPrefab("SimCombatTutoria/Btn_SimCombatRiddleItem.prefab", self))
  self:SetRoot(obj.transform)
  obj.transform:SetParent(parent, false)
  obj.transform.localScale = vectorone
  self:__InitCtrl()
  self.ui = {}
  self:LuaUIBindTable(obj.transform, self.ui)
end
function UISimCombatRiddleItem:SetData(data)
  self.mData = data
  self.ui.mText_Title.text = data.StcData.chapter_name.str
  self.ui.mText_Num.text = string.format("-", data.StcData.id % 10)
  self.ui.mImg_Icon.sprite = IconUtils.GetAtlasV2("SimCombatTeaching", data.StcData.chapter_icon)
  if data.IsUnlocked and data.IsPrevCompleted then
    self.ui.mAnimator_Root:SetBool("Locked", false)
    setactive(self.ui.mTrans_Lock, false)
    if data.Progress < 100 then
      setactive(self.ui.mTrans_Finish, false)
      setactive(self.ui.mTrans_Progress, true)
      self.ui.mText_Progress.text = TableData.GetHintById(103038) .. ": " .. data.Progress .. "%"
    else
      setactive(self.ui.mTrans_Finish, true)
      setactive(self.ui.mTrans_Progress, false)
    end
  else
    self.ui.mAnimator_Root:SetBool("Locked", true)
    setactive(self.ui.mTrans_Lock, true)
  end
  setactive(self.ui.mTrans_RedPoint, data.IsCompleted and not data.IsReceived or data:CheckRedPoint())
end
