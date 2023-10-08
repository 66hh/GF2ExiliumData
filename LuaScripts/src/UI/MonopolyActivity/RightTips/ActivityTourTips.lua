require("UI.UIBaseCtrl")
require("UI.MonopolyActivity.RightTips.Item.ActivityTourNumberTipsItem")
require("UI.MonopolyActivity.RightTips.Item.ActivityTourMuseTipsItem")
ActivityTourTips = class("ActivityTourTips", UIBaseCtrl)
ActivityTourTips.__index = ActivityTourTips
ActivityTourTips.ui = nil
ActivityTourTips.mData = nil
function ActivityTourTips:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function ActivityTourTips:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("ActivityTour/ActivityTourTips.prefab", self), parent)
  self:SetRoot(obj.transform)
  self.ui = {}
  self.mData = nil
  self:LuaUIBindTable(obj, self.ui)
  self.listPointItem = {}
  self.listInspirationItem = {}
  self.listShowItem = {}
end
function ActivityTourTips:RefreshPoint(data)
  self:RefreshInternal(ActivityTourGlobal.NumberTip, self.listPointItem, data)
end
function ActivityTourTips:RefreshInspiration(data)
  self:RefreshInternal(ActivityTourGlobal.InspirationTip, self.listInspirationItem, data)
end
function ActivityTourTips:RefreshInternal(showType, listItem, data)
  if #self.listShowItem >= 2 then
    setactive(self.listShowItem[1].mUIRoot, false)
    if self.listShowItem[1].showType == ActivityTourGlobal.NumberTip then
      table.insert(self.listPointItem, self.listShowItem[1])
    else
      table.insert(self.listInspirationItem, self.listShowItem[1])
    end
    table.remove(self.listShowItem, 1)
  end
  local item
  local count = #listItem
  if 0 < count then
    item = listItem[count]
    table.remove(listItem, count)
    setactive(item.mUIRoot, false)
  else
    item = showType == ActivityTourGlobal.NumberTip and ActivityTourNumberTipsItem.New() or ActivityTourMuseTipsItem.New()
    local scrollListChild = showType == ActivityTourGlobal.NumberTip and self.ui.mScrollListChild_Number or self.ui.mScrollListChild_Muse
    item:InitCtrl(scrollListChild, self.ui.mTrans_Layout)
  end
  item.mUIRoot:SetAsFirstSibling()
  item:Refresh(data.Sender)
  setactive(item.mUIRoot, true)
  table.insert(self.listShowItem, item)
  self.pointsAniLength = item.ui.mRoot_Ani.clip.length
  if data.Content and showType == ActivityTourGlobal.InspirationTip then
    self:DelayCall(item.ui.mRoot_Ani.clip.length, function()
      data.Content()
    end)
  end
end
function ActivityTourTips:GetCurAniLength()
  if not self.pointsAniLength then
    return 0
  end
  return self.pointsAniLength
end
function ActivityTourTips:OnRelease()
  self.listPointItem = nil
  self.listShowItem = nil
  self.listInspirationItem = nil
  self:ReleaseTimers()
  self.super.OnRelease(self, true)
end
