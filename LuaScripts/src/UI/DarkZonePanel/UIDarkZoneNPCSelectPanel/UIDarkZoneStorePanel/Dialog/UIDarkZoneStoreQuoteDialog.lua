require("UI.DarkZonePanel.UIDarkZoneNPCSelectPanel.UIDarkZoneStorePanel.Item.DZQuoteItem")
require("UI.DarkZonePanel.UIDarkZoneNPCSelectPanel.UIDarkZoneStorePanel.Dialog.UIDarkZoneStoreQuoteDialogView")
require("UI.UIBasePanel")
UIDarkZoneStoreQuoteDialog = class("UIDarkZoneStoreQuoteDialog", UIBasePanel)
UIDarkZoneStoreQuoteDialog.__index = UIDarkZoneStoreQuoteDialog
function UIDarkZoneStoreQuoteDialog:ctor(csPanel)
  UIDarkZoneStoreQuoteDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneStoreQuoteDialog:OnInit(root, data)
  UIDarkZoneStoreQuoteDialog.super.SetRoot(UIDarkZoneStoreQuoteDialog, root)
  self:InitBaseData()
  self.mview:InitCtrl(root, self.ui)
  self:AddBtnListen()
  self:InitInfoData()
end
function UIDarkZoneStoreQuoteDialog.OnUpdate(deltatime)
  self = UIDarkZoneStoreQuoteDialog
  for i = 1, #self.QuoteItemList do
    local item = self.QuoteItemList[i]
    if item ~= nil then
      item:OnUpdate()
    end
  end
end
function UIDarkZoneStoreQuoteDialog:OnClose()
  self.ui = nil
  self.mview = nil
  self.ItemDataList = nil
  self.IsPanelOpen = nil
  self:ReleaseCtrlTable(self.QuoteItemList, true)
  self.QuoteItemList = nil
end
function UIDarkZoneStoreQuoteDialog:InitBaseData()
  self.mview = UIDarkZoneStoreQuoteDialogView.New()
  self.ui = {}
  self.ItemDataList = {}
  self.IsPanelOpen = false
  self.QuoteItemList = {}
end
function UIDarkZoneStoreQuoteDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIDarkZoneStoreQuoteDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIDarkZoneStoreQuoteDialog)
  end
end
function UIDarkZoneStoreQuoteDialog:InitInfoData()
  local revices = DarkNetCmdStoreData.Revise
  local UpList = {}
  local DownList = {}
  for k, v in pairs(revices) do
    local data = {}
    data.Id = k
    data.Range = v
    data.Name = TableData.listDarkzoneKindDatas:GetDataById(k).name.str
    if 1000 < v then
      table.insert(UpList, data)
    elseif v < 1000 then
      table.insert(DownList, data)
    end
  end
  table.sort(UpList, function(a, b)
    if a == nil or b == nil then
      return false
    end
    if a.Range > b.Range then
      return true
    elseif a.Range == b.Range then
      return a.Id < b.Id
    else
      return false
    end
  end)
  table.sort(DownList, function(a, b)
    if a == nil or b == nil then
      return false
    end
    if a.Range > b.Range then
      return true
    elseif a.Range == b.Range then
      return a.Id < b.Id
    else
      return false
    end
  end)
  for i = 1, #UpList do
    local item = DZQuoteItem.New()
    item:InitCtrl(self.ui.mTrans_Content, self.ui.mPrefab)
    item:SetData(UpList[i])
    table.insert(self.QuoteItemList, item)
  end
  for i = 1, #DownList do
    local item = DZQuoteItem.New()
    item:InitCtrl(self.ui.mTrans_Content, self.ui.mPrefab)
    item:SetData(DownList[i])
    table.insert(self.QuoteItemList, item)
  end
end
