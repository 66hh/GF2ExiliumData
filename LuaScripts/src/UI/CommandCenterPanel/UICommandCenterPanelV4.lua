require("UI.CommandCenterPanel.Item.CommanderLeftTab")
require("UI.UIRecentActivityPanel.UIRecentActivityPanel")
require("UI.UniTopbar.UIUniTopBarPanel")
require("UI.PosterPanel.UIPosterPanel")
require("UI.PostPanelV2.UIPostBrowserPanel")
require("UI.UICommonUnlockPanel.UICommonUnlockPanel")
require("UI.CommandCenterPanel.UICommandCenterPanel")
require("UI.UniTopbar.Item.ResourcesCommonItem")
require("UI.SimCombatPanel.ResourcesCombat.UISimCombatGlobal")
UICommandCenterPanelV4 = class("self", UIBasePanel)
UICommandCenterPanelV4.__index = UICommandCenterPanelV4
UICommandCenterPanelV4.HideBlackMask = false
function UICommandCenterPanelV4:ctor(csPanel)
  self.super.ctor(self, csPanel)
  self.csPanel = csPanel
  csPanel.HideSceneBackground = false
  csPanel.Is3DPanel = true
  self.RedPointType = {
    RedPointConst.ChapterReward,
    RedPointConst.SimResourceStageIndex,
    RedPointConst.SimulateBattle,
    RedPointConst.Daily,
    RedPointConst.Notice,
    RedPointConst.Gacha,
    RedPointConst.PlayerCard,
    RedPointConst.Barracks,
    RedPointConst.PVP,
    RedPointConst.CommandCenter,
    RedPointConst.RecentActivity,
    RedPointConst.MainBattlePass,
    RedPointConst.MainPlayerInfo,
    RedPointConst.MainChapters,
    RedPointConst.MainDaily,
    RedPointConst.MainBarracks,
    RedPointConst.MainGacha,
    RedPointConst.MainRecentActivity,
    RedPointConst.NewTask
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
  self.systemList = {}
  self.bannerList = {}
  self.leftTabItemList = {}
  self.indicatorList = {}
  self.bannerCache = {}
end
function UICommandCenterPanelV4:OnInit(root, data)
  self.super.SetRoot(self, root)
  self.mUIRoot = root
  self.closeTime = 0
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:InitCommandCenterPanelUI()
  self:SetMaskEnable(false)
  self:InitButtonGroup()
  if self:IsShowHudBtn() then
    UIUtils.AnimatorFadeIn(self.ui.mAnim_Hud)
  end
  function self.systemUnLock(message)
    self:SystemUnLock(message)
  end
  function self.refreshInfo(message)
    self:RefreshInfo(message)
  end
  function self.onClickPuppy(message)
    self:OnClickHud()
  end
  function self.InitFade()
    SceneSys.currentScene:SetCameraFadedIn(false)
    SceneSys.currentScene:CameraFadeIn()
  end
  function self.bannerUpdate()
    if self.skipInitBanner then
      self.skipInitBanner = nil
    else
      self:InitBanner()
    end
  end
  function self.onApplicationFocus(isFocus)
    if isFocus.Sender == true then
      self:RequestDeepLink()
    end
  end
  MessageSys:AddListener(CS.GF2.Message.SystemEvent.ApplicationFocus, self.onApplicationFocus)
  MessageSys:AddListener(CS.GF2.Message.UIEvent.BannerUpdate, self.bannerUpdate)
  MessageSys:AddListener(CS.GF2.Message.UIEvent.OnLoadingEnd, self.InitFade)
  MessageSys:AddListener(CS.GF2.Message.CampaignEvent.ResInfoUpdate, self.refreshInfo)
  MessageSys:AddListener(CS.GF2.Message.UIEvent.SystemUnlockEvent, self.systemUnLock)
  MessageSys:AddListener(CS.GF2.Message.UIEvent.OnClickPuppy, self.onClickPuppy)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.MainPlayerInfo, self.ui.mTrans_SettingsRedPoint, nil, SystemList.Commander)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.MainBattlePass, self.mItem_BattlePass.transRedPoint, nil, self.mItem_BattlePass.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.MainChapters, self.mItem_Battle.transRedPoint, nil, self.mItem_Battle.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.MainDaily, self.mItem_DailyTask.transRedPoint, nil, self.mItem_DailyTask.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.MainBarracks, self.mItem_Barrack.transRedPoint, nil, self.mItem_Barrack.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.MainGacha, self.mItem_Gacha.transRedPoint)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.MainRecentActivity, self.mItem_Activity.transRedPoint)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.NewTask, self.ui.mTrans_NewTaskRedPoint)
  self:InitGM()
