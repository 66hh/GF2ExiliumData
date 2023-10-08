require("UI.UIBasePanel")
require("UI.CommandCenterPanel.UICommandCenterPanelView")
require("UI.UniTopbar.UIUniTopBarPanel")
UICommandCenterPanel = class("UICommandCenterPanel", UIBasePanel)
UICommandCenterPanel.__index = UICommandCenterPanel
local self = UICommandCenterPanel
UICommandCenterPanel.mView = nil
UICommandCenterPanel.checkStep = 0
UICommandCenterPanel.bCanClick = true
UICommandCenterPanel.mTrans_Background = nil
UICommandCenterPanel.chatTimer = nil
UICommandCenterPanel.chatRefreshTime = 0
UICommandCenterPanel.chatSpeed = 45
UICommandCenterPanel.chatDelay = 4
UICommandCenterPanel.autoRoll = nil
UICommandCenterPanel.bannerList = {}
UICommandCenterPanel.indicatorList = {}
UICommandCenterPanel.isFrist = true
UICommandCenterPanel.onClickPVP = false
UICommandCenterPanel.RedPointType = {
  RedPointConst.ChapterReward,
  RedPointConst.SimulateBattle,
  RedPointConst.Daily,
  RedPointConst.Mails,
  RedPointConst.Notice,
  RedPointConst.Friend,
  RedPointConst.ApplyFriend,
  RedPointConst.LoungeChat,
  RedPointConst.Barracks,
  RedPointConst.UAV,
  RedPointConst.Archives,
  RedPointConst.PVP,
  RedPointConst.CommandCenter,
  RedPointConst.CommandCenterIndoor,
  RedPointConst.CommandCenterOutDoor
}
UICommandCenterPanel.CheckQueue = {
  None = 0,
  NickName = 1,
  Reconnection = 2,
  Poster = 3,
  Notice = 4,
  CheckIn = 5,
  Unlock = 6,
  Guide = 7,
  Finish = 8
}
function UICommandCenterPanel:ctor(csPanel)
  UICommandCenterPanel.super.ctor(self, csPanel)
  csPanel.HideSceneBackground = false
end
function UICommandCenterPanel:OnInit(root, data)
  UICommandCenterPanel.super.SetRoot(UICommandCenterPanel, root)
  UICommandCenterPanel.mView = UICommandCenterPanelView.New()
  UICommandCenterPanel.mView:InitCtrl(root)
  UICommandCenterPanel.chatRefreshTime = TableData.GlobalSystemData.ChatRefreshCd
  UICommandCenterPanel.mShowSceneObj = true
  UICommandCenterPanel:SetMaskEnable(true)
  self:UpDateDarkZoneData()
  self:InitRedPointObj()
  self:InitButtonGroup()
  self.mUIRoot = root
  MessageSys:AddListener(CS.GF2.Message.UIEvent.ConversationMsg, UICommandCenterPanel.ConversationMessage)
  MessageSys:AddListener(CS.GF2.Message.UIEvent.ConversationEndMsg, UICommandCenterPanel.ConversationEndMessage)
  MessageSys:AddListener(CS.GF2.Message.CampaignEvent.ResInfoUpdate, UICommandCenterPanel.RefreshInfo)
  MessageSys:AddListener(CS.GF2.Message.UIEvent.SystemUnlockEvent, UICommandCenterPanel.SystemUnLock)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Chapters, self.mView.mItem_Battle.transRedPoint, nil, self.mView.mItem_Battle.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Daily, self.mView.mItem_DailyTask.transRedPoint, nil, self.mView.mItem_DailyTask.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Notice, self.mView.mItem_Post.transRedPoint, nil, self.mView.mItem_Post.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Mails, self.mView.mItem_Mail.transRedPoint, nil, self.mView.mItem_Mail.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Barracks, self.mView.mItem_Barrack.transRedPoint, nil, self.mView.mItem_Barrack.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Chat, self.mView.mItem_Chat.transRedPoint, nil, self.mView.mItem_PlayerInfo.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.UAV, self.mView.mItem_UAV.transRedPoint, nil, self.mView.mItem_UAV.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Friend, self.mView.mItem_Friend.transRedPoint, nil, self.mView.mItem_Friend.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Store, self.mView.mItem_Exchange.transRedPoint, nil, self.mView.mItem_Exchange.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.LoungeChat, self.mView.mItem_LoungeChat.transRedPoint, function(node)
    UICommandCenterPanel:UdpateLoungeChatRedPoint(node)
  end, self.mView.mItem_LoungeChat.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Archives, self.mView.mItem_Archives.transRedPoint, nil, self.mView.mItem_Archives.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.CommandCenter, self.mView.mItem_Adjutant.transRedPoint)
  self:UpdatePlayerInfo()
  self:InitGM()
