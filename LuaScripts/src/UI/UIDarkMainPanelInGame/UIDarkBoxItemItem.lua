require("UI.UIBaseCtrl")
UIDarkBoxItemItem = class("UIDarkBoxItemItem", UIBaseCtrl)
UIDarkBoxItemItem.__index = UIDarkBoxItemItem
local self = UIDarkBoxItemItem
function UIDarkBoxItemItem:__InitCtrl()
end
function UIDarkBoxItemItem:InitCtrl(parent, obj)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, true)
  end
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
end
function UIDarkBoxItemItem:SetPanelTable(panel)
  self.panelData = panel
end
function UIDarkBoxItemItem:SetData(data)
  self.ui.mText_Num.text = data.num
  self.ui.mImage_Icon.sprite = IconUtils.GetItemIconSprite(data.itemdata.id)
  self.ui.mImage_Rank2.color = TableData.GetGlobalGun_Quality_Color2(data.itemdata.rank)
  self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(data.itemdata.rank)
end
function UIDarkBoxItemItem:OnRelease()
  self.panelData = nil
  gfdestroy(self.mUIRoot.gameObject)
end
