require("UI.UIBaseCtrl")
UISimCombatNoteSelItem = class("UISimCombatNoteSelItem", UIBaseCtrl)
UISimCombatNoteSelItem.__index = UISimCombatNoteSelItem
UISimCombatNoteSelItem.mImg_Icon = nil
UISimCombatNoteSelItem.mText_Name = nil
UISimCombatNoteSelItem.mText_Sub = nil
function UISimCombatNoteSelItem:__InitCtrl()
end
function UISimCombatNoteSelItem:ctor()
  self.itemList = {}
end
function UISimCombatNoteSelItem:InitCtrl(parent)
  self.parent = parent
  local obj = instantiate(UIUtils.GetGizmosPrefab("SimCombatTutoria/Btn_SimCombatNoteSelItem.prefab", self))
  self:SetRoot(obj.transform)
  obj.transform:SetParent(parent, false)
  obj.transform.localScale = vectorone
  self:__InitCtrl()
  self.ui = {}
  self:LuaUIBindTable(obj.transform, self.ui)
end
function UISimCombatNoteSelItem:SetData(data)
  self.mData = data
  self.ui.mText_Num.text = data.ppt_number.str
  self.ui.mText_NoteName.text = data.ppt_name.str
end
function UISimCombatNoteSelItem:SetLock(isLock)
  setactive(self.ui.mTrans_Lock, isLock)
end
function UISimCombatNoteSelItem:SetRedPoint(show)
  setactive(self.ui.mTrans_RedPoint, show)
end
