require("UI.UIBaseCtrl")
DarkZoneGlobalEventItem = class("DarkZoneGlobalEventItem", UIBaseCtrl)
DarkZoneGlobalEventItem.__index = DarkZoneGlobalEventItem
function DarkZoneGlobalEventItem:InitCtrl(root, childItem)
  self.obj = instantiate(childItem)
  if root then
    CS.LuaUIUtils.SetParent(self.obj.gameObject, root.gameObject, false)
  end
  self.data = nil
  self.ui = {}
  self.show = false
  self:LuaUIBindTable(self.obj, self.ui)
end
function DarkZoneGlobalEventItem:SetDetail(data)
  local forever = data.forever
  self.show = not forever
  setactive(self.obj.gameObject, true)
  self.ui.mText_EventName.text = data.name
  self.ui.mTextEventDesc.text = data.desc
  if forever then
    self.ui.mText_EventCd.text = TableData.GetHintById(903470)
  else
    self.ui.mText_EventCd.text = data:TimeStr()
  end
  self.data = data
end
function DarkZoneGlobalEventItem:Update()
  self.ui.mText_EventCd.text = self.data:TimeStr()
end
function DarkZoneGlobalEventItem:Close()
  self.show = false
  self.data = nil
  setactive(self.obj.gameObject, false)
end
function DarkZoneGlobalEventItem:OnRelease()
  self.ui = nil
  self.obj = nil
  self.show = nil
  self.data = nil
end
