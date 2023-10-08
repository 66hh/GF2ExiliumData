require("UI.UINickNamePanel.UINickNamePanelView")
require("UI.UIBasePanel")
require("UI.UICommonModifyPanel.UICommonBirthModifyPanel")
UINickNamePanelV2 = class("UINickNamePanelV2", UIBasePanel)
UINickNamePanelV2.__index = UINickNamePanelV2
UINickNamePanelV2.SexType = {Male = 0, Female = 1}
function UINickNamePanelV2:ctor(csPanel)
  self.super.ctor(UINickNamePanelV2, csPanel)
  csPanel.Is3DPanel = true
end
function UINickNamePanelV2:Close()
  UIManager.CloseUISelf(self)
  self.curSex = -1
  self.curDate = -1
end
function UINickNamePanelV2:OnRelease()
end
function UINickNamePanelV2:OnInit(root)
  self.super.SetRoot(UINickNamePanelV2, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.curDate = -1
  self.curSex = -1
  UIUtils.GetButtonListener(self.ui.mBtn_Man.gameObject).onClick = function()
    self:OnClickSex(UINickNamePanelV2.SexType.Male)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Woman.gameObject).onClick = function()
    self:OnClickSex(UINickNamePanelV2.SexType.Female)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnConfirm.gameObject).onClick = function()
    self:OnConfirmName()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BirthDaySel.gameObject).onClick = function()
    self:OnClickBirth()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:OnClickCard()
  end
  self:SetDefaultSex()
end
function UINickNamePanelV2:SetDefaultSex()
  self.curSex = UINickNamePanelV2.SexType.Male
  self.ui.mBtn_Man.interactable = self.curSex ~= UINickNamePanelV2.SexType.Male
  self.ui.mBtn_Woman.interactable = self.curSex ~= UINickNamePanelV2.SexType.Female
end
function UINickNamePanelV2:OnConfirmName()
  local strName = self.ui.mInputField.text
  if strName == "" or strName == nil then
    UIUtils.PopupHintMessage(60048)
    return
  end
  if not UIUtils.CheckInputIsLegal(strName) then
    UIUtils.PopupHintMessage(60077)
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
function UINickNamePanelV2:OnEndInput(str)
  setactive(self.mView.mTrans_Editor, true)
end
function UINickNamePanelV2:OnClickSex(type)
  if self.curSex == type then
    return
  end
  self.ui.mBtn_Man.interactable = type ~= UINickNamePanelV2.SexType.Male
  self.ui.mBtn_Woman.interactable = type ~= UINickNamePanelV2.SexType.Female
  if type == self.SexType.Male then
    if self.curSex ~= -1 then
      MessageSys:SendMessage(UIEvent.OnSetNameSlcMan, nil)
    end
  elseif type == self.SexType.Female then
    MessageSys:SendMessage(UIEvent.OnSetNameSlcWoman, nil)
  end
  self.curSex = type
end
function UINickNamePanelV2:OnModNameCallback(ret)
  if ret == ErrorCodeSuc then
    MessageSys:SendMessage(UIEvent.OnSetNameSuccess, self.curSex)
    self:Close()
  else
  end
end
function UINickNamePanelV2:OnClickCard()
  local type
  if self.curSex == UINickNamePanelV2.SexType.Male then
    type = UINickNamePanelV2.SexType.Female
  else
    type = UINickNamePanelV2.SexType.Male
  end
  self:OnClickSex(type)
end
function UINickNamePanelV2:UpdateBirthDay(birth)
  self.curDate = birth
  if self.curDate < 0 then
    self.ui.mText_NumMonth.text = "--"
    self.ui.mText_NumDay.text = "--"
  else
    local month = luaRoundNum(birth / 100)
    local day = luaRoundNum(birth - month * 100)
    self.ui.mText_NumMonth.text = string.format("-", tostring(month))
    self.ui.mText_NumDay.text = string.format("-", tostring(day))
  end
end
function UINickNamePanelV2:OnClickBirth()
  UICommonBirthModifyPanel.OpenBirthDayPanel(self.curDate, function(birthDay)
    self:UpdateBirthDay(birthDay)
  end, self.mCSPanel.UIGroupType)
end
