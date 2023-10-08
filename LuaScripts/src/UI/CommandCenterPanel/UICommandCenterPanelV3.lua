require("UI.CommandCenterPanel.Item.CommandCenterBottomBtn")
require("UI.CommandCenterPanel.Item.CommandCenterTopBtn")
require("UI.UIRecentActivityPanel.UIRecentActivityPanel")
require("UI.UniTopbar.UIUniTopBarPanel")
require("UI.PosterPanel.UIPosterPanel")
require("UI.PostPanelV2.UIPostBrowserPanel")
require("UI.UICommonUnlockPanel.UICommonUnlockPanel")
require("UI.CommandCenterPanel.UICommandCenterPanel")
require("UI.SimCombatPanel.ResourcesCombat.UISimCombatGlobal")
UICommandCenterPanelV3 = class("self", UIBasePanel)
UICommandCenterPanelV3.__index = UICommandCenterPanelV3
function UICommandCenterPanelV3:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.HideSceneBackground = false
  csPanel.Is3DPanel = true
  self.RedPointType = {
    RedPointConst.ChapterReward,
    RedPointConst.SimResourceStageIndex,
    RedPointConst.SimulateBattle,
    RedPointConst.Daily,
    RedPointConst.Mails,
    RedPointConst.Notice,
    RedPointConst.PlayerInfo,
    RedPointConst.PlayerCard,
    RedPointConst.Friend,
    RedPointConst.Repository,
    RedPointConst.Store,
    RedPointConst.Barracks,
    RedPointConst.Archives,
    RedPointConst.PVP,
    RedPointConst.CommandCenter,
    RedPointConst.RecentActivity,
    RedPointConst.BattlePass
  }
  self.CheckQueue = {
    None = 0,
    NickName = 1,
    Reconnection = 2,
    Poster = 3,
    Notice = 4,
    CheckIn = 5,
    Unlock = 6,
    Tutorial = 7,
    Finish = 8
  }
  self.checkStep = 0
  self.bCanClick = true
  self.mTrans_Background = nil
  self.chatTimer = nil
  self.chatRefreshTime = 0
  self.chatSpeed = 45
  self.chatDelay = 4
  self.autoRoll = nil
  self.bannerList = {}
  self.indicatorList = {}
  self.isFrist = true
  self.onClickPVP = false
  self.systemList = {}
  self.isPostJump = false
  self.conversationTimer = nil
  self.bannerCache = {}
end
function UICommandCenterPanelV3:OnInit(root, data)
  self.super.SetRoot(self, root)
  self.mUIRoot = root
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.mNowTime = 0
  self:InitCommandCenterPanelUI()
  self.chatRefreshTime = TableData.GlobalSystemData.ChatRefreshCd
  self.mShowSceneObj = true
  self:SetMaskEnable(false)
  self:InitRedPointObj()
  self:InitButtonGroup()
  function self.conversationMessage(message)
    self:ConversationMessage(message)
  end
  MessageSys:AddListener(CS.GF2.Message.UIEvent.ConversationMsg, self.conversationMessage)
  function self.conversationEndMessage(message)
    self:ConversationEndMessage(message)
  end
  MessageSys:AddListener(CS.GF2.Message.UIEvent.ConversationEndMsg, self.conversationEndMessage)
  function self.refreshInfo(message)
    self:RefreshInfo(message)
  end
  MessageSys:AddListener(CS.GF2.Message.CampaignEvent.ResInfoUpdate, self.refreshInfo)
  function self.systemUnLock(message)
    self:SystemUnLock(message)
  end
  MessageSys:AddListener(CS.GF2.Message.UIEvent.SystemUnlockEvent, self.systemUnLock)
  function self.updateJumpFunc(msg)
    self.isPostJump = true
  end
  MessageSys:AddListener(CS.GF2.Message.UIEvent.PostJump, self.updateJumpFunc)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.BattlePass, self.mItem_BattlePass.transRedPoint, nil, self.mItem_BattlePass.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Chapters, self.mItem_Battle.transRedPoint, nil, self.mItem_Battle.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Daily, self.mItem_DailyTask.transRedPoint, nil, self.mItem_DailyTask.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Notice, self.mItem_Post.transRedPoint, nil, self.mItem_Post.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Mails, self.mItem_Mail.transRedPoint, nil, self.mItem_Mail.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Barracks, self.mItem_Barrack.transRedPoint, nil, self.mItem_Barrack.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.PlayerInfo, self.mItem_PlayerInfo.transRedPoint, nil, self.mItem_PlayerInfo.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Repository, self.mItem_Repository.transRedPoint, nil, self.mItem_Repository.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Friend, self.ui.mTrans_RedPoint_Chat, nil, self.mItem_Chat.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Store, self.mItem_Exchange.transRedPoint, nil, self.mItem_Exchange.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Archives, self.mItem_Archives.transRedPoint, nil, self.mItem_Archives.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.CommandCenter, self.mItem_Adjutant.transRedPoint)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.RecentActivity, self.mItem_RecentActivity.transRedPoint)
  UIRedPointWatcher.BindRedPoint(self.mItem_Activity.transRedPoint, NewRedPointConst.Activity, function(path, num)
    self:RefreshActivityEntrance()
  end)
  self:InitGM()
  self:NickPlayerName()
end
function UICommandCenterPanelV3:RefreshActivityEntrance()
  if UIUtils.IsNullOrDestroyed(self.mUIRoot) or UIUtils.IsNullOrDestroyed(self.mItem_Activity.btn) then
    return
  end
  local isActivityUnLock = AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.Activity)
  local isShow = NetCmdOperationActivityData:HasShowingActivity()
  setactive(self.mItem_Activity.btn.gameObject, isActivityUnLock and isShow)
