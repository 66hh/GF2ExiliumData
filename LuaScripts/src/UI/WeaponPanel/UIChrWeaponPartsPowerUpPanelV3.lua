require("UI.Common.UICommonLockItem")
UIChrWeaponPartsPowerUpPanelV3 = class("UIChrWeaponPartsPowerUpPanelV3", UIBasePanel)
UIChrWeaponPartsPowerUpPanelV3.__index = UIChrWeaponPartsPowerUpPanelV3
function UIChrWeaponPartsPowerUpPanelV3:ctor(csPanel)
  UIChrWeaponPartsPowerUpPanelV3.super:ctor(csPanel)
  csPanel.Is3DPanel = true
  self.itemId = TableData.GlobalSystemData.WeaponModLevelUpItem
  self.gunWeaponModData = nil
  self.weaponPartUis = {}
  self.weaponPartsList = nil
  self.subPropList = {}
  self.curSelectPartItem = nil
  self.selectMaterial = {}
  self.curSelectCount = 0
  self.resultMaterial = {}
  self.comScreenItemV2 = nil
  self.curAutoSelectRank = 0
  self.curItem = nil
  self.lockItem = nil
  self.lockList = {}
  self.curPropsDetailsId = 0
  self.ringObj = nil
  self.weaponModel = nil
  self.needResetCameraPosToBase = false
  self.curImgFillAmount = 0
  self.curBgImgFillAmount = 0
  self.ColorList = {
    White = Color(0.9372549019607843, 0.9372549019607843, 0.9372549019607843, 0.5098039215686274),
    Red = Color(1, 0.3686274509803922, 0.2549019607843137, 1)
  }
end
function UIChrWeaponPartsPowerUpPanelV3:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
end
function UIChrWeaponPartsPowerUpPanelV3:OnInit(root, data)
  self.gunWeaponModData = data.gunWeaponModData
  self.needResetCameraPosToBase = data.needResetCameraPosToBase
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBack.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIChrWeaponPartsPowerUpPanelV3)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnHome.gameObject).onClick = function()
    UIWeaponGlobal.SetNeedCloseBarrack3DCanvas(true)
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnQuickChoose.gameObject).onClick = function()
    self:OnQuickChooseClick()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnStageUp.gameObject).onClick = function()
    self:OnStageUpClick()
  end
  self:InitWeaponPartList()
  self:InitLockAttrList()
end
function UIChrWeaponPartsPowerUpPanelV3:OnShowStart()
  self:SetWeaponPartData()
end
function UIChrWeaponPartsPowerUpPanelV3:OnRecover()
end
function UIChrWeaponPartsPowerUpPanelV3:OnBackFrom()
  self:SetWeaponPartData()
end
function UIChrWeaponPartsPowerUpPanelV3:OnTop()
end
function UIChrWeaponPartsPowerUpPanelV3:OnShowFinish()
end
function UIChrWeaponPartsPowerUpPanelV3:OnCameraStart()
  return 0.01
end
function UIChrWeaponPartsPowerUpPanelV3:OnCameraBack()
end
function UIChrWeaponPartsPowerUpPanelV3:OnHide()
end
function UIChrWeaponPartsPowerUpPanelV3:OnHideFinish()
  if UIWeaponGlobal.GetNeedCloseBarrack3DCanvas() then
    UIModelToucher.ReleaseWeaponToucher()
    UIWeaponGlobal:ReleaseWeaponModel()
    CS.UIBarrackModelManager.Instance:ShowBarrackObjWithLayer(true)
  end
  self:SetActiveObj(self.ringObj, true)
  self:SetActiveObj(self.weaponModel, true)
  self:SetCurItem()
  if self.comScreenItemV2 then
    self.comScreenItemV2:OnRelease()
    self.comScreenItemV2 = nil
  end
  self:ReleaseCtrlTable(self.subPropList, true)
  for i = 2, #self.lockList do
    gfdestroy(self.lockList[i].obj)
  end
  self.lockList = {}
  self.lockItem:OnRelease(true)
  self.curSelectPartItem = nil
  self.curPropsDetailsId = 0
  ComPropsDetailsHelper:Close()
end
function UIChrWeaponPartsPowerUpPanelV3:OnClose()
end
function UIChrWeaponPartsPowerUpPanelV3:OnRelease()
  self.super.OnRelease(self)
