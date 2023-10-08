require("UI.Repository.Item.UIRepositoryPublicTabItem")
require("UI.Repository.RepositoryPanel.SubPanel.UIRepositoryBasePanel")
UIRepositoryGunCorePanel = class("UIRepositoryGunCorePanel", UIRepositoryBasePanel)
function UIRepositoryGunCorePanel:ctor(parent, panelId, transRoot)
  self.super.ctor(self, parent, panelId, transRoot)
  self.parent = parent
  self.panelId = panelId
  self.isSub = false
  self.sortFunc = nil
  self.param = nil
  self.selectItemList = {}
  self.TopTabTable = {}
  self.super.Close(self)
end
function UIRepositoryGunCorePanel:Show()
  self.super.Show(self)
  self:InitTypeDropItem()
  self.currentIndex = 0
  self.currentTypeID = nil
  function self.virtualList.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  self.parent.ui.mTrans_Other.localPosition = vectorzero
  self:OnClickTypeDropdownItem(1)
  self.needGetList = TableData.GlobalSystemData.BackpackJumpSwitch == 1
  setactive(self.parent.ui.mTrans_ChrTalentList, true)
  setactive(self.parent.ui.mTrans_TalentImgLine, true)
  local templateCompose = self.parent.ui.mBtn_Compose.transform:GetComponent(typeof(CS.UITemplate))
  templateCompose.Texts[0].text = TableData.GetHintById(220040)
  self.parent.ui.mBtn_Compose.interactable = true
  UIUtils.GetButtonListener(self.parent.ui.mBtn_Compose.gameObject).onClick = function()
    self:OnClickCompose()
  end
end
function UIRepositoryGunCorePanel:OnBackFrom()
end
function UIRepositoryGunCorePanel:ItemRenderer(index, renderData)
  local data = self.itemList[index + 1]
  local item = renderData.data
  local count = NetCmdItemData:GetItemCountById(data.id)
  local customOnClick
  if self.currentIndex == 1 then
    item:SetItemData(data.id, count, nil, self.needGetList, nil, nil, nil, customOnClick)
    item:LimitNumTop(count)
  elseif self.currentIndex == 2 then
    function customOnClick()
      local weaponStcId = data.args[0]
      local param = {
        weaponStcId,
        UIWeaponGlobal.WeaponPanelTab.Info,
        true,
        UIWeaponPanel.OpenFromType.RepositoryWeaponCompose,
        needReplaceBtn = false
      }
      UIManager.OpenUIByParam(UIDef.UIWeaponPanel, param)
    end
    local itemNum = NetCmdItemData:GetItemCount(data.id)
    local needCount = 0
    local weaponId = tonumber(data.args[0])
    local weaponData = TableData.listGunWeaponDatas:GetDataById(weaponId)
    for id, count in pairs(weaponData.UnlockCost) do
      needCount = count
    end
    item:SetWeaponPieceData(data, itemNum, needCount, customOnClick)
    item:LimitNumTop(itemNum)
  end
end
function UIRepositoryGunCorePanel:Refresh()
  self:RefreshItemList()
