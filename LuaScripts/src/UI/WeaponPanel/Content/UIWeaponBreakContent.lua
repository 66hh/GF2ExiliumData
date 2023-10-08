require("UI.UIBasePanel")
require("UI.WeaponPanel.UIWeaponPanelView")
UIWeaponBreakContent = class("UIWeaponBreakContent", UIBasePanel)
UIWeaponBreakContent.__index = UIWeaponBreakContent
function UIWeaponBreakContent:ctor(data, weaponPanel)
  self.mView = nil
  self.mData = data
  self.weaponPanel = weaponPanel
  self.breakItem = TableData.GlobalSystemData.WeaponLevelBreakItem
  self.breakLevel = TableData.GlobalSystemData.WeaponLevelPerBreak
  self.weaponLowRank = TableData.GlobalSystemData.WeaponLowRank
  self.materialsList = {}
  self.itemList = {}
  self.selectMaterial = {}
  self.selectItemList = {}
  self.isLevelUpMode = false
  self.propertyList = {}
  self.itemBrief = nil
  self.recordLv = 0
  self.hasReturn = false
  self.needUpdate = true
  self.selectItem = nil
end
function UIWeaponBreakContent:InitCtrl(root, weaponList)
  self.mView = UIWeaponBreakContentView.New()
  self.mView:InitCtrl(root, weaponList)
  self.weaponListContent = weaponList
  self.sortContent = UIWeaponSortItem.New()
  for _, btn in ipairs(self.mView.addBtnList) do
    UIUtils.GetButtonListener(btn.gameObject).onClick = function()
      self:OnClickBreak()
    end
  end
  UIUtils.GetButtonListener(self.mView.mBtn_LevelUp.gameObject).onClick = function()
    self:OnClickLevelUp()
  end
  self.isLevelUpMode = false
end
function UIWeaponBreakContent:OnClose()
  self.mView:OnClose()
  if self.sortContent then
    self.sortContent:OnRelease()
  end
  if self.selectItem then
    self.selectItem:OnRelease(true)
  end
  self:ReleaseCtrlTable(self.propertyList)
end
function UIWeaponBreakContent:OnRelease()
  self:ReleaseTimers()
end
function UIWeaponBreakContent:InitVirtualList()
  function self.mView.mVirtualList.itemProvider()
    local item = self:MaterialItemProvider()
    return item
  end
  function self.mView.mVirtualList.itemRenderer(index, rendererData)
    self:MaterialItemRenderer(index, rendererData)
  end
end
function UIWeaponBreakContent:MaterialItemProvider()
  local itemView = UICommonItem.New()
  itemView:InitCtrl()
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIWeaponBreakContent:MaterialItemRenderer(index, rendererData)
  local itemData = self.materialsList[index + 1]
  local item = rendererData.data
  item:SetMaterialData(itemData, not self:CheckCanSelectWeapon(itemData))
  UIUtils.GetButtonListener(item.ui.mBtn_Select.gameObject).onClick = function()
    self:OnClickItem(item)
  end
  UIUtils.GetButtonListener(item.ui.mBtn_Reduce.gameObject).onClick = function()
    self:OnClickReduce(item)
  end
end
function UIWeaponBreakContent:CheckCanSelectWeapon(data)
  if self:GetSelectMaterialCount() >= UIWeaponGlobal.MaxBreakCount then
    return false
  end
  return true
end
function UIWeaponBreakContent:OnClickItem(item)
  if self:GetSelectMaterialCount() >= GlobalConfig.GunMaxStar - self.mData.BreakTimes then
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
  if item:IsBreakItem(self.mData.stc_id) then
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
  else
    UIUtils.PopupHintMessage(30021)
    return
  end
  if item.mData.selectCount > 0 then
    self:UpdateItemBrief(item.mData.id, item.mData.type)
  else
    self:CloseItemBrief()
  end
  self:SetCurItem(item)
  self:UpdateSelectList(item.mData)
  self:UpdatePropertyList()
  self:UpdatePropChangeValue()
end
function UIWeaponBreakContent:SetCurItem(item)
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
function UIWeaponBreakContent:OnClickReduce(item)
  item:OnReduce()
  self:UpdateSelectList(item.mData)
end
function UIWeaponBreakContent:IsInSelectList(itemData)
  for _, item in ipairs(self.selectMaterial) do
    if itemData.type == item.type and itemData.id == item.id then
      return item
    end
  end
  return nil
end
function UIWeaponBreakContent:GetSelectMaterialCount()
  local count = 0
  for _, item in ipairs(self.selectMaterial) do
    count = count + item.selectCount
  end
  return count
end
function UIWeaponBreakContent:UpdateSelectList(itemData)
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
function UIWeaponBreakContent:UpdateSelectListView()
  if self.selectItem == nil then
    self.selectItem = UIWeaponMaterialItemS.New()
    self.selectItem:InitCtrl(self.mView.mTrans_MaterialList)
    self.selectItem.mBtn_Item.interactable = false
  end
  if #self.selectMaterial > 0 then
    self.selectItem:SetData(self.selectMaterial[1])
    setactive(self.mView.mTrans_MaterialList.parent, true)
    self.selectItem.mText_Count.text = #self.selectMaterial
  else
    setactive(self.mView.mTrans_MaterialList.parent, false)
  end
