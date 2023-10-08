require("UI.UIBaseCtrl")
ActivityTourSettlementTaskItem = class("ActivityTourSettlementTaskItem", UIBaseCtrl)
ActivityTourSettlementTaskItem.__index = ActivityTourSettlementTaskItem
ActivityTourSettlementTaskItem.ui = nil
ActivityTourSettlementTaskItem.mData = nil
function ActivityTourSettlementTaskItem:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function ActivityTourSettlementTaskItem:InitCtrl(childItem, parent)
  local obj = instantiate(childItem, parent)
  self:SetRoot(obj.transform)
  self.ui = {}
  self.mData = nil
  self:LuaUIBindTable(obj, self.ui)
end
function ActivityTourSettlementTaskItem:Refresh(data)
  local taskInfo = NetCmdMonopolyData:GetSettleTaskData(data.id)
  local curNum = taskInfo and taskInfo.Num or 0
  local maxNum = data.condition_num
  local bFinish = curNum >= maxNum
  setactive(self.ui.mImg_Complete.gameObject, bFinish)
  setactive(self.ui.mImg_NotComplete.gameObject, not bFinish)
  self.ui.mText_TaskInfo.text = UIUtils.StringFormatWithHintId(270155, data.des.str, curNum, maxNum)
end
