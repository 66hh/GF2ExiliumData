require("UI.Repository.Item.UIRepositoryWeaponPartTypeItem")
require("UI.Repository.Item.UIRepositoryWeaponPartSuitItem")
require("UI.WeaponPanel.UIWeaponGlobal")
UIRepositoryWeaponPartsPanel = class("UIRepositoryWeaponPartsPanel", UIRepositoryBasePanel)
function UIRepositoryWeaponPartsPanel:ctor(parent, panelId, root)
  self.parent = parent
  self.super.ctor(self, parent, panelId, root)
  self.curPartPosTabIndex = -1
  self.partsPosTabTable = {}
  self.curSuitTabIndex = -1
  self:createAllPartsPosTab()
  self.suitTabTable = {}
  self.curSubPartsPosTabIndex = -1
  self.subPartsPosTabTable = {}
  self.slotTable = {}
  self.comScreenItemV2 = nil
end
function UIRepositoryWeaponPartsPanel:Show()
  self.super.Show(self)
  function self.virtualList.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  setactive(self.parent.ui.mTrans_GrpPartsType, false)
  setactive(self.parent.ui.mTrans_TalentImgLine, false)
  local weaponPartsList = NetCmdWeaponPartsData:GetWeaponPartsList()
  if self.comScreenItemV2 == nil then
    self.comScreenItemV2 = ComScreenItemHelper:InitWeaponPart(self.parent.ui.mTrans_BtnScreen.gameObject, weaponPartsList, function()
      self:RefreshItemList()
    end, nil, 0, true, true)
    self.comScreenItemV2:SetOnShowMultiListFilterCallback(function()
      self.parent:ResetEscapeBtn(true, function()
        self.comScreenItemV2:OnCloseMultiListFilter()
      end)
    end)
    self.comScreenItemV2:SetOnCloseMultiListFilterCallback(function()
      self.parent:ResetEscapeBtn(false)
    end)
  end
  setactive(self.parent.ui.mTrans_Bottom, true)
  self.parent.ui.mTrans_Empty.text = TableData.GetHintById(1060)
  self.parent:SetOwnAndLimitNumVisible(true)
  self:onClickSuitTab(1)
  self:onClickPartsPosTab(1)
  self.parent.ui.mTrans_Other.localPosition = vectorzero
  self.comScreenItemV2:DoFilter()
end
function UIRepositoryWeaponPartsPanel:OnPanelBack()
  self:Refresh()
end
function UIRepositoryWeaponPartsPanel:Close()
  if self.curPartPosTabIndex > 0 then
    self.partsPosTabTable[self.curPartPosTabIndex]:SetSelectState(false)
  end
  if 0 < self.curSubPartsPosTabIndex then
    self.subPartsPosTabTable[self.curSubPartsPosTabIndex]:SetSelectState(false)
  end
  self.curSubPartsPosTabIndex = -1
  self.curSuitTabIndex = -1
  self.curPartPosTabIndex = -1
  self.parent:SetOwnAndLimitNumVisible(false)
  self.parent.ui.mTrans_Other.localPosition = Vector3(0, 3000, 0)
  setactive(self.parent.ui.mTrans_Bottom, false)
  setactive(self.parent.ui.mTrans_Empty, false)
  setactive(self.parent.ui.mTrans_WeaponPartsType, false)
  setactive(self.parent.ui.mTrans_GrpPartsType, false)
  setactive(self.parent.ui.mTrans_WeaponPartsSuit, false)
  setactive(self.parent.ui.mTrans_PartsTypeRoot, false)
  setactive(self.parent.ui.mTrans_TalentImgLine, false)
  self.super.Close(self)
  self.parent.ui.mCanvasGroup_List.alpha = 1
  if self.comScreenItemV2 then
    self.comScreenItemV2:OnRelease()
  end
  self.comScreenItemV2 = nil
