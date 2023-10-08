require("UI.UIBaseCtrl")
DZBuyItem = class("DZBuyItem", UIBaseCtrl)
DZBuyItem.__index = DZBuyItem
function DZBuyItem:__InitCtrl()
end
function DZBuyItem:InitCtrl(root)
  local obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/Btn_ComStoreBuyItem.prefab", self))
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
function DZBuyItem:SetData(Data, panelData)
  self.mData = Data
  self.ui.mText_StoreName.text = Data.storeData:GetStoreGoodData().name.str
  local unlockNum = tonumber(Data.storeData:GetStoreGoodData().spec_args) or 0
  local itemId = 0
  local itemNum = 0
  local rewards = Data.storeData.ItemNumList
  for i = 0, rewards.Count - 1 do
    itemId = rewards[i].itemid
    itemNum = rewards[i].num
  end
  local goodType = self.mData.storeData:GetStoreGoodData().goods_type
  setactive(self.ui.mTrans_LostLegacy, goodType == CS.GF2.Data.GoodsType.Darkzonelost)
  setactive(self.ui.mTrans_GrpItemIcon, false)
  setactive(self.ui.mTrans_GrpEquipIcon, false)
  setactive(self.ui.mTrans_GrpWeaponcon, false)
  setactive(self.ui.mTrans_GrpLock, false)
  setactive(self.ui.mTrans_GrpState, false)
  setactive(self.ui.mTrans_GrpLeftTime, false)
  setactive(self.ui.mTrans_GrpTopLeft, false)
  setactive(self.ui.mTrans_GrpIcon, false)
  setactive(self.ui.mTrans_GrpSoldOut, false)
  setactive(self.ui.mTrans_GrpCost, false)
  local itemData = TableData.listItemDatas:GetDataById(itemId)
  if itemData.type == 20 then
    setactive(self.ui.mTrans_GrpWeaponcon, true)
    self.ui.mImg_WeaponIcon.sprite = ResSys:GetAtlasSprite("Icon/Weapon/" .. Data.storeData.icon)
  elseif itemData.type == 23 then
    setactive(self.ui.mTrans_GrpWeaponcon, true)
    self.ui.mImg_WeaponIcon.sprite = ResSys:GetAtlasSprite("Icon/EquipmentIcon/" .. Data.storeData.icon)
  elseif itemData.type == 21 then
    setactive(self.ui.mTrans_GrpWeaponcon, true)
    self.ui.mImg_WeaponIcon.sprite = IconUtils.GetWeaponPartIcon(Data.storeData.icon)
  else
    setactive(self.ui.mTrans_GrpItemIcon, true)
    self.ui.mImg_StoreIcon.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. Data.storeData.icon)
  end
  local costItemData = TableData.listItemDatas:GetDataById(Data.storeData.price_type)
  self.ui.mImg_BottomLine.color = TableData.GetGlobalGun_Quality_Color2(itemData.rank)
  if panelData.IsNpcUnlock ~= true then
    setactive(self.ui.mTrans_GrpLock, true)
    setactive(self.ui.mTrans_GrpLimitBuy, false)
    TipsManager.Add(self.ui.mBtn_Self.gameObject, itemData)
    self.ui.mImg_CostIcon.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. costItemData.icon)
    setactive(self.ui.mTrans_GrpState, true)
    local level = DZStoreUtils:GetCurFavorLevelAndExp(panelData.Npc, unlockNum)
    self.ui.mText_StateName.text = string_format(TableData.GetHintById(903217), level)
    return
  end
  local NpcFavorData = DarkNetCmdStoreData:GetNpcDataById(panelData.Npc)
  local NpcFavor = 0
  if NpcFavorData ~= nil then
    NpcFavor = NpcFavorData.Favor
    local a, b, c, d = DZStoreUtils:GetCurFavorLevelAndExp(panelData.Npc, NpcFavorData.Favor)
    self.Basediscount = d
  else
    local a, b, c, d = DZStoreUtils:GetCurFavorLevelAndExp(panelData.Npc, 0)
    self.Basediscount = d
  end
  self.ui.mImg_CostIcon.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. costItemData.icon)
  self:SetBaseLimit(Data, NpcFavor)
  setactive(self.ui.mTrans_LeftNum, 0 < self.LimitCount and Data.storeData.refresh_type == 0)
  setactive(self.ui.mText_LeftNum.gameObject, Data.storeData.refresh_type == 0)
  setactive(self.ui.mTrans_GrpLimitBuy, 0 < self.LimitCount and 0 < Data.storeData.refresh_type)
  setactive(self.ui.mText_LimitNum.gameObject, 0 < Data.storeData.refresh_type)
  self:SetRefreshType(Data, Data.storeData.buy_times, Data.storeData.refresh_type)
  if unlockNum <= NpcFavor and 0 < Data.storeData.refresh_type then
    local uid = AccountNetCmdHandler.Uid
    local key = uid .. Data.storeData.id .. "LatestFreshTime"
    local value = NetCmdStoreData:GetGoodsRefreshById(Data.storeData.id)
    PlayerPrefs.SetString(key, value)
  end
  local canClick = true
  local playerLevel = AccountNetCmdHandler:GetLevel()
  if 0 < Data.storeData.buy_times then
    if unlockNum > playerLevel then
      setactive(self.ui.mTrans_GrpLock, true)
      TipsManager.Add(self.ui.mBtn_Self.gameObject, itemData)
      setactive(self.ui.mTrans_GrpState, true)
      canClick = false
      self.ui.mText_StateName.text = string_format(TableData.GetHintById(160013), unlockNum)
      setactive(self.ui.mTrans_LeftNum, false)
      setactive(self.ui.mText_LeftNum.gameObject, false)
      setactive(self.ui.mTrans_GrpLimitBuy, false)
      setactive(self.ui.mText_LimitNum.gameObject, false)
    else
      setactive(self.ui.mTrans_GrpIcon, true)
      setactive(self.ui.mTrans_GrpLock, false)
      if 0 < self.flexibleLimit then
        self:SetPrice(Data)
        self:SetflexibleLimit(Data, Data.storeData.buy_times, Data.storeData.refresh_type)
      else
        canClick = false
        setactive(self.ui.mTrans_GrpSoldOut, true)
        TipsManager.Add(self.ui.mBtn_Self.gameObject, itemData)
        self.StoreId = Data.storeData.id
        self.CountDown = Data.storeData.refresh_timer ~= ""
        setactive(self.ui.mTrans_GrpLeftTime, Data.storeData.refresh_timer ~= "")
        setactive(self.ui.mTrans_GrpLeftTime, Data.storeData.refresh_timer ~= "")
      end
    end
  elseif panelData.IsNpcUnlock then
    if unlockNum > playerLevel then
      canClick = false
      setactive(self.ui.mTrans_GrpLock, true)
      TipsManager.Add(self.ui.mBtn_Self.gameObject, itemData)
      setactive(self.ui.mTrans_GrpState, true)
      self.ui.mText_StateName.text = string_format(TableData.GetHintById(160013), unlockNum)
      setactive(self.ui.mTrans_LeftNum, false)
      setactive(self.ui.mText_LeftNum.gameObject, false)
      setactive(self.ui.mTrans_GrpLimitBuy, false)
      setactive(self.ui.mText_LimitNum.gameObject, false)
    else
      setactive(self.ui.mTrans_GrpIcon, true)
      setactive(self.ui.mTrans_GrpLock, false)
      self:SetPrice(Data, false)
      self:SetflexibleLimit(Data, 0, Data.refresh_type)
    end
  else
    canClick = false
    setactive(self.ui.mTrans_GrpLock, true)
    TipsManager.Add(self.ui.mBtn_Self.gameObject, itemData)
    setactive(self.ui.mTrans_GrpState, true)
    local level = DZStoreUtils:GetCurFavorLevelAndExp(panelData.Npc, unlockNum)
    self.ui.mText_StateName.text = string_format(TableData.GetHintById(903217), level)
  end
  if canClick then
    local data = {}
    data.ItemData = itemData
    data.NpcId = panelData.Npc
    data.StoreId = Data.storeData.id
    data.StoreNum = itemNum
    data.CurrencyId = Data.storeData.price_type
    data.HasLimit = true
    data.LeftNum = self.flexibleLimit
    data.Price = self.RealPrice
    data.Favordiscount = self.Basediscount
    data.TotalBuy = Data.storeData.buy_times
    data.pricediscountList = self.pricediscountList
    data.Countlist = self.Countlist
    data.BasePrice = Data.storeData.price * (self.Basediscount / 1000)
    if goodType == CS.GF2.Data.GoodsType.Darkzonelost then
      data.onlyID = Data.equipData.Id
    end
    UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
      UIManager.OpenUIByParam(UIDef.UIDarkZoneStoreBuyDialog, data)
    end
  end