end
function UIChrWeaponPartsPowerUpPanelV3:InitLockItem()
  local parent = self.ui.mScrollListChild_GrpLock.transform
  local obj
  if parent.childCount > 0 then
    obj = parent:GetChild(0)
  end
  self.lockItem = UICommonLockItem.New()
  self.lockItem:InitCtrl(parent, obj)
  self.lockItem:AddClickListener(function(isOn)
    self:OnClickLock(isOn)
  end)
end
function UIChrWeaponPartsPowerUpPanelV3:InitWeaponPartList()
  function self.itemProvider()
    return self:ItemProvider()
  end
  function self.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  self.ui.mVirtualListEx_GrpWeaponPartsList.itemProvider = self.itemProvider
  self.ui.mVirtualListEx_GrpWeaponPartsList.itemRenderer = self.itemRenderer
end
function UIChrWeaponPartsPowerUpPanelV3:ItemProvider()
  local itemView = UICommonItem.New()
  itemView:InitCtrl(self.ui.mScrollListChild_Content.transform, false)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIChrWeaponPartsPowerUpPanelV3:ItemRenderer(index, renderDataItem)
  if self.resultMaterial == nil or #self.resultMaterial == 0 then
    return
  end
  local itemOrWeaponPartData = self.resultMaterial[index + 1]
  local item = renderDataItem.data
  item:LoseFocus()
  itemOrWeaponPartData.UICommonItem = item
  itemOrWeaponPartData.index = index
  item:SetMaterialPartData(itemOrWeaponPartData)
  if index == 0 then
    item:SetNowEquip(false)
    setactive(item.ui.mTrans_Lock, false)
  else
    item:SetNowEquip(itemOrWeaponPartData.gunWeaponModData.equipWeapon ~= 0)
    setactive(item.ui.mTrans_Lock, itemOrWeaponPartData.gunWeaponModData.IsLocked)
  end
  if self.curItem ~= nil then
    if self.curItem.gunWeaponModData ~= nil then
      if itemOrWeaponPartData.gunWeaponModData ~= nil and itemOrWeaponPartData.gunWeaponModData.id == self.curItem.gunWeaponModData.id then
        item:Focus()
      end
    elseif self.curItem.itemData ~= nil and itemOrWeaponPartData.itemData ~= nil and itemOrWeaponPartData.itemData.id == self.curItem.itemData.id then
      item:Focus()
    end
  end
  item:SetLongPressIntervalEvent(function(go, data)
    self:BeginLongPress(itemOrWeaponPartData)
  end)
  item:SetMinusLongPressEvent(function(go, data)
    self:BeginMinusLongPress(itemOrWeaponPartData)
  end)
  UIUtils.GetButtonListener(item.ui.mBtn_Select.gameObject).onClick = function()
    self:OnClickItem(itemOrWeaponPartData)
  end
  UIUtils.GetButtonListener(item.ui.mBtn_Reduce.gameObject).onClick = function()
    self:OnClickReduce(itemOrWeaponPartData)
  end
end
function UIChrWeaponPartsPowerUpPanelV3:InitLockAttrList()
  if #self.lockList > 0 then
    return
  end
  local tmpParent = self.ui.mTrans_Locked.parent
  local tmpObj = self.ui.mTrans_Locked.gameObject
  local item = {}
  item.obj = tmpObj
  item.txtInfo = self.ui.mText_Lv
  table.insert(self.lockList, item)
  for i = 1, 2 do
    item = {}
    local obj = instantiate(tmpObj, tmpParent)
    item.obj = obj
    item.txtInfo = UIUtils.GetText(obj, "Root/Text_Lv")
    table.insert(self.lockList, item)
  end