end
function UICommandCenterPanelV4:InitGM()
end
function UICommandCenterPanelV4:HasStoryBattleStage()
  local hasReward = false
  local storyList = TableData.GetNormalChapterList()
  for i = 0, storyList.Count - 1 do
    hasReward = hasReward or 0 < NetCmdDungeonData:UpdateChatperRewardRedPoint(storyList[i].id)
  end
  local isNeedRedPoint = NetCmdSimulateBattleData:CheckTeachingUnlockRedPoint() or NetCmdSimulateBattleData:CheckTeachingRewardRedPoint() or NetCmdSimulateBattleData:CheckTeachingNoteReadRedPoint() or NetCmdSimulateBattleData:CheckTeachingNoteProgressRedPoint()
  if hasReward or isNeedRedPoint then
    return true
  end
  return false
end
function UICommandCenterPanelV4:IsShowChangeRedPoint()
  return NetCmdCommandCenterData:UpdateRedPoint() > 0
end
function UICommandCenterPanelV4:IsShowHudRedPoint()
  if self:HasStoryBattleStage() then
    return true
  elseif NetCmdSimulateBattleData:CheckSimStageIndexRedPoint(4) then
    return true
  elseif NetCmdSimulateBattleData:CheckSimBattleHasRedPoint() then
    return true
  elseif GashaponNetCmdHandler:UpdateRedPoint() > 0 then
    return true
  elseif 0 < NetCmdQuestData:UpdateRedPoint() then
    return true
  elseif 0 < NetCmdMailData:UpdateRedPoint() then
    return true
  elseif 0 < PostInfoConfig.UpdateRedPoint() then
    return true
  elseif 0 < NetCmdIllustrationData:UpdatePlayerCardRedPoint() then
    return true
  elseif 0 < NetCmdFriendData:UpdateRedPoint() then
    return true
  elseif 0 < NetCmdItemData:UpdateWeaponPieceRedPoint() then
    return true
  elseif 0 < NetCmdTeamData:UpdateBarracksRedPoint() then
    return true
  elseif 0 < NetCmdArchivesData:UpdateArchivesRedPoint() then
    return true
  elseif NetCmdRecentActivityData:CheckRecentActivityRedPoint() then
    return true
  elseif 0 < NetCmdBattlePassData:GetShowCommandSceneRedPoint() then
    return true
  end
  return false
end
function UICommandCenterPanelV4:CheckBackground()
  local bgData = TableData.listCommandBackgroundDatas:GetDataById(NetCmdCommandCenterData.Background)
  setactive(self.ui.mBtn_Hud, bgData.type ~= 1)
  if bgData.type == 2 then
    SceneSys.currentScene:PlayBackgroundVideo(bgData.bg)
  else
    SceneSys.currentScene:StopBackgroundVideo()
  end
end
function UICommandCenterPanelV4:IsShowHudBtn()
  local bgData = TableData.listCommandBackgroundDatas:GetDataById(NetCmdCommandCenterData.Background)
  return bgData.type ~= 1
end
function UICommandCenterPanelV4:SetResourceBar()
  local staminaCount = NetCmdItemData:GetItemCountById(101)
  self.ui.mText_StaminaNum.text = staminaCount .. "/" .. GlobalData.GetStaminaResourceMaxNum(101)
  self.ui.mText_GemNum.text = ResourcesCommonItem.ChangeNumDigit(NetCmdItemData:GetItemCountById(1))
