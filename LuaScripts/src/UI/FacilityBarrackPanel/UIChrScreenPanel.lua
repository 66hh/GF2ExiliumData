require("UI.FacilityBarrackPanel.Item.ComChrInfoItem")
require("UI.FacilityBarrackPanel.FacilityBarrackGlobal")
require("UI.FacilityBarrackPanel.Item.ChrWeaponItem")
require("UI.FacilityBarrackPanel.Item.ChrBarrackSkillItem")
require("UI.Character.UIComStageItem")
UIChrScreenPanel = class("UIChrScreenPanel", UIBasePanel)
UIChrScreenPanel.__index = UIChrScreenPanel
function UIChrScreenPanel:ctor(csPanel)
  UIChrScreenPanel.super:ctor(csPanel)
  csPanel.Is3DPanel = true
end
function UIChrScreenPanel:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.mGunCmdData = nil
  self.mGunData = nil
  self.curClickUnLockIndex = -1
  self.curClickLockIndex = -1
  self.curChrGunId = -1
  self.curChrItem = nil
  self.gunCmdDataList = nil
  self.lockGunDataList = nil
  self.isUnLock = true
  self.isGunLock = false
  self.skillList = {}
  self.comScreenItem = nil
  self.chrWeaponItem = nil
  self.selectRedPoint = nil
  self.btnTalentSet = nil
  self.stageItem = nil
  self.isGunUnlockEnough = false
  self.isComposeBack = false
  self:InitGunList()
  self:InitRank()
  self:InitSkillList()
  self:InitChrWeaponItem()
  self:InitScreen()
end
function UIChrScreenPanel:OnInit(root, gunCmdData)
  self.isComposeBack = false
  if FacilityBarrackGlobal.ScreenPanelGunId ~= 0 then
    self:ResetSaveGunId()
  else
    self:SetGunCmdData(gunCmdData, false)
    self.isGunLock = gunCmdData.isLockGun
  end
  self.ui.mToggle_ChrState.isOn = not self.isGunLock
  self.isUnLock = not self.isGunLock
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBack.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIChrScreenPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnSelect.gameObject).onClick = function()
    self:OnClickBtnSelect()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnCompose.gameObject).onClick = function()
    self:OnClickBtnCompose()
  end
  self.selectRedPoint = self.ui.mBtn_BtnSelect.transform:Find("Root/Trans_RedPoint")
  self.composeRedPoint = self.ui.mBtn_BtnCompose.transform:Find("Root/Trans_RedPoint")
  self:AddListener()
end
function UIChrScreenPanel:OnShowStart()
  FacilityBarrackGlobal:SwitchCameraPos(BarrackCameraStand.Base, false)
  UISystem.BarrackCharacterCameraCtrl:DetachChrTouchCtrlEvents()
  self:UpdatePanel()
  self:UpdateComScreenItem()
  self:UpdateGunList()
end
function UIChrScreenPanel:OnSave()
  FacilityBarrackGlobal.ScreenPanelGunId = self.mGunData.id
end
function UIChrScreenPanel:OnRecover()
  SceneSys:SwitchVisible(EnumSceneType.Barrack)
  FacilityBarrackGlobal:SwitchCameraPos(BarrackCameraStand.Base, false)
  UISystem.BarrackCharacterCameraCtrl:DetachChrTouchCtrlEvents()
  self:UpdatePanel()
  self:UpdateComScreenItem()
  self:UpdateGunList()
end
function UIChrScreenPanel:OnBackFrom()
  if not self.isComposeBack then
    self:OnRecover()
  end
end
function UIChrScreenPanel:OnTop()
end
function UIChrScreenPanel:OnShowFinish()
  self:ResetEscapeBtn(false)
end
function UIChrScreenPanel:OnCameraStart()
  return 0.01
end
function UIChrScreenPanel:OnCameraBack()
  return 0.01
end
function UIChrScreenPanel:OnHide()
end
function UIChrScreenPanel:OnHideFinish()
end
function UIChrScreenPanel:OnClose()
  self:RemoveListener()
  FacilityBarrackGlobal.SetNeedBarrackEntrance(false)
  self.comScreenItem:OnCloseFilterBtnClick()
  self.ui.mVirtualListEx_GrpList.numItems = 0
  self.curClickUnLockIndex = -1
  self.curClickLockIndex = -1
  self.curChrGunId = -1
end
function UIChrScreenPanel:OnRelease()
  if self.comScreenItem then
    self.comScreenItem:OnRelease()
    self.comScreenItem = nil
  end
  self.super.OnRelease(self)
