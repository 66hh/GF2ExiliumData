require("UI.BattleIndexPanel.UIBattleDetailDialogView")
require("UI.CombatLauncherPanel.Item.UICommonEnemyItem")
require("UI.UniTopbar.UITopResourceBar")
require("UI.BattleIndexPanel.Item.UICombatLauncherChallengeItem")
require("UI.CombatLauncherPanel.Item.UICommonEnemyItem")
require("UI.Common.UICommonItem")
require("UI.UniTopbar.Item.ResourcesCommonItem")
require("UI.UIBaseCtrl")
UIBattleDetailDialog = class("UIBattleDetailDialog", UIBasePanel)
UIBattleDetailDialog.__index = UIBattleDetailDialog
UIBattleDetailDialog.type = 0
UIBattleDetailDialog.stageData = nil
UIBattleDetailDialog.stageRecord = nil
UIBattleDetailDialog.stageConfig = nil
UIBattleDetailDialog.storyData = nil
UIBattleDetailDialog.customData = nil
UIBattleDetailDialog.costItemNum = 0
UIBattleDetailDialog.topCurrency = nil
UIBattleDetailDialog.canBattle = true
UIBattleDetailDialog.isFirst = false
UIBattleDetailDialog.enemyList = {}
UIBattleDetailDialog.dropList = {}
UIBattleDetailDialog.firstDropList = {}
UIBattleDetailDialog.challengeList = {}
UIBattleDetailDialog.mTier = 0
UIBattleDetailDialog.mPhase = 0
UIBattleDetailDialog.mDifficult = 0
UIBattleDetailDialog.LauncherType = {
  Chapter = 1,
  SimCombat = 2,
  Training = 3,
  Weekly = 4,
  Story = 5,
  HideStory = 6
}
function UIBattleDetailDialog.OpenBySimCombatResourceData(panelId, stageData, stageRecord, data, isUnLock, ticketCount, callback)
  UIManager.OpenUIByParam(UIDef.UIBattleDetailDialog, {
    panelId = panelId,
    stageData,
    stageRecord,
    data,
    isUnLock,
    ticketCount,
    callback = callback
  })
end
function UIBattleDetailDialog.OpenBySimCombatData(panelId, stageData, stageRecord, simData, isCanBattle, isLastCanBattle, callback, simEntranceId)
  UIManager.OpenUIByParam(UIDef.UIBattleDetailDialog, {
    panelId = panelId,
    stageData,
    stageRecord,
    simData,
    isCanBattle,
    isLastCanBattle,
    callback = callback,
    simEntranceId = simEntranceId
  })
end
function UIBattleDetailDialog.OpenByChapterData(panelId, stageData, stageRecord, storyData, isCanBattle, callback, btnClose)
  local topUI = UISystem:GetTopDialogUI()
  if topUI and topUI.UIDefine.UIType == UIDef.UIBattleDetailDialog then
    topUI.LuaLogic:Close()
  end
  UIManager.OpenUIByParam(UIDef.UIBattleDetailDialog, {
    panelId = panelId,
    stageData,
    stageRecord,
    storyData,
    isCanBattle,
    callback = callback,
    btnClose = btnClose
  })
end
function UIBattleDetailDialog.OpenBySimTrainingData(panelId, stageData, stageRecord, simData, maxLevel, callback)
  UIManager.OpenUIByParam(UIDef.UIBattleDetailDialog, {
    panelId = panelId,
    stageData,
    stageRecord,
    simData,
    maxLevel,
    callback = callback
  })
end
function UIBattleDetailDialog.OpenBySimTeachingData(panelId, teachingData, stageRecord, isCanBattle, callback)
  UIManager.OpenUIByParam(UIDef.UIBattleDetailDialog, {
    panelId = panelId,
    teachingData,
    stageRecord,
    isCanBattle,
    callback = callback
  })
end
function UIBattleDetailDialog.OpenBySimWeeklyData(panelId, stageData, stageRecord, buffNum, isOpen, isEmpty, isCanBattle, isFinished, isJumped, callback)
  UIManager.OpenUIByParam(UIDef.UIBattleDetailDialog, {
    panelId = panelId,
    stageData,
    stageRecord,
    buffNum,
    isOpen,
    isEmpty,
    isCanBattle,
    isFinished,
    isJumped,
    callback = callback
  })
end
function UIBattleDetailDialog.OpenBySimData()
  UISystem.OpenUI(UIDef.UIBattleDetailDialog)
end
function UIBattleDetailDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIBattleDetailDialog:OnInit(root, data)
  UIBattleDetailDialog.super.SetRoot(UIBattleDetailDialog, root)
  self.mView = UIBattleDetailDialogView.New()
  self.ui = {}
  self.mView:InitCtrl(root, self.ui)
  setactive(self.ui.mBtn_Close.gameObject, true)
  function self.Close()
    if data.callback ~= nil then
      data.callback()
      data.callback = nil
    end
    UIManager.CloseUI(UIDef.UIBattleDetailDialog)
  end
  MessageSys:AddListener(UIEvent.StoryCloseDetail, self.Close)
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = self.Close
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Close)
  self.mData = data
  if self.targetListOn == nil then
    self.targetListOn = true
  end
  if self.enemyListOn == nil then
    self.enemyListOn = true
  end
  if self.winTargetOn == nil then
    self.winTargetOn = true
  end
  if self.dropListOn == nil then
    self.dropListOn = true
  end
  if self.firstDropListOn == nil then
    self.firstDropListOn = true
  end
  self.ui.mRaycast_Close.raycastTarget = true
  self.btnClose = data.btnClose
  if self.btnClose then
    self.ui.mRaycast_Close.raycastTarget = false
  end
end
function UIBattleDetailDialog:OnShowStart()
  setactive(self.ui.mUIRoot, false)
  self:CheckExtraaTimeAndTickNum()
  self.showCoroutine = coroutine.create(self.Show)
  coroutine.resume(self.showCoroutine, self)
  self:SetCloseActive(false)
end
function UIBattleDetailDialog:OnRecover()
  self:OnShowStart()