end
function UICommandCenterPanelV4:InitBanner()
  local count = PostInfoConfig.BannerDataList.Count
  local dataList = {}
  setactive(self.ui.mSlideShowHelper_BannerList.transform.parent, 0 < count)
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
  self.ui.mMask_Banner:SetRadius(3)
  self.ui.mSlideShowHelper_BannerList:SetData(dataListCount)
end
function UICommandCenterPanelV4:InstantiateBanner(data, callback)
  local bannerObj = instantiate(UIUtils.GetGizmosPrefab("CommandCenter/CommandcenterBanneItemV2.prefab", self))
  local button = bannerObj:GetComponent(typeof(CS.UnityEngine.UI.Button))
  if data.type_id == 0 and data.extra ~= "" then
    UIUtils.GetButtonListener(button.gameObject).onClick = function()
      if string.match(data.extra, "{uid}") then
        local text = string.gsub(data.extra, "{uid}", AccountNetCmdHandler:GetUID())
        local strings = string.split(text, "?")
        CS.GF2.ExternalTools.Browsers.BrowserHandler.Show(strings[1] .. "?token=" .. string.gsub(CS.AesUtils.Encode(strings[2]), "-", ""))
      else
        CS.GF2.ExternalTools.Browsers.BrowserHandler.Show(data.extra, CS.GF2.ExternalTools.Browsers.BrowserShowType.OutSourceURL)
      end
    end
  elseif data.type_id == 3 and data.extra ~= "" then
    UIUtils.GetButtonListener(button.gameObject).onClick = function()
      local token = CS.GF2.SDK.PlatformLoginManager.Instance.Token
      local urlStr = data.extra .. "&token=" .. CS.AesUtils.UrlEncode(token)
      CS.GF2.ExternalTools.Browsers.BrowserHandler.Show(urlStr, CS.GF2.ExternalTools.Browsers.BrowserShowType.OutSourceURL)
    end
  elseif data.type_id > 0 and 0 < data.jump_id then
    UIUtils.GetButtonListener(button.gameObject).onClick = function()
      local jumpData = TableData.listJumpListContentnewDatas:GetDataById(tonumber(data.jump_id))
      if jumpData.unlock_id == 0 or AccountNetCmdHandler:CheckSystemIsUnLock(jumpData.unlock_id) then
        self:UnRegistrationAllKeyboard()
        self:CallWithAniDelay(function()
          SceneSwitch:SwitchByID(data.jump_id)
        end)
      else
        local unlockData = TableData.listUnlockDatas:GetDataById(jumpData.unlock_id)
        local str = UIUtils.CheckUnlockPopupStr(unlockData)
        PopupMessageManager.PopupString(str)
      end
    end
  end
  self.ui.mSlideShowHelper_BannerList:PushLayoutElement(bannerObj, data.delay)
  table.insert(self.bannerList, bannerObj)
  local img = bannerObj.transform:Find("Img_Banner"):GetComponent(typeof(CS.UnityEngine.UI.Image))
  if self.bannerCache[data.pic_url] == nil then
    CS.LuaUtils.DownloadTextureFromUrl(data.pic_url, function(tex)
      if not CS.LuaUtils.IsNullOrDestroyed(bannerObj) and img ~= nil then
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
function UICommandCenterPanelV4:InitButtonGroup()
  UIUtils.GetButtonListener(self.mItem_Battle.btn.gameObject).onClick = function()
    self:OnClickBattle()
  end
  UIUtils.GetButtonListener(self.mItem_Gacha.btn.gameObject).onClick = function()
    self:OnClickGacha()
  end
  UIUtils.GetButtonListener(self.mItem_DailyTask.btn.gameObject).onClick = function()
    self:OnClickDailyQuest()
  end
  UIUtils.GetButtonListener(self.mItem_Barrack.btn.gameObject).onClick = function()
    self:OnClickBarrack()
  end
  UIUtils.GetButtonListener(self.mItem_BattlePass.btn.gameObject).onClick = function()
    self:OnClickBattlePass()
  end
  UIUtils.GetButtonListener(self.mItem_Activity.btn.gameObject).onClick = function()
    self:OnClickRecentActivity()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Hud.gameObject).onClick = function()
    self:OnClickHud()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BgChange.gameObject).onClick = function()
    self:OnClickChangeBg()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Settings.gameObject).onClick = function()
    self:OnClickSettings()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_NewTask.gameObject).onClick = function()
    self:OnClickNewTask()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Gem.gameObject).onClick = function()
    SceneSwitch:SwitchByID(3)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Stamina.gameObject).onClick = function()
    SceneSwitch:SwitchByID(2)
  end
