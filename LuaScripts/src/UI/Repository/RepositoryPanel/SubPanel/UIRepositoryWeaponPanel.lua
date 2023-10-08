require("UI.Repository.RepositoryPanel.SubPanel.UIRepositoryBasePanel")
require("UI.WeaponPanel.UIWeaponGlobal")
require("UI.WeaponPanel.UIWeaponPanel")
UIRepositoryWeaponPanel = class("UIRepositoryWeaponPanel", UIRepositoryBasePanel)
function UIRepositoryWeaponPanel:ctor(parent, panelId, subPanelRoot)
  self.super.ctor(self, parent, panelId, subPanelRoot)
  self.parent = parent
  self.panelId = panelId
  self.itemList = {}
  self.isSub = false
  self.sortFunc = nil
  self.param = nil
  self.weaponTypeId = 0
  self.DropdownItemTable = {}
  self.TopTabTable = {}
  self.weaponItemViewList = {}
  self.transRoot = subPanelRoot
  self.selectedItemData = nil
  self.comScreenItemV2 = nil
end
function UIRepositoryWeaponPanel:Show()
  self.super.Show(self)
  function self.virtualList.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  local weaponList = NetCmdWeaponData:GetWeaponListByType()
  self.comScreenItemV2 = ComScreenItemHelper:InitWeapon(self.parent.ui.mTrans_BtnScreen.gameObject, weaponList, function()
    self:RefreshItemList()
  end, nil)
  self:OnClickTypeDropdownItem(1)
  self.parent:SetOwnAndLimitNumVisible(true)
  setactive(self.parent.ui.mTrans_Bottom, true)
  self.parent.ui.mTrans_Other.localPosition = vectorzero
  setactive(self.parent.ui.mTrans_Empty, false)
end
function UIRepositoryWeaponPanel:OnPanelBack()
  self.comScreenItemV2:ShowFilterTrans(false)
  local allWeaponList = NetCmdWeaponData:GetWeaponListByType()
  self.comScreenItemV2:SetList(allWeaponList)
  self:Refresh()
  if not self.selectedItemData then
    return
  end
  local weaponLvUp = self.selectedItemData.Level - self.selectedItemOldLv > 0
  if weaponLvUp then
    self:FocusItem(self.selectedItemData.id)
  end
end
function UIRepositoryWeaponPanel:Close()
  self.comScreenItemV2:OnCloseFilterBtnClick()
  self.super.Close(self)
  self.parent:SetOwnAndLimitNumVisible(false)
  setactive(self.parent.ui.mTrans_Bottom, false)
  self.parent.ui.mTrans_Other.localPosition = Vector3(0, 3000, 0)
  setactive(self.parent.ui.mTrans_TalentImgLine, false)
  if self.comScreenItemV2 then
    self.comScreenItemV2:OnRelease()
  end
  self.comScreenItemV2 = nil
end
function UIRepositoryWeaponPanel:OnRelease()
  self.itemList = nil
  self.parent = nil
  self.panelId = 0
  self.sortFunc = nil
  self.param = nil
  self.DropdownItemTable = nil
  self.selectedItemData = nil
  self.selectedItemOldLv = nil
  for i = #self.weaponItemViewList, 1, -1 do
    self.weaponItemViewList[i]:OnRelease()
  end
  self.weaponItemViewList = nil
end
function UIRepositoryWeaponPanel:InitTypeDropItem()
  self.parent.uiComScreenItemV2:AddCancelScreenClickListener(function()
    self:OnClickTypeDropdownItem(1)
  end)
  local allDataList = TableData.listGunWeaponTypeDatas:GetList()
  local allDataTable = CSList2LuaTable(allDataList)
  table.sort(allDataTable, function(l, r)
    return l.type_id < r.type_id
  end)