end
function UIChrWeaponPartsPowerUpPanelV3:SetWeaponPartData()
  if self.ringObj == nil then
    self.ringObj = BarrackHelper.CameraMgr.Barrack3DCanvas.transform:Find("UI_ChrWeapon_Bg_Ring")
  end
  self.weaponModel = UIWeaponGlobal.GetWeaponModel()
  self:SetActiveObj(self.ringObj, false)
  self:SetActiveObj(self.weaponModel, false)
  self:InitLockItem()
  UISystem.BarrackCharacterCameraCtrl:ShowBarrack3DCanvas(true)
  local typeData = TableData.listWeaponModTypeDatas:GetDataById(self.gunWeaponModData.type)
  local icon = self.gunWeaponModData.icon
  self.ui.mText_Text.text = self.gunWeaponModData.level
  self.ui.mImg_WeaponPartsIcon.sprite = IconUtils.GetWeaponPartIcon(icon)
  self.ui.mText_PartsName.text = self.gunWeaponModData.name
  self.ui.mText_TypeName.text = typeData.name.str
  self.ui.mImg_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(self.gunWeaponModData.rank)
  self.ui.mText_LevelAfter.text = self.gunWeaponModData.level
  self.ui.mText_LevelMax.text = "/" .. self.gunWeaponModData.maxLevel
  self:UpdateLockStatue()
  self.subPropList = UIWeaponGlobal.SetWeaponPartAttr(self.gunWeaponModData, self.subPropList, self.ui.mScrollListChild_Content2)
  self.ui.mTrans_Locked:SetSiblingIndex(self.ui.mScrollListChild_Content2.transform.childCount - 1)
  self.targetLevel = self.gunWeaponModData.level
  self.maxLevel = self.gunWeaponModData.maxLevel
  self.selectMaterial = {}
  self.totalExp = self:GetPartTotalExpByLevel(self.gunWeaponModData.level) + self.gunWeaponModData.exp
  if self.gunWeaponModData.level < self.gunWeaponModData.maxLevel then
    local nextLv = self.gunWeaponModData.level + 1
    local exp = self:GetPartExpByLevel(nextLv)
    self.nextLevelExp = exp
  else
    self.nextLevelExp = 0
  end
  self:UpdateSelectListData()
  self:UpdateSortContent()
  self:UpdateLockInfo()
  self.curImgFillAmount = self.ui.mImg_ProgressBarBefore.fillAmount
  self.curBgImgFillAmount = self.ui.mImg_ProgressBarAfter.fillAmount
end
function UIChrWeaponPartsPowerUpPanelV3:UpdateCompareDetail()
  if self.curItem == nil then
    ComPropsDetailsHelper:SetBlockUIRoot(self.ui.mVirtualListEx_GrpWeaponPartsList.gameObject)
    ComPropsDetailsHelper:ShowOrHide(false)
    return
  end
  local gunWeaponModData = self.curItem.gunWeaponModData
  local itemData = self.curItem.itemData
  local isFocused = self.curItem.UICommonItem:IsFocused() and self.curItem.selectCount > 0 or self.curItem.gunWeaponModData ~= nil and self.curItem.gunWeaponModData.IsLocked
  if gunWeaponModData then
    function self.lockCallback()
      self:OnClickLockCallback(gunWeaponModData, true)
    end
    if self.curPropsDetailsId ~= gunWeaponModData.id and isFocused then
      ComPropsDetailsHelper:InitWeaponPartsData(self.ui.mTrans_WeaponPartsInfo.transform, gunWeaponModData.id, self.lockCallback, false, 0, true)
      self.curPropsDetailsId = gunWeaponModData.id
    end
    ComPropsDetailsHelper:ShowOrHide(isFocused)
  elseif itemData ~= nil then
    if self.curPropsDetailsId ~= self.itemId and isFocused then
      ComPropsDetailsHelper:InitItemData(self.ui.mTrans_WeaponPartsInfo.transform, self.itemId)
      self.curPropsDetailsId = self.itemId
    end
    ComPropsDetailsHelper:ShowOrHide(isFocused)
  end
end
function UIChrWeaponPartsPowerUpPanelV3:UpdateSortContent()
  local gunWeaponModDatas = NetCmdWeaponPartsData:GetEnhanceWeaponPartList(self.gunWeaponModData.id)
  if self.comScreenItemV2 == nil then
    self.comScreenItemV2 = ComScreenItemHelper:InitWeaponPartPowerUp(self.ui.mScrollListChild_GrpScreen.gameObject, gunWeaponModDatas, function()
      self.tmpItemSelectCount = 0
      if self.selectMaterial[self.itemId] ~= nil then
        self.tmpItemSelectCount = self.selectMaterial[self.itemId].selectCount
      end
      self:UpdateReplaceList()
    end)
  else
    self.comScreenItemV2:SetList(gunWeaponModDatas)
  end
  self:UpdateReplaceList()