end
function UIWeaponBreakContent:InvertSelectionItem(item)
  item.selectCount = item.selectCount - 1
  self:UpdateSelectList(item)
  self.mView.mVirtualList:Refresh()
end
function UIWeaponBreakContent:UpdatePanel()
  if not self.needUpdate then
    self.needUpdate = true
    return
  end
  local typeData = TableData.listGunWeaponTypeDatas:GetDataById(self.mData.Type)
  self.mView.mText_Name.text = self.mData.Name
  self.mView.mText_Type.text = typeData.name.str
  self.selectMaterial = {}
  self:UpdateSelectListView()
  self:UpdateSkill(self.mData.Skill, self.mData.NextSkill)
  self:UpdatePropertyList()
  self:UpdateWeaponInfo()
  self:UpdateStar(self.mData.BreakTimes, self.mData.MaxBreakTime)
  self:UpdateMaxBreakTime()
end
function UIWeaponBreakContent:ResetWeaponList()
  UIUtils.GetButtonListener(self.mView.mBtn_CloseList.gameObject).onClick = function()
    self:CloseBreak()
  end
  self.pointer = UIUtils.GetPointerClickHelper(self.mView.mTrans_ItemBrief.gameObject, function()
    self:CloseItemBrief()
  end, self.mView.mTrans_ItemBrief.gameObject)
  self:InitVirtualList()
  self.isLevelUpMode = false
end
function UIWeaponBreakContent:UpdateStar(star, maxStar)
  self.mView.stageItem:ResetMaxNum(maxStar)
  self.mView.stageItem:SetData(star)
end
function UIWeaponBreakContent:UpdateSkill(skill1, skill2)
  if skill2 == nil then
    for i = 1, 2 do
      local skill = self.mView.skillList[i]
      skill.data = nil
      setactive(skill.obj, false)
    end
    return
  end
  local skill = self.mView.skillList[1]
  if skill1 then
    skill.data = skill1
    skill.txtName.text = skill1.name.str
    skill.txtLv.text = GlobalConfig.SetLvText(skill1.level)
    skill.txtDesc.text = skill1.description.str
  else
    skill.data = nil
    setactive(skill.obj, false)
  end
  skill = self.mView.skillList[2]
  if skill2 then
    skill.data = skill2
    skill.txtName.text = skill2.name.str
    skill.txtLv.text = GlobalConfig.SetLvText(skill2.level)
    skill.txtDesc.text = skill2.description.str
  else
    skill.data = nil
    setactive(skill.obj, false)
  end
end
function UIWeaponBreakContent:UpdatePropertyList()
  local attrList = {}
  local nextBreak = math.min(self.mData.BreakTimes + self:GetSelectMaterialCount(), self.mData.MaxBreakTime)
  local expandList = self.mData:GetBreakUpProp(nextBreak)
  for i = 0, expandList.Count - 1 do
    local lanData = TableData.GetPropertyDataByName(expandList[i], 1)
    if lanData.type == 1 then
      local value = self.mData:GetPropertyByLevelAndSysName(lanData.sys_name, self.mData.Level, self.mData.BreakTimes, false)
      local attr = {}
      attr.propData = lanData
      attr.value = value
      table.insert(attrList, attr)
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
  end
end
function UIWeaponBreakContent:UpdateMaxBreakTime()
  setactive(self.mView.mTrans_CostItemContent, not self.mData.IsReachMaxBreak)
  setactive(self.mView.mTrans_CostHint, not self.mData.IsReachMaxBreak)
  setactive(self.mView.mBtn_LevelUp.gameObject, not self.mData.IsReachMaxBreak)
  setactive(self.mView.mBtn_MaxLevelUp.gameObject, self.mData.IsReachMaxBreak)
end
function UIWeaponBreakContent:OnClickBreak()
  if self.isLevelUpMode then
    return
  end
  self.isLevelUpMode = true
  self:UpdateEnhanceList()
  setactive(self.mView.mTrans_EnhanceContent, true)
  setactive(self.weaponPanel.mView.ui.mTrans_Left, false)
end
function UIWeaponBreakContent:CloseBreak()
  if self.mView.mListAniTime and self.mView.mListAnimator then
    self.mView.mListAnimator:SetTrigger("Fadeout")
    self:DelayCall(self.mView.mListAniTime.m_FadeOutTime, function()
      self.isLevelUpMode = false
      self:UpdatePanel()
      setactive(self.mView.mTrans_EnhanceContent, false)
      setactive(self.weaponPanel.mView.ui.mTrans_Left, true)
    end)
  else
    self.isLevelUpMode = false
    self:UpdatePanel()
    setactive(self.mView.mTrans_EnhanceContent, false)
    setactive(self.weaponPanel.mView.ui.mTrans_Left, true)
  end