end
function UIChrScreenPanel:InitGunList()
  self.gunCmdDataList = NetCmdTeamData:GetBarrackGunCmdDatas()
  self.lockGunDataList = NetCmdTeamData:GetBarrackLockGunCmdDatas()
  function self.itemProvider()
    return self:ItemProvider()
  end
  function self.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  self.ui.mVirtualListEx_GrpList.itemProvider = self.itemProvider
  self.ui.mVirtualListEx_GrpList.itemRenderer = self.itemRenderer
end
function UIChrScreenPanel:ItemProvider()
  local itemView = ComChrInfoItem.New()
  itemView:InitCtrl(self.ui.mScrollListChild_Content.transform)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIChrScreenPanel:ItemRenderer(index, renderData)
  local item = renderData.data
  item.ItemIndex = index
  local data
  if self.isUnLock then
    if index >= self.gunCmdDataList.Count then
      return
    end
    data = self.gunCmdDataList[index]
    item:SetData(data, data.gunData, function()
      self:OnChrInfoItemClick(item)
    end)
  else
    if index >= self.lockGunDataList.Count then
      return
    end
    data = self.lockGunDataList[index]
    item:SetData(nil, data.gunData, function()
      self:OnChrInfoItemClick(item)
    end)
  end
  local isLastUnLock
  if self.curChrGunId ~= -1 then
    local gunCmdData = NetCmdTeamData:GetGunByID(self.curChrGunId)
    isLastUnLock = gunCmdData ~= nil
  end
  item:SetSelect(false)
  if self.mGunData.Id == item.mGunData.Id and self.curClickLockIndex == -1 and self.curClickUnLockIndex == -1 and self.curChrGunId == -1 then
    self:OnChrInfoItemClick(item)
    item:SetSelect(true)
  elseif self.isUnLock then
    if isLastUnLock and self.curChrGunId == data.GunId or self.curClickUnLockIndex == index and not isLastUnLock then
      self:OnChrInfoItemClick(item)
      item:SetSelect(true)
    end
  elseif self.curClickLockIndex == -1 and index == 0 or self.curClickLockIndex == index or self.curChrGunId == data.GunId and not isLastUnLock then
    self:OnChrInfoItemClick(item)
    item:SetSelect(true)
  end
  local go = item:GetRoot().gameObject
  local itemId = data.gunData.id
  MessageSys:SendMessage(GuideEvent.VirtualListRendererChanged, VirtualListRendererChangeData(go, itemId, index))
end
function UIChrScreenPanel:InitRank()
  local stageItem = UIComStageItemV3.New()
  stageItem:InitCtrl(self.ui.mScrollListChild_GrpStage.transform, true)
  self.stageItem = stageItem
end
function UIChrScreenPanel:InitSkillList()
  self.skillList = {}
  for i = 1, 5 do
    local skillItem = ChrBarrackSkillItem.New()
    skillItem:InitCtrl(self.ui.mScrollListChild_GrpSkill.transform)
    table.insert(self.skillList, skillItem)
  end
end
function UIChrScreenPanel:InitChrWeaponItem()
  self.chrWeaponItem = ChrWeaponItem.New()
  self.chrWeaponItem:InitCtrl(self.ui.mScrollListChild_WeaponBox.transform)
end
function UIChrScreenPanel:InitScreen()
  if self.comScreenItem ~= nil then
    return
  end
  self.comScreenItem = ComScreenItemHelper:InitGun(self.ui.mScrollListChild_GrpScreen.gameObject, self.gunCmdDataList, function()
    self:UpdateGunList()
  end, nil, true)
  self.comScreenItem:SetOnShowMultiListFilterCallback(function()
    self:ResetEscapeBtn(true)
  end)
  self.comScreenItem:SetOnCloseMultiListFilterCallback(function()
    self:ResetEscapeBtn(false)
  end)
end
function UIChrScreenPanel:SetGunCmdData(gunCmdData, changeAnim)
  changeAnim = changeAnim == nil and true or changeAnim
  if changeAnim then
    FacilityBarrackGlobal.SetNeedBarrackEntrance(self.mGunCmdData == nil or gunCmdData == nil or self.mGunCmdData ~= nil and gunCmdData ~= nil and self.mGunCmdData.Id ~= gunCmdData.Id)
  end
  self.mGunCmdData = gunCmdData
  if self.mGunCmdData ~= nil then
    self.mGunData = self.mGunCmdData.TabGunData
  end
  if self.mGunData == nil then
    self.mGunData = TableData.listGunDatas:GetDataById(gunCmdData.stc_id)
  end
