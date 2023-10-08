require("UI.WeaponPanel.WeaponV4.Item.ChrWeaponItemV4")
require("UI.WeaponPanel.WeaponV4.Item.ChrWeaponAttributeListItemV4")
require("UI.WeaponPanel.WeaponV4.Item.ChrPolarityItem")
require("UI.Common.UICommonLockItem")
require("UI.WeaponPanel.UIWeaponPanel")
require("UI.MessageBox.MessageBoxPanel")
UIWeaponOverviewPanelV4 = class("UIWeaponOverviewPanelV4", UIBasePanel)
UIWeaponOverviewPanelV4.__index = UIWeaponOverviewPanelV4
function UIWeaponOverviewPanelV4:ctor(root, uiChrWeaponPanelV4)
  self.mUIRoot = root
  self.uiChrWeaponPanelV4 = uiChrWeaponPanelV4
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.replaceBtnRedPoint = self.ui.mObj_RedPoint
  self.powerUpBtnRedPoint = self.ui.mBtn_PowerUp.gameObject.transform:Find("Root/Trans_RedPoint")
  self.breakBtnRedPoint = self.ui.mBtn_Break.gameObject.transform:Find("Root/Trans_RedPoint")
  self.gunCmdData = nil
  self.weaponCmdData = nil
  self.curSelectWeaponCmdData = nil
  self.comScreenItemV2 = nil
  self.weaponReplaceList = nil
  self.curWeaponItem = nil
  self.curClickWeaponItemId = 0
  self.chrPolarityItemList = {}
  self.newGunWeaponId = 0
  self.isCompose = false
  self.itemData = nil
  self.isComposeBack = false
  self.isOpenWeaponManage = false
  self.weaponManageUnlockData = nil
  self.ToggleHintStr = {}
  self.isComposeEnough = false
  self.gfToggleTimer = nil
  self.isShowReplaceList = false
end
function UIWeaponOverviewPanelV4:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
end
function UIWeaponOverviewPanelV4:OnInit(data)
  self.ToggleHintStr[1] = TableData.GetHintById(220072)
  self.ToggleHintStr[2] = TableData.GetHintById(220073)
  self.ui.mText_Toggle.text = self.ToggleHintStr[1]
  self.weaponCmdData = data
  self.curSelectWeaponCmdData = data
  self.gunCmdData = self.uiChrWeaponPanelV4.gunCmdData
  UIUtils.GetButtonListener(self.ui.mBtn_Exclusive.gameObject).onClick = function()
    self:OnClickExclusive()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_SpecialEffect.gameObject).onClick = function()
    self:OnClickSpecialEffect()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Root.gameObject).onClick = function()
    self:OnClickReplace(true)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_PowerUp.gameObject).onClick = function()
    self:OnClickPowerUpBtn(UIWeaponGlobal.WeaponPowerUpContentTypeV4.LevelUp)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Break.gameObject).onClick = function()
    self:OnClickPowerUpBtn(UIWeaponGlobal.WeaponPowerUpContentTypeV4.Break)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnCantLvUp.gameObject).onClick = function()
    if TipsManager.NeedLockTips(SystemList.WeaponUpgrade) then
      return
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnCantBreak.gameObject).onClick = function()
    if TipsManager.NeedLockTips(SystemList.WeaponClass) then
      return
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBreak.gameObject).onClick = function()
    self:OnClickReplaceBtn()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    MessageSys:SendMessage(CS.GF2.Message.FacilityBarrackEvent.OnChangeWeapon, self.weaponCmdData.id)
    self.curSelectWeaponCmdData = self.weaponCmdData
    self:OnClickReplace(false)
    self:SetWeaponData()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self.ui.mToggle_Contrast.isOn = false
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Detail.gameObject).onClick = function()
    self:OnClickDetail()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Mix.gameObject).onClick = function()
    self:OnClickMix()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_LevelUpConsume.gameObject).onClick = function()
    self:OnClickConsume()
  end
  self.isCompose = self.uiChrWeaponPanelV4.isCompose
  if not self.isCompose then
    self:InitWeaponToucherEvent()
    if self.uiChrWeaponPanelV4.needReplaceBtn then
      self:InitVirtualList()
    end
    ComPropsDetailsHelper:InitComPropsDetailsItemObjNum(2)
    self.ui.mToggle_Contrast.onValueChanged:AddListener(function(isOn)
      self:OnClickGFToggle(isOn)
    end)
    self:InitChrPolarityItemObj()
  end
end
function UIWeaponOverviewPanelV4:Show(isShow)
  self.mIsRelatedBP = self.uiChrWeaponPanelV4.openFromType == UIWeaponPanel.OpenFromType.BattlePass or self.uiChrWeaponPanelV4.openFromType == UIWeaponPanel.OpenFromType.BattlePassCollection
  self.super.Show(self, isShow)
  if isShow then
    self:InitWeaponToucherEvent()
    self:AddListener()
  else
    UIWeaponGlobal:ReleaseWeaponToucherEvent()
    self:OnClickGFToggle(false)
    if self.gfToggleTimer ~= nil then
      self.gfToggleTimer:Stop()
    end
    self:RemoveListener()
    self:OnClose()
  end
