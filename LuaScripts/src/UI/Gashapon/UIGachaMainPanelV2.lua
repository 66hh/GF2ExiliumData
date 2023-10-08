require("UI.CommonGetGunPanel.UICommonGetGunPanel")
require("UI.StorePanel.QuickStorePurchase")
require("UI.Gashapon.Item.UIGachaLeftTabItemV2")
require("UI.Gashapon.UIGachaMainPanelV2View")
require("UI.UIBasePanel")
require("UI.UITweenCamera")
require("UI.Gashapon.TabDisplayItem")
require("UI.Gashapon.EventDropGunItem")
require("UI.Gashapon.UIGashaponItem")
require("UI.WeaponPanel.UIWeaponPanel")
UIGachaMainPanelV2 = class("UIGachaMainPanelV2", UIBasePanel)
UIGachaMainPanelV2.__index = UIGachaMainPanelV2
UIGachaMainPanelV2.mMainNodePath = "Virtual Cameras/Position_1"
UIGachaMainPanelV2.mPath_GashaponItem = "Gashapon/UIGashaponItem.prefab"
UIGachaMainPanelV2.mPath_TabDisplayItem = "Gashapon/TabDisplayItem.prefab"
UIGachaMainPanelV2.mPath_EventDropGunItem = "Gashapon/EventDropGunItem.prefab"
UIGachaMainPanelV2.mView = nil
UIGachaMainPanelV2.mIPadCameraNode = nil
UIGachaMainPanelV2.mMainCameraNode = nil
UIGachaMainPanelV2.mCamera = nil
UIGachaMainPanelV2.mTempItemRoot = nil
UIGachaMainPanelV2.mCanvas = nil
UIGachaMainPanelV2.mGashaAirportPlayable = nil
UIGachaMainPanelV2.mTabDisplayItemList = nil
UIGachaMainPanelV2.mEventDropGunItemList = nil
UIGachaMainPanelV2.mGashaItemList = nil
UIGachaMainPanelV2.mGashaNetHandler = nil
UIGachaMainPanelV2.mData = nil
UIGachaMainPanelV2.curType = nil
UIGachaMainPanelV2.mCurActivityId = 0
UIGachaMainPanelV2.mCurGachaData = 0
UIGachaMainPanelV2.mItemFlipSpeed = 0.5
UIGachaMainPanelV2.mItemMoveInSpeed = 10
UIGachaMainPanelV2.mTweenEase = CS.DG.Tweening.Ease.InOutSine
UIGachaMainPanelV2.mTweenExpo = CS.DG.Tweening.Ease.InOutCirc
UIGachaMainPanelV2.mItemSpace = 195
UIGachaMainPanelV2.mDiamond2TicketRate = 1
UIGachaMainPanelV2.mSwipeBeginPosX = 0
UIGachaMainPanelV2.mIsDrawClicked = false
UIGachaMainPanelV2.mGachaBanner = nil
UIGachaMainPanelV2.mCacheBackgroundSprite = {}
UIGachaMainPanelV2.mCacheBannerSprite = {}
UIGachaMainPanelV2.mCacheDescSprite = {}
UIGachaMainPanelV2.mEffectList = {}
UIGachaMainPanelV2.mShakeList = {}
UIGachaMainPanelV2.mCountDownTimer = nil
UIGachaMainPanelV2.mAnimTimer = nil
UIGachaMainPanelV2.mVolume = nil
UIGachaMainPanelV2.curTab = 1
UIGachaMainPanelV2.mTotalDelta = 0
UIGachaMainPanelV2.lastSceneType = nil
function UIGachaMainPanelV2:ctor(csPanel)
  self.super.ctor(self)
  self.csPanel = csPanel
end
function UIGachaMainPanelV2.Open()
  UIManager.OpenUI(UIDef.UIGashaponMainPanel)
end
function UIGachaMainPanelV2.Close()
  UIManager.CloseUI(UIDef.UIGashaponMainPanel)
