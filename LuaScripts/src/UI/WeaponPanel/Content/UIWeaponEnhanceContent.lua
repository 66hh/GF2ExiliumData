require("UI.UIBasePanel")
require("UI.WeaponPanel.UIWeaponPanelView")
UIWeaponEnhanceContent = class("UIWeaponEnhanceContent", UIBasePanel)
UIWeaponEnhanceContent.__index = UIWeaponEnhanceContent
function UIWeaponEnhanceContent:ctor(data, weaponPanel)
  self.mView = nil
  self.weaponListContent = nil
  self.mData = data
  self.weaponPanel = weaponPanel
  self.itemIdList = TableData.GlobalSystemData.WeaponLevelUpItem
  self.breakLevel = TableData.GlobalSystemData.WeaponLevelPerBreak
  self.skillUpLevel = TableData.GlobalSystemData.WeaponSkillUpLevel
  self.weaponLowRank = TableData.GlobalSystemData.WeaponLowRank
  UIWeaponGlobal.MaxMaterialCount = TableData.GlobalSystemData.WeaponUpgradeItemLimited
  self.materialsList = {}
  self.itemList = {}
  self.weaponList = {}
  self.selectMaterial = {}
  self.isCoinEnough = false
  self.isLevelUpMode = false
  self.needBreak = false
  self.propertyList = {}
  self.skillDetail = nil
  self.itemBrief = nil
  self.recordLv = 0
  self.recordExp = 0
  self.filtrateContent = nil
  self.filtrateList = {}
  self.curSort = nil
  self.typeList = {}
  self.curType = nil
  self.curItem = nil
  self.needUpdate = true
end
function UIWeaponEnhanceContent:InitCtrl(root, weaponList)
  self.mView = UIWeaponEnhanceContentView.New()
  self.mView:InitCtrl(root, weaponList)
  self.weaponListContent = weaponList
  self.filtrateContent = weaponList.filtrateContent
  self.filtrateList = weaponList.filtrateList
  self.typeList = weaponList.weaponDropList
  self.sortContent = UIWeaponSortItem.New()
  UIUtils.GetButtonListener(self.mView.mBtn_LevelUp.gameObject).onClick = function()
    self:OnClickLevelUp()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_AddItem.gameObject).onClick = function()
    self:OnClickEnhance()
  end
  self.isLevelUpMode = false
  self.mView.mText_SelectNum.text = 0 .. "/" .. UIWeaponGlobal.MaxMaterialCount
end
function UIWeaponEnhanceContent:OnClose()
  self.mView:OnClose()
  self:ReleaseCtrlTable(self.propertyList)
  if self.sortContent then
    self.sortContent:OnRelease()
  end
end
function UIWeaponEnhanceContent:OnRelease()
  self:ReleaseTimers()
end
function UIWeaponEnhanceContent:InitFiltrateContent()
  for i, filtrate in ipairs(self.filtrateList) do
    filtrate.setId = i
    filtrate.hintID = 40044 + i
    filtrate.filtrateCfg = UIWeaponGlobal.MaterialFiltrateCfg[i]
    filtrate.mText_Name.text = TableData.GetHintById(filtrate.hintID)
    if i == PlayerPrefs.GetInt(AccountNetCmdHandler.WeaponFilterType) then
      self.curFiltrate = filtrate
    end
    UIUtils.GetButtonListener(filtrate.mBtn_Suit.gameObject).onClick = function()
      self:OnClickFiltrate(filtrate.setId)
    end
    if self.filtrateList[i] ~= self.curFiltrate then
      self.filtrateList[i]:SetSelect(false)
    else
      self.filtrateList[i]:SetSelect(true)
    end
  end
  if self.curFiltrate == nil then
    self.curFiltrate = self.filtrateList[1]
  end
  self.filtrateContent:SetFiltrateData(self.curFiltrate)
