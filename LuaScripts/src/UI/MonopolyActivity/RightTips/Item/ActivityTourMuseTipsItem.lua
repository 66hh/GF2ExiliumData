require("UI.UIBaseCtrl")
require("UI.MonopolyActivity.ActivityTourGlobal")
ActivityTourMuseTipsItem = class("ActivityTourMuseTipsItem", UIBaseCtrl)
ActivityTourMuseTipsItem.__index = ActivityTourMuseTipsItem
ActivityTourMuseTipsItem.ui = nil
ActivityTourMuseTipsItem.mData = nil
ActivityTourMuseTipsItem.showType = ActivityTourGlobal.InspirationTip
function ActivityTourMuseTipsItem:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function ActivityTourMuseTipsItem:InitCtrl(com, parent)
  local obj = instantiate(com.childItem, parent)
  self:SetRoot(obj.transform)
  self.ui = {}
  self.mData = nil
  self:LuaUIBindTable(obj, self.ui)
  ActivityTourGlobal.ReplaceAllColor(self.mUIRoot)
end
function ActivityTourMuseTipsItem:Refresh(data)
  self.ui.mText_Name.text = UIUtils.GetItemName(data.Id)
  self.ui.mImg_Icon.sprite = UIUtils.GetItemIcon(data.Id)
end
