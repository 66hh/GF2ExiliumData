require("UI.StorePanel.UIStoreConfirmPanel")
require("UI.UIBaseCtrl")
UIStoreCreditItem = class("UIStoreCreditItem", UIBaseCtrl)
UIStoreCreditItem.__index = UIStoreCreditItem
UIStoreCreditItem.mImg_Icon = nil
UIStoreCreditItem.mText_Name = nil
UIStoreCreditItem.mText_Num = nil
UIStoreCreditItem.mText_Name1 = nil
UIStoreCreditItem.mText_CostNum = nil
UIStoreCreditItem.mTrans_On = nil
UIStoreCreditItem.mTrans_Off = nil
function UIStoreCreditItem:__InitCtrl()
end
function UIStoreCreditItem:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("StoreExchange/Btn_StoreCreditItem.prefab", self))
  setparent(parent, obj.transform)
  obj.transform.localScale = vectorone
  obj.transform.localPosition = vectorzero
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
function UIStoreCreditItem:SetData(data, parent)
  if data == nil then
    setactive(self.mUIRoot, false)
    return
  end
  setactive(self.mUIRoot, true)
  self.mData = data
  self.stcData = data:GetStoreGoodData()
  if self.stcData.price_type == UIStoreConfirmPanel.REAL_MONEY_ID then
    self.ui.mText_CostNum.text = "¥ " .. data.price
  else
    self.ui.mText_CostNum.text = data.price
  end
  self.ui.mText_Name.text = self.stcData.name.str
  self.ui.mImg_Bg.sprite = IconUtils.GetCharacterItemSprite(self.stcData.icon)
  UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
    if self.stcData.price_type == UIStoreConfirmPanel.REAL_MONEY_ID then
      NetCmdStoreData:SendStoreOrder(data.id, function(ret)
        local topUI = UISystem:GetTopUI(UIGroupType.Default)
        if topUI ~= nil and topUI.UIDefine.UIType ~= UIDef.UIStorePanel then
          return
        end
        UIManager.OpenUIByParam(UIDef.UICommonReceivePanel)
        parent.checkMayling = true
        parent.AddPoint = tonumber(data.price)
        self:Refresh()
      end)
    else
      UIManager.OpenUIByParam(UIDef.UIComDiamondExchangeDialog, parent)
    end
  end
  self:Refresh()
end
function UIStoreCreditItem:Refresh()
  local diamonditemdata = TableData.GetItemData(1)
  setactive(self.ui.mTrans_OnlyOne, false)
  if self.mData.buy_times > 0 then
    if 0 < self.stcData.buy_reward.Count then
      for id, count in pairs(self.stcData.buy_reward) do
        self.ui.mText_Num.text = "+" .. count .. (0 < TableData.SystemVersionOpenData.FreePayCredit and "(" .. TableData.GetHintById(106044 + id) .. ")" or "")
      end
    end
    setactive(self.ui.mTrans_Double, false)
    setactive(self.ui.mTrans_Extra, 0 < self.stcData.buy_reward.Count)
    setactive(self.ui.mTrans_ExtraText, 0 < self.stcData.buy_reward.Count)
  else
    for id, count in pairs(self.stcData.first_buy_reward) do
      self.ui.mText_Num.text = "+" .. count .. (0 < TableData.SystemVersionOpenData.FreePayCredit and "(" .. TableData.GetHintById(106044 + id) .. ")" or "")
    end
    setactive(self.ui.mTrans_Double, 0 < self.stcData.first_buy_reward.Count)
    setactive(self.ui.mTrans_OnlyOne, 0 < self.stcData.first_buy_reward.Count)
    setactive(self.ui.mTrans_Extra, false)
    setactive(self.ui.mTrans_ExtraText, 0 < self.stcData.first_buy_reward.Count)
  end
end
