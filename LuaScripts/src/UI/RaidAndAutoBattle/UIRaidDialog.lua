require("UI.RaidAndAutoBattle.UIRaidReceivePanel")
UIRaidDialog = class("UIRaidDialog", UIBasePanel)
function UIRaidDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  csPanel.UsePool = false
end
function UIRaidDialog:OnAwake(root, data)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Close.gameObject, function()
    self:onClickClose()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_GrpClose.gameObject, function()
    self:onClickClose()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_GrpBtnReduce.gameObject, function()
    self:onClickReduce()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_GrpBtnIncrease.gameObject, function()
    self:onClickIncrease()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnCancel.gameObject, function()
    self:onClickCancel()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnConfirm.gameObject, function()
    self:onClickStartRaid()
  end)
end
function UIRaidDialog:OnInit(root, data)
  self.stageData = TableData.listStageDatas:GetDataById(data.StageId)
  self.simTypeId = data.SimTypeId
  self.simResourceData = data.SimResourceData
  self.simEntranceData = data.SimEntranceData
  self.onClickStartRaidCallback = data.OnClickStartRaidCallback
  local challengeRemainingNum = self:getRemainingChallengeTimes()
  if challengeRemainingNum == -1 then
    self.maxValue = TableData.GlobalSystemData.RaidOnetimeLimit
  else
    self.maxValue = math.min(TableData.GlobalSystemData.RaidOnetimeLimit, challengeRemainingNum)
  end
  self.ui.mBtn_BtnConfirm.interactable = true
  self.ui.mSlider.minValue = 1
  self.ui.mSlider.maxValue = self.maxValue
  self.ui.mSlider.value = 1
  self.ui.mText_MinNum.text = tostring(1)
  self.ui.mText_MaxNum.text = tostring(self.maxValue)
  self.curRaidTimes = 1
  function self.onSliderValueChangedCallback()
    self:onSliderValueChanged()
  end
  self.ui.mSlider.onValueChanged:AddListener(self.onSliderValueChangedCallback)
end
function UIRaidDialog:OnShowStart()
  self:Refresh()
end
function UIRaidDialog:OnTop()
  self:Refresh()
end
function UIRaidDialog:OnClose()
  self.ui.mSlider.onValueChanged:RemoveListener(self.onSliderValueChangedCallback)
end
function UIRaidDialog:OnRelease()
  self.maxValue = nil
  self.curRaidTimes = nil
  self.ui.stageData = nil
  self.ui = nil
end
function UIRaidDialog:Refresh()
  self:refreshCurValueText()
  self:refreshCostText()
  self:refreshCostIcon()
  self:refreshSliderBtn()
end
function UIRaidDialog:refreshCurValueText()
  self.ui.mText_CompoundNum.text = self.curRaidTimes
end
function UIRaidDialog:refreshSliderValue()
  self.ui.mSlider.value = self.curRaidTimes
end
function UIRaidDialog:refreshSliderBtn()
  self.ui.mBtn_GrpBtnReduce.interactable = self.curRaidTimes ~= 1
  self.ui.mBtn_GrpBtnIncrease.interactable = self.curRaidTimes ~= self.maxValue
end
function UIRaidDialog:refreshCostText()
  self.ui.mText_CostNum.text = self.stageData.stamina_cost * self.curRaidTimes
  if self:isStaminaEnough(self.curRaidTimes) then
    self.ui.mText_CostNum.color = Color.black
  else
    self.ui.mText_CostNum.color = ColorUtils.RedColor
  end
end
function UIRaidDialog:refreshCostIcon()
  local valid = self.stageData.stamina_cost > 0 and 0 < self.stageData.cost_item
  setactive(self.ui.mTrans_CostItem, valid)
  if valid then
    self.ui.mImage_CostItem.sprite = IconUtils.GetItemIconSprite(self.stageData.cost_item)
  end
end
function UIRaidDialog:onClickClose()
  self:closeSelf()
end
function UIRaidDialog:onClickIncrease()
  if self.curRaidTimes >= self.maxValue then
    local hint = TableData.GetHintById(601)
    CS.PopupMessageManager.PopupString(hint)
    return
  end
  if self.curRaidTimes >= TableData.GlobalSystemData.RaidOnetimeLimit then
    local hint = TableData.GetHintById(609)
    CS.PopupMessageManager.PopupString(hint)
    return
  end
  self:changeRaidTimes(1)