end
function UICommandCenterPanelV3:InitCommandCenterPanelUI()
  self.mItem_Chat = self:InitChat()
  self.mItem_Adjutant = self:InitAdjutant(self.ui.mTrans_Adjutant)
  self.mItem_PlayerInfo = self:InitAvatar(self.ui.mTrans_PlayerAvatar)
  self.mItem_BattlePass = self:InitCommandCenterTopBtn(SystemList.Battlepass, "BP")
  setactive(self.mItem_BattlePass.btn.gameObject, NetCmdBattlePassData.IsOpen and AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.Battlepass))
  self.mItem_Post = self:InitCommandCenterTopBtn(SystemList.Notice, "Post")
  self.mItem_Mail = self:InitCommandCenterTopBtn(SystemList.Mail, "Mail")
  self.mItem_Activity = self:InitCommandCenterTopBtn(SystemList.Activity, "Activity")
  self.mItem_CheckIn = self:InitCommandCenterTopBtn(SystemList.Checkin, "CheckIn")
  self.mItem_Archives = self:InitCommandCenterBottomBtn(self.ui.mBtn_ArchivesCenter, SystemList.Archives)
  self.mItem_Repository = self:InitCommandCenterBottomBtn(self.ui.mBtn_BtnRepository, SystemList.Storage)
  self.mItem_Exchange = self:InitCommandCenterBottomBtn(self.ui.mBtn_BtnStoreExchange, SystemList.StoreEnterance)
  self.mItem_Gacha = self:InitCommandCenterBottomBtn(self.ui.mBtn_BtnGashapon, SystemList.Gacha)
  self.mItem_DailyTask = self:InitCommandCenterBottomBtn(self.ui.mBtn_BtnDailyQuest, SystemList.Quest)
  self.mItem_RecentActivity = self:InitLeftRightBtn(self.ui.mBtn_Root, SystemList.RecentActivity)
  self.mItem_Barrack = self:InitLeftRightBtn(self.ui.mBtn_Root1, SystemList.Barrack)
  self.mItem_Battle = self:InitBattle(self.ui.mTrans_SimCombat, SystemList.Battle)
end
function UICommandCenterPanelV3:InitGM()
  if CS.DebugCenter.Instance:IsOn(CS.DebugToggleType.ShowCommandGMButton) then
    local GMItem = instantiate(UIUtils.GetGizmosPrefab("GameCommand/Btn_GMCommandEnter.prefab"), self.mUIRoot.transform)
    GMItem.transform:SetParent(self.ui.mTrans_GrpTop, true)
  end
end
function UICommandCenterPanelV3:UpDateDarkZoneData()
  local str = TableData.GlobalDarkzoneData.DarkzoneOpentime
  if str == "" then
    return
  end
  local strarrs = string.split(str, ",")
  local starttimeArr = string.split(strarrs[1], ":")
  local endtimeArr = string.split(strarrs[2], ":")
  self.DarkUnlockTime = starttimeArr[1] .. ":" .. starttimeArr[2] .. "~" .. endtimeArr[1] .. ":" .. endtimeArr[2]
  local nowtime = CS.CGameTime.ConvertUintToDateTime(CGameTime:GetTimestamp())
  self.StartDatetime = DateTime(nowtime.Year, nowtime.Month, nowtime.Day, System.Int32.Parse(starttimeArr[1]), System.Int32.Parse(starttimeArr[2]), nowtime.Second)
  self.EndDatetime = DateTime(nowtime.Year, nowtime.Month, nowtime.Day, System.Int32.Parse(endtimeArr[1]), System.Int32.Parse(endtimeArr[2]), 0)
end
function UICommandCenterPanelV3:CheckDarkZoneIsInOpenTime()
  local nowtime = CS.CGameTime.ConvertUintToDateTime(CGameTime:GetTimestamp())
  return true
end
function UICommandCenterPanelV3:UdpateLoungeChatRedPoint(node)
end
function UICommandCenterPanelV3:InitBanner()
  local count = PostInfoConfig.BannerDataList.Count
  local dataList = {}
  if count == 0 then
    return
  end
  for i = 0, count - 1 do
    local d = PostInfoConfig.BannerDataList[i]
    if (d.jump_id == 13001 and (NetCmdBattlePassData.BattlePassStatus == CS.ProtoObject.BattlepassType.AdvanceOne or NetCmdBattlePassData.BattlePassStatus == CS.ProtoObject.BattlepassType.AdvanceTwo)) == false then
      table.insert(dataList, d)
    end
  end
  local dataListCount = #dataList
  self:OnHideSlideShow()
  table.insert(self.indicatorList, self.ui.mTrans_Dot.gameObject)
  local instantiateIndicatorObj = function()
    return instantiate(self.ui.mTrans_Dot.gameObject, self.ui.mTrans_Indicator.transform)
  end
  if 2 < dataListCount then
    for i = 0, dataListCount - 1 do
      if 0 < i then
        table.insert(self.indicatorList, instantiateIndicatorObj())
      end
      local start = math.floor((dataListCount + 1) / 2)
      local current = start + i
      if dataListCount <= current then
        current = current - dataListCount
      end
      self:InstantiateBanner(dataList[current + 1])
    end
    self.ui.mSlideShowHelper_BannerList.startingIndex = math.floor(dataListCount / 2)
  elseif dataListCount == 2 then
    local finished = 0
    for i = 0, dataListCount - 1 do
      if 0 < i then
        table.insert(self.indicatorList, instantiateIndicatorObj())
      end
      self:InstantiateBanner(dataList[i + 1], function()
        finished = finished + 1
        if finished == 2 then
          self:InstantiateBanner(dataList[1])
          self:InstantiateBanner(dataList[2])
          self.ui.mSlideShowHelper_BannerList.startingIndex = 2
        end
      end)
    end
  else
    for i = 0, dataListCount - 1 do
      if 0 < i then
        table.insert(self.indicatorList, instantiateIndicatorObj())
      end
      self:InstantiateBanner(dataList[i + 1], function()
        self:InstantiateBanner(dataList[1])
        self:InstantiateBanner(dataList[1])
        self.ui.mSlideShowHelper_BannerList.startingIndex = 1
        self.ui.mSlideShowHelper_BannerList:SetData(1)
      end)
    end
  end
  self.ui.mSlideShowHelper_BannerList:SetData(dataListCount)
