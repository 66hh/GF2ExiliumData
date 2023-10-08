require("UI.UIBaseCtrl")
require("UI.MonopolyActivity.ActivityTourGlobal")
require("UI.MonopolyActivity.RandomMovePoint.Item.ActivityTourPointItem_S")
ActivityTourPointRandomItem = class("ActivityTourPointRandomItem", UIBaseCtrl)
ActivityTourPointRandomItem.__index = ActivityTourPointRandomItem
ActivityTourPointRandomItem.ui = nil
ActivityTourPointRandomItem.mData = nil
function ActivityTourPointRandomItem:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function ActivityTourPointRandomItem:InitCtrl(parent)
  local com = parent:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem, parent)
  self:SetRoot(obj.transform)
  self.ui = {}
  self.mData = nil
  self.listPoint = {}
  self:LuaUIBindTable(obj, self.ui)
  self.pointsAniLength = LuaUtils.GetAnimationClipLengthByAnimation(self.ui.mAni_Points, "Ani_ActivityTourPointRandomItem_Point_FadeIn")
  self.fadeOutLength = LuaUtils.GetAnimationClipLength(self.ui.mAni_Root, "FadeOut")
  ActivityTourGlobal.ReplaceAllColor(self.mUIRoot)
  if not self.listNumSprite then
    self.listNumSprite = {}
    for i = 1, 6 do
      self.listNumSprite[i] = ActivityTourGlobal.GetActivityTourSprite(ActivityTourGlobal.PointPath .. i)
    end
  end
end
function ActivityTourPointRandomItem:Refresh(minPoint, maxPoint, movePoint, buffTrigger, showResult)
  for i = 6, 1, -1 do
    local isEmpty = i < minPoint or maxPoint < i
    local item = self.listPoint[i]
    if not item then
      item = ActivityTourPointItem_S.New()
      item:InitCtrl(self.ui.mTrans_PointList)
      item:Refresh(i)
      self.listPoint[i] = item
    end
    item:RefreshEmpty(isEmpty)
    if isEmpty then
      item.mUIRoot:SetAsLastSibling()
    else
      item.mUIRoot:SetAsFirstSibling()
    end
  end
  setactive(self.ui.mTrans_AddPoint.gameObject, false)
  setactive(self.ui.mTrans_SubPoint.gameObject, false)
  setactive(self.ui.mTrans_StateTip.gameObject, true)
  setactive(self.ui.mTrans_Point.gameObject, true)
  local bufPoint = 0
  local listBuf = {}
  if buffTrigger then
    for i = 0, buffTrigger.BuffTrigger_.Count - 1 do
      local buffEffect = buffTrigger.BuffTrigger_[i]
      if buffEffect.Points ~= 0 then
        bufPoint = bufPoint + buffEffect.Points
        table.insert(listBuf, buffEffect.Buff)
      end
    end
  end
  self.bufPoint = bufPoint
  self.result = movePoint
  setactive(self.ui.mTrans_GrpStateTip.gameObject, bufPoint ~= 0)
  self.ui.mText_StateDesc.text = ""
  if 0 < #listBuf then
    local isAdd = 0 < bufPoint
    self.ui.mAni_State:SetBool("State", isAdd)
    local buffData = TableData.listMonopolyEffectDatas:GetDataById(listBuf[1].Id)
    if buffData then
      self.ui.mText_StateDesc.text = buffData.desc.str
    end
  end
  if showResult then
    self:RefreshSelectPoint(minPoint, maxPoint)
    self:RefreshResult()
  else
    self:ResetSelectPoint(minPoint, maxPoint)
    self:PlayTweenAin(minPoint, maxPoint)
  end
end
function ActivityTourPointRandomItem:RefreshSelectPoint(minPoint, maxPoint)
  for i = minPoint, maxPoint do
    self.listPoint[i]:SelectPoint(self.result == i)
  end
end
function ActivityTourPointRandomItem:ResetSelectPoint(minPoint, maxPoint)
  for i = minPoint, maxPoint do
    self.listPoint[i]:SelectPoint(minPoint == i)
  end
end
function ActivityTourPointRandomItem:OnRelease()
  for i = 1, #self.listPoint do
    self.listPoint[i]:OnRelease(true)
  end
  self:ResetTween()
  self:ResetTimer()
  self.tweenStep1 = nil
  self.tweenStep2 = nil
  self.listNumSprite = nil
  self.super.OnRelease(self, true)
