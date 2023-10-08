require("UI.StoreExchangePanel.Item.UIStoreBuyItem")
require("UI.StoreExchangePanel.Item.UIStoreBuySkinItem")
require("UI.StoreExchangePanel.Item.UIStoreCreditItem")
require("UI.FacilityBarrackPanel.Content.UIModelToucher")
require("UI.Common.UICommonLeftTabItemV2")
require("UI.UIBasePanel")
require("UI.StoreExchangePanel.UIStoreGlobal")
require("UI.SimpleMessageBox.SimpleMessageBoxPanel")
require("UI.Repository.Item.UIRepositoryLeftTab2ItemV3")
UIStorePanelV2 = class("UIStorePanelV2", UIBasePanel)
UIStorePanelV2.__index = UIStorePanelV2
function UIStorePanelV2:ctor(csPanel)
  UIStorePanelV2.super.ctor(self)
  self.mCSPanel = csPanel
end
function UIStorePanelV2.Open()
  UIStorePanelV2.OpenUI(UIDef.UIStorePanel)
end
function UIStorePanelV2:Close()
  if not self.isClosing then
    MessageSys:SendMessage(UIEvent.PrepareCloseStore, nil)
    self.isClosing = true
    TimerSys:DelayCall(1, function()
      UIManager.CloseUI(UIDef.UIStorePanel)
    end)
  end
end
function UIStorePanelV2:OpenCharge()
  if self.ui ~= nil then
    local data = TableData.listStoreSidetagDatas:GetDataById(12)
    self:OnClickTab(data)
  else
    UIManager.OpenUIByParam(UIDef.UIStorePanel, 12)
  end
end
function UIStorePanelV2:OnInit(root, data)
  UIStorePanelV2.super.SetRoot(UIStorePanelV2, root)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  if data and type(data) == "userdata" then
    self.fromData = data[0]
    self.curTopTagIndex = data[1]
  else
    self.fromData = data
  end
  self.tabList = {}
  self.topTabList = {}
  self.creditItemList = {}
  self.goodItemList = {}
  self.skinItemList = {}
  self:InitTabButton()
  SceneSys:OpenStoreScene()
  self.checkMayling = false
  self:SetMaylingInfo()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    self:Close()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    self.isClosing = true
    UIManager.JumpToMainPanel()
  end
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Back)
  local storeMouseClick = self.ui.mTrans_Mayling:GetComponent(typeof(CS.StoreMouseClick))
  if storeMouseClick ~= nil then
    storeMouseClick:SetClickEvent(function()
      MessageSys:SendMessage(UIEvent.OnInteractMaylingInStore, 1)
    end)
  end
  function self.OnJumpCreditCoin()
    if self.ui ~= nil then
      self:OpenCharge()
    end
  end
  function self.OnCloseCommonReceivePanel()
    if self.mCSPanel.UIGroup:GetTopUI() == self.mCSPanel and self.ui ~= nil then
      self:ShowStart(true)
    end
  end
  MessageSys:AddListener(UIEvent.OnCloseCommonReceivePanel, self.OnCloseCommonReceivePanel)
  MessageSys:AddListener(UIEvent.JumpCreditCoin, self.OnJumpCreditCoin)
end
function UIStorePanelV2:OnSave()
  printstack("    self.curTab         " .. self.curTab)
  self.curTabIndex = self.curTab
end
function UIStorePanelV2:OnRecover()
  if self.curTabIndex == nil or self.curTabIndexeTopTagIndex == 0 then
    return
  end
  local data = TableData.listStoreSidetagDatas:GetDataById(self.curTabIndex)
  if data ~= nil then
    self:OnClickTab(data)
  end
