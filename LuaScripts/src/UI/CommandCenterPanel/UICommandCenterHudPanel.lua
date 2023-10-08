require("UI.CommandCenterPanel.Item.CommanderMidTab")
require("UI.CommandCenterPanel.Item.CommandCenterTopBtn")
require("UI.CommandCenterPanel.Item.HudCenterBottomBtn")
UICommandCenterHudPanel = class("self", UIBasePanel)
UICommandCenterHudPanel.__index = UICommandCenterHudPanel
function UICommandCenterHudPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  self.csPanel = csPanel
  csPanel.HideSceneBackground = false
  csPanel.Is3DPanel = true
  self.RedPointType = {
    RedPointConst.StoryBattleStage,
    RedPointConst.SimResourceStageIndex,
    RedPointConst.SimulateBattle,
    RedPointConst.Daily,
    RedPointConst.Mails,
    RedPointConst.Notice,
    RedPointConst.PlayerInfo,
    RedPointConst.Friend,
    RedPointConst.Repository,
    RedPointConst.Barracks,
    RedPointConst.Archives,
    RedPointConst.Gacha,
    RedPointConst.RecentActivity,
    RedPointConst.BattlePass,
    RedPointConst.Store
  }
  self.chatTimer = nil
  self.chatRefreshTime = 0
  self.chatSpeed = 45
  self.chatDelay = 4
  self.systemList = {}
  self.midTabItemList = {}
  self.topTabItemList = {}
  self.bottomTabItemList = {}
end
function UICommandCenterHudPanel:OnInit(root, data)
  self.super.SetRoot(self, root)
  self.mUIRoot = root
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.mNowTime = 0
  self.chatRefreshTime = TableData.GlobalSystemData.ChatRefreshCd
  self:InitCommandCenterPanelUI()
  self:InitButtonGroup()
  function self.systemUnLock(message)
    self:SystemUnLock(message)
  end
  function self.refreshInfo(message)
    self:RefreshInfo(message)
  end
  function self.openChatPanel(message)
    UIManager.OpenUIByParam(UIDef.UICommunicationPanel, {nil, true})
  end
  MessageSys:AddListener(CS.GF2.Message.ChatEvent.OpenChatPanel, self.openChatPanel)
  MessageSys:AddListener(CS.GF2.Message.CampaignEvent.ResInfoUpdate, self.refreshInfo)
  MessageSys:AddListener(CS.GF2.Message.UIEvent.SystemUnlockEvent, self.systemUnLock)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.PlayerInfo, self.mItem_PlayerInfo.transRedPoint, nil, self.mItem_PlayerInfo.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Barracks, self.mItem_Barrack.transRedPoint, nil, self.mItem_Barrack.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Repository, self.mItem_Repository.transRedPoint, nil, self.mItem_Repository.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Store, self.mItem_Exchange.transRedPoint, nil, self.mItem_Exchange.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Archives, self.mItem_Archives.transRedPoint, nil, self.mItem_Archives.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.BattlePass, self.mItem_BattlePass.transRedPoint, nil, self.mItem_BattlePass.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Notice, self.mItem_Post.transRedPoint, nil, self.mItem_Post.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Mails, self.mItem_Mail.transRedPoint, nil, self.mItem_Mail.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Gacha, self.mItem_Gacha.transRedPoint)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.RecentActivity, self.mItem_RecentActivity.transRedPoint)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Friend, self.mItem_Chat.transRedPoint, nil, self.mItem_Chat.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.StoryBattleStage, self.mItem_BattleMainEasy.transRedPoint, nil, self.mItem_BattleMainEasy.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.SimResourceStageIndex, self.mItem_BattleDaily.transRedPoint, nil, self.mItem_BattleDaily.systemId)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.SimulateBattle, self.mItem_BattleSim.transRedPoint, nil, self.mItem_BattleSim.systemId)
  UIRedPointWatcher.BindRedPoint(self.mItem_Activity.transRedPoint, NewRedPointConst.Activity, function(path, num)
    self:RefreshActivityEntrance()
  end)
