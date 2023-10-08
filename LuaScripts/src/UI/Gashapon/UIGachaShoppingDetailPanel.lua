require("UI.Gashapon.UIGachaInfoItem")
require("UI.Gashapon.UIGachaHistoryItem")
require("UI.Gashapon.Item.GashaponDialogLeftTabItemV2")
require("UI.Gashapon.UIGachaShoppingDetailPanelView")
require("UI.UIBasePanel")
require("UI.Gashapon.UIGachaMainPanelV2")
UIGachaShoppingDetailPanel = class("UIGachaShoppingDetailPanel", UIBasePanel)
UIGachaShoppingDetailPanel.__index = UIGachaShoppingDetailPanel
UIGachaShoppingDetailPanel.mView = nil
UIGachaShoppingDetailPanel.curTabId = nil
UIGachaShoppingDetailPanel.gachaData = nil
UIGachaShoppingDetailPanel.tabList = {}
UIGachaShoppingDetailPanel.infoItemList = {}
UIGachaShoppingDetailPanel.historyItemList = {}
UIGachaShoppingDetailPanel.detailItemList = {}
UIGachaShoppingDetailPanel.hintTable = {
  107013,
  107033,
  107014,
  107034,
  107066,
  107013
}
function UIGachaShoppingDetailPanel:ctor(csPanel)
  UIGachaShoppingDetailPanel.super:ctor(csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIGachaShoppingDetailPanel:OnInit(root, data)
  UIGachaShoppingDetailPanel.super.SetRoot(UIGachaShoppingDetailPanel, root)
  self.mView = UIGachaShoppingDetailPanelView.New()
  self.ui = {}
  self.mView:LuaUIBindTable(self.mUIRoot, self.ui)
  self.mView:InitCtrl(self.mUIRoot)
  UIUtils.GetButtonListener(self.ui.mBtn_BgClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIGachaShoppingDetailPanel)
  end
  self.ui.mBtn_Close.interactable = true
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIGachaShoppingDetailPanel)
  end
  self.curTabId = 0
  self:InitData(data)
  self:InitLeftTab()
  setactive(self.ui.mTrans_GrpDetails.gameObject, true)
  setactive(self.ui.mTrans_GrpInfo.gameObject, false)
  setactive(self.ui.mTrans_GrpRecord.gameObject, false)
  self:OnClickTab(self.tabList[1], 6)
end
function UIGachaShoppingDetailPanel:InitData(data)
  self.gachaData = TableDataBase.listGachaDatas:GetDataById(data.GachaID)
  self.typeData = TableDataBase.listGachaTypeListDatas:GetDataById(self.gachaData.type)
  self.rateTable = {}
  self.chrTable = {}
  self.weaponTable = {}
  self.upChrTable = {}
  self.upWeaponTable = {}
  if self.gachaData.gun_rate ~= "" then
    local rateList = string.split(self.gachaData.gun_rate, ",")
    for _, str in pairs(rateList) do
      local params = string.split(str, ":")
      table.insert(self.rateTable, {
        rank = tonumber(params[1]),
        rate = tonumber(params[2])
      })
    end
  end
  if self.gachaData.rate_des_gun ~= "" then
    local chrList = string.split(self.gachaData.rate_des_gun, ",")
    for _, str in pairs(chrList) do
      local params = string.split(str, ":")
      for k, v in pairs(params) do
        if k == 1 then
          self.chrTable[tonumber(v)] = {}
        else
          table.insert(self.chrTable[tonumber(params[1])], tonumber(v))
        end
      end
    end
  end
  if self.gachaData.rate_des_weapon ~= "" then
    local weaponList = string.split(self.gachaData.rate_des_weapon, ",")
    for _, str in pairs(weaponList) do
      local params = string.split(str, ":")
      for k, v in pairs(params) do
        if k == 1 then
          self.weaponTable[tonumber(v)] = {}
        else
          table.insert(self.weaponTable[tonumber(params[1])], tonumber(v))
        end
      end
    end
  end
  if self.gachaData.gun_up_rate ~= "" then
    local upChrList = string.split(self.gachaData.gun_up_rate, ",")
    for _, str in pairs(upChrList) do
      local params = string.split(str, ":")
      gfwarning("insert self.upChrTable rank: " .. tonumber(params[1]))
      self.upChrTable[tonumber(params[1])] = {
        rank = tonumber(params[1]),
        rate = tonumber(params[2]),
        items = {}
      }
    end
    local chrItemList = string.split(self.gachaData.gun_up_item, ",")
    for _, str in pairs(chrItemList) do
      local params = string.split(str, ":")
      local rank = tonumber(params[1])
      for k, v in pairs(params) do
        if k ~= 1 then
          table.insert(self.upChrTable[rank].items, tonumber(v))
        end
      end
    end
    self.upChrTable = self:SortUpTable(self.upChrTable)
  end
  if self.gachaData.weapon_up_rate ~= "" then
    local upWeaponList = string.split(self.gachaData.weapon_up_rate, ",")
    for _, str in pairs(upWeaponList) do
      local params = string.split(str, ":")
      self.upWeaponTable[tonumber(params[1])] = {
        rank = tonumber(params[1]),
        rate = tonumber(params[2]),
        items = {}
      }
    end
    local weaponItemList = string.split(self.gachaData.weapon_up_item, ",")
    for _, str in pairs(weaponItemList) do
      local params = string.split(str, ":")
      local rank = tonumber(params[1])
      for k, v in pairs(params) do
        if k ~= 1 then
          table.insert(self.upWeaponTable[rank].items, tonumber(v))
        end
      end
    end
    self.upWeaponTable = self:SortUpTable(self.upWeaponTable)
  end
  self:InitHistoryData()
