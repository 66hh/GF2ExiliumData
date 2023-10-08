require("UI.UIBasePanel")
require("UI.UICommonModifyPanel.UICommonSelfModifyPanelView")
UICommonSelfModifyPanel = class("UICommonSelfModifyPanel", UIBasePanel)
UICommonSelfModifyPanel.__index = UICommonSelfModifyPanel
UICommonSelfModifyPanel.confirmCallback = nil
UICommonSelfModifyPanel.isEnough = false
UICommonSelfModifyPanel.costId = 0
function UICommonSelfModifyPanel:ctor(csPanel)
  UICommonSelfModifyPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UICommonSelfModifyPanel.Close()
  self = UICommonSelfModifyPanel
  UIManager.CloseUI(UIDef.UICommonSelfModifyPanel)
end
function UICommonSelfModifyPanel:OnRelease()
  self = UICommonSelfModifyPanel
  UICommonSelfModifyPanel.confirmCallback = nil
  UICommonSelfModifyPanel.defaultStr = ""
  UICommonSelfModifyPanel.isEnough = false
end
function UICommonSelfModifyPanel:OnInit(root, data)
  self = UICommonSelfModifyPanel
  self.confirmCallback = data[1]
  self.defaultStr = data[2]
  UICommonSelfModifyPanel.super.SetRoot(UICommonSelfModifyPanel, root)
  UICommonSelfModifyPanel.mView = UICommonSelfModifyPanelView.New()
  UICommonSelfModifyPanel.mView:InitCtrl(root)
  UIUtils.GetButtonListener(self.mView.mBtn_Close.gameObject).onClick = function()
    UICommonSelfModifyPanel.Close()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_CloseBg.gameObject).onClick = function()
    UICommonSelfModifyPanel.Close()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_Cancel.gameObject).onClick = function()
    UICommonSelfModifyPanel.Close()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_Confirm.gameObject).onClick = function()
    UICommonSelfModifyPanel:OnConfirmName()
  end
  setactive(self.mView.mTrans_TextLimit, false)
  self.mView.mText_InputField.text = self.defaultStr
  self.mView.mText_InputField.onValueChanged:AddListener(function()
    UICommonSelfModifyPanel:OnValueChange()
  end)
  self:OnValueChange()
  self:UpdateCostItem()
end
function UICommonSelfModifyPanel:UpdateCostItem()
  local id = 0
  local num = 0
  for i, v in pairs(TableData.GlobalSystemData.PlayerNameChangeCost) do
    id = i
    num = v
  end
  self.mView.mImage_CostIcon.sprite = IconUtils.GetItemIconSprite(id)
  self.mView.mText_CostNum.text = num
  self.costId = id
  self.isEnough = num <= NetCmdItemData:GetItemCountById(id)
  self.mView.mText_CostNum.color = self.isEnough and ColorUtils.BlackColor or ColorUtils.RedColor
end
function UICommonSelfModifyPanel:OnBackFrom()
  self:UpdateCostItem()
end
function UICommonSelfModifyPanel:OnTop()
  self:UpdateCostItem()
end
function UICommonSelfModifyPanel:OnConfirmName()
  local strName = self.mView.mText_InputField.text
  if strName == "" then
    UIUtils.PopupHintMessage(60048)
    return
  else
    if strName == self.defaultStr then
      UIUtils.PopupHintMessage(7007)
      return
    end
    if not UIUtils.CheckInputIsLegal(strName) then
      UIUtils.PopupHintMessage(60049)
      return
    end
  end
  if not self.isEnough then
    CS.PopupMessageManager.PopupString(GlobalConfig.GetCostNotEnoughStr(self.costId))
    return
  end
  if self.confirmCallback ~= nil then
    self.confirmCallback(strName)
  end
end
function UICommonSelfModifyPanel:OnValueChange()
  local str = self.mView.mText_InputField.text
  self.mView.mText_Num.text = utf8.len(str)
  self.mView.mText_AllNum.text = "/" .. 7
  setactive(self.mView.mTrans_TextLimit, 0 < #str)
end
