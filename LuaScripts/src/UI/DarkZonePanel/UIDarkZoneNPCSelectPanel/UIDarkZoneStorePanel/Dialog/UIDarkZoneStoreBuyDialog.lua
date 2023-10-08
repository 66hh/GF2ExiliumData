require("UI.DarkZonePanel.UIDarkZoneNPCSelectPanel.UIDarkZoneStorePanel.Dialog.UIDarkZoneStoreBuyDialogView")
require("UI.UIBasePanel")
UIDarkZoneStoreBuyDialog = class("UIDarkZoneStoreBuyDialog", UIBasePanel)
UIDarkZoneStoreBuyDialog.__index = UIDarkZoneStoreBuyDialog
function UIDarkZoneStoreBuyDialog:ctor(csPanel)
  UIDarkZoneStoreBuyDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneStoreBuyDialog:OnInit(root, data)
  UIDarkZoneStoreBuyDialog.super.SetRoot(UIDarkZoneStoreBuyDialog, root)
  self:InitBaseData()
  self.mData = data
  self.mview:InitCtrl(root, self.ui)
  self:AddBtnListen()
  local count = #self.mData.pricediscountList
  for i = 1, count + 1 do
    local item = DZFlexiblePrizeItem.New()
    item:InitCtrl(self.ui.mTrans_PriceDetailsContent)
    item:SetData(self.mData, i)
    self.prizeItemList[i] = item
  end
  self:InitInfoData()
end
function UIDarkZoneStoreBuyDialog:OnShowFinish()
  self.IsPanelOpen = true
  local refreshData = DarkNetCmdStoreData:GetStoreHistoryData(self.mData.StoreId)
  if 0 < refreshData then
    self.RefreshTime = refreshData
  end
end
function UIDarkZoneStoreBuyDialog:OnHide()
  self.IsPanelOpen = false
end
function UIDarkZoneStoreBuyDialog:CloseFunction()
  UIManager.CloseUI(UIDef.UIDarkZoneStoreBuyDialog)
end
function UIDarkZoneStoreBuyDialog:OnClose()
  self.ui.mSlider_Item.onValueChanged:RemoveAllListeners()
  self.ui = nil
  self.mview = nil
  self.ItemDataList = nil
  self.IsPanelOpen = nil
  self.BuyNum = nil
  self.PriceList = nil
  self.IsBanAddMInus = nil
  self.Slider = nil
  self.RefreshTime = nil
  self:ReleaseCtrlTable(self.prizeItemList, true)
  self.prizeItemList = nil
  self.itemView:DestroySelf()
  self.itemView = nil
end
function UIDarkZoneStoreBuyDialog:InitBaseData()
  self.mview = UIDarkZoneStoreBuyDialogView.New()
  self.ui = {}
  self.ItemDataList = {}
  self.IsPanelOpen = false
  self.BuyNum = 1
  self.PriceList = {}
  self.IsBanAddMInus = false
  self.Slider = true
  self.RefreshTime = 0
  self.prizeItemList = {}
