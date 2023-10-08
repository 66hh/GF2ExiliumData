require("UI.UIBasePanel")
require("UI.FacilityBarrackPanel.Content.UIBarrackContentBase")
require("UI.FacilityBarrackPanel.Content.UIUpgradeContent")
UICharacterDetailPanel = class("UICharacterDetailPanel", UIBasePanel)
UICharacterDetailPanel.__index = UICharacterDetailPanel
UICharacterDetailPanel.isGunLock = false
UICharacterDetailPanel.tabList = {}
UICharacterDetailPanel.curTab = 0
UICharacterDetailPanel.jumpTab = nil
UICharacterDetailPanel.childPanelList = {}
UICharacterDetailPanel.closeCallback = nil
UICharacterDetailPanel.curGunIndex = 1
UICharacterDetailPanel.currentGun = nil
UICharacterDetailPanel.gunList = {}
UICharacterDetailPanel.gunDataList = {}
UICharacterDetailPanel.gunDataTempList = nil
UICharacterDetailPanel.gunItemList = {}
UICharacterDetailPanel.mGunModelObj = nil
UICharacterDetailPanel.switchGun = false
UICharacterDetailPanel.sortContent = nil
UICharacterDetailPanel.sortList = {}
UICharacterDetailPanel.curSort = nil
UICharacterDetailPanel.itemDataList = {}
UICharacterDetailPanel.dutyList = {}
UICharacterDetailPanel.curDuty = nil
UICharacterDetailPanel.reflectionPanel = nil
UICharacterDetailPanel.isModelLoading = false
UICharacterDetailPanel.mData = nil
UICharacterDetailPanel.sortListObj = nil
UICharacterDetailPanel.dutyListObj = nil
UICharacterDetailPanel.isFightBack = false
UICharacterDetailPanel.RedPointType = {
  RedPointConst.Barracks
}
local self = UICharacterDetailPanel
function UICharacterDetailPanel:ctor(csPanel)
  UICharacterDetailPanel.super:ctor(csPanel)
end
function UICharacterDetailPanel:CloseUICharacterDetailPanel()
  if self.curTab == FacilityBarrackGlobal.PowerUpType.Weapon then
    local curChildPanel = self.childPanelList[self.curTab]
    if curChildPanel.curContent == UIWeaponGlobal.ContentType.Replace then
      curChildPanel:CloseReplaceContent()
      return
    end
  end
  if self.switchGun then
    self:OnClickCloseList()
    self:EnableSwitchContent(true)
    self:EnableTabs(true)
    return
  end
  if self.mGunModelObj ~= nil then
    self.mGunModelObj:StopAudio()
  end
  UIManager.CloseUI(UIDef.UICharacterDetailPanel)
end
function UICharacterDetailPanel.ClearUIRecordData()
end
function UICharacterDetailPanel:OnBackFrom()
  self:ShowStart()
end
function UICharacterDetailPanel:OnRecover()
  FacilityBarrackGlobal.SetNeedBarrackEntrance(false)
  self:ShowStart()
end
function UICharacterDetailPanel:OnTop()
  UISystem.BarrackCharacterCameraCtrl:AttachChrTouchCtrlEvents()
end
function UICharacterDetailPanel:OnInit(root, data)
  self:SetRoot(root)
  FacilityBarrackGlobal.CharacterDetailPanel = self
  self.curTab = 0
  self.isFightBack = false
  if data and type(data) == "userdata" then
    self.jumpTab = data[0]
    self:SetGunCmdData(NetCmdTeamData:GetGun(1))
    SceneSys:SwitchVisible(EnumSceneType.Barrack)
  elseif type(data) == "table" then
    self.jumpTab = data.TabId
    self:SetGunCmdData(NetCmdTeamData:GetGunByID(data.GunId))
  elseif FacilityBarrackGlobal.ShowingGunId then
    self.isFightBack = true
    self:SetGunCmdData(NetCmdTeamData:GetGunByID(FacilityBarrackGlobal.ShowingGunId))
  else
    self:SetGunCmdData(NetCmdTeamData:GetGunByID(data))
  end
  self.isGunLock = self.mData == nil
  if self.mData == nil then
    self:SetGunCmdData(NetCmdTeamData:GetLockGunData(data))
  end
  FacilityBarrackGlobal.ShowingGunId = self.mData.Id
  self.tabList = {}
  self.childPanelList = {}
  self.ui = UIUtils.GetUIBindTable(root)
  setactive(self.ui.mTrans_Mask, true)
  UIManager.EnableFacilityBarrack(true)
  self.ui.mVirtualList.itemProvider = self.ItemProvider
  self.ui.mVirtualList.itemRenderer = self.ItemRenderer
  function self.OnLayoutDone(gos)
    self:OnLayoutDoneCallback(gos)
  end
  self.ui.mVirtualList:onLayoutDone("+", self.OnLayoutDone)
  self:InitGunList()
  self:InitDutyList()
  self:InitSortContent()
  if type(data) == "table" then
    UIUtils.GetButtonListener(self.ui.mBtn_BtnClose.gameObject).onClick = data.OnClickBack or function()
      self:CloseUICharacterDetailPanel()
    end
  else
    UIUtils.GetButtonListener(self.ui.mBtn_BtnClose.gameObject).onClick = function()
      self:CloseUICharacterDetailPanel()
    end
  end
  UISystem.BarrackCharacterCameraCtrl:LerpBaseToCharacterNear()
  setactive(UISystem.BarrackCharacterCameraCtrl.CharacterCamera, true)
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_BtnClose)
  UICharacterDetailPanel.super.SetPosZ(UICharacterDetailPanel)
  UIUtils.GetButtonListener(self.ui.mBtn_CommandCenter.gameObject).onClick = function()
    FacilityBarrackGlobal.ShowingGunId = nil
    if self.mGunModelObj ~= nil then
      self.mGunModelObj:StopAudio()
    end
    self:FadeOutCall(function()
      SceneSys:SwitchVisible(EnumSceneType.CommandCenter)
    end)
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GunList.gameObject).onClick = function()
    UICharacterDetailPanel:OnClickCharacterList()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_CurGun.gameObject).onClick = function()
    UICharacterDetailPanel:OnClickCharacterList()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_CloseCharacterList.gameObject).onClick = function()
    UICharacterDetailPanel:OnClickCloseList()
    UICharacterDetailPanel:EnableSwitchContent(true)
    UICharacterDetailPanel:EnableTabs(true)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UICharacterDetailPanel:OnClickCloseList()
    UICharacterDetailPanel:EnableSwitchContent(true)
    UICharacterDetailPanel:EnableTabs(true)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_PreGun.gameObject).onClick = function()
    UICharacterDetailPanel:OnClickChangeGun(-1)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_NextGun.gameObject).onClick = function()
    UICharacterDetailPanel:OnClickChangeGun(1)
  end
  MessageSys:AddListener(CS.GF2.Message.UIEvent.MergeEquipSucc, UICharacterDetailPanel.MergeEquipSucc)
  MessageSys:AddListener(CS.GF2.Message.UIEvent.OnChangeWeapon, UICharacterDetailPanel.OnWeaponChange)
  self.isOpenShow = true
  self:InitTabs()
  self:OnClickCloseList()
  self:DoInit()
  self:AddListener()
