require("UI.UIBasePanel")
UICommanderExchangeDialog = class("UICommanderExchangeDialog", UIBasePanel)
UICommanderExchangeDialog.__index = UICommanderExchangeDialog
UICommanderExchangeDialog.CdkSuc = 0
function UICommanderExchangeDialog:ctor(csPanel)
  UICommanderExchangeDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UICommanderExchangeDialog:OnInit(root, data)
  self:SetRoot(root)
  self.ui = {}
  self.playerInfo = data
  self:LuaUIBindTable(root, self.ui)
  self:AddListener()
  self:RefreshContent()
  MessageSys:AddListener(UIEvent.ExchangeGift, self.OnExchangeCallBack)
end
function CloseBtnClick()
  UIManager.CloseUI(UIDef.UICommanderExchangeDialog)
end
function UICommanderExchangeDialog:AddListener()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UICommanderExchangeDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UICommanderExchangeDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    if self.ui.mInput_Field.text == nil or self.ui.mInput_Field.text == "" then
      UIUtils.PopupHintMessage(260004)
      return
    end
    if self.ui.mInput_Field.text ~= nil and self.ui.mInput_Field.text ~= "" then
      gfdebug(self.ui.mInput_Field.text)
      AccountNetCmdHandler:SendExchangeGift(self.ui.mInput_Field.text)
    end
  end
end
function UICommanderExchangeDialog:RefreshContent()
  self.ui.mText_SetTime.text = self.playerInfo.Name
  self.ui.mText_Lv.text = self.playerInfo.Level
  self.ui.mText_Uid.text = self.playerInfo.UID
  self.ui.mImg_Avatar.sprite = IconUtils.GetPlayerAvatar(self.playerInfo.BustIcon)
  self.ui.mInput_Field.text = ""
end
function UICommanderExchangeDialog:OnClose()
  self.playerInfo = nil
  self.ui = nil
  MessageSys:RemoveListener(UIEvent.ExchangeGift, self.OnExchangeCallBack)
end
function UICommanderExchangeDialog.OnExchangeCallBack(message)
  if not message or not message.Sender then
    return
  end
  local ret = message.Sender
  if ret == UICommanderExchangeDialog.CdkSuc then
    UIUtils.PopupPositiveHintMessage(260001)
    UICommanderExchangeDialog.ui.mInput_Field.text = ""
  else
    local hintData = TableData.listRedeemCodeHintDatas:GetDataById(ret < 0 and -ret or ret)
    if hintData then
      CS.PopupMessageManager.PopupString(hintData.chars.str)
    end
  end
end
