require("UI.SimCombatPanel.Item.Rogue.SimCombatMythicStoreTabContentItem")
require("UI.SimCombatPanel.UISimCombatRogueGlobal")
require("UI.UIBasePanel")
UISimCombatMythicStoreDialog = class("UISimCombatMythicStoreDialog", UIBasePanel)
UISimCombatMythicStoreDialog.__index = UISimCombatMythicStoreDialog
local self = UISimCombatMythicStoreDialog
function UISimCombatMythicStoreDialog:ctor(obj)
  UISimCombatMythicStoreDialog.super.ctor(self)
  obj.Type = UIBasePanelType.Dialog
end
function UISimCombatMythicStoreDialog:OnInit(root)
  self.super.SetRoot(UISimCombatMythicStoreDialog, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.curTabContentItem = nil
  self.curTabBtnItem = nil
  self.curRogueStoreType = nil
  self.curRogueStoreTabBtnTypes = UISimCombatRogueGlobal.RogueStoreTabBtnTypes.Buy
  self.storeListContent = {}
  self.storeGoodsNum = 0
  self.rogueShopPlanData = nil
  self.tmpItemList = {}
  self.tmpRogueSellList = {}
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UISimCombatMythicStoreDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BgClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UISimCombatMythicStoreDialog)
  end
  self:SetTabContent()
  self:SetTabBtn()
end
function UISimCombatMythicStoreDialog:OnHide()
  self.isHide = true
end
function UISimCombatMythicStoreDialog:OnClose()
  self:ReleaseCtrlTable(self.storeListContent)
end
function UISimCombatMythicStoreDialog:SetTabContent()
  local rogueShopTypeDataList = TableData.listRogueShopTypeDescDatas:GetList()
  for i = 0, rogueShopTypeDataList.Count - 1 do
    local item = SimCombatMythicStoreTabContentItem.New()
    item:InitCtrl(self.ui.mScrollListChild_TabContent)
    item:SetData(rogueShopTypeDataList[i])
    UIUtils.GetButtonListener(item.ui.mBtn_Self.gameObject).onClick = function()
      self:OnClickTabItem(item)
    end
    if i == 0 then
      self:OnClickTabItem(item)
    end
  end
end
function UISimCombatMythicStoreDialog:SetTabBtn()
  for i, v in ipairs(UISimCombatRogueGlobal.RogueStoreTabBtns) do
    local item = SimCombatMythicStoreTabBtnItem.New()
    item:InitCtrl(self.ui.mScrollListChild_TabBtn)
    item:SetData(v)
    UIUtils.GetButtonListener(item.ui.mBtn_ComTab1ItemV2.gameObject).onClick = function()
      self:OnclickTabBtn(item)
    end
    if i == 1 then
      self:OnclickTabBtn(item)
    end
  end
end
function UISimCombatMythicStoreDialog:InitRogueStoreList()
  local tmpShopList = {}
  local index = 0
  local count = 0
  if self.curRogueStoreTabBtnTypes == UISimCombatRogueGlobal.RogueStoreTabBtnTypes.Buy then
    tmpShopList = self.rogueShopPlanData.RogueShopGoodIdList
    index = 0
    count = tmpShopList.Count - 1
  else
    tmpShopList = self.tmpItemList
    index = 1
    count = #self.tmpItemList
  end
  for _, v in ipairs(self.storeListContent) do
    v:OnRelease()
  end
  self.storeListContent = {}
  for i = index, count do
    local item = SimCombatMythicStoreListContentItem.New()
    table.insert(self.storeListContent, item)
    if self.curRogueStoreTabBtnTypes == UISimCombatRogueGlobal.RogueStoreTabBtnTypes.Buy then
      item:SetData(self.curRogueStoreType, tmpShopList[i], self.curRogueStoreTabBtnTypes)
    else
      item:SetData(self.curRogueStoreType, tmpShopList[i], self.curRogueStoreTabBtnTypes, self.tmpRogueSellList[i])
    end
  end
  self:SortRogueStoreList()
  for i = 1, #self.storeListContent do
    self.storeListContent[i]:InitCtrl(self.ui.mScrollListChild_ListContent)
  end
