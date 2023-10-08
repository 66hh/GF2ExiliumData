require("UI.UIBasePanel")
require("UI.FacilityBarrackPanel.Item.ComChrInfoItem")
require("UI.FacilityBarrackPanel.FacilityBarrackGlobal")
UIChrWeaponChangeEquipedChrDialog = class("UIChrWeaponChangeEquipedChrDialog", UIBasePanel)
UIChrWeaponChangeEquipedChrDialog.__index = UIChrWeaponChangeEquipedChrDialog
function UIChrWeaponChangeEquipedChrDialog:ctor(csPanel)
  UIChrWeaponChangeEquipedChrDialog.super:ctor(csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIChrWeaponChangeEquipedChrDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.mGunCmdData = nil
  self.mGunData = nil
  self.curChrItem = nil
  self.gunCmdDataList = nil
  self.curGunId = 0
  self.closeCallback = nil
  self:InitGunList()
  self:InitScreen()
end
function UIChrWeaponChangeEquipedChrDialog:OnInit(root, data)
  self.super.SetRoot(self, root)
  self.curGunId = data[1]
  self.closeCallback = data[2]
  local gunCmdData = NetCmdTeamData:GetGunByID(self.curGunId)
  self:SetGunCmdData(gunCmdData)
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:CloseUIAndSaveCurGun(true)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBack.gameObject).onClick = function()
    self:CloseUIAndSaveCurGun(true)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnHome.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBreak.gameObject).onClick = function()
    self:CloseUIAndSaveCurGun(true)
  end
end
function UIChrWeaponChangeEquipedChrDialog:OnShowStart()
  self:UpdateGunList()
end
function UIChrWeaponChangeEquipedChrDialog:OnRecover()
end
function UIChrWeaponChangeEquipedChrDialog:OnBackFrom()
end
function UIChrWeaponChangeEquipedChrDialog:OnTop()
end
function UIChrWeaponChangeEquipedChrDialog:OnShowFinish()
  self:ScrollToCurItem()
end
function UIChrWeaponChangeEquipedChrDialog:OnUpdate(deltaTime)
end
function UIChrWeaponChangeEquipedChrDialog:OnHide()
end
function UIChrWeaponChangeEquipedChrDialog:OnHideFinish()
end
function UIChrWeaponChangeEquipedChrDialog:OnClose()
  self:UpdateGunModel()
  if self.comScreenItem then
    self.comScreenItem:OnCloseFilterBtnClick()
  end
  if self.closeCallback then
    self.closeCallback()
  end
end
function UIChrWeaponChangeEquipedChrDialog:OnRelease()
  if self.comScreenItem then
    self.comScreenItem:OnRelease()
    self.comScreenItem = nil
  end
  self.super.OnRelease(self)
end
function UIChrWeaponChangeEquipedChrDialog:InitGunList()
  self.gunCmdDataList = NetCmdTeamData:GetBarrackGunCmdDatas()
  function self.itemProvider()
    return self:ItemProvider()
  end
  function self.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  self.ui.mVirtualListEx_GrpList.itemProvider = self.itemProvider
  self.ui.mVirtualListEx_GrpList.itemRenderer = self.itemRenderer
end
function UIChrWeaponChangeEquipedChrDialog:ItemProvider()
  local itemView = ComChrInfoItem.New()
  itemView:InitCtrl(self.ui.mScrollListChild_Content.transform)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIChrWeaponChangeEquipedChrDialog:ItemRenderer(index, renderData)
  local item = renderData.data
  local data
  if index >= self.gunCmdDataList.Count then
    return
  end
  data = self.gunCmdDataList[index]
  item:SetData(data, data.gunData, function()
    self:OnChrInfoItemClick(item)
  end)
  if self.mGunCmdData.GunId == item.mGunData.Id then
    self:OnChrInfoItemClick(item, false)
    item:SetSelect(true)
  else
    item:SetSelect(false)
  end
  local go = item:GetRoot().gameObject
  local itemId = data.gunData.id
  MessageSys:SendMessage(GuideEvent.VirtualListRendererChanged, VirtualListRendererChangeData(go, itemId, index))