end
function UICommandCenterPanelV4:InitCommandCenterPanelUI()
  local dataList = TableData.listCommandHomepageDatas:GetList()
  local tabTable = {}
  for i = 0, dataList.Count - 1 do
    local data = dataList[i]
    if data.Type == 2 then
      table.insert(tabTable, data)
    end
  end
  table.sort(tabTable, function(a, b)
    return a.Sort < b.Sort
  end)
  for _, item in pairs(self.leftTabItemList) do
    item:OnRelease()
  end
  self.leftTabItemList = {}
  for _, tab in pairs(tabTable) do
    local item = CommanderLeftTab.New()
    item:InitCtrl(self.ui.mScrollListChild_Tab)
    item:SetData(tab, tab.id)
    table.insert(self.leftTabItemList, item)
    if tab.id == 13000 then
      self.mItem_Gacha = item
      setactive(item.transRedPoint, false)
    elseif tab.id == 24000 then
      self.mItem_DailyTask = item
    elseif tab.id == 12000 then
      self.mItem_Barrack = item
    elseif tab.id == 29101 then
      self.mItem_BattlePass = item
    elseif tab.id == 29202 then
      self.mItem_Activity = item
    end
    table.insert(self.systemList, item)
  end
  self.mItem_Battle = self:InitBattle(self.ui.mTrans_SimCombat, SystemList.Battle)
end
function UICommandCenterPanelV4:InitBattle(btn, systemId)
  local parent = btn:GetComponent(typeof(CS.UnityEngine.RectTransform))
  if parent then
    local item = {}
    item.systemId = systemId
    item.parent = parent
    item.btn = self.ui.mBtn_GrpSimCombat
    item.transRedPoint = self.ui.mTrans_BattleRedPoint
    table.insert(self.systemList, item)
    return item
  end
end
function UICommandCenterPanelV4:SystemUnLock()
  self:UpdateSystemUnLockInfo()
end
function UICommandCenterPanelV4:RefreshInfo()
  self:UpdateSystemUnLockInfo()
end
function UICommandCenterPanelV4:UpdateSystemUnLockInfo()
  for i, item in ipairs(self.systemList) do
    self:UpdateSystemUnLockInfoByItem(item)
  end
end
function UICommandCenterPanelV4:UpdateSystemUnLockInfoByItem(item)
  if item and item.systemId then
    local isLock = self:CheckSystemIsLock(item.systemId)
    if item.animator then
      item.animator:SetBool("Unlock", not isLock)
    end
  end
end
function UICommandCenterPanelV4:CheckSystemIsLock(type)
  return not AccountNetCmdHandler:CheckSystemIsUnLock(type)
end
function UICommandCenterPanelV4:InitRedPointObj()
  for i, item in ipairs(self.systemList) do
    if item.systemId == SystemList.RecentActivity or item.transRedPoint then
    end
  end
end
function UICommandCenterPanelV4:InitKeyCode()
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Settings)
  self:RegistrationKeyboard(KeyCode.B, self.ui.mBtn_BgChange)
  self:RegistrationKeyboard(KeyCode.U, self.mItem_DailyTask.btn)
  self:RegistrationKeyboard(KeyCode.G, self.mItem_Gacha.btn)
  self:RegistrationKeyboard(KeyCode.C, self.mItem_Barrack.btn)
  self:RegistrationKeyboard(KeyCode.D, self.mItem_Activity.btn)
  self:RegistrationKeyboard(KeyCode.V, self.mItem_BattlePass.btn)
  self:RegistrationKeyboard(KeyCode.Tab, self.ui.mBtn_Hud)
