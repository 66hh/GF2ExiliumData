NewTaskPhaseLineItem = class("NewTaskPhaseLineItem", UIBaseCtrl)
function NewTaskPhaseLineItem:ctor(go, parent)
  local obj = instantiate(go, parent)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
function NewTaskPhaseLineItem:SetData(isShow)
  setactive(self:GetRoot(), true)
  setactive(self.ui.mTrans_ImgNone, not isShow)
  setactive(self.ui.mTrans_ImgLine, false)
  setactive(self.ui.mTrans_Complete, isShow)
end
function NewTaskPhaseLineItem:SetColor(color)
  self.ui.mImg_LIne.color = color
end
function NewTaskPhaseLineItem:SetIsCur(isCur)
  setactive(self.ui.mTrans_Complete, not isCur)
  setactive(self.ui.mTrans_ImgLine, isCur)
end