end
function UIWeaponBreakContent:UpdateEnhanceList()
  local list = NetCmdWeaponData:GetBreakWeaponList(self.mData.id)
  self.materialsList = self:UpdateMaterialList(list)
  local sortType = UIWeaponGlobal.MaterialSortCfg[UIWeaponGlobal.MaterialSortType.Rank]
  self:UpdateListBySort(sortType)
  self:ResetMaterialIndex(self.materialsList)
  setactive(self.mView.mTrans_Empty, #self.materialsList <= 0)
end
function UIWeaponBreakContent:UpdateListBySort(sortConfig)
  local sortFunc = self.sortContent:GetEnhanceSortFunc(1, sortConfig, true)
  table.sort(self.materialsList, sortFunc)
  self.mView.mVirtualList.numItems = #self.materialsList
  self.mView.mVirtualList:Refresh()
end
function UIWeaponBreakContent:UpdateMaterialList(list)
  if list then
    self.itemList = {}
    self.weaponList = {}
    local itemList = {}
    local data = UIWeaponGlobal:GetMaterialSimpleData(self.breakItem, UIWeaponGlobal.MaterialType.Item)
    if data then
      data.isBreakItem = true
      table.insert(itemList, data)
      table.insert(self.itemList, data)
    end
    for i = 0, list.Count - 1 do
      local data = UIWeaponGlobal:GetMaterialSimpleData(list[i], UIWeaponGlobal.MaterialType.Weapon)
      table.insert(itemList, data)
      if data.level == 0 and data.rank <= self.weaponLowRank then
        table.insert(self.weaponList, data)
      end
    end
    return itemList
  end
end
function UIWeaponBreakContent:UpdateWeaponInfo()
  self:UpdatePropChangeValue()
end
function UIWeaponBreakContent:UpdatePropChangeValue()
  for _, item in ipairs(self.propertyList) do
    local value = 0
    if item and item.mData then
      local propName = item.mData.sys_name
      local nextBreak = math.min(self.mData.BreakTimes + self:GetSelectMaterialCount(), self.mData.MaxBreakTime)
      value = self.mData:GetPropertyByLevelAndSysName(propName, self.mData.Level, nextBreak, false)
      item:SetValueUp(value)
    end
  end
end
function UIWeaponBreakContent:OnClickLevelUp()
  local itemList, weaponList = self:GetMaterialList()
  if 1 <= #weaponList then
    local lastBreakTimes = self.mData.BreakTimes
    NetCmdWeaponData:SendGunWeaponBreak(self.mData.id, weaponList, function(ret)
      self:LevelUpCallback(ret, lastBreakTimes)
    end)
  else
    UIUtils.PopupHintMessage(40019)
    return
  end
end
function UIWeaponBreakContent:LevelUpCallback(ret, lastBreakTimes)
  if ret == ErrorCodeSuc then
    local lvDate = CommonLvUpData.New()
    lvDate:SetWeaponBreakData(self.propertyList, self.mData.MaxLevel, lastBreakTimes, self.mData.BreakTimes, self.mData.Skill)
    UIManager.OpenUIByParam(UIDef.UIWeaponBreakSuccPanel, {
      lvDate,
      function()
        if self.hasReturn then
          UIManager.OpenUIByParam(UIDef.UICommonReceivePanel)
        end
      end
    })
    self.mData = NetCmdWeaponData:GetWeaponById(self.mData.id)
    self:UpdatePanel()
    self:UpdateEnhanceList()
    setactive(self.weaponPanel.mView.ui.mTrans_Left, true)
    self.weaponPanel:RefreshPanel()
  end
end
function UIWeaponBreakContent:GetMaterialList()
  local itemList = {}
  local weaponList = {}
  for _, item in ipairs(self.selectMaterial) do
    if item.type == UIWeaponGlobal.MaterialType.Item then
      itemList[item.id] = item.selectCount
    elseif item.type == UIWeaponGlobal.MaterialType.Weapon then
      if not self.hasReturn then
        self.hasReturn = item.level > 1 or item.breakTimes > 0
      end
      table.insert(weaponList, item.id)
    end
  end
  return itemList, weaponList
end
function UIWeaponBreakContent:UpdateItemBrief(id, type)
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
function UIWeaponBreakContent:CloseItemBrief()
  ComPropsDetailsHelper:Close()
end
function UIWeaponBreakContent:UpdateWeaponLock(id, isLock)
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
function UIWeaponBreakContent:ResetMaterialIndex(list)
  if list then
    for i, item in ipairs(list) do
      item.index = i - 1
    end
  end
end
function UIWeaponBreakContent:UpdateWeaponDataById(id)
  for i, item in ipairs(self.materialsList) do
    if item.type == UIWeaponGlobal.MaterialType.Weapon and item.id == id then
      self.materialsList[i] = UIWeaponGlobal:GetMaterialSimpleData(NetCmdWeaponData:GetWeaponById(id), UIWeaponGlobal.MaterialType.Weapon)
      return self.materialsList[i]
    end
  end
end
