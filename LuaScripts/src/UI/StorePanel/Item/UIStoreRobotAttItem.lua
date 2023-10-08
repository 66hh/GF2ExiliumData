require("UI.UIBaseCtrl")
UIStoreRobotAttItem = class("UIStoreRobotAttItem", UIBaseCtrl)
UIStoreRobotAttItem.__index = UIStoreRobotAttItem
function UIStoreRobotAttItem:InitCtrl(obj, parent)
  local Insobj = instantiate(obj, parent)
  self.ui = {}
  self:LuaUIBindTable(Insobj, self.ui)
  self:SetRoot(Insobj.transform)
  setactive(Insobj, true)
  self.mData = nil
end
function UIStoreRobotAttItem:SetData(data)
  self.mData = data
  self.ui.mText_SkillName.text = self.mData.Name.str
  self.ui.mText_Desc.text = self.mData.Description.str
  self.ui.mImg_Skill.sprite = IconUtils.GetSkillIconSprite(self.mData.Icon)
end
function UIStoreRobotAttItem:OnRelease()
end
