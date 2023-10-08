require("UI.UIBaseCtrl")
require("UI.WeaponPanel.UIWeaponGlobal")
UICommonItem = class("UICommonItem", UIBaseCtrl)
UICommonItem.__index = UICommonItem
function UICommonItem:ctor()
  self.itemId = 0
  self.itemNum = 0
  self.bagIndex = 0
  self.isItemEnough = false
  self.relateId = nil
  self.itemState = {
    IsFocused = false,
    IsSelected = false,
    IsLocked = false,
    IsEquippedParts = false
  }
  self.partData = nil
end
UICommonItem.mObj = nil
function UICommonItem:__InitCtrl()
end
function UICommonItem:InitObj(obj)
  if obj then
    self:SetRoot(obj.transform)
    self:__InitCtrl()
    self.ui = {}
    self:LuaUIBindTable(obj, self.ui)
  end
end
function UICommonItem:InitCtrl(parent, setToZero)
  local obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComItem.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, true)
  end
  self:InitCtrlWithNoInstantiate(obj, setToZero)
end
function UICommonItem:InitCtrlWithNoInstantiate(obj, setToZero)
  self:SetRoot(obj.transform)
  obj.transform.localPosition = vectorzero
  if setToZero == nil or setToZero then
    obj.transform.anchoredPosition = vector2zero
  else
    obj.transform.anchoredPosition = vector2one * 1000000
  end
  self:__InitCtrl()
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self.ui.mObj = obj
  self.timer = nil
end
function UICommonItem:SetItemData(id, num, needItemCount, needGetWay, tipsCount, relateId, callback, customOnClick, clickItem, hideCredit, data, itemCountSimplify, hideCompose, showUse)
  needGetWay = needGetWay == true and true or false
  needItemCount = needItemCount == true and true or false
  hideCompose = hideCompose == true and true or false
  showUse = showUse == true and true or false
  self:Reset()
  if id ~= nil then
    self.itemId = id
    self.itemNum = num
    local itemData = TableData.GetItemData(id)
    local itemOwn = 0
    self.data = data
    itemOwn = NetCmdItemData:GetItemCountById(id)
    self.ui.mImage_Icon.sprite = IconUtils.GetItemIconSprite(id)
    self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(itemData.rank)
    self.ui.mImage_Rank2.color = TableData.GetGlobalGun_Quality_Color2(itemData.rank, self.ui.mImage_Rank2.color.a)
    if needItemCount then
      self.isItemEnough = num <= itemOwn
      if num > itemOwn then
        if itemCountSimplify then
          local haveDigit = ResourcesCommonItem.ChangeNumDigit(itemOwn)
          local costDigit = ResourcesCommonItem.ChangeNumDigit(num)
          self.ui.mText_Num.text = "<color=#FF5E41>" .. haveDigit .. "</color>/" .. costDigit
        else
          self.ui.mText_Num.text = "<color=red>" .. itemOwn .. "</color>/" .. num
        end
      elseif itemCountSimplify then
        local haveDigit = ResourcesCommonItem.ChangeNumDigit(itemOwn)
        local costDigit = ResourcesCommonItem.ChangeNumDigit(num)
        self.ui.mText_Num.text = haveDigit .. "/" .. costDigit
      else
        self.ui.mText_Num.text = itemOwn .. "/" .. num
      end
    else
      self.ui.mText_Num.text = num
    end
    if itemData.type == GlobalConfig.ItemType.EquipPackages then
      self.ui.mImage_Icon.sprite = CS.IconUtils.GetIconV2("EquipmentIcon", itemData.icon .. "_1")
    end
    local canShowGetWay = (0 < itemData.compose.Count or 0 < string.len(itemData.get_list)) and needGetWay
    setactive(self.ui.mTrans_Num, self.itemNum ~= nil and self.itemNum > 0)
    local curClickItem = clickItem == nil and self.ui.mBtn_Select or clickItem
    if customOnClick == nil then
      TipsManager.Add(curClickItem.gameObject, itemData, tipsCount, canShowGetWay, false, relateId, callback, nil, nil, hideCredit, hideCompose, showUse)
    else
      UIUtils.GetButtonListener(self.ui.mBtn_Select.gameObject).onClick = function()
        customOnClick(self)
      end
    end
    setactive(self.ui.mTrans_JPText, not hideCredit and (itemData.id == GlobalConfig.ResourceType.CreditPay or itemData.id == GlobalConfig.ResourceType.CreditFree) and 0 < TableData.SystemVersionOpenData.FreePayCredit)
    if itemData.id == GlobalConfig.ResourceType.CreditPay then
      self.ui.mText_JPText.text = TableData.GetHintById(106054)
    elseif itemData.id == GlobalConfig.ResourceType.CreditFree then
      self.ui.mText_JPText.text = TableData.GetHintById(106055)
    end
    setactive(self.mUIRoot, true)
  else
    self.itemId = nil
    if self.mUIRoot then
      setactive(self.mUIRoot, false)
    end
  end
end
function UICommonItem:SetPVPChangeData(id, num, onClick)
  if id then
    self.itemId = id
    self.itemNum = num
    local itemData = TableData.GetItemData(id)
    local itemOwn = 0
    itemOwn = NetCmdItemData:GetItemCountById(id)
    self.ui.mText_Num.text = num
    self.ui.mImage_Icon.sprite = IconUtils.GetItemIconSprite(id)
    self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(itemData.rank)
    self.ui.mImage_Rank2.color = TableData.GetGlobalGun_Quality_Color2(itemData.rank, self.ui.mImage_Rank2.color.a)
    UIUtils.GetButtonListener(self.ui.mBtn_Select.gameObject).onClick = function()
      if onClick then
        onClick()
      end
    end
  end
end
function UICommonItem:LimitNumTop(num, digit)
  if digit then
    self.ui.mText_Num.text = CS.LuaUIUtils.GetNumberText(num, digit)
  else
    self.ui.mText_Num.text = CS.LuaUIUtils.GetNumberText(num)
  end
end
function UICommonItem:SetCostItemNum(haveNum, costNum, digit)
  if digit == nil then
    digit = 5
  end
  local haveDigit = CS.LuaUIUtils.GetNumberText(haveNum, digit)
  local costDigit = ResourcesCommonItem.ChangeNumDigit(costNum)
  if haveNum < costNum then
    self.ui.mText_Num.text = "<color=#FF5E41>" .. haveDigit .. "</color>/" .. costDigit
  else
    self.ui.mText_Num.text = haveDigit .. "/" .. costDigit
  end
end
function UICommonItem:DelayInteractable(time)
  self.ui.mBtn_Select.interactable = false
  self.timer = TimerSys:DelayCall(time, function()
    self.ui.mBtn_Select.interactable = true
  end)
