require("UI.UIBasePanel")
require("UI.UIWeeklyPanel.UIWeeklyChrAvatarItem")
require("UI.UIWeeklyPanel.UIWeeklyFleetTeamItem")
require("UI.UIWeeklyPanel.UIWeeklyDefine")
require("UI.Common.UICommonSortItem")
UIWeeklyFleetPanel = class("UIWeeklyModeAMapPanel", UIBasePanel)
UIWeeklyFleetPanel.__index = UIWeeklyFleetPanel
UIWeeklyFleetPanel.mUITeamList = {}
function UIWeeklyFleetPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
end
function UIWeeklyFleetPanel.Close()
  UIManager.CloseUI(UIDef.UIWeeklyFleetPanel)
end
function UIWeeklyFleetPanel:OnInit(root, data)
  UIWeeklyFleetPanel.super.SetRoot(UIWeeklyFleetPanel, root)
  self.mUIRoot = root
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.mData = data
  self.mDirty = false
  self.mCurrentSelect = 1
  self.mWeekData = NetCmdSimulateBattleData:GetSimCombatWeeklyData()
  self:RegisterEvent()
  self:RegisterMessage()
  self:InitSort()
  self:UpdatePanel()
end
function UIWeeklyFleetPanel:RegisterEvent()
  function self.ui.mVirtualist.itemProvider()
    return self:ItemProvider()
  end
  function self.ui.mVirtualist.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Clear.gameObject).onClick = function()
    self:Clear()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    self.Close()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Start.gameObject).onClick = function()
    self:StartWeekly()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_EnemyInfo.gameObject).onClick = function()
    local enemyArr = string.split(self.mWeekData.degreeData.b_boss_id, ":")
    local enemyId = tonumber(enemyArr[1])
    local enemyLevel = tonumber(enemyArr[2])
    UIUnitInfoPanel.Open(UIUnitInfoPanel.ShowType.Enemy, enemyId, enemyLevel)
  end
end
function UIWeeklyFleetPanel:RegisterMessage()
  function self.NotOpenTipCheck()
    UIWeeklyDefine.NotOpenTipCheck(self.NotOpenTipCheck)
  end
  MessageSys:AddListener(UIEvent.UserTapScreen, self.NotOpenTipCheck)
end
function UIWeeklyFleetPanel:RemoveAllMessage()
  MessageSys:RemoveListener(UIEvent.UserTapScreen, self.NotOpenTipCheck)
end
function UIWeeklyFleetPanel:InitSort()
  if self.comScreenItem then
    return
  end
  local gunCmdDataList = NetCmdTeamData.GunList
  self.comScreenItem = ComScreenItemHelper:InitGun(self.ui.mScrollListChild_ScreenList.gameObject, gunCmdDataList, function()
    self:UpdateAllGun()
    self.ui.mScrollFade_Team:PlayFade()
  end, nil, true)
  self.comScreenItem:SetOnShowMultiListFilterCallback(function()
  end)
  self.comScreenItem:SetOnCloseMultiListFilterCallback(function()
  end)
end
function UIWeeklyFleetPanel:OnRecover()
  self:UpdatePanel()
end
function UIWeeklyFleetPanel:OnSave()
  self:OnRelease()
end
function UIWeeklyFleetPanel:OnRelease()
  if self.comScreenItem then
    self.comScreenItem:OnRelease()
    self.comScreenItem = nil
  end
  UIWeeklyFleetPanel.mUITeamList = {}
end
function UIWeeklyFleetPanel:OnClose()
  self:RemoveAllMessage()
  if self.comScreenItem then
    self.comScreenItem:OnCloseFilterBtnClick()
  end
  self:ReleaseCtrlTable(self.mUITeamList, true)
end
function UIWeeklyFleetPanel:UpdatePanel()
  self:InitData()
  self.comScreenItem:SetList(NetCmdTeamData.GunList)
  setactive(self.ui.mBtn_EnemyInfo.transform, true)
  self:UpdateAllGun()
  self:UpdateTeam()
end
function UIWeeklyFleetPanel:InitData()
  self.mTeamData = {}
  self.mEquipGunDic = {}
  self.mMaxTeamCount = self.mWeekData.degreeData.b_id.Length
  local teamIds = self.mWeekData.BTeamIds
  local maxTeamNum = self.mMaxTeamCount - 1
  local serverTeamCount = teamIds and teamIds.Count or 0
  for i = 0, maxTeamNum do
    local teamList = {}
    if i < serverTeamCount then
      local ids = teamIds[i]
      if ids then
        for j = 0, ids.Count - 1 do
          local gunId = ids[j].Id
          self.mEquipGunDic[gunId] = true
          table.insert(teamList, gunId)
        end
      end
    end
    table.insert(self.mTeamData, teamList)
  end
