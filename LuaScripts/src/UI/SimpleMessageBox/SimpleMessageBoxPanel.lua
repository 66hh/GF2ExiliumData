require("UI.UIBaseView")
SimpleMessageBoxPanel = class("SimpleMessageBoxPanel", UIBasePanel)
SimpleMessageBoxPanel.__index = SimpleMessageBoxPanel
SimpleMessageBoxPanel.mBtn_Close = nil
SimpleMessageBoxPanel.mBtn_Close1 = nil
SimpleMessageBoxPanel.mText_Title = nil
SimpleMessageBoxPanel.mText_ = nil
SimpleMessageBoxPanel.mContent_ = nil
SimpleMessageBoxPanel.mScrollbar_ = nil
SimpleMessageBoxPanel.mList_ = nil
function SimpleMessageBoxPanel:ctor(csPanel)
  SimpleMessageBoxPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function SimpleMessageBoxPanel:OnInit(root, data)
  self.messageData = data
  SimpleMessageBoxPanel.super.SetRoot(SimpleMessageBoxPanel, root)
  self:InitCtrl(root)
end
function SimpleMessageBoxPanel:InitCtrl(root)
  self:SetRoot(root)
  self.mBtn_BgClose = UIUtils.GetButton(root, "Root/GrpBg/Btn_Close")
  self.mBtn_Close = UIUtils.GetTempBtn(UIUtils.GetRectTransform(root, "Root/GrpDialog/GrpTop/GrpClose"))
  self.mText_Title = UIUtils.GetText(root, "Root/GrpDialog/GrpTop/GrpText/TitleText")
  self.mText_Content = UIUtils.GetText(root, "Root/GrpDialog/GrpCenter/GrpTextList/Viewport/Content/Text_Content")
  UIUtils.GetButtonListener(self.mBtn_Close.gameObject).onClick = function()
    self.Close()
  end
  UIUtils.GetButtonListener(self.mBtn_BgClose.gameObject).onClick = function()
    self.Close()
  end
  self.animator = getchildcomponent(root, "Root", typeof(CS.UnityEngine.Animator))
  self:UpdatePanel()
end
function SimpleMessageBoxPanel:OnClose()
end
function SimpleMessageBoxPanel.Show(messageContent)
  UIManager.OpenUIByParam(UIDef.SimpleMessageBoxPanel, messageContent)
end
function SimpleMessageBoxPanel.ShowByParam(title, content, zPos)
  SimpleMessageBoxPanel.Show({
    title,
    content,
    zPos
  })
end
function SimpleMessageBoxPanel.Close()
  UIManager.CloseUI(UIDef.SimpleMessageBoxPanel)
end
function SimpleMessageBoxPanel:UpdatePanel()
  self.mText_Title.text = self.messageData[1]
  self.mText_Content.text = self.messageData[2]
end
