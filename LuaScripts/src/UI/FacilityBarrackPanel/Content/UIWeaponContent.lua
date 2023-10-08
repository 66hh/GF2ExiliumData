UIWeaponContent = class("UIWeaponContent", UIBarrackContentBase)
UIWeaponContent.__index = UIWeaponContent
UIWeaponContent.PrefabPath = "Character/ChrWeaponPanel.prefab"
function UIWeaponContent:ctor(obj)
  self.ui = {}
  self.weaponData = nil
  self.weaponDetail = nil
  self.compareDetail = nil
  self.weaponList = {}
  self.lastContent = 0
  self.curContent = 0
  self.isCompareMode = false
  self.curReplaceWeapon = nil
  self.selectWeapon = nil
  self.sortContent = nil
  self.sortList = {}
  self.curSort = nil
  self.partsList = {}
  self.weaponPartInfo = nil
  self.curSlot = nil
  self.lockItem = nil
  self.stageItem = nil
  self.changeContentCallback = nil
  self.weaponEffect = UISystem:GetWeaponEffect()
  self.weaponEffectAni = self.weaponEffect:GetComponent("Animator")
  function self.tempWeaponBlendFinishCallback()
    self:onWeaponBlendFinish()
  end
  function self.tempWeaponToucherBlendFinishCallback()
    self:onWeaponToucherBlendFinish()
  end
  UIWeaponContent.super.ctor(self, obj)
end
function UIWeaponContent:__InitCtrl()
  UIWeaponContent.super.__InitCtrl(self)
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.weaponDetail = UIBarrackWeaponInfoItem.New()
  self.weaponDetail:InitCtrl(self.ui.mTrans_WeaponDetail, function(id, isLock)
    self:UpdateWeaponLock(id, isLock)
  end)
  function self.lockCallback(id, isLock)
    self:UpdateWeaponLock(id, isLock)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:OnClickCloseReplace()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Enhance.gameObject).onClick = function()
    self:OnClickEnhance()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Replace.gameObject).onClick = function()
    self:OnClickReplace()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Preview.gameObject).onClick = function()
    self:OnClickPreview()
  end
  local toggle = self.ui.mToggle_View3DModel
  toggle.onValueChanged:AddListener(function(isOn)
    if isOn then
      self.ui.mAnimator_Visual:SetBool("Bool", true)
      self:PutUpWeaponForObservation()
      UIModelToucher.SwitchToucher(2)
      UIModelToucher.AttachWeaponTransToTouch(UIModelToucher.weaponModel)
    else
      self.ui.mAnimator_Visual:SetBool("Bool", false)
      self:PutDownWeapon()
      UIModelToucher.ReleaseWeaponToucher()
    end
  end)
  self.ui.mToggle_DetailCompare.onValueChanged:AddListener(function(isOn)
    self:OnClickCompare()
  end)
  self:InitVirtualList()
  self:InitSortContent()
  self:InitStage()
  self:InitBtnRedPoint()
end
function UIWeaponContent:OnShow()
  if self.curSlot then
    self:OnClickPart(self.curSlot)
  else
    self.weaponDetail:SetData(self.selectWeapon)
    self.weaponDetail:SetWeaponInfoRootActive(true)
  end
  if self.curContent == UIWeaponGlobal.ContentType.Replace then
    self:UpdateReplaceList()
    self:ResetWeaponIndex(self.weaponList)
  end
  self:UpdateWeaponPartsList(self.selectWeapon)
  self:UpdatePreview()
  self:EnableTabs(self.curContent ~= UIWeaponGlobal.ContentType.Replace)
end
function UIWeaponContent:OnPanelBack()
  if self.curContent == UIWeaponGlobal.ContentType.Info then
    self:PutDownWeapon()
  else
    self:UpdateDetail(self.selectWeapon, nil, UIUtils.SplitStrToVector(self.selectWeapon.Rotation))
    self:UpdatePreview()
    self:UpdateRightTopContent()
    if self.curSlot then
      self.curSlot:SetItemSelect(true)
      self.weaponPartInfo:SetData(self.curSlot.partData, self.curSlot.typeId, self.selectWeapon.id, self.curSlot.slotId)
    end
  end
