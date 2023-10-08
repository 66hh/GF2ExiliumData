require("UI.BattleIndexPanel.Item.UICombatLauncherChallengeItem")
require("UI.SimCombatPanel.ResourcesCombat.UISimCombatResourceRatingSlot")
require("UI.CombatLauncherPanel.Item.UICommonEnemyItem")
require("UI.Common.UICommonItem")
require("UI.RaidAndAutoBattle.UIRaidDialog")
UISimCombatResourceStageDesc = class("UISimCombatResourceStageDesc", UIBaseCtrl)
function UISimCombatResourceStageDesc:ctor(root)
  self:SetRoot(root.transform)
  self.ui = UIUtils.GetUIBindTable(root)
  UIUtils.AddBtnClickListener(self.ui.mBtn_WinTarget.gameObject, function()
    self:OnWinTargetClick()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_MissionList.gameObject, function()
    self:onClickChallengeList()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_EnemyList.gameObject, function()
    self:onClickEnemyList()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_FirstRewardList.gameObject, function()
    self:onClickFirstRewardList()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_RewardList.gameObject, function()
    self:onClickRewardList()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Raid.gameObject, function()
    self:onClickRaid()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnStart.gameObject, function()
    self:onClickBattle()
  end)
  self.challengeSlotTable = {}
  self.ratingSlotTable = {}
  self.enemySlotTable = {}
  self.firstRewardSlotTable = {}
  self.rewardSlotTable = {}
end
function UISimCombatResourceStageDesc:SetData(simEntranceId, simResourceData, isOpenDay, curSlotIndex)
  self.simResourceData = simResourceData
  self.isOpenDay = isOpenDay
  self.curSlotIndex = curSlotIndex
  self.simEntranceData = TableDataBase.listSimCombatEntranceDatas:GetDataById(simEntranceId)
  self.recordData = NetCmdStageRecordData:GetStageRecordById(self.simResourceData.id)
  self.stageData = TableData.listStageDatas:GetDataById(self.simResourceData.id)
  self.simTypeData = TableDataBase.listSimCombatTypeDatas:GetDataById(self.simResourceData.sim_type)
end
function UISimCombatResourceStageDesc:Refresh(isRecover)
  self.ui.mText_Desc.text = self.stageData.synopsis.str
  self:setWinTargetListExpand(true)
  self:setChallengeListExpand(true, isRecover)
  self:setEnemyListExpand(true)
  self:setFirstRewardListExpand(true)
  self:setRewardListExpand(true)
  self:refreshChallengeItem()
  self:refreshEnemyItem()
  self:refreshFirstRewardItem()
  self:refreshRewardItem()
  self:refreshCostItem()
  self:refreshGrpBtn()
end
function UISimCombatResourceStageDesc:OnClose()
  self.simEntranceData = nil
  self.simResourceData = nil
  self.isOpenDay = nil
  self.simEntranceData = nil
  self.recordData = nil
  self.stageData = nil
  self.simTypeData = nil
end
function UISimCombatResourceStageDesc:OnRelease(isDestroy)
  self.ui = nil
  self.super.OnRelease(self, isDestroy)
end
function UISimCombatResourceStageDesc:refreshChallengeItem(isRecover)
  if self.simEntranceData.id == StageType.CashStage.value__ then
    self:refreshCashChallengeItem(isRecover)
  else
    self:refreshOtherChallengeItem()
  end
  self.ui.mText_WinTarget.text = self.stageData.goal.str
  setactive(self.ui.mTrans_WinTarget, self.stageData.goal_show)