end
function UICommonItem:SetblankItem()
  setactive(self.ui.mTrans_QualityNum, false)
  setactive(self.ui.mTrans_GrpBg, false)
  setactive(self.ui.mTrans_GrpItem, false)
  setactive(self.ui.mTrans_Fadein, false)
  setactive(self.ui.mTrans_ImgHL, false)
end
function UICommonItem:SetByItemData(itemData, count, isReceived, clickItem)
  setactive(self.ui.mImage_SuitIcon, false)
  local beShow = isReceived == false and itemData.time_limit > 0 and UIUtils.CheckIsTimeOut(itemData.time_limit) == false
  if beShow then
    self.ui.mImg_RightTop.sprite = IconUtils.GeItemIconSprite("Icon_TimeLimit")
  end
  setactive(self.ui.mImg_RightTop, beShow)
  self.mItemData = itemData
  if itemData.type == GlobalConfig.ItemType.Weapon then
    self:SetData(itemData.args[0], 1, nil, true, itemData, clickItem)
    self:SetReceivedIcon(isReceived)
  elseif itemData.type == GlobalConfig.ItemType.WeaponPart then
    self:SetWeaponPartData(itemData, isReceived)
  elseif itemData.type == GlobalConfig.ItemType.EquipmentType then
    self:SetEquipData(itemData.args[0], 0, nil, itemData.id, isReceived, clickItem)
  else
    self:SetItemDataAndReceive(itemData.id, count, nil, nil, nil, nil, isReceived, clickItem)
  end
end
function UICommonItem:SetItemDataAndReceive(id, num, needItemCount, needGetWay, tipsCount, relateId, isReceived, clickItem)
  self:SetItemData(id, num, needItemCount, needGetWay, tipsCount, relateId, nil, nil, clickItem)
  self:SetReceivedIcon(isReceived ~= nil and isReceived or false)
  self:EnableEquipIndex(false)
end
function UICommonItem:SetEquipByData(data, callback, isChoose, clickItem)
  self.ui.mData = data
  self:SetEquipData(data.stcId, data.level, callback, clickItem)
  if isChoose ~= nil then
    self:SetSelect(isChoose)
  else
    self:SetSelect(false)
  end
  if data then
    setactive(self.ui.mTrans_Lock, data.locked)
    setactive(self.ui.mTrans_Equipped, data.gun_id > 0)
    if data.gun_id > 0 then
      local gunData = TableData.listGunDatas:GetDataById(data.gun_id)
      self.ui.mImage_Head.sprite = IconUtils.GetCharacterHeadSpriteWithClothByGunId(IconUtils.cCharacterAvatarType_Avatar, gunData.id)
    end
  end
end
function UICommonItem:SetDarkZoneEquipByData(data, callback)
  self.ui.mData = data
  self:SetDarkZoneEquipData(data.stcId, data.equipped, callback)
  if data then
    setactive(self.ui.mTrans_Lock, data.Locked)
  end
end
function UICommonItem:SetDarkZoneItemData(id, count, callback, relateId)
  local itemData = TableData.GetItemData(id)
  self.ui.mImage_Icon.sprite = IconUtils.GetItemIconSprite(id)
  self:EnableDarkZoneEquipped(false)
  self:EnableDarkZoneCoin(false)
  if count == nil or count < 0 then
    setactive(self.ui.mTrans_Num, false)
  else
    setactive(self.ui.mTrans_Num, true)
  end
  if callback then
    UIUtils.GetButtonListener(self.ui.mBtn_Select.gameObject).onClick = function()
      callback(self)
    end
  else
    TipsManager.Add(self.ui.mBtn_Select.gameObject, TableData.GetItemData(id), nil, nil, nil, relateId)
  end
end
function UICommonItem:SetDarkZoneEquipData(id, equipped, callback, relateId, data)
  local itemData = TableData.GetItemData(id)
  if equipped ~= nil then
    self:EnableDarkZoneEquipped(equipped)
  end
  self:EnableDarkZoneCoin(false)
  self.ui.mImage_Icon.sprite = IconUtils.GetItemIconSprite(id)
  setactive(self.ui.mTrans_Num, false)
  if callback then
    if data then
      UIUtils.GetButtonListener(self.ui.mBtn_Select.gameObject).onClick = function()
        callback(data)
      end
    else
      UIUtils.GetButtonListener(self.ui.mBtn_Select.gameObject).onClick = function()
        callback(self)
      end
    end
  else
    TipsManager.Add(self.ui.mBtn_Select.gameObject, TableData.GetItemData(id), nil, nil, nil, relateId)
  end
end
function UICommonItem:SetRankAndIconData(rank, icon, itemId, num, clickItem)
  if icon ~= nil then
    self.ui.mImage_Icon.sprite = icon
  end
  self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(rank)
  self.ui.mImage_Rank2.color = TableData.GetGlobalGun_Quality_Color2(rank, self.ui.mImage_Rank2.color.a)
  local curClickItem = clickItem == nil and self.ui.mBtn_Select or clickItem
  if itemId ~= nil then
    TipsManager.Add(curClickItem.gameObject, TableData.GetItemData(itemId), nil, false)
  end
  if num ~= nil then
    self.ui.mText_Num.text = num
  end
  setactive(self.ui.mTrans_Num, num ~= nil)
end
function UICommonItem:SetSelect(isChoose)
  self.isChoose = isChoose
  setactive(self.ui.mTrans_Choose, isChoose)
end
function UICommonItem:SetFirstDrop(isFirst)
  setactive(self.ui.mTrans_First, isFirst)
end
function UICommonItem:SetReceived(isReceived)
  setactive(self.ui.mTrans_Received, isReceived)
end
function UICommonItem:SetRedPoint(enable)
  setactive(self.ui.mTrans_RedPoint, enable)
end
function UICommonItem:SetRedPointAni(enable)
  if self.ui.mTrans_RedPoint == nil then
    return
  end
  local animation = self.ui.mTrans_RedPoint:GetComponentInChildren(typeof(CS.UnityEngine.Animation))
  if not animation then
    return
  end
  animation.enabled = enable
end
function UICommonItem:IsItemEnough()
  return self.isItemEnough
end
function UICommonItem:EnableButton(enable)
  self.ui.mBtn_Select.interactable = enable
end
function UICommonItem:EnableEquipIndex(enable)
end
function UICommonItem:EnableDarkZoneEquipped(enable)
  setactive(self.ui.mTrans_DarkZoneEquipped, enable)
end
function UICommonItem:EnableSel(enable)
  setactive(self.ui.mTrans_Sel, enable)
end
function UICommonItem:EnableDarkZoneCoin(enable)
  setactive(self.ui.mTrans_DarkzoneCoin, enable)