end
function UICommandCenterHudPanel:RefreshActivityEntrance()
  if UIUtils.IsNullOrDestroyed(self.mUIRoot) or UIUtils.IsNullOrDestroyed(self.mItem_Activity.btn) then
    return
  end
  local isActivityUnLock = AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.Activity)
  local isShow = NetCmdOperationActivityData:HasShowingActivity()
  setactive(self.mItem_Activity.btn.gameObject, isActivityUnLock and isShow)
end
function UICommandCenterHudPanel:InitCommandCenterPanelUI()
  local dataList = TableData.listCommandMenuDatas:GetList()
  local topTabTable = {}
  local midTabTable = {}
  local bottomTabTable = {}
  for i = 0, dataList.Count - 1 do
    local data = dataList[i]
    if data.Type == 1 then
      table.insert(topTabTable, data)
    elseif data.Type == 2 then
      table.insert(midTabTable, data)
    elseif data.Type == 3 then
      table.insert(bottomTabTable, data)
    end
  end
  table.sort(topTabTable, function(a, b)
    return a.Sort < b.Sort
  end)
  table.sort(bottomTabTable, function(a, b)
    return a.Sort < b.Sort
  end)
  self.midTabItemList = {}
  local midTabObjs = {
    [13000] = self.ui.mObj_Gacha,
    [16000] = self.ui.mObj_Shop,
    [17000] = self.ui.mObj_Repository,
    [20000] = self.ui.mObj_Archives,
    [12000] = self.ui.mObj_Barrack
  }
  for _, tab in pairs(midTabTable) do
    local item = CommanderMidTab.New()
    item:InitCtrl(midTabObjs[tab.id])
    item:SetData(tab.id)
    table.insert(self.midTabItemList, item)
    if tab.id == 13000 then
      self.mItem_Gacha = item
    elseif tab.id == 16000 then
      self.mItem_Exchange = item
    elseif tab.id == 12000 then
      self.mItem_Barrack = item
    elseif tab.id == 17000 then
      self.mItem_Repository = item
    elseif tab.id == 20000 then
      self.mItem_Archives = item
    end
    table.insert(self.systemList, item)
  end
  for _, item in pairs(self.bottomTabItemList) do
    item:OnRelease()
  end
  self.bottomTabItemList = {}
  for i = 2, #bottomTabTable do
    local tab = bottomTabTable[i]
    local item = self:InitHudCenterBottomBtn(tab.id, tab.name.str)
    if tab.id == 10999 then
      self.mItem_BattleSim = item
    elseif tab.id == 10998 then
      self.mItem_BattleDaily = item
    elseif tab.id == 10997 then
      self.mItem_BattleMainHard = item
      self:UpdateBarnchState(self:CheckSystemIsLock(item.systemId))
    elseif tab.id == 11001 then
      self.mItem_BattleMainEasy = item
    end
  end
  for _, item in pairs(self.topTabItemList) do
    item:OnRelease()
  end
  self.topTabItemList = {}
  self.mItem_CheckIn = self:InitCommandCenterTopBtn(SystemList.Checkin, "CheckIn")
  self.mItem_Mail = self:InitCommandCenterTopBtn(SystemList.Mail, "Mail")
  self.mItem_Post = self:InitCommandCenterTopBtn(SystemList.Notice, "Post")
  self.mItem_BattlePass = self:InitCommandCenterTopBtn(SystemList.Battlepass, "BP")
  setactive(self.mItem_BattlePass.btn.gameObject, NetCmdBattlePassData.IsOpen and AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.Battlepass))
  self.mItem_Activity = self:InitCommandCenterTopBtn(SystemList.Activity, "Activity")
  self.mItem_PlayerInfo = self:InitAvatar(self.ui.mTrans_PlayerAvatar)
  self.mItem_RecentActivity = self:InitRecentActivityBtn(self.ui.mBtn_RecentActivity, SystemList.RecentActivity)
  self.mItem_Chat = self:InitChat()