end
function UICommandCenterPanel:InitGM()
  if CS.DebugCenter.Instance:IsOn(CS.DebugToggleType.ShowCommandGMButton) then
    instantiate(UIUtils.GetGizmosPrefab("GameCommand/Btn_GMCommandEnter.prefab"), self.mUIRoot.transform)
  end
end
function UICommandCenterPanel:UpDateDarkZoneData()
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
function UICommandCenterPanel:CheckDarkZoneIsInOpenTime()
  local nowtime = CS.CGameTime.ConvertUintToDateTime(CGameTime:GetTimestamp())
  return true
end
function UICommandCenterPanel:UdpateLoungeChatRedPoint(node)
end
function UICommandCenterPanel:InitBanner()
  local count = PostInfoConfig.BannerDataList.Count
  if count == 0 then
    return
  end
  self:OnHideSlideShow()
  if 2 < count then
    for i = 0, count - 1 do
      local indicatorObj = instantiate(UIUtils.GetGizmosPrefab("CommandCenter/CommandCenterIndicatorItemV2.prefab", self))
      CS.LuaUIUtils.SetParent(indicatorObj, self.mView.parentIndicator.gameObject)
      table.insert(self.indicatorList, indicatorObj)
      local start = math.floor((count + 1) / 2)
      local current = start + i
      if count <= current then
        current = current - count
      end
      self:InstantiateBanner(PostInfoConfig.BannerDataList[current])
    end
    self.mView.slideShow.startingIndex = math.floor(count / 2)
  elseif count == 2 then
    self:InstantiateBanner(PostInfoConfig.BannerDataList[0])
    self:InstantiateBanner(PostInfoConfig.BannerDataList[1])
    for i = 0, count - 1 do
      local indicatorObj = instantiate(UIUtils.GetGizmosPrefab("CommandCenter/CommandCenterIndicatorItemV2.prefab", self))
      CS.LuaUIUtils.SetParent(indicatorObj, self.mView.parentIndicator.gameObject)
      table.insert(self.indicatorList, indicatorObj)
      self:InstantiateBanner(PostInfoConfig.BannerDataList[i])
    end
    self.mView.slideShow.startingIndex = 2
  else
    self:InstantiateBanner(PostInfoConfig.BannerDataList[0])
    for i = 0, count - 1 do
      local indicatorObj = instantiate(UIUtils.GetGizmosPrefab("CommandCenter/CommandCenterIndicatorItemV2.prefab", self))
      CS.LuaUIUtils.SetParent(indicatorObj, self.mView.parentIndicator.gameObject)
      table.insert(self.indicatorList, indicatorObj)
      self:InstantiateBanner(PostInfoConfig.BannerDataList[i])
    end
    self:InstantiateBanner(PostInfoConfig.BannerDataList[0])
    self.mView.slideShow.startingIndex = 1
    self.mView.slideShow:SetData(1)
  end
  self.mView.slideShow:SetData(count)