end
function UIRepositoryWeaponPartsPanel:OnRelease()
  self.root = nil
  self.virtualList = nil
  self.curSubPartsPosTabIndex = nil
  self.curSuitTabIndex = nil
  for k, tab in pairs(self.partsPosTabTable) do
    tab:OnRelease()
  end
  self.partsPosTabTable = nil
  for k, tab in pairs(self.suitTabTable) do
    tab:OnRelease()
  end
  self.suitTabTable = nil
  for i, subPartsPosTab in ipairs(self.subPartsPosTabTable) do
    subPartsPosTab:OnRelease()
  end
  self.subPartsPosTabTable = nil
  for i, v in ipairs(self.slotTable) do
    v:OnRelease()
  end
  self.slotTable = nil
  self.super.OnRelease(self)
end
function UIRepositoryWeaponPartsPanel:Refresh()
  local weaponModId = self.partsPosTabTable[self.curPartPosTabIndex].weaponModId
  if weaponModId then
    self.comScreenItemV2:SetList(NetCmdWeaponPartsData:GetWeaponPartsList(weaponModId, 0))
    self.comScreenItemV2:DoFilter()
    self:RefreshItemList()
  else
    self.comScreenItemV2:SetList(NetCmdWeaponPartsData:GetWeaponPartsList(0, 0))
    self.comScreenItemV2:DoFilter()
    self:RefreshItemList()
  end
end
function UIRepositoryWeaponPartsPanel:SelectAllType()
  self:onClickSuitTab(1)