end
function UIWeaponOverviewPanelV4:OnShowStart()
  self:SetWeaponData()
  if self.comScreenItemV2 ~= nil then
    self.weaponReplaceList = NetCmdWeaponData:GetAllReplaceWeaponCmdDatasListByGunId(self.weaponCmdData.gun_id)
    self.comScreenItemV2:SetList(self.weaponReplaceList)
    self.comScreenItemV2:DoFilter()
    self:UpdateReplaceList()
    return
  end
end
function UIWeaponOverviewPanelV4:OnRecover()
  if self.comScreenItemV2 ~= nil then
    self.weaponReplaceList = NetCmdWeaponData:GetAllReplaceWeaponCmdDatasListByGunId(self.weaponCmdData.gun_id)
    self.comScreenItemV2:SetList(self.weaponReplaceList)
    self.comScreenItemV2:DoFilter()
    self:UpdateReplaceList()
    return
  end
  self:SetWeaponData()
end
function UIWeaponOverviewPanelV4:OnBackFrom()
  self:SetWeaponData()
  if self.isComposeBack then
    self:ComposeCallback()
    self.isComposeBack = false
  end
  if self.comScreenItemV2 ~= nil then
    self.weaponReplaceList = NetCmdWeaponData:GetAllReplaceWeaponCmdDatasListByGunId(self.weaponCmdData.gun_id)
    self.comScreenItemV2:SetList(self.weaponReplaceList)
    self.comScreenItemV2:DoFilter()
    self:UpdateReplaceList()
    return
  end
end
function UIWeaponOverviewPanelV4:OnTop()
end
function UIWeaponOverviewPanelV4:OnShowFinish()
end
function UIWeaponOverviewPanelV4:OnHide()
end
function UIWeaponOverviewPanelV4:OnHideFinish()
  if self.comScreenItemV2 then
    self.comScreenItemV2:OnRelease()
    self.comScreenItemV2 = nil
  end
  if self.curWeaponItem ~= nil then
    self.curWeaponItem:SetItemSelect(false)
  end
  self.curWeaponItem = nil
  self.curSelectWeaponCmdData = nil
end
function UIWeaponOverviewPanelV4:OnClose()
  self.curClickWeaponItemId = 0
end
function UIWeaponOverviewPanelV4:OnRelease()
  self.super.OnRelease(self)
  for i, v in ipairs(self.chrPolarityItemList) do
    v:OnRelease()
  end
end
function UIWeaponOverviewPanelV4:InitVirtualList()
  function self.itemProvider()
    return self:ItemProvider()
  end
  function self.itemRenderer(index, itemData)
    self:ItemRenderer(index, itemData)
  end
  if self.uiChrWeaponPanelV4.openFromType ~= UIWeaponPanel.OpenFromType.BattlePass and self.uiChrWeaponPanelV4.openFromType ~= UIWeaponPanel.OpenFromType.BattlePassCollection then
    self.weaponReplaceList = NetCmdWeaponData:GetAllReplaceWeaponCmdDatasListByGunId(self.curSelectWeaponCmdData.gun_id)
    self.ui.mVirtualListEx_GrpList.itemProvider = self.itemProvider
    self.ui.mVirtualListEx_GrpList.itemRenderer = self.itemRenderer
  end
end
function UIWeaponOverviewPanelV4:ItemProvider()
  local itemView = ChrWeaponItemV4.New()
  itemView:InitCtrl(self.ui.mScrollListChild_Content1)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIWeaponOverviewPanelV4:ItemRenderer(index, renderData)
  local data = self.weaponReplaceList[index]
  local item = renderData.data
  item:SetWeaponData(data, function(tempItem)
    self:OnClickWeaponItem(tempItem)
  end)
  local isCurEquip = item.weaponCmdData.id == self.weaponCmdData.id
  item:SetItemSelect(false)
  item:SetNowEquip(isCurEquip)
  if isCurEquip then
    item:SetGunEquipped(false)
  else
    item:SetGunEquipped(item.weaponCmdData.gun_id ~= 0)
  end
  if self.curClickWeaponItemId ~= 0 and item.weaponCmdData.id == self.curClickWeaponItemId then
    self:OnClickWeaponItem(item)
  elseif self.curWeaponItem == nil and isCurEquip then
    self:OnClickWeaponItem(item)
  end
  local go = item:GetRoot().gameObject
  local itemId = data.stc_id
  MessageSys:SendMessage(GuideEvent.VirtualListRendererChanged, VirtualListRendererChangeData(go, itemId, index))
