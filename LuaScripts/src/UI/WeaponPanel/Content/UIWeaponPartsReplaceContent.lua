UIWeaponPartsReplaceContent = class("UIWeaponPartsReplaceContent", UIBaseCtrl)
UIWeaponPartsReplaceContent.__index = UIWeaponPartsReplaceContent
local self = UIWeaponPartsReplaceContent
function UIWeaponPartsReplaceContent:ctor()
  UIWeaponPartsReplaceContent.super.ctor(self)
  self.partData = nil
  self.type = 0
  self.slotId = 0
  self.weaponData = 0
  self.partDetail = nil
  self.compareDetail = nil
  self.weaponPartsList = {}
  self.weaponPartDropList = nil
  self.curContent = 0
  self.isCompareMode = false
  self.curReplacePart = nil
  self.sortContent = nil
  self.sortList = {}
  self.curSort = nil
  self.weaponPartContent = nil
  self.curType = nil
  self.replaceCallback = nil
  self.lockCallback = nil
  self.closeCallback = nil
  self.changePartselectCallback = nil
  self.clickTabList = false
  self.sortNum = 4
end
function UIWeaponPartsReplaceContent:OnClose()
end
function UIWeaponPartsReplaceContent:InitCtrl(parent, parentObj)
  self.mParentObj = parentObj
  local obj = instantiate(UIUtils.GetGizmosPrefab("Character/ChrWeaponPartsDetailsItemV2.prefab", self))
  self.tempblockobj = obj
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj.transform, self.ui)
  self:SetRoot(obj.transform)
  self:__InitCtrl()
end
function UIWeaponPartsReplaceContent:__InitCtrl()
  self.partDetail = UIBarrackWeaponPartInfoItem.New()
  self.partDetail:InitCtrl(self.ui.mTrans_WeaponPartDetail, function(id, isLock)
    self:UpdateWeaponPartLock(id, isLock)
  end)
  function self.lockCompareCallback(id, isLock)
    self:UpdateWeaponPartLock(id, isLock)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Enhance.gameObject).onClick = function()
    self:OnClickEnhance()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Equip.gameObject).onClick = function()
    self:OnClickReplace()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Replace.gameObject).onClick = function()
    self:OnClickReplace()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Uninstall.gameObject).onClick = function()
    self:OnClickUninstall()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    self:OnClickBack()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_SuitTipsClose.gameObject).onClick = function()
    self:OnClickSuitTipsClose()
  end
  self.ui.mToggle_DetailCompare.onValueChanged:AddListener(function(isOn)
    self:OnClickCompare()
  end)
  self:InitVirtualList()
  self:InitSortContent()
  self:InitDropWeaponTypeList()
