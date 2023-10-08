require("UI.StorePanel.UIStoreConfirmPanel")
require("UI.UIBaseCtrl")
UIStoreBuyItem = class("UIStoreBuyItem", UIBaseCtrl)
UIStoreBuyItem.__index = UIStoreBuyItem
function UIStoreBuyItem:__InitCtrl()
end
function UIStoreBuyItem:InitCtrl(root)
  local obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/Btn_ComStoreBuyItem.prefab", self))
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
function UIStoreBuyItem:SetData(data, parent)
  if data == nil then
    setactive(self.mUIRoot, false)
    return
  end
  setactive(self.mUIRoot, true)
  setactive(self.ui.mTrans_GrpEquipIcon, false)
  setactive(self.ui.mTrans_GrpWeaponcon, false)
  setactive(self.ui.mTrans_GrpLock, false)
  setactive(self.ui.mTrans_GrpState, false)
  setactive(self.ui.mTrans_GrpLeftTime, false)
  setactive(self.ui.mTrans_GrpTopLeft, false)
  setactive(self.ui.mTrans_GrpLimitBuy, false)
  setactive(self.ui.mTrans_GrpIcon, false)
  setactive(self.ui.mTrans_GrpCost, false)
  self.mData = data
  self.stcData = data:GetStoreGoodData()
  self.ui.mText_StoreName.text = self.stcData.name.str
  if self.stcData.icon == nil or self.stcData.icon == "" then
    local itemData = TableData.GetItemData(data.ItemNumList[0].itemid)
    if itemData ~= nil then
      self.ui.mImg_StoreIcon.sprite = IconUtils.GetItemIcon(itemData.icon)
    end
  else
    self.ui.mImg_StoreIcon.sprite = IconUtils.GetItemIcon(self.stcData.icon)
  end
  self.ui.mImg_BottomLine.color = TableData.GetGlobalGun_Quality_Color2(data.rank)
  self.soldOut = data:IsSellout()
  self.isLocked = data:IsPreShowing()
  if data.price_args_type == 3 and data.price ~= data.base_price then
    local discount = math.floor((data.base_price - data.price) / data.base_price * 100 + 0.5)
    setactive(self.ui.mTrans_GrpTopLeft.gameObject, discount < 100 and not self.isLocked)
    self.ui.mText_BeforeCostNum.text = data.base_price
    if data.price == 0 then
      self.ui.mText_DiscountNum.text = "-" .. 100 .. "%"
    else
      self.ui.mText_DiscountNum.text = "-" .. discount .. "%"
    end
  end
  setactive(self.ui.mTrans_GrpIcon, self.stcData.price_type > UIStoreConfirmPanel.REAL_MONEY_ID)
  if self.stcData.price_type > UIStoreConfirmPanel.REAL_MONEY_ID then
    local costItemData = TableData.listItemDatas:GetDataById(self.stcData.price_type)
    self.ui.mImg_CostIcon.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. costItemData.icon)
    if data.price == "0" then
      self.ui.mText_CostNum.text = TableData.GetHintById(901056)
      setactive(self.ui.mTrans_GrpIcon, false)
    else
      self.ui.mText_CostNum.text = data.price
    end
  else
    self.ui.mText_CostNum.text = "¥ " .. data.price
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
    if self.stcData.goods_type == CS.GF2.Data.GoodsType.LoungeClothes then
      UIManager.OpenUIByParam(UIDef.UILoungeItemDetailPanel, data)
      return
    elseif self.stcData.goods_type == CS.GF2.Data.GoodsType.LoungeNormal then
      UIManager.OpenUIByParam(UIDef.UILoungeItemDetailPanel, data)
      return
    end
    if data.IsShowTime == false then
      UIManager.OpenUIByParam(UIDef.UIStoreLockDialog, {data = data, parent = self})
      return
    end
    if data:IsSellout() then
      UITipsPanel.OpenStoreGood(self.mData.name, self.mData.icon, self.mData.description, self.mData.rank)
      return
    end
    if self.isLocked then
      UIManager.OpenUIByParam(UIDef.UIStoreLockDialog, {data = data, parent = self})
      return
    end
    if self.stcData.limit > 0 and self.stcData.limit - data.buy_times == 0 then
      UITipsPanel.OpenStoreGood(self.stcData.name.str, self.stcData.icon, self.stcData.description.str, self.stcData.rank, self.stcData)
      return
    end
    if self.stcData.goods_type == CS.GF2.Data.GoodsType.Normal then
      UIManager.OpenUIByParam(UIDef.UIStoreConfirmPanel, {data = data, parent = parent})
    elseif self.stcData.goods_type == CS.GF2.Data.GoodsType.GiftDrop then
      UIManager.OpenUIByParam(UIDef.UIStoreBoxBuyDialog, {data = data, parent = parent})
    elseif self.stcData.goods_type == CS.GF2.Data.GoodsType.GiftOptional then
      UIManager.OpenUIByParam(UIDef.UIStoreDiyBuyDialog, data)
    elseif self.stcData.goods_type == CS.GF2.Data.GoodsType.LoungeClothes then
      UIManager.OpenUIByParam(UIDef.UILoungeItemDetailPanel, data)
    elseif self.stcData.goods_type == CS.GF2.Data.GoodsType.LoungeGift then
      UIManager.OpenUIByParam(UIDef.UIStoreConfirmPanel, {data = data, parent = parent})
    elseif self.stcData.goods_type == CS.GF2.Data.GoodsType.LoungeNormal then
      UIManager.OpenUIByParam(UIDef.UILoungeItemDetailPanel, data)
    elseif self.stcData.goods_type == CS.GF2.Data.GoodsType.GiftLevel then
      UIManager.OpenUIByParam(UIDef.UIStoreBoxBuyDialog, {data = data, parent = parent})
    end
  end
  self:SetLimit(data, self.stcData)
  self.feature_code = self.stcData.feature_code.Count > 0 and self.stcData.feature_code[0] or 0
  setactive(self.ui.mTrans_GrpSoldOut, 0 < self.stcData.limit and self.stcData.limit - data.buy_times == 0)
  setactive(self.ui.mTrans_GrpCost, not self.isLocked)
  setactive(self.ui.mTrans_GrpTag, self.feature_code > 0 and not self.isLocked and data.refresh_type == 0 and not self.soldOut)
  setactive(self.ui.mTrans_LeftNum, 0 < self.stcData.limit and data.refresh_type == 0)
  setactive(self.ui.mTrans_GrpLimitBuy, 0 < self.stcData.limit and 0 < data.refresh_type)
  setactive(self.ui.mText_LimitNum, 0 < data.refresh_type)
  setactive(self.ui.mText_StateName, not data.is_unlocked)
  setactive(self.ui.mTrans_GrpSoldOut.gameObject, self.soldOut)
  setactive(self.ui.mTrans_RedPoint.gameObject, self.stcData.price == 0 and not self.isLocked)
  setactive(self.ui.mText_BeforeCostNum, self.stcData.price_args_type == 3 and tonumber(data.price) < data.base_price)
  setactive(self.ui.mTrans_GrpLock, self.isLocked)
  setactive(self.ui.mTrans_Paid, data.price_type == GlobalConfig.ResourceType.CreditPay and 0 < TableData.SystemVersionOpenData.FreePayCredit)
  if self.feature_code > 0 then
    self.ui.mText_Tag.text = TableData.GetHintById(106100 + self.feature_code)
  end
  if self.stcData.price_args_type == 3 then
    self.ui.mText_BeforeCostNum.text = math.floor(data.base_price)
  end
  if self.isLocked then
    if not data.is_unlocked then
      self.ui.mText_StateName.text = data.is_unlocked
    else
      self.ui.mText_StateName.text = data.is_unlocked
    end
  end
  if data.IsToOutStock == true and not self.soldOut then
    self.ui.mText_Time.text = data.left_time
    setactive(self.ui.mTrans_GrpLeftTime, true)
    setactive(self.ui.mTrans_GrpTag, false)
  end
