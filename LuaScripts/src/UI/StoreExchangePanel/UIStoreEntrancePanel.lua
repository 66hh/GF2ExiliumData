require("UI.StoreExchangePanel.UIStoreEntrancePanelView")
require("UI.UIBasePanel")
require("UI.StoreExchangePanel.UIStoreGlobal")
UIStoreEntrancePanel = class("UIStoreEntrancePanel", UIBasePanel)
UIStoreEntrancePanel.__index = UIStoreEntrancePanel
function UIStoreEntrancePanel:ctor()
  UIStoreEntrancePanel.super.ctor(self)
end
function UIStoreEntrancePanel.Open()
  UIStoreEntrancePanel.OpenUI(UIDef.UIStoreEntrancePanel)
end
function UIStoreEntrancePanel.Close()
  UIManager.CloseUI(UIDef.UIStoreEntrancePanel)
end
function UIStoreEntrancePanel:OnInit(root, data)
  UIStoreEntrancePanel.super.SetRoot(UIStoreEntrancePanel, root)
  self.mView = UIStoreEntrancePanelView.New()
  self.ui = {}
  self.mView:LuaUIBindTable(self.mUIRoot, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIStoreEntrancePanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  setactive(self.ui.mTrans_ExchangeLocked, not AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.Exchangestore))
  setactive(self.ui.mTrans_StoreLocked, not AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.Store))
  UIUtils.GetButtonListener(self.ui.mBtn_StoreExchange.gameObject).onClick = function()
    if TipsManager.NeedLockTips(SystemList.Exchangestore) then
      return
    end
    UIManager.OpenUI(UIDef.UIStoreExchangePanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Store.gameObject).onClick = function()
    if TipsManager.NeedLockTips(SystemList.Store) then
      return
    end
    UIManager.OpenUI(UIDef.UIStorePanel)
  end
end
function UIStoreEntrancePanel:OnShowFinish()
  setactive(self.ui.mTrans_StoreRedPoint, NetCmdStoreData:GetMaylingStoreRedPoint() > 0)
  setactive(self.ui.mTrans_ExchangeRedPoint, 0 < NetCmdStoreData:GetExchangeStoreRedPoint())
end
function UIStoreEntrancePanel:OnRelease()
end
