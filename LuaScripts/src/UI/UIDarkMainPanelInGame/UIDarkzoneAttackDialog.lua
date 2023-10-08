require("UI.UIDarkMainPanelInGame.UIDarkzoneAttackDialogView")
require("UI.UIBasePanel")
UIDarkzoneAttackDialog = class("UIDarkzoneAttackDialog", UIBasePanel)
UIDarkzoneAttackDialog.__index = UIDarkzoneAttackDialog
local itemMax = 3
function UIDarkzoneAttackDialog:ctor(csPanel)
  UIDarkzoneAttackDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
  csPanel.Is3DPanel = true
end
function UIDarkzoneAttackDialog:OnInit(root, data)
  UIDarkzoneAttackDialog.super.SetRoot(UIDarkzoneAttackDialog, root)
  self:InitBaseData()
  self.mview:InitCtrl(root, self.ui)
  self.data = data
end
function UIDarkzoneAttackDialog:OnShowStart()
  self.ui.mAni_AttackDialog:SetInteger("Switch", self.data.Item1)
  if self.data.Item1 == 0 then
    setactive(self.ui.mTran_AttackItemRoot.gameObject, true)
    if self.data.Item2 then
      self:AddAttackItem(1)
    end
    if self.data.Item3 then
      self:AddAttackItem(2)
    end
    if self.data.Item4 then
      self:AddAttackItem(3)
    end
  else
    setactive(self.ui.mTran_AttackItemRoot.gameObject, false)
  end
end
function UIDarkzoneAttackDialog:AddAttackItem(index)
  local itemUI
  if self.AttackItemLs[index] == nil then
    itemUI = AttackBenefitInfoItem.New()
    itemUI:InitCtrl(self.ui.mTran_AttackItemRoot, 2)
    self.AttackItemLs[index] = itemUI
  else
    itemUI = self.AttackItemLs[index]
  end
  itemUI:SetDetail(index, nil)
end
function UIDarkzoneAttackDialog:OnClose()
  self.ui = nil
  self.mview = nil
  for i = 1, itemMax do
    if self.AttackItemLs[i] ~= nil then
      self.AttackItemLs[i]:OnRelease()
    end
  end
  self.AttackItemLs = nil
end
function UIDarkzoneAttackDialog:InitBaseData()
  self.mview = UIDarkzoneAttackDialogView.New()
  self.ui = {}
  if self.AttackItemLs == nil then
    self.AttackItemLs = {}
  end
end
function UIDarkzoneAttackDialog:OnCameraStart()
  return 0.01
end
