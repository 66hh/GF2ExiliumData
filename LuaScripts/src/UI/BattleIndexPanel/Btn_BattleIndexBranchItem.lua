require("UI.UIBaseCtrl")
Btn_BattleIndexBranchItem = class("Btn_BattleIndexBranchItem", UIBaseCtrl)
Btn_BattleIndexBranchItem.__index = Btn_BattleIndexBranchItem
function Btn_BattleIndexBranchItem:ctor()
end
function Btn_BattleIndexBranchItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
end
function Btn_BattleIndexBranchItem:SetData(data)
end
