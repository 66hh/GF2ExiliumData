require("UI.UIBaseCtrl")
UICommonSortContentItem = class("UICommonSortContentItem", UIBaseCtrl)
UICommonSortContentItem.__index = UICommonSortContentItem
function UICommonSortContentItem:ctor()
end
function UICommonSortContentItem:__InitCtrl()
end
function UICommonSortContentItem:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("Character/ChrEquipSuitDropDownItemV2.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
  end
  self.textColor = obj.transform:GetComponent(typeof(CS.TextImgColor))
  self.beforeColor = self.textColor.BeforeSelected
  self.afterColor = self.textColor.AfterSelected
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(obj.transform, self.ui)
  self:__InitCtrl()
end
function UICommonSortContentItem:SetData(id, name)
  self.sortId = id
  if name ~= nil then
    self.ui.mText_SuitName.text = name
  else
    self.ui.mText_SuitName.text = TableData.GetHintById(53 + id)
  end
  self.ui.mText_SuitNum.text = ""
  if id == 2 then
    self.ui.mText_SuitName.color = self.textColor.AfterSelected
    setactive(self.ui.mTrans_GrpSel, true)
  else
    self.ui.mText_SuitName.color = self.textColor.BeforeSelected
    setactive(self.ui.mTrans_GrpSel, false)
  end
end
function UICommonSortContentItem:SetSelected(selected)
  self.ui.mBtn_Select.interactable = not selected
end
