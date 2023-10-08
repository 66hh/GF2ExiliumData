UIBattleIndexResourcesCard = class("UIBattleIndexResourcesCard", UIBaseCtrl)
function UIBattleIndexResourcesCard:InitCtrl(parent, template)
  local go = template and UIUtils.InstantiateByTemplate(template, parent) or self:Instantiate("BattleIndex/Btn_BattleIndexDailyItem.prefab", parent)
  self:SetRoot(go.transform)
  self.ui = UIUtils.GetUIBindTable(self.mUIRoot)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BattleIndexDailyItem.gameObject, function()
    self:onClickSelf()
  end)
end
function UIBattleIndexResourcesCard:SetData(simCombatEntranceData, index)
  self.simCombatEntranceData = simCombatEntranceData
  self.index = index
  self.simCombatTypeId = self.simCombatEntranceData.label_id[0]
  self.simCombatTypeData = TableDataBase.listSimCombatTypeDatas:GetDataById(self.simCombatTypeId)
end
function UIBattleIndexResourcesCard:Refresh()
  if not self.simCombatEntranceData then
    return
  end
  self.ui.mText_Title.text = self.simCombatEntranceData.name.str
  self.ui.mImage_Logo.sprite = IconUtils.GetStageIcon(self.simCombatEntranceData.image)
  self.ui.mImage_SmallLogo.sprite = IconUtils.GetStageIcon(self.simCombatEntranceData.icon)
  if self.index < 9 then
    self.ui.mText_Id.text = TableData.GetHintById(103092, "0" .. self.index)
  else
    self.ui.mText_Id.text = TableData.GetHintById(103093, self.index)
  end
  local isUnLock = AccountNetCmdHandler:CheckSystemIsUnLock(self.simCombatEntranceData.unlock)
  setactive(self.ui.mTrans_LockedIcon, not isUnLock)
  if not isUnLock then
    local unlockData = TableData.listUnlockDatas:GetDataById(self.simCombatEntranceData.unlock)
    if unlockData then
      local str = UIUtils.CheckUnlockPopupStr(unlockData)
      self.ui.mText_UnLockTips.text = str
    end
  end
  self.ui.mImage_ItemIcon.sprite = IconUtils.GetItemIconSprite(self.simCombatEntranceData.drop_item)
  local needRedPoint = NetCmdSimulateBattleData:CheckSimResourcesRedPoint(self.simCombatEntranceData.id)
  setactivewithcheck(self.ui.mObj_RedPoint, needRedPoint)
  self:refreshTimes()
end
function UIBattleIndexResourcesCard:AddClickListener(clickCallback)
  self.onClickCallback = clickCallback
end
function UIBattleIndexResourcesCard:OnRelease()
  self.onClickCallback = nil
  self.simCombatEntranceData = nil
  self.index = nil
  self.ui = nil
  self.super.OnRelease(self)
end
function UIBattleIndexResourcesCard:CheckShowHint()
  if self.simCombatEntranceData.label_id.Count <= 1 then
    return false
  end
  local cacheSimType = TableDataBase.listSimCombatTypeDatas:GetDataById(self.simCombatEntranceData.label_id[0])
  for i = 1, self.simCombatEntranceData.label_id.Count - 1 do
    local id = self.simCombatEntranceData.label_id[i]
    local simTypeData = TableDataBase.listSimCombatTypeDatas:GetDataById(id)
    if simTypeData.extra_drop_cost ~= cacheSimType.extra_drop_cost then
      return true
    end
  end
  return false
