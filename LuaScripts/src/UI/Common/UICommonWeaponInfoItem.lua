require("UI.UIBaseCtrl")
UICommonWeaponInfoItem = class("UICommonWeaponInfoItem", UIBaseCtrl)
UICommonWeaponInfoItem.__index = UICommonWeaponInfoItem
function UICommonWeaponInfoItem:ctor()
  self.mData = nil
  self.itemState = {
    IsFocused = false,
    IsSelected = false,
    IsLocked = false,
    IsEquippedParts = false
  }
end
function UICommonWeaponInfoItem:__InitCtrl()
end
function UICommonWeaponInfoItem:Init(parent)
  local obj = self:Instantiate("UICommonFramework/ComWeaponInfoItem.prefab", parent)
  self:SetRoot(obj.transform)
  UIUtils.OutUIBindTable(obj, self)
  setactive(self.mTrans_Equipped_InGun, false)
  setactive(self.mTrans_Equipped_HasParts, false)
  setactive(self.mTrans_Equipped_InWeapon, false)
end
function UICommonWeaponInfoItem:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComWeaponInfoItem.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, true)
  end
  UIUtils.OutUIBindTable(obj, self)
  self:SetRoot(obj.transform)
  self:__InitCtrl()
end
function UICommonWeaponInfoItem:InitObj(obj)
  UIUtils.OutUIBindTable(obj, self)
  self:SetRoot(obj.transform)
  self:__InitCtrl()
end
function UICommonWeaponInfoItem:SetByData(data, callback, isChoose)
  self:SetData(data.stcId or data.stc_id, data.level or data.Level, callback)
  self.mData = data
  if isChoose ~= nil then
    self:SetSelect(isChoose)
  else
    self:SetSelect(false)
  end
  if data then
    setactive(self.mTrans_Lock, data.IsLocked)
    setactive(self.mTrans_Equipped_InGun, data.gun_id > 0)
    if data.gun_id > 0 then
      local gunData = TableData.listGunDatas:GetDataById(data.gun_id)
      if gunData then
        self.mImage_Head.sprite = IconUtils.GetCharacterHeadSprite(IconUtils.cCharacterAvatarType_Avatar, gunData.code)
      end
    end
  end
end
function UICommonWeaponInfoItem:SetWeaponPartsData(data, callback, isFocus, isSelect)
  if not data then
    setactive(self.mUIRoot, false)
    return
  end
  self:Reset()
  self.mWeaponPartsData = data
  UIUtils.GetButtonListener(self.mBtn_Select.gameObject).onClick = function()
    if callback then
      callback(self)
    end
  end
  if isFocus then
    self:Focus()
  else
    self:LoseFocus()
  end
  self:SetSelect(isSelect or false)
  setactive(self.mTrans_Lock, self.mWeaponPartsData.IsLocked)
  setactive(self.mTrans_Equipped_HasParts, false)
  local isWeaponEquipped = self.mWeaponPartsData.equipWeapon ~= 0
  setactive(self.mTrans_Equipped_InWeapon, isWeaponEquipped)
  setactive(self.mImage_Head, isWeaponEquipped)
  local dataSuit = TableData.listModPowerDatas:GetDataById(self.mWeaponPartsData.suitId)
  if dataSuit then
    self.mImage_SuitIcon.sprite = IconUtils.GetWeaponPartIconSprite(dataSuit.image, false)
    setactive(self.mTrans_SuitRoot, true)
  end
  self.mImage_Icon.sprite = IconUtils.GetWeaponPartIconSprite(self.mWeaponPartsData.icon)
  self.mText_Count.text = GlobalConfig.SetLvText(self.mWeaponPartsData.level)
  self.mImage_Rank2.sprite = IconUtils.GetWeaponQuiltyByRank(self.mWeaponPartsData.rank)
  self.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(self.mWeaponPartsData.rank)
end
function UICommonWeaponInfoItem:SetWeaponData(data, callback, isFocus, isSelect)
  if not data then
    return
  end
  self:Reset()
  setactive(self.mTrans_SuitRoot, false)
  self:SetData(data.stcId or data.stc_id, data.level or data.Level, callback)
  self.mWeaponData = data
  if isFocus then
    self:Focus()
  else
    self:LoseFocus()
  end
  if num ~= nil and num ~= 0 then
    self.mText_Count.text = tostring(num)
  end
  self:SetSelect(isSelect or false)
  setactive(self.mTrans_Lock, self.mWeaponData.IsLocked)
  setactive(self.mTrans_Equipped_HasParts, 0 < self.mWeaponData.PartsCount)
  local isGunEquipped = 0 < self.mWeaponData.gun_id
  setactive(self.mTrans_Equipped_InGun, isGunEquipped)
  setactive(self.mImage_Head, isGunEquipped)
  if isGunEquipped then
    local gunData = TableData.listGunDatas:GetDataById(self.mWeaponData.gun_id)
    if gunData then
      self.mImage_Head.sprite = IconUtils.GetCharacterHeadSprite(IconUtils.cCharacterAvatarType_Avatar, gunData.code)
    end
  end
  self.itemState.IsFocused = isFocus
  self.itemState.IsSelected = isSelect
  self.itemState.IsEquippedParts = 0 < self.mWeaponData.PartsCount
  self.itemState.IsLocked = self.mWeaponData.IsLocked