end
function UICommandCenterPanelV4.Close()
  UIManager.CloseUI(UIDef.UICommandCenterPanel)
end
function UICommandCenterPanelV4:OnUpdate()
  self:SetResourceBar()
end
function UICommandCenterPanelV4:RequestDeepLink()
  if LuaUtils.IsIOS() and UISystem:GetTopUI(UIGroupType.Default).UIDefine.UIType == UIDef.UICommandCenterPanel then
    if self.deeplinkTimer ~= nil then
      self.deeplinkTimer:Stop()
      self.deeplinkTimer = nil
    end
    CS.GF2.SDK.PlatformLoginManager.Instance:GetDeeplinkParam()
    self.deeplinkTimer = TimerSys:DelayCall(1, function()
      self:OnUpdateDeepLinkParam()
    end)
  end
end
function UICommandCenterPanelV4:OnUpdateDeepLinkParam()
  if LuaUtils.IsIOS() and (self.checkStep == self.CheckQueue.None or self.checkStep == self.CheckQueue.Finish) and CS.GF2.SDK.PlatformLoginManager.Instance.DeepLinkParam ~= nil and CS.GF2.SDK.PlatformLoginManager.Instance.DeepLinkParam ~= "" then
    if AccountNetCmdHandler:CheckSystemIsUnLock(self.mItem_Activity.systemId) then
      self:OnClickRecentActivity()
    end
    CS.GF2.SDK.PlatformLoginManager.Instance:DeleteDeeplinkParam()
  end
end
function UICommandCenterPanelV4:OnCameraBack()
  if UISystem:GetTopUI(UIGroupType.Default).UIDefine.UIType == UIDef.UICommandCenterHudPanel or UISystem:GetTopUI(UIGroupType.Default).UIDefine.UIType == UIDef.UICommandCenterBgChangePanel then
    return 0.01
  else
    return 0
  end
end
function UICommandCenterPanelV4:OnShowFinish()
  self:UpdateNewTask()
  CS.ResUpdateSys.Instance:ForceDownloadUpdatePostData()
  self:InitKeyCode()
  self:UpdateRedPoint()
  setactive(self.mItem_Activity.transRedPoint, NetCmdThemeData:GetThemeRedState() ~= 3 and AccountNetCmdHandler:CheckSystemIsUnLock(self.mItem_Activity.systemId))
  setactive(self.mItem_Activity.transRedPointNode, NetCmdThemeData:GetThemeRedState() == 1)
  setactive(self.mItem_Activity.transActivitiesOpen, NetCmdThemeData:GetThemeRedState() == 2)
  self:UpdateSystemUnLockInfo()
  setactive(self.ui.mTrans_HudRedPoint, self:IsShowHudRedPoint())
  setactive(self.ui.mTrans_ChangeRedPoint, self:IsShowChangeRedPoint())
  self.ui.mText_Lv.text = TableData.GetHintById(160022) .. " " .. AccountNetCmdHandler:GetLevel()
  self.ui.mText_UID.text = "UID " .. AccountNetCmdHandler:GetUID()
  if SceneSys.currentScene.AnimatorPuppy ~= nil then
    if SceneSys.currentScene.AnimatorPuppy.transform:Find("root/Root_M/Dinergate_commendCenter_HUD_Point_Base") ~= nil then
      setactive(SceneSys.currentScene.AnimatorPuppy.transform:Find("root/Root_M/Dinergate_commendCenter_HUD_Point_Base"), not self:IsShowHudRedPoint())
    end
    if SceneSys.currentScene.AnimatorPuppy.transform:Find("root/Root_M/Dinergate_commendCenter_HUD_Point_RedPoint") ~= nil then
      setactive(SceneSys.currentScene.AnimatorPuppy.transform:Find("root/Root_M/Dinergate_commendCenter_HUD_Point_RedPoint"), self:IsShowHudRedPoint())
    end
    if self:IsShowHudRedPoint() then
      SceneSys.currentScene.AnimatorPuppy:SetTrigger("start_hint")
    else
      SceneSys.currentScene.AnimatorPuppy:SetTrigger("fadeIn")
    end
  end
  SceneSys.currentScene:ResetBlurTween()
  SceneSys.currentScene:CameraFadeIn()
