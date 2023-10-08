require("UI.UIBaseCtrl")
UIWeaponSortItem = class("UIWeaponSortItem", UIBaseCtrl)
UIWeaponSortItem.__index = UIWeaponSortItem
function UIWeaponSortItem:ctor()
  self.curSort = nil
  self.sortFunc = nil
  self.curGunId = 0
end
function UIWeaponSortItem:__InitCtrl()
  self.mBtn_Sort = self:GetButton("Btn_Dropdown")
  self.mBtn_Ascend = self:GetButton("Btn_Screen")
  self.mText_SortName = self:GetText("Btn_Dropdown/Text_SuitName")
  self.mBtn_TypeScreen = self:GetButton("Btn_TypeScreen")
  setactive(self.mBtn_Ascend.gameObject, false)
end
function UIWeaponSortItem:InitCtrl(parent, useScrollListChild)
  local obj
  if useScrollListChild then
    local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
    obj = instantiate(itemPrefab.childItem)
  else
    obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComScreenItemV2.prefab", self))
  end
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
  end
  self:SetRoot(obj.transform)
  self:__InitCtrl()
end
function UIWeaponSortItem:SetReplaceData(data)
  self.curSort = data
  self.mText_SortName.text = TableData.GetHintById(data.hintID)
  self.sortFunc = self:GetReplaceSortFunc(1, self.curSort.sortCfg, self.curSort.isAscend)
end
function UIWeaponSortItem:SetEnhanceData(data)
  self.curSort = data
  self.mText_SortName.text = TableData.GetHintById(data.hintID)
  self.sortFunc = self:GetEnhanceSortFunc(1, self.curSort.sortCfg, self.curSort.isAscend)
end
function UIWeaponSortItem:SetFiltrateData(data)
  self.curSort = data
  self.mText_SortName.text = TableData.GetHintById(data.hintID)
end
function UIWeaponSortItem:SetGunId(id)
  self.curGunId = id
end
function UIWeaponSortItem:GetReplaceSortFunc(tabIndex, sortCfg, isAscend)
  isAscend = isAscend ~= false and true or false
  self.curGunId = self.curGunId ~= 0 and self.curGunId or 0
  local tArrRefer = sortCfg
  local tLength = #tArrRefer
  if tLength == 0 or tabIndex < 1 or tabIndex > tLength then
    return nil
  end
  local function compareFunction(a1, a2, index)
    if index <= tLength then
      local attrName = tArrRefer[index]
      if index <= tLength then
        local tValueA, tValueB
        if index == tabIndex then
          tValueA, tValueB = a1.gunId == self.curGunId or false, a2.gunId == self.curGunId or false
        end
        if tValueA ~= tValueB then
          if tValueA then
            return true
          else
            return false
          end
        end
        if index == tabIndex then
          tValueA, tValueB = a1.type == 1 or false, a2.type == 1 or false
        end
        if tValueA ~= tValueB then
          if tValueA then
            return true
          else
            return false
          end
        elseif tValueA and tValueB then
          return a1.id < a2.id
        end
        if a1[attrName] < a2[attrName] then
          return isAscend
        elseif a1[attrName] > a2[attrName] then
          return not isAscend
        else
          return compareFunction(a1, a2, index + 1)
        end
      else
        return false
      end
    end
    return false
  end
  return function(a1, a2)
    return compareFunction(a1, a2, tabIndex)
  end
end
function UIWeaponSortItem:GetEnhanceSortFunc(tabIndex, sortCfg, isAscend)
  isAscend = isAscend ~= false and true or false
  self.curGunId = self.curGunId ~= 0 and self.curGunId or 0
  local tArrRefer = sortCfg
  local tLength = #tArrRefer
  if tLength == 0 or tabIndex < 1 or tabIndex > tLength then
    return nil
  end
  local function compareFunction(a1, a2, index)
    if index <= tLength then
      local attrName = tArrRefer[index]
      if index <= tLength then
        local tValueA, tValueB
        if index == tabIndex then
          tValueA, tValueB = a1.isLock, a2.isLock
        end
        if tValueA ~= tValueB then
          if not tValueA then
            return true
          else
            return false
          end
        end
        if index == tabIndex then
          tValueA, tValueB = a1.type == 1 or false, a2.type == 1 or false
        end
        if tValueA ~= tValueB then
          if tValueA then
            return true
          else
            return false
          end
        elseif tValueA and tValueB then
          return a1.id < a2.id
        end
        if a1[attrName] < a2[attrName] then
          return isAscend
        elseif a1[attrName] > a2[attrName] then
          return not isAscend
        else
          return compareFunction(a1, a2, index + 1)
        end
      else
        return false
      end
    end
    return false
  end
  return function(a1, a2)
    return compareFunction(a1, a2, tabIndex)
  end
end
function UIWeaponSortItem:EnableSortAscend(enable)
  setactive(self.mBtn_Ascend.gameObject, enable)
end
