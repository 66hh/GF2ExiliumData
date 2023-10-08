require("UI.CommanderInfoPanel.Item.UICommonReputationItem")
require("UI.Common.UICommonPlayerAvatarItem")
require("UI.CommanderInfoPanel.Content.UISettingSubPanel")
require("UI.CommanderInfoPanel.Item.UIPlayerInfoItem")
require("UI.UICommonModifyPanel.UICommanderInfoAchievementItem")
require("UI.UICommonModifyPanel.CommanderInfoGlobal")
UICommanderInfoCardItemV2 = class("UICommanderInfoCardItemV2", UIBaseCtrl)
UICommanderInfoCardItemV2.__index = UICommanderInfoCardItemV2
UICommanderInfoCardItemV2.IconStr = "Icon_Character_"
UICommanderInfoCardItemV2.ModifyType = {
  Name = 1,
  Avatar = 2,
  BirthDay = 3,
  Sign = 4,
  AssistGun = 5,
  Reputation = 6,
  Medal = 7,
  AvatarFrame = 8
}
UICommanderInfoCardItemV2.BtnType = {
  Self = 1,
  Friend = 2,
  Stranger = 3,
  Black = 4,
  Robot = 5
}
UICommanderInfoCardItemV2.SignColor = Color(ColorUtils.GrayColor2.r, ColorUtils.GrayColor2.g, ColorUtils.GrayColor2.b, 0.423)
function UICommanderInfoCardItemV2:ctor(parentPanel)
  self.playerInfo = nil
  self.playerAvatar = nil
  self.mReputationTitle = nil
  self.supportList = nil
  self.parentPanel = parentPanel
  self.robotInfo = nil
end
function UICommanderInfoCardItemV2:InitCtrlNew(obj, parent, isSelf)
  if parent then
    self.mParent = parent
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
  end
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(obj.transform, self.ui)
  self:ComCtrl()
  self.AchieveList = {}
end
function UICommanderInfoCardItemV2:ComCtrl()
  function self.clickMedalRedPoint(msg)
    if self.playerInfo.Medal ~= 0 then
      setactive(self.ui.mTrans_MedalRedPoint.gameObject, 0 < NetCmdIllustrationData:CheckItemTypeShowRedPoint(GlobalConfig.ItemType.Medal))
    else
      setactive(self.ui.mTrans_MedalRedPoint.gameObject, false)
    end
  end
  MessageSys:AddListener(CS.GF2.Message.UIEvent.ClickMedalRedPoint, self.clickMedalRedPoint)
end
function UICommanderInfoCardItemV2:SetData(data, isSelf)
  self.playerInfo = data
  if data.PortraitFrame == 0 then
    self.playerInfo.PortraitFrame = TableData.GlobalSystemData.PlayerAvatarFrameDefault
  end
  self:UpdatePlayerInfo(isSelf)
  if self.playerInfo.Medal ~= 0 and self.playerInfo.Medal ~= nil and self.playerInfo.Medal ~= TableData.GlobalSystemData.PlayerMedalDefault then
    local medalData = TableData.listIdcardMedalDatas:GetDataById(self.playerInfo.Medal)
    self.ui.mImg_MedalIcon.sprite = IconUtils.GetIconV2("Item", medalData.icon)
    setactive(self.ui.mMedal_Icon, true)
    setactive(self.ui.mTrans_NoIcon, false)
  else
    setactive(self.ui.mMedal_Icon, false)
    setactive(self.ui.mTrans_NoIcon, true)
  end
  setactive(self.ui.mTrans_No01, true)
  setactive(self.ui.mImg_01, false)
  setactive(self.ui.mTrans_No02, true)
  setactive(self.ui.mImg_02, false)
  setactive(self.ui.mTrans_No03, true)
  setactive(self.ui.mImg_03, false)
  setactive(self.ui.mTrans_No04, true)
  setactive(self.ui.mImg_04, false)
  if 0 < self.playerInfo.NewMedal.Count then
    local index = 0
    for i = self.playerInfo.NewMedal.Count - 1, 0, -1 do
      local medalData = TableData.listIdcardMedalDatas:GetDataById(self.playerInfo.NewMedal[i])
      if index == 0 and medalData.Id ~= TableData.GlobalSystemData.PlayerMedalDefault then
        self.ui.mImg_01.sprite = IconUtils.GetIconV2("Item", medalData.Icon)
        setactive(self.ui.mTrans_No01, false)
        setactive(self.ui.mImg_01, true)
        index = index + 1
      elseif index == 1 and medalData.Id ~= TableData.GlobalSystemData.PlayerMedalDefault then
        self.ui.mImg_02.sprite = IconUtils.GetIconV2("Item", medalData.Icon)
        setactive(self.ui.mTrans_No02, false)
        setactive(self.ui.mImg_02, true)
        index = index + 1
      elseif index == 2 and medalData.Id ~= TableData.GlobalSystemData.PlayerMedalDefault then
        self.ui.mImg_03.sprite = IconUtils.GetIconV2("Item", medalData.Icon)
        setactive(self.ui.mTrans_No03, false)
        setactive(self.ui.mImg_03, true)
        index = index + 1
      elseif index == 3 and medalData.Id ~= TableData.GlobalSystemData.PlayerMedalDefault then
        self.ui.mImg_04.sprite = IconUtils.GetIconV2("Item", medalData.Icon)
        setactive(self.ui.mTrans_No04, false)
        setactive(self.ui.mImg_04, true)
        index = index + 1
      end
    end
  end