end
function UICharacterDetailPanel.OnJumpInit(data)
  if type(data) == "table" then
    self.curTab = 0
    self.jumpTab = data.TabId
    self:SetGunCmdData(NetCmdTeamData:GetGunByID(data.GunId))
    UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = data.OnClickBack or function()
      self:CloseUICharacterDetailPanel()
    end
  end
  self:DoInit()
end
function UICharacterDetailPanel:DoInit()
  self.jumpTab = self.jumpTab or FacilityBarrackGlobal.PowerUpType.LevelUp
  self:OnClickTab(self.jumpTab)
  self.jumpTab = nil
end
function UICharacterDetailPanel:OnShowStart()
  self:ShowStart()
end
function UICharacterDetailPanel:ShowStart()
  if not FacilityBarrackGlobal.needUpdate then
    FacilityBarrackGlobal.needUpdate = true
    return
  end
  local gunData = TableData.listGunDatas:GetDataById(self.mData.id)
  self:UpdateModel(gunData)
  function self.tempOnBaseChrVcamBlendFinishCallback()
    self:onBaseChrVcamBlendFinishCallback()
  end
  function self.tempOnWeaponChrVcamBlendFinishCallback()
    self:onWeaponChrVcamBlendFinishCallback()
  end
  UISystem.BarrackCharacterCameraCtrl:GetBinding(FacilityBarrackGlobal.CameraType.Base):FinishCallback("-", self.tempOnBaseChrVcamBlendFinishCallback)
  UISystem.BarrackCharacterCameraCtrl:GetBinding(FacilityBarrackGlobal.CameraType.Weapon):FinishCallback("-", self.tempOnWeaponChrVcamBlendFinishCallback)
  UISystem.BarrackCharacterCameraCtrl:GetBinding(FacilityBarrackGlobal.CameraType.Base):FinishCallback("+", self.tempOnBaseChrVcamBlendFinishCallback)
  UISystem.BarrackCharacterCameraCtrl:GetBinding(FacilityBarrackGlobal.CameraType.Weapon):FinishCallback("+", self.tempOnWeaponChrVcamBlendFinishCallback)
  local curChildPanel = self.childPanelList[self.curTab]
  if curChildPanel then
    if self.isOpenShow then
      if curChildPanel.OnShow then
        curChildPanel:OnShow()
      end
      self.isOpenShow = false
    elseif curChildPanel.OnPanelBack then
      curChildPanel:OnPanelBack()
    end
  end
  self:UpdateTabLock()
  self:OnClickElement(self.curDuty)
  self:UpdateTabList()
  self:UpdateCurGunInfo()
  self.gunDataTempList = self.gunList
  setactive(self.ui.mTrans_Mask, false)
  self.ui.mAni_Root:SetTrigger("TrainingListPanel_FadeIn")
end
function UICharacterDetailPanel:UpdatePanel()
  local gunData = TableData.listGunDatas:GetDataById(self.mData.id)
  self:UpdateModel(gunData)
  self:UpdateTabList()
  self:UpdateCurGunInfo()
  if self.isGunLock then
    if self.curTab == FacilityBarrackGlobal.PowerUpType.LevelUp then
      self:UpdateRightContent(self.curTab)
    else
      self:OnClickTab(FacilityBarrackGlobal.PowerUpType.LevelUp)
    end
  else
    self:UpdateRightContent(self.curTab)
  end
