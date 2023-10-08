require("UI.Common.UIComTabBtn1Item")
require("UI.StoreExchangePanel.Item.ExchangeGoodsItem")
require("UI.UIBasePanel")
require("UI.UniTopbar.UITopResourceBar")
require("UI.StoreExchangePanel.Item.ExchangeTagItem")
require("UI.PVP.UIPVPGlobal")
UIPVPStoreExchangePanel = class("UIPVPStoreExchangePanel", UIBasePanel)
UIPVPStoreExchangePanel.__index = UIPVPStoreExchangePanel
UIPVPStoreExchangePanel.mTagButtons = nil
UIPVPStoreExchangePanel.mCurTagIndex = 0
UIPVPStoreExchangePanel.mCurSideTagIndex = 0
UIPVPStoreExchangePanel.curTopTagIndex = -1
UIPVPStoreExchangePanel.mStoreItems = {}
UIPVPStoreExchangePanel.mData = nil
UIPVPStoreExchangePanel.mTagTimer = nil
UIPVPStoreExchangePanel.mDefaultSelect = nil
UIPVPStoreExchangePanel.Instance = nil
UIPVPStoreExchangePanel.mTopTagItems = {}
UIPVPStoreExchangePanel.mUITopResourceBar = nil
UIPVPStoreExchangePanel.mRoot = nil
UIPVPStoreExchangePanel.ItemDataList = {}
UIPVPStoreExchangePanel.RedPointKey = "_PVPStoreRedPoint_"
function UIPVPStoreExchangePanel:ctor(csPanel)
  UIPVPStoreExchangePanel.super.ctor(self)
  self.mCSPanel = csPanel
end
function UIPVPStoreExchangePanel.Open(storeTagType, defaultTab)
  UIManager.OpenUIByParam(UIDef.UIPVPStoreExchangePanel, {storeTagType, defaultTab})
end
function UIPVPStoreExchangePanel.Close()
  self = UIPVPStoreExchangePanel
  UIManager.CloseUI(UIDef.UIPVPStoreExchangePanel)
