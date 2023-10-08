CommandCenterTopBtn = class("CommandCenterTopBtn", UIBaseCtrl)
local self = CommandCenterTopBtn
function CommandCenterTopBtn:ctor()
  self.systemId = nil
  self.iconName = nil
end
function CommandCenterTopBtn:InitCtrl(parent, systemId, iconName)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  self.systemId = systemId
  self.iconName = iconName
  self:InitCommandCenterTopBtn()
end
function CommandCenterTopBtn:InitCommandCenterTopBtn()
  self.ui.mImg_CommandCenterTabIcon.sprite = IconUtils.GetCommandCenterIcon("Icon_CommandCenter_" .. self.iconName)
  local parent = self.mUIRoot
  if parent then
    self.systemId = self.systemId
    self.parent = parent
    self.transRedPoint = self.ui.mObj_RedPoint.transform.parent
    self.btn = self.ui.mBtn_CommandCenterTab3ItemV2
  end
end
function CommandCenterTopBtn:CheckUnLock()
  local unlock = AccountNetCmdHandler:CheckSystemIsUnLock(self.systemId)
  setactive(self.mUIRoot.gameObject, unlock)
end
function CommandCenterTopBtn:SetData()
end
function CommandCenterTopBtn:OnRelease()
  self:DestroySelf()
end
