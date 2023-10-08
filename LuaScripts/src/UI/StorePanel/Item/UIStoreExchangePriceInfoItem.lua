require("UI.UIBaseCtrl")
UIStoreExchangePriceInfoItem = class("UIStoreExchangePriceInfoItem", UIBaseCtrl)
UIStoreExchangePriceInfoItem.__index = UIStoreExchangePriceInfoItem
function UIStoreExchangePriceInfoItem:ctor()
end
function UIStoreExchangePriceInfoItem:__InitCtrl()
  self.mText_Num = self:GetText("Root/GrpBuyNum/Text_Num")
  self.mText_Price = self:GetText("Root/GrpPrice/Text_Price")
  self.mImage_Icon = self:GetImage("Root/GrpPrice/GrpItemIcon/Img_Icon")
  self.mTrans_Now = self:GetRectTransform("Root/Trans_GrpNow")
end
function UIStoreExchangePriceInfoItem:InitCtrl(parent)
  local itemPrefab = UIUtils.GetGizmosPrefab("StoreExchange/StoreExchangePriceInfoItemV2.prefab", self)
  local instObj = instantiate(itemPrefab)
  instObj.transform:SetParent(parent.transform)
  setscale(instObj.transform, vectorone)
  setposition(instObj.transform, vectorzero)
  self:SetRoot(instObj.transform)
  self:__InitCtrl()
end
function UIStoreExchangePriceInfoItem:SetData(data)
  if data.endCount == data.startCount then
    self.mText_Num.text = data.startCount
  elseif data.endCount > 0 then
    self.mText_Num.text = data.startCount .. "~" .. data.endCount
  else
    self.mText_Num.text = data.startCount .. "~"
  end
  self.mText_Price.text = data.price
  local stcData = TableData.GetItemData(data.priceId)
  self.mImage_Icon.sprite = UIUtils.GetIconSprite("Icon/Item", stcData.icon)
  setactive(self.mTrans_Now, false)
end
function UIStoreExchangePriceInfoItem:SetNow()
  setactive(self.mTrans_Now, true)
end
