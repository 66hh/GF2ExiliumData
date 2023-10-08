require("UI.UIBasePanel")
UIWeaponEvolutionPanel = class("UIWeaponEvolutionPanel", UIBasePanel)
UIWeaponEvolutionPanel.__index = UIWeaponEvolutionPanel
function UIWeaponEvolutionPanel:ctor()
  UIWeaponEvolutionPanel.super.ctor(self)
  UIWeaponEvolutionPanel.mView = {}
  UIWeaponEvolutionPanel.itemIdList = TableData.GlobalSystemData.WeaponLevelUpItem
  UIWeaponEvolutionPanel.weaponListContent = nil
  UIWeaponEvolutionPanel.propertyList = {}
  UIWeaponEvolutionPanel.materialsList = {}
  UIWeaponEvolutionPanel.filtrateContent = nil
  UIWeaponEvolutionPanel.filtrateList = {}
  UIWeaponEvolutionPanel.curSort = nil
  UIWeaponEvolutionPanel.typeList = {}
  UIWeaponEvolutionPanel.curType = nil
  UIWeaponEvolutionPanel.sortContent = UIWeaponSortItem.New()
  UIWeaponEvolutionPanel.skillItem = nil
  UIWeaponEvolutionPanel.weaponNowItem = nil
  UIWeaponEvolutionPanel.coreItem = nil
  UIWeaponEvolutionPanel.evolutionList = {}
  UIWeaponEvolutionPanel.selectMaterial = {}
  UIWeaponEvolutionPanel.curExp = 0
  UIWeaponEvolutionPanel.needExp = 0
  UIWeaponEvolutionPanel.needItem = 0
  UIWeaponEvolutionPanel.needCoin = 0
  UIWeaponEvolutionPanel.isCoinEnough = false
  UIWeaponEvolutionPanel.curItem = nil
end
function UIWeaponEvolutionPanel:Close()
  UIWeaponGlobal:EnableWeaponModel(true)
  UIManager.CloseUI(UIDef.UIWeaponEvolutionPanel)
  UIWeaponEvolutionPanel.weaponListContent = nil
  UIWeaponEvolutionPanel.propertyList = {}
  UIWeaponEvolutionPanel.materialsList = {}
  UIWeaponEvolutionPanel.filtrateContent = nil
  UIWeaponEvolutionPanel.filtrateList = {}
  UIWeaponEvolutionPanel.curSort = nil
  UIWeaponEvolutionPanel.typeList = {}
  UIWeaponEvolutionPanel.curType = nil
  UIWeaponEvolutionPanel.sortContent = UIWeaponSortItem.New()
  UIWeaponEvolutionPanel.skillItem = nil
  UIWeaponEvolutionPanel.weaponNowItem = nil
  UIWeaponEvolutionPanel.coreItem = nil
  UIWeaponEvolutionPanel.itemBrief = nil
  UIWeaponEvolutionPanel.returnItem = nil
  UIWeaponEvolutionPanel.evolutionList = {}
  UIWeaponEvolutionPanel.selectMaterial = {}
  UIWeaponEvolutionPanel.curExp = 0
  UIWeaponEvolutionPanel.needExp = 0
  UIWeaponEvolutionPanel.needItem = 0
  UIWeaponEvolutionPanel.needCoin = 0
  UIWeaponEvolutionPanel.isCoinEnough = false
end
function UIWeaponEvolutionPanel:OnInit(root, data)
  self = UIWeaponEvolutionPanel
  UIWeaponEvolutionPanel.super.SetRoot(UIWeaponEvolutionPanel, root)
  self:LuaUIBindTable(root, self.mView)
  self.weaponListContent = UIWeaponListContent.New()
  self.weaponListContent:InitCtrl(self.mView.mTrans_WeaponList)
  self.mData = NetCmdWeaponData:GetWeaponById(data[1])
  self.evolutionWeapon = TableData.listGunWeaponDatas:GetDataById(data[2])
  self.mView.mText_SelectNum.text = 0 .. "/" .. UIWeaponGlobal.MaxMaterialCount
  self.skillItem = self:InitSkillItem()
  self.weaponNowItem = self:InitWeaponNowItem()
  self.pointer = UIUtils.GetPointerClickHelper(self.mView.mTrans_ItemBrief.gameObject, function()
    UIWeaponEvolutionPanel:CloseItemBrief()
  end, self.mView.mTrans_ItemBrief.gameObject)
  UIUtils.GetButtonListener(self.mView.mBtn_Close.gameObject).onClick = function()
    self:Close()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_Evolution.gameObject).onClick = function()
    UIWeaponEvolutionPanel:OnClickEvolution()
  end
  UIUtils.GetButtonListener(self.weaponListContent.ui.mBtn_AutoSelect.gameObject).onClick = function()
    UIWeaponEvolutionPanel:AutoSelect()
  end
  self:InitVirtualList()
  self:InitEvolutionVirtualList()
  self:InitFiltrateContent()
  self:InitTypeContent()
  self:InitCost()
  self:UpdatePanel()
  UIWeaponGlobal:EnableWeaponModel(false)