end
function UIWeaponOverviewPanelV4:OnClickWeaponItem(item)
  self.curSelectWeaponCmdData = item.weaponCmdData
  MessageSys:SendMessage(CS.GF2.Message.FacilityBarrackEvent.OnChangeWeapon, self.curSelectWeaponCmdData.id)
  self:SetWeaponData()
  if self.curWeaponItem ~= nil then
    self.curWeaponItem:SetItemSelect(false)
  end
  self.curWeaponItem = item
  self.curWeaponItem:SetItemSelect(true)
  self.curClickWeaponItemId = self.curWeaponItem.weaponCmdData.id
  if self.curWeaponItem.weaponCmdData.id == self.weaponCmdData.id and self.ui.mToggle_Contrast.isOn then
    self.ui.mToggle_Contrast.isOn = false
  end
  if self.ui.mToggle_Contrast.isOn then
    ComPropsDetailsHelper:InitWeaponData(self.ui.mTrans_NowSel.transform, self.curSelectWeaponCmdData.id, 0)
  end
end
function UIWeaponOverviewPanelV4:SetWeaponData()
  self.weaponManageUnlockData = NetCmdWeaponData:GetFirstUnlockData()
  self.isOpenWeaponManage = self.weaponManageUnlockData == nil
  if self.curSelectWeaponCmdData == nil then
    self.curSelectWeaponCmdData = self.weaponCmdData
  end
  self.ui.mText_WeaponName.text = self.curSelectWeaponCmdData.Name
  self.ui.mText_Name.text = self.curSelectWeaponCmdData.Name
  local weaponTypeData = TableData.listGunWeaponTypeDatas:GetDataById(self.curSelectWeaponCmdData.Type)
  self.ui.mText_WeaponType.text = weaponTypeData.Name.str
  self.ui.mImg_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(self.curSelectWeaponCmdData.Rank)
  self.ui.mImg_Icon.sprite = IconUtils.GetWeaponSprite(self.curSelectWeaponCmdData.StcData.res_code)
  self.ui.mText_WeaponQuality.text = TableData.GetHintById(220055 + self.curSelectWeaponCmdData.Rank)
  self.ui.mText_WeaponQuality.color = TableData.GetGlobalGun_Quality_Color2(self.curSelectWeaponCmdData.Rank)
  self.ui.mText_NumNow.text = GlobalConfig.SetLvText(self.curSelectWeaponCmdData.Level)
  self.ui.mText_Max.text = "/" .. self.curSelectWeaponCmdData.DefaultMaxLevel
  setactive(self.ui.mTrans_BreakLv.gameObject, self.curSelectWeaponCmdData.BreakTimes ~= 0 and not self.mIsRelatedBP)
  if self.curSelectWeaponCmdData.BreakTimes ~= 0 then
    UIWeaponGlobal.SetBreakTimesImg(self.ui.mImg_Num, self.curSelectWeaponCmdData.BreakTimes, self.curSelectWeaponCmdData.MaxBreakTime)
  else
    UIWeaponGlobal.SetBreakTimesImg(self.ui.mImg_Num, 1, self.curSelectWeaponCmdData.MaxBreakTime)
  end
  self:AddAsset(self.ui.mImg_Num.sprite)
  self.isCompose = self.uiChrWeaponPanelV4.isCompose
  self.ui.mGFUIGroupList_Overview:ChangeUIComponentGroups("Unlock", not self.isCompose)
  self.ui.mGFUIGroupList_Overview:ChangeUIComponentGroups("Lock", self.isCompose)
  self.uiChrWeaponPanelV4:CheckTouchPad()
  setactive(self.ui.mTrans_LvOpen, not self.mIsRelatedBP and not self.isCompose)
  gfwarning(tostring(self.uiChrWeaponPanelV4.openFromType == UIWeaponPanel.OpenFromType.GachaPreview))
  if self.mIsRelatedBP or self.uiChrWeaponPanelV4.openFromType == UIWeaponPanel.OpenFromType.GachaPreview then
    setactive(self.ui.mBtn_PowerUp.transform.parent.gameObject, false)
    setactive(self.ui.mBtn_Break.transform.parent.gameObject, false)
    setactive(self.ui.mBtn_BtnCantLvUp.gameObject, false)
    setactive(self.ui.mBtn_BtnCantBreak.gameObject, false)
  else
    local unlockWeaponUpgrade = AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.WeaponUpgrade)
    local unlockWeaponClass = AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.WeaponClass)
    setactive(self.ui.mBtn_PowerUp.transform.parent.gameObject, unlockWeaponUpgrade)
    setactive(self.ui.mBtn_Break.transform.parent.gameObject, unlockWeaponClass)
    setactive(self.ui.mBtn_BtnCantLvUp.gameObject, not unlockWeaponUpgrade and self.isOpenWeaponManage)
    setactive(self.ui.mBtn_BtnCantBreak.gameObject, not unlockWeaponClass and self.isOpenWeaponManage)
  end
  if not self.isCompose then
    setactive(self.ui.mToggle_Contrast.gameObject, self.weaponCmdData.id ~= self.curSelectWeaponCmdData.id)
    self:UpdateRedPoint()
    if self.uiChrWeaponPanelV4.needReplaceBtn then
      self:UpdateWeaponScreen()
    end
    self:UpdateWeaponParts()
    self:UpdateWeaponCapacity()
  else
    self.newGunWeaponId = 0
    self:UpdateConsume()
  end
  self:UpdateExclusive()
  self:UpdateAction()
  self:UpdateSkill()
  self:UpdateAttribute()
  self:UpdateBpType()