end
function UICommandCenterPanel:InstantiateBanner(data)
  local bannerObj = instantiate(UIUtils.GetGizmosPrefab("CommandCenter/CommandcenterBanneItemV2.prefab", self))
  local img = bannerObj.transform:Find("Img_Banner"):GetComponent("Image")
  setactive(img.gameObject, false)
  CS.LuaUtils.DownloadTextureFromUrl(data.pic_url, function(tex)
    if not CS.LuaUtils.IsNullOrDestroyed(bannerObj) then
      local img = bannerObj.transform:Find("Img_Banner"):GetComponent("Image")
      if img ~= nil then
        setactive(img.gameObject, true)
        img.sprite = CS.UIUtils.TextureToSprite(tex)
      end
    end
  end)
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
  self.mView.slideShow:PushLayoutElement(bannerObj, data.delay)
  table.insert(self.bannerList, bannerObj)
end
function UICommandCenterPanel:InitButtonGroup()
  UIUtils.GetButtonListener(self.mView.mBtn_PlayerInfo.gameObject).onClick = function()
    UICommandCenterPanel:OnClickPlayerInfo()
  end
  UIUtils.GetButtonListener(self.mView.mItem_Adjutant.btn.gameObject).onClick = function()
    UICommandCenterPanel:OpenAdjutant()
  end
  UIUtils.GetButtonListener(self.mView.mItem_Chat.btn.gameObject).onClick = function()
    UICommandCenterPanel:OnClickChat()
  end
  UIUtils.GetButtonListener(self.mView.mItem_Chat.btnIcon.gameObject).onClick = function()
    UICommandCenterPanel:OnClickChat()
  end
  UIUtils.GetButtonListener(self.mView.mItem_LoungeChat.btn.gameObject).onClick = function()
    UICommandCenterPanel:OnClickLoungeChat()
  end
  UIUtils.GetButtonListener(self.mView.mItem_DailyTask.btn.gameObject).onClick = function()
    UICommandCenterPanel:OnClickDailyQuest()
  end
  UIUtils.GetButtonListener(self.mView.mItem_Friend.btn.gameObject).onClick = function()
    UICommandCenterPanel:OnClickFriend()
  end
  UIUtils.GetButtonListener(self.mView.mItem_Post.btn.gameObject).onClick = function()
    UICommandCenterPanel:OnClickPost()
  end
  UIUtils.GetButtonListener(self.mView.mItem_Mail.btn.gameObject).onClick = function()
    UICommandCenterPanel:OnClickMail()
  end
  UIUtils.GetButtonListener(self.mView.mItem_Archives.btn.gameObject).onClick = function()
    UICommandCenterPanel:OnClickArchives()
  end
  UIUtils.GetButtonListener(self.mView.mItem_Guild.btn.gameObject).onClick = function()
    UICommandCenterPanel:OnClickGuild()
  end
  UIUtils.GetButtonListener(self.mView.mItem_UAV.btn.gameObject).onClick = function()
    UICommandCenterPanel:OnClickUAV()
  end
  UIUtils.GetButtonListener(self.mView.mItem_Repository.btn.gameObject).onClick = function()
    UICommandCenterPanel:OnClickRepository()
  end
  UIUtils.GetButtonListener(self.mView.mItem_Exchange.btn.gameObject).onClick = function()
    UICommandCenterPanel:OnClickExchangeStore()
  end
  UIUtils.GetButtonListener(self.mView.mItem_Dorm.btn.gameObject).onClick = function()
    UICommandCenterPanel:OnClickDorm()
  end
  UIUtils.GetButtonListener(self.mView.mItem_PVP.btn.gameObject).onClick = function()
    UICommandCenterPanel:OnClickPVP()
  end
  UIUtils.GetButtonListener(self.mView.mItem_Gacha.btn.gameObject).onClick = function()
    UICommandCenterPanel:OnClickGacha()
  end
  UIUtils.GetButtonListener(self.mView.mItem_Barrack.btn.gameObject).onClick = function()
    UICommandCenterPanel:OnClickBarrack()
  end
  UIUtils.GetButtonListener(self.mView.mItem_Battle.btn.gameObject).onClick = function()
    UICommandCenterPanel:OnClickBattle()
  end
  UIUtils.GetButtonListener(self.mView.mItem_DarkZone.btn.gameObject).onClick = function()
    UICommandCenterPanel:ClickDarkZone()
  end
  UIUtils.GetButtonListener(self.mView.mItem_DutyTactics.btn.gameObject).onClick = function()
    UICommandCenterPanel:OnClickProfessionTalentEntrance()
  end
  local entranceVisible = CS.UnityEngine.Application.isEditor
  setactive(self.mView.mItem_Barrack.btn.gameObject.transform.parent, entranceVisible)
  setactive(self.mView.mItem_UAV.btn.gameObject.transform.parent, false)