end
function UIRaidDialog:onClickReduce()
  self:changeRaidTimes(-1)
end
function UIRaidDialog:onSliderValueChanged()
  local delta = math.ceil(self.ui.mSlider.value) - self.curRaidTimes
  self:changeRaidTimes(delta)
end
function UIRaidDialog:onClickStartRaid()
  if self.curRaidTimes == 0 then
    local hint = TableData.GetHintById(601)
    CS.PopupMessageManager.PopupString(hint)
    return
  end
  if not TipsManager.CheckStaminaIsEnoughOnly(self.stageData.stamina_cost * self.curRaidTimes) then
    return
  end
  if self.simEntranceData.id == StageType.CashStage.value__ then
    local itemDataTable = {}
    local gradeGroupId = self:getGradeGroupId()
    local cashGradeDataList = NetCmdStageRatingData:GetSortedCashGradeDataList(gradeGroupId)
    for i, cashGradeData in pairs(cashGradeDataList) do
      for itemId, count in pairs(cashGradeData.AwardDropViewList) do
        table.insert(itemDataTable, {ItemId = itemId, Count = count})
      end
    end
    for i, itemInfo in ipairs(itemDataTable) do
      if TipsManager.CheckItemIsOverflow(itemInfo.ItemId, itemInfo.Count, true) then
        return true
      end
    end
  end
  local sendRaidCmd = function()
    self.ui.mBtn_BtnConfirm.interactable = false
    NetCmdRaidData:SendRaidCmd(self.stageData.Id, self.curRaidTimes, function(ret)
      self:onResponseRaid(ret)
    end)
  end
  local remainingExtraDropTimes = self:getExtraDropTimes()
  if remainingExtraDropTimes == -1 or remainingExtraDropTimes == 0 then
    if self:checkNormalDropIsOverflow() then
      return
    end
    sendRaidCmd()
  elseif remainingExtraDropTimes < self.curRaidTimes then
    local keyTable = {
      AccountNetCmdHandler.Uid,
      "TodayExtraTimes",
      CGameTime.CurGameDateTime.tm_year,
      CGameTime.CurGameDateTime.tm_mon,
      CGameTime.CurGameDateTime.tm_mday,
      self.simEntranceData.id
    }
    local key = table.concat(keyTable)
    local saveStr = PlayerPrefs.GetString(key)
    if saveStr == "" then
      local todayTipsParam = {}
      todayTipsParam[1] = TableData.GetHintById(103095)
      todayTipsParam[2] = function()
        PlayerPrefs.SetString(key, "save")
        if self:checkNormalDropAndMoreDropIsOverflow(remainingExtraDropTimes) then
          return
        end
        sendRaidCmd()
      end
      todayTipsParam[3] = nil
      todayTipsParam[4] = nil
      UIManager.OpenUIByParam(UIDef.UIComTodayTipsDialog, todayTipsParam)
    else
      if self:checkNormalDropAndMoreDropIsOverflow(remainingExtraDropTimes) then
        return
      end
      sendRaidCmd()
    end
  else
    if self:checkNormalDropAndMoreDropIsOverflow(remainingExtraDropTimes - self.curRaidTimes) then
      return
    end
    sendRaidCmd()
  end
end
function UIRaidDialog:changeRaidTimes(delta)
  local targetValue = self.curRaidTimes + delta
  if targetValue > self.maxValue then
    targetValue = self.maxValue
  elseif targetValue < 1 then
    targetValue = 1
  end
  self.curRaidTimes = targetValue
  self:onRiadTimesChanged()
end
function UIRaidDialog:onRiadTimesChanged()
  self:refreshCurValueText()
  self:refreshSliderValue()
  self:refreshSliderBtn()
  self:refreshCostText()
end
function UIRaidDialog:onClickCancel()
  self:closeSelf()
end
function UIRaidDialog:onResponseRaid(ret)
  if ret ~= ErrorCodeSuc then
    return
  end
  self:closeSelf()
  local param = {
    OnDuringEndCallback = function()
      self:onDuringEnd()
    end
  }
  UIManager.OpenUIByParam(UIDef.UIRaidDuringPanel, param)
  if self.onClickStartRaidCallback then
    self.onClickStartRaidCallback()
  end
end
function UIRaidDialog:closeSelf()
  UIManager.CloseUI(UIDef.UIRaidDialog)
