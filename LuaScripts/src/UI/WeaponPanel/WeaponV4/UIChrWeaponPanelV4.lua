require("UI.WeaponPanel.WeaponV4.Item.ChrWeaponTopBarItemV4")
require("UI.WeaponPanel.WeaponV4.UIWeaponPartPanelV2")
require("UI.WeaponPanel.WeaponV4.UIWeaponOverviewPanelV4")
require("UI.WeaponPanel.WeaponV4.WeaponPowerUpV4.UIWeaponPolarityPanelV4")
require("UI.WeaponPanel.UIWeaponPanel")
require("UI.FacilityBarrackPanel.FacilityBarrackGlobal")
require("UI.WeaponPanel.UIWeaponGlobal")
require("UI.Common.UICommonLockItem")
UIChrWeaponPanelV4 = class("UIChrWeaponPanelV4", UIBasePanel)
UIChrWeaponPanelV4.__index = UIChrWeaponPanelV4
function UIChrWeaponPanelV4:ctor(csPanel)
  UIChrWeaponPanelV4.super:ctor(csPanel)
  csPanel.Is3DPanel = true
end
function UIChrWeaponPanelV4:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.gunCmdData = nil
  self.weaponCmdData = nil
  self.suitList = {}
  self.weaponPartUis = {}
  self.replaceBtnRedPoint = nil
  self.needReplaceBtn = false
  self.isLockGun = false
  self.tabItemList = {}
  self.isCompose = false
  self.bgImg = nil
  self.lockItem = nil
  self.isShowReplaceList = false
  self.tabHint = {
    [1] = 220055,
    [2] = 220056
  }
  self.contentList = {}
  self.curContentType = 0
  self:InitTab()
  self:InitContent()
end
function UIChrWeaponPanelV4:OnInit(root, data)
  local weaponId = data[1]
  self.needReplaceBtn = data.needReplaceBtn
  if self.needReplaceBtn == nil then
    self.needReplaceBtn = false
  end
  self.isCompose = false
  setactive(self.ui.mScrollListChild_TopRightBtn, true)
  self.openFromType = data[4]
  if self.openFromType == UIWeaponPanel.OpenFromType.BattlePass or self.openFromType == UIWeaponPanel.OpenFromType.BattlePassCollection then
    self.weaponCmdData = NetCmdWeaponData:GetWeaponByStcId(weaponId)
    setactive(self.ui.mScrollListChild_TopRightBtn, false)
  elseif self.openFromType == UIWeaponPanel.OpenFromType.GachaPreview then
    self.weaponCmdData = NetCmdWeaponData:GetMaxlvWeaponByStcId(weaponId)
    setactive(self.ui.mScrollListChild_TopRightBtn, false)
  elseif self.openFromType == UIWeaponPanel.OpenFromType.RepositoryWeaponCompose then
    self.weaponCmdData = NetCmdWeaponData:GetWeaponByStcId(weaponId)
    self.isCompose = true
  else
    self.weaponCmdData = NetCmdWeaponData:GetWeaponById(weaponId)
  end
  if self.weaponCmdData.gun_id ~= 0 then
    self.gunCmdData = NetCmdTeamData:GetGunByStcId(self.weaponCmdData.gun_id)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    if self.curContentType == UIWeaponGlobal.WeaponContentTypeV4.WeaponPart then
      self:ChangeContent(UIWeaponGlobal.WeaponContentTypeV4.Weapon)
    else
      UIWeaponGlobal.SetNeedCloseBarrack3DCanvas(true)
      UIManager.CloseUI(UIDef.UIWeaponPanel)
    end
  end
  self:SetEscapeEnabled(true)
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIWeaponGlobal.SetNeedCloseBarrack3DCanvas(true)
    UIManager.JumpToMainPanel()
  end
  setactive(self.ui.mBtn_Description.transform.parent, true)
  UIUtils.GetButtonListener(self.ui.mBtn_PreGun.gameObject).onClick = function()
    self:SwitchGun(false)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_NextGun.gameObject).onClick = function()
    self:SwitchGun(true)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ChrChange.gameObject).onClick = function()
    self:InteractChrChangeBtn(false)
    local closeCallback = function()
      self:InteractChrChangeBtn(true)
    end
    local param = {
      [1] = self.gunCmdData.Id,
      [2] = closeCallback
    }
    UIManager.OpenUIByParam(UIDef.UIChrWeaponChangeEquipedChrDialog, param)
  end
  self:AddListener()
  self:InitLockItem()
  self.bgImg = BarrackHelper.CameraMgr.Barrack3DCanvas.transform:Find("Panel"):GetComponent(typeof(CS.UnityEngine.UI.Image))
  for i, v in ipairs(self.contentList) do
    v:OnInit(self.weaponCmdData)
  end
