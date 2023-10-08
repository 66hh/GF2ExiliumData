require("UI.StoreExchangePanel.UIStoreGlobal")
require("UI.FacilityBarrackPanel.Content.UIChangeSkin.UIBarrackChangeSkinSlot")
UIBarrackChangeSkinPanel = class("UIBarrackChangeSkinPanel", UIBasePanel)
function UIBarrackChangeSkinPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Is3DPanel = true
end
function UIBarrackChangeSkinPanel:OnAwake(root, gunId)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnBack.gameObject, function()
    self:onClickBack()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnHome.gameObject, function()
    self:onClickHome()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_PreGun.gameObject, function()
    self:onClickLeftArrow()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_NextGun.gameObject, function()
    self:onClickRightArrow()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Item.gameObject, function()
    self:onClickItem()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_GrpConsume.gameObject, function()
    self:onClickConsume()
  end)
  setactivewithcheck(self.ui.mBtn_BtnBuy.transform.parent, true)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnBuy.gameObject, function()
    self:onClickBuy()
  end)
  setactivewithcheck(self.ui.mBtn_BtnGotoGet.transform.parent, true)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnGotoGet.gameObject, function()
    self:onClickGotoGet()
  end)
  setactivewithcheck(self.ui.mBtn_BtnChange.transform.parent, true)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnChange.gameObject, function()
    self:onClickChangeClothes()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_SkinInfo.gameObject, function()
    local curSlot = self:getCurSlot()
    local clothesData = curSlot:GetClothesData()
    UIManager.OpenUIByParam(UIDef.UIChrSkinDescriptionDialog, clothesData)
  end)
  function self.ui.mVirtualList.itemProvider()
    return self:slotProvider()
  end
  function self.ui.mVirtualList.itemRenderer(index, renderData)
    self:slotRenderer(index, renderData)
  end
  self.ui.mVirtualList:SetConstraintCount(1)
  function self.onEndDrag(eventData)
    local value = self.ui.mVirtualList.horizontalNormalizedPosition
    if value < 0 then
      value = 0
    elseif 1 < value then
      value = 1
    end
    local index = math.floor(value * self.ui.mVirtualList.content.sizeDelta.x / (self.ui.mLayoutGroup.spacing.x + self.ui.mVirtualList.paddingWidth) + 0.5) + 1
    self:onClickSlot(index)
  end
  self.ui.mVirtualList:AddOnEndDrag(self.onEndDrag)
end
function UIBarrackChangeSkinPanel:OnInit(root, data, behaviorId)
  local id = data
  self.mShowClothes = nil
  FacilityBarrackGlobal.CurSkinShowContentType = FacilityBarrackGlobal.ShowContentType.UIChrOverview
  if data and behaviorId ~= 0 then
    id = data[0]
    if data.Length > 1 then
      FacilityBarrackGlobal.CurSkinShowContentType = data[1]
    end
    if data.Length > 2 then
      self.mShowClothes = data[2]
    end
    if data.Length > 3 then
      self.mStoreId = data[3]
    end
    self.isJumpUI = true
  end
  self.gunCmdData = NetCmdTeamData:GetGunByID(id)
  if FacilityBarrackGlobal.CurSkinShowContentType == FacilityBarrackGlobal.ShowContentType.UIBpClothes then
    self.slotTable = self:initBpSlot()
    self.curSlotIndex = 1
    self.gunCmdData = NetCmdTeamData:GetLockGunData(id, true)
  elseif FacilityBarrackGlobal.CurSkinShowContentType == FacilityBarrackGlobal.ShowContentType.UIShopClothes then
    self.slotTable = self:initShopShowSlot()
    self.curSlotIndex = 1
    self.gunCmdData = NetCmdTeamData:GetLockGunData(id, true)
  elseif FacilityBarrackGlobal.CurSkinShowContentType == FacilityBarrackGlobal.ShowContentType.UIClothesPreview then
    self.slotTable = self:initAllSlot()
    self.curSlotIndex = 1
  else
    self.slotTable = self:initAllSlot()
    self.curSlotIndex = self:getEquippedSkinSlotIndex()
  end
  setactive(self.ui.mTrans_Currency, true)
  self.isClickedHome = false
  function self.OnCloseCommonReceivePanel()
    local toppanel = UISystem:GetTopPanelUI()
    if toppanel ~= nil and toppanel.UIDefine.UIType == UIDef.UIBarrackChangeSkinPanel and self.ui ~= nil and self.mTempClothesData ~= nil then
      self:playChangeClothesAnim(self.mTempClothesData)
      self:refreshGrpBtn()
      self:refreshGunDesc()
      if FacilityBarrackGlobal.CurSkinShowContentType == FacilityBarrackGlobal.ShowContentType.UIShopClothes then
        self:UpdateShopShowClothes()
      else
        self.mTempSlot:PlayUnlockingAnim()
      end
    end
  end
  MessageSys:AddListener(UIEvent.OnCloseCommonReceivePanel, self.OnCloseCommonReceivePanel)