end
function UIBattleDetailDialog:CheckExtraaTimeAndTickNum(simEntranceId)
  self.planData = NetCmdSimulateBattleData.PlanData
  if self.mData.panelId == UIDef.UISimCombatGunExpPanel then
    local data = TableData.listSimCombatEntranceDatas:GetDataById(21)
    if data.item_id ~= 0 then
      self.TicketItemId = data.item_id
    else
      local costData = TableData.listCostDatas:GetDataById(self.planData.Args[1])
      self.StaminaCostPercent = costData.cost_mina / 100
    end
    if data.extra_drop_cost ~= 0 then
      self.ExtraDropItemId = data.extra_drop_cost
    end
  elseif self.mData.panelId == UIDef.UISimCombatGoldPanel then
    local data = TableData.listSimCombatEntranceDatas:GetDataById(20)
    if data.item_id ~= 0 then
      self.TicketItemId = data.item_id
    else
      local costData = TableData.listCostDatas:GetDataById(self.planData.Args[0])
      self.StaminaCostPercent = costData.cost_mina / 100
    end
    if data.extra_drop_cost ~= 0 then
      self.ExtraDropItemId = data.extra_drop_cost
    end
  elseif self.mData.panelId == UIDef.UISimCombatWeaponExpPanel then
    local data = TableData.listSimCombatEntranceDatas:GetDataById(StageType.WeaponExpStage.value__)
    if data.item_id ~= 0 then
      self.TicketItemId = data.item_id
    else
      local costData = TableData.listCostDatas:GetDataById(self.planData.Args[3])
      self.StaminaCostPercent = costData.cost_mina / 100
    end
    if data.extra_drop_cost ~= 0 then
      self.ExtraDropItemId = data.extra_drop_cost
    end
  elseif self.mData.panelId == UIDef.UISimCombatDailyPanel then
    local data = TableData.listSimCombatEntranceDatas:GetDataById(StageType.DailyStage.value__)
    if data.item_id ~= 0 then
      self.TicketItemId = data.item_id
    else
      local costData = TableData.listCostDatas:GetDataById(self.planData.Args[2])
      self.StaminaCostPercent = costData.cost_mina / 100
    end
    if data.extra_drop_cost ~= 0 then
      self.ExtraDropItemId = data.extra_drop_cost
    end
  end
end
function UIBattleDetailDialog:Show()
  coroutine.yield()
  if self.mData.panelId == UIDef.UISimCombatGunExpPanel or self.mData.panelId == UIDef.UISimCombatGoldPanel then
    self:InitSimCombatResourceData(self.mData[1], self.mData[2], self.mData[3], self.mData[4], self.mData[5], self.mData[6])
  elseif self.mData.panelId == UIDef.UISimCombatDailyPanel or self.mData.panelId == UIDef.UISimCombatRunesPanel then
    self:InitSimCombatData(self.mData[1], self.mData[2], self.mData[3], self.mData[4], self.mData[5], self.mData[6])
  elseif self.mData.panelId == UIDef.UIChapterPanel or self.mData.panelId == UIDef.UIChapterHardPanel then
    self:InitChapterData(self.mData[1], self.mData[2], self.mData[3], self.mData[4])
  elseif self.mData.panelId == UIDef.UISimCombatTrainingPanel then
    self:InitSimTrainingData(self.mData[1], self.mData[2], self.mData[3], self.mData[4])
  elseif self.mData.panelId == UIDef.UISimCombatTutorialChapterPanel or self.mData.panelId == UIDef.UISimCombatRiddleChapterPanel then
    self:InitSimTeachingData(self.mData[1], self.mData[2], self.mData[3])
  elseif self.mData.panelId == UIDef.UISimCombatWeeklyPanel then
    self:InitSimWeeklyData(self.mData[1], self.mData[2], self.mData[3], self.mData[4], self.mData[5], self.mData[6], self.mData[7], self.mData[8])
  elseif self.mData.panelId == UIDef.UISimCombatProTalentPanel or self.mData.panelId == UIDef.UISimCombatDailyPanel then
    self:InitSimCombatData(self.mData[1], self.mData[2], self.mData[3], self.mData[4], self.mData[5], self.mData[6])
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Start.gameObject).onClick = function()
    self:OnBtnGoClick()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Raid.gameObject).onClick = function()
    self:OnRaidClick()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Enemy.gameObject).onClick = function()
    self:OnEnemyClick(not self.enemyListOn)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_WinTarget.gameObject).onClick = function()
    self:OnWinTargetClick(not self.winTargetOn)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Target.gameObject).onClick = function()
    self:OnTargetClick(not self.targetListOn)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Drop.gameObject).onClick = function()
    self:OnDropClick(not self.dropListOn)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_FirstDrop.gameObject).onClick = function()
    self:OnFirstDropClick(not self.firstDropListOn)
  end
end
function UIBattleDetailDialog:OnTop()
  self:UpdateStaminaInfo()
  if self.mData.panelId ~= nil then
    if self.topRes ~= nil then
      self.topRes:Release()
    end
    local resourceBarData = TableData.GetResourcesBarData(self.mData.panelId)
    if resourceBarData then
      self.topRes = UITopResourceBar.New()
      self.topRes:Init(self.ui.mUIRoot, resourceBarData.resources, resourceBarData.color == 1)
    end
  end
end
function UIBattleDetailDialog:InitData(stageData, stageRecord, isCanBattle)
  self.stageData = stageData
  self.stageRecord = stageRecord
  self.canBattle = isCanBattle
  coroutine.yield()
  self.isFirst = self.stageData.first_reward.Count > 0 and 0 >= self.stageRecord.first_pass_time
  self.stageConfig = TableData.GetStageConfigData(self.stageData.stage_config)
  if 0 < self.stageData.cost_item then
    self.costItemNum = NetCmdItemData:GetItemCountById(self.stageData.cost_item)
  else
    self.costItemNum = 0
  end
end
function UIBattleDetailDialog:InitSimTutorialData(teachingData, stageRecord, isCanBattle)
  self.stageData = teachingData.StageData
  self.stageRecord = stageRecord
  self.canBattle = isCanBattle
  self.isFirst = not teachingData.IsCompleted
  self.stageConfig = TableData.GetStageConfigData(self.stageData.stage_config)
  if self.stageData.cost_item > 0 then
    self.costItemNum = NetCmdItemData:GetItemCountById(self.stageData.cost_item)
  else
    self.costItemNum = 0
  end
