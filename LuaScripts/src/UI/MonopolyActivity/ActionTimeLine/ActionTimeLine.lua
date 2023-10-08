require("UI.UIBaseCtrl")
require("UI.MonopolyActivity.ActionTimeLine.ActivityTourAvatarStepItem")
ActionTimeLine = class("ActionTimeLine", UIBaseCtrl)
ActionTimeLine.__index = ActionTimeLine
local XRangeMax = 0
local XRangeMin = 0
local ItemMoveTime = 1
local currentActionScale = Vector3(1.26, 1.26, 1.26)
local scaleOffset = 6
function ActionTimeLine:ctor()
  self.super.ctor(self)
  self.mUICharItems = {}
end
function ActionTimeLine:InitCtrl(ui)
  self.ui = ui
  self:RegisterMessage()
  XRangeMax = self.ui.mTrans_RangeTimeLine2.anchoredPosition.x
  XRangeMin = self.ui.mTrans_RangeTimeLine1.anchoredPosition.x
end
function ActionTimeLine:RegisterMessage()
end
function ActionTimeLine:UnRegisterMessage()
end
function ActionTimeLine:Hide()
  setactive(self.ui.mScrollListChild_TimeLineContent, false)
  setactive(self.ui.mTrans_InRound, false)
end
function ActionTimeLine:Reset(isSaveIndex, isInsertNull)
  setactive(self.ui.mScrollListChild_TimeLineContent, true)
  setactive(self.ui.mTrans_InRound, true)
  if not isSaveIndex then
    self.mCurrentIndex = nil
  else
    self.mCurrentIndex = MonopolyWorld.MpData.TimeLineIndex + 1
  end
  self:InitNewRound(self.mCurrentIndex, isInsertNull)
end
function ActionTimeLine:InitNewRound(curIndex, isInsertNull)
  local timeLines = MonopolyWorld.MpData.actionTimeLine
  local showAvatarCount = timeLines.Count
  self.mCurrentIndex = curIndex or 0
  local totalWidth = XRangeMax - XRangeMin
  self.mCurrentSpace = totalWidth / showAvatarCount
  local currentIndex = self.mCurrentIndex
  if isInsertNull then
    self.mCurrentIndex = self.mCurrentIndex - 1
  end
  self:HideAll()
  for i = 1, showAvatarCount do
    local gunItem = self.mUICharItems[i]
    if not gunItem then
      gunItem = ActivityTourAvatarStepItem.New()
      gunItem:InitCtrl(self.ui.mScrollListChild_TimeLineContent.childItem, self.ui.mScrollListChild_TimeLineContent.transform)
      self.mUICharItems[i] = gunItem
    end
    gunItem:SetPositionX(self:GetIndexPosX(i))
    local isShow = i >= currentIndex
    gunItem:Show(isShow)
    gunItem.mUIRoot:SetAsFirstSibling()
    if isShow then
      local id = timeLines[i - 1]
      local actorData = MonopolyWorld.MpData:GetActorData(id)
      if actorData ~= nil then
        if actorData.actorType == CS.GF2.Monopoly.MonopolyActorDefine.ActorType.Monster then
          gunItem:SetMonsterData(actorData.configId)
        else
          gunItem:SetGunData(actorData.configId)
        end
      end
      if i == self.mCurrentIndex then
        gunItem.mUIRoot.localScale = currentActionScale
      else
        gunItem.mUIRoot.localScale = vectorone
      end
    end
  end
  if isInsertNull then
    local gunItem = self.mUICharItems[self.mCurrentIndex]
    if gunItem then
      gunItem:Show(false)
    end
  end
  MessageSys:SendMessage(MonopolyEvent.OnActionTimeLineChange, currentIndex - 1)
end
function ActionTimeLine:GetIndexPosX(index)
  local posX = XRangeMax - self.mCurrentSpace * (index - self.mCurrentIndex)
  if self.mCurrentIndex and self.mCurrentIndex > 0 and index > self.mCurrentIndex then
    posX = posX - scaleOffset
  end
  return posX
end
function ActionTimeLine:MoveNext()
  if self.mCurrentIndex > 0 then
    local oldItem = self.mUICharItems[self.mCurrentIndex]
    oldItem:FadeInOut(false)
  end
  self.mCurrentIndex = self.mCurrentIndex + 1
  self:StopAllTween()
  self.mTweens = {}
  local showAvatarCount = MonopolyWorld.MpData.actionTimeLine.Count
  for i = self.mCurrentIndex, showAvatarCount do
    local gunItem = self.mUICharItems[i]
    if gunItem then
      local targetPos = gunItem:GetPosition()
      targetPos.x = self:GetIndexPosX(i)
      local tween = LuaDOTweenUtils.DoAnchorsPosMove(gunItem.mUIRoot, targetPos, ItemMoveTime)
      table.insert(self.mTweens, tween)
      if i == self.mCurrentIndex then
        tween = LuaDOTweenUtils.DoScale(gunItem.mUIRoot, currentActionScale, ItemMoveTime, 0)
        table.insert(self.mTweens, tween)
      end
    end
  end
  MessageSys:SendMessage(MonopolyEvent.OnActionTimeLineChange, self.mCurrentIndex - 1)
end
function ActionTimeLine:HideAll()
  for i = 0, #self.mUICharItems do
    local gunItem = self.mUICharItems[i]
    if gunItem then
      gunItem:Show(false)
    end
  end
end
function ActionTimeLine:FadeInOut(isFadeIn)
  if not self.mUICharItems or self.mCurrentIndex == nil then
    return
  end
  for i = self.mCurrentIndex, #self.mUICharItems do
    local gunItem = self.mUICharItems[i]
    if gunItem then
      gunItem:FadeInOut(isFadeIn)
    end
  end
end
function ActionTimeLine:StopAllTween()
  if not self.mTweens then
    return
  end
  for i = 1, #self.mTweens do
    local tween = self.mTweens[i]
    if tween then
      LuaDOTweenUtils.Kill(tween, false)
    end
    self.mTweens[i] = nil
  end
end
function ActionTimeLine:Release()
  self:UnRegisterMessage()
  self:StopAllTween()
  self.mTweens = nil
  self:ReleaseCtrlTable(self.mUICharItems, true)
  self.mUICharItems = nil
  self:OnRelease(true)
end
