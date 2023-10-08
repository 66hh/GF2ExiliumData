require("UI.UIBaseCtrl")
require("UI.Common.UICommonPlayerAvatarItem")
require("UI.CommanderInfoPanel.Item.UICommonReputationItem")
require("UI.UICommonModifyPanel.CommanderInfoGlobal")
require("UI.UICommonModifyPanel.UICommanderInfoAchievementItem")
UIPlayerInfoItem = class("UIPlayerInfoItem", UIBaseCtrl)
UIPlayerInfoItem.__index = UIPlayerInfoItem
UIPlayerInfoItem.IconStr = "Icon_Character_"
UIPlayerInfoItem.ModifyType = {
  Name = 1,
  Avatar = 2,
  BirthDay = 3,
  Sign = 4,
  AssistGun = 5,
  Reputation = 6,
  Medal = 7,
  AvatarFrame = 8
}
UIPlayerInfoItem.BtnType = {
  Self = 1,
  Friend = 2,
  Stranger = 3,
  Black = 4,
  Robot = 5
}
UIPlayerInfoItem.SignColor = Color(ColorUtils.GrayColor2.r, ColorUtils.GrayColor2.g, ColorUtils.GrayColor2.b, 0.423)
function UIPlayerInfoItem:ctor(parentPanel)
  self.playerInfo = nil
  self.playerAvatar = nil
  self.mReputationTitle = nil
  self.supportList = nil
  self.parentPanel = parentPanel
  self.robotInfo = nil
end
function UIPlayerInfoItem:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("CommanderInfo/CommanderInfoCardDialog.prefab", self))
  if parent then
    self.mParent = parent
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
  end
  self:SetRoot(obj.transform)
  self.ui = {}
  self.AchieveList = {}
  self:LuaUIBindTable(obj.transform, self.ui)
  self:ComCtrl()
end
function UIPlayerInfoItem:ComCtrl()
  function self.clickMedalRedPoint(msg)
    if self.robotInfo == nil and self.playerInfo.Medal ~= 0 then
      setactive(self.ui.mTrans_MedalRedPoint.gameObject, self.playerInfo.UID == AccountNetCmdHandler:GetUID() and 0 < NetCmdIllustrationData:CheckItemTypeShowRedPoint(GlobalConfig.ItemType.Medal))
    else
      setactive(self.ui.mTrans_MedalRedPoint.gameObject, false)
    end
  end
  MessageSys:AddListener(CS.GF2.Message.UIEvent.ClickMedalRedPoint, self.clickMedalRedPoint)
  self:__InitCtrl()
end
function UIPlayerInfoItem:__InitCtrl()
end
function UIPlayerInfoItem:OnRelease()
  if self.playerAvatar then
    gfdestroy(self.playerAvatar.mUIRoot)
    self.playerAvatar = nil
  end
  if self.mReputationTitle then
    gfdestroy(self.mReputationTitle.mUIRoot)
    self.mReputationTitle = nil
  end
  if self.AchieveList then
    for i = 1, #self.AchieveList do
      gfdestroy(self.AchieveList[i]:GetRoot())
    end
  end
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.ClickMedalRedPoint, self.clickMedalRedPoint)
end
function UIPlayerInfoItem:SetData(data)
  self.playerInfo = data
  if data.PortraitFrame == 0 then
    self.playerInfo.PortraitFrame = TableData.GlobalSystemData.PlayerAvatarFrameDefault
  end
  self.AchieveList = {}
  self:UpdatePlayerInfo()
  self:UpdateMedal()
end
function UIPlayerInfoItem:SetRobotData(data)
  self.robotInfo = data
