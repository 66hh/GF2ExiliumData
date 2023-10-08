require("UI.UIBasePanel")
UIRecordVideoDialog = class("UIRecordVideoDialog", UIBasePanel)
UIRecordVideoDialog.__index = UIRecordVideoDialog
function UIRecordVideoDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIRecordVideoDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListen()
end
function UIRecordVideoDialog:OnInit(root, data)
  self.mData = data[1]
  self.Callback = data[2]
  self:InitInfoData()
end
function UIRecordVideoDialog:OnShowStart()
end
function UIRecordVideoDialog:OnHide()
end
function UIRecordVideoDialog:OnClickClose()
  UIManager.CloseUI(UIDef.UIRecordVideoDialog)
  if NetCmdArchivesData:GetShowRewardSate() then
    UIManager.OpenUI(UIDef.UICommonReceivePanel)
    NetCmdArchivesData:SetShowRewardSate(false)
  end
end
function UIRecordVideoDialog:OnRelease()
end
function UIRecordVideoDialog:InitInfoData()
  self.ui.mTrans_Content.anchoredPosition = vector2zero
  self.ui.mText_Name.text = self.mData.title.str
  self.ui.mText_Detail.text = self.mData.Text.str
  if self.Callback ~= nil then
    self.Callback()
  end
end
function UIRecordVideoDialog:AddBtnListen()
  self.ui.mBtn_Close.onClick:AddListener(function()
    self:OnClickClose()
  end)
end