end
function UIDarkZoneStoreBuyDialog:InitInfoData()
  local stcData = TableData.GetItemData(self.mData.ItemData.id, true)
  self.itemView = UICommonItem.New()
  self.itemView:InitCtrl(self.ui.mTrans_Item.transform)
  if self.mData.icon ~= "" then
    local iconSprite = IconUtils.GetItemIcon(self.mData.ItemData.icon)
    local itemId = self.mData.ItemData.id
    self.itemView:SetRankAndIconData(self.mData.ItemData.rank, iconSprite, itemId, nil, self.ui.mBtn_StoreDetail)
  elseif self.mData.ItemData.id ~= 0 and stcData ~= nil and stcData.type == 25 then
    local costItemNum = NetCmdItemData:GetItemCountById(self.mData.ItemData.id)
    self.itemView:SetByItemData(stcData, nil, false, self.ui.mBtn_StoreDetail)
  elseif self.mData.ItemData.id ~= 0 and stcData ~= nil then
    self.itemView:SetByItemData(stcData, nil, false, self.ui.mBtn_StoreDetail)
  end
  self.itemView.ui.mBtn_Select.interactable = false
  self.itemView:SetItemByStcData(self.mData.ItemData, self.mData.StoreNum)
  self.ui.mImage_PriceDetailsIcon.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. TableData.listItemDatas:GetDataById(self.mData.CurrencyId).icon)
  local priceType = TableData.GetStoreDataById(self.mData.StoreId).price_args_type
  setactive(self.ui.mBtn_PriceDetails.gameObject, priceType == 2)
  self.ui.mText_PriceDetailsNum.text = self.mData.Price
  self.ui.mText_ItemName.text = self.mData.ItemData.name.str
  self.ui.mText_Description.text = self.mData.ItemData.introduction.str
  local CurrencyNum = NetCmdItemData:GetResItemCount(self.mData.CurrencyId)
  self.CostNum = self.mData.Price
  self.ui.mImage_GoldIcon.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. TableData.listItemDatas:GetDataById(self.mData.CurrencyId).icon)
  if self.mData.HasLimit then
    if 0 > CurrencyNum - self.mData.Price then
      self.ui.mSlider_Item.maxValue = 1
      self.ui.mSlider_Item.minValue = 0
      self.ui.mSlider_Item.value = 1
      self.ui.mSlider_Item.interactable = false
      self.IsBanAddMInus = true
      self.minvalue = 1
      self.maxvalue = 1
      self.ui.mText_AmountText.text = 1
      self.ui.mText_AmountText.color = ColorUtils.RedColor
      self.ui.mText_MinNum.text = self.minvalue
      self.ui.mText_MaxNum.text = self.maxvalue
      self.ui.mText_Price.text = self.mData.Price
      self.ui.mText_Price.color = ColorUtils.RedColor
      self.ui.mBtn_AmountPlusButton.interactable = false
      self.ui.mBtn_AmountMinusButton.interactable = false
    else
      local tempcost = 0
      local tempmoney = CurrencyNum
      local CanBuyNum = 0
      local tempPrList = self.mData.pricediscountList
      local tempList = self.mData.Countlist
      for i = 1, self.mData.LeftNum do
        if #self.mData.pricediscountList == 0 then
          local price = math.ceil(self.mData.BasePrice)
          tempcost = tempcost + price
          tempmoney = tempmoney - price
          if 0 <= tempmoney then
            CanBuyNum = CanBuyNum + 1
            self.PriceList[CanBuyNum] = tempcost
          end
        else
          local discount = 0
          if i <= tempPrList[1] then
            discount = tempList[1]
          elseif i >= tempPrList[#tempPrList] then
            discount = tempList[#tempPrList]
          else
            for j = 1, #tempPrList do
              if i >= tempPrList[j] and tempPrList[j + 1] ~= nil and i < tempPrList[j + 1] then
                discount = tempList[j]
              end
            end
          end
          local price = math.ceil(self.mData.BasePrice * (discount / 100))
          tempcost = tempcost + price
          tempmoney = tempmoney - price
          if 0 <= tempmoney then
            CanBuyNum = CanBuyNum + 1
            self.PriceList[CanBuyNum] = tempcost
          end
        end
      end
      self.ui.mSlider_Item.interactable = 1 < CanBuyNum
      self.ui.mBtn_AmountPlusButton.interactable = 1 < CanBuyNum
      self.ui.mBtn_AmountMinusButton.interactable = false
      if CanBuyNum == 1 then
        self.ui.mSlider_Item.maxValue = 2
        self.ui.mSlider_Item.minValue = 1
        self.ui.mSlider_Item.value = 2
        self.minvalue = 1
        self.maxvalue = 1
        self.ui.mText_AmountText.text = 1
        self.ui.mText_MinNum.text = self.minvalue
        self.ui.mText_MaxNum.text = self.maxvalue
        self.ui.mText_Price.text = self.CostNum
      else
        self.ui.mSlider_Item.maxValue = CanBuyNum
        self.ui.mSlider_Item.minValue = 1
        self.ui.mSlider_Item.value = 1
        self.minvalue = 1
        self.maxvalue = CanBuyNum
        self.ui.mText_AmountText.text = 1
        self.ui.mText_MinNum.text = self.minvalue
        self.ui.mText_MaxNum.text = self.maxvalue
        self.ui.mText_Price.text = self.CostNum
      end
      if CurrencyNum < self.BuyNum * self.mData.Price then
        self.ui.mText_AmountText.color = ColorUtils.RedColor
        self.ui.mText_Price.color = ColorUtils.RedColor
      else
        self.ui.mText_AmountText.color = ColorUtils.StringToColor("325563")
        self.ui.mText_Price.color = ColorUtils.StringToColor("325563")
      end
    end
  end
  self.ui.mSlider_Item.onValueChanged:AddListener(function(value)
    self:OnSliderChange(value)
  end)
end
function UIDarkZoneStoreBuyDialog:SetValue()
  self.ui.mText_AmountText.text = self.BuyNum
  self.ui.mText_Price.text = self.PriceList[self.BuyNum]
  self.ui.mSlider_Item.value = self.BuyNum
  self.ui.mBtn_AmountPlusButton.interactable = true
  self.ui.mBtn_AmountMinusButton.interactable = true
  if self.BuyNum == self.maxvalue then
    self.ui.mBtn_AmountPlusButton.interactable = false
  end
  if self.BuyNum == self.minvalue then
    self.ui.mBtn_AmountMinusButton.interactable = false
  end
end
function UIDarkZoneStoreBuyDialog:IncreaseNum()
  if self.IsBanAddMInus == false and self.BuyNum < self.maxvalue then
    self.BuyNum = self.BuyNum + 1
    self:SetValue()
  end
end
function UIDarkZoneStoreBuyDialog:DecreaseNum()
  if self.IsBanAddMInus == false and self.BuyNum > self.minvalue then
    self.BuyNum = self.BuyNum - 1
    self:SetValue()
  end
end
function UIDarkZoneStoreBuyDialog:OnSliderChange(value)
  local RealValue = math.floor(value)
  self.BuyNum = RealValue
  self.ui.mSlider_Item.value = value
  self:SetValue()
  if value >= self.maxvalue or value <= self.minvalue then
    self.Slider = false
  else
    self.Slider = true
  end
  if self.Slider == false then
    return
  end
end
function UIDarkZoneStoreBuyDialog:UpdateData()
  if self.mData.IsFirstBuy then
    if self.mData.HasLimit then
      setactive(self.ui.mTrans_GrpTextLeft, true)
      self.ui.mText_LeftNum.text = self.mData.LeftNum
      self:CheckLimit()
    else
    end
  else
    if self.mData.HasLimit then
      setactive(self.ui.mTrans_GrpTextLeft, true)
      self.ui.mText_LeftNum.text = self.mData.LeftNum
      self:CheckLimit()
    else
    end
  end
end
function UIDarkZoneStoreBuyDialog:CheckLimit()
  if self.mData.LimitCount == 0 then
    UIUtils.GetButtonListener(self.mBtn_Buy.gameObject).onClick = function()
      UIUtils.PopupHintMessage(903159)
    end
  else
  end
end
function UIDarkZoneStoreBuyDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Exit.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_AmountPlusButton.gameObject).onClick = function()
    self:IncreaseNum()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_AmountMinusButton.gameObject).onClick = function()
    self:DecreaseNum()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Buy.gameObject).onClick = function()
    self:OnConfirm()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_DetailInfo.gameObject).onClick = function()
    setactive(self.ui.mTrans_GrpPriceDetails, false)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_InfoOpen.gameObject).onClick = function()
    setactive(self.ui.mTrans_GrpPriceDetails, true)
  end