end
function UICommandCenterPanel:InitKeyCode()
  self:RegistrationKeyboard(KeyCode.L, self.mView.mItem_DailyTask.btn)
  self:RegistrationKeyboard(KeyCode.O, self.mView.mItem_Post.btn)
  self:RegistrationKeyboard(KeyCode.M, self.mView.mItem_Mail.btn)
  self:RegistrationKeyboard(KeyCode.R, self.mView.mItem_Archives.btn)
  self:RegistrationKeyboard(KeyCode.H, self.mView.mItem_Guild.btn)
  self:RegistrationKeyboard(KeyCode.B, self.mView.mItem_Repository.btn)
  self:RegistrationKeyboard(KeyCode.E, self.mView.mItem_Exchange.btn)
  self:RegistrationKeyboard(KeyCode.P, self.mView.mItem_PVP.btn)
  self:RegistrationKeyboard(KeyCode.G, self.mView.mItem_Gacha.btn)
  self:RegistrationKeyboard(KeyCode.Escape, self.mView.mBtn_PlayerInfo)
end
function UICommandCenterPanel.Close()
  UIManager.CloseUI(UIDef.UICommandCenterPanel)
end
function UICommandCenterPanel:OnShowFinish()
  self.isPlayAni = true
  CS.ResUpdateSys.Instance:ForceDownloadUpdatePostData()
  self:UpdateRedPoint()
  self:UpdateSystemUnLockInfo()
  self:InitBanner()
  self:InitChatContent()
  NetCmdTalentData:ReqProfessionTalent(function()
    setactive(UICommandCenterPanel.mView.mItem_DutyTactics.transRedPoint, UITalentGlobal.AnyProTalentUpgradeable())
  end)
  setactive(self.mView.mTrans_Conversation, false)
end
function UICommandCenterPanel:OnShowStart()
  self:InitKeyCode()
end
function UICommandCenterPanel:OnBackFrom()
  self:InitKeyCode()
end
function UICommandCenterPanel:OnRecover()
  self:InitKeyCode()
end
function UICommandCenterPanel:OnHide()
  if self.chatTimer then
    self.chatTimer:Stop()
  end
end
function UICommandCenterPanel:OnHideSlideShow()
  self.mView.slideShow:StopTimer()
  for i = 1, #self.bannerList do
    self.mView.slideShow:PopLayoutElement()
  end
  self.bannerList = {}
  for i = 1, #self.indicatorList do
    gfdestroy(self.indicatorList[i])
  end
  self.indicatorList = {}