end
function UIWeeklyFleetPanel:EquipGun(gunId, toTeamIndex, notRefreshUI)
  if toTeamIndex == nil then
    return
  end
  local teamList = self.mTeamData[toTeamIndex]
  if #teamList >= UIWeeklyDefine.TeamMaxGunCount then
    CS.PopupMessageManager.PopupString(UIUtils.StringFormatWithHintId(108149, toTeamIndex))
    return
  end
  self.mDirty = true
  table.insert(teamList, gunId)
  self.mEquipGunDic[gunId] = true
  if not notRefreshUI then
    self:UpdateAllGun()
    self:UpdateTeamByIndex(toTeamIndex)
  end
end
function UIWeeklyFleetPanel:UnEquipGun(gunId, srcTeamIndex, notRefreshUI)
  if srcTeamIndex == nil then
    return
  end
  local teamList = self.mTeamData[srcTeamIndex]
  for i = 1, #teamList do
    if teamList[i] == gunId then
      table.remove(teamList, i)
      break
    end
  end
  self.mDirty = true
  self.mEquipGunDic[gunId] = false
  if not notRefreshUI then
    self:UpdateAllGun()
    self:UpdateTeamByIndex(srcTeamIndex)
  end
end
function UIWeeklyFleetPanel:MoveEquipGun(gunId, srcTeamIndex, toTeamIndex)
  self:UnEquipGun(gunId, srcTeamIndex, true)
  self:EquipGun(gunId, toTeamIndex, true)
  self:UpdateAllGun()
  self:UpdateTeamByIndex(srcTeamIndex)
  self:UpdateTeamByIndex(toTeamIndex)
end
function UIWeeklyFleetPanel:UpdateAllGun()
  local tmpResultList = self.comScreenItem:GetResultList()
  self.gunItemList = {}
  self.gunList = {}
  for i = 0, tmpResultList.Count - 1 do
    table.insert(self.gunList, tmpResultList[i])
  end
  local gunCount = #self.gunList
  self.ui.mVirtualist.numItems = gunCount
  self.ui.mVirtualist:Refresh()
  setactive(self.ui.mVirtualist.transform, 0 < gunCount)
  setactive(self.ui.mTrans_None, gunCount == 0)
end
function UIWeeklyFleetPanel:ItemProvider()
  local itemView = UIWeeklyChrAvatarItem.New()
  itemView:InitCtrl(self.ui.mTrans_GunContent.transform, function(gunData)
    self:OnAvatarClickToEquip(gunData)
  end)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIWeeklyFleetPanel:ItemRenderer(index, renderData)
  local data = self.gunList[index + 1]
  local item = renderData.data
  local gunID = data.id
  item:SetData(data)
  local isEquip = self.mEquipGunDic[gunID] == true
  item:EnableSelect(isEquip)
  item:EnableChoose(false)
  local teamList = self.mTeamData[self.mCurrentSelect]
  for i = 1, #teamList do
    if teamList[i] == gunID then
      item:EnableChoose(true)
      return
    end
  end
end
function UIWeeklyFleetPanel:UpdateTeam()
  local teamCount = self.mMaxTeamCount
  local teamListRoot = self.ui.mTrans_TeamList.transform
  local teamItemTemplate = self.ui.mTrans_TeamList.childItem
  for i = 1, teamCount do
    local item
    if self.mUITeamList[i] then
      item = self.mUITeamList[i]
    else
      item = UIWeeklyFleetTeamItem.New()
      item:InitCtrl(teamListRoot, teamItemTemplate, function(clickIndex)
        self:OnClickTeamItem(clickIndex)
      end, self)
      table.insert(self.mUITeamList, item)
    end
    local ids = self.mTeamData[i]
    if item then
      item.mUIRoot:SetAsLastSibling()
      item:SetData(self.mWeekData, i, ids, i == self.mCurrentSelect)
    end
  end
end
function UIWeeklyFleetPanel:UpdateAllTeam()
  for i = 1, #self.mUITeamList do
    self:UpdateTeamByIndex(i)
  end
end
function UIWeeklyFleetPanel:UpdateTeamByIndex(index)
  local item = self.mUITeamList[index]
  if item == nil then
    return
  end
  item:SetData(self.mWeekData, index, self.mTeamData[index], index == self.mCurrentSelect)
