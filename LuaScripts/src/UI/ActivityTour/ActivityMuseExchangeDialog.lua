require("UI.UIBasePanel")
require("UI.ActivityTour.Btn_ActivityMuseDialogItem")
ActivityMuseExchangeDialog = class("ActivityMuseExchangeDialog", UIBasePanel)
ActivityMuseExchangeDialog.__index = ActivityMuseExchangeDialog
function ActivityMuseExchangeDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function ActivityMuseExchangeDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListener()
end
function ActivityMuseExchangeDialog:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ActivityMuseExchangeDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close1.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ActivityMuseExchangeDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Left.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ActivityMuseExchangeDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Right.gameObject).onClick = function()
    if NetCmdItemData:GetItemCount(self.exchangeData.Need) <= 0 then
      local itemData = TableData.listItemDatas:GetDataById(self.exchangeData.Need)
      PopupMessageManager.PopupPositiveString(string_format(TableData.GetHintById(225), itemData.name))
      return
    end
    self.themeId = NetCmdRecentActivityData:GetNowOpenThemeId(self.themeId)
    NetCmdThemeData:SendConfirmExchange(self.themeId, self.exchangeData.Id, function(ret)
      if ret == ErrorCodeSuc then
        UIManager.CloseUI(UIDef.ActivityMuseExchangeDialog)
        UIManager.OpenUI(UIDef.UICommonReceivePanel)
      else
        NetCmdThemeData:SendInspirationOrders(self.themeId, function(ret)
          if ret == ErrorCodeSuc then
            UIManager.CloseUI(UIDef.ActivityMuseExchangeDialog)
          end
        end)
      end
    end)
  end
end
function ActivityMuseExchangeDialog:OnInit(root, data)
  self.exchangeData = data.exchangeData
  self.themeId = data.themeId
end
function ActivityMuseExchangeDialog:UpdateItem()
  if self.leftItem == nil then
    self.leftItem = Btn_ActivityMuseDialogItem.New()
    self.leftItem:InitCtrl(self.ui.mTrans_Content)
  end
  self.leftItem:SetExchangeData(self.exchangeData, 2, false)
  if self.rightItem == nil then
    self.rightItem = Btn_ActivityMuseDialogItem.New()
    self.rightItem:InitCtrl(self.ui.mTrans_Content1, false)
  end
  self.rightItem:SetExchangeData(self.exchangeData, 1, false)
end
function ActivityMuseExchangeDialog:OnShowStart()
end
function ActivityMuseExchangeDialog:OnShowFinish()
  self:UpdateItem()
end
function ActivityMuseExchangeDialog:OnTop()
end
function ActivityMuseExchangeDialog:OnBackFrom()
end
function ActivityMuseExchangeDialog:OnClose()
end
function ActivityMuseExchangeDialog:OnHide()
end
function ActivityMuseExchangeDialog:OnHideFinish()
end
function ActivityMuseExchangeDialog:OnRelease()
end
