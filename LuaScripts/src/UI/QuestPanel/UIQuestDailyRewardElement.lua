UIQuestDailyRewardElement = class("UIQuestDailyRewardElement", UIBaseCtrl)
function UIQuestDailyRewardElement:ctor(go)
  self.ui = UIUtils.GetUIBindTable(go)
  self:SetRoot(go.transform)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnReceive.gameObject, function()
    self:onClickReceive()
  end)
  self.dailyRewardData = nil
  self.index = nil
end
function UIQuestDailyRewardElement:SetData(index, dailyRewardData, havePoint, onReceivedCallback)
  self.index = index
  self.dailyRewardData = dailyRewardData
  self.havePoint = havePoint
  self.onReceivedCallback = onReceivedCallback
  self:Refresh()
end
function UIQuestDailyRewardElement:Release()
  self.dailyRewardData = nil
  self.index = nil
  self.ui = nil
end
function UIQuestDailyRewardElement:Refresh()
  self:ReleaseCtrlTable(self.itemTable, true)
  self.itemTable = {}
  local rewardList = {}
  for itemId, num in pairs(self.dailyRewardData.reward_list) do
    table.insert(rewardList, {itemId = itemId, num = num})
  end
  table.sort(rewardList, function(a, b)
    return a.itemId > b.itemId
  end)
  for _, reward in pairs(rewardList) do
    local item = UICommonItem.New()
    item:InitCtrl(self.ui.mScrollIItem_Atom.transform)
    item:SetItemData(reward.itemId, reward.num)
    item.mUIRoot:SetAsFirstSibling()
    local stcData = TableData.GetItemData(reward.itemId)
    TipsManager.Add(item.mUIRoot, stcData)
    table.insert(self.itemTable, item)
  end
  setactive(self.ui.mBtn_BtnReceive.gameObject, false)
  setactive(self.ui.mTrans_Unfinished.gameObject, false)
  setactive(self.ui.mTrans_Finished.gameObject, false)
  if self.havePoint >= self.dailyRewardData.value then
    if NetCmdQuestData:IsDailyRewardReceive(self.dailyRewardData.Id) then
      setactive(self.ui.mTrans_Finished.gameObject, true)
    else
      setactive(self.ui.mBtn_BtnReceive.gameObject, true)
    end
  else
    setactive(self.ui.mTrans_Unfinished.gameObject, true)
  end
  self.ui.mText_PointNum.text = tostring(self.dailyRewardData.value)
end
function UIQuestDailyRewardElement:onClickReceive()
  NetCmdQuestData:C2SQuestTakeDailyReward2({
    self.dailyRewardData.Id
  }, function(ret)
    self:onReceived(ret)
  end)
end
function UIQuestDailyRewardElement:onReceived(ret)
  if ret ~= ErrorCodeSuc then
    return
  end
  self:Refresh()
  UICommonReceivePanel.OpenWithCheckPopupDownLeftTips()
  if self.onReceivedCallback then
    self.onReceivedCallback()
  end
end