end
function UIChrWeaponPanelV4:OnShowStart()
  SceneSys:SwitchVisible(EnumSceneType.Barrack)
  CS.UIBarrackModelManager.Instance:ShowBarrackObjWithLayer(false)
  BarrackHelper.CameraMgr:ChangeCameraStand(BarrackCameraStand.Weapon, false)
  self:ChangeContent(UIWeaponGlobal.WeaponContentTypeV4.Weapon)
  self:SetWeaponData()
end
function UIChrWeaponPanelV4:OnSave()
  self.saveContentType = self.curContentType
end
function UIChrWeaponPanelV4:OnRecover()
  SceneSys:SwitchVisible(EnumSceneType.Barrack)
  CS.UIBarrackModelManager.Instance:ShowBarrackObjWithLayer(false)
  BarrackHelper.CameraMgr:ChangeCameraStand(BarrackCameraStand.Weapon, false)
  self:SetWeaponData()
  for i, v in ipairs(self.contentList) do
    v:OnRecover(self.weaponCmdData)
  end
  if self.saveContentType == nil then
    self.saveContentType = UIWeaponGlobal.WeaponContentTypeV4.Weapon
  end
  self:ChangeContent(self.saveContentType)
  self.saveContentType = nil
end
function UIChrWeaponPanelV4:OnBackFrom()
  self:SetWeaponData()
  CS.UIBarrackModelManager.Instance:ShowBarrackObjWithLayer(false)
  if self.curContentType ~= 0 and self.contentList ~= nil and self.contentList[self.curContentType] ~= nil then
    self.contentList[self.curContentType]:OnBackFrom()
  end
end
function UIChrWeaponPanelV4:OnTop()
  self:SetWeaponData()
  if self.curContentType ~= 0 and self.contentList[self.curContentType] ~= nil then
    self.contentList[self.curContentType]:OnTop()
  end
end
function UIChrWeaponPanelV4:OnShowFinish()
  self:UpdateTabLock()
end
function UIChrWeaponPanelV4:OnCameraStart()
  return 0.01
end
function UIChrWeaponPanelV4:OnCameraBack()
end
function UIChrWeaponPanelV4:OnRefresh()
  for i, v in ipairs(self.contentList) do
    if v.OnRefresh ~= nil then
      v:OnRefresh()
    end
  end
end
function UIChrWeaponPanelV4:OnHide()
end
function UIChrWeaponPanelV4:OnHideFinish()
  if UIWeaponGlobal.GetNeedCloseBarrack3DCanvas() then
    UIWeaponGlobal:ReleaseWeaponModel()
    CS.UIBarrackModelManager.Instance:ShowBarrackObjWithLayer(true)
  end
end
function UIChrWeaponPanelV4:OnClose()
  FacilityBarrackGlobal:SwitchCameraPos(BarrackCameraStand.Base, false)
  if self.curContentType ~= 0 then
    self.contentList[self.curContentType]:Show(false)
    self.tabItemList[self.curContentType]:SetItemState(false)
  end
  if self.openFromType == UIWeaponPanel.OpenFromType.GachaPreview then
    SceneSys:SwitchVisible(EnumSceneType.Gacha)
  end
  self.curContentType = 0
  self:SetInputActive(true)
  self:RemoveListener()
end
function UIChrWeaponPanelV4:OnRelease()
  self.super.OnRelease(self)
  self:ReleaseCtrlTable(self.contentList)
  self:SetEscapeEnabled(false)
