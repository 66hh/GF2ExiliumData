require("UI.UIBaseCtrl")
DarkzoneReliabilityDetailFuncTabItem = class("DarkzoneReliabilityDetailFuncTabItem", UIBaseCtrl)
DarkzoneReliabilityDetailFuncTabItem.__index = DarkzoneReliabilityDetailFuncTabItem
function DarkzoneReliabilityDetailFuncTabItem:__InitCtrl()
end
function DarkzoneReliabilityDetailFuncTabItem:InitCtrl(root)
  local obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComTabBtn1ItemV2.prefab", self))
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
function DarkzoneReliabilityDetailFuncTabItem:SetData(Data)
end