end
function UIBarrackChangeSkinPanel:OnShowStart()
  local isPlayAnim = FacilityBarrackGlobal.CurSkinShowContentType == FacilityBarrackGlobal.ShowContentType.UIShopClothes
  self:refresh(isPlayAnim)
  self:scrollToCurSlotIndex(false)
end
function UIBarrackChangeSkinPanel:OnBackFrom()
  SceneSys:SwitchVisible(EnumSceneType.Barrack)
  FacilityBarrackGlobal.HideEffectNum(false)
  self:refreshGrpBtn()
  self:refresh(false)
  self:refreshGunDesc()
  self:refreshSwitchArrow()
end
function UIBarrackChangeSkinPanel:OnTop()
  if FacilityBarrackGlobal.CurSkinShowContentType == FacilityBarrackGlobal.ShowContentType.UIBpClothes then
    return
  end
  if FacilityBarrackGlobal.CurSkinShowContentType == FacilityBarrackGlobal.ShowContentType.UIShopClothes then
    return
  end
end
function UIBarrackChangeSkinPanel:OnHide()
end
function UIBarrackChangeSkinPanel:OnRecover()
  local gunId = BarrackHelper.ModelMgr.GunStcDataId
  self:OnInit(nil, gunId)
end
function UIBarrackChangeSkinPanel:OnClose()
  self.gunCmdData = nil
  self.isClickedHome = nil
  self.curSlotIndex = nil
  self:ReleaseCtrlTable(self.slotTable, false)
  self.slotTable = nil
  self.isJumpUI = nil
  MessageSys:RemoveListener(UIEvent.OnCloseCommonReceivePanel, self.OnCloseCommonReceivePanel)
end
function UIBarrackChangeSkinPanel:OnRelease()
  self.ui.mVirtualList:RemoveOnEndDrag(self.onEndDrag)
  self.gunCmdData = nil
  self.ui = nil
  self.super.OnRelease(self)
end
function UIBarrackChangeSkinPanel:OnCameraStart()
  if FacilityBarrackGlobal.CurSkinShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrOverview then
    return 0.01
  end
  return 0
end
function UIBarrackChangeSkinPanel:OnCameraBack()
  if FacilityBarrackGlobal.CurSkinShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrOverview then
    return 0.01
  end
  return 0
end
function UIBarrackChangeSkinPanel:refresh(needGunClothesAnim)
  self.ui.mVirtualList.numItems = #self.slotTable
  self.ui.mVirtualList:Refresh()
  self:refreshModel(needGunClothesAnim)
  self:refreshGrpBtn()
  self:refreshGunDesc()
  self:refreshSwitchArrow()
  if FacilityBarrackGlobal.CurSkinShowContentType == FacilityBarrackGlobal.ShowContentType.UIShopClothes then
    self.ui.mText_Title.text = TableData.GetHintById(260039)
    self:UpdateShopShowClothes()
  elseif FacilityBarrackGlobal.CurSkinShowContentType == FacilityBarrackGlobal.ShowContentType.UIClothesPreview then
    self.ui.mText_Title.text = TableData.GetHintById(260039)
    self:UpdateClothesPreview()
  else
    self.ui.mText_Title.text = TableData.GetHintById(230006)
  end
  if FacilityBarrackGlobal.CurSkinShowContentType == FacilityBarrackGlobal.ShowContentType.UIBpClothes then
    self:UpdateBpClothes()
    self.ui.mText_Title.text = TableData.GetHintById(260039)
  end