end
function UIChrScreenPanel:UpdatePanel()
  local gunData = self.mGunCmdData
  self.gunMaxLevel = gunData.MaxGunLevel
  local dutyData = TableData.listGunDutyDatas:GetDataById(gunData.TabGunData.duty)
  self.ui.mImg_Duty.sprite = IconUtils.GetGunTypeIcon(dutyData.icon .. "_W")
  local dutyTxt = dutyData.name.str
  if gunData.TabGunData.second_duty ~= 0 then
    local secondDutyData = TableData.listSecondDutyDatas:GetDataById(gunData.TabGunData.second_duty)
    dutyTxt = dutyTxt .. "·" .. secondDutyData.name.str
  end
  self.ui.mText_Name1.text = dutyTxt
  self.ui.mText_ChrName.text = self.mGunData.name.str
  self.ui.mText_Lv.text = GlobalConfig.SetLvText(gunData.level)
  self.ui.mText_LvNum.text = self.gunMaxLevel
  FacilityBarrackGlobal.HideEffectNum()
  self.ui.mText_Num1.text = NetCmdTeamData:GetGunFightingCapacity(gunData)
  self.ui.mImg_QualityColor.color = TableData.GetGlobalGun_Quality_Color2(gunData.TabGunData.rank, self.ui.mImg_QualityColor.color.a)
  local elementData = TableData.listLanguageElementDatas:GetDataById(gunData.TabGunData.Element)
  if elementData ~= nil then
  end
  setactive(self.ui.mBtn_BtnCompose.gameObject, self.isGunLock)
  setactive(self.ui.mTrans_BtnCompose.gameObject, self.isGunLock)
  setactive(self.ui.mBtn_BtnSelect.gameObject, not self.isGunLock)
  setactive(self.ui.mScrollListChild_GrpStage.gameObject, not self.isGunLock)
  setactive(self.ui.mTrans_EquipInfo.gameObject, not self.isGunLock)
  setactive(self.ui.mTrans_SetTalent.gameObject, not self.isGunLock)
  setactive(self.ui.mTrans_Lv.gameObject, not self.isGunLock)
  setactive(self.ui.mTrans_GainWays, false)
  if self.isGunLock then
    local itemData = TableData.listItemDatas:GetDataById(self.mGunData.core_item_id)
    local curChipNum = NetCmdItemData:GetItemCount(itemData.id)
    local unLockNeedNum = tonumber(self.mGunData.unlock_cost)
    self.isGunUnlockEnough = curChipNum >= unLockNeedNum
    self.ui.mText_Num.text = curChipNum .. "/" .. unLockNeedNum
    if self.isGunUnlockEnough then
      self.ui.mText_Num.text = curChipNum .. "/" .. unLockNeedNum
    else
      self.ui.mText_Num.text = "<color=red>" .. curChipNum .. "</color>/" .. unLockNeedNum
    end
    self.ui.mImg_Item.sprite = IconUtils.GetItemIconSprite(self.mGunData.core_item_id)
    UIUtils.GetButtonListener(self.ui.mBtn_ConsumeItem.gameObject).onClick = function()
      local data = TableData.GetItemData(self.mGunData.core_item_id)
      UITipsPanel.Open(data, 0, true)
    end
    setactive(self.composeRedPoint.gameObject, self.isGunUnlockEnough)
    local unlockId = gunData.TabGunData.unlock_hint
    setactive(self.ui.mTrans_GainWays, 0 < unlockId)
    if 0 < unlockId then
      self.ui.mText_Way1.text = TableData.GetHintById(unlockId)
    end
  else
    self:UpdateTalent()
    self:UpdateChrWeaponItem()
    self:UpdateRedPoint()
  end
  self:UpdateRank()
  self:UpdateSkillList()