end
function UICommandCenterHudPanel:InitChat()
  local parent = self.ui.mTrans_Chat
  local isLock = self:CheckSystemIsLock(SystemList.Friend)
  setactive(parent.gameObject, not isLock)
  NetCmdChatData:CheckRobotSpecialChats()
  if parent then
    local item = {}
    item.systemId = SystemList.Friend
    item.parent = parent
    item.chatIsOn = false
    item.txtContent = self.ui.mText_ChatText
    item.txtAnimator = self.ui.mAnimator_ChatText
    item.btn = parent:GetComponent(typeof(CS.UnityEngine.UI.GFButton))
    item.btnIcon = self.ui.mTrans_ChatInfo
    item.transTitle = self.ui.mTrans_ChatTitle
    item.transRedPoint = self.ui.mTrans_RedPoint_Chat
    table.insert(self.systemList, item)
    return item
  end
end
function UICommandCenterHudPanel:InitCommandCenterTopBtn(systemId, iconName)
  local CommandCenterTopBtn = CommandCenterTopBtn.New()
  CommandCenterTopBtn:InitCtrl(self.ui.mScrollListChild_GrpTabSwitch, systemId, iconName)
  table.insert(self.systemList, CommandCenterTopBtn)
  CommandCenterTopBtn:CheckUnLock()
  table.insert(self.topTabItemList, CommandCenterTopBtn)
  return CommandCenterTopBtn
end
function UICommandCenterHudPanel:InitHudCenterBottomBtn(systemId, name)
  local HudCenterBottomBtn = HudCenterBottomBtn.New()
  HudCenterBottomBtn:InitCtrl(self.ui.mScrollListChild_GrpHudBottom, systemId, name)
  if systemId == 10999 then
    HudCenterBottomBtn:HideDot()
  end
  table.insert(self.systemList, HudCenterBottomBtn)
  table.insert(self.bottomTabItemList, HudCenterBottomBtn)
  return HudCenterBottomBtn
end
function UICommandCenterHudPanel:InitRecentActivityBtn(btn, systemId)
  local parent = btn:GetComponent(typeof(CS.UnityEngine.RectTransform))
  if parent then
    local item = {}
    item.systemId = systemId
    item.parent = parent
    item.btn = btn.transform:Find("Root"):GetComponent(typeof(CS.UnityEngine.UI.GFButton))
    item.animator = btn.transform:Find("Root"):GetComponent(typeof(CS.UnityEngine.Animator))
    item.animator:SetBool("Unlock", AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.RecentActivity))
    item.transRedPoint = item.btn.transform:Find("Trans_RedPoint"):GetComponent(typeof(CS.UnityEngine.RectTransform))
    table.insert(self.systemList, item)
    return item
  end
end
function UICommandCenterHudPanel:InitAvatar(rectTransform)
  local parent = rectTransform
  if parent then
    local item = {}
    item.parent = parent
    item.btn = self.ui.mBtn_PlayerAvatar
    item.transRedPoint = self.ui.mObj_RedPointAvatar.gameObject:GetComponent(typeof(CS.UnityEngine.RectTransform))
    table.insert(self.systemList, item)
    return item
  end