end
function UIStorePanelV2:InitTabButton()
  local list = TableData.listStoreSidetagBySidetagTypeDatas:GetDataById(1)
  for i = 0, list.Id.Count - 1 do
    local id = list.Id[i]
    local data = TableData.listStoreSidetagDatas:GetDataById(id)
    local item = UIRepositoryLeftTab2ItemV3.New()
    item:InitCtrl(self.ui.mTrans_LeftTabContent)
    item:SetName(data.id, data.name.str)
    item.ui.mText_Name.text = data.name.str
    local isLock = not AccountNetCmdHandler:CheckSystemIsUnLock(data.unlock)
    item:SetLock(isLock)
    if data.GlobalTab then
      item:SetGlobalTabId(data.GlobalTab)
    end
    UIUtils.GetButtonListener(item.ui.mBtn_ComTab1ItemV2.gameObject).onClick = function()
      if AccountNetCmdHandler:CheckSystemIsUnLock(data.unlock) then
        self:OnClickTab(data)
      else
        local unlockData = TableData.listUnlockDatas:GetDataById(data.unlock)
        local str = UIUtils.CheckUnlockPopupStr(unlockData)
        PopupMessageManager.PopupString(str)
      end
    end
    self.tabList[id] = item
    if i == 0 and self.fromData == nil then
      self:OnClickTab(data)
    elseif self.fromData == id then
      self:OnClickTab(data)
    end
  end
end
function UIStorePanelV2:InitTopTabButton(data)
  for i = 1, #self.topTabList do
    setactive(self.topTabList[i].mUIRoot, false)
  end
  for i = 0, data.include_tag.Count - 1 do
    do
      local id = data.include_tag[i]
      if id ~= 103 then
        local tagData = TableData.listStoreTagDatas:GetDataById(id)
        local item
        if self.topTabList[i + 1] == nil then
          item = UIComTabBtn1Item.New()
          item:InitCtrl(self.ui.mTrans_TopTabContent)
          table.insert(self.topTabList, item)
        else
          item = self.topTabList[i + 1]
          setactive(item.mUIRoot, true)
        end
        item.tagData = tagData
        item.mText_Name.text = tagData.name.str
        UIUtils.GetButtonListener(item.mBtn_Item.gameObject).onClick = function()
          self:OnClickTopTab(i + 1)
        end
        if i == 0 and self.curTopTagIndex == nil then
          self:OnClickTopTab(i + 1)
        elseif self.curTopTagIndex == id then
          self:OnClickTopTab(i + 1)
        end
      end
    end
  end
end
function UIStorePanelV2:OnClickTab(data)
  if self.curTab == data.id then
    return
  end
  if self.curTab ~= nil and self.curTab > 0 then
    local lastTab = self.tabList[self.curTab]
    lastTab:SetItemState(false)
  end
  local curTab = self.tabList[data.id]
  curTab:SetItemState(true)
  self.curTab = data.id
  setactive(self.ui.mTrans_MonthlyCardBuy, data.id == 11)
  setactive(self.ui.mTrans_CreditBuy, data.id == 12)
  setactive(self.ui.mTrans_ComBuy, data.id > 12 and data.id < 15)
  setactive(self.ui.mTrans_GrpSkin, data.id == 15)
  if data.include_tag.Count > 1 then
    self:InitTopTabButton(data)
  else
    local tagData = TableData.listStoreTagDatas:GetDataById(data.include_tag[0])
    self.curTagData = tagData
    self:RefreshItems(tagData)
  end
  MessageSys:SendMessage(GuideEvent.OnTabSwitched, UIDef.UIStorePanel, curTab:GetGlobalTab())
end
function UIStorePanelV2:IsMaylingLevelUp(current, level)
  local start = 1
  local next = TableData.listStoreCashRewardDatas:GetDataById(level + start, true)
  while next ~= nil do
    if current <= next.affection then
      return next.level - 1
    else
      start = start + 1
      next = TableData.listStoreCashRewardDatas:GetDataById(level + start, true)
    end
  end
  return level + start - 1
end
function UIStorePanelV2:SetMaylingInfo()
  local level = NetCmdStoreData.Mayling.Level
  self.curLevel = TableData.listStoreCashRewardDatas:GetDataById(level)
  self.nextLevel = TableData.listStoreCashRewardDatas:GetDataById(level + 1, true)
  if self.nextLevel == nil then
    self.nextLevel = self.curLevel
    self.curLevel = TableData.listStoreCashRewardDatas:GetDataById(NetCmdStoreData.Mayling.Level - 1)
  end
end
function UIStorePanelV2:AddMaylingByKakin(value)
  MessageSys:SendMessage(UIEvent.OnInteractMaylingInStore, 3)
  self:CheckUpdate()
