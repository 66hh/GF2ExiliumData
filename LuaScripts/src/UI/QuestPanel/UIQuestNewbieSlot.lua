require("UI.Common.UIComBtn3ItemR")
UIQuestNewbieSlot = class("UIQuestNewbieSlot", UIBaseCtrl)
function UIQuestNewbieSlot:ctor(go)
  self.ui = UIUtils.GetUIBindTable(go)
  self:SetRoot(go.transform)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnGoto.gameObject, function()
    self:onClickGoto()
  end)
  self.btnReceive = UIComBtn3ItemR.New(self.ui.mTrans_Receive, self.ui.mBtn_BtnReceive)
  self.btnReceive:AddClickListener(function()
    self:onClickReceive()
  end)
  self.questData = nil
  self.index = nil
  self.itemTable = {}
end
function UIQuestNewbieSlot:SetData(newbieQuestData, index, onReceiveCallback)
  self.questData = newbieQuestData
  self.index = index
  self.onReceiveCallback = onReceiveCallback
  if #self.itemTable > 0 then
    self:ReleaseCtrlTable(self.itemTable, true)
  end
  self.itemTable = {}
  for itemId, num in pairs(self.questData.reward_list) do
    local item = UICommonItem.New()
    item:InitCtrl(self.ui.mScrollItem_Atom.transform)
    item:SetItemData(itemId, num)
    item.mUIRoot:SetAsLastSibling()
    local stcData = TableData.GetItemData(itemId)
    TipsManager.Add(item.mUIRoot, stcData)
    table.insert(self.itemTable, item)
  end
  setactive(self.ui.mTrans_EmptyRewardSlot1, false)
  setactive(self.ui.mTrans_EmptyRewardSlot2, false)
  if self.questData.reward_list.Count == 0 then
    setactive(self.ui.mTrans_EmptyRewardSlot1, true)
    setactive(self.ui.mTrans_EmptyRewardSlot2, true)
  elseif self.questData.reward_list.Count == 1 then
    setactive(self.ui.mTrans_EmptyRewardSlot1, true)
  end
  self:Refresh()
end
function UIQuestNewbieSlot:Release()
  self.btnReceive:OnRelease()
  self:ReleaseCtrlTable(self.itemTable)
  self.questData = nil
  self.index = nil
  self.ui = nil
end
function UIQuestNewbieSlot:Refresh()
  self.ui.mText_Tittle.text = self.questData.description
  self.ui.mText_Progress.text = self.questData:GetProgressStr()
  self.ui.mSmoothMask_Progress.FillAmount = self.questData:GetProgress()
  setactive(self.ui.mTrans_Finished, false)
  setactive(self.ui.mBtn_BtnReceive, false)
  setactive(self.ui.mTrans_Unfinished, false)
  setactive(self.ui.mBtn_BtnGoto, false)
  self.btnReceive:SetRedPointVisible(false)
  if self.questData.isReceived then
    setactive(self.ui.mTrans_Finished, true)
  elseif self.questData.isComplete then
    setactive(self.ui.mBtn_BtnReceive, true)
  elseif self.questData.link == "" then
    setactive(self.ui.mTrans_Unfinished, true)
  else
    setactive(self.ui.mBtn_BtnGoto, true)
  end
  self.ui.mBtn_BtnReceive.interactable = not self.questData.isReceived
end
function UIQuestNewbieSlot:onClickGoto()
  local jumpID = tonumber(self.questData.link)
  local result = UIUtils.CheckIsUnLock(jumpID)
  if result ~= 0 then
    local str = ""
    if 0 < result then
      local unlockData = TableData.listUnlockDatas:GetDataById(result)
      str = UIUtils.CheckUnlockPopupStr(unlockData)
    elseif result == -2 then
      str = TableData.GetHintById(103070)
    elseif result == -1 then
      local jumpData = TableData.listJumpListContentnewDatas:GetDataById(tonumber(jumpID))
      str = string_format(TableData.GetHintById(jumpData.plan_open_hint), TableData.GetHintById(103054))
    end
    PopupMessageManager.PopupString(str)
  else
    SceneSwitch:SwitchByID(jumpID)
  end
end
function UIQuestNewbieSlot:onClickReceive()
  for itemId, num in pairs(self.questData.reward_list) do
    if TipsManager.CheckItemIsOverflowAndStop(itemId, num) then
      return
    end
  end
  NetCmdQuestData:SendGuideQuestTakeReward({
    self.questData.Id
  }, function(ret)
    self:onReceivedCallback(ret)
  end)
end
function UIQuestNewbieSlot:onReceivedCallback(ret)
  if ret ~= ErrorCodeSuc then
    return
  end
  if self.onReceiveCallback then
    self.onReceiveCallback(self.questData, self.index)
  end
end