end
function UIChrWeaponChangeEquipedChrDialog:InitScreen()
  if self.comScreenItem ~= nil then
    return
  end
  self.comScreenItem = ComScreenItemHelper:InitGun(self.ui.mScrollListChild_GrpScreen.gameObject, self.gunCmdDataList, function()
    self:UpdateGunList()
  end, nil, true)
  self.comScreenItem:SwitchPreset(1)
  self.comScreenItem:SetOnShowMultiListFilterCallback(function()
    self:ResetEscapeBtn(true)
  end)
  self.comScreenItem:SetOnCloseMultiListFilterCallback(function()
    self:ResetEscapeBtn(false)
  end)
end
function UIChrWeaponChangeEquipedChrDialog:SetGunCmdData(gunCmdData)
  self.mGunCmdData = gunCmdData
  self.mGunData = self.mGunCmdData.TabGunData
end
function UIChrWeaponChangeEquipedChrDialog:UpdateGunList()
  local tmpResultList = self.comScreenItem:GetResultList()
  self.gunCmdDataList = tmpResultList
  local itemDataList = LuaUtils.ConvertToItemIdList(self.gunCmdDataList)
  self.ui.mVirtualListEx_GrpList:SetItemIdList(itemDataList)
  self.ui.mVirtualListEx_GrpList.numItems = self.gunCmdDataList.Count
  self.ui.mVirtualListEx_GrpList:SetConstraintCount(1)
  if self.curChrItem ~= nil then
    self.curChrItem:SetSelect(false)
    self.curChrItem = nil
  end
  self.ui.mVirtualListEx_GrpList:Refresh()
end
function UIChrWeaponChangeEquipedChrDialog:UpdateModel()
  local weaponId = self.mGunCmdData.WeaponId
  MessageSys:SendMessage(CS.GF2.Message.FacilityBarrackEvent.OnChangeWeapon, weaponId)
  MessageSys:SendMessage(CS.GF2.Message.FacilityBarrackEvent.OnSwitchGun, self.mGunCmdData.GunId)
end
function UIChrWeaponChangeEquipedChrDialog:UpdateGunModel()
  CS.UIBarrackModelManager.Instance:SwitchGunModel(self.mGunCmdData)
end
function UIChrWeaponChangeEquipedChrDialog:CloseUIAndSaveCurGun(isSave)
  local targetGunId = 0
  UIManager.CloseUI(UIDef.UIChrWeaponChangeEquipedChrDialog)
end
function UIChrWeaponChangeEquipedChrDialog:ScrollToCurItem()
  for i = 0, self.gunCmdDataList.Count - 1 do
    local itemData = self.gunCmdDataList[i]
    if self.curGunId == itemData.id then
      self.ui.mVirtualListEx_GrpList:CalculateScrollTo(i, false, nil, ScrollAlign.Start, true)
      break
    end
  end
end
function UIChrWeaponChangeEquipedChrDialog:OnChrInfoItemClick(chrInfoItem, needUpdateModel)
  if chrInfoItem then
    self:UpdateAction(self.curGunId == chrInfoItem.mGunData.id)
    if self.curChrItem then
      if self.curChrItem.mGunData.id == chrInfoItem.mGunData.id then
        return
      end
      self.curChrItem:SetSelect(false)
    end
    chrInfoItem:SetSelect(true)
    self.curChrItem = chrInfoItem
    local gunCmdData = NetCmdTeamData:GetGunByID(chrInfoItem.mGunData.id)
    self:SetGunCmdData(gunCmdData)
    if needUpdateModel == nil or needUpdateModel then
      self:UpdateModel()
    end
  end
end
function UIChrWeaponChangeEquipedChrDialog:UpdateAction(boolean)
  setactive(self.ui.mBtn_BtnBreak.gameObject, not boolean)
  setactive(self.ui.mTrans_Selected.gameObject, boolean)
end
function UIChrWeaponChangeEquipedChrDialog:ResetEscapeBtn(boolean)
  if boolean then
    self:UnRegistrationKeyboard(KeyCode.Escape)
    self:RegistrationKeyboardAction(KeyCode.Escape, function()
      self.comScreenItem:OnCloseMultiListFilter()
    end)
  else
    self:UnRegistrationKeyboard(KeyCode.Escape)
    self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_BtnBack)
  end
end