end
function UIChrScreenPanel:UpdateGunList()
  local tmpResultList = self.comScreenItem:GetResultList()
  local hasNoLockGun = tmpResultList.Count == 0
  setactive(self.ui.mTrans_None.gameObject, hasNoLockGun)
  self:UpdateToggleRedPoint()
  if not hasNoLockGun then
    if self.isUnLock then
      self.gunCmdDataList = tmpResultList
      if self.mGunCmdData == nil then
        self:SetGunCmdData(tmpResultList[0], false)
      end
      local itemDataList = LuaUtils.ConvertToItemIdList(self.gunCmdDataList)
      self.ui.mVirtualListEx_GrpList:SetItemIdList(itemDataList)
      self.ui.mVirtualListEx_GrpList.numItems = self.gunCmdDataList.Count
    else
      self.lockGunDataList = tmpResultList
      if self.mGunData == nil then
        self.mGunData = self.lockGunDataList[0]
      end
      local itemDataList = LuaUtils.ConvertToItemIdList(self.lockGunDataList)
      self.ui.mVirtualListEx_GrpList:SetItemIdList(itemDataList)
      self.ui.mVirtualListEx_GrpList.numItems = self.lockGunDataList.Count
    end
  else
    self.ui.mVirtualListEx_GrpList.numItems = 0
  end
  if self.curChrItem ~= nil then
    self.curChrItem:SetSelect(false)
    self.curChrItem = nil
  end
  self.ui.mVirtualListEx_GrpList:Refresh()
end
function UIChrScreenPanel:UpdateRank()
  self.stageItem:SetData(self.mGunCmdData.upgrade)
end
function UIChrScreenPanel:UpdateSkillList()
  if self.skillList then
    local data = self.mGunCmdData.CurAbbr
    for i = 0, data.Count - 1 do
      local skill = self.skillList[i + 1]
      skill:SetData(data[i], function()
        self:OnClickSkill(skill.mBattleSkillData, i + 1)
      end)
    end
  end
  FacilityBarrackGlobal.CurBattleSkillDataList = self.skillList
end
function UIChrScreenPanel:UpdateTalent()
  local id = self.mGunCmdData.id
  local isTalentSysLock = AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.SquadTalent)
  if not isTalentSysLock then
    setactive(self.ui.mTrans_SetTalent, true)
  end
  if self.isGunLock then
    setactive(self.ui.mTrans_SetTalent, false)
  end
  setactive(self.ui.mTrans_SetTalent, true)
  if not self.isGunLock then
    self:UpdateTalentButton()
  end
  local sprite = NetCmdTalentData:GetTalentIcon(id)
  local talentData = NetCmdTalentData:GetTalentData(id)
  if sprite ~= nil then
  else
    printstack("mylog:Lua:" .. "出错了")
  end
end
function UIChrScreenPanel:UpdateTalentButton()
  if self.btnTalentSet == nil then
    self.btnTalentSet = UIGunTalentAssemblyUnlockItem.New()
    self.btnTalentSet:InitCtrl(self.ui.mTrans_Content)
    self.btnTalentSet:SetData(self.mGunCmdData.GunId)
  else
    self.btnTalentSet:SetData(self.mGunCmdData.GunId)
  end
  self.btnTalentSet:AddClickListener(function()
    self:OnClickTalentButton()
  end)
end
function UIChrScreenPanel:OnClickTalentButton()
  if AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.SquadTalentEquip) then
    local gunId = self.mGunCmdData.GunId
    local needMoveCamera = true
    UIManager.OpenUIByParam(UIDef.UIGunTalentAssemblyPanel, {gunId, needMoveCamera})
    BarrackHelper.ModelMgr:ResetBarrackIdle()
  elseif TipsManager.NeedLockTips(SystemList.SquadTalentEquip) then
    return
  end
end
function UIChrScreenPanel:UpdateChrWeaponItem()
  self.chrWeaponItem:SetData(self.mGunCmdData, function()
    self:OnClickWeaponItem()
  end, not self.isUnLock)
end
function UIChrScreenPanel:OnClickWeaponItem()
  local param = {
    self.mGunCmdData.WeaponData.id,
    UIWeaponGlobal.WeaponPanelTab.Info,
    true,
    UIWeaponPanel.OpenFromType.Barrack,
    needReplaceBtn = true
  }
  UIManager.OpenUIByParam(UIDef.UIWeaponPanel, param)
end
function UIChrScreenPanel:UpdateComScreenItem()
  self.comScreenItem:SetUserData(not self.isUnLock)
  if self.isUnLock then
    self.comScreenItem:SetList(NetCmdTeamData:GetBarrackGunCmdDatas())
  else
    self.comScreenItem:SetList(NetCmdTeamData:GetBarrackLockGunCmdDatas())
  end
end
function UIChrScreenPanel:UpdateRedPoint()
  if self.chrWeaponItem ~= nil and self.curChrItem ~= nil then
    local redPointCount = self.chrWeaponItem.redPointCount + self.curChrItem.redPointCount
    setactive(self.selectRedPoint.gameObject, 0 < redPointCount)
  else
    setactive(self.selectRedPoint.gameObject, false)
  end