end
function UIWeaponEvolutionPanel:InitSkillItem()
  local obj = self:InstanceUIPrefab("Character/ChrWeaponSkillItemV2.prefab", self.mView.mTrans_SkillList, true)
  if obj then
    local skill = {}
    skill.obj = obj
    skill.txtName = UIUtils.GetText(obj, "GrpNameInfo/GrpTextName/Text_SkillName")
    skill.txtLv = UIUtils.GetText(obj, "GrpNameInfo/GrpTextName/Trans_Text_Lv")
    skill.txtNum = UIUtils.GetText(obj, "GrpNameInfo/GrpTextName/Trans_Text_Num")
    skill.txtDesc = UIUtils.GetText(obj, "Text_Describe")
    setactive(skill.txtLv.gameObject, true)
    return skill
  end
end
function UIWeaponEvolutionPanel:InitWeaponNowItem()
  local item = UICommonItem.New()
  item:InitCtrl(self.mView.mTrans_WeaponNow)
  return item
end
function UIWeaponEvolutionPanel:InitFiltrateContent()
  local filtrateList = self.weaponListContent.filtrateList
  local filtrateContent = self.weaponListContent.filtrateContent
  for i, filtrate in ipairs(filtrateList) do
    filtrate.hintID = 40044 + i
    filtrate.filtrateCfg = UIWeaponGlobal.MaterialFiltrateCfg[i]
    filtrate.mText_Name.text = TableData.GetHintById(filtrate.hintID)
    if filtrate.filtrateCfg == UIWeaponGlobal.MaterialFiltrateCfg[1] then
      self.curFiltrate = filtrate
    end
    UIUtils.GetButtonListener(filtrate.mBtn_Suit.gameObject).onClick = function()
      self:OnClickFiltrate(filtrate.filtrateCfg)
    end
    if filtrateList[i] ~= self.curFiltrate then
      filtrateList[i]:SetSelect(false)
    else
      filtrateList[i]:SetSelect(true)
    end
  end
  filtrateContent:SetFiltrateData(self.curFiltrate)
end
function UIWeaponEvolutionPanel:InitTypeContent()
  local typeList = self.weaponListContent.weaponDropList
  for i, type in pairs(typeList) do
    UIUtils.GetButtonListener(type.mBtn_Suit.gameObject).onClick = function()
      self:OnClickType(type.setId)
    end
    if typeList[i].setId == 0 then
      self.curType = type
    end
    if typeList[i] ~= self.curType then
      typeList[i]:SetSelect(false)
    else
      typeList[i]:SetSelect(true)
    end
    setactive(typeList[i].mUIRoot, true)
  end
  self.weaponListContent.ui.mText_TypeName.text = self.curType:GetTypeName()
end
function UIWeaponEvolutionPanel:InitVirtualList()
  function self.weaponListContent.ui.mVirtualList.itemProvider()
    local item = self:MaterialItemProvider()
    return item
  end
  function self.weaponListContent.ui.mVirtualList.itemRenderer(index, rendererData)
    self:MaterialItemRenderer(index, rendererData)
  end
end
function UIWeaponEvolutionPanel:MaterialItemProvider()
  local itemView = UICommonItem.New()
  itemView:InitCtrl()
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIWeaponEvolutionPanel:MaterialItemRenderer(index, rendererData)
  local itemData = self.materialsList[index + 1]
  local item = rendererData.data
  item:SetMaterialData(itemData, true)
  item:SetLongPressEvent(function(go, data)
    self:BeginLongPress(item)
  end)
  item:SetMinusLongPressEvent(function(go, data)
    self:BeginMinusLongPress(item)
  end)
  UIUtils.GetButtonListener(item.mBtn_Select.gameObject).onClick = function()
    self:OnClickItem(item)
  end
  UIUtils.GetButtonListener(item.mBtn_Reduce.gameObject).onClick = function()
    self:OnClickReduce(item)
  end