end
function UIChrWeaponPartsPowerUpPanelV3:UpdateReplaceList()
  if self.comScreenItemV2 == nil then
    return
  end
  if self.curSelectPartItem ~= nil then
    self.curSelectPartItem:SetSelect(false)
  end
  self.weaponPartsList = self.comScreenItemV2:GetResultList()
  self.curAutoSelectRank = self.comScreenItemV2:GetCurSortRank()
  self.resultMaterial = {}
  local itemOwn = NetCmdItemData:GetItemCountById(self.itemId)
  if 0 < itemOwn then
    local tmpWeaponPartMaterial = {}
    tmpWeaponPartMaterial.itemData = TableData.listItemDatas:GetDataById(self.itemId)
    tmpWeaponPartMaterial.selectCount = self.tmpItemSelectCount
    table.insert(self.resultMaterial, tmpWeaponPartMaterial)
    self.tmpItemSelectCount = 0
  end
  for i = 0, self.weaponPartsList.Count - 1 do
    local gunWeaponModData = self.weaponPartsList[i]
    local isSelectItem = self.selectMaterial[gunWeaponModData.id]
    if self.selectMaterial[gunWeaponModData.id] ~= nil then
      table.insert(self.resultMaterial, isSelectItem)
    else
      local tmpWeaponPartMaterial = {}
      tmpWeaponPartMaterial.gunWeaponModData = self.weaponPartsList[i]
      tmpWeaponPartMaterial.selectCount = 0
      table.insert(self.resultMaterial, tmpWeaponPartMaterial)
    end
  end
  setactive(self.ui.mTrans_None.gameObject, #self.resultMaterial <= 0)
  self.ui.mVirtualListEx_GrpWeaponPartsList.numItems = #self.resultMaterial
  self.ui.mVirtualListEx_GrpWeaponPartsList:Refresh()
  self.ui.mVirtualListEx_GrpWeaponPartsList.verticalNormalizedPosition = 1
end
function UIChrWeaponPartsPowerUpPanelV3:GetSelectMaterialCount()
  return self.curSelectCount
end
function UIChrWeaponPartsPowerUpPanelV3:AutoSelect()
  if self.gunWeaponModData.level >= self.gunWeaponModData.maxLevel then
    UIUtils.PopupHintMessage(30020)
    return
  end
  self:ResetMaterialList()
  local maxLevelExp = self:GetPartTotalExpByLevel(self.gunWeaponModData.maxLevel)
  local needExp = maxLevelExp - self.totalExp
  local isItemEnough = false
  local itemOwn = NetCmdItemData:GetItemCountById(self.itemId)
  if 0 < itemOwn then
    local tmpWeaponPartMaterial = {}
    tmpWeaponPartMaterial.itemData = TableData.listItemDatas:GetDataById(self.itemId)
    tmpWeaponPartMaterial.selectCount = 0
    local itemExp = tmpWeaponPartMaterial.itemData.args[0]
    local needItemCount = math.ceil(needExp / itemExp)
    if itemOwn >= needItemCount then
      tmpWeaponPartMaterial.selectCount = needItemCount
      isItemEnough = true
    else
      tmpWeaponPartMaterial.selectCount = itemOwn
    end
    self.selectMaterial[self.itemId] = tmpWeaponPartMaterial
    self.resultMaterial[1] = tmpWeaponPartMaterial
    self.curSelectCount = self.curSelectCount + 1
  end
  if not isItemEnough then
    local startIndex = 1
    if self.selectMaterial[self.itemId] ~= nil then
      startIndex = 2
    end
    for i = startIndex, #self.resultMaterial do
      local tmpWeaponPartMaterial = self.resultMaterial[i]
      if self:CanBeAutoSelect(tmpWeaponPartMaterial) then
        if self:GetSelectMaterialCount() >= UIWeaponGlobal.MaxMaterialCount or needExp <= 0 then
          break
        end
        needExp = needExp - tmpWeaponPartMaterial.gunWeaponModData:GetWeaponOfferExp()
        tmpWeaponPartMaterial.selectCount = 1
        self.selectMaterial[tmpWeaponPartMaterial.gunWeaponModData.id] = tmpWeaponPartMaterial
        self.curSelectCount = self.curSelectCount + 1
      end
    end
  end
  self.ui.mVirtualListEx_GrpWeaponPartsList:Refresh()
  self:UpdateSelectListData()
  if self.selectMaterial[self.itemId] ~= nil or 0 < self.curSelectCount then
    UIUtils.PopupPositiveHintMessage(40067)
  else
    UIUtils.PopupHintMessage(102238)
  end
end
function UIChrWeaponPartsPowerUpPanelV3:CanBeAutoSelect(weaponPartMaterial)
  local gunWeaponModData = weaponPartMaterial.gunWeaponModData
  if gunWeaponModData == nil then
    printstack("mylog:Lua:" .. "gunWeaponModData nil")
    return false
  end
  return gunWeaponModData.id ~= self.gunWeaponModData.id and gunWeaponModData.rank <= self.curAutoSelectRank and gunWeaponModData.level <= 1 and gunWeaponModData.exp <= 0 and not gunWeaponModData.IsLocked
end
function UIChrWeaponPartsPowerUpPanelV3:ResetMaterialList()
  for i, item in pairs(self.selectMaterial) do
    item.index = -1
    item.selectCount = 0
  end
  self.selectMaterial = {}
  self.curSelectCount = 0
  self:SetWeaponPartData()
  self.ui.mVirtualListEx_GrpWeaponPartsList:Refresh()
end
function UIChrWeaponPartsPowerUpPanelV3:GetPartTotalExpByLevel(level)
  level = math.min(level, self.gunWeaponModData.maxLevel)
  local expId = self.gunWeaponModData.expList[level - 1]
  local maxExp = TableData.listWeaponModExpDatas:GetDataById(expId)
  return maxExp.exp_total
end
function UIChrWeaponPartsPowerUpPanelV3:UpdateSelectListData()
  local addExp = 0
  self.curSelectCount = 0
  for i, tmpWeaponPartMaterial in pairs(self.selectMaterial) do
    self.curSelectCount = self.curSelectCount + 1
    if tmpWeaponPartMaterial.gunWeaponModData ~= nil then
      addExp = addExp + tmpWeaponPartMaterial.gunWeaponModData:GetWeaponOfferExp()
    else
      addExp = addExp + tmpWeaponPartMaterial.itemData.args[0] * tmpWeaponPartMaterial.selectCount
    end
  end
  self.ui.mText_PartsNum.text = self.curSelectCount .. "/" .. UIWeaponGlobal.MaxMaterialCount
  setactive(self.ui.mBtn_ConsumeItem.gameObject, 0 < self.curSelectCount)
  self.totalExp = self.gunWeaponModData.exp + addExp + self:GetPartTotalExpByLevel(self.gunWeaponModData.level)
  self.targetLevel = math.min(self:CalculateLevel(self.totalExp), self.gunWeaponModData.maxLevel)
  local costCoin = self.gunWeaponModData:GetChipCash(self.totalExp)
  self.isCoinEnough = costCoin <= GlobalData.cash
  self.ui.mText_GoldNum.text = costCoin
  if not self.isCoinEnough then
    self.ui.mText_GoldNum.color = self.ColorList.Red
  else
    self.ui.mText_GoldNum.color = self.ColorList.White
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ConsumeItem.gameObject).onClick = function()
    local itemData = TableData.GetItemData(2)
    UITipsPanel.Open(itemData, 0, true)
  end
  local maxExp = 0
  local curExp = 0
  local sliderBeforeValue = 0
  local sliderAfterValue = 0
  local curExpData = self:GetPartTotalExpByLevel(self.gunWeaponModData.level)
  local targetExpData = self:GetPartTotalExpByLevel(self.targetLevel)
  if self.gunWeaponModData.exp + addExp >= self.nextLevelExp then
    local nextLevel = self.targetLevel >= self.gunWeaponModData.maxLevel and self.gunWeaponModData.maxLevel or self.targetLevel + 1
    maxExp = self:GetPartExpByLevel(nextLevel)
    if self.targetLevel >= self.gunWeaponModData.maxLevel then
      curExp = maxExp
    else
      curExp = curExpData + self.gunWeaponModData.exp + addExp - targetExpData
    end
    sliderBeforeValue = self.gunWeaponModData.level >= self.gunWeaponModData.maxLevel and 1 or 0
    sliderAfterValue = curExp / maxExp
  else
    maxExp = self.nextLevelExp
    if self.targetLevel >= self.gunWeaponModData.maxLevel then
      curExp = maxExp
      sliderBeforeValue = 1
      sliderAfterValue = 1
    else
      curExp = self.gunWeaponModData.exp + addExp
      sliderBeforeValue = self.gunWeaponModData.exp / self.nextLevelExp
      sliderAfterValue = (self.gunWeaponModData.exp + addExp) / self.nextLevelExp
    end
  end
  self.ui.mText_Exp.text = string_format("{0}/{1}", curExp, maxExp)
  self.curBgImgFillAmount = sliderAfterValue
  self.ui.mImg_ProgressBarAfter.fillAmount = sliderAfterValue
  self.ui.mImg_ProgressBarBefore.fillAmount = sliderBeforeValue
  setactive(self.ui.mText_Add.gameObject, 0 < addExp)
  self.ui.mText_Add.text = "+" .. addExp
  self.ui.mText_LevelAfter.text = self.targetLevel
  self.ui.mText_LevelMax.text = "/" .. self.gunWeaponModData.maxLevel
  self.ui.mBtn_BtnStageUp.interactable = 0 < addExp
  self.canLevelUp = 0 < addExp
  if self.gunWeaponModData.level ~= self.targetLevel then
    self.subPropList[1]:SetValueUp(self.gunWeaponModData.mainPropValue + self.gunWeaponModData:GetTargetMainValue(self.targetLevel))
  else
    local propData = TableData.GetPropertyDataByName(self.gunWeaponModData.mainProp)
    self.subPropList[1]:SetValueUp(0, false)
    self.subPropList[1]:SetData(propData, self.gunWeaponModData.mainPropValue)
  end