end
function UICommandCenterPanelV4:OnRecover(data, behaviorId, isTop)
  if isTop then
    self:StartCommanderCheckQueue()
    self:CheckBackground()
  end
  self.isRecover = true
  self.skipInitBanner = nil
end
function UICommandCenterPanelV4:OnShowStart()
  self:StartCommanderCheckQueue()
  self:CheckBackground()
  self.isHide = false
  self.skipInitBanner = nil
end
function UICommandCenterPanelV4:OnBackFrom()
  if self.isRecover == true then
    SceneSys.currentScene:SetCameraFadedIn(false)
    self.isRecover = nil
  end
  self.isHide = false
  SceneSys:SwitchVisible(EnumSceneType.CommandCenter)
  self:StartCommanderCheckQueue()
  self:UpdateNewTask()
  self:CheckBackground()
  self.skipInitBanner = nil
  if #self.bannerCache == 0 then
    self:InitBanner()
  end
end
function UICommandCenterPanelV4:OnHide()
  self.isHide = true
end
function UICommandCenterPanelV4:OnHideFinish()
  self:OnHideSlideShow()
  if self.isHud then
    SceneSys.currentScene:SetCameraFadedIn(true)
    self.isHud = false
    return
  end
  SceneSys.currentScene:SetCameraFadedIn(false)
  SceneSys.currentScene:HideBackgroundVideo()
end
function UICommandCenterPanelV4:OnHideSlideShow()
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
function UICommandCenterPanelV4:OnClose()
  self:OnHideSlideShow()
  self.ui = nil
  self.checkStep = 0
  for i, sprite in pairs(self.bannerCache) do
    gfdestroy(sprite)
  end
  self.bannerCache = {}
  for _, item in pairs(self.leftTabItemList) do
    item:OnRelease()
  end
  if self.deeplinkTimer ~= nil then
    CS.GF2.SDK.PlatformLoginManager.Instance:DeleteDeeplinkParam()
    self.deeplinkTimer:Stop()
    self.deeplinkTimer = nil
  end
  self.leftTabItemList = {}
  MessageSys:RemoveListener(CS.GF2.Message.SystemEvent.ApplicationFocus, self.onApplicationFocus)
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.BannerUpdate, self.bannerUpdate)
  MessageSys:RemoveListener(CS.GF2.Message.CampaignEvent.ResInfoUpdate, self.refreshInfo)
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.SystemUnlockEvent, self.systemUnLock)
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.OnLoadingEnd, self.InitFade)
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.OnClickPuppy, self.onClickPuppy)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.MainPlayerInfo)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.MainBattlePass)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.MainChapters)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.MainDaily)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.MainBarracks)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.MainRecentActivity)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.MainGacha)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.NewTask)
end
function UICommandCenterPanelV4:SetMaskEnable(enable)
end
function UICommandCenterPanelV4:StartCommanderCheckQueue()
  if CS.AVGController.IsOnPlayAVG then
    return
  end
  self:SetMaskEnable(true)
  self.checkStep = self.CheckQueue.None
  self:CommanderCheckQueue()
end
function UICommandCenterPanelV4:CheckReconnectBattle()
  if AccountNetCmdHandler:CheckNeedReconnectBattle(function()
    self:CommanderCheckQueue()
  end) then
  else
    self:CommanderCheckQueue()
  end
end
function UICommandCenterPanelV4:CheckGameReconnect()
  if AccountNetCmdHandler:CheckAndRebuildDzStageAwake() then
    self:CommanderCheckQueue()
  else
    self:CheckReconnectBattle()
  end