end
function UIStorePanelV2:CheckUpdate()
  local curLevel = NetCmdStoreData.Mayling.Level
  local nextLevel = self:IsMaylingLevelUp(NetCmdStoreData.Mayling.Favor, curLevel)
  if curLevel < nextLevel then
    NetCmdStoreData:MaylingLevelUp(nextLevel, function()
      MessageSys:SendMessage(UIEvent.OnInteractMaylingInStore, 2)
      TimerSys:DelayCall(1.5, function()
        UIManager.OpenUI(UIDef.UICommonReceivePanel)
      end)
      setactive(self.mGunModelObj.hvfx, true)
      self:ShowUIFX(true)
    end)
  else
    self:ShowUIFX(false)
  end
end
function UIStorePanelV2:OnClickTopTab(id)
  if self.curTopTab == id or id == nil or id <= 0 then
    return
  end
  if self.curTopTab > 0 then
    local lastTab = self.topTabList[self.curTopTab]
    lastTab:SetSelect(false)
  end
  local curTab = self.topTabList[id]
  curTab:SetSelect(true)
  self.curTopTab = id
  self.curTagData = curTab.tagData
  self:RefreshItems(curTab.tagData)
end
function UIStorePanelV2:RefreshTagRedPoint()
  for i, v in pairs(self.tabList) do
    local showTagRedPoint = false
    local storeSidetagData = TableData.listStoreSidetagDatas:GetDataById(v.tagId)
    if storeSidetagData ~= nil then
      for i = 0, storeSidetagData.include_tag.Count - 1 do
        showTagRedPoint = NetCmdStoreData:GetGiftRedPoint(storeSidetagData.include_tag[i]) == 1
      end
    end
    setactive(v.ui.mTrans_RedPoint, showTagRedPoint)
    if v.tagId == 15 then
      setactive(v.ui.mTrans_RedPoint, 0 < NetCmdStoreData:GetSkinStoreRedPoint())
    end
  end
end
function UIStorePanelV2:RefreshItems(tagData, skipAnim)
  for i, v in pairs(self.creditItemList) do
    setactive(v:GetRoot(), false)
  end
  self:RefreshTagRedPoint()
  if tagData.id == 101 then
    local goods = NetCmdStoreData:GetStoreGoodListByTag(tagData.id)
    local index = 1
    for i = 0, goods.Count - 1 do
      local data = goods[i]
      local item
      if self.creditItemList[i + 1] == nil then
        item = UIStoreCreditItem.New()
        item:InitCtrl(self.ui.mTrans_CreditContent)
        table.insert(self.creditItemList, item)
      else
        item = self.creditItemList[i + 1]
      end
      item:SetData(data, self)
      setactive(item:GetRoot(), true)
    end
    if not skipAnim then
      self.ui.mTrans_CreditContent.transform:GetComponent(typeof(CS.MonoScrollerFadeManager)).enabled = false
      self.ui.mTrans_CreditContent.transform:GetComponent(typeof(CS.MonoScrollerFadeManager)).enabled = true
    end
  elseif tagData.id == 107 then
    self:RefreshSkinTag(tagData, skipAnim)
  elseif tagData.id > 103 then
    for i = 1, #self.goodItemList do
      setactive(self.goodItemList[i]:GetRoot(), false)
    end
    for i = 1, #self.skinItemList do
      setactive(self.skinItemList[i]:GetRoot(), false)
    end
    local goods = NetCmdStoreData:GetSortedStoreGoodListByTag(tagData.id)
    local index = 0
    for i = 0, goods.Count - 1 do
      local data = goods[i]
      if data:IsShow() then
        local item
        index = index + 1
        if self.goodItemList[index] == nil then
          item = UIStoreBuyItem.New()
          item:InitCtrl(self.ui.mTrans_BuyContent)
          table.insert(self.goodItemList, item)
        else
          item = self.goodItemList[index]
        end
        setactive(item:GetRoot(), true)
        item:SetData(data, self)
      end
    end
    if not skipAnim then
      self.ui.mTrans_BuyContent.transform:GetComponent(typeof(CS.MonoScrollerFadeManager)).enabled = false
      self.ui.mTrans_BuyContent.transform:GetComponent(typeof(CS.MonoScrollerFadeManager)).enabled = true
    end
  else
    local goods = NetCmdStoreData:GetStoreGoodListByTag(tagData.id)
    local goodData = goods[0]
    self:UpdateBigMonthly(goodData)
    self:UpdateLittleMonthly(goods[1])
  end
  if tagData.id ~= 107 then
    MessageSys:SendMessage(UIEvent.SetStoreVisible, true)
    if not self.ui.mTrans_Mayling.gameObject.activeSelf then
      setactive(self.ui.mTrans_Mayling.gameObject, true)
      self.ui.mAnimator_Root:SetTrigger("MaylingFadeIn")
    end
  end
