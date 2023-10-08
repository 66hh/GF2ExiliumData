require("UI.Common.UICommonSimpleView")
require("UI.DarkZonePanel.UIDarkZoneWishPanel.Item.UIDarkZoneWishTabItem")
require("UI.DarkZonePanel.UIDarkZoneWishPanel.Item.UIDarkZoneWishItem")
require("UI.UIBasePanel")
UIDarkZoneWishDialog = class("UIDarkZoneWishDialog", UIBasePanel)
UIDarkZoneWishDialog.__index = UIDarkZoneWishDialog
function UIDarkZoneWishDialog:ctor(csPanel)
  UIDarkZoneWishDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneWishDialog:OnInit(root, data)
  self:SetRoot(root)
  self.endlessData = TableData.listDarkzoneSystemEndlessDatas:GetDataById(data[0])
  if data[3] == true then
    self.limitTime = CGameTime:GetTimestamp() + self.endlessData.limit_time
  end
  self.needWish = data[2]
  self.isRaid = data[1]
  self.isInDarkZone = data[4]
  self.rewardId = data[6]
  self.endLessRewardData = TableData.listDarkzoneSystemEndlessRewardDatas:GetDataById(self.rewardId)
  if data[5] then
    self.selectItemList = data[5]
  end
  self:InitBaseData()
  self.mview:InitCtrl(root, self.ui)
  self:AddBtnListen()
  for i = 1, self.maxItemTypeCount do
    self.tabItemList[i] = UIDarkZoneWishTabItem.New()
    local item = self.tabItemList[i]
    item:InitCtrl(self.ui["mTrans_WishItem" .. i])
    local itemData
    if self.selectItemList and self.selectItemList[i] and 0 < self.selectItemList[i] then
      itemData = TableData.listDarkzoneWishDatas:GetDataById(self.selectItemList[i])
    end
    item:SetData(itemData)
    item:SetEndlessID(self.endlessData.id)
    item:SetIndexID(i)
    item:SetLimitTime(self.limitTime)
    item:SetCanWish(self.needWish)
    item:SetWishItemCallBack(function(itemData)
      self:SetWishItem(item.index, itemData)
    end)
    item:SetOnWishItemClickCallBack(function()
      self.showRedDotList[i] = false
    end)
    item.ui.mBtn_Item.interactable = self.needWish == true
  end
  function self.ui.mVirtualListEx_List.itemProvider()
    return self:ItemProvider()
  end
  function self.ui.mVirtualListEx_List.itemRenderer(index, itemData)
    self:ItemRenderer(index, itemData)
  end
  local t = self.ui.mBtn_Confirm.transform:Find("Root/GrpText/Text_Name")
  local btnText, textComponent
  if t then
    textComponent = t:GetComponent(typeof(CS.UnityEngine.UI.Text))
    btnText = t.gameObject
    textComponent.text = TableData.GetHintById(240096)
  end
  if btnText and self.limitTime then
    self.timeCount = btnText:GetComponent(typeof(CS.UICountdown))
    if self.timeCount == nil then
      self.timeCount = btnText:AddComponent(typeof(CS.UICountdown))
    end
    self.timeCount:SetHitID(240080)
    self.timeCount:SetShowType(1)
    self.timeCount:StartCountdown(self.limitTime)
    self.timeCount:AddFinishCallback(function(suc)
      if self.isRaid == true then
        self:StartEndLessMode(suc)
      else
        self:SendEndLessData()
      end
    end)
  end
  if self.limitTime then
    self.timeCount.enabled = self.limitTime ~= nil
  end
  if textComponent and self.needWish == false then
    textComponent.text = TableData.GetHintById(240082)
  end
end
function UIDarkZoneWishDialog:OnShowStart()
  self:UpdateData()
  self:RefreshTabItem()
  setactive(self.ui.mBtn_Home, self.isInDarkZone ~= true)
  setactive(self.ui.mBtn_Back, self.limitTime == nil)
end
function UIDarkZoneWishDialog:OnTop()
  self:RefreshTabItem()
end
function UIDarkZoneWishDialog:OnBackForm()
  self:RefreshTabItem()
end
function UIDarkZoneWishDialog:CloseFunction()
  local closeFunc = function()
    if self.isOpenMessageBox == true then
      MessageBox.Close()
      self.isOpenMessageBox = false
    end
    UIManager.CloseUISelf(self)
  end
  if self.needWish == false or self.isRaid then
    closeFunc()
  else
    PopupMessageManager.PopupString(TableData.GetHintById(240081))
    self:DelayCall(0.5, function()
      closeFunc()
    end)
  end