end
function UIWeaponEnhanceContent:InitTypeContent()
  for i, type in pairs(self.typeList) do
    UIUtils.GetButtonListener(type.mBtn_Suit.gameObject).onClick = function()
      self:OnClickType(type.setId)
    end
    if self.typeList[i].setId == 0 then
      self.curType = type
    end
    if self.typeList[i] ~= self.curType then
      self.typeList[i]:SetSelect(false)
    else
      self.typeList[i]:SetSelect(true)
    end
    setactive(self.typeList[i].mUIRoot, true)
  end
  self.mView.mText_TypeName.text = self.curType:GetTypeName()
end
function UIWeaponEnhanceContent:InitVirtualList()
  function self.mView.mVirtualList.itemProvider()
    local item = self:MaterialItemProvider()
    return item
  end
  function self.mView.mVirtualList.itemRenderer(index, rendererData)
    self:MaterialItemRenderer(index, rendererData)
  end
end
function UIWeaponEnhanceContent:MaterialItemProvider()
  local itemView = UICommonItem.New()
  itemView:InitCtrl()
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIWeaponEnhanceContent:MaterialItemRenderer(index, rendererData)
  local itemData = self.materialsList[index + 1]
  local item = rendererData.data
  item:SetMaterialData(itemData, not self:CheckCanSelectWeapon(itemData))
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
function UIWeaponEnhanceContent:CheckCanSelectWeapon(data)
  if self:GetSelectMaterialCount() >= UIWeaponGlobal.MaxMaterialCount then
    return false
  elseif self.targetLevel >= self.mData.MaxLevel then
    return false
  end
  return true
end
function UIWeaponEnhanceContent:OnClickItem(item)
  if self:GetSelectMaterialCount() >= UIWeaponGlobal.MaxMaterialCount then
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
    if item.mData.partCount > 0 then
      MessageBoxPanel.ShowDoubleType(TableData.GetHintById(40038), function()
        NetCmdWeaponPartsData:ReqWeaponPartBelong(0, item.mData.id, 0, function()
          item.mData = self:UpdateWeaponDataById(item.mData.id)
          self:OnClickItem(item)
        end)
      end)
      self:UpdateItemBrief(item.mData.id, item.mData.type)
      self:SetCurItem(item)
      self.needUpdate = false
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
function UIWeaponEnhanceContent:SetCurItem(item)
  if self.curItem then
    self.curItem.isSelect = false
    self.mView.mVirtualList:RefreshItem(self.curItem.index)
  end
  if item then
    item.mData.isSelect = true
    item:EnableSelectFrame(true)
    self.curItem = item.mData
  else
    self.curItem = nil
  end
end
function UIWeaponEnhanceContent:OnClickReduce(item)
  item:OnReduce()
  self:UpdateSelectList(item.mData)
end
function UIWeaponEnhanceContent:IsInSelectList(itemData)
  for i, item in ipairs(self.selectMaterial) do
    if itemData.type == item.type and itemData.id == item.id then
      return item, i
    end
  end
  return nil
end
function UIWeaponEnhanceContent:GetSelectMaterialCount()
  local count = 0
  for _, item in ipairs(self.selectMaterial) do
    if item.type == UIWeaponGlobal.MaterialType.Weapon then
      count = count + item.selectCount
    elseif item.type == UIWeaponGlobal.MaterialType.Item then
      count = count + 1
    end
  end
  return count
end
function UIWeaponEnhanceContent:UpdateSelectList(itemData)
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
function UIWeaponEnhanceContent:UpdateSelectListView()
  local addExp = 0
  local costCoin = 0
  local count = 1
  local item
  self.mView.mText_SelectNum.text = #self.selectMaterial .. "/" .. UIWeaponGlobal.MaxMaterialCount
  for i = 1, #self.selectMaterial do
    local data = self.selectMaterial[i]
    addExp = addExp + data.offerExp * data.selectCount
    costCoin = costCoin + data.costCoin * data.selectCount
  end
  self.isCoinEnough = costCoin <= GlobalData.cash
  self.mView.mText_CostCoin.text = costCoin
  self.mView.mText_CostCoin.color = self.isCoinEnough and ColorUtils.WhiteColor or ColorUtils.RedColor
  self:UpdateLevelUpInfo(addExp)
end
function UIWeaponEnhanceContent:InvertSelectionItem(item)
  item.selectCount = item.selectCount - 1
  self:UpdateSelectList(item)
  self.mView.mVirtualList:Refresh()
