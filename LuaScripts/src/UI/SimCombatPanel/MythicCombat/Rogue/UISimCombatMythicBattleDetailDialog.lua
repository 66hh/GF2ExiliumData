require("UI.UIBasePanel")
UISimCombatMythicBattleDetailDialog = class("UISimCombatMythicBattleDetailDialog", UIBasePanel)
UISimCombatMythicBattleDetailDialog.__index = UISimCombatMythicBattleDetailDialog
local self = UISimCombatMythicBattleDetailDialog
function UISimCombatMythicBattleDetailDialog:ctor(obj)
  UISimCombatMythicBattleDetailDialog.super.ctor(self)
  obj.Type = UIBasePanelType.Dialog
end
function UISimCombatMythicBattleDetailDialog:OnInit(root)
  self.super.SetRoot(UISimCombatMythicBattleDetailDialog, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UISimCombatRogueGlobal.CurItem:SetSelect(false)
    UIManager.CloseUI(UIDef.UISimCombatMythicBattleDetailDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Reset.gameObject).onClick = function()
    self:ResetRogueLevel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Start.gameObject).onClick = function()
    self:OnRogueBattleStart()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_StoreContent.gameObject).onClick = function()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BuffContent.gameObject).onClick = function()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_TopTitle.gameObject).onClick = function()
    self:ChangeTopTittleState()
  end
  self:AddListener()
end
function UISimCombatMythicBattleDetailDialog:OnShowFinish()
  self:SetData()
  CS.GF2.Message.MessageSys.Instance:SendMessage(CS.GF2.Message.RogueEvent.SetTargetBtnShow, false)
end
function UISimCombatMythicBattleDetailDialog:SetData()
  local data = UISimCombatRogueGlobal.CurItem
  UISimCombatRogueGlobal.CurItem:SetSelect(true)
  self.chapterItemData = data.chapterItemData
  self.chapterItemState = data.chapterItemState
  self.chapterItemMode = data.chapterItemMode
  self.chapterItemRogueMode = data.chapterItemRogueMode
  self.tier = data.chapterItemData.Id
  self.rogueChapterCofigData = nil
  self.progressNum = 0
  self.curAllGroupNum = 0
  self.releaseCallback = nil
  if self.enemyItemList ~= nil then
    self:ReleaseCtrlTable(self.enemyItemList, true)
  end
  self.enemyItemList = {}
  if NetCmdSimCombatRogueData.FinishRogueTier ~= 0 then
    UIManager.CloseUI(UIDef.UISimCombatMythicBattleDetailDialog)
    UISimCombatRogueGlobal.CurItem:SetSelect(false)
    return
  end
  if NetCmdSimCombatRogueData.RogueStage.FinishedGroupNum ~= 0 then
    if self.tier == NetCmdSimCombatRogueData.RogueStage.Tier and 0 < NetCmdSimCombatRogueData.RogueStage.SelectedBuffs.Count then
      self.SetContentShow(false)
      self.SelBuff(function()
        self.SetContentShow(true)
      end)
    end
    self.SelBuff()
  end
  local groupNum = NetCmdSimCombatRogueData:GetRogueLevelGroupNum(self.chapterItemRogueMode, self.tier)
  self.curAllGroupNum = groupNum
  if NetCmdSimCombatRogueData.RogueStage.Tier == self.tier then
    self.progressNum = NetCmdSimCombatRogueData.RogueStage.FinishedGroupNum
    local allProgress = NetCmdSimCombatRogueData:GetRogueLevelGroupNum(NetCmdSimCombatRogueData.RogueStage.RogueType, NetCmdSimCombatRogueData.RogueStage.Tier)
    if self.progressNum == allProgress then
      self.progressNum = 0
    end
  else
    self.progressNum = 0
  end
  if self.progressNum ~= 0 then
    self.SetLeftBottomShow(true)
  else
    setactive(self.ui.mBtn_BuffContent.gameObject, false)
    setactive(self.ui.mBtn_StoreContent.gameObject, false)
  end
  self.ui.mText_Lv.text = self.chapterItemData.Chapter
  self.ui.mText_NameLayer.text = self.chapterItemData.Name
  if self.progressNum == self.curAllGroupNum then
    self.rogueChapterCofigData = NetCmdSimCombatRogueData:GetRogueChapterCofig(self.chapterItemRogueMode, self.tier, self.progressNum)
    setactive(self.ui.mBtn_BuffContent.gameObject, false)
    setactive(self.ui.mBtn_StoreContent.gameObject, false)
  else
    self.rogueChapterCofigData = NetCmdSimCombatRogueData:GetRogueChapterCofig(self.chapterItemRogueMode, self.tier, self.progressNum + 1)
  end
  local progress = self.progressNum / self.curAllGroupNum
  local showProgress = math.ceil(progress * 100)
  local tmpStr = "{0}<color=#B2B2B2>({1}%)</color>"
  tmpStr = string_format(tmpStr, self.rogueChapterCofigData.Name, tostring(showProgress))
  self.ui.mText_ChapterName.text = tmpStr
  local tmpDescText = ""
  if self.tier == NetCmdSimCombatRogueData.RogueStage.Tier and not NetCmdSimCombatRogueData.RogueStage.IsFinished then
    tmpDescText = self.rogueChapterCofigData.Des
  elseif self.chapterItemRogueMode == UISimCombatRogueGlobal.RogueMode.Normal then
    tmpDescText = self.chapterItemData.NormalModeStageDes
  else
    tmpDescText = self.chapterItemData.ChallengeModeStageDes
  end
  self.ui.mTextFit_DescriptionText.text = tmpDescText
  self.ui.mImg_BattleDetailTopBg.sprite = UISimCombatRogueGlobal.GetRogueIcon(UISimCombatRogueGlobal.IconType.BattleDetailBg, self.tier)
  self:SetMode(self.chapterItemState, self.chapterItemMode, self.chapterItemRogueMode, self.progressNum / self.curAllGroupNum)