end
function UIBattleDetailDialog:InitChapterData(stageData, stageRecord, storyData, isCanBattle)
  if storyData.type == GlobalConfig.StoryType.Hide then
    self.type = UIBattleDetailDialog.LauncherType.HideStory
  elseif storyData.type == GlobalConfig.StoryType.Story then
    self.type = UIBattleDetailDialog.LauncherType.Story
  else
    self.type = UIBattleDetailDialog.LauncherType.Chapter
  end
  self.storyData = storyData
  UIBattleDetailDialog.initData = coroutine.create(self.InitData)
  coroutine.resume(self.initData, self, stageData, stageRecord, isCanBattle)
  if self.mData.panelId == UIDef.UIChapterPanel then
    local isPrevStoryUnlock = NetCmdDungeonData:PrevStoryIsUnlocked(self.storyData)
    local isLevelUnlock = NetCmdDungeonData:IsUnlockedByCommandLevel(self.storyData)
    if isPrevStoryUnlock and isLevelUnlock then
      self.ui.mText_LockedDesc.text = TableData.GetHintById(103001)
    elseif not isPrevStoryUnlock and not isLevelUnlock then
      self.ui.mText_LockedDesc.text = TableData.GetHintById(103156) .. TableData.GetHintById(103157) .. TableData.GetHintById(103158, self.storyData.unlock_level) .. TableData.GetHintById(103159)
    elseif not isPrevStoryUnlock then
      self.ui.mText_LockedDesc.text = TableData.GetHintById(103156) .. TableData.GetHintById(103159)
    elseif not isLevelUnlock then
      self.ui.mText_LockedDesc.text = TableData.GetHintById(103158, self.storyData.unlock_level) .. TableData.GetHintById(103159)
    end
  elseif self.canBattle then
    if storyData.type == GlobalConfig.StoryType.Hard and storyData.daily_times > 0 and NetCmdDungeonData:DailyTimes(self.storyData.id) == storyData.daily_times then
      self.canBattle = false
      self.ui.mText_LockedDesc.text = TableData.GetHintById(103001)
    end
  else
    self.ui.mText_LockedDesc.text = TableData.GetHintById(24)
  end
  setactive(self.ui.mTrans_Start, self.canBattle)
  setactive(self.ui.mTrans_Locked, not self.canBattle)
  setactive(self.ui.mTrans_Unlocked, false)
  UIBattleDetailDialog.updatePanel = coroutine.create(self.UpdatePanel)
  coroutine.resume(self.updatePanel, self)
end
function UIBattleDetailDialog:OnUpdate()
  if self.showCoroutine and coroutine.status(self.showCoroutine) ~= "dead" then
    coroutine.resume(self.showCoroutine, self)
    return
  end
  if self.initData and coroutine.status(self.initData) ~= "dead" then
    coroutine.resume(self.initData, self, self.stageData, self.stageRecord, self.isCanBattle)
    return
  end
  if self.updatePanel and coroutine.status(self.updatePanel) ~= "dead" then
    coroutine.resume(self.updatePanel, self)
    return
  end
  if self.updateChallenge and coroutine.status(self.updateChallenge) ~= "dead" then
    coroutine.resume(self.updateChallenge, self)
  end
  if self.updateEnemy and coroutine.status(self.updateEnemy) ~= "dead" then
    coroutine.resume(self.updateEnemy, self)
    return
  end
  if self.updateDrop and coroutine.status(self.updateDrop) ~= "dead" then
    coroutine.resume(self.updateDrop, self)
    return
  end
end
function UIBattleDetailDialog:OnWinTargetClick(isOn)
  self.winTargetOn = isOn
  setactive(self.ui.mText_WinTarget, self.winTargetOn)
  self.ui.mAnimator_WinTarget:SetBool("Selected", self.winTargetOn)
end
function UIBattleDetailDialog:OnEnemyClick(isOn)
  self.enemyListOn = isOn
  setactive(self.ui.mTrans_EnemyList, self.enemyListOn)
  self.ui.mAnimator_Enemy:SetBool("Selected", self.enemyListOn)
end
function UIBattleDetailDialog:OnTargetClick(isOn)
  self.targetListOn = isOn
  setactive(self.ui.mTrans_ChallengeList, self.targetListOn)
  self.ui.mAnimator_Target:SetBool("Selected", self.targetListOn)
  self:UpdateChallengeList()
end
function UIBattleDetailDialog:OnDropClick(isOn)
  self.dropListOn = isOn
  setactive(self.ui.mTrans_DropList, self.dropListOn)
  self.ui.mAnimator_Drop:SetBool("Selected", self.dropListOn)
end
function UIBattleDetailDialog:OnFirstDropClick(isOn)
  self.firstDropListOn = isOn
  setactive(self.ui.mTrans_FirstDropList, self.firstDropListOn)
  self.ui.mAnimator_FirstDrop:SetBool("Selected", self.firstDropListOn)
end
function UIBattleDetailDialog:InitSimCombatResourceData(stageData, stageRecord, simData, isCanBattle, ticketCount)
  self.type = UIBattleDetailDialog.LauncherType.SimCombat
  self.simData = simData
  self:InitData(stageData, stageRecord, isCanBattle)
  local sequence = simData.id % 100
  if not self.canBattle then
    self.ui.mText_LockedDesc.text = TableData.GetHintById(24)
  elseif simData.unlock_level > AccountNetCmdHandler:GetLevel() then
    self.canBattle = false
    self.ui.mText_LockedDesc.text = string_format(TableData.GetHintById(103006), simData.unlock_level)
  elseif self.TicketItemId ~= nil then
    local HasPlayTimes = 0
    local MostPlayTimes = 0
    if self.mData.panelId == UIDef.UISimCombatGoldPanel then
      MostPlayTimes = TableData.listCostDatas:GetDataById(self.planData.Args[0]).cost_item
    elseif self.mData.panelId == UIDef.UISimCombatGunExpPanel then
      MostPlayTimes = TableData.listCostDatas:GetDataById(self.planData.Args[1]).cost_item
    elseif self.mData.panelId == UIDef.UISimCombatDailyPanel then
      MostPlayTimes = TableData.listCostDatas:GetDataById(self.planData.Args[2]).cost_item
    elseif self.mData.panelId == UIDef.UISimCombatProTalentPanel then
      MostPlayTimes = TableData.listCostDatas:GetDataById(self.planData.Args[3]).cost_item
    end
    local NetItemData = NetCmdItemData:GetItemCmdData(self.TicketItemId)
    local TicketItemNum = 0
    if NetItemData ~= nil then
      TicketItemNum = NetItemData.Num
    end
    if TicketItemNum < 1 then
      self.canBattle = false
      local str = TableData.GetHintById(103052)
      self.ui.mText_LockedDesc.text = string_format(str, TableData.listItemDatas:GetDataById(self.TicketItemId).name.str)
    end
    if HasPlayTimes == MostPlayTimes then
      self.canBattle = false
      self.ui.mText_LockedDesc.text = TableData.GetHintById(103007)
    end
  end
  setactive(self.ui.mTrans_Start, self.canBattle)
  setactive(self.ui.mTrans_Locked, not self.canBattle)
  setactive(self.ui.mTrans_Unlocked, false)
  UIUtils.GetButtonListener(self.ui.mBtn_Start.gameObject).onClick = function()
    self:OnBtnGoClick()
  end
  self:UpdatePanel()
end
function UIBattleDetailDialog:RefreshTimes(ticketCount)
  if ticketCount == 0 then
    self.canBattle = false
    self.ui.mText_LockedDesc.text = TableData.GetHintById(103007)
  end
  setactive(self.ui.mTrans_Start, self.canBattle)
  setactive(self.ui.mTrans_Locked, not self.canBattle)
  setactive(self.ui.mTrans_Unlocked, false)
  self:UpdatePanel()