end
function UIWeaponOverviewPanelV4:UpdateBpType()
  setactive(self.ui.mTrans_BpRoot, false)
  if self.openFromType == UIWeaponPanel.OpenFromType.BattlePass then
    setactive(self.ui.mTrans_BpRoot, true)
    local status = NetCmdBattlePassData.BattlePassStatus
    local isBuyBp = status == CS.ProtoObject.BattlepassType.AdvanceTwo or status == CS.ProtoObject.BattlepassType.AdvanceOne
    local isFullBpLevel = NetCmdBattlePassData.BattlePassLevel == NetCmdBattlePassData.CurSeason.max_level
    setactive(self.ui.mTrans_BPToGet, isBuyBp and not isFullBpLevel)
    setactive(self.ui.mTrans_BpLocked.transform, not isBuyBp)
    local isMaxRewardGet = NetCmdBattlePassData.IsMaxRewardGet
    setactive(self.ui.mTrans_BPHasReceied, isFullBpLevel and isMaxRewardGet)
    setactive(self.ui.mBtn_Receive.transform.parent, isFullBpLevel and not isMaxRewardGet and isBuyBp)
    UIUtils.GetButtonListener(self.ui.mBtn_Receive.gameObject).onClick = function()
      NetCmdBattlePassData:SendGetBattlepassReward(NetCmdBattlePassData.BattlePassStatus, NetCmdBattlePassData.BattlePassStatus, CS.ProtoCsmsg.BpRewardGetType.GetTypeNone, function(ret)
        if ret == ErrorCodeSuc then
          MessageSys:SendMessage(UIEvent.BpGetReward, nil)
          UIManager.OpenUI(UIDef.UICommonReceivePanel)
          self:UpdateBpType()
        end
      end)
    end
  else
    setactive(self.ui.mTrans_BpRoot, false)
  end
end
function UIWeaponOverviewPanelV4:UpdateWeaponParts()
  if self.uiChrWeaponPanelV4.openFromType == UIWeaponPanel.OpenFromType.BattlePass or self.uiChrWeaponPanelV4.openFromType == UIWeaponPanel.OpenFromType.BattlePassCollection or self.uiChrWeaponPanelV4.openFromType == UIWeaponPanel.OpenFromType.GachaPreview then
    return
  end
  local slotList = self.curSelectWeaponCmdData.slotList
  for i = 1, UIWeaponGlobal.WeaponMaxSlot do
    setactive(self.ui["mScrollListChild_GrpParts" .. i].gameObject, false)
  end
  if not AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.WeaponPolarity) then
    return
  end
  self.chrPolarityItemList = {}
  for i = 1, slotList.Count do
    if i <= UIWeaponGlobal.WeaponMaxSlot then
      do
        local partObj = self.ui["mScrollListChild_GrpParts" .. i].gameObject
        setactive(partObj, true)
        local item = ChrPolarityItem.New()
        local obj
        if partObj.transform.childCount > 0 then
          obj = partObj.transform:GetChild(0).gameObject
        end
        local weaponPartType = self.curSelectWeaponCmdData:GetWeaponPartTypeBySlotIndex(i - 1)
        local weaponPart = self.curSelectWeaponCmdData:GetWeaponPartByType(i - 1)
        local polarityTagData = self.curSelectWeaponCmdData:GetPolarityTagDataByIndex(i - 1)
        item:InitCtrl(partObj, weaponPartType, obj)
        item:SetWeaponPartData(polarityTagData, weaponPart)
        item:SetBtnEnabled(false)
        UIUtils.GetButtonListener(item.ui.mBtn_ChrPolarityItem.gameObject).onClick = function()
          self:OnClickReplacePart(i)
        end
        table.insert(self.chrPolarityItemList, item)
      end
    end
  end
end
function UIWeaponOverviewPanelV4:InitChrPolarityItemObj()
  for i = 1, UIWeaponGlobal.WeaponMaxSlot do
    local partObj = self.ui["mScrollListChild_GrpParts" .. i].gameObject
    setactive(partObj, false)
    local obj
    if partObj.transform.childCount == 0 then
      local itemPrefab = partObj:GetComponent(typeof(CS.ScrollListChild))
      obj = instantiate(itemPrefab.childItem)
      CS.LuaUIUtils.SetParent(obj.gameObject, partObj.gameObject, false)
    end
  end
