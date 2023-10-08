require("UI.DarkZonePanel.UIDarkZoneCraftPanel.Item.DZCraftItem")
require("UI.DarkZonePanel.UIDarkZoneCraftPanel.UIDarkZoneCraftPanelView")
require("UI.UIBasePanel")
UIDarkZoneCraftPanel = class("UIDarkZoneCraftPanel", UIBasePanel)
UIDarkZoneCraftPanel.__index = UIDarkZoneCraftPanel
function UIDarkZoneCraftPanel:ctor(csPanel)
  UIDarkZoneCraftPanel.super.ctor(UIDarkZoneCraftPanel, csPanel)
end
function UIDarkZoneCraftPanel:OnInit(root)
  UIDarkZoneCraftPanel.super.SetRoot(UIDarkZoneCraftPanel, root)
  self.ui = {}
  self.mView = UIDarkZoneCraftPanelView.New()
  self.mView:InitCtrl(root, self.ui)
  self:AddBtnListener()
  self:InitBaseData()
  self.ui.mText_TitleName.text = TableData.GetHintById(903292)
  function self.ui.mVirtualListEx_PartList.itemProvider()
    return self:ItemProvider()
  end
  function self.ui.mVirtualListEx_PartList.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
end
function UIDarkZoneCraftPanel:OnShowFinish()
  if self.needFresh == true then
    self:RefreshAllData()
    self.ui.mVirtualListEx_PartList:Refresh()
    self.ui.mVirtualListEx_PartList.numItems = #self.ItemListData
    if self.currentItemData then
      self:ChangeMakeNum(0)
    end
    self.needFresh = false
  end
end
function UIDarkZoneCraftPanel:CloseFunction()
  UIManager.CloseUI(UIDef.UIDarkZoneCraftPanel)
end
function UIDarkZoneCraftPanel:OnClose()
  self.ui.mVirtualListEx_PartList.itemProvider = nil
  self.ui.mVirtualListEx_PartList.itemRenderer = nil
  self.ui = nil
  self.mView = nil
  self.currentMakeNum = nil
  self.canMakeMaxNum = nil
  self.currentItemData = nil
  self.ItemListData = nil
  self.costItemIsEnough = nil
  self.currentClickLeftTabItem = nil
  self.needFresh = nil
  for i = 1, #self.costItemList do
    self.costItemList[i]:OnRelease()
  end
  self.costItemList = nil
end
function UIDarkZoneCraftPanel:OnRelease()
  self.super.OnRelease(self)
  self.hasCache = false
