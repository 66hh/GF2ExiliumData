require("UI.UIBaseCtrl")
UIWeaponPartEnhanceContent = class("UIWeaponPartEnhanceContent", UIBaseCtrl)
UIWeaponPartEnhanceContent.__index = UIWeaponPartEnhanceContent
function UIWeaponPartEnhanceContent:ctor(weaponPartPanel)
  self.weaponPartPanel = weaponPartPanel
  self.partData = nil
  self.mainProp = nil
  self.expList = nil
  self.listContent = nil
  self.subPropList = {}
  self.lockList = {}
  self.ui = {}
  self.curItem = nil
  self.itemBrief = nil
  self.materialsList = {}
  self.selectMaterial = {}
  self.curType = nil
  self.curFiltrate = nil
  self.isLevelUpMode = false
  self.isCoinEnough = false
  self.itemId = TableData.GlobalSystemData.WeaponModLevelUpItem
end
function UIWeaponPartEnhanceContent:OnClose()
  self:CloseEnhance(false)
  if self.listContent then
    self.listContent:OnClose()
  end
  self.mainProp:OnRelease(true)
  self:ReleaseCtrlTable(self.subPropList, true)
  self.listContent = nil
end
function UIWeaponPartEnhanceContent:__InitCtrl()
  self.mainProp = UICommonPropertyItem.New()
  self.mainProp:InitCtrl(self.ui.mTrans_GrpAttribute, true)
  for i = 1, 3 do
    local item = {}
    local obj = UIUtils.GetRectTransform(self.ui.mTrans_GrpLock, "GrpLock" .. i)
    item.obj = obj
    item.txtLv = UIUtils.GetText(obj, "GrpContent/GrpList/Text_Name")
    item.txtInfo = UIUtils.GetText(obj, "GrpText/Text_Info")
    table.insert(self.lockList, item)
  end
end
function UIWeaponPartEnhanceContent:InitCtrl(obj, listObj)
  if self.listContent == nil then
    self.listContent = UIWeaponPartListContent.New()
    self.listContent:InitCtrl(listObj)
  end
  self.sortContent = UIWeaponPartSortItem.New()
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self:__InitCtrl()
  UIUtils.GetButtonListener(self.ui.mBtn_LevelUp.gameObject).onClick = function()
    self:OnClickLevelUp()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Add.gameObject).onClick = function()
    self:OnClickAddItem()
  end
  UIUtils.GetButtonListener(self.listContent.ui.mBtn_Back.gameObject).onClick = function()
    self:CloseEnhance()
  end
  UIUtils.GetButtonListener(self.listContent.ui.mBtn_Select.gameObject).onClick = function()
    self:AutoSelect()
  end
  self.pointer = UIUtils.GetPointerClickHelper(self.listContent.ui.mTrans_ItemBrief.gameObject, function()
    self:CloseItemBrief()
  end, self.listContent.ui.mTrans_ItemBrief.gameObject)
  self:InitVirtualList()
  self:InitTypeContent()
  self:InitFiltrateContent()
end
function UIWeaponPartEnhanceContent:InitFiltrateContent()
  for i, filtrate in ipairs(self.listContent.filtrateList) do
    filtrate.setId = i
    filtrate.hintID = 102232 + i
    filtrate.filtrateCfg = UIWeaponGlobal.PartMaterialFiltrateCfg[i]
    filtrate.mText_Name.text = TableData.GetHintById(filtrate.hintID)
    if filtrate.filtrateCfg == UIWeaponGlobal.PartMaterialFiltrateCfg[1] then
      self.curFiltrate = filtrate
    end
    UIUtils.GetButtonListener(filtrate.mBtn_Suit.gameObject).onClick = function()
      self:OnClickFiltrate(filtrate.setId)
    end
    if self.listContent.filtrateList[i] ~= self.curFiltrate then
      self.listContent.filtrateList[i]:SetSelect(false)
    else
      self.listContent.filtrateList[i]:SetSelect(true)
    end
  end
  self.listContent.filtrateContent:SetFiltrateData(self.curFiltrate)