end
function UIWeaponOverviewPanelV4:OnClickReplacePart(index)
  local param = {
    weaponCmdData = self.weaponCmdData,
    curSlotIndex = index
  }
  UIManager.OpenUIByParam(UIDef.UIChrWeaponPartsReplacePanel, param)
end
function UIWeaponOverviewPanelV4:UpdateRedPoint()
  if self.uiChrWeaponPanelV4.openFromType == UIWeaponPanel.OpenFromType.BattlePass or self.uiChrWeaponPanelV4.openFromType == UIWeaponPanel.OpenFromType.BattlePassCollection then
    setactive(self.replaceBtnRedPoint.gameObject, false)
    return
  end
  if self.curSelectWeaponCmdData ~= nil then
    local redPoint = 0
    if self.curSelectWeaponCmdData.gun_id ~= 0 then
      redPoint = NetCmdWeaponData:UpdateWeaponCanChangeRedPoint(self.curSelectWeaponCmdData.id, self.curSelectWeaponCmdData.gun_id)
    end
    self.redPointCount = redPoint
    setactive(self.replaceBtnRedPoint.gameObject, 0 < redPoint)
    setactive(self.replaceBtnRedPoint.transform.parent.gameObject, 0 < redPoint)
    local canPowerUp = 0 < NetCmdWeaponData:UpdateWeaponCanEnhanceRedPoint(self.curSelectWeaponCmdData.id)
    local canBreak = 0 < NetCmdWeaponData:UpdateWeaponCanBreakRedPoint(self.curSelectWeaponCmdData.id)
    setactive(self.powerUpBtnRedPoint.gameObject, canPowerUp)
    setactive(self.breakBtnRedPoint.gameObject, canBreak)
  end
end
function UIWeaponOverviewPanelV4:UpdateExclusive()
  setactive(self.ui.mBtn_Exclusive.gameObject, self.curSelectWeaponCmdData.StcData.private_skill ~= 0 and self.curSelectWeaponCmdData.CharacterData ~= nil)
  local isPrivate = self.curSelectWeaponCmdData:CheckPrivateWeapon(self.weaponCmdData.gun_id)
  self.ui.mAnimator_Exclusive:SetBool("Activated", isPrivate)
end
function UIWeaponOverviewPanelV4:UpdateSkill()
  local data = self.curSelectWeaponCmdData.Skill
  setactive(self.ui.mTrans_WeaponSkill, data ~= nil)
  if data then
    self.ui.mText_SkillName.text = data.name.str
    self.ui.mTextFit_Describe.text = data.description.str
    self.ui.mText_Lv.text = GlobalConfig.SetLvText(data.Level)
  end
  self.ui.mTextFit_Describe1.text = self.curSelectWeaponCmdData.StcData.Description.str
end
function UIWeaponOverviewPanelV4:UpdateWeaponCapacity()
  self.uiChrWeaponPanelV4:UpdateWeaponCapacity()
end
function UIWeaponOverviewPanelV4:UpdateAttribute()
  local attrList = {}
  local tmpWeaponCmdData = self.curSelectWeaponCmdData
  local expandList = TableData.GetPropertyExpandList()
  for i = 0, expandList.Count - 1 do
    local lanData = expandList[i]
    local value = tmpWeaponCmdData:GetWeaponValueByName(lanData.sys_name)
    if 0 < value then
      local attr = {}
      attr.propData = lanData
      attr.value = value
      table.insert(attrList, attr)
    end
  end
  table.sort(attrList, function(a, b)
    return a.propData.order < b.propData.order
  end)
  local tmpAttrParent = self.ui.mTrans_Attribute.transform
  setactive(tmpAttrParent.gameObject, false)
  setactive(tmpAttrParent.gameObject, true)
  for i = 1, 5 do
    local item
    item = ChrWeaponAttributeListItemV4.New()
    if i <= tmpAttrParent.childCount then
      item:InitCtrl(tmpAttrParent.gameObject, tmpAttrParent:GetChild(i - 1))
    else
      local tmpItem = instantiate(self.ui.mTrans_AttributeItem1)
      item:InitCtrl(tmpAttrParent.gameObject, tmpItem)
    end
    local index = 6 - i
    if index <= #attrList then
      item:SetData(attrList[index].propData, attrList[index].value)
    else
      item:SetData(nil)
    end
  end