end
function UIWeaponContent:OnRelease()
  if CS.LuaUtils.IsNullOrDestroyed(UIWeaponGlobal.weaponModel) then
    UIModelToucher.ReleaseWeaponToucher()
    self:ReleaseTimers()
  end
  UISystem.BarrackCharacterCameraCtrl:GetBinding(FacilityBarrackGlobal.CameraType.Weapon):FinishCallback("-", self.tempWeaponBlendFinishCallback)
  UISystem.BarrackCharacterCameraCtrl:GetBinding(FacilityBarrackGlobal.CameraType.WeaponToucher):FinishCallback("-", self.tempWeaponToucherBlendFinishCallback)
  UIWeaponGlobal:ReleaseWeaponModel()
  if not CS.LuaUtils.IsNullOrDestroyed(self.weaponEffect) then
    setactive(self.weaponEffect, false)
    self.weaponEffect = nil
  end
  self.super.OnRelease(self)
end
function UIWeaponContent:OnEnable(enable)
  UIWeaponContent.super.OnEnable(self, enable)
  if self.weaponEffect then
    setactive(self.weaponEffect, enable)
  end
  if enable then
    UISystem.BarrackCharacterCameraCtrl:GetBinding(FacilityBarrackGlobal.CameraType.Weapon):FinishCallback("-", self.tempWeaponBlendFinishCallback)
    UISystem.BarrackCharacterCameraCtrl:GetBinding(FacilityBarrackGlobal.CameraType.WeaponToucher):FinishCallback("-", self.tempWeaponToucherBlendFinishCallback)
    UISystem.BarrackCharacterCameraCtrl:GetBinding(FacilityBarrackGlobal.CameraType.Weapon):FinishCallback("+", self.tempWeaponBlendFinishCallback)
    UISystem.BarrackCharacterCameraCtrl:GetBinding(FacilityBarrackGlobal.CameraType.WeaponToucher):FinishCallback("+", self.tempWeaponToucherBlendFinishCallback)
    UISystem.BarrackCharacterCameraCtrl:DetachChrTouchCtrlEvents()
  else
    UISystem.BarrackCharacterCameraCtrl:GetBinding(FacilityBarrackGlobal.CameraType.Weapon):FinishCallback("-", self.tempWeaponBlendFinishCallback)
    UISystem.BarrackCharacterCameraCtrl:GetBinding(FacilityBarrackGlobal.CameraType.WeaponToucher):FinishCallback("-", self.tempWeaponToucherBlendFinishCallback)
  end
  self:ChangeContentType(UIWeaponGlobal.ContentType.Info)
  if not enable then
    self:ReleaseTimers()
  end
  self:AnimFade(enable, true)
  setactive(self.ui.mToggle_View3DModel.gameObject, enable)
end
function UIWeaponContent:SetData(data, parent)
  UIWeaponContent.super.SetData(self, data, parent)
  self.weaponData = NetCmdWeaponData:GetWeaponById(self.mData.WeaponId)
  self.curSlot = nil
  self.sortContent:SetGunId(self.weaponData.gun_id)
  self:EnableModel(false)
  self:ResetContent()
  self.weaponEffectAni:Play("WeaponEffect", 0, 0)
  UIWeaponGlobal:EnableWeaponModel(true)
  if FacilityBarrackGlobal.GetCurCameraStand() ~= FacilityBarrackGlobal.CameraType.Weapon then
    UISystem.BarrackCharacterCameraCtrl:SetFarthestTwoFingerScale(function()
      FacilityBarrackGlobal:SwitchCameraPos(BarrackCameraStand.Weapon)
    end)
  end
  UIWeaponGlobal:PutDownWeapon(self.weaponData.StcData)
  self:UpdateButtonRedPoint()
end
function UIWeaponContent:InitVirtualList()
  function self.ui.ReplaceVirtual.itemProvider()
    local item = self:WeaponItemProvider()
    return item
  end
  function self.ui.ReplaceVirtual.itemRenderer(index, rendererData)
    self:WeaponItemRenderer(index, rendererData)
  end
