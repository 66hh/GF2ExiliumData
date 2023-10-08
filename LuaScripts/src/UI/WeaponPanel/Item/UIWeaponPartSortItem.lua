require("UI.UIBaseCtrl")
UIWeaponPartSortItem = class("UIWeaponPartSortItem", UIBaseCtrl)
UIWeaponPartSortItem.__index = UIWeaponPartSortItem
function UIWeaponPartSortItem:ctor()
  self.curSort = nil
  self.sortFunc = nil
end
function UIWeaponPartSortItem:__InitCtrl()
  self.mBtn_Sort = self:GetButton("Btn_Dropdown")
  self.mBtn_Ascend = self:GetButton("Btn_Screen")
  self.Btn_TypeScreen = self:GetButton("Btn_TypeScreen")
  self.mText_SortName = self:GetText("Btn_Dropdown/Text_SuitName")
end
function UIWeaponPartSortItem:InitCtrl(parent, useScrollListChild)
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
function UIWeaponPartSortItem:SetData(data)
  self.curSort = data
  self.mText_SortName.text = TableData.GetHintById(data.hintID)
  self.sortFunc = self:GetSortFunc(1, self.curSort.sortCfg, self.curSort.isAscend)
end
function UIWeaponPartSortItem:SetReplaceData(data)
  self.curSort = data
  self.mText_SortName.text = TableData.GetHintById(data.hintID)
  self.sortFunc = self:GetReplaceSortFunc(1, self.curSort.sortCfg, self.curSort.isAscend)
end
function UIWeaponPartSortItem:GetSortFunc(tabIndex, sortCfg, isAscend)
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
        if tArrRefer[index] == "type" then
          tValueA, tValueB = a1.type == 1 or false, a2.type == 1 or false
        end
        if tArrRefer[index] == "equipGun" then
          tValueA, tValueB = a1.equipGun > 0 or false, a2.equipGun > 0 or false
        end
        if tArrRefer[index] == "weaponId" then
          tValueA, tValueB = 0 < a1.weaponId or false, 0 < a2.weaponId or false
        end
        if tArrRefer[index] == "isLock" then
          tValueA, tValueB = a1.isLock == true or false, a2.isLock == true or false
        end
        if tValueA ~= nil and tValueB ~= nil then
          if tValueA ~= tValueB then
            if tValueA then
              return true
            else
              return false
            end
          else
            if a1.type == 1 and a2.type == 1 then
              return a1.id < a2.id
            end
            return compareFunction(a1, a2, index + 1)
          end
        end
        if a1[attrName] < a2[attrName] then
          return index == 1 and isAscend or true
        elseif a1[attrName] > a2[attrName] then
          return index == 1 and not isAscend or false
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
function UIWeaponPartSortItem:GetReplaceSortFunc(tabIndex, sortCfg, isAscend)
  isAscend = isAscend ~= false and true or false
  local tArrRefer = sortCfg
  local compareFunction = function(a1, a2, index)
    local attrName = tArrRefer[1]
    if a1[attrName] < a2[attrName] then
      return isAscend
    elseif a1[attrName] > a2[attrName] then
      return not isAscend
    else
      local tValueA, tValueB
      tValueA, tValueB = a1.type == 1 or false, a2.type == 1 or false
      if tValueA ~= tValueB then
        if tValueA then
          return true
        else
          return false
        end
      else
        tValueA, tValueB = a1.equipGun > 0 or false, a2.equipGun > 0 or false
        if tValueA ~= tValueB then
          if tValueA then
            return true
          else
            return false
          end
        else
          tValueA, tValueB = 0 < a1.weaponId or false, 0 < a2.weaponId or false
          if tValueA ~= tValueB then
            if tValueA then
              return true
            else
              return false
            end
          else
            tValueA, tValueB = a1.isLock == true or false, a2.isLock == true or false
            if tValueA ~= tValueB then
              if tValueA then
                return true
              else
                return false
              end
            elseif a1.fatherType == a2.fatherType then
              if a1.partType == a2.partType then
                if a1.suitId == a2.suitId then
                  return a1.id < a2.id
                else
                  return a1.suitId < a2.suitId
                end
              else
                return a1.partType < a2.partType
              end
            else
              return a1.fatherType < a2.fatherType
            end
          end
        end
      end
    end
  end
  return function(a1, a2)
    return compareFunction(a1, a2, tabIndex)
  end
end