end
function UIWeaponOverviewPanelV4:UpdateAction()
  if self.gunCmdData == nil then
    setactive(self.ui.mTrans_Equiped.gameObject, false)
    setactive(self.ui.mBtn_BtnBreak.gameObject, false)
  else
    local isCurWeapon = self.gunCmdData.WeaponId == self.curSelectWeaponCmdData.id
    setactive(self.ui.mTrans_Equiped.gameObject, isCurWeapon)
    setactive(self.ui.mBtn_BtnBreak.gameObject, not isCurWeapon and not self.mIsRelatedBP)
  end
  setactive(self.ui.mTrans_Locked.gameObject, not self.isOpenWeaponManage and not self.mIsRelatedBP and not self.isCompose)
  if not self.isOpenWeaponManage then
    if self.weaponManageUnlockData == nil then
      self.weaponManageUnlockData = AccountNetCmdHandler:GetUnlockDataBySystemId(SystemList.WeaponManage)
    end
    local str = UIUtils.CheckUnlockPopupStr(self.weaponManageUnlockData)
    self.ui.mText_LockedName.text = str
  end
  setactive(self.ui.mBtn_BtnBreak.transform.parent, not self.mIsRelatedBP)
  setactive(self.ui.mBtn_Root.gameObject, self.uiChrWeaponPanelV4.needReplaceBtn)
  self.uiChrWeaponPanelV4:ActiveChrChangeBtn(self.uiChrWeaponPanelV4.needReplaceBtn and not self.isShowReplaceList)
  setactive(self.uiChrWeaponPanelV4.ui.mTrans_Arrow.gameObject, self.uiChrWeaponPanelV4.needReplaceBtn and not self.isShowReplaceList)
end
function UIWeaponOverviewPanelV4:UpdateConsume()
  local mapField = self.weaponCmdData.StcData.unlock_cost
  local costItemId, costValue
  for i, v in pairs(mapField) do
    costItemId = i
    costValue = v
  end
  self.itemData = TableData.GetItemData(costItemId)
  local itemOwnNum = NetCmdItemData:GetItemCountById(costItemId)
  local itemOwnNumShow = CS.LuaUIUtils.GetNumberText(itemOwnNum)
  self.ui.mImg_Item.sprite = IconUtils.GetItemIconSprite(costItemId)
  self.isComposeEnough = costValue <= itemOwnNum
  if costValue <= itemOwnNum then
    self.ui.mText_Num.text = itemOwnNumShow .. "/" .. costValue
  else
    self.ui.mText_Num.text = "<color=red>" .. itemOwnNumShow .. "</color>/" .. costValue
  end
end
function UIWeaponOverviewPanelV4:UpdateWeaponScreen()
  if self.weaponCmdData.gun_id == 0 then
    return
  end
  if self.comScreenItemV2 ~= nil then
    return
  end
  self.comScreenItemV2 = ComScreenItemHelper:InitWeapon(self.ui.mScrollListChild_GrpScreen.gameObject, self.weaponReplaceList, function()
    self:UpdateReplaceList()
  end, nil)
  self.comScreenItemV2.IsDown = false
  self.comScreenItemV2:SetFilterBtnShow(false)
end
function UIWeaponOverviewPanelV4:UpdateReplaceList()
  if self.comScreenItemV2 == nil then
    return
  end
  self.comScreenItemV2:DoSort()
  local tmpResultList = self.comScreenItemV2:GetResultList()
  self.weaponReplaceList = tmpResultList
  if self.curWeaponItem ~= nil then
    self.curWeaponItem:SetItemSelect(false)
  end
  for i = 0, self.weaponReplaceList.Count - 1 do
    local weaponCmdData = self.weaponReplaceList[i]
    if weaponCmdData.id == self.weaponCmdData.id then
      self.weaponReplaceList:RemoveAt(i)
      self.weaponReplaceList:Insert(0, weaponCmdData)
    end
  end
  local itemDataList = LuaUtils.ConvertToItemIdList(self.weaponReplaceList)
  self.ui.mVirtualListEx_GrpList:SetItemIdList(itemDataList)
  self.ui.mVirtualListEx_GrpList.numItems = self.weaponReplaceList.Count
  self.ui.mVirtualListEx_GrpList:Refresh()
end
function UIWeaponOverviewPanelV4:OnClickExclusive()
  if nil == self.curSelectWeaponCmdData then
    self.curSelectWeaponCmdData = self.weaponCmdData
  end
  local name = self.curSelectWeaponCmdData.CharacterData.name.str
  local weaponPrivateName = string_format(TableData.GetHintById(220006), name)
  local battleSkillDisplayData = TableData.listBattleSkillDisplayDatas:GetDataById(self.curSelectWeaponCmdData.StcData.private_skill)
  local desc = battleSkillDisplayData.description.str
  local data = {
    [1] = weaponPrivateName,
    [2] = desc
  }
  UIManager.OpenUIByParam(UIDef.SimpleMessageBoxPanel, data)
end
function UIWeaponOverviewPanelV4:OnClickSpecialEffect()
  local param = {
    weaponCmdData = self.curSelectWeaponCmdData
  }
  UIManager.OpenUIByParam(UIDef.UIChrSpecialEffectDialog, param)