end
function UICommanderInfoCardItemV2:UpdatePlayerInfo()
  self:SetItems()
  self:UpdatePlayerContent(isSelf)
  self:UpdatePlayerMotto()
  self:UpdateAchievements()
  self:SetBtnGroup(self.BtnType.Self)
  setactive(self.ui.mTrans_GrpExp.gameObject, true)
  self.ui.mBtn_Rename.interactable = true
  self.ui.mBtn_Medal.interactable = true
  self.playerAvatar:SetData(self.playerInfo.Icon)
  self.playerAvatar:SetFrameDataOut(self.playerInfo.IconFrame)
end
function UICommanderInfoCardItemV2:SetBtnGroup(btnType)
  setactive(self.ui.mTrans_Actions.gameObject, btnType ~= UICommanderInfoCardItemV2.BtnType.Robot)
  setactive(self.ui.mBtn_CheckIn.transform.parent.gameObject, btnType == self.BtnType.Self)
end
function UICommanderInfoCardItemV2:SetItems()
  if self.playerAvatar == nil then
    self.playerAvatar = UICommonPlayerAvatarItem.New()
    self.playerAvatar:InitCtrlByScrollChild(self.ui.mScrollChild_PlayerAvatar.childItem, self.ui.mTrans_PlayerAvatar)
    self.playerAvatar:EnableBtn(false)
  end
  if self.mReputationTitle == nil and self.playerInfo.ReputationTitle ~= 0 and self.playerInfo.ReputationTitle ~= nil then
    self.mReputationTitle = UICommonReputationItem.New()
    self.mReputationTitle:InitCtrl(self.ui.mTrans_ReputationTitle)
    self.mReputationTitle:EnableBtn(false)
    self.mReputationTitle.ui.mBtn_Reputation.interactable = false
  end
  setactive(self.ui.mBtn_Medal.gameObject, self.playerInfo.Medal ~= 0)
  self.playerAvatar:EnableBtn(true)
  UIUtils.GetButtonListener(self.playerAvatar.ui.mBtn_Avatar.gameObject).onClick = function()
    self:OnCLickAvatar()
  end
  if self.mReputationTitle ~= nil then
    UIUtils.GetButtonListener(self.ui.mBtn_Add.gameObject).onClick = function()
      self:OnClickReputation()
    end
  end
  if self.playerInfo.Medal ~= 0 then
    UIUtils.GetButtonListener(self.ui.mBtn_Medal.gameObject).onClick = function()
      self:OnClickMedal()
    end
  end
  self.ui.mBtn_Signature.interactable = false
  setactive(self.ui.mImg_SIgn, false)
  UIUtils.GetButtonListener(self.ui.mBtn_Signature.gameObject).onClick = function()
    self:OnClickSignRemark()
  end
  setactive(self.ui.mBtn_Rename, false)
  UIUtils.GetButtonListener(self.ui.mBtn_Rename.gameObject).onClick = function()
    self:OnClickRemark()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Copy.gameObject).onClick = function()
    self:OnClickCopyUid()
  end
  setactive(self.ui.mBtn_Exchange.gameObject, not LuaUtils.IsIOS())
  UIUtils.GetButtonListener(self.ui.mBtn_Exchange.gameObject).onClick = function()
    self:OnClickExchange()
  end