end
function UIWeaponPartEnhanceContent:InitTypeContent()
  for i, type in ipairs(self.listContent.weaponPartDropList) do
    UIUtils.GetButtonListener(type.mBtn_Suit.gameObject).onClick = function()
      self:OnClickType(i)
    end
    if self.listContent.weaponPartDropList[i].setId == 0 then
      self.curType = type
    end
    if self.listContent.weaponPartDropList[i] ~= self.curType then
      self.listContent.weaponPartDropList[i]:SetSelect(false)
    else
      self.listContent.weaponPartDropList[i]:SetSelect(true)
    end
    setactive(self.listContent.weaponPartDropList[i].mUIRoot, true)
  end
  self.listContent.ui.mText_TypeName.text = self.curType:GetTypeName()
end
function UIWeaponPartEnhanceContent:InitVirtualList()
  function self.listContent.ui.mVirtualList.itemProvider()
    local item = self:MaterialItemProvider()
    return item
  end
  function self.listContent.ui.mVirtualList.itemRenderer(index, rendererData)
    self:MaterialItemRenderer(index, rendererData)
  end
end
function UIWeaponPartEnhanceContent:MaterialItemProvider()
  local itemView = UICommonItem.New()
  itemView:InitCtrl()
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIWeaponPartEnhanceContent:MaterialItemRenderer(index, rendererData)
  local itemData = self.materialsList[index + 1]
  local item = rendererData.data
  item:SetMaterialPartData(itemData, not self:CheckCanSelectWeapon(itemData))
  item:SetLongPressEvent(function(go, data)
    self:BeginLongPress(item)
  end)
  item:SetMinusLongPressEvent(function(go, data)
    self:BeginMinusLongPress(item)
  end)
  UIUtils.GetButtonListener(item.ui.mBtn_Select.gameObject).onClick = function()
    self:OnClickItem(item)
  end
  UIUtils.GetButtonListener(item.ui.mBtn_Reduce.gameObject).onClick = function()
    self:OnClickReduce(item)
  end
end
function UIWeaponPartEnhanceContent:OnClickReduce(item)
  item:OnReduce()
  self:UpdateSelectList(item.mData)
end
function UIWeaponPartEnhanceContent:OnClickFiltrate(type)
  if type then
    if self.curFiltrate and self.curFiltrate.setId ~= type then
      self.curFiltrate:SetSelect(false)
    end
    self.curFiltrate = self.listContent.filtrateList[type]
    self.curFiltrate:SetSelect(true)
    self.listContent.filtrateContent:SetFiltrateData(self.curFiltrate)
    self.listContent:CloseItemSort()
  end
end
function UIWeaponPartEnhanceContent:OnClickType(type)
  if type then
    if self.curType and self.curType.setId ~= type then
      self.curType:SetSelect(false)
    end
    self.curType = self.listContent.weaponPartDropList[type]
    self.curType:SetSelect(true)
    self.listContent.ui.mText_TypeName.text = self.curType:GetTypeName()
    self:RemoveFiltratePart()
    self:UpdateEnhanceList()
    self.listContent.ui.mVirtualList.verticalNormalizedPosition = 1
    self.listContent:CloseItemType()
  end
end
function UIWeaponPartEnhanceContent:SetData(partData)
  local typeData = TableData.listWeaponModTypeDatas:GetDataById(partData.type)
  self.partData = partData
  self.expList = partData.expList
  self.ui.mText_Name.text = partData.name
  self.ui.mText_Type.text = typeData.name.str
  self:UpdatePanel()
end
function UIWeaponPartEnhanceContent:UpdatePanel()
  self.targetLevel = self.partData.level
  self.maxLevel = self.partData.maxLevel
  self.selectMaterial = {}
  self.totalExp = self:GetPartTotalExpByLevel(self.partData.level) + self.partData.exp
  if self.partData.level < self.partData.maxLevel then
    local nextLv = self.partData.level + 1
    local exp = self:GetPartExpByLevel(nextLv)
    self.nextLevelExp = exp
  else
    self.nextLevelExp = 0
  end
  self:UpdateIsMaxLevel()
  self:UpdateSelectListView()
  self:UpdateMainProp()
  self:UpdateSubProp()
  self:UpdateLockInfo()