end
function UIChrWeaponPartsPowerUpPanelV3:CalculateLevel(exp)
  for i = 1, self.gunWeaponModData.expList.Count - 1 do
    local needData = TableData.listWeaponModExpDatas:GetDataById(self.gunWeaponModData.expList[i])
    local lastData = TableData.listWeaponModExpDatas:GetDataById(self.gunWeaponModData.expList[i - 1])
    local needExp = needData.exp_total
    local lastExp = lastData.exp_total
    if exp >= lastExp and exp < needExp then
      return lastData.level
    end
  end
  local expData = TableData.listWeaponModExpDatas:GetDataById(self.gunWeaponModData.expList[self.gunWeaponModData.expList.Count - 1])
  return expData.level
end
function UIChrWeaponPartsPowerUpPanelV3:GetPartExpByLevel(level)
  level = math.min(level, self.gunWeaponModData.maxLevel)
  local expId = self.gunWeaponModData.expList[level - 1]
  local maxExp = TableData.listWeaponModExpDatas:GetDataById(expId)
  return maxExp.exp
end
function UIChrWeaponPartsPowerUpPanelV3:UpdateLockInfo()
  for i, item in ipairs(self.lockList) do
    setactive(item.obj, false)
    item.obj.transform:SetSiblingIndex(item.obj.transform.parent.childCount)
  end
  for i = 0, self.gunWeaponModData.lockLevel.Count - 1 do
    if self.gunWeaponModData.level < self.gunWeaponModData.lockLevel[i] then
      local item = self.lockList[i + 1]
      if item ~= nil then
        item.txtInfo.text = string_format(TableData.GetHintById(102244), self.gunWeaponModData.lockLevel[i])
        setactive(item.obj, true)
      end
    end
  end
