require("UI.UIBaseCtrl")
Btn_ActivityTourMapMarkSelectItem = class("Btn_ActivityTourMapMarkSelectItem", UIBaseCtrl)
Btn_ActivityTourMapMarkSelectItem.__index = Btn_ActivityTourMapMarkSelectItem
function Btn_ActivityTourMapMarkSelectItem:ctor()
end
function Btn_ActivityTourMapMarkSelectItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
    CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject, true)
  end
  self:SetRoot(instObj.transform)
  UIUtils.GetButtonListener(self.ui.mBtn_ActivityTourMapMarkSelectItem.gameObject).onClick = function()
    self.isSelect = not self.isSelect
    self:UpdateSelectAni()
  end
  self.hintIdList = {
    270194,
    270193,
    270196,
    270195
  }
end
function Btn_ActivityTourMapMarkSelectItem:UpdateSelectAni()
  setactive(self.ui.mTrans_Sel.gameObject, self.isSelect)
  self.parent:UpdateToggleState(self.index, self.isSelect)
end
function Btn_ActivityTourMapMarkSelectItem:SetData(index, parent, isSelect)
  self.index = index
  self.parent = parent
  self.isSelect = isSelect
  self:UpdateSelectAni()
  self.ui.mText_Title.text = TableData.GetHintById(self.hintIdList[index])
end
