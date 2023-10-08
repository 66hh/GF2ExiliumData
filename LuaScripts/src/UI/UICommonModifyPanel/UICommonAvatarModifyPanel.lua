require("UI.UIBasePanel")
require("UI.QuestPanel.UICommonTab")
require("UI.CommanderInfoPanel.Item.UIPlayerInfoItem")
UICommonAvatarModifyPanel = class("UICommonAvatarModifyPanel", UIBasePanel)
UICommonAvatarModifyPanel.__index = UICommonAvatarModifyPanel
UICommonAvatarModifyPanel.avatarDataList = {}
UICommonAvatarModifyPanel.avatarList = {}
UICommonAvatarModifyPanel.avatarFrameList = {}
UICommonAvatarModifyPanel.displayAvatar = nil
UICommonAvatarModifyPanel.curAvatar = nil
UICommonAvatarModifyPanel.curAvatarFrame = nil
UICommonAvatarModifyPanel.equipAvatar = nil
UICommonAvatarModifyPanel.equipAvatarFrame = nil
UICommonAvatarModifyPanel.avatarType = {head = 1, headFrame = 2}
function UICommonAvatarModifyPanel:ctor(csPanel)
  UICommonAvatarModifyPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UICommonAvatarModifyPanel:Close()
  UIManager.CloseUI(UIDef.UICommonAvatarModifyPanel)
end
function UICommonAvatarModifyPanel:OnInit(root, data)
  self.confirmCallback = data[1]
  self.defaultStr = tonumber(data[2])
  self.defaultStrFrame = tonumber(data[3])
  if self.defaultStrFrame == 0 then
    self.defaultStrFrame = TableData.GlobalSystemData.PlayerAvatarFrameDefault
  end
  self.super.SetRoot(self, root)
  self.ui = {}
  self.tabTable = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:InitDisplayAvatar()
  self.avatarDataList = self:InitAvatarList(UICommonAvatarModifyPanel.avatarType.head)
  self.avatarDataFrameList = self:InitAvatarList(UICommonAvatarModifyPanel.avatarType.headFrame)
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    self:OnReplaceAvatar()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:Close()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_CloseBg.gameObject).onClick = function()
    self:Close()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Goto.gameObject).onClick = function()
    self:Goto()
  end
  self:InitBase()
  self:UpdateAvatarList()
  function self.refreshInfoFunc()
    self:RefreshInfo()
  end
  MessageSys:AddListener(CS.GF2.Message.CampaignEvent.ResInfoUpdate, self.refreshInfoFunc)
end
function UICommonAvatarModifyPanel:InitBase()
  self.curTabIndex = UICommonAvatarModifyPanel.avatarType.head
  self.SendAvatarType = UIPlayerInfoItem.ModifyType.Avatar
  for i = 1, 2 do
    local type = GlobalConfig.ItemType.PlayerAvatar
    if i == 1 then
      type = GlobalConfig.ItemType.PlayerAvatar
    else
      type = GlobalConfig.ItemType.PlayerAvatarFrame
    end
    if not self.tabTable[i] then
      self.tabTable[i] = UICommonTab.New(instantiate(self.ui.mScrollChild_Tab.childItem, self.ui.mScrollChild_Tab.transform))
    end
    self.tabTable[i]:Init(i, function()
      self:onClickTab(i)
      local redPointVisible = NetCmdIllustrationData:CheckItemTypeShowRedPoint(type) > 0
      self.tabTable[i]:SetRedPointVisible(redPointVisible)
    end)
    self.tabTable[i].ui.mText_Name.text = TableData.GetHintById(104061 + i)
    local redPointVisible = NetCmdIllustrationData:CheckItemTypeShowRedPoint(type) > 0
    self.tabTable[i]:SetRedPointVisible(redPointVisible)
  end
  self:onClickTab(self.curTabIndex)
end
function UICommonAvatarModifyPanel:onClickTab(index)
  if index <= 0 or index > #self.tabTable then
    return
  end
  if self.tabTable[self.curTabIndex] then
    self.tabTable[self.curTabIndex]:Deselect()
  end
  if self.tabTable[index] then
    self.tabTable[index]:Select()
  end
  self:onTabChanged(self.curTabIndex, index)
  self.curTabIndex = index
end
function UICommonAvatarModifyPanel:onTabChanged(preTabIndex, curTabIndex)
  if curTabIndex == UICommonAvatarModifyPanel.avatarType.head then
    self.SendAvatarType = UIPlayerInfoItem.ModifyType.Avatar
    self:UpdateAvatarList()
  elseif curTabIndex == UICommonAvatarModifyPanel.avatarType.headFrame then
    self.SendAvatarType = UIPlayerInfoItem.ModifyType.AvatarFrame
    self:UpdateAvatarFrameList()
  end
  setactive(self.ui.mTrans_GrpAvatarList, curTabIndex == UICommonAvatarModifyPanel.avatarType.head)
  setactive(self.ui.mTrans_GrpAvatarFrameList, curTabIndex == UICommonAvatarModifyPanel.avatarType.headFrame)
