require("UI.UIBaseCtrl")
UISimCombatTutorialItem = class("UISimCombatTutorialItem", UIBaseCtrl)
UISimCombatTutorialItem.__index = UISimCombatTutorialItem
UISimCombatTutorialItem.mImg_Icon = nil
UISimCombatTutorialItem.mText_Name = nil
UISimCombatTutorialItem.mText_Sub = nil
function UISimCombatTutorialItem:__InitCtrl()
end
function UISimCombatTutorialItem:ctor()
  self.itemList = {}
end
function UISimCombatTutorialItem:InitCtrl(parent)
  self.parent = parent
  local obj = instantiate(UIUtils.GetGizmosPrefab("SimCombatTutoria/Btn_SimCombatTeachingItem.prefab", self))
  self:SetRoot(obj.transform)
  obj.transform:SetParent(parent, false)
  obj.transform.localScale = vectorone
  self:__InitCtrl()
  self.ui = {}
  self:LuaUIBindTable(obj.transform, self.ui)
end
function UISimCombatTutorialItem:SetNew(enable)
  setactive(self.ui.mTrans_Now, enable)
end
function UISimCombatTutorialItem:SetData(data)
  self.mData = data
  self.ui.mText_Name.text = data.StcData.chapter_name.str
  self.ui.mImg_Icon.sprite = IconUtils.GetAtlasV2("SimCombatTeaching", data.StcData.chapter_icon)
  if data.IsUnlocked and data.IsPrevCompleted then
    setactive(self.ui.mTrans_Lock, false)
    setactive(self.ui.mTrans_Progress, true)
    if data.Progress < 100 then
      setactive(self.ui.mTrans_Finish, false)
      setactive(self.ui.mTrans_Progress, true)
      self.ui.mText_Progress.text = TableData.GetHintById(103038) .. ": " .. data.Progress .. "%"
    else
      setactive(self.ui.mTrans_Finish, true)
      setactive(self.ui.mTrans_Progress, false)
    end
    self:SetNew(not data.IsCompleted)
  else
    setactive(self.ui.mTrans_Lock, true)
    setactive(self.ui.mTrans_Progress, false)
  end
  setactive(self.ui.mTrans_RedPoint, data.IsCompleted and not data.IsReceived or data:CheckRedPoint())
end
