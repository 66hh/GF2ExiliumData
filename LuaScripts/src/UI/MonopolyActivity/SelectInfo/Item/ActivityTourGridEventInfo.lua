require("UI.UIBaseCtrl")
ActivityTourGridEventInfo = class("ActivityTourGridEventInfo", UIBaseCtrl)
ActivityTourGridEventInfo.__index = ActivityTourGridEventInfo
ActivityTourGridEventInfo.ui = nil
ActivityTourGridEventInfo.mData = nil
function ActivityTourGridEventInfo:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function ActivityTourGridEventInfo:InitCtrl(itemPrefab, parent)
  local obj = instantiate(itemPrefab, parent)
  self:SetRoot(obj.transform)
  self.ui = {}
  self.mData = nil
  self:LuaUIBindTable(obj, self.ui)
end
function ActivityTourGridEventInfo:Refresh(data)
  self.ui.mText_Name.text = data.name.str
  self.ui.mText_Detail.text = data.desc.str
end
