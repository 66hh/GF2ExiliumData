UIRecordAudioDialog = class("UIRecordAudioDialog", UIBasePanel)
UIRecordAudioDialog.__index = UIRecordAudioDialog
function UIRecordAudioDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIRecordAudioDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListen()
end
function UIRecordAudioDialog:OnInit(root, data)
  self.mData = data[1]
  self.Callback = data[2]
  self:InitInfoData()
end
function UIRecordAudioDialog:OnShowStart()
end
function UIRecordAudioDialog:OnHide()
end
function UIRecordAudioDialog:OnClickClose()
  UIManager.CloseUI(UIDef.UIRecordAudioDialog)
  if NetCmdArchivesData:GetShowRewardSate() then
    UIManager.OpenUI(UIDef.UICommonReceivePanel)
    NetCmdArchivesData:SetShowRewardSate(false)
  end
end
function UIRecordAudioDialog:OnRelease()
  self.mData = nil
end
function UIRecordAudioDialog:InitInfoData()
  self.ui.mTrans_Content.anchoredPosition = vector2zero
  self.ui.mText_Name.text = self.mData.title.str
  self.ui.mText_Detail.text = self.mData.Text.str
  if self.Callback ~= nil then
    self.Callback()
  end
end
function UIRecordAudioDialog:AddBtnListen()
  self.ui.mBtn_Close.onClick:AddListener(function()
    self:OnClickClose()
  end)
end