end
function UICommandCenterHudPanel:InitButtonGroup()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self.isHud = true
    SceneSys.currentScene:SetSceneGaussianBlur(0)
    self:UnRegistrationAllKeyboard()
    self.Close()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_PlayerAvatar.gameObject).onClick = function()
    self:OnClickPlayerInfo()
  end
  UIUtils.GetButtonListener(self.mItem_Gacha.btn.gameObject).onClick = function()
    self:OnClickGacha()
  end
  UIUtils.GetButtonListener(self.mItem_Barrack.btn.gameObject).onClick = function()
    self:OnClickBarrack()
  end
  UIUtils.GetButtonListener(self.mItem_Repository.btn.gameObject).onClick = function()
    self:OnClickRepository()
  end
  UIUtils.GetButtonListener(self.mItem_Exchange.btn.gameObject).onClick = function()
    self:OnClickExchangeStore()
  end
  UIUtils.GetButtonListener(self.mItem_Archives.btn.gameObject).onClick = function()
    self:OnClickArchives()
  end
  UIUtils.GetButtonListener(self.mItem_BattlePass.btn.gameObject).onClick = function()
    self:OnClickBattlePass()
  end
  UIUtils.GetButtonListener(self.mItem_Post.btn.gameObject).onClick = function()
    self:OnClickPost()
  end
  UIUtils.GetButtonListener(self.mItem_CheckIn.btn.gameObject).onClick = function()
    self:OnClickCheckIn()
  end
  UIUtils.GetButtonListener(self.mItem_Mail.btn.gameObject).onClick = function()
    self:OnClickMail()
  end
  UIUtils.GetButtonListener(self.mItem_Activity.btn.gameObject).onClick = function()
    self:OnClickActivity()
  end
  UIUtils.GetButtonListener(self.mItem_RecentActivity.btn.gameObject).onClick = function()
    self:OnClickRecentActivity()
  end
  UIUtils.GetButtonListener(self.mItem_BattleSim.btn.gameObject).onClick = function()
    self:OnClickBattleSim()
  end
  UIUtils.GetButtonListener(self.mItem_BattleDaily.btn.gameObject).onClick = function()
    self:OnClickBattleDaily()
  end
  UIUtils.GetButtonListener(self.mItem_BattleMainHard.btn.gameObject).onClick = function()
    self:OnClickBattleMainHard()
  end
  UIUtils.GetButtonListener(self.mItem_BattleMainEasy.btn.gameObject).onClick = function()
    self:OnClickBattleMainEasy()
  end
  UIUtils.GetButtonListener(self.mItem_Chat.btn.gameObject).onClick = function()
    self:OnClickChat()
  end
end
function UICommandCenterHudPanel:OnClickBattlePass()
  if TipsManager.NeedLockTips(SystemList.Battlepass) then
    return
  end
  local mIsCurBpOpen = NetCmdBattlePassData:CheckCurBpIsOpen()
  if not mIsCurBpOpen then
    return
  end
  SceneSys.currentScene:SetSceneGaussianBlur(0)
  self:CallWithAniDelay(function()
    NetCmdBattlePassData:SendGetBattlepassInfo(function(ret)
      if ret == ErrorCodeSuc then
        self:UnRegistrationAllKeyboard()
        UIManager.OpenUI(UIDef.UIBattlePassPanel)
      end
    end)
  end)
end
function UICommandCenterHudPanel:SystemUnLock()
  self:UpdateSystemUnLockInfo()
end
function UICommandCenterHudPanel:RefreshInfo()
  self:UpdatePlayerInfo()
  self:UpdateSystemUnLockInfo()
end
function UICommandCenterHudPanel:UpdatePlayerInfo()
  self.ui.mText_PlayerName.text = AccountNetCmdHandler:GetName()
  local frameId = AccountNetCmdHandler:GetAvatarFrame()
  if frameId == 0 or frameId == TableData.GlobalSystemData.PlayerAvatarFrameDefault then
    setactive(self.ui.mImage_AvatarFrame, false)
  else
    setactive(self.ui.mImage_AvatarFrame, true)
    local frameData = TableData.listHeadFrameDatas:GetDataById(frameId)
    if frameData ~= nil then
      self.ui.mImage_AvatarFrame.sprite = IconUtils.GetPlayerAvatarFrame(frameData.icon)
    end
  end
  self.ui.mImage_PlayerAvatar.sprite = IconUtils.GetPlayerAvatar(AccountNetCmdHandler:GetAvatar())
  self.ui.mText_Lv.text = AccountNetCmdHandler:GetLevel()
  self.ui.mImage_PlayerExp.FillAmount = AccountNetCmdHandler:GetExpPct()
  setactive(self.ui.mImg_MonthCard, AccountNetCmdHandler:IsMonCard())
end
function UICommandCenterHudPanel:UpdateSystemUnLockInfo()
  for i, item in ipairs(self.systemList) do
    self:UpdateSystemUnLockInfoByItem(item)
  end
