UIPVPRankDialogTabItem = class("UIPVPRankDialogTabItem", UIBaseCtrl)
function UIPVPRankDialogTabItem:ctor()
end
function UIPVPRankDialogTabItem:InitCtrl(parent, data)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  self.index = data.index
  self.ui.mText_Name.text = TableData.GetHintById(130001 + self.index)
end
function UIPVPRankDialogTabItem:OnHandleClick(func)
  UIUtils.GetButtonListener(self.ui.mBtn_PVPRankDateItem.gameObject).onClick = function()
    func()
  end
end
function UIPVPRankDialogTabItem:OnRelease()
  UIUtils.GetButtonListener(self.ui.mBtn_PVPRankDateItem.gameObject).onClick = nil
  gfdestroy(self.mUIRoot)
  self.index = 0
  self.ui = nil
end
