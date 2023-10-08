CommandCenterBottomBtn = class("CommandCenterBottomBtn", UIBaseCtrl)
local self = CommandCenterBottomBtn
function CommandCenterBottomBtn:ctor()
  self.systemId = 0
end
function CommandCenterBottomBtn:InitCtrl(btn, systemId)
  self.mUIRoot = btn
  self.systemId = systemId
  self:InitCommandCenterBottomBtn()
end
function CommandCenterBottomBtn:InitCommandCenterBottomBtn()
  local parent = self.mUIRoot
  if parent then
    self.systemId = self.systemId
    self.parent = parent
    self.btn = self.mUIRoot.transform:GetComponent("Button")
    self.transRedPoint = UIUtils.GetRectTransform(self.mUIRoot.transform, "Root/Trans_RedPoint")
    self.animator = self.mUIRoot:GetComponent("Animator")
  end
end
function CommandCenterBottomBtn:SetData()
end
function CommandCenterBottomBtn:OnRelease()
  self:DestroySelf()
end
