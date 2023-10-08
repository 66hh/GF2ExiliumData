require("UI.DarkZonePanel.UIDarkZoneTeamReNameDialog.UIDarkZoneTeamReNameDialogView")
require("UI.UIBasePanel")
UIDarkZoneTeamReNameDialog = class("UIDarkZoneTeamReNameDialog", UIBasePanel)
UIDarkZoneTeamReNameDialog.__index = UIDarkZoneTeamReNameDialog
function UIDarkZoneTeamReNameDialog:ctor(csPanel)
  UIDarkZoneTeamReNameDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneTeamReNameDialog:OnInit(root, data)
  UIDarkZoneTeamReNameDialog.super.SetRoot(UIDarkZoneTeamReNameDialog, root)
  self.panelData = data
  self:InitBaseData()
  self.mview:InitCtrl(root, self.ui)
  self:AddBtnListen()
  self:OnValueChange()
  self.ui.mInputField.text = self.defaultStr
end
function UIDarkZoneTeamReNameDialog:OnClose()
  self.ui = nil
  self.mview = nil
  self.defaultStr = nil
  self.strName = nil
end
function UIDarkZoneTeamReNameDialog:OnRelease()
  self.super.OnRelease(self)
  self.hasCache = false
end
function UIDarkZoneTeamReNameDialog:InitBaseData()
  self.mview = UIDarkZoneTeamReNameDialogView.New()
  self.ui = {}
  self.defaultStr = self.panelData.ui.mText_TeamName.text
end
function UIDarkZoneTeamReNameDialog:AddBtnListen()
  if self.hasCache ~= true then
    local f = function()
      UIManager.CloseUI(UIDef.UIDarkZoneTeamReNameDialog)
    end
    self.ui.mBtn_Close.onClick:AddListener(f)
    self.ui.mBtn_Cancel.onClick:AddListener(f)
    self.ui.mBtn_GrpClose.onClick:AddListener(f)
    self.ui.mBtn_Confirm.onClick:AddListener(function()
      self:OnConfirmName()
    end)
    self.ui.mInputField.onValueChanged:AddListener(function()
      self:OnValueChange()
    end)
    self.ui.mInputField.onEndEdit:AddListener(function(strText)
      if strText == "" then
        self.ui.mInputField.text = self.defaultStr
      end
    end)
    self.hasCache = true
  end
end
function UIDarkZoneTeamReNameDialog:OnConfirmName()
  local strName = self.ui.mInputField.text
  if strName == "" then
    UIUtils.PopupHintMessage(60048)
    return
  else
    if strName == self.defaultStr then
      UIUtils.PopupHintMessage(903335)
      return
    end
    if not UIUtils.CheckInputIsLegal(strName) then
      UIUtils.PopupHintMessage(60049)
      return
    end
  end
  self.strName = strName
  local teamid = self.panelData.curTeam
  DarkNetCmdTeamData:SetTeamName(teamid, strName, function(ret)
    self:OnReNameCallback(ret)
  end)
end
function UIDarkZoneTeamReNameDialog:OnReNameCallback(ret)
  if ret == CS.CMDRet.eError then
    UIUtils.PopupHintMessage(60049)
  else
    local curteam = self.panelData.curTeam
    self.panelData.TeamDataDic[curteam + 1].name = self.strName
    self.panelData.ui.mText_TeamName.text = self.strName
    self.panelData.TeamObj[curteam + 1].txtName.text = self.strName
    DarkNetCmdTeamData.Teams[curteam].Name = self.strName
    UIManager.CloseUI(UIDef.UIDarkZoneTeamReNameDialog)
    UIUtils.PopupPositiveHintMessage(7001)
  end
end
function UIDarkZoneTeamReNameDialog:OnValueChange()
  local str = self.ui.mInputField.text
  self.ui.mText_Num.text = utf8.len(str)
  self.ui.mText_NumAll.text = "/" .. 7
end
