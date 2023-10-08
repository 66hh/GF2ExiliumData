UIDarkZoneQuestBtnItem = class("UIDarkZoneQuestBtnItem", UIBaseCtrl)
UIDarkZoneQuestBtnItem.__index = UIDarkZoneQuestBtnItem
function UIDarkZoneQuestBtnItem:ctor()
end
function UIDarkZoneQuestBtnItem:InitCtrl(prefab, parent)
  local obj = instantiate(prefab, parent)
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self.callback = nil
  self.curLevelType = 0
end
function UIDarkZoneQuestBtnItem:SetData(callback, levelType)
  self.callback = callback
  self.curLevelType = levelType
  UIUtils.GetButtonListener(self.ui.mBtn_Level).onClick = function()
    self:callback(self.curLevelType)
  end
end