end
function UISimCombatMythicStoreDialog:SortRogueStoreList()
  table.sort(self.storeListContent, function(a, b)
    if a.canBuy ~= b.canBuy then
      return a.canBuy
    elseif self.curRogueStoreTabBtnTypes == UISimCombatRogueGlobal.RogueStoreTabBtnTypes.Buy then
      return a.storeGoodData.Sort < b.storeGoodData.Sort
    else
      return a.rogueShopsellData.Sort < b.rogueShopsellData.Sort
    end
  end)
end
function UISimCombatMythicStoreDialog:OnClickTabItem(item)
  if self.curTabContentItem == item then
    return
  end
  if self.curTabContentItem ~= nil then
    self.curTabContentItem.ui.mBtn_Self.interactable = true
  end
  item.ui.mBtn_Self.interactable = false
  self.curTabContentItem = item
  self.curRogueStoreType = item.rogueShopTypeDescData.id
  self.RefreshRogueTab()
end
function UISimCombatMythicStoreDialog:OnclickTabBtn(item)
  if self.curTabBtnItem == item then
    return
  end
  if self.curTabBtnItem ~= nil then
    self.curTabBtnItem.ui.mBtn_ComTab1ItemV2.interactable = true
  end
  item.ui.mBtn_ComTab1ItemV2.interactable = false
  self.curTabBtnItem = item
  self.curRogueStoreTabBtnTypes = item.rogueStoreTabBtnType
  self.RefreshRogueTab()
end
function UISimCombatMythicStoreDialog.RefreshRogueTab()
  if self.curRogueStoreTabBtnTypes == UISimCombatRogueGlobal.RogueStoreTabBtnTypes.Buy then
    if self.curRogueStoreType == UISimCombatRogueGlobal.RogueStoreTypes.Gun then
      self.rogueShopPlanData = NetCmdSimCombatRogueData.GunShopPlanData
    elseif self.curRogueStoreType == UISimCombatRogueGlobal.RogueStoreTypes.Buff then
      self.rogueShopPlanData = NetCmdSimCombatRogueData.BuffShopPlanData
    end
    self.storeGoodsNum = self.rogueShopPlanData.RogueShopGoodIdList.Count
  else
    self.tmpItemList = {}
    self.tmpRogueSellList = {}
    local checkHasItem = function(item)
      local checkId = item.Args[0]
      local checkResult
      if item.Type == UISimCombatRogueGlobal.ItemTypes.Gun and self.curRogueStoreType == UISimCombatRogueGlobal.RogueStoreTypes.Gun then
        checkResult = NetCmdSimCombatRogueData.RogueStage:CheckHasPreGun(checkId)
      elseif item.Type == UISimCombatRogueGlobal.ItemTypes.Buff and self.curRogueStoreType == UISimCombatRogueGlobal.RogueStoreTypes.Buff then
        checkResult = NetCmdSimCombatRogueData.RogueStage:CheckHasBuff(checkId)
      end
      if checkResult then
        table.insert(self.tmpItemList, item)
      end
      return checkResult
    end
    local shopSellList = TableData.listRogueLevelCofigDatas:GetDataById(NetCmdSimCombatRogueData.RogueStage.Tier).CheckFloorToShopsellList
    for i = 0, shopSellList.Count - 1 do
      local shopSellId = shopSellList[i]
      local rogueShopSellCofigData = TableData.listRogueShopSellCofigDatas:GetDataById(shopSellId)
      local rogueItemData = TableData.listItemDatas:GetDataById(rogueShopSellCofigData.SellGoods)
      if checkHasItem(rogueItemData) then
        table.insert(self.tmpRogueSellList, rogueShopSellCofigData)
      end
    end
    self.storeGoodsNum = #self.tmpItemList
  end
  self:InitRogueStoreList()
  setactive(self.ui.mTrans_Empty.gameObject, #self.storeListContent == 0)
end