end
function UIGachaMainPanelV2:OnInit(root, data)
  self.super.SetRoot(UIGachaMainPanelV2, root)
  self.mData = data
  if self.mData ~= nil and self.mData[1] ~= nil and self.mData[1] then
    self.curTab = 1
  end
  self.mView = UIGachaMainPanelV2View.New()
  self.ui = {}
  self.mView:LuaUIBindTable(self.mUIRoot, self.ui)
  self.mView:InitCtrl(root, self.ui)
  self:SetCameraRoot()
  self.mTabDisplayItemList = List:New(TabDisplayItem)
  self.mEventDropGunItemList = List:New(EventDropGunItem)
  self.mWaitShowResult = nil
  function self.OnGetGashapon(msg)
    if not self.mGachaSceneIsFinish then
      self.mWaitShowResult = msg
    else
      self:PlayAirportAnim(msg)
    end
  end
  function self.UpdateView()
    self:RefreshText()
  end
  function self.OnSwitchByActivityID(msg)
    local paramArray = msg.Sender
    local gachaID = tonumber(paramArray[0])
    for i = 1, self.mTabDisplayItemList:Count() do
      local gachaItem = self.mTabDisplayItemList[i]
      if gachaItem.mEventData.GachaID == gachaID then
        self:OnActivityTabClicked(gachaItem.mBtn_GachaEventBtn.gameObject)
        return
      end
    end
  end
  function self.refreshGashaAirportPlayable(msg)
    if self.mGashaAirportPlayable ~= nil then
      self.mGashaAirportPlayable.initialTime = 18
      setactive(self.mGashaAirportPlayable.gameObject, true)
    end
  end
  function self.gashaShowResultFunc(msg)
    self.skipPanel:HideTouchPad()
    if self.gachaScene ~= nil then
      self.gachaScene:ResetShadowDistance()
    end
    InputSys:OneFingerDragingEvent("-", UIGachaMainPanelV2.OneFingerDragingEventHandle)
    InputSys:OneFingerDragEndEvent("-", UIGachaMainPanelV2.OneFingerDragEndEventHandle)
    TimerSys:DelayCall(0.1 + TableData.GlobalSystemData.GachaTimePhase3 / 1000, function()
      setactive(self.skipPanel.ui.mBtn_BgSkip.gameObject, true)
      self:ShowResultPanel(self.msg)
      self.msg = nil
    end, nil)
  end
  MessageSys:AddListener(CS.GF2.Message.GashaponEvent.GashaponAcquire, self.OnGetGashapon)
  MessageSys:AddListener(CS.GF2.Message.CommonEvent.ItemUpdate, self.UpdateView)
  MessageSys:AddListener(CS.GF2.Message.CampaignEvent.ResInfoUpdate, self.UpdateView)
  MessageSys:AddListener(CS.GF2.Message.GashaponEvent.SwitchByActivityID, self.OnSwitchByActivityID)
  MessageSys:AddListener(UIEvent.GashaAirportPlayable, self.refreshGashaAirportPlayable)
  MessageSys:AddListener(UIEvent.GashaShowResult, self.gashaShowResultFunc)
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    SceneSys:SwitchVisible(self.lastSceneType or EnumSceneType.CommandCenter)
    self.lastSceneType = nil
    self.Close()
    self.curTab = 1
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    self.curTab = 1
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_OrderTen.gameObject).onClick = function(gameobj)
    self:OnTenTimeClicked(gameobj)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_OrderOne.gameObject).onClick = function()
    self:OnOneTimeClicked()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_OrderTenNew.gameObject).onClick = function(gameobj)
    self:OnTenTimeClicked(gameobj)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_UpTen.gameObject).onClick = function(gameobj)
    self:OnTenTimeClicked(gameobj)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_UpOne.gameObject).onClick = function()
    self:OnOneTimeClicked()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ShopMobile.gameObject).onClick = function()
    self:OnShopClicked()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Shop.gameObject).onClick = function()
    self:OnShop()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_OptionReward.gameObject).onClick = function()
    UIManager.OpenUI(UIDef.UIGachaOptionalDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_OpenGachaListMobile.gameObject).onClick = function()
    self:OnGachaListClicked()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Preview.gameObject).onClick = function()
    local listType = CS.System.Collections.Generic.List(CS.System.Int32)
    local mlist = listType()
    mlist:Add(self.mCurGachaData.GunUpCharacter)
    mlist:Add(FacilityBarrackGlobal.ShowContentType.UIGachaPreview)
    mlist:Add(self.mCurGachaData.GachaID)
    SceneSwitch:SwitchByID(4001, false, mlist)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_WeaponPreview.gameObject).onClick = function()
    local param = {
      self.mCurGachaData.GunUpWeapon,
      UIWeaponGlobal.WeaponPanelTab.Info,
      true,
      UIWeaponPanel.OpenFromType.GachaPreview,
      needReplaceBtn = false
    }
    UIManager.OpenUIByParam(UIDef.UIWeaponPanel, param)
  end
  self.ui.mText_Confirm.text = TableData.GetHintById(107007)
  self.ui.mText_Id.text = TableData.GetHintById(107001)
  self.ui.mText_OrderOneName.text = TableData.GetHintById(107009)
  self.ui.mText_OrderTenName.text = TableData.GetHintById(107010)
  self.ui.mText_2.text = TableData.GetHintById(107005)
  self.ui.mText_DateTitle.text = TableData.GetHintById(107006)
  self.ui.mText_Details.text = TableData.GetHintById(107004)
  self:LimitTimesRefresh()
  self.switchTrigger = true
  self:InitActivity()
  self:UpdateView()
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Back)
end
function UIGachaMainPanelV2:CheckGachaScene()
  self.mGachaSceneIsFinish = SceneSys:CheckOrOpenGachaScene()
  if self.mGachaSceneIsFinish then
    self:OnGachaSceneLoadFinish()
  else
    function self.OnGachaSceneLoad(msg)
      self.mGachaSceneIsFinish = true
      self:OnGachaSceneLoadFinish()
    end
    MessageSys:AddListener(UIEvent.GachaSceneLoadFinish, self.OnGachaSceneLoad)
  end
end
function UIGachaMainPanelV2:OnGachaSceneLoadFinish()
  self.gachaScene = SceneSys:GetGachaScene()
  if self.gachaScene == nil then
    return
  end
  local LuaUIBindScript = self.gachaScene.DefaultTimelineObj:GetComponent(UIBasePanel.LuaBindUi)
  local vars = LuaUIBindScript.BindingNameList
  for i = 0, vars.Count - 1 do
    self[vars[i]] = LuaUIBindScript:GetBindingComponent(vars[i])
  end
  SceneSys:SwitchVisible(EnumSceneType.Gacha)
  if self.mWaitShowResult ~= nil then
    self:PlayAirportAnim(self.mWaitShowResult)
    self.mWaitShowResult = nil
  end
end
function UIGachaMainPanelV2:OnBackFrom()
  self.DelayLoadGachaTimer = TimerSys:DelayCall(1, function()
    self:CheckGachaScene()
  end, nil)
  if self.mGachaSceneIsFinish == true then
    SceneSys:SwitchVisible(EnumSceneType.Gacha)
  end
  local count = self.mTabDisplayItemList:Count()
  for i = 1, count do
    local eventItem = self.mTabDisplayItemList[i]
    eventItem:UpdateRedPoint()
  end
  if not self.mTabDisplayItemList[self.curTab].mEventData.IsOpen then
    local data = self.mTabDisplayItemList[self.curTab].mEventData
    for _, item in pairs(self.mTabDisplayItemList) do
      item:OnRelease(true)
    end
    self.mTabDisplayItemList:Clear()
    self:InitActivity()
  else
    setactive(self.ui.mTrans_PreviewRedpoint, not GashaponNetCmdHandler:CheckPoolPreviewed(self.mCurActivityId))
  end
  local item = self.mTabDisplayItemList[self.curTab]
  self:SetEventData(item.mEventData)
  if item.mEventData.Type ~= 3 and item.mEventData.Type ~= 5 then
    self.ui.mAnimator:SetTrigger("Switch")
  end
  self:ShowPanel()
