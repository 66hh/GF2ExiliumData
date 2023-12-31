require("UI.UIBaseCtrl")
StoreLackToBuyCoin = class("StoreLackToBuyCoin", UIBaseCtrl)
StoreLackToBuyCoin.__index = StoreLackToBuyCoin
StoreLackToBuyCoin.mImage_CoinImage = nil
StoreLackToBuyCoin.mText_CoinAmount = nil
function StoreLackToBuyCoin:__InitCtrl()
  self.mImage_CoinImage = self:GetImage("Image_CoinImage")
  self.mText_CoinAmount = self:GetText("Text_CoinAmount")
end
function StoreLackToBuyCoin:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("Store/StoreLackToBuyCoin.prefab", self))
  self:SetRoot(obj.transform)
  setparent(parent, obj.transform)
  obj.transform.localScale = vectorone
  self:SetRoot(obj.transform)
  self:__InitCtrl()
end
function StoreLackToBuyCoin:SetData(itemId, itemNum)
  self.mImage_CoinImage.sprite = CS.IconUtils.GetItemIconSprite(itemId)
  self.mText_CoinAmount.text = itemNum
end