end
function DZBuyItem:UpdateTime(deltatime)
  if self.CountDown == true then
    local IsRefresh = DarkNetCmdStoreData:IsRefreshStore(self.StoreId)
    self.ui.mText_Time.text = self.mData.storeData.refreshTime
    if IsRefresh then
      self.CountDown = nil
    end
  end
end
function DZBuyItem:SetPrice(Data, IsBoughtItem)
  local pricediscountList = {}
  local list = {}
  local stcData = Data.storeData:GetStoreGoodData()
  for i = 0, stcData.price_args.Count - 1 do
    local pricearr = string.split(stcData.price_args[i], ":")
    table.insert(pricediscountList, tonumber(pricearr[2]))
    table.insert(list, tonumber(pricearr[1]))
  end
  self.pricediscountList = pricediscountList
  self.Countlist = list
  setactive(self.ui.mTrans_GrpCost, true)
  self.RealPrice = tonumber(Data.storeData.price) * (self.Basediscount / 1000)
  local rebate = self.RealPrice / stcData.price
  setactive(self.ui.mTrans_GrpTopLeft, rebate < 1 and self.mData.storeData:GetStoreGoodData().goods_type ~= CS.GF2.Data.GoodsType.Darkzonelost)
  if rebate < 1 then
    setactive(self.ui.mText_BeforeCostNum, true)
    self.ui.mText_BeforeCostNum.text = string.format("%.0f", stcData.price)
  end
  self.ui.mText_LeftUpNum.text = math.floor((1 - rebate) * 100 + 0.5) .. "%"
  self.RealPrice = math.ceil(self.RealPrice)
  self.ui.mText_CostNum.text = self.RealPrice
