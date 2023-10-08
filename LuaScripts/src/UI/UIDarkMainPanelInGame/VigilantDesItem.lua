require("UI.UIBaseCtrl")
VigilantDesItem = class("VigilantDesItem", UIBaseCtrl)
VigilantDesItem.__index = VigilantDesItem
function VigilantDesItem:InitCtrl(root, childItem)
  self.obj = instantiate(childItem)
  if root then
    CS.LuaUIUtils.SetParent(self.obj.gameObject, root.gameObject, false)
  end
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
end
function VigilantDesItem:SetDetail(desName)
  setactive(self.obj.gameObject, true)
  self.ui.mText_InfoName.text = desName
end
function VigilantDesItem:Close()
  setactive(self.obj.gameObject, false)
end
function VigilantDesItem:OnRelease()
  self.ui = nil
  self.obj = nil
end