end
function UIWeaponPartEnhanceContent:UpdatePartExp(exp)
  local maxExp = 0
  local curExp = 0
  local sliderBeforeValue = 0
  local sliderAfterValue = 0
  local curExpData = self:GetPartTotalExpByLevel(self.partData.level)
  local targetExpData = self:GetPartTotalExpByLevel(self.targetLevel)
  if self.partData.exp + exp >= self.nextLevelExp then
    local nextLevel = self.targetLevel >= self.maxLevel and self.maxLevel or self.targetLevel + 1
    maxExp = self:GetPartExpByLevel(nextLevel)
    if self.targetLevel >= self.maxLevel then
      curExp = maxExp
    else
      curExp = curExpData + self.partData.exp + exp - targetExpData
    end
    sliderBeforeValue = self.partData.level >= self.maxLevel and 1 or 0
    sliderAfterValue = curExp / maxExp
  else
    maxExp = self.nextLevelExp
    if self.targetLevel >= self.maxLevel then
      curExp = maxExp
      sliderBeforeValue = 1
      sliderAfterValue = 1
    else
      curExp = self.partData.exp + exp
      sliderBeforeValue = self.partData.exp / self.nextLevelExp
      sliderAfterValue = (self.partData.exp + exp) / self.nextLevelExp
    end
  end
  self.ui.mText_Exp.text = string_format("{0}/{1}", curExp, maxExp)
  self.ui.mImg_ProgressBarAfter.fillAmount = sliderAfterValue
  self.ui.mImg_ProgressBarBefore.fillAmount = sliderBeforeValue
  self.ui.mText_Add.text = "+" .. exp
  self.ui.mText_LevelNow.text = self.targetLevel
  self.ui.mText_LeveMax.text = "/" .. self.maxLevel
  setactive(self.ui.mTrans_AddExp, 0 < exp)
  self.ui.mBtn_LevelUp.interactable = 0 < exp
  self.canLevelUp = 0 < exp
  if self.partData.level ~= self.targetLevel then
    self.mainProp:SetValueUp(self.partData.mainPropValue + self.partData:GetTargetMainValue(self.targetLevel))
  else
    self:UpdateMainProp()
    setactive(self.mainProp.mTrans_ValueChange, false)
  end
end
function UIWeaponPartEnhanceContent:UpdateMainProp()
  self.mainProp:SetDataByName(self.partData.mainProp, self.partData.mainPropValue, true, false, false)
end
function UIWeaponPartEnhanceContent:UpdateSubProp()
  for i, item in ipairs(self.subPropList) do
    item:SetData(nil)
  end
  local dataList = self.partData.subPropList
  for i = 0, dataList.Count - 1 do
    local data = dataList[i]
    local item = self.subPropList[i + 1]
    if item == nil then
      item = UICommonPropertyItem.New()
      item:InitCtrl(self.ui.mTrans_GrpAttributeDown, true)
      table.insert(self.subPropList, item)
    end
    local rankList = self:GetSubPropRankList(data)
    item:SetData(data.propData, data.value, true, false, false, true)
    item:SetPropQuality(rankList)
  end
end
function UIWeaponPartEnhanceContent:GetSubPropRankList(data)
  local rankList = {}
  local affixData = TableData.listModAffixDatas:GetDataById(data.affixId)
  table.insert(rankList, affixData.rank)
  for i = 0, data.levelData.Count - 1 do
    local lvUpData = TableData.listPropertyLevelUpGroupDatas:GetDataById(data.levelData[i])
    table.insert(rankList, lvUpData.rank)
  end
  return rankList
end
function UIWeaponPartEnhanceContent:UpdateLockInfo()
  for i, item in ipairs(self.lockList) do
    setactive(item.obj, false)
  end
  for i = 0, self.partData.lockLevel.Count - 1 do
    if self.partData.level < self.partData.lockLevel[i] then
      local propList = CSList2LuaTable(self.partData:GetSubPropGroup(i), function(value)
        local propData = TableData.GetPropertyDataByName(value)
        return propData.show_name.str
      end)
      local item = self.lockList[i + 1]
      item.txtLv.text = string_format(TableData.GetHintById(102244), self.partData.lockLevel[i])
      item.txtInfo.text = string_format(TableData.GetHintById(102231), table.concat(propList, ","))
      setactive(item.obj, true)
    end
  end
end
function UIWeaponPartEnhanceContent:GetPartTotalExpByLevel(level)
  level = math.min(level, self.partData.maxLevel)
  local expId = self.expList[level - 1]
  local maxExp = TableData.listWeaponModExpDatas:GetDataById(expId)
  return maxExp.exp_total
end
function UIWeaponPartEnhanceContent:GetPartExpByLevel(level)
  level = math.min(level, self.partData.maxLevel)
  local expId = self.expList[level - 1]
  local maxExp = TableData.listWeaponModExpDatas:GetDataById(expId)
  return maxExp.exp
