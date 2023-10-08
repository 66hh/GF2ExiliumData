require("UI.UIBaseCtrl")
UIFriendListItem = class("UIFriendListItem", UIBaseCtrl)
UIFriendListItem.__index = UIFriendListItem
UIFriendListItem.cdTimer = nil
function UIFriendListItem:ctor()
  UIFriendListItem.super.ctor(self)
  self.playerInfo = nil
  self.titleObj = nil
end
function UIFriendListItem:__InitCtrl()
end
function UIFriendListItem:InitCtrl(parent, go)
  self:SetRoot(go.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.mParent = parent
  self.titleObj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComReputationTitleItem_S.prefab", self), self.ui.mTrans_Title)
  self:__InitCtrl()
end
function UIFriendListItem:OnRelease()
end
function UIFriendListItem:SetData(data, type)
  if data then
    self.playerInfo = data
    self.type = type
    self.ui.mImg_Avatar.sprite = IconUtils.GetPlayerAvatar(self.playerInfo.Icon)
    if self.playerInfo.Mark == "" or self.playerInfo.Mark == nil then
      self.ui.mText_ChrName.text = self.playerInfo.Name
      self.ui.mText_ChrName.color = Color.white
    else
      self.ui.mText_ChrName.text = self.playerInfo.Mark
      self.ui.mText_ChrName.color = ColorUtils.BlueColor4
    end
    setactive(self.ui.mImg_MonthCard, self.playerInfo:IsMonCard())
    setactive(self.ui.mTrans_Title, self.playerInfo.ReputationTitle ~= nil and self.playerInfo.ReputationTitle ~= 0 and self.playerInfo.ReputationTitle ~= TableData.GlobalSystemData.PlayerTitleDefault)
    if self.playerInfo.ReputationTitle ~= nil and self.playerInfo.ReputationTitle ~= 0 and self.playerInfo.ReputationTitle ~= TableData.GlobalSystemData.PlayerTitleDefault then
      setactive(self.titleObj.transform:GetChild(0), true)
      self.titleObj.transform:GetChild(0):GetComponent(typeof(CS.UnityEngine.UI.Image)).sprite = IconUtils.GetPlayerTitlePic(TableData.listIdcardTitleDatas:GetDataById(self.playerInfo.ReputationTitle).icon .. "_S")
      self.titleObj.transform:GetChild(1):GetComponent(typeof(CS.UnityEngine.UI.Text)).text = TableData.listIdcardTitleDatas:GetDataById(self.playerInfo.ReputationTitle).title.str
    else
      setactive(self.titleObj.transform:GetChild(0), false)
      self.titleObj.transform:GetChild(1):GetComponent(typeof(CS.UnityEngine.UI.Text)).text = "没有称号"
    end
    setactive(self.ui.mTrans_GrpState.gameObject, self.type == UIFriendGlobal.ListTab.FriendList)
    setactive(self.ui.mBtn_More.gameObject, self.type == UIFriendGlobal.ListTab.FriendList)
    setactive(self.ui.mTrans_Apply.gameObject, self.type == UIFriendGlobal.ListTab.ApplyList)
    setactive(self.ui.mBtn_Add.gameObject, self.type == UIFriendGlobal.ListTab.AddList)
    setactive(self.ui.mBtn_Recover.gameObject, self.type == UIFriendGlobal.ListTab.BlackList)
    setactive(self.ui.mTrans_MoreNote.gameObject, false)
    UIUtils.GetButtonListener(self.ui.mBtn_self.gameObject).onClick = nil
    if self.type == UIFriendGlobal.ListTab.FriendList then
      if self.playerInfo.IsOnline then
        setactive(self.ui.mTrans_StateText.gameObject, true)
        setactive(self.ui.mText_Time.gameObject, false)
      else
        setactive(self.ui.mTrans_StateText.gameObject, false)
        setactive(self.ui.mText_Time.gameObject, true)
        local time = self.playerInfo.GetOnlineOrOfflineTime
        if time < 3600 then
          self.ui.mText_Time.text = TableData.GetHintReplaceById(100036, tostring(time // 60))
        elseif 3600 < time and time / 3600 < 24 then
          self.ui.mText_Time.text = TableData.GetHintReplaceById(100035, tostring(time // 3600))
        elseif 86400 <= time and time / 86400 < 30 then
          self.ui.mText_Time.text = TableData.GetHintReplaceById(100034, tostring(time // 86400))
        else
          self.ui.mText_Time.text = TableData.GetHintById(100119)
        end
      end
      UIUtils.GetButtonListener(self.ui.mBtn_self.gameObject).onClick = function()
        self.mParent:HideAllNote()
        self.mParent.mParent.mChatContentSubPanel:InitCtrl(self.mParent.mParent.ui.mTrans_ChatContent, self.mParent, self.playerInfo, UICommunicationGlobal.ChatType.Friend)
        self.mParent.mParent:EnterSubPanel(self.mParent.mParent.SUB_PANEL_ID.CHAT_CONTENT)
      end
      UIUtils.GetButtonListener(self.ui.mBtn_Avatar.gameObject).onClick = function()
        self:OnClickPlayerInfo()
      end
      UIUtils.GetButtonListener(self.ui.mBtn_More.gameObject).onClick = function()
        if self.mParent.selectItem ~= nil then
          self.mParent.selectItem:CloseNote()
        end
        self.mParent.selectItem = self
        setactive(self.ui.mTrans_MoreNote.gameObject, true)
      end
      UIUtils.GetButtonListener(self.ui.mBtn_CloseNote.gameObject).onClick = function()
        self:CloseNote()
      end
      UIUtils.GetButtonListener(self.ui.mBtn_Bg.gameObject).onClick = function()
        self:CloseNote()
      end
      UIUtils.GetButtonListener(self.ui.mBtn_Delete.gameObject).onClick = function()
        self:DeleteFriend()
      end
      UIUtils.GetButtonListener(self.ui.mBtn_Block.gameObject).onClick = function()
        self:AddBlackList()
      end
      UIUtils.GetButtonListener(self.ui.mBtn_Edit.gameObject).onClick = function()
        self:OnClickRemark()
      end
    elseif self.type == UIFriendGlobal.ListTab.ApplyList then
      UIUtils.GetButtonListener(self.ui.mBtn_self.gameObject).onClick = function()
        self:OnClickPlayerInfo()
      end
      UIUtils.GetButtonListener(self.ui.mBtn_Agree.gameObject).onClick = function()
        self:ApplyFriend(true)
      end
      UIUtils.GetButtonListener(self.ui.mBtn_Refuse.gameObject).onClick = function()
        self:ApplyFriend(false)
      end
      UIUtils.GetButtonListener(self.ui.mBtn_Avatar.gameObject).onClick = function()
        self:OnClickPlayerInfo()
      end
    elseif self.type == UIFriendGlobal.ListTab.AddList then
      UIUtils.GetButtonListener(self.ui.mBtn_self.gameObject).onClick = function()
        self:OnClickPlayerInfo()
      end
      UIUtils.GetButtonListener(self.ui.mBtn_Add.gameObject).onClick = function()
        self:AddFriend()
      end
      UIUtils.GetButtonListener(self.ui.mBtn_Avatar.gameObject).onClick = function()
        self:OnClickPlayerInfo()
      end
    elseif self.type == UIFriendGlobal.ListTab.BlackList then
      UIUtils.GetButtonListener(self.ui.mBtn_self.gameObject).onClick = function()
        self:OnClickPlayerInfo()
      end
      UIUtils.GetButtonListener(self.ui.mBtn_Recover.gameObject).onClick = function()
        self:RemoveBlackList()
      end
    end
  else
    setactive(self.mUIRoot, false)
  end
end
function UIFriendListItem:CloseNote()
  self.mParent.selectItem = nil
  setactive(self.ui.mTrans_MoreNote.gameObject, false)
end
function UIFriendListItem:AddFriend()
  if UIFriendListItem.cdTimer then
    return
  end
  UIFriendListItem.cdTimer = TimerSys:DelayCall(1, function()
    UIFriendListItem.cdTimer:Stop()
    UIFriendListItem.cdTimer = nil
  end)
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
function UIFriendListItem:DeleteFriend()
  if self.playerInfo then
    MessageBox.Show(TableData.GetHintById(64), TableData.GetHintById(100028), nil, function()
      NetCmdFriendData:SendSocialDeleteFriend(self.playerInfo.UID)
    end, nil)
  end
end
function UIFriendListItem:ApplyFriend(isPass)
  if self.playerInfo then
    NetCmdFriendData:SendFriendApproveApplication(self.playerInfo.UID, isPass)
  end
end
function UIFriendListItem:AddBlackList()
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
function UIFriendListItem:RemoveBlackList()
  if self.playerInfo.IsBlack then
    NetCmdFriendData:SendUnsetBlackList(self.playerInfo.UID, function()
      UIUtils.PopupPositiveHintMessage(100047)
    end)
  end
end
function UIFriendListItem:OnClickRemark()
  local defaultStr = ""
  if self.playerInfo.Mark ~= nil and self.playerInfo.Mark ~= "" then
    defaultStr = self.playerInfo.Mark
  end
  UIManager.OpenUIByParam(UIDef.UICommonModifyPanel, {
    function(strName)
      self:OnClickConfirm(strName)
    end,
    defaultStr
  })
end
function UIFriendListItem:OnClickConfirm(strName)
  NetCmdFriendData:SendSetFriendMark(self.playerInfo.UID, strName, function(ret)
  end)
end
function UIFriendListItem:OnChangeNoteCallback(ret)
  if ret == ErrorCodeSuc then
    gfdebug("修改成功")
  else
    gfdebug("修改失败")
  end
  self:UpdatePlayerName()
end
function UIFriendListItem:UpdatePlayerName()
  self.ui.mText_ChrName.text = self.playerInfo.Name
end
function UIFriendListItem:UpdateRedPoint()
end
function UIFriendListItem:OnClickPlayerInfo()
  if self.playerInfo then
    if self.playerInfo.IsFriend then
      NetCmdFriendData:SendSocialFriendSearch(tostring(self.playerInfo.UID), function()
        self.playerInfo = NetCmdFriendData:GetFriendDataById(self.playerInfo.UID)
        self:SetData(self.playerInfo, self.type)
        UIManager.OpenUIByParam(UIDef.UIPlayerInfoDialog, {
          self.playerInfo
        })
      end)
    else
      UIManager.OpenUIByParam(UIDef.UIPlayerInfoDialog, {
        self.playerInfo
      })
    end
  end
end
