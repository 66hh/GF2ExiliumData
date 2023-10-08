require("UI.UIBaseCtrl")
UIDarkZoneWishTabItem = class("UIDarkZoneWishTabItem", UIBaseCtrl)
UIDarkZoneWishTabItem.__index = UIDarkZoneWishTabItem
function UIDarkZoneWishTabItem:__InitCtrl()
end
function UIDarkZoneWishTabItem:InitCtrl(obj)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self.mData = nil
  self.itemData = nil
  UIUtils.GetButtonListener(self.ui.mBtn_Item.gameObject).onClick = function()
    local t = {}
    t.endlessId = self.endlessId
    t.index = self.index
    t.callback = self.callback
    t.selectItem = self.mData
    t.limitTime = self.limitTime
    t.typeID = self.typeID
    if self.clickCallback then
      self.clickCallback()
    end
    UIManager.OpenUIByParam(UIDef.UIDarkZoneWishItemSelectDialog, t)
  end
end
function UIDarkZoneWishTabItem:SetData(data)
  local hasItem = data ~= nil
  setactive(self.ui.mTrans_Item, hasItem == true)
  setactive(self.ui.mTrans_Add, hasItem == false)
  if hasItem then
    self.mData = data
    local itemID = self.mData.id
    self.itemData = TableData.GetItemData(itemID)
    self.ui.mText_Name.text = self.mData.name.str
    self.ui.mImg_Item.sprite = IconUtils.GetItemIconSprite(itemID)
    self.ui.mImg_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(self.itemData.Rank)
  else
    self.mData = nil
    self.itemData = nil
    self.ui.mText_Name.text = TableData.GetHintById(240074)
  end
end
function UIDarkZoneWishTabItem:SetCanWish(canWish)
  local hasItem = self.mData ~= nil
  setactive(self.ui.mTrans_None, hasItem == false and canWish == false)
  setactive(self.ui.mTrans_Add, hasItem == false and canWish == true)
end
function UIDarkZoneWishTabItem:SetRedDot(canShow)
  setactive(self.ui.mTrans_RedPoint, canShow == true)
end
function UIDarkZoneWishTabItem:SetLimitTime(time)
  self.limitTime = time
end
function UIDarkZoneWishTabItem:SetEndlessID(id)
  self.endlessId = id
end
function UIDarkZoneWishTabItem:SetIndexID(id)
  self.index = id
  self.typeID = id
  local num = 240070 + id - 1
  self.ui.mText_Title.text = TableData.GetHintById(num)
end
function UIDarkZoneWishTabItem:SetWishItemCallBack(func)
  self.callback = func
end
function UIDarkZoneWishTabItem:SetOnWishItemClickCallBack(func)
  self.clickCallback = func
end
function UIDarkZoneWishTabItem:OnRelease()
  self.ui = nil
  self.mData = nil
  self.limitTime = nil
  self.typeID = nil
  self.super.OnRelease(self, true)
end
