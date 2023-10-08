require("UI.UIBasePanel")
require("UI.MonopolyActivity.ActivityTourGlobal")
require("UI.MonopolyActivity.Store.Item.Btn_ActivityTourStoreTopItem")
require("UI.MonopolyActivity.Store.Item.ActivityTourStoreItem")
require("UI.MonopolyActivity.Store.Item.ActivityTourStoreCommandItem")
require("UI.Common.UIComTabBtn1ItemV2")
ActivityTourStoreDialog = class("ActivityTourStoreDialog", UIBasePanel)
ActivityTourStoreDialog.__index = ActivityTourStoreDialog
function ActivityTourStoreDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function ActivityTourStoreDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self.listTab = {}
  self.listGoods = {}
  self.listCurrentCommandItem = {}
  self.listCostItem = {}
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListener()
  self:InitLeftCommandList()
  self:InitPoints()
  function self.ui.mAniEvent_Refresh.onAnimationEvent()
    self:OnClickTabRefresh()
  end
  self.oriFirstDelay = self.ui.mAutoScrollFade_GoodsList.FirstDelay
end
function ActivityTourStoreDialog:OnInit(root, data)
  self.listCanComposeId = {}
  self.callBack = data.callBack
  self.shopId = MonopolyWorld.MpData.ShopId
  self.shopData = TableDataBase.listMonopolyShopDatas:GetDataById(self.shopId)
  self.selectComposeId = 0
  self.selectComposeIndex = 0
  self.tabType = ActivityTourGlobal.StoreTabType_Buy
  self.ui.mVirtualListEx_Command.verticalNormalizedPosition = 1
  self.haveClose = false
  self:InitTab()
  if not self.btnText then
    local uiTemplate = self.ui.mBtn_Buy.transform:GetComponent(typeof(CS.UITemplate))
    if uiTemplate and 0 < uiTemplate.Texts.Length then
      self.btnText = uiTemplate.Texts[0]
    end
  end
  MessageSys:SendMessage(MonopolyEvent.HideActivityTourMainPanel, nil)
  self:AddMessageListener(MonopolyEvent.OnRefreshCommand, self.OnRefreshCommand)
  self:AddMessageListener(MonopolyEvent.RefreshPointsOnly, self.OnRefreshPoints)
  ActivityTourGlobal.ReplaceAllColor(self.mUIRoot)
end
function ActivityTourStoreDialog:OnShowStart()
  self:Refresh()
  NetCmdMonopolyData:CheckShowGetCommandPanel(nil, false)
end
function ActivityTourStoreDialog:OnShowFinish()
  self:SetFirstDelay()
end
function ActivityTourStoreDialog:OnClose()
  self.super.OnClose(self)
  self.btnText = nil
  self.shopData = nil
  MessageSys:SendMessage(MonopolyEvent.ShowActivityTourMainPanel, false)
  self.ui.mAutoScrollFade_GoodsList.FirstDelay = self.oriFirstDelay
end
function ActivityTourStoreDialog:OnRelease()
  self.ui.mAniEvent_Refresh.onAnimationEvent = nil
  self.ui = nil
  self:ReleaseCtrlTable(self.listTab, true)
  self:ReleaseCtrlTable(self.listCostItem, true)
  self:ReleaseCtrlTable(self.listCurrentCommandItem)
end
function ActivityTourStoreDialog:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_Refresh.gameObject).onClick = function()
    self:OnBtnRefresh()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Buy.gameObject).onClick = function()
    if self.tabType == ActivityTourGlobal.StoreTabType_Buy then
      self:OnBtnBuy()
    else
      self:OnBtnCompose()
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:OnBtnClose()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_OutsideClose.gameObject).onClick = function()
    self:OnBtnClose()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Points.gameObject).onClick = function()
    UITipsPanel.Open(TableData.GetItemData(ActivityTourGlobal.PointsId))
  end
end
function ActivityTourStoreDialog:InitTab()
  for i = ActivityTourGlobal.StoreTabType_Buy, ActivityTourGlobal.StoreTabType_Compose do
    local item = self.listTab[i]
    if item == nil then
      item = UIComTabBtn1ItemV2.New()
      local data = {
        index = i,
        name = i == ActivityTourGlobal.StoreTabType_Buy and TableData.GetHintById(270250) or TableData.GetHintById(270251)
      }
      item:InitCtrl(self.ui.mScrollListChild_TabList.transform, data)
      self.listTab[i] = item
      item:AddClickListener(function()
        self:OnClickTab(item)
      end)
    end
    if i == ActivityTourGlobal.StoreTabType_Buy then
      self:OnClickTab(item)
    end
  end
