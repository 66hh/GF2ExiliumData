require("UI.UIBasePanel")
require("UI.WeaponPanel.UIWeaponGlobal")
require("UI.Common.UICommonLockItem")
require("UI.Repository.Item.UIRepositoryLeftTab2ItemV3")
require("UI.Common.UICommonPropertyItem")
require("UI.Common.UICommonReceivePanel")
UIRepositoryDecomposePanelV3 = class("UIRepositoryDecomposePanelV3", UIBasePanel)
UIRepositoryDecomposePanelV3.SortType = {
  BlueLowNoTrain = 1,
  BlueLowAndTrain = 2,
  OrangeLowAndTrain = 3
}
UIRepositoryDecomposePanelV3.maxDecomposeValue = TableData.GlobalSystemData.DarkzoneSplitLimit
UIRepositoryDecomposePanelV3.decomposeLevel = TableData.GlobalSystemData.ModDecomposeLevel
UIRepositoryDecomposePanelV3.mShowTag = {}
function UIRepositoryDecomposePanelV3:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self.leftTabTable = {}
  self.highRankCount = 0
  self.curDecomposeNum = 0
  self.curDecomposeId = 0
  self.curWeaponPartDecomposeId = 0
  self.sliderMaxNum = 0
  self.dropItemDataTable = {}
  self.partRankType = 1
  self.selectIndex = -1
  self.selectIndexTable = {}
  self.toRemovePartList = {}
  self.contentItem = {}
  self.instanceTab = {}
  self:LuaUIBindTable(root, self.ui)
  self.virtualList = self.ui.mVirtualListEx_List
  function self.virtualList.itemProvider()
    local item = self:ItemProvider()
    return item
  end
  function self.virtualList.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Back.transform).onClick = function()
    self:OnReturnClick()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    self:OnCommanderCenter()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_SliderAdd.gameObject).onClick = function()
    self:OnAddSlider()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_SliderReduce.gameObject).onClick = function()
    self:OnReduceSlider()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Decompose.gameObject).onClick = function()
    self:OnDecompose()
  end
  self.ui.mBtn_QuickSelect.interactable = true
  local uiTemplate = self.ui.mBtn_QuickSelect.transform:GetComponent(typeof(CS.UITemplate))
  uiTemplate.Texts[0].text = TableData.GetHintById(102007)
  UIUtils.GetButtonListener(self.ui.mBtn_QuickSelect.gameObject).onClick = function()
    self:OnClickQuickSelect()
  end
  self:InitTabButton()
end
function UIRepositoryDecomposePanelV3:OnInit(root, data)
  self.QuickSortType = {
    [UIRepositoryGlobal.PanelType.WeaponPanel] = {
      [1] = {hintId = 1084, arg = 3},
      [2] = {hintId = 1085, arg = 4},
      [3] = {hintId = 1086, arg = 5},
      func = function()
        self:QicklySelectWeaponPanel()
      end
    },
    [UIRepositoryGlobal.PanelType.WeaponParts] = {
      [1] = {hintId = 1087, arg = 3},
      [2] = {hintId = 1088, arg = 4},
      [3] = {hintId = 1089, arg = 5},
      func = function()
        self:QicklySelectWeaponParts()
      end
    },
    [UIRepositoryGlobal.PanelType.GunCore] = {
      [1] = {hintId = 1081, arg = 0},
      [2] = {hintId = 1082, arg = 11},
      [3] = {hintId = 1083, arg = 38},
      func = function()
        self:QicklySelectGunCore()
      end
    },
    [UIRepositoryGlobal.PanelType.PublicSkill] = {
      [1] = {hintId = 1090, arg = 3},
      [2] = {hintId = 1091, arg = 4},
      [3] = {hintId = 1092, arg = 5},
      func = function()
        self:QicklySelectPublicSkill()
      end
    }
  }
  self.modSuitItemList = {}
  self.attributeList = {}
  self.proficAttributeList = {}
  self.makeUpAttributeList = {}
  self.subPropList = {}
  self.dropItemList = {}
  self.polarityList = {
    self.ui.mTrans_GrpPolarity1,
    self.ui.mTrans_GrpPolarity2,
    self.ui.mTrans_GrpPolarity3,
    self.ui.mTrans_GrpPolarity4,
    self.ui.mTrans_GrpPolarity5,
    self.ui.mTrans_GrpPolarity6
  }
  self.weaponPartList = {}
  self.playProgressAni = false
  self.attributeItemTable = {}
  self.selectItem = nil
  self.curTabId = data
  setactive(self.ui.mTrans_TitleTagContent, true)
  setactive(self.ui.mTrans_WeaponPartSlider, false)
  setactive(self.ui.mTrans_GrpDecompose, true)
  if self.curTabId == UIRepositoryGlobal.PanelType.WeaponParts then
    setactive(self.ui.mTrans_TitleTagContent, false)
    setactive(self.ui.mTrans_WeaponPartSlider, true)
    setactive(self.ui.mTrans_GrpDecompose, false)
  end
  self.curClickTabId = -1
  self.partRankType = 1
  self:InitLockItem()
  self:OnClickTab(self.curTabId)
  setactive(self.ui.mTrans_WeaponPart, false)
end
function UIRepositoryDecomposePanelV3:OnCommanderCenter()
  UIManager.JumpToMainPanel()
  SceneSys:SwitchVisible(EnumSceneType.CommandCenter)
end
function UIRepositoryDecomposePanelV3:CanDataSold(data)
  if data.can_sold.Count > 0 then
    for i = 0, data.can_sold.Count - 1 do
      if data.can_sold[i] == 1 then
        return true
      end
    end
  end
  return false
end
function UIRepositoryDecomposePanelV3:InitTabButton()
  local typeList = TableData.listRepositoryTagDatas:GetList()
  local list = {}
  for i = 0, typeList.Count - 1 do
    local type = typeList[i]
    list[type.sequence] = type
  end
  table.sort(list, function(a, b)
    return a.sequence < b.sequence
  end)
  for id, data in pairs(list) do
    if data ~= nil and self:CanDataSold(data) then
      local item = UIRepositoryLeftTab2ItemV3.New()
      item:InitCtrl(self.ui.mTrans_TitleTagContent)
      item:SetName(data.id, data.title.str)
      item.ui.mText_Name.text = data.title.str
      UIUtils.GetButtonListener(item.ui.mBtn_ComTab1ItemV2.gameObject).onClick = function()
        self:OnClickTab(item.tagId)
      end
      table.insert(self.leftTabTable, item)
      if data.id == UIRepositoryGlobal.PanelType.WeaponParts then
        setactive(item:GetRoot(), false)
      end
    end
  end
end
function UIRepositoryDecomposePanelV3:InitLockItem()
  local parent = self.ui.mScrollListChild_BtnLock.transform
  local obj
  if parent.childCount > 0 then
    obj = parent:GetChild(0)
  end
  self.lockItem = self.lockItem or UICommonLockItem.New()
  self.lockItem:InitCtrl(parent, obj)
  self.lockItem:AddClickListener(function(isOn)
    self:OnClickLock(isOn)
  end)
end
function UIRepositoryDecomposePanelV3:OnClickLock(isOn)
  if self.contentItem[self.selectFrameIndex].mWeaponPartsData then
    if isOn == self.contentItem[self.selectFrameIndex].mWeaponPartsData.IsLocked then
      return
    end
    if not self.contentItem[self.selectFrameIndex].mWeaponPartsData.IsLocked then
      for i = 1, #self.selectIndexTable do
        if self.selectIndexTable[i].Index == self.selectFrameIndex then
          table.remove(self.selectIndexTable, i)
          self.contentItem[self.selectFrameIndex]:SetSelectNum(0)
          break
        end
      end
    end
    NetCmdWeaponPartsData:ReqWeaponPartLockUnlock(self.contentItem[self.selectFrameIndex].mWeaponPartsData.id, function(ret)
      if ret == ErrorCodeSuc then
        if isOn then
          UIUtils.PopupPositiveHintMessage(220007)
        else
          UIUtils.PopupPositiveHintMessage(220008)
        end
        self.lockItem:SetLock(isOn)
        self.contentItem[self.selectFrameIndex]:SetLock(isOn)
        self:RefreshSlider()
      end
    end)
  else
    if not self.contentItem[self.selectFrameIndex].mWeaponData and isOn == self.contentItem[self.selectFrameIndex].mWeaponData.IsLocked then
      return
    end
    if not self.contentItem[self.selectFrameIndex].mWeaponData.IsLocked then
      for i = 1, #self.selectIndexTable do
        if self.selectIndexTable[i].Index == self.selectFrameIndex then
          table.remove(self.selectIndexTable, i)
          self.contentItem[self.selectFrameIndex]:SetSelectNum(0)
          break
        end
      end
    end
    NetCmdWeaponData:SendGunWeaponLockUnlock(self.contentItem[self.selectFrameIndex].mWeaponData.id, function(ret)
      if ret == ErrorCodeSuc then
        if isOn then
          UIUtils.PopupPositiveHintMessage(220007)
        else
          UIUtils.PopupPositiveHintMessage(220008)
        end
        self.lockItem:SetLock(isOn)
        self.contentItem[self.selectFrameIndex]:SetLock(isOn)
        self:RefreshSlider()
      end
    end)
  end