end
function UICommonItem:FreshItemCount(num)
  if num then
    self.itemNum = num
  end
  local itemOwn = 0
  itemOwn = NetCmdItemData:GetItemCountById(self.itemId)
  self.isItemEnough = itemOwn >= self.itemNum
  if itemOwn < self.itemNum then
    self.ui.mText_Num.text = "<color=red>" .. itemOwn .. "</color>/" .. self.itemNum
  else
    self.ui.mText_Num.text = itemOwn .. "/" .. self.itemNum
  end
end
function UICommonItem:RefreshItemNum(num, onlyItemNum)
  if num then
    self.itemNum = num
  end
  local itemOwn = 0
  itemOwn = NetCmdItemData:GetItemCountById(self.itemId)
  self.isItemEnough = itemOwn >= self.itemNum
  if itemOwn < self.itemNum then
    self.ui.mText_Num.text = onlyItemNum and "<color=red>" .. self.itemNum .. "</color>" or "<color=red>" .. itemOwn .. "</color>/" .. self.itemNum
  else
    self.ui.mText_Num.text = onlyItemNum and self.itemNum or itemOwn .. "/" .. self.itemNum
  end
end
function UICommonItem:SetExtraIconVisible(visible)
  if visible then
    setactive(self.ui.mImg_RightTop, visible)
    self.ui.mImg_RightTop.sprite = IconUtils.GeItemIconSprite("Icon_ItemExtra")
  end
end
function UICommonItem:SetUpIconVisible(visible)
  if visible then
    setactive(self.ui.mImg_RightTop, visible)
    self.ui.mImg_RightTop.sprite = IconUtils.GeItemIconSprite("Icon_Up")
  end
end
function UICommonItem:SetAniFadein()
  self.ui.mAni_Root:SetTrigger("FadeIn")
end
function UICommonItem:SetByData(data, callback, isChoose)
  self:SetData(data.stcId or data.stc_id, data.level or data.Level, callback)
  self.mData = data
  if isChoose ~= nil then
    self:SetSelect(isChoose)
  else
    self:SetSelect(false)
  end
  if data then
    setactive(self.ui.mTrans_Lock, data.IsLocked)
    setactive(self.ui.mTrans_Equipped_InGun, data.gun_id > 0)
    if data.gun_id > 0 then
      local gunData = TableData.listGunDatas:GetDataById(data.gun_id)
      if gunData then
        self.ui.mImage_Head.sprite = IconUtils.GetCharacterHeadSpriteWithClothByGunId(IconUtils.cCharacterAvatarType_Avatar, gunData.id)
      end
    end
  end
end
function UICommonItem:SetWeaponPartsData(data, callback, isFocus, isSelect)
  if not data then
    setactive(self.mUIRoot, false)
    return
  end
  self:Reset()
  self.mWeaponPartsData = data
  UIUtils.GetButtonListener(self.ui.mBtn_Select.gameObject).onClick = function()
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
  self.ui.mCanvasGroup_Text.alpha = 1
  setactive(self.ui.mTrans_Lock, self.mWeaponPartsData.IsLocked)
  setactive(self.ui.mTrans_Equipped_HasParts, false)
  local isWeaponEquipped = self.mWeaponPartsData.equipWeapon ~= 0
  local isGunEquipped = self.mWeaponPartsData.equipGun ~= 0
  setactive(self.ui.mTrans_Equipped_InGun, isWeaponEquipped and isGunEquipped)
  setactive(self.ui.mImage_Head, isWeaponEquipped and isGunEquipped)
  if isWeaponEquipped and isGunEquipped then
    local gunData = TableData.listGunDatas:GetDataById(self.mWeaponPartsData.equipGun, true)
    if gunData then
      self.ui.mImage_Head.sprite = IconUtils.GetCharacterHeadSpriteWithClothByGunId(IconUtils.cCharacterAvatarType_Avatar, gunData.id)
    end
  end
  if self.mWeaponPartsData.ModEffectTypeData then
    self.ui.mImg_PartsEffectType.sprite = IconUtils.GetWeaponPartIconSprite(self.mWeaponPartsData.ModEffectTypeData.Icon, false)
    setactive(self.ui.mTrans_PartsEffectType, true)
    if self.mWeaponPartsData.ModEffectTypeData.EffectId == UIWeaponGlobal.ModEffectType.Cover then
      setactive(self.ui.mTrans_SuitRoot, true)
      local dataSuit
      if self.mWeaponPartsData.suitId ~= 0 then
        dataSuit = TableData.listModPowerEffectDatas:GetDataById(self.mWeaponPartsData.suitId)
      end
      if dataSuit ~= nil then
        self.ui.mImage_SuitIcon.sprite = IconUtils.GetWeaponPartIconSprite(dataSuit.image, false)
      end
    end
  else
    setactive(self.ui.mTrans_PartsEffectType, false)
  end
  setactive(self.ui.mTrans_PolarityIcon, self.mWeaponPartsData.PolarityId ~= 0)
  if self.mWeaponPartsData.PolarityId ~= 0 then
    self.ui.mImg_PolarityIcon.sprite = IconUtils.GetElementIcon(TableData.listPolarityTagDatas:GetDataById(self.mWeaponPartsData.PolarityId).Icon .. "_S")
  end
  setactive(self.ui.mTrans_WeaponPartVolume, false)
  self.ui.mText_WeaponPartVolume.text = tostring(self.mWeaponPartsData.Capacity)
  self.ui.mImage_Icon.sprite = IconUtils.GetWeaponPartIconSprite(self.mWeaponPartsData.icon)
  setactive(self.ui.mTrans_Num, true)
  CS.GunWeaponModData.SetModLevelText(self.ui.mText_Num, self.mWeaponPartsData, nil, false, self.ui.mCanvasGroup_Text, 0.4)
  self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(self.mWeaponPartsData.rank)
  self.ui.mImage_Rank2.color = TableData.GetGlobalGun_Quality_Color2(self.mWeaponPartsData.rank, self.ui.mImage_Rank2.color.a)
end
function UICommonItem:SetWeaponDataNoLock(data, callback)
  self:SetWeaponData(data, callback)
  self:SetWeaponLocked(false)
