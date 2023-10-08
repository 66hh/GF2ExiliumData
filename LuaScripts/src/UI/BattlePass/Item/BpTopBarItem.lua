require("UI.UIBaseCtrl")
BpTopBarItem = class("BpTopBarItem", UIBaseCtrl)
BpTopBarItem.__index = BpTopBarItem
function BpTopBarItem:__InitCtrl()
end
function BpTopBarItem:InitCtrl(parent)
  self.obj = instantiate(UIUtils.GetGizmosPrefab("BattlePass/Btn_BpTopBarItemV3.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(self.obj.gameObject, parent.gameObject, false)
  end
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  self:SetRoot(self.obj.transform)
  self:__InitCtrl()
end
function BpTopBarItem:SetData(index, callBack)
  self.ui.mText_Name.text = TableData.GetHintById(UIBattlePassGlobal.ButtonTypeHintText[index])
  UIUtils.GetButtonListener(self.ui.mBtn_ChrBarrackTopBarItemV3.gameObject).onClick = function()
    if callBack then
      callBack()
    end
  end
  self.ui.mAnimator_ChrBarrackTopBarItemV3:SetBool("Unlock", true)
end
function BpTopBarItem:SetInteractable(interactable)
  self.ui.mBtn_ChrBarrackTopBarItemV3.interactable = interactable
end
function BpTopBarItem:SetGlobalTab(globalTabId)
  self.globalTab = GetOrAddComponent(self:GetRoot().gameObject, (typeof(GlobalTab)))
  self.globalTab:SetGlobalTabId(globalTabId)
end
function BpTopBarItem:GetGlobalTab()
  return self.globalTab
end
function BpTopBarItem:OnRelease()
  gfdestroy(self.obj)
end
function BpTopBarItem:UpdateRedPoint(show)
  setactive(self.ui.mTrans_RedPoint, show)
end
