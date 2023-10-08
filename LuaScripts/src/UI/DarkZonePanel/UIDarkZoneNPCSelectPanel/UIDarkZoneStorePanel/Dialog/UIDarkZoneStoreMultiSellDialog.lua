require("UI.DarkZonePanel.UIDarkZoneNPCSelectPanel.UIDarkZoneStorePanel.Dialog.UIDarkZoneStoreMultiSellDialogView")
require("UI.UIBasePanel")
UIDarkZoneStoreMultiSellDialog = class("UIDarkZoneStoreMultiSellDialog", UIBasePanel)
UIDarkZoneStoreMultiSellDialog.__index = UIDarkZoneStoreMultiSellDialog
function UIDarkZoneStoreMultiSellDialog:ctor(csPanel)
  UIDarkZoneStoreMultiSellDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneStoreMultiSellDialog:OnInit(root, data)
  UIDarkZoneStoreMultiSellDialog.super.SetRoot(UIDarkZoneStoreMultiSellDialog, root)
  self:InitBaseData()
  self.mData = data[1]
  self.storePanel = data[2]
  self.mview:InitCtrl(root, self.ui)
  self:AddBtnListen()
  self.storePanel.NotSell = true
end
function UIDarkZoneStoreMultiSellDialog:OnShowFinish()
  self.IsPanelOpen = true
  self:InitInfoData()
end
function UIDarkZoneStoreMultiSellDialog:OnHide()
  self.IsPanelOpen = false
end
function UIDarkZoneStoreMultiSellDialog:OnHideFinish()
  self.storePanel:SetItemListClick(true)
end
function UIDarkZoneStoreMultiSellDialog:CloseFunction(skip)
  UIManager.CloseUI(UIDef.UIDarkZoneStoreMultiSellDialog)
  if self.ClickConfirm then
    for k, v in pairs(self.storePanel.SellItemScriptList) do
      v:Release()
    end
    self.storePanel.ChoseSellItemIdList = {}
    self.storePanel.MultiSellList = {}
    self.storePanel.IsSetBack = true
    self.storePanel.ClickMultiSell = false
    setactive(self.storePanel.ui.mTrans_GrpBulkSale, false)
    setactive(self.storePanel.ui.mTrans_GrpDetailsLeft, false)
    self.storePanel:SetStateBack()
  end
  self.storePanel.isSell = skip
end
function UIDarkZoneStoreMultiSellDialog:OnClose()
  self.ui = nil
  self.mview = nil
  self.AddExpNum = nil
  self.SellList = nil
  self.IsShowLevelUpDialog = nil
  self.ClickConfirm = nil
  self.mData = nil
  self:ReleaseCtrlTable(self.comItemList, true)
  self.comItemList = nil
  self.storePanel.NotSell = false
end
function UIDarkZoneStoreMultiSellDialog:InitBaseData()
  self.mview = UIDarkZoneStoreMultiSellDialogView.New()
  self.ui = {}
  self.IsPanelOpen = false
  self.AddExpNum = 0
  self.SellList = {}
  self.topBar = {}
  self.IsShowLevelUpDialog = false
  self.ClickConfirm = false
  self.comItemList = {}
end
function UIDarkZoneStoreMultiSellDialog:InitInfoData()
  local TotalPrice = 0
  local TotalAddFavor = 0
  DarkNetCmdStoreData.Sellentities:Clear()
  DarkNetCmdStoreData.SellOthers:Clear()
  for k, v in pairs(self.mData) do
    local StcData = v.mData
    local ItemNum = v.ItemNum
    local SellPrice = v.SellPrice
    local item = UICommonItem.New()
    item:InitCtrl(self.ui.mTrans_Content)
    item:SetItemByStcData(StcData.ItemData, ItemNum)
    item.ui.mBtn_Select.interactable = false
    table.insert(self.comItemList, item)
    local AddRatio = 1000
    local NpcData = TableData.listDarkzoneNpcDatas:GetDataById(self.storePanel.Npc)
    for k, v in pairs(NpcData.favor_item) do
      if k == StcData.DarkZoneItemData.item_kind then
        AddRatio = v
        break
      end
    end
    local ration = AddRatio / 1000
    local BaseFavor = StcData.DarkZoneItemData.DarkzoneImpression * ration
    BaseFavor = math.ceil(BaseFavor)
    TotalPrice = TotalPrice + ItemNum * SellPrice
    TotalAddFavor = TotalAddFavor + BaseFavor * ItemNum
    if StcData.IsItem == false then
      DarkNetCmdStoreData.Sellentities:Add(StcData.Id)
    else
      local ProItem = CS.ProtoObject.Item()
      ProItem.Id = StcData.ItemId
      ProItem.Num = ItemNum
      DarkNetCmdStoreData.SellOthers:Add(ProItem)
    end
  end
  self.NowFavorLevel = self.storePanel.FavorLevel
  self.NowFavorExp = self.storePanel.FavorExp
  local FavorLevel, FavorExp, NextFavor = DZStoreUtils:GetCurFavorLevelAndExp(self.storePanel.Npc, self.storePanel.NpcFavor + TotalAddFavor)
  self.ui.mText_Level.text = DZStoreUtils:SetIndex(FavorLevel)
  self.NextFavorLevel = FavorLevel
  self.ui.mText_ExpNum.text = FavorExp .. "/" .. NextFavor
  self.ui.mText_AddExpNum.text = "+" .. TotalAddFavor
  if self.NowFavorLevel ~= FavorLevel then
    setactive(self.ui.mSlider_Now.gameObject, false)
    self.ui.mSlider_Add.fillAmount = FavorExp / NextFavor
    self.IsShowLevelUpDialog = true
  else
    self.ui.mSlider_Now.fillAmount = self.NowFavorExp / NextFavor
    self.ui.mSlider_Add.fillAmount = FavorExp / NextFavor
  end
  if self.NowFavorLevel == TableDataBase.GlobalDarkzoneData.DarkzoneNpcMaxFavorLevel then
    self.ui.mText_AddExpNum.text = "+" .. 0
  elseif FavorLevel == TableDataBase.GlobalDarkzoneData.DarkzoneNpcMaxFavorLevel then
    self.ui.mText_AddExpNum.text = "+" .. FavorExp - self.storePanel.NpcFavor
  end
  self.ui.mText_GetNum.text = TotalPrice
  self.TotalPrice = TotalPrice
  local DZCoinStr = TableData.listItemDatas:GetDataById(18).icon
  self.ui.mImg_CoinIcon.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. DZCoinStr)
end
function UIDarkZoneStoreMultiSellDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    self:OnClickConfirm()
  end
end
function UIDarkZoneStoreMultiSellDialog:OnClickConfirm()
  DarkNetCmdStoreData:SellItem(self.storePanel.Npc, function()
    DarkNetCmdStoreData:ReqMessage(function()
      for k, v in pairs(self.mData) do
        v.mData.ItemCount = v.mData.ItemCount - v.ItemNum
        if v.mData.ItemCount <= 0 then
          DarkNetCmdStoreData:RemoveStorageItem(v.mData.mIndex)
        end
      end
      DarkNetCmdStoreData:SendCS_DarkZoneStorage()
      self.ClickConfirm = true
      self:CloseFunction(true)
      if self.IsShowLevelUpDialog then
        local data = {}
        data.From = self.NowFavorLevel
        data.To = self.NextFavorLevel
        UIManager.OpenUIByParam(UIDef.UIDarkZoneFavorUpDownDialog, data)
      else
        UIManager.OpenUI(UIDef.UICommonReceivePanel)
      end
    end)
  end)
end
