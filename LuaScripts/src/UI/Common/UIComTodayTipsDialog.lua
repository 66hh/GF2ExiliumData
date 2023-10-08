require("UI.Common.UIComTodayTipsDialogView")
UIComTodayTipsDialog = class("UIComTodayTipsDialog", UIBasePanel)
UIComTodayTipsDialog.__index = UIComTodayTipsDialog
local self = UIComTodayTipsDialog
function UIComTodayTipsDialog:ctor(csPanel)
  UIComTodayTipsDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIComTodayTipsDialog:OnAwake(root, data)
  self:SetRoot(root)
  self:InitBaseData()
  self.mview:InitCtrl(root, self.ui)
  self:AddBtnListen()
end
function UIComTodayTipsDialog:OnInit(root, data)
  self.mData = data
  self.ContentText = self.mData[1] == nil and "" or self.mData[1]
  self.ConfirmCb = self.mData[2]
  self.SaveKey = self.mData[3] == nil and "" or self.mData[3]
  self.CloseCb = self.mData[4]
  if self.mData[5] ~= nil then
    self.IsToday = self.mData[5]
  end
  self.ThisLoginCb = self.mData[6]
  self.ui.mText_Content.text = self.ContentText
  if self.IsToday then
    self.ui.mText_Toggle.text = TableData.GetHintById(103079)
  else
    self.ui.mText_Toggle.text = TableData.GetHintById(1099)
  end
  self.NeedSave = false
  setactive(self.ui.mTrans_ImgOn, self.NeedSave)
end
function UIComTodayTipsDialog:OnShow()
  self.IsPanelOpen = true
end
function UIComTodayTipsDialog.OnHide()
  self.IsPanelOpen = false
end
function UIComTodayTipsDialog:OnClickClose()
  if self.NeedSave then
    if self.IsToday then
      if self.SaveKey ~= "" then
        local key = AccountNetCmdHandler.Uid .. self.SaveKey
        PlayerPrefs.SetString(key, "save")
      else
        gfdebug("未传本地存储所用字段名")
      end
    elseif self.ThisLoginCb then
      self.ThisLoginCb()
    end
  end
  UIManager.CloseUI(UIDef.UIComTodayTipsDialog)
  if self.CloseCb then
    self.CloseCb()
  end
end
function UIComTodayTipsDialog:OnRelease()
  self.ui = nil
  self.mview = nil
  self.IsPanelOpen = nil
  self.NeedSave = nil
  self.SaveKey = nil
  self.ContentText = nil
  self.ConfirmCb = nil
  self.IsToday = nil
  self.ThisLoginCb = nil
end
function UIComTodayTipsDialog:InitBaseData()
  self.mview = UIComTodayTipsDialogView.New()
  self.ui = {}
  self.IsPanelOpen = false
  self.NeedSave = false
  if self.ui.mTrans_ImgOn then
    setactive(self.ui.mTrans_ImgOn, false)
  end
  self.SaveKey = ""
  self.ContentText = ""
  self.ConfirmCb = nil
  self.IsToday = true
  self.ThisLoginCb = nil
end
function UIComTodayTipsDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    self:OnClickClose()
    if self.ConfirmCb then
      self.ConfirmCb()
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BgClose.gameObject).onClick = function()
    self:OnClickClose()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:OnClickClose()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    self:OnClickClose()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Hint.gameObject).onClick = function()
    self.NeedSave = not self.NeedSave
    setactive(self.ui.mTrans_ImgOn, self.NeedSave)
  end
end