end
function UIPlayerInfoItem:UpdatePlayerInfo()
  self:SetItems()
  self:UpdatePlayerContent()
  self:UpdatePlayerMotto()
  self:UpdateAchievements()
  if self.robotInfo == nil and self.playerInfo.UID ~= nil and self.playerInfo.UID ~= 0 then
    if self.playerInfo.UID == AccountNetCmdHandler:GetUID() then
      self:SetBtnGroup(self.BtnType.Self)
    elseif NetCmdFriendData:IsFriend(self.playerInfo.UID) then
      self:SetBtnGroup(self.BtnType.Friend)
    elseif NetCmdFriendData:IsBlack(self.playerInfo.UID) then
      self:SetBtnGroup(self.BtnType.Black)
    else
      self:SetBtnGroup(self.BtnType.Stranger)
    end
    setactive(self.ui.mTrans_GrpExp.gameObject, true)
    self:InitFriendButtons()
    self.ui.mBtn_Signature.interactable = self.playerInfo.UID == AccountNetCmdHandler:GetUID()
    self.ui.mText_PlayerLvNum.text = TableData.GetHintById(55) .. tostring(self.playerInfo.Level)
    if self.playerInfo.Mark == "" or self.playerInfo.Mark == nil then
      self.ui.mText_PlayerName.text = self.playerInfo.Name
    else
      self.ui.mText_PlayerName.text = self.playerInfo.Name .. "(#" .. self.playerInfo.Mark .. ")"
    end
    self.ui.mText_Name.text = TableData.GetHintById(100201)
    self.ui.mText_SetTime.text = CS.CGameTime.ConvertLongToDateTime(self.playerInfo.CreateTime):ToString("yyyy.MM.dd")
    self.ui.mText_Name01.text = TableData.GetHintById(100202)
    self.ui.mText_SetTime01.text = tostring(self.playerInfo.GunCollectNum)
    self.ui.mText_Name02.text = TableData.GetHintById(100203)
    if self.playerInfo.MaxStage ~= 0 then
      self.ui.mText_SetTime02.text = TableData.listStageDatas:GetDataById(self.playerInfo.MaxStage).code.str
    end
    self.playerAvatar:SetData(self.playerInfo.Icon)
    self.playerAvatar:SetFrameDataOut(self.playerInfo.IconFrame)
    setactive(self.ui.mImg_MonthCard, self.playerInfo:IsMonCard())
  else
    self:SetBtnGroup(self.BtnType.Robot)
    setactive(self.ui.mBtn_Rename, false)
    setactive(self.ui.mImg_MonthCard, false)
    if self.robotInfo then
      self.playerAvatar:SetData(self.robotInfo.head_icon)
      setactive(self.ui.mTrans_GrpUID.gameObject, false)
      setactive(self.ui.mTrans_GrpExp.gameObject, false)
      local gunList = TableData.listGunCharacterDatas:GetDataById(self.robotInfo.id)
      local gun
      for i = 0, gunList.unit_id.Count - 1 do
        gun = NetCmdTeamData:GetGunByID(gunList.unit_id[i])
        if gun then
          break
        end
      end
      if gun then
        self.ui.mText_PlayerLvNum.text = TableData.GetHintById(55) .. tostring(gun.level)
        self.ui.mText_PlayerName.text = self.robotInfo.name
        self.ui.mText_Name.text = TableData.GetHintById(101003)
        self.ui.mText_SetTime.text = CS.CGameTime.ConvertLongToDateTime(gun.mGun.Timestamp):ToString("yyyy.MM.dd")
        self.ui.mText_Name01.text = TableData.GetHintById(110007)
        self.ui.mText_SetTime01.text = gunList.body_id.str
        self.ui.mText_Name02.text = TableData.GetHintById(110008)
        self.ui.mText_SetTime02.text = gunList.brand.str
      else
        gferror("人形机器人获取异常")
      end
      self.ui.mText_Signature.text = self.robotInfo.message
      self.ui.mBtn_Signature.interactable = false
      if self.robotInfo.Medal ~= 0 and self.robotInfo.Medal ~= nil and self.robotInfo.Medal ~= TableData.GlobalSystemData.PlayerMedalDefault then
        local medalData = TableData.listIdcardMedalDatas:GetDataById(self.robotInfo.Medal)
        self.ui.mImg_MedalIcon.sprite = IconUtils.GetIconV2("Item", medalData.icon)
        setactive(self.ui.mTrans_BadgeIcon, true)
        setactive(self.ui.mTrans_MedalNo, false)
      else
        setactive(self.ui.mTrans_BadgeIcon, false)
        setactive(self.ui.mTrans_MedalNo, true)
      end
      if self.robotInfo.Title ~= 0 and self.robotInfo.Title ~= nil and self.robotInfo.Title ~= TableData.GlobalSystemData.PlayerTitleDefault then
        if self.mReputationTitle == nil then
          self.mReputationTitle = UICommonReputationItem.New()
          self.mReputationTitle:InitCtrl(self.ui.mTrans_ReputationTitle)
        end
        setactive(self.mReputationTitle:GetRoot(), true)
        setactive(self.ui.mTrans_ReputationNo, false)
        self.mReputationTitle:EnableBtn(false)
        local titleData = TableData.listIdcardTitleDatas:GetDataById(self.robotInfo.Title)
        self.mReputationTitle:SetData(titleData.title.str, titleData.icon)
        self.mReputationTitle:SetRedPoint(false)
      else
        setactive(self.mReputationTitle:GetRoot(), false)
        setactive(self.ui.mTrans_ReputationNo, true)
      end
    end
  end