end
function UIRepositoryDecomposePanelV3:GetLeftTabByTagId(tagId)
  for i, tab in pairs(self.leftTabTable) do
    if tab.tagId == tagId then
      return tab
    end
  end
  return nil
end
function UIRepositoryDecomposePanelV3:OnClickTab(tabId)
  self.curTabId = tabId
  self.selectIndex = -1
  self.selectIndexTable = {}
  self.toRemovePartList = {}
  self.selectFrameIndex = -1
  self.contentItem = {}
  self.instanceTab = {}
  self:SetTabFalse()
  local tab = self:GetLeftTabByTagId(tabId)
  if tab ~= nil then
    tab:SetItemState(true)
  end
  setactive(self.ui.mTrans_QuickSelect, tabId ~= UIRepositoryGlobal.PanelType.ItemPanel)
  if tabId ~= UIRepositoryGlobal.PanelType.ItemPanel then
    self:InitSortPart()
  end
  self.itemList = {}
  if tabId == UIRepositoryGlobal.PanelType.ItemPanel then
    self:GetCommonItemList(self.itemList)
  elseif tabId == UIRepositoryGlobal.PanelType.GunCore then
    local itemTabData = TableData.listRepositoryTagDatas:GetDataById(UIRepositoryGlobal.PanelType.GunCore)
    self:GetGunCoreList(self.itemList, itemTabData)
  elseif tabId == UIRepositoryGlobal.PanelType.WeaponPanel then
    self:GetWeaponList(self.itemList)
  elseif tabId == UIRepositoryGlobal.PanelType.WeaponParts then
    self:GetWeaponPartList(self.itemList, 0)
    self:UpdateDecomposeSortContent()
  elseif tabId == UIRepositoryGlobal.PanelType.PublicSkill then
    self:GetPublicSkillList(self.itemList)
  else
    self:GetAllItemList()
  end
  if self.itemList ~= nil then
    self:RefreshItemList()
  end
  local repositoryTagData = TableData.listRepositoryTagDatas:GetDataById(self.curTabId, true)
  if repositoryTagData ~= nil then
    self.ui.mTxt_EmptyL.text = string_format(TableData.GetHintById(1068), repositoryTagData.title.str)
  else
    self.ui.mTxt_EmptyL.text = string_format(TableData.GetHintById(1074))
  end
  self.highRankCount = 0
  self.curDecomposeNum = 0
  self.curDecomposeId = 0
  self:RefreshSlider()
  setactive(self.ui.mTxt_EmptyL, self.itemList == nil or #self.itemList == 0)
  setactive(self.ui.mTrans_GrpWeaponText, self.curTabId == UIRepositoryGlobal.PanelType.WeaponPanel)
  setactive(self.ui.mTrans_EmptyR, true)
  setactive(self.ui.mTrans_DetailInfo, false)
  setactive(self.ui.mTrans_Talent, false)
  setactive(self.ui.mScrollListChild_BtnLock.gameObject, false)
  setactive(self.ui.mTrans_Num, false)
  setactive(self.ui.mBtn_Decompose, false)
  setactive(self.ui.mTrans_DecomposeDisable, true)
  setactive(self.ui.mTrans_TopInfo, false)
  setactive(self.ui.mTrans_Weapon, false)
  setactive(self.ui.mTrans_WeaponPart, false)
  setactive(self.ui.mTrans_Capacity, false)
  setactive(self.ui.mImg_PartType, false)
  setactive(self.ui.mText_Flaw, false)
  setactive(self.ui.mScrollChild_Attribute, false)
  setactive(self.ui.mTrans_Special, false)
  setactive(self.ui.mTrans_MakeUp, false)
  setactive(self.ui.mTrans_GrpPolarity, false)
end
function UIRepositoryDecomposePanelV3:RefreshItemList(child)
  setactive(self.ui.mTrans_QuickSelect, #self.itemList > 0 and self.curTabId ~= UIRepositoryGlobal.PanelType.ItemPanel)
  self.virtualList.numItems = #self.itemList
  self.virtualList:Refresh()
  setactive(self.ui.mTrans_Content, false)
  setactive(self.ui.mTrans_Content, true)
end
function UIRepositoryDecomposePanelV3:ItemProvider()
  local itemView = UICommonItem.New()
  itemView:InitCtrl(self.ui.mTrans_Content, false)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  setactive(renderDataItem.renderItem, true)
  renderDataItem.data = itemView
  return renderDataItem
end
function UIRepositoryDecomposePanelV3:ItemRenderer(index, renderData)
  local data = self.itemList[index + 1]
  local item = renderData.data
  local instanceId = renderData.renderItem:GetInstanceID()
  if self.instanceTab == nil then
    self.instanceTab = {}
  end
  self.instanceTab[instanceId] = index + 1
  self.contentItem[index + 1] = item
  local curItemTabId = data.tabId
  local curItem = data.curItem
  if curItemTabId == UIRepositoryGlobal.PanelType.ItemPanel then
    item:SetItemData(curItem.item_id, curItem.item_num, false, false, data.item_num, nil, nil, function(tempItem)
      UIRepositoryDecomposePanelV3:ShowCommonItem(index + 1, tempItem)
    end, nil, true)
  elseif curItemTabId == UIRepositoryGlobal.PanelType.GunCore then
    local count = NetCmdItemData:GetItemCountById(curItem.item_id)
    item:SetItemData(curItem.item_id, count, false, false, count, nil, nil, function(tempItem)
      UIRepositoryDecomposePanelV3:OnShowGunCoreItem(index + 1, tempItem)
    end, nil, true)
  elseif curItemTabId == UIRepositoryGlobal.PanelType.WeaponPanel then
    item:SetWeaponData(curItem.attr, function(tempItem)
      UIRepositoryDecomposePanelV3:OnClickWeaponItem(index + 1, tempItem)
    end, false, false, curItem.num, false)
  elseif curItemTabId == UIRepositoryGlobal.PanelType.WeaponParts then
    item:SetWeaponPartsData(curItem, function(tempItem)
      UIRepositoryDecomposePanelV3:OnClickWeaponPartItem(index + 1, tempItem)
    end)
  elseif curItemTabId == UIRepositoryGlobal.PanelType.PublicSkill then
    item:SetPublicSkillData(curItem, function(tempItem)
      UIRepositoryDecomposePanelV3:OnShowPublicSkillItem(index + 1, tempItem)
    end)
  end
  item:SetSelectShow(false)
  item:SetSelectNum(0)
  if self:IsUnstackMode() then
    for _, v in pairs(self.selectIndexTable) do
      if v.Index == index + 1 then
        item:SetSelectShow(true)
        item:SetSelectNum(1)
        break
      end
    end
  else
    for _, v in pairs(self.selectIndexTable) do
      if v.Index == index + 1 then
        item:SetSelectNum(v.Count)
        break
      end
    end
  end
  item:SetSelectShow(self.selectFrameIndex == index + 1)
end
function UIRepositoryDecomposePanelV3:UpdateSelectItem(defaultIndex)
  if self:IsUnstackMode() then
    for _, v in pairs(self.selectIndexTable) do
      local item = self.contentItem[v.Index]
      if item then
        local instanceId = item:GetRoot().gameObject:GetInstanceID()
        if self.instanceTab[instanceId] ~= nil and self.instanceTab[instanceId] == v.Index then
          item:SetSelectNum(1)
          if defaultIndex then
            item:SetSelectShow(defaultIndex == v.Index)
          else
            item:SetSelectShow(self.selectFrameIndex == v.Index)
          end
        end
      end
    end
  else
    for _, v in pairs(self.selectIndexTable) do
      local item = self.contentItem[v.Index]
      if defaultIndex and defaultIndex == v.Index then
        self.curDecomposeNum = v.Count
      end
      if item then
        item:SetSelectNum(v.Count)
        if defaultIndex then
          item:SetSelectShow(defaultIndex == v.Index)
        else
          item:SetSelectShow(self.selectFrameIndex == v.Index)
        end
      end
    end
  end
end
function UIRepositoryDecomposePanelV3:OnClickUnstackItem(index, item, isLocked, hasPart, partList)
  if isLocked then
    if self.curTabId == UIRepositoryGlobal.PanelType.WeaponPanel then
      UIUtils.PopupHintMessage(1095)
    elseif self.curTabId == UIRepositoryGlobal.PanelType.WeaponParts then
      UIUtils.PopupHintMessage(1096)
    end
  end
  local isSelected = true
  for i = 1, #self.selectIndexTable do
    if self.selectIndexTable[i].Index == index then
      table.remove(self.selectIndexTable, i)
      isSelected = false
      item:SetSelectNum(0)
      if partList ~= nil then
        for _, part in pairs(partList) do
          self.toRemovePartList[part.id] = nil
        end
      end
      break
    end
  end
  if isSelected and not isLocked then
    if #self.selectIndexTable >= self:GetDisposalLimit() or self.curTabId == UIRepositoryGlobal.PanelType.WeaponParts and self:CheckMaxDecomposeProgress() then
      UIUtils.PopupHintMessage(1106)
      isSelected = false
      item:SetSelectNum(0)
    elseif self.curTabId == UIRepositoryGlobal.PanelType.WeaponPanel and hasPart ~= nil and hasPart then
      local param = {
        title = TableData.GetHintById(208),
        contentText = TableData.GetHintById(1100),
        customData = partList,
        isDouble = true,
        confirmCallback = function()
          table.insert(self.selectIndexTable, {Index = index, Count = 1})
          item:SetSelectNum(1)
          for _, part in pairs(partList) do
            self.toRemovePartList[part.id] = true
          end
          self:RefreshSlider()
        end,
        dialogType = 4
      }
      UIManager.OpenUIByParam(UIDef.UIComDoubleCheckDialog, param)
    else
      table.insert(self.selectIndexTable, {Index = index, Count = 1})
      item:SetSelectNum(1)
    end
  end
  item:SetSelectShow(true)
end
function UIRepositoryDecomposePanelV3:OnClickStackItem(index, item)
  local isSelected = true
  for i = 1, #self.selectIndexTable do
    if self.selectIndexTable[i].Index == index then
      isSelected = false
      self:OnSliderChange(0)
      item:SetSelectNum(0)
      break
    end
  end
  if isSelected then
    self:OnSliderChange(self.sliderMaxNum)
    item:SetSelectNum(self.sliderMaxNum)
  end
  item:SetSelectShow(true)
end
function UIRepositoryDecomposePanelV3:ShowCommonItem(index, item)
  self.ui.mSlider_Decompose.onValueChanged:RemoveAllListeners()
  if self.selectFrameIndex >= 0 then
    self.contentItem[self.selectFrameIndex]:SetSelectShow(false)
  end
  self.selectFrameIndex = index
  self:InitSlider(NetCmdItemData:GetItemCountById(item.itemId))
  self:OnClickStackItem(index, item)
  self.ui.mTxt_Title.text = TableData.GetHintById(1003)
  UIRepositoryDecomposePanelV3:SetDetailShow()
  local itemTabData = TableData.GetItemData(item.itemId)
  if itemTabData ~= nil then
    self.curDecomposeId = item.itemId
    self.ui.mTxt_ItemName.text = itemTabData.name.str
    self.ui.mImg_Rank.color = TableData.GetGlobalGun_Quality_Color2(itemTabData.rank)
    self.ui.mTxt_DetailInfo.text = itemTabData.introduction.str
  end
  setactive(self.ui.mTrans_TopInfo, itemTabData ~= nil)
  self.curClickTabId = UIRepositoryGlobal.PanelType.ItemPanel
end
function UIRepositoryDecomposePanelV3:OnClickWeaponItem(index, item, ignoreTable)
  local weaponData = self.itemList[index].curItem.attr
  if self.selectFrameIndex >= 0 then
    self.contentItem[self.selectFrameIndex]:SetSelectShow(false)
  end
  self.selectFrameIndex = index
  setactive(self.ui.mScrollListChild_BtnLock.gameObject, true)
  self.lockItem:SetLock(weaponData.IsLocked)
  if ignoreTable == nil or not ignoreTable then
    if weaponData:HasPart() then
      local partList = {}
      for i = 0, weaponData.DicWeaponParts.Count - 1 do
        local part = weaponData.DicWeaponParts[i]
        table.insert(partList, {
          itemId = part.ItemData.Id,
          itemNum = 1,
          id = part.id
        })
      end
      self:OnClickUnstackItem(index, item, weaponData.IsLocked, weaponData:HasPart(), partList)
    else
      self:OnClickUnstackItem(index, item, weaponData.IsLocked)
    end
  end
  self.ui.mTxt_Title.text = TableData.GetHintById(1003)
  UIRepositoryDecomposePanelV3:SetDetailShow()
  local weaponCmdData = NetCmdWeaponData:GetWeaponById(weaponData.id)
  if weaponCmdData == nil then
    return
  end
  setactive(self.ui.mTrans_GrpPolarityIcom, false)
  setactive(self.ui.mTrans_TextChr, false)
  for i = 0, weaponCmdData.Polarization.Count - 1 do
    local polarization = weaponCmdData.Polarization[i]
    local item = self.polarityList[i + 1]
    if item then
      local img = item.transform:Find("Img_Polarity"):GetComponent(typeof(CS.UnityEngine.UI.Image))
      if img then
        setactive(img.gameObject, polarization ~= 0)
        if polarization ~= 0 then
          setactive(self.ui.mTrans_GrpPolarityIcom, true)
          setactive(self.ui.mTrans_TextChr, true)
          local polarizationData = TableData.listPolarityTagDatas:GetDataById(polarization)
          if polarizationData then
            img.sprite = IconUtils.GetElementIcon(polarizationData.icon .. "_S")
          end
        end
      end
    end
  end
  self.curDecomposeId = weaponData.stc_id
  local typeData = TableData.listGunWeaponTypeDatas:GetDataById(weaponCmdData.Type)
  if typeData ~= nil then
    self.ui.mTxt_Title.text = typeData.name.str
  end
  self.ui.mTxt_ItemName.text = weaponData.Name
  setactive(self.ui.mTrans_TopInfo, true)
  self.ui.mTxt_WeaponDetailInfo.text = weaponData.StcData.Description.str
  self.ui.mImg_Rank.color = TableData.GetGlobalGun_Quality_Color2(weaponData.Rank)
  self:RefreshSlider()
  setactive(self.ui.mTrans_Slider, false)
  self.curClickTabId = UIRepositoryGlobal.PanelType.WeaponPanel
end
function UIRepositoryDecomposePanelV3:OnShowGunCoreItem(index, item, ignoreTable)
  self.ui.mSlider_Decompose.onValueChanged:RemoveAllListeners()
  if self.selectFrameIndex >= 0 then
    self.contentItem[self.selectFrameIndex]:SetSelectShow(false)
  end
  self.selectFrameIndex = index
  self:InitSlider(NetCmdItemData:GetItemCountById(item.itemId))
  if ignoreTable == nil or not ignoreTable then
    self:OnClickStackItem(index, item)
  end
  self.ui.mTxt_Title.text = TableData.GetHintById(1055)
  UIRepositoryDecomposePanelV3:SetDetailShow()
  local itemTabData = TableData.GetItemData(item.itemId)
  if itemTabData ~= nil then
    self.curDecomposeId = item.itemId
    self.ui.mTxt_ItemName.text = itemTabData.name.str
    self.ui.mImg_Rank.color = TableData.GetGlobalGun_Quality_Color2(itemTabData.rank)
    self.ui.mTxt_DetailInfo.text = itemTabData.introduction.str
  end
  setactive(self.ui.mTrans_TopInfo, itemTabData ~= nil)
  self.curClickTabId = UIRepositoryGlobal.PanelType.GunCore
end
function UIRepositoryDecomposePanelV3:OnClickWeaponPartItem(index, item, ignoreTable)
  if self.selectFrameIndex >= 0 then
    self.contentItem[self.selectFrameIndex]:SetSelectShow(false)
  end
  local weaponPartsData = self.itemList[index].curItem
  if ignoreTable == nil or not ignoreTable then
    self:OnClickUnstackItem(index, item, weaponPartsData.IsLocked)
  end
  self.selectFrameIndex = index
  self.ui.mTxt_ItemName.text = weaponPartsData.name
  self.ui.mTxt_DetailInfo.text = ""
  self.ui.mImg_Rank.color = TableData.GetGlobalGun_Quality_Color2(weaponPartsData.rank)
  self.curDecomposeId = weaponPartsData.stcId
  self.curWeaponPartDecomposeId = weaponPartsData.id
  UIRepositoryDecomposePanelV3:SetDetailShow()
  setactive(self.ui.mTrans_Capacity, false)
  setactive(self.ui.mImg_PartType, true)
  self.ui.mImg_PartType.sprite = IconUtils.GetWeaponPartIconSprite(weaponPartsData.ModEffectTypeData.Icon, false)
  setactive(self.ui.mText_Flaw, true)
  self.ui.mText_Flaw.text = ""
  setactive(self.ui.mScrollListChild_BtnLock, true)
  self.lockItem:SetLock(weaponPartsData.IsLocked)
  self.contentItem[self.selectFrameIndex]:SetLock(weaponPartsData.IsLocked)
  self:RefreshSlider()
  local color = ColorUtils.OrangeColor
  local atrributeListColor
  setactive(self.ui.mScrollChild_Attribute, true)
  atrributeListColor = CS.GunWeaponModData.SetWeaponPartAttr(weaponPartsData, self.ui.mScrollChild_Attribute.transform, self.ui.mTrans_MainAttribute.transform, 0)
  local flag = false
  if weaponPartsData.ModEffectTypeData.EffectId == UIWeaponGlobal.ModEffectType.Cover and weaponPartsData.ModPowerData then
    CS.GunWeaponModData.SetModPowerDataNameWithLevel(self.ui.mText_MakeUpName, weaponPartsData.ModPowerData, weaponPartsData)
    self.ui.mImg_MakeUp.sprite = IconUtils.GetWeaponPartIconSprite(weaponPartsData.ModPowerData.image, false)
    if 0 < weaponPartsData.BasicValue.Length + weaponPartsData.GunWeaponModPropertyListWithAddValue.Count or weaponPartsData.GroupSkillData ~= nil then
      setactive(self.ui.mTrans_MakeUp, true)
      setactive(self.ui.mTrans_Special, true)
      flag = true
    else
      setactive(self.ui.mTrans_MakeUp, false)
    end
    self.ui.mText_MakeUpLv.text = string_format("1/{0}", weaponPartsData.ModPowerList[1].Key)
    self.ui.mTrans_MakeUpItem:GetComponent(typeof(CS.TextFit)).text = weaponPartsData:GetModGroupSkillShowText()
  end
  local preficAttList = CS.GunWeaponModData.SetWeaponPartProficiencySkill(weaponPartsData, self.ui.mTrans_GrpPolarity.transform)
  self:SetModLevel(weaponPartsData)
  if weaponPartsData.ModEffectTypeData.EffectId == UIWeaponGlobal.ModEffectType.Ambush or weaponPartsData.ModEffectTypeData.EffectId == UIWeaponGlobal.ModEffectType.Armor then
    if weaponPartsData.ExtraCapacity ~= 0 or 0 < weaponPartsData.GunWeaponModPropertyListWithAddValue.Count then
      setactive(self.ui.mTrans_GrpPolarity, true)
      flag = true
    else
      setactive(self.ui.mTrans_GrpPolarity, false)
    end
  end
  setactive(self.ui.mTrans_Special, flag)
  setactive(self.ui.mTrans_MakeUp, weaponPartsData.GroupSkillData ~= nil)
  local slotData = TableData.listWeaponModTypeDatas:GetDataById(weaponPartsData.fatherType)
  if slotData ~= nil then
    self.ui.mTxt_Title.text = slotData.name.str
  end
  setactive(self.ui.mTrans_TopInfo, slotData ~= nil)
  local mainProp = self.subPropList[1]
  if mainProp == nil then
    mainProp = UICommonPropertyItem.New()
    table.insert(self.subPropList, mainProp)
  end
  self:RefreshSlider()
  self.curClickTabId = UIRepositoryGlobal.PanelType.WeaponParts
  setactive(self.ui.mTrans_Slider, false)
  self:RefreshDecomposeProgress()
end
function UIRepositoryDecomposePanelV3:SetModLevel(tmpGunWeaponModData)
  setactive(self.ui.mTrans_PolarityIcon, tmpGunWeaponModData.stcDataCanPolarity)
  CS.GunWeaponModData.SetModLevelText(self.ui.mText_Lv, tmpGunWeaponModData, self.ui.mText_LvMax)
  CS.GunWeaponModData.SetModPolarityText(self.ui.mText_State, self.ui.mImg_Polarity, tmpGunWeaponModData, self.ui.mCanvasGroup_Info)
end
function UIRepositoryDecomposePanelV3:OnShowPublicSkillItem(index, item, ignoreTable)
  if self.selectFrameIndex >= 0 then
    self.contentItem[self.selectFrameIndex]:SetSelectShow(false)
  end
  local skillData = self.itemList[index].curItem
  if ignoreTable == nil or not ignoreTable then
    self:OnClickUnstackItem(index, item)
  end
  self.selectFrameIndex = index
  self.ui.mTxt_Title.text = TableData.GetHintById(180024)
  UIRepositoryDecomposePanelV3:SetDetailShow()
  local itemTabData = TableData.GetItemData(skillData.itemId)
  if itemTabData ~= nil then
    self.curDecomposeId = skillData.itemId
    self.ui.mTxt_ItemName.text = itemTabData.name.str
    self.ui.mImg_Rank.color = TableData.GetGlobalGun_Quality_Color2(itemTabData.rank)
    self.ui.mTxt_TalentDetailInfo.text = itemTabData.introduction.str
    local talentKey = tonumber(itemTabData.args[0])
    local talentKeyData = TableData.listTalentKeyDatas:GetDataById(talentKey)
    local skillDisplayData = TableData.listBattleSkillDisplayDatas:GetDataById(talentKeyData.BattleSkillId)
    setactivewithcheck(self.ui.mTxt_TalentSkill, false)
    if skillDisplayData then
      self.ui.mTxt_TalentSkill.text = skillDisplayData.Description.str
      setactivewithcheck(self.ui.mTxt_TalentSkill, true)
    end
    self:ShowPropertyNow(talentKeyData.PropertyId)
  end
  setactive(self.ui.mTrans_TopInfo, itemTabData ~= nil)
  self:RefreshSlider()
  self.curClickTabId = UIRepositoryGlobal.PanelType.PublicSkill
  setactive(self.ui.mTrans_Slider, false)
end
function UIRepositoryDecomposePanelV3:SetDetailShow()
  setactive(self.ui.mTrans_EmptyR, false)
  setactive(self.ui.mTrans_DetailInfo, self.curTabId ~= UIRepositoryGlobal.PanelType.PublicSkill and self.curTabId ~= UIRepositoryGlobal.PanelType.WeaponPanel)
  setactive(self.ui.mTrans_Talent, self.curTabId == UIRepositoryGlobal.PanelType.PublicSkill)
  setactive(self.ui.mTrans_Weapon, self.curTabId == UIRepositoryGlobal.PanelType.WeaponPanel)
  setactive(self.ui.mTrans_WeaponPart, self.curTabId == UIRepositoryGlobal.PanelType.WeaponParts)
  setactive(self.ui.mBtn_Decompose, #self.selectIndexTable > 0)
  setactive(self.ui.mTrans_DecomposeDisable, #self.selectIndexTable == 0)
  setactive(self.ui.mTrans_Num, #self.selectIndexTable > 0)
  setactive(self.ui.mTxt_Total, self:IsUnstackMode())
end
function UIRepositoryDecomposePanelV3:GetAllItemList()
  local itemTabData = TableData.listRepositoryTagDatas:GetDataById(UIRepositoryGlobal.PanelType.ItemPanel)
  if itemTabData ~= nil and self:CanDataSold(itemTabData) then
    self:GetCommonItemList(self.itemList)
  end
  itemTabData = TableData.listRepositoryTagDatas:GetDataById(UIRepositoryGlobal.PanelType.GunCore)
  if itemTabData ~= nil and self:CanDataSold(itemTabData) then
    self:GetGunCoreList(self.itemList, itemTabData)
  end
  itemTabData = TableData.listRepositoryTagDatas:GetDataById(UIRepositoryGlobal.PanelType.WeaponPanel)
  if itemTabData ~= nil and self:CanDataSold(itemTabData) then
    self:GetWeaponList(self.itemList)
  end
  itemTabData = TableData.listRepositoryTagDatas:GetDataById(UIRepositoryGlobal.PanelType.WeaponParts)
  if itemTabData ~= nil and self:CanDataSold(itemTabData) then
    self:GetWeaponPartList(self.itemList, 0)
  end
  itemTabData = TableData.listRepositoryTagDatas:GetDataById(UIRepositoryGlobal.PanelType.PublicSkill)
  if itemTabData ~= nil and self:CanDataSold(itemTabData) then
    self:GetPublicSkillList(self.itemList)
  end
end
function UIRepositoryDecomposePanelV3:GetCommonItemList(list)
  local typeList = TableData.listRepositoryCategoryDatas
  for i = 0, typeList.Count - 1 do
    local itemDataList = NetCmdItemData:GetRepositoryItemListByTypes(typeList[i].item_type)
    for j = 0, itemDataList.Count - 1 do
      local itemData = itemDataList[j]
      local itemTabData = TableData.GetItemData(itemData.item_id)
      if itemTabData ~= nil and 0 < itemTabData.dismantling_list.Count then
        local insertItem = {
          tabId = UIRepositoryGlobal.PanelType.ItemPanel,
          curItem = itemData
        }
        table.insert(list, insertItem)
      end
    end
  end
  return list
end
function UIRepositoryDecomposePanelV3:GetWeaponList(list)
  local weaponList = NetCmdWeaponData:GetWeaponListByType()
  for i, attr in pairs(weaponList) do
    local itemTabData = TableData.GetItemData(attr.stc_id, true)
    if itemTabData ~= nil and itemTabData.dismantling_list.Count > 0 and attr.gun_id == 0 then
      local weaponItem = {
        id = attr.stc_id,
        num = attr.WeaponduplicateNum,
        attr = attr
      }
      local insertItem = {
        tabId = UIRepositoryGlobal.PanelType.WeaponPanel,
        curItem = weaponItem
      }
      table.insert(list, insertItem)
    end
  end
  table.sort(list, function(a, b)
    if a.curItem.attr.IsLocked == b.curItem.attr.IsLocked then
      local valueA = a.curItem.attr.Rank * 1000 + a.curItem.attr.BreakTimes * 100 + a.curItem.attr.Level
      local valueB = b.curItem.attr.Rank * 1000 + b.curItem.attr.BreakTimes * 100 + b.curItem.attr.Level
      if valueA ~= valueB then
        return valueA < valueB
      else
        return a.curItem.attr.stc_id < b.curItem.attr.stc_id
      end
    else
      return b.curItem.attr.IsLocked
    end
  end)
  return list
end
function UIRepositoryDecomposePanelV3:GetGunCoreList(list, itemTabData)
  local typeList = {}
  for i = 0, itemTabData.toptag.Count - 1 do
    local tagId = tonumber(itemTabData.toptag[i])
    local topTagData = TableData.listRepositoryToptagDatas:GetDataById(tagId)
    for _, type in pairs(topTagData.item_type) do
      if topTagData then
        table.insert(typeList, tonumber(type))
      end
    end
  end
  for _, type in pairs(typeList) do
    local itemDataList = NetCmdItemData:GetRepositoryItemListByType(type)
    for i = 0, itemDataList.Count - 1 do
      local itemData = itemDataList[i]
      local count = NetCmdItemData:GetItemCountById(itemData.item_id)
      local itemTabData = TableData.GetItemData(itemData.item_id)
      if itemTabData ~= nil and 0 < itemTabData.dismantling_list.Count and 0 < count then
        local insertItem = {
          tabId = UIRepositoryGlobal.PanelType.GunCore,
          curItem = itemData
        }
        table.insert(list, insertItem)
      end
    end
  end
  table.sort(list, function(a, b)
    local tableA = TableData.GetItemData(a.curItem.item_id)
    local tableB = TableData.GetItemData(b.curItem.item_id)
    return tableA.type * 100 + tableA.rank < tableB.type * 100 + tableB.rank
  end)
  return list
end
function UIRepositoryDecomposePanelV3:GetWeaponPartList(list, partRankType)
  local weaponPartsList = NetCmdWeaponPartsData:GetWeaponPartsListByRank(partRankType)
  for i = 0, weaponPartsList.Count - 1 do
    local itemTabData = TableData.GetItemData(weaponPartsList[i].stcId, true)
    if itemTabData ~= nil and 0 < itemTabData.dismantling_list.Count and weaponPartsList[i].equipWeapon == 0 then
      local insertItem = {
        tabId = UIRepositoryGlobal.PanelType.WeaponParts,
        curItem = weaponPartsList[i]
      }
      table.insert(list, insertItem)
    end
  end
  table.sort(list, function(a, b)
    local tableA = a.curItem.ItemData
    local tableB = b.curItem.ItemData
    if a.curItem.IsLocked ~= b.curItem.IsLocked then
      return a.curItem.IsLocked == false
    elseif a.curItem.rank ~= b.curItem.rank then
      return a.curItem.rank < b.curItem.rank
    elseif a.curItem.level ~= b.curItem.level then
      return a.curItem.level < b.curItem.level
    elseif a.curItem.Quality ~= b.curItem.Quality then
      return a.curItem.Quality < b.curItem.Quality
    else
      return tableA.Id < tableB.Id
    end
  end)
  return list
end
function UIRepositoryDecomposePanelV3:GetPublicSkillList(list)
  local publicSkillList = NetCmdTalentData:GetPublicSkillsItemByType()
  for i = 0, publicSkillList.Count - 1 do
    local publicSkillItem = publicSkillList[i]
    local itemTabData = TableData.GetItemData(publicSkillItem.itemId)
    if itemTabData ~= nil and 0 < itemTabData.dismantling_list.Count then
      local insertItem = {
        tabId = UIRepositoryGlobal.PanelType.PublicSkill,
        curItem = publicSkillItem
      }
      table.insert(list, insertItem)
    end
  end
  return list
end
function UIRepositoryDecomposePanelV3:SetTabFalse()
  for i, tab in pairs(self.leftTabTable) do
    tab:SetItemState(false)
  end
end
function UIRepositoryDecomposePanelV3:GetDropItem()
  self.dropItemDataTable = {}
  self.highRankCount = 0
  for _, value in pairs(self.selectIndexTable) do
    local data = self.itemList[value.Index]
    local num = value.Count
    local itemID
    local multi = 1
    if self.curTabId == UIRepositoryGlobal.PanelType.WeaponPanel then
      itemID = data.curItem.id
    elseif self.curTabId == UIRepositoryGlobal.PanelType.WeaponParts then
      multi = TableData.GlobalSystemData.ModDecomposeLevel
      itemID = data.curItem.stcId
    elseif self.curTabId == UIRepositoryGlobal.PanelType.PublicSkill then
      itemID = data.curItem.itemId
    elseif self.curTabId == UIRepositoryGlobal.PanelType.ItemPanel then
      itemID = data.curItem.item_id
    elseif self.curTabId == UIRepositoryGlobal.PanelType.GunCore then
      itemID = data.curItem.item_id
    end
    local itemTabData = TableData.GetItemData(itemID)
    if itemTabData.rank > 3 then
      self.highRankCount = self.highRankCount + 1
    end
    if self.curTabId == UIRepositoryGlobal.PanelType.WeaponParts then
      for itemId, count in pairs(itemTabData.dismantling_list) do
        if self.dropItemDataTable[itemId] then
          self.dropItemDataTable[itemId] = FormatNum(self.dropItemDataTable[itemId] + self:GetWeaponModReturnItems(data.curItem, count))
        else
          self.dropItemDataTable[itemId] = FormatNum(self:GetWeaponModReturnItems(data.curItem, count))
        end
      end
    else
      for itemId, count in pairs(itemTabData.dismantling_list) do
        if self.dropItemDataTable[itemId] then
          self.dropItemDataTable[itemId] = FormatNum(self.dropItemDataTable[itemId] + math.floor(multi * count) * num)
        else
          self.dropItemDataTable[itemId] = FormatNum(math.floor(multi * count) * num)
        end
      end
    end
    local weaponData = data.curItem.attr
    if weaponData then
      local weaponRecoverData = TableDataBase.listWeaponRecoverDatas:GetDataById(weaponData.Level)
      local weaponCmdData = NetCmdWeaponData:GetWeaponById(weaponData.id)
      if weaponCmdData == nil then
        weaponCmdData = NetCmdWeaponData:GetWeaponByStcId(weaponData.stc_id)
      end
      if weaponRecoverData and weaponCmdData then
        local itemList
        if weaponCmdData.Rank == 1 then
          itemList = weaponRecoverData.item_recover_1
        elseif weaponCmdData.Rank == 2 then
          itemList = weaponRecoverData.item_recover_2
        elseif weaponCmdData.Rank == 3 then
          itemList = weaponRecoverData.item_recover_3
        elseif weaponCmdData.Rank == 4 then
          itemList = weaponRecoverData.item_recover_4
        elseif weaponCmdData.Rank == 5 then
          itemList = weaponRecoverData.item_recover_5
        elseif weaponCmdData.Rank == 6 then
          itemList = weaponRecoverData.item_recover_6
        end
        if itemList then
          for itemId, count in pairs(itemList) do
            if self.dropItemDataTable[itemId] then
              self.dropItemDataTable[itemId] = FormatNum(self.dropItemDataTable[itemId] + count)
            else
              self.dropItemDataTable[itemId] = FormatNum(count)
            end
          end
        end
      end
      local breakData = TableDataBase.listWeaponStarRecoverDatas:GetDataById(weaponCmdData.BreakTimes, true)
      if breakData and 0 < breakData.number then
        if self.dropItemDataTable[weaponData.stc_id] then
          self.dropItemDataTable[weaponData.stc_id] = FormatNum(self.dropItemDataTable[weaponData.stc_id] + breakData.number)
        else
          self.dropItemDataTable[weaponData.stc_id] = FormatNum(breakData.number)
        end
      end
    end
  end
  setactive(self.ui.mBtn_Decompose, 0 < #self.selectIndexTable)
  setactive(self.ui.mTrans_DecomposeDisable, #self.selectIndexTable == 0)
  setactive(self.ui.mTrans_ItemGet, 0 < #self.selectIndexTable)
  local index = 1
  for k, v in pairs(self.dropItemDataTable) do
    local itemView = self.dropItemList[index]
    if itemView == nil then
      itemView = UICommonItem.New()
      itemView:InitCtrl(self.ui.mTrans_ItemGet, false)
      table.insert(self.dropItemList, itemView)
    end
    setactive(itemView.ui.mBtn_Select, true)
    itemView:SetItemData(k, v)
    index = index + 1
  end
  if #self.dropItemList > index - 1 then
    for i = index, #self.dropItemList do
      setactive(self.dropItemList[i].ui.mBtn_Select, false)
    end
  end
end
function UIRepositoryDecomposePanelV3:GetWeaponModReturnItems(curItem, count)
  local modData = TableData.listWeaponModDatas:GetDataById(curItem.stcId)
  local y = modData.exp
  local x = curItem.RealExp
  return count + math.floor((count + math.ceil(y + x * TableData.GlobalSystemData.ModDecomposeLevel)) / 100)
end
function UIRepositoryDecomposePanelV3:InitSlider(max)
  max = math.min(max, 999)
  self.sliderMaxNum = max
  self.ui.mSlider_Decompose.minValue = 0
  self.ui.mSlider_Decompose.maxValue = max
  self.ui.mTxt_SliderMax.text = tostring(max)
  setactive(self.ui.mTrans_Slider, true)
  self:RefreshSlider()
  self.ui.mSlider_Decompose.onValueChanged:AddListener(function(value)
    self:OnSliderChange(value)
  end)
end
function UIRepositoryDecomposePanelV3:QicklySelectWeaponPanel()
  local preCount = #self.selectIndexTable
  local hasItem = false
  for index, item in pairs(self.itemList) do
    if #self.selectIndexTable >= self:GetDisposalLimit() then
      break
    end
    local itemId = item.curItem.id
    local itemTabData = TableData.GetItemData(itemId)
    if not item.curItem.attr.IsLocked and not item.curItem.attr:HasPowerUp() and itemTabData.rank <= self.QuickSortType[self.curTabId][self.partRankType].arg then
      hasItem = true
      local isSelected = false
      for _, value in pairs(self.selectIndexTable) do
        if value.Index == index then
          value.Count = 1
          isSelected = true
          break
        end
      end
      if not isSelected then
        table.insert(self.selectIndexTable, {Index = index, Count = 1})
      end
    end
  end
  if #self.selectIndexTable == 0 then
    UIUtils.PopupHintMessage(1094)
  elseif preCount == #self.selectIndexTable and preCount ~= self:GetDisposalLimit() then
    UIUtils.PopupHintMessage(1107)
  elseif preCount == #self.selectIndexTable and preCount == self:GetDisposalLimit() then
    UIUtils.PopupHintMessage(1106)
  else
    local index = 0
    for _, data in pairs(self.selectIndexTable) do
      if index == 0 or index > data.Index then
        index = data.Index
      end
    end
    UIUtils.PopupPositiveHintMessage(220077)
    self:OnClickWeaponItem(index, self.contentItem[index], true)
    self:UpdateSelectItem()
    self:RefreshSlider()
  end
end
function UIRepositoryDecomposePanelV3:QicklySelectWeaponParts()
  local preCount = #self.selectIndexTable
  local hasItem = false
  for index, item in pairs(self.itemList) do
    if #self.selectIndexTable >= self:GetDisposalLimit() or self:CheckMaxDecomposeProgress() then
      break
    end
    local itemId = item.curItem.stcId
    local itemTabData = TableData.GetItemData(itemId)
    if not item.curItem.IsLocked and not item.curItem:HasPowerUp() and itemTabData.rank <= self.QuickSortType[self.curTabId][self.partRankType].arg then
      local isSelected = false
      hasItem = true
      for _, value in pairs(self.selectIndexTable) do
        if value.Index == index then
          value.Count = 1
          isSelected = true
          break
        end
      end
      if not isSelected then
        table.insert(self.selectIndexTable, {Index = index, Count = 1})
      end
    end
  end
  if #self.selectIndexTable == 0 then
    UIUtils.PopupHintMessage(1094)
  elseif preCount == #self.selectIndexTable and preCount ~= self:GetDisposalLimit() and not self:CheckMaxDecomposeProgress() then
    UIUtils.PopupHintMessage(1107)
  elseif preCount == #self.selectIndexTable and preCount == self:GetDisposalLimit() and self:CheckMaxDecomposeProgress() then
    UIUtils.PopupHintMessage(1106)
  else
    local index = 0
    for _, data in pairs(self.selectIndexTable) do
      if index == 0 or index > data.Index then
        index = data.Index
      end
    end
    UIUtils.PopupPositiveHintMessage(220077)
    self:OnClickWeaponPartItem(index, self.contentItem[index], true)
    self:UpdateSelectItem()
    self:RefreshSlider()
  end
end
function UIRepositoryDecomposePanelV3:QicklySelectGunCore()
  local preCount = #self.selectIndexTable
  local hasItem = false
  for index, item in pairs(self.itemList) do
    local itemId = item.curItem.item_id
    local itemTabData = TableData.GetItemData(itemId)
    local max = math.min(NetCmdItemData:GetItemCountById(itemId), 999)
    if itemTabData.type == self.QuickSortType[self.curTabId][self.partRankType].arg or self.QuickSortType[self.curTabId][self.partRankType].arg == 0 then
      local isSelected = false
      hasItem = true
      for _, value in pairs(self.selectIndexTable) do
        if value.Index == index then
          value.Count = max
          isSelected = true
          break
        end
      end
      if not isSelected then
        table.insert(self.selectIndexTable, {Index = index, Count = max})
      end
    end
  end
  if #self.selectIndexTable == 0 then
    UIUtils.PopupHintMessage(1094)
  elseif preCount == #self.selectIndexTable or not hasItem then
  else
    local index = 0
    for _, data in pairs(self.selectIndexTable) do
      if index == 0 or index > data.Index then
        index = data.Index
      end
    end
    UIUtils.PopupPositiveHintMessage(220077)
    self:OnShowGunCoreItem(index, self.contentItem[index], true)
    self:UpdateSelectItem(index)
    self:RefreshSlider()
  end
end
function UIRepositoryDecomposePanelV3:QicklySelectPublicSkill()
  local preCount = #self.selectIndexTable
  local hasItem = false
  for index, item in pairs(self.itemList) do
    if #self.selectIndexTable >= self:GetDisposalLimit() then
      break
    end
    local itemId = item.curItem.itemId
    local itemTabData = TableData.GetItemData(itemId)
    if itemTabData.rank <= self.QuickSortType[self.curTabId][self.partRankType].arg then
      local isSelected = false
      hasItem = true
      for _, value in pairs(self.selectIndexTable) do
        if value.Index == index then
          value.Count = 1
          isSelected = true
          break
        end
      end
      if not isSelected then
        table.insert(self.selectIndexTable, {Index = index, Count = 1})
      end
    end
  end
  if #self.selectIndexTable == 0 or not hasItem then
    UIUtils.PopupHintMessage(1094)
  elseif preCount == #self.selectIndexTable then
  else
    local index = 0
    for _, data in pairs(self.selectIndexTable) do
      if index == 0 or index > data.Index then
        index = data.Index
      end
    end
    UIUtils.PopupPositiveHintMessage(220077)
    self:OnShowPublicSkillItem(index, self.contentItem[index], true)
    self:UpdateSelectItem()
    self:RefreshSlider()
  end
end
function UIRepositoryDecomposePanelV3:OnClickQuickSelect()
  self.QuickSortType[self.curTabId].func()
end
function UIRepositoryDecomposePanelV3:OnSliderChange(value)
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
  self:RefreshSlider()
end
function UIRepositoryDecomposePanelV3:OnAddSlider()
  if self.curDecomposeNum >= self.sliderMaxNum then
    return
  end
  self:OnSliderChange(self.curDecomposeNum + 1)
end
function UIRepositoryDecomposePanelV3:OnReduceSlider()
  if self.curDecomposeNum <= 0 then
    return
  end
  self:OnSliderChange(self.curDecomposeNum - 1)
end
function UIRepositoryDecomposePanelV3:IsUnstackMode()
  return self.curTabId == UIRepositoryGlobal.PanelType.WeaponPanel or self.curTabId == UIRepositoryGlobal.PanelType.WeaponParts or self.curTabId == UIRepositoryGlobal.PanelType.PublicSkill
end
function UIRepositoryDecomposePanelV3:GetDisposalLimit()
  if self.curTabId == UIRepositoryGlobal.PanelType.WeaponPanel then
    return TableData.GlobalSystemData.WeaponDisposalLimit
  elseif self.curTabId == UIRepositoryGlobal.PanelType.WeaponParts then
    return TableData.GlobalSystemData.WeaponModDisposalLimit
  elseif self.curTabId == UIRepositoryGlobal.PanelType.PublicSkill then
    return TableData.GlobalSystemData.TalentKeyDisposalLimit
  end
  return 0
end
function UIRepositoryDecomposePanelV3:RefreshSlider()
  local nowCount = 0
  if self:IsUnstackMode() then
    self.curDecomposeNum = #self.selectIndexTable
    nowCount = self.curDecomposeNum
    self.sliderMaxNum = self:GetDisposalLimit()
    self.ui.mBtn_SliderReduce.interactable = false
    self.ui.mBtn_SliderAdd.interactable = false
    self:GetDropItem()
  else
    self:GetDropItem()
    self.ui.mBtn_SliderReduce.interactable = self.curDecomposeNum ~= 0
    self.ui.mBtn_SliderAdd.interactable = self.curDecomposeNum ~= self.sliderMaxNum
    if self.selectFrameIndex ~= -1 then
      self.contentItem[self.selectFrameIndex]:SetSelectNum(self.curDecomposeNum)
    end
    self.ui.mSlider_Decompose.value = self.curDecomposeNum
    nowCount = 0
    for _, value in pairs(self.selectIndexTable) do
      local count = value.Count
      nowCount = nowCount + count
    end
  end
  self.ui.mTxt_DecomposeNum.text = string.format("%d", self.curDecomposeNum)
  self.ui.mTxt_Total.text = string.format("/%d", self.sliderMaxNum)
  self.ui.mTxt_Now.text = string.format("%d", nowCount)
  setactive(self.ui.mTrans_Num, 0 < #self.selectIndexTable)
  setactive(self.ui.mTxt_Total, self:IsUnstackMode())
end
function UIRepositoryDecomposePanelV3:OnDecompose()
  local idList = {}
  local countList = {}
  local hasPart = false
  for _, value in pairs(self.selectIndexTable) do
    local data = self.itemList[value.Index]
    local count = value.Count
    local itemID
    if self.curTabId == UIRepositoryGlobal.PanelType.WeaponPanel then
      itemID = data.curItem.attr.id
      if data.curItem.attr:HasPart() then
        hasPart = true
      end
    elseif self.curTabId == UIRepositoryGlobal.PanelType.WeaponParts then
      itemID = data.curItem.id
    elseif self.curTabId == UIRepositoryGlobal.PanelType.PublicSkill then
      itemID = data.curItem.uId
    elseif self.curTabId == UIRepositoryGlobal.PanelType.ItemPanel then
      itemID = data.curItem.item_id
    elseif self.curTabId == UIRepositoryGlobal.PanelType.GunCore then
      itemID = data.curItem.item_id
    end
    table.insert(idList, itemID)
    table.insert(countList, count)
  end
  if self.curClickTabId == UIRepositoryGlobal.PanelType.ItemPanel then
    NetCmdItemData:C2SItemDismantle(idList, countList, function(ret)
      self:OnDecomposeSucc(ret)
    end)
  elseif self.curClickTabId == UIRepositoryGlobal.PanelType.GunCore then
    NetCmdItemData:C2SItemDismantle(idList, countList, function(ret)
      self:OnDecomposeSucc(ret)
    end)
  elseif self.curClickTabId == UIRepositoryGlobal.PanelType.WeaponPanel then
    if self.highRankCount > 0 then
      if NetCmdWeaponData:GetHighRankTips() then
        local todayTipsParam = {}
        todayTipsParam[1] = TableData.GetHintById(1098)
        todayTipsParam[2] = function()
          NetCmdWeaponData:SendGunWeaponDismantle(idList, function(ret)
            if hasPart then
              UIUtils.PopupPositiveHintMessage(1101)
              for k, v in pairs(self.toRemovePartList) do
                if v == true then
                  local modData = NetCmdWeaponPartsData:GetWeaponModById(k)
                  if modData ~= nil then
                    modData.equipWeapon = 0
                  end
                end
              end
              self.toRemovePartList = {}
            end
            self:OnDecomposeSucc(ret)
          end)
        end
        todayTipsParam[3] = ""
        todayTipsParam[4] = nil
        todayTipsParam[5] = false
        todayTipsParam[6] = function()
          NetCmdWeaponData:HideHighRankTips()
        end
        UIManager.OpenUIByParam(UIDef.UIComTodayTipsDialog, todayTipsParam)
      else
        NetCmdWeaponData:SendGunWeaponDismantle(idList, function(ret)
          if hasPart then
            UIUtils.PopupPositiveHintMessage(1101)
            for k, v in pairs(self.toRemovePartList) do
              if v == true then
                local modData = NetCmdWeaponPartsData:GetWeaponModById(k)
                if modData ~= nil then
                  modData.equipWeapon = 0
                end
              end
            end
            self.toRemovePartList = {}
          end
          self:OnDecomposeSucc(ret)
        end)
      end
    else
      NetCmdWeaponData:SendGunWeaponDismantle(idList, function(ret)
        if hasPart then
          UIUtils.PopupPositiveHintMessage(1101)
          for k, v in pairs(self.toRemovePartList) do
            if v == true then
              local modData = NetCmdWeaponPartsData:GetWeaponModById(k)
              if modData ~= nil then
                modData.equipWeapon = 0
              end
            end
          end
          self.toRemovePartList = {}
        end
        self:OnDecomposeSucc(ret)
      end)
    end
  elseif self.curClickTabId == UIRepositoryGlobal.PanelType.WeaponParts then
    DarkNetCmdMakeTableData:SendCS_DarkZoneWishDismantle(idList, function(ret)
      self.playProgressAni = true
      UIManager.OpenUIByParam(UIDef.UIRepositoryDecomposingDialog, function()
        if DarkNetCmdMakeTableData.FullDecompose then
          if ret == ErrorCodeSuc then
            UICommonReceivePanel.OpenWithCheckPopupDownLeftTips(function()
              self:OnClickTab(self.curTabId)
              self:PlayProgressAnimation()
            end)
          end
        else
          self:OnClickTab(self.curTabId)
        end
      end)
    end)
  elseif self.curClickTabId == UIRepositoryGlobal.PanelType.PublicSkill then
    NetCmdTalentData:ReqPublicSkillItemDismantle(idList, function(ret)
      self:OnDecomposeSucc(ret)
    end)
  end
end
function UIRepositoryDecomposePanelV3:OnDecomposeSucc(ret)
  if ret == ErrorCodeSuc then
    UICommonReceivePanel.OpenWithCheckPopupDownLeftTips(function()
      self:OnClickTab(self.curTabId)
    end)
  end
end
function UIRepositoryDecomposePanelV3:InitSortPart()
  if self.comScreenDropdownListItem == nil then
    self.comScreenDropdownListItem = instantiate(self.ui.mTrans_Screen.childItem, self.ui.mTrans_Screen.transform)
  end
  self.ui.mTrans_TypeContent = self.comScreenDropdownListItem.transform:Find("Trans_GrpScreenList")
  local tmpParent = self.ui.mTrans_TypeContent.gameObject:GetComponent(typeof(CS.ScrollListChild))
  self.uiBind = {}
  self.sortList = {}
  self:LuaUIBindTable(self.comScreenDropdownListItem, self.uiBind)
  setactive(self.uiBind.mBtn_TypeScreen, false)
  setactive(self.uiBind.mBtn_Ascend, false)
  UIUtils.GetButtonListener(self.uiBind.mBtn_Sort.gameObject).onClick = function()
    setactive(self.ui.mTrans_TypeContent, true)
  end
  for i = 0, self.ui.mTrans_TypeContent.childCount - 1 do
    gfdestroy(self.ui.mTrans_TypeContent:GetChild(i).gameObject)
  end
  local sortList = instantiate(tmpParent.childItem, self.ui.mTrans_TypeContent)
  local parent = UIUtils.GetRectTransform(sortList, "Content")
  for i = 1, #self.QuickSortType[self.curTabId] do
    local obj = self:InstanceUIPrefab("Character/ChrEquipSuitDropdownItemV2.prefab", parent)
    if obj then
      local sort = {}
      sort.obj = obj
      sort.btnSort = UIUtils.GetButton(obj)
      sort.txtName = UIUtils.GetText(obj, "GrpText/Text_SuitName")
      sort.sortType = i
      sort.hintID = self.QuickSortType[self.curTabId][i].hintId
      sort.sortCfg = UIWeaponGlobal.ReplaceSortCfg[i]
      sort.isAscend = false
      sort.grpset = obj.transform:Find("GrpSel")
      sort.txtName.text = TableData.GetHintById(sort.hintID)
      UIUtils.GetButtonListener(sort.btnSort.gameObject).onClick = function()
        self:OnClickSort(sort.sortType)
        self.curSort = sort
        self:ChangeDropItem()
      end
      self.textcolor = obj.transform:GetComponent(typeof(CS.TextImgColor))
      self.beforecolor = self.textcolor.BeforeSelected
      self.aftercolor = self.textcolor.AfterSelected
      table.insert(self.sortList, sort)
      if i == 1 then
        self.curSort = sort
      end
      if sort ~= self.curSort then
        sort.txtName.color = self.textcolor.BeforeSelected
        setactive(sort.grpset, false)
      else
        sort.txtName.color = self.textcolor.AfterSelected
        setactive(sort.grpset, true)
      end
    end
  end
  UIUtils.GetUIBlockHelper(self.ui.mRoot, self.ui.mTrans_TypeContent, function()
    self:CloseItemSort()
  end)
  self.partRankType = 1
  self.uiBind.mText_SortName.text = TableData.GetHintById(self.QuickSortType[self.curTabId][1].hintId)
  setposition(self.uiBind.mScrollListChild_ScreenList.transform, Vector3(0, 106, 0))
end
function UIRepositoryDecomposePanelV3:OnClickSort(type)
  self.partRankType = type
  self:CloseItemSort()
  self.uiBind.mText_SortName.text = TableData.GetHintById(self.QuickSortType[self.curTabId][type].hintId)
end
function UIRepositoryDecomposePanelV3:ChangeDropItem()
  for i = 1, #self.sortList do
    local sort = self.sortList[i]
    if sort ~= self.curSort then
      sort.txtName.color = self.textcolor.BeforeSelected
      setactive(sort.grpset, false)
    else
      sort.txtName.color = self.textcolor.AfterSelected
      setactive(sort.grpset, true)
    end
  end
end
function UIRepositoryDecomposePanelV3:CloseItemSort()
  setactive(self.ui.mTrans_TypeContent, false)
end
function UIRepositoryDecomposePanelV3:ShowPropertyNow(propertyId)
  for i, attributeScript in ipairs(self.attributeItemTable) do
    attributeScript:SetVisible(false)
  end
  local usedIndex = 1
  for j = DevelopProperty.None.value__ + 1, DevelopProperty.AllEnd.value__ - 1 do
    local propertyType = DevelopProperty.__CastFrom(j)
    if propertyType then
      local propertyValue = PropertyHelper.GetPropertyValueByEnum(propertyId, propertyType)
      if 0 < propertyValue then
        local propertyData = TableData.GetPropertyDataByName(propertyType:ToString())
        if propertyData then
          local name = propertyData.ShowName.str
          local nowValue = propertyValue
          if propertyData.ShowType == 2 then
            nowValue = nowValue / 10
            nowValue = math.floor(nowValue * 10 + 0.5) / 10
            nowValue = nowValue .. "%"
          end
          if usedIndex > #self.attributeItemTable then
            local template = self.ui.mScrollListChild_TalentAttribute.childItem
            local go = UIUtils.InstantiateByTemplate(template, self.ui.mScrollListChild_TalentAttribute.transform)
            local attrBar = self:NewAttrBar(go)
            table.insert(self.attributeItemTable, attrBar)
          end
          local attributeScript = self.attributeItemTable[usedIndex]
          attributeScript:Show(name, nowValue)
          attributeScript:SetVisible(true)
          usedIndex = usedIndex + 1
        end
      end
    end
  end
  self:setLastAttrLineInvisible()
end
function UIRepositoryDecomposePanelV3:setLastAttrLineInvisible()
  local count = #self.attributeItemTable
  for i, attributeScript in ipairs(self.attributeItemTable) do
    attributeScript:SetLineVisible(i ~= count)
  end
end
function UIRepositoryDecomposePanelV3:NewAttrBar(go)
  local attrBar = {}
  function attrBar:BindGo(root)
    self.root = root
    self.ui = UIUtils.GetUIBindTable(root)
  end
  function attrBar:Show(name, value)
    self.ui.mText_Num.text = value
    self.ui.mText_Name.text = name
  end
  function attrBar:SetLineVisible(visible)
    setactive(self.ui.mTrans_Line, visible)
  end
  function attrBar:SetVisible(visible)
    setactive(self.root, visible)
  end
  function attrBar:OnRelease(isDestroy)
    if isDestroy then
      gfdestroy(self.root)
    end
  end
  attrBar:BindGo(go)
  return attrBar
end
function UIRepositoryDecomposePanelV3:OnShowStart()
  if self.virtualList ~= nil then
    self.virtualList.enabled = true
  end
end
function UIRepositoryDecomposePanelV3:OnReturnClick(gameObj)
  self:Close()
end
function UIRepositoryDecomposePanelV3:Close()
  UIManager.CloseUI(UIDef.UIRepositoryDecomposePanelV3)
end
function UIRepositoryDecomposePanelV3:OnHide()
  if self.virtualList ~= nil then
    self.virtualList.enabled = false
  end
  self.isHide = true
end
function UIRepositoryDecomposePanelV3:OnClose()
  for _, item in pairs(self.modSuitItemList) do
    gfdestroy(item:GetRoot())
  end
  for _, item in pairs(self.attributeList) do
    gfdestroy(item:GetRoot())
  end
  for _, item in pairs(self.subPropList) do
    gfdestroy(item:GetRoot())
  end
  for _, item in pairs(self.dropItemList) do
    gfdestroy(item:GetRoot())
  end
  for i = 1, #self.makeUpAttributeList do
    if self.makeUpAttributeList[i] then
      gfdestroy(self.makeUpAttributeList[i])
    end
  end
  for i = 1, #self.proficAttributeList do
    if self.proficAttributeList[i] then
      gfdestroy(self.proficAttributeList[i])
    end
  end
  if self.comScreenDropdownListItem ~= nil then
    gfdestroy(self.comScreenDropdownListItem.gameObject)
    self.comScreenDropdownListItem = nil
  end
  self:ReleaseCtrlTable(self.attributeItemTable, true)
  self.attributeItemTable = nil
  self.modSuitItemList = nil
  self.attributeList = nil
  self.subPropList = nil
  self.polarityList = nil
  self.partRankType = 1
  if self.suitItem ~= nil then
    gfdestroy(self.suitItem:GetRoot())
  end
  self.instanceTab = nil
  self.suitItem = nil
  self.lockItem = nil
  self.QuickSortType = nil
end
function UIRepositoryDecomposePanelV3:OnRelease()
  self:ReleaseCtrlTable(self.leftTabTable, true)
end
function UIRepositoryDecomposePanelV3:OnTop()
  if self.playProgressAni and not DarkNetCmdMakeTableData.FullDecompose then
    self:PlayProgressAnimation()
  end
end
function UIRepositoryDecomposePanelV3:UpdateDecomposeSortContent()
  self:GetWeaponOfferExpDic()
  self:RefreshDecomposeProgress()
end
function UIRepositoryDecomposePanelV3:GetCurDecomposeExp()
  if not self.weaponPartExpList then
    return 0
  end
  local value = 0
  for i = 1, #self.selectIndexTable do
    local id = self.itemList[self.selectIndexTable[i].Index].curItem.id
    if self.weaponPartExpList[id] then
      value = value + self.weaponPartExpList[id]
    end
  end
  return value
end
function UIRepositoryDecomposePanelV3:GetWeaponOfferExpDic()
  if not self.weaponPartList then
    return nil
  end
  self.weaponPartExpList = {}
  for _, item in pairs(self.itemList) do
    self.weaponPartExpList[item.curItem.id] = item.curItem:GetWeaponOfferExp()
  end
end
function UIRepositoryDecomposePanelV3:RefreshDecomposeProgress()
  setactive(self.ui.mTrans_Num.gameObject, #self.selectIndexTable > 0)
  setactive(self.ui.mBtn_Decompose.gameObject, #self.selectIndexTable > 0)
  setactive(self.ui.mTrans_DecomposeDisable.gameObject, #self.selectIndexTable <= 0)
  local curValue = self:GetCurDecomposeExp() + DarkNetCmdMakeTableData.CurExp
  local percent = curValue * 100 / self.maxDecomposeValue
  if percent < 1 and 0 < percent then
    percent = math.ceil(percent)
  else
    percent = math.floor(percent)
  end
  self.ui.mText_DecomposeProgress.text = percent .. "%"
  if 100 <= percent then
    self.ui.mAnimator_Icon:SetBool("Bool", true)
  else
    self.ui.mAnimator_Icon:SetBool("Bool", false)
  end
  if not self.playProgressAni then
    self.ui.mImg_CurProgress.fillAmount = DarkNetCmdMakeTableData.CurExp / self.maxDecomposeValue
    self.ui.mImg_AddProgress.fillAmount = curValue / self.maxDecomposeValue
  end
end
function UIRepositoryDecomposePanelV3:CheckMaxDecomposeProgress()
  return self:GetCurDecomposeExp() + DarkNetCmdMakeTableData.CurExp >= self.maxDecomposeValue
end
function UIRepositoryDecomposePanelV3:PlayProgressAnimation()
  self.ui.mImg_AddProgress.fillAmount = 0
  if DarkNetCmdMakeTableData.FullDecompose then
    self.ui.mImg_CurProgress.fillAmount = 0
  end
  if self.listTween then
    LuaDOTweenUtils.Kill(self.listTween, false)
  end
  local getter = function(tempSelf)
    return tempSelf.ui.mImg_CurProgress.fillAmount
  end
  local setter = function(tempSelf, value)
    tempSelf.ui.mImg_CurProgress.fillAmount = value
  end
  local curValue = DarkNetCmdMakeTableData.CurExp
  local percent = curValue / self.maxDecomposeValue
  self.listTween = LuaDOTweenUtils.ToOfFloat(self, getter, setter, percent, 1, function()
    self.playProgressAni = false
  end)
end