end
function UIBattleDetailDialog:InitSimCombatData(stageData, stageRecord, simData, isCanBattle, isLastCanBattle)
  self.type = UIBattleDetailDialog.LauncherType.SimCombat
  self.simData = simData
  if isLastCanBattle == true then
    if AccountNetCmdHandler:GetLevel() < simData.unlock_level then
      self.ui.mText_LockedDesc.text = string_format(TableData.GetHintById(103006), simData.unlock_level)
      isCanBattle = false
    else
      isCanBattle = true
    end
  elseif isLastCanBattle == false then
    self.ui.mText_LockedDesc.text = TableData.GetHintById(24)
    isCanBattle = false
  end
  self:InitData(stageData, stageRecord, isCanBattle)
  if self.TicketItemId ~= nil then
    local HasPlayTimes = 0
    local MostPlayTimes = 0
    if self.mData.panelId == UIDef.UISimCombatDailyPanel then
      MostPlayTimes = TableData.listCostDatas:GetDataById(self.planData.Args[2]).cost_item
    elseif self.mData.panelId == UIDef.UISimCombatProTalentPanel then
      MostPlayTimes = TableData.listCostDatas:GetDataById(self.planData.Args[3]).cost_item
    end
    local NetItemData = NetCmdItemData:GetItemCmdData(self.TicketItemId)
    local TicketItemNum = 0
    if NetItemData ~= nil then
      TicketItemNum = NetItemData.Num
    end
    if TicketItemNum < 1 then
      self.canBattle = false
      isCanBattle = false
      local str = TableData.GetHintById(103052)
      self.ui.mText_LockedDesc.text = string_format(str, TableData.listItemDatas:GetDataById(self.TicketItemId).name.str)
    end
    if HasPlayTimes == MostPlayTimes then
      self.canBattle = false
      isCanBattle = false
      self.ui.mText_LockedDesc.text = TableData.GetHintById(103007)
    end
  end
  local sequence = 0
  if simData.sequence == nil then
    sequence = simData.id % 100
  else
    sequence = tonumber(simData.sequence)
  end
  setactive(self.ui.mTrans_Start, isCanBattle)
  setactive(self.ui.mTrans_Locked, not isCanBattle)
  setactive(self.ui.mTrans_Unlocked, false)
  UIUtils.GetButtonListener(self.ui.mBtn_Start.gameObject).onClick = function()
    self:OnBtnGoClick()
  end
  self:UpdatePanel()
end
function UIBattleDetailDialog:InitSimTrainingData(stageData, stageRecord, simData, maxLevel)
  self.type = UIBattleDetailDialog.LauncherType.Training
  self:InitData(stageData, stageRecord, true)
  self.ui.mText_LockedDesc.text = TableData.GetHintById(24)
  local isLock = simData.id > maxLevel + 1
  local isUnLock = maxLevel >= simData.id
  local isCurrent = simData.id == maxLevel + 1
  setactive(self.ui.mTrans_Start, isCurrent)
  setactive(self.ui.mTrans_Unlocked, isUnLock)
  setactive(self.ui.mTrans_Locked, isLock)
  self:UpdatePanel()
  UIUtils.GetButtonListener(self.ui.mBtn_Start.gameObject).onClick = function()
    self:OnBtnGoClick()
  end
end
function UIBattleDetailDialog:InitSimTeachingData(teachingData, stageRecord, isCanBattle)
  self.type = UIBattleDetailDialog.LauncherType.SimCombat
  self:InitSimTutorialData(teachingData, stageRecord, isCanBattle)
  if not teachingData.IsUnlocked then
    self.ui.mText_LockedDesc.text = TableData.GetHintById(24)
    isCanBattle = false
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Start.gameObject).onClick = function()
    self:OnBtnGoClick()
  end
  setactive(self.ui.mTrans_Start, isCanBattle)
  setactive(self.ui.mTrans_Locked, not isCanBattle)
  setactive(self.ui.mTrans_Unlocked, false)
  self:UpdatePanel()
end
function UIBattleDetailDialog:InitSimWeeklyData(stageData, stageRecord, buffNum, isOpen, isEmpty, isCanBattle, isFinished, isJumped)
  self.type = UIBattleDetailDialog.LauncherType.Weekly
  self:InitData(stageData, stageRecord, true)
  self.ui.mText_UnLockedDesc.text = TableData.GetHintById(80132)
  self.ui.mText_BuffNum.text = buffNum
  if isOpen == false then
    self.ui.mText_LockedDesc.text = TableData.GetHintById(108036)
    isCanBattle = false
    isFinished = false
  elseif isOpen == true then
    if isEmpty == true then
      self.ui.mText_LockedDesc.text = TableData.GetHintById(108057)
      isCanBattle = false
      isFinished = false
    elseif isEmpty == false then
      if isFinished == true then
        self.ui.mText_UnLockedDesc.text = TableData.GetHintById(108039)
        isCanBattle = false
      elseif isFinished == false then
        if isJumped == true then
          self.ui.mText_LockedDesc.text = TableData.GetHintById(108048)
          isCanBattle = false
          isFinished = false
        elseif isJumped == false then
          self.ui.mText_LockedDesc.text = TableData.GetHintById(108058)
        end
      end
    end
  end
  setactive(self.ui.mTrans_Start, isCanBattle)
  setactive(self.ui.mTrans_During, isCanBattle)
  setactive(self.ui.mTrans_Buff, true)
  setactive(self.ui.mTrans_Locked, not isCanBattle and not isFinished)
  setactive(self.ui.mTrans_Unlocked, not isCanBattle and isFinished)
  self:UpdatePanel()
  UIUtils.GetButtonListener(self.ui.mBtn_Start.gameObject).onClick = function()
    self:OnBtnGoClick()
  end