end
function UIBarrackChangeSkinPanel:initAllSlot()
  local tempSlotTable = {}
  local gunData = TableDataBase.listGunDatas:GetDataById(self.gunCmdData.id)
  local tempTable = CSList2LuaTable(gunData.costume_replace)
  table.sort(tempTable, function(l, r)
    local clothesDataL = TableDataBase.listClothesDatas:GetDataById(l)
    local clothesDataR = TableDataBase.listClothesDatas:GetDataById(r)
    return clothesDataL.order < clothesDataR.order
  end)
  local curBPId = NetCmdBattlePassData:GetCurOrRecentBpId()
  if FacilityBarrackGlobal.CurSkinShowContentType == FacilityBarrackGlobal.ShowContentType.UIClothesPreview then
    local d = TableDataBase.listClothesDatas:GetDataById(self.mShowClothes)
    local skinCount = NetCmdIllustrationData:GetCountByTypeAndItemId(tonumber(GlobalConfig.ItemType.Costume), tonumber(self.mShowClothes))
    local isExistStore = false
    if d.unlock_type == 3 then
      local storeId = tonumber(d.unlock_arg)
      local storeData = NetCmdStoreData:GetStoreGoodsById(storeId)
      if storeData ~= nil then
        isExistStore = storeData.IsShowTime
      end
    end
    if d.display_config > 0 or d.display_config == 0 and (isExistStore or 0 < skinCount) then
      local bpID
      if d.display_config == 2 then
        bpID = curBPId
      end
      if bpID == nil or bpID >= d.display_arg then
        local slot = UIBarrackChangeSkinSlot.New()
        slot:SetData(self.gunCmdData, d, 1)
        slot:AddBtnClickListener(function(tempIndex)
          self:onClickSlot(tempIndex)
        end)
        table.insert(tempSlotTable, slot)
      end
    end
  else
    local index = 1
    for i, clothesId in ipairs(tempTable) do
      local d = TableDataBase.listClothesDatas:GetDataById(clothesId)
      local skinCount = NetCmdIllustrationData:GetCountByTypeAndItemId(tonumber(GlobalConfig.ItemType.Costume), tonumber(clothesId))
      local isExistStore = false
      if d.unlock_type == 3 then
        local storeId = tonumber(d.unlock_arg)
        local storeData = NetCmdStoreData:GetStoreGoodsById(storeId)
        if storeData ~= nil then
          isExistStore = storeData.IsShowTime
        end
      end
      if d.display_config > 0 or d.display_config == 0 and (isExistStore or 0 < skinCount) then
        local bpID
        if d.display_config == 2 then
          bpID = curBPId
        end
        if bpID == nil or bpID >= d.display_arg then
          local slot = UIBarrackChangeSkinSlot.New()
          slot:SetData(self.gunCmdData, d, index)
          slot:AddBtnClickListener(function(tempIndex)
            self:onClickSlot(tempIndex)
          end)
          table.insert(tempSlotTable, slot)
          index = index + 1
        end
      end
    end
  end
  return tempSlotTable
end
function UIBarrackChangeSkinPanel:initBpSlot()
  local tempSlotTable = {}
  if self.mShowClothes == nil then
    return
  end
  local d = TableDataBase.listClothesDatas:GetDataById(self.mShowClothes)
  local skinCount = NetCmdIllustrationData:GetCountByTypeAndItemId(tonumber(GlobalConfig.ItemType.Costume), tonumber(self.mShowClothes))
  local isExistStore = false
  if d.unlock_type == 3 then
    local storeId = tonumber(d.unlock_arg)
    local storeData = NetCmdStoreData:GetStoreGoodsById(storeId)
    if storeData ~= nil then
      isExistStore = storeData.IsShowTime
    end
  end
  if d.display_config > 0 or d.display_config == 0 and (isExistStore or 0 < skinCount) then
    local bpID
    if bpID == nil or bpID >= d.display_arg then
      local slot = UIBarrackChangeSkinSlot.New()
      slot:SetData(self.gunCmdData, d, 1)
      table.insert(tempSlotTable, slot)
    end
  end
  return tempSlotTable
end
function UIBarrackChangeSkinPanel:initShopShowSlot()
  local tempSlotTable = {}
  if self.mShowClothes == nil then
    return
  end
  local d = TableDataBase.listClothesDatas:GetDataById(self.mShowClothes)
  local skinCount = NetCmdIllustrationData:GetCountByTypeAndItemId(tonumber(GlobalConfig.ItemType.Costume), tonumber(self.mShowClothes))
  local isExistStore = false
  if d.unlock_type == 3 then
    local storeId = tonumber(d.unlock_arg)
    local storeData = NetCmdStoreData:GetStoreGoodsById(storeId)
    if storeData ~= nil then
      isExistStore = storeData.IsShowTime
    end
  end
  if d.display_config > 0 or d.display_config == 0 and (isExistStore or 0 < skinCount) then
    local bpID
    if bpID == nil or bpID >= d.display_arg then
      local slot = UIBarrackChangeSkinSlot.New()
      slot:SetData(self.gunCmdData, d, 1)
      table.insert(tempSlotTable, slot)
    end
  end
  return tempSlotTable