end
function UIWeaponContent:InitSortContent()
  if self.sortContent == nil then
    self.sortContent = UIWeaponSortItem.New()
    self.sortContent:InitCtrl(self.ui.mTrans_Sort, true)
    setactive(self.sortContent.mBtn_TypeScreen.gameObject, false)
    UIUtils.GetButtonListener(self.sortContent.mBtn_Sort.gameObject).onClick = function()
      self:OnClickSortList()
    end
    UIUtils.GetButtonListener(self.sortContent.mBtn_Ascend.gameObject).onClick = function()
      self:OnClickAscend()
    end
    self.sortContent:EnableSortAscend(true)
  end
  local sortList = self:InstanceUIPrefab("UICommonFramework/ComScreenDropdownListItemV2.prefab", self.ui.mTrans_SortList)
  local parent = UIUtils.GetRectTransform(sortList, "Content")
  for i = 1, 3 do
    local obj = self:InstanceUIPrefab("Character/ChrEquipSuitDropdownItemV2.prefab", parent)
    if obj then
      local sort = {}
      sort.obj = obj
      sort.btnSort = UIUtils.GetButton(obj)
      sort.txtName = UIUtils.GetText(obj, "GrpText/Text_SuitName")
      sort.sortType = i
      sort.hintID = 101000 + i
      sort.sortCfg = UIWeaponGlobal.ReplaceSortCfg[i]
      sort.isAscend = false
      sort.grpset = obj.transform:Find("GrpSel")
      sort.txtName.text = TableData.GetHintById(sort.hintID)
      UIUtils.GetButtonListener(sort.btnSort.gameObject).onClick = function()
        self:OnClickSort(sort.sortType)
      end
      self.textcolor = obj.transform:GetComponent("TextImgColor")
      self.beforecolor = self.textcolor.BeforeSelected
      self.aftercolor = self.textcolor.AfterSelected
      table.insert(self.sortList, sort)
      if sort ~= self.curSort then
        sort.txtName.color = self.textcolor.BeforeSelected
        setactive(sort.grpset, false)
      else
        sort.txtName.color = self.textcolor.AfterSelected
        setactive(sort.grpset, true)
      end
    end
  end
  UIUtils.GetUIBlockHelper(self.mParentObj, self.ui.mTrans_SortList, function()
    self:CloseItemSort()
  end)
end
function UIWeaponContent:InitBtnRedPoint()
  self.weaponReplaceRedPoint = self.ui.mBtn_Replace.transform:Find("Root/Trans_RedPoint")
end
function UIWeaponContent:UpdateWeaponModel(weaponCmdData, showEffect, enableToucher, enableRotation)
  local weaponId = weaponCmdData.stc_id
  local gunId = weaponCmdData.gun_id
  local weaponType = self.weaponData.Type
  UIWeaponGlobal:UpdateWeaponModelByConfig(weaponCmdData, enableRotation, enableToucher)
  if showEffect == nil or showEffect then
    UIWeaponGlobal:SetWeaponEffectShow(true)
  else
    UIWeaponGlobal:SetWeaponEffectShow(false)
  end
end
function UIWeaponContent:SetWeaponStartEuler(euler, needAnim)
  if needAnim == nil or needAnim then
    UIModelToucher.SetStartEuler(euler)
  else
    UIModelToucher.SetStartEulerDirect(euler)
    UIModelToucher.weaponModel.transform.localEulerAngles = euler
  end
end
function UIWeaponContent:OnClickEnhance()
  self:ChangeContentType(UIWeaponGlobal.ContentType.Enhance)
end
function UIWeaponContent:OnClickCloseReplace()
  self:CloseReplaceContent()
  self:PutDownWeapon()
  self:AnimFade(false, true)
end
function UIWeaponContent:OnClickReplace()
  if self.curContent == UIWeaponGlobal.ContentType.Replace then
    self:ReplaceWeapon()
  else
    self:ChangeContentType(UIWeaponGlobal.ContentType.Replace)
  end
end
function UIWeaponContent:OnClickPreview()
end
function UIWeaponContent:UpdateReplaceContent()
  self.isCompareMode = false
  self:UpdateReplaceList()
  self:UpdateCompareDetail()
  self:UpdateButton()
end
function UIWeaponContent:ReplaceWeapon()
  if self.selectWeapon.gun_id ~= 0 then
    local gunName2 = TableData.listGunDatas:GetDataById(self.selectWeapon.gun_id).name.str
    MessageBoxPanel.ShowDoubleType(string_format(TableData.GetHintById(40015), gunName2), function()
      self:OnReplaceWeapon()
    end)
  else
    self:OnReplaceWeapon()
  end
end
function UIWeaponContent:OnReplaceWeapon()
  local gunID = self.weaponData.gun_id
  NetCmdWeaponData:SendGunWeaponBelong(self.selectWeapon.id, gunID, function(ret)
    self:OnReplaceCallback(ret)
  end)
end
function UIWeaponContent:OnReplaceCallback(ret)
  if ret == ErrorCodeSuc then
    self.weaponData = NetCmdWeaponData:GetWeaponById(self.selectWeapon.id)
    self.selectWeapon = self.weaponData
    self.curReplaceWeapon = nil
    if self.isCompareMode then
      self.ui.mToggle_DetailCompare.isOn = false
    end
    self:UpdateReplaceContent()
    self:UpdateWeaponModel(self.weaponData)
    UIWeaponGlobal:PutUpWeaponForObservation(self.weaponData.StcData)
    MessageSys:SendMessage(CS.GF2.Message.UIEvent.OnChangeWeapon, nil)
    UIUtils.PopupPositiveHintMessage(40071)
  end
