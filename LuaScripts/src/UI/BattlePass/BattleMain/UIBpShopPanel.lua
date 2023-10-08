require("UI.StoreExchangePanel.Item.ExchangeTagItem")
require("UI.BattlePass.UIBattlePassGlobal")
require("UI.StoreExchangePanel.Item.ExchangeGoodsItem")
UIBpShopPanel = class("UIBpShopPanel", UIBaseCtrl)
UIBpShopPanel.__index = UIBpShopPanel
function UIBpShopPanel:ctor()
  self.itemList = {}
end
function UIBpShopPanel:__InitCtrl()
end
function UIBpShopPanel:InitCtrl(prefab, parent)
  self.obj = instantiate(prefab, parent)
  CS.LuaUIUtils.SetParent(self.obj.gameObject, parent.gameObject)
  self:SetRoot(self.obj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  self:__InitCtrl()
  self.mStoreItems = {}
  self:SetData(nil)
end
function UIBpShopPanel:SetData(data)
  local storeSideTagList = TableData.listStoreSidetagDatas
  self.mTagButtons = {}
  self.mCurSideTagIndex = nil
  for i = 0, storeSideTagList.Count - 1 do
    local data = storeSideTagList[i]
    local isShow = data.SidetagType == CS.GF2.Data.StoreTagType.Battlepass:GetHashCode()
    if isShow == true then
      if self.mCurSideTagIndex == nil then
        self.mCurSideTagIndex = data.id
      end
      do
        local item = ExchangeTagItem.New()
        item:InitCtrl(self.ui.mSListChild_Content.transform, true)
        item:InitData(data)
        UIUtils.GetButtonListener(item.ui.mBtn_Self.gameObject).onClick = function()
          if item.mIsLocked == true then
            local unlockData = TableData.listUnlockDatas:GetDataById(item.mData.unlock)
            local str = UIUtils.CheckUnlockPopupStr(unlockData)
            PopupMessageManager.PopupString(str)
          else
            self:OnTagButtonClicked(data.id, item)
          end
        end
        table.insert(self.mTagButtons, item)
      end
    end
  end
  setactive(self.obj, true)
  self.virtualList = self.ui.mVList_GrpItemList
  function self.virtualList.itemProvider()
    local item = self:ItemProvider()
    return item
  end
  function self.virtualList.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
end
function UIBpShopPanel:OnTagButtonClicked(tagId, paramData)
  if paramData.mIsLocked then
    TipsManager.NeedLockTips(paramData.mData.unlock)
    return
  end
  self.mCurSideTagIndex = tagId
  local selectData
  for i = 1, #self.mTagButtons do
    self.mTagButtons[i]:SetSelect(false)
    if self.mTagButtons[i].mData.id == self.mCurSideTagIndex then
      self.mTagButtons[i]:SetSelect(true)
      selectData = self.mTagButtons[i].mData
    end
  end
  self:RefreshSingleTag()
end
function UIBpShopPanel:OnGoodsItemClicked(gameObj)
  local eventTrigger = getcomponent(gameObj, typeof(CS.ButtonEventTriggerListener))
  if eventTrigger ~= nil then
    local item = eventTrigger.param
    local icon = item.mData.icon
    if icon == "" and item.mData.frame ~= 0 and TableData.GetItemData(item.mData.frame) then
      icon = TableData.GetItemData(item.mData.frame).icon
    end
    if item.mData:IsPreShowing() then
      UIManager.OpenUIByParam(UIDef.UIStoreLockDialog, {
        data = item.mData,
        parent = self
      })
    elseif item.mData:IsSellout() then
      UITipsPanel.OpenStoreGood(item.mData.name, icon, item.mData.description, item.mData.rank, TableData.GetItemData(item.mData.frame))
    elseif item.mData:HasRemain() then
      self:OpenConfirmPanel(item.mData)
    end
  end
end
function UIBpShopPanel:OpenConfirmPanel(itemData)
  gfdebug("OpenConfirmPanel")
  UIManager.OpenUIByParam(UIDef.UIStoreConfirmPanel, {data = itemData, parent = self})
end
function UIBpShopPanel:Show()
  self:OnTagButtonClicked(self.mTagButtons[1].mData.Id, self.mTagButtons[1])
  local OnRes = function(ret)
  end
  local OnAutoRefresh = function()
    self:RefreshSingleTag()
  end
  function self.AutoRefresh()
    self:RefreshSingleTag()
  end
  MessageSys:AddListener(CS.GF2.Message.UIEvent.OnCloseCommonReceivePanel, self.AutoRefresh)
end
function UIBpShopPanel:OnRefresh()
end
function UIBpShopPanel:OnBackFrom()
end
function UIBpShopPanel:RefreshSingleTag()
  local storeSidetagData = TableData.listStoreSidetagDatas:GetDataById(self.mCurSideTagIndex)
  local tagType = storeSidetagData.IncludeTag[0]
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
    if goods.tag == tagType and goods:IsShow() then
      table.insert(self.ItemDataList, goods)
    end
  end
  self.virtualList.numItems = #self.ItemDataList
  self.virtualList:Refresh()
  setactive(self.ui.mTrans_None, #self.ItemDataList == 0)
  setactive(self.ui.mSListChild_Content1, false)
  setactive(self.ui.mSListChild_Content1, #self.ItemDataList ~= 0)
  self.ui.mSListChild_Content1.transform:GetComponent(typeof(CS.MonoScrollerFadeManager)).enabled = false
  self.ui.mSListChild_Content1.transform:GetComponent(typeof(CS.MonoScrollerFadeManager)).enabled = true
end
function UIBpShopPanel:ItemProvider()
  local itemView = ExchangeGoodsItem.New()
  itemView:InitCtrl(self.ui.mSListChild_Content1.transform)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIBpShopPanel:ItemRenderer(index, renderData)
  local data = self.ItemDataList[index + 1]
  local item = renderData.data
  item:InitData(data)
  local itemBtn = UIUtils.GetButtonListener(item.mUIRoot.gameObject)
  function itemBtn.onClick(tempItem)
    self:OnGoodsItemClicked(tempItem)
  end
  itemBtn.param = item
  itemBtn.paramData = nil
end
function UIBpShopPanel:OnUpdate()
end
function UIBpShopPanel:Hide()
  if self.mTabBtns ~= nil then
    for _, item in pairs(self.mTabBtns) do
      gfdestroy(item:GetRoot())
    end
  end
  if self.AutoRefresh ~= nil then
    MessageSys:RemoveListener(CS.GF2.Message.UIEvent.OnCloseCommonReceivePanel, self.AutoRefresh)
  end
end
function UIBpShopPanel:Release()
  gfdestroy(self.obj)
  if self.AutoRefresh ~= nil then
    MessageSys:RemoveListener(CS.GF2.Message.UIEvent.OnCloseCommonReceivePanel, self.AutoRefresh)
  end
end