end
function UIChrWeaponPanelV4:InitTab()
  if #self.tabItemList > 0 then
    return
  end
  local tmpTabParent = self.ui.mScrollListChild_TopRightBtn.transform
  local initTab = function(index, systemId, hintId, globalTabId)
    local obj
    if index < tmpTabParent.childCount then
      obj = tmpTabParent:GetChild(index)
    end
    local tabItem = ChrWeaponTopBarItemV4.New()
    tabItem:InitCtrl(tmpTabParent.gameObject, systemId, hintId, obj, globalTabId)
    tabItem:OnButtonClick(function()
      self:ChangeContent(index)
      MessageSys:SendMessage(GuideEvent.OnTabSwitched, UIDef.UIWeaponPanel, tabItem:GetGlobalTab())
    end)
    table.insert(self.tabItemList, tabItem)
  end
  self.tabItemList = {}
  initTab(1, SystemList.GundetailWeapon, self.tabHint[1], 41)
  initTab(2, SystemList.GundetailWeaponpart, self.tabHint[2], 42)
end
function UIChrWeaponPanelV4:UpdateTabLock()
  for _, item in ipairs(self.tabItemList) do
    if self.isCompose then
      item:SetEnable(false)
    else
      item:SetEnable(true)
      item:UpdateSystemLock()
      if item.systemId == SystemList.GundetailWeaponpart then
        item:SetEnable(self.weaponCmdData.CanEquipMod)
      end
      if item.systemId == SystemList.GundetailWeapon then
        item:UpdateLockState(true)
      end
    end
  end
end
function UIChrWeaponPanelV4:InitContent()
  if #self.contentList > 0 then
    return
  end
  self.curContent = nil
  self.contentList = {}
  self.contentList[1] = UIWeaponOverviewPanelV4.New(self.ui.mTrans_Overview, self)
  self.contentList[2] = UIWeaponPartPanelV2.New(self.ui.mTrans_WeaponParts, self)
end
function UIChrWeaponPanelV4:InitLockItem()
  self.lockItem = UICommonLockItem.New()
  self.lockItem:InitToggle(self.ui.mToggle_Locked, self.ui.mTrans_LockState)
  self.lockItem:AddClickListener(function(isOn)
    self:OnClickLock(isOn)
  end)
end
function UIChrWeaponPanelV4:ChangeContent(contentType)
  if contentType == 0 or contentType == nil then
    return
  end
  if self.curContentType == 0 then
    self.curContentType = contentType
    self:ShowContent(self.curContentType, true)
    self:OnTabChanged(contentType, true)
    self.tabItemList[self.curContentType]:SetItemState(true)
  elseif self.curContentType ~= contentType then
    self:ShowMask(true)
    self.contentList[self.curContentType]:OnHide()
    self:OnTabChanged(self.curContentType, false)
    self:OnTabChanged(contentType, true)
    TransformUtils.PlayAniWithCallback(self.contentList[self.curContentType].mUIRoot.transform, function()
      self:ShowContent(self.curContentType, false)
      self.curContentType = contentType
      self:ShowContent(self.curContentType, true)
      self:ShowMask(false)
    end)
  end
end
function UIChrWeaponPanelV4:ShowContent(contentType, enabled)
  self.ui.mGFUIGroupList_ChrWeaponPanelV4:ChangeUIComponentGroups("partsclose", contentType ~= UIWeaponGlobal.WeaponContentTypeV4.WeaponPart)
  self.contentList[contentType]:Show(enabled)
  if enabled then
    self.contentList[contentType]:OnShowStart()
    setactive(self.contentList[contentType].mUIRoot.gameObject, true)
  else
    self.contentList[contentType]:OnHideFinish()
    setactive(self.contentList[contentType].mUIRoot.gameObject, false)
  end
  self:CheckTouchPad()
end
function UIChrWeaponPanelV4:OnTabChanged(contentType, enabled)
  if self.tabItemList ~= nil and self.tabItemList[contentType] ~= nil and self.tabItemList[contentType].SetItemState ~= nil then
    self.tabItemList[contentType]:SetItemState(enabled)
  end
  if self.contentList ~= nil and self.contentList[contentType] ~= nil and self.contentList[contentType].OnTabChanged ~= nil then
    self.contentList[contentType]:OnTabChanged(enabled)
  end
  self:CheckTouchPad()
end
function UIChrWeaponPanelV4:CheckTouchPad()
  setactive(self.ui.mTrans_TouchPad.gameObject, self.curContentType == UIWeaponGlobal.WeaponContentTypeV4.Weapon and not self.isShowReplaceList)
