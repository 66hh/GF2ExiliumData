require("UI.Repository.Item.UIRepositoryListItemV2")
require("UI.Repository.UIRepositoryGlobal")
require("UI.DarkZonePanel.UIDarkZoneRepositoryPanel.UIDarkZoneRepositoryGlobal")
UIDarkBagPanelV2 = class("UIDarkBagPanelV2", UIBasePanel)
UIDarkBagPanelV2.__index = UIDarkBagPanelV2
function UIDarkBagPanelV2:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function UIDarkBagPanelV2:OnAwake(root, data)
end
function UIDarkBagPanelV2:OnInit(root, data)
  self:SetRoot(root)
  self.ui = {}
  self.itemList = {}
  self.tagList = {}
  self.detailUI = {}
  self:LuaUIBindTable(root, self.ui)
  if self.detailInfo == nil then
    self.detailInfo = instantiate(self.ui.mScrollChild_Right.childItem, self.ui.mScrollChild_Right.transform)
  end
  self:LuaUIBindTable(self.detailInfo, self.detailUI)
  self:AddBtnListener()
end
function UIDarkBagPanelV2:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIDarkBagPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Discard.gameObject).onClick = function()
    self:OnDiscardClick()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    self:OnCancelClick()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_DiscardConfirm.gameObject).onClick = function()
    self:OnDiscardConfirmClick()
  end
end
function UIDarkBagPanelV2:OnDiscardClick()
  self.isDiscardMode = true
  setactive(self.ui.mTrans_Discard, true)
  for k, v in pairs(self.contentItem) do
    self.contentItem[k]:SetSelectShow(false)
  end
  self.curClickTabId = -1
  self:SetDetailShow()
  setactive(self.detailUI.mTrans_TexpEmpty, not self.isEmpty)
  setactive(self.detailUI.mTrans_TopInfo, false)
  setactive(self.ui.mBtn_Discard.transform.parent, false)
end
function UIDarkBagPanelV2:OnDiscardConfirmClick()
  for i = 1, #self.selectIndexTable do
    self.BagMgr:PickDown(self.bagDataList[self.selectIndexTable[i].Index])
  end
  self.BagMgr:SendPickDown(function()
    self:ResetInit()
  end)
end
function UIDarkBagPanelV2:OnCancelClick()
  self.isDiscardMode = false
  setactive(self.ui.mTrans_Discard, false)
  self:ResetInit()
end
function UIDarkBagPanelV2:InitData()
  self.selectIndexTable = {}
  self.contentItem = {}
  self.bagDataList = {}
  self.sliderMaxNum = 0
  self.selectFrameIndex = -1
  self.index = 0
  self.BagMgr = CS.SysMgr.dzPlayerMgr.MainPlayer.DarkPlayerBag
  self.maxNum = CS.SysMgr.dzPlayerMgr.MainPlayer.Chequer:ToString()
  self.curClickTabId = -1
  self.isEmpty = true
  self.isDiscardMode = false
  self:SetDetailShow()
end
function UIDarkBagPanelV2:Show()
  self.ui.mText_Num.text = self.BagMgr:ItemNumInBag() .. "/" .. self.maxNum
  setactive(self.ui.mTrans_Discard, false)
  self:UpdateItemList()
end
function UIDarkBagPanelV2:UpdateItemList()
  self:InitItemTypeList()
  for index, tag in ipairs(self.tagList) do
    self:UpdateDarkZoneItemList(index, tag)
  end
end
function UIDarkBagPanelV2:ResetInit()
  self:InitData()
  self:Show()
  setactive(self.ui.mTrans_Empty.gameObject, self.isEmpty)
  setactive(self.ui.mBtn_Discard.transform.parent, not self.isEmpty)
  setactive(self.detailUI.mTrans_TexpEmpty, not self.isEmpty)
  setactive(self.detailUI.mTrans_TopInfo, false)
  self.ui.mBtn_DiscardConfirm.interactable = #self.selectIndexTable > 0
  if self.isEmpty then
    for i = 1, #self.tagList do
      setactive(self.tagList[i]:GetRoot(), false)
    end
  end