end
function UIGachaMainPanelV2:OnUpdate()
end
function UIGachaMainPanelV2:LimitTimesRefresh()
  local limitType = GashaponNetCmdHandler:GachaLimitType()
  GashaponNetCmdHandler:SetLimit()
  local limitTimes = GashaponNetCmdHandler.Limit
  local limitVisible = TableDataBase.GlobalSystemData.GachaLimitIsvisible
  if limitType ~= -1 and limitVisible == true then
    setactive(self.ui.mText_TipsBg.gameObject, true)
    local limitTimesStr
    if limitType == 1 then
      limitTimesStr = string.format("%d", limitTimes)
      self.ui.mText_Tips.text = TableData.GetHintReplaceById(107020, limitTimesStr)
    elseif limitType == 2 then
      limitTimesStr = string.format("%d", limitTimes)
      self.ui.mText_Tips.text = TableData.GetHintReplaceById(107021, limitTimesStr)
    end
  else
    setactive(self.ui.mText_TipsBg.gameObject, false)
  end
end
function UIGachaMainPanelV2:OnSkipAnimClicked(msg)
  self:ShowResultPanel(msg)
end
function UIGachaMainPanelV2:InitAnimations()
  self.mGashaAirportPlayable = self.gachaScene:GetCurrentPlayable(false, self.mCurActivityId)
  self.mGashaAirportPlayable:Stop()
  setactive(self.mGashaAirportPlayable.gameObject, false)
end
function UIGachaMainPanelV2.OneFingerDragingEventHandle(touchPoint, offset)
  local oriValue = math.max(0, UIGachaMainPanelV2.mTotalDelta)
  local newValue
  if oriValue > TableData.GlobalSystemData.GachaStartRatePhase2 then
    newValue = UIGachaMainPanelV2.mTotalDelta + TableData.GlobalSystemData.GachaSpeedPhase2 * offset.x
  else
    newValue = UIGachaMainPanelV2.mTotalDelta + offset.x
  end
  UIGachaMainPanelV2.mTotalDelta = math.max(0, newValue)
  local value = UIGachaMainPanelV2.mTotalDelta / (CS.UnityEngine.Screen.width * 0.5)
  UIGachaMainPanelV2.gachaScene:SetAnimationNormalizedTime(math.min(1, math.max(0, value)), UIGachaMainPanelV2.rank)
  UIGachaMainPanelV2.gachaScene:SetParticleActive(0 < offset.x, UIGachaMainPanelV2.rank)
  if 0 < value and oriValue == 0 then
    if UIGachaMainPanelV2.skipPanel ~= nil then
      UIGachaMainPanelV2.skipPanel:SetDragActive(false)
    end
  elseif value == 0 and 0 < oriValue and UIGachaMainPanelV2.skipPanel ~= nil then
    UIGachaMainPanelV2.skipPanel:SetDragActive(true)
  end
end
function UIGachaMainPanelV2.OneFingerDragEndEventHandle()
end
function UIGachaMainPanelV2:PlayAirportAnim(msg)
  UIGachaMainPanelV2.gachaScene:InitAnimations()
  self.msg = msg
  self.addDragEvent = false
  if self.mAnimTimer ~= nil then
    self.mAnimTimer:Stop()
    self.mAnimTimer = nil
  end
  self.mAnimTimer = TimerSys:DelayCall(10, function(msg)
    UIGachaMainPanelV2.mTotalDelta = 0
    SceneSys:GetGachaScene():SetAnimationNormalizedTime(0, self.rank)
    self.addDragEvent = true
    self.skipPanel:InitTouchPad()
    InputSys:OneFingerDragingEvent("+", self.OneFingerDragingEventHandle)
    InputSys:OneFingerDragEndEvent("+", self.OneFingerDragEndEventHandle)
  end, msg)
  local gachainfos = msg.Content
  local count = gachainfos.Length
  self.mEffectList = {}
  self.mShakeList = {}
  self.rank = 3
  for i = 0, count - 1 do
    local info = gachainfos[i]
    local mStcData = TableData.GetItemData(info.ItemId)
    if mStcData.rank >= 5 then
      self.rank = 5
    elseif mStcData.rank >= 4 and self.rank == 3 then
      self.rank = 4
    end
  end
  NetCmdAchieveData:GashaponStart()
  local num = math.random(1, 1000)
  self.mGashaAirportPlayable = self.gachaScene:GetCurrentPlayable(self.rank == 5 and num <= TableDataBase.GlobalSystemData.GachaSpecielTimelineRate, self.mCurActivityId, true)
  setactive(self.mGashaAirportPlayable.transform, true)
  self.mGashaAirportPlayable:Play()
  self:HidePanel()
  AudioUtils.PlayBGMById(77)
  UIManager.OpenUIByParam(UIDef.UIGashaponSkipPanel, {
    onInitFinished = function(skipPanel)
      self.skipPanel = skipPanel
      setactive(skipPanel.ui.mBtn_BgSkip.gameObject, false)
    end,
    bgSkip = nil,
    btnSkip = function(skipPanel)
      if self.addDragEvent then
        self.addDragEvent = false
        self.skipPanel:HideTouchPad()
        InputSys:OneFingerDragingEvent("-", UIGachaMainPanelV2.OneFingerDragingEventHandle)
        InputSys:OneFingerDragEndEvent("-", UIGachaMainPanelV2.OneFingerDragEndEventHandle)
      end
      if self.gachaScene ~= nil then
        self.gachaScene:ResetShadowDistance()
      end
      self.mGashaAirportPlayable:Pause()
      self.mAnimTimer:Stop()
      self.mAnimTimer = nil
      setactive(self.mGashaAirportPlayable.gameObject, false)
      local unskipableIndex = self:GetNewIndex(msg.Content)
      if unskipableIndex == 0 then
        skipPanel.Close()
        UIManager.OpenUIByParam(UIDef.UIGachaResultPanel, msg)
      else
        setactive(skipPanel.ui.mBtn_BgSkip.gameObject, true)
        self:ShowResultPanel(msg, nil, unskipableIndex)
      end
      if self.rank == 3 then
        AudioUtils.PlayByID(10026)
      elseif self.rank == 4 then
        AudioUtils.PlayByID(10029)
      elseif self.rank == 5 then
        AudioUtils.PlayByID(10032)
      end
    end
  }, CS.UISystem.UIGroupType.BattleUI)