end
function UICommandCenterPanel:OnClose()
  self:OnHideSlideShow()
  self.mView = nil
  self.ModelPoint = nil
  self.checkStep = 0
  self.isPlayAni = false
  self.autoRoll = nil
  self.isFrist = true
  if self.chatTimer then
    self.chatTimer:Stop()
    self.chatTimer = nil
  end
  self.DarkUnlockTime = nil
  self.darkzoneIsInOpen = nil
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.ConversationMsg, UICommandCenterPanel.ConversationMessage)
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.ConversationEndMsg, UICommandCenterPanel.ConversationEndMessage)
  MessageSys:RemoveListener(CS.GF2.Message.CampaignEvent.ResInfoUpdate, UICommandCenterPanel.RefreshInfo)
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.SystemUnlockEvent, UICommandCenterPanel.SystemUnLock)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Chapters)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Daily)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Notice)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Mails)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Barracks)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Chat)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.UAV)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Friend)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.LoungeChat)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Archives)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Store)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.CommandCenter)
end
function UICommandCenterPanel:CommanderCheckQueue()
  local isLogin = AccountNetCmdHandler:IsLogin()
  if isLogin == false then
    return
  end
  self.checkStep = self.checkStep + 1
  if self.checkStep == UICommandCenterPanel.CheckQueue.None then
    return
  elseif self.checkStep == UICommandCenterPanel.CheckQueue.NickName then
    self:NickPlayerName()
  elseif self.checkStep == UICommandCenterPanel.CheckQueue.Reconnection then
    self:CheckReconnectBattle()
  elseif self.checkStep == UICommandCenterPanel.CheckQueue.Poster then
    self:CheckPoster()
  elseif self.checkStep == UICommandCenterPanel.CheckQueue.Notice then
    self:CheckNotice()
  elseif self.checkStep == UICommandCenterPanel.CheckQueue.CheckIn then
    self:CheckDailyCheckIn()
  elseif self.checkStep == UICommandCenterPanel.CheckQueue.Unlock then
    self:CheckUnlock()
  elseif self.checkStep == UICommandCenterPanel.CheckQueue.Guide then
    self:CheckGuide()
  elseif self.checkStep == UICommandCenterPanel.CheckQueue.Finish then
    self:SetMaskEnable(false)
    self.checkStep = UICommandCenterPanel.CheckQueue.None
    MessageSys:SendMessage(CS.GF2.Message.CommonEvent.PlayDefaultConversation, nil)
  end
end
function UICommandCenterPanel:NickPlayerName()
  if not AccountNetCmdHandler:GetRecordFlag(GlobalConfig.RecordFlag.NameModified) then
    if CS.UnityEngine.Application.isEditor and not CS.DebugCenter.Instance.TutorialDebug then
      AccountNetCmdHandler:SendInitRoleInfo("指挥官", 0, 101, function(CMDRet)
        self:CommanderCheckQueue()
      end)
      return
    end
    UIManager.OpenUIByParam(UIDef.UINickNamePanel, function()
      self:CommanderCheckQueue()
    end)
  else
    self:CommanderCheckQueue()
  end
end
function UICommandCenterPanel:CheckReconnectBattle()
  if AccountNetCmdHandler:CheckNeedReconnectBattle(function()
    self:CommanderCheckQueue()
  end) then
  else
    self:CommanderCheckQueue()
  end
end
function UICommandCenterPanel:CheckPoster()
  if PostInfoConfig.CanShowPost() then
    UIPosterPanel.Open(function()
      self:CommanderCheckQueue()
    end)
  else
    self:CommanderCheckQueue()
  end
end
function UICommandCenterPanel:CheckNotice()
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
function UICommandCenterPanel:CheckDailyCheckIn()
  if not self:CheckSystemIsLock(SystemList.Checkin) and not NetCmdCheckInData:IsChecked() then
    NetCmdCheckInData:SendGetDailyCheckInCmd(self.SendCheckInCallback)
  else
    self:CommanderCheckQueue()
  end
end
function UICommandCenterPanel:CheckGuide()
  MessageSys:SendMessage(GuideEvent.EnterMainMenuPanel, nil)
  self:CommanderCheckQueue()
end
function UICommandCenterPanel:CheckUnlock()
  if not AccountNetCmdHandler:ContainsUnlockId(UIDef.UICommandCenterPanel) then
    self:CommanderCheckQueue()
  else
    if AccountNetCmdHandler.tempUnlockList.Count > 0 then
      for i = 0, AccountNetCmdHandler.tempUnlockList.Count - 1 do
        local unlockData = TableData.listUnlockDatas:GetDataById(AccountNetCmdHandler.tempUnlockList[i])
        if unlockData.interface_id == UIDef.UICommandCenterPanel then
          UICommonUnlockPanel.Open(unlockData, function()
            UICommandCenterPanel:CheckUnlock()
          end)
          return
        end
      end
    end
    self:CommanderCheckQueue()
  end
