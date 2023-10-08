require("UI.UIBasePanel")
require("UI.Lounge.DormGlobal")
require("UI.FacilityBarrackPanel.Item.ComChrInfoItem")
UIDormChrChangePanel = class("UIDormChrChangePanel", UIBasePanel)
UIDormChrChangePanel.__index = UIDormChrChangePanel
function UIDormChrChangePanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Is3DPanel = true
end
function UIDormChrChangePanel:OnInit(root, gunCmdData)
  local tmpGunCmdData = NetCmdLoungeData:GetCurrGunCmdData()
  self.IsChanging = false
  self:SetGunCmdData(tmpGunCmdData, false)
  self.isGunLock = tmpGunCmdData.isDormLockGun
  self.mCurDormGunCmdData = nil
  self:SetCurDormGunCmdData(tmpGunCmdData)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.ui.mText_Name.text = TableData.GetHintById(280011)
  self:AddBtnListener()
  self:InitGunList()
  self:InitScreen()
  setactivewithcheck(self.ui.mTrans_Screen, false)
end
function UIDormChrChangePanel:InitGunList()
  self.gunCmdDataList = NetCmdTeamData:GetBarrackGunCmdDatas()
  self.lockGunDataList = NetCmdTeamData:GetBarrackLockGunCmdDatas()
  for i = 0, self.lockGunDataList.Count - 1 do
    self.gunCmdDataList:Add(self.lockGunDataList[i])
  end
  function self.itemProvider()
    return self:ItemProvider()
  end
  function self.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  self.ui.mVirtualListEx_GrpList.itemProvider = self.itemProvider
  self.ui.mVirtualListEx_GrpList.itemRenderer = self.itemRenderer
end
function UIDormChrChangePanel:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIDormChrChangePanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    self:OnClickChange()
  end
end
function UIDormChrChangePanel:OnClickChange()
  self:SetCurDormGunCmdData(self.mGunCmdData)
  self.ui.mText_ChrName.text = self.mGunData.name.str
  self:UpdatePanel()
  if self.preChrItem then
    self.preChrItem:SetIsSelectTeamGun(self.mCurDormGunCmdData.Id)
  end
  self.curChrItem:SetIsSelectTeamGun(self.mCurDormGunCmdData.Id)
  NetCmdLoungeData:SendEnterDorm(self.mCurDormGunCmdData.id, function(ret)
    if ret == ErrorCodeSuc then
    end
  end)
  self.IsChanging = true
  UISystem.UISystemBlackCanvas:PlayFadeOutEnhanceBlack(0.5, function()
    UIManager.CloseUI(UIDef.UIDormChrChangePanel)
    CS.LoungeModelManager.Instance:SwitchGunModel(self.mGunCmdData.Id)
    LoungeHelper.CameraCtrl.CameraPreObj:ExitLookAt()
    TimerSys:DelayCall(0.5, function()
      UISystem.UISystemBlackCanvas:PlayFadeInEnhanceBlack(0.5, nil)
    end)
  end)
end
function UIDormChrChangePanel:ItemProvider()
  local itemView = ComChrInfoItem.New()
  itemView:InitCtrl(self.ui.mScrollListChild_Content.transform)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIDormChrChangePanel:ItemRenderer(index, renderData)
  local item = renderData.data
  local data
  if index >= self.gunCmdDataList.Count then
    return
  end
  data = self.gunCmdDataList[index]
  item:SetDormData(data, data.gunData, function()
    self:OnChrInfoItemClick(item)
  end)
  item:SetIsSelectTeamGun(self.mCurDormGunCmdData.Id)
  if self.mGunData.Id == item.mGunData.Id then
    self:OnChrInfoItemClick(item)
    item:SetSelect(true)
  else
    item:SetSelect(false)
  end
end
function UIDormChrChangePanel:OnChrInfoItemClick(chrInfoItem)
  if self.IsChanging then
    return
  end
  if chrInfoItem then
    if self.curChrItem then
      if self.curChrItem.mGunData.id == chrInfoItem.mGunData.id then
        return
      end
      self.curChrItem:SetSelect(false)
    end
    chrInfoItem:SetSelect(true)
    self.preChrItem = self.curChrItem
    self.curChrItem = chrInfoItem
    local gunCmdData = NetCmdTeamData:GetGunDormUnlockByID(chrInfoItem.mGunData.id)
    self.isGunLock = gunCmdData == nil
    if gunCmdData == nil then
      local tmpGunCmdData = CS.GunCmdData()
      tmpGunCmdData:SetData(chrInfoItem.mGunData.id)
      self:SetGunCmdData(tmpGunCmdData, not tmpGunCmdData.isDormLockGun)
    else
      self:SetGunCmdData(gunCmdData, not gunCmdData.isDormLockGun)
    end
    if self.mGunCmdData == nil then
      self:SetGunCmdData(NetCmdTeamData:GetLockGunData(chrInfoItem.mGunData.id))
    end
    self:UpdatePanel()
  end
