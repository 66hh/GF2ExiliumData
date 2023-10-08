require("UI.UIBaseCtrl")
SimCombatMythicStoreListContentItem = class("SimCombatMythicStoreListContentItem", UIBaseCtrl)
local self = SimCombatMythicStoreListContentItem
function SimCombatMythicStoreListContentItem:ctor()
  self.super.ctor(self)
  self.rogueShopPlanId = 0
  self.rogueShopPlanCofigData = nil
  self.rogueBuffCofigData = nil
  self.storeGoodData = nil
  self.itemData = nil
  self.rogueShopsellData = nil
  self.rogueLimitArgs = nil
  self.isLock = false
  self.unLockList = {}
  self.isMaxLevelBuff = false
  self.storeNum = 0
  self.canLevelUpBuff = false
  self.rogueStoreState = UISimCombatRogueGlobal.RogueStoreTabBtnTypes.Buy
  self.isActive = false
  self.canBuy = true
  self.hasGun = false
  self.hasBuff = false
  self.goodsType = UISimCombatRogueGlobal.StoreTypes.Gun
end
function SimCombatMythicStoreListContentItem:SetData(curRogueStoreType, rogueShopGoodId, rogueStoreTabBtnTypes, rogueShopsellData)
  self.curRogueStoreType = curRogueStoreType
  self:ChangeRogueStoreItemState(rogueStoreTabBtnTypes)
  if self.rogueStoreState == UISimCombatRogueGlobal.RogueStoreTabBtnTypes.Buy then
    self.storeGoodData = TableData.listStoreGoodDatas:GetDataById(rogueShopGoodId)
    self.goodsType = self.storeGoodData.GoodsType
    self.rogueShopPlanId = rogueShopGoodId
    self.rogueShopPlanCofigData = TableData.listRogueShopPlanCofigDatas:GetDataById(rogueShopGoodId)
    self.rogueLimitArgs = string.split(self.rogueShopPlanCofigData.RogueLimitArgs, ":")
    self.isLock = false
    if self.rogueShopPlanCofigData.RogueUnlockArgs.Count ~= 0 then
      local curTier, curGroupNum = NetCmdSimCombatRogueData.RogueStage.Tier, NetCmdSimCombatRogueData.RogueStage.FinishedGroupNum
      for tier, groupNum in pairs(self.rogueShopPlanCofigData.RogueUnlockArgs) do
        if tier == curTier then
          self.isLock = groupNum > curGroupNum
          self.unLockList = {Tier = tier, GroupNum = groupNum}
          break
        end
      end
    end
    if self.storeGoodData.GoodsType == UISimCombatRogueGlobal.StoreTypes.Gun then
      self:SetBuyRogueStoreGunData()
    elseif self.storeGoodData.GoodsType == UISimCombatRogueGlobal.StoreTypes.Buff then
      self:SetBuyRogueStoreBuffData()
    end
  else
    self.rogueShopsellData = rogueShopsellData
    self.itemData = rogueShopGoodId
    self:SetSellRogueStoreData()
  end
end
function SimCombatMythicStoreListContentItem:SetBuyRogueStoreGunData()
  self.storeNum = 1
  self.hasGun = false
  local preGunId = tonumber(self.rogueLimitArgs[2])
  local preGuns = NetCmdSimCombatRogueData:GetRogueGuns()
  for i = 0, preGuns.Count - 1 do
    if preGunId == preGuns[i] then
      self.hasGun = true
      break
    end
  end
  self.itemData = TableData.listItemDatas:GetDataById(preGunId)
  if self.hasGun or self.isLock then
    self.canBuy = false
  end
end
function SimCombatMythicStoreListContentItem:SetBuyRogueStoreBuffData()
  local type = tonumber(self.rogueLimitArgs[1])
  local id = tonumber(self.rogueLimitArgs[2])
  local shopNum = tonumber(self.rogueLimitArgs[3])
  self.hasBuff = false
  self.storeNum = 0
  self.rogueBuffCofigData = TableData.listRogueBuffCofigDatas:GetDataById(id)
  local itemId = tonumber(string.split(self.storeGoodData.Reward, ":")[1])
  self.itemData = TableData.listItemDatas:GetDataById(itemId)
  if type == 2 then
    for i = 0, NetCmdSimCombatRogueData.RogueStage.Buffs.Count - 1 do
      local tmpBuff = NetCmdSimCombatRogueData.RogueStage.Buffs[i]
      if self.rogueBuffCofigData.GroupId == tmpBuff.GroupId then
        self.hasBuff = true
        self.storeNum = shopNum - tmpBuff.Level
        break
      end
    end
    if not self.hasBuff then
      self.storeNum = shopNum
    end
  end
  self.storeNum = UISimCombatRogueGlobal.GetBuyLeastBuffNum(self.rogueBuffCofigData.Level, self.storeNum)
  self.canLevelUpBuff = self.hasBuff
  if self.storeNum == 0 or self.isLock then
    self.canBuy = false
  end