end
function UICharacterDetailPanel:OnHide()
  local curChildPanel = self.childPanelList[self.curTab]
  if curChildPanel and curChildPanel.OnHide then
    curChildPanel:OnHide()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:CloseUICharacterDetailPanel()
  end
  UISystem.BarrackCharacterCameraCtrl:GetBinding(FacilityBarrackGlobal.CameraType.Base):FinishCallback("-", self.tempOnBaseChrVcamBlendFinishCallback)
  UISystem.BarrackCharacterCameraCtrl:GetBinding(FacilityBarrackGlobal.CameraType.Weapon):FinishCallback("-", self.tempOnWeaponChrVcamBlendFinishCallback)
end
function UICharacterDetailPanel:OnUpdate()
  if UICharacterDetailPanel.curTab == 0 then
    return
  end
  local curChildPanel = self.childPanelList[self.curTab]
  if curChildPanel and curChildPanel.OnUpdate then
    curChildPanel:OnUpdate()
  end
end
function UICharacterDetailPanel:OnHideFinish()
end
function UICharacterDetailPanel:OnClose()
  FacilityBarrackGlobal.ShowingGunId = nil
  for _, childPanel in pairs(self.childPanelList) do
    if childPanel then
      childPanel:OnRelease()
    end
  end
  for _, tabItem in pairs(self.tabList) do
    if tabItem then
      tabItem:OnRelease()
    end
  end
  UICharacterDetailPanel.tabList = {}
  UICharacterDetailPanel.childPanelList = {}
  UICharacterDetailPanel.gunModel = nil
  UICharacterDetailPanel.curTab = 0
  UICharacterDetailPanel.curGunIndex = 1
  UICharacterDetailPanel.gunList = {}
  UICharacterDetailPanel.gunDataList = {}
  UICharacterDetailPanel.gunItemList = {}
  UICharacterDetailPanel.currentGun = nil
  UICharacterDetailPanel.switchGun = false
  UICharacterDetailPanel.sortContent = nil
  UICharacterDetailPanel.sortList = {}
  UICharacterDetailPanel.curSort = nil
  UICharacterDetailPanel.dutyList = {}
  UICharacterDetailPanel.curDuty = nil
  UICharacterDetailPanel.isModelLoading = false
  UICharacterDetailPanel.reflectionPanel = nil
  FacilityBarrackGlobal.needUpdate = true
  UIManager.EnableFacilityBarrack(false)
  UIUtils.ReleaseBarrackUIModel()
  UICharacterDetailPanel.mGunModelObj = nil
  FacilityBarrackGlobal.UIModel = nil
  UIModelToucher.ReleaseWeaponToucher()
  UIModelToucher.ReleaseCharacterToucher()
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.OnChangeWeapon, UICharacterDetailPanel.OnWeaponChange)
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.MergeEquipSucc, UICharacterDetailPanel.MergeEquipSucc)
  self.ui.mVirtualList.itemProvider = nil
  self.ui.mVirtualList.itemRenderer = nil
  self.ui.mVirtualList:onLayoutDone("-", self.OnLayoutDone)
  UISystem.BarrackCharacterCameraCtrl:GetBinding(FacilityBarrackGlobal.CameraType.Base):FinishCallback("-", self.tempOnBaseChrVcamBlendFinishCallback)
  UISystem.BarrackCharacterCameraCtrl:GetBinding(FacilityBarrackGlobal.CameraType.Weapon):FinishCallback("-", self.tempOnWeaponChrVcamBlendFinishCallback)
  self:RemoveListener()
end
function UICharacterDetailPanel:InitTabs()
  for i = 0, TableData.listBarrackDatas.Count - 1 do
    local data = TableData.listBarrackDatas[i]
    if data.Type == 1 then
      local item = UIBarrackCommonTabItem.New()
      item.tagId = data.id
      item.tagName = FacilityBarrackGlobal.PowerUpName[i + 1]
      item.systemId = data.unlock
      local template = self.ui.mScrollItem_Tab.childItem
      item:InitObj(instantiate(template, self.ui.mScrollItem_Tab.transform))
      item:SetName(data.name.str)
      UIUtils.GetButtonListener(item.mBtn_ClickTab.gameObject).onClick = function()
        self:OnClickTab(item.tagId)
      end
      self.tabList[item.tagId] = item
    end
  end
  self:UpdateTabLock()
end
function UICharacterDetailPanel:SetTabsVisible(visible)
  setactive(self.ui.mTrans_Tabs, visible)
end
function UICharacterDetailPanel:OnClickTab(id)
  if id then
    if TipsManager.NeedLockTips(self.tabList[id].systemId) or self.curTab == id then
      return
    end
    if id == FacilityBarrackGlobal.PowerUpType.GunTalent then
      self:UpdateTabList()
    end
    if id ~= FacilityBarrackGlobal.PowerUpType.LevelUp and self.mGunModelObj ~= nil then
      self.mGunModelObj:StopAudio()
    end
    if self.curTab > 0 and id == FacilityBarrackGlobal.PowerUpType.LevelUp and self.mGunModelObj ~= nil then
      self.mGunModelObj:SetAnim("BarrackIdle")
      self.mGunModelObj:StopEffect()
    end
    if self.curTab > 0 then
      local lastTab = self.tabList[self.curTab]
      lastTab:SetItemState(false)
      self:CloseCurChildPanel()
    end
    local curTab = self.tabList[id]
    curTab:SetItemState(true)
    self.curTab = id
    self:UpdateRightContent(self.curTab)
    setactive(self.ui.mTrans_GunList, self.curTab == FacilityBarrackGlobal.PowerUpType.LevelUp)
    setactive(self.ui.mTrans_CurGun, self.curTab ~= FacilityBarrackGlobal.PowerUpType.LevelUp)
  end
