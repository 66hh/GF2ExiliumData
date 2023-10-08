require("UI.UIBaseCtrl")
UIWeaponListContent = class("UIWeaponListContent", UIBaseCtrl)
UIWeaponListContent.__index = UIWeaponListContent
function UIWeaponListContent:ctor()
  self.filtrateList = {}
  self.filtrateContent = nil
  self.weaponDropList = nil
  self.pointer = nil
  self.ui = {}
end
function UIWeaponListContent:__InitCtrl()
  self:LuaUIBindTable(self.mUIRoot, self.ui)
end
function UIWeaponListContent:InitCtrl(obj)
  self:SetRoot(obj.transform)
  self:__InitCtrl()
  self:InitSortContent()
  self:InitDropWeaponTypeList()
end
function UIWeaponListContent:InitSortContent()
  if self.filtrateContent == nil then
    self.filtrateContent = UIWeaponSortItem.New()
    self.filtrateContent:InitCtrl(self.ui.mTrans_Sort, true)
    setactive(self.filtrateContent.mBtn_TypeScreen.gameObject, false)
    UIUtils.GetButtonListener(self.filtrateContent.mBtn_Sort.gameObject).onClick = function()
      self:OnClickSortList()
    end
  end
  local sortList = self:InstanceUIPrefab("UICommonFramework/ComScreenDropdownListItemV2.prefab", self.ui.mTrans_SortList)
  self.sortListObj1 = sortList
  local parent = UIUtils.GetRectTransform(sortList, "Content")
  for i = 1, 4 do
    local item = UIBarrackSuitDropdownItem.New()
    item:InitCtrl(parent)
    table.insert(self.filtrateList, item)
  end
  UIUtils.GetUIBlockHelper(self.mUIRoot.parent, self.ui.mTrans_SortList, function()
    self:CloseItemSort()
  end)
end
function UIWeaponListContent:InitDropWeaponTypeList()
  UIUtils.GetButtonListener(self.ui.mBtn_TypeList.gameObject).onClick = function()
    self:OnClickTypeList()
  end
  local sortList = self:InstanceUIPrefab("UICommonFramework/ComScreenDropdownListItemV2.prefab", self.ui.mTrans_DropTypeList)
  self.sortListObj2 = sortList
  local parent = UIUtils.GetRectTransform(sortList, "Content")
  if self.weaponDropList == nil then
    self.weaponDropList = {}
    local list = UIWeaponGlobal:GetWeaponTypeList()
    for i = 0, #list do
      local item
      if i == 0 then
        item = UIBarrackSuitDropdownItem.New()
        item:InitCtrl(parent)
        item:SetWeaponTypeData(0)
      else
        local data = list[i]
        item = UIBarrackSuitDropdownItem.New()
        item:InitCtrl(parent)
        item:SetWeaponTypeData(data.type_id)
      end
      self.weaponDropList[i] = item
    end
  end
  UIUtils.GetUIBlockHelper(self.mUIRoot.parent, self.ui.mTrans_DropTypeList, function()
    self:CloseItemType()
  end)
end
function UIWeaponListContent:OnClickSortList()
  setactive(self.ui.mTrans_SortList, true)
end
function UIWeaponListContent:OnClickTypeList()
  setactive(self.ui.mTrans_DropTypeList, true)
end
function UIWeaponListContent:CloseItemSort()
  setactive(self.ui.mTrans_SortList, false)
end
function UIWeaponListContent:CloseItemType()
  setactive(self.ui.mTrans_DropTypeList, false)
end
function UIWeaponListContent:OnClose()
  if self.sortListObj1 then
    gfdestroy(self.sortListObj1.gameObject)
  end
  if self.sortListObj2 then
    gfdestroy(self.sortListObj2.gameObject)
  end
end