end
function ActivityTourStoreDialog:OnClickTab(tabItem)
  if tabItem == self.curTabItem then
    return
  end
  if self.curTabItem ~= nil then
    self.curTabItem:SetBtnInteractable(true)
  end
  tabItem:SetBtnInteractable(false)
  self.curTabItem = tabItem
  self.tabType = tabItem.index
  self.ui.mRoot_Ani:SetTrigger("Tab_FadeIn")
  self.detailInfo = nil
  self.isClickTab = true
  self:Refresh()
  self.isClickTab = false
end
function ActivityTourStoreDialog:Refresh()
  self:RefreshBuy()
  self:RefreshCompose()
  self:RefreshMyCommandList()
end
function ActivityTourStoreDialog:RefreshBuy()
  if self.tabType ~= ActivityTourGlobal.StoreTabType_Buy then
    return
  end
  self.listShopGoods = MonopolyWorld.MpData.ShopGoodsList
  self.selectGoodsId = self.listShopGoods.Count > 0 and self.listShopGoods[0].Id or 0
  self:ShowBuyGoodsPart()
  self:RefreshLeftCommandList()
  self:RefreshGoodsInfo()
end
function ActivityTourStoreDialog:RefreshCompose()
  if self.tabType ~= ActivityTourGlobal.StoreTabType_Compose then
    return
  end
  self:GetComposeCommandList()
  self:ShowBuyGoodsPart()
  self:RefreshLeftCommandList()
  self:RefreshComposeInfo()
end
function ActivityTourStoreDialog:OnBtnRefresh()
  if MonopolyWorld.MpData.ShopRefreshCount >= self.shopData.refresh.Count then
    UIUtils.PopupHintMessage(270241)
    return
  end
  local cost = self.shopData.refresh[MonopolyWorld.MpData.ShopRefreshCount]
  local tip = string_format(TableData.GetHintById(270242), cost, MonopolyWorld.MpData.ShopRefreshCount, self.shopData.refresh.Count)
  MessageBoxPanel.ShowDoubleType(tip, function()
    if MonopolyWorld.IsGmMode then
      return
    end
    if MonopolyWorld.MpData.Points < cost then
      UIUtils.PopupHintMessage(270273)
      return
    end
    NetCmdMonopolyData:SendRefreshShop(function(ret)
      if ret == ErrorCodeSuc then
        UIUtils.PopupPositiveHintMessage(270207)
        self:RefreshBuy()
      end
    end)
  end)
end
function ActivityTourStoreDialog:RefreshMyCommandList(slotIndex)
  local listCurrentCommandId = MonopolyWorld.MpData.commandList
  local maxNum = listCurrentCommandId.Count
  maxNum = math.min(maxNum, ActivityTourGlobal.MaxCommandNum)
  for i = 0, maxNum - 1 do
    local commandID = listCurrentCommandId[i]
    local item = self.listCurrentCommandItem[i + 1]
    if item == nil then
      item = ActivityTourStoreCommandItem.New()
      item:InitCtrl(self.ui.mTrans_CommandRoot, self.RefreshAfterBuyCommand)
      self.listCurrentCommandItem[i + 1] = item
      setactive(item:GetRoot(), true)
    end
    item:SetData(commandID, i == slotIndex)
  end
  for i = maxNum + 1, ActivityTourGlobal.MaxCommandNum do
    local item = self.listCurrentCommandItem[i]
    if item == nil then
      item = ActivityTourStoreCommandItem.New()
      item:InitCtrl(self.ui.mTrans_CommandRoot, self.RefreshAfterBuyCommand)
      self.listCurrentCommandItem[i] = item
      setactive(item:GetRoot(), true)
    end
    item:RefreshEmpty()
  end
end
function ActivityTourStoreDialog.RefreshAfterBuyCommand()
  self = ActivityTourStoreDialog
  self:RefreshMyCommandList()