end
function UICharacterDetailPanel:UpdateRightContent(type)
  local childPanel = self.childPanelList[type]
  if childPanel == nil then
    if type == FacilityBarrackGlobal.PowerUpType.LevelUp then
      childPanel = UIGunInfoContent.New()
      childPanel:InitCtrl(self.ui.mTrans_LevelUp)
      self.childPanelList[type] = childPanel
    elseif type == FacilityBarrackGlobal.PowerUpType.Upgrade then
      childPanel = UIUpgradeContent.New()
      childPanel:InitCtrl(self.ui.mTrans_Upgrade)
      self.childPanelList[type] = childPanel
    elseif type == FacilityBarrackGlobal.PowerUpType.Weapon then
      childPanel = UIWeaponContent.New()
      childPanel:InitCtrl(self.ui.mTrans_Weapon)
      self.childPanelList[type] = childPanel
    elseif type == FacilityBarrackGlobal.PowerUpType.GunTalent then
      local template = self.ui.mTrans_GunTalent:GetComponent(typeof(CS.ScrollListChild)).childItem
      local go = instantiate(template, self.ui.mTrans_GunTalent)
      childPanel = UIGunTalentPanel.New()
      childPanel:InitCtrl(go, self.mData, UICharacterDetailPanel)
      self.childPanelList[type] = childPanel
    end
  end
  if childPanel then
    childPanel:SetData(self.mData, self)
  end
end
function UICharacterDetailPanel:onBaseChrVcamBlendFinishCallback()
  local childPanel = self.childPanelList[self.curTab]
  if childPanel then
    childPanel:OnEnable(true)
  end
end
function UICharacterDetailPanel:onWeaponChrVcamBlendFinishCallback()
  local childPanel = self.childPanelList[self.curTab]
  if childPanel then
    childPanel:OnEnable(true)
  end
end
function UICharacterDetailPanel:EnableCharacterModel(enable)
  if (self.gunModel or {}).gameObject and enable then
    local data = TableData.listModelConfigDatas:GetDataById(self.mData.model_id)
    local vec = UIUtils.SplitStrToVector(data.character_type)
    self.gunModel.gameObject.transform.position = vec
    if self.reflectionPanel == nil then
      local canvas = UISystem.CharacterCanvas
      self.reflectionPanel = UIUtils.GetTransform(canvas, "ReflectionPlane")
    end
    self.reflectionPanel.transform.position = vec
  end
end
function UICharacterDetailPanel:CloseCurChildPanel()
  if self.curTab then
    local childPanel = self.childPanelList[self.curTab]
    if childPanel then
      childPanel:OnEnable(false)
    end
  end
end
function UICharacterDetailPanel:GetGunPropByType(type)
  if not type then
    return 0
  end
  return self.mData:GetGunPropertyValueByType(type)
end
function UICharacterDetailPanel:CloseChildPanel()
  self:CloseCurChildPanel()
  self.curTab = 0
end
function UICharacterDetailPanel:UpdateGunModel(model_id, weapon_id, weaponData)
  UIUtils.GetBarrackUIModelAsyn(model_id, weapon_id, weaponData, function(go)
    self:UpdateModelCallback(go)
  end)
  UIManager.SetCharacterCameraScaleModelId(model_id)
end
function UICharacterDetailPanel:UpdateModelCallback(obj)
  self:SetLookAtCharacter(obj.gameObject)
  local modelId = self.mData ~= nil and self.mData.model_id or TableData.GetRoleTemplateData(tableData.role_template_id).model_code
  if obj.tableId ~= modelId then
    return
  end
  self.mGunModelObj = obj
  if self.mGunModelObj ~= nil and self.mGunModelObj.gameObject ~= nil then
    self.mGunModelObj:Show(false)
    self.mGunModelObj.transform.localEulerAngles = Vector3(0, 180, 0)
    GFUtils.MoveToLayer(self.mGunModelObj.transform, CS.UnityEngine.LayerMask.NameToLayer("Friend"))
    UIModelToucher.AttachCharacterTransToTouch(self.mGunModelObj.gameObject)
    FacilityBarrackGlobal.UIModel = self.mGunModelObj
  else
    FacilityBarrackGlobal.UIModel = nil
  end
  self.gunModel = FacilityBarrackGlobal.UIModel
  if self.gunModel ~= nil then
    local camera = UISystem.CharacterCamera
    local characterCameraScaleCtrl = CS.CharacterCameraScaleController.Get(camera.gameObject)
    characterCameraScaleCtrl:SetModel(self.gunModel.gameObject)
  end
  self:EnableCharacterModel(self.childPanelList[self.curTab].needModel)
  if self.mGunModelObj ~= nil and self.mGunModelObj.gameObject ~= nil then
    self.mGunModelObj:Show(true)
    if self.curTab == FacilityBarrackGlobal.PowerUpType.LevelUp and FacilityBarrackGlobal.GetNeedBarrackEntrance() and not self.isFightBack then
      self.mGunModelObj:PlayAudio()
      FacilityBarrackGlobal:ChangeChrAnim(FacilityBarrackGlobal.ChrAnimTriggerType.Entrance)
    end
  end
  self.isModelLoading = false