end
function UICommonItem:SetWeaponData(data, callback, isFocus, isSelect, num, showEquipped, enableClick)
  if enableClick == nil then
    enableClick = true
  end
  self.ui.mBtn_Select.enabled = enableClick
  self:Reset()
  local weaponID = data.id
  local weaponStcId = data.stc_id
  setactive(self.ui.mEquip_Light, false)
  setactive(self.ui.mImage_SuitIcon, false)
  self.mWeaponData = NetCmdWeaponData:GetWeaponById(weaponID)
  if self.mWeaponData == nil then
    self.mWeaponData = NetCmdWeaponData:GetWeaponByStcId(data.stc_id)
  end
  self.ui.mImage_Icon.sprite = IconUtils.GetWeaponSprite(self.mWeaponData.StcData.res_code)
  self.ui.mImage_Rank2.color = TableData.GetGlobalGun_Quality_Color2(self.mWeaponData.Rank, self.ui.mImage_Rank2.color.a)
  self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(self.mWeaponData.Rank)
  local duplicateNum = 0
  local breakNum = 0
  local hasGet = self.mWeaponData.CmdData ~= nil
  if hasGet == true then
    duplicateNum = self.mWeaponData.WeaponduplicateNum
    breakNum = self.mWeaponData.BreakTimes
  else
  end
  showEquipped = showEquipped == nil and true or showEquipped ~= nil and showEquipped == true
  local isGunEquipped = 0 < self.mWeaponData.gun_id and showEquipped
  setactive(self.ui.mTrans_Lock, data.IsLocked)
  setactive(self.ui.mTrans_Equipped_InGun, isGunEquipped)
  setactive(self.ui.mImage_Head, isGunEquipped)
  if isGunEquipped then
    local gunData = TableData.listGunDatas:GetDataById(self.mWeaponData.gun_id)
    if gunData then
      self.ui.mImage_Head.sprite = IconUtils.GetCharacterHeadSpriteWithClothByGunId(IconUtils.cCharacterAvatarType_Avatar, gunData.id)
    end
  end
  setactive(self.ui.mTrans_WeaponLocked, hasGet == false)
  setactive(self.ui.mTrans_BreakNum, 0 < breakNum)
  if 0 < breakNum then
    self.ui.mImg_BreakNum.sprite = IconUtils.GetUIWeaponBreakNum("Img_BreakNum" .. breakNum .. "_S")
    UIWeaponGlobal.SetBreakTimesImg(self.ui.mImg_BreakNum, breakNum, self.mWeaponData.MaxBreakTime)
  end
  self.ui.mText_Num.text = GlobalConfig.SetLvText(data.Level)
  local curClickItem = self:GetRoot()
  if hasGet == true and callback ~= nil then
    UIUtils.GetButtonListener(self.ui.mBtn_Select.gameObject).onClick = function()
      if callback then
        callback(self)
      end
    end
  else
    local itemData = TableData.GetItemData(weaponStcId)
    TipsManager.Add(curClickItem.gameObject, itemData)
  end
end
function UICommonItem:SetPublicSkillData(data, callback)
  self:Reset()
  local itemData = data.SkillItemData
  self.ui.mImage_Icon.sprite = IconUtils.GetItemIconSprite(itemData.id)
  self.ui.mImage_Rank2.color = TableData.GetGlobalGun_Quality_Color2(itemData.rank, self.ui.mImage_Rank2.color.a)
  self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(itemData.rank, self.ui.mImage_Rank.color.a)
  setactive(self.mUIRoot, true)
  setactive(self.ui.mTrans_Num, false)
  local isGunEquipped = data.ownerId > 0
  setactive(self.ui.mTrans_Equipped_InGun, isGunEquipped)
  setactive(self.ui.mImage_Head, isGunEquipped)
  if isGunEquipped then
    local gunData = TableData.listGunDatas:GetDataById(data.ownerId)
    if gunData then
      self.ui.mImage_Head.sprite = IconUtils.GetCharacterHeadSpriteWithClothByGunId(IconUtils.cCharacterAvatarType_Avatar, gunData.id)
    end
  end
  self.data = data
  if callback then
    UIUtils.GetButtonListener(self.ui.mBtn_Select.gameObject).onClick = function()
      if callback then
        callback(self)
      end
    end
  else
    TipsManager.Add(self:GetRoot().gameObject, itemData)
  end
end
function UICommonItem:SetData(weaponId, level, callback, hasTip, itemData, clickItem)
  if weaponId then
    setactive(self.ui.mImage_SuitIcon, false)
    self.mData = TableData.listGunWeaponDatas:GetDataById(weaponId)
    local elementData = TableData.listLanguageElementDatas:GetDataById(self.mData.element)
    self.ui.mImage_Icon.sprite = IconUtils.GetWeaponSprite(self.mData.res_code)
    if level then
      self.ui.mText_Num.text = GlobalConfig.SetLvText(level)
      setactive(self.ui.mText_Num.gameObject, true)
    else
      setactive(self.ui.mText_Num.gameObject, false)
    end
    self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(self.mData.rank)
    self.ui.mImage_Rank2.color = TableData.GetGlobalGun_Quality_Color2(self.mData.rank, self.ui.mImage_Rank2.color.a)
    setactive(self.mUIRoot, true)
    UIUtils.GetButtonListener(self.ui.mBtn_Select.gameObject).onClick = function()
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
function UICommonItem:SetItem(itemId)
  if itemId then
    self.mData = TableData.listItemDatas:GetDataById(itemId)
    self.ui.mImage_Icon.sprite = IconUtils.GetItemIconSprite(itemId)
    self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(self.mData.rank)
    self.ui.mImage_Rank2.color = TableData.GetGlobalGun_Quality_Color2(self.mData.rank, self.ui.mImage_Rank2.color.a)
    setactive(self.ui.mTrans_Num, false)
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UICommonItem:SetWeapon(weaponId)
  if weaponId then
    self.mData = TableData.listGunWeaponDatas:GetDataById(weaponId)
    self.ui.mImage_Icon.sprite = IconUtils.GetWeaponSprite(self.mData.res_code)
    setactive(self.ui.mTrans_Line, false)
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UICommonItem:SetReceived(isReceived)
  if self.mItemData == nil then
    local itemData = TableData.GetItemData(self.itemId)
    self.mItemData = itemData
  end
  local time = self.mItemData.time_limit
  local isTimeOut = 0 < time and UIUtils.CheckIsTimeOut(time)
  setactive(self.ui.mTrans_Received, isReceived or isTimeOut == true)
  if isTimeOut then
    self.ui.mText_Hint.text = TableData.GetHintById(190005)
  else
    self.ui.mText_Hint.text = TableData.GetHintById(903236)
  end
end
function UICommonItem:SetFirstDrop(isFirst)
  if isFirst then
    self.ui.mImg_RightTop.sprite = IconUtils.GeItemIconSprite("Icon_First")
  end
  setactive(self.ui.mImg_RightTop, isFirst)
end
function UICommonItem:SetFirstDropVisible(visible)
  setactive(self.ui.mImg_RightTop, visible)
  self.ui.mImg_RightTop.sprite = IconUtils.GeItemIconSprite("Icon_First")
end
function UICommonItem:SetTopRightIcon(sprite)
  self.ui.mImg_RightTop.sprite = sprite
end
function UICommonItem:SetTopRightIconVisible(visible)
  setactive(self.ui.mImg_RightTop, visible)