end
function UISimCombatMythicBattleDetailDialog:SetMode(itemState, ItemMode, rogueMode, progressNum)
  setactive(self.ui.mTrans_Locked, itemState == UISimCombatRogueGlobal.ItemState.Lock)
  setactive(self.ui.mTrans_ProgressInfo, self.tier == NetCmdSimCombatRogueData.RogueStage.Tier and not NetCmdSimCombatRogueData.RogueStage.IsFinished)
  setactive(self.ui.mTrans_Action, itemState ~= UISimCombatRogueGlobal.ItemState.Lock)
  setactive(self.ui.mTrans_Ex, ItemMode == UISimCombatRogueGlobal.ItemMode.Ex)
  setactive(self.ui.mTrans_ImgChallenge, rogueMode == UISimCombatRogueGlobal.RogueMode.Challenge)
  setactive(self.ui.mTrans_ImgChallengeBg, rogueMode == UISimCombatRogueGlobal.RogueMode.Challenge)
  setactive(self.ui.mTrans_ImgNormal, rogueMode == UISimCombatRogueGlobal.RogueMode.Normal)
  setactive(self.ui.mTrans_Normal, rogueMode == UISimCombatRogueGlobal.RogueMode.Normal)
  setactive(self.ui.mTrans_Challenge, rogueMode == UISimCombatRogueGlobal.RogueMode.Challenge)
  setactive(self.ui.mTrans_BtnStore, rogueMode == UISimCombatRogueGlobal.RogueMode.Challenge and itemState == UISimCombatRogueGlobal.ItemState.During and self.tier == NetCmdSimCombatRogueData.RogueStage.Tier)
  setactive(self.ui.mText_ChapterName.gameObject, itemState ~= UISimCombatRogueGlobal.ItemState.Lock)
  self.ui.mSlider_ProgressBar.FillAmount = progressNum
  setactive(self.ui.mBtn_Start.gameObject, itemState ~= UISimCombatRogueGlobal.ItemState.Lock and itemState ~= UISimCombatRogueGlobal.ItemState.Finish)
  setactive(self.ui.mTrans_BtnStart.gameObject, itemState ~= UISimCombatRogueGlobal.ItemState.Lock and itemState ~= UISimCombatRogueGlobal.ItemState.Finish)
  setactive(self.ui.mBtn_Reset.gameObject, itemState == UISimCombatRogueGlobal.ItemState.During)
  setactive(self.ui.mTrans_BtnReset.gameObject, itemState == UISimCombatRogueGlobal.ItemState.During)
  local btnStartText = self.ui.mTrans_BtnStart.transform:Find("Btn_Content/Root/GrpText/Text_Name"):GetComponent("Text")
  local hintId = itemState == UISimCombatRogueGlobal.ItemState.During and 111065 or 111007
  btnStartText.text = TableData.GetHintById(hintId)
  if self.chapterItemRogueMode == UISimCombatRogueGlobal.RogueMode.Challenge then
    self:SetChallengeBattle()
  end
  setactive(self.ui.mBtn_BuffContent.gameObject, false)
  setactive(self.ui.mBtn_StoreContent.gameObject, false)
  self:ChangeTopTittleState(true)
  self:UpdateEnemyList()
