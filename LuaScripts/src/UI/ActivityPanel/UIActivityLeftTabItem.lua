require("UI.UIBaseCtrl")
UIActivityLeftTabItem = class("UIActivityLeftTabItem", UIBaseCtrl)
UIActivityLeftTabItem.__index = UIActivityLeftTabItem
function UIActivityLeftTabItem:ctor()
  self.super.ctor(self)
end
function UIActivityLeftTabItem:InitCtrl(itemPrefab, parent, onclick)
  local instObj = instantiate(itemPrefab, parent)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(instObj.transform, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
    onclick(self.mIndex)
  end
end
function UIActivityLeftTabItem:SetData(activityData, index, isSelect)
  self.mData = activityData
  self.mIndex = index
  self.activityID = self.mData.activityID
  local tableData = self.mData.tableData
  self.ui.mText_Name.text = tableData.name.str
  self.ui.mImage_Icon.sprite = IconUtils.GetActivityIcon(tableData.icon)
  self:SetSelect(isSelect)
  self:UpdateRedPoint()
end
function UIActivityLeftTabItem:SetSelect(select)
  UIUtils.EnableBtn(self.ui.mBtn_Self, not select)
end
function UIActivityLeftTabItem:UpdateRedPoint()
  setactive(self.ui.mTrans_RedPoint, NetCmdOperationActivityData:HasRedPoint(self.mData.activityID))
end
