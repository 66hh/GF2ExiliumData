require("UI.StoreExchangePanel.Item.ExchangeTagItem")
require("UI.UniTopbar.UITopResourceBar")
require("UI.Common.UIComTabBtn1Item")
require("UI.StoreExchangePanel.Item.ExchangeGoodsItem")
require("UI.UIBasePanel")
UIStoreExchangePanel = class("UIStoreExchangePanel", UIBasePanel)
UIStoreExchangePanel.__index = UIStoreExchangePanel
UIStoreExchangePanel.mTagButtons = nil
UIStoreExchangePanel.mCurTagIndex = 0
UIStoreExchangePanel.mCurSideTagIndex = 0
UIStoreExchangePanel.curTopTagIndex = -1
UIStoreExchangePanel.mStoreItems = {}
UIStoreExchangePanel.mData = nil
UIStoreExchangePanel.mTagTimer = nil
UIStoreExchangePanel.mDefaultSelect = nil
UIStoreExchangePanel.Instance = nil
UIStoreExchangePanel.mTopTagItems = {}
UIStoreExchangePanel.mUITopResourceBar = nil
UIStoreExchangePanel.mRoot = nil
UIStoreExchangePanel.ItemDataList = {}
function UIStoreExchangePanel:ctor(csPanel)
  UIStoreExchangePanel.super.ctor(self)
  self.mCSPanel = csPanel
end
function UIStoreExchangePanel.Open()
  UIStoreExchangePanel.OpenUI(UIDef.UIStoreExchangePanel)
end
function UIStoreExchangePanel.Close()
  self = UIStoreExchangePanel
  UIManager.CloseUI(UIDef.UIStoreExchangePanel)