end
function UIChrWeaponPanelV4:ShowMask(boolean)
  self:SetInputActive(not boolean)
  if self ~= nil and self.ui ~= nil and not CS.LuaUtils.IsNullOrDestroyed(self.ui.mTrans_Mask) and not CS.LuaUtils.IsNullOrDestroyed(self.ui.mTrans_Mask.gameObject) then
    setactive(self.ui.mTrans_Mask.gameObject, boolean)
  end
end
function UIChrWeaponPanelV4:SetWeaponCmdData(weaponId)
  self.weaponCmdData = NetCmdWeaponData:GetWeaponById(weaponId)
end
function UIChrWeaponPanelV4:SetWeaponData()
  SceneSys:SwitchVisible(EnumSceneType.Barrack)
  BarrackHelper.CameraMgr:SetWeaponRT()
  self.weaponCmdData:ResetPreviewWeaponMod()
  self.bgImg.sprite = ResSys:GetWeaponBgSprite("Img_Weapon_Bg")
  self.bgImgAnimator = self.bgImg.gameObject:GetComponent(typeof(CS.UnityEngine.Animator))
  FacilityBarrackGlobal:SwitchCameraPos(BarrackCameraStand.Weapon, false)
  UISystem.BarrackCharacterCameraCtrl:ShowBarrack3DCanvas(true)
  UIWeaponGlobal.SetNeedCloseBarrack3DCanvas(false)
  self:UpdateWeaponModel()
  if self.openFromType ~= UIWeaponPanel.OpenFromType.BattlePass and self.openFromType ~= UIWeaponPanel.OpenFromType.BattlePassCollection and not self.isCompose then
    self:UpdateRedPoint()
  end
  self.mIsRelatedBP = self.openFromType == UIWeaponPanel.OpenFromType.BattlePass or self.openFromType == UIWeaponPanel.OpenFromType.BattlePassCollection
  self.lockItem:SetActive(not self.isCompose and not self.mIsRelatedBP and self.openFromType ~= UIWeaponPanel.OpenFromType.GachaPreview)
  self:UpdateLockStatue()
  setactive(self.ui.mTrans_Equiped.gameObject, false)
  if self.weaponCmdData ~= nil and self.weaponCmdData.CmdData ~= nil and self.weaponCmdData.CmdData.GunId ~= 0 then
    setactive(self.ui.mTrans_Equiped.gameObject, true)
    local beUsedGunId = self.weaponCmdData.CmdData.GunId
    local gunData = TableData.listGunDatas:GetDataById(beUsedGunId)
    self.ui.mText_Name.text = gunData.Name.str
    self.ui.mImg_ChrHead.sprite = IconUtils.GetCharacterHeadSpriteWithClothByGunId(IconUtils.cCharacterAvatarType_Avatar, gunData.id)
  end
end
function UIChrWeaponPanelV4:UpdateWeaponModel(needRefresh)
  if needRefresh == nil then
    needRefresh = false
  end
  local ignoreUnGet = self.openFromType == UIWeaponPanel.OpenFromType.GachaPreview or self.openFromType == UIWeaponPanel.OpenFromType.BattlePassCollection or self.openFromType == UIWeaponPanel.OpenFromType.BattlePass
  UIBarrackWeaponModelManager:GetBarrckWeaponModelByData(self.weaponCmdData, needRefresh, ignoreUnGet)
  UIBarrackWeaponModelManager:ShowCurWeaponModel(true)
end
function UIChrWeaponPanelV4:UpdateRedPoint()
  if self.weaponCmdData ~= nil then
    local redPoint
    for _, item in ipairs(self.tabItemList) do
      if item.hintId == self.tabHint[1] then
        self.contentList[1]:UpdateRedPoint()
        redPoint = self.weaponCmdData:GetWeaponLevelUpBreakRedPoint()
        redPoint = redPoint + self.contentList[1].redPointCount
      elseif item.hintId == self.tabHint[2] then
        redPoint = self.weaponCmdData:UpdateWeaponModRedPoint()
      end
      item:SetRedPointEnable(0 < redPoint)
    end
  end
end
function UIChrWeaponPanelV4:UpdateWeaponCapacity()
  setactive(self.ui.mTrans_PartsVolume.gameObject, false)
  return
end
function UIChrWeaponPanelV4:SetEscapeEnabled(enabled, btn)
  if enabled then
    if btn == nil then
      btn = self.ui.mBtn_Back
    end
    self:UnRegistrationKeyboard(KeyCode.Escape)
    self:RegistrationKeyboard(KeyCode.Escape, btn)
  else
    self:UnRegistrationKeyboard(KeyCode.Escape)
  end
