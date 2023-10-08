require("UI.UIBasePanel")
require("UI.MessageBox.Data.MessageContent")
MessageBoxPanel = class("MessageBoxPanel", UIBasePanel)
MessageBoxPanel.__index = MessageBoxPanel
function MessageBoxPanel.Show(messageContent)
  UIManager.OpenUIByParam(UIDef.MessageBoxPanel, messageContent)
end
function MessageBoxPanel.ShowByParam(content, showType, okCb, cancelCb, title, okTxt, cancelTxt, zPos)
  local messageData = MessageContent.New(content, showType, okCb, cancelCb, title, okTxt, cancelTxt, zPos)
  MessageBoxPanel.Show(messageData)
end
function MessageBoxPanel.ShowDoubleType(content, okCb, cancelCb, title, okTxt, cancelTxt)
  local messageData = MessageContent.New(content, nil, okCb, cancelCb, title, okTxt, cancelTxt, nil)
  MessageBoxPanel.Show(messageData)
end
function MessageBoxPanel.ShowGotoType(content, okCb, cancelCb, title, gotoTxt, cancelTxt)
  local messageData = MessageContent.New(content, MessageContent.MessageType.GotoBtn, okCb, cancelCb, title, gotoTxt, cancelTxt, nil)
  MessageBoxPanel.Show(messageData)
end
function MessageBoxPanel.ShowSingleType(content, okCb, title, okTxt)
  local messageData = MessageContent.New(content, MessageContent.MessageType.SingleBtn, okCb, nil, title, okTxt, nil, nil)
  MessageBoxPanel.Show(messageData)
end
function MessageBoxPanel.ShowItemNotEnoughMessage(itemId, jumpFunc, zPos, hintId)
  local hint = TableData.GetHintById(200)
  if hintId then
    hint = TableData.GetHintById(hintId)
  end
  local itemData = TableData.listItemDatas:GetDataById(itemId)
  if itemData then
    hint = string_format(hint, itemData.name.str)
    local messageData = MessageContent.New(hint, MessageContent.MessageType.GotoBtn, jumpFunc, function()
      MessageBoxPanel.IsItemNotEnough = false
    end, nil, nil, nil, zPos)
    MessageBoxPanel.Show(messageData)
    MessageBoxPanel.IsItemNotEnough = true
  end
end
MessageBoxPanel.IsQuickClose = false
function MessageBoxPanel.Close()
  UIManager.CloseUI(UIDef.MessageBoxPanel)
end
function MessageBoxPanel:OnRelease()
  self.messageData = nil
end
function MessageBoxPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function MessageBoxPanel:OnInit(root, data)
  self.messageData = data
  self:SetRoot(root)
  self:InitCtrl(root)
  self:SetPosZ()
  self:UpdatePanel()
end
function MessageBoxPanel:InitCtrl(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Ok.gameObject).onClick = function()
    if self.messageData.okCallback ~= nil then
      self.Close()
      self.messageData.okCallback()
    else
      self.Close()
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    if self.messageData.cancelCallback ~= nil then
      self.Close()
      self.messageData.cancelCallback()
    else
      self.Close()
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Goto.gameObject).onClick = function()
    if self.messageData.okCallback ~= nil then
      self.Close()
      self.messageData.okCallback()
    else
      self.Close()
    end
  end
  self.animator = getchildcomponent(root, "Root", typeof(CS.UnityEngine.Animator))
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    if self.messageData.closeCallback ~= nil then
      self.messageData.closeCallback()
    end
    self.Close()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BgClose.gameObject).onClick = function()
    if self.messageData.closeCallback ~= nil then
      self.messageData.closeCallback()
    end
    self.Close()
  end
end
function MessageBoxPanel:UpdatePanel()
  self.ui.mText_Title.text = self.messageData.title
  self.ui.mText_Content.text = self.messageData.content
  local cancleText = self.ui.mTrans_Cancel:Find("Btn_Content/Root/GrpText/Text_Name"):GetComponent("Text")
  local okText = self.ui.mTrans_Ok:Find("Btn_Content/Root/GrpText/Text_Name"):GetComponent("Text")
  if self.messageData.cancelTxt ~= TableData.GetHintById(19) then
    cancleText.text = self.messageData.cancelTxt
  end
  if self.messageData.okTxt ~= TableData.GetHintById(18) then
    okText.text = self.messageData.okTxt
  end
  if self.messageData.showType == MessageContent.MessageType.DoubleBtn then
    setactive(self.ui.mTrans_Cancel.gameObject, true)
    setactive(self.ui.mTrans_Goto.gameObject, false)
    setactive(self.ui.mTrans_Ok.gameObject, true)
  elseif self.messageData.showType == MessageContent.MessageType.GotoBtn then
    setactive(self.ui.mTrans_Cancel.gameObject, true)
    setactive(self.ui.mTrans_Goto.gameObject, true)
    setactive(self.ui.mTrans_Ok.gameObject, false)
  elseif self.messageData.showType == MessageContent.MessageType.SingleBtn then
    setactive(self.ui.mTrans_Cancel.gameObject, false)
    setactive(self.ui.mTrans_Goto.gameObject, false)
    setactive(self.ui.mTrans_Ok.gameObject, true)
  end
end
function MessageBoxPanel:OnClose()
  UIUtils.GetButtonListener(self.ui.mBtn_Ok.gameObject).onClick = nil
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = nil
  UIUtils.GetButtonListener(self.ui.mBtn_BgClose.gameObject).onClick = nil
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = nil
  UIUtils.GetButtonListener(self.ui.mBtn_Goto.gameObject).onClick = nil
end