end
function UIStoreExchangePanel:OnInit(root, data)
  self = UIStoreExchangePanel
  UIStoreExchangePanel.super.SetRoot(UIStoreExchangePanel, root)
  UIStoreExchangePanel.Instance = self
  self.storeType = CS.GF2.Data.StoreTagType.Exchange:GetHashCode()
  if data and type(data) == "userdata" then
    self.mData = data[0]
    self.curTopTagIndex = data[1]
    if data.Length > 2 then
      self.storeType = data[2]
    end
  else
    self.mData = data
  end
  self.mRoot = root
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.virtualList = self.ui.mVirtualList
  self.parent = self.ui.mTrans_Content
  self.itemList = {}
  self.sortFunc = nil
  self.param = nil
  self.virtualList.itemProvider = self.ItemProvider
  self.virtualList.itemRenderer = self.ItemRenderer
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
  end
  self = UIStoreExchangePanel
  self.mTagButtons = List:New()
  setactive(self.ui.mBtn_RenewButton, false)
  setactive(self.ui.mTrans_Refresh, false)
  UIUtils.GetButtonListener(self.ui.mBtn_Return.gameObject).onClick = self.OnReturnClick
  UIUtils.GetButtonListener(self.ui.mBtn_RenewButton.gameObject).onClick = self.OnRenewClick
  self:InitTagButtons()
  self:InitStoreItems()
  MessageSys:AddListener(CS.GF2.Message.UIEvent.OnCloseCommonReceivePanel, self.OnAutoRefresh)
  UIUtils.GetButtonListener(self.ui.mBtn_CommandCenter.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
end
function UIStoreExchangePanel:OnShowFinish()
  if self.block then
    self.mCSPanel:Block()
    self.block = nil
  end
end
function UIStoreExchangePanel:InitTagButtons()
  local storeSideTagList = TableData.listStoreSidetagDatas
  self.mTagButtons:Clear()
  for i = 0, self.ui.mTrans_ButtonList.transform.childCount - 1 do
    local obj = self.ui.mTrans_ButtonList.transform:GetChild(i)
    gfdestroy(obj)
  end
  local defaultChangeTag
  for i = 0, storeSideTagList.Count - 1 do
    local data = storeSideTagList[i]
    local hide = data.SidetagType ~= self.storeType and data.SidetagType ~= CS.GF2.Data.StoreTagType.Blackmarket:GetHashCode()
    if hide == false then
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
            UIStoreExchangePanel.OnTagButtonClicked(data.id, item)
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
function UIStoreExchangePanel.OnTagButtonClicked(param, paramData)
  self = UIStoreExchangePanel
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
  self:RefreshSingleTag()
end
function UIStoreExchangePanel:RefreshSingleTag()
  self:InitStoreItems()
  self.RefreshStoreItemsByTag()
  self.RefreshBlackMarket()
  self.UpdateRefreshTime()
  self.UpdateRefreshBtn()
  local storeTagData = TableData.listStoreTagDatas:GetDataById(self.mCurTagIndex)
  if storeTagData ~= nil then
    UIStoreExchangePanel.UpdateResourceBar(storeTagData)
  end
end
function UIStoreExchangePanel.UpdateRefreshBtn()
  self = UIStoreExchangePanel
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
function UIStoreExchangePanel.UpdateRefreshTime()
  self = UIStoreExchangePanel
  if self.mTagTimer ~= nil then
    self.mTagTimer:Stop()
  end
  self.StartTagCountDown()
  self:InitStoreItems()
end
function UIStoreExchangePanel.RefreshBlackMarket()
  self = UIStoreExchangePanel
  local countdown = NetCmdStoreData:GetStoreTagTimeInt(self.mCurTagIndex)
  if countdown < 0 then
    NetCmdStoreData:SendStoreTagRefresh(self.mCurTagIndex, false, self.UpdateRefreshTime)
  end
end
function UIStoreExchangePanel.StartTagCountDown()
  self = UIStoreExchangePanel
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
function UIStoreExchangePanel.UpdateResourceBar(tagData)
  local currencyParent = CS.TransformUtils.DeepFindChild(self.mUIRoot, "GrpCurrency/TopResourceBarRoot(Clone)")
  if currencyParent == nil then
    TimerSys:DelayCall(0.1, function()
      UIStoreExchangePanel.UpdateResourceBar(tagData)
    end, nil)
    return
  end
  self.topRes:Release()
  self.topRes:UpdateCurrencyContent(currencyParent, tagData.trade_item_list)
end
function UIStoreExchangePanel.ItemProvider()
  self = UIStoreExchangePanel
  local itemView = ExchangeGoodsItem.New()
  itemView:InitCtrl(self.ui.mLayout_List.transform)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIStoreExchangePanel.ItemRenderer(index, renderData)
  self = UIStoreExchangePanel
  local data = self.ItemDataList[index + 1]
  local item = renderData.data
  self.mStoreItems[data.id] = item
  item:InitData(data)
  local itemBtn = UIUtils.GetButtonListener(item.mUIRoot.gameObject)
  itemBtn.onClick = self.OnGoodsItemClicked
  itemBtn.param = item
  itemBtn.paramData = nil
end
function UIStoreExchangePanel:InitStoreItems()
  self.mStoreItems = {}
  self.ItemDataList = {}
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
function UIStoreExchangePanel.RefreshStoreItemsByTag()
  self = UIStoreExchangePanel
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
UIStoreExchangePanel.IsConfirmPanelOpening = false
function UIStoreExchangePanel.OnGoodsItemClicked(gameObj)
  self = UIStoreExchangePanel
  local eventTrigger = getcomponent(gameObj, typeof(CS.ButtonEventTriggerListener))
  if eventTrigger ~= nil then
    UIStoreExchangePanel.IsConfirmPanelOpening = true
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
function UIStoreExchangePanel:OpenConfirmPanel(itemData)
  gfdebug("OpenConfirmPanel")
  UIManager.OpenUIByParam(UIDef.UIStoreConfirmPanel, {data = itemData, parent = self})
end
function UIStoreExchangePanel:OpenUnlockPanel(storeData)
  gfdebug("未解锁详情界面")
  UIManager.OpenUIByParam(UIDef.UIStoreLockDialog, {data = storeData, parent = self})
end
function UIStoreExchangePanel.OnConfirmGotoBuyDiamond(tagId)
  self = UIStoreExchangePanel
  gfdebug("OnConfirmGotoBuyDiamond")
  self.mCurTagIndex = tagId
  self:InitTagButtons()
  self:RefreshStoreItemsByTag()
end
function UIStoreExchangePanel.OnBuySuccess()
  gfdebug("OnBuySuccess")
  self = UIStoreExchangePanel
  self.UpdateStoreGood()
end
function UIStoreExchangePanel.UpdateStoreGood()
  self = UIStoreExchangePanel
  self.OnRefreshStoreGood(ErrorCodeSuc)
end
function UIStoreExchangePanel.OnRefreshStoreGood(ret)
  self = UIStoreExchangePanel
  if ret == ErrorCodeSuc then
    gfdebug("刷新商品列表")
    self:InitStoreItems()
    self.UpdateRefreshTime()
    self.UpdateRefreshBtn()
    self:RefreshTopSideTag()
    local storeTagData = TableData.listStoreTagDatas:GetDataById(self.mCurTagIndex)
    if storeTagData ~= nil then
      UIStoreExchangePanel.UpdateResourceBar(storeTagData)
    end
    for i = 1, #self.mTagButtons do
      self.mTagButtons[i]:UpdateRedPoint()
    end
  else
    gfdebug("刷新商品列表失败")
    MessageBox.Show("出错了", "刷新商品列表失败!", MessageBox.ShowFlag.eMidBtn, nil, nil, nil)
  end
end
function UIStoreExchangePanel.OnRenewClick(gameobj)
  self = UIStoreExchangePanel
  local hint = TableData.GetHintById(60047)
  local noticeHint = TableData.GetHintById(208)
  MessageBox.Show(noticeHint, hint, MessageBox.ShowFlag.eNone, nil, UIStoreExchangePanel.OnRenew, nil)
end
function UIStoreExchangePanel.OnRenew()
  self = UIStoreExchangePanel
  NetCmdStoreData:SendStoreTagRefresh(self.mCurTagIndex, true, self.OnManualRefresh)
end
function UIStoreExchangePanel.OnManualRefresh(ret)
  self = UIStoreExchangePanel
  self.OnRefreshStoreGood(ret)
  if ret == ErrorCodeSuc then
    local hint = TableData.GetHintById(60011)
    CS.PopupMessageManager.PopupString(hint)
  end
end
function UIStoreExchangePanel.OnAutoRefresh(msg)
  self = UIStoreExchangePanel
  self.OnRefreshStoreGood(ErrorCodeSuc)
end
function UIStoreExchangePanel:ClearStoreItems()
  for k, v in pairs(self.mStoreItems) do
    local item = v
    gfdestroy(v.mUIRoot.gameObject)
  end
  self.mStoreItems = {}
end
function UIStoreExchangePanel.Hide()
  self = UIStoreExchangePanel
  self:Show(false)
end
function UIStoreExchangePanel.OnReturnClick(gameobj)
  self = UIStoreExchangePanel
  UIStoreExchangePanel.Close()
end
function UIStoreExchangePanel:GetCurSideTagDefaultStoreTag(sideTag)
  local strArr = sideTag.IncludeTag
  self.mCurTagIndex = tonumber(strArr[0])
  if 0 < self.curTopTagIndex then
    self.mCurTagIndex = self.curTopTagIndex
    self.curTopTagIndex = -1
  end
  self:InitSideTag(sideTag)
end
function UIStoreExchangePanel:InitSideTag(sideTag)
  for k, v in pairs(self.mTopTagItems) do
    v:OnRelease()
  end
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
          UIStoreExchangePanel:OnTopTagClick(i)
        end
        obj:SetSelect(tonumber(strArr[i]) == self.mCurTagIndex)
        local storeTagData = TableData.listStoreTagDatas:GetDataById(tonumber(strArr[i]))
        if storeTagData ~= nil then
          obj:SetData(storeTagData)
          local isLock = not AccountNetCmdHandler:CheckSystemIsUnLock(storeTagData.unlock)
          obj:SetLock(isLock)
        end
      end
    end
  else
    setactive(self.ui.mTrans_TopTabContent.gameObject, false)
  end
end
function UIStoreExchangePanel:RefreshTopSideTag()
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
function UIStoreExchangePanel:OnTopTagClick(index)
  local sideTagData = TableData.listStoreSidetagDatas:GetDataById(self.mCurSideTagIndex)
  local strArr = sideTagData.IncludeTag
  for i = 0, strArr.Count - 1 do
    if i == index then
      local tagId = tonumber(strArr[i])
      local storeTagData = TableData.listStoreTagDatas:GetDataById(tagId)
      local isLock = not AccountNetCmdHandler:CheckSystemIsUnLock(storeTagData.unlock)
      if isLock == true then
        TipsManager.NeedLockTips(storeTagData.unlock)
        return
      end
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
function UIStoreExchangePanel:Update()
  if self.ItemDataList ~= nil then
    for i = 1, #self.ItemDataList do
      self.ItemDataList[i]:Update()
    end
  end
end
function UIStoreExchangePanel:OnClose()
  self = UIStoreExchangePanel
  UIStoreExchangePanel.ui = nil
  UIStoreExchangePanel.mCurTagIndex = 0
  UIStoreExchangePanel.mCurSideTagIndex = 0
  self.mData = nil
  self.curTopTagIndex = -1
  if self.mTagTimer ~= nil then
    self.mTagTimer:Stop()
  end
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.OnCloseCommonReceivePanel, self.OnAutoRefresh)
  self.parent = nil
  self.itemList = {}
  self.sortFunc = nil
  UIStoreExchangePanel.Instance = nil
end