end
function UIDormChrChangePanel:UpdateGunList()
  local tmpResultList = self.comScreenItem:GetResultList()
  local hasNoLockGun = tmpResultList.Count == 0
  self:UpdateToggleRedPoint()
  if not hasNoLockGun then
    self.gunCmdDataList = tmpResultList
    if self.mGunCmdData == nil then
      self:SetGunCmdData(tmpResultList[0], false)
    end
    local itemDataList = LuaUtils.ConvertToItemIdList(self.gunCmdDataList)
    self.ui.mVirtualListEx_GrpList:SetItemIdList(itemDataList)
    self.ui.mVirtualListEx_GrpList.numItems = self.gunCmdDataList.Count
  else
    self.ui.mVirtualListEx_GrpList.numItems = 0
  end
  if self.curChrItem ~= nil then
    self.curChrItem:SetSelect(false)
    self.curChrItem = nil
  end
  self.ui.mVirtualListEx_GrpList:Refresh()
end
function UIDormChrChangePanel:UpdatePanel()
  if self.isGunLock then
    local unlockDesc = ""
    for i = 0, self.mGunCmdData.UnlockDorm.Count - 1 do
      local id = self.mGunCmdData.UnlockDorm[i]
      local achieve = TableData.listAchievementDetailDatas:GetDataById(id)
      unlockDesc = unlockDesc .. achieve.des.str
    end
    self.ui.mText_Lock.text = unlockDesc
  end
  setactive(self.ui.mTrans_Lock, self.isGunLock)
  setactive(self.ui.mTrans_Now, self.mGunCmdData.Id == self.mCurDormGunCmdData.Id)
  setactive(self.ui.mBtn_Confirm, self.mGunCmdData.Id ~= self.mCurDormGunCmdData.Id and not self.isGunLock)
end
function UIDormChrChangePanel:SetGunCmdData(gunCmdData, changeAnim)
  changeAnim = changeAnim == nil and true or changeAnim
  self.mGunCmdData = gunCmdData
  if self.mGunCmdData ~= nil then
    self.mGunData = self.mGunCmdData.TabGunData
  end
  if self.mGunData == nil then
    self.mGunData = TableData.listGunDatas:GetDataById(gunCmdData.stc_id)
  end
end
function UIDormChrChangePanel:SetCurDormGunCmdData(gunCmdData)
  self.mCurDormGunCmdData = gunCmdData
  NetCmdLoungeData:SetGunId(gunCmdData.Id)
end
function UIDormChrChangePanel:ResetSaveGunId()
  if DormGlobal.ScreenPanelGunId == 0 then
    return
  end
  local gunCmdData = NetCmdTeamData:GetGunDormUnlockByID(DormGlobal.ScreenPanelGunId)
  self.isGunLock = gunCmdData == nil
  if gunCmdData == nil then
    local tmpGunCmdData = CS.GunCmdData()
    tmpGunCmdData:SetData(DormGlobal.ScreenPanelGunId)
    self:SetGunCmdData(tmpGunCmdData, false)
  else
    self:SetGunCmdData(gunCmdData, false)
  end
  DormGlobal.ScreenPanelGunId = 0
end
function UIDormChrChangePanel:UpdateToggleRedPoint()
  if not self.isUnLock then
    return
  end
  local redPoint = 0
  local lockGuns = NetCmdTeamData:GetBarrackLockGunCmdDatas()
  for i = 0, lockGuns.Count - 1 do
    redPoint = redPoint + lockGuns[i]:GetGunRedPoint()
  end
end
function UIDormChrChangePanel:OnShowStart()
  self.ui.mText_ChrName.text = self.mGunData.name.str
  self:UpdatePanel()
  self:UpdateComScreenItem()
  self:UpdateGunList()
end
function UIDormChrChangePanel:UpdateComScreenItem()
  self.comScreenItem:SetUserData(false)
  self.comScreenItem:SetList(self.gunCmdDataList)
end
function UIDormChrChangePanel:InitScreen()
  if self.comScreenItem ~= nil then
    return
  end
  self.comScreenItem = ComScreenItemHelper:InitDormGun(self.ui.mScrollListChild_GrpScreen.gameObject, self.gunCmdDataList, function()
    self:UpdateGunList()
  end, nil, true)
  self.comScreenItem:SetOnShowMultiListFilterCallback(function()
    self:ResetEscapeBtn(true)
  end)
  self.comScreenItem:SetOnCloseMultiListFilterCallback(function()
    self:ResetEscapeBtn(false)
  end)
end
function UIDormChrChangePanel:ResetEscapeBtn(boolean)
  if boolean then
    self:UnRegistrationKeyboard(KeyCode.Escape)
    self:RegistrationKeyboardAction(KeyCode.Escape, function()
      self.comScreenItem:OnCloseMultiListFilter()
    end)
  else
    self:UnRegistrationKeyboard(KeyCode.Escape)
    self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Back)
  end
end
function UIDormChrChangePanel:OnShowFinish()
  LoungeHelper.CameraCtrl.isDebug = false
end
function UIDormChrChangePanel:OnClose()
  self.IsChanging = false
  self.comScreenItem:OnCloseFilterBtnClick()
  LoungeHelper.CameraCtrl.isDebug = true
end
function UIDormChrChangePanel:OnRelease()
end
function UIDormChrChangePanel:OnCameraStart()
  return 0.01
end
function UIDormChrChangePanel:OnCameraBack()
  return 0.01
end