end
function UICommonItem:EnableButton(enable)
  self.ui.mBtn_Select.interactable = enable
end
function UICommonItem:IsNoneState()
  return not self.itemState.IsFocused and not self.itemState.IsSelected and not self.itemState.IsLocked and not self.itemState.IsEquippedParts
end
function UICommonItem:IsSelect()
  return self.isChoose
end
function UICommonItem:IsLock()
  return self.itemState.IsLocked
end
function UICommonItem:IsFocused()
  return self.itemState.IsFocused
end
function UICommonItem:IsEquippedParts()
  return self.itemState.IsEquippedParts
end
function UICommonItem:Focus()
  self.itemState.IsFocused = true
  setactive(self.ui.mImg_Sel, true)
end
function UICommonItem:LoseFocus()
  self.itemState.IsFocused = false
  setactive(self.ui.mImg_Sel, false)
end
function UICommonItem:SetSelect(isChoose)
  self.isChoose = isChoose
  self.itemState.IsSelected = isChoose
  setactive(self.ui.mTrans_Choose, self.isChoose)
end
function UICommonItem:SetLock(isLock)
  self.isLock = isLock
  setactive(self.ui.mTrans_Lock, isLock)
end
function UICommonItem:SetLockColor()
  self.ui.mImg_Lock.color = ColorUtils.StringToColor("C9C8CE")
end
function UICommonItem:SetWeaponLocked(isLock)
  setactive(self.ui.mTrans_WeaponLocked, isLock)
  setactive(self.ui.mImg_WeaponLock, true)
end
function UICommonItem:SetBlackMask(bShow)
  setactive(self.ui.mTrans_WeaponLocked, bShow)
  setactive(self.ui.mImg_WeaponLock, false)
end
function UICommonItem:SetReceivedIcon(isReceived)
  setactive(self.ui.mTrans_ReceivedIcon, isReceived)
end
function UICommonItem:SetRewardEffect(isShow)
  setactive(self.ui.mTrans_RewardEffect, isShow)
end
function UICommonItem:SetPromptEffect(isShow)
  setactive(self.ui.mPromptEffect, isShow)
  setactive(self.ui.mPromptEffect.transform.parent, isShow)
end
function UICommonItem:GetWeaponItemId()
  return self.mWeaponData.id
end
function UICommonItem:GetWeaponItemStcId()
  return self.mWeaponData.stc_id
end
function UICommonItem:GetWeaponPartsItemId()
  if not self.mWeaponPartsData then
    return 0
  end
  return self.mWeaponPartsData.id
end
function UICommonItem:SetGunEquipped(isGunEquipped)
  setactive(self.ui.mTrans_Equipped_InGun, isGunEquipped)
end
function UICommonItem:UnEquipParts(callback)
  local onUninstallCallback = function(ret)
    if ret == ErrorCodeSuc then
      self.itemState.IsEquippedParts = self.mWeaponData.PartsCount > 0
      setactive(self.ui.mTrans_Equipped_HasParts, self.itemState.IsEquippedParts)
    end
    if callback then
      callback(ret)
    end
  end
  NetCmdWeaponPartsData:ReqWeaponPartBelong(0, self.mWeaponData.id, 0, onUninstallCallback)
end
function UICommonItem:Reset()
  self.mWeaponData = nil
  self.mWeaponPartsData = nil
  self.mData = nil
  UIUtils.GetButtonListener(self.ui.mBtn_Select.gameObject).onClick = nil
  setactive(self.ui.mTrans_RedPoint, false)
  setactive(self.ui.mTrans_Equipped_InGun, false)
  setactive(self.ui.mTrans_Equipped_HasParts, false)
  setactive(self.ui.mTrans_Equipped_InWeapon, false)
  setactive(self.ui.mTrans_ChooseNum, false)
  setactive(self.ui.mImage_SuitIcon, false)
  setactive(self.ui.mTrans_Lock, false)
  setactive(self.ui.mTrans_BreakNum, false)
  setactive(self.ui.mEquip_Light, false)
  setactive(self.ui.mTrans_WeaponLocked, false)
  setactive(self.ui.mTrans_Num, true)
  setactive(self.ui.mTrans_Lock, false)
  setactive(self.ui.mImage_Head, false)
  setactive(self.ui.mTrans_PartsEffectType, false)
  setactive(self.ui.mTrans_SuitRoot, false)
  setactive(self.ui.mTrans_PolarityIcon, false)
  setactive(self.ui.mTrans_CardDisplay, false)
  self.ui.mCanvasGroup_Text.alpha = 1
  self:ReleaseTimers()
  if self.frameDelayTimer then
    self.frameDelayTimer:Stop()
    self.frameDelayTimer = nil
  end
end
function UICommonItem:OnRelease(isDestroy)
  self.mWeaponData = nil
  self.mWeaponPartsData = nil
  self.itemState = nil
  self.mData = nil
  self.timer = nil
  UIUtils.GetButtonListener(self.ui.mBtn_Select.gameObject).onClick = nil
  self.super.OnRelease(self, isDestroy)
end
function UICommonItem:SetQualityLine(isOn)
  setactive(self.ui.mTrans_QualityLine, isOn)
end
function UICommonItem:EnableButton(enable)
  self.ui.mBtn_Select.interactable = enable
end
function UICommonItem:SetLevel(isOn)
  if isOn == false then
    setactive(self.ui.mTrans_Num, false)
  end
end
function UICommonItem:SetDaiyanCommandData(commandID)
  self:Reset()
  if not commandID then
    setactive(self.mUIRoot, false)
    return
  end
  local data = TableData.listMonopolyOrderDatas:GetDataById(commandID)
  if not data then
    setactive(self.mUIRoot, false)
    return
  end
  setactive(self.mUIRoot, true)
  self.ui.mImage_Icon.sprite = IconUtils.GetActivityTourIcon(data.order_icon)
  self.ui.mImage_Rank.color = TableData.GetActivityTourCommand_Quality_Color(data.level)
  self.ui.mText_Num.text = string_format(TableData.GetHintById(270277), data.level)
  UIUtils.GetButtonListener(self.ui.mBtn_Select.gameObject).onClick = function()
    UITipsPanel.OpenCommandDetail(data)
  end
end
function UICommonItem:SetWeaponPartData(itemData, isReceived)
  local partData = CS.GunWeaponModData(itemData.args[0])
  self:SetPartData(partData)
  self:SetReceivedIcon(isReceived)
  self:SetQualityLine(true)
  self:SetReceiveData(partData)
  TipsManager.Add(self.ui.mBtn_Select.gameObject, itemData, 1, false, nil, nil, nil, nil, false)