end
function UIWeaponContent:CloseReplaceContent()
  self:ChangeContentType(UIWeaponGlobal.ContentType.Info)
end
function UIWeaponContent:ResetContent()
  self.curContent = UIWeaponGlobal.ContentType.Info
  self.isCompareMode = false
  self.selectWeapon = self.weaponData
  self.curReplaceWeapon = nil
  self.ui.mToggle_DetailCompare.isOn = false
  self.ui.mBtn_Replace.interactable = true
  setactive(self.ui.mTrans_Compare.gameObject, false)
  setactive(self.ui.mTrans_Replace, false)
  setactive(self.ui.mTrans_CompareDetail, false)
  self:UpdateDetail(self.weaponData, nil, UIUtils.SplitStrToVector(self.weaponData.Rotation))
  self:UpdatePreview()
  self:UpdateRightTopContent()
end
function UIWeaponContent:OnClickCompare(isOn)
  self.isCompareMode = not self.isCompareMode
  setactive(self.ui.mTrans_CompareDetail, self.isCompareMode)
end
function UIWeaponContent:OnClickSortList()
  setactive(self.ui.mTrans_SortList, true)
end
function UIWeaponContent:CloseItemSort()
  setactive(self.ui.mTrans_SortList, false)
end
function UIWeaponContent:OnClickSort(type)
  if type then
    if self.curSort and self.curSort.sortType ~= type then
      self.curSort.txtName.color = self.textcolor.BeforeSelected
      setactive(self.curSort.grpset, false)
    end
    self.curSort = self.sortList[type]
    self.curSort.isAscend = false
    self.curSort.txtName.color = self.textcolor.AfterSelected
    setactive(self.curSort.grpset, true)
    self.sortContent:SetReplaceData(self.curSort)
    self:UpdateListBySort()
    self:CloseItemSort()
  end
end
function UIWeaponContent:OnClickAscend()
  if self.curSort then
    self.curSort.isAscend = not self.curSort.isAscend
    self.sortContent:SetReplaceData(self.curSort)
    self:UpdateListBySort()
  end
end
function UIWeaponContent:UpdateReplaceList()
  local weaponList = NetCmdWeaponData:GetReplaceWeaponList(self.weaponData.id, self.weaponData.gun_id)
  self.weaponList = self:UpdateWeaponList(weaponList)
  self:OnClickSort(UIWeaponGlobal.ReplaceSortType.Rank)
  self.ui.ReplaceVirtual:SetVerticalNormalizedPosition(1)
end
function UIWeaponContent:UpdateListBySort()
  local sortFunc = self.sortContent.sortFunc
  table.sort(self.weaponList, sortFunc)
  self.ui.ReplaceVirtual.numItems = #self.weaponList
  self.ui.ReplaceVirtual:Refresh()
  self:ResetWeaponIndex(self.weaponList)
end
function UIWeaponContent:UpdateWeaponList(list)
  if list then
    local itemList = {}
    for i = 0, list.Count - 1 do
      local data = UIWeaponGlobal:GetWeaponSimpleData(list[i])
      if self.curReplaceWeapon then
        if self.curReplaceWeapon.id == data.id then
          self.curReplaceWeapon = data
        end
        data.isSelect = self.curReplaceWeapon.id == data.id
      end
      table.insert(itemList, data)
    end
    return itemList
  end
end
function UIWeaponContent:ResetWeaponIndex(list)
  if list then
    for i, item in ipairs(list) do
      item.index = i - 1
    end
  end
end
function UIWeaponContent:WeaponItemProvider()
  local itemView = UIWeaponReplaceItem.New()
  itemView:InitCtrl()
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIWeaponContent:WeaponItemRenderer(index, renderDataItem)
  local itemData = self.weaponList[index + 1]
  local item = renderDataItem.data
  item:SetData(itemData)
  item:SetNowEquip(self.weaponData.id == itemData.id)
  if item.weaponData.id == self.weaponData.id then
    self:OnClickWeapon(item)
  end
  UIUtils.GetButtonListener(item.ui.mBtn_Weapon.gameObject).onClick = function()
    self:OnClickWeapon(item)
  end
