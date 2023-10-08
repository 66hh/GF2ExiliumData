UIRepositoryDecomposePanelV2 = class("UIRepositoryDecomposePanelV2", UIBasePanel)
UIRepositoryDecomposePanelV2.panelType = {
  EQUIP = 1,
  WEAPON = 2,
  WEAPON_PARTS = 3
}
function UIRepositoryDecomposePanelV2:OnAwake(root, data)
end
function UIRepositoryDecomposePanelV2:OnInit(root, data)
  self:SetRoot(root)
  self.itemViewList = {}
  self.mView = nil
  self.isHide = false
  self.curPanelType = false
  self.soldItemList = {}
  self.soldObjList = {}
  self.selectItemList = {}
  self.selectItemIdList = {}
  self.skillList = {}
  self.suitList = {}
  self.attributeList = {}
  self.isSortDropDownActive = false
  self.isSuitDropDownActive = false
  self.isAscend = true
  self.curSort = UIRepositoryGlobal.SortType.Level
  self.curSuit = 0
  self.sortList = {}
  self.subProp = {}
  self.isHide = false
  self.mView = UIRepositoryDecomposePanelV2View.New()
  self.mView:InitCtrl(root, data[1])
  self.detailLockItem = UICommonLockItem.New()
  self.detailLockItem:InitCtrl(self.mView.mTrans_LockRoot)
  self.detailLockItem:AddClickListener(function()
    self:OnClickLock()
  end)
  self.curPanelType = data[1]
  if data[2] ~= nil then
    self.mIsPop = data[2]
  end
  UIUtils.GetButtonListener(self.mView.mBtn_Back.gameObject).onClick = function()
    self:OnReturnClick()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_Home.gameObject).onClick = function()
    self:OnCommanderCenter()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_3Item.gameObject).onClick = function()
    self:OnDismantle()
  end
  self.tagData = nil
  if self.curPanelType == UIRepositoryDecomposePanelV2.panelType.EQUIP then
    self.tagData = TableData.listRepositoryTagDatas:GetDataById(4)
    UIUtils.GetButtonListener(self.mView.mBtn_SuitDropdown.gameObject).onClick = function()
      self:OnSuitDropDown()
    end
    UIUtils.GetUIBlockHelper(self.mView.mUIRoot, self.mView.mTrans_Suit, function()
      self:OnSuitClose()
    end)
    local equipList = NetCmdEquipData:GetEquipListBySetId(0)
    self.itemList = self.listToTable(equipList)
    self.virtualList = self.mView.mVirtualList_EquipAll
    function self.virtualList.itemProvider()
      return self:EquipProvider()
    end
    setactive(self.mView.mTrans_LeftEquip, true)
    setactive(self.mView.mTrans_EquipSuitList.transform, true)
    self:InitSuitButton()
  else
    self.tagData = TableData.listRepositoryTagDatas:GetDataById(3)
    local weaponList = NetCmdWeaponData:GetEnhanceWeaponList(0)
    self.itemList = self.listToTable(weaponList)
    self.virtualList = self.mView.mVirtualList_Weapon
    function self.virtualList.itemProvider()
      return self:WeaponProvider()
    end
    setactive(self.mView.mList_WeaponSuit.transform, true)
  end
  self.CurFocusItemId = 0
  self.targetRanks = {}
  local enum = self.tagData.sold_checkbox:GetEnumerator()
  while enum:MoveNext() do
    table.insert(self.targetRanks, tonumber(enum.Current.Key))
  end
  table.sort(self.targetRanks)
  for i = 1, self.tagData.sold_checkbox.Count do
    self.mView["mBtn_Star" .. i] = self.mView:InstanceUIPrefab("Repository/RepositoryDecomposeQualityScreenItemV2.prefab", self.mView.mTrans_Quality, true):GetComponent("GFToggle")
    self.mView["mAnimator_Star" .. i] = UIUtils.GetAnimator(self.mView["mBtn_Star" .. i])
    self.mView["mBtn_Star" .. i].transform:Find("Root/GrpText/Text_Name"):GetComponent("Text").text = TableData.GetHintById(self.tagData.sold_checkbox[self.targetRanks[i]])
    self.mView["mBtn_Star" .. i].onValueChanged:AddListener(function(isOn)
      self:OnSelectRank(i, isOn)
    end)
  end
  UIUtils.GetButtonListener(self.mView.mBtn_Screen.gameObject).onClick = function()
    self:OnAscend()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_Dropdown.gameObject).onClick = function()
    self:OnDropDown()
  end
  UIUtils.GetUIBlockHelper(self.mView.mUIRoot, self.mView.mTrans_Screen, function()
    self:OnScreenClose()
  end)
  self:InitSortButton()
  setactive(self.mView.mTrans_Action, true)
  setactive(self.mView.mTrans_RightList, false)
  setactive(self.mView.mTrans_Weapon, self.curPanelType == UIRepositoryDecomposePanelV2.panelType.WEAPON)
  setactive(self.mView.mTrans_RightList, true)
  setactive(self.mView.mTrans_GrpWeapon, false)
  self.mView.mText_Empty.text = TableData.GetHintById(1059)
  self:UpdateConfirmBtn()
  self:UpdateCurrentCount()
  self:CheckDetail()
