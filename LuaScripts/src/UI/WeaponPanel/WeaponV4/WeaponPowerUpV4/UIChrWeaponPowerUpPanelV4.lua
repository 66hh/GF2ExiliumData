require("UI.WeaponPanel.WeaponV4.WeaponPowerUpV4.UIWeaponPolarityPanelV4")
require("UI.WeaponPanel.WeaponV4.WeaponPowerUpV4.UIChrWeaponBreakPanelV4")
require("UI.WeaponPanel.WeaponV4.WeaponPowerUpV4.UIWeaponLevelUpPanelV4")
require("UI.WeaponPanel.WeaponV4.Item.ChrWeaponTopBarItemV4")
require("UI.Common.UICommonLockItem")
UIChrWeaponPowerUpPanelV4 = class("UIChrWeaponPowerUpPanelV4", UIBasePanel)
UIChrWeaponPowerUpPanelV4.__index = UIChrWeaponPowerUpPanelV4
function UIChrWeaponPowerUpPanelV4:ctor(csPanel)
  UIChrWeaponPowerUpPanelV4.super:ctor(csPanel)
  csPanel.Is3DPanel = true
end
function UIChrWeaponPowerUpPanelV4:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.tabHint = {
    [1] = 220015,
    [2] = 220016
  }
  self.gunCmdData = nil
  self.weaponCmdData = nil
  self.suitList = {}
  self.weaponPartUis = {}
  self.replaceBtnRedPoint = nil
  self.isLockGun = false
  self.tabItemList = {}
  self.lockItem = nil
  self.bgImg = nil
  self.bglizi = nil
  self.hadAddEvent = false
  self.contentList = {}
  self.curContentType = 0
  self.targetContent = 0
  self.changeContentTimer = nil
  self:InitTab()
  self:InitContent()
end
function UIChrWeaponPowerUpPanelV4:OnInit(root, data)
  self.weaponCmdData = data[1]
  self.targetContent = data[2]
  self.openFromType = data[3]
  self.needArrow = self.openFromType == UIWeaponPanel.OpenFromType.Barrack
  if self.weaponCmdData.gun_id ~= 0 then
    self.gunCmdData = NetCmdTeamData:GetGunByStcId(self.weaponCmdData.gun_id)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIWeaponGlobal.SetNeedCloseBarrack3DCanvas(false)
    UIManager.CloseUI(UIDef.UIChrWeaponPowerUpPanelV4)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIWeaponGlobal.SetNeedCloseBarrack3DCanvas(true)
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_PreGun.gameObject).onClick = function()
    self:SwitchGun(false)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_NextGun.gameObject).onClick = function()
    self:SwitchGun(true)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ChrChange.gameObject).onClick = function()
    local param = {
      [1] = self.gunCmdData.Id
    }
    UIManager.OpenUIByParam(UIDef.UIChrWeaponChangeEquipedChrDialog, param)
  end
  self:InitLockItem()
  self.bgImg = BarrackHelper.CameraMgr.Barrack3DCanvas.transform:Find("PanelPowerUp"):GetComponent(typeof(CS.UnityEngine.UI.Image))
  self.bgImgAnimator = self.bgImg.gameObject:GetComponent(typeof(CS.UnityEngine.Animator))
  self.bglizi = BarrackHelper.CameraMgr.Barrack3DCanvas.transform:Find("ChrWeaponPowerUp_Bglizi")
  for i, v in ipairs(self.contentList) do
    v:OnInit(self.weaponCmdData)
  end
end
function UIChrWeaponPowerUpPanelV4:OnShowStart()
  setactive(self.bgImg.gameObject, true)
  self.bgImgAnimator:SetTrigger("Ani_ChrWeaponPowerUpBg_FadeIn")
  self:UpdateTabLock()
  if self.targetContent == 0 or self.targetContent == nil then
    self.targetContent = 1
  end
  for i = 1, #self.tabItemList do
    if not self.tabItemList[i]:IsLock() then
      break
    end
    self.targetContent = self.targetContent + 1
  end
  if self.targetContent > #self.tabItemList then
    printstack("mylog:Lua:" .. "全都未解锁")
  end
  self:ChangeContent(self.targetContent)
  self:SetWeaponData()