end
function UIDarkZoneCraftPanel:ItemProvider()
  local itemView = DZCraftItem.New()
  itemView:InitCtrl(self.ui.mTrans_Content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIDarkZoneCraftPanel:ItemRenderer(index, renderData)
  local data = self.ItemListData[index + 1]
  local func = function(data, clickItem)
    self:ChangeCurrentData(data, clickItem)
  end
  local item = renderData.data
  item:SetData(data, func)
  if index == 0 then
    item:ClickFunction()
  end
end
function UIDarkZoneCraftPanel:InitBaseData()
  self.currentMakeNum = 0
  self.canMakeMaxNum = 0
  self.currentItemData = nil
  self.costItemList = {}
  self.configData = TableData.GlobalDarkzoneData.DarkzoneProductLimit or 10
  self.ItemListData = {}
  local list = TableData.listDevelopProductDatas:GetList()
  for i = 0, list.Count - 1 do
    local data = self:CheckItemCanProduct(list[i])
    table.insert(self.ItemListData, data)
  end
  table.sort(self.ItemListData, function(a, b)
    if a.mIsUnLock == true and b.mIsUnLock == true then
      if a.canMakeMaxNum > 0 and b.canMakeMaxNum > 0 then
        return a.itemData.id < b.itemData.id
      end
      return a.canMakeMaxNum > 0
    end
    return a.mIsUnLock == true
  end)
  local needShowRedDot = false
  local list2 = TableData.listItemByTypeDatas:GetDataById(GlobalConfig.ItemType.WeaponPart).Id
  for i = 0, list2.Count - 1 do
    local d = TableData.listWeaponModDatas:GetDataById(list2[i])
    if d.isShowNew == true then
      needShowRedDot = true
      break
    end
  end
  setactive(self.ui.mTrans_RedPoint, needShowRedDot)
  self.needFresh = true
end
function UIDarkZoneCraftPanel:AddBtnListener()
  if self.hasCache ~= true then
    self.ui.mBtn_Back.onClick:AddListener(function()
      self:CloseFunction()
    end)
    self.ui.mBtn_Reduce.onClick:AddListener(function()
      self:ChangeMakeNum(-1)
    end)
    self.ui.mBtn_Increase.onClick:AddListener(function()
      self:ChangeMakeNum(1)
    end)
    self.ui.mBtn_BlueprintPreview.onClick:AddListener(function()
      UIManager.OpenUI(UIDef.UIDarkZoneCraftDialog)
    end)
    self.ui.mBtn_Repository.onClick:AddListener(function()
      SceneSwitch:SwitchByID(8005)
    end)
    self.ui.mBtn_Material.onClick:AddListener(function()
      SceneSwitch:SwitchByID(10002)
    end)
    self.ui.mBtn_Make.onClick:AddListener(function()
      if self.costItemIsEnough == false then
        PopupMessageManager.PopupString(TableData.GetHintById(903293))
        return
      end
      if self.currentMakeNum > self.canMakeMaxNum then
        PopupMessageManager.PopupString(TableData.GetHintById(903314))
      else
        for itemID, v in pairs(self.currentItemData.itemData.darkzone_productmod) do
          if TipsManager.CheckItemIsOverflowAndStop(itemID, self.currentMakeNum) then
            return
          end
        end
        local hint = string_format(TableData.GetHintById(903319), self.currentItemData.itemData.plan_name.str, self.currentMakeNum)
        MessageBoxPanel.ShowDoubleType(hint, function()
          DarkNetCmdCraftData:SendProductModMsg(self.currentItemData.itemData.id, self.currentMakeNum, function()
            UIManager.OpenUI(UIDef.UIDarkZoneCraftMakeDialog)
            self.needFresh = true
          end)
        end)
      end
    end)
    self.hasCache = true
  end
end
function UIDarkZoneCraftPanel:ChangeMakeNum(num)
  local currentNum = self.currentMakeNum
  currentNum = currentNum + num
  self.currentMakeNum = currentNum
  self.ui.mBtn_Reduce.interactable = self.currentMakeNum > 1
  self.ui.mBtn_Increase.interactable = self.currentMakeNum < self.canMakeMaxNum
  self.ui.mText_Num.text = tostring(self.currentMakeNum)
  local totalPrice = self.currentMakeNum * self.currentItemData.price
  self.ui.mText_CostNum.text = tostring(totalPrice)
  local CurrencyNum = NetCmdItemData:GetResItemCount(self.currentItemData.costItemId)
  self.costItemIsEnough = totalPrice < CurrencyNum
  if self.costItemIsEnough == false then
    self.ui.mText_CostNum.color = ColorUtils.RedColor
  else
    self.ui.mText_CostNum.color = CS.GF2.UI.UITool.StringToColor("EFEFEF")
  end
  for i = 1, #self.costItemList do
    local item = self.costItemList[i]
    local d = self.currentCostItemList[i]
    if item.mUIRoot.gameObject.activeSelf == true then
      item:FreshItemCount(d.price * self.currentMakeNum)
    end
  end
end
function UIDarkZoneCraftPanel:ChangeCurrentData(data, clickItem)
  if self.currentClickLeftTabItem then
    self.currentClickLeftTabItem.ui.mBtn_Self.interactable = true
  end
  self.currentClickLeftTabItem = clickItem
  self.currentClickLeftTabItem.ui.mBtn_Self.interactable = false
  self.ui.mAnimator_Root:SetTrigger("Cut")
  self.currentItemData = data
  self.ui.mText_ItemName.text = data.itemData.plan_name.str
  self.ui.mText_Details.text = data.itemData.plan_desc.str
  self.canMakeMaxNum = math.min(data.canMakeMaxNum, self.configData)
  self.currentMakeNum = 1
  if self.canMakeMaxNum > 0 then
    self.currentMakeNum = 1
  end
  self:ChangeMakeNum(0)
  for i = 1, #self.costItemList do
    self.costItemList[i]:SetActive(false)
  end
  local index = 1
  self.currentCostItemList = {}
  for itemID, needNum in pairs(self.currentItemData.itemData.darkzone_productcost1) do
    if self.costItemList[index] == nil then
      self.costItemList[index] = UICommonItem.New()
      self.costItemList[index]:InitCtrl(self.ui.mTrans_ItemList)
    end
    local d = {}
    d.itemID = itemID
    d.price = needNum
    table.insert(self.currentCostItemList, d)
    self.costItemList[index]:SetActive(true)
    self.costItemList[index]:SetItemData(itemID, needNum * self.currentMakeNum, true, true)
    index = index + 1
  end
  self.ui.mImg_CostItem.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. TableData.listItemDatas:GetDataById(self.currentItemData.costItemId).icon)
end
function UIDarkZoneCraftPanel:CheckItemCanProduct(itemData)
  local data = {}
  data.itemData = itemData
  self:CheckItemData(data)
  return data
end
function UIDarkZoneCraftPanel:CheckItemData(data)
  local itemData = data.itemData
  local maxNum
  local costList = {}
  for itemID, needNum in pairs(itemData.darkzone_productcost1) do
    local data1 = {}
    data1.itemID = itemID
    data1.needNum = needNum
    table.insert(costList, data1)
  end
  for itemID, needNum in pairs(itemData.darkzone_productcost2) do
    local data1 = {}
    data1.itemID = itemID
    data1.needNum = needNum
    table.insert(costList, data1)
    if data.price == nil then
      data.price = needNum
      data.costItemId = itemID
    end
  end
  for i = 1, #costList do
    local itemID = costList[i].itemID
    local needNum = costList[i].needNum
    local itemNum = NetCmdItemData:GetItemCountById(itemID)
    local result = math.floor(itemNum / needNum)
    if maxNum then
      maxNum = math.min(maxNum, result)
    else
      maxNum = result
    end
  end
  data.canMakeMaxNum = maxNum
  local isUnlock = true
  for i = 0, itemData.condition.Count - 1 do
    local unlock = itemData.condition[i]
    if NetCmdAchieveData:CheckComplete(unlock) == false then
      isUnlock = false
      break
    end
  end
  data.mIsUnLock = isUnlock
end
function UIDarkZoneCraftPanel:RefreshAllData()
  for i = 1, #self.ItemListData do
    local data = self.ItemListData[i]
    self:CheckItemData(data)
  end
end