end
function UICommandCenterPanelV3:InstantiateBanner(data, callback)
  local bannerObj = instantiate(UIUtils.GetGizmosPrefab("CommandCenter/CommandcenterBanneItemV2.prefab", self))
  local button = bannerObj:GetComponent("Button")
  if data.type_id == 0 and data.extra ~= "" then
    UIUtils.GetButtonListener(button.gameObject).onClick = function()
      if string.match(data.extra, "{uid}") then
        local text = string.gsub(data.extra, "{uid}", AccountNetCmdHandler:GetUID())
        local strings = string.split(text, "?")
        CS.GF2.ExternalTools.Browsers.BrowserHandler.Show(strings[1] .. "?token=" .. string.gsub(CS.AesUtils.Encode(strings[2]), "-", ""))
      else
        CS.GF2.ExternalTools.Browsers.BrowserHandler.Show(data.extra)
      end
    end
  elseif data.type_id > 0 and 0 < data.jump_id then
    UIUtils.GetButtonListener(button.gameObject).onClick = function()
      SceneSwitch:SwitchByID(data.jump_id)
    end
  end
  self.ui.mSlideShowHelper_BannerList:PushLayoutElement(bannerObj, data.delay)
  table.insert(self.bannerList, bannerObj)
  local img = bannerObj.transform:Find("Img_Banner"):GetComponent("Image")
  if self.bannerCache[data.pic_url] == nil then
    setactive(img.gameObject, false)
    CS.LuaUtils.DownloadTextureFromUrl(data.pic_url, function(tex)
      if not CS.LuaUtils.IsNullOrDestroyed(bannerObj) and img ~= nil then
        setactive(img.gameObject, true)
        local sprite = CS.UIUtils.TextureToSprite(tex)
        self.bannerCache[data.pic_url] = sprite
        img.sprite = sprite
      end
      if callback ~= nil then
        callback()
      end
    end)
  else
    img.sprite = self.bannerCache[data.pic_url]
    if callback ~= nil then
      callback()
    end
  end
end
function UICommandCenterPanelV3:InitButtonGroup()
  UIUtils.GetButtonListener(self.ui.mBtn_PlayerAvatar.gameObject).onClick = function()
    self:OnClickPlayerInfo()
  end
  UIUtils.GetButtonListener(self.mItem_Adjutant.btn.gameObject).onClick = function()
    self:OpenAdjutant()
  end
  UIUtils.GetButtonListener(self.mItem_Chat.btn.gameObject).onClick = function()
    self:OnClickChat()
  end
  UIUtils.GetButtonListener(self.mItem_CheckIn.btn.gameObject).onClick = function()
    self:OnClickCheckIn()
  end
  UIUtils.GetButtonListener(self.mItem_DailyTask.btn.gameObject).onClick = function()
    self:OnClickDailyQuest()
  end
  UIUtils.GetButtonListener(self.mItem_Archives.btn.gameObject).onClick = function()
    self:OnClickArchives()
  end
  UIUtils.GetButtonListener(self.mItem_Mail.btn.gameObject).onClick = function()
    self:OnClickMail()
  end
  UIUtils.GetButtonListener(self.mItem_Activity.btn.gameObject).onClick = function()
    self:OnClickActivity()
  end
  UIUtils.GetButtonListener(self.mItem_BattlePass.btn.gameObject).onClick = function()
    self:UnRegistrationAllKeyboard()
    self:CallWithAniDelay(function()
      NetCmdBattlePassData:SendGetBattlepassInfo(function(ret)
        if ret == ErrorCodeSuc then
          UIManager.OpenUI(UIDef.UIBattlePassPanel)
        end
      end)
    end)
  end
  UIUtils.GetButtonListener(self.mItem_Post.btn.gameObject).onClick = function()
    self:OnClickPost()
  end
  UIUtils.GetButtonListener(self.mItem_Repository.btn.gameObject).onClick = function()
    self:OnClickRepository()
  end
  UIUtils.GetButtonListener(self.mItem_Exchange.btn.gameObject).onClick = function()
    self:OnClickExchangeStore()
  end
  UIUtils.GetButtonListener(self.mItem_Gacha.btn.gameObject).onClick = function()
    self:OnClickGacha()
  end
  UIUtils.GetButtonListener(self.mItem_Barrack.btn.gameObject).onClick = function()
    self:OnClickBarrack()
  end
  UIUtils.GetButtonListener(self.mItem_Battle.btn.gameObject).onClick = function()
    self:OnClickBattle()
  end
  UIUtils.GetButtonListener(self.mItem_RecentActivity.btn.gameObject).onClick = function()
    self:ClickRecentActivity()
  end
end
function UICommandCenterPanelV3:InitKeyCode()
  self:RegistrationKeyboard(KeyCode.L, self.mItem_DailyTask.btn)
  self:RegistrationKeyboard(KeyCode.O, self.mItem_Post.btn)
  self:RegistrationKeyboard(KeyCode.M, self.mItem_Mail.btn)
  self:RegistrationKeyboard(KeyCode.R, self.mItem_Archives.btn)
  self:RegistrationKeyboard(KeyCode.B, self.mItem_Repository.btn)
  self:RegistrationKeyboard(KeyCode.E, self.mItem_Exchange.btn)
  self:RegistrationKeyboard(KeyCode.G, self.mItem_Gacha.btn)
  self:RegistrationKeyboard(KeyCode.C, self.mItem_Barrack.btn)
  self:RegistrationKeyboard(KeyCode.D, self.mItem_RecentActivity.btn)
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_PlayerAvatar)
end
function UICommandCenterPanelV3.Close()
  UIManager.CloseUI(UIDef.UICommandCenterPanel)