end
function UIGachaShoppingDetailPanel:InitDetails(content)
  for i = 1, #self.detailItemList do
    gfdestroy(self.detailItemList[i])
  end
  self.detailItemList = {}
  if content ~= "" then
    local list = string.split(content, ",")
    for _, str in pairs(list) do
      local item = instantiate(self.ui.mScorllListChild_Detail.childItem, self.ui.mScorllListChild_Detail.transform)
      local txt = UIUtils.GetText(item.transform, "TextName")
      txt.text = TableData.GetHintById(tonumber(str))
      setactive(item, true)
      table.insert(self.detailItemList, item)
    end
  end
end
function UIGachaShoppingDetailPanel:InitHistoryData()
  self.gachaHistory = GashaponNetCmdHandler:GetGachaHistory()
  self:ClearInfoItem()
  local showBg = true
  for _, history in pairs(self.gachaHistory) do
    local item = UIGachaHistoryItem.New()
    item:InitCtrl(self.ui.mScorllListChild_History.transform)
    item:SetData(history)
    item:SetBG(showBg)
    showBg = not showBg
    table.insert(self.historyItemList, item)
  end
  setactive(self.ui.mTrans_GrpRecordInfo, self.gachaHistory.Count > 0)
  setactive(self.ui.mTrans_NoText, self.gachaHistory.Count == 0)
end
function UIGachaShoppingDetailPanel:SortUpTable(list)
  local retTable = {}
  for _, value in pairs(list) do
    table.insert(retTable, value)
  end
  list = {}
  table.sort(retTable, function(a, b)
    return a.rank > b.rank
  end)
  return retTable
end
function UIGachaShoppingDetailPanel:InitLeftTab()
  local list = string.split(self.typeData.sheet, ",")
  self.tabList = {}
  for _, v in pairs(list) do
    local id = tonumber(v)
    if id ~= 2 then
      do
        local item = GashaponDialogLeftTabItemV2.New()
        table.insert(self.tabList, item)
        item:InitCtrl(self.ui.mLeftTabList)
        item:SetData({
          name = TableData.GetHintById(self.hintTable[id])
        })
        local itemBtn = UIUtils.GetListener(item.mBtn_Self.gameObject)
        itemBtn.param = id
        itemBtn.paramData = item
        function itemBtn.onClick()
          self:OnClickTab(item, id)
        end
      end
    end
  end
