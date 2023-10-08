require("UI.UIBaseCtrl")
UIDarkZoneQuestInfoBtnItem = class("UIDarkZoneQuestInfoBtnItem", UIBaseCtrl)
UIDarkZoneQuestInfoBtnItem.__index = UIDarkZoneQuestInfoBtnItem
function UIDarkZoneQuestInfoBtnItem:ctor()
end
function UIDarkZoneQuestInfoBtnItem:__InitCtrl()
end
function UIDarkZoneQuestInfoBtnItem:InitCtrl(obj, parent, SlibingIndex)
  local instantObj = instantiate(obj)
  CS.LuaUIUtils.SetParent(instantObj.gameObject, parent.gameObject)
  self:SetRoot(instantObj.transform)
  self.ui = {}
  self.slibingIndex = SlibingIndex
  self:LuaUIBindTable(instantObj, self.ui)
  self.ui.mText_Text.text = ""
  self.pos = 0
  self.itemList = nil
  self.isFinish = true
  self.anim = nil
  self.Distance = 0
  self.isLock = true
  self.virtualList = nil
end
function UIDarkZoneQuestInfoBtnItem:SetBtnData(x, i, itemList, distance, isLock, virtualList)
  self.ui.mText_Text.text = TableData.listDarkzoneQuestBundleDatas:GetDataById(100 + i).name.str
  self.isLock = isLock
  self.Distance = distance
  self.pos = x
  self.itemList = itemList
  self.virtualList = virtualList
  UIUtils.GetButtonListener(self.ui.mBtn_Item.gameObject).onClick = function()
    self:TransSlide()
  end
end
function UIDarkZoneQuestInfoBtnItem:TransSlide()
  if not CS.LuaUtils.IsNullOrDestroyed(self.virtualList) then
    self.virtualList.decelerationRate = 0
  else
    gfdebug("virtualList is null! G")
  end
  self.isFinish = false
  for i = 1, #self.itemList do
    self.itemList[i].ui.mBtn_Item.interactable = true
  end
  self.anim = LuaDOTweenUtils.SetTransformSlide(self.slibingIndex, Vector2(self.pos, self.slibingIndex.anchoredPosition.y), function()
    self.isFinish = true
    if not CS.LuaUtils.IsNullOrDestroyed(self.virtualList) then
      self.virtualList.decelerationRate = 0.135
      self.virtualList.velocity = vector2zero
    else
      gfdebug("virtualList is null! onCompelete")
    end
  end)
  self.ui.mBtn_Item.interactable = false
end