end
function UICommandCenterPanel.SendCheckInCallback(ret)
  self = UICommandCenterPanel
  if NetCmdCheckInData:IsChecked() then
    self:CommanderCheckQueue()
  else
    UIManager.OpenUIByParam(UIDef.UIDailyCheckInPanel, function()
      self:CommanderCheckQueue()
    end)
  end
end
function UICommandCenterPanel.RefreshInfo()
  UICommandCenterPanel:UpdatePlayerInfo()
  UICommandCenterPanel:UpdateSystemUnLockInfo()
end
function UICommandCenterPanel:UpdatePlayerInfo()
  self.mView.mText_PlayerName.text = AccountNetCmdHandler:GetName()
  self.mView.mImage_PlayerAvatar.sprite = IconUtils.GetPlayerAvatar(AccountNetCmdHandler:GetAvatar())
  self.mView.mText_PlayerLevel.text = GlobalConfig.SetLvText(AccountNetCmdHandler:GetLevel())
  self.mView.mImage_PlayerExp.fillAmount = AccountNetCmdHandler:GetExpPct()
  self:UpdateStageInfo()
end
function UICommandCenterPanel:UpdateStageInfo()
  local storyData = NetCmdDungeonData:GetCurrentStory()
  if storyData then
    local data = TableData.GetStorysByChapterID(storyData.chapter)
    local total = data.Count * 3
    local stars = NetCmdDungeonData:GetCurStarsByChapterID(storyData.chapter) + NetCmdDungeonData:GetFinishChapterStoryCountByChapterID(storyData.chapter) * 3
    self.mView.mItem_Battle.txtPercent.text = tostring(math.ceil(stars / total * 100)) .. "%"
    self.mView.mItem_Battle.txtLevel.text = storyData.code.str
  end
end
function UICommandCenterPanel.ConversationMessage(msg)
  self = UICommandCenterPanel
  setactive(self.mView.mTrans_Conversation, true)
  setactive(self.mView.mText_Conversation.gameObject, msg.Content ~= nil)
  if msg.Content then
    self.mView.mText_Conversation.text = msg.Content.str
  end
end
function UICommandCenterPanel.ConversationEndMessage(msg)
  self = UICommandCenterPanel
  if self.mView.mDialogAnimator then
    self.mView.mDialogAnimator:SetTrigger("Fadeout")
  end
  TimerSys:DelayCall(0.5, function()
    if UICommandCenterPanel.mView and UICommandCenterPanel.mView.mTrans_Conversation then
      setactive(UICommandCenterPanel.mView.mTrans_Conversation, false)
    end
  end)
end
function UICommandCenterPanel:InitChatContent()
  if self.chatTimer then
    self.chatTimer:Stop()
  end
  self.autoRoll = CS.LuaDOTweenUtils.SetChatRoll(self.mView.mItem_Chat.chatContent, UICommandCenterPanel.chatSpeed, UICommandCenterPanel.chatDelay)
  self:UpdateChatContent()
  self.chatTimer = TimerSys:DelayCall(UICommandCenterPanel.chatRefreshTime, function()
    self:UpdateChatContent()
  end, nil, -1)
end
function UICommandCenterPanel:UpdateChatContent()
  local data = NetCmdChatData:GetTopMessageInPool()
  if self.mView.mItem_Chat.animator and self.mView.mItem_Chat.txtAnimator then
    if data then
      if not self.mView.mItem_Chat.chatIsOn then
        self.mView.mItem_Chat.animator:SetBool("OnOff", true)
        self.mView.mItem_Chat.chatIsOn = true
      end
      self.mView.mItem_Chat.txtAnimator:SetTrigger("Switch")
      self.mView.mItem_Chat.txtContent.text = data.message
      if self.autoRoll then
        self.autoRoll:ResetAndStart()
      end
    else
      self.mView.mItem_Chat.animator:SetBool("OnOff", false)
      self.mView.mItem_Chat.chatIsOn = false
    end
  end
