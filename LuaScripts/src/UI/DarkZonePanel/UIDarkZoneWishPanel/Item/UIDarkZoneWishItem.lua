require("UI.UIBaseCtrl")
require("UI.DarkZonePanel.UIDarkZoneWishPanel.Item.UIDarkZoneWishTypeDescItem")
UIDarkZoneWishItem = class("UIDarkZoneWishItem", UIBaseCtrl)
UIDarkZoneWishItem.__index = UIDarkZoneWishItem
function UIDarkZoneWishItem:__InitCtrl()
end
function UIDarkZoneWishItem:InitCtrl(root)
  if root == nil then
    return
  end
  local itemPrefab = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(itemPrefab.childItem)
  CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self.mData = nil
  setactive(self.ui.mTrans_InfoItem, false)
  self.typeDescItemList = {}
  for i = 1, 4 do
    self.typeDescItemList[i] = UIDarkZoneWishTypeDescItem.New()
    local item = self.typeDescItemList[i]
    item:InitCtrl(self.ui.mTrans_InfoItem.gameObject, self.ui.mTrans_Info)
    item:SetData(i)
  end
  self.highLightNum = 0
end
function UIDarkZoneWishItem:SetParentPanel(panel)
  self.parentPanel = panel
end
function UIDarkZoneWishItem:SetData(data)
  self.mData = TableData.listWeaponModTypeDatas:GetDataById(data)
  self.ui.mImg_Icon.sprite = IconUtils.GetWeaponPartIconSprite(self.mData.icon, false)
  self.ui.mText_Title.text = self.mData.weapon_mod_des.str
  self.ui.mText_Describe.text = self.mData.name.str
  self:CancelTypeHighLight()
end
function UIDarkZoneWishItem:SetTypeHighLight(tbData)
  local needShowHighLight = false
  if tbData.effect_type:Contains(self.mData.id) and self.typeDescItemList[tbData.type] then
    self.typeDescItemList[tbData.type]:SetHighLight(tbData.effect_type_des.str)
    needShowHighLight = true
    self.highLightNum = self.highLightNum + 1
  end
  self.ui.mAnimator_Self:SetBool("Inuse", self.highLightNum > 0)
end
function UIDarkZoneWishItem:CancelTypeHighLight()
  for i = 1, 4 do
    local item = self.typeDescItemList[i]
    item:CancelHighLight()
  end
  self.highLightNum = 0
  self.ui.mAnimator_Self:SetBool("Inuse", false)
end
function UIDarkZoneWishItem:SetSelectItemData(dataList)
  self.dataList = dataList
end
function UIDarkZoneWishItem:OnRelease()
  self.ui = nil
  self.mData = nil
  self.parentPanel = nil
  self.highLightNum = nil
  self.super.OnRelease(self, true)
end
