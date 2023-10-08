require("UI.UIBaseCtrl")
ComChrUAVSkillInfoItem = class("ComChrUAVSkillInfoItem", UIBaseCtrl)
local self = ComChrUAVSkillInfoItem
function ComChrUAVSkillInfoItem:ctor()
end
function ComChrUAVSkillInfoItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
end
function ComChrUAVSkillInfoItem:SetItemName(text)
  self.ui.mText_UAVSkillItemName.text = text
end
function ComChrUAVSkillInfoItem:SetSelected(enable)
  self.ui.mBtn_ComChrUAVSkillInfoItem.interactable = not enable
end
function ComChrUAVSkillInfoItem:OnRelease()
  gfdestroy(self.mUIRoot.gameObject)
  self.super.OnRelease(self)
end