end
function UIRepositoryWeaponPartsPanel:RefreshItemList()
  self.itemList = self:getWeaponModTable()
  self.super.RefreshItemList(self)
  self.parent:SetOwnAndLimitNum(#self.itemList, CS.GF2.Data.GlobalData.weaponPart_capacity)
  local isEmpty = #self.itemList == 0
  setactive(self.parent.ui.mTrans_Empty, isEmpty)
  self.parent.ui.mFade_ItemContent:InitFade()
end
function UIRepositoryWeaponPartsPanel:ItemRenderer(index, renderData)
  local item = renderData.data
  local data = self.itemList[index + 1]
  item:SetWeaponPartsData(data, UIRepositoryWeaponPartsPanel.OnClickWeaponPartsItem)
end
function UIRepositoryWeaponPartsPanel.OnClickWeaponPartsItem(item)
  local gunWeaponModData = NetCmdWeaponPartsData:GetWeaponModById(item:GetWeaponPartsItemId())
  local param = {
    [1] = gunWeaponModData,
    [2] = UIWeaponGlobal.WeaponPartPanelTab.Info
  }
  UIManager.OpenUIByParam(UIDef.UIChrWeaponPartsPowerUpPanelV4, param)
end
function UIRepositoryWeaponPartsPanel:onClickPartsPosDropdown()
  setactive(self.parent.ui.mTrans_TypeScreen, not self.parent.ui.mTrans_TypeScreen.gameObject.activeSelf)
end
function UIRepositoryWeaponPartsPanel:onClickSuitDropdown()
  setactive(self.parent.ui.mTrans_TypeScreen2, not self.parent.ui.mTrans_TypeScreen2.gameObject.activeSelf)
end
function UIRepositoryWeaponPartsPanel:onClickPartsPosBlock()
  self:onClickPartsPosDropdown()
end
function UIRepositoryWeaponPartsPanel:onClickSuitBlock()
  self:onClickSuitDropdown()
end
function UIRepositoryWeaponPartsPanel:createAllSubPartsPosTab(weaponModId)
  local allDataList = TableData.listWeaponModTypeDatas:GetList()
  local index = 1
  for i = 0, allDataList.Count - 1 do
    local itemData = allDataList[i]
    if itemData and itemData.father_type == weaponModId then
      self:createSubPartsPos(itemData.name.str, itemData.id, index)
      index = index + 1
    end
  end
end
function UIRepositoryWeaponPartsPanel:destroyAllSubTab()
  for k, topTab in pairs(self.subPartsPosTabTable) do
    gfdestroy(topTab.Item)
  end
  self.subPartsPosTabTable = {}
end
function UIRepositoryWeaponPartsPanel:createSubPartsPos(name, weaponModTypeId, index)
  if self.subPartsPosTabTable[index] == nil then
    local item = UIRepositoryWeaponPartTypeItem.New()
    item:InitCtrl(self.parent.ui.mTrans_WeaponPartsSuit)
    self.subPartsPosTabTable[index] = item
  end
  local topTab = self.subPartsPosTabTable[index]
  topTab:SetActive(true)
  topTab.ItemIndex = index
  topTab.WeaponModTypeId = weaponModTypeId
  topTab:SetData(name)
  topTab:SetClickFunction(function()
    self:onClickSubPartsPosTab(topTab.ItemIndex)
  end)
end
function UIRepositoryWeaponPartsPanel:getWeaponModTable()
  local weaponPartsList = self.comScreenItemV2:GetResultList()
  local itemTable = {}
  for i = 0, weaponPartsList.Count - 1 do
    local data = weaponPartsList[i]
    table.insert(itemTable, data)
  end
  return itemTable
end
function UIRepositoryWeaponPartsPanel:createAllPartsPosTab()
  local partsPosTabTable = {}
  local firstTab = self:createPartsPosTab(TableData.GetHintById(1063), nil, nil, 1)
  table.insert(partsPosTabTable, firstTab)
  local allDataList = TableData.listRepositoryTagDatas:GetDataById(self.panelId).toptag
  local allDataTable = {}
  for i = 0, allDataList.Count - 1 do
    local tbArgs = TableData.listRepositoryToptagDatas:GetDataById(allDataList[i])
    for j = 0, tbArgs.args.Count - 1 do
      local tbData = TableData.listPolarityTagDatas:GetDataById(tbArgs.args[j])
      table.insert(allDataTable, tbData)
    end
  end
  table.sort(allDataTable, function(l, r)
    return l.PolarityId < r.PolarityId
  end)
  for i = 1, #allDataTable do
    local itemData = allDataTable[i]
    if itemData then
      local tab = self:createPartsPosTab(itemData.name.str, itemData.icon, itemData.PolarityId, i + 1)
      table.insert(partsPosTabTable, tab)
    end
  end
  return partsPosTabTable
end
function UIRepositoryWeaponPartsPanel:createAllSuitTab()
  local suitTabTable = {}
  self.parent.uiComScreenItemV2:AddCancelScreenClickListener(function()
    self:onClickSuitTab(1)
  end)
  local suitDataTable = UIWeaponGlobal:GetWeaponPartSuitList()
  table.sort(suitDataTable, function(a, b)
    return a.id < b.id
  end)
  for i = 1, #suitDataTable do
    local itemData = suitDataTable[i]
    local tab = self:createSuitTab(itemData.name.str, itemData.image, itemData.id, i)
    table.insert(suitTabTable, tab)
  end
  return suitTabTable
end
function UIRepositoryWeaponPartsPanel:createPartsPosTab(partsPosName, spriteName, weaponModId, index)
  if self.partsPosTabTable[index] == nil then
    local item1 = UIRepositoryWeaponPartSuitItem.New()
    item1:InitCtrl(self.parent.ui.mTrans_GrpPartsType)
    self.partsPosTabTable[index] = item1
  end
  local item = self.partsPosTabTable[index]
  item.itemIndex = index
  item.weaponModId = weaponModId
  item:SetClickFunction(function()
    self:onClickPartsPosTab(item.itemIndex)
  end)
  if partsPosName then
    item:SetData(partsPosName)
  end
  if weaponModId == nil then
    item:SetData(TableData.GetHintById(80044))
  end
  return item
end
function UIRepositoryWeaponPartsPanel:createSuitTab(tabName, spriteName, suitId, index)
  if self.parent.DropdownItemTable[index] == nil then
    local item1 = ChrEquipSuitDropdownItemV2.New()
    local dropdownItemObj = self.parent.ui.DropdownItemObj
    local dropdownItem = instantiate(dropdownItemObj, self.parent.uiComScreenItemV2.ui.mScrollListChild_ScreenList.transform)
    item1.view = dropdownItem
    item1:InitCtrl(dropdownItem.transform)
    self.parent.DropdownItemTable[index] = item1
  end
  local suitTab = self.parent.DropdownItemTable[index]
  suitTab.itemIndex = index
  suitTab.suitId = suitId
  suitTab.mText_SuitNum.text = ""
  self.textcolor = suitTab.view.transform:GetComponent(typeof(CS.TextImgColor))
  self.beforecolor = self.textcolor.BeforeSelected
  self.aftercolor = self.textcolor.AfterSelected
  UIUtils.GetButtonListener(suitTab.mBtn_Select.gameObject).onClick = function()
    self:onClickSuitTab(suitTab.itemIndex)
  end
  suitTab.mText_SuitName.text = tabName
  if spriteName then
    suitTab:SetIconSprite(IconUtils.GetWeaponPartIconSprite(spriteName, false))
  end
  suitTab:SetActive(true)
  return suitTab
end
function UIRepositoryWeaponPartsPanel:onClickSuitTab(suitTabIndex)
  if self.curSuitTabIndex == suitTabIndex then
    return
  end
  for k, suitTab in pairs(self.parent.DropdownItemTable) do
    if suitTab.mUIRoot.gameObject.activeSelf == true then
      if suitTab.itemIndex == suitTabIndex then
        suitTab.mText_SuitName.color = self.textcolor.AfterSelected
        setactive(suitTab.mTrans_GrpSet, true)
        self.parent.ui.mText_TypeName2.text = suitTab.mText_SuitName.text
      else
        suitTab.mText_SuitName.color = self.textcolor.BeforeSelected
        setactive(suitTab.mTrans_GrpSet, false)
      end
    end
  end
  self.curSuitTabIndex = suitTabIndex
  self:RefreshItemList()
end
function UIRepositoryWeaponPartsPanel:onClickPartsPosTab(partsPosTabIndex)
  local weaponModId = self.partsPosTabTable[partsPosTabIndex].weaponModId
  if self.curPartPosTabIndex > 0 then
    self.partsPosTabTable[self.curPartPosTabIndex]:SetSelectState(false)
  end
  self.curPartPosTabIndex = partsPosTabIndex
  self.partsPosTabTable[self.curPartPosTabIndex]:SetSelectState(true)
  for k, topTab in pairs(self.subPartsPosTabTable) do
    topTab:SetActive(false)
    topTab:SetSelectState(false)
  end
  self.curSubPartsPosTabIndex = -1
  if weaponModId then
    self.comScreenItemV2:SetList(NetCmdWeaponPartsData:GetWeaponPartsList(weaponModId, 0))
    self.comScreenItemV2:DoFilter()
    self:RefreshItemList()
  else
    self.comScreenItemV2:SetList(NetCmdWeaponPartsData:GetWeaponPartsList(0, 0))
    self.comScreenItemV2:DoFilter()
    self:RefreshItemList()
  end
  setactive(self.parent.ui.mTrans_WeaponPartsSuit, weaponModId ~= nil)
end
function UIRepositoryWeaponPartsPanel:onClickSubPartsPosTab(tabIndex)
  if self.curSubPartsPosTabIndex > 0 then
    self.subPartsPosTabTable[self.curSubPartsPosTabIndex]:SetSelectState(false)
  end
  self.curSubPartsPosTabIndex = tabIndex
  self.subPartsPosTabTable[self.curSubPartsPosTabIndex]:SetSelectState(true)
  local weaponModTypeId = 0
  if self.curSubPartsPosTabIndex > 0 then
    weaponModTypeId = self.subPartsPosTabTable[self.curSubPartsPosTabIndex].WeaponModTypeId
  end
  local suitId = 0
  self.comScreenItemV2:SetList(NetCmdWeaponPartsData:GetWeaponPartsList(weaponModTypeId, suitId))
  self.comScreenItemV2:DoFilter()
  self:RefreshItemList()
end
