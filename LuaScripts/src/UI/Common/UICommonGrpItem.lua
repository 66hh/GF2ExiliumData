require("UI.UIBaseCtrl")
UICommonGrpItem = class("UICommonGrpItem", UIBaseCtrl)
UICommonGrpItem.__index = UICommonGrpItem
UICommonGrpItem.mCanvasGroup_Item = nil
UICommonGrpItem.mCanvasGroup_Weapon = nil
UICommonGrpItem.mCanvasGroup_WeaponParts = nil
UICommonGrpItem.mBtn_ItemSelect = nil
UICommonGrpItem.mBtn_WeaponSelect = nil
UICommonGrpItem.mBtn_WeaponPart = nil
UICommonGrpItem.mObj = nil
function UICommonGrpItem:__InitCtrl()
end
function UICommonGrpItem:__InitCtrlItem()
  setactive(self.ui.mCanvasGroup_Item, true)
  self.mBtn_ItemSelect = UIUtils.GetTempBtn(self.ui.mCanvasGroup_Item.transform)
  self.mBtn_ItemSelect.transform.anchorMin = vector2zero
  self.mBtn_ItemSelect.transform.anchorMax = vector2one
  self.mBtn_ItemSelect.transform.offsetMin = vector2zero
  self.mBtn_ItemSelect.transform.offsetMax = vector2zero
end
function UICommonGrpItem:__InitCtrlWeapon()
  setactive(self.ui.mCanvasGroup_Weapon, true)
  self.mBtn_WeaponSelect = UIUtils.GetTempBtn(self.ui.mCanvasGroup_Weapon.transform)
  self.mBtn_WeaponSelect.transform.anchorMin = vector2zero
  self.mBtn_WeaponSelect.transform.anchorMax = vector2one
  self.mBtn_WeaponSelect.transform.offsetMin = vector2zero
  self.mBtn_WeaponSelect.transform.offsetMax = vector2zero
end
function UICommonGrpItem:__InitCtrlWeaponPart()
  setactive(self.ui.mCanvasGroup_WeaponParts, true)
  self.mBtn_WeaponPart = UIUtils.GetTempBtn(self.ui.mCanvasGroup_WeaponParts.transform)
  self.mBtn_WeaponPart.transform.anchorMin = vector2zero
  self.mBtn_WeaponPart.transform.anchorMax = vector2one
  self.mBtn_WeaponPart.transform.offsetMin = vector2zero
  self.mBtn_WeaponPart.transform.offsetMax = vector2zero
end
function UICommonGrpItem:InitCtrl(parent)
  self.mObj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComGrpItemV2.prefab", self), parent)
  if parent then
  end
  self:SetRoot(self.mObj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mObj, self.ui)
  self:__InitCtrl()
end
function UICommonGrpItem:SetEquipData(id, level, callback, itemId, isReceived, clickItem)
  self.ui.mCanvasGroup_Item.alpha = 1
  self.ui.mCanvasGroup_Weapon.alpha = 0
  self.ui.mCanvasGroup_WeaponParts.alpha = 0
  self:SetItemCanBeClick()
  if self.mBtn_ItemSelect == nil then
    self:__InitCtrlItem()
    self.item = UICommonItem:New()
    self.item:InitObj(self.mBtn_ItemSelect)
  end
  self.item:SetEquipData(id, level, callback, itemId, clickItem)
  self.item:SetReceived(isReceived)
end
function UICommonGrpItem:SetItemDataClick(id, num, needItemCount, needGetWay, tipsCount, relateId, isReceived, clickItem)
  self:SetItemData(id, num, needItemCount, needGetWay, tipsCount, relateId, isReceived, clickItem)
end
function UICommonGrpItem:SetItemData(id, num, needItemCount, needGetWay, tipsCount, relateId, isReceived, clickItem, customOnClick)
  self.ui.mCanvasGroup_Item.alpha = 1
  self.ui.mCanvasGroup_Weapon.alpha = 0
  self.ui.mCanvasGroup_WeaponParts.alpha = 0
  self:SetItemCanBeClick()
  if self.mBtn_ItemSelect == nil then
    self:__InitCtrlItem()
    self.item = UICommonItem:New()
    self.item:InitObj(self.mBtn_ItemSelect)
  end
  self.item:SetItemData(id, num, needItemCount, needGetWay, tipsCount, relateId, nil, customOnClick, clickItem)
  self.item:SetReceived(isReceived ~= nil and isReceived or false)
  self.item:EnableEquipIndex(false)
