require("UI.UIBasePanel")
UIRecordPaperDialog = class("UIRecordPaperDialog", UIBasePanel)
UIRecordPaperDialog.__index = UIRecordPaperDialog
function UIRecordPaperDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIRecordPaperDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListen()
end
function UIRecordPaperDialog:OnInit(root, data)
  self.mData = data[1]
  self.Callback = data[2]
  self:InitInfoData()
end
function UIRecordPaperDialog:OnShowStart()
end
function UIRecordPaperDialog:OnHide()
end
function UIRecordPaperDialog:OnClickClose()
  UIManager.CloseUI(UIDef.UIRecordPaperDialog)
  if NetCmdArchivesData:GetShowRewardSate() then
    NetCmdArchivesData:SetShowRewardSate(false)
    UIManager.OpenUI(UIDef.UICommonReceivePanel)
  end
end
function UIRecordPaperDialog:OnRelease()
end
function UIRecordPaperDialog:InitInfoData()
  self.ui.mTrans_Content.anchoredPosition = vector2zero
  self.ui.mText_Name.text = self.mData.title.str
  self.ui.mText_Detail.text = self.mData.Text.str
  if self.Callback ~= nil then
    self.Callback()
  end
end
function UIRecordPaperDialog:AddBtnListen()
  self.ui.mBtn_Close.onClick:AddListener(function()
    self:OnClickClose()
  end)
end