end
function UIBarrackChangeSkinPanel:UpdateBpClothes()
  setactive(self.ui.mTrans_BPToGet, false)
  setactive(self.ui.mTrans_BpLocked.transform, false)
  setactive(self.ui.mTrans_BPHasReceied, false)
  setactive(self.ui.mBtn_Receive.transform.parent, false)
  setactive(self.ui.mTrans_Buy, false)
  setactivewithcheck(self.ui.mBtn_BtnChange, false)
  if FacilityBarrackGlobal.CurSkinShowContentType == FacilityBarrackGlobal.ShowContentType.UIBpClothes then
    setactivewithcheck(self.ui.mTrans_Bp, true)
    setactivewithcheck(self.ui.mTrans_Skin, false)
    setactive(self.ui.mTrans_RedText, false)
    setactive(self.ui.mTrans_Currency, false)
    local status = NetCmdBattlePassData.BattlePassStatus
    local isBuyBp = status == CS.ProtoObject.BattlepassType.AdvanceTwo or status == CS.ProtoObject.BattlepassType.AdvanceOne
    local isFullBpLevel = NetCmdBattlePassData.BattlePassLevel == NetCmdBattlePassData.CurSeason.max_level
    setactive(self.ui.mTrans_BPToGet, isBuyBp and not isFullBpLevel)
    setactive(self.ui.mTrans_BpLocked.transform, not isBuyBp)
    local isMaxRewardGet = NetCmdBattlePassData.IsMaxRewardGet
    setactive(self.ui.mTrans_BPHasReceied, isFullBpLevel and isMaxRewardGet)
    setactive(self.ui.mBtn_Receive.transform.parent, isFullBpLevel and not isMaxRewardGet and isBuyBp)
    setactive(self.ui.mBtn_Receive, isFullBpLevel and not isMaxRewardGet and isBuyBp)
    UIUtils.GetButtonListener(self.ui.mBtn_Receive.gameObject).onClick = function()
      NetCmdBattlePassData:SendGetBattlepassReward(NetCmdBattlePassData.BattlePassStatus, NetCmdBattlePassData.CurSeason.MaxLevel, CS.ProtoCsmsg.BpRewardGetType.GetTypeNone, function(ret)
        if ret == ErrorCodeSuc then
          MessageSys:SendMessage(UIEvent.BpGetReward, nil)
          UIManager.OpenUI(UIDef.UICommonReceivePanel)
          self:UpdateBpClothes()
        end
      end)
    end
  end
end
function UIBarrackChangeSkinPanel:UpdateClothesPreview()
  if FacilityBarrackGlobal.CurSkinShowContentType ~= FacilityBarrackGlobal.ShowContentType.UIClothesPreview then
    return
  end
  setactivewithcheck(self.ui.mTrans_Buy, false)
  setactivewithcheck(self.ui.mTrans_GreenText, false)
  setactivewithcheck(self.ui.mTrans_Have, NetCmdIllustrationData:CheckIndexDetailUnlock(13, self.mShowClothes))
  setactivewithcheck(self.ui.mTrans_RedText, not NetCmdIllustrationData:CheckIndexDetailUnlock(13, self.mShowClothes))
  setactivewithcheck(self.ui.mBtn_BtnGotoGet, false)
  setactivewithcheck(self.ui.mBtn_BtnChange, false)
  local curSlot = self:getCurSlot()
  local clothesData = curSlot:GetClothesData()
  self.ui.mText_RedText.text = clothesData.unlock_description.str
end
function UIBarrackChangeSkinPanel:UpdateShopShowClothes()
  if FacilityBarrackGlobal.CurSkinShowContentType ~= FacilityBarrackGlobal.ShowContentType.UIShopClothes then
    return
  end
  setactivewithcheck(self.ui.mTrans_Bp, false)
  setactivewithcheck(self.ui.mTrans_Skin, true)
  setactive(self.ui.mTrans_RedText, false)
  setactive(self.ui.mTrans_Buy, true)
  local storeData = NetCmdStoreData:GetStoreGoodsById(self.mStoreId)
  if storeData == nil then
    return
  end
  local itemId = storeData.ItemNumList[0].itemid
  local itemData = TableData.GetItemData(itemId)
  if itemData == nil then
    return
  end
  self.mSkinCount = NetCmdIllustrationData:GetCountByTypeAndItemId(tonumber(GlobalConfig.ItemType.Costume), tonumber(itemData.args[0]))
  self.ui.mText_Cost.text = storeData.price
  self.ui.mImage_Item.sprite = IconUtils.GetItemIconSprite(storeData.price_type)
  local haveCount = NetCmdItemData:GetItemCount(storeData.price_type)
  local n1, n2 = math.modf(storeData.price)
  self.ui.mText_Cost.text = n1
  if haveCount < n1 then
    self.ui.mText_Cost.color = ColorUtils.RedColor3
  else
    self.ui.mText_Cost.color = ColorUtils.GrayColor
  end
  setactive(self.ui.mText_BeforeText, false)
  if storeData.price_args_type == 3 and storeData.price ~= storeData.base_price then
    setactive(self.ui.mText_BeforeText, true)
    self.ui.mText_BeforeText.text = FormatNum(storeData.base_price)
  end
  setactivewithcheck(self.ui.mBtn_Item, true)
  setactivewithcheck(self.ui.mTrans_Buy, self.mSkinCount == 0)
  setactivewithcheck(self.ui.mTrans_Have, self.mSkinCount ~= 0)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnBuy.gameObject, function()
    self:onClickShopBuy(self.mStoreId)
  end)
