require("UI.UIBasePanel")
require("UI.Common.UICommonMedalItem")
UICommonMedalModifyPanel = class("UICommonMedalModifyPanel", UIBasePanel)
UICommonMedalModifyPanel.__index = UICommonMedalModifyPanel
UICommonMedalModifyPanel.medalDataList = {}
UICommonMedalModifyPanel.medalList = {}
UICommonMedalModifyPanel.curMedal = nil
UICommonMedalModifyPanel.equipMedal = nil
function UICommonMedalModifyPanel:ctor(csPanel)
  UICommonMedalModifyPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UICommonMedalModifyPanel:Close()
  UIManager.CloseUI(UIDef.UICommonMedalModifyPanel)
end
function UICommonMedalModifyPanel:OnInit(root, data)
  self.confirmCallback = data[1]
  self.defaultStr = tonumber(data[2])
  self.super.SetRoot(self, root)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.medalDataList = self:InitMedalList()
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    self:OnReplaceMedal()
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
  self:UpdateMedalList()
  self:InitDisplayMedal()
  function self.refreshInfoFunc()
    self:RefreshInfo()
  end
  MessageSys:AddListener(CS.GF2.Message.CampaignEvent.ResInfoUpdate, self.refreshInfoFunc)
  self.ui.mTrans_Content.anchoredPosition = CS.UnityEngine.Vector2(self.ui.mTrans_Content.anchoredPosition.x, 0)
end
function UICommonMedalModifyPanel:OnClose()
  for i = 1, #self.medalDataList do
    if self.medalList[i] then
      gfdestroy(self.medalList[i]:GetRoot())
    end
  end
  self.medalDataList = {}
  self.medalList = {}
  self.curMedal = nil
  self.equipMedal = nil
  MessageSys:RemoveListener(CS.GF2.Message.CampaignEvent.ResInfoUpdate, self.refreshInfoFunc)
end
function UICommonMedalModifyPanel:InitDisplayMedal()
end
function UICommonMedalModifyPanel:UpdateMedalList()
  for i, data in ipairs(self.medalDataList) do
    local item = self.medalList[i]
    if item == nil then
      item = UICommonMedalItem.New()
      item:InitCtrl(self.ui.mScrollList_Badge.childItem, self.ui.mTrans_MedalList)
      table.insert(self.medalList, item)
    end
    item.data = self.medalDataList[i]
    item:SetData(self.medalDataList[i].icon)
    item:SetLockState(self.medalDataList[i].isLock)
    item:SetRedPoint(NetCmdIllustrationData:CheckItemShowRedPoint(GlobalConfig.ItemType.Medal, item.data.itemData.id))
    item:SetEquipState(self.medalDataList[i].id == self.defaultStr)
    if self.medalDataList[i].id == self.defaultStr then
      self.equipMedal = item
    end
    if self.medalDataList[i].id == TableData.GlobalSystemData.PlayerMedalDefault then
      setactive(item.ui.mTrans_No, true)
      setactive(item.ui.mTrans_Badge, false)
    else
      setactive(item.ui.mTrans_No, false)
      setactive(item.ui.mTrans_Badge, true)
      item.ui.mText_Name.text = self.medalDataList[i].itemData.name.str
      if self.medalDataList[i].isLock then
        if self.medalDataList[i].qualifySimplify ~= "" and self.medalDataList[i].qualifySimplify ~= nil then
          setactive(item.ui.mText_Content, true)
          item.ui.mText_Content.text = self.medalDataList[i].qualifySimplify
        else
          setactive(item.ui.mText_Content, false)
        end
      else
        setactive(item.ui.mText_Content, false)
      end
    end
    UIUtils.GetButtonListener(item.ui.mBtn_Medal.gameObject).onClick = function()
      self:OnClickMedal(item)
    end
  end
  self:OnClickMedal(self.equipMedal)