end
function UISimCombatResourceStageDesc:refreshCashChallengeItem(isRecover)
  for _, slot in ipairs(self.ratingSlotTable) do
    slot:ClearData()
  end
  local cashGradeGroupId = self:getGradeGroupId()
  local cashGradeDataList = NetCmdStageRatingData:GetSortedCashGradeDataList(cashGradeGroupId, false)
  local visible = cashGradeDataList ~= nil and cashGradeDataList.Count > 0
  setactivewithcheck(self.ui.mTrans_ChallengeRoot, visible)
  if not visible then
    return
  end
  local prevPoint = NetCmdStageRatingData:GetPrevCashPoint(self.stageData.id)
  local currPoint = NetCmdStageRatingData:GetCashPoint(self.stageData.id)
  local targetLevel = 0
  local fromLevel = 0
  for i = 0, cashGradeDataList.Count - 1 do
    local slot = self.ratingSlotTable[i + 1]
    local cashGradeData = cashGradeDataList[i]
    if slot == nil then
      slot = UISimCombatResourceRatingSlot.New()
      local template = self.ui.mScrollListChild_MissionRatingItem.childItem
      local go = instantiate(template, self.ui.mScrollListChild_MissionRatingItem.transform)
      slot:SetRoot(go)
      table.insert(self.ratingSlotTable, slot)
    end
    slot:SetData(cashGradeData, self.stageData.id, i + 1)
    slot:Refresh(isRecover)
    slot:SetVisible(true)
    local state = slot:GetSlotPointState(currPoint)
    if state == 1 then
      targetLevel = i + 1
    elseif state == 2 then
      fromLevel = i + 1
    end
  end
  if fromLevel ~= targetLevel and fromLevel ~= 0 and targetLevel > fromLevel then
    self:OpenRantingSlider(fromLevel, targetLevel)
  end
  for i, slot in pairs(self.ratingSlotTable) do
    if not slot:HasData() then
      slot:SetVisible(false)
    end
  end
end
function UISimCombatResourceStageDesc:OpenRantingSlider(from, target)
  gfdebug(from .. "_" .. target)
  UIManager.OpenUIByParam(UIDef.UISimcombatGoldUpDialog, {from = from, target = target})
end
function UISimCombatResourceStageDesc:refreshOtherChallengeItem()
  for _, slot in ipairs(self.challengeSlotTable) do
    slot:SetData(nil)
  end
  setactivewithcheck(self.ui.mTrans_ChallengeRoot, true)
  local checkBit = function(value, nbit)
    local tmp1 = 2 ^ (nbit + 1)
    local tmp2 = 2 ^ nbit
    local ret = 0
    ret = value % tmp1
    ret = ret / tmp2
    if 1 <= ret then
      return 1
    else
      return 0
    end
  end
  local complete_challenge = {}
  local bitFlag = self.recordData.complete_challenge
  for i = 0, self.stageData.challenge_list.Count - 1 do
    if checkBit(bitFlag, i) == 1 then
      complete_challenge[i] = true
    else
      complete_challenge[i] = false
    end
  end
  for i = 0, self.stageData.challenge_list.Count - 1 do
    local slot = self.challengeSlotTable[i + 1]
    local challengeId = self.stageData.challenge_list[i]
    if slot == nil then
      slot = UICombatLauncherChallengeItem.New()
      local template = self.ui.mScrollListChild_MissionItem.childItem
      local go = instantiate(template, self.ui.mScrollListChild_MissionItem.transform)
      slot:InitRoot(go)
      table.insert(self.challengeSlotTable, slot)
    end
    slot:SetData(challengeId, complete_challenge[i] or false)
  end
end
function UISimCombatResourceStageDesc:refreshEnemyItem()
  for _, slot in ipairs(self.enemySlotTable) do
    slot:SetData(nil)
  end
  local stageConfig = TableData.GetStageConfigData(self.stageData.stage_config)
  local sorted = TableData.GetSortedEnemyData(stageConfig.enemies)
  local visible = sorted.Count > 0
  setactivewithcheck(self.ui.mTrans_EnemyRoot, visible)
  if not visible then
    return
  end
  for i = 0, sorted.Count - 1 do
    do
      local enemyId = sorted[i]
      local enemyData = TableData.GetEnemyData(enemyId)
      local slot = self.enemySlotTable[i + 1]
      if slot == nil then
        slot = UICommonEnemyItem.New()
        local template = self.ui.mScrollListChild_EnemyItem.childItem
        local go = instantiate(template, self.ui.mScrollListChild_EnemyItem.transform)
        slot:InitRoot(go)
        table.insert(self.enemySlotTable, slot)
      end
      slot:SetData(enemyData, self.stageData.stage_class)
      UIUtils.GetButtonListener(slot.mBtn_OpenDetail.gameObject).onClick = function()
        CS.RoleInfoCtrlHelper.Instance:InitSysEnemyData(enemyData, self.stageData.stage_class)
      end
    end
  end