end
function UICommonWeaponInfoItem:SetData(weaponId, level, callback, hasTip, itemData, clickItem)
  if weaponId then
    self.mData = TableData.listGunWeaponDatas:GetDataById(weaponId)
    local elementData = TableData.listLanguageElementDatas:GetDataById(self.mData.element)
    self.mImage_Icon.sprite = IconUtils.GetWeaponSprite(self.mData.res_code)
    if level then
      self.mText_Count.text = GlobalConfig.SetLvText(level)
      setactive(self.mText_Count.gameObject, true)
    else
      setactive(self.mText_Count.gameObject, false)
    end
    self.mImage_Rank2.sprite = IconUtils.GetWeaponQuiltyByRank(self.mData.rank)
    self.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(self.mData.rank)
    setactive(self.mUIRoot, true)
    UIUtils.GetButtonListener(self.mBtn_Select.gameObject).onClick = function()
      if callback then
        callback(self)
      end
    end
    local curClickItem = clickItem == nil and self:GetRoot() or clickItem
    if hasTip == true then
      local itemData = TableData.GetItemData(weaponId)
      TipsManager.Add(curClickItem.gameObject, itemData)
    end
  else
    setactive(self.mUIRoot, false)
  end
end
function UICommonWeaponInfoItem:SetItem(itemId)
  if itemId then
    self.mData = TableData.listItemDatas:GetDataById(itemId)
    self.mImage_Icon.sprite = IconUtils.GetItemIconSprite(itemId)
    self.mImage_Rank2.sprite = IconUtils.GetWeaponQuiltyByRank(self.mData.rank)
    setactive(self.mTrans_Level, false)
    setactive(self.mTrans_Line, false)
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UICommonWeaponInfoItem:SetWeapon(weaponId)
  if weaponId then
    self.mData = TableData.listGunWeaponDatas:GetDataById(weaponId)
    self.mImage_Icon.sprite = IconUtils.GetWeaponSprite(self.mData.res_code)
    self.mImage_Rank2.sprite = IconUtils.GetWeaponQuiltyByRank(self.mData.rank)
    setactive(self.mTrans_Level, false)
    setactive(self.mTrans_Line, false)
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UICommonWeaponInfoItem:SetReceived(isReceived)
  setactive(self.mTrans_Received, isReceived)
end
function UICommonWeaponInfoItem:SetFirstDrop(isFirst)
  setactive(self.mTrans_First, isFirst)
end
function UICommonWeaponInfoItem:EnableButton(enable)
  self.mBtn_Select.interactable = enable
end
function UICommonWeaponInfoItem:IsNoneState()
  return not self.itemState.IsFocused and not self.itemState.IsSelected and not self.itemState.IsLocked and not self.itemState.IsEquippedParts
end
function UICommonWeaponInfoItem:IsSelect()
  return self.isChoose
end
function UICommonWeaponInfoItem:IsLock()
  return self.itemState.IsLocked
end
function UICommonWeaponInfoItem:IsFocused()
  return self.itemState.IsFocused
end
function UICommonWeaponInfoItem:IsEquippedParts()
  return self.itemState.IsEquippedParts
end
function UICommonWeaponInfoItem:Focus()
  self.itemState.IsFocused = true
  setactive(self.mTrans_Select, true)
end
function UICommonWeaponInfoItem:LoseFocus()
  self.itemState.IsFocused = false
  setactive(self.mTrans_Select, false)
end
function UICommonWeaponInfoItem:SetSelect(isChoose)
  self.isChoose = isChoose
  self.itemState.IsSelected = isChoose
  setactive(self.mTrans_Choose, self.isChoose)
end
function UICommonWeaponInfoItem:GetWeaponItemId()
  return self.mWeaponData.id
end
function UICommonWeaponInfoItem:GetWeaponPartsItemId()
  return self.mWeaponPartsData.id
end
function UICommonWeaponInfoItem:SetGunEquipped(isGunEquipped)
  setactive(self.mTrans_Equipped_InGun, isGunEquipped)
end
function UICommonWeaponInfoItem:UnEquipParts(callback)
  local onUninstallCallback = function(ret)
    if ret == ErrorCodeSuc then
      self.itemState.IsEquippedParts = self.mWeaponData.PartsCount > 0
      setactive(self.mTrans_Equipped_HasParts, self.itemState.IsEquippedParts)
    end
    if callback then
      callback(ret)
    end
  end
  NetCmdWeaponPartsData:ReqWeaponPartBelong(0, self.mWeaponData.id, 0, onUninstallCallback)
end
function UICommonWeaponInfoItem:Reset()
  self.mWeaponData = nil
  self.mWeaponPartsData = nil
  self.mData = nil
  UIUtils.GetButtonListener(self.mBtn_Select.gameObject).onClick = nil
  setactive(self.mTrans_Equipped_InGun, false)
  setactive(self.mTrans_Equipped_HasParts, false)
  setactive(self.mTrans_Equipped_InWeapon, false)
end
function UICommonWeaponInfoItem:OnRelease(isDestroy)
  self.mWeaponData = nil
  self.mWeaponPartsData = nil
  self.itemState = nil
  self.mData = nil
  UIUtils.GetButtonListener(self.mBtn_Select.gameObject).onClick = nil
  self.super.OnRelease(self, isDestroy)
end