end
function SimCombatMythicStoreListContentItem:SetSellRogueStoreData()
  if self.itemData.Type == UISimCombatRogueGlobal.ItemTypes.Gun then
    self.goodsType = UISimCombatRogueGlobal.StoreTypes.Gun
  elseif self.itemData.Type == UISimCombatRogueGlobal.ItemTypes.Buff then
    self.goodsType = UISimCombatRogueGlobal.StoreTypes.Buff
    local buffId = self.itemData.Args[0]
    self.rogueBuffCofigData = TableData.listRogueBuffCofigDatas:GetDataById(buffId)
  end
end
function SimCombatMythicStoreListContentItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  setactive(self.ui.mTrans_GrpTag.gameObject, false)
  setactive(self.ui.mImg_LockIcon.gameObject, false)
  setactive(self.ui.mTrans_GrpLimitBuy, false)
  setactive(self.ui.mTrans_LeftNum, true)
  if self.rogueStoreState == UISimCombatRogueGlobal.RogueStoreTabBtnTypes.Buy then
    if self.storeGoodData.GoodsType == UISimCombatRogueGlobal.StoreTypes.Gun then
      self:SetBuyRogueStoreGun()
    elseif self.storeGoodData.GoodsType == UISimCombatRogueGlobal.StoreTypes.Buff then
      self:SetBuyRogueStoreBuff()
    end
    self:SetBuyCostOrSellNum()
  else
    self.ui.mText_LeftNum.text = string_format(TableData.GetHintById(808), 1)
    self:SetSellRogueStore()
  end
end
function SimCombatMythicStoreListContentItem:SetBuyRogueStoreGun()
  if self.hasGun then
    setactive(self.ui.mTrans_GrpLock, true)
    self.ui.mText_LockText.HintID = 111043
    self.ui.mText_LockText.gameObject:GetComponent("Text").text = TableData.GetHintById(111043)
    self.ui.mText_LockTransText.text = ""
    self.ui.mText_LeftNum.text = string_format(TableData.GetHintById(808), 0)
  else
    if self.isLock then
      setactive(self.ui.mTrans_GrpLock, true)
      local rogueChapterCofig = NetCmdSimCombatRogueData:GetRogueChapterCofig(NetCmdSimCombatRogueData.RogueStage.RogueType, self.unLockList.Tier, self.unLockList.GroupNum)
      self.ui.mText_LockTransText.text = string_format(TableData.GetHintById(111044), rogueChapterCofig.Name)
    else
      self.ui.mBtn_Self.interactable = true
      setactive(self.ui.mTrans_GrpLock, false)
    end
    self.ui.mText_LeftNum.text = string_format(TableData.GetHintById(808), 1)
  end
  self:SetItemSprite(false)
  self:SetItemClick()
end
function SimCombatMythicStoreListContentItem:SetBuyRogueStoreBuff()
  setactive(self.ui.mTrans_GrpLock, false)
  self:SetItemSprite(true)
  setactive(self.ui.mTrans_GrpTag.gameObject, self.hasBuff and self.storeNum ~= 0)
  if self.hasBuff then
    self.ui.mText_Tag.text = TableData.GetHintById(111046)
  end
  if self.storeNum == 0 then
    setactive(self.ui.mTrans_GrpLock, true)
    self.ui.mText_LockText.HintID = 111045
    self.ui.mText_LockText.gameObject:GetComponent("Text").text = TableData.GetHintById(111045)
    self.ui.mText_LockTransText.text = ""
    self.ui.mText_LeftNum.text = string_format(TableData.GetHintById(808), 0)
    return
  elseif self.isLock then
    setactive(self.ui.mTrans_GrpLock, true)
    local rogueChapterCofig = NetCmdSimCombatRogueData:GetRogueChapterCofig(NetCmdSimCombatRogueData.RogueStage.RogueType, self.unLockList.Tier, self.unLockList.GroupNum)
    self.ui.mText_LockTransText.text = string_format(TableData.GetHintById(111044), rogueChapterCofig.Name)
  else
    self.ui.mBtn_Self.interactable = true
  end
  self.ui.mText_LeftNum.text = string_format(TableData.GetHintById(808), self.storeNum)
  self:SetItemClick()