end
function UICharacterDetailPanel.OnWeaponChange()
  self:UpdateModel(self.mData.TabGunData)
  self.isModelLoading = false
end
function UICharacterDetailPanel:SetLookAtCharacter(obj)
  local characterSelfShadowSettings = SceneSys.currentScene.CharacterSelfShadowSettings
  if characterSelfShadowSettings then
    characterSelfShadowSettings:SetLookAtCharacter(obj)
  end
end
function UICharacterDetailPanel:UpdateModel(tableData)
  local modelId = self.mData ~= nil and self.mData.model_id or TableData.GetRoleTemplateData(tableData.role_template_id).model_code
  local weaponModelId = self.mData ~= nil and (self.mData.WeaponData ~= nil and self.mData.WeaponData.stc_id or tableData.weapon_default) or tableData.weapon_default
  local weaponData
  if self.mData ~= nil then
    weaponData = NetCmdWeaponData:GetWeaponById(self.mData.WeaponId)
  end
  self.isModelLoading = true
  self:UpdateGunModel(modelId, weaponModelId, weaponData)
end
function UICharacterDetailPanel:UpdateTabLock()
  for _, tab in pairs(self.tabList) do
    tab:UpdateSystemLock()
  end
end
function UICharacterDetailPanel:OnClickCharacterList()
  for _, gun in ipairs(self.gunItemList) do
    if gun and gun.tableData then
      gun:SetData(gun.tableData.id)
      gun:SetSelect(self.mData.id == gun.tableData.id)
      if self.mData.id == gun.tableData.id then
        self.currentGun = gun
      end
    end
  end
  if self.curTab == FacilityBarrackGlobal.PowerUpType.LevelUp then
    self.childPanelList[self.curTab]:EnableLevelInfo(false)
  end
  self.switchGun = true
  self:ShowOrHideCharacterList(true)
  self:EnableSwitchContent(false)
  self:EnableTabs(false)
end
function UICharacterDetailPanel:OnLayoutDoneCallback(gameObjectArr)
  for _, gun in ipairs(self.gunItemList) do
    if gun and gun.tableData then
      gun:SetData(gun.tableData.id)
      gun:SetSelect(self.mData.id == gun.tableData.id)
      if self.mData.id == gun.tableData.id then
        self.currentGun = gun
      end
    end
  end
end
function UICharacterDetailPanel:OnGunClick(gun)
  if gun then
    if self.currentGun then
      if self.currentGun.tableData.id == gun.tableData.id then
        return
      end
      self.currentGun:SetSelect(false)
    end
    gun:SetSelect(true)
    self.currentGun = gun
    self.curGunIndex = gun.index
    self.gunDataTempList = self.gunList
    FacilityBarrackGlobal.ShowingGunId = gun.tableData.id
    self:SetGunCmdData(NetCmdTeamData:GetGunByID(gun.tableData.id))
    self.isGunLock = self.mData == nil
    if self.mData == nil then
      self:SetGunCmdData(NetCmdTeamData:GetLockGunData(gun.tableData.id))
    end
    self:UpdatePanel()
  end
end
function UICharacterDetailPanel:OnClickCloseList()
  self.switchGun = false
  self:CloseDuty()
  self:CloseItemSort()
  if self.curTab == FacilityBarrackGlobal.PowerUpType.LevelUp then
    self.childPanelList[self.curTab]:EnableLevelInfo(true)
  end
  self:ShowOrHideCharacterList(false)
end
function UICharacterDetailPanel:OnClickChangeGun(step)
  local index = self.curGunIndex + step
  if index <= 0 then
    index = #self.gunDataTempList
  elseif index > #self.gunDataTempList then
    index = 1
  end
  self.curGunIndex = index
  local gun = self.gunDataTempList[self.curGunIndex]
  self:SetGunCmdData(NetCmdTeamData:GetGunByID(gun.id))
  self.isGunLock = self.mData == nil
  if self.mData == nil then
    self:SetGunCmdData(NetCmdTeamData:GetLockGunData(gun.id))
  end
  FacilityBarrackGlobal.ShowingGunId = gun.id
  self.childPanelList[self.curTab]:PlaySwitchAni(step)
  self.childPanelList[self.curTab]:PlaySwitchInAni()
  self:UpdatePanel()
  if self.curTab == FacilityBarrackGlobal.PowerUpType.GunTalent then
    self:UpdateTabList()
  end
end
function UICharacterDetailPanel:OnClickElementList()
  setactive(self.dutyListObj, true)
  setactive(self.sortListObj, false)
  setactive(self.ui.mTrans_DutyContent, true)
end
function UICharacterDetailPanel:CloseDuty()
  setactive(self.dutyListObj, false)
  self:CheckListClose()
end
function UICharacterDetailPanel:OnClickElement(item)
  if item then
    if self.curDuty and self.curDuty.type ~= item.type then
      self.curDuty.txtName.color = self.textcolor.BeforeSelected
      self.curDuty.imgIcon.color = self.textcolor.ImgBeforeSelected
      setactive(self.curDuty.grpset, false)
    end
    self.curDuty = item
    self.curDuty.txtName.color = self.textcolor.AfterSelected
    self.curDuty.imgIcon.color = self.textcolor.ImgAfterSelected
    setactive(self.curDuty.grpset, true)
    self:OnClickSort(self.curSort.sortType)
    self:CloseDuty()
    self.ui.mImage_DutyIcon.sprite = IconUtils.GetGunTypeIcon(self.curDuty.data.icon .. "_W")
  end