end
function UIPlayerInfoItem:UpdateSearchInteractive()
  if self.robotInfo == nil and self.playerInfo.UID ~= nil and self.playerInfo.UID ~= 0 and self.playerInfo.UID == AccountNetCmdHandler:GetUID() then
    self.ui.mBtn_Signature.interactable = false
    if self.mReputationTitle then
      self.mReputationTitle:EnableBtn(false)
      self.mReputationTitle:SetRedPoint(false)
    end
    self.playerAvatar:EnableBtn(false)
    self.playerAvatar:SetRedPoint(false)
    if self.ui.mBtn_Rename then
      setactive(self.ui.mBtn_Rename.gameObject, false)
    end
    if self.ui.mTrans_Actions then
      setactive(self.ui.mTrans_Actions.gameObject, false)
    end
    if self.ui.mTrans_MedalRedPoint then
      setactive(self.ui.mTrans_MedalRedPoint.gameObject, false)
    end
  end
end
function UIPlayerInfoItem:InitFriendButtons()
  UIUtils.GetButtonListener(self.ui.mBtn_BlackListAdd.gameObject).onClick = function()
    self:AddBlackList()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_FriendDelete.gameObject).onClick = function()
    self:DeleteFriend()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_FriendAdd.gameObject).onClick = function()
    self:AddFriend()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BlackListRemove.gameObject).onClick = function()
    self:RemoveBlackList()
  end
end
function UIPlayerInfoItem:SetItems()
  if self.playerAvatar == nil then
    self.playerAvatar = UICommonPlayerAvatarItem.New()
    self.playerAvatar:InitCtrlByScrollChild(self.ui.mScrollChild_PlayerAvatar.childItem, self.ui.mTrans_PlayerAvatar)
    self.playerAvatar:EnableBtn(false)
  end
  if self.mReputationTitle == nil and self.playerInfo.ReputationTitle ~= 0 and self.playerInfo.ReputationTitle ~= nil and self.playerInfo.ReputationTitle ~= TableData.GlobalSystemData.PlayerTitleDefault then
    self.mReputationTitle = UICommonReputationItem.New()
    self.mReputationTitle:InitCtrl(self.ui.mTrans_ReputationTitle)
    self.mReputationTitle:EnableBtn(false)
  end
  if self.robotInfo == nil and self.playerInfo.UID == AccountNetCmdHandler:GetUID() then
    self.playerAvatar:EnableBtn(true)
    if self.ui.mBtn_Signature then
      UIUtils.GetButtonListener(self.ui.mBtn_Signature.gameObject).onClick = function()
        self:OnClickSignRemark()
      end
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Rename.gameObject).onClick = function()
    self:OnClickRemark()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Copy.gameObject).onClick = function()
    self:OnClickCopyUid()
  end
end
function UIPlayerInfoItem:SetBtnGroup(btnType)
  setactive(self.ui.mTrans_Actions.gameObject, btnType ~= self.BtnType.Robot)
  setactive(self.ui.mTrans_LeftActions.gameObject, true)
  setactive(self.ui.mTrans_RightActions.gameObject, true)
  setactive(self.ui.mBtn_BlackListAdd.gameObject, btnType == self.BtnType.Friend or btnType == self.BtnType.Stranger)
  setactive(self.ui.mBtn_FriendDelete.transform.parent.gameObject, btnType == self.BtnType.Friend)
  setactive(self.ui.mBtn_FriendAdd.transform.parent.gameObject, btnType == self.BtnType.Stranger)
  setactive(self.ui.mBtn_BlackListRemove.transform.parent.gameObject, btnType == self.BtnType.Black)
  setactive(self.ui.mBtn_Rename, btnType == self.BtnType.Friend or btnType == self.BtnType.Black)