end
function UIBarrackChangeSkinPanel:onClickSlot(slotIndex)
  if not slotIndex then
    return
  end
  if self.curSlotIndex == slotIndex then
    self:scrollToCurSlotIndex(true)
    return
  end
  if slotIndex <= 0 or slotIndex > #self.slotTable then
    return
  end
  local prevSlotIndex = self.curSlotIndex
  self.curSlotIndex = slotIndex
  self:onSwitchedSelectSlotAfter(prevSlotIndex, self.curSlotIndex)
end
function UIBarrackChangeSkinPanel:onSwitchedSelectSlotAfter(prevSlotIndex, curSlotIndex)
  self:refresh(true)
  self:scrollToCurSlotIndex(true)
  local curSlot = self:getCurSlot()
  local clothesData = curSlot:GetClothesData()
  if curSlot:IsUnlock() then
    NetCmdGunClothesData:SetPreviewedRecord(clothesData.id)
  end
end
function UIBarrackChangeSkinPanel:scrollToCurSlotIndex(isSmooth)
  self:scrollTo(self.curSlotIndex, isSmooth)
end
function UIBarrackChangeSkinPanel:scrollTo(index, isSmooth)
  if not index then
    return
  end
  local targetIndex = index - 1
  if targetIndex < 0 then
    targetIndex = 0
  end
  self.ui.mVirtualList:ScrollTo(targetIndex, isSmooth, nil, ScrollAlign.Start)
end
function UIBarrackChangeSkinPanel:getCurSlot()
  return self.slotTable[self.curSlotIndex]
end
function UIBarrackChangeSkinPanel:refreshModel(needGunClothesAnim)
  local curSlot = self:getCurSlot()
  local clothesData = curSlot:GetClothesData()
  BarrackHelper.ModelMgr:ChangeClothes(self.gunCmdData.id, clothesData.id, function()
    BarrackHelper.ModelMgr.curModel:Show(true)
    if not needGunClothesAnim then
      return
    end
    self:playChangeClothesAnim(clothesData)
    BarrackHelper.ModelMgr:PlayChangeClothesEffect()
  end)
end
function UIBarrackChangeSkinPanel:refreshGrpBtn()
  setactivewithcheck(self.ui.mBtn_Item, false)
  setactivewithcheck(self.ui.mBtn_BtnReceive, false)
  setactivewithcheck(self.ui.mTrans_Buy, false)
  setactivewithcheck(self.ui.mBtn_BtnGotoGet, false)
  setactivewithcheck(self.ui.mBtn_BtnChange, false)
  setactivewithcheck(self.ui.mTrans_RedText, false)
  setactivewithcheck(self.ui.mTrans_GreenText, false)
  local curSlot = self:getCurSlot()
  local clothesData = curSlot:GetClothesData()
  local isFocusEquipped = curSlot:GetClothesId() == self.gunCmdData.costume
  if isFocusEquipped then
    setactivewithcheck(self.ui.mTrans_GreenText, true)
    return
  end
  if FacilityBarrackGlobal.CurSkinShowContentType == FacilityBarrackGlobal.ShowContentType.UIShopClothes then
    setactivewithcheck(self.ui.mTrans_Buy, self.mSkinCount == nil or self.mSkinCount == 0)
    setactivewithcheck(self.ui.mBtn_Item, self.mSkinCount == nil or self.mSkinCount == 0)
    return
  end
  if clothesData.unlock_type == 1 then
    setactivewithcheck(self.ui.mBtn_BtnChange, true)
  elseif clothesData.unlock_type == 2 then
    local isUnlock = curSlot:IsUnlock()
    if isUnlock then
      setactivewithcheck(self.ui.mBtn_BtnChange, true)
    else
      self.ui.mText_RedText.text = clothesData.unlock_description.str
      setactivewithcheck(self.ui.mTrans_RedText, true)
    end
  elseif clothesData.unlock_type == 3 then
    local isUnlock = curSlot:IsUnlock()
    if isUnlock then
      setactivewithcheck(self.ui.mBtn_BtnChange, true)
    else
      local storeId = tonumber(clothesData.unlock_arg)
      local storeData = NetCmdStoreData:GetStoreGoodsById(storeId)
      if not storeData then
        return
      end
      self.ui.mImage_Item.sprite = IconUtils.GetItemIconSprite(storeData.price_type)
      local haveCount = NetCmdItemData:GetItemCount(storeData.price_type)
      local n1, n2 = math.modf(tonumber(storeData.price))
      self.ui.mText_Cost.text = n1
      if haveCount < n1 then
        self.ui.mText_Cost.color = ColorUtils.RedColor3
      else
        self.ui.mText_Cost.color = ColorUtils.GrayColor
      end
      setactive(self.ui.mText_BeforeText, false)
      if storeData.price_args_type == 3 and storeData.price ~= storeData.base_price then
        setactive(self.ui.mText_BeforeText, true)
        self.ui.mText_BeforeText.text = FormatNum(storeData.base_price)
      end
      setactivewithcheck(self.ui.mBtn_Item, true)
      setactivewithcheck(self.ui.mBtn_GrpConsume, true)
      setactivewithcheck(self.ui.mTrans_Buy, true)
    end
  elseif clothesData.unlock_type == 4 then
    local isUnlock = curSlot:IsUnlock()
    if isUnlock then
      setactivewithcheck(self.ui.mBtn_BtnChange, true)
    else
      setactivewithcheck(self.ui.mBtn_BtnGotoGet, true)
    end
  elseif clothesData.unlock_type == 5 then
    self.ui.mText_RedText.text = clothesData.unlock_description.str
    setactivewithcheck(self.ui.mTrans_RedText, true)
  end
