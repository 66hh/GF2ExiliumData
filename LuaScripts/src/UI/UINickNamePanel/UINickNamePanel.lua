require("UI.UINickNamePanel.UINickNamePanelView")
require("UI.UIBasePanel")
require("UI.UICommonModifyPanel.UICommonBirthModifyPanel")
UINickNamePanel = class("UINickNamePanel", UIBasePanel)
UINickNamePanel.__index = UINickNamePanel
UINickNamePanel.SexType = {Male = 0, Female = 1}
UINickNamePanel.callback = nil
UINickNamePanel.curSex = -1
UINickNamePanel.curDate = -1
function UINickNamePanel:ctor(csPanel)
  UINickNamePanel.super.ctor(UINickNamePanel, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  self.mCSPanel = csPanel
end
function UINickNamePanel:Close()
  UIManager.CloseUISelf(self)
  self.curSex = -1
  self.curDate = -1
end
function UINickNamePanel:OnRelease()
end
function UINickNamePanel:OnInit(root, data)
  self.callback = data
  self.super.SetRoot(self, root)
  self.mView = UINickNamePanelView.New()
  self.mView:InitCtrl(root)
  UIUtils.GetButtonListener(self.mView.mBtn_Man.gameObject).onClick = function()
    self:OnClickSex(self.SexType.Male)
  end
  UIUtils.GetButtonListener(self.mView.mBtn_Woman.gameObject).onClick = function()
    self:OnClickSex(self.SexType.Female)
  end
  UIUtils.GetButtonListener(self.mView.mBtn_Confirm.gameObject).onClick = function()
    self:OnConfirmName()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_Birth.gameObject).onClick = function()
    self:OnClickBirth()
  end
  self.mView.mText_Month.text = "--"
  self.mView.mText_Day.text = "--"
end
function UINickNamePanel:OnConfirmName()
  local strName = self.mView.mInputField.text
  if strName == "" then
    UIUtils.PopupHintMessage(60048)
    return
  end
  if not UIUtils.CheckInputIsLegal(strName) then
    UIUtils.PopupHintMessage(60049)
    return
  end
  if self.curSex < 0 then
    UIUtils.PopupHintMessage(60059)
    return
  end
  if 0 > self.curDate then
    UIUtils.PopupHintMessage(60063)
    return
  end
  AccountNetCmdHandler:SendInitRoleInfo(strName, self.curSex, self.curDate, function(ret)
    self:OnModNameCallback(ret)
  end)
end
function UINickNamePanel:OnEndInput(str)
  setactive(self.mView.mTrans_Editor, true)
end
function UINickNamePanel:OnClickSex(type)
  if self.curSex == type then
    return
  end
  self.mView.mBtn_Man.interactable = type ~= self.SexType.Male
  self.mView.mBtn_Woman.interactable = type ~= self.SexType.Female
  self.curSex = type
end
function UINickNamePanel:OnModNameCallback(ret)
  if ret == ErrorCodeSuc then
    if self.callback ~= nil then
      self.callback(self)
    else
      self:Close()
    end
  else
    UIUtils.PopupHintMessage(60049)
  end
end
function UINickNamePanel:UpdateBirthDay(birth)
  self.curDate = birth
  if self.curDate < 0 then
    self.mView.mText_Month.text = "--"
    self.mView.mText_Day.text = "--"
  else
    local month = luaRoundNum(birth / 100)
    local day = luaRoundNum(birth - month * 100)
    self.mView.mText_Month.text = string.format("-", tostring(month))
    self.mView.mText_Day.text = string.format("-", tostring(day))
  end
end
function UINickNamePanel:OnClickBirth()
  UICommonBirthModifyPanel.OpenBirthDayPanel(self.curDate, function(birthDay)
    self:UpdateBirthDay(birthDay)
  end, self.mCSPanel.UIGroupType)
end