end
function UICommandCenterPanel:OnClickPlayerInfo()
  if not AccountNetCmdHandler.tempUnlockList.Count ~= 0 then
    self:UnRegistrationAllKeyboard()
    self:CallWithAniDelay(function()
      UIManager.OpenUI(UIDef.UICommanderInfoPanel)
    end)
  end
end
function UICommandCenterPanel:OpenAdjutant()
  self:UnRegistrationAllKeyboard()
  UIManager.OpenUI(UIDef.UIAdjutantFunctionSelectPanel)
end
function UICommandCenterPanel:OnClickChat()
  self:UnRegistrationAllKeyboard()
  UIManager.OpenUIByParam(UIDef.UIChatPanel, {nil, true})
end
function UICommandCenterPanel:OnClickLoungeChat()
  if TipsManager.NeedLockTips(SystemList.Restroom) then
    return
  end
  self:UnRegistrationAllKeyboard()
  UIManager.OpenUIByParam(UIDef.UILoungeChatPanel)
end
function UICommandCenterPanel:OnClickDailyQuest()
  if TipsManager.NeedLockTips(SystemList.Quest) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    UIManager.OpenUI(UIDef.UIQuestPanel)
  end)
end
function UICommandCenterPanel:OnClickFriend()
  if TipsManager.NeedLockTips(SystemList.Friend) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
  end)
end
function UICommandCenterPanel:OnClickPost()
  if TipsManager.NeedLockTips(SystemList.Notice) then
    return
  end
  self:UnRegistrationAllKeyboard()
  UIManager.OpenUI(UIDef.UIPostPanelV2)
end
function UICommandCenterPanel:OnClickMail()
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
function UICommandCenterPanel:OnClickProfessionTalentEntrance()
  if TipsManager.NeedLockTips(SystemList.SquadTalent) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    UIManager.OpenUI(UIDef.UIProfessionTalentEntrancePanel)
  end)
end
function UICommandCenterPanel:OnClickArchives()
  if TipsManager.NeedLockTips(SystemList.Archives) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    UIManager.OpenUI(UIDef.ArchivesCenterEnterPanelV2)
  end)
end
function UICommandCenterPanel:OnClickGuild()
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
function UICommandCenterPanel:OnClickUAV()
  if TipsManager.NeedLockTips(SystemList.Uav) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    CS.UIMainPanel.EnterUAV()
  end)
end
function UICommandCenterPanel:OnClickRepository()
  if TipsManager.NeedLockTips(SystemList.Storage) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    UIManager.OpenUI(UIDef.UIRepositoryPanelV2)
  end)
end
function UICommandCenterPanel:OnClickExchangeStore()
  if TipsManager.NeedLockTips(SystemList.StoreEnterance) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    UIManager.OpenUI(UIDef.UIStoreEntrancePanel)
  end)
end
function UICommandCenterPanel:OnClickDorm()
  if TipsManager.NeedLockTips(SystemList.Restroom) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    CS.UIMainPanel.EnterDorm(7)
  end)
end
function UICommandCenterPanel:OnClickPVP()
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
function UICommandCenterPanel:OnClickGacha()
  if TipsManager.NeedLockTips(SystemList.Gacha) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    CS.UIMainPanel.EnterGashapon()
  end)
end
function UICommandCenterPanel:OnClickBarrack()
  if TipsManager.NeedLockTips(SystemList.Barrack) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    UIManager.OpenUI(UIDef.UIChrPowerUpPanel)
  end)
