require("UI.UIBaseCtrl")
DZFlexiblePrizeItem = class("DZFlexiblePrizeItem", UIBaseCtrl)
DZFlexiblePrizeItem.__index = DZFlexiblePrizeItem
function DZFlexiblePrizeItem:__InitCtrl()
end
function DZFlexiblePrizeItem:InitCtrl(root)
  local com = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
function DZFlexiblePrizeItem:SetData(Data, index)
  self.ui.mText_BuyNum.text = index
  if #Data.pricediscountList == 0 then
    setactive(self.ui.mTrans_GrpNow, true)
    self.ui.mText_Price.text = math.floor(Data.BasePrice)
  elseif index > #Data.pricediscountList then
    self.ui.mText_Price.text = math.floor(Data.BasePrice)
    if Data.TotalBuy >= Data.pricediscountList[#Data.pricediscountList] then
      setactive(self.ui.mTrans_GrpNow, true)
    end
  else
    if Data.TotalBuy == Data.pricediscountList[index] - 1 then
      setactive(self.ui.mTrans_GrpNow, true)
    end
    self.ui.mText_Price.text = math.floor(Data.Countlist[index])
  end
  local pieceData = TableData.listItemDatas:GetDataById(Data.CurrencyId)
  self.ui.mImg_Icon.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. pieceData.icon)
end
