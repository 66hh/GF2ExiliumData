require("UI.UIBaseCtrl")
require("UI.DarkZonePanel.UIDarkZoneModePanel.UIDarkZoneEndlessPanel.Item.UIDarkZoneEndlessTopTypeItem")
UIDarkZoneEndlessMissionItem = class("UIDarkZoneEndlessMissionItem", UIBaseCtrl)
UIDarkZoneEndlessMissionItem.__index = UIDarkZoneEndlessMissionItem
function UIDarkZoneEndlessMissionItem:__InitCtrl()
end
function UIDarkZoneEndlessMissionItem:InitCtrl(root)
  if root == nil then
    return
  end
  local itemPrefab = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(itemPrefab.childItem)
  CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self.mData = nil
  self.isOpenList = nil
  self.clickFunction = nil
  self.isUnlock = true
  self.maxHeight1 = 140
  self.maxHeight2 = 98
  self.typeItemList = {}
  self.curUnlockItem = nil
  self:SetItemListVisible(false)
  UIUtils.GetButtonListener(self.ui.mBtn_Root.gameObject).onClick = function()
    self:ClickItemFunction()
  end
end
function UIDarkZoneEndlessMissionItem:SetData(data, index)
  self.mData = data
  self.ui.mText_Num.text = string.format("-", index)
  self.ui.mText_Name.text = data.quest.str
  self.ui.mText_Describe.text = data.quest_des.str
  local list = TableData.listDarkzoneSystemEndlessRewardByGroupDatas:GetDataById(self.mData.id).Id
  for i = 0, list.Count - 1 do
    local index = i + 1
    local id = list[i]
    local d = TableData.listDarkzoneSystemEndlessRewardDatas:GetDataById(id)
    local typeData = TableData.listDarkzoneSystemEndlessTypeDatas:GetDataById(d.type)
    if self.typeItemList[index] == nil then
      self.typeItemList[index] = UIDarkZoneEndlessTopTypeItem.New()
      self.typeItemList[index]:InitCtrl(self.ui.mTrans_TypeRoot)
    end
    local item = self.typeItemList[index]
    item:SetData(typeData, d)
    item:SetLockState(self.isUnlock)
    item:SetClickFunction(function()
      self:OnClickTypeItem(item)
    end)
    if item.isUnLock == true then
      self.curUnlockItem = item
    end
  end
  self:CheckRaidState()
end
function UIDarkZoneEndlessMissionItem:CheckRaidState()
  local showStr = CS.LuaUIUtils.CheckUnlockPopupStrByRepeatedList(self.mData.raid_unlock)
  self.ui.mText_LockInfo.text = showStr
  self.canRaid = string.len(showStr) == 0
  setactive(self.ui.mTrans_Raid, self.canRaid == true)
end
function UIDarkZoneEndlessMissionItem:SetLockState()
  local list = self.mData.unlock
  local isUnlock = true
  local stringList = {}
  self.lockHitStr = nil
  for i = 0, list.Count - 1 do
    local unlockID = list[i]
    if DarkNetCmdStoreData:CheckEndLessTopTypeRecord(unlockID) == false then
      isUnlock = false
      table.insert(stringList, self.mData.unlock_des.str)
      break
    end
  end
  for i, v in pairs(self.mData.unlock2) do
    local s
    if i == 1 then
      if v > AccountNetCmdHandler:GetLevel() then
        isUnlock = false
        s = self.mData.unlock_des2.str
      end
    elseif i == 2 and NetCmdDarkZoneSeasonData:IsQuestFinish(v) == false then
      isUnlock = false
      s = self.mData.unlock_des2.str
    end
    if s ~= nil then
      table.insert(stringList, s)
    end
  end
  local listCount = #stringList
  if 0 < listCount then
    if 1 < listCount then
      self.lockHitStr = string_format(TableData.GetHintById(240121), stringList[1], stringList[2])
    else
      self.lockHitStr = string_format(TableData.GetHintById(240122), stringList[1])
    end
  end
  self.isUnlock = isUnlock
  local lockState = 0
  if isUnlock == true then
    lockState = 1
  end
  self.ui.mAnimator_Root:SetInteger("Switch", lockState)
end
function UIDarkZoneEndlessMissionItem:OnClickTypeItem(item)
  if self.mData then
    local t = {}
    t[0] = 2
    t[1] = self.mData.id
    t[2] = item.mRewardData.id
    UIManager.OpenUIByParam(UIDef.UIDarkZoneQuestPanel, t)
  end
end
function UIDarkZoneEndlessMissionItem:SetItemClickCallBack(func)
  self.clickFunction = func
end
function UIDarkZoneEndlessMissionItem:SetItemListVisible(isShow)
  self.isOpenList = isShow
  local num = 0
  if self.isUnlock == true then
    if self.isOpenList == true then
      num = 2
    else
      num = 1
    end
  end
  local maxHeight = 0
  local fadeTime = 0.3
  if self.isOpenList == false then
    fadeTime = 0.1
  elseif self.canRaid == true then
    maxHeight = self.maxHeight2
  else
    maxHeight = self.maxHeight1
  end
  if self.listTween then
    LuaDOTweenUtils.Kill(self.listTween, false)
  end
  local getter = function(tempSelf)
    return tempSelf.ui.mLayoutElement_layout.minHeight
  end
  local setter = function(tempSelf, value)
    tempSelf.ui.mLayoutElement_layout.minHeight = value
  end
  if self.isOpenList == false then
    setactive(self.ui.mTrans_TypeRoot, self.isOpenList)
    setactive(self.ui.mTrans_RaidLock, self.canRaid == false and self.isOpenList == true)
  end
  self.listTween = LuaDOTweenUtils.ToOfFloat(self, getter, setter, maxHeight, fadeTime, function()
    if self.isOpenList == true then
      setactive(self.ui.mTrans_TypeRoot, self.isOpenList)
      setactive(self.ui.mTrans_RaidLock, self.canRaid == false and self.isOpenList == true)
    end
  end)
  self.ui.mAnimator_Root:SetInteger("Switch", num)
end
function UIDarkZoneEndlessMissionItem:ClickItemFunction(needShow)
  if self.isUnlock == false then
    CS.PopupMessageManager.PopupString(self.lockHitStr)
    return
  end
  if needShow == nil then
    needShow = not self.isOpenList or needShow
  end
  self.isOpenList = needShow
  local item
  if self.isOpenList == true then
    item = self
  end
  if self.clickFunction and self.isUnlock then
    self.clickFunction(item)
  end
  self:SetItemListVisible(self.isOpenList)
end
function UIDarkZoneEndlessMissionItem:OnRelease()
  self.ui = nil
  self.mData = nil
  self.isUnlock = nil
  self.curUnlockItem = nil
  if self.listTween then
    LuaDOTweenUtils.Kill(self.listTween, false)
  end
  self.listTween = nil
  self:ReleaseCtrlTable(self.typeItemList, true)
  self.super.OnRelease(self, true)
end
