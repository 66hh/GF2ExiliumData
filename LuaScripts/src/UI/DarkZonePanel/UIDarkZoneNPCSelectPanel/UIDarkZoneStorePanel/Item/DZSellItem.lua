require("UI.UIBaseCtrl")
DZSellItem = class("DZSellItem", UIBaseCtrl)
DZSellItem.__index = DZSellItem
function DZSellItem:__InitCtrl()
end
function DZSellItem:InitCtrl(root)
  local com = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  setactive(obj, true)
  self.AddLongPressListener = nil
  self.AddFrame = 0
  self.MinusFrame = 0
  self.LongAddPress = false
  self.LongMinusPress = false
end
function DZSellItem:SetTable(panelTable)
  self.tableData = panelTable
end
function DZSellItem:SetData(Data, index)
  ComPropsDetailsHelper:InitComPropsDetailsItemObjNum(2)
  self.mData = Data
  self.mIndex = index
  self.ClickNum = 0
  self.SellPrice = Data.DarkZoneItemData.darkzone_price
  setactive(self.ui.mTrans_DarkzoneCoin, true)
  self.ItemCount = Data.ItemCount
  local NpcData = TableData.listDarkzoneNpcDatas:GetDataById(self.tableData.Npc)
  setactive(self.ui.mTrans_Relation, false)
  for k, v in pairs(NpcData.favor_item) do
    if Data.DarkZoneItemData.item_kind == k then
      setactive(self.ui.mTrans_Relation, true)
    end
  end
  self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(self.mData.ItemData.rank)
  self.ui.mImage_Rank2.color = TableData.GetGlobalGun_Quality_Color2(self.mData.ItemData.rank, self.ui.mImage_Rank2.color.a)
  if Data.ItemCount > 1 then
    setactive(self.ui.mTrans_Num, true)
    self.ui.mText_Num.text = Data.ItemCount
  else
    setactive(self.ui.mTrans_Num, false)
  end
  self.ui.mImage_Icon.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. Data.ItemData.icon)
  self.ui.mImg_DZCoin.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. TableData.listItemDatas:GetDataById(18).Icon)
  local Revise = DarkNetCmdStoreData.Revise
  local Kind = Data.DarkZoneItemData.item_kind
  if Revise:ContainsKey(Kind) and 1000 < Revise[Kind] then
    self.ui.mText_DZCoinNum.color = ColorUtils.StringToColor("4BB56C")
    local ration = Revise[Kind] / 1000
    self.SellPrice = math.floor(self.SellPrice * ration)
  elseif Revise:ContainsKey(Kind) and Revise[Kind] < 1000 then
    self.ui.mText_DZCoinNum.color = ColorUtils.RedColor
    local ration = Revise[Kind] / 1000
    self.SellPrice = math.floor(self.SellPrice * ration)
  else
    self.ui.mText_DZCoinNum.color = ColorUtils.WhiteColor
    self.SellPrice = self.SellPrice
  end
  self.SellPrice = math.ceil(self.SellPrice)
  self.ui.mText_DZCoinNum.text = self.SellPrice * 1
  UIUtils.GetButtonListener(self.ui.mBtn_Select.gameObject).onClick = function()
    self:OnClickBtn(Data)
  end
  if self.AddLongPressListener == nil then
    self.AddLongPressListener = CS.LongPressTriggerListener.Set(self.ui.mBtn_Select.gameObject, 0.5, true)
    function self.AddLongPressListener.longPressStart()
      self:OnAddLongPressStart()
    end
    function self.AddLongPressListener.longPressEnd()
      self:OnAddLongPressEnd()
    end
    self.tableData.LongAddList[index] = self.AddLongPressListener
  end
  if self.NumbText == nil then
    self.NumbText = self.ui.mTrans_GrpReduce:Find("Text_Num"):GetComponent(typeof(CS.UnityEngine.UI.Text))
    self.NumbText.text = self.ClickNum
    local MinusBtn = self.ui.mBtn_Minus
    if self.MinusLongPressListener == nil then
      self.MinusLongPressListener = CS.LongPressTriggerListener.Set(MinusBtn.gameObject, 0.5, true)
      function self.MinusLongPressListener.longPressStart()
        self:OnMinusLongPressStart()
      end
      function self.MinusLongPressListener.longPressEnd()
        self:OnMinusLongPressEnd()
      end
      UIUtils.GetButtonListener(MinusBtn.gameObject).onClick = function()
        if self.tableData.ClickMultiSell then
          self:LimitChoseNum(-1, true)
        end
      end
    end
  end
  if self.tableData.IsSwitchLockByArrow == true then
    self.ui.mBtn_Select.interactable = false
  else
    self.ui.mBtn_Select.interactable = true
  end
  local saveClickNum = DZStoreUtils.SellItemDataDic[index].ClickNum
  if 1 <= saveClickNum then
    setactive(self.ui.mTrans_Choose, false)
    setactive(self.ui.mTrans_GrpReduce, true)
    self.NumbText.text = saveClickNum
  else
    setactive(self.ui.mTrans_Choose, false)
    setactive(self.ui.mTrans_GrpReduce, false)
  end