end
function UIWeaponContent:OnClickWeapon(weapon)
  if self.curReplaceWeapon then
    if self.curReplaceWeapon.id == weapon.weaponData.id then
      return
    end
    self.curReplaceWeapon.isSelect = false
    self.ui.ReplaceVirtual:RefreshItem(self.curReplaceWeapon.index)
  end
  weapon.weaponData.isSelect = true
  weapon:SetSelect(true)
  self.curReplaceWeapon = weapon.weaponData
  self.selectWeapon = weapon.cmdData
  local weaponData = TableData.listGunWeaponDatas:GetDataById(self.selectWeapon.stc_id)
  self:UpdateDetail(self.selectWeapon, nil, UIUtils.SplitStrToVector(weaponData.Rotation), false)
  self:UpdateButton()
  self.weaponEffectAni:Play("WeaponEffect", 0, 0)
  local location = UIWeaponGlobal:GetWeaponLocation()
  if location == UIWeaponGlobal.Location.Desktop then
    UIWeaponGlobal:EnableWeaponModel(false)
  elseif location == UIWeaponGlobal.Location.Dev then
    UIWeaponGlobal:PutUpWeaponForDev(self.weaponData.StcData)
  end
  UIWeaponGlobal:PutUpWeaponForObservation(self.selectWeapon.StcData)
  self:UpdateRightTopContent()
end
function UIWeaponContent:UpdateButton()
  self.ui.mBtn_Replace.interactable = self.selectWeapon.id ~= self.weaponData.id
  setactive(self.ui.mTrans_Compare.gameObject, self.selectWeapon.id ~= self.weaponData.id)
  setactive(self.ui.mTrans_CompareDetail, self.isCompareMode and self.selectWeapon.id ~= self.weaponData.id)
  setactive(self.ui.mTrans_Preview, false)
  self:UpdateButtonRedPoint()
end
function UIWeaponContent:UpdateButtonRedPoint()
  local weaponCanChangeCount = NetCmdWeaponData:UpdateWeaponCanChangeRedPoint(self.mData.WeaponId, self.mData.GunId)
  setactive(self.weaponReplaceRedPoint, 0 < weaponCanChangeCount)
  self:UpdateRedPoint()
end
function UIWeaponContent:UpdateDetail(weaponData, showEffect, lastEuler, enableRotation)
  if weaponData then
    UIModelToucher.SetStartEulerDirect(lastEuler)
    self.weaponDetail:SetData(weaponData)
    self:UpdateWeaponPartsList(weaponData)
    local enableToucher
    if self.curContent == UIWeaponGlobal.ContentType.WeaponPart then
      enableToucher = false
    end
    self:UpdateWeaponModel(weaponData, showEffect, enableToucher, enableRotation)
    if self.curContent ~= UIWeaponGlobal.ContentType.Info then
      UIWeaponGlobal:PutUpWeaponForDev(self.weaponData.StcData)
    end
  end
end
function UIWeaponContent:UpdateCompareDetail()
  if self.weaponData then
    ComPropsDetailsHelper:InitWeaponData(self.ui.mTrans_CompareDetail.transform, self.weaponData.id, self.lockCallback, true)
  end
end
function UIWeaponContent:UpdateWeaponLock(id, isLock)
  if self.curContent == UIWeaponGlobal.ContentType.Replace then
    local targetIndex = 0
    for index, item in ipairs(self.weaponList) do
      if item.id == id then
        item.isLock = isLock
        targetIndex = index
        break
      end
    end
    if targetIndex ~= 0 then
      self.ui.ReplaceVirtual:RefreshItem(targetIndex - 1)
    end
  end
end
function UIWeaponContent:UpdateWeaponPartsList(weaponCmdData)
  if not AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.GundetailWeaponpart) then
    setactive(self.ui.mTrans_PartInfo, false)
    return
  end
  if weaponCmdData == nil then
    return
  end
  for i, part in ipairs(self.partsList) do
    part:SetData(nil, nil)
  end
  local slotList = weaponCmdData.slotList
  for i = 0, slotList.Count - 1 do
    do
      local item = self.partsList[i + 1]
      if item == nil then
        item = UICommonItem.New()
        item:InitCtrl(self.ui.mTrans_WeaponParts)
        table.insert(self.partsList, item)
      end
      local data = weaponCmdData:GetWeaponPartByType(i)
      item:SetSlotData(data, slotList[i], i + 1)
      UIUtils.GetButtonListener(item.ui.mBtn_Select.gameObject).onClick = function()
        self:OnClickPart(item)
      end
    end
  end
  setactive(self.ui.mTrans_PartInfo, 0 < weaponCmdData.BuffSkillId)