end
function UIChrWeaponPowerUpPanelV4:OnSave()
  self.saveTargetContentType = self.curContentType
end
function UIChrWeaponPowerUpPanelV4:OnRecover()
  if self.saveTargetContentType ~= nil and tonumber(self.saveTargetContentType) > 0 then
    self.targetContent = self.saveTargetContentType
  end
  self:OnShowStart()
end
function UIChrWeaponPowerUpPanelV4:OnBackFrom()
  self:SetWeaponData()
  if self.curContentType ~= 0 and self.contentList[self.curContentType] ~= nil then
    self.contentList[self.curContentType]:OnBackFrom()
  end
end
function UIChrWeaponPowerUpPanelV4:OnTop()
  self:SetWeaponData()
  if self.curContentType ~= 0 and self.contentList[self.curContentType] ~= nil then
    self.contentList[self.curContentType]:OnTop()
  end
end
function UIChrWeaponPowerUpPanelV4:OnShowFinish()
  self:AddListener()
  if self.curContentType ~= 0 and self.contentList[self.curContentType] ~= nil then
    self.contentList[self.curContentType]:OnShowFinish()
  end
end
function UIChrWeaponPowerUpPanelV4:OnCameraStart()
  return 0.01
end
function UIChrWeaponPowerUpPanelV4:OnRefresh()
  self:SetWeaponData()
  for i, v in ipairs(self.contentList) do
    if v.OnRefresh ~= nil then
      v:OnRefresh()
    end
    if v.SetWeaponData ~= nil then
      v:SetWeaponData(false)
    end
  end
end
function UIChrWeaponPowerUpPanelV4:OnHide()
  self.bgImgAnimator:SetTrigger("Ani_ChrWeaponPowerUpBg_FadeOut")
end
function UIChrWeaponPowerUpPanelV4:OnHideFinish()
  setactive(self.bgImg.gameObject, false)
  if UIWeaponGlobal.GetNeedCloseBarrack3DCanvas() then
    UIWeaponGlobal:ReleaseWeaponModel()
    CS.UIBarrackModelManager.Instance:ShowBarrackObjWithLayer(true)
  end
end
function UIChrWeaponPowerUpPanelV4:OnClose()
  self:RemoveListener()
  if self.curContentType ~= 0 then
    self.contentList[self.curContentType]:OnClose()
    if self.contentList[self.curContentType].OnRelease ~= nil then
      self.contentList[self.curContentType]:OnRelease()
    end
    self.tabItemList[self.curContentType]:SetItemState(false)
    setactive(self.contentList[self.curContentType].mUIRoot.gameObject, false)
    self.curContentType = 0
  end
  if self.bglizi ~= nil then
    setactive(self.bglizi.gameObject, false)
  end
end
function UIChrWeaponPowerUpPanelV4:OnRelease()
  self.super.OnRelease(self)
end
function UIChrWeaponPowerUpPanelV4:InitLockItem()
  self.lockItem = UICommonLockItem.New()
  self.lockItem:InitToggle(self.ui.mToggle_Locked, self.ui.mTrans_LockState)
  self.lockItem:AddClickListener(function(isOn)
    self:OnClickLock(isOn)
  end)
end
function UIChrWeaponPowerUpPanelV4:InitTab()
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
      MessageSys:SendMessage(GuideEvent.OnTabSwitched, UIDef.UIChrWeaponPowerUpPanelV4, tabItem:GetGlobalTab())
    end)
    table.insert(self.tabItemList, tabItem)
  end
  self.tabItemList = {}
  initTab(1, SystemList.WeaponClass, self.tabHint[2], 52)
  initTab(2, SystemList.WeaponUpgrade, self.tabHint[1], 51)
end
function UIChrWeaponPowerUpPanelV4:UpdateTabLock()
  for _, item in ipairs(self.tabItemList) do
    item:UpdateSystemLock()
  end