end
function UIBattleDetailDialog:UpdatePanel()
  self.ui.mImg_Bg.sprite = IconUtils.GetAtlasV2("BattleIndexBg", self.stageData.des_pic)
  self:UpdateStaminaInfo()
  coroutine.yield()
  self.ui.mText_Name0.text = self.stageData.name.str
  if self.stageData.recommanded_ce > 0 then
    self.ui.mText_Level.text = string_format(TableData.GetHintById(103086), self.stageData.recommanded_ce)
  else
    self.ui.mText_Level.text = string_format(TableData.GetHintById(803), self.stageData.recommanded_playerlevel)
  end
  self.ui.mText_Desc.text = self.stageData.synopsis.str
  if self.type == UIBattleDetailDialog.LauncherType.Story then
    self.ui.mText_BattleHint.text = TableData.GetHintById(27)
  else
    self.ui.mText_BattleHint.text = TableData.GetHintById(26)
  end
  local firstRewardShow = 0 < self.stageData.more_drop_view_list.Count and self:CheckHasExtraDrop()
  local rewardShow = 0 < self.stageData.normal_drop_view_list.Count + self.stageData.exp + self.stageData.weapon_exp
  if not self.isFirst then
    self.ui.mText_FirstRewardTopTitleTittle.text = "额外掉落"
  end
  setactive(self.ui.mTrans_EnemyContent, self.type ~= UIBattleDetailDialog.LauncherType.Story)
  setactive(self.ui.mTrans_EnemyList, self.type ~= UIBattleDetailDialog.LauncherType.Story)
  setactive(self.ui.mTrans_ChallengeList, self.type ~= UIBattleDetailDialog.LauncherType.Story and self.type ~= UIBattleDetailDialog.LauncherType.Training and self.type ~= UIBattleDetailDialog.LauncherType.HideStory)
  setactive(self.ui.mTrans_Desc, true)
  setactive(self.ui.mTrans_FirstDropContent, firstRewardShow or self.isFirst)
  setactive(self.ui.mTrans_FirstDropList, self.firstDropListOn)
  setactive(self.ui.mTrans_DropContent, rewardShow)
  setactive(self.ui.mTrans_DropList, 0 < self.stageData.normal_drop_view_list.Count and self.dropListOn)
  coroutine.yield()
  setactive(self.ui.mUIRoot, true)
  coroutine.yield()
  self:UpdateRaidBattle()
  if self.storyData and self.storyData.type == GlobalConfig.StoryType.StoryBattle then
    setactive(self.ui.mTrans_ChallengeContent, false)
  else
    setactive(self.ui.mTrans_ChallengeContent, 0 < self.stageData.challenge_list.Count)
    if 0 < self.stageData.challenge_list.Count then
      self:OnTargetClick(self.targetListOn)
    end
  end
  self.ui.mText_WinTarget.text = self.stageData.goal.str
  setactive(self.ui.mTrans_WinTarget, self.stageData.goal_show)
  self:OnWinTargetClick(self.winTargetOn)
  self:OnEnemyClick(self.enemyListOn)
  self:OnDropClick(self.dropListOn)
  self:OnFirstDropClick(self.firstDropListOn)
  self.updateChallenge = coroutine.create(self.UpdateChallengeList)
  coroutine.yield()
  self.updateEnemy = coroutine.create(self.UpdateEnemyList)
  coroutine.yield()
  self.updateDrop = coroutine.create(self.UpdateDropItemList)
  coroutine.yield()
end
function UIBattleDetailDialog:UpdateStaminaInfo()
  if self.stageData.cost_item > 0 then
    self.costItemNum = NetCmdItemData:GetItemCountById(self.stageData.cost_item)
  else
    self.costItemNum = 0
  end
  if self.StaminaCostPercent == nil then
    local costItem
    if self.mData.panelId == UIDef.UIChapterPanel or self.mData.panelId == UIDef.UIChapterHardPanel then
      if 0 >= self.stageRecord.first_pass_time and 0 < self.stageData.first_cost_item then
        costItem = self.stageData.first_cost_item
        self.stamincost = self.stageData.first_stamina_cost
      else
        costItem = self.stageData.cost_item
        self.stamincost = self.stageData.stamina_cost
      end
      if costItem ~= 0 then
        self.costItemNum = NetCmdItemData:GetItemCountById(costItem)
      end
      setactive(self.ui.mTrans_Stamina, 0 < costItem and 0 < self.stamincost)
      if 0 < costItem then
        self.costItemNum = NetCmdItemData:GetItemCountById(costItem)
        setactive(self.ui.mTrans_Stamina, 0 < costItem and 0 < self.stamincost)
        if 0 < costItem then
          self.ui.mImage_StaminaIcon.sprite = IconUtils.GetItemIconSprite(costItem)
          self.ui.mText_StaminaCost.text = self.stamincost
          self.ui.mText_StaminaCost.color = self.costItemNum < self.stamincost and ColorUtils.RedColor or ColorUtils.BlackColor
          self.ui.mText_CostHint.color = self.costItemNum < self.stamincost and ColorUtils.RedColor or ColorUtils.BlackColor
        end
      end
    else
      self.stamincost = self.stageData.stamina_cost
      setactive(self.ui.mTrans_Stamina, false)
    end
  else
    self.stamincost = math.floor(self.stageData.stamina_cost * self.StaminaCostPercent)
    setactive(self.ui.mTrans_Stamina, self.stageData.cost_item > 0 and 0 < self.stamincost)
    if self.stageData.cost_item > 0 then
      self.ui.mImage_StaminaIcon.sprite = IconUtils.GetItemIconSprite(self.stageData.cost_item)
      self.ui.mText_StaminaCost.text = self.stamincost
      self.ui.mText_StaminaCost.color = self.costItemNum < self.stamincost and ColorUtils.RedColor or ColorUtils.BlackColor
      self.ui.mText_CostHint.color = self.costItemNum < self.stamincost and ColorUtils.RedColor or ColorUtils.BlackColor
    end
  end
end
function UIBattleDetailDialog:UpdateRaidBattle()
  local isShowRaidBtn = self.stageData.CanRaid ~= 0 and self.canBattle
  setactive(self.ui.mTrans_RaidBattle, isShowRaidBtn)
  local canRaid = AFKBattleManager:CheckCanRaid(self.stageData)
  self.ui.mAnimator_Raid:SetBool("Lock", not canRaid)
end
function UIBattleDetailDialog:UpdateChallengeList()
  for _, challenge in ipairs(self.challengeList) do
    challenge:SetData(nil)
  end
  local BitAND = function(a, b)
    local p, c = 1, 0
    while 0 < a and 0 < b do
      local ra, rb = a % 2, b % 2
      if 1 < ra + rb then
        c = c + p
      end
      a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
    end
    return c
  end
  local complete_challenge = {}
  local bitFlag = self.stageRecord.complete_challenge
  for i = 0, self.stageData.challenge_list.Count - 1 do
    if 0 < BitAND(bitFlag, 1 << i) then
      complete_challenge[i] = true
    else
      complete_challenge[i] = false
    end
  end
  for i = 0, self.stageData.challenge_list.Count - 1 do
    local item = self.challengeList[i + 1]
    local challenge_id = self.stageData.challenge_list[i]
    if item == nil then
      item = UICombatLauncherChallengeItem.New()
      item:InitCtrl(self.ui.mTrans_ChallengeList.transform)
      table.insert(self.challengeList, item)
    end
    item:SetData(challenge_id, complete_challenge[i] or false)
  end