end
function UIChrScreenPanel:UpdateToggleRedPoint()
  if not self.isUnLock then
    setactive(self.ui.mScrollListChild_RedPoint.gameObject, false)
    return
  end
  local redPoint = 0
  local lockGuns = NetCmdTeamData:GetBarrackLockGunCmdDatas()
  for i = 0, lockGuns.Count - 1 do
    redPoint = redPoint + lockGuns[i]:GetGunRedPoint()
  end
  setactive(self.ui.mScrollListChild_RedPoint.gameObject, 0 < redPoint)
end
function UIChrScreenPanel:UpdateModel()
  if CS.UIBarrackModelManager.Instance.curModel ~= nil and self.mGunCmdData.GunId == CS.UIBarrackModelManager.Instance.curModel.tableId then
    CS.UIBarrackModelManager.Instance:SetCurModelLock(self.isGunLock)
    CS.UIBarrackModelManager.Instance.curModel:Show(true)
    return
  end
  self.isGunLock = self.mGunCmdData.isLockGun
  CS.UIBarrackModelManager.Instance:SwitchGunModel(self.mGunCmdData, function(modelGameObject)
    FacilityBarrackGlobal:SwitchCameraPos(BarrackCameraStand.Base, true)
    FacilityBarrackGlobal.SetNeedBarrackEntrance(not self.isGunLock)
    CS.UIBarrackModelManager.Instance:SetCurModelLock(self.isGunLock)
    CS.UIBarrackModelManager.Instance.curModel:Show(true)
  end)
  self.ui.mAnimator_Root:SetTrigger("Switch")
end
function UIChrScreenPanel:UpdateModelCallback(modelGameObject)
  local topUi = UISystem:GetTopPanelUI()
  if topUi.UIDefine.UIName ~= "UIChrScreenPanel" then
    return
  end
  if CS.UIBarrackModelManager.Instance.curModel ~= nil and self.mGunCmdData.GunId == CS.UIBarrackModelManager.Instance.curModel.tableId then
    CS.UIBarrackModelManager.Instance:SetCurModelLock(self.isGunLock)
    CS.UIBarrackModelManager.Instance.curModel:Show(true)
  end
end
function UIChrScreenPanel:ResetSaveGunId()
  if FacilityBarrackGlobal.ScreenPanelGunId == 0 then
    return
  end
  local gunCmdData = NetCmdTeamData:GetGunByID(FacilityBarrackGlobal.ScreenPanelGunId)
  self.isGunLock = gunCmdData == nil
  if gunCmdData == nil then
    local tmpGunCmdData = CS.GunCmdData()
    tmpGunCmdData:SetData(FacilityBarrackGlobal.ScreenPanelGunId)
    self:SetGunCmdData(tmpGunCmdData, false)
  else
    self:SetGunCmdData(gunCmdData, false)
  end
  FacilityBarrackGlobal.ScreenPanelGunId = 0
end
function UIChrScreenPanel:OnChrInfoItemClick(chrInfoItem)
  if chrInfoItem then
    if self.curChrItem then
      if self.curChrItem.mGunData.id == chrInfoItem.mGunData.id then
        return
      end
      self.curChrItem:SetSelect(false)
    end
    chrInfoItem:SetSelect(true)
    self.curChrItem = chrInfoItem
    FacilityBarrackGlobal.ShowingGunId = chrInfoItem.mGunData.id
    local gunCmdData = NetCmdTeamData:GetGunByID(chrInfoItem.mGunData.id)
    self.isGunLock = gunCmdData == nil
    if gunCmdData == nil then
      local tmpGunCmdData = CS.GunCmdData()
      tmpGunCmdData:SetData(chrInfoItem.mGunData.id)
      self:SetGunCmdData(tmpGunCmdData, not tmpGunCmdData.isLockGun)
      self.curClickLockIndex = chrInfoItem.ItemIndex
      self.curChrGunId = tmpGunCmdData.GunId
    else
      self.curClickUnLockIndex = chrInfoItem.ItemIndex
      self.curChrGunId = gunCmdData.GunId
      self:SetGunCmdData(gunCmdData, not gunCmdData.isLockGun)
    end
    if self.mGunCmdData == nil then
      self:SetGunCmdData(NetCmdTeamData:GetLockGunData(chrInfoItem.mGunData.id))
    end
    self:UpdateModel()
    self:UpdatePanel()
  end