end
function UIChrWeaponPowerUpPanelV4:InitContent()
  if #self.contentList > 0 then
    return
  end
  self.curContent = nil
  self.contentList = {}
  self.contentList[1] = UIChrWeaponBreakPanelV4.New(self.ui.mTrans_Break, self)
  self.contentList[2] = UIWeaponLevelUpPanelV4.New(self.ui.mTrans_LevelUp, self)
end
function UIChrWeaponPowerUpPanelV4:ChangeContent(contentType)
  if contentType == 0 or contentType == nil or contentType > #self.contentList then
    return
  end
  if self.curContentType == 0 then
    self.curContentType = contentType
    self:ShowContent(self.curContentType, true)
  elseif self.curContentType ~= contentType then
    self:ShowMask(true)
    self.contentList[self.curContentType]:OnHide()
    self.tabItemList[self.curContentType]:SetItemState(false)
    self.tabItemList[contentType]:SetItemState(true)
    if self.changeContentTimer ~= nil then
      self.changeContentTimer:Stop()
    end
    self.changeContentTimer = TransformUtils.PlayAniWithCallback(self.contentList[self.curContentType].mUIRoot.transform, function()
      self:ShowContent(self.curContentType, false)
      self.curContentType = contentType
      self:ShowContent(self.curContentType, true)
      self:ShowMask(false)
    end)
  end
end
function UIChrWeaponPowerUpPanelV4:ShowContent(contentType, enabled)
  self.contentList[contentType]:Show(enabled)
  self.tabItemList[contentType]:SetItemState(enabled)
  if enabled then
    setactive(self.contentList[contentType].mUIRoot.gameObject, true)
    self.contentList[contentType]:OnShowStart()
  else
    self.contentList[contentType]:OnClose()
    setactive(self.contentList[contentType].mUIRoot.gameObject, false)
  end
end
function UIChrWeaponPowerUpPanelV4:ShowMask(boolean)
  self:SetInputActive(not boolean)
  if self ~= nil and self.ui ~= nil and not CS.LuaUtils.IsNullOrDestroyed(self.ui.mTrans_Mask) and not CS.LuaUtils.IsNullOrDestroyed(self.ui.mTrans_Mask.gameObject) then
    setactive(self.ui.mTrans_Mask.gameObject, boolean)
  end
end
function UIChrWeaponPowerUpPanelV4:SetWeaponData()
  SceneSys:SwitchVisible(EnumSceneType.Barrack)
  CS.UIBarrackModelManager.Instance:ShowBarrackObjWithLayer(false)
  UISystem.BarrackCharacterCameraCtrl:ShowBarrack3DCanvas(true)
  BarrackHelper.CameraMgr:ChangeCameraStand(BarrackCameraStand.Weapon, false)
  BarrackHelper.CameraMgr:SetWeaponRT()
  self.bgImg.sprite = ResSys:GetWeaponBgSprite("Img_WeaponPowerUp_Bg")
  if self.bglizi ~= nil then
    setactive(self.bglizi.gameObject, true)
  end
  self.ui.mImg_Icon.sprite = IconUtils.GetWeaponSprite(self.weaponCmdData.StcData.res_code)
  self.ui.mText_WeaponName.text = self.weaponCmdData.Name
  local weaponTypeData = TableData.listGunWeaponTypeDatas:GetDataById(self.weaponCmdData.Type)
  self.ui.mText_WeaponType.text = weaponTypeData.Name.str
  self.ui.mImg_Quality.color = TableData.GetGlobalGun_Quality_Color2(self.weaponCmdData.Rank)
  self.ui.mText_WeaponQuality.text = TableData.GetHintById(220055 + self.weaponCmdData.Rank)
  self.ui.mText_WeaponQuality.color = TableData.GetGlobalGun_Quality_Color2(self.weaponCmdData.Rank)
  setactive(self.ui.mTrans_Arrow.gameObject, self.needArrow)
  setactive(self.ui.mTrans_Equiped.gameObject, false)
  if self.weaponCmdData ~= nil and self.weaponCmdData.CmdData ~= nil and self.weaponCmdData.CmdData.GunId ~= 0 then
    setactive(self.ui.mTrans_Equiped.gameObject, true)
    local beUsedGunId = self.weaponCmdData.CmdData.GunId
    local gunData = TableData.listGunDatas:GetDataById(beUsedGunId)
    self.ui.mText_Name.text = gunData.Name.str
    self.ui.mImg_ChrHead.sprite = IconUtils.GetCharacterHeadSpriteWithClothByGunId(IconUtils.cCharacterAvatarType_Avatar, gunData.id)
  end
  self:UpdateWeaponModel()
  self:UpdateRedPoint()
  self:UpdateLockStatue()
