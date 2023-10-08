require("UI.MessageBox.MessageBoxPanel")
require("UI.UIBasePanel")
require("UI.StoreExchangePanel.UIStoreGlobal")
UIComItemExchangeDialog = class("UIComItemExchangeDialog", UIBasePanel)
UIComItemExchangeDialog.__index = UIComItemExchangeDialog
local self = UIComItemExchangeDialog
function UIComItemExchangeDialog:ctor(obj)
  UIComItemExchangeDialog.super.ctor(UIComItemExchangeDialog, obj)
  obj.Type = UIBasePanelType.Dialog
end
function UIComItemExchangeDialog:OnAwake()
  self.selectIndex = 1
end
function UIComItemExchangeDialog:OnInit(root, param)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.param = param
  self.systemType = 0
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIComItemExchangeDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIComItemExchangeDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnConfirm.gameObject).onClick = function()
    self:OnClickConfirmBtn()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnConfirm.gameObject).onClick = function()
    self:OnClickConfirmBtn()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnCancel.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIComItemExchangeDialog)
  end
end
function UIComItemExchangeDialog:OnShowStart()
end
function UIComItemExchangeDialog:OnShowFinish()
  self:RefreshData()
end
function UIComItemExchangeDialog:RefreshData()
  self:SetItemList()
  self:SetUIData()
end
function UIComItemExchangeDialog:SetItemList()
  self.systemType = self.param[0]
  if self.systemType == 1 and self.param[1] and self.param[2] then
    self.storeDataA = TableDataBase.listStoreGoodDatas:GetDataById(self.param[1])
    self.mData = TableDataBase.listStoreGoodDatas:GetDataById(self.param[2])
    self.itemDataA = TableData.listItemDatas:GetDataById(self.storeDataA.price_type)
    self.itemDataB = TableData.listItemDatas:GetDataById(self.mData.price_type)
    self.exchangeItem = TableData.listItemDatas:GetDataById(102)
    local itemArrayA = string.split(self.storeDataA.reward, ":")
    local itemArrayB = string.split(itemArrayA[2], ";")
    self.itemNumA = tonumber(itemArrayB[1])
    self.itemNumB = 1
    self.itemCountA = NetCmdItemData:GetResItemCount(self.storeDataA.price_type)
    self.itemCountB = NetCmdItemData:GetResItemCount(self.mData.price_type)
    self:SetItemData()
  end