end
function UIChrWeaponPartsPowerUpPanelV3:GetMaterialList()
  local itemList = {}
  local partList = {}
  for _, item in pairs(self.selectMaterial) do
    if item.itemData ~= nil then
      itemList[item.itemData.id] = item.selectCount
    elseif item.gunWeaponModData ~= nil then
      table.insert(partList, item.gunWeaponModData.id)
    end
  end
  return itemList, partList
end
function UIChrWeaponPartsPowerUpPanelV3:OnQuickChooseClick()
  self:AutoSelect()
end
function UIChrWeaponPartsPowerUpPanelV3:OnStageUpClick()
  if self.gunWeaponModData.level >= self.gunWeaponModData.maxLevel then
    UIUtils.PopupHintMessage(30020)
    return
  end
  if not self.isCoinEnough then
    UIUtils.PopupHintMessage(40050)
    return
  end
  if not self.canLevelUp then
    UIUtils.PopupHintMessage(40019)
    return
  end
  local itemList, partList = self:GetMaterialList()
  self.recordLv = self.gunWeaponModData.level
  self.recordExp = self.gunWeaponModData.exp
  self.ui.mBtn_BtnStageUp.interactable = false
  self:SetCurItem()
  self:UpdateCompareDetail()
  NetCmdWeaponPartsData:ReqWeaponPartLvUp(self.gunWeaponModData.id, partList, itemList, function(ret)
    if ret == ErrorCodeSuc then
      local tempPropList = deep_copy(self.subPropList)
      setactive(self.ui.mTrans_Mask, true)
      self:SetInputActive(false)
      local start = self.recordLv + self.curImgFillAmount
      local endLv = self.targetLevel + self.curBgImgFillAmount
      CS.ProgressBarAnimationHelper.PlayProgress(self.ui.mImg_ProgressBarBefore, self.ui.mImg_ProgressBarAfter, start, endLv, 0.5, nil, function()
        self.gunWeaponModData = NetCmdWeaponPartsData:GetWeaponModById(self.gunWeaponModData.id)
        self:SetWeaponPartData()
        self:OpenLevelUpPanel(tempPropList)
        setactive(self.ui.mTrans_Mask, false)
        self:SetInputActive(true)
      end)
    end
  end)