end
function ActivityTourPointRandomItem:PlayTweenAin(minPoint, maxPoint)
  if not (minPoint and maxPoint) or maxPoint <= minPoint or minPoint < 1 then
    return
  end
  self:ResetTween()
  self:ResetTimer()
  local round1 = 3
  local round3 = 5
  local interval = maxPoint - minPoint
  local rate = (interval + 1) / 4
  local listIndex1 = {}
  for i = 1, round1 do
    for j = minPoint, maxPoint do
      table.insert(listIndex1, j)
    end
  end
  local getter1 = function(tempSelf)
    return 1
  end
  local setter1 = function(tempSelf, value)
    local index = math.floor(value)
    for j = minPoint, maxPoint do
      self.listPoint[j]:SelectPoint(listIndex1[index] == j)
    end
    self.ui.mImg_FinalPoint.sprite = self.listNumSprite[listIndex1[index]]
  end
  local listIndex2 = {}
  for i = round1 + 1, round3 do
    for j = minPoint, maxPoint do
      table.insert(listIndex2, j)
      if i == round3 and self.result == j then
        break
      end
    end
  end
  local getter2 = function(tempSelf)
    return 1
  end
  local setter2 = function(tempSelf, value)
    local index = math.floor(value)
    for j = minPoint, maxPoint do
      self.listPoint[j]:SelectPoint(listIndex2[index] == j)
    end
    self.ui.mImg_FinalPoint.sprite = self.listNumSprite[listIndex2[index]]
  end
  self.timer1 = TimerSys:DelayCall(0.5, function()
    self.tweenStep1 = LuaDOTweenUtils.ToOfFloat(self, getter1, setter1, #listIndex1, 0.5 * rate, function()
      self.tweenStep2 = LuaDOTweenUtils.ToOfFloat(self, getter2, setter2, #listIndex2, 1 * rate, function()
        for j = minPoint, maxPoint do
          self.listPoint[j]:SetFinalColor(j == self.result)
        end
        self.timer2 = TimerSys:DelayCall(0.15, function()
          self:RefreshResult()
        end)
      end, CS.DG.Tweening.Ease.OutQuad)
    end)
  end)
end
function ActivityTourPointRandomItem:RefreshResult()
  self.ui.mImg_FinalPoint.sprite = self.listNumSprite[self.result]
  if self.bufPoint and self.bufPoint ~= 0 then
    self.timer3 = TimerSys:DelayCall(self.pointsAniLength, function()
      local isAdd = self.bufPoint > 0
      setactive(self.ui.mTrans_AddPoint.gameObject, isAdd)
      setactive(self.ui.mTrans_SubPoint.gameObject, not isAdd)
      if isAdd then
        self.ui.mImg_AddPoint.sprite = ActivityTourGlobal.GetActivityTourSprite(ActivityTourGlobal.PointPath .. self.bufPoint)
      else
        self.ui.mImg_SubPoint.sprite = ActivityTourGlobal.GetActivityTourSprite(ActivityTourGlobal.PointPath .. -self.bufPoint)
      end
      self.timer4 = TimerSys:DelayCall(1, function()
        self:PlayHideAni()
      end)
    end)
  else
    self.timer4 = TimerSys:DelayCall(1, function()
      self:PlayHideAni()
    end)
  end
end
function ActivityTourPointRandomItem:PlayHideAni()
  self.ui.mAni_Root:SetTrigger("FadeOut")
  self.timer5 = TimerSys:DelayCall(self.fadeOutLength, function()
    setactive(self.mUIRoot, false)
    MessageSys:SendMessage(MonopolyEvent.PlayDiceAniFinish, nil)
  end)
end
function ActivityTourPointRandomItem:ResetTimer()
  for i = 1, 5 do
    if self["timer" .. i] then
      self["timer" .. i]:Stop()
      self["timer" .. i] = nil
    end
  end
end
function ActivityTourPointRandomItem:ResetTween()
  if not LuaUtils.IsNullOrDestroyed(self.tweenStep1) then
    LuaDOTweenUtils.Kill(self.tweenStep1, false)
  end
  if not LuaUtils.IsNullOrDestroyed(self.tweenStep2) then
    LuaDOTweenUtils.Kill(self.tweenStep2, false)
  end
end