end
function UIBattleDetailDialog:UpdateEnemyList()
  for _, enemy in ipairs(self.enemyList) do
    enemy:SetData(nil)
  end
  if self.stageConfig ~= nil then
    local config = self.stageConfig
    local sorted = TableData.GetSortedEnemyData(config.enemies)
    for i = 0, sorted.Count - 1 do
      do
        local enemyId = sorted[i]
        local enemyData = TableData.GetEnemyData(enemyId)
        coroutine.yield()
        local item = self.enemyList[i + 1]
        if item == nil then
          item = UICommonEnemyItem.New()
          item:InitCtrl(self.ui.mTrans_EnemyList)
          table.insert(self.enemyList, item)
        end
        item:SetData(enemyData, self.stageData.stage_class)
        UIUtils.GetButtonListener(item.mBtn_OpenDetail.gameObject).onClick = function()
          self:OnClickEnemy(enemyId)
        end
      end
    end
  end
end
function UIBattleDetailDialog:GetItemSortNew(list)
  local itemIdList = {}
  if list then
    for _, v in pairs(list) do
      table.insert(itemIdList, v)
    end
    table.sort(itemIdList, function(a, b)
      local data1 = TableData.listItemDatas:GetDataById(a.item_id)
      local data2 = TableData.listItemDatas:GetDataById(b.item_id)
      local typeOrder1 = self:GetItemTypeOrder(data1.type)
      local typeOrder2 = self:GetItemTypeOrder(data2.type)
      if data1.rank == data2.rank then
        return data1.id > data2.id
      end
      return data1.rank > data2.rank
    end)
  end
  return itemIdList
end
function UIBattleDetailDialog:CheckHasExtraDrop()
  if self.ExtraDropItemId ~= 0 and self.ExtraDropItemId ~= nil then
    local ItemData = NetCmdItemData:GetItemCmdData(self.ExtraDropItemId)
    local ItemNum = 0
    if ItemData ~= nil then
      return 0 < ItemData.Num
    end
  end
  return false
end
function UIBattleDetailDialog:UpdateDropItemList()
  local dropList = {}
  local firstDropList = {}
  for _, item in ipairs(self.dropList) do
    gfdestroy(item)
  end
  clearallchild(self.ui.mTrans_DropList)
  for _, item in ipairs(self.firstDropList) do
    gfdestroy(item)
  end
  clearallchild(self.ui.mTrans_FirstDropList)
  self.dropList = {}
  self.firstDropList = {}
  if self.isFirst then
    local prizes = self.stageData.first_reward
    local itemList = self:GetItemSort(prizes)
    for _, value in ipairs(itemList) do
      table.insert(dropList, {
        item_id = value,
        item_num = prizes[value],
        isFirst = true
      })
    end
  end
  local normalDropList = self.stageData.normal_drop_view_list
  if normalDropList.Count > 0 then
    local itemList = self:GetItemSort(normalDropList)
    for _, value in ipairs(itemList) do
      table.insert(dropList, {
        item_id = value,
        item_num = normalDropList[value],
        isFirst = false
      })
    end
  end
  local hasExtra = self:CheckHasExtraDrop()
  if hasExtra then
    local moreDropList = self.stageData.more_drop_view_list
    if moreDropList.Count > 0 then
      local itemList = self:GetItemSort(moreDropList)
      for _, value in ipairs(itemList) do
        local num = moreDropList[value]
        table.insert(dropList, {
          item_id = value,
          item_num = num,
          isFirst = true,
          isExtra = true
        })
      end
    end
  end
  if self.isFirst and 0 < self.stageData.exp_first then
    table.insert(dropList, {
      item_id = 200,
      item_num = self.stageData.exp_first,
      isFirst = true
    })
  elseif 0 < self.stageData.exp then
    table.insert(dropList, {
      item_id = 200,
      item_num = self.stageData.exp,
      isFirst = false
    })
  end
  if self.isFirst and 0 < self.stageData.gun_exp_first then
  elseif 0 < self.stageData.gun_exp then
  end
  if self.isFirst and 0 < self.stageData.weapon_exp_first then
    table.insert(dropList, {
      item_id = 231,
      item_num = self.stageData.weapon_exp_first,
      isFirst = true
    })
  elseif 0 < self.stageData.weapon_exp then
    table.insert(dropList, {
      item_id = 231,
      item_num = self.stageData.weapon_exp,
      isFirst = false
    })
  end
  local sortedDropList = self:GetItemSortNew(dropList)
  for i, dropItem in ipairs(sortedDropList) do
    local item = self:GetAppropriateItem(dropItem.item_id, dropItem.item_num, dropItem.isFirst)
    table.insert(self.dropList, item)
    item:SetFirstDrop(dropItem.isFirst)
    local isExtra = dropItem.isExtra == true
    local itemData = TableData.GetItemData(dropItem.item_id)
    if itemData.type ~= GlobalConfig.ItemType.Weapon then
      item:SetExtraIconVisible(isExtra or hasExtra and dropItem.isFirst and not self.isFirst)
    end
    coroutine.yield()
  end
  for i, dropItem in ipairs(firstDropList) do
    local item = self:GetAppropriateItem(dropItem.item_id, dropItem.item_num, dropItem.isFirst)
    table.insert(self.firstDropList, item)
    coroutine.yield()
  end
end
function UIBattleDetailDialog:GetAppropriateItem(itemId, itemNum, isFirst)
  local itemData = TableData.GetItemData(itemId)
  if itemData == nil then
    return nil
  end
  local disableRaycaster = function()
    if self.raycaster then
      self.raycaster.enabled = false
    end
  end
  if itemData.type == GlobalConfig.ItemType.Weapon then
    local weaponInfoItem = UICommonItem.New()
    if isFirst then
      weaponInfoItem:InitCtrl(self.ui.mTrans_FirstDropList)
    else
      weaponInfoItem:InitCtrl(self.ui.mTrans_DropList)
    end
    weaponInfoItem:SetData(itemData.args[0], 1, disableRaycaster, true)
    return weaponInfoItem
  else
    local itemView = UICommonItem.New()
    if isFirst then
      itemView:InitCtrl(self.ui.mTrans_FirstDropList)
    else
      itemView:InitCtrl(self.ui.mTrans_DropList)
    end
    if itemData.type == GlobalConfig.ItemType.EquipmentType then
      local equipData = TableData.listGunEquipDatas:GetDataById(tonumber(itemData.args[0]))
      itemView:SetEquipData(itemData.args[0], 0, nil, itemId)
    else
      itemView:SetItemData(itemId, itemNum, nil, false, nil, nil, disableRaycaster)
    end
    return itemView
  end