end
function UIWeaponOverviewPanelV4:OnClickReplace(boolean)
  self.isShowReplaceList = boolean
  self.uiChrWeaponPanelV4.isShowReplaceList = boolean
  self.uiChrWeaponPanelV4:ActiveChrChangeBtn(not boolean)
  if boolean then
    self:UpdateReplaceList()
    self.uiChrWeaponPanelV4.ui.mAnimator_Root:ResetTrigger("FadeIn")
    self.uiChrWeaponPanelV4.ui.mAnimator_Root:SetTrigger("FadeOut")
    self.ui.mAnimator_ChrWeaponOverviewItem:ResetTrigger("WeaponList_FadeOut")
    self.ui.mAnimator_ChrWeaponOverviewItem:SetTrigger("WeaponList_FadeIn")
    self.uiChrWeaponPanelV4.ui.mAnimator_WeaponInfo:ResetTrigger("WeaponList_FadeOut")
    self.uiChrWeaponPanelV4.ui.mAnimator_WeaponInfo:SetTrigger("WeaponList_FadeIn")
    self.ui.mVirtualListEx_GrpList.horizontalNormalizedPosition = 0
    self.uiChrWeaponPanelV4:SetEscapeEnabled(true, self.ui.mBtn_Back)
    UIBarrackWeaponModelManager:EnterReplaceView()
  else
    self.uiChrWeaponPanelV4.ui.mAnimator_Root:ResetTrigger("FadeOut")
    self.uiChrWeaponPanelV4.ui.mAnimator_Root:SetTrigger("FadeIn")
    self.ui.mAnimator_ChrWeaponOverviewItem:ResetTrigger("WeaponList_FadeIn")
    self.ui.mAnimator_ChrWeaponOverviewItem:SetTrigger("WeaponList_FadeOut")
    self.uiChrWeaponPanelV4.ui.mAnimator_WeaponInfo:ResetTrigger("WeaponList_FadeIn")
    self.uiChrWeaponPanelV4.ui.mAnimator_WeaponInfo:SetTrigger("WeaponList_FadeOut")
    self.uiChrWeaponPanelV4:SetEscapeEnabled(true)
    if self.ui.mToggle_Contrast.isOn then
      self.ui.mToggle_Contrast.isOn = false
    end
    if self.curWeaponItem ~= nil then
      self.curWeaponItem:SetItemSelect(false)
      self.curWeaponItem = nil
    end
    self.curClickWeaponItemId = 0
    UIBarrackWeaponModelManager:ExitReplaceView()
  end
  setactive(self.uiChrWeaponPanelV4.ui.mTrans_Arrow.gameObject, self.uiChrWeaponPanelV4.needReplaceBtn and not self.isShowReplaceList)
end
function UIWeaponOverviewPanelV4:OnClickPowerUpBtn(targetContent)
  if targetContent == nil then
    targetContent = 1
  end
  local param = {
    [1] = self.weaponCmdData,
    [2] = targetContent,
    [3] = self.uiChrWeaponPanelV4.openFromType
  }
  UIManager.OpenUIByParam(UIDef.UIChrWeaponPowerUpPanelV4, param)
end
function UIWeaponOverviewPanelV4:OnClickReplaceBtn()
  if self.curSelectWeaponCmdData.gun_id ~= 0 then
    local gunName2 = TableData.listGunDatas:GetDataById(self.curSelectWeaponCmdData.gun_id).name.str
    MessageBoxPanel.ShowDoubleType(string_format(TableData.GetHintById(40015), gunName2), function()
      self:OnReplaceWeapon()
    end)
  else
    self:OnReplaceWeapon()
  end
end
function UIWeaponOverviewPanelV4:OnReplaceWeapon()
  local tmpWeaponCmdData = self.curSelectWeaponCmdData
  NetCmdWeaponData:SendGunWeaponBelong(tmpWeaponCmdData.id, self.gunCmdData.Id, function(ret)
    if ret == ErrorCodeSuc then
      MessageSys:SendMessage(CS.GF2.Message.FacilityBarrackEvent.OnChangeWeapon, tmpWeaponCmdData.id)
      UIUtils.PopupPositiveHintMessage(220013)
      self.weaponCmdData = tmpWeaponCmdData
      self.ui.mToggle_Contrast.isOn = false
      self.curSelectWeaponCmdData = self.weaponCmdData
      self.gunCmdData = self.uiChrWeaponPanelV4.gunCmdData
      self:OnClickReplace(false)
      self:SetWeaponData()
      self.uiChrWeaponPanelV4:SetWeaponData()
    end
  end)
end
function UIWeaponOverviewPanelV4:OnClickDetail()
  local param = {
    attributeShowType = FacilityBarrackGlobal.AttributeShowType.Weapon,
    weaponCmdData = self.curSelectWeaponCmdData
  }
  UIManager.OpenUIByParam(UIDef.UIChrAttributeDetailsDialogV3, param)