end
function SimCombatMythicStoreListContentItem:SetBuyCostOrSellNum()
  local priceNum
  if self.storeGoodData.GoodsType == UISimCombatRogueGlobal.StoreTypes.Gun then
    priceNum = math.ceil(self.storeGoodData.Price)
  elseif self.storeGoodData.GoodsType == UISimCombatRogueGlobal.StoreTypes.Buff then
    local price = UISimCombatRogueGlobal.GetBuffCost(self.storeGoodData, self.rogueBuffCofigData)
    if price ~= nil then
      priceNum = math.ceil(price)
    else
      priceNum = 0
    end
  end
  self.ui.mText_CostNum.text = priceNum
  self.ui.mText_StoreName.text = self.storeGoodData.Name.str
  self.ui.mImg_BottomLine.color = TableData.GetGlobalGun_Quality_Color2(self.storeGoodData.Rank)
  self.ui.mImg_CostIcon.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. TableData.GetItemData(self.storeGoodData.PriceType).icon)
end
function SimCombatMythicStoreListContentItem:SetSellRogueStore()
  self.ui.mBtn_Self.interactable = true
  setactive(self.ui.mTrans_GrpCost, true)
  setactive(self.ui.mTrans_GrpLock, false)
  local costType, costNum
  for cost, num in pairs(self.rogueShopsellData.SellPrice) do
    costType = cost
    costNum = num
  end
  self.ui.mImg_CostIcon.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. TableData.GetItemData(costType).icon)
  self.ui.mText_CostNum.text = costNum
  if self.itemData.Type == UISimCombatRogueGlobal.ItemTypes.Gun then
    self.goodsType = UISimCombatRogueGlobal.StoreTypes.Gun
    self:SetItemSprite(false)
  elseif self.itemData.Type == UISimCombatRogueGlobal.ItemTypes.Buff then
    self.goodsType = UISimCombatRogueGlobal.StoreTypes.Buff
    local buffId = self.itemData.Args[0]
    self.rogueBuffCofigData = TableData.listRogueBuffCofigDatas:GetDataById(buffId)
    self:SetItemSprite(true)
  end
  self.ui.mText_StoreName.text = self.itemData.Name.str
  self.ui.mImg_BottomLine.color = TableData.GetGlobalGun_Quality_Color2(self.itemData.Rank)
  self:SetItemClick()
end
function SimCombatMythicStoreListContentItem:ChangeRogueStoreItemState(state)
  self.rogueStoreState = state
end
function SimCombatMythicStoreListContentItem:SetItemSprite(isBuff)
  setactive(self.ui.mTrans_BuffIcon, isBuff)
  setactive(self.ui.mImg_StoreIcon, not isBuff)
  if isBuff then
    self.ui.mImg_BuffIcon.sprite = IconUtils.GetRogueBuffIcon(self.rogueBuffCofigData.IconPath)
    self.ui.mImg_BuffQualityColor.color = TableData.GetGlobalGun_Quality_Color2(self.itemData.Rank)
  else
    self.ui.mImg_StoreIcon.sprite = IconUtils.GetItemIcon(self.itemData.Icon)
  end
end
function SimCombatMythicStoreListContentItem:SetItemClick()
  if self.canBuy then
    UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
      UIManager.OpenUIByParam(UIDef.UISimCombatMythicStoreBuyOrSellDialog, {
        rogueStoreState = self.rogueStoreState,
        rogueStoreItemState = self.goodsType,
        storeGoodData = self.storeGoodData,
        itemData = self.itemData,
        rogueBuffCofigData = self.rogueBuffCofigData,
        rogueShopsellData = self.rogueShopsellData,
        storeNum = self.storeNum,
        itemSprite = self.ui.mImg_StoreIcon.sprite,
        costIcon = self.ui.mImg_CostIcon.sprite,
        canLevelUpBuff = self.canLevelUpBuff,
        curRogueStoreType = self.curRogueStoreType
      })
    end
  else
    TipsManager.Add(self.ui.mBtn_Self.gameObject, self.itemData)
  end
end
function SimCombatMythicStoreListContentItem:SetActive(isActive)
  setactive(self.mUIRoot, isActive)
  self.isActive = isActive
end
function SimCombatMythicStoreListContentItem:OnRelease()
  gfdestroy(self.mUIRoot)
  self:DestroySelf()
end