end
function UIStorePanelV2:RefreshSkinTag(tagData, skipAnim)
  MessageSys:SendMessage(UIEvent.SetStoreVisible, false)
  setactive(self.ui.mTrans_Mayling.gameObject, false)
  for i = 1, #self.goodItemList do
    setactive(self.goodItemList[i]:GetRoot(), false)
  end
  for i = 1, #self.skinItemList do
    setactive(self.skinItemList[i]:GetRoot(), false)
  end
  local goods = NetCmdStoreData:GetSortedStoreGoodListByTag(tagData.id)
  local index = 0
  local sortGoods = {}
  for i = 0, goods.Count - 1 do
    table.insert(sortGoods, goods[i])
  end
  table.sort(sortGoods, function(a, b)
    if self:CheckSkinGoodIsbuy(a) == self:CheckSkinGoodIsbuy(b) then
      return a.id > b.id
    end
    return not self:CheckSkinGoodIsbuy(a)
  end)
  for i = 1, #sortGoods do
    local data = sortGoods[i]
    if data:IsShow() then
      local item
      index = index + 1
      if self.skinItemList[index] == nil then
        item = UIStoreBuySkinItem.New()
        item:InitCtrl(self.ui.mSListChild_Content2.transform)
        table.insert(self.skinItemList, item)
      else
        item = self.skinItemList[index]
      end
      setactive(item:GetRoot(), true)
      item:SetData(data, self)
    end
  end
  if not skipAnim then
    setactive(self.ui.mTrans_BuyContent, false)
    setactive(self.ui.mTrans_BuyContent, true)
  end
end
function UIStorePanelV2:CheckSkinGoodIsbuy(storeData)
  local itemId = storeData.ItemNumList[0].itemid
  local itemData = TableData.GetItemData(itemId)
  if itemData == nil then
    return 0
  end
  local skinCount = NetCmdIllustrationData:GetCountByTypeAndItemId(tonumber(GlobalConfig.ItemType.Costume), tonumber(itemData.args[0]))
  return 0 < skinCount
end
function UIStorePanelV2:OnUpdate(deltaTime)
  if self.MaylingLevelFade then
    self.deltaTime = self.deltaTime + deltaTime
    local percent = self.deltaTime / 0.266
    if 1 <= percent then
      self.MaylingLevelFade = nil
      self:SetMaylingInfo()
      TimerSys:DelayCall(1.5, function()
        if self.ui ~= nil then
          self.ui.mAnimator_Root:SetTrigger("NPCInfo_FadeOut")
        end
      end)
    else
    end
  else
    self.deltaTime = 0
  end
  if self.skinItemList ~= nil then
    for i = 1, #self.skinItemList do
      self.skinItemList[i]:Update()
    end
  end
  if self.goodItemList ~= nil then
    for i = 1, #self.goodItemList do
      self.goodItemList[i]:Update()
    end
  end