end
function UIGachaMainPanelV2:GetNewIndex(dataList)
  for i = 0, dataList.Length - 1 do
    local item = dataList[i]
    local itemData = TableData.listItemDatas:GetDataById(item.ItemId)
    if itemData.type == GlobalConfig.ItemType.Weapon then
      local weaponData = TableData.listGunWeaponDatas:GetDataById(itemData.args[0])
      if NetCmdIllustrationData:CheckItemIsFirstTime(itemData.type, weaponData.id, false) then
        return i + 1
      end
    elseif itemData.type == GlobalConfig.ItemType.GunType and item.ItemNum ~= 0 then
      return i + 1
    end
  end
  return 0
end
function UIGachaMainPanelV2:ShowResultPanel(msg, itemList, unskipableIndex)
  if self.mEffectSound then
    self.mEffectSound:StopAudio()
  end
  UICommonGetGunPanel.OpenGetGunPanel(itemList == nil and msg.Content or itemList, function(getGunPanel, skipPanel)
    if skipPanel ~= nil then
      skipPanel.Close()
    end
    self.skipPanel = nil
    if getGunPanel.timeLineShow ~= nil and self.mGashaAirportPlayable then
      setactive(self.mGashaAirportPlayable.gameObject, false)
      self.mGashaAirportPlayable.initialTime = 0
    end
    UIManager.OpenUIByParam(UIDef.UIGachaResultPanel, {
      msg,
      function()
        getGunPanel.Close()
      end
    })
  end, nil, true, false, self.skipPanel, unskipableIndex, true)
  setactive(self.mGashaAirportPlayable.gameObject, false)
end
function UIGachaMainPanelV2:OnShop()
  SceneSwitch:SwitchByID(5003)
end
function UIGachaMainPanelV2:OnShopClicked(obj)
  GashaponNetCmdHandler:SendReqGachaHistory(function(ret)
    UIManager.OpenUIByParam(UIDef.UIGachaShoppingDetailPanel, self.mCurGachaData)
  end)
end
function UIGachaMainPanelV2:OnBuyTicketClicked()
  local ticketItem = TableData.GetItemData(self.mCurGachaData.CostItemID)
  local tag = NetCmdStoreData:GetStoreGoodById(ticketItem.Goodsid).tag
  QuickStorePurchase.RedirectToStoreTag(tag, self)
end
function UIGachaMainPanelV2:OnBuyDiamondClicked()
  local tag = 1
  QuickStorePurchase.RedirectToStoreTag(tag, self)
end
function UIGachaMainPanelV2:InitActivity()
  local isTutorial = false
  if UISystem:GetTopUI(UIGroupType.Tutorial) ~= nil and UISystem:GetTopUI(UIGroupType.Tutorial).UIDefine.UIType == 33 then
    isTutorial = UISystem:GetTopUI(UIGroupType.Tutorial).GameObject.activeSelf
  end
  local curActivity = GashaponNetCmdHandler:GetCurGachaActivity(isTutorial)
  for i = 0, curActivity.Count - 1 do
    local data = curActivity[i]
    local leftTab
    leftTab = UIGachaLeftTabItemV2.New()
    leftTab:InitCtrl(self.ui.mContent_LeftTabMobile)
    leftTab:SetData(data)
    UIUtils.GetButtonListener(leftTab.mBtn_GachaEventBtn.gameObject).onClick = function()
      self:OnActivityTabClicked(i + 1, true)
    end
    if self.mData and data.GachaID == self.mData[1] then
      self.curTab = i + 1
    end
    if self.curType and self.curType == data.type then
      self.curTab = i + 1
      self.curType = nil
    end
    self.mTabDisplayItemList:Add(leftTab)
  end
  self:OnActivityTabClicked(self.curTab)
end
function UIGachaMainPanelV2:OnActivityTabClicked(index, playAnim)
  if self.upSwitchTimer ~= nil then
    return
  end
  local item = self.mTabDisplayItemList[index]
  self.curTab = index
  self:UnAllSelectEventTab()
  item:SetSelect(true)
  self:SetEventData(item.mEventData)
  if item.mEventData.Type ~= 3 and item.mEventData.Type ~= 5 then
    if self.switchTrigger ~= nil and self.switchTrigger == true then
      self.switchTrigger = false
    end
    self.ui.mAnimator:SetTrigger("Switch")
  end
  self:RefreshText()
  MessageSys:SendMessage(GuideEvent.OnTabSwitched, UIDef.UIGashaponMainPanel, item:GetGlobalTab())
end
function UIGachaMainPanelV2:SetTopResourceBar()
  local interfaceId = UIDef.UIGashaponMainPanel
  local resources = tostring(self.mCurGachaData.CostItemID) .. ":" .. tostring(self.mCurGachaData.JumpId) .. "," .. TableData.GetResourcesBarData(interfaceId).resources
  local root = self.mUIRoot
  local currencyParent = CS.TransformUtils.DeepFindChild(root, "TopResourceBarRoot(Clone)")
  self.csPanel.TopResourceBar.LuaTopResourceBar:ReleaseCurrencyItemList()
  if currencyParent == nil then
    TimerSys:DelayCall(0.1, function()
      self:SetTopResourceBar()
    end, nil)
  else
    self.csPanel.TopResourceBar.LuaTopResourceBar:InitFromPanel(currencyParent, resources, true)
  end
