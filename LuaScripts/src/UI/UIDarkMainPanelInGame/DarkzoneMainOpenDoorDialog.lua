require("UI.UIDarkMainPanelInGame.DarkzoneMainOpenDoorDialogView")
require("UI.UIBasePanel")
local EnumDarkzoneProperty = require("UI.UIDarkMainPanelInGame.DarkzoneProperty")
DarkzoneMainOpenDoorDialog = class("DarkzoneMainOpenDoorDialog", UIBasePanel)
DarkzoneMainOpenDoorDialog.__index = DarkzoneMainOpenDoorDialog
function DarkzoneMainOpenDoorDialog:ctor(csPanel)
  DarkzoneMainOpenDoorDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function DarkzoneMainOpenDoorDialog:OnInit(root, data)
  DarkzoneMainOpenDoorDialog.super.SetRoot(DarkzoneMainOpenDoorDialog, root)
  self:InitBaseData(root)
  self:InitUI(data)
  self:AddBtnListen()
  self:AddMsgListener()
end
function DarkzoneMainOpenDoorDialog:InitBaseData(root)
  self.mview = DarkzoneMainOpenDoorDialogView.New()
  self.ui = {}
  self.mview:InitCtrl(root, self.ui)
  function self.CloseFun()
    self.mCSPanel.FadeOutTime = self.ui.mAniTime_Root.m_FadeOutTime
    self.mCSPanel.FadeOutTrigger = "FadeOut"
    UIManager.CloseUI(UIDef.DarkzoneMainOpenDoorDialog)
    self:ShowInteractiveButton()
  end
  function self.OpenFun()
    self.mCSPanel.FadeOutTime = 1.26
    self.mCSPanel.FadeOutTrigger = "Open_FadeOut"
    UIManager.CloseUI(UIDef.DarkzoneMainOpenDoorDialog)
    self.context:OpenDoor()
  end
end
function DarkzoneMainOpenDoorDialog:AddBtnListen()
  self.ui.mBtn_Close.onClick:AddListener(self.CloseFun)
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Close)
  self.ui.mBtn_Confirm.onClick:AddListener(self.OpenFun)
  self.ui.mBtn_Try.onClick:AddListener(self.OpenFun)
end
function DarkzoneMainOpenDoorDialog:ShowInteractiveButton()
end
function DarkzoneMainOpenDoorDialog:AddMsgListener()
end
function DarkzoneMainOpenDoorDialog:InitUI(data)
  self.context = data
  local commonCostItem = self.context:GetCost()[0]
  local itemId = commonCostItem.itemData.Id
  self.ui.mText_Title.text = self.context:GetTableCfg().name.str
  if itemId == EnumDarkzoneProperty.Property.DzEnergy1Now then
    setactive(self.ui.mImg_Red.gameObject, true)
    setactive(self.ui.mImg_Blue.gameObject, false)
  elseif itemId == EnumDarkzoneProperty.Property.DzEnergy2Now then
    setactive(self.ui.mImg_Red.gameObject, false)
    setactive(self.ui.mImg_Blue.gameObject, true)
  end
  local lowNeedNum = TableData.GlobalDarkzoneData.DzDoorOpenMinEnergy
  local enough = commonCostItem:CheckCostIsEnough()
  self.ui.mImg_EnergyBar.fillAmount = commonCostItem:GetNeedPercent()
  if enough then
    setactive(self.ui.mBtn_Confirm.gameObject, true)
    setactive(self.ui.mBtn_Try.gameObject, false)
    setactive(self.ui.mTran_Lock.gameObject, false)
    setactive(self.ui.mText_LockText.transform.parent.gameObject, false)
    setactive(self.ui.mTran_UnLock.gameObject, true)
    setactive(self.ui.mTran_Warn.gameObject, false)
    self.ui.mText_EnergyNum.text = commonCostItem.currentValue .. "/" .. commonCostItem.needNum
    self.ui.mText_SuccessPercent.text = "100%"
  elseif lowNeedNum > commonCostItem.currentValue then
    setactive(self.ui.mBtn_Confirm.gameObject, false)
    setactive(self.ui.mBtn_Try.gameObject, true)
    self.ui.mBtn_Try.interactable = false
    setactive(self.ui.mTran_Lock.gameObject, true)
    setactive(self.ui.mText_LockText.transform.parent.gameObject, true)
    setactive(self.ui.mTran_UnLock.gameObject, false)
    setactive(self.ui.mTran_Warn.gameObject, false)
    self.ui.mText_EnergyNum.text = "<color=#ce4848>" .. commonCostItem.currentValue .. "</color>/" .. commonCostItem.needNum .. ""
    self.ui.mText_LockText.text = string_format(TableData.GetHintById(903451), lowNeedNum)
  else
    setactive(self.ui.mBtn_Confirm.gameObject, false)
    setactive(self.ui.mBtn_Try.gameObject, true)
    self.ui.mBtn_Try.interactable = true
    setactive(self.ui.mTran_Lock.gameObject, false)
    setactive(self.ui.mText_LockText.transform.parent.gameObject, false)
    setactive(self.ui.mTran_UnLock.gameObject, true)
    setactive(self.ui.mTran_Warn.gameObject, true)
    self.ui.mText_EnergyNum.text = "<color=#f26c1c>" .. commonCostItem.currentValue .. "</color>/" .. commonCostItem.needNum .. ""
    self.ui.mText_SuccessPercent.text = math.floor(commonCostItem:GetNeedPercent() * 100 * TableData.GlobalDarkzoneData.DzDoorChanceTrans) .. "%"
  end
end
function DarkzoneMainOpenDoorDialog:OnShowStart()
  if not self.context.VM:HasPickInterest() then
    self.mCSPanel.FadeOutTime = self.ui.mAniTime_Root.m_FadeOutTime
    self.mCSPanel.FadeOutTrigger = "FadeOut"
    UIManager.CloseUI(UIDef.DarkzoneMainOpenDoorDialog)
    return
  end
end
function DarkzoneMainOpenDoorDialog:OnClose()
  self:UnRegistrationKeyboard(nil)
  self.ui.mBtn_Close.onClick:RemoveListener(self.CloseFun)
  self.ui.mBtn_Confirm.onClick:RemoveListener(self.OpenFun)
  self.ui.mBtn_Try.onClick:RemoveListener(self.OpenFun)
  self.OpenFun = nil
  self.CloseFun = nil
  self.ui = nil
  self.mview = nil
  self.context = nil
end