end
function UIBattleDetailDialog:OnBtnGoClick()
  if self.isFirst then
    for item, count in pairs(self.stageData.first_reward) do
      if TipsManager.CheckItemIsOverflowAndStop(item, count) then
        return
      end
    end
  end
  local normalDropList = self.stageData.normal_drop_view_list
  if normalDropList.Count > 0 then
    local itemList = self:GetItemSort(normalDropList)
    for _, value in ipairs(itemList) do
      if TipsManager.CheckItemIsOverflowAndStop(value) then
        return
      end
    end
  end
  if self.type == UIBattleDetailDialog.LauncherType.Training then
    if not TipsManager.CheckTrainingCountIsEnough(self.stamincost) then
      return
    end
  else
    if self.StaminaCostPercent == nil and not TipsManager.CheckTicketIsEnough(1, self.TicketItemId) then
      return
    end
    if not TipsManager.CheckStaminaIsEnough(self.stamincost, false) then
      return
    end
  end
  if self.type == UIBattleDetailDialog.LauncherType.Weekly then
    self:CheckFuelIsEnough(function()
      SceneSys:OpenBattleSceneForWeekly(self.stageData, self.customData)
      self.Close()
      UISimCombatWeeklyGameplayAPanel.maskEnabled = true
    end)
  elseif self.type == UIBattleDetailDialog.LauncherType.Chapter or self.type == UIBattleDetailDialog.LauncherType.SimCombat or self.type == UIBattleDetailDialog.LauncherType.HideStory or self.type == UIBattleDetailDialog.LauncherType.Training then
    if not self.canBattle then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(608))
      return
    end
    if self.customData then
      UIStoryChapterPanel.recordStoryId = self.customData.id
    end
    if self.mData.panelId == UIDef.UIChapterPanel and 0 < self.storyData.battle_group_id then
      local firstStory = NetCmdDungeonData:GetBattleGroupStory(self.storyData.chapter, self.storyData.battle_group_id)
      local stageData = TableData.GetStageData(firstStory.stage_id)
      if stageData ~= nil then
        self.stageRecord = NetCmdStageRecordData:GetStageRecordById(stageData.id)
        self.storyData = firstStory
        self.stageData = stageData
      end
    end
    local key = AccountNetCmdHandler.Uid .. "TodayExtraTimes"
    local saveStr = PlayerPrefs.GetString(key)
    if saveStr == "" then
      if self.ExtraDropItemId ~= nil then
        local HasDropTimes = 0
        local MostDropTimes = 0
        if self.mData.panelId == UIDef.UISimCombatGoldPanel then
          MostDropTimes = TableData.listCostDatas:GetDataById(self.planData.Args[0]).extra_item
          local entranceData = TableData.listSimCombatEntranceDatas:GetDataById(StageType.CashStage.value__)
          if entranceData then
            HasDropTimes = MostDropTimes - NetCmdItemData:GetNetItemCount(entranceData.extra_drop_cost)
          end
        end
        if self.mData.panelId == UIDef.UISimCombatGunExpPanel then
          MostDropTimes = TableData.listCostDatas:GetDataById(self.planData.Args[1]).extra_item
          local entranceData = TableData.listSimCombatEntranceDatas:GetDataById(StageType.ExpStage.value__)
          if entranceData then
            HasDropTimes = MostDropTimes - NetCmdItemData:GetNetItemCount(entranceData.extra_drop_cost)
          end
        end
        if self.mData.panelId == UIDef.UISimCombatDailyPanel then
          MostDropTimes = TableData.listCostDatas:GetDataById(self.planData.Args[2]).extra_item
          local entranceData = TableData.listSimCombatEntranceDatas:GetDataById(StageType.DailyStage.value__)
          if entranceData then
            HasDropTimes = MostDropTimes - NetCmdItemData:GetNetItemCount(entranceData.extra_drop_cost)
          end
        end
        if self.mData.panelId == UIDef.UISimCombatProTalentPanel then
          MostDropTimes = TableData.listCostDatas:GetDataById(self.planData.Args[3]).extra_item
          local entranceData = TableData.listSimCombatEntranceDatas:GetDataById(StageType.DutyStage.value__)
          if entranceData then
            HasDropTimes = MostDropTimes - NetCmdItemData:GetNetItemCount(entranceData.extra_drop_cost)
          end
        end
        if MostDropTimes <= HasDropTimes then
          local data = {}
          data[1] = TableData.GetHintById(103053)
          data[2] = function()
            self.Close()
            self:StartBattle()
          end
          data[3] = "TodayExtraTimes"
          UIManager.OpenUIByParam(UIDef.UIComTodayTipsDialog, data)
          return
        else
          self:StartBattle()
        end
      else
        self:StartBattle()
      end
    else
      self:StartBattle()
    end
    self.Close()
  elseif self.type == UIBattleDetailDialog.LauncherType.Story and self.canBattle then
    local tempStoryData = self.storyData
    local tempStageData = self.stageData
    local tempFirst = self.isFirst
    local data = self.mData
    gfdebug("[Tutorial] UIBattleDetailDialog RequestStageStart")
    self.ui.mBtn_Start.interactable = false
    self.mCSPanel:Block()
    BattleNetCmdHandler:RequestStageStart(tempStageData.id, false, nil, function(ret)
      self.ui.mBtn_Start.interactable = true
      self.mCSPanel:Unblock()
      if ret ~= ErrorCodeSuc then
        gfdebug("[Tutorial] RequestStageStart 请求失败")
        return
      end
      CS.AVGController.PlayAVG(self.stageData.id, 1, function()
        if data.callback ~= nil then
          data.callback(tempFirst)
        end
        gfdebug("剧情节点")
      end)
      UIManager.CloseUI(UIDef.UIBattleDetailDialog)
    end)
  end
end
function UIBattleDetailDialog:StartBattle()
  SceneSys:OpenBattleSceneForChapter(self.stageData, self.stageRecord, self.storyData and self.storyData.id or 0)
end
function UIBattleDetailDialog:OnRaidClick()
  local data = self.stageData
  if not TipsManager.CheckCanRaid(data) then
    return
  end
  if self.raycaster then
    self.raycaster.enabled = false
  end
  if self.simData then
  elseif self.storyData then
    self:ShowRiadDialogByStory()
  end
end
function UIBattleDetailDialog:ShowRiadDialogBySim()
  if not self.simData then
    return
  end
  local simCombatEntranceData
  local simCombatEntranceDataList = TableData.listSimCombatEntranceDatas:GetList()
  for i = 0, simCombatEntranceDataList.Count - 1 do
    local simTypeIdList = simCombatEntranceDataList[i].LabelId
    for j = 0, simTypeIdList.Count - 1 do
      if simTypeIdList[j] == self.simData.sim_type then
        simCombatEntranceData = simCombatEntranceDataList[i]
        break
      end
    end
    if simCombatEntranceData then
      break
    end
  end
  if not simCombatEntranceData then
    gferror("数据为空!")
    return
  end
  local openRiadDialog = function()
    local raidParam = {
      StageId = self.stageData.id,
      SimTypeId = self.simData.sim_type,
      SimEntranceData = simCombatEntranceData
    }
    UIManager.OpenUIByParam(UIDef.UIRaidDialog, raidParam)
  end
  if 0 < simCombatEntranceData.extra_drop_cost then
    local haveNum = NetCmdItemData:GetNetItemCount(simCombatEntranceData.extra_drop_cost)
    if haveNum == 0 then
      local key = AccountNetCmdHandler.Uid .. "RaidExtraTimes"
      local saveStr = PlayerPrefs.GetString(key)
      if saveStr == "" then
        local todayTipsParam = {}
        todayTipsParam[1] = TableData.GetHintById(103053)
        todayTipsParam[2] = nil
        todayTipsParam[3] = "RaidExtraTimes"
        todayTipsParam[4] = openRiadDialog
        UIManager.OpenUIByParam(UIDef.UIComTodayTipsDialog, todayTipsParam)
      else
        openRiadDialog()
      end
    else
      openRiadDialog()
    end
  else
    openRiadDialog()
  end