end
function UICharacterDetailPanel:OnClickSortList()
  setactive(self.sortListObj, true)
  setactive(self.dutyListObj, false)
  setactive(self.ui.mTrans_SortList, true)
end
function UICharacterDetailPanel:CloseItemSort()
  setactive(self.sortListObj, false)
  self:CheckListClose()
end
function UICharacterDetailPanel:CheckListClose()
  local isSortListAllClose = self.sortListObj.activeSelf == false and self.dutyListObj.activeSelf == false
  setactive(self.ui.mTrans_SortList, not isSortListAllClose)
end
function UICharacterDetailPanel:CloseAllList()
  setactive(self.sortListObj, false)
  setactive(self.dutyListObj, false)
  setactive(self.ui.mTrans_SortList, false)
end
function UICharacterDetailPanel:OnClickSort(type)
  if type then
    if self.curSort and self.curSort.sortType ~= type then
      self.curSort.txtName.color = self.textcolor.BeforeSelected
      setactive(self.curSort.grpset, false)
    end
    self.curSort = self.sortList[type]
    self.curSort.txtName.color = self.textcolor.AfterSelected
    setactive(self.curSort.grpset, true)
    self.sortContent:SetData(self.curSort)
    FacilityBarrackGlobal:SetSortType(self.curSort)
    self:UpdateGunList()
    self:CloseItemSort()
  end
end
function UICharacterDetailPanel:OnClickAscend()
  if self.curSort then
    self.curSort.isAscend = not self.curSort.isAscend
    FacilityBarrackGlobal:SetSortType(self.curSort)
    self:UpdateGunList()
  end
end
function UICharacterDetailPanel.ItemProvider()
  self = UICharacterDetailPanel
  local itemView = UIBarrackChrCardItem.New()
  itemView:InitCtrl(self.ui.mTrans_CharacterList.transform)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  table.insert(self.gunItemList, itemView)
  return renderDataItem
end
function UICharacterDetailPanel.ItemRenderer(index, renderData)
  self = UICharacterDetailPanel
  local data = self.itemDataList[index + 1]
  local item = renderData.data
  item:SetData(data.id)
  item.index = index + 1
  UIUtils.GetButtonListener(item.mBtn_Gun.gameObject).onClick = function()
    self:OnGunClick(item)
  end
end
function UICharacterDetailPanel:UpdateGunList()
  self.gunList = self:GetGunListByDuty(self.curDuty.type)
  if self.gunDataTempList == nil then
    self.gunDataTempList = self.gunList
  end
  local sortFunc = FacilityBarrackGlobal:GetSortFunc(1, self.curSort.sortCfg, self.curSort.isAscend)
  table.sort(self.gunList, sortFunc)
  for _, gun in ipairs(self.gunItemList) do
    gun:SetData(nil)
    gun:SetSelect(false)
  end
  self.itemDataList = {}
  if self.gunList then
    for i = 1, #self.gunList do
      local item
      local data = self.gunList[i]
      table.insert(self.itemDataList, data)
    end
  end
  self.ui.mVirtualList.numItems = #self.itemDataList
  self.ui.mVirtualList:Refresh()
  local currentGun, curGunIndex = self:GetGunItemById(self.mData.id)
  if currentGun then
    self.currentGun = currentGun
    self.curGunIndex = curGunIndex
    self.currentGun:SetSelect(true)
    self.gunDataTempList = self.gunList
  else
    currentGun, curGunIndex = self:GetTempGunItemById(self.mData.id)
    if currentGun then
      self.currentGun = nil
      self.curGunIndex = curGunIndex
    end
  end
end
function UICharacterDetailPanel:GetGunListByDuty(duty)
  if duty then
    local tempGunList = {}
    if duty == 0 then
      for _, gunList in pairs(self.gunDataList) do
        if gunList then
          for _, gunId in ipairs(gunList) do
            local data = NetCmdTeamData:GetGunByID(gunId)
            if data == nil then
              data = FacilityBarrackGlobal:GetLockGunData(gunId)
            end
            table.insert(tempGunList, data)
          end
        end
      end
    else
      local gunIdList = self.gunDataList[duty]
      if gunIdList then
        for _, gunId in ipairs(gunIdList) do
          local data = NetCmdTeamData:GetGunByID(gunId)
          if data == nil then
            data = FacilityBarrackGlobal:GetLockGunData(gunId)
          end
          table.insert(tempGunList, data)
        end
      end
    end
    return tempGunList
  end
  return nil
