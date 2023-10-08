require("UI.Common.UICommonSimpleView")
require("UI.DarkZonePanel.UIDarkZoneWishPanel.Item.UIDarkZoneWishDescribeItem")
require("UI.UIBasePanel")
UIDarkZoneWishDescribeDialog = class("UIDarkZoneWishDescribeDialog", UIBasePanel)
UIDarkZoneWishDescribeDialog.__index = UIDarkZoneWishDescribeDialog
function UIDarkZoneWishDescribeDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneWishDescribeDialog:OnInit(root, data)
  self:SetRoot(root)
  self.endlessData = TableData.listDarkzoneSystemEndlessDatas:GetDataById(data.endlessId)
  self.callback = data.callback
  self.dataList = data.dataList
  self.needWish = data.needWish
  self.limitTime = data.limitTime
  self:InitBaseData()
  self.mView:InitCtrl(root, self.ui)
  self:AddBtnListen()
  self:UpdateData()
  local needCountDown = self.needWish == true and self.limitTime
  setactive(self.ui.mTrans_Action, self.needWish == true)
  self.ui.mUICountdown_TitleText.enabled = needCountDown
  if needCountDown then
    self.ui.mUICountdown_TitleText:SetHitID(240080)
    self.ui.mUICountdown_TitleText:SetShowType(1)
    self.ui.mUICountdown_TitleText:StartCountdown(self.limitTime)
    self.ui.mUICountdown_TitleText:AddFinishCallback(function(suc)
      self:CloseFunction()
    end)
  else
    self.ui.mText_Title.text = TableData.GetHintById(240082)
  end
end
function UIDarkZoneWishDescribeDialog:CloseFunction()
  UIManager.CloseUI(UIDef.UIDarkZoneWishDescribeDialog)
end
function UIDarkZoneWishDescribeDialog:OnClose()
  if self.needWish == true and self.limitTime then
    self.ui.mUICountdown_TitleText:CleanFinishCallback()
  end
  self.ui = nil
  self.mView = nil
  self:ReleaseCtrlTable(self.itemList, true)
  self.itemList = nil
  self.endlessData = nil
  self.callback = nil
  self.dataList = nil
  self.needWish = nil
  self.limitTime = nil
end
function UIDarkZoneWishDescribeDialog:InitBaseData()
  self.mView = UICommonSimpleView.New()
  self.ui = {}
  self.itemList = {}
end
function UIDarkZoneWishDescribeDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    self:OnClickConFirmBtn()
  end
end
function UIDarkZoneWishDescribeDialog:UpdateData()
  local dataCount = #self.dataList
  for i = 1, dataCount do
    if self.itemList[i] == nil then
      self.itemList[i] = UIDarkZoneWishDescribeItem.New()
      self.itemList[i]:InitCtrl(self.ui.mTrans_Content)
    end
    local item = self.itemList[i]
    item:SetData(self.dataList[i])
  end
  setactive(self.ui.mTrans_List, 0 < dataCount)
  setactive(self.ui.mTrans_TextEmpty, dataCount <= 0)
end
function UIDarkZoneWishDescribeDialog:OnClickConFirmBtn()
  if self.callback then
    self.callback()
  end
  self:CloseFunction()
end