end
function UICommandCenterHudPanel:UpdateSystemUnLockInfoByItem(item)
  if item and item.systemId then
    local isLock = self:CheckSystemIsLock(item.systemId)
    if item.systemId == 10997 then
      self:UpdateBarnchState(isLock)
    elseif item.animator then
      item.animator:SetBool("Unlock", not isLock)
    end
  end
end
function UICommandCenterHudPanel:CheckSystemIsLock(type)
  return not AccountNetCmdHandler:CheckSystemIsUnLock(type)
end
function UICommandCenterHudPanel:InitRedPointObj()
  for i, item in ipairs(self.systemList) do
    if item.systemId ~= SystemList.RecentActivity and item.transRedPoint then
      self:InstanceUIPrefab("UICommonFramework/ComRedPointItemV2.prefab", item.transRedPoint, true)
    end
  end
end
function UICommandCenterHudPanel:UpdateBarnchState(islock)
  self.isCanInitBranchStory = false
  self.chapterId = 0
  if islock == false then
    local indexData = TableData.listStageIndexDatas:GetDataById(5)
    if indexData and 0 < indexData.detail_id.Count then
      for i = 0, indexData.detail_id.Count - 1 do
        local chapterData = TableData.listChapterDatas:GetDataById(indexData.detail_id[i])
        if chapterData then
          local planActivity = TableData.listPlanDatas:GetDataById(chapterData.plan_id)
          if planActivity and CGameTime:GetTimestamp() >= planActivity.open_time and CGameTime:GetTimestamp() < planActivity.close_time then
            self.isCanInitBranchStory = true
            self.chapterId = chapterData.id
            break
          end
        end
      end
    end
  end
  if not islock and self.isCanInitBranchStory then
    self.mItem_BattleMainHard.animator:SetBool("Unlock", true)
  else
    self.mItem_BattleMainHard.animator:SetBool("Unlock", false)
  end
end
function UICommandCenterHudPanel.Close()
  UIManager.CloseUI(UIDef.UICommandCenterHudPanel)
end
function UICommandCenterHudPanel:OnUpdate(deltatime)
  self.mNowTime = self.mNowTime + deltatime
  if self.mNowTime > 2 then
    self.mNowTime = 0
    self.mIsCurBpOpen = NetCmdBattlePassData:CheckCurBpIsOpen()
    setactive(self.mItem_BattlePass.btn.gameObject, self.mIsCurBpOpen and AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.Battlepass))
  end
end
function UICommandCenterHudPanel:InitChatContent()
  if self.chatTimer then
    self.chatTimer:Stop()
  end
  self.autoRoll = CS.LuaDOTweenUtils.SetChatRoll(self.mItem_Chat.chatContent, self.chatSpeed, self.chatDelay)
  self:UpdateChatContent()
  self.chatTimer = TimerSys:DelayCall(self.chatRefreshTime, function()
    self:UpdateChatContent()
  end, nil, -1)
end
function UICommandCenterHudPanel:UpdateChatContent()
  local data = NetCmdChatData:GetTopMessageInPool()
  if self.mItem_Chat.txtAnimator then
    if data then
      setactive(self.mItem_Chat.transTitle, false)
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
      setactive(self.mItem_Chat.transTitle, true)
      setactive(self.mItem_Chat.btnIcon.gameObject, false)
    end
  end
end
function UICommandCenterHudPanel:InitKeyCode()
  self:RegistrationKeyboard(KeyCode.Return, self.mItem_Chat.btn)
  self:RegistrationKeyboard(KeyCode.B, self.mItem_Repository.btn)
  self:RegistrationKeyboard(KeyCode.G, self.mItem_Gacha.btn)
  self:RegistrationKeyboard(KeyCode.C, self.mItem_Barrack.btn)
  self:RegistrationKeyboard(KeyCode.D, self.mItem_RecentActivity.btn)
  self:RegistrationKeyboard(KeyCode.J, self.mItem_CheckIn.btn)
  self:RegistrationKeyboard(KeyCode.M, self.mItem_Mail.btn)
  self:RegistrationKeyboard(KeyCode.O, self.mItem_Post.btn)
  self:RegistrationKeyboard(KeyCode.V, self.mItem_BattlePass.btn)
  self:RegistrationKeyboard(KeyCode.F, self.mItem_Activity.btn)
  self:RegistrationKeyboard(KeyCode.E, self.mItem_Exchange.btn)
  self:RegistrationKeyboard(KeyCode.K, self.mItem_Archives.btn)
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Close)
end
function UICommandCenterHudPanel:OnCameraStart()
  if UISystem:GetTopUI(UIGroupType.Default).UIDefine.UIType == UIDef.UICommandCenterPanel then
    return 0.01
  else
    return 0
  end
