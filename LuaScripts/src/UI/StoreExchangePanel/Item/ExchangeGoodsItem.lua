require("UI.UIBaseCtrl")
ExchangeGoodsItem = class("ExchangeGoodsItem", UIBaseCtrl)
ExchangeGoodsItem.__index = ExchangeGoodsItem
ExchangeGoodsItem.mImage_Rank = nil
ExchangeGoodsItem.mImage_IconImage = nil
ExchangeGoodsItem.mImage_Head = nil
ExchangeGoodsItem.mImage_GoodsRate = nil
ExchangeGoodsItem.mText_Name = nil
ExchangeGoodsItem.mText_AmountNumber = nil
ExchangeGoodsItem.mText_PriceNumber = nil
ExchangeGoodsItem.mText_refreshtime = nil
ExchangeGoodsItem.mTrans_HeadIcon = nil
ExchangeGoodsItem.mTrans_EquipIcon = nil
ExchangeGoodsItem.mImage_EquipIcon = nil
ExchangeGoodsItem.mTrans_base_arrow = nil
ExchangeGoodsItem.mTrans_Recommend = nil
ExchangeGoodsItem.mTrans_RecommendUnavailableMask = nil
ExchangeGoodsItem.mTrans_UnavailableMask = nil
ExchangeGoodsItem.mTrans_Refreshtime = nil
ExchangeGoodsItem.mTrans_New = nil
ExchangeGoodsItem.mImage_RankLine = nil
ExchangeGoodsItem.mTrans_WeaponIcon = nil
ExchangeGoodsItem.mImage_WeaponIcon = nil
ExchangeGoodsItem.mTrans_EquipIcon = nil
ExchangeGoodsItem.mImage_EquipIcon = nil
ExchangeGoodsItem.mTrans_Pos = nil
ExchangeGoodsItem.mImage_Pos = nil
ExchangeGoodsItem.mImagePrice = nil
ExchangeGoodsItem.mTrans_MonthLeft = nil
ExchangeGoodsItem.mTrans_GrpElement = nil
ExchangeGoodsItem.mImage_ElementIcon = nil
function ExchangeGoodsItem:__InitCtrl()
end
ExchangeGoodsItem.mData = nil
function ExchangeGoodsItem:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/Btn_ComStoreBuyItem.prefab", self))
  setparent(parent, obj.transform)
  setscale(obj.transform, vectorzero)
  obj.transform.anchoredPosition = vector2one * 1000000
  self.ui = {}
  self:SetRoot(obj.transform)
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:__InitCtrl()
end
function ExchangeGoodsItem:InitData(data)
  self.mData = data
  self.ui.mText_StoreName.text = data.name
  local num = tonumber(data.price)
  self.ui.mText_CostNum.color = ColorUtils.WhiteColor
  self.ui.mText_CostNum.text = formatnum(num)
  setactive(self.ui.mTrans_GrpItemIcon, false)
  setactive(self.ui.mTrans_GrpEquipIcon, false)
  setactive(self.ui.mTrans_GrpWeaponcon, false)
  setactive(self.ui.mTrans_GrpLock, false)
  setactive(self.ui.mTrans_GrpState, false)
  setactive(self.ui.mTrans_GrpLeftTime, false)
  setactive(self.ui.mTrans_GrpTopLeft, false)
  setactive(self.ui.mTrans_GrpLimitBuy, false)
  setactive(self.ui.mTrans_GrpTag, false)
  setactive(self.ui.mText_LimitNum.gameObject, false)
  setactive(self.ui.mTrans_GrpSoldOut, false)
  setactive(self.ui.mText_BeforeCostNum, false)
  setactive(self.ui.mTrans_GrpRefreshTime, false)
  setactive(self.ui.mImg_StoreIcon, false)
  setactive(self.ui.mImg_Element, false)
  if data.limit ~= 0 and 0 < data.refresh_type then
    setactive(self.ui.mTrans_GrpLimitBuy.gameObject, true)
    setactive(self.ui.mText_LimitNum.gameObject, true)
    if data.refresh_type ~= 6 then
      self.ui.mText_LimitNum.text = string_format(TableData.GetHintById(106050), data.remain_times .. "/" .. data.limit)
    else
      self.ui.mText_LimitNum.text = string_format(TableData.GetHintById(120087), data.remain_times, data.limit)
    end
  else
    setactive(self.ui.mTrans_GrpLimitBuy.gameObject, false)
  end
  if data.limit ~= 0 and data.refresh_type == 0 then
    setactive(self.ui.mTrans_LeftNum.gameObject, true)
    setactive(self.ui.mTrans_GrpLimitBuy.gameObject, false)
    self.ui.mText_LeftNum.text = string_format(TableData.GetHintById(808), data.remain_times)
  else
    setactive(self.ui.mTrans_LeftNum.gameObject, false)
  end
  if data.IsRecommend or data.IsFlashSale or data.IsHot then
    setactive(self.ui.mTrans_GrpTag.gameObject, true)
    local hintId = 106101
    if data.IsFlashSale then
      hintId = 106102
    elseif data.IsHot then
      hintId = 106103
    end
    self.ui.mText_Tag.text = TableData.GetHintById(hintId)
  else
    setactive(self.ui.mTrans_GrpTag.gameObject, false)
  end
  if data.price_args_type == 3 and data.price ~= data.base_price then
    setactive(self.ui.mTrans_GrpTopLeft.gameObject, true)
    self.ui.mText_BeforeCostNum.text = FormatNum(data.base_price)
    setactive(self.ui.mText_BeforeCostNum.gameObject, true)
    self.ui.mText_DiscountNum.text = "-" .. math.floor((data.base_price - data.price) / data.base_price * 100 + 0.5) .. "%"
    self.ui.mText_CostNum.color = ColorUtils.StringToColor("f0af14")
  end
  if data.is_unlocked == false and data.IsShowTime == false then
    setactive(self.ui.mTrans_GrpLock, true)
    self.ui.mText_LockCause.text = TableData.GetHintById(103051)
    setactive(self.ui.mTrans_GrpTopLeft.gameObject, false)
    setactive(self.ui.mTrans_GrpLimitBuy.gameObject, false)
  end
  if data.is_unlocked == false and data.IsShowTime == true then
    setactive(self.ui.mTrans_GrpLock, true)
    setactive(self.ui.mTrans_GrpTopLeft.gameObject, false)
    setactive(self.ui.mTrans_GrpLimitBuy.gameObject, false)
    self.ui.mText_LockCause.text = TableData.GetHintById(103051)
  end
  self:SetLockCause()
  if 0 < data.price_type then
    local stcData = TableData.GetItemData(data.price_type)
    if stcData == nil then
      gferror("未知的PriceType" .. data.price_type .. ",Item表里没有该ID")
    end
    setactive(self.ui.mTrans_GrpIcon, true)
    self.ui.mImg_CostIcon.sprite = IconUtils.GetItemIcon(stcData.icon)
  end
  if data.IsToOutStock == true then
    setactive(self.ui.mTrans_GrpLeftTime, true)
    self.ui.mText_Time.text = data.left_time
  end
  local itemData = TableData.GetItemData(data.frame, true)
  if data:IsSellout() then
    setactive(self.ui.mTrans_GrpSoldOut.gameObject, true)
    setactive(self.ui.mTrans_GrpTopLeft.gameObject, false)
  else
    setactive(self.ui.mTrans_GrpSoldOut.gameObject, false)
  end
  if itemData ~= nil and itemData.type == 20 then
    setactive(self.ui.mTrans_GrpWeaponcon, true)
    local weaponData = TableData.listGunWeaponDatas:GetDataById(itemData.args[0])
    if weaponData ~= nil then
      local elementData = TableData.listLanguageElementDatas:GetDataById(weaponData.element)
      if data.icon ~= nil and data.icon ~= "" then
        self.ui.mImg_WeaponIcon.sprite = IconUtils.GetItemIcon(data.icon)
      else
        self.ui.mImg_WeaponIcon.sprite = IconUtils.GetWeaponNormalSprite(weaponData.res_code)
      end
    end
  elseif itemData ~= nil and itemData.type == 25 then
    setactive(self.ui.mTrans_GrpItemIcon, true)
    local supplyData = TableData.listSupplyDatas:GetDataById(data.frame)
    local elementData = TableData.listLanguageElementDatas:GetDataById(supplyData.Type)
    self.ui.mImg_Element.sprite = IconUtils.GetElementIconM(elementData.icon)
    setactive(self.ui.mImg_Element, true)
    if data.icon ~= nil and data.icon ~= "" then
      self.ui.mImg_StoreIcon.sprite = IconUtils.GetItemIcon(data.icon)
    elseif itemData ~= nil then
      self.ui.mImg_StoreIcon.sprite = IconUtils.GetItemIconSprite(itemData.id)
    end
  else
    setactive(self.ui.mTrans_GrpItemIcon, true)
    if data.icon ~= nil and data.icon ~= "" then
      self.ui.mImg_StoreIcon.sprite = IconUtils.GetItemIcon(data.icon)
    elseif itemData ~= nil then
      self.ui.mImg_StoreIcon.sprite = IconUtils.GetItemIconSprite(itemData.id)
    end
  end
  self.ui.mImg_BottomLine.color = TableData.GetGlobalGun_Quality_Color2(data.rank)
  local storeGoodData = data:GetStoreGoodData()
  self:ExchangeGoodsItem(data, storeGoodData)
  setactive(self.ui.mTrans_RedPoint.gameObject, self.mData.id == CS.CommonDefine.Exchange_Store_License_Id and not data:IsSellout())
