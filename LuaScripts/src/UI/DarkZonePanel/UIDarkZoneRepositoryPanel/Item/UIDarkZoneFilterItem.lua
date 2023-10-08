require("UI.UIBaseCtrl")
UIDarkZoneFilterItem = class("UIDarkZoneFilterItem", UIBaseCtrl)
UIDarkZoneFilterItem.__index = UIDarkZoneFilterItem
function UIDarkZoneFilterItem:ctor()
end
function UIDarkZoneFilterItem:__InitCtrl()
end
function UIDarkZoneFilterItem:InitObj(obj, callBack)
  self.callBack = callBack
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(obj.transform, self.ui)
  self:__InitCtrl()
  self.filterList = {}
  for i = 0, 7 do
    local obj = self:InstanceUIPrefab("Character/ChrEquipSuitDropdownItemV2.prefab", self.ui.mTrans_Content)
    if obj then
      local filter = {}
      filter.obj = obj
      filter.data = i
      self:LuaUIBindTable(obj, filter)
      filter.mImg_Icon.sprite = ResSys:GetUIResAIconSprite("Darkzone" .. "/" .. "icon_Darkzone_Equip_" .. i .. ".png")
      filter.mText_SuitName.text = TableData.GetHintById(903171 + i)
      if i == 7 then
        filter.mText_SuitName.text = TableData.GetHintById(903376)
      end
      setactive(filter.mTrans_Icon, true)
      UIUtils.GetButtonListener(filter.mBtn_Select.gameObject).onClick = function()
        self:OnClickElement(filter)
      end
      if i == 0 then
        self:SetSelected(filter, true)
        self.curFilter = filter
      end
      table.insert(self.filterList, filter)
    end
  end
end
function UIDarkZoneFilterItem:OnClickElement(item)
  if item then
    if self.curFilter and self.curFilter.data ~= item.data then
      self:SetSelected(self.curFilter, false)
    end
    self.curFilter = item
    self:SetSelected(self.curFilter, true)
    self.callBack()
  end
end
function UIDarkZoneFilterItem:SetSelected(filter, selected)
  if selected then
    filter.mText_SuitName.color = filter.textColor.AfterSelected
    filter.mImg_Icon.color = filter.textColor.ImgBeforeSelected
  else
    filter.mText_SuitName.color = filter.textColor.BeforeSelected
    filter.mImg_Icon.color = filter.textColor.ImgBeforeSelected
  end
  setactive(filter.mTrans_GrpSel, selected)
end
function UIDarkZoneFilterItem:Release()
  self.curFilter = nil
end
