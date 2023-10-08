UIPVPQuestDotItem = class("UIPVPQuestDotItem", UIBaseCtrl)
function UIPVPQuestDotItem:ctor()
end
function UIPVPQuestDotItem:InitCtrl(obj, parent)
  local instObj = instantiate(obj, parent)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  self:SetRoot(instObj.transform)
  setactive(instObj, true)
end
function UIPVPQuestDotItem:SetActivate(IsAct)
  setactive(self.ui.mTrans_Activated, IsAct)
  setactive(self.ui.mTrans_NotActivated, not IsAct)
end