end
function UIComItemExchangeDialog:SetItemData()
  local itemview, needView
  local tmpStr = string_format(TableData.GetHintById(120053), self.itemNumB, self.itemDataA.Name.str, self.itemNumA, self.exchangeItem.Name.str)
  if self.uiCommonItem == nil then
    itemview = UICommonItem.New()
    itemview:InitCtrl(self.ui.mScrollListChild_Content)
    itemview:SetNowEquip(true)
    self.uiCommonItem = itemview
  else
    itemview = self.uiCommonItem
  end
  itemview:SetPVPChangeData(self.itemDataA.id, self.itemCountA, function()
    itemview:SetSelect(true)
    self.selectIndex = 1
    self.ui.mText_TextName.text = TableData.GetHintById(120052)
    self.ui.mText_Description.text = tmpStr
    setactive(self.ui.mText_ExchangeTimes.gameObject, false)
    if self.needItem then
      self.needItem:SetSelect(false)
    end
  end)
  if self.needItem == nil then
    needView = UICommonItem.New()
    needView:InitCtrl(self.ui.mScrollListChild_Content)
    needView:SetNowEquip(true)
    self.needItem = needView
  else
    needView = self.needItem
  end
  self.needPrice = 0
  if self.mData.price_args_type == 1 then
    self.needPrice = self.mData.price
  elseif self.mData.price_args_type == 2 then
    self.goodsData = NetCmdStoreData:GetStoreGoodsById(self.mData.id)
    for i = 1, self.mData.price_args.Count do
      if i > self.goodsData.buy_times then
        local strList = string.split(self.mData.price_args[i - 1], ":")
        self.needPrice = tonumber(strList[1])
        break
      end
    end
  end
  needView:SetPVPChangeData(self.mData.price_type, self.itemCountB, function()
    needView:SetSelect(true)
    self.selectIndex = 2
    self.ui.mText_TextName.text = TableData.GetHintById(120204)
    if self.goodsData.remain_times > 0 and 0 < self.needPrice then
      local desc = string_format(TableData.GetHintById(120205), self.needPrice, 1, self.itemNumA)
      self.ui.mText_Description.text = desc
    else
      self.ui.mText_Description.text = TableData.GetHintById(120206)
    end
    setactive(self.ui.mText_ExchangeTimes.gameObject, true)
    if self.uiCommonItem then
      self.uiCommonItem:SetSelect(false)
    end
  end)
  local hint = TableData.GetHintReplaceById(808, self.goodsData.remain_times)
  if self.mData.refresh_type == 1 then
    hint = TableData.GetHintReplaceById(106001, self.goodsData.remain_times)
  end
  if self.mData.refresh_type == 2 then
    hint = TableData.GetHintReplaceById(106002, self.goodsData.remain_times)
  end
  if self.mData.refresh_type == 3 then
    hint = TableData.GetHintReplaceById(106003, self.goodsData.remain_times)
  end
  self.ui.mText_ExchangeTimes.text = hint
  if self.selectIndex == 1 then
    itemview:SetSelect(true)
    needView:SetSelect(false)
    self.ui.mText_TextName.text = TableData.GetHintById(120052)
    self.ui.mText_Description.text = tmpStr
    setactive(self.ui.mText_ExchangeTimes.gameObject, false)
    setactive(itemview.ui.mTrans_Num.gameObject, true)
    itemview.ui.mText_Num.text = self.itemCountA
    itemview.ui.mText_Num.color = self.itemNumB <= self.itemCountA and ColorUtils.WhiteColor or ColorUtils.RedColor
  else
    itemview:SetSelect(false)
    needView:SetSelect(true)
    self.ui.mText_TextName.text = TableData.GetHintById(120204)
    needView.ui.mText_Num.text = self.itemCountB
    needView.ui.mText_Num.color = self.needPrice <= self.itemCountB and ColorUtils.WhiteColor or ColorUtils.RedColor
    setactive(needView.ui.mTrans_Num.gameObject, true)
    setactive(self.ui.mText_ExchangeTimes.gameObject, true)
  end
end
function UIComItemExchangeDialog:SetUIData()
  if self.systemType == 1 then
    self.ui.mText_TitleText.text = TableData.GetHintById(120051)
  end
end
function UIComItemExchangeDialog:OnClickConfirmBtn()
  if self.systemType == 1 then
    if self.selectIndex == 1 then
      if 1 > self.itemCountA then
        local desc = string_format(TableData.GetHintById(108059), self.itemDataA.Name.str)
        CS.PopupMessageManager.PopupPositiveString(desc)
        return
      end
      NetCmdPVPData:ReqNrtPvpTicketExchange(function(ret)
        if ret == ErrorCodeSuc then
          UIManager.CloseUI(UIDef.UIComItemExchangeDialog)
          local hint = TableData.GetHintById(120055)
          CS.PopupMessageManager.PopupPositiveString(hint)
        end
      end)
    elseif 1 > NetCmdItemData:GetNetItemCount(self.storeDataA.price_type) then
      if self.needPrice == 0 then
        CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(106012))
        return
      end
      if self.itemCountB >= self.needPrice then
        if 0 < self.goodsData.remain_times then
          local callback = function()
            local hint = TableData.GetHintById(106013)
            CS.PopupMessageManager.PopupPositiveString(hint)
            TimerSys:DelayCall(0.3, function()
              self:RefreshData()
            end)
          end
          UIStoreGlobal.OnBuyClick(self, self.goodsData, nil, 1, callback)
        else
          CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(106012))
        end
      end
    end
  end
end
function UIComItemExchangeDialog:OnClose()
end
function UIComItemExchangeDialog:OnRelease()
  if self.uiCommonItem then
    self.uiCommonItem:OnRelease(true)
  end
  if self.needItem then
    self.needItem:OnRelease(true)
  end
end
