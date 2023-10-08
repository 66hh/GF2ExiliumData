require("UI.WeaponPanel.WeaponV4.Item.ChrPolaritySelItem")
require("UI.WeaponPanel.WeaponV4.Item.ChrWeaponPartsBlankBoardItem")
require("UI.Common.UICommonItem")
UIChrWeaponCustomPolarityDialog = class("UIChrWeaponCustomPolarityDialog", UIBasePanel)
UIChrWeaponCustomPolarityDialog.__index = UIChrWeaponCustomPolarityDialog
function UIChrWeaponCustomPolarityDialog:ctor(csPanel)
  UIChrWeaponCustomPolarityDialog.super:ctor(csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  self.param = {
    title = nil,
    weaponCmdData = nil,
    slotIndex = nil,
    isRandom = nil,
    gunWeaponModData = nil,
    polarityTagData = nil
  }
  self.nextGunWeaponModData = nil
  self.ChrPolaritySelItemList = {}
  self.curChrPolaritySelItem = nil
  self.curWeaponPartItem = nil
  self.curWeaponPartItem2 = nil
  self.curCostItemDataA = nil
  self.curCostItemDataB = nil
  self.isAEnough = true
  self.isBEnough = true
  self.isFirstGet = false
  self.curRecommendItemIndex = 0
  self.polaritySuccess = false
end
function UIChrWeaponCustomPolarityDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
end
function UIChrWeaponCustomPolarityDialog:OnInit(root, param)
  self.param = param
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIChrWeaponCustomPolarityDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIChrWeaponCustomPolarityDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnCancel.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIChrWeaponCustomPolarityDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnConfirm.gameObject).onClick = function()
    self:OnClickConfirm()
  end
  self:InitCustomViewPartItem()
end
function UIChrWeaponCustomPolarityDialog:OnShowStart()
  self:SetPolarityData()
end
function UIChrWeaponCustomPolarityDialog:OnRecover()
end
function UIChrWeaponCustomPolarityDialog:OnBackFrom()
  self:SetPolarityData()
end
function UIChrWeaponCustomPolarityDialog:OnTop()
end
function UIChrWeaponCustomPolarityDialog:OnShowFinish()
end
function UIChrWeaponCustomPolarityDialog:OnRefresh()
  self:SetPolarityData()
end
function UIChrWeaponCustomPolarityDialog:OnHide()
end
function UIChrWeaponCustomPolarityDialog:OnHideFinish()
end
function UIChrWeaponCustomPolarityDialog:OnClose()
  if not self.param.isRandom and self.polaritySuccess and not self.isFirstGet then
    UIWeaponGlobal.SetPolarityIndex(self.param.slotIndex)
  end
  self.polaritySuccess = false
end
function UIChrWeaponCustomPolarityDialog:OnRelease()
  self.super.OnRelease(self)
end
function UIChrWeaponCustomPolarityDialog:InitChrPolaritySelItem()
  local count = TableData.listPolarityTagDatas.Count
  local parent = self.ui.mScrollListChild_Content
  for i = 0, count - 1 do
    local item = ChrPolaritySelItem.New()
    local obj
    if i < parent.transform.childCount then
      obj = parent.transform:GetChild(i).gameObject
    end
    item:InitCtrl(parent, obj)
    local tmpPolarityTagData = TableData.listPolarityTagDatas:GetDataById(i + 1)
    item:SetPolarityTagData(tmpPolarityTagData)
    table.insert(self.ChrPolaritySelItemList, item)
  end
  self:SetItemWeaponModData()
  for i, v in ipairs(self.ChrPolaritySelItemList) do
    local chrPolaritySelItem = v
    chrPolaritySelItem:SetBtnEnabled(true)
    chrPolaritySelItem:SetBtnInteractable(true)
  end
  setactive(parent.gameObject, false)
  setactive(parent.gameObject, true)
