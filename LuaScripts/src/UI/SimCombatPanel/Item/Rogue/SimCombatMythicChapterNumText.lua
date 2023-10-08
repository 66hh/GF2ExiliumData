require("UI.UIBaseCtrl")
SimCombatMythicChapterNumText = class("SimCombatMythicChapterNumText", UIBaseCtrl)
local self = SimCombatMythicChapterNumText
function SimCombatMythicChapterNumText:ctor()
end
function SimCombatMythicChapterNumText:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
end
function SimCombatMythicChapterNumText:SetData(num)
  num = AddZeroFrontNum(2, num)
  self.ui.mText_Num.text = num
end
function SimCombatMythicChapterNumText:OnRelease()
  self:DestroySelf()
end
