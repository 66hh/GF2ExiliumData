require("UI.Common.UICommonItem")
UIComDoubleCheckDialog = class("UIComDoubleCheckDialog", UIBasePanel)
UIComDoubleCheckDialog.__index = UIComDoubleCheckDialog
function UIComDoubleCheckDialog:ctor(csPanel)
  UIComDoubleCheckDialog.super:ctor(csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  UIComDoubleCheckDialog.DialogType = {
    WeaponBreak = 1,
    WeaponPartUninstall = 2,
    GunSkin = 3,
    ItemShow = 4
  }
  self.param = {
    useResourcesBar = false,
    title = nil,
    contentText = nil,
    tips = nil,
    isDouble = false,
    dialogType = 0,
    customData = nil,
    confirmCallback = nil,
    cancelCallback = nil
  }
  self.UICommonItems = {}
end
function UIComDoubleCheckDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
end
function UIComDoubleCheckDialog:OnInit(root, param)
  self.param = param
  self:SetData()
end
function UIComDoubleCheckDialog:OnShowStart()
end
function UIComDoubleCheckDialog:OnRecover()
end
function UIComDoubleCheckDialog:OnBackFrom()
end
function UIComDoubleCheckDialog:OnTop()
end
function UIComDoubleCheckDialog:OnShowFinish()
end
function UIComDoubleCheckDialog:OnHide()
end
function UIComDoubleCheckDialog:OnHideFinish()
end
function UIComDoubleCheckDialog:OnClose()
  self:ReleaseCtrlTable(self.UICommonItems, true)
end
function UIComDoubleCheckDialog:OnRelease()
  self.super.OnRelease(self)
end
function UIComDoubleCheckDialog:SetData()
  setactivewithcheck(self.ui.mTrans_ConsumeRoot, false)
  setactive(self.ui.mTrans_Top.gameObject, self.param.useResourcesBar ~= nil and self.param.useResourcesBar)
  setactive(self.ui.mBtn_BtnCancel.gameObject, self.param.isDouble ~= nil and self.param.isDouble)
  self:InitBtnClick()
  if self.param.title ~= nil then
    setactive(self.ui.mText_TitleText.gameObject, true)
    self.ui.mText_TitleText.text = self.param.title
  else
    setactive(self.ui.mText_TitleText.gameObject, false)
  end
  if self.param.contentText ~= nil then
    self.ui.mText_TextName.text = self.param.contentText
  end
  if self.param.tips ~= nil then
    self.ui.mText_Description.text = self.param.tips
  end
  if self.param.customData ~= nil and self.param.dialogType ~= 0 then
    if self.param.dialogType == UIComDoubleCheckDialog.DialogType.WeaponBreak then
      self:ShowWeaponBreakDialog(self.param.customData)
    elseif self.param.dialogType == UIComDoubleCheckDialog.DialogType.WeaponPartUninstall then
      self:ShowWeaponPartUninstallDialog(self.param.customData)
    elseif self.param.dialogType == UIComDoubleCheckDialog.DialogType.GunSkin then
      self:ShowGunSkinDialog(self.param.customData)
    elseif self.param.dialogType == UIComDoubleCheckDialog.DialogType.ItemShow then
      self:ShowItemDialog(self.param.customData)
    end
  end
end
function UIComDoubleCheckDialog:InitBtnClick()
  if self.param.confirmCallback ~= nil then
    UIUtils.GetButtonListener(self.ui.mBtn_BtnConfirm.gameObject).onClick = function()
      self.param.confirmCallback()
      UIManager.CloseUI(UIDef.UIComDoubleCheckDialog)
    end
  else
    UIUtils.GetButtonListener(self.ui.mBtn_BtnConfirm.gameObject).onClick = function()
      UIManager.CloseUI(UIDef.UIComDoubleCheckDialog)
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnCancel.gameObject).onClick = function()
    if self.param.cancelCallback ~= nil then
      self.param.cancelCallback()
    end
    UIManager.CloseUI(UIDef.UIComDoubleCheckDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    if self.param.cancelCallback ~= nil then
      self.param.cancelCallback()
    end
    UIManager.CloseUI(UIDef.UIComDoubleCheckDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    if self.param.cancelCallback ~= nil then
      self.param.cancelCallback()
    end
    UIManager.CloseUI(UIDef.UIComDoubleCheckDialog)
  end
end
function UIComDoubleCheckDialog:ShowWeaponBreakDialog(weaponCmdData)
  local item = UICommonItem.New()
  item:InitCtrl(self.ui.mScrollListChild_Content)
  item:SetWeaponData(weaponCmdData, nil, nil, nil, nil, nil, false)
  table.insert(self.UICommonItems, item)
end
function UIComDoubleCheckDialog:ShowWeaponPartUninstallDialog(gunWeaponModDatas)
  local gunWeaponModData
  for i = 0, gunWeaponModDatas.Count - 1 do
    local item = UICommonItem.New()
    gunWeaponModData = gunWeaponModDatas[i]
    item:InitCtrl(self.ui.mScrollListChild_Content)
    item:SetPartData(gunWeaponModData)
    setactive(item.ui.mTrans_Equipped_InGun, false)
    setactive(item.ui.mImage_Head, false)
    setactive(item.ui.mTrans_Equipped_InWeapon, false)
    table.insert(self.UICommonItems, item)
  end
end
function UIComDoubleCheckDialog:ShowGunSkinDialog(storeData)
  local itemAndNumList = TableData.SpliteStrToItemAndNumList(storeData.reward)
  for i = 0, itemAndNumList.Count - 1 do
    local itemAndNum = itemAndNumList[i]
    local item = UICommonItem.New()
    item:InitCtrl(self.ui.mScrollListChild_Content)
    item:SetItemData(itemAndNum.itemid, itemAndNum.num)
    table.insert(self.UICommonItems, item)
  end
  local costItemId = storeData.price_type
  local storeCmdData = NetCmdStoreData:GetStoreGoodsById(storeData.id)
  local costNum = tonumber(storeCmdData.price)
  if costItemId == 0 or costNum == 0 then
    setactivewithcheck(self.ui.mTrans_ConsumeRoot, false)
  else
    self.ui.mText_ConsumeTitle.text = TableData.GetHintById(230008)
    local n1, n2 = math.modf(costNum)
    self.ui.mText_ConsumeNum.text = n1
    self.ui.mImage_ConsumeIcon.sprite = IconUtils.GetItemIconSprite(costItemId)
    setactivewithcheck(self.ui.mTrans_ConsumeRoot, true)
  end
end
function UIComDoubleCheckDialog:ShowItemDialog(itemListData)
  local itemAndNumList = itemListData
  for i = 1, #itemAndNumList do
    local itemAndNum = itemAndNumList[i]
    local item = UICommonItem.New()
    item:InitCtrl(self.ui.mScrollListChild_Content)
    item:SetItemData(itemAndNum.itemId, itemAndNum.itemNum, nil, nil, nil, itemAndNum.id)
    table.insert(self.UICommonItems, item)
  end
end
