require("UI.UIBaseCtrl")
DarkMainPanelInGameSlotItem = class("DarkMainPanelInGameSlotItem", UIBaseCtrl)
DarkMainPanelInGameSlotItem.__index = DarkMainPanelInGameSlotItem
function DarkMainPanelInGameSlotItem:InitCtrl(root, keySlot)
  local com = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self:SetEnable(false)
  local slotconfig = root.gameObject:GetComponent(typeof(CS.SlotItemConfig)):GetSlotItemProp(keySlot)
  self.ui.mImg_SlotIcon.sprite = slotconfig.bgImg
  self.ui.mImg_Fill.color = slotconfig.fillColor
end
function DarkMainPanelInGameSlotItem:SetFill(fill)
  self.ui.mImg_Fill.fillAmount = fill
end
function DarkMainPanelInGameSlotItem:SetEnable(enable)
  setactive(self.mUIRoot.gameObject, enable)
end
function DarkMainPanelInGameSlotItem:OnRelease()
  self.ui = nil
end
