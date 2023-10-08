require("UI.Common.UIComBtn3ItemR")
UIQuestNewbieSlotV2 = class("UIQuestNewbieSlotV2", UIBaseCtrl)
function UIQuestNewbieSlotV2:ctor(prefab, parent)
  local go = instantiate(prefab, parent)
  self.ui = {}
  self:LuaUIBindTable(go, self.ui)
  self:SetRoot(go.transform)
  self.ui.mAnimator_NewTaskItem.keepAnimatorControllerStateOnDisable = true
  UIUtils.AddBtnClickListener(self.ui.mBtn_See.gameObject, function()
    self:onClickSee()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Receive.gameObject, function()
    self:onClickReceive()
  end)
  self.ui.mText_Receive.text = TableData.GetHintById(112025)
  self.questData = nil
  self.index = nil
  self.itemTable = {}
end
function UIQuestNewbieSlotV2:SetData(newbieQuestData, index, onReceiveCallback, phaseNum)
  self.questData = newbieQuestData
  self.index = index
  self.onReceiveCallback = onReceiveCallback
  self.phaseNum = phaseNum
  if #self.itemTable > 0 then
    self:ReleaseCtrlTable(self.itemTable, true)
  end
end
function UIQuestNewbieSlotV2:Release()
  self.btnReceive:OnRelease()
  self:ReleaseCtrlTable(self.itemTable)
  self.questData = nil
  self.index = nil
  self.ui = nil
end
function UIQuestNewbieSlotV2:Refresh()
  local itemID = string.split(self.questData.rewardShow, ":")
  if itemID then
    itemID = tonumber(itemID[1])
    self.ui.mImg_Icon.sprite = IconUtils.GetItemIconSprite(itemID)
  end
  self.ui.mText_Num.text = "0" .. tostring(self.index) .. "/"
  self.ui.mText_Content.text = self.questData.name
  self.ui.mText_IndexNum.text = string_format(TableData.GetHintById(112032), self.phaseNum * 100 + self.index)
  setactive(self.ui.mTrans_Finished, false)
  setactive(self.ui.mBtn_Receive.transform.parent.transform, false)
  setactive(self.ui.mBtn_See.transform.parent.transform, false)
  if self.questData.isReceived then
    self.ui.mAnimator_NewTaskItem:SetInteger("Switch", 2)
  elseif self.questData.isComplete then
    self.ui.mAnimator_NewTaskItem:SetInteger("Switch", 1)
  else
    self.ui.mAnimator_NewTaskItem:SetInteger("Switch", 0)
  end
end
function UIQuestNewbieSlotV2:onClickSee()
  UIManager.OpenUIByParam(UIDef.UINewTaskSeeDialog, self.questData)
end
function UIQuestNewbieSlotV2:onClickReceive()
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
function UIQuestNewbieSlotV2:onReceivedCallback(ret)
  if ret ~= ErrorCodeSuc then
    return
  end
  if self.onReceiveCallback then
    self.onReceiveCallback(ret)
  end
end