end
function ActivityTourStoreDialog:InitLeftCommandList()
  function self.ui.mVirtualListEx_Command.itemProvider()
    local item = self:ItemProvider()
    return item
  end
  function self.ui.mVirtualListEx_Command.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
end
function ActivityTourStoreDialog:RefreshLeftCommandList()
  if self.ui.mTrans_TextNot.gameObject.activeSelf then
    return
  end
  local isBuy = self.tabType == ActivityTourGlobal.StoreTabType_Buy
  self.ui.mText_ListTip.text = isBuy and TableData.GetHintById(270244) or TableData.GetHintById(270245)
  self.ui.mVirtualListEx_Command.vertical = isBuy and self.listShopGoods.Count > 0 or 0 < #self.listCanComposeId
  self.ui.mVirtualListEx_Command.numItems = isBuy and self.listShopGoods.Count or #self.listCanComposeId
  self.ui.mVirtualListEx_Command:Refresh()
end
function ActivityTourStoreDialog:ItemProvider()
  local itemView = ActivityTourStoreItem.New()
  itemView:InitCtrl(self.ui.mScrollListChild_Content.childItem, self.ui.mScrollListChild_Content.transform, self.OnClickGoods)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function ActivityTourStoreDialog:ItemRenderer(index, renderData)
  local item = renderData.data
  local isBuy = self.tabType == ActivityTourGlobal.StoreTabType_Buy
  if isBuy then
    if index + 1 > self.listShopGoods.Count then
      return
    end
    local goodsId = self.listShopGoods[index].Id
    item:SetData(goodsId, self.listShopGoods[index].OrderId, index)
    item:RefreshStoreInfo(self.selectGoodsId == goodsId, isBuy)
  else
    if index + 1 > #self.listCanComposeId then
      return
    end
    local composeId = self.listCanComposeId[index + 1]
    item:SetData(composeId, composeId, index)
    item:RefreshStoreInfo(self.selectComposeIndex == index, isBuy)
  end
end
function ActivityTourStoreDialog.OnClickGoods(id, index)
  self = ActivityTourStoreDialog
  local isBuy = self.tabType == ActivityTourGlobal.StoreTabType_Buy
  if isBuy then
    local oriSelectId = self.selectGoodsId
    self.selectGoodsId = id
    self:RefreshGoodsInfo()
    for i = 0, self.listShopGoods.Count - 1 do
      if self.listShopGoods[i].Id == id or self.listShopGoods[i].Id == oriSelectId then
        self.ui.mVirtualListEx_Command:RefreshItemByIndex(i)
      end
    end
  else
    local oriSelectId = self.selectComposeId
    self.selectComposeId = id
    self.selectComposeIndex = index
    self:RefreshComposeInfo()
    for i = 1, #self.listCanComposeId do
      if self.listCanComposeId[i] == id or self.listCanComposeId[i] == oriSelectId then
        self.ui.mVirtualListEx_Command:RefreshItemByIndex(i - 1)
      end
    end
  end
end
function ActivityTourStoreDialog:RefreshGoodsInfo()
  local isSoldOut = true
  local commandId = 0
  for i = 0, self.listShopGoods.Count do
    if self.selectGoodsId == self.listShopGoods[i].Id then
      commandId = self.listShopGoods[i].OrderId
      isSoldOut = 0 >= self.listShopGoods[i].Limit
      break
    end
  end
  local data = TableData.listMonopolyOrderDatas:GetDataById(commandId)
  if data then
    self:RefreshInfoInternal(data)
  end
  local isFull = MonopolyWorld.MpData.IsCommandFull
  setactive(self.ui.mTrans_GrpReplace.gameObject, isFull and not isSoldOut)
  setactive(self.ui.mTrans_GrpSold.gameObject, isSoldOut)
  setactive(self.ui.mTrans_Buy.gameObject, not isSoldOut)
end
function ActivityTourStoreDialog:RefreshComposeInfo()
  if self.selectComposeId <= 0 then
    return
  end
  local data = TableData.listMonopolyOrderDatas:GetDataById(self.selectComposeId)
  if not data then
    return
  end
  self:RefreshInfoInternal(data)
  setactive(self.ui.mTrans_GrpSold.gameObject, false)
  setactive(self.ui.mTrans_Buy.gameObject, true)
  self:RefreshComposeCost()