end
function DZBuyItem:SetBaseLimit(Data, NpcFavor)
  local favorList = {}
  local limitList = {}
  local stcData = Data.storeData:GetStoreGoodData()
  for i = 0, stcData.limit_args.Count - 1 do
    local arr = string.split(stcData.limit_args[i], ":")
    table.insert(favorList, tonumber(arr[1]))
    table.insert(limitList, tonumber(arr[2]))
  end
  local count = stcData.limit
  for i = 1, #favorList do
    if NpcFavor >= favorList[i] and favorList[i + 1] ~= nil and NpcFavor < favorList[i + 1] then
      count = limitList[i]
    elseif NpcFavor >= favorList[i] and favorList[i + 1] == nil then
      count = limitList[#favorList]
    end
  end
  self.LimitCount = count
  self.flexibleLimit = count - Data.storeData.buy_times
  if Data.storeData:GetStoreGoodData().goods_type == CS.GF2.Data.GoodsType.Darkzonelost then
    self.LimitCount = 0
    self.flexibleLimit = 1
  end
end
function DZBuyItem:SetflexibleLimit(Data, HasBuyNum, refreshType)
  if Data.storeData.IsMultiPrice == false then
    return
  end
  local price_args = Data.storeData:GetStoreGoodData().price_args
  local pricediscountList = {}
  local list = {}
  for i = 0, price_args.Count - 1 do
    local pricearr = string.split(price_args[i], ":")
    table.insert(pricediscountList, tonumber(pricearr[2]))
    table.insert(list, tonumber(pricearr[1]))
  end
  if HasBuyNum < pricediscountList[1] then
    self.flexibleLimit = pricediscountList[1]
  elseif HasBuyNum >= pricediscountList[#pricediscountList] then
    self.flexibleLimit = self.LimitCount - HasBuyNum
  else
    for i = 1, #pricediscountList do
      if HasBuyNum >= pricediscountList[i] and pricediscountList[i + 1] ~= nil and HasBuyNum < pricediscountList[i + 1] then
        self.flexibleLimit = pricediscountList[i + 1] - HasBuyNum
      end
    end
  end
  self.ui.mText_LimitNum.text = self.flexibleLimit
  if refreshType ~= nil then
    self:SetRefreshType(Data, HasBuyNum, refreshType)
  end
end
function DZBuyItem:SetRefreshType(Data, HasBuyNum, refreshType)
  if refreshType == 0 then
    local count = self.LimitCount - HasBuyNum
    self.ui.mText_LeftNum.text = TableData.GetHintById(903195) .. tostring(count)
  end
  if refreshType == 1 then
    self.ui.mText_LimitNum.text = string_format(TableData.GetHintById(903218), self.LimitCount - HasBuyNum, self.LimitCount)
  end
  if refreshType == 2 then
    self.ui.mText_LimitNum.text = string_format(TableData.GetHintById(903219), self.LimitCount - HasBuyNum, self.LimitCount)
  end
  if refreshType == 3 then
    self.ui.mText_LimitNum.text = string_format(TableData.GetHintById(903220), self.LimitCount - HasBuyNum, self.LimitCount)
  end
  if refreshType == 4 then
    local str = string.split(Data.storeData.refresh_timer, ";")
    self.ui.mText_LimitNum.text = string_format(TableData.GetHintById(903221), str[1], self.LimitCount - HasBuyNum, self.LimitCount)
  end
  if refreshType == 5 then
    self.ui.mText_LimitNum.text = string_format(TableData.GetHintById(903222), self.LimitCount - HasBuyNum, self.LimitCount)
  end
end