end
function UIDarkBagPanelV2:InitItemTypeList()
  local parentRoot = self.ui.mContent_Item.transform
  local typeList = TableData.listDarkzoneRepositoryCategoryDatas
  for i = 0, typeList.Count - 1 do
    local item = self.tagList[i + 1]
    if item == nil then
      item = UIRepositoryListItemV2.New()
      table.insert(self.tagList, item)
      item:InitCtrl(parentRoot)
    end
    local isDzWeaponPart = typeList[i].ItemType.Count
    setactive(item:GetRoot(), true)
    item:SetData(typeList[i])
  end
end
function UIDarkBagPanelV2:UpdateDarkZoneItemList(index, tag)
  local index = self.index
  local tagEmpty = true
  if tag.mData then
    for i = 1, #tag.itemList do
      setactive(tag.itemList[i]:GetRoot(), false)
    end
    local ItemType = tag.mData.item_type
    local itemDataList = self.BagMgr:GetBagByType(index, ItemType)
    for i = 0, itemDataList.Count - 1 do
      self.isEmpty = false
      tagEmpty = false
      local itemData = itemDataList[i]
      if 0 < itemData.num then
        local itemTableData = TableData.listItemDatas:GetDataById(itemData.itemID)
        local timeLimit = itemTableData.time_limit
        if timeLimit == 0 or timeLimit ~= 0 and timeLimit > CGameTime:GetTimestamp() then
          local item
          if i + 1 > #self.itemList then
            item = UICommonItem.New()
            item:InitCtrl(tag.mTrans_ItemList)
            table.insert(tag.itemList, item)
          else
            item = tag.itemList[i + 1]
          end
          index = self.index
          self.contentItem[index] = item
          self.bagDataList[index] = itemData
          if itemData.itemdata.Type == 21 then
            item:SetWeaponPartsData(itemData.gunweaponModData, function(tempItem)
              self:OnClickWeaponPartItem(tempItem)
            end)
          else
            item:SetItemData(itemData.itemID, itemData.num, false, false, itemData.num, nil, nil, function(tempItem)
              self:ShowCommonItem(tempItem)
            end, nil, true)
          end
          item:SetBagIndex(index)
          self.index = self.index + 1
        end
      end
    end
  end
  if tagEmpty then
    setactive(tag:GetRoot(), false)
  end
end
function UIDarkBagPanelV2:ShowCommonItem(item)
  if self.selectFrameIndex >= 0 then
    self.contentItem[self.selectFrameIndex]:SetSelectShow(false)
  end
  local index = item.bagIndex
  self.selectFrameIndex = index
  self:InitSlider(item.itemNum)
  self:OnClickStackItem(index, item)
  local itemTabData = TableData.GetItemData(item.itemId)
  if itemTabData ~= nil then
    self.curDecomposeId = item.itemId
    self.detailUI.mText_Title.text = itemTabData.name.str
    self.detailUI.mImg_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(itemTabData.rank)
    self.detailUI.mTxt_DetailInfo.text = itemTabData.introduction.str
    self.detailUI.mTxt_ItemName.text = TableData.listItemTypeDescDatas:GetDataById(itemTabData.type).name.str
  end
  setactive(self.detailUI.mTrans_TopInfo, itemTabData ~= nil)
  self.curClickTabId = UIRepositoryGlobal.PanelType.ItemPanel
  UIDarkBagPanelV2:SetDetailShow()