end
function UICommonGrpItem:SetByItemData(itemData, count, isReceived, clickItem)
  self.mItemData = itemData
  if itemData.type == GlobalConfig.ItemType.Weapon then
    self:SetData(itemData.args[0], 1, nil, isReceived, itemData, count, clickItem)
  elseif itemData.type == GlobalConfig.ItemType.WeaponPart then
    self:SetWeaponPartData(itemData, isReceived)
  elseif itemData.type == GlobalConfig.ItemType.EquipmentType then
    self:SetEquipData(itemData.args[0], 0, nil, itemData.id, isReceived, clickItem)
  else
    self:SetItemData(itemData.id, count, nil, nil, nil, nil, isReceived, clickItem)
  end
end
function UICommonGrpItem:SetData(weaponId, level, callback, isReceived, itemData, clickItem)
  self.ui.mCanvasGroup_Item.alpha = 0
  self.ui.mCanvasGroup_Weapon.alpha = 1
  self.ui.mCanvasGroup_WeaponParts.alpha = 0
  self:SetItemCanBeClick()
  if self.mBtn_WeaponSelect == nil then
    self:__InitCtrlWeapon()
    self.weaponItem = UICommonWeaponInfoItem:New()
    self.weaponItem:InitObj(self.mBtn_WeaponSelect)
  end
  self.weaponItem:SetData(weaponId, level, callback, true, itemData, clickItem)
  self.weaponItem:SetReceived(isReceived)
end
function UICommonGrpItem:SetWeaponData(data, callback, isFocus, isSelect, num)
  self.ui.mCanvasGroup_Item.alpha = 0
  self.ui.mCanvasGroup_Weapon.alpha = 1
  self.ui.mCanvasGroup_WeaponParts.alpha = 0
  self:SetItemCanBeClick()
  if self.mBtn_WeaponSelect == nil then
    self:__InitCtrlWeapon()
    self.weaponItem = UICommonWeaponInfoItem:New()
    self.weaponItem:InitObj(self.mBtn_WeaponSelect)
  end
  self.weaponItem:SetWeaponData(data, callback, isFocus, isSelect, num)
end
function UICommonGrpItem:SetWeaponPartsData(data, callback, isFocus, isSelect)
  self.ui.mCanvasGroup_Item.alpha = 0
  self.ui.mCanvasGroup_Weapon.alpha = 1
  self.ui.mCanvasGroup_WeaponParts.alpha = 0
  self:SetItemCanBeClick()
  if self.mBtn_WeaponSelect == nil then
    self:__InitCtrlWeapon()
    self.weaponItem = UICommonWeaponInfoItem:New()
    self.weaponItem:InitObj(self.mBtn_WeaponSelect)
  end
  self.weaponItem:SetWeaponPartsData(data, callback, isFocus, isSelect)
  self.weaponItem:SetGunEquipped(false)
end
function UICommonGrpItem:SetWeaponPartData(itemData, isReceived)
  self.ui.mCanvasGroup_Item.alpha = 0
  self.ui.mCanvasGroup_Weapon.alpha = 0
  self.ui.mCanvasGroup_WeaponParts.alpha = 1
  self:SetItemCanBeClick()
  if self.mBtn_WeaponPart == nil then
    self:__InitCtrlWeaponPart()
    self.weaponPartItem = UICommonItem:New()
    self.weaponPartItem:InitObj(self.mBtn_WeaponPart)
  end
  local partData = UIWeaponGlobal:GetWeaponModSimpleData(CS.GunWeaponModData(itemData.args[0]))
  self.weaponPartItem:SetData(partData)
  self.weaponPartItem:SetReceived(isReceived)
  setactive(self.ui.mTrans_Num, true)
  self.weaponPartItem:SetQualityLine(false)
  self.weaponPartItem:SetReceiveData(partData)
  TipsManager.Add(self.weaponPartItem.ui.mBtn_Part.gameObject, itemData, 1, false, nil, nil, nil, nil, false)
end
function UICommonGrpItem:SetRankAndIconData(rank, icon, itemId, clickItem)
  self.ui.mCanvasGroup_Item.alpha = 1
  self.ui.mCanvasGroup_Weapon.alpha = 0
  self.ui.mCanvasGroup_WeaponParts.alpha = 0
  self:SetItemCanBeClick()
  if self.mBtn_ItemSelect == nil then
    self:__InitCtrlItem()
    self.item = UICommonItem:New()
    self.item:InitObj(self.mBtn_ItemSelect)
  end
  self.item:SetRankAndIconData(rank, icon, itemId, nil, clickItem)
end
function UICommonGrpItem:SetItemCanBeClick()
  setactive(self.ui.mCanvasGroup_Item, self.ui.mCanvasGroup_Item.alpha == 1)
  setactive(self.ui.mCanvasGroup_Weapon, self.ui.mCanvasGroup_Weapon.alpha == 1)
  setactive(self.ui.mCanvasGroup_WeaponParts, self.ui.mCanvasGroup_WeaponParts.alpha == 1)
end
function UICommonGrpItem:OnDestroy()
  if self.mObj ~= nil then
    gfdestroy(self.mObj)
  end
end
