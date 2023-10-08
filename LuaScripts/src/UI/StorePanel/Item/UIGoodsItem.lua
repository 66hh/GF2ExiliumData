require("UI.UIBaseCtrl")
UIGoodsItem = class("UIGoodsItem", UIBaseCtrl)
UIGoodsItem.__index = UIGoodsItem
UIGoodsItem.mImage_ItemType = nil
UIGoodsItem.mImage_GoodsRate = nil
UIGoodsItem.mImage_IconImage = nil
UIGoodsItem.mText_refreshtime = nil
UIGoodsItem.mText_AmountNumber = nil
UIGoodsItem.mText_Name = nil
UIGoodsItem.mText_PriceNumber = nil
UIGoodsItem.mTrans_Refreshtime = nil
UIGoodsItem.mTrans_Recommend = nil
UIGoodsItem.mTrans_UnavailableMask = nil
function UIGoodsItem:__InitCtrl()
  self.mImage_ItemType = self:GetImage("Image_ItemType")
  self.mImage_GoodsRate = self:GetImage("GoodsIcon/Image_GoodsRate")
  self.mImage_IconImage = self:GetImage("GoodsIcon/Image_IconImage")
  self.mText_refreshtime = self:GetText("Trans_Refreshtime/Text_refreshtime")
  self.mText_AmountNumber = self:GetText("Amount/Text_AmountNumber")
  self.mText_Name = self:GetText("GoodsName/Text_Name")
  self.mText_PriceNumber = self:GetText("Price/Text_PriceNumber")
  self.mTrans_Refreshtime = self:GetRectTransform("Trans_Refreshtime")
  self.mTrans_Recommend = self:GetRectTransform("Trans_Recommend")
  self.mTrans_UnavailableMask = self:GetRectTransform("Trans_UnavailableMask")
end
UIGoodsItem.mImage_PriceImage = nil
function UIGoodsItem:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
  self.mImage_PriceImage = self:GetImage("Price/image_price")
end
function UIGoodsItem:InitData(data)
  self.mData = data
  self.mText_Name.text = data.name
  local num = tonumber(data.price)
  self.mText_PriceNumber.text = formatnum(num)
  if data.limit == 0 then
    self.mText_AmountNumber.text = "-"
  else
    self.mText_AmountNumber.text = "" .. data.remain_times
  end
  if data.IsRecommend then
    setactive(self.mTrans_Recommend.gameObject, true)
  else
    setactive(self.mTrans_Recommend.gameObject, false)
  end
  if data.remain_times == 0 and (data.limit ~= 0 or data.IsSpecial) then
    setactive(self.mTrans_UnavailableMask.gameObject, true)
  end
  self.mImage_ItemType.color = TableData.GetGlobalGun_Quality_Color2(data.rank)
  self.mImage_IconImage.sprite = UIUtils.GetIconSprite("Icon/Item", data.icon)
  if 0 < data.price_type then
    local stcData = TableData.GetItemData(data.price_type)
    if stcData == nil then
      gferror("未知的PriceType" .. data.price_type .. ",Item表里没有该ID")
    end
    self.mImage_PriceImage.sprite = UIUtils.GetIconSprite("Icon/Item", stcData.icon)
  end
  if data.can_refresh then
    setactive(self.mTrans_Refreshtime.gameObject, true)
    self.StartItemCountDown({data, self})
  end
end
function UIGoodsItem.StartItemCountDown(params)
  local item = params[2]
  local itemData = params[1]
  item.mCountDownTimer = TimerSys:DelayCall(10, item.StartItemCountDown, {itemData, item})
  item.mText_refreshtime.text = itemData.refresh_time
  item.mText_AmountNumber.text = "" .. itemData.remain_times
end
function UIGoodsItem:ReleaseTimer()
  if self.mCountDownTimer ~= nil then
    self.mCountDownTimer:Stop()
    self.mCountDownTimer = nil
  end
end
function UIGoodsItem:OnHighlight()
end