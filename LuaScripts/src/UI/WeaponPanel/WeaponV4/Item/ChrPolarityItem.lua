require("UI.UIBaseCtrl")
ChrPolarityItem = class("ChrPolarityItem", UIBaseCtrl)
ChrPolarityItem.__index = ChrPolarityItem
function ChrPolarityItem:ctor()
  self.weaponModTypeData = 0
  self.gunWeaponModData = nil
  self.polarityTagData = nil
  self.timer = nil
end
function ChrPolarityItem:InitCtrl(parent, weaponPartType, obj)
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
  self.weaponModTypeData = TableData.listWeaponModTypeDatas:GetDataById(weaponPartType)
  self:SetRoot(instObj.transform)
  setactive(self.ui.mObj_RedPoint, false)
end
function ChrPolarityItem:OnButtonClick(callback)
  UIUtils.GetButtonListener(self.ui.mBtn_ChrPolarityItem.gameObject).onClick = function()
    if callback then
      callback()
    end
  end
end
function ChrPolarityItem:SetWeaponPartData(polarityTagData, gunWeaponModData)
  self.polarityTagData = polarityTagData
  self.gunWeaponModData = gunWeaponModData
  self.ui.mText_Name.text = self.weaponModTypeData.Name.str
  self.ui.mImg_PartsIcon.sprite = IconUtils.GetWeaponPartIconSprite(self.weaponModTypeData.icon, false)
  if self.gunWeaponModData == nil then
    self.ui.mAnimator_ChrPolarityItem:SetBool("Equiped", false)
  else
    self.ui.mAnimator_ChrPolarityItem:SetBool("Equiped", true)
  end
  if self.polarityTagData == nil then
    setactive(self.ui.mImg_Unlighted.gameObject, false)
    setactive(self.ui.mTrans_Lighted.gameObject, false)
  else
    setactive(self.ui.mImg_Unlighted.gameObject, true)
    self.ui.mImg_Unlighted.sprite = IconUtils.GetElementIcon(self.polarityTagData.icon .. "_S")
    local isSamePolarity = gunWeaponModData ~= nil and gunWeaponModData.PolarityId == self.polarityTagData.PolarityId
    if isSamePolarity then
      setactive(self.ui.mTrans_Lighted.gameObject, true)
      self.ui.mTrans_Lighted.sprite = IconUtils.GetElementIcon(self.polarityTagData.icon .. "_S")
      local colorList = self.ui.mTextImgColorList_Icon
      self.ui.mImg_Icon.color = colorList.ImageColor[self.polarityTagData.PolarityId - 1]
    else
      setactive(self.ui.mTrans_Lighted.gameObject, false)
    end
  end
  self:SetPolarityEffect()
end
function ChrPolarityItem:SetRedPointEnable(enable)
  setactive(self.ui.mObj_RedPoint, enable)
end
function ChrPolarityItem:SetBtnEnabled(boolean)
  self.ui.mBtn_ChrPolarityItem.enabled = boolean
  self.ui.mGFUIGroupList_ChrPolarityItem:ChangeUIComponentGroups("OVLine", boolean)
end
function ChrPolarityItem:SetBtnInteractable(boolean)
  self.ui.mBtn_ChrPolarityItem.interactable = boolean
end
function ChrPolarityItem:ShowPolarityFx()
  setactive(self.ui.mObj_ChrPolarityItem.gameObject, true)
  self.timer = TimerSys:DelayCall(2, function()
    setactive(self.ui.mObj_ChrPolarityItem.gameObject, false)
  end)
end
function ChrPolarityItem:TimerAbort()
  if self.timer ~= nil then
    self.timer:Abort()
    self.timer = nil
  end
  setactive(self.ui.mObj_ChrPolarityItem.gameObject, false)
end
function ChrPolarityItem:SetPolarityEffect()
  if self.polarityTagData == nil then
    return
  end
  if self.ui.mObj_ChrPolarityItem.transform.childCount > 0 then
    ResourceDestroy(self.ui.mObj_ChrPolarityItem.transform:GetChild(0).gameObject)
  end
  local originalString = self.polarityTagData.icon
end
function ChrPolarityItem:OnRelease()
  if self.fxGameObject ~= nil then
    ResourceManager:DestroyInstance(self.fxGameObject)
  end
  self:DestroySelf()
end