end
function UIPlayerInfoItem:UpdatePlayerContent()
  if self.playerInfo.Mark == "" or self.playerInfo.Mark == nil then
    self.ui.mText_PlayerName.text = self.playerInfo.Name
  else
    self.ui.mText_PlayerName.text = self.playerInfo.Name .. "(#" .. self.playerInfo.Mark .. ")"
  end
  local curExp = self.playerInfo.Exp
  local maxExp = 0
  if self.playerInfo.Level < TableData.GlobalSystemData.CommanderLevel then
    local data = TableData.listPlayerLevelDatas:GetDataById(self.playerInfo.Level + 1)
    maxExp = data.exp
    self.ui.mText_PlayerExpNum.text = curExp .. "/" .. maxExp
  else
    local data = TableData.listPlayerLevelDatas:GetDataById(TableData.GlobalSystemData.CommanderLevel)
    self.ui.mText_PlayerExpNum.text = TableData.GetHintById(111045)
  end
  setactive(self.ui.mTrans_GrpUID.gameObject, true)
  self.ui.mText_UID.text = self.playerInfo.UID
  self.ui.mText_PlayerLvNum.text = GlobalConfig.SetLvText(self.playerInfo.Level)
  self.playerAvatar:SetRedPoint(self.robotInfo == nil and self.playerInfo.UID == AccountNetCmdHandler:GetUID() and 0 < NetCmdIllustrationData:CheckItemTypeShowRedPoint(GlobalConfig.ItemType.PlayerAvatar))
  self:UpdateReputation()
end
function UIPlayerInfoItem:UpdatePlayerMotto()
  if self.playerInfo.PlayerMotto == nil or self.playerInfo.PlayerMotto == "" then
    self.ui.mText_Signature.text = CS.LuaUIUtils.Unescape(TableData.GetHintById(100013))
    self.ui.mText_Signature.color = self.SignColor
  else
    self.ui.mText_Signature.text = self.playerInfo.PlayerMotto
    self.ui.mText_Signature.color = ColorUtils.GrayColor3
  end
end
function UIPlayerInfoItem:UpdateReputation()
  if self.playerInfo.ReputationTitle ~= 0 and self.playerInfo.ReputationTitle ~= TableData.GlobalSystemData.PlayerTitleDefault then
    setactive(self.mReputationTitle:GetRoot(), true)
    setactive(self.ui.mTrans_ReputationNo, false)
    setactive(self.mReputationTitle.ui.mBtn_Reputation, true)
    local titleData = TableData.listIdcardTitleDatas:GetDataById(self.playerInfo.ReputationTitle)
    self.mReputationTitle:SetData(titleData.title.str, titleData.icon)
    self.mReputationTitle:SetRedPoint(0 < NetCmdIllustrationData:CheckItemTypeShowRedPoint(GlobalConfig.ItemType.Title) and self.playerInfo.UID == AccountNetCmdHandler:GetUID())
  else
    if self.mReputationTitle then
      setactive(self.mReputationTitle:GetRoot(), false)
      setactive(self.mReputationTitle.ui.mBtn_Reputation, false)
    end
    setactive(self.ui.mTrans_ReputationNo, true)
  end
end
function UIPlayerInfoItem:UpdateMedal()
  if self.playerInfo.Medal ~= 0 and self.playerInfo.Medal ~= nil and self.playerInfo.Medal ~= TableData.GlobalSystemData.PlayerMedalDefault then
    local medalData = TableData.listIdcardMedalDatas:GetDataById(self.playerInfo.Medal)
    self.ui.mImg_MedalIcon.sprite = IconUtils.GetIconV2("Item", medalData.icon)
    setactive(self.ui.mTrans_BadgeIcon, true)
    setactive(self.ui.mTrans_MedalNo, false)
  else
    setactive(self.ui.mTrans_BadgeIcon, false)
    setactive(self.ui.mTrans_MedalNo, true)
  end