end
function UIChrScreenPanel:OnClickBtnSelect()
  UIManager.CloseUI(UIDef.UIChrScreenPanel)
end
function UIChrScreenPanel:OnClickBtnCompose()
  if not self.isGunUnlockEnough then
    local itemData = TableData.GetItemData(self.mGunData.core_item_id)
    UITipsPanel.Open(itemData, 0, true)
  else
    NetCmdTrainGunData:SendCmdUpgradeGun(self.mGunData.id, function(ret)
      FacilityBarrackGlobal.SetNeedBarrackEntrance(true)
      self:UnLockCallBack(ret)
    end)
  end
end
function UIChrScreenPanel:UnLockCallBack(ret)
  if ret == ErrorCodeSuc then
    printstack("解锁人形成功")
    self.isComposeBack = true
    local data = {}
    data.ItemId = self.mGunCmdData.id
    UICommonGetGunPanel.OpenGetGunPanel({data}, function()
      UIManager.CloseUI(UIDef.UIChrScreenPanel)
      if SceneSys.currentScene:GetSceneType() == CS.EnumSceneType.CommandCenter then
        SceneSys:SwitchVisible(CS.EnumSceneType.Barrack)
      end
    end, nil, true)
  else
    printstack("解锁人形失败")
  end
end
function UIChrScreenPanel:ResetEscapeBtn(boolean)
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
function UIChrScreenPanel:ToggleChrStateOnValueChanged(ison)
  self.mGunData = nil
  self.mGunCmdData = nil
  self.isUnLock = ison
  self.curChrItem = nil
  FacilityBarrackGlobal.SetNeedBarrackEntrance(ison)
  self:UpdateComScreenItem()
  self.comScreenItem:DoFilter()
  if self.isUnLock and self.curClickUnLockIndex ~= -1 then
    self.ui.mVirtualListEx_GrpList:CalculateScrollTo(self.curClickUnLockIndex, false, nil, ScrollAlign.Start, true)
  elseif not self.isUnLock and self.curClickLockIndex ~= -1 then
    self.ui.mVirtualListEx_GrpList:CalculateScrollTo(self.curClickLockIndex, false, nil, ScrollAlign.Start, true)
  end
end
function UIChrScreenPanel:OnClickSkill(skillData, pos)
  UIManager.OpenUIByParam(UIDef.UIChrSkillInfoDialog, {
    skillData = skillData,
    gunCmdData = self.mGunCmdData,
    isGunLock = self.mGunCmdData.isLockGun,
    pos = pos,
    openFromTypeId = UIDef.UIChrScreenPanel,
    showBottomBtn = true
  })
end
function UIChrScreenPanel:AddListener()
  function self.toggleChrStateOnValueChanged(ison)
    self:ToggleChrStateOnValueChanged(ison)
  end
  self.ui.mToggle_ChrState.onValueChanged:AddListener(self.toggleChrStateOnValueChanged)
  self:AddEventListener()
end
function UIChrScreenPanel:RemoveListener()
  self.ui.mToggle_ChrState.onValueChanged:RemoveListener(self.toggleChrStateOnValueChanged)
  self:RemoveEventListener()
end
function UIChrScreenPanel:OnSwitchGun(message)
  local id = message.Sender
  self.mGunCmdData = NetCmdTeamData:GetGunByStcId(id)
  if self.mGunCmdData ~= nil then
    self.mGunData = self.mGunCmdData.TabGunData
  end
end
function UIChrScreenPanel:AddEventListener()
  function self.onSwitchGun(message)
    self:OnSwitchGun(message)
  end
  MessageSys:AddListener(CS.GF2.Message.FacilityBarrackEvent.OnSwitchGun, self.onSwitchGun)
  function self.updateModelCallback(message)
    self:UpdateModelCallback(message.Sender)
  end
  MessageSys:AddListener(CS.GF2.Message.FacilityBarrackEvent.UpdateModelCallback, self.updateModelCallback)
end
function UIChrScreenPanel:RemoveEventListener()
  MessageSys:RemoveListener(CS.GF2.Message.FacilityBarrackEvent.OnSwitchGun, self.onSwitchGun)
  if self.updateModelCallback ~= nil then
    MessageSys:RemoveListener(CS.GF2.Message.FacilityBarrackEvent.UpdateModelCallback, self.updateModelCallback)
    self.updateModelCallback = nil
  end
end