end
function UIWeaponContent:OnClickPart(item)
  if self.weaponPartInfo == nil then
    self.weaponPartInfo = UIWeaponPartsReplaceContent.New()
    self.weaponPartInfo:InitCtrl(self.ui.mTrans_WeaponPartInfo, self.mParentObj)
    self.weaponPartInfo:SetReplaceCallback(function()
      if self.selectWeapon then
        self:UpdateWeaponPartsList(self.selectWeapon)
      end
      self:UpdateWeaponModel(self.selectWeapon, false, false, false)
      UIWeaponGlobal:PutUpWeaponForObservation(self.selectWeapon.StcData, self.curSlot.slotId)
      MessageSys:SendMessage(CS.GF2.Message.UIEvent.OnChangeWeapon, nil)
      self.ui.ReplaceVirtual:Refresh()
      self:UpdateTabList()
      self:UpdateRedPoint()
    end)
    self.weaponPartInfo:SetLockCallback(function(id)
      self:UpdateWeaponModStateById(id)
    end)
    self.weaponPartInfo:SetCloseCallback(function()
      self:CloseWeaponModRelpace()
      UIWeaponGlobal:PutUpWeaponForObservation(self.selectWeapon.StcData)
      UIModelToucher.ResetWeaponModelToucher()
    end)
    self.weaponPartInfo:SetChangePartselectCallback(function()
      UIWeaponGlobal:PutUpWeaponForObservation(self.selectWeapon.StcData, self.curSlot.slotId)
    end)
  end
  self.weaponPartInfo:OnClickSuitTipsClose()
  if self.curSlot then
    self.curSlot:SetItemSelect(false)
  end
  self.curSlot = item
  if self.curSlot then
    self.curSlot:SetItemSelect(true)
    self.weaponPartInfo:SetData(self.curSlot.partData, self.curSlot.typeId, self.selectWeapon.id, self.curSlot.slotId)
    UIWeaponGlobal:PutUpWeaponForObservation(self.selectWeapon.StcData, self.curSlot.slotId)
  end
  self:ChangeContentType(UIWeaponGlobal.ContentType.WeaponPart)
end
function UIWeaponContent:EnableReplaceContent(enable)
  setactive(self.ui.mTrans_Compare.gameObject, enable)
  setactive(self.ui.mTrans_Replace, enable)
  setactive(self.ui.mTrans_CompareDetail, enable and self.isCompareMode)
end
function UIWeaponContent:CloseWeaponModRelpace()
  self:UpdateDetail(self.selectWeapon, false, UIModelToucher.weaponModel.transform.localEulerAngles)
  if self.curSlot then
    self.curSlot:SetItemSelect(false)
    self.curSlot = nil
  end
  setactive(self.ui.mTrans_WeaponPartInfo, false)
  UIModelToucher.ResetStartEuler()
  self:Back2LastContent()
end
function UIWeaponContent:UpdateWeaponModStateById(id)
  for i, part in ipairs(self.partsList) do
    if part.partData and part.partData.id == id then
      local data = NetCmdWeaponPartsData:GetWeaponModById(id)
      part:SetData(data, part.typeId)
      return
    end
  end
end
function UIWeaponContent:UpdatePreview()
end
function UIWeaponContent.UpdateWeaponContentDetail(Id)
  local self = UIWeaponContent
  self.weaponData = NetCmdWeaponData:GetWeaponById(Id)
  self:UpdateWeaponModel(self.weaponData)
end
function UIWeaponContent:PlaySwitchInAni()
  if self.ui.mAnimator then
    self.ui.mAnimator:SetTrigger("Switch")
  end
end
function UIWeaponContent:PutUpWeaponForDev()
  if FacilityBarrackGlobal.GetCurCameraStand() ~= FacilityBarrackGlobal.CameraType.WeaponToucher then
    self:AnimFade(false, true)
    UIWeaponGlobal:EnableWeaponModel(false)
  end
  FacilityBarrackGlobal:SwitchCameraPos(BarrackCameraStand.WeaponToucher)
  setactive(self.ui.mToggle_View3DModel.gameObject, false)
end
function UIWeaponContent:PutUpWeaponForObservation()
  self:AnimFade(false, true)
  UIWeaponGlobal:EnableWeaponModel(false)
  FacilityBarrackGlobal:SwitchCameraPos(BarrackCameraStand.WeaponToucher)
  setactive(self.ui.mToggle_View3DModel.gameObject, false)