end
function UIDarkZoneStoreBuyDialog:OnConfirm()
  local nextRefreshTime = NetCmdStoreData:GetGoodsRefreshById(self.mData.StoreId)
  local nowRefreshTime
  if 0 < nextRefreshTime then
    nowRefreshTime = nextRefreshTime
  end
  if self.RefreshTime ~= 0 and nowRefreshTime and nowRefreshTime ~= self.RefreshTime then
    UIUtils.PopupHintMessage(903160)
    return
  end
  if TipsManager.CheckItemIsOverflowAndStop(self.mData.ItemData.id, self.BuyNum) == true then
    return
  end
  if self.mData.LeftNum == 0 then
    UIUtils.PopupHintMessage(903159)
    return
  elseif self.IsBanAddMInus == true then
    local str = TableData.listItemDatas:GetDataById(18).name.str
    CS.PopupMessageManager.PopupString(string_format(TableData.GetHintById(225), str))
  else
    local onlyID = self.mData.onlyID == nil and 0 or self.mData.onlyID
    NetCmdStoreData:SendDarkStoreBuy(self.mData.StoreId, self.CostNum, self.BuyNum, nil, onlyID, function()
      self:CloseFunction()
      UIManager.OpenUI(UIDef.UICommonReceivePanel)
    end)
  end
end