end
function UIRepositoryDecomposePanelV2.listToTable(clrlist)
  local t = {}
  local it = clrlist:GetEnumerator()
  while it:MoveNext() do
    if not it.Current.IsEquipped then
      t[#t + 1] = it.Current
    end
  end
  return t
end
function UIRepositoryDecomposePanelV2:OnCommanderCenter()
  UIManager.JumpToMainPanel()
  SceneSys:SwitchVisible(EnumSceneType.CommandCenter)
end
function UIRepositoryDecomposePanelV2:OnSelectRank(index, isOn)
  self["isSelectStar" .. index] = isOn
  self:UpdateSelect(self.targetRanks[index], self["isSelectStar" .. index])
  self.mView["mAnimator_Star" .. index]:SetBool("Sel", isOn)
  self.virtualList:Refresh()
end
function UIRepositoryDecomposePanelV2:OnClickLock()
  NetCmdWeaponData:SendGunWeaponLockUnlock(self.CurFocusItemId, function(ret)
    self:LockUnLockCallback(ret)
  end)
end
function UIRepositoryDecomposePanelV2:LockUnLockCallback(ret)
  if ret ~= ErrorCodeSuc then
    return
  end
  local itemView = self:GetItem(self.CurFocusItemId)
  if not itemView then
    return
  end
  local weaponCmdData = NetCmdWeaponData:GetWeaponById(self.CurFocusItemId)
  if not weaponCmdData then
    return
  end
  itemView:SetWeaponData(weaponCmdData, function(item)
    self:OnClickItem(item)
  end, weaponCmdData.id == self.CurFocusItemId, self.selectItemIdList[weaponCmdData.id])
  self:UpdateDetailLockState()
  if not weaponCmdData.IsLocked then
    self:FocusWeaponItem(self.CurFocusItemId)
  else
    UIRepositoryDecomposePanelV2:OnSelected(itemView, false)
  end
end
function UIRepositoryDecomposePanelV2:OnDropDown()
  setactive(self.mView.mTrans_Screen, true)
end
function UIRepositoryDecomposePanelV2:OnSuitDropDown()
  setactive(self.mView.mTrans_Suit, true)
end
function UIRepositoryDecomposePanelV2:OnScreenClose()
  setactive(self.mView.mTrans_Screen, false)
end
function UIRepositoryDecomposePanelV2:OnSuitClose()
  setactive(self.mView.mTrans_Suit, false)
end
function UIRepositoryDecomposePanelV2:OnAscend()
  self.isAscend = not self.isAscend
  self:UpdateSortList(self.curSort)
end
function UIRepositoryDecomposePanelV2:CanSelect(data)
  if self.curPanelType == UIRepositoryDecomposePanelV2.panelType.EQUIP then
    return self:Star(data, 1) or self:Star(data, 2) or self:Star(data, 3)
  else
    return self:Star(data, 1) or self:Star(data, 2) or self:Star(data, 3)
  end
end
function UIRepositoryDecomposePanelV2:Star(data, index)
  return self["isSelectStar" .. index] and data.Rank == UIRepositoryDecomposePanelV2.targetRanks[index]
end
function UIRepositoryDecomposePanelV2:CheckHaveHighRank(itemList)
  if itemList then
    local lowerRank = TableDataBase.GlobalSystemData.WeaponLowRank
    for _, item in ipairs(itemList) do
      local rank = item.rank or item.Rank
      if lowerRank < rank then
        return true
      end
    end
  end
  return false
end
function UIRepositoryDecomposePanelV2:OnDismantle()
  local selectList = self.selectItemList
  if #selectList <= 0 then
    return
  end
  if self:CheckHaveHighRank(selectList) then
    MessageBoxPanel.ShowDoubleType(TableData.GetHintById(30013), function()
      UIRepositoryDecomposePanelV2:DismantleItem(selectList)
    end)
    return
  else
    self:DismantleItem(selectList)
  end
end
function UIRepositoryDecomposePanelV2:DismantleItem(selectList)
  local idList = {}
  for _, item in ipairs(selectList) do
    table.insert(idList, item.id)
  end
  if self.curPanelType == UIRepositoryDecomposePanelV2.panelType.EQUIP then
    NetCmdGunEquipData:SendGunEquipDismantlingCmd(idList, function(ret)
      self:OnCloseSold(ret)
    end)
  elseif self.curPanelType == UIRepositoryDecomposePanelV2.panelType.WEAPON then
  end
end
function UIRepositoryDecomposePanelV2:UpdateItemList()
  self.soldItemList = {}
  self.selectItemIdList = {}
  for _, item in ipairs(self.itemList) do
    local soldItem = self:GetSoldItem(item)
    self:RemoveSelectItemById(item.id)
    self:RemoveSoldItem(soldItem)
  end
  self:ResetRankButtons()
  if self.curPanelType == UIRepositoryDecomposePanelV2.panelType.EQUIP then
    local equipList = NetCmdEquipData:GetEquipListBySetId(self.curSuit)
    self.itemList = self.listToTable(equipList)
  elseif self.curPanelType == UIRepositoryDecomposePanelV2.panelType.WEAPON then
    local weaponList = NetCmdWeaponData:GetEnhanceWeaponList(0)
    self.itemList = self.listToTable(weaponList)
  end
  if self.sortFunc then
    table.sort(self.itemList, self.sortFunc)
  end
  self.virtualList.numItems = #self.itemList
  self.virtualList:Refresh()
  self:CheckDetail()
  self:UpdateCurrentCount()
  self:UpdateSoldContent()
  self:UpdateConfirmBtn()
  if self.curPanelType == UIRepositoryDecomposePanelV2.panelType.EQUIP then
    self.suitList[self.curSuit].mText_SuitNum.text = #self.itemList
  end
end
function UIRepositoryDecomposePanelV2:OnCloseSold(ret)
  if ret == ErrorCodeSuc then
    UICommonReceivePanel.OpenWithCheckPopupDownLeftTips()
    self:UpdateItemList()
    self.CurFocusItemId = 0
    self:CheckDetail()
  else
    gferror("Dismantle Failed !!!!!")
  end
end
function UIRepositoryDecomposePanelV2:UpdateCurrentCount()
  self.mView.mText_NumNow.text = #self.selectItemList
  self.mView.mText_NumTotal.text = "/" .. #self.itemList
end
function UIRepositoryDecomposePanelV2:GetSoldItem(data)
  local soldItem
  if self.curPanelType == UIRepositoryDecomposePanelV2.panelType.EQUIP then
    soldItem = UIRepositoryGlobal:GetSoldOutItem(data.TableData.sold_get)
  else
    soldItem = UIRepositoryGlobal:GetSoldOutItem(data.StcData.sold_get)
  end
  return soldItem
end
function UIRepositoryDecomposePanelV2:UpdateSelect(i, select)
  for _, item in ipairs(self.itemList) do
    local rank = item.rank or item.Rank
    local level = item.level or item.Level or 0
    local soldItem = self:GetSoldItem(item)
    if rank == i and level == 0 then
      if select and not self.selectItemIdList[item.id] then
        table.insert(self.selectItemList, item)
        self.selectItemIdList[item.id] = true
        self:AddSoldItem(soldItem)
      end
      if not select then
        self:RemoveSelectItemById(item.id)
        self:RemoveSoldItem(soldItem)
      end
    end
  end
  self:UpdateSoldContent()
  self:CheckDetail()
  self:UpdateConfirmBtn()
end
function UIRepositoryDecomposePanelV2:InitSuitButton()
  local sortOptionPrefab = UIUtils.GetGizmosPrefab("Character/ChrEquipSuitDropDownItemV2.prefab", self)
  local item = ChrEquipSuitDropdownItemV2.New()
  local obj = instantiate(sortOptionPrefab, self.mView.mContent_Suit.transform)
  item:InitCtrl(obj.transform)
  item:SetZeroData(#self.itemList, function()
    self:OnClickSuit()
  end)
  self.suitList[0] = item
  local setList = TableData.listEquipSetDatas
  for i = 0, setList.Count - 1 do
    item = ChrEquipSuitDropdownItemV2.New()
    obj = instantiate(sortOptionPrefab, self.mView.mContent_Suit.transform)
    item:InitCtrl(obj.transform)
    item:SetData(setList[i], function()
      self:OnClickSuit()
    end)
    self.textcolor = obj.transform:GetComponent("TextImgColor")
    self.beforecolor = self.textcolor.BeforeSelected
    self.aftercolor = self.textcolor.AfterSelected
    self.suitList[setList[i].id] = item
    if i ~= 0 then
      self.suitList[i].mText_SuitName.color = self.beforecolor
      self.suitList[i].mText_SuitNum.color = self.beforecolor
      setactive(self.suitList[i].mTrans_GrpSet, false)
    else
      self.suitList[i].mText_SuitName.color = self.aftercolor
      self.suitList[i].mText_SuitNum.color = self.aftercolor
      setactive(self.suitList[i].mTrans_GrpSet, true)
    end
  end
  self.mView.mText_Dropdown_SuitName.text = TableData.GetHintById(1051)
end
function UIRepositoryDecomposePanelV2:InitSortButton()
  local sortOptionPrefab = UIUtils.GetGizmosPrefab("Character/ChrEquipSuitDropDownItemV2.prefab", self)
  for _, id in pairs(UIRepositoryGlobal.SortType) do
    local item = ChrEquipSuitDropdownItemV2.New()
    local obj = instantiate(sortOptionPrefab, self.mView.mContent_Screen.transform)
    item:InitCtrl(obj.transform)
    item.sortId = id
    item.mText_SuitName.text = TableData.GetHintById(53 + id)
    item.mText_SuitNum.text = ""
    self.textcolor = obj.transform:GetComponent("TextImgColor")
    self.beforecolor = self.textcolor.BeforeSelected
    self.aftercolor = self.textcolor.AfterSelected
    self.sortList[id] = item
    UIUtils.GetButtonListener(item.mBtn_Select.gameObject).onClick = function()
      self:OnClickSort(item.sortId)
    end
    if id == 2 then
      item.mText_SuitName.color = self.textcolor.AfterSelected
      setactive(item.mTrans_GrpSet, true)
    else
      item.mText_SuitName.color = self.textcolor.BeforeSelected
      setactive(item.mTrans_GrpSet, false)
    end
  end
  self.mView.mText_DropdownSuitName.text = TableData.GetHintById(53 + self.curSort)
end
function UIRepositoryDecomposePanelV2:OnClickSort(id)
  self.curSort = id
  self.mView.mText_DropdownSuitName.text = TableData.GetHintById(53 + id)
  setactive(self.mView.mTrans_Screen, false)
  self.isSortDropDownActive = false
  self:UpdateSortList(self.curSort)
  for keyid, item in ipairs(self.sortList) do
    if keyid == self.curSort then
      item.mText_SuitName.color = self.textcolor.AfterSelected
      setactive(item.mTrans_GrpSet, true)
    else
      item.mText_SuitName.color = self.textcolor.BeforeSelected
      setactive(item.mTrans_GrpSet, false)
    end
  end
end
function UIRepositoryDecomposePanelV2:ResetRankButtons()
  self.isSelectStar1 = false
  self.isSelectStar2 = false
  self.isSelectStar3 = false
  self.mView.mAnimator_Star1:SetBool("Sel", self.isSelectStar1)
  self.mView.mAnimator_Star2:SetBool("Sel", self.isSelectStar2)
  self.mView.mAnimator_Star3:SetBool("Sel", self.isSelectStar3)
end
function UIRepositoryDecomposePanelV2:OnClickSuit(item)
  if item.mWeaponData then
    self.curSuit = item.mWeaponData.id
  else
    self.curSuit = item.id
  end
  self.selectItemIdList = {}
  for _, item in ipairs(self.itemList) do
    local soldItem = self:GetSoldItem(item)
    self:RemoveSelectItemById(item.id)
    self:RemoveSoldItem(soldItem)
  end
  self:ResetRankButtons()
  self.mView.mText_Dropdown_SuitName.text = item.mText_SuitName.text
  self.isSuitDropDownActive = false
  setactive(self.mView.mTrans_Suit, false)
  local equipList = NetCmdEquipData:GetEquipListBySetId(self.curSuit)
  self.itemList = self.listToTable(equipList)
  if self.sortFunc then
    table.sort(self.itemList, self.sortFunc)
  end
  self.virtualList.numItems = #self.itemList
  self.virtualList:Refresh()
  self:CheckDetail()
  self:UpdateCurrentCount()
  for k, v in pairs(self.suitList) do
    if k == self.curSuit then
      v.mText_SuitName.color = self.aftercolor
      v.mText_SuitNum.color = self.aftercolor
      setactive(v.mTrans_GrpSet, true)
    else
      v.mText_SuitName.color = self.beforecolor
      v.mText_SuitNum.color = self.beforecolor
      setactive(v.mTrans_GrpSet, false)
    end
  end
end
function UIRepositoryDecomposePanelV2:SortItemList(sortFunc)
  if self.curPanelType == UIRepositoryDecomposePanelV2.panelType.EQUIP then
    function self.virtualList.itemRenderer(index, renderData)
      self:EquipRenderer(index, renderData)
    end
  else
    function self.virtualList.itemRenderer(index, renderData)
      self:WeaponRenderer(index, renderData)
    end
  end
  if sortFunc then
    table.sort(self.itemList, sortFunc)
    self.virtualList.numItems = #self.itemList
    self.virtualList:Refresh()
    self.sortFunc = sortFunc
  end
end
function UIRepositoryDecomposePanelV2:UpdateSortList(sortType)
  local sortFunc
  if self.curPanelType == UIRepositoryDecomposePanelV2.panelType.EQUIP then
    sortFunc = UIRepositoryGlobal:GetEquipSortFunction(sortType, 1, self.isAscend)
  else
    sortFunc = UIRepositoryGlobal:GetWeaponSortFunction(sortType, 1, self.isAscend)
  end
  self:SortItemList(sortFunc)
end
function UIRepositoryDecomposePanelV2:EquipProvider()
  local itemView = UICommonItem.New()
  itemView:InitCtrl(self.parent)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  table.insert(self.itemViewList, itemView)
  return renderDataItem
end
function UIRepositoryDecomposePanelV2:EquipRenderer(index, renderData)
  local data = self.itemList[index + 1]
  local item = renderData.data
  item:SetEquipByData(data, function(item)
    self:OnClickItem(item)
  end, self.selectItemIdList[data.id])
end
function UIRepositoryDecomposePanelV2:WeaponProvider()
  local itemView = UICommonItem.New()
  itemView:InitCtrl(self.virtualList.content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIRepositoryDecomposePanelV2:WeaponRenderer(index, renderData)
  local data = self.itemList[index + 1]
  local item = renderData.data
  self.itemViewList[index + 1] = item
  item:SetWeaponData(data, function(item)
    self:OnClickItem(item)
  end, data.id == self.CurFocusItemId, self.selectItemIdList[data.id])
end
function UIRepositoryDecomposePanelV2:UpdateConfirmBtn()
  self.mView.mBtn_Content.interactable = #self.selectItemList > 0
end
function UIRepositoryDecomposePanelV2:OnClickItem(item)
  self:FocusWeaponItem(item:GetWeaponItemId())
end
function UIRepositoryDecomposePanelV2:FocusWeaponItem(itemId)
  if self.CurFocusItemId == itemId then
    local itemView = self:GetItem(self.CurFocusItemId)
    itemView:LoseFocus()
    if itemView:IsSelect() then
      self:OnSelected(itemView, false)
    end
    self.CurFocusItemId = 0
    if 0 < #self.selectItemList then
      local prevItemId = self.selectItemList[#self.selectItemList].id
      self:FocusItem(prevItemId)
    else
      self:UpdateSoldContent()
      self:CheckDetail()
      self:UpdateConfirmBtn()
    end
  else
    local itemView = self:GetItem(self.CurFocusItemId)
    if itemView then
      itemView:LoseFocus()
    end
    itemView = self:FocusItem(itemId)
    if itemView:IsNoneState() then
      self:OnSelected(itemView, true)
    elseif itemView:IsSelect() then
      self:OnSelected(itemView, false)
    elseif itemView:IsLock() then
      local hint = TableData.GetHintById(40037)
      PopupMessageManager.PopupString(hint)
    elseif itemView:IsEquippedParts() then
      local onClickConfirm = function()
        itemView:UnEquipParts(function(ret)
          if ret == ErrorCodeSuc then
            UIRepositoryDecomposePanelV2:OnSelected(itemView, true)
          end
        end)
      end
      MessageBoxPanel.ShowDoubleType(TableData.GetHintById(40038), onClickConfirm)
    elseif itemView:IsFocused() then
      self:OnSelected(itemView, true)
    end
  end
end
function UIRepositoryDecomposePanelV2:GetItem(itemId)
  if itemId == 0 then
    return nil
  end
  for i, v in ipairs(self.itemViewList) do
    if v:GetWeaponItemId() == itemId then
      return v
    end
  end
  return nil
end
function UIRepositoryDecomposePanelV2:Refocus(itemId)
  self.CurFocusItemId = 0
  self:FocusWeaponItem(itemId)
end
function UIRepositoryDecomposePanelV2:FocusItem(itemId)
  local itemView = self:GetItem(itemId)
  itemView:Focus()
  self.CurFocusItemId = itemId
  self:UpdateSoldContent()
  self:CheckDetail()
  self:UpdateConfirmBtn()
  return itemView
end
function UIRepositoryDecomposePanelV2:UpdateDetailLockState()
  local itemView = self:GetItem(self.CurFocusItemId)
  if not itemView then
    return
  end
  self.detailLockItem:SetLock(itemView:IsLock())
end
function UIRepositoryDecomposePanelV2:OnSelected(item, isChoose)
  item:SetSelect(isChoose)
  local soldItem = self:GetSoldItem(item.mWeaponData)
  if item.isChoose then
    table.insert(self.selectItemList, item.mWeaponData)
    self.selectItemIdList[item.mWeaponData.id] = true
    self:AddSoldItem(soldItem)
    setactive(self.mView.mTrans_RightList, true)
  else
    self:RemoveSelectItemById(item.mWeaponData.id)
    self:RemoveSoldItem(soldItem)
  end
  local selectedAllStar1 = true
  local selectedAllStar2 = true
  local selectedAllStar3 = true
  local containsStar1 = false
  local containsStar2 = false
  local containsStar3 = false
  for i = 1, #self.itemList do
    local item = self.itemList[i]
    local rank = item.rank or item.Rank
    local level = item.level or item.Level
    if level == 0 then
      if not self.selectItemIdList[item.id] then
        if rank == UIRepositoryDecomposePanelV2.targetRanks[1] then
          selectedAllStar1 = false
          containsStar1 = true
        elseif rank == UIRepositoryDecomposePanelV2.targetRanks[2] then
          selectedAllStar2 = false
          containsStar2 = true
        elseif rank == UIRepositoryDecomposePanelV2.targetRanks[3] then
          selectedAllStar3 = false
          containsStar3 = true
        end
      elseif rank == UIRepositoryDecomposePanelV2.targetRanks[1] then
        containsStar1 = true
      elseif rank == UIRepositoryDecomposePanelV2.targetRanks[2] then
        containsStar2 = true
      elseif rank == UIRepositoryDecomposePanelV2.targetRanks[3] then
        containsStar3 = true
      end
    end
  end
  if selectedAllStar1 and containsStar1 and not self.isSelectStar1 then
    self.isSelectStar1 = true
    self.mView.mAnimator_Star1:SetBool("Sel", self.isSelectStar1)
  end
  if not selectedAllStar1 and self.isSelectStar1 then
    self.isSelectStar1 = false
    self.mView.mAnimator_Star1:SetBool("Sel", self.isSelectStar1)
  end
  if selectedAllStar2 and containsStar2 and not self.isSelectStar2 then
    self.isSelectStar2 = true
    self.mView.mAnimator_Star2:SetBool("Sel", self.isSelectStar2)
  end
  if not selectedAllStar2 and self.isSelectStar2 then
    self.isSelectStar2 = false
    self.mView.mAnimator_Star2:SetBool("Sel", self.isSelectStar2)
  end
  if selectedAllStar3 and containsStar3 and not self.isSelectStar3 then
    self.isSelectStar3 = true
    self.mView.mAnimator_Star3:SetBool("Sel", self.isSelectStar3)
  end
  if not selectedAllStar3 and self.isSelectStar3 then
    self.isSelectStar3 = false
    self.mView.mAnimator_Star3:SetBool("Sel", self.isSelectStar3)
  end
  self:UpdateSoldContent()
  self:CheckDetail()
  self:UpdateConfirmBtn()
end
function UIRepositoryDecomposePanelV2:CheckDetail()
  local hasFocused = self.CurFocusItemId ~= 0
  setactive(self.mView.mTrans_Empty, not hasFocused)
  setactive(self.mView.mTrans_GrpWeapon, hasFocused)
  self.mView.mBtn_Content.interactable = hasFocused
  if not hasFocused then
    return
  end
  local item = self:GetItem(self.CurFocusItemId)
  self:UpdateWeaponDetail(item.mWeaponData)
end
function UIRepositoryDecomposePanelV2:RemoveSelectItemById(id)
  local index = 0
  for i, item in ipairs(self.selectItemList) do
    if item.id == id then
      index = i
      break
    end
  end
  if 0 < index then
    table.remove(self.selectItemList, index)
  end
  self.selectItemIdList[id] = false
end
function UIRepositoryDecomposePanelV2:UpdateEquipDetail(data)
  self.mView.mText_EquipName.text = data.name
  self.mView.mText_EquipLevel.text = GlobalConfig.SetLvTextWithMax(data.level, data.max_level)
  self.mView.mImg_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(data.rank)
  self:UpdateEquipSet(data)
  self:UpdateEquipAttribute(data)
end
function UIRepositoryDecomposePanelV2:UpdateEquipSet(data)
  if data.setId ~= 0 then
    local setData = TableData.listEquipSetDatas:GetDataById(data.setId)
    for i, item in ipairs(self.mView.equipSetList) do
      item:SetData(data.setId, setData["set" .. i .. "_num"])
    end
  end
end
function UIRepositoryDecomposePanelV2:UpdateEquipAttribute(data)
  self:UpdateMainAttribute(data)
  self:UpdateSubAttribute(data)
end
function UIRepositoryDecomposePanelV2:UpdateMainAttribute(data)
  if data.main_prop then
    local tableData = TableData.listCalibrationDatas:GetDataById(data.main_prop.Id)
    if tableData then
      local propData = TableData.GetPropertyDataByName(tableData.property, tableData.type)
      self.mView.mText_MainAttrName.text = propData.show_name.str
      if propData.show_type == 2 then
        self.mView.mText_MainAttrNum.text = math.ceil(data.main_prop.Value / 10) .. "%"
      else
        self.mView.mText_MainAttrNum.text = data.main_prop.Value
      end
    end
  end
end
function UIRepositoryDecomposePanelV2:UpdateSubAttribute(data)
  if data.sub_props then
    local item
    for _, item in ipairs(self.subProp) do
      item:SetData(nil)
    end
    for i = 0, data.sub_props.Length - 1 do
      local prop = data.sub_props[i]
      local tableData = TableData.listCalibrationDatas:GetDataById(prop.Id)
      local propData = TableData.GetPropertyDataByName(tableData.property, tableData.type)
      if i + 1 <= #self.subProp then
        item = self.subProp[i + 1]
      else
        item = UICommonPropertyItem.New()
        item:InitCtrl(self.mView.mTrans_SubAttr)
        table.insert(self.subProp, item)
      end
      item:SetData(propData, prop.Value, true, false, false, false)
    end
  end
end
function UIRepositoryDecomposePanelV2:UpdateWeaponDetail(data)
  self.gunElement = gunElement
  local elementData = TableData.listLanguageElementDatas:GetDataById(data.Element)
  self.mView.mText_WeaponName.text = data.Name
  self.mView.mText_WeaponLevel.text = GlobalConfig.SetLvTextWithMax(data.Level, data.MaxLevel)
  local weaponTypeData = TableData.listGunWeaponTypeDatas:GetDataById(data.Type)
  self.mView.mText_WeaponTypeName.text = weaponTypeData.name.str
  self.mView.mImg_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(data.Rank)
  self.mView.stageItem:SetData(data.BreakTimes)
  self:UpdateAttribute(data)
  self:UpdateDetailLockState()
  if data.Skill and data.Skill.id ~= 0 then
    if self.normalSkillItem == nil then
      self.normalSkillItem = UIWeaponSkillItem.New()
      self.normalSkillItem:InitCtrl(self.mView.mTrans_Skill)
    end
    setactive(self.normalSkillItem.mUIRoot, true)
    self.normalSkillItem:SetData(data.Skill.id)
  elseif self.normalSkillItem ~= nil then
    setactive(self.normalSkillItem.mUIRoot, false)
  end
  if data.BuffSkill and data.BuffSkill.id ~= 0 then
    if self.elementSkillItem == nil then
      self.elementSkillItem = UIWeaponSkillItem.New()
      self.elementSkillItem:InitCtrl(self.mView.mTrans_Skill)
    end
    setactive(self.elementSkillItem.mUIRoot, true)
    self.elementSkillItem:SetData(data.BuffSkill.id)
  elseif self.elementSkillItem ~= nil then
    setactive(self.elementSkillItem.mUIRoot, false)
  end
end
function UIRepositoryDecomposePanelV2:UpdateAttribute(data)
  local attrList = {}
  local expandList = TableData.GetPropertyExpandList()
  for i = 0, expandList.Count - 1 do
    local lanData = expandList[i]
    if lanData.type == 1 then
      local value = data:GetPropertyByLevelAndSysName(lanData.sys_name, data.Level, data.BreakTimes)
      if 0 < value then
        local attr = {}
        attr.propData = lanData
        attr.value = value
        table.insert(attrList, attr)
      end
    end
  end
  table.sort(attrList, function(a, b)
    return a.propData.order < b.propData.order
  end)
  for _, item in ipairs(self.attributeList) do
    item:SetData(nil)
  end
  for i = 1, #attrList do
    local item
    if i <= #self.attributeList then
      item = self.attributeList[i]
    else
      item = UICommonPropertyItem.New()
      item:InitCtrl(self.mView.mTrans_AttrList)
      table.insert(self.attributeList, item)
    end
    item:SetData(attrList[i].propData, attrList[i].value, true, false, false)
    item:SetTextColor(attrList[i].propData.statue == 2 and ColorUtils.OrangeColor or ColorUtils.BlackColor)
  end
end
function UIRepositoryDecomposePanelV2:AddSoldItem(soldItem)
  if soldItem then
    for _, v in ipairs(soldItem) do
      local item = self:GetSoldItemById(v.id)
      if item then
        item.count = item.count + v.count
      else
        local tempItem = {}
        tempItem.id = v.id
        tempItem.count = v.count
        table.insert(self.soldItemList, tempItem)
        table.sort(self.soldItemList, function(a, b)
          return a.id < b.id
        end)
      end
    end
  end
end
function UIRepositoryDecomposePanelV2:RemoveSoldItem(soldItem)
  if soldItem then
    for _, v in ipairs(soldItem) do
      local item = self:GetSoldItemById(v.id)
      if item then
        item.count = item.count - v.count
        if item.count <= 0 then
          self:RemoveSoldItemById(item.id)
        end
      end
    end
    self:UpdateSoldContent()
  end
end
function UIRepositoryDecomposePanelV2:UpdateSoldContent()
  self.mView.mText_NumNow.text = #self.selectItemList
  self.mView.mText_NumTotal.text = "/" .. #self.itemList
  if #self.soldObjList > #self.soldItemList then
    for i = #self.soldItemList + 1, #self.soldObjList do
      self.soldObjList[i]:SetItemData(nil)
    end
  end
  for i, soldItem in ipairs(self.soldItemList) do
    local item
    if i <= #self.soldObjList then
      item = self.soldObjList[i]
    else
      item = UICommonItem.New()
      item:InitCtrl(self.mView.mContent_DecomposeItem)
      table.insert(self.soldObjList, item)
    end
    item:SetItemData(soldItem.id, soldItem.count)
  end
end
function UIRepositoryDecomposePanelV2:GetSoldItemById(id)
  for _, item in ipairs(self.soldItemList) do
    if item.id == id then
      return item
    end
  end
  return nil
end
function UIRepositoryDecomposePanelV2:RemoveSoldItemById(id)
  local index = 0
  for i, item in ipairs(self.soldItemList) do
    if item.id == id then
      index = i
    end
  end
  if 0 < index then
    table.remove(self.soldItemList, index)
  end
end
function UIRepositoryDecomposePanelV2:OnShowStart()
  self:UpdateSortList(self.curSort)
end
function UIRepositoryDecomposePanelV2:OnReturnClick(gameObj)
  self:Close()
end
function UIRepositoryDecomposePanelV2:Close()
  UIManager.CloseUI(UIDef.UIRepositoryDecomposePanelV2)
end
function UIRepositoryDecomposePanelV2:OnHide()
  self.isHide = true
end
function UIRepositoryDecomposePanelV2:OnClose()
  self.setView = nil
  self.virtualList = nil
  self.itemList = {}
  self.sortFunc = nil
  self.selectItemList = nil
  self.selectItemIdList = nil
  self.curTab = 0
  self.curPanel = 0
  self.curSort = UIRepositoryGlobal.SortType.Level
  self.tabList = nil
  self.sortList = nil
  self.subPanel = nil
  self.soldItemList = nil
  self.soldObjList = nil
  self.subProp = nil
  self.skillList = nil
  self.attributeList = nil
  self.elementSkillItem = nil
  self.normalSkillItem = nil
  self.suitList = nil
  self.CurFocusItemId = 0
  self:ReleaseCtrlTable(self.itemViewList, true)
  self.detailLockItem:OnRelease()
  self.detailLockItem = nil
  if self.mView.stageItem then
    self.mView.stageItem:Release()
  end
  self.mView:OnRelease(true)
end
function UIRepositoryDecomposePanelV2:OnRelease()
end