end
function UIDarkBagPanelV2:OnClickWeaponPartItem(item)
  if self.selectFrameIndex >= 0 then
    self.contentItem[self.selectFrameIndex]:SetSelectShow(false)
  end
  local index = item.bagIndex
  local weaponPartsData = item.mWeaponPartsData
  self:OnClickUnstackItem(index, item, weaponPartsData.IsLocked)
  self.selectFrameIndex = index
  self.detailUI.mText_Title.text = weaponPartsData.name
  self.detailUI.mTxt_DetailInfo.text = ""
  self.detailUI.mImg_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(weaponPartsData.rank)
  self.curDecomposeId = weaponPartsData.stcId
  self.curWeaponPartDecomposeId = weaponPartsData.id
  setactive(self.detailUI.mTrans_Capacity, false)
  self.detailUI.mText_Capacity.text = tostring(weaponPartsData.Capacity)
  setactive(self.detailUI.mImg_PartType, true)
  self.detailUI.mImg_PartType.sprite = IconUtils.GetWeaponPartIconSprite(weaponPartsData.ModEffectTypeData.Icon, false)
  setactive(self.detailUI.mText_Flaw, true)
  self.detailUI.mText_Flaw.text = ""
  setactive(self.detailUI.mScrollListChild_BtnLock, true)
  local color = ColorUtils.OrangeColor
  local atrributeListColor
  setactive(self.detailUI.mScrollChild_Attribute, true)
  atrributeListColor = CS.GunWeaponModData.SetWeaponPartAttr(weaponPartsData, self.detailUI.mScrollChild_Attribute.transform, self.detailUI.mTrans_MainAttribute.transform, 0)
  local flag = false
  if weaponPartsData.ModEffectTypeData.EffectId == UIWeaponGlobal.ModEffectType.Cover then
    CS.GunWeaponModData.SetModPowerDataNameWithLevel(self.detailUI.mText_MakeUpName, weaponPartsData.ModPowerData, weaponPartsData)
    self.detailUI.mImg_MakeUp.sprite = IconUtils.GetWeaponPartIconSprite(weaponPartsData.ModPowerData.image, false)
    if 0 < weaponPartsData.BasicValue.Length + weaponPartsData.GunWeaponModPropertyListWithAddValue.Count or weaponPartsData.GroupSkillData ~= nil then
      setactive(self.detailUI.mTrans_MakeUp, true)
      setactive(self.detailUI.mTrans_Special, true)
      flag = true
    else
      setactive(self.detailUI.mTrans_MakeUp, false)
    end
    self.detailUI.mText_MakeUpLv.text = string_format("1/{0}", weaponPartsData.ModPowerList[1].Key)
    local tmp = self.detailUI.mTrans_MakeUpItem
    if self.detailUI.mTrans_MakeUpItem == nil then
      gfdebug("背包mTrans_MakeUpItem报空")
    end
    if self.detailUI.mTrans_MakeUpItem:GetComponent(typeof(CS.TextFit)) == nil then
      gfdebug("self.detailUI.mTrans_MakeUpItem:GetComponent(typeof(CS.TextFit)).text 报空")
    end
    if weaponPartsData and self.detailUI.mTrans_MakeUpItem then
      self.detailUI.mTrans_MakeUpItem:GetComponent(typeof(CS.TextFit)).text = weaponPartsData:GetModGroupSkillShowText()
    else
      gfdebug("weaponPartsData 为空")
    end
    gfdebug("weaponPartsData" .. tostring(weaponPartsData.ItemData.Id))
  end
  local preficAttList = CS.GunWeaponModData.SetWeaponPartProficiencySkill(weaponPartsData, self.detailUI.mTrans_GrpPolarity.transform)
  self:SetModLevel(weaponPartsData)
  if weaponPartsData.ModEffectTypeData.EffectId == UIWeaponGlobal.ModEffectType.Ambush or weaponPartsData.ModEffectTypeData.EffectId == UIWeaponGlobal.ModEffectType.Armor then
    if weaponPartsData.ExtraCapacity ~= 0 or 0 < weaponPartsData.GunWeaponModPropertyListWithAddValue.Count then
      setactive(self.detailUI.mTrans_GrpPolarity, true)
      flag = true
    else
      setactive(self.detailUI.mTrans_GrpPolarity, false)
    end
  end
  setactive(self.detailUI.mTrans_Special, flag)
  setactive(self.detailUI.mTrans_MakeUp, weaponPartsData.GroupSkillData ~= nil)
  local slotData = TableData.listWeaponModTypeDatas:GetDataById(weaponPartsData.fatherType)
  if slotData ~= nil then
    self.detailUI.mTxt_ItemName.text = slotData.name.str
  end
  setactive(self.detailUI.mTrans_TopInfo, slotData ~= nil)
  self.curClickTabId = UIRepositoryGlobal.PanelType.WeaponParts
  UIDarkBagPanelV2:SetDetailShow()
end
function UIDarkBagPanelV2:SetModLevel(tmpGunWeaponModData)
  setactive(self.detailUI.mTrans_PolarityIcon, tmpGunWeaponModData.stcDataCanPolarity)
  CS.GunWeaponModData.SetModLevelText(self.detailUI.mText_Lv, tmpGunWeaponModData, self.detailUI.mText_LvMax)
  CS.GunWeaponModData.SetModPolarityText(self.detailUI.mText_State, self.detailUI.mImg_Polarity, tmpGunWeaponModData, self.detailUI.mCanvasGroup_Lv)
