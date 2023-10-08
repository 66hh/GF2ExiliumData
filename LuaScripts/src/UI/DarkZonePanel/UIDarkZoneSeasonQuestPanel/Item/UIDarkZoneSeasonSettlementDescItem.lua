require("UI.UIBaseCtrl")
UIDarkZoneSeasonSettlementDescItem = class("UIDarkZoneSeasonSettlementDescItem", UIBaseCtrl)
UIDarkZoneSeasonSettlementDescItem.__index = UIDarkZoneSeasonSettlementDescItem
function UIDarkZoneSeasonSettlementDescItem:__InitCtrl()
end
function UIDarkZoneSeasonSettlementDescItem:InitCtrl(root)
  local itemPrefab = root:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self:SetRoot(instObj.transform)
  if root then
    CS.LuaUIUtils.SetParent(instObj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
end
function UIDarkZoneSeasonSettlementDescItem:SetData(data)
  self.mData = data
  self.ui.mText_Description.text = data.description.str
end
function UIDarkZoneSeasonSettlementDescItem:SetFunction(func)
  self.callBack = func
end
function UIDarkZoneSeasonSettlementDescItem:SetStartPlayFunction(func)
  self.playCallBack = func
end
function UIDarkZoneSeasonSettlementDescItem:InvokeCallBack(param)
  if self.callBack then
    self.callBack(param)
  end
end
function UIDarkZoneSeasonSettlementDescItem:InvokeStartPlayCallBack()
  if self.playCallBack then
    self.playCallBack()
  end
end
function UIDarkZoneSeasonSettlementDescItem:StartPlay()
  self:SetActive(true)
  self:DelayCall(0.1, function()
    self:InvokeStartPlayCallBack()
  end)
  self:DelayCall(0.4, function()
    self:InvokeCallBack()
  end)
end
function UIDarkZoneSeasonSettlementDescItem:OnRelease()
  self.mData = nil
  self.ui = nil
  self.callBack = nil
  self:ReleaseTimers()
  self.super.OnRelease(self, true)
end