end
function UIPlayerInfoItem:UpdateAchievements()
  local rewardList = {}
  for i = 0, TableData.listAchievementTagDatas.Count - 1 do
    local data = TableData.listAchievementTagDatas[i]
    local rewardId = NetCmdAchieveData:GetCurrentTagRewardId(data.id)
    local rewardData = TableData.listAchievementRewardDatas:GetDataById(rewardId)
    table.insert(rewardList, rewardData.tag_lv)
  end
  for i = CS.ProtoObject.AchieveRank.Gold.value__, CS.ProtoObject.AchieveRank.Plastics.value__ do
    local item = self.AchieveList[i + 1]
    if not item then
      item = UICommanderInfoAchievementItem.New()
      item:InitCtrl(self.ui.mScrollChild_Achieve.childItem, self.ui.mScrollChild_Achieve.transform)
      table.insert(self.AchieveList, item)
    end
    local num = 0
    if self.playerInfo then
      num = self.playerInfo:GetAchievementNum(i)
    else
      num = NetCmdAchieveData:AchievementRankNumByType(i + 1)
    end
    local icon = TableData.listAchievementTagDatas:GetDataById(i + 1).icon
    item:SetData(num, icon)
  end
  self.ui.mText_Attachment.text = TableData.GetHintById(104066)
end
function UIPlayerInfoItem:OnClickRemark()
  if self.playerInfo.UID == AccountNetCmdHandler:GetUID() and self.robotInfo == nil then
    local defaultStr = ""
    if self.playerInfo.Name ~= nil and self.playerInfo.Name ~= "" then
      defaultStr = self.playerInfo.Name
    end
    UIManager.OpenUIByParam(UIDef.UICommonSelfModifyPanel, {
      function(strName)
        self:OnClickConfirm(strName, UIPlayerInfoItem.ModifyType.Name)
      end,
      defaultStr
    })
  else
    local defaultStr = ""
    if self.playerInfo.Mark ~= nil and self.playerInfo.Mark ~= "" then
      defaultStr = self.playerInfo.Mark
    end
    UIManager.OpenUIByParam(UIDef.UICommonModifyPanel, {
      function(strName)
        self:OnClickConfirmRemark(strName)
      end,
      defaultStr
    })
  end
end
function UIPlayerInfoItem:OnCLickAvatar()
  local defaultStr = self.playerInfo.Portrait
  local defaultStrFrame = self.playerInfo.PortraitFrame
  if self.playerInfo.Portrait ~= nil and self.playerInfo.Portrait ~= "" then
    defaultStr = self.playerInfo.Portrait
  end
  UIManager.OpenUIByParam(UIDef.UICommonAvatarModifyPanel, {
    function(strName, type)
      self:OnClickConfirm(strName, type)
      UIUtils.PopupPositiveHintMessage(180014)
    end,
    defaultStr,
    defaultStrFrame
  })
end
function UIPlayerInfoItem:OnClickReputation()
  local defaultStr = self.playerInfo.ReputationTitle
  if self.playerInfo.ReputationTitle == 0 then
    defaultStr = TableData.GlobalSystemData.PlayerTitleDefault
  end
  UIManager.OpenUIByParam(UIDef.UICommonReputationModifyPanel, {
    function(strName)
      self:OnClickConfirm(strName, UIPlayerInfoItem.ModifyType.Reputation)
      UIUtils.PopupPositiveHintMessage(180014)
    end,
    defaultStr
  })
end
function UIPlayerInfoItem:OnClickMedal()
  local defaultStr = self.playerInfo.Medal
  if self.playerInfo.Medal == 0 then
    defaultStr = TableData.GlobalSystemData.PlayerMedalDefault
  end
  UIManager.OpenUIByParam(UIDef.UICommonMedalModifyPanel, {
    function(strName)
      self:OnClickConfirm(strName, UIPlayerInfoItem.ModifyType.Medal)
      UIUtils.PopupPositiveHintMessage(180014)
    end,
    defaultStr
  })
end
function UIPlayerInfoItem:OnClickSignRemark()
  local defaultStr = ""
  if self.playerInfo.PlayerMotto ~= nil and self.playerInfo.PlayerMotto ~= "" then
    defaultStr = self.playerInfo.PlayerMotto
  end
  UIManager.OpenUIByParam(UIDef.UICommonSignModifyPanel, {
    function(strName)
      self:OnClickConfirm(strName, UIPlayerInfoItem.ModifyType.Sign)
    end,
    defaultStr
  })