end
function UICommandCenterPanelV3:OnShowFinish()
  self:UpdatePlayerInfo()
  if self.skipInitBanner then
    self.skipInitBanner = nil
  else
    self:InitBanner()
  end
  self:InitKeyCode()
  CS.ResUpdateSys.Instance:ForceDownloadUpdatePostData()
  self:RefreshActivityEntrance()
  self:UpdateRedPoint()
  self:UpdateSystemUnLockInfo()
  self:InitChatContent()
  setactive(self.ui.mTrans_DialogBox, false)
end
function UICommandCenterPanelV3:OnRecover(data, behaviorId, isTop)
  self:UpdatePlayerInfo()
  self:UpdateBtnRecentActivity()
  if SceneSys.currentScene.ResetMainCamera ~= nil then
    SceneSys.currentScene:ResetMainCamera()
  end
  if isTop then
    self:StartCommanderCheckQueue()
  end
  self.skipInitBanner = nil
end
function UICommandCenterPanelV3:OnShowStart()
  self:UpdatePlayerInfo()
  self:UpdateBtnRecentActivity()
  if SceneSys.currentScene.ResetMainCamera ~= nil then
    SceneSys.currentScene:ResetMainCamera()
  end
  local stories = NetCmdDungeonData:GetFirstBattleGroup()
  for i, story in pairs(stories) do
    local stageRecord = NetCmdStageRecordData:GetStageRecordById(story.stage_id)
    if not stageRecord or stageRecord.first_pass_time <= 0 then
      return
    end
  end
  self:StartCommanderCheckQueue()
  self.skipInitBanner = nil
end
function UICommandCenterPanelV3:OnBackFrom()
  self:UpdatePlayerInfo()
  self:UpdateBtnRecentActivity()
  if SceneSys.currentScene.ResetMainCamera ~= nil then
    SceneSys.currentScene:ResetMainCamera()
  end
  SceneSys:SwitchVisible(EnumSceneType.CommandCenter)
  self:StartCommanderCheckQueue()
  self.skipInitBanner = nil
end
function UICommandCenterPanelV3:OnUpdate(deltatime)
  self.mNowTime = self.mNowTime + deltatime
  if self.mNowTime > 2 then
    self.mNowTime = 0
    self.mIsCurBpOpen = NetCmdBattlePassData:CheckCurBpIsOpen()
    setactive(self.mItem_BattlePass.btn.gameObject, self.mIsCurBpOpen and AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.Battlepass))
  end
end
function UICommandCenterPanelV3:OnHide()
  if self.chatTimer then
    self.chatTimer:Stop()
  end
  if self.ui.mTrans_DialogBox.gameObject.activeSelf then
    self:CloseConversation()
  end
  if self.conversationTimer then
    self:CloseConversation()
    self.conversationTimer:Stop()
    self.conversationTimer = nil
  end
end
function UICommandCenterPanelV3:OnHideFinish()
  if SceneSys.currentScene.StopConversation ~= nil then
    SceneSys.currentScene:StopConversation()
  end
  self:OnHideSlideShow()
end
function UICommandCenterPanelV3:OnHideSlideShow()
  self.ui.mSlideShowHelper_BannerList:StopLerping()
  for i = 1, #self.bannerList do
    self.ui.mSlideShowHelper_BannerList:PopLayoutElement()
  end
  self.bannerList = {}
  for i = 2, #self.indicatorList do
    gfdestroy(self.indicatorList[i])
  end
  self.indicatorList = {}
end
function UICommandCenterPanelV3:OnClose()
  self:OnHideSlideShow()
  self.ui = nil
  self.ModelPoint = nil
  self.checkStep = 0
  self.autoRoll = nil
  self.isFrist = true
  if self.chatTimer then
    self.chatTimer:Stop()
    self.chatTimer = nil
  end
  if self.conversationTimer then
    self:CloseConversation()
    self.conversationTimer:Stop()
    self.conversationTimer = nil
  end
  for i, sprite in pairs(self.bannerCache) do
    gfdestroy(sprite)
  end
  self.bannerCache = {}
  self.DarkUnlockTime = nil
  self.darkzoneIsInOpen = nil
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.PostJump, self.updateJumpFunc)
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.ConversationMsg, self.conversationMessage)
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.ConversationEndMsg, self.conversationEndMessage)
  MessageSys:RemoveListener(CS.GF2.Message.CampaignEvent.ResInfoUpdate, self.refreshInfo)
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.SystemUnlockEvent, self.systemUnLock)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.BattlePass)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Chapters)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Daily)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Notice)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Mails)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Barracks)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.PlayerInfo)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Friend)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Repository)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.UAV)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.LoungeChat)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Archives)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Store)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.CommandCenter)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.RecentActivity)
end
function UICommandCenterPanelV3:CommanderCheckQueue()
  local isLogin = AccountNetCmdHandler:IsLogin()
  if isLogin == false then
    return
  end
  self.checkStep = self.checkStep + 1
  if self.checkStep == self.CheckQueue.None then
    return
  elseif self.checkStep == self.CheckQueue.NickName then
    self:CommanderCheckQueue()
  elseif self.checkStep == self.CheckQueue.Reconnection then
    self:CheckGameReconnect()
  elseif self.checkStep == self.CheckQueue.Poster then
    self:CheckPoster()
  elseif self.checkStep == self.CheckQueue.Notice then
    self:CheckNotice()
  elseif self.checkStep == self.CheckQueue.CheckIn then
    self:CheckDailyCheckIn()
  elseif self.checkStep == self.CheckQueue.Unlock then
    self:CheckUnlock()
  elseif self.checkStep == self.CheckQueue.Tutorial then
    self:CheckTutorial()
  elseif self.checkStep == self.CheckQueue.Finish then
    self:SetMaskEnable(false)
    self.checkStep = self.CheckQueue.None
    MessageSys:SendMessage(CS.GF2.Message.CommonEvent.PlayDefaultConversation, nil)
  end
