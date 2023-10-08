require("UI.UIBasePanel")
UIRecordElectronDialog = class("UIRecordElectronDialog", UIBasePanel)
UIRecordElectronDialog.__index = UIRecordElectronDialog
function UIRecordElectronDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIRecordElectronDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListen()
end
function UIRecordElectronDialog:OnInit(root, data)
  self.mData = data[1]
  self.Callback = data[2]
  self:InitInfoData()
end
function UIRecordElectronDialog:OnShowStart()
end
function UIRecordElectronDialog:OnHide()
end
function UIRecordElectronDialog:OnClickClose()
  UIManager.CloseUI(UIDef.UIRecordElectronDialog)
  if NetCmdArchivesData:GetShowRewardSate() then
    UIManager.OpenUI(UIDef.UICommonReceivePanel)
    NetCmdArchivesData:SetShowRewardSate(false)
  end
end
function UIRecordElectronDialog:OnRelease()
end
function UIRecordElectronDialog:InitInfoData()
  self.ui.mTrans_Content.anchoredPosition = vector2zero
  self.ui.mText_Name.text = self.mData.title.str
  self.ui.mText_Detail.text = self.mData.Text.str
  if self.Callback ~= nil then
    self.Callback()
  end
end
function UIRecordElectronDialog:AddBtnListen()
  self.ui.mBtn_Close.onClick:AddListener(function()
    self:OnClickClose()
  end)
end
