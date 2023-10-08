require("UI.StoreExchangePanel.UIComDiamondExchangeDialogView")
require("UI.UIBasePanel")
require("UI.Common.UICommonItem")
require("UI.StoreExchangePanel.UIStorePanelV2")
require("UI.StoreExchangePanel.UIStoreGlobal")
UIComDiamondExchangeDialog = class("UIComDiamondExchangeDialog", UIBasePanel)
UIComDiamondExchangeDialog.__index = UIComDiamondExchangeDialog
function UIComDiamondExchangeDialog:ctor(csPanel)
  UIComDiamondExchangeDialog.super.ctor(UIComDiamondExchangeDialog, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIComDiamondExchangeDialog.Open()
  UIComDiamondExchangeDialog.OpenUI(UIDef.UIComDiamondExchangeDialog)
end
function UIComDiamondExchangeDialog.Close()
  UIManager.CloseUI(UIDef.UIComDiamondExchangeDialog)
end
function UIComDiamondExchangeDialog:OnInit(root, data)
  UIComDiamondExchangeDialog.super.SetRoot(UIComDiamondExchangeDialog, root)
  self.mView = UIComDiamondExchangeDialogView.New()
  self.ui = {}
  self.mView:LuaUIBindTable(self.mUIRoot, self.ui)
  local costId = 11
  self.creditItem = UICommonItem.New()
  self.creditItem:InitObj(self.ui.mBtn_Credit.gameObject)
  self.diamondItem = UICommonItem.New()
  self.diamondItem:InitObj(self.ui.mBtn_Diamond.gameObject)
  local number = 1
  local costItemData = TableData.listItemDatas:GetDataById(GlobalConfig.ResourceType.CreditFree)
  local max = GlobalData.credit_all
  self.diamondItem:SetItemData(1, math.min(1, max))
  self.creditItem:SetItemData(costId, math.min(1, max), nil, nil, nil, nil, nil, nil, nil, true)
  self.maxValue = math.max(1, max)
  self.minValue = 1
  self.ui.mImg_Bg.sprite = IconUtils.GetItemIcon(costItemData.icon)
  self.ui.mText_MaxNum.text = self.maxValue
  self.ui.mText_MinNum.text = self.minValue
  self.ui.mSlider_Line.maxValue = self.maxValue
  self.ui.mSlider_Line.minValue = self.minValue
  UIUtils.GetButtonListener(self.ui.mBtn_Increase.gameObject).onClick = function()
    self.number = math.min(max, self.number + 1)
    self.ui.mSlider_Line.value = self.number
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Reduce.gameObject).onClick = function()
    self.number = math.max(1, self.number - 1)
    self.ui.mSlider_Line.value = self.number
  end
  self.ui.mSlider_Line.onValueChanged:AddListener(function(ptc)
    self:RefreshInfo(ptc)
  end)
  local num = 1
  if num ~= self.ui.mSlider_Line.value then
    self.ui.mSlider_Line.value = num
  else
    self:RefreshInfo(num)
  end
  if max == 0 then
    self.ui.mText_CompoundNum.color = ColorUtils.RedColor
    self.ui.mText_CostNum.color = ColorUtils.RedColor
  else
    self.ui.mText_CompoundNum.color = ColorUtils.BlackColor
    self.ui.mText_CostNum.color = ColorUtils.BlackColor
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BgClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIComDiamondExchangeDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIComDiamondExchangeDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    if max == 0 then
      MessageBox.Show(TableData.GetHintById(64), TableData.GetHintById(106023), nil, function()
        UIManager.CloseUI(UIDef.UIComDiamondExchangeDialog)
        UIStorePanelV2:OpenCharge()
      end, function()
      end)
      return
    end
    if 0 < TableData.SystemVersionOpenData.FreePayCredit then
      UIManager.OpenUIByParam(UIDef.UIJapanCreditConsumeDialog, {
        price = self.number,
        price_type = GlobalConfig.ResourceType.CreditFree,
        callback = function()
          self:SendBuy(self.number)
        end
      })
    else
      self:SendBuy(self.number)
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIComDiamondExchangeDialog)
  end
end
function UIComDiamondExchangeDialog:SendBuy(number)
  local needPay = GlobalData.credit_free - number
  if needPay < 0 then
    NetCmdStoreData:SendStoreBuy(UIStoreGlobal.ExchangeFreeCreditId, math.abs(needPay), function()
      NetCmdStoreData:SendStoreBuy(UIStoreGlobal.ExchangeDiamondId, math.abs(number), function()
        self.Close()
        UIManager.OpenUIByParam(UIDef.UICommonReceivePanel)
      end)
    end)
  else
    NetCmdStoreData:SendStoreBuy(UIStoreGlobal.ExchangeDiamondId, number, function()
      self.Close()
      UIManager.OpenUIByParam(UIDef.UICommonReceivePanel)
    end)
  end
end
function UIComDiamondExchangeDialog:RefreshInfo(ptc)
  self.number = math.floor(ptc)
  self.ui.mText_CompoundNum.text = math.floor(ptc)
  self.ui.mText_CostNum.text = math.floor(ptc)
  self.ui.mBtn_Increase.interactable = self.number < self.maxValue
  self.ui.mBtn_Reduce.interactable = self.number > self.minValue
  self.diamondItem:SetItemData(1, self.number)
  self.creditItem:SetItemData(11, self.number, nil, nil, nil, nil, nil, nil, nil, true)
end
function UIComDiamondExchangeDialog:OnShowStart()
end
function UIComDiamondExchangeDialog:OnRelease()
end