end
function UICommanderInfoCardItemV2:UpdatePlayerContent(isSelf)
  if self.playerInfo.Mark == "" or self.playerInfo.Mark == nil then
    self.ui.mText_PlayerName.text = self.playerInfo.Name
  else
    self.ui.mText_PlayerName.text = self.playerInfo.Name .. "(#" .. self.playerInfo.Mark .. ")"
  end
  setactive(self.ui.mImg_MonthCard, self.playerInfo:IsMonCard())
  local curExp = self.playerInfo.Exp
  local maxExp = 0
  if self.playerInfo.Level < TableData.GlobalSystemData.CommanderLevel then
    local data = TableData.listPlayerLevelDatas:GetDataById(self.playerInfo.Level + 1)
    maxExp = data.exp
    self.ui.mText_PlayerExpNum.text = curExp .. "/" .. maxExp
  else
    local data = TableData.listPlayerLevelDatas:GetDataById(TableData.GlobalSystemData.CommanderLevel)
    maxExp = data.exp
    curExp = data.exp
    self.ui.mText_PlayerExpNum.text = TableData.GetHintById(111045)
  end
  setactive(self.ui.mTrans_GrpUID.gameObject, true)
  if isSelf then
    self.ui.mText_UID.text = AccountNetCmdHandler:GetUID()
  else
    self.ui.mText_UID.text = self.playerInfo.UID
  end
  self.ui.mText_PlayerLvNum.text = GlobalConfig.SetLvText(self.playerInfo.Level)
  if self.playerInfo.ReputationTitle ~= 0 and self.playerInfo.ReputationTitle ~= TableData.GlobalSystemData.PlayerTitleDefault then
    setactive(self.ui.mTrans_ReputationNo, false)
    setactive(self.mReputationTitle:GetRoot(), true)
  else
    setactive(self.ui.mTrans_ReputationNo, true)
    setactive(self.mReputationTitle:GetRoot(), false)
  end
  setactive(self.ui.mTransReputaNoRedPoint, 0 < NetCmdIllustrationData:CheckItemTypeShowRedPoint(GlobalConfig.ItemType.Title))
  if self.playerAvatar then
    self.playerAvatar:SetRedPoint(0 < NetCmdIllustrationData:CheckItemTypeShowRedPoint(GlobalConfig.ItemType.PlayerAvatar) or 0 < NetCmdIllustrationData:CheckItemTypeShowRedPoint(GlobalConfig.ItemType.PlayerAvatarFrame))
  end
  if self.mReputationTitle ~= nil then
    local titleData = TableData.listIdcardTitleDatas:GetDataById(self.playerInfo.ReputationTitle)
    self.mReputationTitle:SetData(titleData.title.str, titleData.icon)
  end
  if self.playerInfo.Medal ~= 0 then
    setactive(self.ui.mTrans_MedalRedPoint.gameObject, 0 < NetCmdIllustrationData:CheckItemTypeShowRedPoint(GlobalConfig.ItemType.Medal))
  else
    setactive(self.ui.mTrans_MedalRedPoint.gameObject, false)
  end
end
function UICommanderInfoCardItemV2:UpdatePlayerMotto()
  if self.playerInfo.PlayerMotto == nil or self.playerInfo.PlayerMotto == "" then
    self.ui.mText_Signature.text = CS.LuaUIUtils.Unescape(TableData.GetHintById(100013))
    self.ui.mText_Signature.color = self.SignColor
  else
    self.ui.mText_Signature.text = self.playerInfo.PlayerMotto
    self.ui.mText_Signature.color = ColorUtils.GrayColor3
  end