end
function UICharacterDetailPanel.MergeEquipSucc()
end
function UICharacterDetailPanel:UpdateTabList()
  for i, tab in pairs(self.tabList) do
    local redPoint = 0
    local isUnlock = not self.isGunLock
    if tab.tagId == FacilityBarrackGlobal.PowerUpType.LevelUp then
      if isUnlock then
        redPoint = NetCmdTeamData:UpdateBreakRedPoint(self.mData) + NetCmdTeamData:UpdateUpgradeRedPoint(self.mData)
      else
        redPoint = NetCmdTeamData:UpdateLockRedPoint(self.mData.TabGunData)
      end
    elseif tab.tagId == FacilityBarrackGlobal.PowerUpType.Upgrade then
      if isUnlock then
        redPoint = NetCmdTeamData:UpdateUpgradeRedPoint(self.mData)
      end
    elseif tab.tagId == FacilityBarrackGlobal.PowerUpType.Weapon then
      if isUnlock then
        redPoint = NetCmdWeaponData:UpdateWeaponCanChangeRedPoint(self.mData.WeaponId, self.mData.GunId)
        if AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.GundetailWeaponpart) then
          redPoint = redPoint + NetCmdTeamData:UpdateWeaponModRedPoint(self.mData)
        end
      end
    elseif tab.tagId == FacilityBarrackGlobal.PowerUpType.GunTalent then
      isUnlock = isUnlock and AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.SquadTalent)
      if isUnlock then
      end
    end
    tab:SetEnable(isUnlock)
    tab:SetRedPointEnable(0 < redPoint)
  end
end
function UICharacterDetailPanel:RefreshGun()
  self:SetGunCmdData(NetCmdTeamData:GetGunByID(self.mData.id))
  self.isGunLock = self.mData == nil
  if self.mData == nil then
    self:SetGunCmdData(NetCmdTeamData:GetLockGunData(self.mData.id))
  end
  self:UpdatePanel()
  self:UpdateRedPoint()
end
function UICharacterDetailPanel:UpdateSwichContent()
  setactive(self.modelViewer.gameObject, self.curTab == FacilityBarrackGlobal.PowerUpType.LevelUp)
end
function UICharacterDetailPanel:EnableTabs(enable)
  setactive(self.ui.mTrans_Tabs, enable and not self.switchGun)
end
function UICharacterDetailPanel:SetCharacterPanelVisible(visible)
  self:ShowOrHideCharacterList(visible and self.switchGun)
end
function UICharacterDetailPanel:EnableSwitchContent(enable)
  setactive(self.ui.mTrans_SwitchContent, enable and not self.switchGun)
  setactive(self.ui.mTrans_Switch, enable)
  setactive(self.ui.mTrans_GunList, enable and self.curTab == FacilityBarrackGlobal.PowerUpType.LevelUp)
  setactive(self.ui.mTrans_CurGun, enable and self.curTab ~= FacilityBarrackGlobal.PowerUpType.LevelUp)
end
function UICharacterDetailPanel:InitGunList()
  self.gunDataList = {}
  for i = 0, TableData.listGunDatas.Count - 1 do
    local gunData = TableData.listGunDatas[i]
    if self.gunDataList[gunData.duty] == nil then
      self.gunDataList[gunData.duty] = {}
    end
    table.insert(self.gunDataList[gunData.duty], gunData.id)
  end
end
function UICharacterDetailPanel:InitDutyList()
  self.dutyList = {}
  local dutyDataList = {}
  local data = {}
  data.id = 0
  data.icon = "Icon_Professional_ALL"
  table.insert(dutyDataList, data)
  local list = TableData.listGunDutyDatas:GetList()
  for i = 0, list.Count - 1 do
    local data = list[i]
    table.insert(dutyDataList, data)
  end
  local sortList = self:InitScrollListChild(self.ui.mTrans_DutyContent)
  self.dutyListObj = sortList
  local parent = UIUtils.GetRectTransform(sortList, "Content")
  for i = 1, #dutyDataList do
    local data = dutyDataList[i]
    local obj = self:InitScrollListChild(parent)
    if obj then
      local duty = {}
      duty.obj = obj
      duty.data = data
      duty.btnSort = UIUtils.GetButton(obj)
      duty.txtName = UIUtils.GetText(obj, "GrpText/Text_SuitName")
      duty.transIcon = UIUtils.GetRectTransform(obj, "Trans_GrpElement")
      duty.imgIcon = UIUtils.GetImage(obj, "Trans_GrpElement/ImgIcon")
      duty.type = data.id
      duty.grpset = obj.transform:Find("GrpSel")
      self.textcolor = obj.transform:GetComponent("TextImgColor")
      self.beforecolor = self.textcolor.BeforeSelected
      self.aftercolor = self.textcolor.AfterSelected
      self.imgbeforecolor = self.textcolor.ImgBeforeSelected
      self.imgaftercolor = self.textcolor.ImgAfterSelected
      duty.imgIcon.sprite = IconUtils.GetGunTypeIcon(data.icon .. "_W")
      duty.txtName.text = data.id == 0 and TableData.GetHintById(101006) or data.name.str
      setactive(duty.transIcon, true)
      UIUtils.GetButtonListener(duty.btnSort.gameObject).onClick = function()
        self:OnClickElement(duty)
      end
      table.insert(self.dutyList, duty)
    end
  end
  UIUtils.GetUIBlockHelper(self.mUIRoot, self.ui.mTrans_DutyContent, function()
    self:CloseAllList()
  end)
  self.curDuty = self.dutyList[1]
  for i = 1, #self.dutyList do
    if self.dutyList[i] ~= self.curDuty then
      self.dutyList[i].txtName.color = self.textcolor.BeforeSelected
      setactive(self.dutyList[i].grpset, false)
    else
      self.dutyList[i].txtName.color = self.textcolor.AfterSelected
      setactive(self.dutyList[i].grpset, true)
    end
  end