end
function UISimCombatMythicBattleDetailDialog:UpdateEnemyList()
  for _, enemy in ipairs(self.enemyItemList) do
    enemy:SetData(nil)
  end
  local hasEnemy = true
  local stageConfigData, stageData, enemiesList
  if NetCmdSimCombatRogueData.RogueStage.Tier ~= self.tier and self.chapterItemState ~= UISimCombatRogueGlobal.ItemState.Lock then
    if self.chapterItemRogueMode == UISimCombatRogueGlobal.RogueMode.Challenge then
      enemiesList = TableData.listRogueLevelCofigDatas:GetDataById(self.tier).EnemyListChallengeMode
    else
      enemiesList = TableData.listRogueLevelCofigDatas:GetDataById(self.tier).EnemyListNormalMode
    end
  elseif NetCmdSimCombatRogueData.RogueStage.Tier == self.tier then
    if NetCmdSimCombatRogueData.RogueStage.IsFinished then
      local rogueLevelCofigData = TableData.listRogueLevelCofigDatas:GetDataById(self.tier)
      enemiesList = rogueLevelCofigData.EnemyListNormalMode
    elseif self.chapterItemRogueMode == UISimCombatRogueGlobal.RogueMode.Challenge then
      if NetCmdSimCombatRogueData.RogueStage.NextGroupId.Count ~= 1 then
        hasEnemy = false
      else
        local stageConfigId = TableData.listStageDatas:GetDataById(NetCmdSimCombatRogueData.NextGroupId).StageConfig
        stageConfigData = TableData.listStageConfigDatas:GetDataById(stageConfigId)
        stageData = TableData.listStageDatas:GetDataById(NetCmdSimCombatRogueData.NextGroupId)
        enemiesList = stageConfigData.Enemies
      end
    else
      stageData = TableData.listStageDatas:GetDataById(NetCmdSimCombatRogueData.RogueStage.NextGroupId[0])
      local stageConfigId = stageData.StageConfig
      stageConfigData = TableData.listStageConfigDatas:GetDataById(stageConfigId)
      enemiesList = stageConfigData.Enemies
    end
  end
  if enemiesList == nil or not hasEnemy then
    setactive(self.ui.mTrans_MissionEnemyList, false)
    return
  end
  enemiesList = NetCmdSimCombatRogueData:SortEnemies(enemiesList)
  setactive(self.ui.mTrans_MissionEnemyList, true)
  for i = 0, enemiesList.Length - 1 do
    local enemyId = enemiesList[i]
    local enemyData = TableData.GetEnemyData(enemyId)
    local item = self.enemyItemList[i + 1]
    if item == nil then
      item = UICommonEnemyItem.New()
      item:InitCtrl(self.ui.mTrans_EnemyList)
      table.insert(self.enemyItemList, item)
    end
    local enemyLevel
    if stageData ~= nil then
      enemyLevel = stageData.StageClass
    else
      enemyLevel = self.chapterItemData.StageClass
      if self.chapterItemRogueMode == UISimCombatRogueGlobal.RogueMode.Normal then
        enemyLevel = enemyLevel[0]
      else
        enemyLevel = enemyLevel[1]
      end
    end
    if NetCmdSimCombatRogueData:CheckRogueEnemyById(enemyId) then
      item:SetData(enemyData, enemyLevel)
      UIUtils.GetButtonListener(item.mBtn_OpenDetail.gameObject).onClick = function()
        CS.RoleInfoCtrlHelper.Instance:InitSysEnemyData(enemyData, enemyLevel)
      end
    else
      item:SetUnKnowEnemyData(enemyData)
      UIUtils.GetButtonListener(item.mBtn_OpenDetail.gameObject).onClick = function()
        CS.PopupMessageManager.PopupString(TableData.GetHintById(111066))
      end
    end
  end