end
function UICommonItem:SetReceiveData(partData)
  if partData == nil then
    setactive(self.mUIRoot, false)
    return
  end
  self.partData = partData
  self:UpdateReceivePartInfo()
  setactive(self.ui.mTrans_Add, false)
  setactive(self.mUIRoot, true)
end
function UICommonItem:SetImageMaterial(mat)
  self.ui.mImage_Icon.material = mat
end
function UICommonItem:SetPartData(partData, needShowLevel, needShowLock)
  if partData == nil then
    setactive(self.mUIRoot, false)
    return
  end
  self.partData = partData
  self:UpdatePartInfo()
  if partData.isSelect == nil then
    setactive(self.ui.mImg_Sel, false)
  else
    setactive(self.ui.mImg_Sel, partData.isSelect)
  end
  setactive(self.ui.mTrans_Add, false)
  setactive(self.mUIRoot, true)
  if needShowLock == false then
    setactive(self.ui.mTrans_Lock, false)
  elseif self.partData.isLock == nil then
    setactive(self.ui.mTrans_Lock, self.partData.IsLocked)
  else
    setactive(self.ui.mTrans_Lock, self.partData.isLock)
  end
end
function UICommonItem:SetDisplay(partData)
  if partData == nil then
    setactive(self.mUIRoot, false)
    return
  end
  self.partData = partData
  self:UpdateDisplayInfo()
  setactive(self.ui.mTrans_PartInfo, true)
  setactive(self.ui.mTrans_Add, false)
  setactive(self.ui.mUIRoot, true)
end
function UICommonItem:UpdateDisplayInfo()
  local suitData = TableData.listModPowerEffectDatas:GetDataById(self.partData.suitId)
  self.ui.mImage_Icon.sprite = IconUtils.GetWeaponPartIcon(self.partData.icon)
  self.ui.mImage_SuitIcon.sprite = IconUtils.GetWeaponPartIcon(suitData.image, false)
  setactive(self.ui.mTrans_Num, false)
  self:SetQualityLine(false)
end
function UICommonItem:UpdatePartInfo()
  local suitData = TableData.listModPowerEffectDatas:GetDataById(self.partData.suitId, true)
  self.ui.mImage_Icon.sprite = IconUtils.GetWeaponPartIconSprite(self.partData.icon)
  self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(self.partData.rank)
  self.ui.mImage_Rank2.color = TableData.GetGlobalGun_Quality_Color2(self.partData.rank, self.ui.mImage_Rank2.color.a)
  self.ui.mCanvasGroup_Text.alpha = 1
  setactive(self.ui.mTrans_PolarityIcon, self.partData.PolarityId ~= nil and self.partData.PolarityId ~= 0)
  if self.partData.PolarityId ~= nil and self.partData.PolarityId ~= 0 then
    self.ui.mImg_PolarityIcon.sprite = IconUtils.GetElementIcon(TableData.listPolarityTagDatas:GetDataById(self.partData.PolarityId).Icon .. "_S")
  end
  if self.partData.ModEffectTypeData then
    self.ui.mImg_PartsEffectType.sprite = IconUtils.GetWeaponPartIconSprite(self.partData.ModEffectTypeData.Icon, false)
    setactive(self.ui.mTrans_PartsEffectType, true)
    if self.partData.ModEffectTypeData.EffectId == UIWeaponGlobal.ModEffectType.Cover and self.partData.ModSuitData ~= nil then
      setactive(self.ui.mTrans_SuitRoot, true)
      local dataSuit
      if self.partData.suitId ~= 0 then
        dataSuit = TableData.listModPowerEffectDatas:GetDataById(self.partData.suitId)
      end
      if dataSuit ~= nil then
        self.ui.mImage_SuitIcon.sprite = IconUtils.GetWeaponPartIconSprite(dataSuit.image, false)
      end
    else
      setactive(self.ui.mTrans_SuitRoot, false)
    end
  else
    setactive(self.ui.mTrans_PartsEffectType, false)
  end
  CS.GunWeaponModData.SetModLevelText(self.ui.mText_Num, self.partData, nil, false, self.ui.mCanvasGroup_Text, 0.4)
  self.ui.mBtn_Select.interactable = not self.partData.isSelect
  if self.partData.isLock == nil then
    setactive(self.ui.mTrans_Lock, self.partData.IsLocked)
  else
    setactive(self.ui.mTrans_Lock, self.partData.isLock)
  end
  local isGunEquipped = self.partData.equipGun ~= nil and 0 < self.partData.equipGun
  local isWeaponEquipped = self.partData.equipWeapon ~= nil and 0 < self.partData.equipWeapon and not isGunEquipped
  setactive(self.ui.mTrans_Equipped_InGun, isGunEquipped)
  setactive(self.ui.mImage_Head, isGunEquipped)
  setactive(self.ui.mTrans_Equipped_InWeapon, isWeaponEquipped)
  if isGunEquipped then
    local gunData = TableData.listGunDatas:GetDataById(self.partData.equipGun)
    if gunData then
      self.ui.mImage_Head.sprite = IconUtils.GetCharacterHeadSpriteWithClothByGunId(IconUtils.cCharacterAvatarType_Avatar, gunData.id)
    end
  end
end
function UICommonItem:UpdateReceivePartInfo()
  self.ui.mImage_Icon.sprite = IconUtils.GetWeaponPartIcon(self.partData.icon)
  self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(self.partData.rank)
  self.ui.mImage_Rank2.color = TableData.GetGlobalGun_Quality_Color2(self.partData.rank, self.ui.mImage_Rank2.color.a)
end
function UICommonItem:SetNowEquip(isEquip)
  setactive(self.ui.mTrans_SelNow, isEquip)
end
function UICommonItem:SetSelectShow(isShow)
  setactive(self.ui.mTrans_Select, isShow)
end
function UICommonItem:SetSlotData(partData, typeId, slotId)
  if partData == nil and typeId == nil then
    self.partData = nil
    self.typeId = nil
    self.slotId = 0
    setactive(self.mUIRoot, false)
    return
  end
  self.partData = partData
  self.typeId = typeId
  self.slotId = slotId
  if self.partData == nil then
    local slotData = TableData.listWeaponModTypeDatas:GetDataById(typeId)
    self.ui.mImage_Icon.sprite = IconUtils.GetWeaponPartIcon(slotData.icon)
    setactive(self.ui.mImage_SuitIcon.gameObject, false)
    setactive(self.ui.mTrans_Lock, false)
    setactive(self.ui.mTrans_RedPoint, NetCmdWeaponPartsData:HasHeigherNotUsedMod(self.typeId, 0))
  else
    self:UpdateSlotPartInfo()
    setactive(self.ui.mTrans_RedPoint, NetCmdWeaponPartsData:HasHeigherNotUsedMod(self.typeId, self.partData.stcId))
  end
  self:ShowPartData(self.partData ~= nil)
  setactive(self.ui.mTrans_Add, self.partData == nil)
  setactive(self.mUIRoot, true)