end
function UIWeaponContent:PutDownWeapon()
  self:AnimFade(false, true)
  FacilityBarrackGlobal:SwitchCameraPos(BarrackCameraStand.Weapon)
  UIWeaponGlobal:EnableWeaponModel(false)
  setactive(self.ui.mToggle_View3DModel.gameObject, false)
end
function UIWeaponContent:onWeaponBlendFinish()
  UIWeaponGlobal:PutDownWeapon(self.weaponData.StcData)
  self.weaponDetail:SetWeaponInfoRootActive(true)
  UIWeaponGlobal:EnableWeaponModel(true)
  self:CheckCanShowView3DModelToggle()
  UISystem.BarrackCharacterCameraCtrl:DetachChrTouchCtrlEvents()
  self:ExcuteChangeContentCallback()
end
function UIWeaponContent:onWeaponToucherBlendFinish()
  self.weaponDetail:SetWeaponInfoRootActive(true)
  if self.curContent == UIWeaponGlobal.ContentType.Replace then
    UIWeaponGlobal:PutUpWeaponForDev(self.weaponData.StcData)
    setactive(self.ui.mTrans_Replace, true)
    self:AnimFade(true, true)
  elseif self.curContent == UIWeaponGlobal.ContentType.Enhance then
    UIWeaponGlobal:PutUpWeaponForDev(self.weaponData.StcData)
  elseif self.curContent == UIWeaponGlobal.ContentType.WeaponPart then
    self:AnimFade(true)
    setactive(self.weaponPartInfo.mUIRoot, true)
    self.weaponDetail:SetWeaponInfoRootActive(false)
  elseif self.curContent == UIWeaponGlobal.ContentType.Info then
    UIWeaponGlobal:PutUpWeaponForObservation(self.weaponData.StcData)
  end
  self:UpdateRightTopContent()
  UIWeaponGlobal:EnableWeaponModel(true)
  self:CheckCanShowView3DModelToggle()
  self:ExcuteChangeContentCallback()
end
function UIWeaponContent:AnimFade(enable, withParent)
  if self.ui.mAnimator then
    if enable then
      if withParent then
        self.mParent.ui.mAni_Root:ResetTrigger("Visual_Fade_Out")
        self.mParent.ui.mAni_Root:SetTrigger("Visual_FadeIn")
      end
      setactive(self.mUIRoot.gameObject, enable)
      self.ui.mAnimator:ResetTrigger("FadeOut")
      self.ui.mAnimator:SetTrigger("FadeIn")
    else
      if withParent then
        self.mParent.ui.mAni_Root:ResetTrigger("Visual_FadeIn")
        self.mParent.ui.mAni_Root:SetTrigger("Visual_Fade_Out")
      end
      self.ui.mAnimator:ResetTrigger("FadeIn")
      self.ui.mAnimator:SetTrigger("FadeOut")
    end
  else
    setactive(self.mUIRoot.gameObject, enable)
  end
end
function UIWeaponContent:UpdateRightTopContent()
  local weaponTypeData = TableData.listGunWeaponTypeDatas:GetDataById(self.selectWeapon.Type)
  if self.curContent == UIWeaponGlobal.ContentType.Info then
    setactive(self.ui.mTrans_WeaponText, true)
    setactive(self.ui.mTrans_TitleContent, false)
    setactive(self.ui.mTrans_WeaponInfo, true)
    self.ui.mText_WeaponTypeName1.text = weaponTypeData.Name.str
  else
    setactive(self.ui.mTrans_WeaponInfo, false)
    setactive(self.ui.mTrans_WeaponText, false)
    setactive(self.ui.mTrans_TitleContent, true)
    self.ui.mText_WeaponName.text = self.selectWeapon.Name
    self.ui.mText_WeaponTypeName.text = weaponTypeData.Name.str
    self.ui.mText_WeaponLevel.text = GlobalConfig.SetLvText(self.selectWeapon.Level)
    self.stageItem:SetData(self.selectWeapon.BreakTimes)
  end
end
function UIWeaponContent:InitLockItem()
  self.lockItem = UICommonLockItem.New()
  self.lockItem:InitCtrl(self.ui.mScrollListChild_BtnLock.transform)
  UIUtils.GetButtonListener(self.lockItem.ui.btnLock.gameObject).onClick = function()
    self:OnClickLock()
  end
end
function UIWeaponContent:OnClickLock()
  NetCmdWeaponData:SendGunWeaponLockUnlock(self.selectWeapon.id, function()
    self:UpdateLockStatue()
  end)
end
function UIWeaponContent:UpdateLockStatue()
  setactive(self.lockItem.ui.transLock, self.selectWeapon.IsLocked)
  setactive(self.lockItem.ui.transUnlock, not self.selectWeapon.IsLocked)