end
function UIStorePanelV2:UpdateLittleMonthly(goodData)
  local stcData = goodData:GetStoreGoodData()
  self.ui.mText_Buy.text = "¥" .. goodData.price
  local curMonthlyItemId = 0
  local rewards = string.split(string.sub(stcData.reward, 1, -2), ",")
  for i = 1, #rewards do
    local itemArr = string.split(rewards[i], ":")
    local itemId = tonumber(itemArr[1])
    local itemData = TableData.GetItemData(itemId)
    local args = string.split(string.sub(itemData.args_str, 1, -2), ",")
    local currentTime = CGameTime:GetTimestamp()
    local monthCard = AccountNetCmdHandler:GetMonthCardById(itemId)
    if monthCard ~= nil and currentTime < monthCard.InvalidTime then
      local leftDays = CS.TimeUtils.LeftTimeToDays(monthCard.InvalidTime - currentTime)
      self.ui.mText_Time.text = string_format(TableData.GetHintById(106019), leftDays)
      setactive(self.ui.mTrans_NormalTitle, true)
    else
      self.ui.mText_Time.text = ""
      setactive(self.ui.mTrans_NormalTitle, false)
    end
    if i == 1 then
      curMonthlyItemId = itemId
    end
  end
  local bigMonthCard = TableData.listMonthCardDatas:GetDataById(curMonthlyItemId)
  if bigMonthCard == nil then
    return
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Buy.gameObject).onClick = function()
    local monthCard = AccountNetCmdHandler:GetMonthCardById(curMonthlyItemId)
    if monthCard and monthCard.InvalidTime - CGameTime:GetTimestamp() > (bigMonthCard.maxduration - 30) * 24 * 60 * 60 then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(106045))
      return
    end
    NetCmdStoreData:SendStoreOrder(goodData:GetStoreGoodData().id, function(ret)
      local userDropCache = NetCmdItemData:GetUserDropCache()
      if userDropCache.Count > 0 then
        UIManager.OpenUIByParam(UIDef.UICommonReceivePanel)
      end
      CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(106013))
      self.AddPoint = tonumber(goodData.price)
      self:UpdateLittleMonthly(goodData)
      RedPointSystem:GetInstance():UpdateRedPointByType(RedPointConst.Store)
      self:RefreshTagRedPoint()
      self:AddMaylingByKakin()
      MessageSys:SendMessage(CS.GF2.Message.OssEvent.BuyMonthCardLog, nil)
    end)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Icon.gameObject).onClick = function()
    SimpleMessageBoxPanel.ShowByParam(bigMonthCard.title, bigMonthCard.DescDetail)
  end
  self.ui.mText_Name.text = goodData.name
  self.ui.mText_Info.text = bigMonthCard.desc_brief
end
function UIStorePanelV2:UpdateBigMonthly(goodData)
  local stcData = goodData:GetStoreGoodData()
  self.ui.mText_Buy1.text = "¥" .. goodData.price
  local curMonthlyItemId = 0
  local rewards = string.split(string.sub(stcData.reward, 1, -2), ",")
  for i = 1, #rewards do
    local itemArr = string.split(rewards[i], ":")
    local itemId = tonumber(itemArr[1])
    local itemData = TableData.GetItemData(itemId)
    local args = string.split(string.sub(itemData.args_str, 1, -2), ",")
    local currentTime = CGameTime:GetTimestamp()
    local monthCard = AccountNetCmdHandler:GetMonthCardById(itemId)
    if monthCard ~= nil and currentTime < monthCard.InvalidTime then
      local leftDays = CS.TimeUtils.LeftTimeToDays(monthCard.InvalidTime - currentTime)
      self.ui.mText_Time1.text = string_format(TableData.GetHintById(106019), leftDays)
      setactive(self.ui.mTrans_PlusTitle, true)
    else
      self.ui.mText_Time1.text = ""
      setactive(self.ui.mTrans_PlusTitle, false)
    end
    if i == 1 then
      curMonthlyItemId = itemId
    end
  end
  local bigMonthCard = TableData.listMonthCardDatas:GetDataById(curMonthlyItemId)
  if bigMonthCard == nil then
    return
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Buy1.gameObject).onClick = function()
    local monthCard = AccountNetCmdHandler:GetMonthCardById(curMonthlyItemId)
    if monthCard and monthCard.InvalidTime - CGameTime:GetTimestamp() > (bigMonthCard.maxduration - 30) * 24 * 60 * 60 then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(106045))
      return
    end
    NetCmdStoreData:SendStoreOrder(goodData:GetStoreGoodData().id, function(ret)
      local userDropCache = NetCmdItemData:GetUserDropCache()
      if userDropCache.Count > 0 then
        UIManager.OpenUIByParam(UIDef.UICommonReceivePanel)
      else
        self:AddMaylingByKakin()
      end
      printstack("打印飘字  " .. TableData.GetHintById(106013))
      CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(106013))
      self.AddPoint = tonumber(goodData.price)
      self:UpdateBigMonthly(goodData)
      RedPointSystem:GetInstance():UpdateRedPointByType(RedPointConst.Store)
      self:RefreshTagRedPoint()
      MessageSys:SendMessage(CS.GF2.Message.OssEvent.BuyMonthCardLog, nil)
    end)
  end
  self.ui.mText_Name1.text = goodData.name
  UIUtils.GetButtonListener(self.ui.mBtn_Icon1.gameObject).onClick = function()
    SimpleMessageBoxPanel.ShowByParam(bigMonthCard.title, bigMonthCard.DescDetail)
  end
  self.ui.mText_Info1.text = bigMonthCard.desc_brief
