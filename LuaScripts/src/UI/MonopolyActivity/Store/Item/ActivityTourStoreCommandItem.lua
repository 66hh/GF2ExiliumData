require("UI.UIBaseCtrl")
ActivityTourStoreCommandItem = class("ActivityTourStoreCommandItem", UIBaseCtrl)
ActivityTourStoreCommandItem.__index = ActivityTourStoreCommandItem
ActivityTourStoreCommandItem.ui = nil
ActivityTourStoreCommandItem.mData = nil
function ActivityTourStoreCommandItem:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function ActivityTourStoreCommandItem:InitCtrl(parent, refreshCallBack)
  local com = parent:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem, parent)
  self:SetRoot(obj.transform)
  self.ui = {}
  self.mData = nil
  self:LuaUIBindTable(obj, self.ui)
  function self.ui.mAniEvent_Refresh.onAnimationEvent()
    if refreshCallBack then
      refreshCallBack()
    end
  end
end
function ActivityTourStoreCommandItem:SetData(commandID, isSelSlot)
  local data = TableData.listMonopolyOrderDatas:GetDataById(commandID)
  if not data then
    return
  end
  setactive(self.ui.mImg_Icon.gameObject, true)
  self.ui.mImg_Icon.sprite = ActivityTourGlobal.GetActivityTourSprite(data.order_icon)
  if isSelSlot then
    self.ui.mAni_Root:Play()
  end
end
function ActivityTourStoreCommandItem:RefreshEmpty()
  setactive(self.ui.mImg_Icon.gameObject, false)
end
function ActivityTourStoreCommandItem:Release()
  self.ui.mAniEvent_Refresh.onAnimationEvent = nil
  self.super.OnRelease(self, true)
end