end
function UIRaidDialog:onDuringEnd()
  UIRaidReceivePanel.OpenWithCheckPopupDownLeftTips()
  MessageSys:SendMessage(UIEvent.OnRaidDuringEnd, self.simTypeId)
end
function UIRaidDialog:isStaminaEnough(count)
  local cost = count * self.stageData.StaminaCost
  local total = GlobalData.GetStaminaResourceItemCount(GlobalConfig.StaminaId)
  if cost > total then
    return false
  end
  return true
end
function UIRaidDialog:getRemainingChallengeTimes()
  if not self.simEntranceData then
    gferror("数据为空!")
    return 0
  end
  if self.simEntranceData.ItemId == 0 then
    return -1
  end
  return NetCmdItemData:GetNetItemCount(self.simEntranceData.ItemId)
end
function UIRaidDialog:getExtraDropTimes()
  if not self.simEntranceData then
    return -1
  end
  if self.simEntranceData.ExtraDropCost == 0 then
    return -1
  end
  return NetCmdItemData:GetNetItemCount(self.simEntranceData.ExtraDropCost)
end
function UIRaidDialog:getGradeGroupId()
  if self.simResourceData.cash_group_id.Count ~= 2 then
    gferror("simResourceDataId" .. self.simResourceData.id .. "的cash_group_id 解析错误!")
    return 0
  end
  return self.simResourceData.cash_group_id[1]
end
function UIRaidDialog:checkNormalDropIsOverflow()
  if not self.stageData then
    return true
  end
  local itemDataTable = {}
  local normalDropList = self.stageData.NormalDropList
  for i = 0, normalDropList.Count - 1 do
    local dropPackageId = normalDropList[i]
    local dropPackageData = TableData.listDropPackageDatas:GetDataById(dropPackageId)
    for i = 0, dropPackageData.args.Count - 1 do
      local args = dropPackageData.args[i]
      local splitArgs = string.split(args, ":")
      if #splitArgs == 3 then
        local itemId = tonumber(splitArgs[1])
        local num = tonumber(splitArgs[2]) * self.curRaidTimes
        if itemDataTable[itemId] then
          itemDataTable[itemId] = itemDataTable[itemId] + num
        else
          itemDataTable[itemId] = num
        end
      end
    end
  end
  for itemId, num in pairs(itemDataTable) do
    if TipsManager.CheckItemIsOverflow(itemId, num, true) then
      return true
    end
  end
  return false
end
function UIRaidDialog:checkNormalDropAndMoreDropIsOverflow(extraDropTimes)
  if not self.stageData then
    return true
  end
  local itemDataTable = {}
  local normalDropList = self.stageData.NormalDropList
  for i = 0, normalDropList.Count - 1 do
    local dropPackageId = normalDropList[i]
    local dropPackageData = TableData.listDropPackageDatas:GetDataById(dropPackageId)
    for j = 0, dropPackageData.args.Count - 1 do
      local args = dropPackageData.args[j]
      local splitArgs = string.split(args, ":")
      if #splitArgs == 3 then
        local itemId = tonumber(splitArgs[1])
        local num = tonumber(splitArgs[2]) * self.curRaidTimes
        if itemDataTable[itemId] then
          itemDataTable[itemId] = itemDataTable[itemId] + num
        else
          itemDataTable[itemId] = num
        end
      end
    end
  end
  local moreDropList = self.stageData.MoreDropList
  for i = 0, moreDropList.Count - 1 do
    local dropPackageId = moreDropList[i]
    local dropPackageData = TableData.listDropPackageDatas:GetDataById(dropPackageId)
    for j = 0, dropPackageData.args.Count - 1 do
      local args = dropPackageData.args[j]
      local splitArgs = string.split(args, ":")
      if #splitArgs == 3 then
        local itemId = tonumber(splitArgs[1])
        local num = tonumber(splitArgs[2]) * extraDropTimes
        if itemDataTable[itemId] then
          itemDataTable[itemId] = itemDataTable[itemId] + num
        else
          itemDataTable[itemId] = num
        end
      end
    end
  end
  if itemDataTable[2] then
    itemDataTable[2] = itemDataTable[2] + self.stageData.Coin * self.curRaidTimes
  else
    itemDataTable[2] = self.stageData.Coin * self.curRaidTimes
  end
  for itemId, num in pairs(itemDataTable) do
    if TipsManager.CheckItemIsOverflow(itemId, num, true) then
      return true
    end
  end
  return false
end
