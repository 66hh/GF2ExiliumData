require("UI.UIBaseCtrl")
require("UI.MonopolyActivity.ActivityTourGlobal")
ActivityTourStoreItem = class("ActivityTourStoreItem", UIBaseCtrl)
ActivityTourStoreItem.__index = ActivityTourStoreItem
function ActivityTourStoreItem:ctor()
  self.super.ctor(self)
end
function ActivityTourStoreItem:InitCtrl(itemPrefab, parent, onclick)
  local instObj = instantiate(itemPrefab, parent)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(instObj.transform, self.ui)
  setactive(self.ui.mText_LeftNum.gameObject, false)
  setactive(self.ui.mTrans_StepNum.gameObject, false)
  self:ShowSelect(false)
  self.ui.mBtn_Root.interactable = true
  self.goodsId = 0
  self.commandIndex = 0
  UIUtils.AddBtnClickListener(self.ui.mBtn_Root, function()
    if onclick then
      onclick(self.goodsId, self.commandIndex)
    end
  end)
end
function ActivityTourStoreItem:SetData(goodsId, commandID, index)
  setactive(self.ui.mUIRoot, true)
  self.commandIndex = index
  self.goodsId = goodsId
  self.data = TableData.listMonopolyOrderDatas:GetDataById(commandID and commandID or goodsId)
  self.ui.mImage_Icon.sprite = ActivityTourGlobal.GetActivityTourSprite(self.data.order_icon)
  self.ui.mText_Name.text = self.data.name.str
  self.ui.mImage_Quality.color = ActivityTourGlobal.GetCommandItemQualityColor(self.data.level)
end
function ActivityTourStoreItem:RefreshStoreInfo(isSelect, isShowBuyPart)
  setactive(self.ui.mText_LeftNum.gameObject, isShowBuyPart)
  setactive(self.ui.mTrans_StepNum.gameObject, isShowBuyPart)
  self.ui.mBtn_Root.interactable = not isSelect
  if not isShowBuyPart then
    return
  end
  local lefNum = 0
  local price = 0
  for i = 0, MonopolyWorld.MpData.ShopGoodsList.Count - 1 do
    if MonopolyWorld.MpData.ShopGoodsList[i].Id == self.goodsId then
      lefNum = MonopolyWorld.MpData.ShopGoodsList[i].Limit
      price = MonopolyWorld.MpData.ShopGoodsList[i].Price
      break
    end
  end
  self.ui.mText_LeftNum.text = string_format(TableData.GetHintById(270249), lefNum)
  self.ui.mText_StepNum.text = price
  self.ui.mImg_StepIcon.sprite = IconUtils.GetActivityTourIcon(MonopolyWorld.MpData.levelData.token_icon)
end
function ActivityTourStoreItem:EnableBtn(enable)
  UIUtils.EnableBtn(self.ui.mBtn_Root, enable)
end
function ActivityTourStoreItem:ShowSelect(show)
  setactive(self.ui.mTrans_Select, show)
end
function ActivityTourStoreItem:Hide()
  setactive(self.ui.mUIRoot, false)
end
