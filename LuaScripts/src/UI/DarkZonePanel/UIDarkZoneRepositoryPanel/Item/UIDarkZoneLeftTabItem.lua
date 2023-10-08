require("UI.UIBaseCtrl")
UIDarkZoneLeftTabItem = class("UIDarkZoneLeftTabItem", UIBaseCtrl)
UIDarkZoneLeftTabItem.__index = UIDarkZoneLeftTabItem
function UIDarkZoneLeftTabItem:ctor()
end
function UIDarkZoneLeftTabItem:__InitCtrl()
end
function UIDarkZoneLeftTabItem:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("Darkzone/DarkzoneLeftTabItem.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
  end
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(obj.transform, self.ui)
  self:__InitCtrl()
end
function UIDarkZoneLeftTabItem:SetData(data)
  self.ui.mImg_Icon.sprite = ResSys:GetUIResAIconSprite("Darkzone" .. "/" .. "icon_DarkzoneRepository_LeftTab" .. data + 1 .. ".png")
  self.ui.mText_Name.text = TableData.GetHintById(data + 903144)
end
function UIDarkZoneLeftTabItem:SetSelected(selected)
  self.ui.mBtn_Root.interactable = not selected
end