end
function UIGachaMainPanelV2:OnUpdate()
  if self.ui ~= nil and self.mCurGachaData ~= nil and self.mCurGachaData.EndTime ~= 0 then
    if CGameTime:GetTimestamp() > self.mCurGachaData.EndTime then
      self.curTab = 1
      for _, item in pairs(self.mTabDisplayItemList) do
        item:OnRelease(true)
      end
      self.mTabDisplayItemList:Clear()
      self:InitActivity()
      return
    end
    if self.mCurGachaData.GunUpCharacter ~= 0 then
      self.ui.mCount_Up:StartCountdown(self.mCurGachaData.EndTime)
    else
      self.ui.mCount_Order:StartCountdown(self.mCurGachaData.EndTime)
    end
  end
end
function UIGachaMainPanelV2:SetEventData(data)
  self.tempEndTime = CGameTime:GetTimestamp() + 15
  self:ClearAllEventDropGunItem()
  self.mCurActivityId = data.GachaID
  self.mCurGachaData = data
  self:SetTopResourceBar()
  setactive(self.ui.mTrans_GrpUp, false)
  if data.GunUpCharacter == 0 then
    setactive(self.ui.mTrans_GrpOrder, data.Type ~= 5)
    setactive(self.ui.mTrans_GrpNew, data.Type == 5)
    if data.Type == 5 then
      self.ui.mText_TitleNew.text = data.Name
    else
      if data.EndTime ~= 0 then
        self.ui.mCount_Order:StartCountdown(data.EndTime)
      end
      self.mGachaBanner = IconUtils.GetAtlasV2("GashaponPic", data.Banner)
      self.ui.mImage_Banner.sprite = self.mGachaBanner
      self.ui.mText_Title.text = data.Name
      local pickUp = ""
      if data.GunUpWeapon ~= 0 then
        local itemData = TableData.listGunWeaponDatas:GetDataById(data.GunUpWeapon)
        self.ui.mText_WeaponName.text = itemData.name.str
      end
      setactive(self.ui.mTrans_GrpWeaponName, data.Type == 4)
      setactive(self.ui.mText_Discount, data.Type == 5)
      setactive(self.ui.mTrans_Discount, data.Type == 5)
      setactive(self.ui.mTrans_Newbie, data.Type == 5)
      setactive(self.ui.mBtn_OrderOne, data.Type ~= 5)
      setactive(self.ui.mText_OneNum, data.Type ~= 5)
      setactive(self.ui.mImg_OneIcon, data.Type ~= 5)
      setactive(self.ui.mImg_One, data.Type ~= 5)
      setactive(self.ui.mTrans_ChrAttribute1, false)
      setactive(self.ui.mTrans_ChrAttribute2, false)
      setactive(self.ui.mTrans_WeaponAttribute1, false)
      setactive(self.ui.mTrans_WeaponAttribute2, false)
      for i = 0, data.SSRPickUpList.Count - 1 do
        if data.SSRPickUpList[i].Type == 4 then
          local gunData = TableData.GetGunData(tonumber(data.SSRPickUpList[i].args[0]))
          local dutyData = TableData.listGunDutyDatas:GetDataById(gunData.duty)
          if i == 0 then
            setactive(self.ui.mTrans_ChrAttribute1, true)
            self.ui.mText_PickUpChr1Name.text = gunData.name.str
            pickUp = pickUp .. gunData.name.str
            self.ui.mImg_DutyIcon1.sprite = IconUtils.GetGunTypeSprite(dutyData.icon)
          else
            setactive(self.ui.mTrans_ChrAttribute2, true)
            self.ui.mText_PickUpChr2Name.text = gunData.name.str
            pickUp = "," .. pickUp .. gunData.name.str
            self.ui.mImg_DutyIcon2.sprite = IconUtils.GetGunTypeSprite(dutyData.icon)
          end
        elseif data.SSRPickUpList[i].type == 8 then
          local weaponData = TableData.listGunWeaponDatas:GetDataById(tonumber(data.SSRPickUpList[i].args[0]))
          local elementData = TableData.listLanguageElementDatas:GetDataById(weaponData.element)
          if i == 0 then
            setactive(self.ui.mTrans_WeaponAttribute1, true)
            self.ui.mText_PickUpWeapon1Name.text = weaponData.name.str
            pickUp = pickUp .. weaponData.name.str
            self.ui.mImg_ElementIcon1.sprite = IconUtils.GetElementIcon(elementData.icon)
          else
            setactive(self.ui.mTrans_WeaponAttribute2, true)
            self.ui.mText_PickUpWeapon2Name.text = weaponData.name.str
            pickUp = "," .. pickUp .. weaponData.name.str
            self.ui.mImg_ElementIcon2.sprite = IconUtils.GetElementIcon(elementData.icon)
          end
        end
      end
      setactive(self.ui.mTrans_GrpListDuty, data.Type == 1)
      setactive(self.ui.mTrans_Date, false)
      setactive(self.ui.mTrans_Chr, data.Type == 1 or data.Type == 3)
      setactive(self.ui.mTrans_Weapon, data.Type == 2 or data.Type == 4)
      self.ui.mText_Time.text = data.Start .. "-" .. data.End
      setactive(self.ui.mCount_Up, data.EndTime ~= 0)
      setactive(self.ui.mCount_Order, data.EndTime ~= 0)
    end
  else
    self.upSwitchTimer = TimerSys:DelayCall(0.2, function()
      setactive(self.ui.mTrans_GrpNew, false)
      setactive(self.ui.mTrans_GrpOrder, false)
      if data.EndTime ~= 0 then
        self.ui.mCount_Up:StartCountdown(data.EndTime)
      end
      setactive(self.ui.mTrans_PreviewRedpoint, not GashaponNetCmdHandler:CheckPoolPreviewed(self.mCurActivityId))
      self.ui.mText_UpName.text = data.GunUpCharacterName
      self.ui.mText_UpTitle.text = data.Name
      self:PlayVideo(data.GunUpCharacterVideo)
      setactive(self.ui.mCount_Up, data.EndTime ~= 0)
      setactive(self.ui.mCount_Order, data.EndTime ~= 0)
      if self.upSwitchTimer ~= nil then
        self.upSwitchTimer:Stop()
        self.upSwitchTimer = nil
      end
    end)
  end
  self.ui.mText_OptionNum.text = math.min(TableData.GlobalSystemData.GachaSelfSelectedProcess, GashaponNetCmdHandler.GachaOptionalTimes) .. "/" .. TableData.GlobalSystemData.GachaSelfSelectedProcess
  setactive(self.ui.mTrans_OptionalRedPoint, GashaponNetCmdHandler.GachaOptionalTimes >= TableData.GlobalSystemData.GachaSelfSelectedProcess)
  setactive(self.ui.mTrans_OptionalRedPointFx, GashaponNetCmdHandler.GachaOptionalTimes >= TableData.GlobalSystemData.GachaSelfSelectedProcess)
  setactive(self.ui.mTrans_GrpNum, false)
  setactive(self.ui.mTrans_GrpUp, data.GunUpCharacter ~= 0)
  self.ui.mText_RandomNum.text = self:GetRandomNum()
  self:RefreshText()
  GashaponNetCmdHandler:UpdateCounter()