end
function UISimCombatResourceStageDesc:refreshFirstRewardItem()
  for _, slot in ipairs(self.firstRewardSlotTable) do
    slot:SetData(nil)
  end
  local dropTable = {}
  local isFirstOfStageBattle = self:isFirstOfStageBattle()
  if isFirstOfStageBattle then
    for itemId, count in pairs(self.stageData.first_reward) do
      table.insert(dropTable, {ItemId = itemId, Count = count})
    end
  end
  local hasExtra = self:hasExtraTimes()
  if hasExtra then
    for itemId, count in pairs(self.stageData.more_drop_view_list) do
      table.insert(dropTable, {
        ItemId = itemId,
        Count = count,
        IsExtra = true
      })
    end
  end
  if isFirstOfStageBattle and self.stageData.exp_first > 0 then
    table.insert(dropTable, {
      ItemId = 200,
      Count = self.stageData.exp_first
    })
  end
  if self.simEntranceData.id == StageType.CashStage.value__ then
    local gradeGroupId = self:getGradeGroupId()
    local cashGradeDataList = NetCmdStageRatingData:GetSortedCashGradeDataList(gradeGroupId)
    local curRatingType = NetCmdStageRatingData:GetCashRating(self.stageData.id)
    for i, cashGradeData in pairs(cashGradeDataList) do
      if cashGradeData.grade_id > curRatingType.value__ then
        for itemId, count in pairs(cashGradeData.AwardDropViewList) do
          table.insert(dropTable, {
            ItemId = itemId,
            Count = count,
            CashGradeData = cashGradeData
          })
        end
      end
    end
  end
  self:sortItemTable(dropTable)
  local visible = 0 < #dropTable
  setactivewithcheck(self.ui.mTrans_FirstRewardRoot, visible)
  if not visible then
    return
  end
  for i, dropInfo in ipairs(dropTable) do
    local itemId = dropInfo.ItemId
    local count = dropInfo.Count
    local cashGradeData = dropInfo.CashGradeData
    local itemData = TableData.listItemDatas:GetDataById(itemId)
    local slot = self.firstRewardSlotTable[i + 1]
    if slot == nil then
      slot = UICommonItem.New()
      slot:InitCtrl(self.ui.mScrollListChild_FirstRewardItem.transform)
      table.insert(self.firstRewardSlotTable, slot)
    end
    if itemData.type == GlobalConfig.ItemType.Weapon then
      slot:SetData(itemData.args[0], 1, nil, true)
    elseif itemData.type == GlobalConfig.ItemType.EquipmentType then
      slot:SetEquipData(itemData.args[0], 0, nil, itemId)
    else
      slot:SetItemData(itemId, count, nil, false, nil, nil, nil)
    end
    slot:SetFirstDropVisible(true)
    local isExtra = dropInfo.IsExtra == true
    if itemData.type ~= GlobalConfig.ItemType.Weapon then
      slot:SetExtraIconVisible(isExtra or hasExtra and not isFirstOfStageBattle)
    end
    if cashGradeData ~= nil then
      local sprite = IconUtils.GetSimCombatTopRightSprite(cashGradeData.grade_id)
      slot:SetTopRightIcon(sprite)
      slot:SetTopRightIconVisible(true)
    end
  end
end
function UISimCombatResourceStageDesc:refreshRewardItem()
  for _, slot in ipairs(self.rewardSlotTable) do
    slot:SetData(nil)
  end
  local dropTable = {}
  for itemId, count in pairs(self.stageData.normal_drop_view_list) do
    table.insert(dropTable, {ItemId = itemId, Count = count})
  end
  if self.stageData.exp > 0 then
    table.insert(dropTable, {
      ItemId = 200,
      Count = self.stageData.exp
    })
  end
  if self.simEntranceData.id == StageType.CashStage.value__ then
    local gradeGroupId = self:getGradeGroupId()
    local cashGradeDataList = NetCmdStageRatingData:GetSortedCashGradeDataList(gradeGroupId)
    local curRatingType = NetCmdStageRatingData:GetCashRating(self.stageData.id)
    for i, cashGradeData in pairs(cashGradeDataList) do
      if cashGradeData.grade_id <= curRatingType.value__ then
        for itemId, count in pairs(cashGradeData.AwardDropViewList) do
          table.insert(dropTable, {
            ItemId = itemId,
            Count = count,
            CashGradeData = cashGradeData
          })
        end
      end
    end
  end
  self:sortItemTable(dropTable)
  local visible = 0 < #dropTable
  setactivewithcheck(self.ui.mTrans_RewardRoot, visible)
  if not visible then
    return
  end
  for i, dropInfo in ipairs(dropTable) do
    local itemId = dropInfo.ItemId
    local count = dropInfo.Count
    local cashGradeData = dropInfo.CashGradeData
    local itemData = TableData.listItemDatas:GetDataById(itemId)
    local slot = self.rewardSlotTable[i + 1]
    if slot == nil then
      slot = UICommonItem.New()
      slot:InitCtrl(self.ui.mScrollListChild_RewardItem.transform)
      table.insert(self.rewardSlotTable, slot)
    end
    if itemData.type == GlobalConfig.ItemType.Weapon then
      slot:SetData(itemData.args[0], 1, nil, true)
    elseif itemData.type == GlobalConfig.ItemType.EquipmentType then
      slot:SetEquipData(itemData.args[0], 0, nil, itemId)
    else
      slot:SetItemData(itemId, count, nil, false, nil, nil, nil)
    end
    slot:SetTopRightIconVisible(false)
    if cashGradeData ~= nil then
      local sprite = IconUtils.GetSimCombatTopRightSprite(cashGradeData.grade_id)
      slot:SetTopRightIcon(sprite)
      slot:SetTopRightIconVisible(true)
    end
  end
