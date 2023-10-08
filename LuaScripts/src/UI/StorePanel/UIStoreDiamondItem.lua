require("UI.UIBaseCtrl")
UIStoreDiamondItem = class("UIStoreDiamondItem", UIBaseCtrl)
UIStoreDiamondItem.__index = UIStoreDiamondItem
UIStoreDiamondItem.mBtn_Main = nil
UIStoreDiamondItem.mImage_IconImage = nil
UIStoreDiamondItem.mText_Name = nil
UIStoreDiamondItem.mText_PriceNumber = nil
UIStoreDiamondItem.mText_Price_PriceNumber = nil
function UIStoreDiamondItem:__InitCtrl()
  self.mBtn_Main = self:GetButton("Btn_Main")
  self.mImage_IconImage = self:GetImage("Btn_Main/GoodsIcon/Image_IconImage")
  self.mText_Name = self:GetText("Btn_Main/GoodsName/Text_Name")
  self.mText_PriceNumber = self:GetText("Btn_Main/Price/Text_PriceNumber")
  self.mText_Price_PriceNumber = self:GetText("Shadow/UI_Price/Text_PriceNumber")
end
function UIStoreDiamondItem:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
function UIStoreDiamondItem:InitData(data)
  self.mData = data
  self.mText_Name.text = data.name
  local num = tonumber(data.price)
  self.mText_PriceNumber.text = "<size=48>￥</size><size=78>" .. formatnum(num) .. "</size>"
  self.mText_Price_PriceNumber.text = "<size=48>￥</size><size=78>" .. formatnum(num) .. "</size>"
  self.mImage_IconImage.sprite = UIUtils.GetIconSprite("Icon/Item", data.icon)
end