end
function UIChrWeaponCustomPolarityDialog:SetItemWeaponModData()
  self.curRecommendItemIndex = 0
  for i, v in ipairs(self.ChrPolaritySelItemList) do
    local chrPolaritySelItem = v
    if self.param.isRandom then
      chrPolaritySelItem.isRecommend = false
      chrPolaritySelItem:SetGunWeaponModData(nil)
      chrPolaritySelItem:SetGunWeaponModData(nil)
    else
      local gunWeaponModData = self.param.weaponCmdData:GetWeaponPartByType(self.param.slotIndex - 1)
      chrPolaritySelItem:SetGunWeaponModData(gunWeaponModData)
      if chrPolaritySelItem.isRecommend then
        self.curRecommendItemIndex = i
      end
    end
  end
end
function UIChrWeaponCustomPolarityDialog:InitCustomViewPartItem()
  local tmpParent = self.ui.mScrollListChild_Blank
  local item = ChrWeaponPartsBlankBoardItem.New()
  local obj
  if tmpParent.transform.childCount > 0 then
    obj = tmpParent.transform:GetChild(0).gameObject
  end
  item:InitCtrl(tmpParent, obj)
  item:SetWeaponPartData(nil, self.param.weaponModTypeData)
  self.curWeaponPartItem = self:InitWeaponPartItem(self.ui.mScrollListChild_Equiped)
  self.curWeaponPartItem2 = self:InitWeaponPartItem(self.ui.mScrollListChild_Equiped2)
end
function UIChrWeaponCustomPolarityDialog:InitWeaponPartItem(scrollListChild)
  local item = UICommonItem.New()
  if scrollListChild.transform.childCount == 0 then
    item:InitCtrl(scrollListChild)
  else
    item:InitObj(scrollListChild.transform:GetChild(0))
  end
  return item
end
function UIChrWeaponCustomPolarityDialog:SetPolarityData()
  self.ui.mText_TitleText.text = self.param.title
  if self.param.isRandom then
    self:RandomPolarity()
  else
    self:CustomPolarity()
  end
  self:SetNowPolarity()
  self:UpdateChrPolaritySelItemList()
  self:UpdateCost()
end
function UIChrWeaponCustomPolarityDialog:RandomPolarity()
  setactive(self.ui.mTrans_ComTop.gameObject, true)
  setactive(self.ui.mTrans_CustomTop.gameObject, false)
  setactive(self.ui.mTrans_CustomView.gameObject, false)
end
function UIChrWeaponCustomPolarityDialog:CustomPolarity()
  setactive(self.ui.mTrans_ComTop.gameObject, false)
  setactive(self.ui.mTrans_CustomTop.gameObject, true)
  setactive(self.ui.mTrans_CustomView.gameObject, true)
end
function UIChrWeaponCustomPolarityDialog:SetNowPolarity()
  setactive(self.ui.mTrans_Icon.gameObject, self.param.polarityTagData ~= nil)
  setactive(self.ui.mTrans_Text.gameObject, self.param.polarityTagData == nil)
  if self.param.polarityTagData ~= nil then
    self.ui.mImg_Icon.sprite = IconUtils.GetElementIcon(self.param.polarityTagData.icon)
  end
end
function UIChrWeaponCustomPolarityDialog:UpdateChrPolaritySelItemList()
  if self.ChrPolaritySelItemList == nil or #self.ChrPolaritySelItemList == 0 then
    self:InitChrPolaritySelItem()
  end
  self.curChrPolaritySelItem = nil
  for i, v in ipairs(self.ChrPolaritySelItemList) do
    local chrPolaritySelItem = v
    chrPolaritySelItem:SetActive(true)
    chrPolaritySelItem:SetBtnInteractable(not self.param.isRandom)
    chrPolaritySelItem:SetBtnEnabled(not self.param.isRandom)
    if not self.param.isRandom then
      chrPolaritySelItem:OnButtonClick(function()
        self:OnClickChrPolaritySelItem(chrPolaritySelItem)
      end)
    end
  end
  if not self.param.isRandom then
    local curIndex = 1
    if self.curRecommendItemIndex ~= 0 then
      curIndex = self.curRecommendItemIndex
    end
    local tmpItem = self.ChrPolaritySelItemList[curIndex]
    if not tmpItem.isActive then
      tmpItem = self.ChrPolaritySelItemList[2]
    end
    self:OnClickChrPolaritySelItem(tmpItem)
  end