end
function UICommandCenterPanelV3:IsReadyToStartTutorial()
  if not AccountNetCmdHandler:GetRecordFlag(GlobalConfig.RecordFlag.NameModified) then
    return false
  end
  if AccountNetCmdHandler:IsNeedRebuildDzStageAwake() or AccountNetCmdHandler:IsNeedReconnectBattle() then
    return false
  end
  if not self:CheckSystemIsLock(SystemList.Notice) and PostInfoConfig.CanShowPost() then
    return false
  end
  if not self:CheckSystemIsLock(SystemList.Notice) and PostInfoConfig.CanShowNotice() then
    return false
  end
  if not self:CheckSystemIsLock(SystemList.Checkin) and not NetCmdCheckInData:IsChecked() then
    return false
  end
  if AccountNetCmdHandler:ContainsUnlockId(UIDef.UICommandCenterPanel) and AccountNetCmdHandler.tempUnlockList.Count > 0 then
    for i = 0, AccountNetCmdHandler.tempUnlockList.Count - 1 do
      local unlockId = AccountNetCmdHandler.tempUnlockList[i]
      local unlockData = TableData.listUnlockDatas:GetDataById(unlockId)
      if unlockData.interface_id == UIDef.UICommandCenterPanel then
        return false
      end
    end
  end
  return true
end
function UICommandCenterPanelV3:NickPlayerName()
  if not AccountNetCmdHandler:GetRecordFlag(GlobalConfig.RecordFlag.NameModified) then
    local storyData = TableData.listStoryDatas:GetDataById(101)
    local goToBattle = function(nickNamePanel)
      local needClose = true
      local stageData = TableData.GetStageData(storyData.stage_id)
      if stageData ~= nil then
        local stageRecord = NetCmdStageRecordData:GetStageRecordById(stageData.id)
        if stageRecord ~= nil and stageRecord.first_pass_time <= 0 then
          SceneSys:OpenBattleSceneForChapter(stageData, stageRecord, storyData.id)
          needClose = false
        end
      end
      if needClose and nickNamePanel then
        nickNamePanel:Close()
      end
    end
    UIManager.OpenUIByParam(UIDef.UINickNamePanel, goToBattle, CS.UISystem.UIGroupType.BattleUI)
    UIManager.OpenUI(UIDef.UIBattleIndexPanel)
    UIManager.OpenUIByParam(UIDef.UIChapterPanel, storyData.chapter)
  else
  end
end
function UICommandCenterPanelV3:CheckReconnectBattle()
  if AccountNetCmdHandler:CheckNeedReconnectBattle(function()
    self:CommanderCheckQueue()
  end) then
  else
    self:CommanderCheckQueue()
  end
end
function UICommandCenterPanelV3:CheckGameReconnect()
  if AccountNetCmdHandler:CheckAndRebuildDzStageAwake() then
    self:CommanderCheckQueue()
  else
    self:CheckReconnectBattle()
  end
end
function UICommandCenterPanelV3:CheckPoster()
  if not self:CheckSystemIsLock(SystemList.Notice) then
    if PostInfoConfig.CanShowPost() then
      UIPosterPanel.Open(function()
        self:CommanderCheckQueue()
      end)
    else
      self:CommanderCheckQueue()
    end
  else
    self:CommanderCheckQueue()
  end
end
function UICommandCenterPanelV3:CheckNotice()
  if not self:CheckSystemIsLock(SystemList.Notice) then
    if PostInfoConfig.CanShowNotice() then
      UIPostBrowserPanel.Open(function()
        self:CommanderCheckQueue()
      end)
    else
      self:CommanderCheckQueue()
    end
  else
    self:CommanderCheckQueue()
  end
end
function UICommandCenterPanelV3:CheckDailyCheckIn()
  if not self:CheckSystemIsLock(SystemList.Checkin) and not NetCmdCheckInData:IsChecked() then
    local SendCheckInCallback = function(ret)
      if self.isPostJump then
        self:CommanderCheckQueue()
        NetCmdCheckInData:ResetCheckIn()
        self.isPostJump = false
      else
        self:SendCheckInCallback(ret)
      end
    end
    NetCmdCheckInData:SendGetDailyCheckInCmd(SendCheckInCallback)
  else
    self:CommanderCheckQueue()
  end
end
function UICommandCenterPanelV3:OnTop()
  if self.checkStep == self.CheckQueue.None then
  end
  self.skipInitBanner = true
end
function UICommandCenterPanelV3:CheckUnlock()
  if not AccountNetCmdHandler:ContainsUnlockId(UIDef.UICommandCenterPanel) then
    self:CommanderCheckQueue()
  else
    if AccountNetCmdHandler.tempUnlockList.Count > 0 then
      for i = 0, AccountNetCmdHandler.tempUnlockList.Count - 1 do
        local unlockData = TableData.listUnlockDatas:GetDataById(AccountNetCmdHandler.tempUnlockList[i])
        if unlockData.interface_id == UIDef.UICommandCenterPanel then
          UICommonUnlockPanel.Open(unlockData, function()
            self:CheckUnlock()
          end)
          return
        end
      end
    end
    self:CommanderCheckQueue()
  end
end
function UICommandCenterPanelV3:CheckTutorial()
  self:CommanderCheckQueue()