end
function UISimCombatResourceStageDesc:refreshCostItem()
  local isFirst = self:isFirstOfStageBattle()
  local costItemId = 0
  local staminaCost = 0
  if isFirst then
    costItemId = self.stageData.first_cost_item
    staminaCost = self.stageData.first_stamina_cost
  else
    costItemId = self.stageData.cost_item
    staminaCost = self.stageData.StaminaCost
  end
  local visible = 0 < costItemId and 0 < staminaCost
  setactive(self.ui.mTrans_Consume, visible)
  if not visible then
    return
  end
  local costItemNum = NetCmdItemData:GetItemCountById(costItemId)
  self.ui.mImage_CostIcon.sprite = IconUtils.GetItemIconSprite(costItemId)
  self.ui.mText_CostNum.text = staminaCost
  self.ui.mText_CostNum.color = staminaCost > costItemNum and ColorUtils.RedColor or ColorUtils.WhiteColor
end
function UISimCombatResourceStageDesc:refreshGrpBtn()
  local prevStageIsPassed = NetCmdSimulateBattleData:PrevStageIsPassed(self.simResourceData)
  local isUnlockedByCommandLevel = NetCmdSimulateBattleData:IsUnlockedByCommandLevel(self.simResourceData)
  local unlocked = prevStageIsPassed and isUnlockedByCommandLevel
  local isOpenDay = self.isOpenDay
  local canPlay = unlocked and isOpenDay
  local isShowRaidBtn = self.stageData.CanRaid ~= 0 and unlocked and canPlay
  setactivewithcheck(self.ui.mBtn_Raid, isShowRaidBtn)
  local canRaid = AFKBattleManager:CheckCanRaid(self.stageData)
  local ratingOpen = true
  if self.simEntranceData.id == StageType.CashStage.value__ then
    local gradeGroupId = self:getGradeGroupId()
    local ratingType = NetCmdStageRatingData:GetCashRating(self.stageData.id)
    local cashGradeData = NetCmdStageRatingData:GetCashGradeData(gradeGroupId, ratingType)
    ratingOpen = cashGradeData ~= nil and cashGradeData.auto_open
    setactivewithcheck(self.ui.mTrans_RaidRatingRoot, canRaid)
    if cashGradeData then
      self.ui.mImage_Rating.sprite = IconUtils.GetSimCombatTopRightSprite(cashGradeData.grade_id)
    end
  end
  self.ui.mAnimator_Raid:SetBool("Lock", not canRaid or not ratingOpen)
  setactivewithcheck(self.ui.mBtn_BtnStart, canPlay)
  setactivewithcheck(self.ui.mTrans_Locked, not canPlay)
  setactivewithcheck(self.ui.mTrans_Unlocked, false)
  if not canPlay then
    if isOpenDay then
      if not prevStageIsPassed and not isUnlockedByCommandLevel then
        self.ui.mText_Locked.text = TableData.GetHintById(103156) .. TableData.GetHintById(103157) .. TableData.GetHintById(103158, self.simResourceData.unlock_level) .. TableData.GetHintById(103159)
      elseif not prevStageIsPassed then
        self.ui.mText_Locked.text = TableData.GetHintById(103156) .. TableData.GetHintById(103159)
      elseif not isUnlockedByCommandLevel then
        self.ui.mText_Locked.text = TableData.GetHintById(103158, self.simResourceData.unlock_level) .. TableData.GetHintById(103159)
      end
    else
      self.ui.mText_Locked.text = NetCmdSimulateBattleData:GetOpenTimeText(self.simResourceData.sim_type)
    end
  end
