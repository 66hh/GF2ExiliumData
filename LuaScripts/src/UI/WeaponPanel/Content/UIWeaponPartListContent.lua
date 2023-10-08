require("UI.UIBaseCtrl")
UIWeaponPartListContent = class("UIWeaponPartListContent", UIBaseCtrl)
UIWeaponPartListContent.__index = UIWeaponPartListContent
function UIWeaponPartListContent:ctor()
  self.filtrateList = {}
  self.filtrateContent = nil
  self.weaponPartDropList = nil
  self.pointer = nil
  self.ui = {}
end
function UIWeaponPartListContent:OnClose()
  self.filtrateContent:OnRelease()
  self:ReleaseCtrlTable(self.filtrateList, true)
  self:ReleaseCtrlTable(self.weaponPartDropList, true)
end
function UIWeaponPartListContent:__InitCtrl()
  self:LuaUIBindTable(self.mUIRoot, self.ui)
end
function UIWeaponPartListContent:InitCtrl(obj)
  self:SetRoot(obj.transform)
  self:__InitCtrl()
  self:InitSortContent()
  self:InitDropWeaponTypeList()
end
function UIWeaponPartListContent:InitSortContent()
  if self.filtrateContent == nil then
    self.filtrateContent = UIWeaponSortItem.New()
    self.filtrateContent:InitCtrl(self.ui.mTrans_BtnScreen, true)
    setactive(self.filtrateContent.mBtn_TypeScreen.gameObject, false)
    UIUtils.GetButtonListener(self.filtrateContent.mBtn_Sort.gameObject).onClick = function()
      self:OnClickSortList()
    end
  end
  local sortList = self:InstanceUIPrefab("UICommonFramework/ComScreenDropdownListItemV2.prefab", self.ui.mTrans_SortList)
  local parent = UIUtils.GetRectTransform(sortList, "Content")
  for i = 1, 3 do
    local item = UIBarrackSuitDropdownItem.New()
    item:InitCtrl(parent)
    table.insert(self.filtrateList, item)
  end
  UIUtils.GetUIBlockHelper(self.mUIRoot.parent, self.ui.mTrans_SortList, function()
    self:CloseItemSort()
  end)
end
function UIWeaponPartListContent:InitDropWeaponTypeList()
  UIUtils.GetButtonListener(self.ui.mBtn_TypeScreen.gameObject).onClick = function()
    self:OnClickTypeList()
  end
  local sortList = self:InstanceUIPrefab("UICommonFramework/ComScreenDropdownListItemV2.prefab", self.ui.mTrans_DropTypeList)
  local parent = UIUtils.GetRectTransform(sortList, "Content")
  if self.weaponPartDropList == nil then
    self.weaponPartDropList = {}
    local list = UIWeaponGlobal:GetWeaponPartTypeList()
    for i = 0, #list do
      local item
      if i == 0 then
        item = UIBarrackSuitDropdownItem.New()
        item:InitCtrl(parent)
        item:SetWeaponPartTypeData(0)
      else
        local data = list[i]
        item = UIBarrackSuitDropdownItem.New()
        item:InitCtrl(parent)
        item:SetWeaponPartTypeData(data.id)
      end
      table.insert(self.weaponPartDropList, item)
    end
  end
  UIUtils.GetUIBlockHelper(self.mUIRoot.parent, self.ui.mTrans_DropTypeList, function()
    self:CloseItemType()
  end)
end
function UIWeaponPartListContent:OnClickSortList()
  setactive(self.ui.mTrans_SortList, true)
end
function UIWeaponPartListContent:OnClickTypeList()
  setactive(self.ui.mTrans_DropTypeList, true)
end
function UIWeaponPartListContent:CloseItemSort()
  setactive(self.ui.mTrans_SortList, false)
end
function UIWeaponPartListContent:CloseItemType()
  setactive(self.ui.mTrans_DropTypeList, false)
end
