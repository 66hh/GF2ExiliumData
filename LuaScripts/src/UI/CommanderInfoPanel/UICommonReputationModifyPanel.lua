require("UI.UIBasePanel")
require("UI.CommanderInfoPanel.Item.UICommanderReputationItem")
UICommonReputationModifyPanel = class("UICommonReputationModifyPanel", UIBasePanel)
UICommonReputationModifyPanel.__index = UICommonReputationModifyPanel
UICommonReputationModifyPanel.reputationDataList = {}
UICommonReputationModifyPanel.reputationList = {}
UICommonReputationModifyPanel.displayReputation = nil
UICommonReputationModifyPanel.curReputation = nil
UICommonReputationModifyPanel.equipReputation = nil
function UICommonReputationModifyPanel:ctor(csPanel)
  UICommonReputationModifyPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UICommonReputationModifyPanel:Close()
  UIManager.CloseUI(UIDef.UICommonReputationModifyPanel)
end
function UICommonReputationModifyPanel:OnInit(root, data)
  self.confirmCallback = data[1]
  self.defaultStr = tonumber(data[2])
  self.super.SetRoot(self, root)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  setactive(self.ui.mTrans_Action, true)
  self.ui.mTrans_ReputationList.anchoredPosition = vector2zero
  self.reputationDataList = self:InitReputationList()
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    self:OnReplaceReputation()
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
  self:UpdateReputationList()
  function self.refreshInfoFunc()
    self:RefreshInfo()
  end
  MessageSys:AddListener(CS.GF2.Message.CampaignEvent.ResInfoUpdate, self.refreshInfoFunc)
end
function UICommonReputationModifyPanel:OnClose()
  for i = 1, #self.reputationList do
    if self.reputationList[i] then
      self.reputationList[i]:OnRelease()
    end
  end
  self.reputationDataList = {}
  self.reputationList = {}
  self.displayReputation = nil
  self.curReputation = nil
  self.equipReputation = nil
  MessageSys:RemoveListener(CS.GF2.Message.CampaignEvent.ResInfoUpdate, self.refreshInfoFunc)
end
function UICommonReputationModifyPanel:InitDisplayReputation()
  if self.displayReputation == nil then
    self.displayReputation = UICommonReputationItem.New()
    self.displayReputation:InitCtrl(self.ui.mTrans_DisplayReputation)
  end
end
function UICommonReputationModifyPanel:UpdateReputationList()
  for i, data in ipairs(self.reputationDataList) do
    local item = self.reputationList[i]
    if item == nil then
      item = UICommanderReputationItem.New()
      item:InitCtrl(self.ui.mTrans_ReputationList)
      table.insert(self.reputationList, item)
    end
    item.data = self.reputationDataList[i]
    item:SetData(self.reputationDataList[i])
    item:SetLockState(self.reputationDataList[i].isLock)
    item:SetEquipState(self.reputationDataList[i].id == self.defaultStr)
    item:SetRedPoint(NetCmdIllustrationData:CheckItemShowRedPoint(GlobalConfig.ItemType.Title, item.data.itemData.id))
    item:SetEquipState(self.reputationDataList[i].id == self.defaultStr)
    if self.reputationDataList[i].id == self.defaultStr then
      self.equipReputation = item
    end
    if self.reputationDataList[i].id == TableData.GlobalSystemData.PlayerTitleDefault then
      setactive(item.ui.mTrans_No, true)
      setactive(item.reputationItem.ui.mImg_Bg, false)
      setactive(item.reputationItem.ui.mText_Name, false)
      self:ClearRedPoint(item)
    else
      setactive(item.ui.mTrans_No, false)
      setactive(item.reputationItem.ui.mImg_Bg, true)
      setactive(item.reputationItem.ui.mText_Name, true)
    end
    UIUtils.GetButtonListener(item.ui.mBtn_Reputation.gameObject).onClick = function()
      self:OnClickReputation(item)
    end
  end
  self:OnClickReputation(self.equipReputation)
