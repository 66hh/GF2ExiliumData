require("UI.UIBaseCtrl")
ChrPolaritySelItem = class("ChrPolaritySelItem", UIBaseCtrl)
ChrPolaritySelItem.__index = ChrPolaritySelItem
function ChrPolaritySelItem:ctor()
  self.polarityTagData = nil
  self.isRecommend = false
  self.isActive = true
end
function ChrPolaritySelItem:InitCtrl(parent, obj)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj
  if obj ~= nil then
    instObj = obj
  else
    instObj = instantiate(itemPrefab.childItem)
  end
  if parent then
    CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject, false)
  end
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  self:SetRoot(instObj.transform)
end
function ChrPolaritySelItem:OnButtonClick(callback)
  UIUtils.GetButtonListener(self.ui.mBtn_ChrPolaritySelItem.gameObject).onClick = function()
    if callback then
      callback()
    end
  end
end
function ChrPolaritySelItem:SetPolarityTagData(polarityTagData)
  self.polarityTagData = polarityTagData
  self.ui.mImg_Icon.sprite = IconUtils.GetElementIcon(self.polarityTagData.icon)
end
function ChrPolaritySelItem:SetGunWeaponModData(gunWeaponModData)
  if gunWeaponModData ~= nil and gunWeaponModData.PolarityTagData ~= nil and self.polarityTagData ~= nil then
    local gunWeaponModPolarityId = gunWeaponModData.PolarityTagData.polarity_id
    self.isRecommend = gunWeaponModPolarityId == self.polarityTagData.polarity_id
  end
  setactive(self.ui.mTrans_Recommend.gameObject, self.isRecommend)
end
function ChrPolaritySelItem:SetBtnEnabled(boolean)
  self.ui.mBtn_ChrPolaritySelItem.enabled = boolean
end
function ChrPolaritySelItem:SetBtnInteractable(boolean)
  self.ui.mBtn_ChrPolaritySelItem.interactable = boolean
end
function ChrPolaritySelItem:SetActive(boolean)
  self.super.SetActive(self, boolean)
  self.isActive = boolean
end
function ChrPolaritySelItem:OnRelease()
  self:DestroySelf()
end
