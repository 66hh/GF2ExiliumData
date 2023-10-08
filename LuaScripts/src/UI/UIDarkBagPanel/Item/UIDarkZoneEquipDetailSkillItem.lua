require("UI.UIBaseCtrl")
UIDarkZoneEquipDetailSkillItem = class("UIDarkZoneEquipDetailSkillItem", UIBaseCtrl)
UIDarkZoneEquipDetailSkillItem.__index = UIDarkZoneEquipDetailSkillItem
function UIDarkZoneEquipDetailSkillItem:__InitCtrl()
end
function UIDarkZoneEquipDetailSkillItem:InitCtrl(root, gameObject)
  local obj = instantiate(gameObject)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self:SetActive(true)
end
function UIDarkZoneEquipDetailSkillItem:SetData(skillID)
  local skillData = TableData.listDzSkillDatas:GetDataById(skillID)
  self.ui.mText_SkillName.text = skillData.name.str
  self.ui.mText_SkillDesc.text = skillData.description.str
end
