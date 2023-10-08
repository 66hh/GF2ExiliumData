require("UI.UIBasePanel")
require("UI.StoreExchangePanel.Item.UIStoreEmptyItem")
require("UI.StorePanel.UIStoreConfirmPanel")
UIStoreDiyBuyDialog = class("UIStoreDiyBuyDialog", UIBasePanel)
UIStoreDiyBuyDialog.__index = UIStoreDiyBuyDialog
UIStoreDiyBuyDialog.curItem = nil
function UIStoreDiyBuyDialog:ctor(csPanel)
  UIStoreDiyBuyDialog.super.ctor(UIStoreDiyBuyDialog, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIStoreDiyBuyDialog.Open()
  UIStoreDiyBuyDialog.OpenUI(UIDef.UIStoreDiyBuyDialog)
end
function UIStoreDiyBuyDialog:OnClose()
  for i, v in pairs(self.emptyItemList) do
    gfdestroy(v:GetRoot())
  end
  for i, v in pairs(self.itemList) do
    gfdestroy(v.mUIRoot.gameObject)
  end
  for i, v in pairs(self.selectItemDataList) do
    gfdestroy(v.mUIRoot.gameObject)
  end
end
function UIStoreDiyBuyDialog.Close()
  UIManager.CloseUI(UIDef.UIStoreDiyBuyDialog)
end
function UIStoreDiyBuyDialog:OnInit(root, data)
  UIStoreDiyBuyDialog.super.SetRoot(UIStoreDiyBuyDialog, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.itemList = {}
  self.emptyItemList = {}
  self.itemDataList = {}
  self.selectItemDataList = {}
  self.selectedId = {}
  self.ui.mText_Name.text = ""
  self.ui.mText_Description.text = ""
  self.mData = data
  self.stcData = data:GetStoreGoodData()
  self:AddListener()
  local reward = string.sub(self.stcData.reward, 1, -2)
  local rewards = string.split(reward, ",")
  self.allCount = #rewards
  for i = 1, #rewards do
    local itemData = TableData.GetItemData(tonumber(rewards[i]))
    local item = UICommonItem.New()
    item:InitCtrl(self.ui.mTrans_ItemContent)
    item:SetItemData(nil)
    UIUtils.GetButtonListener(item.ui.mBtn_Select.gameObject).onClick = function()
      self.curItem = item
      self:RefreshSelectList(itemData, i)
    end
    table.insert(self.itemDataList, itemData)
    local emptyItem = UIStoreEmptyItem.New()
    emptyItem:InitCtrl(self.ui.mTrans_ItemContent)
    UIUtils.GetButtonListener(emptyItem.ui.mBtn_Self.gameObject).onClick = function()
      self.curItem = self.itemList[i]
      self:RefreshSelectList(self.itemDataList[i], i)
      setactive(self.ui.mTrans_Empty, true)
      setactive(self.ui.mTrans_Top, false)
      setactive(self.ui.mTrans_DescriptionList, false)
    end
    if i == 1 then
      self.curItem = item
      emptyItem.ui.mBtn_Self.interactable = false
      self:RefreshSelectList(itemData, i)
    end
    table.insert(self.itemList, item)
    table.insert(self.emptyItemList, emptyItem)
  end
  setactive(self.ui.mTrans_Empty, true)
  setactive(self.ui.mTrans_Top, false)
  setactive(self.ui.mTrans_DescriptionList, false)
  setactive(self.ui.mTrans_Paid, data.price_type == GlobalConfig.ResourceType.CreditPay and TableData.SystemVersionOpenData.FreePayCredit > 0)
  if data.price_type > UIStoreConfirmPanel.REAL_MONEY_ID then
    self.costItemData = TableData.listItemDatas:GetDataById(data.price_type)
    self.ui.mImg_Bg.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. self.costItemData.icon)
    setactive(self.ui.mImg_Bg.transform.parent, true)
  else
    setactive(self.ui.mImg_Bg.transform.parent, false)
    self.ui.mText_CostNum.text = "¥ " .. data.price
  end
end
function UIStoreDiyBuyDialog:RefreshSelectList(data, index)
  local rewards = string.split(data.args_str, ",")
  for i = 1, #self.emptyItemList do
    self.emptyItemList[i].ui.mBtn_Self.interactable = index ~= i
  end
  for i = 1, #rewards do
    do
      local reward = string.gsub(rewards[i], "[%;]", "")
      local itemArr = string.split(reward, ":")
      local itemId = tonumber(itemArr[1])
      local itemCount = tonumber(itemArr[2])
      local itemData = TableData.GetItemData(itemId)
      local item
      if self.selectItemDataList[i] == nil then
        item = UICommonItem.New()
        item:InitCtrl(self.ui.mTrans_SelectContent)
        table.insert(self.selectItemDataList, item)
      else
        item = self.selectItemDataList[i]
      end
      item:SetItemData(itemId, itemCount)
      if self.selectedId[index] ~= nil then
        item:SetSelect(self.selectedId[index].itemId == itemId)
        if self.selectedId[index].itemId == itemId then
          setactive(self.ui.mTrans_Top, true)
          setactive(self.ui.mTrans_DescriptionList, true)
          setactive(self.ui.mTrans_Empty, false)
          self.ui.mText_Name.text = itemData.name.str
          self.ui.mText_Description.text = itemData.description.str
        end
      else
        item:SetSelect(false)
      end
      UIUtils.GetButtonListener(item.ui.mBtn_Select.gameObject).onClick = function()
        for i = 1, #self.selectItemDataList do
          if self.selectItemDataList[i] ~= item then
            self.selectItemDataList[i]:SetSelect(false)
          end
        end
        if item.isChoose then
          CS.PopupMessageManager.PopupString(TableData.GetHintById(106040))
        else
          self.selectedId[index] = {itemId = itemId, itemCount = itemCount}
          setactive(self.emptyItemList[index].mUIRoot, false)
          item:SetSelect(true)
          setactive(self.curItem.mUIRoot, true)
          setactive(self.ui.mTrans_Top, true)
          setactive(self.ui.mTrans_DescriptionList, true)
          setactive(self.ui.mTrans_Empty, false)
          self.curItem:SetRankAndIconData(itemData.rank, IconUtils.GetItemIconSprite(itemId), nil, itemCount)
          self.ui.mText_Name.text = itemData.name.str
          self.ui.mText_Description.text = itemData.description.str
        end
      end
    end
  end
end
function UIStoreDiyBuyDialog:AddListener()
  UIUtils.GetButtonListener(self.ui.mBtn_BgClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIStoreDiyBuyDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIStoreDiyBuyDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    if #self.selectedId ~= self.allCount then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(106040))
      return
    end
    local items = {}
    local itemDict = {}
    for i, v in pairs(self.selectedId) do
      table.insert(items, v.itemId)
      if itemDict[v.itemId] == nil then
        itemDict[v.itemId] = v.itemCount
      else
        itemDict[v.itemId] = itemDict[v.itemId] + v.itemCount
      end
    end
    for itemId, num in pairs(itemDict) do
      if TipsManager.CheckItemIsOverflowAndStop(itemId, num) then
        return
      end
    end
    UIStoreGlobal.OnBuyClick(self, self.mData, items)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIStoreDiyBuyDialog)
  end
end
function UIStoreDiyBuyDialog:OnShow()
end
function UIStoreDiyBuyDialog:OnRelease()
end