end
function UIStorePanelV2:OnHide()
  MessageSys:SendMessage(UIEvent.SetStoreVisible, false)
end
function UIStorePanelV2:OnBackFrom()
  MessageSys:SendMessage(UIEvent.SetStoreVisible, true)
  if self.curTagData ~= nil then
    self:RefreshItems(self.curTagData)
  end
end
function UIStorePanelV2:SetLookAtCharacter(obj)
  if self.mCharacterSelfShadowSettings ~= nil then
    self.mCharacterSelfShadowSettings:SetLookAtCharacter(obj)
  end
end
function UIStorePanelV2:OnShowStart()
  self.isHide = false
  MessageSys:SendMessage(UIEvent.SetStoreVisible, true)
  self:ShowStart(true)
end
function UIStorePanelV2:ShowStart(skipAnim)
  self:RefreshItems(self.curTagData, skipAnim)
  self:AddMaylingByKakin()
  if self.AddPoint ~= nil and self.AddPoint > 0 then
    self.AddPoint = nil
  else
    self:CheckUpdate()
  end
end
function UIStorePanelV2:OnShowFinish()
  RedPointSystem:GetInstance():UpdateRedPointByType(RedPointConst.Store)
  self:RefreshTagRedPoint()
end
function UIStorePanelV2:ShowUIFX(isLevelUp)
  if isLevelUp then
    self.mCSPanel:Block()
  else
    self.ui.mCanvasGroup_Root.blocksRaycasts = false
  end
  self.ui.mAnimator_Root:ResetTrigger("NPCInfo_FadeOut")
  self.ui.mAnimator_Root:SetTrigger("NPCInfo_FadeIn")
  TimerSys:DelayCall(0.5, function()
    if isLevelUp then
      self.ui.mAnimator_Root:SetTrigger("NPCInfo_Fx")
      TimerSys:DelayCall(0.733, function()
        self:SetMaylingInfo()
        if self.nextLevel ~= self.curLevel then
          self.beforeAmount = 0
          self.MaylingLevelFade = true
        end
      end)
    else
      self.MaylingLevelFade = true
    end
  end)
end
function UIStorePanelV2:OnClose()
  self:UnRegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Back)
  self.ui = nil
  self.curTab = nil
  self.curTagData = nil
  self.curTopTab = nil
  for _, v in pairs(self.tabList) do
    gfdestroy(v:GetRoot())
  end
  self.tabList = {}
  self.topTabList = {}
  for _, v in pairs(self.goodItemList) do
    gfdestroy(v:GetRoot())
  end
  for _, v in pairs(self.skinItemList) do
    gfdestroy(v:GetRoot())
  end
  self.goodItemList = {}
  self.skinItemList = {}
  for _, v in pairs(self.creditItemList) do
    gfdestroy(v:GetRoot())
  end
  self.creditItemList = {}
  MessageSys:SendMessage(UIEvent.OnCloseStore, nil)
  self.isClosing = nil
  MessageSys:RemoveListener(UIEvent.JumpCreditCoin, self.OnJumpCreditCoin)
  MessageSys:RemoveListener(UIEvent.OnCloseCommonReceivePanel, self.OnCloseCommonReceivePanel)
end
function UIStorePanelV2:OnTop()
  if self.block then
    self.mCSPanel:Block()
  end
end
