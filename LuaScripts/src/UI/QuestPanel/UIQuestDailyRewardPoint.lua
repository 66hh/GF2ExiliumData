UIQuestDailyRewardPoint = class("UIQuestDailyRewardPoint", UIBaseCtrl)
function UIQuestDailyRewardPoint:ctor(go)
  self.ui = UIUtils.GetUIBindTable(go)
  self:SetRoot(go.transform)
end
function UIQuestDailyRewardPoint:SetData(havePoint, index)
  self.havePoint = havePoint
  self.curFlagPoint = TableData.listDailyRewardDatas:GetDataById(index).value
  self.index = index
  self:Refresh()
end
function UIQuestDailyRewardPoint:Refresh()
  setactive(self.ui.mTrans_CannotReceive, false)
  setactive(self.ui.mTrans_CanReceive, false)
  setactive(self.ui.mTrans_Received, false)
  if self.havePoint >= self.curFlagPoint then
    if self:isReceived() then
      setactive(self.ui.mTrans_Received, true)
    else
      setactive(self.ui.mTrans_CanReceive, true)
    end
  else
    setactive(self.ui.mTrans_CannotReceive, true)
  end
  self.ui.mText_FlagPoint.text = tostring(self.curFlagPoint)
end
function UIQuestDailyRewardPoint:Release()
  self.havePoint = nil
  self.curFlagPoint = nil
  self.index = nil
  self.ui = nil
end
function UIQuestDailyRewardPoint:SetVisible(visible)
  setactive(self:GetRoot(), visible)
end
function UIQuestDailyRewardPoint:isReceived()
  local dailyRewards = NetCmdQuestData:GetDailyRewards()
  if not dailyRewards then
    return false
  end
  for id, isReceived in pairs(dailyRewards) do
    if id == self.index and isReceived then
      return true
    end
  end
  return false
end