end
function UIChrWeaponPanelV4:SwitchGun(isNext)
  isNext = isNext == nil and true or isNext
  if isNext then
    CS.UIBarrackModelManager.Instance:SwitchRightGunModel()
  else
    CS.UIBarrackModelManager.Instance:SwitchLeftGunModel()
  end
  local gunCmdData = NetCmdTeamData:GetOtherGunById(self.weaponCmdData.gun_id, isNext)
  self.weaponCmdData = gunCmdData.WeaponData
  if self.weaponCmdData.gun_id ~= 0 then
    self.gunCmdData = NetCmdTeamData:GetGunByStcId(self.weaponCmdData.gun_id)
  end
  self:SetWeaponData()
  MessageSys:SendMessage(CS.GF2.Message.FacilityBarrackEvent.OnSwitchGun, gunCmdData.stc_id)
end
function UIChrWeaponPanelV4:OnClickLock(isOn)
  local tmpWeaponCmdData = self.weaponCmdData
  if self.weaponCmdData == nil then
    tmpWeaponCmdData = self.weaponCmdData
  end
  if isOn == tmpWeaponCmdData.IsLocked then
    return
  end
  NetCmdWeaponData:SendGunWeaponLockUnlock(tmpWeaponCmdData.id, function(ret)
    if ret == ErrorCodeSuc then
      if isOn then
        UIUtils.PopupPositiveHintMessage(220007)
      else
        UIUtils.PopupPositiveHintMessage(220008)
      end
      self:UpdateLockStatue()
    end
  end)
end
function UIChrWeaponPanelV4:UpdateLockStatue()
  local tmpWeaponCmdData = self.weaponCmdData
  if self.weaponCmdData == nil then
    tmpWeaponCmdData = self.weaponCmdData
  end
  self.lockItem:SetLock(tmpWeaponCmdData.IsLocked)
end
function UIChrWeaponPanelV4:ActiveChrChangeBtn(boolean)
  self.ui.mBtn_ChrChange.enabled = boolean
end
function UIChrWeaponPanelV4:InteractChrChangeBtn(boolean)
  self.ui.mBtn_ChrChange.interactable = boolean
end
function UIChrWeaponPanelV4:OnChangeWeapon(message)
  local id = message.Sender
  if id == 0 or self.weaponCmdData ~= nil and self.weaponCmdData.id == id then
    return
  end
  self.weaponCmdData = NetCmdWeaponData:GetWeaponById(id)
  if self.contentList ~= nil and self.weaponCmdData ~= nil and 0 < #self.contentList then
    for i, v in ipairs(self.contentList) do
      if v.OnChangeWeapon ~= nil then
        v:OnChangeWeapon(self.weaponCmdData, self.curContentType == i)
      end
    end
  end
  self:SetWeaponData()
end
function UIChrWeaponPanelV4:OnSwitchGun(message)
  local id = message.Sender
  self.gunCmdData = NetCmdTeamData:GetGunByStcId(id)
  self.weaponCmdData = self.gunCmdData.WeaponData
  if self.contentList ~= nil and self.weaponCmdData ~= nil and #self.contentList > 0 then
    for i, v in ipairs(self.contentList) do
      if v.SwitchGun ~= nil then
        v:SwitchGun(self.gunCmdData, i == self.curContentType)
      end
    end
  end
end
function UIChrWeaponPanelV4:AddListener()
  function self.onChangeWeapon(message)
    self:OnChangeWeapon(message)
  end
  MessageSys:AddListener(CS.GF2.Message.FacilityBarrackEvent.OnChangeWeapon, self.onChangeWeapon)
  function self.onSwitchGun(message)
    self:OnSwitchGun(message)
  end
  MessageSys:AddListener(CS.GF2.Message.FacilityBarrackEvent.OnSwitchGun, self.onSwitchGun)
end
function UIChrWeaponPanelV4:RemoveListener()
  MessageSys:RemoveListener(CS.GF2.Message.FacilityBarrackEvent.OnChangeWeapon, self.onChangeWeapon)
  MessageSys:RemoveListener(CS.GF2.Message.FacilityBarrackEvent.OnSwitchGun, self.onSwitchGun)
end