end
function UIRepositoryGunCorePanel:RefreshItemList()
  self.itemList = self:GetGunCoreList()
  setactive(self.parent.ui.mTrans_Empty, #self.itemList == 0)
  if self.currentIndex == 1 then
    self.parent.ui.mTrans_Empty.text = TableData.GetHintById(1103)
  else
    for _, data in pairs(self.itemList) do
      local itemNum = NetCmdItemData:GetItemCount(data.id)
      local needCount = 0
      local weaponId = tonumber(data.args[0])
      local weaponData = TableData.listGunWeaponDatas:GetDataById(weaponId)
      for id, count in pairs(weaponData.UnlockCost) do
        needCount = count
      end
      if itemNum >= needCount then
        self.parent.ui.mBtn_Compose.interactable = true
        table.insert(self.pendingList, {
          id = weaponId,
          count = math.floor(itemNum / needCount)
        })
      end
    end
    self.parent.ui.mTrans_Empty.text = TableData.GetHintById(1102)
  end
  self.super.RefreshItemList(self)
  self.TopTabTable[2]:SetRedPoint(0 < NetCmdItemData:UpdateWeaponPieceRedPoint())
end
function UIRepositoryGunCorePanel:InitTypeDropItem()
  local tableData = TableData.listRepositoryTagDatas:GetDataById(self.panelId)
  local allDataList = tableData.toptag
  local allDataTable = CSList2LuaTable(allDataList)
  for i = 1, #allDataTable do
    local itemData = TableData.listRepositoryToptagDatas:GetDataById(allDataTable[i])
    if itemData then
      self:RegTypeDropdownItem(itemData.title.str, itemData.icon, itemData.item_type, i)
    end
  end
end
function UIRepositoryGunCorePanel:RegTypeDropdownItem(suitName, spriteName, typeId, index)
  if self.TopTabTable[index] == nil then
    local item1 = UIRepositoryPublicTabItem.New()
    item1:InitCtrl(self.parent.ui.mTrans_ChrTalentList.transform)
    self.TopTabTable[index] = item1
    item1:SetRedPoint(index == 2 and NetCmdItemData:UpdateWeaponPieceRedPoint() > 0)
  end
  local item = self.TopTabTable[index]
  item.itemIndex = index
  item.typeId = typeId
  item:SetData(suitName)
  item:SetClickFunction(function()
    self:OnClickTypeDropdownItem(item.itemIndex)
  end)
end
function UIRepositoryGunCorePanel:OnComposeSucc(ret)
  if ret == ErrorCodeSuc then
    local gunList = NetCmdItemData:GetUserDropGunWeaponChache()
    local ret = {}
    for i = 0, gunList.Length - 1 do
      local gun = {}
      gun.ItemId = gunList[i].ItemId
      table.insert(ret, gun)
    end
    if gunList ~= nil and 0 < gunList.Length then
      UICommonGetGunPanel.OpenGetGunPanel(ret, function()
        UICommonReceivePanel.OpenWithCheckPopupDownLeftTips()
        self:OnClickTypeDropdownItem(2)
      end, nil, true)
    else
      UICommonReceivePanel.OpenWithCheckPopupDownLeftTips()
      self:OnClickTypeDropdownItem(2)
    end
  end
end
function UIRepositoryGunCorePanel:OnClickCompose()
  local idList = {}
  local countList = {}
  for _, value in pairs(self.pendingList) do
    table.insert(idList, value.id)
    table.insert(countList, math.min(value.count, TableData.GlobalConfigData.WeaponComposeLimit))
  end
  if 0 < #idList then
    NetCmdWeaponData:SendWeaponCompose(idList, countList, function(ret)
      self:OnComposeSucc(ret)
    end)
  else
  end
end
function UIRepositoryGunCorePanel:OnClickTypeDropdownItem(itemIndex)
  self.pendingList = {}
  self.parent.ui.mBtn_Compose.interactable = false
  if self.currentIndex > 0 then
    self.TopTabTable[self.currentIndex]:SetSelectState(false)
  end
  self.currentIndex = itemIndex
  self.TopTabTable[self.currentIndex]:SetSelectState(true)
  self.currentTypeID = self.TopTabTable[itemIndex].typeId
  self:RefreshItemList()
  setactive(self.parent.ui.mTrans_Bottom, true)
  setactive(self.parent.ui.mBtn_Compose.transform.parent, self.currentIndex == 2)
end
function UIRepositoryGunCorePanel:GetGunCoreList()
  local list = {}
  local itemDataList = NetCmdItemData:GetRepositoryItemListByTypes(self.currentTypeID)
  for i = 0, itemDataList.Count - 1 do
    local itemData = itemDataList[i]
    local count = NetCmdItemData:GetItemCountById(itemData.item_id)
    local itemTabData = TableData.GetItemData(itemData.item_id)
    table.insert(list, itemTabData)
  end
  table.sort(list, function(a, b)
    return a.rank > b.rank
  end)
  return list
end
function UIRepositoryGunCorePanel:OnPanelBack()
  self:OnClickTypeDropdownItem(self.currentIndex)
  self.super.OnPanelBack(self)
end
function UIRepositoryGunCorePanel:Close()
  self.needGetList = nil
  self.parent.ui.mTrans_Other.localPosition = Vector3(0, 3000, 0)
  setactive(self.parent.ui.mTrans_ChrTalentList, false)
  setactive(self.parent.ui.mTrans_TalentImgLine, false)
  if 0 < self.currentIndex then
    self.TopTabTable[self.currentIndex]:SetSelectState(false)
  end
  self.currentIndex = 0
  self.currentTypeID = nil
  for i, v in ipairs(self.TopTabTable) do
    v:OnRelease()
  end
  self.pendingList = {}
  self.TopTabTable = {}
  setactive(self.parent.ui.mBtn_Compose.transform.parent, false)
end
