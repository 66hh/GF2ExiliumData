require("UI.DarkZonePanel.UIDarkZoneModePanel.DarkZoneGlobal")
UIDarkZoneEventDetailDialogItem = class("UIDarkZoneEventDetailDialogItem", UIBaseCtrl)
UIDarkZoneEventDetailDialogItem.__index = UIDarkZoneEventDetailDialogItem
function UIDarkZoneEventDetailDialogItem:__InitCtrl()
end
function UIDarkZoneEventDetailDialogItem:InitCtrl(root, childItem)
  local obj = instantiate(childItem, root)
  self.ui = {}
  self.mData = {}
  self.posCache = 0
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self:SetActive(true)
end
function UIDarkZoneEventDetailDialogItem:SetData(table)
  self.mData = table
  local v = TableData.listDzGlobalEventShowDatas:GetDataById(table.stcDataId)
  self.ui.mText_Events.text = v.name.str
  self.ui.mText_Explain.text = v.desc_show.str
  self.ui.mText_EventType.text = TableData.GetHintById(240032 + table.type)
  self.ui.mImg_Icon.sprite = IconUtils.GetDarkzoneEventIcon(DarkZoneGlobal.EventIcon[table.type])
end
function UIDarkZoneEventDetailDialogItem:SetPos()
  self.posCache = self.ui.mTrans_EventItem.rect.height
  return self.posCache
end