end
function UICommanderInfoCardItemV2:UpdateReputation()
  local titleData = TableData.listIdcardTitleDatas:GetDataById(self.playerInfo.ReputationTitle)
  self.mReputationTitle:SetData(titleData.title.str)
end
function UICommanderInfoCardItemV2:UpdateMedal()
  local medalData = TableData.listIdcardMedalDatas:GetDataById(self.playerInfo.Medal)
  self.ui.mImg_MedalIcon.sprite = IconUtils.GetIconV2("Item", medalData.icon)
  setactive(self.ui.mMedal_Icon, self.playerInfo.Medal ~= 0 and self.playerInfo.Medal ~= TableData.GlobalSystemData.PlayerMedalDefault)
  setactive(self.ui.mTrans_NoIcon, self.playerInfo.Medal == 0 or self.playerInfo.Medal == TableData.GlobalSystemData.PlayerMedalDefault)
end
function UICommanderInfoCardItemV2:UpdateAchievements()
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
    local icon = TableData.listAchievementTagDatas:GetDataById(i + 1).icon
    num = NetCmdAchieveData:AchievementRankNumByType(i)
    item:SetData(num, icon)
  end
  self.ui.mText_GetOrder.text = TableData.GetHintById(104067)
  self.ui.mText_Attachment.text = TableData.GetHintById(104066)