end
function UIWeaponOverviewPanelV4:InitWeaponToucherEvent()
  UIWeaponGlobal:ReleaseWeaponToucherEvent()
  UIWeaponGlobal:SetWeaponToucherBeginCallback(function()
    self.uiChrWeaponPanelV4.ui.mAnimator_Root:SetBool("Visual", true)
    setactive(self.uiChrWeaponPanelV4.ui.mTrans_Arrow.gameObject, false)
  end)
  UIWeaponGlobal:SetWeaponToucherEndCallback(function()
    self.uiChrWeaponPanelV4.ui.mAnimator_Root:SetBool("Visual", false)
    setactive(self.uiChrWeaponPanelV4.ui.mTrans_Arrow.gameObject, self.uiChrWeaponPanelV4.needReplaceBtn and not self.isShowReplaceList)
  end)
  UIWeaponGlobal:InitWeaponToucherEvent()
end
function UIWeaponOverviewPanelV4:SetCanvasGroup(canvasGroup, isShow)
  if isShow then
    canvasGroup.alpha = 1
    canvasGroup.blocksRaycasts = true
  else
    canvasGroup.alpha = 0
    canvasGroup.blocksRaycasts = false
  end
end
function UIWeaponOverviewPanelV4:OnClickMix()
  if not self.isComposeEnough then
    self:OnClickConsume()
    return
  end
  NetCmdWeaponData:SendWeaponCompose({
    self.weaponCmdData.stc_id
  }, {1}, function(ret)
    if ret == ErrorCodeSuc then
      self.isComposeBack = true
      local tmpTable = {
        {
          ItemId = self.weaponCmdData.stc_id
        }
      }
      UICommonGetGunPanel.OpenGetGunPanel(tmpTable, nil, nil, true)
    end
  end)
end
function UIWeaponOverviewPanelV4:OnClickConsume()
  UITipsPanel.Open(self.itemData, 0, true)
end
function UIWeaponOverviewPanelV4:OnClickGFToggle(isOn)
  if isOn then
    setactive(self.ui.mTrans_Compare.gameObject, isOn)
  end
  if isOn then
    self.ui.mText_Toggle.text = self.ToggleHintStr[2]
    ComPropsDetailsHelper:InitWeaponData(self.ui.mTrans_NowSel.transform, self.curSelectWeaponCmdData.id, 0)
    ComPropsDetailsHelper:InitWeaponData(self.ui.mTrans_Setted.transform, self.weaponCmdData.id, 1)
    self.uiChrWeaponPanelV4:SetEscapeEnabled(true, self.ui.mBtn_Close)
  else
    self.ui.mText_Toggle.text = self.ToggleHintStr[1]
    self:SetInputActive(false)
    self.ui.mAnimator_Compare:SetTrigger("FadeOut")
    local length = CSUIUtils.GetClipLengthByEndsWith(self.ui.mAnimator_Compare, "FadeOut")
    if self.gfToggleTimer ~= nil then
      self.gfToggleTimer:Stop()
    end
    self.gfToggleTimer = TimerSys:DelayCall(length, function()
      ComPropsDetailsHelper:Close(0)
      ComPropsDetailsHelper:Close(1)
      self.uiChrWeaponPanelV4:SetEscapeEnabled(true, self.ui.mBtn_Back)
      self:SetInputActive(true)
      setactive(self.ui.mTrans_Compare.gameObject, isOn)
    end)
  end
end
function UIWeaponOverviewPanelV4:SwitchGun(gunCmdData, isShow)
  self.gunCmdData = gunCmdData
  self.weaponCmdData = gunCmdData.WeaponData
  self.curSelectWeaponCmdData = self.weaponCmdData
  self:OnShowStart()
end
function UIWeaponOverviewPanelV4:ComposeCallback()
  if self.newGunWeaponId == 0 then
    UIManager.CloseUI(UIDef.UIWeaponPanel)
  else
    self.uiChrWeaponPanelV4:OnShowStart()
    self:SetWeaponData()
  end
end
function UIWeaponOverviewPanelV4:AddListener()
  function self.newGunWeapon(message)
    local id = message.Sender
    self.newGunWeaponId = id
    if self.isCompose then
      self.uiChrWeaponPanelV4:OnInit(nil, {
        id,
        nil,
        nil,
        UIWeaponPanel.OpenFromType.Repository
      })
    end
  end
  MessageSys:AddListener(CS.GF2.Message.FacilityBarrackEvent.NewGunWeapon, self.newGunWeapon)
end
function UIWeaponOverviewPanelV4:RemoveListener()
  MessageSys:RemoveListener(CS.GF2.Message.FacilityBarrackEvent.NewGunWeapon, self.newGunWeapon)
end