end
function UIWeaponEnhanceContent:UpdateLevelUpInfo(exp)
  self.totalExp = self.mData.Exp + exp + self:GetWeaponTotalExpByLevel(self.mData.Level)
  self.targetLevel = math.min(self:CalculateLevel(self.totalExp), self.maxLevel)
  self:UpdateWeaponInfo(exp)
end
function UIWeaponEnhanceContent:CalculateLevel(exp)
  return UIWeaponGlobal:GetWeaponLevelByExp(exp, self.mData.StcData.ExpRate)
end
function UIWeaponEnhanceContent:UpdatePanel()
  if not self.needUpdate then
    self.needUpdate = true
    return
  end
  local typeData = TableData.listGunWeaponTypeDatas:GetDataById(self.mData.Type)
  self.mView.mText_Name.text = self.mData.Name
  self.mView.mText_Type.text = typeData.name.str
  self.targetLevel = self.mData.Level
  self.maxLevel = self.mData.MaxLevel
  self.totalExp = self:GetWeaponTotalExpByLevel(self.mData.GunLevel) + self.mData.Exp
  self.recordLv = self.mData.Level
  self.recordExp = self.mData.Exp
  self:UpdateStar(self.mData.BreakTimes, self.mData.MaxBreakTime)
  self.selectMaterial = {}
  if self.mData.Level < self.mData.MaxLevel then
    local nextLevel = self.mData.Level + 1
    local exp = self.mData:GetWeaponCurNeedExpByLv(nextLevel)
    self.nextLevelExp = exp
  else
    self.nextLevelExp = 0
  end
  self:UpdateSelectListView()
  self:UpdateWeaponInfo(0)
  self:UpdatePropertyList()
  self:UpdateIsMaxLevel()
  setactive(self.mView.mTrans_AutoSelect, true)
  self.mView.ui.mBtn_LevelUp.interactable = false
end
function UIWeaponEnhanceContent:ResetWeaponList()
  UIUtils.GetButtonListener(self.mView.mBtn_CloseList.gameObject).onClick = function()
    self:CloseEnhance()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_AutoSelect.gameObject).onClick = function()
    self:AutoSelect()
  end
  self.pointer = UIUtils.GetPointerClickHelper(self.mView.mTrans_ItemBrief.gameObject, function()
    self:CloseItemBrief()
  end, self.mView.mTrans_ItemBrief.gameObject)
  self:InitVirtualList()
  self:InitFiltrateContent()
  self:InitTypeContent()
  self.isLevelUpMode = false
end
function UIWeaponEnhanceContent:UpdateStar(star, maxStar)
  self.mView.stageItem:ResetMaxNum(maxStar)
  self.mView.stageItem:SetData(star)
end
function UIWeaponEnhanceContent:UpdatePropertyList()
  local attrList = {}
  local expandList = TableData.GetPropertyExpandList()
  for i = 0, expandList.Count - 1 do
    local lanData = expandList[i]
    if lanData.type == 1 then
      local value = self.mData:GetPropertyByLevelAndSysName(lanData.sys_name, self.mData.Level, self.mData.BreakTimes, false)
      if 0 < value and lanData.statue == 1 then
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
  for _, item in ipairs(self.propertyList) do
    item:SetData(nil)
  end
  for i = 1, #attrList do
    local item
    if i <= #self.propertyList then
      item = self.propertyList[i]
    else
      item = UICommonPropertyItem.New()
      item:InitCtrl(self.mView.mTrans_PropList, true)
      table.insert(self.propertyList, item)
    end
    item:SetData(attrList[i].propData, attrList[i].value, true, false, false, false)
    item:SetTextColor(attrList[i].propData.statue == 2 and ColorUtils.OrangeColor or ColorUtils.WhiteColor)
  end
end
function UIWeaponEnhanceContent:OnClickEnhance()
  if self.isLevelUpMode then
    return
  end
  self.isLevelUpMode = true
  self.mView.ui.mBtn_AddItem.interactable = false
  self:UpdateEnhanceList()
  setactive(self.mView.mTrans_EnhanceContent, true)
  setactive(self.weaponPanel.mView.ui.mTrans_Left, false)
