require("UI.UIBaseCtrl")
Btn_ActivityMuseItem = class("Btn_ActivityMuseItem", UIBaseCtrl)
Btn_ActivityMuseItem.__index = Btn_ActivityMuseItem
function Btn_ActivityMuseItem:ctor()
end
function Btn_ActivityMuseItem:InitCtrl(parent)
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
function Btn_ActivityMuseItem:SetData(data, isinteractable)
  self.ui.mImg_Icon.sprite = IconUtils.GetItemIconSprite(data.id)
  local itemNum = NetCmdItemData:GetItemCount(data.id)
  self.ui.mText_Num.text = itemNum
  if itemNum <= 0 then
    self.ui.mText_Num.color = ColorUtils.RedColor
  else
    self.ui.mText_Num.color = ColorUtils.WhiteColor
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ActivityMuseItem.gameObject).onClick = function()
    UITipsPanel.Open(TableData.GetItemData(data.id))
  end
end
