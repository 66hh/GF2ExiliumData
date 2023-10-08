require("UI.UIBasePanel")
UIDarkZoneEventTopTabItem = class("UIDarkZoneEventTopTabItem", UIBaseCtrl)
UIDarkZoneEventTopTabItem.__index = UIDarkZoneEventTopTabItem
function UIDarkZoneEventTopTabItem:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function UIDarkZoneEventTopTabItem:InitCtrl(prefab, parent)
  local obj = instantiate(prefab, parent)
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self.callBack = nil
  self.pos = 0
  self.eventType = DarkZoneGlobal.EventType.Start
  UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
    self.callBack()
  end
end
function UIDarkZoneEventTopTabItem:SetData(eventType, callBack)
  self.eventType = eventType
  self.callBack = callBack
  self.ui.mText_Name.text = TableData.GetHintById(240032 + self.eventType)
end
function UIDarkZoneEventTopTabItem:OnClose()
end