end
function UICommandCenterPanelV4:CheckPoster()
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
function UICommandCenterPanelV4:CheckNotice()
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
function UICommandCenterPanelV4:CheckDailyCheckIn()
  if not self:CheckSystemIsLock(SystemList.Checkin) and not NetCmdCheckInData:IsChecked() then
    local SendCheckInCallback = function(ret)
      self:SendCheckInCallback(ret)
    end
    NetCmdCheckInData:SendGetDailyCheckInCmd(SendCheckInCallback)
  else
    self:CommanderCheckQueue()
  end
end
function UICommandCenterPanelV4:CheckUnlock()
  if not AccountNetCmdHandler:ContainsUnlockId(UIDef.UICommandCenterPanel) then
    self:CommanderCheckQueue()
  else
    if AccountNetCmdHandler.tempUnlockList.Count > 0 then
      for i = 0, AccountNetCmdHandler.tempUnlockList.Count - 1 do
        local unlockData = TableData.listUnlockDatas:GetDataById(AccountNetCmdHandler.tempUnlockList[i])
        if unlockData.interface_id == UIDef.UICommandCenterPanel then
          UICommonUnlockPanel.Open(self, unlockData, function()
            self:CheckUnlock()
          end)
          return
        end
      end
    end
    self:CommanderCheckQueue()
  end
end
function UICommandCenterPanelV4:CheckTutorial()
  self:CommanderCheckQueue()
end
function UICommandCenterPanelV4:SendCheckInCallback(ret)
  if NetCmdCheckInData:IsChecked() then
    self:CommanderCheckQueue()
  else
    UIManager.OpenUIByParam(UIDef.UIDailyCheckInPanel, function()
      self:CommanderCheckQueue()
    end)
  end
end
function UICommandCenterPanelV4:IsReadyToStartTutorial()
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
  if AVGController.IsOnPlayAVG then
    return false
  end
  return true
end
function UICommandCenterPanelV4:CommanderCheckQueue()
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
    self:RequestDeepLink()
  end
end
function UICommandCenterPanelV4:OnTop()
  self.skipInitBanner = true
  self:UpdateNewTask()
end
function UICommandCenterPanelV4:PuppyFadeOut()
  if SceneSys.currentScene.AnimatorPuppy ~= nil then
    SceneSys.currentScene.AnimatorPuppy:SetTrigger("fadeOut")
  end
end
function UICommandCenterPanelV4:OnClickBattle()
  if TipsManager.NeedLockTips(SystemList.Battle) then
    return
  end
  if not self.bCanClick then
    return
  end
  self:UnRegistrationAllKeyboard()
  self.bCanClick = false
  self:OpenCampaign()
end
function UICommandCenterPanelV4:OnClickGacha()
  if TipsManager.NeedLockTips(SystemList.Gacha) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    UIManager.OpenUIByParam(UIDef.UIGashaponMainPanel, {true})
  end)
end
function UICommandCenterPanelV4:OnClickDailyQuest()
  if TipsManager.NeedLockTips(SystemList.Quest) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    UIManager.OpenUI(UIDef.UIQuestPanel)
  end)
end
function UICommandCenterPanelV4:OnClickBattlePass()
  if TipsManager.NeedLockTips(SystemList.Battlepass) then
    return
  end
  local mIsCurBpOpen = NetCmdBattlePassData:CheckCurBpIsOpen()
  if not mIsCurBpOpen then
    return
  end
  self:CallWithAniDelay(function()
    NetCmdBattlePassData:SendGetBattlepassInfo(function(ret)
      if ret == ErrorCodeSuc then
        self:UnRegistrationAllKeyboard()
        UIManager.OpenUI(UIDef.UIBattlePassPanel)
      end
    end)
  end)
end
function UICommandCenterPanelV4:OnClickBarrack()
  if TipsManager.NeedLockTips(SystemList.Barrack) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    local openAvgTask
    local isWatchedBarrackFirstAvg = AccountNetCmdHandler:IsWatchedChapter(TableDataBase.GlobalSystemData.BarrackFirstAvgId)
    if not isWatchedBarrackFirstAvg then
      openAvgTask = CS.AVGController.PlayAvgByPlotId(TableDataBase.GlobalSystemData.BarrackFirstAvgId, nil, true, true, true, true)
      if openAvgTask ~= nil then
        UISystem:EnableUICanvas(false)
      end
      local openUITask = UISystem:OpenUI(UIDef.UIChrPowerUpPanel, nil, 0, UIGroupType.Default, false, false, nil, false)
      if openUITask then
        openUITask:AddDependTask(openAvgTask)
      end
    else
      UISystem:OpenUI(UIDef.UIChrPowerUpPanel, nil, 0, UIGroupType.Default, false, false, nil, false)
    end
  end)
