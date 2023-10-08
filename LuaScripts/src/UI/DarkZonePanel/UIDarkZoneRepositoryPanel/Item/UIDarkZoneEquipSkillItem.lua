require("UI.UIBaseCtrl")
UIDarkZoneEquipSkillItem = class("UIDarkZoneEquipSkillItem", UIBaseCtrl)
UIDarkZoneEquipSkillItem.__index = UIDarkZoneEquipSkillItem
function UIDarkZoneEquipSkillItem:ctor()
end
function UIDarkZoneEquipSkillItem:__InitCtrl()
end
function UIDarkZoneEquipSkillItem:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("Character/ChrEquipSkillItemV2.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
  end
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(obj.transform, self.ui)
  self:__InitCtrl()
end
function UIDarkZoneEquipSkillItem:SetData(data)
  self.ui.mText_Name.text = data.name.str
  setactive(self.ui.mTrans_GrpNum, false)
  self.ui.mText_Describe.text = data.description.str
end