end
function UIWeaponPartEnhanceContent:OnClickAddItem()
  if self.isLevelUpMode then
    return
  end
  self.isLevelUpMode = true
  self.ui.mBtn_Add.interactable = false
  self:UpdateEnhanceList()
  setactive(self.listContent.mUIRoot, true)
  setactive(self.weaponPartPanel.mView.mTrans_TabList.gameObject, false)
end
function UIWeaponPartEnhanceContent:UpdateEnhanceList()
  local list = NetCmdWeaponPartsData:GetEnhanceWeaponPartList(self.partData.id, self.curType.setId)
  self.materialsList = self:UpdateMaterialList(list)
  local sortType = UIWeaponGlobal.PartMaterialSortCfg
  self:UpdateListBySort(sortType)
  self:ResetMaterialIndex(self.materialsList)
  setactive(self.listContent.ui.mTrans_GrpEmpty, #self.materialsList <= 0)
  self.weaponPartPanel:RefreshPanel()
end
function UIWeaponPartEnhanceContent:UpdateListBySort(sortType)
  local sortFunc = self.sortContent:GetSortFunc(1, sortType, true)
  table.sort(self.materialsList, sortFunc)
  self.listContent.ui.mVirtualList.numItems = #self.materialsList
  self.listContent.ui.mVirtualList:Refresh()
end
function UIWeaponPartEnhanceContent:UpdateMaterialList(list)
  if list then
    self.itemList = {}
    self.partList = {}
    local itemList = {}
    local id = self.itemId
    local data = UIWeaponGlobal:GetWeaponModSimpleData(id, UIWeaponGlobal.MaterialType.Item)
    if data then
      local item, i = self:IsInSelectList(data)
      if item then
        data.selectCount = item.selectCount
        self.selectMaterial[i] = data
      end
      table.insert(itemList, data)
      table.insert(self.itemList, data)
    end
    for i = 0, list.Count - 1 do
      local data = UIWeaponGlobal:GetWeaponModSimpleData(list[i], UIWeaponGlobal.MaterialType.Weapon)
      if data then
        local item, i = self:IsInSelectList(data)
        if item then
          data.selectCount = item.selectCount
          self.selectMaterial[i] = data
        end
        table.insert(itemList, data)
        table.insert(self.partList, data)
      end
    end
    return itemList
  end
end
function UIWeaponPartEnhanceContent:IsInSelectList(itemData)
  for i, item in ipairs(self.selectMaterial) do
    if itemData.type == item.type and itemData.id == item.id then
      return item, i
    end
  end
  return nil
end
function UIWeaponPartEnhanceContent:ResetMaterialIndex(list)
  if list then
    for i, item in ipairs(list) do
      item.index = i - 1
    end
  end
  self.ui.mTrans_SelectPartNum.text = 0 .. "/" .. UIWeaponGlobal.MaxMaterialCount
end
function UIWeaponPartEnhanceContent:CloseEnhance(boolean)
  boolean = boolean == nil and true or boolean
  if boolean and self.listContent.ui.mListAniTime and self.listContent.ui.mListAnimator then
    self.listContent.ui.mListAnimator:SetTrigger("Fadeout")
    self:DelayCall(self.listContent.ui.mListAniTime.m_FadeOutTime, function()
      self.isLevelUpMode = false
      self.ui.mBtn_Add.interactable = true
      self.ui.mBtn_LevelUp.interactable = false
      self:ResetTypeFiltareList()
      self:UpdatePanel()
      setactive(self.listContent.mUIRoot, false)
      setactive(self.weaponPartPanel.mView.mTrans_TabList.gameObject, true)
    end)
  else
    self.isLevelUpMode = false
    self.ui.mBtn_Add.interactable = true
    self.ui.mBtn_LevelUp.interactable = false
    self:ResetTypeFiltareList()
    self:UpdatePanel()
    setactive(self.listContent.mUIRoot, false)
    setactive(self.weaponPartPanel.mView.mTrans_TabList.gameObject, true)
  end
end
function UIWeaponPartEnhanceContent:ResetTypeFiltareList()
  if self.listContent == nil then
    return
  end
  self.curType = self.listContent.weaponPartDropList[1]
  self.curFiltrate = self.listContent.filtrateList[1]
  for i, type in pairs(self.listContent.weaponPartDropList) do
    if self.listContent.weaponPartDropList[i] ~= self.curType then
      self.listContent.weaponPartDropList[i]:SetSelect(false)
    else
      self.listContent.weaponPartDropList[i]:SetSelect(true)
    end
  end
  self.listContent.ui.mText_TypeName.text = self.curType:GetTypeName()
  for i, filtrate in ipairs(self.listContent.filtrateList) do
    if self.listContent.filtrateList[i] ~= self.curFiltrate then
      self.listContent.filtrateList[i]:SetSelect(false)
    else
      self.listContent.filtrateList[i]:SetSelect(true)
    end
  end
  self.listContent.filtrateContent:SetFiltrateData(self.curFiltrate)
end
function UIWeaponPartEnhanceContent:CheckCanSelectWeapon(data)
  if self:GetSelectMaterialCount() >= UIWeaponGlobal.MaxMaterialCount then
    return false
  elseif self.targetLevel >= self.partData.maxLevel then
    return false
  end
  return true
end
function UIWeaponPartEnhanceContent:GetSelectMaterialCount()
  local count = 0
  for _, item in ipairs(self.selectMaterial) do
    if item.type == UIWeaponGlobal.MaterialType.Weapon then
      count = count + item.selectCount
    end
  end
  return count
end
function UIWeaponPartEnhanceContent:OnClickItem(item)
  if item.mData.type == UIWeaponGlobal.MaterialType.Weapon and self:GetSelectMaterialCount() >= UIWeaponGlobal.MaxMaterialCount then
    if self:IsInSelectList(item.mData) == nil then
      UIUtils.PopupHintMessage(40010)
      return
    elseif item:IsRemoveWeapon() then
      item:SetMaterialSelect()
      self:UpdateSelectList(item.mData)
      self:SetCurItem(item)
      return
    else
      return
    end
  end
  if self.targetLevel < self.maxLevel then
    if item:IsLocked() then
      UIUtils.PopupHintMessage(40037)
      self:UpdateItemBrief(item.mData.id, item.mData.type)
      self:SetCurItem(item)
      return
    end
    item:SetMaterialSelect()
  elseif item:IsRemoveWeapon() then
    item:SetMaterialSelect()
  else
    UIUtils.PopupHintMessage(30020)
    return
  end
  if item.mData.selectCount > 0 then
    self:UpdateItemBrief(item.mData.id, item.mData.type)
  else
    self:CloseItemBrief()
  end
  self:SetCurItem(item)
  self:UpdateSelectList(item.mData)
end
function UIWeaponPartEnhanceContent:UpdateItemBrief(id, type)
  self.pointer.isInSelf = true
  local lockCallback = function(tmpId, isLock)
    self:UpdateWeaponPartLock(tmpId, isLock)
  end
  if type == UIWeaponGlobal.MaterialType.Item then
    ComPropsDetailsHelper:InitItemData(self.listContent.ui.mTrans_ItemBrief.transform, id, lockCallback)
  elseif type == UIWeaponGlobal.MaterialType.Weapon then
    ComPropsDetailsHelper:InitWeaponPartsData(self.listContent.ui.mTrans_ItemBrief.transform, id, lockCallback, false)
  end
end
function UIWeaponPartEnhanceContent:UpdateWeaponPartLock(id, isLock)
  for _, item in ipairs(self.materialsList) do
    if item.type == UIWeaponGlobal.MaterialType.Weapon and item.id == id then
      item.isLock = isLock
      if isLock then
        self:InvertSelectionItem(item)
        return
      end
      break
    end
  end
  self.listContent.ui.mVirtualList:Refresh()
end
function UIWeaponPartEnhanceContent:UpdateSelectList(itemData)
  if itemData then
    local index = 0
    for i, item in ipairs(self.selectMaterial) do
      if itemData.type == item.type and itemData.id == item.id then
        index = i
        break
      end
    end
    if 0 < index then
      local data = self.selectMaterial[index]
      if 0 >= data.selectCount then
        table.remove(self.selectMaterial, index)
      end
    else
      table.insert(self.selectMaterial, itemData)
    end
    self:UpdateSelectListView()
  end
end
function UIWeaponPartEnhanceContent:UpdateSelectListView()
  local addExp = 0
  local count = 1
  local item
  self.ui.mTrans_SelectPartNum.text = #self.selectMaterial .. "/" .. UIWeaponGlobal.MaxMaterialCount
  for i = 1, #self.selectMaterial do
    local data = self.selectMaterial[i]
    addExp = addExp + data.offerExp * data.selectCount
  end
  self:UpdateLevelUpInfo(addExp)
end
function UIWeaponPartEnhanceContent:UpdateLevelUpInfo(exp)
  self.totalExp = self.partData.exp + exp + self:GetPartTotalExpByLevel(self.partData.level)
  self.targetLevel = math.min(self:CalculateLevel(self.totalExp), self.maxLevel)
  local costCoin = self.partData:GetChipCash(self.totalExp)
  self.isCoinEnough = costCoin <= GlobalData.cash
  self.ui.mText_CostCoin.text = costCoin
  if not self.isCoinEnough then
    self.ui.mText_CostCoin.color = ColorUtils.RedColor
  else
    self.ui.mText_CostCoin.color = ColorUtils.WhiteColor
  end
  self:UpdatePartExp(exp)
end
function UIWeaponPartEnhanceContent:CalculateLevel(exp)
  for i = 1, self.expList.Count - 1 do
    local needData = TableData.listWeaponModExpDatas:GetDataById(self.expList[i])
    local lastData = TableData.listWeaponModExpDatas:GetDataById(self.expList[i - 1])
    local needExp = needData.exp_total
    local lastExp = lastData.exp_total
    if exp >= lastExp and exp < needExp then
      return lastData.level
    end
  end
  local expData = TableData.listWeaponModExpDatas:GetDataById(self.expList[self.expList.Count - 1])
  return expData.level
end
function UIWeaponPartEnhanceContent:InvertSelectionItem(item)
  item.selectCount = item.selectCount - 1
  self:UpdateSelectList(item)
  self.listContent.ui.mVirtualList:Refresh()
end
function UIWeaponPartEnhanceContent:SetCurItem(item)
  if self.curItem then
    self.curItem.isSelect = false
    self.listContent.ui.mVirtualList:RefreshItem(self.curItem.index)
  end
  if item then
    item.mData.isSelect = true
    item:EnableSelectFrame(true)
    self.curItem = item.mData
  else
    self.curItem = nil
  end
end
function UIWeaponPartEnhanceContent:CloseItemBrief()
  ComPropsDetailsHelper:Close()
end
function UIWeaponPartEnhanceContent:AutoSelect()
  self:ResetMaterialList()
  local matList = {}
  local maxLevelExp = self:GetPartTotalExpByLevel(self.maxLevel)
  local needExp = maxLevelExp - self.totalExp
  for i, v in ipairs(self.partList) do
    if self:CanBeAutoSelect(v, self.curFiltrate.filtrateCfg) then
      table.insert(matList, v)
    end
  end
  table.sort(matList, function(a, b)
    if a.rank == b.rank then
      if a.fatherType == b.fatherType then
        if a.partType == b.partType then
          if a.suitId == b.suitId then
            return a.id < b.id
          else
            return a.suitId < b.suitId
          end
        else
          return a.partType < b.partType
        end
      else
        return a.fatherType < b.fatherType
      end
    else
      return a.rank < b.rank
    end
  end)
  for _, item in ipairs(matList) do
    if self:GetSelectMaterialCount() >= UIWeaponGlobal.MaxMaterialCount or needExp <= 0 then
      break
    end
    if 0 >= item.selectCount then
      item.selectCount = 1
      table.insert(self.selectMaterial, item)
      needExp = needExp - item.offerExp
    end
  end
  self.listContent.ui.mVirtualList:Refresh()
  self:UpdateSelectListView()
  if 0 >= #self.selectMaterial then
    UIUtils.PopupHintMessage(102238)
  end
  if 0 < #self.selectMaterial then
    UIUtils.PopupPositiveHintMessage(40067)
  end
end
function UIWeaponPartEnhanceContent:ResetMaterialList()
  for i, item in ipairs(self.selectMaterial) do
    item.selectCount = 0
  end
  self.selectMaterial = {}
  self:UpdateSelectListView()
  self.listContent.ui.mVirtualList:Refresh()
end
function UIWeaponPartEnhanceContent:CanBeAutoSelect(item, filter)
  if item.type == UIWeaponGlobal.MaterialType.Weapon and item.level <= 1 and item.exp <= 0 and not item.isLock and filter >= item.rank then
    return true
  end
  return false
end
function UIWeaponPartEnhanceContent:RemoveFiltratePart()
  local list = {}
  for i, item in ipairs(self.selectMaterial) do
    table.insert(list, item)
  end
  for i, item in ipairs(list) do
    if item.type == UIWeaponGlobal.MaterialType.Weapon and self.curType.setId ~= 0 and self.curType.setId ~= item.type then
      self:InvertSelectionItem(item)
    end
  end
end
function UIWeaponPartEnhanceContent:OnClickLevelUp()
  if not self.isCoinEnough then
    UIUtils.PopupHintMessage(40050)
    return
  end
  if not self.canLevelUp then
    UIUtils.PopupHintMessage(40019)
    return
  end
  local itemList, partList = self:GetMaterialList()
  self.recordLv = self.partData.level
  self.recordExp = self.partData.exp
  self.ui.mBtn_LevelUp.interactable = false
  NetCmdWeaponPartsData:ReqWeaponPartLvUp(self.partData.id, partList, itemList, function(ret)
    self:LevelUpCallback(ret)
    self.ui.mBtn_LevelUp.interactable = true
  end)
end
function UIWeaponPartEnhanceContent:LevelUpCallback(ret)
  if ret == ErrorCodeSuc then
    gfdebug("强化配件成功")
    if self.recordLv < self.targetLevel then
      local tempPropList = deep_copy(self.subPropList)
      local tempMain = deep_copy(self.mainProp)
      self.partData = NetCmdWeaponPartsData:GetWeaponModById(self.partData.id)
      self:UpdatePanel()
      self:UpdateEnhanceList()
      self:OpenLevelUpPanel(tempMain, tempPropList)
    else
      setactive(self.weaponPartPanel.mView.mTrans_Mask, true)
      local start = self.partData.level + self.recordExp / self.nextLevelExp
      local endLv = self.partData.level + self.partData.exp / self.nextLevelExp
      CS.ProgressBarAnimationHelper.Play(self.ui.mImg_ProgressBarBefore, start, endLv, 0.5, nil, function()
        self.partData = NetCmdWeaponPartsData:GetWeaponModById(self.partData.id)
        self:UpdatePanel()
        self:UpdateEnhanceList()
        setactive(self.weaponPartPanel.mView.mTrans_Mask, false)
      end)
    end
    self:CloseEnhance()
  end
end
function UIWeaponPartEnhanceContent:OpenLevelUpPanel(tempMain, tempPropList)
  local lvUpData = CommonLvUpData.New(self.recordLv, self.targetLevel, 102103)
  tempMain.upValue = self.mainProp.value
  lvUpData:SetWeaponPartLvUpData(tempMain, tempPropList, self.subPropList)
  UIManager.OpenUIByParam(UIDef.UIWeaponPartLvUpSuccPanel, lvUpData)
end
function UIWeaponPartEnhanceContent:GetMaterialList()
  local itemList = {}
  local partList = {}
  for _, item in ipairs(self.selectMaterial) do
    if item.type == UIWeaponGlobal.MaterialType.Item then
      itemList[item.id] = item.selectCount
    elseif item.type == UIWeaponGlobal.MaterialType.Weapon then
      table.insert(partList, item.id)
    end
  end
  return itemList, partList
end
function UIWeaponPartEnhanceContent:BeginLongPress(item)
  if self.targetLevel >= self.maxLevel then
    return
  end
  if item.mData.type == UIWeaponGlobal.MaterialType.Item then
    local maxLevelExp = self:GetPartTotalExpByLevel(self.maxLevel)
    local needExp = maxLevelExp - self.totalExp
    item.mData.selectCount = math.min(item.mData.count, item.mData.selectCount + math.ceil(needExp / item.mData.offerExp))
    self.listContent.ui.mVirtualList:Refresh()
    self:UpdateSelectList(item.mData)
    self:SetCurItem(item)
  end
end
function UIWeaponPartEnhanceContent:BeginMinusLongPress(item)
  if item.mData.type == UIWeaponGlobal.MaterialType.Item then
    item.mData.selectCount = 0
    self.listContent.ui.mVirtualList:Refresh()
    self:UpdateSelectList(item.mData)
    self:SetCurItem(item)
  end
end
function UIWeaponPartEnhanceContent:UpdateIsMaxLevel()
  local isMax = self.targetLevel >= self.maxLevel
  setactive(self.ui.mTrans_CostCoin, not isMax)
  setactive(self.ui.mTrans_BtnLevelUp, not isMax)
  setactive(self.ui.mTrans_AddItem, not isMax)
  setactive(self.ui.mTrans_MaxLevel, isMax)
end