end
function ActivityTourStoreDialog:RefreshGoodsDetail()
  if not self.detailInfo then
    return
  end
  self.ui.mText_Title.text = self.detailInfo.name.str
  self.ui.mImg_QualityLine.color = ActivityTourGlobal.GetCommandItemQualityColor(self.detailInfo.level)
  setactive(self.ui.mTrans_Step.gameObject, self.detailInfo.section.Count > 0)
  self.ui.mText_Step.text = TableData.GetActivityTourStepContent(self.detailInfo)
  self.ui.mText_Desc.text = self.detailInfo.order_desc.str
end
function ActivityTourStoreDialog:RefreshInfoInternal(data)
  self.detailInfo = data
  if not self.isClickTab then
    self:RefreshGoodsDetail()
  end
  local isBuy = self.tabType == ActivityTourGlobal.StoreTabType_Buy
  if self.btnText then
    self.btnText.text = isBuy and TableData.GetHintById(270246) or TableData.GetHintById(270247)
  end
end
function ActivityTourStoreDialog:ShowBuyGoodsPart()
  local isBuy = self.tabType == ActivityTourGlobal.StoreTabType_Buy
  setactive(self.ui.mTrans_ComposeCost.gameObject, not isBuy)
  setactive(self.ui.mTrans_Buy.gameObject, isBuy)
  setactive(self.ui.mTrans_Refresh.gameObject, isBuy)
  if isBuy then
    setactive(self.ui.mTrans_TextNot.gameObject, false)
    setactive(self.ui.mTrans_Left.gameObject, true)
    setactive(self.ui.mTrans_Right.gameObject, true)
  else
    setactive(self.ui.mTrans_TextNot.gameObject, self.selectComposeId <= 0)
    setactive(self.ui.mTrans_Left.gameObject, self.selectComposeId > 0)
    setactive(self.ui.mTrans_Right.gameObject, self.selectComposeId > 0)
    setactive(self.ui.mTrans_GrpReplace.gameObject, false)
  end
end
function ActivityTourStoreDialog:OnBtnBuy()
  if MonopolyWorld.IsGmMode then
    local listCurrentCommandId = MonopolyWorld.MpData.commandList
    local bFind = false
    for i = 0, listCurrentCommandId.Count - 1 do
      if listCurrentCommandId[i] == self.selectGoodsId then
        bFind = true
        break
      end
    end
    if not bFind and 0 < listCurrentCommandId.Count then
      self:RefreshMyCommandList(listCurrentCommandId[0])
    end
  else
    for i = 0, self.listShopGoods.Count - 1 do
      local shopItem = self.listShopGoods[i]
      if self.selectGoodsId == shopItem.Id and MonopolyWorld.MpData.Points < shopItem.Price then
        UIUtils.PopupHintMessage(270273)
        return
      end
    end
    NetCmdMonopolyData:SendBuyShopItem(self.selectGoodsId, function(ret)
      if ret == ErrorCodeSuc then
        self:RefreshBuy()
        NetCmdMonopolyData:CheckShowGetCommandPanel(nil, false)
        UIUtils.PopupPositiveHintMessage(270243)
      end
    end)
  end
end
function ActivityTourStoreDialog:OnBtnCompose()
  if MonopolyWorld.IsGmMode then
    return
  end
  NetCmdMonopolyData:SendComposeShopItem(self.selectComposeId, function(ret)
    if ret == ErrorCodeSuc then
      NetCmdMonopolyData:CheckShowGetCommandPanel(function()
        self:RefreshCompose()
        self:RefreshMyCommandList()
      end, false)
      UIUtils.PopupPositiveHintMessage(270272)
    end
  end)
end
function ActivityTourStoreDialog:OnBtnClose()
  if MonopolyWorld.IsGmMode then
    UIManager.CloseUI(UIDef.ActivityTourStoreDialog)
    if self.callBack then
      self.callBack()
    end
    return
  end
  local tip = TableData.GetHintById(270248)
  MessageBoxPanel.ShowDoubleType(tip, function()
    self.haveClose = true
    NetCmdMonopolyData:RefreshAndResetPoint()
    NetCmdMonopolyData:SendCloseShop(function(ret)
      if ret ~= ErrorCodeSuc then
        print_error("关闭商店失败!")
      end
      if self.callBack then
        self.callBack()
      end
      self.callBack = nil
      UIManager.CloseUI(UIDef.ActivityTourStoreDialog)
    end)
  end)