end
function UICommonMedalModifyPanel:UpdateMedalInfo()
  if self.curMedal then
    self.ui.mText_MedalName.text = self.curMedal.data.name.str
    if self.curMedal.data.isLock then
      self.ui.mText_Process.text = self.curMedal.data.process
    else
      self.ui.mText_Time.text = TableData.GetHintById(82003) .. "\n" .. self.curMedal.data.time
      self.ui.mText_Process.text = self.curMedal.data.itemData.introduction.str
    end
    if self.curMedal.data.id == TableData.GlobalSystemData.PlayerMedalDefault then
      self.ui.mText_MedalName.text = self.curMedal.data.qualify.str
      setactive(self.ui.mText_Time, false)
      setactive(self.ui.mText_MedalName, true)
      setactive(self.ui.mText_Process, false)
      setactive(self.ui.mTrans_BadgeIcon, false)
      setactive(self.ui.mTrans_No, true)
    else
      self.ui.mImg_DisplayMedal.sprite = IconUtils.GetIconV2("Item", self.curMedal.data.icon)
      setactive(self.ui.mText_Time, not self.curMedal.data.isLock)
      setactive(self.ui.mText_MedalName, true)
      setactive(self.ui.mText_Process, true)
      setactive(self.ui.mTrans_BadgeIcon, true)
      setactive(self.ui.mTrans_No, false)
    end
    setactive(self.ui.mTrans_Equipped.gameObject, self.curMedal.data.id == self.equipMedal.data.id)
    setactive(self.ui.mTrans_Lock.gameObject, self.curMedal.data.id ~= self.equipMedal.data.id and self.curMedal.data.isLock and self.curMedal.data.link == 0)
    setactive(self.ui.mBtn_Goto.gameObject, self.curMedal.data.id ~= self.equipMedal.data.id and self.curMedal.data.isLock and self.curMedal.data.link ~= 0)
    setactive(self.ui.mTrans_Replace.gameObject, self.curMedal.data.id ~= self.equipMedal.data.id and not self.curMedal.data.isLock)
  end
end
function UICommonMedalModifyPanel:OnClickMedal(item)
  if self.curMedal then
    self.curMedal.ui.mBtn_Medal.interactable = true
  end
  self.curMedal = item
  self.curMedal.ui.mBtn_Medal.interactable = false
  if NetCmdIllustrationData:CheckItemShowRedPoint(GlobalConfig.ItemType.Medal, item.data.itemData.id) then
    NetCmdIllustrationData:SendReadRedPoint(GlobalConfig.ItemType.Medal, item.data.itemData.id)
    item:SetRedPoint(NetCmdIllustrationData:CheckItemShowRedPoint(GlobalConfig.ItemType.Medal, item.data.itemData.id))
    MessageSys:SendMessage(UIEvent.ClickMedalRedPoint, nil)
  end
  self:UpdateMedalInfo()
end
function UICommonMedalModifyPanel:OnReplaceMedal()
  if self.confirmCallback and self.curMedal then
    self.confirmCallback(self.curMedal.data.id)
  end
end
function UICommonMedalModifyPanel:RefreshInfo()
  self.defaultStr = AccountNetCmdHandler:GetRoleInfoData().Medal
  self.equipMedal = nil
  if self.curMedal then
    self.curMedal.ui.mBtn_Medal.interactable = true
    self.curMedal = nil
  end
  self:UpdateMedalList()
end
function UICommonMedalModifyPanel:Goto()
  SceneSwitch:SwitchByID(tonumber(self.curMedal.data.link))
end
function UICommonMedalModifyPanel:InitMedalList()
  local list = {}
  local dataList = TableData.listIdcardMedalDatas:GetList()
  for i = 0, dataList.Count - 1 do
    local medal = {}
    local itemData = TableData.listItemDatas:GetDataById(dataList[i].id)
    if itemData then
      medal.id = dataList[i].id
      medal.name = dataList[i].name
      medal.qualify = dataList[i].qualify
      medal.icon = dataList[i].icon
      medal.itemData = itemData
      medal.isLock = not NetCmdIllustrationData:CheckMedalIsUnlock(medal.id)
      medal.link = dataList[i].jump
      medal.qualifySimplify = dataList[i].qualify_simplify.str
      if medal.isLock then
        local achievement = TableData.listAchievementDetailDatas:GetDataById(dataList[i].achievement)
        if string.find(dataList[i].qualify.str, "{0}") then
          medal.process = string_format(dataList[i].qualify.str, NetCmdAchieveData:GetProgressStr(achievement.id))
        else
          medal.process = dataList[i].qualify.str
        end
      else
        medal.time = NetCmdIllustrationData:GetDetailTime(GlobalConfig.ItemType.Medal, medal.id)
      end
      table.insert(list, medal)
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