end
function UICommandCenterPanelV3:SendCheckInCallback(ret)
  if NetCmdCheckInData:IsChecked() then
    self:CommanderCheckQueue()
  else
    UIManager.OpenUIByParam(UIDef.UIDailyCheckInPanel, function()
      if SceneSys.CurSceneType ~= EnumSceneType.CommandCenter then
        UIManager.CloseUI(UIDef.UIDailyCheckInPanel)
      end
      self:CommanderCheckQueue()
    end)
  end
end
function UICommandCenterPanelV3:OnTutorialInfoCallback(ret)
end
function UICommandCenterPanelV3:RefreshInfo()
  self:UpdatePlayerInfo()
  self:UpdateSystemUnLockInfo()
end
function UICommandCenterPanelV3:UpdatePlayerInfo()
  self.ui.mText_PlayerName.text = AccountNetCmdHandler:GetName()
  self.ui.mImage_PlayerAvatar.sprite = IconUtils.GetPlayerAvatar(AccountNetCmdHandler:GetAvatar())
  self.ui.mText_Lv.text = AccountNetCmdHandler:GetLevel()
  self.ui.mImage_PlayerExp.FillAmount = AccountNetCmdHandler:GetExpPct()
  setactive(self.ui.mImg_MonthCard, AccountNetCmdHandler:IsMonCard())
  self:UpdateStageInfo()
end
function UICommandCenterPanelV3:UpdateStageInfo()
  local storyData = NetCmdDungeonData:GetCurrentStory()
  if storyData then
    local data = TableData.GetStorysByChapterID(storyData.chapter, false)
    local total = data.Count * 3
    local stars = NetCmdDungeonData:GetCurStarsByChapterID(storyData.chapter) + NetCmdDungeonData:GetFinishChapterStoryCountByChapterID(storyData.chapter) * 3
    local precent = stars / total
    self.mItem_Battle.txtPercent.text = tostring(math.ceil(precent * 100)) .. "%"
    self.mItem_Battle.barPercent.fillAmount = precent
    setactive(self.mItem_Battle.barPercent.gameObject, false)
    setactive(self.mItem_Battle.barPercent.gameObject, true)
    self.mItem_Battle.txtLevel.text = storyData.code.str
    local stageData = TableData.listStageDatas:GetDataById(storyData.stage_id)
    self.mItem_Battle.txtName.text = stageData.name.str
  end
end
function UICommandCenterPanelV3:ConversationMessage(msg)
  setactive(self.ui.mTrans_DialogBox, true)
  setactive(self.ui.mTextFit_Content.gameObject, msg.Content ~= nil)
  if msg.Content then
    self.ui.mTextFit_Content.text = msg.Content.str
  end
end
function UICommandCenterPanelV3:ConversationEndMessage(msg)
  if self.ui.mAnimator_DialogBox then
    self.ui.mAnimator_DialogBox:SetTrigger("Fadeout")
  end
  self.conversationTimer = TimerSys:DelayCall(0.5, function()
    self:CloseConversation()
  end)
end
function UICommandCenterPanelV3:CloseConversation()
  if self.ui and self.ui.mTrans_DialogBox then
    CS.CriWareAudioController.StopVoice()
    setactive(self.ui.mTrans_DialogBox, false)
  end
end
function UICommandCenterPanelV3:InitChatContent()
  if self.chatTimer then
    self.chatTimer:Stop()
  end
  self.autoRoll = CS.LuaDOTweenUtils.SetChatRoll(self.mItem_Chat.chatContent, self.chatSpeed, self.chatDelay)
  self:UpdateChatContent()
  self.chatTimer = TimerSys:DelayCall(self.chatRefreshTime, function()
    self:UpdateChatContent()
  end, nil, -1)
end
function UICommandCenterPanelV3:UpdateChatContent()
  local data = NetCmdChatData:GetTopMessageInPool()
  if self.mItem_Chat.txtAnimator then
    if data then
      setactive(self.mItem_Chat.btnIcon.gameObject, true)
      if not self.mItem_Chat.chatIsOn then
        self.mItem_Chat.chatIsOn = true
      end
      self.mItem_Chat.txtAnimator:SetTrigger("Switch")
      self.mItem_Chat.txtContent.text = data.message
      if self.autoRoll then
        self.autoRoll:ResetAndStart()
      end
    else
      self.mItem_Chat.chatIsOn = false
      setactive(self.mItem_Chat.btnIcon.gameObject, false)
    end
  end
end
function UICommandCenterPanelV3:OnClickPlayerInfo()
  if not AccountNetCmdHandler.tempUnlockList.Count ~= 0 then
    self:UnRegistrationAllKeyboard()
    self:CallWithAniDelay(function()
      UIManager.OpenUIByParam(UIDef.UICommanderInfoPanel, {isSelf = true})
    end)
  end
end
function UICommandCenterPanelV3:OpenAdjutant()
  self:UnRegistrationAllKeyboard()
  if SceneSys.currentScene.ResetMainCamera ~= nil then
    SceneSys.currentScene:ResetMainCamera()
  end
  UIManager.OpenUI(UIDef.UIAdjutantChrChangeDialog)
end
function UICommandCenterPanelV3:OnClickChat()
  self:UnRegistrationAllKeyboard()
  if SceneSys.currentScene.ResetMainCamera ~= nil then
    SceneSys.currentScene:ResetMainCamera()
  end
  UIManager.OpenUIByParam(UIDef.UICommunicationPanel, {nil, true})
end
function UICommandCenterPanelV3:OnClickLoungeChat()
  if TipsManager.NeedLockTips(SystemList.Restroom) then
    return
  end
  self:UnRegistrationAllKeyboard()
  UIManager.OpenUIByParam(UIDef.UILoungeChatPanel)
end
function UICommandCenterPanelV3:OnClickDailyQuest()
  if TipsManager.NeedLockTips(SystemList.Quest) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    UIManager.OpenUI(UIDef.UIQuestPanel)
  end)
end
function UICommandCenterPanelV3:OnClickFriend()
  if TipsManager.NeedLockTips(SystemList.Friend) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
  end)