end
function UIChrWeaponCustomPolarityDialog:UpdateCost()
  local cost
  if self.param.isRandom then
    cost = self.param.weaponCmdData.StcData.polarity_cost_random
  else
    cost = self.param.weaponCmdData.StcData.polarity_cost_custom
  end
  local costTable = {}
  for k, v in pairs(cost) do
    table.insert(costTable, {id = k, value = v})
  end
  table.sort(costTable, function(a, b)
    return a.id > b.id
  end)
  local paramA = costTable[1]
  local haveACount = NetCmdItemData:GetItemCount(paramA.id)
  local isAEnough = haveACount >= paramA.value
  haveACount = CS.LuaUIUtils.GetNumberText(haveACount)
  self.ui.mImg_Bg.sprite = IconUtils.GetItemIconSprite(costTable[1].id)
  if isAEnough then
    self.ui.mText_CostNum.text = haveACount .. "/" .. paramA.value
  else
    self.ui.mText_CostNum.text = "<color=#FF5E41>" .. haveACount .. "</color>/" .. paramA.value
  end
  local paramB = costTable[2]
  local haveBCount = NetCmdItemData:GetItemCount(paramB.id)
  local isBEnough = haveBCount >= paramB.value
  haveBCount = CS.LuaUIUtils.GetNumberText(haveBCount)
  self.ui.mImg_Bg1.sprite = IconUtils.GetItemIconSprite(costTable[2].id)
  if isBEnough then
    self.ui.mText_CostNum1.text = haveBCount .. "/" .. paramB.value
  else
    self.ui.mText_CostNum1.text = "<color=#FF5E41>" .. haveBCount .. "</color>/" .. paramB.value
  end
  self.curCostItemDataA = TableData.listItemDatas:GetDataById(paramA.id)
  self.curCostItemDataB = TableData.listItemDatas:GetDataById(paramB.id)
  self.isAEnough = isAEnough
  self.isBEnough = isBEnough
  UIUtils.GetButtonListener(self.ui.mBtn_Consume1.gameObject).onClick = function()
    UITipsPanel.Open(self.curCostItemDataA, 0, true)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Consume2.gameObject).onClick = function()
    UITipsPanel.Open(self.curCostItemDataB, 0, true)
  end
end
function UIChrWeaponCustomPolarityDialog:SetWeaponPart()
  setactive(self.ui.mScrollListChild_Blank.gameObject, self.param.gunWeaponModData == nil)
  setactive(self.ui.mScrollListChild_Equiped.gameObject, self.param.gunWeaponModData ~= nil)
  self.isOverflow = self.param.weaponCmdData:CheckCapacityOverflow(self.param.slotIndex - 1, self.curChrPolaritySelItem.polarityTagData.PolarityId)
  if self.isOverflow then
    self.nextGunWeaponModData = self.param.weaponCmdData:GetNextOverflowWeaponPart(self.param.slotIndex - 1)
  else
    self.nextGunWeaponModData = nil
  end
  setactive(self.ui.mScrollListChild_Equiped2.gameObject, self.nextGunWeaponModData ~= nil)
  if self.param.gunWeaponModData ~= nil then
    self.curWeaponPartItem:SetPartData(self.param.gunWeaponModData)
    self.curWeaponPartItem:Reset()
    setactive(self.curWeaponPartItem.ui.mTrans_Num, false)
    local polarityId = self.param.gunWeaponModData.PolarityId
    setactive(self.curWeaponPartItem.ui.mTrans_PolarityIcon, polarityId ~= 0)
    if polarityId ~= 0 then
      self.curWeaponPartItem.ui.mImg_PolarityIcon.sprite = IconUtils.GetElementIcon(TableData.listPolarityTagDatas:GetDataById(polarityId).Icon .. "_S")
    end
    UIUtils.GetButtonListener(self.curWeaponPartItem.ui.mBtn_Select.gameObject).onClick = function()
      UITipsPanel.Open(self.param.gunWeaponModData.ItemData, 0, false, nil, self.param.gunWeaponModData.id)
    end
  end
  if self.nextGunWeaponModData ~= nil then
    self.curWeaponPartItem2:SetPartData(self.nextGunWeaponModData)
    self.curWeaponPartItem2:Reset()
    setactive(self.curWeaponPartItem2.ui.mTrans_Num, false)
    local polarityId = self.nextGunWeaponModData.PolarityId
    setactive(self.curWeaponPartItem2.ui.mTrans_PolarityIcon, polarityId ~= 0)
    if polarityId ~= 0 then
      self.curWeaponPartItem2.ui.mImg_PolarityIcon.sprite = IconUtils.GetElementIcon(TableData.listPolarityTagDatas:GetDataById(polarityId).Icon .. "_S")
    end
    UIUtils.GetButtonListener(self.curWeaponPartItem2.ui.mBtn_Select.gameObject).onClick = function()
      UITipsPanel.Open(self.nextGunWeaponModData.ItemData, 0, false, nil, self.nextGunWeaponModData.id)
    end
  end
  self:CheckOverflow()