end
function UIGachaShoppingDetailPanel:OnClickTab(gameObj, idValue)
  if self.curTabId and self.curTabId == idValue then
    return
  end
  self.curTabId = idValue
  self.ui.mText_topTitle.text = TableData.GetHintById(self.hintTable[idValue])
  setactive(self.ui.mTrans_GrpDetails, idValue == 1 or idValue == 5 or idValue == 6)
  setactive(self.ui.mTrans_GrpInfo, idValue == 2 or idValue == 3)
  setactive(self.ui.mTrans_GrpRecord, idValue == 4)
  if idValue == 3 then
    self:ClearInfoItem()
    for rank, rate in pairs(self.upChrTable) do
      local item = UIGachaInfoItem.New()
      item:InitCtrl(self.ui.mTrans_GachaContent)
      local data = {}
      data.gachaId = self.gachaData.id
      data.rank = rate.rank
      data.rate = rate.rate
      data.items = rate.items
      data.isChr = true
      item:SetData(UIGachaInfoItem.ItemInfoType.UpRate, data)
      table.insert(self.infoItemList, item)
    end
    for rank, rate in pairs(self.upWeaponTable) do
      local item = UIGachaInfoItem.New()
      item:InitCtrl(self.ui.mTrans_GachaContent)
      local data = {}
      data.gachaId = self.gachaData.id
      data.rank = rate.rank
      data.rate = rate.rate
      data.items = rate.items
      data.isChr = false
      item:SetData(UIGachaInfoItem.ItemInfoType.UpRate, data)
      table.insert(self.infoItemList, item)
    end
    local titleItem = UIGachaInfoItem.New()
    titleItem:InitCtrl(self.ui.mTrans_GachaContent)
    local titleData = {}
    titleData.str = "对象清单"
    titleItem:SetData(UIGachaInfoItem.ItemInfoType.Title, titleData)
    table.insert(self.infoItemList, titleItem)
    for _, rate in pairs(self.rateTable) do
      local item = UIGachaInfoItem.New()
      item:InitCtrl(self.ui.mTrans_GachaContent)
      local data = {}
      data.gachaId = self.gachaData.id
      data.rank = rate.rank
      data.rate = rate.rate
      data.chrTable = self.chrTable
      data.weaponTable = self.weaponTable
      item:SetData(UIGachaInfoItem.ItemInfoType.Rate, data)
      table.insert(self.infoItemList, item)
    end
  elseif idValue == 5 then
    for i = 1, #self.detailItemList do
      gfdestroy(self.detailItemList[i])
    end
    self.detailItemList = {}
    local item = instantiate(self.ui.mScorllListChild_Detail.childItem, self.ui.mScorllListChild_Detail.transform)
    local txt = UIUtils.GetText(item.transform, "TextName")
    txt.text = TableData.GetHintById(107069)
    setactive(item, true)
    table.insert(self.detailItemList, item)
  elseif idValue == 6 then
    for i = 1, #self.detailItemList do
      gfdestroy(self.detailItemList[i])
    end
    self.detailItemList = {}
    local item = instantiate(self.ui.mScorllListChild_Detail.childItem, self.ui.mScorllListChild_Detail.transform)
    local txt = UIUtils.GetText(item.transform, "TextName")
    txt.text = GashaponNetCmdHandler:GetGachaDetailText(self.gachaData.id)
    setactive(item, true)
    table.insert(self.detailItemList, item)
  end
  for i = 1, #self.tabList do
    self.tabList[i]:SetSelect(false)
    if UIUtils.GetListener(self.tabList[i].mBtn_Self.gameObject).param == self.curTabId then
      self.tabList[i]:SetSelect(true)
    end
  end
end
function UIGachaShoppingDetailPanel:ClearInfoItem()
  for i, v in pairs(self.infoItemList) do
    v:OnRelease(true)
  end
  self.infoItemList = {}
end
function UIGachaShoppingDetailPanel:ClearHistoryItem()
  for i, v in pairs(self.historyItemList) do
    v:OnRelease(true)
  end
  self.historyItemList = {}
end
function UIGachaShoppingDetailPanel:OnClose()
  self.mView = nil
  self.curTabId = nil
  for i = 1, #self.tabList do
    gfdestroy(self.tabList[i]:GetRoot())
  end
  self.tabList = {}
  for i = 1, #self.detailItemList do
    gfdestroy(self.detailItemList[i])
  end
  self.detailItemList = {}
  self:ClearHistoryItem()
  self:ClearInfoItem()
  self.gachaHistory = nil
end