end
function UICommandCenterHudPanel:OnCameraBack()
  if self.isHud then
    return 0.01
  else
    return 0
  end
end
function UICommandCenterHudPanel:OnShowFinish()
  SceneSys.currentScene:SetSceneGaussianBlur(1)
  self:CheckBackground()
  self:UpdatePlayerInfo()
  self:UpdateRedPoint()
  setactive(self.ui.mTrans_ActivitieOpen, NetCmdThemeData:GetThemeRedState() < 3)
  self:UpdateSystemUnLockInfo()
  self:InitChatContent()
  self:InitKeyCode()
  if SceneSys.currentScene.AnimatorPuppy.transform:Find("root/Root_M/EFF_Dinergate_Projection") ~= nil then
    setactive(SceneSys.currentScene.AnimatorPuppy.transform:Find("root/Root_M/EFF_Dinergate_Projection"), true)
  end
end
function UICommandCenterHudPanel:OnTop()
  local root = UIUtils.GetRectTransform(self.mUIRoot, "Root")
  if root then
    local animtor = root.gameObject:GetComponent("Animator")
    animtor:SetTrigger("FadeIn")
  end
  if SceneSys.currentScene.AnimatorPuppy.transform:Find("root/Root_M/EFF_Dinergate_Projection") ~= nil then
    setactive(SceneSys.currentScene.AnimatorPuppy.transform:Find("root/Root_M/EFF_Dinergate_Projection"), true)
  end
end
function UICommandCenterHudPanel:OnRecover(data, behaviorId, isTop)
  self:UpdatePlayerInfo()
  self:CheckBackground()
end
function UICommandCenterHudPanel:OnShowStart()
  self:UpdatePlayerInfo()
  self:CheckBackground()
end
function UICommandCenterHudPanel:OnBackFrom()
  SceneSys:SwitchVisible(EnumSceneType.CommandCenter)
  self:UpdatePlayerInfo()
  self:CheckBackground()
end
function UICommandCenterHudPanel:OnHide()
  if self.isHud == nil or not self.isHud then
  end
  if self.chatTimer then
    self.chatTimer:Stop()
  end
end
function UICommandCenterHudPanel:OnClose()
  self.ui = nil
  self.midTabItemList = {}
  for _, item in pairs(self.bottomTabItemList) do
    item:OnRelease()
  end
  self.bottomTabItemList = {}
  for _, item in pairs(self.topTabItemList) do
    item:OnRelease()
  end
  self.topTabItemList = {}
  if self.chatTimer then
    self.chatTimer:Stop()
    self.chatTimer = nil
  end
  MessageSys:RemoveListener(CS.GF2.Message.ChatEvent.OpenChatPanel, self.openChatPanel)
  MessageSys:RemoveListener(CS.GF2.Message.CampaignEvent.ResInfoUpdate, self.refreshInfo)
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.SystemUnlockEvent, self.systemUnLock)
  if SceneSys.currentScene.AnimatorPuppy.transform:Find("root/Root_M/EFF_Dinergate_Projection") ~= nil then
    setactive(SceneSys.currentScene.AnimatorPuppy.transform:Find("root/Root_M/EFF_Dinergate_Projection"), false)
  end
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.PlayerInfo)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Barracks)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Repository)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Store)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Archives)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.BattlePass)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Notice)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Mails)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.RecentActivity)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Friend)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.StoryBattleStage)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.SimResourceStageIndex)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.SimulateBattle)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Gacha)
end
function UICommandCenterHudPanel:OnHideFinish()
  if self.isHud then
    self.isHud = false
    return
  end
  SceneSys.currentScene:HideBackgroundVideo()