end
function UICharacterDetailPanel:InitSortContent()
  if self.sortContent == nil then
    self.sortContent = UIGunSortItem.New()
    self.sortContent:InitCtrl(self.ui.mTrans_SortContent, true)
    UIUtils.GetButtonListener(self.sortContent.mBtn_Sort.gameObject).onClick = function()
      self:OnClickSortList()
    end
    UIUtils.GetButtonListener(self.sortContent.mBtn_Ascend.gameObject).onClick = function()
      self:OnClickAscend()
    end
    UIUtils.GetButtonListener(self.sortContent.mBtn_TypeScreen.gameObject).onClick = function()
      self:OnClickElementList()
    end
  end
  local sortList = self:InitScrollListChild(self.ui.mTrans_SortList)
  self.sortListObj = sortList
  local parent = UIUtils.GetRectTransform(sortList, "Content")
  for i = 1, 4 do
    local obj = self:InitScrollListChild(parent)
    if obj then
      local sort = {}
      sort.obj = obj
      sort.btnSort = UIUtils.GetButton(obj)
      sort.txtName = UIUtils.GetText(obj, "GrpText/Text_SuitName")
      sort.sortType = i
      sort.hintID = FacilityBarrackGlobal.SortHint[i]
      sort.sortCfg = FacilityBarrackGlobal.GunSortCfg[i]
      sort.isAscend = false
      sort.grpset = obj.transform:Find("GrpSel")
      sort.txtName.text = TableData.GetHintById(sort.hintID)
      UIUtils.GetButtonListener(sort.btnSort.gameObject).onClick = function()
        self:OnClickSort(sort.sortType)
      end
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
  self.curSort = self.sortList[FacilityBarrackGlobal.SortType.sortType]
  self.curSort.isAscend = FacilityBarrackGlobal.SortType.isAscend
end
function UICharacterDetailPanel:GetGunItemById(id)
  for i, gun in ipairs(self.gunItemList) do
    if gun and gun.tableData and id == gun.tableData.id then
      return gun, i
    end
  end
  return nil, nil
end
function UICharacterDetailPanel:GetTempGunItemById(id)
  for i, gun in ipairs(self.gunDataTempList) do
    if gun and id == gun.id then
      return gun, i
    end
  end
  return nil, nil
end
function UICharacterDetailPanel:UpdateCurGunInfo()
  local gunData = self.mData.TabGunData
  self.ui.mImage_GunHead.sprite = IconUtils.GetCharacterHeadSprite(gunData.code)
  self.ui.mText_GunName.text = gunData.name.str
end
function UICharacterDetailPanel:ShowOrHideCharacterList(enabled)
  if enabled then
    setactive(self.ui.mTrans_Character, true)
  else
    local animator = self.ui.mTrans_Character.transform:GetComponent("Animator")
    animator:SetTrigger("FadeOut")
    TimerSys:DelayCall(0.2, function()
      if self.ui.mTrans_Character then
        setactive(self.ui.mTrans_Character, false)
      end
    end)
  end
end
function UICharacterDetailPanel:SwitchCameraPos(barrackCameraStandType)
  FacilityBarrackGlobal:SwitchCameraPos(barrackCameraStandType)
end
function UICharacterDetailPanel:FadeOut()
  self.ui.mAni_Root:SetTrigger("ComPage_FadeOut")
  self.ui.mAni_Root:SetTrigger("TrainingListPanel_FadeOut")
  local length1 = CSUIUtils.GetClipLengthByEndsWith(self.ui.mAni_Root, "ComPage_FadeOut")
  local length2 = CSUIUtils.GetClipLengthByEndsWith(self.ui.mAni_Root, "Ani_Barrack_FadeOut")
  local maxLength = math.max(length1, length2)
  TimerSys:UnscaledDelayCall(maxLength, function(tempSelf)
    setactive(tempSelf.mUIRoot, false)
  end, self)
end
function UICharacterDetailPanel.Back2LastContent()
  local curChildPanel = self.childPanelList[self.curTab]
  if curChildPanel then
    curChildPanel:Back2LastContent()
  end
end
function UICharacterDetailPanel:InitScrollListChild(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(itemPrefab.childItem)
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
  end
  return obj
end
function UICharacterDetailPanel:GunModelStopAudioAndEffect()
  self.mGunModelObj:StopAudio()
  self.mGunModelObj:StopEffect()
end
function UICharacterDetailPanel:SetGunCmdData(gunCmdData)
  FacilityBarrackGlobal.SetNeedBarrackEntrance(self.mData == nil or gunCmdData == nil or self.mData.Id ~= gunCmdData.Id)
  self.mData = gunCmdData
end
function UICharacterDetailPanel:AddListener()
  MessageSys:AddListener(CS.GF2.Message.FacilityBarrackEvent.RefreshGun, self.RefreshGunEvent)
  MessageSys:AddListener(CS.GF2.Message.FacilityBarrackEvent.Back2LastContent, self.Back2LastContent)
end
function UICharacterDetailPanel:RemoveListener()
  MessageSys:RemoveListener(CS.GF2.Message.FacilityBarrackEvent.RefreshGun, self.RefreshGunEvent)
  MessageSys:RemoveListener(CS.GF2.Message.FacilityBarrackEvent.Back2LastContent, self.Back2LastContent)
end
function UICharacterDetailPanel.RefreshGunEvent()
  self:RefreshGun()
end