end
function UIChrWeaponCustomPolarityDialog:CheckOverflow()
  local hintId
  local color = self.ui.mTextImgColorList_Tips.TextColor[0]
  if self.param.gunWeaponModData == nil then
    hintId = 220050
  elseif self.isOverflow then
    hintId = 220052
    color = self.ui.mTextImgColorList_Tips.TextColor[1]
    if self.nextGunWeaponModData ~= nil then
      hintId = 220062
    end
  else
    hintId = 220051
  end
  local text = TableData.GetHintById(hintId)
  self.ui.mText_Tips.text = text
  self.ui.mText_Tips.color = color
end
function UIChrWeaponCustomPolarityDialog:OnClickChrPolaritySelItem(chrPolaritySelItem)
  if self.curChrPolaritySelItem ~= nil then
    self.curChrPolaritySelItem:SetBtnInteractable(true)
  end
  self.curChrPolaritySelItem = chrPolaritySelItem
  self.curChrPolaritySelItem:SetBtnInteractable(false)
  self:SetWeaponPart()
end
function UIChrWeaponCustomPolarityDialog:OnClickConfirm()
  if not self.isAEnough and not self.isBEnough then
    if self.curCostItemDataA.rank > self.curCostItemDataB.rank then
      UITipsPanel.Open(self.curCostItemDataA, 0, true)
    else
      UITipsPanel.Open(self.curCostItemDataB, 0, true)
    end
    return
  end
  if not self.isAEnough then
    UITipsPanel.Open(self.curCostItemDataA, 0, true)
    return
  end
  if not self.isBEnough then
    UITipsPanel.Open(self.curCostItemDataB, 0, true)
    return
  end
  self:SetInputActive(false)
  local polarityId = 0
  if not self.param.isRandom then
    polarityId = self.curChrPolaritySelItem.polarityTagData.polarity_id
  end
  self.isFirstGet = false
  NetCmdWeaponData:SendWeaponGetPolarization(self.param.weaponCmdData.id, self.param.slotIndex, polarityId, function(ret)
    self:SetInputActive(true)
    if ret == ErrorCodeSuc then
      self.polaritySuccess = true
      UIManager.CloseUI(UIDef.UIChrWeaponCustomPolarityDialog)
      if self.param.polarityTagData == nil then
        local weaponPartType = self.param.weaponCmdData:GetWeaponPartTypeBySlotIndex(self.param.slotIndex - 1)
        local targetPolarityId = self.param.weaponCmdData.Polarization[self.param.slotIndex - 1]
        local param = {
          modType = weaponPartType,
          polarityId = targetPolarityId,
          slotIndex = self.param.slotIndex
        }
        self.isFirstGet = true
        UIWeaponGlobal.SetIsReadyToStartTutorial(false)
        UIManager.OpenUIByParam(UIDef.UIChrWeaponPolarityFirstGetDialog, param)
      else
        self:SelectPolarization()
      end
    end
  end)
end
function UIChrWeaponCustomPolarityDialog:SelectPolarization()
  if self.param.weaponCmdData.SelectPolarization == nil then
    UIUtils.PopupPositiveHintMessage(220030)
    UIWeaponGlobal.SetIsReadyToStartTutorial(true)
    return
  end
  local param = {
    weaponCmdData = self.param.weaponCmdData,
    selectPolarization = self.param.weaponCmdData.SelectPolarization
  }
  UIWeaponGlobal.SetIsReadyToStartTutorial(false)
  UIManager.OpenUIByParam(UIDef.UIChrWeaponPolarityDoubleCheckDialog, param)
end