end
function UICommanderInfoCardItemV2:OnClickRemark()
  if self.playerInfo.UID == AccountNetCmdHandler:GetUID() then
    local defaultStr = ""
    if self.playerInfo.Name ~= nil and self.playerInfo.Name ~= "" then
      defaultStr = self.playerInfo.Name
    end
    UIManager.OpenUIByParam(UIDef.UICommonSelfModifyPanel, {
      function(strName)
        self:OnClickConfirm(strName, UICommanderInfoCardItemV2.ModifyType.Name)
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
function UICommanderInfoCardItemV2:OnCLickAvatar()
  local defaultStr = self.playerInfo.Portrait
  local defaultStrFrame = self.playerInfo.PortraitFrame
  if defaultStrFrame == 0 or defaultStrFrame == "" then
    defaultStrFrame = TableData.GlobalSystemData.PlayerAvatarFrameDefault
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
function UICommanderInfoCardItemV2:OnClickReputation()
  local defaultStr = self.playerInfo.ReputationTitle
  if self.playerInfo.ReputationTitle == 0 then
    defaultStr = TableData.GlobalSystemData.PlayerTitleDefault
  end
  UIManager.OpenUIByParam(UIDef.UICommonReputationModifyPanel, {
    function(strName)
      self:OnClickConfirm(strName, UICommanderInfoCardItemV2.ModifyType.Reputation)
      UIUtils.PopupPositiveHintMessage(180014)
    end,
    defaultStr
  })
end
function UICommanderInfoCardItemV2:OnClickMedal()
  local defaultStr = self.playerInfo.Medal
  if self.playerInfo.Medal == 0 then
    defaultStr = TableData.GlobalSystemData.PlayerMedalDefault
  end
  UIManager.OpenUIByParam(UIDef.UICommonMedalModifyPanel, {
    function(strName)
      self:OnClickConfirm(strName, UICommanderInfoCardItemV2.ModifyType.Medal)
      UIUtils.PopupPositiveHintMessage(180014)
    end,
    defaultStr
  })
end
function UICommanderInfoCardItemV2:OnClickSignRemark()
  local defaultStr = ""
  if self.playerInfo.PlayerMotto ~= nil and self.playerInfo.PlayerMotto ~= "" then
    defaultStr = self.playerInfo.PlayerMotto
  end
  UIManager.OpenUIByParam(UIDef.UICommonSignModifyPanel, {
    function(strName)
      self:OnClickConfirm(strName, UICommanderInfoCardItemV2.ModifyType.Sign)
    end,
    defaultStr
  })
end
function UICommanderInfoCardItemV2:OnClickConfirm(strName, type)
  if type == UICommanderInfoCardItemV2.ModifyType.Name then
    AccountNetCmdHandler:SendModNameReq(strName, function(ret)
      self:OnChangeNoteCallback(ret, type)
    end)
  elseif type == UICommanderInfoCardItemV2.ModifyType.Sign then
    AccountNetCmdHandler:SendReqModPlayerMotto(strName, function(ret)
      self:OnChangeNoteCallback(ret, type)
    end)
  elseif type == UICommanderInfoCardItemV2.ModifyType.Avatar then
    AccountNetCmdHandler:SendReqModPlayerPortrait(tonumber(strName), function(ret)
      self:OnChangeNoteCallback(ret, type)
    end)
  elseif type == UICommanderInfoCardItemV2.ModifyType.AvatarFrame then
    AccountNetCmdHandler:SendReqModPlayerPortraitFrame(tonumber(strName), function(ret)
      self:OnChangeNoteCallback(ret, type)
    end)
  elseif type == UICommanderInfoCardItemV2.ModifyType.Reputation then
    AccountNetCmdHandler:SendReqModPlayerReputation(tonumber(strName), function(ret)
      self:OnChangeNoteCallback(ret, type)
    end)
  elseif type == UICommanderInfoCardItemV2.ModifyType.Medal then
    AccountNetCmdHandler:SendReqModPlayerMedal(tonumber(strName), function(ret)
      self:OnChangeNoteCallback(ret, type)
    end)
  end
end
function UICommanderInfoCardItemV2:OnClickConfirmRemark(strName)
  NetCmdFriendData:SendSetFriendMark(self.playerInfo.UID, strName, function(ret)
    if ret == ErrorCodeSuc then
      self.ui.mText_PlayerName.text = self.playerInfo.Name .. "(#" .. strName .. ")"
    else
      UIUtils.PopupHintMessage(60049)
    end
  end)
end
function UICommanderInfoCardItemV2:OnClickExchange()
  UIManager.OpenUIByParam(UIDef.UICommanderExchangeDialog, self.playerInfo)
end
function UICommanderInfoCardItemV2:OnClickCopyUid()
  CS.UnityEngine.GUIUtility.systemCopyBuffer = self.playerInfo.UID
  UIUtils.PopupPositiveHintMessage(7002)
end
function UICommanderInfoCardItemV2:OnRelease()
  if self.mReputationTitle then
    self.mReputationTitle:OnRelease()
    self.mReputationTitle = nil
  end
  if self.playerAvatar then
    gfdestroy(self.playerAvatar:GetRoot())
  end
  if self.AchieveList then
    for i = 1, #self.AchieveList do
      gfdestroy(self.AchieveList[i]:GetRoot())
    end
  end
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.ClickMedalRedPoint, self.clickMedalRedPoint)
end
function UICommanderInfoCardItemV2:OnChangeNoteCallback(ret, type)
  if ret == ErrorCodeSuc then
    if type == UICommanderInfoCardItemV2.ModifyType.Name then
      UIUtils.PopupPositiveHintMessage(7001)
      self:UpdatePlayerContent()
      UIManager.CloseUI(UIDef.UICommonSelfModifyPanel)
    elseif type == UICommanderInfoCardItemV2.ModifyType.Sign then
      UIUtils.PopupPositiveHintMessage(7001)
      self:UpdatePlayerMotto()
      UIManager.CloseUI(UIDef.UICommonSignModifyPanel)
    elseif type == UICommanderInfoCardItemV2.ModifyType.Avatar then
      self.playerAvatar:SetData(self.playerInfo.Icon)
    elseif type == UIPlayerInfoItem.ModifyType.AvatarFrame then
      self.playerAvatar:SetFrameDataOut(self.playerInfo.IconFrame)
    elseif type == UICommanderInfoCardItemV2.ModifyType.Reputation then
      self:UpdateReputation()
    elseif type == UICommanderInfoCardItemV2.ModifyType.Medal then
      self:UpdateMedal()
    end
  elseif type == UICommanderInfoCardItemV2.ModifyType.Name or type == UICommanderInfoCardItemV2.ModifyType.Sign then
  end
end