end
function UICommonReputationModifyPanel:UpdateReputationInfo()
  if self.curReputation then
    self.ui.mText_ReputationName.text = self.curReputation.data.name
    self.ui.mText_Name.text = self.curReputation.data.name
    if not self.curReputation.data.isLock then
      self.ui.mText_Time.text = TableData.GetHintById(82003) .. "\n" .. self.curReputation.data.time
      self.ui.mText_ReputationDesc.text = self.curReputation.data.itemData.introduction.str
    else
      self.ui.mText_ReputationDesc.text = self.curReputation.data.process
    end
    self.ui.mImg_Bg.sprite = IconUtils.GetPlayerTitlePic(self.curReputation.data.icon)
    if self.curReputation.data.id == TableData.GlobalSystemData.PlayerTitleDefault then
      self.ui.mText_ReputationName.text = self.curReputation.data.qualify
      self.ui.mText_ReputationDesc.text = self.curReputation.data.itemData.introduction.str
      setactive(self.ui.mTrans_Reputation, false)
      setactive(self.ui.mTrans_No, true)
    else
      setactive(self.ui.mTrans_Reputation, true)
      setactive(self.ui.mTrans_No, false)
    end
    setactive(self.ui.mText_Time, not self.curReputation.data.isLock and self.curReputation.data.id ~= 0 and self.curReputation.data.id ~= TableData.GlobalSystemData.PlayerTitleDefault)
    setactive(self.ui.mTrans_Equipped.gameObject, self.curReputation.data.id == self.equipReputation.data.id)
    setactive(self.ui.mTrans_Lock.gameObject, self.curReputation.data.id ~= self.equipReputation.data.id and self.curReputation.data.isLock and self.curReputation.data.link == 0)
    setactive(self.ui.mBtn_Goto, self.curReputation.data.id ~= self.equipReputation.data.id and self.curReputation.data.isLock and self.curReputation.data.link ~= 0)
    setactive(self.ui.mTrans_Replace.gameObject, self.curReputation.data.id ~= self.equipReputation.data.id and not self.curReputation.data.isLock)
  end
end
function UICommonReputationModifyPanel:OnClickReputation(item)
  if self.curReputation ~= nil then
    self.curReputation.ui.mBtn_Reputation.interactable = true
  end
  self.curReputation = item
  self.curReputation.ui.mBtn_Reputation.interactable = false
  if NetCmdIllustrationData:CheckItemShowRedPoint(GlobalConfig.ItemType.Title, item.data.itemData.id) then
    NetCmdIllustrationData:SendReadRedPoint(GlobalConfig.ItemType.Title, item.data.itemData.id)
    item:SetRedPoint(NetCmdIllustrationData:CheckItemShowRedPoint(GlobalConfig.ItemType.Title, item.data.itemData.id))
  end
  self:UpdateReputationInfo()
end
function UICommonReputationModifyPanel:ClearRedPoint(item)
  if NetCmdIllustrationData:CheckItemShowRedPoint(GlobalConfig.ItemType.Title, item.data.itemData.id) then
    NetCmdIllustrationData:SendReadRedPoint(GlobalConfig.ItemType.Title, item.data.itemData.id)
    item:SetRedPoint(NetCmdIllustrationData:CheckItemShowRedPoint(GlobalConfig.ItemType.Title, item.data.itemData.id))
  end
end
function UICommonReputationModifyPanel:OnReplaceReputation()
  if self.confirmCallback and self.curReputation then
    self.confirmCallback(self.curReputation.data.id)
  end
end
function UICommonReputationModifyPanel:Goto()
  SceneSwitch:SwitchByID(tonumber(self.curReputation.data.link))
end
function UICommonReputationModifyPanel:RefreshInfo()
  self.defaultStr = AccountNetCmdHandler:GetRoleInfoData().ReputationTitle
  self.equipReputation = nil
  if self.curReputation then
    self.curReputation.ui.mBtn_Reputation.interactable = true
    self.curReputation = nil
  end
  self:UpdateReputationList()
end
function UICommonReputationModifyPanel:InitReputationList()
  local list = {}
  local dataList = TableData.listIdcardTitleDatas:GetList()
  for i = 0, dataList.Count - 1 do
    local reputation = {}
    local itemData = TableData.listItemDatas:GetDataById(dataList[i].id)
    if itemData then
      reputation.id = dataList[i].id
      reputation.name = dataList[i].name.str
      reputation.qualify = dataList[i].qualify.str
      reputation.title = dataList[i].title.str
      reputation.itemData = itemData
      reputation.isLock = not NetCmdIllustrationData:CheckReputationIsUnlock(reputation.id)
      reputation.link = dataList[i].jump
      reputation.icon = dataList[i].icon
      if reputation.isLock then
        local achievement = TableData.listAchievementDetailDatas:GetDataById(dataList[i].achievement)
        if string.find(dataList[i].qualify.str, "{0}") then
          reputation.process = string_format(dataList[i].qualify.str, NetCmdAchieveData:GetProgressStr(achievement.id))
        else
          reputation.process = dataList[i].qualify.str
        end
      else
        reputation.time = NetCmdIllustrationData:GetDetailTime(GlobalConfig.ItemType.Title, reputation.id)
      end
      table.insert(list, reputation)
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