end
function UIWeaponEnhanceContent:CloseEnhance()
  if self.mView.mListAniTime and self.mView.mListAnimator then
    self.mView.mListAnimator:SetTrigger("Fadeout")
    self:DelayCall(self.mView.mListAniTime.m_FadeOutTime, function()
      self.isLevelUpMode = false
      self.mView.ui.mBtn_AddItem.interactable = true
      self.mView.ui.mBtn_LevelUp.interactable = false
      self:ResetTypeFiltareList()
      self:UpdatePanel()
      setactive(self.mView.mTrans_EnhanceContent, false)
      setactive(self.weaponPanel.mView.ui.mTrans_Left, true)
    end)
  else
    self.isLevelUpMode = false
    self.mView.ui.mBtn_AddItem.interactable = true
    self.mView.ui.mBtn_LevelUp.interactable = false
    self:ResetTypeFiltareList()
    self:UpdatePanel()
    setactive(self.mView.mTrans_EnhanceContent, false)
    setactive(self.weaponPanel.mView.ui.mTrans_Left, true)
  end
end
function UIWeaponEnhanceContent:UpdateEnhanceList()
  local list = NetCmdWeaponData:GetEnhanceWeaponList(self.mData.id, self.curType.setId)
  self.materialsList = self:UpdateMaterialList(list)
  local sortType = UIWeaponGlobal.MaterialSortCfg[UIWeaponGlobal.MaterialSortType.Rank]
  self:UpdateListBySort(sortType)
  self:ResetMaterialIndex(self.materialsList)
  setactive(self.mView.mTrans_Empty, #self.materialsList <= 0)
end
function UIWeaponEnhanceContent:UpdateListBySort(sortType)
  local sortFunc = self.sortContent:GetEnhanceSortFunc(1, sortType, true)
  table.sort(self.materialsList, sortFunc)
  self.mView.mVirtualList.numItems = #self.materialsList
  self.mView.mVirtualList:Refresh()
end
function UIWeaponEnhanceContent:UpdateMaterialList(list)
  if list then
    self.itemList = {}
    self.weaponList = {}
    local itemList = {}
    for i = 0, self.itemIdList.Count - 1 do
      local id = self.itemIdList[i]
      local data = UIWeaponGlobal:GetMaterialSimpleData(id, UIWeaponGlobal.MaterialType.Item)
      if data then
        local item, i = self:IsInSelectList(data)
        if item then
          data.selectCount = item.selectCount
          self.selectMaterial[i] = data
        end
        table.insert(itemList, data)
        table.insert(self.itemList, data)
      end
    end
    for i = 0, list.Count - 1 do
      local data = UIWeaponGlobal:GetMaterialSimpleData(list[i], UIWeaponGlobal.MaterialType.Weapon)
      if data then
        local item, i = self:IsInSelectList(data)
        if item then
          data.selectCount = item.selectCount
          self.selectMaterial[i] = data
        end
        table.insert(itemList, data)
        table.insert(self.weaponList, data)
      end
    end
    return itemList
  end
end
function UIWeaponEnhanceContent:UpdateWeaponInfo(exp)
  local maxExp = 0
  local curExp = 0
  local sliderBeforeValue = 0
  local sliderAfterValue = 0
  local curExpData = self:GetWeaponTotalExpByLevel(self.mData.Level)
  local targetExpData = self:GetWeaponTotalExpByLevel(self.targetLevel)
  if self.mData.Exp + exp >= self.nextLevelExp then
    local nextLevel = self.targetLevel >= self.maxLevel and self.maxLevel or self.targetLevel + 1
    maxExp = self.mData:GetWeaponCurNeedExpByLv(nextLevel)
    if self.targetLevel >= self.maxLevel then
      curExp = maxExp
    else
      curExp = curExpData + self.mData.Exp + exp - targetExpData
    end
    sliderBeforeValue = self.mData.Level >= self.maxLevel and 1 or 0
    sliderAfterValue = curExp / maxExp
  else
    maxExp = self.nextLevelExp
    if self.targetLevel >= self.maxLevel then
      curExp = maxExp
      sliderBeforeValue = 1
      sliderAfterValue = 1
    else
      curExp = self.mData.Exp + exp
      sliderBeforeValue = self.mData.Exp / self.nextLevelExp
      sliderAfterValue = (self.mData.Exp + exp) / self.nextLevelExp
    end
  end
  self.mView.mText_Exp.text = string_format("{0}/{1}", curExp, maxExp)
  self.mView.mText_LevelNow.text = self.targetLevel
  self.mView.mText_LevelMax.text = "/" .. self.mData.MaxLevel
  self.mView.mText_AddExp.text = "+" .. exp
  self.mView.mImage_ExpAfter.fillAmount = sliderAfterValue
  self.mView.mImage_ExpBefore.fillAmount = sliderBeforeValue
  self.canLevelUp = 0 < exp
  self:UpdatePropChangeValue()
  setactive(self.mView.mTrans_ExpAdd, 0 < exp)
  self.mView.ui.mBtn_LevelUp.interactable = 0 < exp
end
function UIWeaponEnhanceContent:UpdatePropChangeValue()
  for _, item in ipairs(self.propertyList) do
    local value = 0
    if self.targetLevel ~= self.mData.Level then
      local propName = item.mData.sys_name
      value = self.mData:GetPropertyByLevelAndSysName(propName, self.targetLevel, self.mData.BreakTimes, false)
    end
    item:SetValueUp(value)
  end
end
function UIWeaponEnhanceContent:OnClickLevelUp()
  if not self.isCoinEnough then
    UIUtils.PopupHintMessage(40050)
    return
  end
  if not self.canLevelUp then
    UIUtils.PopupHintMessage(40019)
    return
  end
  local itemList, weaponList = self:GetMaterialList()
  self.recordLv = self.mData.Level
  self.recordExp = self.mData.Exp
  NetCmdWeaponData:SendGunWeaponLvUp(self.mData.id, weaponList, itemList, function(ret)
    self:LevelUpCallback(ret)
  end)
end
function UIWeaponEnhanceContent:LevelUpCallback(ret)
  if ret == ErrorCodeSuc then
    gfdebug("强化武器成功")
    if self.recordLv < self.targetLevel then
      self:OpenLevelUpPanel()
      self.mData = NetCmdWeaponData:GetWeaponById(self.mData.id)
      self:UpdatePanel()
      self:UpdateEnhanceList()
      if self.needBreak and self.mData.Level < self.mData.MaxLevel then
        self.weaponPanel:RefreshPanel()
      end
    else
      setactive(self.mView.mTrans_Mask, true)
      local start = self.mData.Level + self.recordExp / self.nextLevelExp
      local endLv = self.mData.Level + self.mData.Exp / self.nextLevelExp
      CS.ProgressBarAnimationHelper.Play(self.mView.mImage_ExpBefore, start, endLv, 0.5, nil, function()
        self.mData = NetCmdWeaponData:GetWeaponById(self.mData.id)
        self:UpdatePanel()
        self:UpdateEnhanceList()
        if self.needBreak and self.mData.Level < self.mData.MaxLevel then
          self.weaponPanel:RefreshPanel()
        end
        setactive(self.mView.mTrans_Mask, false)
      end)
    end
    self:CloseEnhance()
  end
end
function UIWeaponEnhanceContent:OpenLevelUpPanel()
  local lvUpData = CommonLvUpData.New(self.recordLv, self.targetLevel, 102103)
  lvUpData:SetWeaponLvUpData(self.propertyList)
  UIManager.OpenUIByParam(UIDef.UIWeaponLvUpSuccPanel, lvUpData)
end
function UIWeaponEnhanceContent:GetMaterialList()
  local itemList = {}
  local weaponList = {}
  for _, item in ipairs(self.selectMaterial) do
    if item.type == UIWeaponGlobal.MaterialType.Item then
      itemList[item.id] = item.selectCount
    elseif item.type == UIWeaponGlobal.MaterialType.Weapon then
      table.insert(weaponList, item.id)
    end
  end
  return itemList, weaponList
end
function UIWeaponEnhanceContent:UpdateItemBrief(id, type)
  local lockCallback = function(id, isLock)
    self:UpdateWeaponLock(id, isLock)
  end
  self.pointer.isInSelf = true
  if type == UIWeaponGlobal.MaterialType.Item then
    ComPropsDetailsHelper:InitItemData(self.mView.mTrans_ItemBrief.transform, id, lockCallback)
  elseif type == UIWeaponGlobal.MaterialType.Weapon then
    ComPropsDetailsHelper:InitWeaponData(self.mView.mTrans_ItemBrief.transform, id, lockCallback, false)
  end
end
function UIWeaponEnhanceContent:CloseItemBrief()
  ComPropsDetailsHelper:Close()
end
function UIWeaponEnhanceContent:UpdateIsMaxLevel()
  local isMax = self.targetLevel >= self.mData.DefaultMaxLevel
  local equalGunLevel = self.targetLevel == self.mData.MaxLevel
  setactive(self.mView.mTrans_CostCoin, not equalGunLevel and not isMax)
  setactive(self.mView.mTrans_BtnLevelUp, not equalGunLevel and not isMax)
  setactive(self.mView.mTrans_AddItem, not equalGunLevel and not isMax)
  setactive(self.mView.mTrans_SelectNum, not equalGunLevel and not isMax)
  setactive(self.mView.mTrans_MaxLevel, isMax)
  setactive(self.mView.mTrans_SkillList, isMax)
  setactive(self.mView.mTrans_ChrMaxLevel, equalGunLevel and not isMax)
end
function UIWeaponEnhanceContent:OnClickFiltrate(type)
  if type then
    PlayerPrefs.SetInt(AccountNetCmdHandler.WeaponFilterType, type)
    if self.curFiltrate and self.curFiltrate.setId ~= type then
      self.curFiltrate:SetSelect(false)
    end
    self.curFiltrate = self.filtrateList[type]
    self.curFiltrate:SetSelect(true)
    self.filtrateContent:SetFiltrateData(self.curFiltrate)
    self.weaponListContent:CloseItemSort()
  end
end
function UIWeaponEnhanceContent:OnClickType(type)
  if type then
    if self.curType and self.curType.setId ~= type then
      self.curType:SetSelect(false)
    end
    self.curType = self.typeList[type]
    self.curType:SetSelect(true)
    self.mView.mText_TypeName.text = self.curType:GetTypeName()
    self:RemoveFiltrateWeapon()
    self:UpdateEnhanceList()
    self.mView.mVirtualList.verticalNormalizedPosition = 1
    self.weaponListContent:CloseItemType()
  end
end
function UIWeaponEnhanceContent:AutoSelect()
  self:ResetMaterialList()
  local matList = {}
  local maxLevelExp = self:GetWeaponTotalExpByLevel(self.mData.MaxLevel)
  local needExp = maxLevelExp - self.totalExp
  for i = 1, #self.itemList do
    local item = self.itemList[#self.itemList - i + 1]
    local maxItemOfferCount = math.ceil(needExp / item.offerExp)
    if maxItemOfferCount <= item.count then
      item.selectCount = maxItemOfferCount
    else
      item.selectCount = item.count
    end
    table.insert(matList, item)
    needExp = needExp - item.offerExp * item.selectCount
    if needExp <= 0 then
      needExp = 0
      break
    end
  end
  if 0 < needExp then
    local sortType = UIWeaponGlobal.MaterialSortCfg[UIWeaponGlobal.MaterialSortType.Rank]
    local sortFunc = self.sortContent:GetEnhanceSortFunc(1, sortType, true)
    table.sort(self.weaponList, sortFunc)
    for i, v in ipairs(self.weaponList) do
      if #matList >= UIWeaponGlobal.MaxMaterialCount then
        break
      end
      if self:CanBeAutoSelect(v, self.curFiltrate.filtrateCfg) and 0 < needExp then
        v.selectCount = 1
        needExp = needExp - v.offerExp
        table.insert(matList, v)
        if needExp <= 0 then
          needExp = 0
          break
        end
      end
    end
  end
  for _, item in ipairs(matList) do
    table.insert(self.selectMaterial, item)
  end
  if 0 < #matList then
    UIUtils.PopupPositiveHintMessage(40067)
  end
  self.mView.mVirtualList:Refresh()
  self:UpdateSelectListView()
end
function UIWeaponEnhanceContent:UpdateWeaponLock(id, isLock)
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
  self.mView.mVirtualList:Refresh()
end
function UIWeaponEnhanceContent:BeginLongPress(item)
  if self.targetLevel >= self.maxLevel then
    return
  end
  if item.mData.type == UIWeaponGlobal.MaterialType.Item then
    local maxLevelExp = self:GetWeaponTotalExpByLevel(self.maxLevel)
    local needExp = maxLevelExp - self.totalExp
    item.mData.selectCount = math.min(item.mData.count, item.mData.selectCount + math.ceil(needExp / item.mData.offerExp))
    self.mView.mVirtualList:Refresh()
    self:UpdateSelectList(item.mData)
    self:SetCurItem(item)
  end
end
function UIWeaponEnhanceContent:BeginMinusLongPress(item)
  if item.mData.type == UIWeaponGlobal.MaterialType.Item then
    item.mData.selectCount = 0
    self.mView.mVirtualList:Refresh()
    self:UpdateSelectList(item.mData)
    self:SetCurItem(item)
  end
end
function UIWeaponEnhanceContent:GetWeaponTotalExpByLevel(level)
  return UIWeaponGlobal:GetWeaponTotalExpByLevel(level, self.mData.StcData.ExpRate / 1000)
end
function UIWeaponEnhanceContent:CanBeAutoSelect(item, filter)
  if item.type == UIWeaponGlobal.MaterialType.Weapon and item.level <= 1 and not item.isLock and item.partCount <= 0 and 0 >= item.breakTimes and filter >= item.rank then
    return true
  end
  return false
end
function UIWeaponEnhanceContent:ResetMaterialIndex(list)
  if list then
    for i, item in ipairs(list) do
      item.index = i - 1
    end
  end
end
function UIWeaponEnhanceContent:ResetMaterialList()
  for i, item in ipairs(self.selectMaterial) do
    item.selectCount = 0
  end
  self.selectMaterial = {}
  self:UpdateSelectListView()
  self:UpdateWeaponInfo(0)
  self.mView.mVirtualList:Refresh()
end
function UIWeaponEnhanceContent:RemoveFiltrateWeapon()
  local list = {}
  for i, item in ipairs(self.selectMaterial) do
    table.insert(list, item)
  end
  for i, item in ipairs(list) do
    if item.type == UIWeaponGlobal.MaterialType.Weapon and self.curType.setId ~= 0 and self.curType.setId ~= item.weaponType then
      self:InvertSelectionItem(item)
    end
  end
end
function UIWeaponEnhanceContent:ResetTypeFiltareList()
  self.curType = self.typeList[0]
  self.curFiltrate = self.filtrateList[1]
  for i, filtrate in ipairs(self.filtrateList) do
    if i == PlayerPrefs.GetInt(AccountNetCmdHandler.WeaponFilterType) then
      self.curFiltrate = filtrate
      break
    end
  end
  for i, type in pairs(self.typeList) do
    if self.typeList[i] ~= self.curType then
      self.typeList[i]:SetSelect(false)
    else
      self.typeList[i]:SetSelect(true)
    end
  end
  self.mView.mText_TypeName.text = self.curType:GetTypeName()
  for i, filtrate in ipairs(self.filtrateList) do
    if self.filtrateList[i] ~= self.curFiltrate then
      self.filtrateList[i]:SetSelect(false)
    else
      self.filtrateList[i]:SetSelect(true)
    end
  end
  self.filtrateContent:SetFiltrateData(self.curFiltrate)
end
function UIWeaponEnhanceContent:UpdateWeaponDataById(id)
  for i, item in ipairs(self.materialsList) do
    if item.type == UIWeaponGlobal.MaterialType.Weapon and item.id == id then
      self.materialsList[i] = UIWeaponGlobal:GetMaterialSimpleData(NetCmdWeaponData:GetWeaponById(id), UIWeaponGlobal.MaterialType.Weapon)
      return self.materialsList[i]
    end
  end
end