end
function UISimCombatResourceStageDesc:setWinTargetListExpand(expand)
  setactive(self.ui.mText_WinTarget, expand)
  self.ui.mAnimator_WinTarget:SetBool("Selected", expand)
end
function UISimCombatResourceStageDesc:setChallengeListExpand(expand, isRecover)
  local animator = self.ui.mBtn_MissionList.gameObject:GetComponent(typeof(CS.UnityEngine.Animator))
  animator:SetBool("Selected", expand)
  if self.simEntranceData.id == StageType.CashStage.value__ then
    setactivewithcheck(self.ui.mScrollListChild_MissionRatingItem, expand)
  else
    setactivewithcheck(self.ui.mScrollListChild_MissionItem, expand)
  end
  self:refreshChallengeItem(isRecover)
end
function UISimCombatResourceStageDesc:setEnemyListExpand(expand)
  local animator = self.ui.mBtn_EnemyList.gameObject:GetComponent(typeof(CS.UnityEngine.Animator))
  animator:SetBool("Selected", expand)
  setactivewithcheck(self.ui.mScrollListChild_EnemyItem, expand)
end
function UISimCombatResourceStageDesc:setFirstRewardListExpand(expand)
  local animator = self.ui.mBtn_FirstRewardList.gameObject:GetComponent(typeof(CS.UnityEngine.Animator))
  animator:SetBool("Selected", expand)
  setactivewithcheck(self.ui.mScrollListChild_FirstRewardItem, expand)
end
function UISimCombatResourceStageDesc:setRewardListExpand(expand)
  local animator = self.ui.mBtn_RewardList.gameObject:GetComponent(typeof(CS.UnityEngine.Animator))
  animator:SetBool("Selected", expand)
  setactivewithcheck(self.ui.mScrollListChild_RewardItem, expand)
end
function UISimCombatResourceStageDesc:OnWinTargetClick()
  local expand = not self.ui.mText_WinTarget.gameObject.activeSelf
  self:setWinTargetListExpand(expand)
end
function UISimCombatResourceStageDesc:onClickChallengeList()
  local expand = false
  if self.simEntranceData.id == StageType.CashStage.value__ then
    expand = not self.ui.mScrollListChild_MissionRatingItem.gameObject.activeSelf
  else
    expand = not self.ui.mScrollListChild_MissionItem.gameObject.activeSelf
  end
  self:setChallengeListExpand(expand)
end
function UISimCombatResourceStageDesc:onClickEnemyList()
  local expand = not self.ui.mScrollListChild_EnemyItem.gameObject.activeSelf
  self:setEnemyListExpand(expand)
end
function UISimCombatResourceStageDesc:onClickFirstRewardList()
  local expand = not self.ui.mScrollListChild_FirstRewardItem.gameObject.activeSelf
  self:setFirstRewardListExpand(expand)
end
function UISimCombatResourceStageDesc:onClickRewardList()
  local expand = not self.ui.mScrollListChild_RewardItem.gameObject.activeSelf
  self:setRewardListExpand(expand)
end
function UISimCombatResourceStageDesc:getItemTypeOrder(type)
  if type then
    local list = TableData.GlobalSystemData.LauncherItemType
    for i = 0, list.Length - 1 do
      if list[i] == type then
        return i
      end
    end
  end
  return -1
end
function UISimCombatResourceStageDesc:isFirstOfStageBattle()
  if not self.stageData then
    gferror("stageData is nil")
    return false
  end
  return self.stageData.first_reward.Count > 0 and 0 >= self.recordData.first_pass_time
end
function UISimCombatResourceStageDesc:sortItemTable(itemTable)
  if not itemTable or type(itemTable) ~= "table" then
    return
  end
  table.sort(itemTable, function(l, r)
    local itemDataL = TableData.listItemDatas:GetDataById(l.ItemId)
    local itemDataR = TableData.listItemDatas:GetDataById(r.ItemId)
    local typeDataL = TableData.listItemTypeDescDatas:GetDataById(itemDataL.type)
    local typeDataR = TableData.listItemTypeDescDatas:GetDataById(itemDataR.type)
    if typeDataL.rank == typeDataR.rank then
      if itemDataL.type == itemDataR.type then
        if itemDataL.rank == itemDataR.Rank then
          if itemDataL.id == itemDataR.id then
            if l.CashGradeData and r.CashGradeData then
              return l.CashGradeData.GradeId > r.CashGradeData.GradeId
            elseif l.CashGradeData then
              return false
            elseif r.CashGradeData then
              return true
            else
              return false
            end
          end
          return itemDataR.id > itemDataL.id
        end
        return itemDataL.rank > itemDataR.rank
      end
      return itemDataR.type > itemDataL.type
    end
    return typeDataR.rank > typeDataL.rank
  end)