end
function UISimCombatMythicBattleDetailDialog:OnRogueBattleStart()
  if self.tier ~= NetCmdSimCombatRogueData.RogueStage.Tier then
    if not NetCmdSimCombatRogueData.RogueStage.IsFinished then
      self:ChangeRogueLevel()
    else
      NetCmdSimCombatRogueData:GetCS_SimCombatRogueReset(self.chapterItemRogueMode, self.chapterItemData.Id, function()
        self:OnRogueLevelStartBattle()
      end)
    end
  elseif not NetCmdSimCombatRogueData.RogueStage.IsFinished then
    self:OnRogueLevelStartBattle()
  else
    NetCmdSimCombatRogueData:GetCS_SimCombatRogueReset(self.chapterItemRogueMode, self.chapterItemData.Id, function()
      self:OnRogueLevelStartBattle()
    end)
  end
end
function UISimCombatMythicBattleDetailDialog:ResetRogueLevel()
  local tmpFinishedGroupNum = 0
  if not NetCmdSimCombatRogueData.RogueStage.IsFinished then
    tmpFinishedGroupNum = NetCmdSimCombatRogueData.RogueStage.FinishedGroupNum
  end
  local hint = TableData.GetHintById(111053)
  local content = MessageContent.New(hint, MessageContent.MessageType.DoubleBtn, function()
    NetCmdSimCombatRogueData:GetCS_SimCombatRogueReset(self.chapterItemRogueMode, self.chapterItemData.Id, function(ret)
      if ret == ErrorCodeSuc then
        if self.chapterItemRogueMode == UISimCombatRogueGlobal.RogueMode.Challenge and self.chapterItemData.InheritCoinCofig ~= nil and tmpFinishedGroupNum ~= 0 then
          local inheritList = string.split(self.chapterItemData.InheritCoinCofig, ",")
          local hintText = ""
          local hasRewardCoin = false
          for i, v in ipairs(inheritList) do
            local inheritArgs = string.split(v, ":")
            if tonumber(inheritArgs[1]) == 1 and tmpFinishedGroupNum >= tonumber(inheritArgs[2]) then
              hasRewardCoin = true
              hintText = tonumber(inheritArgs[3])
            end
          end
          if hasRewardCoin then
            local tmpHint = string_format(TableData.GetHintById(111041), hintText)
            local content = MessageContent.New(tmpHint, MessageContent.MessageType.DoubleBtn, function()
              self:OnResetRogueLevelCallback()
            end)
            MessageBoxPanel.Show(content)
          else
            self:OnResetRogueLevelCallback()
          end
        else
          self:OnResetRogueLevelCallback()
        end
      end
    end)
  end)
  MessageBoxPanel.Show(content)
end
function UISimCombatMythicBattleDetailDialog:OnResetRogueLevelCallback()
  CS.GF2.Message.MessageSys.Instance:SendMessage(CS.GF2.Message.RogueEvent.InitChapterList, nil)
  CS.GF2.Message.MessageSys.Instance:SendMessage(CS.GF2.Message.RogueEvent.SetCurItemCenterPos, nil)
  for _, enemy in ipairs(self.enemyItemList) do
    enemy:SetData(nil)
  end
  self:SetData()
end
function UISimCombatMythicBattleDetailDialog:ChangeRogueLevel()
  local hint = TableData.GetHintById(111016)
  local content = MessageContent.New(hint, MessageContent.MessageType.DoubleBtn, function()
    NetCmdSimCombatRogueData:GetCS_SimCombatRogueReset(self.chapterItemRogueMode, self.chapterItemData.Id, function()
      self:OnRogueLevelStartBattle()
    end)
  end)
  MessageBoxPanel.Show(content)
end
function UISimCombatMythicBattleDetailDialog:OnRogueLevelStartBattle()
  if self.chapterItemRogueMode == UISimCombatRogueGlobal.RogueMode.Normal then
    NetCmdSimCombatRogueData.NextGroupId = NetCmdSimCombatRogueData.RogueStage.NextGroupId[0]
    self.SelBuff(function()
      self.StartRogueBattle()
    end)
  else
    NetCmdSimCombatRogueData.NextGroupId = NetCmdSimCombatRogueData.RogueStage.NextGroupId[0]
    self:StartChallengeBattle()
  end
end
function UISimCombatMythicBattleDetailDialog:SetChallengeBattle()
  UISimCombatRogueGlobal.InitChallengeFuncList()
  UISimCombatRogueGlobal.AddChallengeFuncList("TeamConfirm", self.TeamConfirm)
  if NetCmdSimCombatRogueData.SelNextGroupId ~= 0 then
    NetCmdSimCombatRogueData.NextGroupId = NetCmdSimCombatRogueData.SelNextGroupId
  else
    UISimCombatRogueGlobal.AddChallengeFuncList("SelMode", self.SelMode)
  end
  UISimCombatRogueGlobal.AddChallengeFuncList("SelBuff", self.SelBuff, function()
    UISimCombatRogueGlobal.NextChallengeFuncList()
  end)
  UISimCombatRogueGlobal.AddChallengeFuncList("RogueFindEx", self.RogueFindEx)
  UISimCombatRogueGlobal.AddChallengeFuncList("StartRogueBattle", self.StartRogueBattle)