end
function UIBattleIndexResourcesCard:refreshTimes()
  setactive(self.ui.mTrans_GrpTimes, false)
  setactive(self.ui.mTrans_GrpExtraReward, false)
  if self:CheckShowHint() then
    setactive(self.ui.mTrans_GrpExtraReward, true)
    self.ui.mText_GrpExtraReward.text = TableData.GetHintById(103161)
    return
  end
  local simTypeData = self.simCombatTypeData
  local timerData = TableData.listTimerDatas:GetDataById(simTypeData.extra_drop_timer)
  local time
  if timerData == nil or simTypeData.extra_drop_cost == 0 then
  elseif timerData.RecoveryItems:TryGetValue(simTypeData.extra_drop_cost) then
    time = timerData.RecoveryItems[simTypeData.extra_drop_cost]
  end
  setactive(self.ui.mTrans_GrpExtraReward, true)
  setactive(self.ui.mText_GrpExtraReward, true)
  setactive(self.ui.mText_GrpExtraRewardMax, false)
  if self.simCombatEntranceData.id == 20 then
    self.ui.mText_GrpExtraReward.text = string_format(TableData.GetHintById(103161), TableData.GetHintById(103002))
  elseif self.simCombatEntranceData.id == 21 then
    self.ui.mText_GrpExtraReward.text = string_format(TableData.GetHintById(103161), TableData.GetHintById(103003))
  elseif self.simCombatEntranceData.id == 22 then
    self.ui.mText_GrpExtraReward.text = string_format(TableData.GetHintById(103161), TableData.GetHintById(103163))
  elseif self.simCombatEntranceData.id == 31 then
    self.ui.mText_GrpExtraReward.text = string_format(TableData.GetHintById(103161), TableData.GetHintById(103162))
  elseif self.simCombatEntranceData.id == 41 then
    self.ui.mText_GrpExtraReward.text = string_format(TableData.GetHintById(103161), TableData.GetHintById(103164))
  end
  if simTypeData.extra_drop_cost ~= 0 and time then
    setactive(self.ui.mTrans_GrpExtraReward, true)
    local itemData = TableData.listItemDatas:GetDataById(simTypeData.extra_drop_cost, true)
    if not itemData then
      return
    end
    local itemName = itemData.name.str
    local haveNum = NetCmdItemData:GetNetItemCount(simTypeData.extra_drop_cost)
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
      self.ui.mText_GrpExtraRewardMax.text = itemName .. "<color=#F0AF14>" .. haveNum .. "</color>/" .. time
    else
      self.ui.mText_GrpExtraRewardMax.text = itemName .. haveNum .. "/" .. time
    end
    if haveNum == 0 then
      self:ChallengeTime()
    end
  else
    self:ChallengeTime()
  end
end
function UIBattleIndexResourcesCard:ChallengeTime()
  local entranceData = self.simCombatEntranceData
  local timerData = TableData.listTimerDatas:GetDataById(entranceData.item_times)
  local time = 0
  if timerData and timerData.RecoveryItems:TryGetValue(entranceData.item_id) then
    time = timerData.RecoveryItems[entranceData.item_id]
  end
  setactive(self.ui.mTrans_GrpExtraReward, false)
  setactive(self.ui.mTrans_GrpTimes, true)
  setactive(self.ui.mText_GrpTimesMax, false)
  setactive(self.ui.mText_GrpTimes, true)
  if self.simCombatEntranceData.id == 20 then
    self.ui.mText_GrpTimes.text = string_format(TableData.GetHintById(103161), TableData.GetHintById(103002))
  elseif self.simCombatEntranceData.id == 21 then
    self.ui.mText_GrpTimes.text = string_format(TableData.GetHintById(103161), TableData.GetHintById(103003))
  elseif self.simCombatEntranceData.id == 22 then
    self.ui.mText_GrpTimes.text = string_format(TableData.GetHintById(103161), TableData.GetHintById(103163))
  elseif self.simCombatEntranceData.id == 31 then
    self.ui.mText_GrpTimes.text = string_format(TableData.GetHintById(103161), TableData.GetHintById(103162))
  elseif self.simCombatEntranceData.id == 41 then
    self.ui.mText_GrpTimes.text = string_format(TableData.GetHintById(103161), TableData.GetHintById(103164))
  end
  if entranceData.item_id ~= 0 then
    setactive(self.ui.mTrans_GrpExtraReward, false)
    setactive(self.ui.mTrans_GrpTimes, true)
    setactive(self.ui.mText_GrpTimesMax, true)
    local itemData = TableData.listItemDatas:GetDataById(entranceData.item_id, true)
    if not itemData then
      return
    end
    local itemName = itemData.name.str
    local haveNum = NetCmdItemData:GetNetItemCount(entranceData.item_id)
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
          if monthCardData.ItemFreshInit:ContainsKey(entranceData.item_id) then
            maxCount = maxCount + monthCardData.ItemFreshInit[entranceData.item_id]
          end
        end
      end
      self.ui.mText_GrpTimesMax.text = itemName .. "<color=#F0AF14>" .. haveNum .. "</color>/" .. time
    else
      self.ui.mText_GrpTimesMax.text = itemName .. haveNum .. "/" .. time
    end
  end
end
function UIBattleIndexResourcesCard:SetNumShow(str)
  self.ui.mText_NumShow.text = str
end
function UIBattleIndexResourcesCard:onClickSelf()
  if self.onClickCallback then
    self.onClickCallback(self.simCombatEntranceData)
  end
end
