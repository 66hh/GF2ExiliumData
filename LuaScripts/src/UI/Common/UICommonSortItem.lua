require("UI.UIBaseCtrl")
require("UI.Common.UICommonSortContentItem")
UICommonSortItem = class("UICommonSortItem", UIBaseCtrl)
UICommonSortItem.__index = UICommonSortItem
UICommonSortItem.itemList = {}
function UICommonSortItem:ctor()
end
function UICommonSortItem:__InitCtrl()
end
function UICommonSortItem:InitCtrl(parent, buttonParent, isWhite, uiRoot, callback, nameList)
  self.callback = callback
  self.nameList = nameList
  local obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComScreenDropdownListItemV2.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
    self.parent = parent
  end
  self.ui = {}
  if isWhite ~= nil then
    local btnObj
    if isWhite then
      btnObj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComScreenItemV2_W.prefab", self))
    else
      btnObj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComScreenItemV2.prefab", self))
    end
    if buttonParent then
      CS.LuaUIUtils.SetParent(btnObj.gameObject, buttonParent.gameObject, false)
    end
    self:LuaUIBindTable(btnObj, self.ui)
  else
    self:LuaUIBindTable(buttonParent, self.ui)
  end
  self:LuaUIBindTable(obj, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Ascend.gameObject).onClick = function()
    self:OnAscend()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Sort.gameObject).onClick = function()
    self:OnDropDown()
  end
  UIUtils.GetUIBlockHelper(uiRoot, self.parent, function()
    self:OnScreenClose()
  end)
  for i = 1, 3 do
    do
      local item = UICommonSortContentItem.New()
      item:InitCtrl(self.ui.mTrans_Content)
      item:SetData(i, nameList[i])
      table.insert(self.itemList, item)
      UIUtils.GetButtonListener(item.ui.mBtn_Select.gameObject).onClick = function()
        self:OnClickSort(item.sortId)
      end
    end
  end
end
function UICommonSortItem:OnDropDown()
  self:OnScreen(not self.isSortDropDownActive)
end
function UICommonSortItem:OnAscend()
  self.isAscend = not self.isAscend
  self:UpdateSortList(self.curSort)
end
function UICommonSortItem:OnScreenClose()
  self:OnScreen(false)
end
function UICommonSortItem:OnScreen(isOn)
  self.isSortDropDownActive = isOn
  setactive(self.parent, isOn)
end
function UICommonSortItem:ResetItemListSort()
  local defaultSort = UIRepositoryGlobal.SortType.Level
  self.isAscend = false
  self:OnClickSort(defaultSort)
end
function UICommonSortItem:OnClickSort(id)
  self.curSort = id
  for i = 1, #self.itemList do
    local item = self.itemList[i]
    if item.sortId == id then
      item.ui.mText_SuitName.color = item.textColor.AfterSelected
      setactive(item.ui.mTrans_GrpSel, true)
    else
      item.ui.mText_SuitName.color = item.textColor.BeforeSelected
      setactive(item.ui.mTrans_GrpSel, false)
    end
  end
  if self.nameList == nil then
    self.ui.mText_SortName.text = TableData.GetHintById(53 + id)
  else
    self.ui.mText_SortName.text = self.nameList[id]
  end
  self:OnScreenClose()
  self:UpdateSortList(self.curSort)
end
function UICommonSortItem:UpdateSortList(sortType)
  self.callback(sortType, self.isAscend)
end
function UICommonSortItem:Release()
  UICommonSortItem.itemList = {}
end