end
function UIPlayerInfoItem:OnClickConfirm(strName, type)
  if type == UIPlayerInfoItem.ModifyType.Name then
    AccountNetCmdHandler:SendModNameReq(strName, function(ret)
      self:OnChangeNoteCallback(ret, type)
    end)
  elseif type == UIPlayerInfoItem.ModifyType.Sign then
    AccountNetCmdHandler:SendReqModPlayerMotto(strName, function(ret)
      self:OnChangeNoteCallback(ret, type)
    end)
  elseif type == UIPlayerInfoItem.ModifyType.Avatar then
    AccountNetCmdHandler:SendReqModPlayerPortrait(tonumber(strName), function(ret)
      self:OnChangeNoteCallback(ret, type)
    end)
  elseif type == UIPlayerInfoItem.ModifyType.AvatarFrame then
    AccountNetCmdHandler:SendReqModPlayerPortraitFrame(tonumber(strName), function(ret)
      self:OnChangeNoteCallback(ret, type)
    end)
  elseif type == UIPlayerInfoItem.ModifyType.Reputation then
    AccountNetCmdHandler:SendReqModPlayerReputation(tonumber(strName), function(ret)
      self:OnChangeNoteCallback(ret, type)
    end)
  elseif type == UIPlayerInfoItem.ModifyType.Medal then
    AccountNetCmdHandler:SendReqModPlayerMedal(tonumber(strName), function(ret)
      self:OnChangeNoteCallback(ret, type)
    end)
  end
end
function UIPlayerInfoItem:OnClickConfirmRemark(strName)
  NetCmdFriendData:SendSetFriendMark(self.playerInfo.UID, strName, function(ret)
    if ret == ErrorCodeSuc then
      self.ui.mText_PlayerName.text = self.playerInfo.Name .. "(#" .. strName .. ")"
    else
      UIUtils.PopupHintMessage(60049)
    end
  end)
end
function UIPlayerInfoItem:AddBlackList()
  if not self.playerInfo.IsBlack then
    MessageBox.Show(TableData.GetHintById(64), TableData.GetHintById(100038), nil, function()
      NetCmdFriendData:SendSetBlackList(self.playerInfo.UID, function(ret)
        if ret == ErrorCodeSuc then
          UIUtils.PopupPositiveHintMessage(100050)
          MessageSys:SendMessage(CS.GF2.Message.FriendEvent.AddBlack, nil)
        end
      end)
    end)
  end
end
function UIPlayerInfoItem:RemoveBlackList()
  if self.playerInfo.IsBlack then
    NetCmdFriendData:SendUnsetBlackList(self.playerInfo.UID, function()
      UIUtils.PopupPositiveHintMessage(100047)
    end)
  end
end
function UIPlayerInfoItem:AddFriend()
  if self.playerInfo then
    if NetCmdFriendData:GetFriendCount() >= TableData.GetFriendLimit() then
      UIUtils.PopupHintMessage(60020)
      return
    end
    NetCmdFriendData:SendSocialFriendApply(self.playerInfo.UID, function()
      UIUtils.PopupPositiveHintMessage(100027)
    end)
  end
end
function UIPlayerInfoItem:DeleteFriend()
  if self.playerInfo then
    MessageBox.Show(TableData.GetHintById(64), TableData.GetHintById(100028), nil, function()
      NetCmdFriendData:SendSocialDeleteFriend(self.playerInfo.UID)
    end, nil)
  end
end
function UIPlayerInfoItem:OnClickCopyUid()
  CS.UnityEngine.GUIUtility.systemCopyBuffer = self.playerInfo.UID
  UIUtils.PopupPositiveHintMessage(7002)
end
function UIPlayerInfoItem:OnChangeNoteCallback(ret, type)
  if ret == ErrorCodeSuc then
    if type == UIPlayerInfoItem.ModifyType.Name then
      UIUtils.PopupPositiveHintMessage(7001)
      self:UpdatePlayerContent()
      UIManager.CloseUI(UIDef.UICommonSelfModifyPanel)
    elseif type == UIPlayerInfoItem.ModifyType.Sign then
      UIUtils.PopupPositiveHintMessage(7001)
      self:UpdatePlayerMotto()
      UIManager.CloseUI(UIDef.UICommonSignModifyPanel)
    elseif type == UIPlayerInfoItem.ModifyType.Avatar then
      self.playerAvatar:SetData(self.playerInfo.Icon)
    elseif type == UIPlayerInfoItem.ModifyType.Reputation then
      self:UpdateReputation()
    elseif type == UIPlayerInfoItem.ModifyType.Medal then
      self:UpdateMedal()
    end
  elseif type == UIPlayerInfoItem.ModifyType.Name or type == UIPlayerInfoItem.ModifyType.Sign then
    UIUtils.PopupHintMessage(60049)
  end
end