end
function ActivityTourStoreDialog:GetComposeCommandList()
  if not self.listComposeData then
    self.listComposeData = {}
    local orderIDList = TableDataBase.listMonopolyOrderByIsshowDatas:GetDataById(0).Id
    self:GetComposeCommandListInternal(orderIDList)
    orderIDList = TableDataBase.listMonopolyOrderByIsshowDatas:GetDataById(1).Id
    self:GetComposeCommandListInternal(orderIDList)
  end
  self.listCanComposeId = {}
  local listCurrentCommandId = MonopolyWorld.MpData.commandList
  for k, v in pairs(self.listComposeData) do
    local isEnough = true
    local canMergeCount = 999
    for id, needNum in pairs(v) do
      local curNum = 0
      for i = 0, listCurrentCommandId.Count - 1 do
        if listCurrentCommandId[i] == id then
          curNum = curNum + 1
        end
      end
      if needNum > curNum then
        isEnough = false
        canMergeCount = 0
        break
      else
        canMergeCount = math.min(canMergeCount, math.floor(curNum / needNum))
      end
    end
    if isEnough then
      for i = 1, canMergeCount do
        table.insert(self.listCanComposeId, k)
      end
    end
  end
  table.sort(self.listCanComposeId, function(a, b)
    local dataA = TableDataBase.listMonopolyOrderDatas:GetDataById(a)
    local dataB = TableDataBase.listMonopolyOrderDatas:GetDataById(b)
    if dataA.level ~= dataB.level then
      return dataA.level > dataB.level
    else
      return a < b
    end
  end)
  self.selectComposeId = 0
  self.selectComposeIndex = 0
  for _, v in pairs(self.listCanComposeId) do
    self.selectComposeId = v
    self.selectComposeIndex = math.max(_ - 1, 0)
    break
  end
end
function ActivityTourStoreDialog:GetComposeCommandListInternal(orderIDList)
  for i = 0, orderIDList.Count - 1 do
    local key = orderIDList[i]
    local data = TableDataBase.listMonopolyOrderDatas:GetDataById(key)
    if data and 0 < data.up_class.Count then
      self.listComposeData[key] = {}
      for k, v in pairs(data.up_class) do
        self.listComposeData[key][k] = v
      end
    end
  end
end
function ActivityTourStoreDialog:RefreshComposeCost()
  if self.selectComposeId <= 0 then
    return
  end
  local data = TableDataBase.listMonopolyOrderDatas:GetDataById(self.selectComposeId)
  if not data then
    return
  end
  local costList = {}
  for k, v in pairs(data.up_class) do
    table.insert(costList, {id = k, num = v})
  end
  local index = 1
  for i = 1, #costList do
    local commandId = costList[i].id
    local commandNum = costList[i].num
    for j = 1, commandNum do
      local rewardItem = self.listCostItem[index]
      if rewardItem == nil then
        rewardItem = UICommonItem.New()
        rewardItem:InitCtrl(self.ui.mScrollListChild_Cost.transform, true)
        table.insert(self.listCostItem, rewardItem)
      end
      setactive(rewardItem:GetRoot(), true)
      rewardItem:SetDaiyanCommandData(commandId)
      index = index + 1
    end
  end
  for i = index, #self.listCostItem do
    setactive(self.listCostItem[i]:GetRoot(), false)
  end
end
function ActivityTourStoreDialog:OnRefreshCommand(msg)
  local slotIndex = msg.Sender
  self:RefreshGoodsInfo()
  self:RefreshMyCommandList(slotIndex)
end
function ActivityTourStoreDialog:InitPoints()
  self.ui.mImg_PointsIcon.sprite = IconUtils.GetActivityTourIcon(MonopolyWorld.MpData.levelData.token_icon)
  self:OnRefreshPoints()
end
function ActivityTourStoreDialog:OnRefreshPoints()
  if self.haveClose then
    return
  end
  self.ui.mText_Points.text = MonopolyWorld.MpData.Points
end
function ActivityTourStoreDialog:OnClickTabRefresh()
  self:RefreshGoodsDetail()
end
function ActivityTourStoreDialog:SetFirstDelay()
  self.ui.mAutoScrollFade_GoodsList.FirstDelay = 0
end
