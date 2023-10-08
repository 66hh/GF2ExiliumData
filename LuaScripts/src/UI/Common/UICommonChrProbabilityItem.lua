require("UI.UIBaseCtrl")
UICommonChrProbabilityItem = class("UICommonChrProbabilityItem", UIBaseCtrl)
UICommonChrProbabilityItem.__index = UICommonChrProbabilityItem
function UICommonChrProbabilityItem:ctor()
  self.dutyData = nil
end
function UICommonChrProbabilityItem:__InitCtrl()
end
function UICommonChrProbabilityItem:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComChrProbabilityItem.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, true)
  end
  self:SetRoot(obj.transform)
  self:__InitCtrl()
  self.ui = {}
  self:LuaUIBindTable(obj.transform, self.ui)
end
function UICommonChrProbabilityItem:SetData(name, num)
  self.ui.mText_Name.text = name
  self.ui.mText_Num.text = num
end
