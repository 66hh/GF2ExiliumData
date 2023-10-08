require("UI.UIBaseCtrl")
UIDarkKillLogItem = class("UIDarkKillLogItem", UIBaseCtrl)
function UIDarkKillLogItem:ctor(parent, template)
  local go = UIUtils.InstantiateByTemplate(template, parent)
  self:SetRoot(go)
  self.ui = UIUtils.GetUIBindTable(go)
end
function UIDarkKillLogItem:SetData(name, avatarSprite)
  self.name = name
  self.avatarSprite = avatarSprite
end
function UIDarkKillLogItem:Refresh()
  self.ui.mText_Tittle.text = self.name
  self.ui.mImage_Avatar.sprite = self.avatarSprite
end
function UIDarkKillLogItem:OnRelease()
  self.name = nil
  self.avatarSprite = nil
end