end
function UIDarkBagPanelV2:InitSlider(max)
  max = math.min(max, 999)
  self.sliderMaxNum = max
end
function UIDarkBagPanelV2:OnClickStackItem(index, item)
  local isSelected = true
  if self.isDiscardMode then
    for i = 1, #self.selectIndexTable do
      if self.selectIndexTable[i].Index == index then
        isSelected = false
        self:OnSliderChange(0)
        item:SetSelect(false)
        break
      end
    end
    if isSelected then
      self:OnSliderChange(self.sliderMaxNum)
      item:SetSelect(true)
    end
  end
  item:SetSelectShow(true)
end
function UIDarkBagPanelV2:OnClickUnstackItem(index, item, isLocked)
  local isSelected = true
  if self.isDiscardMode then
    for i = 1, #self.selectIndexTable do
      if self.selectIndexTable[i].Index == index then
        table.remove(self.selectIndexTable, i)
        isSelected = false
        item:SetSelect(false)
        break
      end
    end
    if isSelected and not isLocked then
      if #self.selectIndexTable > CS.SysMgr.dzPlayerMgr.MainPlayer.Chequer then
        UIUtils.PopupHintMessage(1106)
        isSelected = false
        item:SetSelect(false)
      else
        table.insert(self.selectIndexTable, {Index = index, Count = 1})
        item:SetSelect(true)
      end
    end
  end
  item:SetSelectShow(true)
end
function UIDarkBagPanelV2:OnSliderChange(value)
  self.curDecomposeNum = value
  if value == 0 then
    for i = 1, #self.selectIndexTable do
      if self.selectIndexTable[i].Index == self.selectFrameIndex then
        table.remove(self.selectIndexTable, i)
        break
      end
    end
  else
    local isSelected = false
    for i = 1, #self.selectIndexTable do
      if self.selectIndexTable[i].Index == self.selectFrameIndex then
        self.selectIndexTable[i].Count = value
        isSelected = true
        break
      end
    end
    if not isSelected then
      table.insert(self.selectIndexTable, {
        Index = self.selectFrameIndex,
        Count = value
      })
    end
  end
end
function UIDarkBagPanelV2:OnShowStart()
end
function UIDarkBagPanelV2:OnShowFinish()
  TimerSys:DelayCall(0.02, function()
    self:ResetInit()
  end)
end
function UIDarkBagPanelV2:SetDetailShow()
  setactive(self.detailUI.mTrans_GrpWeaponPart, self.curClickTabId == UIRepositoryGlobal.PanelType.WeaponParts)
  setactive(self.detailUI.mTrans_GrpInfo, self.curClickTabId == UIRepositoryGlobal.PanelType.ItemPanel)
  setactive(self.detailUI.mTrans_TexpEmpty, self.curClickTabId == -1)
  setactive(self.detailUI.mTrans_TopInfo, true)
  setactive(self.detailUI.mText_Flaw, self.curClickTabId == UIRepositoryGlobal.PanelType.WeaponParts)
  setactive(self.detailUI.mTrans_Capacity, false)
  setactive(self.ui.mTrans_Empty.gameObject, self.isEmpty)
  setactive(self.ui.mBtn_Discard.transform.parent, not self.isEmpty)
  self.ui.mBtn_DiscardConfirm.interactable = #self.selectIndexTable > 0
end
function UIDarkBagPanelV2:OnClose()
  self.selectIndex = -1
  self.selectIndexTable = {}
  self.selectFrameIndex = -1
  self.contentItem = {}
  setactive(self.detailUI.mTrans_Capacity, false)
  setactive(self.detailUI.mImg_PartType, false)
  setactive(self.detailUI.mText_Flaw, false)
  setactive(self.detailUI.mScrollChild_Attribute, false)
  setactive(self.detailUI.mTrans_Special, false)
  setactive(self.detailUI.mTrans_MakeUp, false)
  setactive(self.detailUI.mTrans_GrpPolarity, false)
  setactive(self.detailUI.mTrans_TopInfo, false)
  gfdestroy(self.detailInfo.gameObject)
  self.detailInfo = nil
  if self.tagList then
    for i = 1, #self.tagList do
      gfdestroy(self.tagList[i]:GetRoot())
    end
  end
end
function UIDarkBagPanelV2:OnRelease()
end
