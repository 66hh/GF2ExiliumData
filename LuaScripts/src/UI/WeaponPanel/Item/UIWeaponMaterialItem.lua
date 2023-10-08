require("UI.UIBaseCtrl")
UIWeaponMaterialItem = class("UIWeaponMaterialItem", UIBaseCtrl)
UIWeaponMaterialItem.__index = UIWeaponMaterialItem
function UIWeaponMaterialItem:ctor()
  self.mData = nil
  self.isSelect = false
end
function UIWeaponMaterialItem:__InitCtrl()
  self.mBtn_Reduce = UIUtils.GetTempBtn(self:GetRectTransform("GrpContent/Trans_GrpReduce/GrpMinus"))
  self.mBtn_Select = self:GetSelfButton()
  self.mImage_Icon = self:GetImage("GrpContent/GrpIcon/Img_Icon")
  self.mImage_Rank = self:GetImage("GrpContent/GrpQualityLine/ImgLine")
  self.mImage_Rank2 = self:GetImage("GrpContent/GrpIcon/Img_Bg")
  self.mText_Count = self:GetText("GrpContent/GrpLevel/Text_Level")
  self.mTrans_Select = self:GetRectTransform("GrpContent/GrpSel")
  self.mTrans_UseDetail = self:GetRectTransform("GrpContent/Trans_GrpReduce")
  self.mText_SelectCount = self:GetText("GrpContent/Trans_GrpReduce/GrpText/Text_Num")
  self.mTrans_Choose = self:GetRectTransform("GrpContent/Trans_GrpChoose")
  self.mTrans_Lock = self:GetRectTransform("GrpContent/Trans_GrpLock")
  self.mTrans_PartFlag = self:GetRectTransform("GrpContent/Trans_GrpPartsEquiped")
  self.longPress = CS.LongPressTriggerListener.Set(self.mUIRoot.gameObject, 0.5, true)
  self.minusLongPress = CS.LongPressTriggerListener.Set(self.mBtn_Reduce.gameObject, 0.5, true)
end
function UIWeaponMaterialItem:InitCtrl()
  local obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComWeaponInfoItem.prefab", self))
  self:SetRoot(obj.transform)
  self:__InitCtrl()
end
function UIWeaponMaterialItem:SetData(data, isCanNotSelect)
  if data then
    self.mData = data
    if data.type == UIWeaponGlobal.MaterialType.Item then
      self.mImage_Icon.sprite = IconUtils.GetItemIconSprite(data.id)
      setactive(self.mTrans_PartFlag, false)
      self.mText_Count.text = data.count
      self.longPress.enabled = true
    elseif data.type == UIWeaponGlobal.MaterialType.Weapon then
      local weaponData = TableData.listGunWeaponDatas:GetDataById(data.stcId)
      local elementData = TableData.listLanguageElementDatas:GetDataById(weaponData.element)
      self.mImage_Icon.sprite = IconUtils.GetWeaponSprite(data.icon)
      self.mText_Count.text = GlobalConfig.SetLvText(data.level)
      setactive(self.mTrans_PartFlag, data.partCount > 0)
      self.longPress.enabled = false
    end
    self.mImage_Rank2.sprite = IconUtils.GetWeaponQuiltyByRank(data.rank)
    self.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(data.rank)
    self.mText_SelectCount.text = data.selectCount
    setactive(self.mTrans_UseDetail, 0 < data.selectCount and data.type == UIWeaponGlobal.MaterialType.Item)
    setactive(self.mTrans_Choose, 0 < data.selectCount and data.type == UIWeaponGlobal.MaterialType.Weapon)
    setactive(self.mTrans_Lock, data.isLock)
    setactive(self.mTrans_Select, self.mData.isSelect)
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UIWeaponMaterialItem:SetPartData(data, isCanNotSelect)
  if data then
    self.mData = data
    if data.type == UIWeaponGlobal.MaterialType.Item then
      self.mImage_Icon.sprite = IconUtils.GetItemIconSprite(data.id)
      self.mText_Count.text = data.count
      self.longPress.enabled = true
    elseif data.type == UIWeaponGlobal.MaterialType.Weapon then
      local partData = TableData.listWeaponModDatas:GetDataById(data.stcId)
      local suitData = TableData.listModPowerDatas:GetDataById(data.suitId)
      self.mImage_Icon.sprite = IconUtils.GetWeaponPartIcon(data.icon)
      self.mText_Count.text = GlobalConfig.SetLvText(data.level)
      self.longPress.enabled = false
    end
    self.mImage_Rank2.sprite = IconUtils.GetWeaponQuiltyByRank(data.rank)
    self.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(data.rank)
    self.mText_SelectCount.text = data.selectCount
    setactive(self.mTrans_UseDetail, data.selectCount > 0 and data.type == UIWeaponGlobal.MaterialType.Item)
    setactive(self.mTrans_Choose, data.selectCount > 0 and data.type == UIWeaponGlobal.MaterialType.Weapon)
    setactive(self.mTrans_Lock, data.isLock)
    setactive(self.mTrans_Select, self.mData.isSelect)
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UIWeaponMaterialItem:SetMaterialSelect()
  if self.mData.selectCount < self.mData.count then
    self.mData.selectCount = self.mData.selectCount + 1
    if self.mData.type == UIWeaponGlobal.MaterialType.Item then
      self.mText_SelectCount.text = self.mData.selectCount
      setactive(self.mTrans_UseDetail, self.mData.selectCount > 0)
      setactive(self.mTrans_Choose, false)
    end
  elseif self.mData.type == UIWeaponGlobal.MaterialType.Weapon then
    self.mData.selectCount = self.mData.selectCount - 1
    setactive(self.mTrans_UseDetail, false)
  end
  setactive(self.mTrans_Choose, self.mData.type == UIWeaponGlobal.MaterialType.Weapon and self.mData.selectCount > 0)
end
function UIWeaponMaterialItem:OnReduce()
  if self.mData.type == UIWeaponGlobal.MaterialType.Item then
    if self.mData.selectCount > 0 then
      self.mData.selectCount = self.mData.selectCount - 1
    end
    self.mText_SelectCount.text = self.mData.selectCount
    setactive(self.mTrans_UseDetail, self.mData.selectCount > 0)
  end
end
function UIWeaponMaterialItem:SetLongPressEvent(beginCb, endCb)
  if self.longPress then
    self.longPress.longPressStart = beginCb
    self.longPress.longPressEnd = endCb
  end
end
function UIWeaponMaterialItem:SetMinusLongPressEvent(beginCb, endCb)
  if self.minusLongPress then
    self.minusLongPress.longPressStart = beginCb
    self.minusLongPress.longPressEnd = endCb
  end
end
function UIWeaponMaterialItem:IsRemoveWeapon()
  return self.mData.type == UIWeaponGlobal.MaterialType.Weapon and self.mData.selectCount > 0
end
function UIWeaponMaterialItem:IsBreakItem(id)
  if self.mData.type == UIWeaponGlobal.MaterialType.Weapon then
    return self.mData.stcId == id
  elseif self.mData.type == UIWeaponGlobal.MaterialType.Item then
    return self.mData.isBreakItem
  end
end
function UIWeaponMaterialItem:IsLocked()
  return self.mData.isLock
end
function UIWeaponMaterialItem:EnableSelectFrame(enable)
  setactive(self.mTrans_Select, enable)
end