end
function UIGachaMainPanelV2:PlayVideo(filename)
  local tmpPath = "Gacha/" .. filename .. ".usm"
  self.ui.mVideo_Bg:PlayClipPath(tmpPath)
end
function UIGachaMainPanelV2:GetRandomNum()
  local alphaPool = {
    "A",
    "B",
    "C",
    "D",
    "E",
    "H",
    "K",
    "M",
    "N",
    "P",
    "R",
    "S",
    "V",
    "Y"
  }
  return alphaPool[math.random(1, 14)] .. math.random(100, 999) .. " - " .. math.random(100, 999) .. " - " .. math.random(100, 999)
end
function UIGachaMainPanelV2:RefreshText()
  local imgOne = self.ui.mImg_OneIcon
  local imgTen = self.ui.mImg_TenIcon
  local txtOne = self.ui.mText_OneNum
  local txtTen = self.ui.mText_TenNum
  local txtLeftTime = self.ui.mText_LeftTime
  if self.mCurGachaData.GunUpCharacter ~= 0 then
    imgOne = self.ui.mImg_UpOneIcon
    imgTen = self.ui.mImg_UpTenIcon
    txtOne = self.ui.mText_UpOneNum
    txtTen = self.ui.mText_UpTenNum
    txtLeftTime = self.ui.mText_UpLeftTime
  end
  local ticketItem = TableData.GetItemData(self.mCurGachaData.CostItemID)
  imgTen.sprite = IconUtils.GetItemIconSprite(ticketItem.id)
  if self.mCurGachaData.Type ~= 5 then
    txtTen.text = "×10"
  else
    self.ui.mText_TenNumNew.text = "×8"
  end
  imgOne.sprite = IconUtils.GetItemIconSprite(ticketItem.id)
  txtOne.text = "×1"
  local count = NetCmdItemData:GetItemCountById(self.mCurGachaData.CostItemID)
  if count < 1 then
    if self.mCurGachaData.GunUpCharacter == 0 then
      txtOne.color = ColorUtils.RedColor
    else
      txtOne.color = ColorUtils.StringToColor("CE4848")
    end
  elseif self.mCurGachaData.GunUpCharacter == 0 then
    txtOne.color = ColorUtils.BlackColor
  else
    txtOne.color = ColorUtils.StringToColor("EFEFEF")
  end
  local tenNum = 10
  if self.mCurGachaData.Type == 5 then
    tenNum = 8
  end
  if count < tenNum then
    if self.mCurGachaData.GunUpCharacter == 0 then
      self.ui.mText_TenNumNew.color = ColorUtils.StringToColor("CE4848")
      txtTen.color = ColorUtils.RedColor
    else
      txtTen.color = ColorUtils.StringToColor("CE4848")
    end
  elseif self.mCurGachaData.GunUpCharacter == 0 then
    self.ui.mText_TenNumNew.color = ColorUtils.StringToColor("EFEFEF")
    txtTen.color = ColorUtils.BlackColor
  else
    txtTen.color = ColorUtils.StringToColor("EFEFEF")
  end
  local item = self.mTabDisplayItemList[self.curTab]
  if self.mCurGachaData.Type ~= 5 then
    txtLeftTime.text = TableData.GetHintReplaceById(107008, item.mEventData.RemainGachaTimes)
  else
    self.ui.mText_LeftTimeNew.text = TableData.GetHintById(260016)
    local gachaData = TableDataBase.listGachaDatas:GetDataById(self.mCurGachaData.GachaID)
    self.ui.mText_NewbieLeft.text = string_format("{0} {1}", TableData.GetHintById(103005), self.mCurGachaData.NoviceLimit - GashaponNetCmdHandler:GetGachaLimit(self.mCurGachaData.GachaID) .. "/" .. self.mCurGachaData.NoviceLimit)
  end
end
function UIGachaMainPanelV2:UnAllSelectEventTab()
  local count = self.mTabDisplayItemList:Count()
  for i = 1, count do
    local eventItem = self.mTabDisplayItemList[i]
    eventItem:SetSelect(false)
  end
end
function UIGachaMainPanelV2:ClearAllEventDropGunItem()
  local count = self.mEventDropGunItemList:Count()
  for i = 1, count do
    local eventItem = self.mEventDropGunItemList[i]
    gfdestroy(eventItem:GetRoot().gameObject)
  end
  self.mEventDropGunItemList:Clear()