end
function UICommonItem:UpdateSlotPartInfo()
  local suitData = TableData.listModPowerEffectDatas:GetDataById(self.partData.suitId)
  self.ui.mImage_Icon.sprite = IconUtils.GetWeaponPartIcon(self.partData.icon)
  self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(self.partData.rank)
  self.ui.mImage_Rank2.color = TableData.GetGlobalGun_Quality_Color2(self.partData.rank, self.ui.mImage_Rank2.color.a)
  if suitData ~= nil then
    setactive(self.ui.mTrans_SuitRoot, true)
    setactive(self.ui.mImage_SuitIcon.gameObject, true)
    self.ui.mImage_SuitIcon.sprite = IconUtils.GetWeaponPartIcon(suitData.image, false)
  else
    setactive(self.ui.mTrans_SuitRoot, false)
    setactive(self.ui.mImage_SuitIcon.gameObject, false)
  end
  self.ui.mText_Num.text = GlobalConfig.SetLvText(self.partData.level)
  if self.partData.isLock == nil then
    setactive(self.ui.mTrans_Lock, self.partData.IsLocked)
  else
    setactive(self.ui.mTrans_Lock, self.partData.isLock)
  end
end
function UICommonItem:ShowPartData(boolean)
  setactive(self.ui.mTrans_QualityLine, boolean)
  self:SetLevel(boolean)
  setactive(self.ui.mImage_Icon, boolean)
end
function UICommonItem:SetItemSelect(isSelect)
  self.ui.mBtn_Select.interactable = not isSelect
  setactive(self.ui.mImg_Sel, isSelect)