end
function UIChrWeaponPowerUpPanelV4:UpdateWeaponModel()
  UIBarrackWeaponModelManager:GetBarrckWeaponModelByData(self.weaponCmdData)
end
function UIChrWeaponPowerUpPanelV4:UpdateRedPoint()
  if self.weaponCmdData ~= nil then
    local redPoint
    for _, item in ipairs(self.tabItemList) do
      if item.hintId == self.tabHint[1] then
        redPoint = self.weaponCmdData:GetWeaponLevelUpRedPoint()
      elseif item.hintId == self.tabHint[2] then
        redPoint = self.weaponCmdData:GetWeaponBreakRedPoint()
      end
      item:SetRedPointEnable(0 < redPoint)
    end
  end
end
function UIChrWeaponPowerUpPanelV4:UpdateLockStatue()
  self.lockItem:SetLock(self.weaponCmdData.IsLocked)
end
function UIChrWeaponPowerUpPanelV4:OnClickLock(isOn)
  if isOn == self.weaponCmdData.IsLocked then
    return
  end
  NetCmdWeaponData:SendGunWeaponLockUnlock(self.weaponCmdData.id, function(ret)
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
function UIChrWeaponPowerUpPanelV4:SwitchGun(isNext)
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
  for i, v in ipairs(self.contentList) do
    if v.SwitchGun ~= nil then
      v:SwitchGun(self.gunCmdData, i == self.curContentType)
    end
  end
  self:UpdateRedPoint()
end
function UIChrWeaponPowerUpPanelV4:IsReadyToStartTutorial()
  return UIWeaponGlobal.GetIsReadyToStartTutorial()
end
function UIChrWeaponPowerUpPanelV4:OnSwitchGun(message)
  local id = message.Sender
  self.gunCmdData = NetCmdTeamData:GetGunByStcId(id)
  self.weaponCmdData = self.gunCmdData.WeaponData
  self:SetWeaponData()
  for i, v in ipairs(self.contentList) do
    if v.SwitchGun ~= nil then
      v:SwitchGun(self.gunCmdData, i == self.curContentType)
    end
  end
  self:UpdateRedPoint()
end
function UIChrWeaponPowerUpPanelV4:AddListener()
  if self.hadAddEvent then
    return
  end
  function self.onSwitchGun(message)
    self:OnSwitchGun(message)
  end
  MessageSys:AddListener(CS.GF2.Message.FacilityBarrackEvent.OnSwitchGun, self.onSwitchGun)
  function self.changeContent(message)
    local contentType = message.Sender
    if type(contentType) ~= "number" then
      return
    end
    self:ChangeContent(contentType)
  end
  MessageSys:AddListener(CS.GF2.Message.FacilityBarrackEvent.ChangeContent, self.changeContent)
  self.hadAddEvent = true
  for i, v in ipairs(self.contentList) do
    if v.AddListener ~= nil then
      v:AddListener()
    end
  end
end
function UIChrWeaponPowerUpPanelV4:RemoveListener()
  if not self.hadAddEvent then
    return
  end
  MessageSys:RemoveListener(CS.GF2.Message.FacilityBarrackEvent.OnSwitchGun, self.onSwitchGun)
  MessageSys:RemoveListener(CS.GF2.Message.FacilityBarrackEvent.ChangeContent, self.changeContent)
  self.hadAddEvent = false
  for i, v in ipairs(self.contentList) do
    if v.RemoveListener ~= nil then
      v:RemoveListener()
    end
  end
end
