require("UI.UIBaseCtrl")
require("UI.DarkZonePanel.UIDarkZoneModePanel.UIDarkZoneEndlessPanel.Item.UIDarkZoneEndlessMissionItem")
UIDarkZoneEndlessItem = class("UIDarkZoneEndlessItem", UIBaseCtrl)
UIDarkZoneEndlessItem.__index = UIDarkZoneEndlessItem
function UIDarkZoneEndlessItem:__InitCtrl()
end
function UIDarkZoneEndlessItem:InitCtrl(root, parentPanel)
  if root == nil then
    return
  end
  self.parentPanel = parentPanel
  local itemPrefab = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(itemPrefab.childItem)
  CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self.mData = nil
  self.topTypeItemList = {}
  self.delayTime = 0.8
  self:OnInItUI()
  self:AddEventListener()
end
function UIDarkZoneEndlessItem:OnInItUI()
  self.isFirstIn = true
  self.allDataList = {}
  local list = TableData.listDarkzoneSystemEndlessDatas:GetList()
  for i = 0, list.Count - 1 do
    local tbData = list[i]
    table.insert(self.allDataList, tbData)
  end
  function self.onLoadingEndFunc()
    local lookIndex, unlockRaidIndex
    for i, v in ipairs(self.topTypeItemList) do
      if unlockRaidIndex == nil and v.canRaid == false then
        local itemPreIndex = i - 1
        local preItem = self.topTypeItemList[itemPreIndex]
        if preItem and preItem.canRaid == true then
          unlockRaidIndex = itemPreIndex
        end
      end
      if lookIndex == nil and v.isUnlock == false then
        local itemPreIndex = i - 1
        local preItem = self.topTypeItemList[itemPreIndex]
        if preItem and preItem.isUnlock == true and preItem.wish == true then
          lookIndex = itemPreIndex
        end
      end
    end
    local lookItem
    if lookIndex ~= nil then
      lookItem = self.topTypeItemList[lookIndex]
    end
    local raidItem
    if unlockRaidIndex ~= nil then
      raidItem = self.topTypeItemList[unlockRaidIndex]
    end
    if lookItem and lookItem.mData.wish == true then
      self:DelayCall(self.delayTime, function()
        self:CheckShowNewStateUnlock(lookItem, raidItem)
      end)
    elseif raidItem ~= nil then
      self:DelayCall(self.delayTime, function()
        self:CheckShowNewSubStateUnlock(raidItem)
      end)
    end
  end
end
function UIDarkZoneEndlessItem:OnClickTypeItem()
  self.showDataList = self.allDataList or {}
  local lookIndex, unlockRaidIndex
  local count = #self.showDataList
  for i = 1, count do
    local data = self.showDataList[i]
    if self.topTypeItemList[i] == nil then
      local itemView = UIDarkZoneEndlessMissionItem.New()
      itemView:InitCtrl(self.ui.mVirtualListExNew_MissionList.content)
      self.topTypeItemList[i] = itemView
    end
    local item = self.topTypeItemList[i]
    item:SetData(data, i)
    item:SetLockState()
    item:SetItemClickCallBack(function(v)
      self:OnClickMissionItem(v)
    end)
    if lookIndex == nil then
      if item.isUnlock == false then
        local itemPreIndex = i - 1
        local preItem = self.topTypeItemList[itemPreIndex]
        if preItem and preItem.isUnlock == true then
          lookIndex = itemPreIndex
        end
      elseif i == count then
        lookIndex = i
      end
    end
  end
  if 0 < count then
    if lookIndex == nil then
      lookIndex = 1
    end
    local lookItem = self.topTypeItemList[lookIndex]
    if self.tween then
      LuaDOTweenUtils.Kill(self.tween, false)
      self.tween = nil
    end
    self:DelayCall(0.05, function()
      local itemHeight = 90
      local endValue = (lookIndex - 1) * itemHeight
      if lookItem.isUnlock == true then
        lookItem:ClickItemFunction(true)
      end
      self.tween = LuaDOTweenUtils.SmoothMoveY(self.ui.mVirtualListExNew_MissionList.content, endValue, 0.4, nil, Ease.OutCubic)
    end)
    if self.needTips ~= false then
      self.onLoadingEndFunc()
    end
  end
