require("UI.UIDarkZoneMapSelectPanel.MapSelectUtils")
require("UI.UIBaseCtrl")
DarkZoneMapSelectItem = class("DarkZoneMapSelectItem", UIBaseCtrl)
DarkZoneMapSelectItem.__index = DarkZoneMapSelectItem
function DarkZoneMapSelectItem:__InitCtrl()
end
function DarkZoneMapSelectItem:InitCtrl(root)
  local com = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
function DarkZoneMapSelectItem:SetData(Data, index, callback)
  setactive(self.ui.mTrans_Battle, false)
  setactive(self.ui.mTrans_Open, false)
  setactive(self.ui.mTrans_Lock, false)
  self.mIndex = index
  if MapSelectUtils.LastItemIndex ~= nil and MapSelectUtils.LastItemIndex ~= self.mIndex then
    self.ui.mBtn_Root.interactable = true
  elseif MapSelectUtils.LastItemIndex ~= nil and MapSelectUtils.LastItemIndex == self.mIndex then
    MapSelectUtils.LastBtn = self.ui.mBtn_Root
    self.ui.mBtn_Root.interactable = false
  end
  local condition0 = false
  local condition1 = false
  local condition2 = false
  local resetDay = 0
  local typeNum = 0
  UIUtils.GetButtonListener(self.ui.mBtn_Root.gameObject).onClick = function()
    if MapSelectUtils.LastBtn ~= nil then
      MapSelectUtils.LastBtn.interactable = true
    end
    MapSelectUtils.LastBtn = self.ui.mBtn_Root
    MapSelectUtils.LastItemIndex = self.mIndex
    self.ui.mBtn_Root.interactable = false
    self:SetMapInfo(Data)
    DarkNetCmdMatchData.MapId = Data.Id
    callback(Data, typeNum, resetDay)
  end
  self.ui.mText_Tittle.text = Data.name.str .. "/" .. Data.Id
end
function DarkZoneMapSelectItem:CheckTimeOpen()
end
function DarkZoneMapSelectItem:SetMapInfo(Data)
  MapSelectUtils.CurMapData = Data
end
