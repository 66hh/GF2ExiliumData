UISimCombatResourceTopBar = class("UISimCombatResourceTopBar", UIBaseCtrl)
function UISimCombatResourceTopBar:ctor(root)
  self:SetRoot(root.transform)
  self.ui = UIUtils.GetUIBindTable(root)
  function self.updateTabCount(sender)
    if sender.Sender then
      self:UpdateTabCount(sender.Sender)
    end
  end
  MessageSys:AddListener(UIEvent.ResouceTabClick, self.updateTabCount)
end
function UISimCombatResourceTopBar:SetData(simEntranceId, simCombatTypeId)
  self.simEntranceId = simEntranceId
  self.simCombatTypeId = simCombatTypeId
  self.simCombatEntranceData = TableDataBase.listSimCombatEntranceDatas:GetDataById(self.simEntranceId)
  self.simTypeData = TableDataBase.listSimCombatTypeDatas:GetDataById(self.simCombatTypeId)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Hint.gameObject, function()
    self:onClickHint()
  end)
  self:refreshTimes()
end
function UISimCombatResourceTopBar:UpdateTabCount(simCombatTypeId)
  if self.simEntranceId == nil then
    return
  end
  self:SetData(self.simEntranceId, simCombatTypeId)
end
function UISimCombatResourceTopBar:Refresh()
  self:refreshTitle()
  self:refreshHint()
  self:refreshTimes()
  self:refreshBg()
end
function UISimCombatResourceTopBar:OnClose()
  MessageSys:RemoveListener(UIEvent.ResouceTabClick, self.updateTabCount)
end
function UISimCombatResourceTopBar:OnRelease(isDestroy)
  self.simEntranceId = nil
  self.simCombatEntranceData = nil
  self.ui = nil
  self.super.OnRelease(self, isDestroy)
end
function UISimCombatResourceTopBar:refreshTitle()
  if not self.simCombatEntranceData then
    return
  end
  self.ui.mText_Title.text = self.simCombatEntranceData.name.str
end
function UISimCombatResourceTopBar:refreshHint()
  local isAllOpenDay = true
  for i = 0, self.simCombatEntranceData.label_id.Count - 1 do
    local simTypeId = self.simCombatEntranceData.label_id[i]
    isAllOpenDay = isAllOpenDay and NetCmdSimulateBattleData:IsOpenTime(simTypeId)
    if not isAllOpenDay then
      break
    end
  end
  setactivewithcheck(self.ui.mBtn_Hint, not isAllOpenDay)
end
function UISimCombatResourceTopBar:refreshBg()
  local simCombatTypeData = TableDataBase.listSimCombatTypeDatas:GetDataById(self.simCombatTypeId)
  self.ui.mImage_Bg.sprite = IconUtils.GetAtlasSprite(simCombatTypeData.Icon)
end
function UISimCombatResourceTopBar:refreshTimes()
  setactive(self.ui.mTrans_GrpExtra, false)
  setactive(self.ui.mTrans_GrpChallenge, false)
  setactive(self.ui.mTrans_TextDec, false)
  gfdebug(self.simCombatTypeId)
  local simTypeData = self.simTypeData
  local haveNum = NetCmdItemData:GetNetItemCount(simTypeData.extra_drop_cost)
  local timerData = TableData.listTimerDatas:GetDataById(simTypeData.extra_drop_timer)
  local time
  if timerData == nil or simTypeData.extra_drop_cost == 0 then
    setactive(self.ui.mText_GrpExtraReward, false)
  elseif timerData.RecoveryItems:TryGetValue(simTypeData.extra_drop_cost) then
    time = timerData.RecoveryItems[simTypeData.extra_drop_cost]
  end
  if simTypeData.extra_drop_cost ~= 0 and time then
    local monthCardMap = AccountNetCmdHandler:GetMonthCard()
    local haveMonCard = false
    for id, _ in pairs(monthCardMap) do
      local monthItem = TableData.listMonthCardDatas:GetDataById(id)
      if 0 < monthItem.item_fresh_init.Count then
        haveMonCard = true
      end
    end
    if haveMonCard then
      local maxCount = 0
      for monthCardId, monthCard in pairs(monthCardMap) do
        if monthCard.InvalidTime > CGameTime:GetTimestamp() then
          local monthCardData = TableDataBase.listMonthCardDatas:GetDataById(monthCardId)
          if monthCardData.ItemFreshInit:ContainsKey(simTypeData.extra_drop_cost) then
            maxCount = maxCount + monthCardData.ItemFreshInit[simTypeData.extra_drop_cost]
          end
        end
      end
      local text = "<color=#F0AF14>" .. haveNum .. "</color>/" .. time
      self.ui.mText_ExtraNum.text = text
      setactive(self.ui.mTrans_TextDec, true)
    else
      local text = "<color=#FFFFFF>" .. haveNum .. "</color>/" .. time
      self.ui.mText_ExtraNum.text = text
    end
    if haveNum ~= 0 then
      setactive(self.ui.mTrans_GrpExtra, true)
    end
  else
    local itemID = self.simCombatEntranceData.item_id
    if itemID ~= 0 then
      setactive(self.ui.mTrans_GrpChallenge, true)
      haveNum = NetCmdItemData:GetNetItemCount(itemID)
      local monthCardMap = AccountNetCmdHandler:GetMonthCard()
      local haveMonCard = false
      for id, _ in pairs(monthCardMap) do
        local monthItem = TableData.listMonthCardDatas:GetDataById(id)
        if 0 < monthItem.item_fresh_init.Count then
          haveMonCard = true
        end
      end
      if haveMonCard then
        local maxCount = 0
        for monthCardId, monthCard in pairs(monthCardMap) do
          if monthCard.InvalidTime > CGameTime:GetTimestamp() then
            local monthCardData = TableDataBase.listMonthCardDatas:GetDataById(monthCardId)
            if monthCardData.ItemFreshInit:ContainsKey(itemID) then
              maxCount = maxCount + monthCardData.ItemFreshInit[itemID]
            end
          end
        end
        local entranceData = self.simCombatEntranceData
        timerData = TableData.listTimerDatas:GetDataById(entranceData.item_times)
        time = 0
        if timerData and timerData.RecoveryItems:TryGetValue(entranceData.item_id) then
          time = timerData.RecoveryItems[entranceData.item_id]
        end
        local text = "<color=#F0AF14>" .. haveNum .. "</color>/" .. time
        self.ui.mText_ChallengeNum.text = text
        setactive(self.ui.mTrans_TextDec, true)
      else
        local entranceData = self.simCombatEntranceData
        timerData = TableData.listTimerDatas:GetDataById(entranceData.item_times)
        time = 0
        if timerData and timerData.RecoveryItems:TryGetValue(entranceData.item_id) then
          time = timerData.RecoveryItems[entranceData.item_id]
        end
        local text = "<color=#FFFFF>" .. haveNum .. "</color>/" .. time
        self.ui.mText_ChallengeNum.text = text
      end
      local title = TableData.GetHintById(self.simCombatEntranceData.display_name)
      self.ui.mText_ChallengeTitle.text = title
    end
  end
end
function UISimCombatResourceTopBar:onClickHint()
  UIManager.OpenUI(UIDef.UISimCombatDutyOpenDateDialog)
end
