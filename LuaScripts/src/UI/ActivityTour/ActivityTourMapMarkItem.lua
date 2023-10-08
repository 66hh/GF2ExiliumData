require("UI.UIBaseCtrl")
ActivityTourMapMarkItem = class("ActivityTourMapMarkItem", UIBaseCtrl)
ActivityTourMapMarkItem.__index = ActivityTourMapMarkItem
function ActivityTourMapMarkItem:ctor()
end
function ActivityTourMapMarkItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
    CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject, true)
  end
  self:SetRoot(instObj.transform)
end
function ActivityTourMapMarkItem:SetData(data, mapData)
  self.ui.mText_Tittle.text = mapData.name.str
  if mapData.type == 1 or mapData.type == 8 or mapData.type == 9 or mapData.type == 99 then
    self.ui.mImg_Mark.color = ColorUtils.StringToColor("FFFFFF")
  end
  local resourceData = TableData.listMonopolyPointResourcesDatas:GetDataById(mapData.map_image)
  if resourceData and resourceData.point_icon ~= "" then
    self.ui.mImg_Mark.sprite = IconUtils.GetActivityTourIcon(resourceData.point_icon)
  end
end
function ActivityTourMapMarkItem:SetOccupyData(index)
  setactive(self.ui.mImg_Bg.gameObject, false)
  self.ui.mImg_Mark.color = ColorUtils.StringToColor("FFFFFF")
  if index == 1 then
    self.ui.mText_Tittle.text = TableData.GetHintById(270300)
    self.ui.mImg_Mark.sprite = IconUtils.GetActivityTourIcon("Icon_ActivityTour_Occupy_1")
  else
    self.ui.mText_Tittle.text = TableData.GetHintById(270299)
    self.ui.mImg_Mark.sprite = IconUtils.GetActivityTourIcon("Icon_ActivityTour_Occupy_2")
  end
end
