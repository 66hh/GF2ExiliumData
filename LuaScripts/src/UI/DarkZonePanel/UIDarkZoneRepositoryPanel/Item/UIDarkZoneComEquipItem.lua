require("UI.UIBaseCtrl")
UIDarkZoneComEquipItem = class("UIDarkZoneComEquipItem", UIBaseCtrl)
UIDarkZoneComEquipItem.__index = UIDarkZoneComEquipItem
function UIDarkZoneComEquipItem:ctor()
end
function UIDarkZoneComEquipItem:__InitCtrl()
end
function UIDarkZoneComEquipItem:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("Darkzone/DarkzoneComEquipItem.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
  end
  self:SetRoot(obj.transform)
  self.ui = {}
  self.isSetBlank = false
  self:LuaUIBindTable(obj.transform, self.ui)
  self:__InitCtrl()
end
function UIDarkZoneComEquipItem:SetEquipTypeBg(Num)
  self.ui.mImage_TypeBg.sprite = ResSys:GetUIResAIconSprite("Darkzone/icon_Darkzone_Equip_" .. Num .. ".png")
end
function UIDarkZoneComEquipItem:SetDarkZoneEquipData(equipData, equipped, callback, relateId)
  setactive(self.ui.mBtn_Equip, true)
  setactive(self.ui.mBtn_UnEquip, false)
  local itemData = equipData.ItemData
  if itemData == nil then
    itemData = equipData.itemdata
  end
  self.ui.mImage_Icon.sprite = IconUtils.GetItemIconSprite(itemData.id)
  self.ui.mImage_Bg.sprite = IconUtils.GetQuiltyByRank(itemData.rank)
  self.ui.mText_EquipLightNum.text = equipData.lightLv
  if callback then
    UIUtils.GetButtonListener(self.ui.mBtn_Equip.gameObject).onClick = function()
      callback(self)
    end
  else
    TipsManager.Add(self.ui.mBtn_Equip.gameObject, itemData, nil, nil, nil, relateId)
  end
end
function UIDarkZoneComEquipItem:SetBtnListener(callback)
  UIUtils.GetButtonListener(self.ui.mBtn_UnEquip.gameObject).onClick = callback
end
function UIDarkZoneComEquipItem:RemoveDarkZoneEquip()
  setactive(self.ui.mBtn_Equip, false)
  setactive(self.ui.mBtn_UnEquip, true)
end
function UIDarkZoneComEquipItem:SetBlankClick(onClickCallBack)
  self.isSetBlank = true
  UIUtils.GetButtonListener(self.ui.mBtn_UnEquip.gameObject).onClick = function()
    onClickCallBack(self)
  end
end
function UIDarkZoneComEquipItem:SetRedDot(enable)
  setactive(self.ui.mTrans_RedPoint, enable)
end