end
function UIBarrackChangeSkinPanel:refreshGunDesc()
  if not self.gunCmdData then
    return
  end
  local curSlot = self:getCurSlot()
  if not curSlot then
    return
  end
  local clothesData = curSlot:GetClothesData()
  if not clothesData then
    return
  end
  self.ui.mText_ChrName.text = self.gunCmdData.gunData.name.str
  self.ui.mText_SkinName.text = clothesData.name.str
  self.ui.mImage_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(clothesData.rare)
  self.ui.mText_SkinDesc.text = clothesData.description.str
  setactive(self.ui.mTrans_Several, clothesData.clothes_type == 1)
  setactive(self.ui.mTrans_All, clothesData.clothes_type == 2)
end
function UIBarrackChangeSkinPanel:playChangeClothesAnim(clothesData)
  local gunGlobalConfigData = TableDataBase.listGunGlobalConfigDatas:GetDataById(clothesData.model_id)
  local barrackFormationData
  if self.gunCmdData:IsPrivateWeapon() then
    barrackFormationData = TableDataBase.listBarrackFormationDatas:GetDataById(gunGlobalConfigData.barrack_formation_exclusive)
  else
    local isEqualToPrivateWeaponModelType = self.gunCmdData:IsPrivateSameWeapon()
    if not isEqualToPrivateWeaponModelType then
      barrackFormationData = TableDataBase.listBarrackFormationDatas:GetDataById(gunGlobalConfigData.barrack_formation_normal01)
    else
      barrackFormationData = TableDataBase.listBarrackFormationDatas:GetDataById(gunGlobalConfigData.barrack_formation_normal02)
    end
  end
  if not barrackFormationData then
    return
  end
  if #barrackFormationData.changeclothes > 0 then
    BarrackHelper.ModelMgr:ChangeChrAnim(CS.ChrAnimTriggerType.BarrackChangeClothes)
  else
    BarrackHelper.TimelineMgr:PlayTimeline(barrackFormationData.changeclothes_timeline)
  end
end
function UIBarrackChangeSkinPanel:refreshSwitchArrow()
  local gunCmdData = self:getValidGunCmdData(self.gunCmdData.id, true, 1, NetCmdTeamData.GunCount)
  setactivewithcheck(self.ui.mBtn_RightArrow, gunCmdData ~= nil)
  setactivewithcheck(self.ui.mBtn_LeftArrow, gunCmdData ~= nil)
end
function UIBarrackChangeSkinPanel:onClickLeftArrow()
  if NetCmdTeamData.GunCount <= 1 then
    return
  end
  local gunCmdData = self:getValidGunCmdData(self.gunCmdData.id, false, 1, NetCmdTeamData.GunCount)
  if not gunCmdData or gunCmdData.GunId == self.gunCmdData.id then
    return
  end
  self.ui.mAnimator:SetTrigger("Previous")
  FacilityBarrackGlobal.SetNeedBarrackEntrance(false)
  BarrackHelper.ModelMgr:SwitchGunModel(gunCmdData, function()
    self:onSwitchedModel()
  end)
  self.ui.mVirtualList.numItems = 0
  self:OnInit(nil, gunCmdData.GunId)
  self:refresh(false)
  self:scrollToCurSlotIndex(false)
end
function UIBarrackChangeSkinPanel:onClickRightArrow()
  if NetCmdTeamData.GunCount <= 1 then
    return
  end
  local gunCmdData = self:getValidGunCmdData(self.gunCmdData.id, true, 1, NetCmdTeamData.GunCount)
  if not gunCmdData or gunCmdData.GunId == self.gunCmdData.id then
    return
  end
  self.ui.mAnimator:SetTrigger("Next")
  FacilityBarrackGlobal.SetNeedBarrackEntrance(false)
  BarrackHelper.ModelMgr:SwitchGunModel(gunCmdData, function()
    self:onSwitchedModel()
  end)
  self.ui.mVirtualList.numItems = 0
  self:OnInit(nil, gunCmdData.GunId)
  self:refresh(false)
  self:scrollToCurSlotIndex(false)