end
function UICommandCenterHudPanel:CheckBackground()
  local bgData = TableData.listCommandBackgroundDatas:GetDataById(NetCmdCommandCenterData.Background)
  if bgData.type ~= 2 then
    SceneSys.currentScene:StopBackgroundVideo()
  else
    SceneSys.currentScene:PlayBackgroundVideo(bgData.bg)
  end
end
function UICommandCenterHudPanel:OnClickPlayerInfo()
  self:UnRegistrationAllKeyboard()
  if not AccountNetCmdHandler.tempUnlockList.Count ~= 0 then
    SceneSys.currentScene:SetSceneGaussianBlur(0)
    self:CallWithAniDelay(function()
      UIManager.OpenUIByParam(UIDef.UICommanderInfoPanel, {isSelf = true})
    end)
  end
end
function UICommandCenterHudPanel:OnClickGacha()
  if TipsManager.NeedLockTips(SystemList.Gacha) then
    return
  end
  self:UnRegistrationAllKeyboard()
  SceneSys.currentScene:SetSceneGaussianBlur(0)
  self:CallWithAniDelay(function()
    UIManager.OpenUIByParam(UIDef.UIGashaponMainPanel, {true})
  end)
end
function UICommandCenterHudPanel:OnClickBarrack()
  if TipsManager.NeedLockTips(SystemList.Barrack) then
    return
  end
  self:UnRegistrationAllKeyboard()
  SceneSys.currentScene:SetSceneGaussianBlur(0)
  self:CallWithAniDelay(function()
    UIManager.OpenUI(UIDef.UIChrPowerUpPanel)
  end)
end
function UICommandCenterHudPanel:OnClickRepository()
  if TipsManager.NeedLockTips(SystemList.Storage) then
    return
  end
  self:UnRegistrationAllKeyboard()
  SceneSys.currentScene:SetSceneGaussianBlur(0)
  self:CallWithAniDelay(function()
    UIManager.OpenUI(UIDef.UIRepositoryPanelV2)
  end)
end
function UICommandCenterHudPanel:OnClickExchangeStore()
  if TipsManager.NeedLockTips(SystemList.StoreEnterance) then
    return
  end
  self:UnRegistrationAllKeyboard()
  SceneSys.currentScene:SetSceneGaussianBlur(0)
  self:CallWithAniDelay(function()
    UIManager.OpenUI(UIDef.UIStoreEntrancePanel)
  end)
end
function UICommandCenterHudPanel:OnClickArchives()
  if TipsManager.NeedLockTips(SystemList.Archives) then
    return
  end
  self:UnRegistrationAllKeyboard()
  SceneSys.currentScene:SetSceneGaussianBlur(0)
  self:CallWithAniDelay(function()
    UIManager.OpenUI(UIDef.ArchivesCenterEnterPanelV2)
  end)
end
function UICommandCenterHudPanel:OnClickPost()
  if TipsManager.NeedLockTips(SystemList.Notice) then
    return
  end
  self:UnRegistrationAllKeyboard()
  SceneSys.currentScene:SetSceneGaussianBlur(0)
  if SceneSys.currentScene.AnimatorPuppy.transform:Find("root/Root_M/EFF_Dinergate_Projection") ~= nil then
    setactive(SceneSys.currentScene.AnimatorPuppy.transform:Find("root/Root_M/EFF_Dinergate_Projection"), false)
  end
  self:CallWithAniDelay(function()
    UIManager.OpenUI(UIDef.UIPostPanelV2)
  end)
end
function UICommandCenterHudPanel:OnClickCheckIn()
  if TipsManager.NeedLockTips(SystemList.Checkin) then
    return
  end
  self:UnRegistrationAllKeyboard()
  SceneSys.currentScene:SetSceneGaussianBlur(0)
  if SceneSys.currentScene.AnimatorPuppy.transform:Find("root/Root_M/EFF_Dinergate_Projection") ~= nil then
    setactive(SceneSys.currentScene.AnimatorPuppy.transform:Find("root/Root_M/EFF_Dinergate_Projection"), false)
  end
  self:CallWithAniDelay(function()
    UIManager.OpenUIByParam(UIDef.UIDailyCheckInPanel)
  end)