end
function UIGachaMainPanelV2:OnShowStart()
  self.lastSceneType = SceneSys.CurSceneType
  self:UpdateView()
  if self.mCurGachaData and self.mCurGachaData.GunUpCharacter ~= 0 then
    self:PlayVideo(self.mCurGachaData.GunUpCharacterVideo)
  end
  self.DelayLoadGachaTimer = TimerSys:DelayCall(1, function()
    self:CheckGachaScene()
  end, nil)
  if self.mGachaSceneIsFinish == true then
    SceneSys:SwitchVisible(EnumSceneType.Gacha)
  end
  if self.switchTrigger ~= nil and self.switchTrigger == false then
    self.switchTrigger = true
    self.ui.mAnimator:SetTrigger("Switch")
  end
end
function UIGachaMainPanelV2:SetCameraRoot()
  self.mMainCameraNode = UIUtils.FindTransform(self.mMainNodePath)
end
function UIGachaMainPanelV2:OnOneTimeClicked(gameobj, isSuccess)
  if self.mIsDrawClicked and gameobj ~= nil then
    return
  end
  local cost = GashaponNetCmdHandler:GetCachaCostOne()
  local ticket = NetCmdItemData:GetResItemCount(self.mCurGachaData.CostItemID)
  local limitType = GashaponNetCmdHandler:GachaLimitType()
  local limitVisible = TableDataBase.GlobalSystemData.GachaLimitIsvisible
  if limitType ~= -1 and true == limitVisible then
    if GashaponNetCmdHandler.Limit - 1 < 0 then
      local limitmsg = TableData.GetHintById(107022)
      CS.PopupMessageManager.PopupString(limitmsg)
    elseif cost > ticket then
      local diamondCost = self.mDiamond2TicketRate
      local num = cost
      local ticketItem = TableData.GetItemData(self.mCurGachaData.CostItemID)
      QuickStorePurchase.QuickPurchase(self, ticketItem.Goodsid, 1, 107012, self, function(ret)
        self:OnBuyTicketCallBack_1(ret)
      end, function()
        self:DrawCancelled()
      end)
    else
      local msg = TableData.GetHintById(107011)
      msg = string_format(msg, "1", TableData.GetItemData(self.mCurGachaData.CostItemID).name.str, "1")
      local limitmsg = self.ui.mText_Tips.text
      msg = msg .. "\n" .. limitmsg
      MessageBox.Show(TableData.GetHintById(64), msg, nil, function()
        self:DrawOneTime()
      end, function()
        self:DrawCancelled()
      end)
      self.mIsDrawClicked = true
    end
  elseif cost > ticket and isSuccess == nil then
    local diamondCost = self.mDiamond2TicketRate
    local num = cost
    local ticketItem = TableData.GetItemData(self.mCurGachaData.CostItemID)
    QuickStorePurchase.QuickPurchase(self, ticketItem.Goodsid, 1, 107012, self, function(ret)
      self:OnBuyTicketCallBack_1(ret)
    end, function()
      self:DrawCancelled()
    end)
  else
    local msg = TableData.GetHintById(107011)
    msg = string_format(msg, "1", TableData.GetItemData(self.mCurGachaData.CostItemID).name.str, "1")
    MessageBox.Show(TableData.GetHintById(64), msg, nil, function(param)
      self:DrawOneTime(param)
    end, function()
      self:DrawCancelled()
    end)
    self.mIsDrawClicked = true
  end
end
function UIGachaMainPanelV2:OnTenTimeClicked(gameobj, isSuccess)
  if self.mIsDrawClicked and gameobj ~= nil then
    return
  end
  local cost = GashaponNetCmdHandler:GetCachaCostTen()
  local ticket = NetCmdItemData:GetResItemCount(self.mCurGachaData.CostItemID)
  local limitType = GashaponNetCmdHandler:GachaLimitType()
  local limitVisible = TableDataBase.GlobalSystemData.GachaLimitIsvisible
  local tenNum = 10
  if self.mCurGachaData.Type == 5 then
    tenNum = 8
    cost = 8
  end
  if limitType ~= -1 and true == limitVisible then
    if GashaponNetCmdHandler.Limit - tenNum < 0 then
      local limitmsg = TableData.GetHintById(107022)
      CS.PopupMessageManager.PopupString(limitmsg)
    elseif ticket < cost then
      local num = cost - ticket
      local diamondCost = self.mDiamond2TicketRate * num
      local ticketItem = TableData.GetItemData(self.mCurGachaData.CostItemID)
      QuickStorePurchase.QuickPurchase(self, ticketItem.Goodsid, num, 107012, self, function(ret)
        self:OnBuyTicketCallBack_2(ret)
      end, function()
        self:DrawCancelled()
      end)
    else
      local msg = TableData.GetHintById(107011)
      msg = string_format(msg, tostring(tenNum), TableData.GetItemData(self.mCurGachaData.CostItemID).name.str, "10")
      local limitmsg = self.ui.mText_Tips.text
      msg = msg .. "\n" .. limitmsg
      MessageBox.Show(TableData.GetHintById(64), msg, nil, function(param)
        self:DrawTenTime(param)
      end, function()
        self:DrawCancelled()
      end)
      self.mIsDrawClicked = true
    end
  elseif ticket < cost and isSuccess == nil then
    local num = cost - ticket
    local diamondCost = self.mDiamond2TicketRate * num
    local ticketItem = TableData.GetItemData(self.mCurGachaData.CostItemID)
    QuickStorePurchase.QuickPurchase(self, ticketItem.Goodsid, num, 107012, self, function(ret)
      self:OnBuyTicketCallBack_2(ret)
    end, function()
      self:DrawCancelled()
    end)
  else
    local msg = TableData.GetHintById(107011)
    msg = string_format(msg, tostring(tenNum), TableData.GetItemData(self.mCurGachaData.CostItemID).name.str, "10")
    MessageBox.Show(TableData.GetHintById(64), msg, nil, function(param)
      self:DrawTenTime(param)
    end, function()
      self:DrawCancelled()
    end)
    self.mIsDrawClicked = true
  end