end
function UIBarrackChangeSkinPanel:onSwitchedModel()
  BarrackHelper.ModelMgr.curModel:Show(true)
  BarrackHelper.ModelMgr:ChangeChrAnim("BarrackIdle")
  BarrackHelper.ModelMgr:PlayChangeGunEffect()
end
function UIBarrackChangeSkinPanel:getValidGunCmdData(gunId, isNext, itorCount, allGunCount)
  if allGunCount < itorCount then
    return nil
  end
  local gunCmdData = NetCmdTeamData:GetOtherGunById(gunId, isNext)
  if gunCmdData.id == gunId then
    return nil
  end
  return gunCmdData
end
function UIBarrackChangeSkinPanel:slotProvider()
  local skinCardTemplate = self.ui.mScrollListChild_SkinCard.childItem
  local slotTrans = UIUtils.InstantiateByTemplate(skinCardTemplate, self.ui.mScrollListChild_SkinCard.transform)
  slotTrans.position = vectorone * 1000
  local renderDataItem = RenderDataItem()
  renderDataItem.renderItem = slotTrans.gameObject
  renderDataItem.data = nil
  return renderDataItem
end
function UIBarrackChangeSkinPanel:slotRenderer(index, renderData)
  local slot = self.slotTable[index + 1]
  local go = renderData.renderItem
  slot:SetRoot(go.transform)
  if slot:GetIndex() == self.curSlotIndex then
    slot:Select()
  else
    slot:Deselect()
  end
  if FacilityBarrackGlobal.CurSkinShowContentType == FacilityBarrackGlobal.ShowContentType.UIBpClothes or FacilityBarrackGlobal.CurSkinShowContentType == FacilityBarrackGlobal.ShowContentType.UIShopClothes then
    slot:PlayUnlockingAnim()
    slot:RefreshInfo()
  else
    slot:Refresh()
  end
end
function UIBarrackChangeSkinPanel:getEquippedSkinSlotIndex()
  for i, slot in ipairs(self.slotTable) do
    if slot:GetClothesId() == self.gunCmdData.costume then
      return slot:GetIndex()
    end
  end
  return -1
end
function UIBarrackChangeSkinPanel:onClickChangeClothes()
  local curSlot = self:getCurSlot()
  local clothesData = curSlot:GetClothesData()
  NetCmdGunClothesData:SendChangeCostumeCmd(self.gunCmdData.id, clothesData.id, function(ret)
    if ret ~= ErrorCodeSuc then
      return
    end
    local text = TableData.GetHintById(230009)
    PopupMessageManager.PopupPositiveString(text)
    self:refresh(false)
  end)
end
function UIBarrackChangeSkinPanel:onClickGotoGet()
  local curSlot = self:getCurSlot()
  local clothesData = curSlot:GetClothesData()
  local jumpId = tonumber(clothesData.unlock_arg)
  SceneSwitch:SwitchByID(jumpId)
end
function UIBarrackChangeSkinPanel:onClickBuy()
  local curSlot = self:getCurSlot()
  self.mTempSlot = curSlot
  local clothesData = curSlot:GetClothesData()
  self.mTempClothesData = clothesData
  local storeId = tonumber(clothesData.unlock_arg)
  local storeData = NetCmdStoreData:GetStoreGoodsById(storeId)
  if not storeData then
    return
  end
  local haveNum = NetCmdItemData:GetItemCount(storeData.price_type)
  if haveNum < tonumber(storeData.price) then
    UIStoreGlobal.OpenCharge()
    return
  end
  local title = TableData.GetHintById(230010)
  local gunName = self.gunCmdData.TabGunData.FirstName.str
  local clothesName = clothesData.name.str
  local gunRank = self.gunCmdData.TabGunData.rank
  local clothesRank = clothesData.Rare
  local gunColorHex = "#" .. CS.Utage.ColorUtil.ToColorString(TableData.GetGlobalGun_Quality_Color2(gunRank))
  local clothesColorHex = "#" .. CS.Utage.ColorUtil.ToColorString(TableData.GetGlobalGun_Quality_Color2(clothesRank))
  local clothesTypeStr = clothesData.clothes_type == 1 and TableData.GetHintById(230012) or TableData.GetHintById(230011)
  local clothesTypeNotice = clothesData.clothes_type == 1 and TableData.GetHintById(230015) or TableData.GetHintById(230016)
  local content = TableData.GetHintById(230007, gunColorHex, gunName, clothesColorHex, clothesName, clothesTypeStr, clothesTypeNotice)
  content = CS.LuaUIUtils.String_Replace(content, "\\n", "\n")
  local param = {
    title = title,
    contentText = content,
    customData = TableDataBase.listStoreGoodDatas:GetDataById(storeId),
    isDouble = true,
    dialogType = 3,
    confirmCallback = function()
      UIManager.CloseUI(UIDef.UIComDoubleCheckDialog)
      NetCmdStoreData:SendStoreBuy(storeId, 1, function(ret)
        if ret ~= ErrorCodeSuc then
          return
        end
        UIManager.OpenUI(UIDef.UICommonReceivePanel)
      end)
    end
  }
  UIManager.OpenUIByParam(UIDef.UIComDoubleCheckDialog, param)