end
function UIDarkZoneWishDialog:OnClose()
  self:ReleaseTimers()
  if self.timeCount then
    self.timeCount:CleanFinishCallback()
    self.timeCount = nil
  end
  self.ui.mVirtualListEx_List.numItems = 0
  self.ui = nil
  self.mview = nil
  self.tabItemList = nil
  self.limitTime = nil
  self.showDataList = nil
  self.selectItemList = nil
  self.isOpenMessageBox = nil
  self.showRedDotList = nil
end
function UIDarkZoneWishDialog:OnRelease()
  self.super.OnRelease(self)
end
function UIDarkZoneWishDialog:InitBaseData()
  self.mview = UICommonSimpleView.New()
  self.ui = {}
  self.tabItemList = {}
  self.showDataList = self.endLessRewardData.drop_type
  self.showRedDotList = {
    false,
    false,
    false,
    false
  }
  self.maxItemTypeCount = 4
  if self.needWish == true then
    local list = TableData.listDarkzoneWishDatas:GetList()
    for i = 0, list.Count - 1 do
      local d = list[i]
      local itemNum = DarkZoneNetRepositoryData:GetItemNum(d.id)
      if 0 < itemNum then
        self.showRedDotList[d.type] = true
      end
    end
  end
end
function UIDarkZoneWishDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    local t = {}
    t.dataList = {}
    t.endlessId = self.endlessData.id
    t.limitTime = self.limitTime
    t.needWish = self.needWish
    for i, v in ipairs(self.tabItemList) do
      if v.mData then
        table.insert(t.dataList, v.mData.id)
      end
    end
    if self.needWish then
      if self.isRaid then
        function t.callback()
          self:StartEndLessMode()
        end
      else
        function t.callback()
          self:SendEndLessData()
        end
      end
      if #t.dataList > 0 then
        UIManager.OpenUIByParam(UIDef.UIDarkZoneWishDescribeDialog, t)
      else
        self.isOpenMessageBox = true
        MessageBox.Show(TableData.GetHintById(208), TableData.GetHintById(240111), nil, t.callback, function()
          self.isOpenMessageBox = false
        end)
      end
    else
      UIManager.OpenUIByParam(UIDef.UIDarkZoneWishDescribeDialog, t)
    end
  end
end
function UIDarkZoneWishDialog:UpdateData()
  self.ui.mVirtualListEx_List.numItems = self.showDataList.Count
  self.ui.mVirtualListEx_List:Refresh()
end
function UIDarkZoneWishDialog:RefreshTabItem()
  for i, v in ipairs(self.tabItemList) do
    v:SetRedDot(self.showRedDotList[i])
  end
end
function UIDarkZoneWishDialog:ItemProvider()
  local itemView = UIDarkZoneWishItem.New()
  itemView:InitCtrl(self.ui.mVirtualListEx_List.content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIDarkZoneWishDialog:ItemRenderer(index, itemData)
  local data = self.showDataList[index]
  local item = itemData.data
  item:SetData(data)
  for i, v in pairs(self.tabItemList) do
    if v.mData then
      item:SetTypeHighLight(v.mData)
    end
  end
end
function UIDarkZoneWishDialog:SetWishItem(index, itemData)
  local item = self.tabItemList[index]
  if item then
    item:SetData(itemData)
  end
  local itemID = 0
  if itemData then
    itemID = itemData.id
  end
  DarkNetCmdStoreData:SetWishItemList(index - 1, itemID)
  self.ui.mVirtualListEx_List:Refresh()
end
function UIDarkZoneWishDialog:StartEndLessMode(suc)
  local param = {
    OnDuringEndCallback = function()
      UIManager.CloseUI(UIDef.UIDarkZoneWishDialog)
      UIManager.OpenUI(UIDef.UICommonReceivePanel)
    end
  }
  local list = CS.LuaUtils.CreateArrayInstance(typeof(CS.System.UInt32), 4)
  for i, v in pairs(self.tabItemList) do
    local itemID = 0
    if v.mData then
      itemID = v.mData.id
    end
    list[i - 1] = itemID
  end
  DarkNetCmdStoreData:SendCS_DarkZoneEndLessRaid(self.endlessData.id, self.rewardId, list, function()
    UIManager.OpenUIByParam(UIDef.UIRaidDuringPanel, param)
    for i, v in pairs(self.tabItemList) do
      v:SetData(nil)
    end
  end)
end
function UIDarkZoneWishDialog:SendEndLessData()
  local list = CS.LuaUtils.CreateArrayInstance(typeof(CS.System.UInt32), 4)
  for i, v in pairs(self.tabItemList) do
    local itemID = 0
    if v.mData then
      itemID = v.mData.id
    end
    list[i - 1] = itemID
  end
  DarkNetCmdStoreData:SendCS_DarkZoneEndLessWish(self.endlessData.map, list, function()
    self:CloseFunction()
  end)
end