end
function UIWeaponEvolutionPanel:InitEvolutionVirtualList()
  function self.mView.mTrans_WeaponPreview.itemProvider()
    local item = self:EvolutionItemProvider()
    return item
  end
  function self.mView.mTrans_WeaponPreview.itemRenderer(index, rendererData)
    self:EvolutionItemRenderer(index, rendererData)
  end
end
function UIWeaponEvolutionPanel:EvolutionItemProvider()
  local itemView = UICommonItem.New()
  itemView:InitCtrl()
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIWeaponEvolutionPanel:EvolutionItemRenderer(index, rendererData)
  local itemData = self.evolutionList[index + 1]
  local item = rendererData.data
  local data = TableData.listGunWeaponDatas:GetDataById(itemData.data)
  item:SetData(itemData.data, data.default_maxlv, function(data)
    self:OnClickEvolutionWeapon(data, itemData.index)
  end)
  setactive(item.mTrans_Select, self.evolutionWeapon.id == item.mData.id)
  setactive(item.mTrans_Choose, self.evolutionWeapon.id == item.mData.id)
end
function UIWeaponEvolutionPanel:InitCost()
  self.needExp = TableData.GlobalSystemData.WeaponAdvanceExpcost
  local itemList = TableData.GlobalSystemData.WeaponAdvanceCost
  for id, num in pairs(itemList) do
    if tonumber(id) == GlobalConfig.CoinId then
      self.needCoin = tonumber(num)
    elseif tonumber(id) == GlobalConfig.WeaponEvolutionItem then
      self.needItem = tonumber(num)
    end
  end
  self.coreItem = UICommonItem.New()
  self.coreItem:InitCtrl(self.mView.mTrans_Item)
  self.coreItem:SetItemData(GlobalConfig.WeaponEvolutionItem, self.needItem, true)
  self.returnItem = UIWeaponGlobal:BreakWeaponReturn(self.mData)
end
function UIWeaponEvolutionPanel:UpdatePanel()
  self:UpdateEvolutionWeapon()
  self:UpdateEnhanceList()
  self:UpdateWeaponNow()
  self:UpdateWeaponEvolution()
  self:UpdateSelectListView()
end
function UIWeaponEvolutionPanel:UpdateEvolutionWeapon()
  local typeData = TableData.listGunWeaponTypeDatas:GetDataById(self.evolutionWeapon.type)
  local skillData
  if self.evolutionWeapon.skill ~= 0 then
    skillData = TableData.GetSkillData(self.evolutionWeapon.skill)
  end
  self.mView.mText_Name.text = self.evolutionWeapon.name.str
  self.mView.mText_Type.text = typeData.name.str
  self:UpdatePropertyList(self.evolutionWeapon.id, self.evolutionWeapon.default_maxlv, 0)
  self:UpdateSkill(skillData)