end
function UIDarkZoneEndlessItem:RefreshItemState()
  local count = #self.showDataList
  for i = 1, count do
    local item = self.topTypeItemList[i]
    item:SetLockState()
  end
end
function UIDarkZoneEndlessItem:CheckShowNewStateUnlock(item, raidItem)
  local curStageID = PlayerPrefs.GetInt(AccountNetCmdHandler:GetUID() .. "EndlessModeStage")
  if curStageID < item.mData.id then
    CS.PopupMessageManager.PopupString(TableData.GetHintById(240118))
    if raidItem then
      self:DelayCall(1.5, function()
        self:CheckShowNewSubStateUnlock(raidItem)
      end)
    end
    PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. "EndlessModeStage", item.mData.id)
  end
end
function UIDarkZoneEndlessItem:CheckShowNewSubStateUnlock(item)
  local curSubStageID = PlayerPrefs.GetInt(AccountNetCmdHandler:GetUID() .. "EndlessModeAutoRaidStage")
  if curSubStageID < item.mData.id then
    CS.PopupMessageManager.PopupString(string_format(TableData.GetHintById(240115), item.mData.quest.str))
    PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. "EndlessModeAutoRaidStage", item.mData.id)
  end
end
function UIDarkZoneEndlessItem:OnClickMissionItem(item)
  if self.currentSelectItem and self.currentSelectItem ~= item then
    self.currentSelectItem:SetItemListVisible(false)
  end
  self.currentSelectItem = item
end
function UIDarkZoneEndlessItem:ItemProvider()
  local itemView = UIDarkZoneEndlessMissionItem.New()
  itemView:InitCtrl(self.ui.mVirtualListExNew_MissionList.content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIDarkZoneEndlessItem:ItemRenderer(index, itemData)
  local data = self.showDataList[index + 1]
  local item = itemData.data
  item:SetData(data, index + 1)
  item:SetLockState()
end
function UIDarkZoneEndlessItem:Show(mIsFirstShowQuest, isBackFrom, isNeedDelayFadein)
  for i = 1, 3 do
    setactive(self.parentPanel.ui["mImg_Map" .. i], false)
  end
  if isBackFrom ~= true then
    self:OnClickTypeItem()
  else
    self:RefreshItemState()
  end
  self.parentPanel.animator:ResetTrigger("ExploreMode_FadeOut")
  self.parentPanel.animator:SetTrigger("ExploreMode_FadeIn")
  self.parentPanel.ui.mAnimator_Mode:SetTrigger("MoveLight")
end
function UIDarkZoneEndlessItem:Hide(IsFirstIn)
  for i = 1, 3 do
    setactive(self.parentPanel.ui["mImg_Map" .. i], true)
  end
end
function UIDarkZoneEndlessItem:OnShowFinish()
end
function UIDarkZoneEndlessItem:OnBackFrom()
end
function UIDarkZoneEndlessItem:OnRecover()
  self.needTips = false
end
function UIDarkZoneEndlessItem:Release()
  self:OnRelease()
end
function UIDarkZoneEndlessItem:OnRelease()
  self.ui = nil
  self.mData = nil
  self:ReleaseCtrlTable(self.topTypeItemList, true)
  self.topTypeItemList = nil
  self.super.OnRelease(self, true)
  self.currentSelectItem = nil
  if self.tween then
    LuaDOTweenUtils.Kill(self.tween, false)
  end
  self.tween = nil
  self:ReleaseTimers()
  self.isFirstIn = nil
  self:RemoveEventListener()
end
function UIDarkZoneEndlessItem:AddEventListener()
  MessageSys:AddListener(CS.GF2.Message.UIEvent.OnLoadingEnd, self.onLoadingEndFunc)
end
function UIDarkZoneEndlessItem:RemoveEventListener()
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.OnLoadingEnd, self.onLoadingEndFunc)
  self.onLoadingEndFunc = nil
end
