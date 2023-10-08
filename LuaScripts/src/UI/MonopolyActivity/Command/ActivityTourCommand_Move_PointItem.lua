require("UI.UIBaseCtrl")
ActivityTourCommandPointItem = class("ActivityTourCommandPointItem", UIBaseCtrl)
ActivityTourCommandPointItem.__index = ActivityTourCommandPointItem
function ActivityTourCommandPointItem:ctor()
  self.super.ctor(self)
end
function ActivityTourCommandPointItem:InitCtrl(itemPrefab, parent)
  local instObj = instantiate(itemPrefab, parent)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(instObj.transform, self.ui)
end
function ActivityTourCommandPointItem:SetData(num, onclick)
  self.num = num
  local isEmpty = num == nil
  setactive(self.ui.mTrans_Empty, isEmpty)
  setactive(self.ui.mTrans_Num, not isEmpty)
  self:EnableBtn(not isEmpty)
  if isEmpty then
    self.ui.mBtn_Root.enabled = false
    return
  end
  self.ui.mBtn_Root.enabled = true
  self.ui.mImage_Num.sprite = IconUtils.GetAtlasSprite("ActivityTour/Icon_ActivityTourMove_Point_" .. tostring(num))
  UIUtils.AddBtnClickListener(self.ui.mBtn_Root, function()
    if onclick then
      onclick()
    end
  end)
end
function ActivityTourCommandPointItem:EnableBtn(enable)
  UIUtils.EnableBtn(self.ui.mBtn_Root, enable)
end
