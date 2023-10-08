require("UI.UIBaseCtrl")
UIDarkZoneQuestInfoRootItem = class("UIDarkZoneQuestInfoRootItem", UIBaseCtrl)
UIDarkZoneQuestInfoRootItem.__index = UIDarkZoneQuestInfoRootItem
function UIDarkZoneQuestInfoRootItem:ctor()
end
function UIDarkZoneQuestInfoRootItem:__InitCtrl()
end
function UIDarkZoneQuestInfoRootItem:InitCtrl(obj, parent)
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self:SetActive(true)
end
function UIDarkZoneQuestInfoRootItem:SetData(titleHint, titleImg)
  self.ui.mText_Title.text = titleHint
end
function UIDarkZoneQuestInfoRootItem:SetLock()
  local c = ColorUtils.StringToColor("1a2c33")
  c.a = 0.5
  self.ui.mText_Title.color = c
  c.a = 0.7
  self.ui.mImg_Bg.color = c
  self.ui.mOutline_Title.enabled = false
end