end
function UICommonItem:SetMaterialData(data, isCanNotSelect)
  if self.longPress == nil then
    self.longPress = CS.LongPressTriggerListener.Set(self.mUIRoot.gameObject, 0.5, true)
  end
  if self.minusLongPress == nil then
    self.minusLongPress = CS.LongPressTriggerListener.Set(self.ui.mBtn_Reduce.gameObject, 0.5, true)
  end
  if data then
    self.mData = data
    if data.type == UIWeaponGlobal.MaterialType.Item then
      self.ui.mImage_Icon.sprite = IconUtils.GetItemIconSprite(data.id)
      self.ui.mText_Num.text = data.count
      self.longPress.enabled = true
    elseif data.type == UIWeaponGlobal.MaterialType.Weapon then
      self.ui.mImage_Icon.sprite = IconUtils.GetWeaponSprite(data.icon)
      self.ui.mText_Num.text = GlobalConfig.SetLvText(data.level)
      self.longPress.enabled = false
    end
    self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(data.rank)
    self.ui.mImage_Rank2.color = TableData.GetGlobalGun_Quality_Color2(data.rank, self.ui.mImage_Rank2.color.a)
    self.ui.mText_SelectCount.text = data.selectCount
    setactive(self.ui.mTrans_Reduce, data.selectCount > 0 and data.type == UIWeaponGlobal.MaterialType.Item)
    setactive(self.ui.mTrans_Choose, data.selectCount > 0 and data.type == UIWeaponGlobal.MaterialType.Weapon)
    setactive(self.ui.mTrans_Lock, data.isLock)
    setactive(self.ui.mImg_Sel, self.mData.isSelect)
    setactive(self.ui.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UICommonItem:SetMaterialPartData(data)
  if self.longPress == nil then
    self.longPress = CS.LongPressTriggerListener.Set(self.mUIRoot.gameObject, 0.5, true)
  end
  if self.minusLongPress == nil then
    self.minusLongPress = CS.LongPressTriggerListener.Set(self.ui.mBtn_Reduce.gameObject, 0.5, true)
  end
  if data then
    self.mData = data
    setactive(self.ui.mText_Num.gameObject, true)
    self.ui.mCanvasGroup_Text.alpha = 1
    if data.itemData ~= nil then
      self.ui.mImage_Icon.sprite = IconUtils.GetItemIconSprite(data.itemData.id)
      self.ui.mText_Num.text = NetCmdItemData:GetItemCountById(data.itemData.id)
      self.longPress.enabled = true
      setactive(self.ui.mTrans_Reduce, data.selectCount ~= nil and data.selectCount > 0)
      setactive(self.ui.mTrans_Choose, false)
      self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(data.itemData.rank, self.ui.mImage_Rank.color.a)
      self.ui.mImage_Rank2.color = TableData.GetGlobalGun_Quality_Color2(data.itemData.rank, self.ui.mImage_Rank2.color.a)
      setactive(self.ui.mTrans_PartsEffectType, false)
    elseif data.gunWeaponModData ~= nil then
      self.ui.mImage_Icon.sprite = IconUtils.GetWeaponPartIcon(data.gunWeaponModData.icon)
      CS.GunWeaponModData.SetModLevelText(self.ui.mText_Num, data.gunWeaponModData, nil, false, self.ui.mCanvasGroup_Text, 0.4)
      setactive(self.ui.mTrans_PolarityIcon, data.gunWeaponModData.PolarityId ~= 0)
      if data.gunWeaponModData.PolarityId ~= 0 then
        self.ui.mImg_PolarityIcon.sprite = IconUtils.GetElementIcon(TableData.listPolarityTagDatas:GetDataById(data.gunWeaponModData.PolarityId).Icon .. "_S")
      end
      if data.gunWeaponModData.ModEffectTypeData then
        self.ui.mImg_PartsEffectType.sprite = IconUtils.GetWeaponPartIconSprite(data.gunWeaponModData.ModEffectTypeData.Icon, false)
        setactive(self.ui.mTrans_PartsEffectType, true)
        if data.gunWeaponModData.ModEffectTypeData.EffectId == UIWeaponGlobal.ModEffectType.Cover then
          setactive(self.ui.mTrans_SuitRoot, true)
          local dataSuit
          if data.gunWeaponModData.suitId ~= 0 then
            dataSuit = TableData.listModPowerEffectDatas:GetDataById(data.gunWeaponModData.suitId)
          end
          if dataSuit ~= nil then
            self.ui.mImage_SuitIcon.sprite = IconUtils.GetWeaponPartIconSprite(dataSuit.image, false)
          end
        else
          setactive(self.ui.mTrans_SuitRoot, false)
        end
      else
        setactive(self.ui.mTrans_PartsEffectType, false)
      end
      self.longPress.enabled = false
      setactive(self.ui.mTrans_Reduce, false)
      setactive(self.ui.mTrans_Choose, data.selectCount > 0)
      setactive(self.ui.mTrans_Lock, data.gunWeaponModData.IsLocked)
      self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(data.gunWeaponModData.rank, self.ui.mImage_Rank.color.a)
      self.ui.mImage_Rank2.color = TableData.GetGlobalGun_Quality_Color2(data.gunWeaponModData.rank, self.ui.mImage_Rank2.color.a)
    end
    self.ui.mText_SelectCount.text = data.selectCount
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UICommonItem:SetMaterialSelect(isSelect, enableReduce)
  if isSelect == nil then
    isSelect = false
  end
  if enableReduce == nil then
    enableReduce = false
  end
  setactive(self.ui.mTrans_Reduce, isSelect and enableReduce)
  self:SetSelect(isSelect)
end
function UICommonItem:OnReduce()
  if self.mData.type == UIWeaponGlobal.MaterialType.Item then
    if self.mData.selectCount > 0 then
      self.mData.selectCount = self.mData.selectCount - 1
    end
    self.mText_SelectCount.text = self.mData.selectCount
    setactive(self.mTrans_Reduce, self.mData.selectCount > 0)
  end
end
function UICommonItem:SetLongPressEvent(beginCb, endCb)
  if self.longPress then
    self.longPress.longPressStart = beginCb
    self.longPress.longPressEnd = endCb
  end
end
function UICommonItem:SetMinusLongPressEvent(beginCb, endCb)
  if self.minusLongPress then
    self.minusLongPress.longPressStart = beginCb
    self.minusLongPress.longPressEnd = endCb
  end
end
function UICommonItem:SetLongPressIntervalEvent(beginCb)
  if self.longPress then
    self.longPress.LongPressIntervalEvent = beginCb
  end
end
function UICommonItem:SetIntervalCount(num)
  if self.longPress then
    self.longPress:SetIntervalCount(num)
  end
end
function UICommonItem:SetAcceleration(num)
  if self.longPress then
    self.longPress:SetAcceleration(num)
  end
end
function UICommonItem:SetAccelerationCallback(func)
  if self.longPress then
    self.longPress:SetAccelerationCallback(func)
  end
end
function UICommonItem:SetLongPressValue(num)
  if self.longPress then
    self.longPress:SetLongPressValue(num)
  end
end
function UICommonItem:SetMinusLongPressIntervalEvent(beginCb)
  if self.minusLongPress then
    self.minusLongPress:SetLongPressIntervalEvent(beginCb)
  end
end
function UICommonItem:SetMinusIntervalCount(num)
  if self.minusLongPress then
    self.minusLongPress:SetIntervalCount(num)
  end
end
function UICommonItem:SetMinusAcceleration(num)
  if self.minusLongPress then
    self.minusLongPress:SetAcceleration(num)
  end
end
function UICommonItem:SetMinusAccelerationCallback(func)
  if self.minusLongPress then
    self.minusLongPress:SetAccelerationCallback(func)
  end
end
function UICommonItem:SetMinusLongPressValue(num)
  if self.minusLongPress then
    self.minusLongPress:SetLongPressValue(num)
  end
end
function UICommonItem:IsRemoveWeapon()
  return self.mData.type == UIWeaponGlobal.MaterialType.Weapon and self.mData.selectCount > 0
end
function UICommonItem:IsBreakItem(id)
  if self.mData.type == UIWeaponGlobal.MaterialType.Weapon then
    return self.mData.stcId == id
  elseif self.mData.type == UIWeaponGlobal.MaterialType.Item then
    return self.mData.isBreakItem
  end
end
function UICommonItem:IsLocked()
  return self.mData.isLock
end
function UICommonItem:EnableSelectFrame(enable)
  setactive(self.ui.mImg_Sel, enable)
end
function UICommonItem:SetSelectNum(num)
  setactive(self.ui.mTrans_ChooseNum, num ~= 0)
  self.ui.mTxt_ChooseNum.text = FormatNum(num)
end
function UICommonItem:SetItemOverflowDisplay(itemId, num)
  local data = TableData.GetItemData(itemId)
  setactive(self.ui.mTrans_CardDisplay, true)
  self:DelayCall(0.7, function()
    self:PlayItemOverflowDisplay(data, num)
  end)
end
function UICommonItem:PlayItemOverflowDisplay(data, num)
  if self.frameDelayTimer then
    self.frameDelayTimer:Stop()
    self.frameDelayTimer = nil
  end
  self.frameDelayTimer = TimerSys:DelayCall(0.3, function()
    self:SetItemByStcData(data, num)
  end)
end
function UICommonItem:SetItemByStcData(data, num)
  self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(data.rank)
  self.ui.mImage_Rank2.color = TableData.GetGlobalGun_Quality_Color2(data.rank, self.ui.mImage_Rank2.color.a)
  if 1 < num then
    self.ui.mText_Num.text = num
  else
    setactive(self.ui.mTrans_Num, false)
  end
  self.ui.mImage_Icon.sprite = IconUtils.GetItemIconSprite(data.id)
  self.ui.mBtn_Select.interactable = true
  TipsManager.Add(self.ui.mBtn_Select.gameObject, data)
end
function UICommonItem:SetComposeData(data, needCount)
  self:Reset()
  self.data = data
  self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(data.rank)
  self.ui.mImage_Rank2.color = TableData.GetGlobalGun_Quality_Color2(data.rank, self.ui.mImage_Rank2.color.a)
  self.ui.mImage_Icon.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. data.icon)
  local itemNum = NetCmdItemData:GetItemCount(data.id)
  self.ui.mText_Num.text = itemNum
  if needCount <= itemNum then
    self.ui.mText_Num.color = CS.GF2.UI.UITool.StringToColor("EFEFEF")
  else
    self.ui.mText_Num.color = CS.GF2.UI.UITool.StringToColor("FF5E41")
  end
  TipsManager.Add(self.ui.mBtn_Select.gameObject, data, nil, true, false, nil, nil, nil, nil, nil, true)
end
function UICommonItem:SetWeaponPieceData(data, itemNum, needCount, customOnClick)
  self:Reset()
  self.data = data
  self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(data.rank)
  self.ui.mImage_Rank2.color = TableData.GetGlobalGun_Quality_Color2(data.rank, self.ui.mImage_Rank2.color.a)
  self.ui.mImage_Icon.sprite = ResSys:GetAtlasSprite("Icon/WeaponCore/" .. data.icon)
  self:SetRedPoint(needCount <= itemNum)
  if needCount <= itemNum then
    self.ui.mText_Num.text = itemNum .. "/" .. needCount
  else
    self.ui.mText_Num.text = "<color=#FF5E41>" .. itemNum .. "/</color>" .. needCount
  end
  if customOnClick ~= nil then
    UIUtils.GetButtonListener(self.ui.mBtn_Select.gameObject).onClick = function()
      customOnClick(self)
    end
  end
end
function UICommonItem:SetBagIndex(index)
  self.bagIndex = index
end