end
function UICommandCenterPanelV4:OnClickRecentActivity()
  if TipsManager.NeedLockTips(SystemList.RecentActivity) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    UIManager.OpenUI(UIDef.UIRecentActivityPanel)
  end)
end
function UICommandCenterPanelV4:OnClickHud()
  if self.isHide ~= nil and self.isHide then
    return
  end
  self:UnRegistrationAllKeyboard()
  self.isHide = true
  self.isHud = true
  if self:IsShowHudRedPoint() and SceneSys.currentScene.AnimatorPuppy ~= nil then
    SceneSys.currentScene.AnimatorPuppy:SetTrigger("finish_hint")
  end
  AudioUtils.PlayCommonAudio(1020282)
  UIManager.OpenUI(UIDef.UICommandCenterHudPanel)
end
function UICommandCenterPanelV4:OnClickSettings()
  self:UnRegistrationAllKeyboard()
  if not AccountNetCmdHandler.tempUnlockList.Count ~= 0 then
    self:CallWithAniDelay(function()
      UIManager.OpenUIByParam(UIDef.UICommanderInfoPanel, {isSelf = true})
    end)
  end
end
function UICommandCenterPanelV4:OnClickChangeBg()
  if self:IsShowHudRedPoint() and SceneSys.currentScene.AnimatorPuppy ~= nil then
    SceneSys.currentScene.AnimatorPuppy:SetTrigger("finish_hint")
  end
  self:UnRegistrationAllKeyboard()
  self.isHud = true
  self:CallWithAniDelay(function()
    UIManager.OpenUI(UIDef.UICommandCenterBgChangePanel)
  end)
end
function UICommandCenterPanelV4:CallWithAniDelay(callback)
  self.super.CallWithAniDelay(self, callback)
  if self:IsShowHudBtn() then
    UIUtils.AnimatorFadeOut(self.ui.mAnim_Hud)
  end
end
function UICommandCenterPanelV4:UpdateNewTask()
  local curPhase = NetCmdQuestData:GetCurPhaseId()
  local guidePhaseData = TableData.listGuideQuestPhaseDatas:GetDataById(curPhase)
  self.ui.mImg_PhaseReward.sprite = IconUtils.GetAtlasSprite(guidePhaseData.CommandRewardShow)
  local dataList = TableData.listGuideQuestPhaseDatas:GetList()
  if dataList == nil then
    gferror("GuideQuestPhase新手任务表为空或者读不到！！")
    return
  end
  local totalPhaseNum = dataList[dataList.Count - 1].id
  local completePhaseNum = NetCmdQuestData:GetCompletedPhaseNum()
  setactive(self.ui.mBtn_NewTask, totalPhaseNum ~= completePhaseNum)
end
function UICommandCenterPanelV4:OnClickNewTask()
  UIManager.OpenUI(UIDef.UINewTaskPanel)
end
function UICommandCenterPanelV4:OpenCampaign()
  UIUniTopBarPanel:Show(false)
  UIBattleIndexGlobal.CachedTabIndex = -1
  self:UnRegistrationAllKeyboard()
  UIManager.OpenUI(UIDef.UIBattleIndexPanel)
  self.bCanClick = true
end
function UICommandCenterPanelV4:OnReconnectSuc()
  local uiBasePanel = UISystem:GetTopUI()
  if uiBasePanel == nil or uiBasePanel.UIDefine.UIType ~= UIDef.UICommandCenterPanel then
    return
  end
  TimerSys:DelayFrameCall(1, function()
    CS.MessageBox.Close()
    self:StartCommanderCheckQueue()
  end)
end
