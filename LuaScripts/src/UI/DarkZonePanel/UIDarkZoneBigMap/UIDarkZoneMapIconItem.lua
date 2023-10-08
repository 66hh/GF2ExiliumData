require("UI.UIBaseCtrl")
UIDarkZoneMapIconItem = class("UIDarkZoneMapIconItem", UIBaseCtrl)
UIDarkZoneMapIconItem.__index = UIDarkZoneMapIconItem
function UIDarkZoneMapIconItem:InitCtrl(root, obj)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
function UIDarkZoneMapIconItem:OnRelease()
  if self.imageSprite then
    ResourceManager:UnloadAssetFromLua(self.imageSprite)
  end
  self.imageSprite = nil
  self.super.OnRelease(self)
  self.ui = nil
  self.data = nil
end
function UIDarkZoneMapIconItem:SetData(data)
  self.data = data
  self.imageSprite = IconUtils.GetIconV2("Darkzone", data.icon)
  self.ui.mImg_Mark.sprite = self.imageSprite
  self.ui.mText_Tittle.text = data.iconName
end