end
function UIChrWeaponPartsPowerUpPanelV3:OnClickReduce(item)
  if item.itemData == nil then
    return
  end
  item.selectCount = item.selectCount - 1
  if item.selectCount == 0 then
    self.selectMaterial[self.itemId] = nil
  end
  self:SetCurItem(item)
  self:UpdateSelectListData()
end
function UIChrWeaponPartsPowerUpPanelV3:OnClickItem(item)
  local maxLevelExp = self:GetPartTotalExpByLevel(self.gunWeaponModData.maxLevel)
  local needExp = maxLevelExp - self.totalExp
  if item.gunWeaponModData ~= nil then
    if item.gunWeaponModData.IsLocked then
      local hint = TableData.GetHintById(102239)
      CS.PopupMessageManager.PopupString(hint)
    elseif item.selectCount > 0 then
      item.UICommonItem:SetMaterialSelect(false)
      self.selectMaterial[item.gunWeaponModData.id].selectCount = 0
      self.curSelectCount = self.curSelectCount - 1
      self.selectMaterial[item.gunWeaponModData.id] = nil
    else
      if self.targetLevel >= self.gunWeaponModData.maxLevel then
        UIUtils.PopupHintMessage(30020)
        return
      end
      if self:GetSelectMaterialCount() >= UIWeaponGlobal.MaxMaterialCount then
        UIUtils.PopupHintMessage(40010)
        return
      elseif needExp <= 0 then
        local hint = TableData.GetHintById(40020)
        CS.PopupMessageManager.PopupString(hint)
        return
      else
        item.selectCount = 1
        item.UICommonItem:SetMaterialSelect(true)
        self.selectMaterial[item.gunWeaponModData.id] = item
        self.curSelectCount = self.curSelectCount + 1
        needExp = needExp - item.gunWeaponModData:GetWeaponOfferExp()
      end
    end
  elseif needExp <= 0 then
    local hint = TableData.GetHintById(40020)
    CS.PopupMessageManager.PopupString(hint)
  else
    if self.targetLevel >= self.gunWeaponModData.maxLevel then
      UIUtils.PopupHintMessage(30020)
      return
    end
    local itemOwn = NetCmdItemData:GetItemCountById(self.itemId)
    if item.selectCount == nil then
      item.selectCount = 0
    end
    if itemOwn < item.selectCount + 1 then
      return
    end
    item.selectCount = item.selectCount + 1
    item.UICommonItem:SetMaterialSelect(true, true)
    self:SetCurItem(item)
    needExp = needExp - item.itemData.args[0]
    self.curSelectCount = self.curSelectCount + 1
    self.selectMaterial[self.itemId] = item
  end
  self:SetCurItem(item)
  self:UpdateCompareDetail()
  self:UpdateSelectListData()