end
function DZSellItem:OnClickBtn(Data)
  if self.tableData.ClickMultiSell then
    if DZStoreUtils.SellItemDataDic[self.mIndex] == nil then
      DZStoreUtils.SellItemDataDic[self.mIndex] = {}
      DZStoreUtils.SellItemDataDic[self.mIndex].ClickNum = 0
    end
    if DZStoreUtils.SellItemDataDic[self.mIndex].ClickNum == 0 then
      local count = 0
      for k, v in pairs(self.tableData.MultiSellList) do
        count = count + 1
      end
      if count >= TableDataBase.GlobalDarkzoneData.BatchSellLimit then
        local str = string_format(TableData.GetHintById(903206), TableDataBase.GlobalDarkzoneData.BatchSellLimit)
        CS.PopupMessageManager.PopupString(str)
        return
      end
      self:LimitChoseNum(Data.ItemCount)
    else
      self:LimitChoseNum(1)
    end
    if Data.ItemData.type == 90 then
      ComPropsDetailsHelper:InitDarkItemData(self.tableData.ui.mTrans_GrpDetailsLeft, 1, Data)
    else
      ComPropsDetailsHelper:InitDarkItemData(self.tableData.ui.mTrans_GrpDetailsLeft, 2, Data)
    end
    setactive(self.tableData.ui.mTrans_GrpDetailsLeft, true)
    self.tableData.pointer.isInSelf = true
    self.tableData.ui.mBtn_Sell.interactable = true
  else
    local data = {}
    data.SellPrice = self.SellPrice
    data.Data = Data
    data.storePanel = self.tableData
    UIManager.OpenUIByParam(UIDef.UIDarkZoneStoreSingleSellDialog, data)
  end
end
function DZSellItem:Release()
  self.ClickNum = 0
  self.LongAddPress = nil
  self.LongMinusPress = nil
end
function DZSellItem:LimitChoseNum(AddNum, canBeCancel)
  self.ClickNum = self.ClickNum + AddNum
  if self.ClickNum > self.ItemCount then
    self.ClickNum = self.ItemCount
    self.LongAddPress = false
    self.LongMinusPress = false
    self.AddFrame = 0
    self.MinusFrame = 0
  elseif self.ClickNum < 1 and canBeCancel ~= true then
    self.ClickNum = 1
    self.LongAddPress = false
    self.LongMinusPress = false
    self.AddFrame = 0
    self.MinusFrame = 0
  elseif self.ClickNum < 1 and canBeCancel == true then
    self.ClickNum = 0
    self.LongAddPress = false
    self.LongMinusPress = false
    self.AddFrame = 0
    self.MinusFrame = 0
  end
  if self.ClickNum >= 1 then
    setactive(self.ui.mTrans_Choose, false)
    setactive(self.ui.mTrans_GrpReduce, true)
    self.NumbText.text = self.ClickNum
  elseif self.ClickNum == 0 then
    setactive(self.ui.mTrans_Choose, false)
    setactive(self.ui.mTrans_GrpReduce, false)
  end
  if self.ClickNum > 0 then
    local data = {}
    data.mData = self.mData
    data.ItemNum = self.ClickNum
    data.SellPrice = self.SellPrice
    self.tableData.MultiSellList[self.mIndex + 1] = data
    DZStoreUtils.SellItemDataDic[self.mIndex].ClickNum = self.ClickNum
  else
    DZStoreUtils.SellItemDataDic[self.mIndex] = nil
    self.tableData.MultiSellList[self.mIndex + 1] = nil
  end
  self.tableData:FreshSellTotalPieceData()
end
function DZSellItem:OnAddLongPressStart(gameObj, eventData)
  if self.tableData.IsSwitchLockByArrow == true then
    return
  end
  if self.tableData.ClickMultiSell then
    self.LongAddPress = true
  end
end
function DZSellItem:OnAddLongPressEnd(gameObj, eventData)
  if self.tableData.IsSwitchLockByArrow == true then
    return
  end
  self.LongAddPress = false
  self.AddFrame = 0
end
function DZSellItem:OnMinusLongPressStart(gameObj, eventData)
  if self.tableData.IsSwitchLockByArrow == true then
    return
  end
  if self.tableData.ClickMultiSell then
    self.LongMinusPress = true
  end
end
function DZSellItem:OnMinusLongPressEnd(gameObj, eventData)
  if self.tableData.IsSwitchLockByArrow == true then
    return
  end
  self.LongMinusPress = false
  self.MinusFrame = 0
end
function DZSellItem:OnUpdate(deltatime)
  if self.LongAddPress then
    self.AddFrame = self.AddFrame + 1
    if self.AddFrame == 10 then
      self:LimitChoseNum(1)
      self.AddFrame = 0
    end
  elseif self.LongMinusPress then
    self.MinusFrame = self.MinusFrame + 1
    if self.MinusFrame == 10 then
      self:LimitChoseNum(-1)
      self.MinusFrame = 0
    end
  end
end