end
function UIStoreBuyItem:Update()
  self:RefreshLeftTime()
  self:RefreshTime(self.mData, self.stcData)
end
function UIStoreBuyItem:RefreshLeftTime()
  if self.mData == nil then
    return
  end
  if self.mData.IsToOutStock == true and not self.soldOut then
    self.ui.mText_Time.text = self.mData.left_time
    setactive(self.ui.mTrans_GrpLeftTime, true)
    setactive(self.ui.mTrans_GrpTag, false)
  end
end
function UIStoreBuyItem:RefreshTime(data, stcData)
  if self.mData == nil or self.stcData == nil then
    return
  end
  local refreshType = stcData.refresh_type
  if 0 < refreshType then
    self.ui.mText_RefreshTime.text = data.refreshTime
  end
  setactive(self.ui.mTrans_GrpRefreshTime, 0 < refreshType)
end
function UIStoreBuyItem:SetRefreshType(data, stcData)
  local refreshType = stcData.refresh_type
  if 0 < refreshType then
    self.ui.mText_RefreshTime.text = data.refreshTime
  end
  setactive(self.ui.mTrans_GrpRefreshTime, 0 < refreshType)
end
function UIStoreBuyItem:SetLimit(data, stcData)
  local buyNum = data.buy_times
  local limitCount = stcData.limit
  local refreshType = stcData.refresh_type
  if 0 < limitCount then
    if 0 < refreshType then
      self.ui.mText_LimitNum.text = TableData.GetHintReplaceById(106050, stcData.limit - data.buy_times .. "/" .. stcData.limit)
    else
      self.ui.mText_LeftNum.text = TableData.GetHintReplaceById(106049, stcData.limit - data.buy_times)
    end
  end
end
function UIStoreBuyItem:SetActive(isActive)
  setactive(self.mUIRoot, isActive)
end