end
function UISimCombatMythicBattleDetailDialog:StartChallengeBattle()
  self.SetContentShow(false)
  UISimCombatRogueGlobal.ExcuteChallengeFuncList()
end
function UISimCombatMythicBattleDetailDialog.TeamConfirm()
  if self.progressNum == 0 then
    UIManager.OpenUIByParam(UIDef.UISimCombatMythicTeamDialog, self.tier)
  else
    UISimCombatRogueGlobal.NextChallengeFuncList()
  end
end
function UISimCombatMythicBattleDetailDialog.SelMode()
  if self.chapterItemRogueMode == UISimCombatRogueGlobal.RogueMode.Challenge and NetCmdSimCombatRogueData.RogueStage.NextGroupId.Count > 1 then
    UIManager.OpenUIByParam(UIDef.UISimCombatMythicModeSelDialog, self.rogueChapterCofigData.Name)
  else
    UISimCombatRogueGlobal.NextChallengeFuncList()
  end
end
function UISimCombatMythicBattleDetailDialog.SelBuff(callback)
  if self.tier == NetCmdSimCombatRogueData.RogueStage.Tier and NetCmdSimCombatRogueData.RogueStage.SelectedBuffs.Count > 0 then
    if callback then
      callback()
    end
  elseif callback then
    callback()
  end
end
function UISimCombatMythicBattleDetailDialog.RogueFindEx()
  if NetCmdSimCombatRogueData.ExId ~= 0 then
    UIManager.OpenUI(UIDef.UISimCombatMythicFindExDialog)
  else
    UISimCombatRogueGlobal.NextChallengeFuncList()
  end
end
function UISimCombatMythicBattleDetailDialog.StartRogueBattle()
  SceneSys:OpenBattleSceneForRogue(TableData.listStageDatas:GetDataById(NetCmdSimCombatRogueData.NextGroupId))
end
function UISimCombatMythicBattleDetailDialog:ChangeTopTittleState(boolean)
  if boolean == nil then
    boolean = not self.ui.mTrans_Description.gameObject.activeSelf
  end
  self.ui.mAnimator_TopTitle:SetBool("Selected", not boolean)
  setactive(self.ui.mTrans_Description, boolean)
end
function UISimCombatMythicBattleDetailDialog.SetContentShow(boolean)
  if boolean then
    self.ui.mAnimator_Root:SetTrigger("FadeIn")
  else
    self.ui.mAnimator_Root:SetTrigger("FadeOut")
  end
end
function UISimCombatMythicBattleDetailDialog.SetLeftBottomShow(boolean)
  if boolean then
    self.ui.mAnimator_Root:SetTrigger("Bottom_FadeIn")
  else
    self.ui.mAnimator_Root:SetTrigger("Bottom_FadeOut")
  end
end
function UISimCombatMythicBattleDetailDialog:OnHide()
  CS.GF2.Message.MessageSys.Instance:SendMessage(CS.GF2.Message.RogueEvent.SetTargetBtnShow, true)
  self.SetLeftBottomShow(false)
  self.isHide = true
end
function UISimCombatMythicBattleDetailDialog:OnClose()
  if self.releaseCallback then
    self.releaseCallback()
    self.releaseCallback = nil
  end
  self:ReleaseCtrlTable(self.enemyItemList)
  self:RemoveListener()
end
function UISimCombatMythicBattleDetailDialog:AddListener()
  CS.GF2.Message.MessageSys.Instance:AddListener(CS.GF2.Message.RogueEvent.SetReleaseCallback, function(message)
    self:SetReleaseCallback(message.Sender)
  end)
end
function UISimCombatMythicBattleDetailDialog:RemoveListener()
  CS.GF2.Message.MessageSys.Instance:RemoveListener(CS.GF2.Message.RogueEvent.SetReleaseCallback, function(message)
    self:SetReleaseCallback(message.Sender)
  end)
end
function UISimCombatMythicBattleDetailDialog:SetReleaseCallback(callback)
  self.releaseCallback = callback
end
