require("UI.UIBaseCtrl")
UICommonLeftTabItemV2 = class("UICommonLeftTabItemV2", UIBaseCtrl)
UICommonLeftTabItemV2.__index = UICommonLeftTabItemV2
UICommonLeftTabItemV2.mText_Name = nil
UICommonLeftTabItemV2.mTrans_Locked = nil
function UICommonLeftTabItemV2:__InitCtrl()
  self.mText_Name = self.ui.mText_Name
  self.mTrans_Locked = self.ui.mTrans_Locked
  self.mTrans_RedPoint = self.ui.mTrans_RedPoint
  self.mText_Num = self.ui.mText_RandomNum
end
function UICommonLeftTabItemV2:InitCtrl(root)
  self.ui = {}
  self:SetRoot(root)
  self:LuaUIBindTable(root, self.ui)
  self:__InitCtrl()
  self.mBtn = self.ui.mBtn_Self
end
function UICommonLeftTabItemV2:SetName(id, name)
  if name then
    self.tagId = id
    self.ui.mText_Name.text = name
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UICommonLeftTabItemV2:SetRedPoint(enable)
  setactive(self.mTrans_RedPoint, enable)
end
function UICommonLeftTabItemV2:SetItemState(isChoose)
  self.isChoose = isChoose
  self.ui.mBtn_Self.interactable = not self.isChoose
end
function UICommonLeftTabItemV2:SetUnlock(id)
  if id and 0 < id and self.ui.mTrans_Locked then
    setactive(self.ui.mTrans_Locked, not AccountNetCmdHandler:CheckSystemIsUnLock(id))
  end
end
function UICommonLeftTabItemV2.GetRandomNum()
  local num1 = math.random(100, 999)
  local num2 = math.random(100, 999)
  return num1 .. "-" .. num2
end
function UICommonLeftTabItemV2.GetRandomNum()
  local num1 = math.random(100, 999)
  local num2 = math.random(100, 999)
  local num3 = math.random(100, 999)
  return num1 .. "-" .. num2 .. "-" .. num3
end