end
function UICommandCenterPanelV3:OnClickPost()
  if TipsManager.NeedLockTips(SystemList.Notice) then
    return
  end
  self:UnRegistrationAllKeyboard()
  UIManager.OpenUI(UIDef.UIPostPanelV2)
end
function UICommandCenterPanelV3:OnClickMail()
  if TipsManager.NeedLockTips(SystemList.Mail) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    NetCmdMailData:SendReqRoleMailsCmd(function()
      UIManager.OpenUI(UIDef.UIMailPanelV2)
    end)
  end)
end
function UICommandCenterPanelV3:OnClickActivity()
  if TipsManager.NeedLockTips(SystemList.Activity) then
    return
  end
  if NetCmdOperationActivityData:HasShowingActivity() then
    self:UnRegistrationAllKeyboard()
    UIManager.OpenUI(UIDef.UIActivityDialog)
  end
end
function UICommandCenterPanelV3:OnClickArchives()
  if TipsManager.NeedLockTips(SystemList.Archives) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    UIManager.OpenUI(UIDef.ArchivesCenterEnterPanelV2)
  end)
end
function UICommandCenterPanelV3:OnClickGuild()
  if TipsManager.NeedLockTips(SystemList.Guild) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    NetCmdGuildData:SendSocialGuild(function()
      UIManager.OpenUI(UIDef.UIGuildPanel)
    end)
  end)
end
function UICommandCenterPanelV3:OnClickUAV()
  if TipsManager.NeedLockTips(SystemList.Uav) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    CS.UIMainPanel.EnterUAV()
  end)
end
function UICommandCenterPanelV3:OnClickRepository()
  if TipsManager.NeedLockTips(SystemList.Storage) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    UIManager.OpenUI(UIDef.UIRepositoryPanelV2)
  end)
end
function UICommandCenterPanelV3:OnClickExchangeStore()
  if TipsManager.NeedLockTips(SystemList.StoreEnterance) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    if TipsManager.NeedLockTips(SystemList.Store) then
      return
    end
    UIManager.OpenUI(UIDef.UIStoreExchangePanel)
  end)
end
function UICommandCenterPanelV3:OnClickDorm()
  if TipsManager.NeedLockTips(SystemList.Restroom) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    CS.UIMainPanel.EnterDorm(7)
  end)
end
function UICommandCenterPanelV3:OnClickPVP()
  if TipsManager.NeedLockTips(SystemList.Nrtpvp) or self.onClickPVP then
    return
  end
  if not NetCmdPVPData.PVPIsOpen then
    NetCmdSimulateBattleData:ReqPlanData(3, function(ret)
      if ret then
        NetCmdPVPData:SetPvpSeason()
        if not NetCmdPVPData.PVPIsOpen then
          CS.PopupMessageManager.PopupString(TableData.GetHintById(120203))
        end
      end
    end)
    return
  end
  self:UnRegistrationAllKeyboard()
  self.onClickPVP = true
  self:CallWithAniDelay(function()
    NetCmdPVPData:RequestPVPInfo(function()
      UIManager.OpenUI(UIDef.UINRTPVPPanel)
      self.onClickPVP = false
    end)
  end)
end
function UICommandCenterPanelV3:OnClickGacha()
  if TipsManager.NeedLockTips(SystemList.Gacha) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    UIManager.OpenUIByParam(UIDef.UIGashaponMainPanel, {true})
  end)
end
function UICommandCenterPanelV3:OnClickBarrack()
  if TipsManager.NeedLockTips(SystemList.Barrack) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    UIManager.OpenUI(UIDef.UIChrPowerUpPanel)
  end)
end
function UICommandCenterPanelV3:OnClickBattle()
  if TipsManager.NeedLockTips(SystemList.Battle) then
    return
  end
  if self.bCanClick == false then
    return
  end
  self.ui.mAnimator_Root:SetTrigger("FadeOut")
  local modelPointGameObject = CS.UnityEngine.GameObject.Find("Character_Point/Model_Point")
  if modelPointGameObject and modelPointGameObject.transform.childCount > 0 then
    self.ModelPoint = modelPointGameObject.transform:GetChild(0)
    self.ModelAnim = self.ModelPoint:GetComponent("Animator")
    if self.ModelAnim:GetCurrentAnimatorStateInfo(0):IsName("idle") then
      self.ModelAnim:SetTrigger("move")
    end
  end
  self.mTrans_Background = CS.UnityEngine.GameObject.Find("Background")
  self.bCanClick = false
  self:UnRegistrationAllKeyboard()
  TimerSys:DelayCall(0.6, function(obj)
    self:OpenCampaign()
  end)
end
function UICommandCenterPanelV3:OnClickCheckIn()
  if TipsManager.NeedLockTips(SystemList.Checkin) then
    return
  end
  UIManager.OpenUIByParam(UIDef.UIDailyCheckInPanel)
end
function UICommandCenterPanelV3:OpenCampaign()
  UIUniTopBarPanel:Show(false)
  UIBattleIndexGlobal.CachedTabIndex = -1
  UISystem:OpenUI(UIDef.UIFakeLoadingPanel, nil, 0, CS.UISystem.UIGroupType.SystemLoadScene)
  UIManager.OpenUI(UIDef.UIBattleIndexPanel)
  self.bCanClick = true
end
function UICommandCenterPanelV3:OnStoreClicked(gameobj)
  if TipsManager.NeedLockTips(SystemList.Store) then
    return
  end
  local params = {1, false}
  UIManager.OpenUIByParam(UIDef.UIStoreMainPanel, params)
end
function UICommandCenterPanelV3:UpdateSystemUnLockInfo()
  for i, item in ipairs(self.systemList) do
    self:UpdateSystemUnLockInfoByItem(item)
  end