end
function UIRepositoryWeaponPanel:RegTypeDropdownItem(suitName, spriteName, weaponTypeId, index)
  if self.parent.DropdownItemTable[index] == nil then
    local item1 = ChrEquipSuitDropdownItemV2.New()
    local dropdownItemObj = self.parent.ui.DropdownItemObj
    local dropdownItem = instantiate(dropdownItemObj, self.parent.uiComScreenItemV2.ui.mScrollListChild_ScreenList.transform)
    item1.view = dropdownItem
    item1:InitCtrl(dropdownItem.transform)
    self.parent.DropdownItemTable[index] = item1
  end
  local item = self.parent.DropdownItemTable[index]
  item.itemIndex = index
  item.weaponTypeId = weaponTypeId
  item.mText_SuitNum.text = ""
  item.mText_SuitName.text = suitName
  item:SetIconVisible(false)
  self.textcolor = item.view.transform:GetComponent(typeof(CS.TextImgColor))
  self.beforecolor = self.textcolor.BeforeSelected
  self.aftercolor = self.textcolor.AfterSelected
  UIUtils.GetButtonListener(item.mBtn_Select.gameObject).onClick = function()
    self:OnClickTypeDropdownItem(item.itemIndex)
  end
  setactive(item.view.transform, true)
end
function UIRepositoryWeaponPanel:OnClickTypeDropdownItem(itemIndex)
  self:RefreshItemList()
end
function UIRepositoryWeaponPanel:OnClickDropdown()
  setactive(self.parent.ui.mTrans_TypeScreen, not self.parent.ui.mTrans_TypeScreen.gameObject.activeSelf)
end
function UIRepositoryWeaponPanel:OnClickTypeBlock()
  self:OnClickDropdown()
end
function UIRepositoryWeaponPanel:ItemRenderer(index, renderData)
  local data = self.itemList[index + 1]
  local item = renderData.data
  item:SetWeaponData(data, function(tempItem)
    self:OnClickWeaponItem(tempItem)
  end, false, false)
end
function UIRepositoryWeaponPanel:FocusItem(cmdId)
  if not cmdId then
    return
  end
  local targetIndex = 0
  for i, weaponCmdData in ipairs(self.itemList) do
    if weaponCmdData.id == cmdId then
      targetIndex = i - 1
      break
    end
  end
  self:ScrollTo(targetIndex)
end
function UIRepositoryWeaponPanel:ScrollTo(itemIndex)
  local rowIndex = math.floor(itemIndex / 7)
  local virtualList = self.virtualList
  local elementHeight = virtualList.cellSize.y + virtualList.spacing.y
  local targetPosY = rowIndex * elementHeight
  self.parent.ui.mTrans_Content.anchoredPosition = Vector2(self.parent.ui.mTrans_Content.anchoredPosition.x, targetPosY)
end
function UIRepositoryWeaponPanel:ChangeSelectedTypeFlag(selectedItemIndex)
  for k, dropdownItem in pairs(self.parent.DropdownItemTable) do
    if dropdownItem.mUIRoot.gameObject.activeSelf == true then
      if dropdownItem.itemIndex == selectedItemIndex then
        dropdownItem.mText_SuitName.color = self.textcolor.AfterSelected
        setactive(dropdownItem.mTrans_GrpSet, true)
      else
        dropdownItem.mText_SuitName.color = self.textcolor.BeforeSelected
        setactive(dropdownItem.mTrans_GrpSet, false)
      end
    end
  end
end
function UIRepositoryWeaponPanel:Refresh()
  self:RefreshItemList()
end
function UIRepositoryWeaponPanel:RefreshItemList()
  self.itemList = self:GetWeaponList()
  self.parent:SetOwnAndLimitNum(#self.itemList, CS.GF2.Data.GlobalData.weapon_capacity)
  self.super.RefreshItemList(self)
end
function UIRepositoryWeaponPanel:InitFiltrateItemList()
  local tempList = {}
  for _, item in ipairs(self.itemList) do
    if not item.isEquip and not item.isLock then
      table.insert(tempList, item)
    end
  end
  self.itemList = tempList
  self.super.UpdateItemList(self)
end
function UIRepositoryWeaponPanel:OnClickWeaponItem(item)
  self.selectedItemData = item.mWeaponData
  self.selectedItemOldLv = item.mWeaponData.Level
  local param = {
    item:GetWeaponItemId(),
    UIWeaponGlobal.WeaponPanelTab.Info,
    true,
    UIWeaponPanel.OpenFromType.Repository,
    needReplaceBtn = false
  }
  UIManager.OpenUIByParam(UIDef.UIWeaponPanel, param)
end
function UIRepositoryWeaponPanel:GetWeaponList()
  local list = {}
  local weaponList = self.comScreenItemV2:GetResultList()
  for i = 0, weaponList.Count - 1 do
    table.insert(list, weaponList[i])
  end
  return list
end