end
function UIBattleDetailDialog:ShowRiadDialogByStory()
  if not self.storyData then
    return
  end
  local raidParam = {
    StageId = data.id,
    SimTypeId = self.simData.sim_type
  }
  if self.storyData.daily_times > 0 then
    raidParam.RemainingNum = self.mStoryData.daily_times - NetCmdDungeonData:DailyTimes(self.storyData.id)
  else
    raidParam.RemainingNum = -1
  end
  UIManager.OpenUIByParam(UIDef.UIRaidDialog, raidParam)
end
function UIBattleDetailDialog:IsResourceSimBat()
  return self.type == UIBattleDetailDialog.LauncherType.SimCombat
end
function UIBattleDetailDialog:OnClickEnemy(enemyId)
  if self.raycaster then
    self.raycaster.enabled = false
  end
  local enemyData = TableData.GetEnemyData(enemyId)
  CS.RoleInfoCtrlHelper.Instance:InitSysEnemyData(enemyData, self.stageData.stage_class + enemyData.add_level)
end
function UIBattleDetailDialog:RefreshItemState()
  if self.stageData.cost_item ~= 0 then
    self.costItemNum = NetCmdItemData:GetItemCountById(self.stageData.cost_item)
  end
  self.ui.mText_StaminaCost.color = self.costItemNum < self.stamincost and ColorUtils.RedColor or ColorUtils.BlackColor
  self.ui.mText_CostHint.color = self.costItemNum < self.stamincost and ColorUtils.RedColor or ColorUtils.BlackColor
end
function UIBattleDetailDialog:GetItemSort(prizes)
  local itemIdList = {}
  if prizes then
    for key, v in pairs(prizes) do
      table.insert(itemIdList, key)
    end
    table.sort(itemIdList, function(a, b)
      local data1 = TableData.listItemDatas:GetDataById(a)
      local data2 = TableData.listItemDatas:GetDataById(b)
      local typeOrder1 = self:GetItemTypeOrder(data1.type)
      local typeOrder2 = self:GetItemTypeOrder(data2.type)
      if typeOrder1 == typeOrder2 then
        if data1.rank == data2.rank then
          return data1.id > data2.id
        end
        return data1.rank > data2.rank
      end
      return typeOrder1 < typeOrder2
    end)
  end
  return itemIdList
end
function UIBattleDetailDialog:GetItemTypeOrder(type)
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
function UIBattleDetailDialog:UpdateTopStamina()
  if self.topCurrency == nil then
    self.topCurrency = ResourcesCommonItem.New()
    self.topCurrency:InitCtrl(self.ui.mTrans_TopCurrency)
    local itemData = TableData.GetItemData(self.stageData.cost_item)
    self.topCurrency:SetData({
      id = itemData.id,
      jumpID = itemData.how_to_get
    })
    MessageSys:AddListener(9007, self.RefreshStamina)
  else
    setactive(self.topCurrency.mUIRoot.gameObject, true)
  end
end
function UIBattleDetailDialog.RefreshStamina()
  if self.topCurrency ~= nil then
    self.topCurrency:UpdateData()
  end
end
function UIBattleDetailDialog:OnClose()
  self:SetCloseActive(true)
  self.type = 0
  self.stageData = nil
  self.stageRecord = nil
  self.stageConfig = nil
  self.storyData = nil
  self.customData = nil
  self.costItemNum = 0
  self.topCurrency = nil
  self.canBattle = true
  self.isFirst = false
  for _, item in ipairs(self.enemyList) do
    gfdestroy(item:GetRoot())
  end
  self.enemyList = {}
  for _, item in ipairs(self.dropList) do
    gfdestroy(item:GetRoot())
  end
  self.dropList = {}
  for _, item in ipairs(self.firstDropList) do
    gfdestroy(item:GetRoot())
  end
  self.firstDropList = {}
  for _, item in ipairs(self.challengeList) do
    gfdestroy(item:GetRoot())
  end
  self.challengeList = {}
  self.mTier = 0
  self.mPhase = 0
  self.mDifficult = 0
  self.stamincost = 0
  self.StaminaCostPercent = nil
  self.TicketItemId = nil
  self.planData = nil
  self.ExtraDropItemId = nil
  if self.topCurrency ~= nil then
    MessageSys:RemoveListener(9007, self.RefreshStamina)
    self.topCurrency = nil
  end
  MessageSys:RemoveListener(UIEvent.StoryCloseDetail, self.Close)
  self.mData = nil
  self.targetListOn = nil
  self.enemyListOn = nil
  self.winTargetOn = nil
  self.dropListOn = nil
  self.firstDropListOn = nil
end
function UIBattleDetailDialog:CheckFuelIsEnough(OpenBattleFunc)
  if TutorialSystem.IsInTutorial == false and self.stageData.BlockFunction == "" then
    local root = UISystem:GetTopDialogUI().GameObject
    local nowfuelnum = NetCmdItemData:GetResItemCount(23)
    local totalfuelnum = NetCmdItemData:GetResItemCount(24)
    if nowfuelnum < totalfuelnum and AccountNetCmdHandler.UAVHint == 0 then
      self.FuelNotEnoughPanel = UAVFuelNotEnougContent.New()
      self.FuelNotEnoughPanel:InitCtrl(root.transform)
      self.FuelNotEnoughPanel:SetData(function()
        OpenBattleFunc()
      end, root.transform)
      return
    end
  end
  OpenBattleFunc()
end
function UIBattleDetailDialog:SetCloseActive(active)
  if self.mData.panelId == UIDef.UISimCombatGunExpPanel then
    setactive(self.ui.mBtn_Close, active)
  elseif self.mData.panelId == UIDef.UISimCombatGoldPanel then
    setactive(self.ui.mBtn_Close, active)
  elseif self.mData.panelId == UIDef.UISimCombatDailyPanel then
    setactive(self.ui.mBtn_Close, active)
  end
end