end
function ExchangeGoodsItem:SetLockCause()
  setactive(self.ui.mText_StateName, false)
end
function ExchangeGoodsItem:Update()
  if self.mData == nil then
    return
  end
  if self.mData.IsToOutStock == true then
    setactive(self.ui.mTrans_GrpLeftTime, true)
    self.ui.mText_Time.text = self.mData.left_time
  end
  self:RefreshTime(self.mData, self.mData:GetStoreGoodData())
end
function ExchangeGoodsItem:ExchangeGoodsItem(data, stcData)
  if stcData == nil then
    return
  end
  local refreshType = stcData.refresh_type
  if 0 < refreshType then
    self.ui.mText_RefreshTime.text = data.refreshTime
  end
  local isUnLock = data.is_unlocked
  setactive(self.ui.mTrans_GrpRefreshTime, 0 < refreshType and isUnLock)
end
function ExchangeGoodsItem:RefreshTime(data, stcData)
  if self.mData == nil or self.stcData == nil then
    return
  end
  local refreshType = stcData.refresh_type
  if 0 < refreshType then
    self.ui.mText_RefreshTime.text = data.refreshTime
  end
  setactive(self.ui.mTrans_GrpRefreshTime, 0 < refreshType)
end
function ExchangeGoodsItem:SetLock()
  setactive(self.ui.mTrans_GrpLock, true)
  setactive(self.ui.mTrans_GrpTopLeft.gameObject, false)
  setactive(self.ui.mTrans_GrpLeftTime.gameObject, false)
  setactive(self.ui.mTrans_GrpLimitBuy.gameObject, false)
end
