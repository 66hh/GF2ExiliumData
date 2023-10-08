require("UI.UIBaseCtrl")
require("UI.DarkZonePanel.UIDarkZoneSeasonQuestPanel.Item.UIDarkZoneSeasonSettlementDescItem")
UIDarkZoneSeasonSettlementItem = class("UIDarkZoneSeasonSettlementItem", UIBaseCtrl)
UIDarkZoneSeasonSettlementItem.__index = UIDarkZoneSeasonSettlementItem
function UIDarkZoneSeasonSettlementItem:__InitCtrl()
end
function UIDarkZoneSeasonSettlementItem:InitCtrl(root)
  local itemPrefab = root:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self:SetRoot(instObj.transform)
  if root then
    CS.LuaUIUtils.SetParent(instObj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.descItemList = {}
  self.isActive = false
  self.curNum = 0
  self.maxNum = 0
  self.playItemIndex = 0
  self.barLength = self.ui.mTrans_Bar.rect.width
end
function UIDarkZoneSeasonSettlementItem:SetData(data, questType)
  self.ui.mText_Title.text = TableData.listDarkzoneSeasonQuestTypeDatas:GetDataById(questType).type.str
  for i = 1, #data do
    local d = data[i]
    if self.descItemList[i] == nil then
      self.descItemList[i] = UIDarkZoneSeasonSettlementDescItem.New()
      self.descItemList[i]:InitCtrl(self.ui.mTrans_Content)
    end
    self.descItemList[i]:SetData(d)
    self.descItemList[i]:SetActive(false)
    self.descItemList[i]:SetFunction(function()
      self:SetItem()
      self:StartPlay()
    end)
    self.descItemList[i]:SetStartPlayFunction(function()
      self:ChangeScroll()
    end)
  end
end
function UIDarkZoneSeasonSettlementItem:StartPlay()
  if self.isActive == false then
    self:SetActive(true)
    self:SetProgress()
    self.isActive = true
  end
  self.playItemIndex = self.playItemIndex + 1
  if self.playItemIndex <= #self.descItemList then
    self.descItemList[self.playItemIndex]:StartPlay()
  else
    self:DelayCall(0.3, function()
      self.finishCallBack()
    end)
  end
end
function UIDarkZoneSeasonSettlementItem:SetFunction(func)
  self.callBack = func
end
function UIDarkZoneSeasonSettlementItem:SetStartFunction(func)
  self.startPlayCallBack = func
end
function UIDarkZoneSeasonSettlementItem:SetFinishFunction(func)
  self.finishCallBack = func
end
function UIDarkZoneSeasonSettlementItem:InvokeCallBack(param)
  if self.callBack then
    self.callBack(param)
  end
end
function UIDarkZoneSeasonSettlementItem:ChangeScroll()
  if self.listTween then
    LuaDOTweenUtils.Kill(self.listTween, false)
  end
  local getter = function(tempSelf)
    return tempSelf.ui.mVirtualListEx_List.verticalNormalizedPosition
  end
  local setter = function(tempSelf, value)
    tempSelf.ui.mVirtualListEx_List.verticalNormalizedPosition = value
  end
  self.listTween = LuaDOTweenUtils.ToOfFloat(self, getter, setter, 0, 0.3, nil)
end
function UIDarkZoneSeasonSettlementItem:SetItem()
  local item = self.descItemList[self.playItemIndex]
  self:InvokeCallBack(item.mData)
end
function UIDarkZoneSeasonSettlementItem:SetProgress()
  self.ui.mText_Progress.text = "0%"
  local num = #self.descItemList
  local n = num / self.maxNum
  if self.progressTween then
    LuaDOTweenUtils.Kill(self.progressTween, false)
  end
  local getter = function(tempSelf)
    return 0
  end
  local setter = function(tempSelf, value)
    tempSelf.ui.mText_Progress.text = math.floor(value * 100) .. "%"
    tempSelf.ui.mTrans_Add.sizeDelta = Vector2(value * tempSelf.barLength, tempSelf.ui.mTrans_Add.sizeDelta.y)
  end
  self.progressTween = LuaDOTweenUtils.ToOfFloat(self, getter, setter, n, 1, nil)
end
function UIDarkZoneSeasonSettlementItem:OnRelease()
  self.mData = nil
  self.curNum = nil
  self.maxNum = nil
  self.playItemIndex = nil
  self.barLength = nil
  self.ui = nil
  self.callBack = nil
  self.finishCallBack = nil
  self.startPlayCallBack = nil
  self.isActive = nil
  if self.progressTween then
    LuaDOTweenUtils.Kill(self.progressTween, false)
  end
  self.progressTween = nil
  if self.listTween then
    LuaDOTweenUtils.Kill(self.progressTween, false)
  end
  self.listTween = nil
  self.super.OnRelease(self, true)
end