end
function UIWeeklyFleetPanel:OnClickTeamItem(clickIndex)
  local preSelectIndex = self.mCurrentSelect
  self.mCurrentSelect = clickIndex
  local preItem = self.mUITeamList[preSelectIndex]
  local currentItem = self.mUITeamList[self.mCurrentSelect]
  if preItem then
    preItem:EnableSelect(false)
  end
  if currentItem then
    currentItem:EnableSelect(true)
  end
  self:UpdateAllGun()
end
function UIWeeklyFleetPanel:OnBackFrom()
  self:UpdatePanel()
end
function UIWeeklyFleetPanel:OnAvatarClickToEquip(gunData)
  if not self.mEquipGunDic[gunData.id] then
    self:EquipGun(gunData.id, self.mCurrentSelect)
    return
  end
  self:EquipToCurrentSelectTeam(gunData.id)
end
function UIWeeklyFleetPanel:EquipToCurrentSelectTeam(gunId)
  local teamIndex = self:FindGunTeamIndex(gunId)
  if teamIndex and teamIndex == self.mCurrentSelect then
    self:UnEquipGun(gunId, self.mCurrentSelect)
    return
  end
  local toTeamList = self.mTeamData[self.mCurrentSelect]
  if #toTeamList >= UIWeeklyDefine.TeamMaxGunCount then
    return
  end
  local content = string_format(TableData.GetHintById(108117), teamIndex, self.mCurrentSelect)
  MessageBox.Show(TableData.GetHintById(64), content, nil, function()
    self:MoveEquipGun(gunId, teamIndex, self.mCurrentSelect)
  end, function()
  end)
end
function UIWeeklyFleetPanel:FindGunTeamIndex(gunId)
  for i = 1, #self.mTeamData do
    local teamList = self.mTeamData[i]
    for j = 1, #teamList do
      local id = teamList[j]
      if id == gunId then
        return i
      end
    end
  end
  return nil
end
function UIWeeklyFleetPanel:Clear()
  self.mEquipGunDic = {}
  for i = 1, #self.mTeamData do
    self.mTeamData[i] = {}
  end
  self:UpdateAllGun()
  self:UpdateAllTeam()
end
function UIWeeklyFleetPanel:OnCheckNeedSaveUIStack()
  return false
end
function UIWeeklyFleetPanel:StartWeekly()
  local isAllEmpty = true
  for i = 1, #self.mTeamData do
    if #self.mTeamData[i] > 0 then
      isAllEmpty = false
    end
  end
  if isAllEmpty then
    CS.PopupMessageManager.PopupString(TableData.GetHintById(108106))
    return
  end
  local totalUseCount = 0
  local notFullTeams = {}
  for i = 1, #self.mTeamData do
    local teamUseCount = #self.mTeamData[i]
    if teamUseCount == 0 then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(108107))
      return
    end
    totalUseCount = totalUseCount + teamUseCount
    if teamUseCount < UIWeeklyDefine.TeamMaxGunCount then
      table.insert(notFullTeams, string_format(TableData.GetHintById(108108), i))
    end
  end
  if #notFullTeams == 0 or totalUseCount >= NetCmdTeamData.GunList.Count then
    self:EnterBattle()
    return
  end
  local content = string_format(TableData.GetHintById(108109), table.concat(notFullTeams, TableData.GetHintById(108110)))
  MessageBox.Show(TableData.GetHintById(64), content, nil, function()
    self:EnterBattle()
  end, function()
  end)
end
function UIWeeklyFleetPanel:EnterBattle()
  local content = UIUtils.StringFormatWithHintId(180174, self.mData.costNum, UIUtils.GetItemName(self.mData.costId))
  MessageBox.Show(TableData.GetHintById(64), content, nil, function()
    local teamGunList = self:GetReqTeamData()
    self.mWeekData:SaveGameBLocalGunData(teamGunList[1], teamGunList[2], teamGunList[3])
    if self.mData.startBattle then
      self.mData.startBattle()
    end
  end, function()
  end)
end
function UIWeeklyFleetPanel:GetReqTeamData()
  local teamGunList = {}
  for i = 1, #self.mTeamData do
    local teamList = self.mTeamData[i]
    local gunList = {}
    for j = 1, #teamList do
      local gunId = teamList[j]
      local cmdData = NetCmdTeamData:GetGunByID(gunId)
      table.insert(gunList, cmdData)
    end
    table.insert(teamGunList, gunList)
  end
  return teamGunList
end