end
function UICommonAvatarModifyPanel:OnClose()
  for i = 1, #self.tabTable do
    if self.tabTable[i] then
      gfdestroy(self.tabTable[i]:GetRoot())
    end
  end
  for i = 1, #self.avatarList do
    if self.avatarList[i] then
      self.avatarList[i]:OnRelease()
    end
  end
  for i = 1, #self.avatarFrameList do
    if self.avatarFrameList[i] then
      self.avatarFrameList[i]:OnRelease()
    end
  end
  self.avatarDataList = {}
  self.avatarList = {}
  self.avatarDataFrameList = {}
  self.avatarFrameList = {}
  gfdestroy(self.displayAvatar:GetRoot())
  self.displayAvatar = nil
  self.curAvatar = nil
  self.curAvatarFrame = nil
  self.equipAvatar = nil
  self.equipAvatarFrame = nil
  MessageSys:RemoveListener(CS.GF2.Message.CampaignEvent.ResInfoUpdate, self.refreshInfoFunc)
end
function UICommonAvatarModifyPanel:InitDisplayAvatar()
  if self.displayAvatar == nil then
    self.displayAvatar = UICommonPlayerAvatarItem.New()
    self.displayAvatar:InitCtrlByScrollChild(self.ui.mScrollChild_DisplayAvatar.childItem, self.ui.mTrans_DisplayAvatar)
    self.displayAvatar.ui.mBtn_Avatar.interactable = false
    setactive(self.displayAvatar.ui.mTrans_Sel, false)
  end
end
function UICommonAvatarModifyPanel:UpdateAvatarList()
  for i, data in ipairs(self.avatarDataList) do
    local item = self.avatarList[i]
    if item == nil then
      item = UICommonPlayerAvatarItem.New()
      item:InitCtrl(self.ui.mTrans_AvatarList)
      table.insert(self.avatarList, item)
    end
    item.data = self.avatarDataList[i]
    if self.avatarDataList[i].id ~= 0 then
      if AccountNetCmdHandler.Gender == 0 then
        item:SetData(self.avatarDataList[i].Icon)
      else
        item:SetData(self.avatarDataList[i].IconFemale)
      end
    end
    item:SetLockState(self.avatarDataList[i].isLock)
    item:SetRedPoint(NetCmdIllustrationData:CheckItemShowRedPoint(GlobalConfig.ItemType.PlayerAvatar, item.data.itemData.id))
    item:SetEquipState(self.avatarDataList[i].id == self.defaultStr)
    if self.avatarDataList[i].id == self.defaultStr then
      self.equipAvatar = item
    end
    UIUtils.GetButtonListener(item.ui.mBtn_Avatar.gameObject).onClick = function()
      self:OnClickAvatar(item)
    end
  end
  self:OnClickAvatar(self.equipAvatar)
end
function UICommonAvatarModifyPanel:UpdateAvatarFrameList()
  for i, data in ipairs(self.avatarDataFrameList) do
    local item = self.avatarFrameList[i]
    if item == nil then
      item = UICommonPlayerAvatarItem.New()
      item:InitCtrlByScrollChild(self.ui.mScrollChild_FrameList.childItem, self.ui.mTrans_AvatarFrameList)
      table.insert(self.avatarFrameList, item)
    end
    item.data = self.avatarDataFrameList[i]
    if self.avatarDataFrameList[i].id ~= TableData.GlobalSystemData.PlayerAvatarFrameDefault then
      item:SetFrameData(self.avatarDataFrameList[i].icon)
      setactive(item.ui.mImage_Avatar, true)
      setactive(item.ui.mTrans_No, false)
    else
      setactive(item.ui.mImage_Avatar, false)
      setactive(item.ui.mTrans_No, true)
    end
    item:SetLockState(self.avatarDataFrameList[i].isLock)
    item:SetRedPoint(NetCmdIllustrationData:CheckItemShowRedPoint(GlobalConfig.ItemType.PlayerAvatarFrame, item.data.itemData.id))
    item:SetEquipState(self.avatarDataFrameList[i].id == self.defaultStrFrame)
    if self.avatarDataFrameList[i].id == self.defaultStrFrame then
      self.equipAvatarFrame = item
    end
    UIUtils.GetButtonListener(item.ui.mBtn_Avatar.gameObject).onClick = function()
      self:OnClickAvatarFrame(item)
    end
  end
  self:OnClickAvatarFrame(self.equipAvatarFrame)
