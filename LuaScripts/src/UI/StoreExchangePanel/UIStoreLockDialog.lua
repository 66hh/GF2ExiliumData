require("UI.PVP.Item.UIPVPStoreUnlockConditionItem")
require("UI.UIBasePanel")
UIStoreLockDialog = class("UIStoreLockDialog", UIBasePanel)
UIStoreLockDialog.__index = UIStoreLockDialog
UIStoreLockDialog.itemListLock = {}
UIStoreLockDialog.itemListUnlock = {}
function UIStoreLockDialog:ctor(csPanel)
  UIStoreLockDialog.super.ctor(UIStoreLockDialog, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  csPanel.UsePool = false
end
function UIStoreLockDialog.Open()
  UIStoreLockDialog.OpenUI(UIDef.UIStoreLockDialog)
end
function UIStoreLockDialog.Close()
  UIManager.CloseUI(UIDef.UIStoreLockDialog)
end
function UIStoreLockDialog:OnInit(root, data)
  UIStoreLockDialog.super.SetRoot(UIStoreLockDialog, root)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  if type(data) == "table" then
    self.mData = data.data
    self.parent = data.parent
  else
    self.mData = data
  end
  self.icon = nil
  self.BigItem = UICommonItem.New()
  self.BigItem:InitCtrl(self.ui.mTrans_Item)
  self.BigItem.mUIRoot.transform.anchoredPosition = vector2zero
  local stcData = TableData.GetItemData(self.mData.frame, true)
  if self.mData.icon ~= "" then
    local iconSprite = IconUtils.GetItemIcon(self.mData.icon)
    local itemId = self.mData.ItemNumList[0].itemid
    local item = TableData.GetItemData(itemId)
    if item.type == 51 then
      self.BigItem:SetRankAndIconData(self.mData.rank, iconSprite, itemId, nil, self.ui.mBtn_StoreDetail)
    else
      self.BigItem:SetRankAndIconData(self.mData.rank, iconSprite, nil, nil, self.ui.mBtn_StoreDetail)
      self.stcData = self.mData:GetStoreGoodData()
      UIUtils.GetButtonListener(self.ui.mBtn_StoreDetail.gameObject).onClick = function()
        UITipsPanel.OpenStoreGood(self.stcData.name.str, self.stcData.icon, self.stcData.description.str, self.stcData.rank, self.stcData)
      end
    end
    self.icon = self.mData.icon
  elseif self.mData.frame ~= 0 and stcData ~= nil and stcData.type == 25 then
    local costItemNum = NetCmdItemData:GetItemCountById(self.mData.frame)
    self.BigItem:SetByItemData(stcData, nil, false, self.ui.mBtn_StoreDetail)
    self.icon = self.mData.frame
  elseif self.mData.frame ~= 0 and stcData ~= nil then
    self.BigItem:SetByItemData(stcData, nil, false, self.ui.mBtn_StoreDetail)
    self.icon = self.mData.frame
  end
  self.BigItem.mUIRoot:GetComponent(typeof(CS.UnityEngine.CanvasGroup)).blocksRaycasts = false
  self.stcData = self.mData:GetStoreGoodData()
  self.ui.mText_ItemName.text = self.stcData.name.str
  self.ui.mText_Description.text = self.stcData.description.str
  self.ui.mScroll_Des.verticalNormalizedPosition = 1
  setactive(self.ui.mTrans_CreditNum, false)
  setactive(self.ui.mBtn_Buy, false)
  setactive(self.ui.mBtn_InfoOpen1, false)
  setactive(self.ui.mBtn_Cancel, false)
  setactive(self.ui.mTrans_PurchaseQuantity, false)
  setactive(self.ui.mBtn_PriceDetails, false)
  setactive(self.ui.mTrans_LockLimit, true)
  setactive(self.ui.mTrans_Bought, false)
  setactive(self.ui.mTrans_Top, false)
  setactive(self.ui.mTrans_GrpTextLeft, false)
  setactive(self.ui.mTrans_ItemBoxList, false)
  if self.ui.mTrans_ItemBoxLis then
    setactive(self.ui.mTrans_ItemBoxLis, false)
  end
  TimerSys:DelayFrameCall(5, function()
    self.lockCondition = self.mData.lock_cause_desList
    for i = 0, self.lockCondition.Count - 1 do
      local item = self.itemListLock[i + 1]
      if not item then
        item = UIPVPStoreUnlockConditionItem.New()
        table.insert(self.itemListLock, item)
      end
      item:InitCtrl(self.ui.mTrans_Bought, self.ui.mTrans_LockContent)
      item:SetData(self.lockCondition[i])
      item:SetLock()
    end
    self.unlockCondition = self.mData.unlock_desList
    for i = 0, self.unlockCondition.Count - 1 do
      local item = self.itemListUnlock[i + 1]
      if not item then
        item = UIPVPStoreUnlockConditionItem.New()
        table.insert(self.itemListUnlock, item)
      end
      item:InitCtrl(self.ui.mTrans_Bought, self.ui.mTrans_LockContent)
      item:SetData(self.unlockCondition[i])
      item:SetComplete()
    end
  end)
  UIUtils.GetButtonListener(self.ui.mBtn_Exit.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIStoreLockDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIStoreLockDialog)
  end
end
function UIStoreLockDialog:OnClose()
  for _, item in pairs(self.itemListLock) do
    gfdestroy(item:GetRoot())
  end
  for _, item in pairs(self.itemListUnlock) do
    gfdestroy(item:GetRoot())
  end
  setactive(self.ui.mBtn_InfoOpen1, true)
  setactive(self.ui.mBtn_Buy, true)
  setactive(self.ui.mBtn_Cancel, true)
  setactive(self.ui.mTrans_PurchaseQuantity, true)
  setactive(self.ui.mBtn_PriceDetails, true)
  setactive(self.ui.mTrans_Bought, true)
  setactive(self.ui.mTrans_Top, true)
  setactive(self.ui.mTrans_GrpTextLeft, true)
  setactive(self.ui.mTrans_LockLimit, false)
  setactive(self.ui.mTrans_ItemBoxList, true)
  self.itemListLock = {}
  self.itemListUnlock = {}
  if self.BigItem then
    gfdestroy(self.BigItem:GetRoot())
  end
  setactive(self.ui.mBtn_Buy, true)
  setactive(self.ui.mBtn_Cancel, true)
end
function UIStoreLockDialog:OnRelease()
  if self.topRes ~= nil then
    self.topRes:Release()
  end
end