end
function UIPVPStoreExchangePanel:OnInit(root, data)
  self = UIPVPStoreExchangePanel
  UIPVPStoreExchangePanel.super.SetRoot(UIPVPStoreExchangePanel, root)
  UIPVPStoreExchangePanel.Instance = self
  self.curStoreType = CS.GF2.Data.StoreTagType.Pvp
  if data and type(data) == "userdata" then
    self.mData = data[0]
    self.curTopTagIndex = data[1]
  else
    self.curStoreType = data[1]
    self.mData = data[2]
    self.curTopTagIndex = 213
  end
  self.mRoot = root
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.virtualList = self.ui.mVirtualList
  self.itemList = {}
  self.sortFunc = nil
  self.param = nil
  self.virtualList.itemProvider = self.ItemProvider
  self.virtualList.itemRenderer = self.ItemRenderer
  self.uid = AccountNetCmdHandler.Uid
  if self.mData ~= nil then
    self.mCurSideTagIndex = self.mData
    self.mData = nil
  else
    self.mCurSideTagIndex = TableData.GlobalSystemData.StoreexchangeDefaultTag
  end
  local sideTagData = TableData.listStoreSidetagDatas:GetDataById(self.mCurSideTagIndex)
  self:GetCurSideTagDefaultStoreTag(sideTagData)
  local storeTagData = TableData.listStoreTagDatas:GetDataById(self.mCurTagIndex)
  if storeTagData ~= nil then
    if self.topRes ~= nil then
      self.topRes:Release()
    end
    self.topRes = UITopResourceBar.New()
    self.topRes:Init(root, storeTagData.trade_item_list)
    UIPVPStoreExchangePanel.UpdateResourceBar(storeTagData)
  end
  self = UIPVPStoreExchangePanel
  self.mTagButtons = List:New()
  UIUtils.GetButtonListener(self.ui.mBtn_Return.gameObject).onClick = self.OnReturnClick
  self:InitTagButtons()
  self:InitStoreItems()
  function self.RefreshUnlockTipFun()
  end
  function self.storeGoodsRefresh()
    self:OnBuySuccess()
  end
  MessageSys:AddListener(CS.GF2.Message.UIEvent.BuySuccess, self.RefreshUnlockTipFun)
  MessageSys:AddListener(CS.GF2.Message.UIEvent.OnCloseCommonReceivePanel, self.storeGoodsRefresh)
  UIUtils.GetButtonListener(self.ui.mBtn_CommandCenter.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
end
function UIPVPStoreExchangePanel:OnShowFinish()
  if self.block then
    self.mCSPanel:Block()
    self.block = nil
  end
end
function UIPVPStoreExchangePanel:InitTagButtons()
  local storeSideTagList = TableData.listStoreSidetagDatas
  self.mTagButtons:Clear()
  for i = 0, self.ui.mTrans_ButtonList.transform.childCount - 1 do
    local obj = self.ui.mTrans_ButtonList.transform:GetChild(i)
    gfdestroy(obj)
  end
  local defaultChangeTag
  for i = 0, storeSideTagList.Count - 1 do
    local data = storeSideTagList[i]
    local hide = data.SidetagType == self.curStoreType:GetHashCode()
    if hide then
      if self.mCurSideTagIndex == 0 then
        self.mCurSideTagIndex = data.id
      end
      do
        local item = ExchangeTagItem.New()
        item:InitCtrl(self.ui.mTrans_ButtonList)
        item:InitData(data)
        UIUtils.GetButtonListener(item.ui.mBtn_Self.gameObject).onClick = function()
          if item.mIsLocked == true then
            local unlockData = TableData.listUnlockDatas:GetDataById(item.mData.unlock)
            local str = UIUtils.CheckUnlockPopupStr(unlockData)
            PopupMessageManager.PopupString(str)
          else
            UIPVPStoreExchangePanel.OnTagButtonClicked(data.id, item)
          end
        end
        self.mTagButtons:Add(item)
        if data.id == self.mCurSideTagIndex then
          self.mDefaultSelect = data.id
          defaultChangeTag = item
        end
      end
    end
  end
  TimerSys:DelayCall(0.1, function(idx)
    self.OnTagButtonClicked(self.mDefaultSelect, defaultChangeTag)
  end, nil)
end
function UIPVPStoreExchangePanel.OnTagButtonClicked(param, paramData)
  self = UIPVPStoreExchangePanel
  if paramData.mIsLocked then
    TipsManager.NeedLockTips(paramData.mData.unlock)
    return
  end
  self.mCurSideTagIndex = param
  local selectData
  for i = 1, #self.mTagButtons do
    self.mTagButtons[i]:SetSelect(false)
    if self.mTagButtons[i].mData.id == self.mCurSideTagIndex then
      self.mTagButtons[i]:SetSelect(true)
      selectData = self.mTagButtons[i].mData
    end
  end
  self:GetCurSideTagDefaultStoreTag(selectData)
end
function UIPVPStoreExchangePanel:RefreshSingleTag()
  self:InitStoreItems()
  self.RefreshStoreItemsByTag()
  local storeTagData = TableData.listStoreTagDatas:GetDataById(self.mCurTagIndex)
  if storeTagData ~= nil then
    UIPVPStoreExchangePanel.UpdateResourceBar(storeTagData)
  end
end
function UIPVPStoreExchangePanel.UpdateRefreshBtn()
  self = UIPVPStoreExchangePanel
  if NetCmdStoreData:ShowRefreshButton(self.mCurTagIndex) then
    setactive(self.ui.mBtn_RenewButton, true)
    setactive(self.ui.mTrans_Refresh, true)
    local priceData = NetCmdStoreData:GetRefreshPriceByTag(self.mCurTagIndex)
    local stcData = TableData.listItemDatas:GetDataById(priceData.itemid)
    if priceData.num <= 0 then
      local hint = TableData.GetHintById(60013)
      self.ui.mText_CostNum.text = hint
    else
      self.ui.mText_CostNum.text = priceData.num
    end
    self.ui.mImage_CostItem.sprite = UIUtils.GetIconSprite("Icon/" .. stcData.IconPath, stcData.Icon)
    local has = NetCmdItemData:GetResItemCount(stcData.id)
    if has < priceData.num then
      self.ui.mBtn_RenewButton.interactable = false
      self.ui.mText_CostNum.color = ColorUtils.RedColor
    else
      self.ui.mBtn_RenewButton.interactable = true
      self.ui.mText_CostNum.color = Color.black
    end
  else
    setactive(self.ui.mBtn_RenewButton, false)
    setactive(self.ui.mTrans_Refresh, false)
  end
end
function UIPVPStoreExchangePanel.UpdateRefreshTime()
  self = UIPVPStoreExchangePanel
  if self.mTagTimer ~= nil then
    self.mTagTimer:Stop()
  end
  self.StartTagCountDown()
  self:InitStoreItems()
end
function UIPVPStoreExchangePanel.RefreshBlackMarket()
  self = UIPVPStoreExchangePanel
  local countdown = NetCmdStoreData:GetStoreTagTimeInt(self.mCurTagIndex)
  if countdown < 0 then
    NetCmdStoreData:SendStoreTagRefresh(self.mCurTagIndex, false, self.UpdateRefreshTime)
  end
end
function UIPVPStoreExchangePanel.StartTagCountDown()
  self = UIPVPStoreExchangePanel
  setactive(self.ui.mTrans_CountDown, false)
  if NetCmdStoreData:StoreTagCanRefresh(self.mCurTagIndex) then
    return
  end
  local countdown = NetCmdStoreData:GetStoreTagTimeInt(self.mCurTagIndex)
  if countdown == 0 then
    NetCmdStoreData:SendStoreTagRefresh(self.mCurTagIndex, false, self.UpdateRefreshTime)
    return
  end
  self.mTagTimer = TimerSys:DelayCall(1, self.StartTagCountDown, nil)
  if 0 < countdown then
    self.ui.mText_CountDown.text = NetCmdStoreData:GetStoreTagRefreshTime(self.mCurTagIndex)
    setactive(self.ui.mTrans_CountDown, self.ui.mText_CountDown.text ~= "")
  end
end
function UIPVPStoreExchangePanel:UpdateUnLockTip()
end
function UIPVPStoreExchangePanel.UpdateResourceBar(tagData)
  local currencyParent = self.ui.mScrollChild_TopRes.transform
  if currencyParent == nil then
    return
  end
  if self.topRes then
    self.topRes:Release()
    self.topRes:UpdateCurrencyContent(currencyParent, tagData.trade_item_list)
  end
end
function UIPVPStoreExchangePanel.ItemProvider()
  self = UIPVPStoreExchangePanel
  local itemView = ExchangeGoodsItem.New()
  itemView:InitCtrl(self.ui.mLayout_List.transform)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIPVPStoreExchangePanel.ItemRenderer(index, renderData)
  self = UIPVPStoreExchangePanel
  local data = self.ItemDataList[index + 1]
  local item = renderData.data
  self.mStoreItems[data.id] = item
  item:InitData(data)
  item:SetLockCause()
  local itemBtn = UIUtils.GetButtonListener(item.mUIRoot.gameObject)
  itemBtn.onClick = self.OnGoodsItemClicked
  itemBtn.param = item
  itemBtn.paramData = nil
end
function UIPVPStoreExchangePanel:InitStoreItems()
  self.mStoreItems = {}
  self.ItemDataList = {}
  self.ui.mFade_Content:CompleteTweenerList()
  self.ui.mFade_Content:StopAllCoroutines()
  self.mGoodDatas = List:New(CS.Cmd.StoreGoods)
  local storeGoodList = NetCmdStoreData:GetStoreGoodsList()
  for i = 0, storeGoodList.Count - 1 do
    local goods = storeGoodList[i]
    self.mGoodDatas:Add(goods)
  end
  local compareBySort = function(elem1, elem2)
    return elem1.sort < elem2.sort
  end
  self.mGoodDatas:Sort(compareBySort)
  for i = 1, self.mGoodDatas:Count() do
    local goods = self.mGoodDatas[i]
    if goods.tag == self.mCurTagIndex and goods:IsShow() then
      table.insert(self.ItemDataList, goods)
    end
  end
  self.virtualList.numItems = #self.ItemDataList
  self.virtualList:Refresh()
  setactive(self.ui.mFade_Content, false)
  setactive(self.ui.mFade_Content, true)
  self.RefreshStoreItemsByTag()
end
function UIPVPStoreExchangePanel.RefreshStoreItemsByTag()
  self = UIPVPStoreExchangePanel
  local tagType = NetCmdStoreData:GetStoreTagType(self.mCurTagIndex)
  for k, v in pairs(self.mStoreItems) do
    local item = v
    if item.mData.tag == self.mCurTagIndex then
      if not item.mData.IsCurrentSection then
        setactive(item:GetRoot().gameObject, false)
      else
        setactive(item:GetRoot().gameObject, true)
      end
    else
      setactive(item:GetRoot().gameObject, false)
    end
  end
end
UIPVPStoreExchangePanel.IsConfirmPanelOpening = false
function UIPVPStoreExchangePanel.OnGoodsItemClicked(gameObj)
  self = UIPVPStoreExchangePanel
  local eventTrigger = getcomponent(gameObj, typeof(CS.ButtonEventTriggerListener))
  if eventTrigger ~= nil then
    UIPVPStoreExchangePanel.IsConfirmPanelOpening = true
    local item = eventTrigger.param
    local icon = item.mData.icon
    if icon == "" and item.mData.frame ~= 0 and TableData.GetItemData(item.mData.frame) then
      icon = TableData.GetItemData(item.mData.frame).icon
    end
    if item.mData:IsPreShowing() then
      self:OpenUnlockPanel(item.mData)
    elseif item.mData:IsSellout() then
      UITipsPanel.OpenStoreGood(item.mData.name, icon, item.mData.description, item.mData.rank, TableData.GetItemData(item.mData.frame))
    elseif item.mData:HasRemain() then
      self:OpenConfirmPanel(item.mData)
    end
  end
end
function UIPVPStoreExchangePanel:OpenConfirmPanel(itemData)
  gfdebug("购买确认面板")
  UIManager.OpenUIByParam(UIDef.UIStoreConfirmPanel, {
    data = itemData,
    parent = self,
    callBack = function()
      self:RefreshUnlockTip()
    end,
    isShowCreditNum = false
  })
end
function UIPVPStoreExchangePanel:OpenUnlockPanel(storeData)
  gfdebug("未解锁详情界面")
  UIManager.OpenUIByParam(UIDef.UIStoreLockDialog, {data = storeData, parent = self})
end
function UIPVPStoreExchangePanel.OnConfirmGotoBuyDiamond(tagId)
  self = UIPVPStoreExchangePanel
  gfdebug("OnConfirmGotoBuyDiamond")
  self.mCurTagIndex = tagId
  self:InitTagButtons()
  self:RefreshStoreItemsByTag()
end
function UIPVPStoreExchangePanel.OnBuySuccess()
  gfdebug("OnBuySuccess")
  self = UIPVPStoreExchangePanel
  self.UpdateStoreGood()
end
function UIPVPStoreExchangePanel:RefreshUnlockTip()
  for i = 1, #self.mTopTagItems do
    local flag = false
    for j = 1, #self.beforeBuy do
      if self.mTopTagItems[i].mData.Id == self.beforeBuy[j].Id then
        flag = true
        break
      end
    end
    if flag then
      local storeTagData = self.mTopTagItems[i].mData
      local isUnLock = AccountNetCmdHandler:CheckSystemIsUnLock(storeTagData.unlock)
      if isUnLock then
        PlayerPrefs.SetInt(self.uid .. UIPVPGlobal.RedPointKey .. storeTagData.Id, 1)
        MessageSys:SendMessage(UIEvent.PVPStoreRedPointRefresh, nil)
        RedPointSystem:GetInstance():UpdateRedPointByType(RedPointConst.PVP)
        self.mTopTagItems[i]:SetRedPoint(true)
        CS.PopupMessageManager.PopupStateChangeString(string_format(TableData.GetHintById(120120), storeTagData.name))
      end
    end
  end
end
function UIPVPStoreExchangePanel.UpdateStoreGood()
  self = UIPVPStoreExchangePanel
  self.OnRefreshStoreGood(ErrorCodeSuc)
end
function UIPVPStoreExchangePanel.OnRefreshStoreGood(ret)
  self = UIPVPStoreExchangePanel
  if ret == ErrorCodeSuc then
    gfdebug("刷新商品列表")
    self:InitStoreItems()
    self:RefreshTopSideTag()
    local storeTagData = TableData.listStoreTagDatas:GetDataById(self.mCurTagIndex)
    if storeTagData ~= nil then
      UIPVPStoreExchangePanel.UpdateResourceBar(storeTagData)
    end
  else
    gfdebug("刷新商品列表失败")
    MessageBox.Show("出错了", "刷新商品列表失败!", MessageBox.ShowFlag.eMidBtn, nil, nil, nil)
  end
end
function UIPVPStoreExchangePanel.OnRenewClick(gameobj)
  self = UIPVPStoreExchangePanel
  local hint = TableData.GetHintById(60047)
  local noticeHint = TableData.GetHintById(208)
  MessageBox.Show(noticeHint, hint, MessageBox.ShowFlag.eNone, nil, UIPVPStoreExchangePanel.OnRenew, nil)
end
function UIPVPStoreExchangePanel.OnRenew()
  self = UIPVPStoreExchangePanel
  NetCmdStoreData:SendStoreTagRefresh(self.mCurTagIndex, true, self.OnManualRefresh)
end
function UIPVPStoreExchangePanel.OnManualRefresh(ret)
  self = UIPVPStoreExchangePanel
  self.OnRefreshStoreGood(ret)
  if ret == ErrorCodeSuc then
    local hint = TableData.GetHintById(60011)
    CS.PopupMessageManager.PopupString(hint)
  end
end
function UIPVPStoreExchangePanel:ClearStoreItems()
  for k, v in pairs(self.mStoreItems) do
    local item = v
    gfdestroy(v.mUIRoot.gameObject)
  end
  self.mStoreItems = {}
end
function UIPVPStoreExchangePanel.Hide()
  self = UIPVPStoreExchangePanel
  self:Show(false)
end
function UIPVPStoreExchangePanel.OnReturnClick(gameobj)
  self = UIPVPStoreExchangePanel
  UIPVPStoreExchangePanel.Close()
end
function UIPVPStoreExchangePanel:GetCurSideTagDefaultStoreTag(sideTag)
  local strArr = sideTag.IncludeTag
  self.mCurTagIndex = tonumber(strArr[0])
  if 0 < self.curTopTagIndex then
    self.mCurTagIndex = self.curTopTagIndex
    self.curTopTagIndex = -1
  end
  self.beforeBuy = {}
  for i = 0, strArr.Count - 1 do
    local tagId = tonumber(strArr[i])
    local storeTagData = TableData.listStoreTagDatas:GetDataById(tagId)
    local isLock = not AccountNetCmdHandler:CheckSystemIsUnLock(storeTagData.unlock)
    if isLock then
      table.insert(self.beforeBuy, storeTagData)
    end
  end
  self:InitSideTag(sideTag)
end
function UIPVPStoreExchangePanel:InitSideTag(sideTag)
  for k, v in pairs(self.mTopTagItems) do
    v:OnRelease()
  end
  setactive(self.ui.mTrans_CountDown, false)
  local strArr = sideTag.IncludeTag
  self.mTopTagItems = {}
  if strArr.Count > 1 then
    setactive(self.ui.mTrans_TopTabContent.gameObject, true)
    for i = 0, strArr.Count - 1 do
      do
        local obj = UIComTabBtn1Item.New()
        obj:InitCtrl(self.ui.mTrans_TopTabContent.transform)
        table.insert(self.mTopTagItems, obj)
        UIUtils.GetButtonListener(obj.ui.mBtn_Self.gameObject).onClick = function()
          UIPVPStoreExchangePanel:OnTopTagClick(i)
        end
        obj:SetSelect(tonumber(strArr[i]) == self.mCurTagIndex)
        local storeTagData = TableData.listStoreTagDatas:GetDataById(tonumber(strArr[i]))
        local isShowRedPoint = PlayerPrefs.GetInt(self.uid .. UIPVPGlobal.RedPointKey .. storeTagData.Id)
        if storeTagData ~= nil then
          obj:SetData(storeTagData)
          local isLock = not AccountNetCmdHandler:CheckSystemIsUnLock(storeTagData.unlock)
          obj:SetLock(isLock)
          obj:SetRedPoint(isShowRedPoint == 1)
        end
      end
    end
  else
    setactive(self.ui.mTrans_TopTabContent.gameObject, false)
  end
  UIPVPStoreExchangePanel:OnTopTagClick(0)
end
function UIPVPStoreExchangePanel:RefreshTopSideTag()
  local sideTagData = TableData.listStoreSidetagDatas:GetDataById(self.mCurSideTagIndex)
  if sideTagData == nil then
    return
  end
  local strArr = sideTagData.IncludeTag
  if strArr.Count > 1 then
    setactive(self.ui.mTrans_TopTabContent.gameObject, true)
    for i = 0, strArr.Count - 1 do
      local obj = self.mTopTagItems[i + 1]
      local storeTagData = TableData.listStoreTagDatas:GetDataById(tonumber(strArr[i]))
      if storeTagData ~= nil then
        local isLock = not AccountNetCmdHandler:CheckSystemIsUnLock(storeTagData.unlock)
        obj:SetLock(isLock)
      end
    end
  else
    setactive(self.ui.mTrans_TopTabContent.gameObject, false)
  end
end
function UIPVPStoreExchangePanel:OnTopTagClick(index)
  setactive(self.ui.mTrans_CountDown, false)
  local sideTagData = TableData.listStoreSidetagDatas:GetDataById(self.mCurSideTagIndex)
  local strArr = sideTagData.IncludeTag
  self.beforeBuy = {}
  for i = 0, strArr.Count - 1 do
    local tagId = tonumber(strArr[i])
    local storeTagData = TableData.listStoreTagDatas:GetDataById(tagId)
    local isLock = not AccountNetCmdHandler:CheckSystemIsUnLock(storeTagData.unlock)
    if isLock then
      table.insert(self.beforeBuy, storeTagData)
    end
    if i == index then
      if isLock == true then
        setactive(self.ui.mTrans_CountDown, true)
        local costNum = NetCmdStoreData:GetTotalGoodsHistoryByPriceType(storeTagData.trade_item_list)
        local unlockData = TableData.listUnlockDatas:GetDataById(storeTagData.unlock)
        local str = UIUtils.CheckUnlockPopupStr(unlockData)
        self.ui.mText_CountDown.text = string_format(str, costNum)
      else
        if PlayerPrefs.HasKey(self.uid .. UIPVPGlobal.RedPointKey .. storeTagData.Id) then
          PlayerPrefs.DeleteKey(self.uid .. UIPVPGlobal.RedPointKey .. storeTagData.Id)
          MessageSys:SendMessage(UIEvent.PVPStoreRedPointRefresh, nil)
          RedPointSystem:GetInstance():UpdateRedPointByType(RedPointConst.PVP)
        end
        if self.mTopTagItems[i + 1] then
          self.mTopTagItems[i + 1]:SetRedPoint(false)
        end
        setactive(self.ui.mTrans_CountDown, false)
      end
      self.curindexLock = isLock
    end
  end
  for k, obj in pairs(self.mTopTagItems) do
    obj:SetSelect(index == k - 1)
  end
  for i = 0, strArr.Count - 1 do
    if index == i then
      self.mCurTagIndex = tonumber(strArr[i])
    end
  end
  self:RefreshSingleTag()
end
function UIPVPStoreExchangePanel:OnClose()
  self = UIPVPStoreExchangePanel
  UIPVPStoreExchangePanel.ui = nil
  UIPVPStoreExchangePanel.mCurTagIndex = 0
  UIPVPStoreExchangePanel.mCurSideTagIndex = 0
  if self.mTagButtons then
    for i = 1, #self.mTagButtons do
      self.mTagButtons[i]:OnClose()
    end
    self:ReleaseCtrlTable(self.mTagButtons)
  end
  self.mData = nil
  self.curTopTagIndex = -1
  if self.mTagTimer ~= nil then
    self.mTagTimer:Stop()
  end
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.BuySuccess, self.RefreshUnlockTipFun)
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.OnCloseCommonReceivePanel, self.storeGoodsRefresh)
  self.itemList = {}
  self.sortFunc = nil
  UIPVPStoreExchangePanel.Instance = nil
end