end
function UISimCombatResourceStageDesc:hasExtraTimes()
  local haveNum = 0
  if 0 < self.simTypeData.extra_drop_cost then
    haveNum = NetCmdItemData:GetItemCount(self.simTypeData.extra_drop_cost)
  end
  return 0 < haveNum
end
function UISimCombatResourceStageDesc:getGradeGroupId()
  if self.simResourceData.cash_group_id.Count ~= 2 then
    gferror("simResourceDataId" .. self.simResourceData.id .. "的cash_group_id 解析错误!")
    return 0
  end
  return self.simResourceData.cash_group_id[1]
end
function UISimCombatResourceStageDesc:CachePos()
end
function UISimCombatResourceStageDesc:onClickBattle()
  local isFirst = self:isFirstOfStageBattle()
  if isFirst then
    for itemId, count in pairs(self.stageData.first_reward) do
      if TipsManager.CheckItemIsOverflowAndStop(itemId, count) then
        return
      end
    end
  end
  local sortItem = function(prizes)
    local itemIdTable = {}
    if prizes then
      for key, v in pairs(prizes) do
        table.insert(itemIdTable, key)
      end
      table.sort(itemIdTable, function(a, b)
        local data1 = TableData.listItemDatas:GetDataById(a)
        local data2 = TableData.listItemDatas:GetDataById(b)
        local typeOrder1 = self:getItemTypeOrder(data1.type)
        local typeOrder2 = self:getItemTypeOrder(data2.type)
        if typeOrder1 == typeOrder2 then
          if data1.rank == data2.rank then
            return data1.id > data2.id
          end
          return data1.rank > data2.rank
        end
        return typeOrder1 < typeOrder2
      end)
    end
    return itemIdTable
  end
  local normalDropList = self.stageData.normal_drop_view_list
  if normalDropList.Count > 0 then
    local itemIdTable = sortItem(normalDropList)
    for _, value in ipairs(itemIdTable) do
      if TipsManager.CheckItemIsOverflowAndStop(value) then
        return
      end
    end
  end
  if 0 < self.simEntranceData.ItemId and not TipsManager.CheckTicketIsEnough(1, self.simEntranceData.ItemId) then
    return
  end
  local staminaItemId = 0
  if isFirst then
    staminaItemId = self.stageData.first_stamina_cost
  else
    staminaItemId = self.stageData.StaminaCost
  end
  if 0 < staminaItemId and not TipsManager.CheckStaminaIsEnough2(staminaItemId) then
    return
  end
  local openBattleScene = function()
    SceneSys:OpenBattleSceneForChapter(self.stageData, self.recordData, 0)
  end
  if self.simTypeData.extra_drop_cost > 0 then
    local haveNum = NetCmdItemData:GetNetItemCount(self.simTypeData.extra_drop_cost)
    if haveNum == 0 then
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
        todayTipsParam[1] = TableData.GetHintById(103053)
        todayTipsParam[2] = function()
          PlayerPrefs.SetString(key, "save")
          openBattleScene()
        end
        todayTipsParam[3] = nil
        todayTipsParam[4] = nil
        UIManager.OpenUIByParam(UIDef.UIComTodayTipsDialog, todayTipsParam)
        return
      else
        openBattleScene()
      end
    else
      openBattleScene()
    end
  else
    openBattleScene()
  end
end
function UISimCombatResourceStageDesc:onClickRaid()
  if not TipsManager.CheckCanRaid(self.stageData) then
    return
  end
  if self.simEntranceData.ItemId > 0 and not TipsManager.CheckTicketIsEnough(1, self.simEntranceData.ItemId) then
    return
  end
  if not TipsManager.CheckStaminaIsEnoughOnly(self.stageData.stamina_cost) then
    TipsManager.ShowBuyStamina()
    return
  end
  local raidParam = {
    StageId = self.stageData.id,
    SimTypeId = self.simResourceData.sim_type,
    SimResourceData = self.simResourceData,
    SimEntranceData = self.simEntranceData,
    OnClickStartRaidCallback = function()
      setactivewithcheck(self.ui.mTrans_Mask, true)
    end
  }
  UIManager.OpenUIByParam(UIDef.UIRaidDialog, raidParam)
end