end
function UICommandCenterPanel:OnClickBattle()
  if TipsManager.NeedLockTips(SystemList.Battle) then
    return
  end
  if UICommandCenterPanel.bCanClick == false then
    return
  end
  self.mView.mAnimator:SetTrigger("FadeOut")
  UICommandCenterPanel.ModelPoint = CS.UnityEngine.GameObject.Find("Model_Point").transform:GetChild(0)
  UICommandCenterPanel.ModelAnim = UICommandCenterPanel.ModelPoint:GetComponent("Animator")
  if UICommandCenterPanel.ModelAnim:GetCurrentAnimatorStateInfo(0):IsName("idle") then
    UICommandCenterPanel.ModelAnim:SetTrigger("move")
  end
  UICommandCenterPanel.mTrans_Background = CS.UnityEngine.GameObject.Find("Background")
  UICommandCenterPanel.bCanClick = false
  self:UnRegistrationAllKeyboard()
  TimerSys:DelayCall(0.6, function(obj)
    UICommandCenterPanel.OpenCampaign()
  end)
end
function UICommandCenterPanel.OpenCampaign()
  self = UICommandCenterPanel
  UIUniTopBarPanel:Show(false)
  UIManager.OpenUI(UIDef.UIBattleIndexPanel)
  UICommandCenterPanel.bCanClick = true
end
function UICommandCenterPanel.OnStoreClicked(gameobj)
  self = UICommandCenterPanel
  if TipsManager.NeedLockTips(SystemList.Store) then
    return
  end
  local params = {1, false}
  UIManager.OpenUIByParam(UIDef.UIStoreMainPanel, params)
end
function UICommandCenterPanel:UpdateSystemUnLockInfo()
  for i, item in ipairs(self.mView.systemList) do
    self:UpdateSystemUnLockInfoByItem(item)
  end
end
function UICommandCenterPanel:UpdateSystemUnLockInfoByItem(item)
  if item and item.systemId then
    local isLock = self:CheckSystemIsLock(item.systemId)
    if item.animator then
      item.animator:SetBool("LockState", not isLock)
    end
    if item.systemId == SystemList.Darkzone and not isLock and self.darkzoneIsInOpen ~= self:CheckDarkZoneIsInOpenTime() then
      if self:CheckDarkZoneIsInOpenTime() then
        item.txtUnlock.text = TableData.GetHintById(901059)
      end
      self.darkzoneIsInOpen = self:CheckDarkZoneIsInOpenTime()
    end
  end
end
function UICommandCenterPanel:CheckSystemIsLock(type)
  return not AccountNetCmdHandler:CheckSystemIsUnLock(type)
end
function UICommandCenterPanel.SystemUnLock()
  self = UICommandCenterPanel
  printstack("有新的系统解锁了奥")
  self:UpdateSystemUnLockInfo()
end
function UICommandCenterPanel:ClickDarkZone()
  if not self:CheckDarkZoneIsInOpenTime() then
    UIUtils.PopupPositiveHintMessage(903001)
    return
  end
  if TipsManager.NeedLockTips(SystemList.Darkzone) then
    return
  end
  self:UnRegistrationAllKeyboard()
  self:CallWithAniDelay(function()
    UIManager.OpenUI(UIDef.UIDarkZoneMainPanel)
  end)
end
function UICommandCenterPanel:SetMaskEnable(enable)
  setactive(UICommandCenterPanel.mView.mTrans_Mask, enable)
end
function UICommandCenterPanel:EnableModelPoint(enable)
  setactive(self.ModelPoint, enable)
end
function UICommandCenterPanel:InitRedPointObj()
  for i, item in ipairs(self.mView.systemList) do
    if item.transRedPoint then
      self:InstanceUIPrefab("UICommonFramework/ComRedPointItemV2.prefab", item.transRedPoint, true)
    end
  end
end
function UICommandCenterPanel:OnUpdate()
  if not self.isPlayAni or UICommandCenterPanel.checkStep ~= 0 or self.mCSPanel.ShowType.value__ == 3 then
    self:SetMaskEnable(false)
    return
  end
  local state = UICommandCenterPanel.mView.mAnimator:GetCurrentAnimatorStateInfo(0)
  if state:IsName("Ani_CommandCenter_FadeIn") and state.normalizedTime > 1 then
    self.isPlayAni = false
    UICommandCenterPanel.checkStep = 0
    self:SetMaskEnable(true)
    self:CommanderCheckQueue()
  end
end
function UICommandCenterPanel:OnFadeInFinish()
end