end
function UICommonAvatarModifyPanel:UpdateAvatarInfo()
  if self.curAvatar then
    if self.curAvatar.data.isLock then
      self.ui.mText_AvatarDesc.text = self.curAvatar.data.unlockDes
    else
      self.ui.mText_AvatarDesc.text = self.curAvatar.data.itemData.introduction.str
    end
    if AccountNetCmdHandler.Gender == 0 then
      self.displayAvatar:SetData(self.curAvatar.data.icon)
    else
      self.displayAvatar:SetData(self.curAvatar.data.IconFemale)
    end
    self.ui.mText_AvatarName.text = self.curAvatar.data.itemData.name.str
  else
    gferror("头像为空了")
  end
  setactive(self.ui.mTrans_Equipped.gameObject, self.curAvatar.data.id == self.equipAvatar.data.id)
  setactive(self.ui.mTrans_Lock.gameObject, self.curAvatar.data.id ~= self.equipAvatar.data.id and self.curAvatar.data.isLock and self.curAvatar.data.link == 0)
  setactive(self.ui.mBtn_Goto.gameObject, self.curAvatar.data.id ~= self.equipAvatar.data.id and self.curAvatar.data.isLock and self.curAvatar.data.link ~= 0)
  setactive(self.ui.mTrans_Replace.gameObject, self.curAvatar.data.id ~= self.equipAvatar.data.id and not self.curAvatar.data.isLock)
end
function UICommonAvatarModifyPanel:UpdateAvatarFrameInfo()
  if self.curAvatarFrame then
    if self.curAvatarFrame.data.isLock then
      self.ui.mText_AvatarDesc.text = self.curAvatarFrame.data.unlockDes
    else
      self.ui.mText_AvatarDesc.text = self.curAvatarFrame.data.itemData.introduction.str
    end
    self.displayAvatar.ui.mImage_AvatarFrame.sprite = IconUtils.GetPlayerAvatarFrame(self.curAvatarFrame.data.icon)
    setactive(self.displayAvatar.ui.mTrans_AvatarFrame, true)
  end
  self.ui.mText_AvatarName.text = self.curAvatarFrame.data.itemData.name.str
  setactive(self.ui.mTrans_Equipped.gameObject, self.curAvatarFrame.data.id == self.equipAvatarFrame.data.id)
  setactive(self.ui.mTrans_Lock.gameObject, self.curAvatarFrame.data.id ~= self.equipAvatarFrame.data.id and self.curAvatarFrame.data.isLock and self.curAvatarFrame.data.link == 0)
  setactive(self.ui.mBtn_Goto.gameObject, self.curAvatarFrame.data.id ~= self.equipAvatarFrame.data.id and self.curAvatarFrame.data.isLock and self.curAvatarFrame.data.link ~= 0)
  setactive(self.ui.mTrans_Replace.gameObject, self.curAvatarFrame.data.id ~= self.equipAvatarFrame.data.id and not self.curAvatarFrame.data.isLock)
end
function UICommonAvatarModifyPanel:OnClickAvatar(item)
  if self.curAvatar then
    self.curAvatar.ui.mBtn_Avatar.interactable = true
  end
  self.curAvatar = item
  self.curAvatar.ui.mBtn_Avatar.interactable = false
  if NetCmdIllustrationData:CheckItemShowRedPoint(GlobalConfig.ItemType.PlayerAvatar, item.data.itemData.id) then
    NetCmdIllustrationData:SendReadRedPoint(GlobalConfig.ItemType.PlayerAvatar, item.data.itemData.id)
    item:SetRedPoint(NetCmdIllustrationData:CheckItemShowRedPoint(GlobalConfig.ItemType.PlayerAvatar, item.data.itemData.id))
  end
  local redPointVisible = NetCmdIllustrationData:CheckItemTypeShowRedPoint(GlobalConfig.ItemType.PlayerAvatar) > 0
  self.tabTable[1]:SetRedPointVisible(redPointVisible)
  self:UpdateAvatarInfo()