end
function UIWeaponPartsReplaceContent:SetData(data, type, weaponId, slotId)
  self.partData = nil
  self.type = nil
  self.curReplacePart = nil
  self.slotId = slotId
  self.weaponData = NetCmdWeaponData:GetWeaponById(weaponId)
  self:ResetTypeFiltareList()
  if data then
    self.partData = NetCmdWeaponPartsData:GetWeaponModById(data.id)
    self.type = self.partData.type
    self:UpdateReplaceList()
  elseif type then
    self.type = type
    self:UpdateReplaceList()
  end
  if self.curReplacePart then
    self:UpdateReplaceDetail(self.curReplacePart.id)
  else
    self:UpdateReplaceDetail(nil)
  end
  self:UpdateButton()
  self:UpdateCompareDetail()
  self:UpdateWeaponPartType()
  self:UpdateReplaceListCount()
  setactive(self.ui.mTrans_Empty, #self.weaponPartsList <= 0)
end
function UIWeaponPartsReplaceContent:SetReplaceCallback(callback)
  self.replaceCallback = callback
end
function UIWeaponPartsReplaceContent:SetLockCallback(callback)
  self.lockCallback = callback
end
function UIWeaponPartsReplaceContent:SetChangePartselectCallback(callback)
  self.changePartselectCallback = callback
end
function UIWeaponPartsReplaceContent:SetCloseCallback(callback)
  self.closeCallback = callback
end
function UIWeaponPartsReplaceContent:InitVirtualList()
  function self.ui.ReplaceVirtual.itemProvider()
    local item = self:PartItemProvider()
    return item
  end
  function self.ui.ReplaceVirtual.itemRenderer(index, rendererData)
    self:PartItemRenderer(index, rendererData)
  end
end
function UIWeaponPartsReplaceContent:InitSortContent()
  if self.sortContent == nil then
    self.sortContent = UIWeaponPartSortItem.New()
    self.sortContent:InitCtrl(self.ui.mTrans_Sort, true)
    UIUtils.GetButtonListener(self.sortContent.mBtn_Sort.gameObject).onClick = function()
      self:OnClickSortList()
    end
    UIUtils.GetButtonListener(self.sortContent.mBtn_Ascend.gameObject).onClick = function()
      self:OnClickAscend()
    end
    UIUtils.GetButtonListener(self.sortContent.Btn_TypeScreen.gameObject).onClick = function()
      self:OnClickTypeList()
    end
  end
  local sortList = self:InstanceUIPrefab("UICommonFramework/ComScreenDropdownListItemV2.prefab", self.ui.mTrans_SortList)
  self.ui.mTrans_SortListObj = sortList
  local parent = UIUtils.GetRectTransform(sortList, "Content")
  for i = 1, self.sortNum do
    local obj = self:InstanceUIPrefab("Character/ChrEquipSuitDropdownItemV2.prefab", parent)
    if obj then
      local sort = {}
      sort.obj = obj
      sort.btnSort = UIUtils.GetButton(obj)
      sort.txtName = UIUtils.GetText(obj, "GrpText/Text_SuitName")
      sort.sortType = i
      sort.hintID = 101000 + i
      sort.sortCfg = UIWeaponGlobal.WeaponPartsSortCfg[i]
      sort.isAscend = false
      sort.grpset = obj.transform:Find("GrpSel")
      sort.txtName.text = TableData.GetHintById(sort.hintID)
      self.textcolor = obj.transform:GetComponent("TextImgColor")
      self.beforecolor = self.textcolor.BeforeSelected
      self.aftercolor = self.textcolor.AfterSelected
      UIUtils.GetButtonListener(sort.btnSort.gameObject).onClick = function()
        self:OnClickSort(sort.sortType)
      end
      table.insert(self.sortList, sort)
      if sort ~= self.curSort then
        sort.txtName.color = self.beforecolor
        setactive(sort.grpset, false)
      else
        sort.txtName.color = self.aftercolor
        setactive(sort.grpset, true)
      end
    end
  end
  if self.mParentObj == nil then
    UIUtils.GetUIBlockHelper(self.tempblockobj.transform, self.ui.mTrans_SortList, function()
      self:CloseItemSort()
    end)
  else
    UIUtils.GetUIBlockHelper(self.mParentObj, self.ui.mTrans_SortList, function()
      self:CloseItemSort()
    end)
  end
end
function UIWeaponPartsReplaceContent:InitDropWeaponTypeList()
  local sortList = self:InstanceUIPrefab("UICommonFramework/ComScreenDropdownListItemV2.prefab", self.ui.mTrans_DropTypeList)
  self.ui.mTrans_DropTypeListObj = sortList
  local parent = UIUtils.GetRectTransform(sortList, "Content")
  if self.weaponPartDropList == nil then
    self.weaponPartDropList = {}
    local list = UIWeaponGlobal:GetWeaponPartSuitList()
    for i = 0, #list do
      local item
      if i == 0 then
        item = UIBarrackSuitDropdownItem.New()
        item:InitCtrl(parent)
        item:SetWeaponPartSuitData(0)
      else
        local data = list[i]
        item = UIBarrackSuitDropdownItem.New()
        item:InitCtrl(parent)
        item:SetWeaponPartSuitData(data.id)
      end
      table.insert(self.weaponPartDropList, item)
    end
  end
  UIUtils.GetUIBlockHelper(self.mUIRoot.parent, self.ui.mTrans_DropTypeList, function()
    self:CloseItemType()
  end)
  for i, type in ipairs(self.weaponPartDropList) do
    UIUtils.GetButtonListener(type.mBtn_Suit.gameObject).onClick = function()
      self:OnClickType(i, type.setId)
    end
    setactive(self.weaponPartDropList[i].mUIRoot, true)
  end
end
function UIWeaponPartsReplaceContent:ResetTypeFiltareList()
  self.curType = self.weaponPartDropList[1]
  for i, type in ipairs(self.weaponPartDropList) do
    if self.weaponPartDropList[i] ~= self.curType then
      self.weaponPartDropList[i]:SetSelect(false)
    else
      self.weaponPartDropList[i]:SetSelect(true)
    end
  end
end
function UIWeaponPartsReplaceContent:UpdateReplaceListCount()
  for i, item in ipairs(self.weaponPartDropList) do
    item:UpdatePartCount(self.type)
  end
end
function UIWeaponPartsReplaceContent:OnClickType(type, setId)
  if type then
    if self.curType and self.curType.setId ~= setId then
      self.curType:SetSelect(false)
    end
    self.curType = self.weaponPartDropList[type]
    self.curType:SetSelect(true)
    self:UpdateReplaceList()
    self.ui.ReplaceVirtual.verticalNormalizedPosition = 1
    self:CloseItemType()
    setactive(self.ui.mTrans_SuitSelectedTips, type ~= 1)
    self.ui.mText_SuitSelectedName.text = self.curType.mText_Name.text
  end
end
function UIWeaponPartsReplaceContent:CloseItemType()
  setactive(self.ui.mTrans_DropTypeList, false)
  self.clickTabList = false
end
function UIWeaponPartsReplaceContent:OnClickTypeList()
  if self.clickTabList then
    self:CloseItemSort()
    self:CloseItemType()
    self.clickTabList = false
    return
  end
  setactive(self.ui.mTrans_DropTypeList, true)
  setactive(self.ui.mTrans_DropTypeListObj, true)
  setactive(self.ui.mTrans_SortListObj, false)
  self.clickTabList = true
end
function UIWeaponPartsReplaceContent:RotateWeapon()
  local trans = self.weaponModel.transform
  CS.UITweenManager.PlayRotationTweenLoop(trans, 8)
end
function UIWeaponPartsReplaceContent:OnClickEnhance()
  local partData
  if self.curReplacePart ~= nil then
    partData = self.curReplacePart.id
  else
    partData = self.partData.id
  end
  UIWeaponGlobal:EnableWeaponModel(false)
  UIManager.OpenUIByParam(UIDef.UIWeaponPartPanel, {
    partData,
    UIWeaponGlobal.WeaponPartPanelTab.Enhance
  })
end
function UIWeaponPartsReplaceContent:OnClickReplace()
  self:ReplaceWeaponPart()
end
function UIWeaponPartsReplaceContent:OnClickUninstall()
  if self.curReplacePart then
    local index = self.slotId
    NetCmdWeaponPartsData:ReqWeaponPartBelong(0, self.weaponData.id, index, function(ret)
      self:OnUninstallCallback(ret)
    end)
  end
end
function UIWeaponPartsReplaceContent:OnClickBack()
  self:OnClickSuitTipsClose()
  self.partDetail:SetVisible(false)
  if self.ui.mAnimator_Root then
    self.ui.mAnimator_Root:ResetTrigger("FadeIn")
    self.ui.mAnimator_Root:SetTrigger("FadeOut")
    local length = CSUIUtils.GetClipLengthByEndsWith(self.ui.mAnimator_Root, "FadeOut")
    TimerSys:DelayCall(length, function()
      setactive(self.mUIRoot.gameObject, false)
    end)
  else
    setactive(self.mUIRoot.gameObject, false)
  end
  if self.closeCallback then
    self.closeCallback()
  end
end
function UIWeaponPartsReplaceContent:UpdateReplaceContent()
  self:UpdateReplaceList()
  self:UpdateCompareDetail()
  self.isCompareMode = false
  self:UpdateButton()
end
function UIWeaponPartsReplaceContent:ReplaceWeaponPart()
  if self.curReplacePart.weaponId > 0 then
    local weaponData = NetCmdWeaponData:GetWeaponById(self.curReplacePart.weaponId)
    local weaponName = weaponData.Name
    local rankColor = TableDataBase.GlobalConfigData.GunQualityColor2[weaponData.Rank - 1]
    local colorName = string_format("<color=#{0}>{1}</color>", rankColor, weaponName)
    MessageBoxPanel.ShowDoubleType(string_format(TableData.GetHintById(102216), colorName), function()
      self:OnReplaceWeaponPart()
    end)
    FacilityBarrackGlobal.needUpdate = false
  else
    self:OnReplaceWeaponPart()
  end
end
function UIWeaponPartsReplaceContent:OnReplaceWeaponPart()
  if self.curReplacePart then
    local index = self.slotId
    NetCmdWeaponPartsData:ReqWeaponPartBelong(self.curReplacePart.id, self.weaponData.id, index, function(ret)
      self:OnReplaceCallback(ret)
    end)
  end
end
function UIWeaponPartsReplaceContent:OnReplaceCallback(ret)
  if ret == ErrorCodeSuc then
    self.partData = NetCmdWeaponPartsData:GetWeaponModById(self.curReplacePart.id)
    self.curReplacePart = nil
    if self.isCompareMode then
      self.ui.mToggle_DetailCompare.isOn = false
    end
    self:UpdateReplaceContent()
    self:UpdateReplaceDetail(self.partData.id)
    if self.replaceCallback then
      self.replaceCallback()
    end
    UIUtils.PopupPositiveHintMessage(102242)
  end
end
function UIWeaponPartsReplaceContent:OnUninstallCallback(ret)
  if ret == ErrorCodeSuc then
    self.curReplacePart = nil
    self.partData = nil
    if self.isCompareMode then
      self.ui.mToggle_DetailCompare.isOn = false
    end
    self:UpdateReplaceContent()
    self:UpdateReplaceDetail(nil)
    if self.replaceCallback then
      self.replaceCallback()
    end
  end
end
function UIWeaponPartsReplaceContent:OnClickCompare(isOn)
  self.isCompareMode = not self.isCompareMode
  setactive(self.ui.mTrans_CompareDetail, self.isCompareMode)
end
function UIWeaponPartsReplaceContent:OnClickSortList()
  if self.clickTabList then
    self:CloseItemSort()
    self:CloseItemType()
    return
  end
  setactive(self.ui.mTrans_SortList, true)
  setactive(self.ui.mTrans_DropTypeListObj, false)
  setactive(self.ui.mTrans_SortListObj, true)
  self.clickTabList = true
end
function UIWeaponPartsReplaceContent:CloseItemSort()
  setactive(self.ui.mTrans_SortList, false)
  self.clickTabList = false
end
function UIWeaponPartsReplaceContent:OnClickSort(type)
  if type then
    if self.curSort and self.curSort.sortType ~= type then
      PlayerPrefs.SetInt(AccountNetCmdHandler.WeaponPartFilterType, type)
      self.curSort.txtName.color = self.beforecolor
      setactive(self.curSort.grpset, false)
    end
    self.curSort = self.sortList[type]
    self.curSort.isAscend = false
    self.curSort.txtName.color = self.aftercolor
    setactive(self.curSort.grpset, true)
    self.sortContent:SetReplaceData(self.curSort)
    self:UpdateListBySort()
    self:CloseItemSort()
  end
end
function UIWeaponPartsReplaceContent:OnClickAscend()
  if self.curSort then
    self.curSort.isAscend = not self.curSort.isAscend
    self.sortContent:SetReplaceData(self.curSort)
    self:UpdateListBySort()
  end
end
function UIWeaponPartsReplaceContent:UpdateReplaceList()
  local weaponPartsList = NetCmdWeaponPartsData:GetReplaceWeaponPartsListByType(self.type, self.curType.setId)
  self.weaponPartsList = self:UpdateWeaponPartsList(weaponPartsList)
  setactive(self.ui.mTrans_Empty, #self.weaponPartsList <= 0)
  if PlayerPrefs.GetInt(AccountNetCmdHandler.WeaponPartFilterType) == 0 then
    PlayerPrefs.SetInt(AccountNetCmdHandler.WeaponPartFilterType, 1)
  end
  local filterType = PlayerPrefs.GetInt(AccountNetCmdHandler.WeaponPartFilterType)
  if filterType > self.sortNum then
    filterType = 1
  end
  self:OnClickSort(filterType)
end
function UIWeaponPartsReplaceContent:UpdateListBySort()
  local sortFunc = self.sortContent.sortFunc
  table.sort(self.weaponPartsList, sortFunc)
  self.ui.ReplaceVirtual.numItems = #self.weaponPartsList
  self.ui.ReplaceVirtual:Refresh()
  self:ResetWeaponPartIndex(self.weaponPartsList)
  self.ui.ReplaceVirtual.verticalNormalizedPosition = 1
end
function UIWeaponPartsReplaceContent:UpdateWeaponPartsList(list)
  if list then
    local itemList = {}
    for i = 0, list.Count - 1 do
      local data = UIWeaponGlobal:GetWeaponModSimpleData(list[i])
      if self.partData and data.id == self.partData.id then
        self.curReplacePart = data
        data.isSelect = true
      end
      table.insert(itemList, data)
    end
    return itemList
  end
end
function UIWeaponPartsReplaceContent:ResetWeaponPartIndex(list)
  if list then
    for i, item in ipairs(list) do
      item.index = i - 1
    end
  end
end
function UIWeaponPartsReplaceContent:GetPartDataById(id)
  for i, part in ipairs(self.weaponPartsList) do
    if part.id == id then
      return part
    end
  end
  return nil
end
function UIWeaponPartsReplaceContent:PartItemProvider()
  local itemView = UICommonItem.New()
  itemView:InitCtrl()
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIWeaponPartsReplaceContent:PartItemRenderer(index, renderDataItem)
  local itemData = self.weaponPartsList[index + 1]
  local item = renderDataItem.data
  item:SetPartData(itemData)
  if self.partData then
    item:SetNowEquip(self.partData.id == itemData.id)
  else
    item:SetNowEquip(false)
  end
  UIUtils.GetButtonListener(item.ui.mBtn_Select.gameObject).onClick = function()
    self:OnClickWeaponPart(item)
  end
end
function UIWeaponPartsReplaceContent:OnClickWeaponPart(part)
  if self.curReplacePart then
    if self.curReplacePart.id == part.partData.id then
      return
    end
    self.curReplacePart.isSelect = false
    self.ui.ReplaceVirtual:RefreshItem(self.curReplacePart.index)
  end
  part.partData.isSelect = true
  part:SetItemSelect(true)
  self.curReplacePart = part.partData
  local suitCount = self.weaponData:GetSuitCountById(part.partData.suitId, self.slotId)
  self:UpdateReplaceDetail(part.partData.id, suitCount + 1)
  self:UpdateButton()
  local previewWeaponCmdData = self.weaponData:GetPreviewPart(part.partData.id)
  UIWeaponGlobal:UpdateWeaponModelByConfig(previewWeaponCmdData, false, false)
  UIWeaponGlobal:PutUpWeaponForObservation(self.weaponData.StcData, self.slotId)
  UIWeaponGlobal:SetWeaponEffectShow(false)
  if self.changePartselectCallback ~= nil then
    self.changePartselectCallback()
  end
end
function UIWeaponPartsReplaceContent:UpdateButton()
  if self.partData then
    setactive(self.ui.mTrans_CompareDetail, self.isCompareMode and self.curReplacePart.id ~= self.partData.id)
    setactive(self.ui.mTrans_Compare.gameObject, self.curReplacePart.id ~= self.partData.id)
    setactive(self.ui.mTrans_ReplaceBtn, self.curReplacePart.id ~= self.partData.id)
    setactive(self.ui.mTrans_Uninstall, self.curReplacePart.id == self.partData.id)
    setactive(self.ui.mTrans_EquipBtn, false)
    setactive(self.ui.mTrans_EmptyInfo, false)
  else
    setactive(self.ui.mTrans_Compare.gameObject, false)
    setactive(self.ui.mTrans_CompareDetail, false)
    setactive(self.ui.mTrans_ReplaceBtn, false)
    setactive(self.ui.mTrans_Uninstall, false)
    setactive(self.ui.mTrans_EquipBtn, self.curReplacePart ~= nil)
    setactive(self.ui.mTrans_EmptyInfo, self.curReplacePart == nil)
  end
end
function UIWeaponPartsReplaceContent:UpdateReplaceDetail(partId, suitCount)
  if partId == nil then
    self.partDetail:SetData(nil)
    setactive(self.ui.mTrans_Enhance.gameObject, false)
  else
    local data = NetCmdWeaponPartsData:GetWeaponModById(partId)
    if data then
      self.partDetail:SetData(data, suitCount)
      setactive(self.ui.mTrans_Enhance.gameObject, data.isCanLevelUp)
    end
  end
end
function UIWeaponPartsReplaceContent:UpdateCompareDetail()
  if self.partData then
    ComPropsDetailsHelper:InitWeaponPartsData(self.ui.mTrans_CompareDetail.transform, self.partData.id, self.lockCompareCallback, true)
    setactive(self.ui.mTrans_CompareDetail, false)
  end
end
function UIWeaponPartsReplaceContent:UpdateWeaponPartLock(id, isLock)
  local data
  for _, item in ipairs(self.weaponPartsList) do
    if item.id == id then
      data = item
      item.isLock = isLock
      break
    end
  end
  if data then
    self.ui.ReplaceVirtual:RefreshItem(data.index)
  end
  if self.lockCallback then
    self.lockCallback(id)
  end
end
function UIWeaponPartsReplaceContent:UpdateWeaponPartType()
  local typeData = TableData.listWeaponModTypeDatas:GetDataById(self.type)
  self.ui.mText_WeaponPartType.text = string_format(TableData.GetHintById(40029), typeData.name.str)
end
function UIWeaponPartsReplaceContent:UpdateWeaponPartPos()
  if self.curReplacePart then
    self.ui.ReplaceVirtual:DelayScrollToPosByIndex(self.curReplacePart.index + 1)
  end
end
function UIWeaponPartsReplaceContent:OnClickSuitTipsClose()
  setactive(self.ui.mTrans_SuitSelectedTips, false)
  if self.curType then
    self.curType:SetSelect(false)
  end
  self.curType = self.weaponPartDropList[1]
  self.curType:SetSelect(true)
  self:UpdateReplaceList()
  self.ui.ReplaceVirtual.verticalNormalizedPosition = 1
  self:CloseItemType()
end
