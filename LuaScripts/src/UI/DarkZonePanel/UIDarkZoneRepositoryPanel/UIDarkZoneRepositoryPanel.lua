require("UI.DarkZonePanel.UIDarkZoneRepositoryPanel.UIDarkZoneRepositoryPanelView")
require("UI.UIBasePanel")
UIDarkZoneRepositoryPanel = class("UIDarkZoneRepositoryPanel", UIBasePanel)
UIDarkZoneRepositoryPanel.__index = UIDarkZoneRepositoryPanel
function UIDarkZoneRepositoryPanel:ctor(csPanel)
  UIDarkZoneRepositoryPanel.super.ctor(UIDarkZoneRepositoryPanel, csPanel)
  csPanel.Is3DPanel = true
  self.mCSPanel = csPanel
end
function UIDarkZoneRepositoryPanel:OnInit(root)
  self:SetRoot(root)
  self.ui = {}
  self.mView = UIDarkZoneRepositoryPanelView.New()
  self.mView:InitCtrl(root, self.ui)
  self:AddBtnListener()
end
function UIDarkZoneRepositoryPanel:OnShowStart()
  local index = self.index == nil and 0 or self.index
  if self.index == index and self.index == 0 then
    return
  end
  index = 1
  self.index = index
  self:ChangeView(index)
end
function UIDarkZoneRepositoryPanel:OnShowFinish()
end
function UIDarkZoneRepositoryPanel:OnHide()
end
function UIDarkZoneRepositoryPanel:OnUpdate(deltaTime)
end
function UIDarkZoneRepositoryPanel.Close()
end
function UIDarkZoneRepositoryPanel:OnClose()
  self.mCSPanel.FadeOutTime = 0.01
  self.ui.mAnimator_Root:SetTrigger("ComPage_FadeOut")
  self.ui.mAnimator_Root:SetTrigger("FadeOut")
  self.ui = nil
  self.mView = nil
  self.index = nil
  if self.mMaintenancePanel then
    self.mMaintenancePanel:Close()
  end
  self.leftContentShow = nil
  if self.mEquipPanel then
    self.mEquipPanel:Close()
  end
  if self.mMaintenancePanel then
    self.mMaintenancePanel:Release()
  end
  self.mMaintenancePanel = nil
  if self.mEquipPanel then
    self.mEquipPanel:Release()
  end
  self.mEquipPanel = nil
end
function UIDarkZoneRepositoryPanel:OnRelease()
end
function UIDarkZoneRepositoryPanel:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIDarkZoneRepositoryPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
end
function UIDarkZoneRepositoryPanel:ChangeView(index)
  self.index = index
  setactive(self.ui.mTrans_1, index == 1)
  self.ui.mAnimator_Root:SetInteger("Switch", index)
  if index == 1 then
    self.ui.mText_Title.text = TableData.GetHintById(903153)
    if self.mEquipPanel == nil then
      self.mEquipPanel = UIDarkZoneSubEquipPanel
      self.mEquipPanel:InitCtrl(self.ui.mTrans_1, self)
    else
      self.mEquipPanel:ShowBriefLeft(false)
      self.mEquipPanel:ShowBriefRight(false)
      self.mEquipPanel.comScreenItem:OnCloseFilterBtnClick()
      self.mEquipPanel:SetEquipDict()
    end
  else
  end
end
function UIDarkZoneRepositoryPanel:OnCameraStart()
  return 0.01
end
function UIDarkZoneRepositoryPanel:OnCameraBack()
  return 0.01
end