end
function UICommonAvatarModifyPanel:OnClickAvatarFrame(item)
  if self.curAvatarFrame then
    self.curAvatarFrame.ui.mBtn_Avatar.interactable = true
  end
  self.curAvatarFrame = item
  self.curAvatarFrame.ui.mBtn_Avatar.interactable = false
  if NetCmdIllustrationData:CheckItemShowRedPoint(GlobalConfig.ItemType.PlayerAvatarFrame, item.data.itemData.id) then
    NetCmdIllustrationData:SendReadRedPoint(GlobalConfig.ItemType.PlayerAvatarFrame, item.data.itemData.id)
    item:SetRedPoint(NetCmdIllustrationData:CheckItemShowRedPoint(GlobalConfig.ItemType.PlayerAvatarFrame, item.data.itemData.id))
  end
  local redPointVisible = NetCmdIllustrationData:CheckItemTypeShowRedPoint(GlobalConfig.ItemType.PlayerAvatarFrame) > 0
  self.tabTable[2]:SetRedPointVisible(redPointVisible)
  self:UpdateAvatarFrameInfo()
end
function UICommonAvatarModifyPanel:OnReplaceAvatar()
  if self.SendAvatarType == UIPlayerInfoItem.ModifyType.Avatar then
    if self.confirmCallback and self.curAvatar then
      self.confirmCallback(self.curAvatar.data.id, self.SendAvatarType)
    end
  elseif self.SendAvatarType == UIPlayerInfoItem.ModifyType.AvatarFrame and self.confirmCallback and self.curAvatarFrame then
    self.confirmCallback(self.curAvatarFrame.data.id, self.SendAvatarType)
  end
end
function UICommonAvatarModifyPanel:RefreshInfo()
  self.defaultStr = AccountNetCmdHandler:GetRoleInfoData().Portrait
  self.defaultStrFrame = AccountNetCmdHandler:GetRoleInfoData().PortraitFrame
  if self.defaultStrFrame == 0 then
    self.defaultStrFrame = TableData.GlobalSystemData.PlayerAvatarFrameDefault
  end
  self.equipAvatar = nil
  self.equipAvatarFrame = nil
  if self.curAvatar then
    self.curAvatar.ui.mBtn_Avatar.interactable = true
    self.curAvatar = nil
  end
  if self.curAvatarFrame then
    self.curAvatarFrame.ui.mBtn_Avatar.interactable = true
    self.curAvatarFrame = nil
  end
  if self.SendAvatarType == UIPlayerInfoItem.ModifyType.Avatar then
    self:UpdateAvatarList()
  elseif self.SendAvatarType == UIPlayerInfoItem.ModifyType.AvatarFrame then
    self:UpdateAvatarFrameList()
  end
end
function UICommonAvatarModifyPanel:Goto()
  if self.curTabIndex == UICommonAvatarModifyPanel.avatarType.head then
    SceneSwitch:SwitchByID(tonumber(self.curAvatar.data.link))
  elseif self.curTabIndex == UICommonAvatarModifyPanel.avatarType.headFrame then
    SceneSwitch:SwitchByID(tonumber(self.curAvatarFrame.data.link))
  end
end
function UICommonAvatarModifyPanel:InitAvatarList(type)
  local list = {}
  local dataList = {}
  if type == UICommonAvatarModifyPanel.avatarType.head then
    dataList = TableData.listPlayerAvatarDatas:GetList()
  elseif type == UICommonAvatarModifyPanel.avatarType.headFrame then
    dataList = TableData.listHeadFrameDatas:GetList()
  end
  local curBPId = NetCmdBattlePassData:GetCurOrRecentBpId()
  for i = 0, dataList.Count - 1 do
    local d = dataList[i]
    if 0 < d.display_config then
      local bpID
      if d.display_config == 2 then
        bpID = curBPId
      end
      if bpID == nil or bpID >= d.display_arg then
        local avatar = {}
        local itemData = TableData.listItemDatas:GetDataById(dataList[i].id)
        if itemData then
          avatar.id = dataList[i].id
          avatar.itemData = itemData
          avatar.icon = dataList[i].icon
          avatar.IconFemale = dataList[i].IconFemale
          avatar.link = dataList[i].jump
          avatar.unlockDes = dataList[i].unlock_des.str
          if type == UICommonAvatarModifyPanel.avatarType.head then
            avatar.isLock = not NetCmdIllustrationData:CheckAvatarIsUnlock(avatar.id)
            avatar.Icon = avatar.icon
            avatar.IconFemale = avatar.IconFemale
          elseif type == UICommonAvatarModifyPanel.avatarType.headFrame then
            avatar.isLock = not NetCmdIllustrationData:CheckAvatarFrameIsUnlock(avatar.id)
            if avatar.id == TableData.GlobalSystemData.PlayerAvatarFrameDefault then
              avatar.isLock = false
            end
          end
          table.insert(list, avatar)
        end
      end
    end
  end
  table.sort(list, function(a, b)
    if a.isLock == b.isLock then
      return a.itemData.id < b.itemData.id
    elseif a.isLock == false and b.isLock == true then
      return true
    else
      return false
    end
  end)
  return list
end