end
function UIWeaponContent:InitStage()
  self.stageItem = UIComStageItemV2:New()
  self.stageItem:InitCtrl(self.ui.mScrollListChild_Stage, true)
end
function UIWeaponContent:CheckCanShowView3DModelToggle()
  local needShow = self.curContent == UIWeaponGlobal.ContentType.Info
  setactive(self.ui.mToggle_View3DModel.gameObject, needShow)
end
function UIWeaponContent:ChangeContentType(contentType)
  if contentType == self.curContent then
    return
  end
  self.lastContent = self.curContent
  self.curContent = contentType
  if self.curContent == UIWeaponGlobal.ContentType.Info then
    UIWeaponGlobal:EnableWeaponModel(false)
    local changeContent = function()
      if self.selectWeapon.stc_id ~= self.weaponData.stc_id then
        self:UpdateWeaponModel(self.weaponData)
      end
      self:EnableTabs(true)
      self:EnableSwitchGun(true)
      self:ResetContent()
      UIModelToucher.ReleaseWeaponToucher()
    end
    if FacilityBarrackGlobal.GetCurCameraStand() ~= FacilityBarrackGlobal.CameraType.Weapon then
      self:PutDownWeapon()
      self:SetChangeContentCallback(function()
        changeContent()
      end)
    else
      changeContent()
    end
  elseif self.curContent == UIWeaponGlobal.ContentType.Replace then
    UIWeaponGlobal:EnableWeaponModel(false)
    local changeContent = function()
      UIWeaponGlobal:EnableWeaponModel(true)
      self:EnableReplaceContent(true)
      self:UpdateReplaceContent()
      self:EnableTabs(false)
      self:EnableSwitchGun(false)
      self.weaponDetail:SetWeaponInfoRootActive(true)
      self.mParent:SetCharacterPanelVisible(false)
      UIModelToucher.SwitchToucher(2)
    end
    if FacilityBarrackGlobal.GetCurCameraStand() ~= FacilityBarrackGlobal.CameraType.WeaponToucher then
      self:PutUpWeaponForDev()
      self:SetChangeContentCallback(function()
        changeContent()
      end)
    else
      changeContent()
    end
  elseif self.curContent == UIWeaponGlobal.ContentType.Enhance then
    local weaponId = self.selectWeapon.id
    UIManager.OpenUIByParam(UIDef.UIWeaponPanel, {
      weaponId,
      UIWeaponGlobal.WeaponPanelTab.Enhance,
      false,
      UIWeaponPanel.OpenFromType.Barrack
    })
    UIModelToucher.SwitchToucher(2)
  elseif self.curContent == UIWeaponGlobal.ContentType.WeaponPart then
    UIWeaponGlobal:EnableWeaponModel(false)
    setactive(self.weaponPartInfo.mUIRoot, false)
    local changeContent = function()
      self.weaponPartInfo:OnClickSuitTipsClose()
      self:EnableTabs(false)
      self:EnableSwitchGun(false)
      self:UpdateWeaponPartsList(self.selectWeapon)
      self:EnableReplaceContent(false)
      setactive(self.ui.mTrans_WeaponPartInfo, true)
      self:UpdateWeaponModel(self.selectWeapon, false, false)
      local slotId
      if self.curSlot == nil then
        slotId = 1
      else
        slotId = self.curSlot.slotId
      end
      UIWeaponGlobal:PutUpWeaponForObservation(self.selectWeapon.StcData, slotId)
      UIWeaponGlobal:EnableWeaponModel(true)
      self.weaponDetail:SetWeaponInfoRootActive(false)
    end
    if FacilityBarrackGlobal.GetCurCameraStand() ~= FacilityBarrackGlobal.CameraType.WeaponToucher then
      self:PutUpWeaponForDev()
      self:SetChangeContentCallback(function()
        changeContent()
      end)
    else
      changeContent()
      setactive(self.weaponPartInfo.mUIRoot, true)
    end
    UIModelToucher.ReleaseWeaponToucher()
  end
end
function UIWeaponContent:Back2LastContent()
  if self.curContent == UIWeaponGlobal.ContentType.Info then
    self:OnEnable(false)
    return
  end
  self:ChangeContentType(self.lastContent)
end
function UIWeaponContent:SetChangeContentCallback(callback)
  self.changeContentCallback = callback
end
function UIWeaponContent:ExcuteChangeContentCallback()
  if self.changeContentCallback then
    self.changeContentCallback()
    self.changeContentCallback = nil
  end
end