end
function UIGachaMainPanelV2:DrawOneTime(param)
  GashaponNetCmdHandler:SendReqGachaOneTime(self.mCurActivityId, function(ret)
    self.mIsDrawClicked = false
  end)
  self:LimitTimesRefresh()
end
function UIGachaMainPanelV2:DrawTenTime(param)
  GashaponNetCmdHandler:SendReqGachaTenTime(self.mCurActivityId, function(ret)
    self.mIsDrawClicked = false
  end)
  self:LimitTimesRefresh()
end
function UIGachaMainPanelV2:BuyTicket(param)
  local num = param
  NetCmdItemData:SendCmdRoleDiamondToItem(111, num, function()
    self:OnBuyTicketCallBack()
  end)
end
function UIGachaMainPanelV2:OnBuyTicketCallBack_1(ret)
  if ret == ErrorCodeSuc then
    gfdebug("购买扭蛋券成功")
    self:OnOneTimeClicked(nil, true)
    self:RefreshText()
  else
    gfdebug("购买扭蛋券失败")
    MessageBox.Show(TableData.GetHintById(120143), TableData.GetHintById(107071), MessageBox.ShowFlag.eMidBtn, nil, nil, nil)
    self.mIsDrawClicked = false
  end
end
function UIGachaMainPanelV2:OnBuyTicketCallBack_2(ret)
  if ret == ErrorCodeSuc then
    gfdebug("购买扭蛋券成功")
    self:OnTenTimeClicked(nil, true)
    self:RefreshText()
  else
    gfdebug("购买扭蛋券失败")
    MessageBox.Show(TableData.GetHintById(120143), TableData.GetHintById(107071), MessageBox.ShowFlag.eMidBtn, nil, nil, nil)
    self.mIsDrawClicked = false
  end
end
function UIGachaMainPanelV2:DrawCancelled(param)
  self.mIsDrawClicked = false
end
function UIGachaMainPanelV2:OnItemClicked(gameObj)
  local btnTrigger = getcomponent(gameObj, typeof(CS.EventTriggerListener))
  if btnTrigger ~= nil and btnTrigger.param ~= nil then
    local item = btnTrigger.param
    if item.mIsBeingLongPressed == true then
      item.mIsBeingLongPressed = false
      return
    end
    if item.mIsFlipped == true then
      return
    end
    self.FlipStart(item)
    self.FlipEnd(item)
  end
end
function UIGachaMainPanelV2:HidePanel()
  UISystem:SetMainCamera(true)
  setactive(self.mUIRoot.gameObject, false)
end
function UIGachaMainPanelV2:ShowPanel()
  UISystem:SetMainCamera(false)
  setactive(self.mUIRoot.gameObject, true)
end
function UIGachaMainPanelV2:OnTop(data)
  setactive(self.ui.mTrans_GrpNum, false)
  SceneSys:SwitchVisible(EnumSceneType.Gacha)
end
function UIGachaMainPanelV2:OnGachaListClicked(gameobj)
  SceneSwitch:SwitchByID(5003)
end
function UIGachaMainPanelV2:OnReturnClick()
  if CS.SceneSys.Instance.IsLoading then
    return
  end
  self.Close()
  UISystem:ClearUIStacks()
  self.curTab = 1
  SceneSys:ReturnMain(false)
end
function UIGachaMainPanelV2:OnClose()
  MessageSys:RemoveListener(CS.GF2.Message.GashaponEvent.GashaponAcquire, self.OnGetGashapon)
  MessageSys:RemoveListener(CS.GF2.Message.CommonEvent.ItemUpdate, self.UpdateView)
  MessageSys:RemoveListener(CS.GF2.Message.CampaignEvent.ResInfoUpdate, self.UpdateView)
  MessageSys:RemoveListener(CS.GF2.Message.GashaponEvent.SwitchByActivityID, self.OnSwitchByActivityID)
  MessageSys:RemoveListener(UIEvent.GashaAirportPlayable, self.refreshGashaAirportPlayable)
  MessageSys:RemoveListener(UIEvent.GashaShowResult, self.gashaShowResultFunc)
  MessageSys:RemoveListener(UIEvent.GachaSceneLoadFinish, self.OnGachaSceneLoad)
  if self.mCountDownTimer ~= nil then
    self.mCountDownTimer:Stop()
  end
  for i = 1, #self.mEffectList do
    ResourceManager:DestroyInstance(self.mEffectList[i])
  end
  for i = 1, #self.mShakeList do
    ResourceManager:DestroyInstance(self.mShakeList[i])
  end
  setactive(self.ui.mTrans_GrpOrder, false)
  self.mGachaBanner = nil
  self.lastSceneType = nil
  self.mClickedHome = false
  self.mIsDrawClicked = false
  self.mCacheBackgroundSprite = {}
  self.mCacheBannerSprite = {}
  self.mCacheDescSprite = {}
  self.mEffectList = {}
  self.mShakeList = {}
  self.mGashaAirportPlayable = nil
  self.mBg = nil
  self.ui = nil
  for _, item in pairs(self.mTabDisplayItemList) do
    item:OnRelease(true)
  end
  self.mTabDisplayItemList:Clear()
  self.mEventDropGunItemList:Clear()
  NetCmdAchieveData:GashaponEnd()
  if self.upSwitchTimer ~= nil then
    TimerSys:RemoveTimer(self.upSwitchTimer)
    self.upSwitchTimer = nil
  end
  if self.mAnimTimer ~= nil then
    self.mAnimTimer:Stop()
    self.mAnimTimer = nil
  end
  if self.DelayLoadGachaTimer ~= nil then
    TimerSys:RemoveTimer(self.DelayLoadGachaTimer)
    self.DelayLoadGachaTimer = nil
  end
  if self.gachaScene ~= nil then
    self.gachaScene:SetDefaultObjs(false)
    self.gachaScene:StartUnloadScene()
    self.gachaScene = nil
  end
end
function UIGachaMainPanelV2:OnHide()
  self.ui.mVideo_Bg:Stop()
end