end
function UIBarrackChangeSkinPanel:onClickShopBuy(storeId)
  local curSlot = self:getCurSlot()
  local clothesData = curSlot:GetClothesData()
  self.mTempSlot = curSlot
  local storeId = storeId
  local storeData = NetCmdStoreData:GetStoreGoodsById(storeId)
  if not storeData then
    return
  end
  local haveNum = NetCmdItemData:GetItemCount(storeData.price_type)
  if haveNum < tonumber(storeData.price) then
    UIStoreGlobal.OpenCharge()
    return
  end
  self.mTempClothesData = clothesData
  local title = TableData.GetHintById(230010)
  local gunName = self.gunCmdData.TabGunData.FirstName.str
  local clothesName = clothesData.name.str
  local gunRank = self.gunCmdData.TabGunData.rank
  local clothesRank = clothesData.Rare
  local gunColorHex = "#" .. CS.Utage.ColorUtil.ToColorString(TableData.GetGlobalGun_Quality_Color2(gunRank))
  local clothesColorHex = "#" .. CS.Utage.ColorUtil.ToColorString(TableData.GetGlobalGun_Quality_Color2(clothesRank))
  local clothesTypeStr = clothesData.clothes_type == 1 and TableData.GetHintById(230012) or TableData.GetHintById(230011)
  local clothesTypeNotice = clothesData.clothes_type == 1 and TableData.GetHintById(230015) or TableData.GetHintById(230016)
  local content = TableData.GetHintById(230007, gunColorHex, gunName, clothesColorHex, clothesName, clothesTypeStr, clothesTypeNotice)
  content = CS.LuaUIUtils.String_Replace(content, "\\n", "\n")
  local param = {
    title = title,
    contentText = content,
    customData = TableDataBase.listStoreGoodDatas:GetDataById(storeId),
    isDouble = true,
    dialogType = 3,
    confirmCallback = function()
      UIManager.CloseUI(UIDef.UIComDoubleCheckDialog)
      NetCmdStoreData:SendStoreBuy(storeId, 1, function(ret)
        if ret ~= ErrorCodeSuc then
          return
        end
        UIManager.OpenUI(UIDef.UICommonReceivePanel)
      end)
    end
  }
  UIManager.OpenUIByParam(UIDef.UIComDoubleCheckDialog, param)
end
function UIBarrackChangeSkinPanel:onClickConsume()
  local curSlot = self:getCurSlot()
  local clothesData = curSlot:GetClothesData()
  local storeId = tonumber(clothesData.unlock_arg)
  local storeHistory = NetCmdStoreData:GetGoodsHistoryById(storeId)
  if not storeHistory then
    local storeData = TableDataBase.listStoreGoodDatas:GetDataById(storeId)
    if not storeData then
      return
    end
    local itemData = TableDataBase.listItemDatas:GetDataById(storeData.price_type)
    UITipsPanel.Open(itemData, storeData.price, true)
  end
end
function UIBarrackChangeSkinPanel:onClickItem()
  local curSlot = self:getCurSlot()
  local clothesData = curSlot:GetClothesData()
  local storeId = tonumber(clothesData.unlock_arg)
  local storeHistory = NetCmdStoreData:GetGoodsHistoryById(storeId)
  if not storeHistory then
    local storeData = TableDataBase.listStoreGoodDatas:GetDataById(storeId)
    if not storeData then
      return
    end
    local itemData = TableDataBase.listItemDatas:GetDataById(storeData.price_type)
    UITipsPanel.Open(itemData, storeData.price, true)
  end
end
function UIBarrackChangeSkinPanel:onClickBack()
  if FacilityBarrackGlobal.CurSkinShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrOverview then
    BarrackHelper.ModelMgr:RevertClothes()
  end
  UIManager.CloseUI(self.mCSPanel)
  if self.isJumpUI ~= true then
  end
end
function UIBarrackChangeSkinPanel:OnClose()
  if FacilityBarrackGlobal.CurSkinShowContentType == FacilityBarrackGlobal.ShowContentType.UIShopClothes then
    SceneSys:SwitchVisible(EnumSceneType.Store, false)
  elseif FacilityBarrackGlobal.CurSkinShowContentType == FacilityBarrackGlobal.ShowContentType.UIClothesPreview then
    SceneSys:SwitchVisible(EnumSceneType.CommandCenter)
  end
end
function UIBarrackChangeSkinPanel:onClickHome()
  if FacilityBarrackGlobal.CurSkinShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrOverview then
    BarrackHelper.ModelMgr:RevertClothes()
  end
  self.isClickedHome = true
  UIManager.JumpToMainPanel()
end