end
function UIChrWeaponPartsPowerUpPanelV3:SetCurItem(item)
  local refreshIndex1 = 0
  local refreshIndex2 = 0
  if self.curItem then
    if self.curItem.itemData ~= nil and self.curPropsDetailsId ~= self.curItem.itemData.id then
      ComPropsDetailsHelper:ShowOrHide(false)
    elseif self.curItem.gunWeaponModData ~= nil and self.curPropsDetailsId ~= self.curItem.gunWeaponModData.id then
      ComPropsDetailsHelper:ShowOrHide(false)
    end
    refreshIndex1 = self.curItem.index
  end
  if item then
    self.curItem = item
    refreshIndex2 = self.curItem.index
  else
    self.curItem = nil
  end
  self.ui.mVirtualListEx_GrpWeaponPartsList:RefreshItem(refreshIndex1)
  self.ui.mVirtualListEx_GrpWeaponPartsList:RefreshItem(refreshIndex2)
end
function UIChrWeaponPartsPowerUpPanelV3:BeginMinusLongPress(item)
  if item.itemData == nil or item.selectCount == 0 then
    return
  end
  item.selectCount = 0
  self.selectMaterial[self.itemId] = nil
  self:SetCurItem(item)
  self:UpdateSelectListData()
end
function UIChrWeaponPartsPowerUpPanelV3:BeginLongPress(item)
  if self.targetLevel >= self.gunWeaponModData.maxLevel or item.itemData == nil then
    return
  end
  local maxLevelExp = self:GetPartTotalExpByLevel(self.gunWeaponModData.maxLevel)
  local needExp = maxLevelExp - self.totalExp
  local itemOwn = NetCmdItemData:GetItemCountById(self.itemId)
  local itemExp = item.itemData.args[0]
  local needNum = math.ceil(needExp / itemExp)
  if self.selectMaterial[self.itemId] == nil then
    self.selectMaterial[self.itemId] = item
  end
  local targetAddNum = 5
  if needNum < 5 then
    targetAddNum = needNum
  end
  if itemOwn < item.selectCount + targetAddNum then
    item.selectCount = itemOwn
  else
    item.selectCount = item.selectCount + targetAddNum
  end
  self:SetCurItem(item)
  self:UpdateSelectListData()
end
function UIChrWeaponPartsPowerUpPanelV3:OnClickLock(isOn)
  if isOn == self.gunWeaponModData.IsLocked then
    return
  end
  NetCmdWeaponPartsData:ReqWeaponPartLockUnlock(self.gunWeaponModData.id, function(ret)
    if ret == ErrorCodeSuc then
      self:UpdateLockStatue()
    end
  end)
end
function UIChrWeaponPartsPowerUpPanelV3:OnClickLockCallback(gunWeaponModData, needRefreshListItem)
  if needRefreshListItem == nil then
    needRefreshListItem = false
  end
  if self.curItem ~= nil and needRefreshListItem then
    self.curItem.selectCount = 0
    self.curItem.UICommonItem:SetMaterialSelect(false)
    self.ui.mVirtualListEx_GrpWeaponPartsList:RefreshItem(self.curItem.index)
  end
  if gunWeaponModData.IsLocked then
    self.selectMaterial[gunWeaponModData.id] = nil
    self.curSelectCount = self.curSelectCount - 1
  end
  self:UpdateSelectListData()
end
function UIChrWeaponPartsPowerUpPanelV3:UpdateLockStatue()
  self.lockItem:SetLock(self.gunWeaponModData.IsLocked)
end
function UIChrWeaponPartsPowerUpPanelV3:OpenLevelUpPanel(tempPropList)
  local lvUpData = CommonLvUpData.New(self.recordLv, self.targetLevel, 102103)
  lvUpData:SetWeaponPartLvUpData(nil, tempPropList, self.subPropList, self.gunWeaponModData.subPropList)
  lvUpData:SetMaxLv(self.targetLevel == self.gunWeaponModData.maxLevel)
  UIManager.OpenUIByParam(UIDef.UIWeaponPartLvUpSuccPanelV3, lvUpData)
end
function UIChrWeaponPartsPowerUpPanelV3:SetActiveObj(obj, active)
  if obj ~= nil then
    setactive(obj, active)
  end
end