end
function UICommandCenterHudPanel:OnClickMail()
  if TipsManager.NeedLockTips(SystemList.Mail) then
    return
  end
  self:UnRegistrationAllKeyboard()
  SceneSys.currentScene:SetSceneGaussianBlur(0)
  self:CallWithAniDelay(function()
    NetCmdMailData:SendReqRoleMailsCmd(function()
      UIManager.OpenUI(UIDef.UIMailPanelV2)
    end)
  end)
end
function UICommandCenterHudPanel:OnClickActivity()
  if TipsManager.NeedLockTips(SystemList.Activity) then
    return
  end
  self:UnRegistrationAllKeyboard()
  if NetCmdOperationActivityData:HasShowingActivity() then
    SceneSys.currentScene:SetSceneGaussianBlur(0)
    if SceneSys.currentScene.AnimatorPuppy.transform:Find("root/Root_M/EFF_Dinergate_Projection") ~= nil then
      setactive(SceneSys.currentScene.AnimatorPuppy.transform:Find("root/Root_M/EFF_Dinergate_Projection"), false)
    end
    self:CallWithAniDelay(function()
      UIManager.OpenUI(UIDef.UIActivityDialog)
    end)
  end
end
function UICommandCenterHudPanel:OnClickRecentActivity()
  if TipsManager.NeedLockTips(SystemList.RecentActivity) then
    return
  end
  self:UnRegistrationAllKeyboard()
  SceneSys.currentScene:SetSceneGaussianBlur(0)
  self:CallWithAniDelay(function()
    UIManager.OpenUI(UIDef.UIRecentActivityPanel)
  end)
end
function UICommandCenterHudPanel:OnClickBattleSim()
  if TipsManager.NeedLockTips(SystemList.BattleSim) then
    return
  end
  self:UnRegistrationAllKeyboard()
  SceneSys.currentScene:SetSceneGaussianBlur(0)
  self:CallWithAniDelay(function()
    local menuData = TableData.listCommandMenuDatas:GetDataById(10999)
    SceneSwitch:SwitchByID(menuData.jump)
  end)
end
function UICommandCenterHudPanel:OnClickBattleDaily()
  if TipsManager.NeedLockTips(SystemList.BattleDaily) then
    return
  end
  self:UnRegistrationAllKeyboard()
  SceneSys.currentScene:SetSceneGaussianBlur(0)
  self:CallWithAniDelay(function()
    local menuData = TableData.listCommandMenuDatas:GetDataById(10998)
    SceneSwitch:SwitchByID(menuData.jump)
  end)
end
function UICommandCenterHudPanel:OnClickBattleMainHard()
  if TipsManager.NeedLockTips(SystemList.BattleTemporary) then
    return
  end
  if not self.isCanInitBranchStory then
    PopupMessageManager.PopupString(TableData.GetHintById(210005))
    return
  end
  UIManager.OpenUIByParam(UIDef.UIBattleIndexPanel, {5})
end
function UICommandCenterHudPanel:OnClickBattleMainEasy()
  if TipsManager.NeedLockTips(SystemList.BattleMainEasy) then
    return
  end
  self:UnRegistrationAllKeyboard()
  SceneSys.currentScene:SetSceneGaussianBlur(0)
  self:CallWithAniDelay(function()
    local menuData = TableData.listCommandMenuDatas:GetDataById(11001)
    SceneSwitch:SwitchByID(menuData.jump)
  end)
end
function UICommandCenterHudPanel:OnClickChat()
  self:UnRegistrationAllKeyboard()
  SceneSys.currentScene:SetSceneGaussianBlur(0)
  SceneSys.currentScene:MovePuppy(true)
  NetCmdChatData:SendGetAllFriendChat(function()
    UIManager.OpenUIByParam(UIDef.UICommunicationPanel, {nil, true})
  end)
end