end
function UICommandCenterPanelV3:UpdateSystemUnLockInfoByItem(item)
  if item and item.systemId then
    local isLock = self:CheckSystemIsLock(item.systemId)
    if item.animator then
      item.animator:SetBool("Unlock", not isLock)
    end
  end
end
function UICommandCenterPanelV3:CheckSystemIsLock(type)
  return not AccountNetCmdHandler:CheckSystemIsUnLock(type)
end
function UICommandCenterPanelV3:SystemUnLock()
  printstack("有新的系统解锁了奥")
  self:UpdateSystemUnLockInfo()
end
function UICommandCenterPanelV3:UpdateBtnRecentActivity()
  local planActivityDataList = NetCmdRecentActivityData:GetRequestedPlanActivityDataList()
  setactivewithcheck(self.ui.mTrans_Activity, planActivityDataList.Count > 0)
end
function UICommandCenterPanelV3:ClickRecentActivity()
  if TipsManager.NeedLockTips(SystemList.RecentActivity) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    UIManager.OpenUI(UIDef.UIRecentActivityPanel)
  end)
end
function UICommandCenterPanelV3:SetMaskEnable(enable)
  setactive(self.ui.mTrans_Mask, enable)
end
function UICommandCenterPanelV3:EnableModelPoint(enable)
  setactive(self.ModelPoint, enable)
end
function UICommandCenterPanelV3:InitRedPointObj()
  for i, item in ipairs(self.systemList) do
    if item.systemId ~= SystemList.RecentActivity and item.transRedPoint then
      self:InstanceUIPrefab("UICommonFramework/ComRedPointItemV2.prefab", item.transRedPoint, true)
    end
  end
end
function UICommandCenterPanelV3:StartCommanderCheckQueue()
  if TutorialSystem.IsInTutorial then
    return
  end
  self:SetMaskEnable(true)
  self.checkStep = self.CheckQueue.None
  self:CommanderCheckQueue()
end
function UICommandCenterPanelV3:InitCommandCenterTopBtn(systemId, iconName)
  local CommandCenterTopBtn = CommandCenterTopBtn.New()
  CommandCenterTopBtn:InitCtrl(self.ui.mScrollListChild_GrpTabSwitch, systemId, iconName)
  table.insert(self.systemList, CommandCenterTopBtn)
  CommandCenterTopBtn:CheckUnLock()
  return CommandCenterTopBtn
end
function UICommandCenterPanelV3:InitCommandCenterBottomBtn(btn, systemId)
  local CommandCenterBottomBtn = CommandCenterBottomBtn.New()
  CommandCenterBottomBtn:InitCtrl(btn, systemId)
  table.insert(self.systemList, CommandCenterBottomBtn)
  return CommandCenterBottomBtn
end
function UICommandCenterPanelV3:InitLeftRightBtn(btn, systemId)
  local parent = btn:GetComponent("RectTransform")
  if parent then
    local item = {}
    item.systemId = systemId
    item.parent = parent
    item.btn = btn
    item.animator = item.btn.gameObject:GetComponent("Animator")
    item.transRedPoint = UIUtils.GetRectTransform(item.btn.transform, "Trans_RedPoint")
    item.txtUnlock = UIUtils.GetText(item.btn.transform, "GrpLock/Text")
    table.insert(self.systemList, item)
    return item
  end
end
function UICommandCenterPanelV3:InitBattle(btn, systemId)
  local parent = btn:GetComponent("RectTransform")
  if parent then
    local item = {}
    item.systemId = systemId
    item.parent = parent
    item.btn = self.ui.mBtn_GrpSimCombat
    item.txtPercent = self.ui.mText_Num
    item.barPercent = self.ui.mImg_ProgressBar
    item.txtLevel = self.ui.mText_Level
    item.txtName = self.ui.mText_Name
    item.transRedPoint = self.ui.mTrans_RedPoint
    table.insert(self.systemList, item)
    return item
  end
end
function UICommandCenterPanelV3:InitAvatar(rectTransform)
  local parent = rectTransform
  if parent then
    local item = {}
    item.parent = parent
    item.btn = self.ui.mBtn_PlayerAvatar
    item.transRedPoint = UIUtils.GetRectTransform(parent, "Btn_PlayerAvatar/Root/Trans_RedPoint")
    table.insert(self.systemList, item)
    return item
  end
end
function UICommandCenterPanelV3:InitAdjutant(rectTransform)
  local parent = rectTransform
  if parent then
    local item = {}
    item.parent = parent
    item.btn = self.ui.mBtn_Adjutant
    item.transRedPoint = self.ui.mObj_RedPoint
    table.insert(self.systemList, item)
    return item
  end
end
function UICommandCenterPanelV3:InitChat()
  local parent = self.ui.mTrans_Chat
  local isLock = self:CheckSystemIsLock(SystemList.Friend)
  setactive(parent.gameObject, not isLock)
  NetCmdChatData:CheckRobotSpecialChats()
  if parent then
    local item = {}
    item.systemId = SystemList.Friend
    item.parent = parent
    item.chatIsOn = false
    item.txtContent = UIUtils.GetRectTransform(parent, "Btn_Chat/GrpText/Text_Content"):GetComponent("Text")
    item.txtAnimator = UIUtils.GetRectTransform(parent, "Btn_Chat/GrpText"):GetComponent("Animator")
    item.btn = UIUtils.GetButton(parent)
    item.btnIcon = UIUtils.GetRectTransform(parent, "Btn_Chat")
    item.transRedPoint = UIUtils.GetRectTransform(parent, "GrpChatIcon/Trans_RedPoint")
    table.insert(self.systemList, item)
    return item
  end
end
function UICommandCenterPanelV3:OnReconnectSuc()
  TimerSys:DelayFrameCall(1, function()
    CS.MessageBox.Close()
    self:StartCommanderCheckQueue()
  end)
end