end
function UIWeaponEvolutionPanel:UpdateEnhanceList()
  local list = NetCmdWeaponData:GetEnhanceWeaponList(self.mData.id, self.curType.setId)
  self.materialsList = self:UpdateMaterialList(list)
  local sortType = UIWeaponGlobal.MaterialSortCfg[UIWeaponGlobal.MaterialSortType.Rank]
  self:UpdateListBySort(sortType)
  self:ResetMaterialIndex(self.materialsList)
  setactive(self.weaponListContent.ui.mTrans_Empty, #self.materialsList <= 0)
end
function UIWeaponEvolutionPanel:UpdateWeaponNow()
  if self.weaponNowItem then
    self.weaponNowItem:SetData(self.mData.stc_id, self.mData.Level)
  end
end
function UIWeaponEvolutionPanel:UpdateWeaponEvolution()
  self.evolutionList = {}
  for i = 0, self.mData.AdvanceWeapon.Count - 1 do
    local itemData = {}
    itemData.data = self.mData.AdvanceWeapon[i]
    itemData.index = i
    table.insert(self.evolutionList, itemData)
  end
  self.mView.mTrans_WeaponPreview.numItems = #self.evolutionList
  self.mView.mTrans_WeaponPreview:Refresh()
end
function UIWeaponEvolutionPanel:UpdateListBySort(sortType)
  local sortFunc = self.sortContent:GetEnhanceSortFunc(1, sortType, true)
  table.sort(self.materialsList, sortFunc)
  self.weaponListContent.ui.mVirtualList.numItems = #self.materialsList
  self.weaponListContent.ui.mVirtualList:Refresh()
end
function UIWeaponEvolutionPanel:UpdateMaterialList(list)
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
function UIWeaponEvolutionPanel:UpdatePropertyList(weaponId, level, breakTime)
  local attrList = {}
  local expandList = TableData.GetPropertyExpandList()
  for i = 0, expandList.Count - 1 do
    local lanData = expandList[i]
    if lanData.type == 1 then
      local value = NetCmdWeaponData:GetPropertyByLevelAndSysName(weaponId, lanData.sys_name, level, breakTime)
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
  for _, item in ipairs(self.propertyList) do
    item:SetData(nil)
  end
  for i = 1, #attrList do
    local item
    if i <= #self.propertyList then
      item = self.propertyList[i]
    else
      item = UICommonPropertyItem.New()
      item:InitCtrl(self.mView.mTrans_PropList)
      table.insert(self.propertyList, item)
    end
    item:SetData(attrList[i].propData, attrList[i].value, true, false, false, false)
    item:SetTextColor(attrList[i].propData.statue == 2 and ColorUtils.OrangeColor or ColorUtils.BlackColor)
  end
end
function UIWeaponEvolutionPanel:UpdateSkill(skill1)
  local skill = self.skillItem
  if skill1 then
    skill.data = skill1
    skill.txtName.text = skill1.name.str
    skill.txtLv.text = GlobalConfig.SetLvText(skill1.level)
    skill.txtDesc.text = skill1.description.str
    setactive(skill.obj, true)
  else
    skill.data = nil
    setactive(skill.obj, false)
  end
end
function UIWeaponEvolutionPanel:UpdateSelectList(itemData)
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
function UIWeaponEvolutionPanel:UpdateSelectListView()
  local addExp = 0
  local count = 1
  local item
  self.mView.mText_SelectNum.text = #self.selectMaterial .. "/" .. UIWeaponGlobal.MaxMaterialCount
  for i = 1, #self.selectMaterial do
    local data = self.selectMaterial[i]
    addExp = addExp + data.offerExp * data.selectCount
  end
  self.curExp = addExp
  self.isCoinEnough = GlobalData.cash >= self.needCoin
  self.mView.mText_CostCoin.text = self.needCoin
  self.mView.mText_CostCoin.color = self.isCoinEnough and ColorUtils.BlackColor or ColorUtils.RedColor
  self:UpdateWeaponInfo(addExp)
end
function UIWeaponEvolutionPanel:UpdateWeaponInfo(exp)
  local sliderBeforeValue = 0
  local sliderAfterValue = 0
  if exp >= self.needExp then
    sliderBeforeValue = 0
    sliderAfterValue = 1
  else
    sliderBeforeValue = 0
    sliderAfterValue = exp / self.needExp
  end
  self.mView.mText_Exp.text = string_format("{0}/{1}", exp, self.needExp)
  self.mView.mText_AddExp.text = "+" .. exp
  self.mView.mImage_ExpAfter.fillAmount = sliderAfterValue
  self.mView.mImage_ExpBefore.fillAmount = sliderBeforeValue
  self.mView.mText_Exp.color = exp < self.needExp and ColorUtils.RedColor or ColorUtils.BlackColor
end
function UIWeaponEvolutionPanel:UpdateItemBrief(id, type)
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
function UIWeaponEvolutionPanel:OnClickFiltrate(type)
  if type then
    PlayerPrefs.SetInt(AccountNetCmdHandler.WeaponFilterType, type)
    if self.curFiltrate and self.curFiltrate.setId ~= type then
      self.curFiltrate:SetSelect(false)
    end
    self.curFiltrate = self.weaponListContent.filtrateList[type - 1]
    self.curFiltrate:SetSelect(true)
    self.weaponListContent.filtrateContent:SetFiltrateData(self.curFiltrate)
    self.weaponListContent:CloseItemSort()
  end
end
function UIWeaponEvolutionPanel:OnClickType(type)
  if type then
    if self.curType and self.curType.setId ~= type then
      self.curType:SetSelect(false)
    end
    self.curType = self.weaponListContent.weaponDropList[type]
    self.curType:SetSelect(true)
    self.weaponListContent.ui.mText_TypeName.text = self.curType:GetTypeName()
    self:RemoveFiltrateWeapon()
    self:UpdateEnhanceList()
    self.weaponListContent.ui.mVirtualList.verticalNormalizedPosition = 1
    self.weaponListContent:CloseItemType()
  end
end
function UIWeaponEvolutionPanel:OnClickEvolutionWeapon(item, index)
  self.evolutionWeapon = item.mData
  if UIWeaponPanel.curIndex ~= index then
    self.mView.mTrans_WeaponPreview:RefreshItem(UIWeaponPanel.curIndex)
    UIWeaponPanel.curIndex = index
  end
  setactive(item.mTrans_Select, true)
  setactive(item.mTrans_Choose, true)
  self:UpdateEvolutionWeapon()
end
function UIWeaponEvolutionPanel:OnClickItem(item)
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
  if self.curExp < self.needExp then
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
function UIWeaponEvolutionPanel:OnClickReduce(item)
  item:OnReduce()
  self:UpdateSelectList(item.mData)
end
function UIWeaponEvolutionPanel:CloseItemBrief()
  if self.itemBrief ~= nil then
    ComPropsDetailsHelper:Close()
  end
end
function UIWeaponEvolutionPanel:UpdateWeaponLock(id, isLock)
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
  self.weaponListContent.ui.mVirtualList:Refresh()
end
function UIWeaponEvolutionPanel:InvertSelectionItem(item)
  item.selectCount = item.selectCount - 1
  self:UpdateSelectList(item)
  self.weaponListContent.ui.mVirtualList:Refresh()
end
function UIWeaponEvolutionPanel:OnClickEvolution()
  if not self.coreItem:IsItemEnough() then
    local itemData = TableData.GetItemData(self.coreItem.itemId)
    UITipsPanel.Open(itemData, 0, true)
    UIUtils.PopupHintMessage(40042)
    return
  end
  if self.curExp < self.needExp then
    UIUtils.PopupHintMessage(40043)
    return
  end
  if not self.isCoinEnough then
    UIUtils.PopupHintMessage(40050)
    return
  end
  local selfColor = "#" .. TableDataBase.GlobalConfigData.GunQualityColor2[self.mData.Rank - 1]
  local evolutionColor = "#" .. TableDataBase.GlobalConfigData.GunQualityColor2[self.evolutionWeapon.rank - 1]
  local hint = string_format(TableData.GetHintById(40041), selfColor, self.mData.Rank, self.mData.Name, evolutionColor, self.evolutionWeapon.rank, self.evolutionWeapon.name.str)
  MessageBoxPanel.ShowDoubleType(hint, function()
    self:EvolutionWeapon()
  end)
end
function UIWeaponEvolutionPanel:EvolutionWeapon()
  local index = self:GetEvolutionIndex(self.evolutionWeapon.id)
  local itemList, weaponList = self:GetMaterialList()
  NetCmdWeaponData:SendGunWeaponEvolution(self.mData.id, index, weaponList, itemList, function(ret)
    if ret == ErrorCodeSuc then
      self:EvolutionCallback(self.mData.id)
    end
  end)
end
function UIWeaponEvolutionPanel:EvolutionCallback(gunId)
  local tempItem = self.returnItem
  local tempWeapon = self.evolutionWeapon
  setactive(self.mView.mTrans_Mask, true)
  CS.ProgressBarAnimationHelper.Play(self.mView.mImage_ExpBefore, 0, 1, 0.5, nil, function()
    setactive(self.mView.mTrans_Mask, false)
    UIWeaponGlobal:UpdateWeaponModelByConfig(self.mData)
    UIWeaponContent.UpdateWeaponContentDetail(gunId)
    UICharacterDetailPanel.OnWeaponChange()
    self:Close()
    UIManager.OpenUIByParam(UIDef.UIWeaponEvolutionSuccPanel, {
      tempWeapon.id,
      tempItem,
      function()
        local itemList = {}
        table.insert(itemList, {
          ItemId = tempWeapon.id,
          ItemNum = 1,
          RelateId = tempWeapon.default_maxlv
        })
        if tempItem.num > 0 then
          table.insert(itemList, {
            ItemId = tempItem.id,
            ItemNum = tempItem.num
          })
        end
        UIManager.OpenUIByParam(UIDef.UICommonReceivePanel, {itemList})
      end
    })
  end)
end
function UIWeaponEvolutionPanel:CheckCanSelectWeapon(data)
  if self:GetSelectMaterialCount() >= UIWeaponGlobal.MaxMaterialCount then
    return false
  elseif self.targetLevel >= self.mData.MaxLevel then
    return false
  end
  return true
end
function UIWeaponEvolutionPanel:IsInSelectList(itemData)
  for i, item in ipairs(self.selectMaterial) do
    if itemData.type == item.type and itemData.id == item.id then
      return item, i
    end
  end
  return nil
end
function UIWeaponEvolutionPanel:GetSelectMaterialCount()
  local count = 0
  for _, item in ipairs(self.selectMaterial) do
    count = count + item.selectCount
  end
  return count
end
function UIWeaponEvolutionPanel:GetEvolutionIndex(id)
  for i = 0, self.mData.AdvanceWeapon.Count - 1 do
    if self.mData.AdvanceWeapon[i] == id then
      return i
    end
  end
end
function UIWeaponEvolutionPanel:AutoSelect2()
  self:ResetMaterialList()
  local matList = {}
  local needExp = self.needExp - self.curExp
  for i, v in ipairs(self.weaponList) do
    if self:CanBeAutoSelect(v, self.curFiltrate.filtrateCfg) then
      table.insert(matList, v)
    end
  end
  table.sort(matList, function(a, b)
    if a.weaponType == b.weaponType then
      if a.stc_id == b.stc_id then
        return a.id < b.id
      else
        return a.stc_id < b.stc_id
      end
    else
      return a.weaponType < b.weaponType
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
  self.weaponListContent.ui.mVirtualList:Refresh()
  self:UpdateSelectListView()
end
function UIWeaponEvolutionPanel:AutoSelect()
  self:ResetMaterialList()
  local matList = {}
  local needExp = self.needExp - self.curExp
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
  self.weaponListContent.ui.mVirtualList:Refresh()
  self:UpdateSelectListView()
end
function UIWeaponEvolutionPanel:BeginLongPress(item)
  if self.curExp >= self.needExp then
    return
  end
  if item.mData.type == UIWeaponGlobal.MaterialType.Item then
    local needExp = self.needExp - self.curExp
    item.mData.selectCount = item.mData.selectCount + math.ceil(needExp / item.mData.offerExp)
    self.weaponListContent.ui.mVirtualList:Refresh()
    self:UpdateSelectList(item.mData)
    self:SetCurItem(item)
  end
end
function UIWeaponEvolutionPanel:BeginMinusLongPress(item)
  if item.mData.type == UIWeaponGlobal.MaterialType.Item then
    item.mData.selectCount = 0
    self.weaponListContent.ui.mVirtualList:Refresh()
    self:UpdateSelectList(item.mData)
    self:SetCurItem(item)
  end
end
function UIWeaponEvolutionPanel:CanBeAutoSelect(item, filter)
  if item.type == UIWeaponGlobal.MaterialType.Weapon and item.level <= 1 and not item.isLock and item.partCount <= 0 and 0 >= item.breakTimes and filter >= item.rank then
    return true
  end
  return false
end
function UIWeaponEvolutionPanel:ResetMaterialIndex(list)
  if list then
    for i, item in ipairs(list) do
      item.index = i - 1
    end
  end
end
function UIWeaponEvolutionPanel:SetCurItem(item)
  if self.curItem then
    self.curItem.isSelect = false
    self.weaponListContent.ui.mVirtualList:RefreshItem(self.curItem.index)
  end
  if item then
    item.mData.isSelect = true
    item:EnableSelectFrame(true)
    self.curItem = item.mData
  else
    self.curItem = nil
  end
end
function UIWeaponEvolutionPanel:GetMaterialList()
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
function UIWeaponEvolutionPanel:ResetMaterialList()
  for i, item in ipairs(self.selectMaterial) do
    item.selectCount = 0
  end
  self.selectMaterial = {}
  self:UpdateSelectListView()
  self:UpdateWeaponInfo(0)
  self.weaponListContent.ui.mVirtualList:Refresh()
end
function UIWeaponEvolutionPanel:RemoveFiltrateWeapon()
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
function UIWeaponEvolutionPanel:UpdateWeaponDataById(id)
  for i, item in ipairs(self.materialsList) do
    if item.type == UIWeaponGlobal.MaterialType.Weapon and item.id == id then
      self.materialsList[i] = UIWeaponGlobal:GetMaterialSimpleData(NetCmdWeaponData:GetWeaponById(id), UIWeaponGlobal.MaterialType.Weapon)
      return self.materialsList[i]
    end
  end
end
