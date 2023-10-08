require("UI.UIBaseCtrl")
ChrWeaponPartsBlankBoardItem = class("ChrWeaponPartsBlankBoardItem", UIBaseCtrl)
ChrWeaponPartsBlankBoardItem.__index = ChrWeaponPartsBlankBoardItem
function ChrWeaponPartsBlankBoardItem:ctor()
  self.weaponModTypeData = 0
  self.polarityTagData = nil
end
function ChrWeaponPartsBlankBoardItem:InitCtrl(parent, obj)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj
  if obj ~= nil then
    instObj = obj
  else
    instObj = instantiate(itemPrefab.childItem)
  end
  if parent then
    CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  self:SetRoot(instObj.transform)
end
function ChrWeaponPartsBlankBoardItem:SetWeaponPartData(polarityTagData, weaponModTypeData, needEffect)
  if needEffect == nil then
    needEffect = true
  end
  self.polarityTagData = polarityTagData
  self.weaponModTypeData = weaponModTypeData
  self.ui.mImg_Icon.sprite = IconUtils.GetWeaponPartIconSprite(self.weaponModTypeData.icon, false)
  if self.polarityTagData ~= nil then
    setactive(self.ui.mImg_PolarityIcon.gameObject, true)
    self.ui.mImg_PolarityIcon.sprite = IconUtils.GetElementIcon(self.polarityTagData.icon .. "_S")
    if needEffect then
      if self.ui.mTrans_Fx.transform.childCount > 0 then
        ResourceDestroy(self.ui.mTrans_Fx.transform:GetChild(0).gameObject)
      end
      local originalString = self.polarityTagData.icon
      local replacedString = string.gsub(originalString, "Icon_BulletHit_", "UI_PolarityIcon_")
    end
  else
    setactive(self.ui.mImg_PolarityIcon.gameObject, false)
  end
end
function ChrWeaponPartsBlankBoardItem:OnRelease()
  if self.fxGameObject ~= nil then
    ResourceManager:DestroyInstance(self.fxGameObject)
  end
  self:DestroySelf()
end
