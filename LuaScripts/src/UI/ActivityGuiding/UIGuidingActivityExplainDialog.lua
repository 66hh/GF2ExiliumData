require("UI.UIBasePanel")
UIGuidingActivityExplainDialog = class("UISevenQuestDialog", UIBasePanel)
UIGuidingActivityExplainDialog.__index = UIGuidingActivityExplainDialog
function UIGuidingActivityExplainDialog:ctor(csPanel)
  self.super:ctor(csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIGuidingActivityExplainDialog:OnInit(root, data)
  self.super.SetRoot(UIGuidingActivityExplainDialog, root)
  self.ui = {}
  self.id = data.id
  self:LuaUIBindTable(root, self.ui)
  self:RegisterEvent()
end
function UIGuidingActivityExplainDialog:OnShowFinish()
  self.medium = NetCmdActivityGuidingData:GetActivityMedium(self.id)
  if self.medium ~= nil then
    self.ui.mText_Token.text = self.medium.Token
  end
end
function UIGuidingActivityExplainDialog.CloseSelf()
  UIManager.CloseUI(UIDef.UIGuidingActivityExplainDialog)
end
function UIGuidingActivityExplainDialog:RegisterEvent()
  UIUtils.GetButtonListener(self.ui.mBtn_Close:GetChild(0).gameObject).onClick = function()
    self.CloseSelf()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BgClose.gameObject).onClick = function()
    self.CloseSelf()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Copy.gameObject).onClick = function()
    if self.medium ~= nil then
      CS.UnityEngine.GUIUtility.systemCopyBuffer = self.medium.Token
      UIUtils.PopupPositiveHintMessage(7002)
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_QrCode.gameObject).onClick = function()
    NetCmdActivityGuidingData:SaveQrCodePic(self.ui.mImg_QrCode)
  end
end
function UIGuidingActivityExplainDialog:OnClose()
end
