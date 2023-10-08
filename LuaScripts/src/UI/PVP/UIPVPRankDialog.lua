require("UI.PVP.Item.UIPVPRankItem")
require("UI.PVP.Item.UIPVPRankGunAvatarItem")
require("UI.Common.UICommonPlayerAvatarItem")
require("UI.PVP.Item.UIPVPRankDialogTabItem")
require("UI.PVP.Item.UIPVPRankDialogDropDownItem")
UIPVPRankDialog = class("UIPVPRankDialog", UIBasePanel)
local self = UIPVPRankDialog
function UIPVPRankDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIPVPRankDialog:OnInit(root)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.leftTabList = {}
  self.curleftTabItem = nil
  self.selfAvatarTable = {}
  self.pvpRankItemViewTable = {}
  self.planItemList = {}
  self.flagCnt = 0
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIPVPRankDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Reward.gameObject).onClick = function()
    self:OnClickRewardBtn()
  end
  self.ui.mVirtualListEx_GrpList.itemProvider = self.ItemProvider
  self.ui.mVirtualListEx_GrpList.itemRenderer = self.ItemRenderer
  self.ui.mText_Name.text = TableData.GetHintById(130004)
  setactive(self.ui.mObj_RedPoint.parent.gameObject, true)
  setactive(self.ui.mBtn_Reward.gameObject, false)
  local weeklyCyclePlan = NetCmdSimulateBattleData:GetPlanByType(CS.GF2.Data.PlanType.PlanFunctionPvpMonthCycle)
  if weeklyCyclePlan == nil then
    self.curPlanId = 0
  else
    self.curPlanId = weeklyCyclePlan.Id
  end
  local planList = NetCmdSimulateBattleData:GetPlansByType(CS.GF2.Data.PlanType.PlanFunctionPvpMonthCycle)
  self.planList = planList
  if planList == nil then
    self.prevPlanId = 0
  else
    self.curSeasonCyclePlan = NetCmdSimulateBattleData:GetPlanByType(CS.GF2.Data.PlanType.PlanFunctionPvpMonthCycle)
    local lastSeasonCyclePlan
    for i = 0, planList.Count - 1 do
      if planList[i].CloseTime < self.curSeasonCyclePlan.CloseTime then
        if not lastSeasonCyclePlan then
          lastSeasonCyclePlan = planList[i]
        elseif lastSeasonCyclePlan.CloseTime < planList[i].CloseTime then
          lastSeasonCyclePlan = planList[i]
        end
      end
    end
    if lastSeasonCyclePlan == nil then
      self.prevPlanId = 0
    else
      self.prevPlanId = lastSeasonCyclePlan.Id
    end
  end
  local index = 1
  self:InitLeftTab()
  for i = 0, planList.Count - 1 do
    NetCmdSimulateBattleData:ReqSimCombatWeeklyAllRankInfo(function(ret)
      NetCmdSimulateBattleData:ReqSimCombatWeeklyMyRankInfo(function(ret)
        index = index + 1
        local preMyRankData = self:GetMyWeeklyRankDataList(planList[i].Id)
        if preMyRankData then
          NetCmdSimulateBattleData:ReqSimCombatWeeklyRankDetailInfo(preMyRankData)
        end
        index = index + 1
        local curRankDataList = self:GetAllWeeklyRankDataList(planList[i].Id)
        local curRankListCallback = function(ret)
          self:ChangeTab2Next(self.leftTabList[1])
        end
        if curRankDataList and curRankDataList.Count > 0 then
          for i = 0, curRankDataList.Count - 1 do
            if i == curRankDataList.Count - 1 then
              NetCmdSimulateBattleData:ReqSimCombatWeeklyRankDetailInfo(curRankDataList[i], curRankListCallback)
            else
              NetCmdSimulateBattleData:ReqSimCombatWeeklyRankDetailInfo(curRankDataList[i])
            end
          end
        else
          self:ChangeTab2Next(self.leftTabList[1])
        end
      end, planList[i].Id)
    end, planList[i].Id)
  end
  local seasonPlan = NetCmdSimulateBattleData:GetPlanByType(CS.GF2.Data.PlanType.PlanFunctionPvpMonthCycle)
  if seasonPlan == nil then
    return
  end
  self.seasonCloseTime = seasonPlan.CloseTime
  if seasonPlan.CloseTime <= CGameTime:GetTimestamp() then
    setactive(self.ui.mText_Time, false)
  else
    self:SeasonCountdown()
    setactive(self.ui.mText_Time, true)
  end
  setactive(self.ui.mTrans_GrpPlayerSelf, false)
end
function UIPVPRankDialog:OnShowStart()
  self:Refresh()
end
function UIPVPRankDialog:OnClose()
  self:ReleaseCtrlTable(self.leftTabList)
  self:ReleaseCtrlTable(self.selfAvatarTable)
  self:ReleaseCtrlTable(self.pvpRankItemViewTable)
  self:ReleaseCtrlTable(self.planItemList)
  if self.closeTimer ~= nil then
    self.closeTimer:Stop()
    self.closeTimer = nil
  end
  gfdestroy(self.dropDown)
  self.leftTabList = nil
  self.selfAvatarTable = nil
  self.pvpRankItemViewTable = nil
  self.curleftTabItem = nil
  self.rankItemDataTable = nil
  self.planList = nil
  self.playerAvatarItem:OnRelease()
  self.playerAvatarItem = nil
  self.curPlanId = 0
  self.prevPlanId = 0
  self.seasonCloseTime = 0
  self.ui.mVirtualListEx_GrpList.itemProvider = nil
  self.ui.mVirtualListEx_GrpList.itemRenderer = nil
  self.ui = nil
end
function UIPVPRankDialog:InitLeftTab()
  for i = 1, 2 do
    do
      local leftTabItem = UIPVPRankDialogTabItem.New()
      table.insert(self.leftTabList, leftTabItem)
      local leftTabItemData = {index = i}
      leftTabItem:InitCtrl(self.ui.mTrans_Content1, leftTabItemData)
      leftTabItem:OnHandleClick(function()
        self:ChangeTab2Next(leftTabItem)
      end)
    end
  end
  self.dropDown = instantiate(self.ui.mScrollChild_Screen.childItem, self.ui.mScrollChild_Screen.transform)
  self:LuaUIBindTable(self.dropDown, self.ui)
  setactive(self.ui.mBtn_Screen, false)
  setactive(self.ui.mBtn_TypeScreen, false)
  setactive(self.ui.mScrollChildList_Screen, false)
  self.BlockHelper = UIUtils.GetUIBlockHelper(self.ui.mTrans_Self, self.ui.mBlockHelper_Screen.transform, function()
    setactive(self.ui.mBlockHelper_Screen, false)
  end)
  UIUtils.GetButtonListener(self.ui.mBtn_Dropdown.gameObject).onClick = function()
    for i = 1, #self.planItemList do
      if self.prevPlanId == self.planItemList[i].mData.Id then
        self.planItemList[i]:OnHandleClick()
      else
        setactive(self.planItemList[i].ui.mTrans_GrpSel, false)
      end
    end
    setactive(self.ui.mScrollChildList_Screen, true)
    ComScreenItemHelper:RefreshFilterTransPos(self.ui.mTrans_ScreenItemV2.gameObject, self.ui.mScrollChildList_Screen.gameObject)
  end
  self.flagCnt = 0
  for i = 0, self.planList.Count - 1 do
    if self.planList[i].CloseTime < self.curSeasonCyclePlan.CloseTime then
      local NRTPVP_seasonData = TableData.listNrtpvpSeasonDatas:GetDataById(self.planList[i].Id)
      if NRTPVP_seasonData.season_id ~= 1 then
        self.flagCnt = self.flagCnt + 1
      end
      local item = UIPVPRankDialogDropDownItem.New()
      item:InitCtrl(self.ui.mScrollChildList_Screen.childItem, self.ui.mScrollChildList_Screen.transform, self)
      item:SetData(self.planList[i], function(selectId)
        self.prevPlanId = selectId
        self:OnSelectDropDown()
      end)
      table.insert(self.planItemList, item)
    end
  end
  if 1 < self.flagCnt then
    setactive(self.ui.mBtn_Dropdown, true)
    self.ui.mText_SuitName.text = TableData.listNrtpvpSeasonDatas:GetDataById(self.prevPlanId).Name.str
  else
    setactive(self.ui.mBtn_Dropdown, false)
    setactive(self.leftTabList[2]:GetRoot(), false)
  end
end
function UIPVPRankDialog:InitSelfRankItem(planId)
  setactive(self.ui.mText_Ranking, false)
  setactive(self.ui.mText_NoRanking, false)
  local data = self:GetMyWeeklyRankDataList(planId)
  local levelDataRow
  if not data then
    levelDataRow = UIPVPGlobal.GetCurSeasonLevelDataRow(0, 0)
    if not levelDataRow then
      return
    end
    self.ui.mText_Rank.text = levelDataRow.Name.str
    self.ui.mText_PlayerName.text = AccountNetCmdHandler:GetName()
    self.ui.mText_Num.text = "0"
    self.ui.mText_Level.text = TableData.GetHintReplaceById(80057, AccountNetCmdHandler:GetLevel())
    setactive(self.ui.mText_NoRanking, true)
  else
    levelDataRow = UIPVPGlobal.GetCurSeasonLevelDataRow(data.Points, data.Rank)
    if not levelDataRow then
      return
    end
    self.ui.mText_Rank.text = levelDataRow.Name.str
    self.ui.mText_PlayerName.text = data.User.Name
    self.ui.mText_Num.text = data.Points
    self.ui.mText_Level.text = TableData.GetHintReplaceById(80057, data.User.Level)
    if data.Rank == 0 then
      setactive(self.ui.mText_NoRanking, true)
    else
      self.ui.mText_Ranking.text = data.Rank
      setactive(self.ui.mText_Ranking, true)
    end
  end
  if not self.playerAvatarItem then
    self.playerAvatarItem = UICommonPlayerAvatarItem.New()
    self.playerAvatarItem:InitCtrlByScrollChild(self.ui.mScrollChild_Self.childItem, self.ui.mTrans_GrpPlayerAvatar)
    self.playerAvatarItem:AddBtnListener(function()
      self:OnClickUserAvatar()
    end)
    self.playerAvatarItem:EnableBtn(false)
  end
  self.playerAvatarItem:SetData(AccountNetCmdHandler:GetAvatar())
  if levelDataRow then
    self.ui.mImg_RankBg.sprite = IconUtils.GetAtlasSprite("PVPPic/Img_PVPRank_Chess_" .. levelDataRow.Section .. "_Bg")
    self.ui.mImg_RankIcon.sprite = IconUtils.GetAtlasSprite("PVPPic/Img_PVPRank_Chess_" .. levelDataRow.Section)
    self.ui.mImg_RankNum.sprite = IconUtils.GetAtlasSprite("PVPPic/Img_PVPRank_Num_" .. levelDataRow.Icon)
  end
  self:InitSelfRankAvatarList(data)
end
function UIPVPRankDialog:InitSelfRankAvatarList(weeklyRankData)
  if not self.selfAvatarTable or #self.selfAvatarTable == 0 then
    local gunLimit = 4
    for i = 0, gunLimit - 1 do
      local rankAvatarItem = UIPVPRankGunAvatarItem.New()
      rankAvatarItem:InitCtrl(self.ui.mGrp_ChrList)
      table.insert(self.selfAvatarTable, rankAvatarItem)
    end
  end
  local gunCmdDataTable = {
    nil,
    nil,
    nil,
    nil
  }
  if weeklyRankData and weeklyRankData.GunDetails then
    local gunAvatarList = weeklyRankData.GunDetails[0]
    for i = 0, gunAvatarList.Count - 1 do
      if gunAvatarList[i].Id ~= 0 then
        table.insert(gunCmdDataTable, gunAvatarList[i])
      end
    end
  end
  for i = 1, #self.selfAvatarTable do
    self.selfAvatarTable[i]:SetData(gunCmdDataTable[i])
  end
end
function UIPVPRankDialog:Refresh()
end
function UIPVPRankDialog:ChangeTab2Next(leftTabItem)
  if self.curleftTabItem ~= nil then
    self.curleftTabItem.ui.mBtn_PVPRankDateItem.interactable = true
  end
  self.curleftTabItem = leftTabItem
  self.curleftTabItem.ui.mBtn_PVPRankDateItem.interactable = false
  if leftTabItem.index == 1 then
    setactive(self.ui.mScrollChild_Screen, false)
    self.rankItemDataTable = self:GetSeasonRankDataTable(self.curPlanId)
    self:InitSelfRankItem(self.curPlanId)
  elseif leftTabItem.index == 2 then
    if 1 < self.flagCnt then
      setactive(self.ui.mScrollChild_Screen, true)
    else
      setactive(self.ui.mScrollChild_Screen, false)
    end
    self.rankItemDataTable = self:GetSeasonRankDataTable(self.prevPlanId)
    self:InitSelfRankItem(self.prevPlanId)
  end
  setactive(self.ui.mTrans_Empty, #self.rankItemDataTable == 0)
  setactive(self.ui.mTrans_GrpPlayerSelf, #self.rankItemDataTable ~= 0)
  self.ui.mVirtualListEx_GrpList.numItems = #self.rankItemDataTable
  self.ui.mVirtualListEx_GrpList:Refresh()
  self.ui.mTrans_Content.transform:GetComponent(typeof(CS.MonoScrollerFadeManager)).enabled = false
  self.ui.mTrans_Content.transform:GetComponent(typeof(CS.MonoScrollerFadeManager)).enabled = true
end
function UIPVPRankDialog:OnSelectDropDown()
  self.rankItemDataTable = self:GetSeasonRankDataTable(self.prevPlanId)
  self:InitSelfRankItem(self.prevPlanId)
  setactive(self.ui.mTrans_Empty, #self.rankItemDataTable == 0)
  setactive(self.ui.mTrans_GrpPlayerSelf, #self.rankItemDataTable ~= 0)
  self.ui.mVirtualListEx_GrpList.numItems = #self.rankItemDataTable
  self.ui.mVirtualListEx_GrpList:Refresh()
  self.ui.mTrans_Content.transform:GetComponent(typeof(CS.MonoScrollerFadeManager)).enabled = false
  self.ui.mTrans_Content.transform:GetComponent(typeof(CS.MonoScrollerFadeManager)).enabled = true
end
function UIPVPRankDialog:GetSeasonRankDataTable(planId)
  local temp = {}
  local rankDataList = self:GetAllWeeklyRankDataList(planId)
  if rankDataList == nil then
    return temp
  end
  for i = 0, rankDataList.Count - 1 do
    table.insert(temp, rankDataList[i])
  end
  return temp
end
function UIPVPRankDialog:GetAllWeeklyRankDataList(planId)
  local weeklyData = NetCmdSimulateBattleData:GetSimCombatWeeklyData()
  return weeklyData:GetRankByPlanId(planId)
end
function UIPVPRankDialog:GetMyWeeklyRankDataList(planId)
  local weeklyData = NetCmdSimulateBattleData:GetSimCombatWeeklyData()
  return weeklyData:GetMyRankByPlanId(planId)
end
function UIPVPRankDialog.ItemProvider()
  local itemView = UIPVPRankItem.New()
  itemView:InitCtrl(self.ui.mTrans_Content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  table.insert(self.pvpRankItemViewTable, itemView)
  return renderDataItem
end
function UIPVPRankDialog.ItemRenderer(index, renderData)
  if self.rankItemDataTable == nil or #self.rankItemDataTable == 0 then
    return
  end
  local data = self.rankItemDataTable[index + 1]
  local item = renderData.data
  item:SetData(data, index)
end
function UIPVPRankDialog:OnClickUserAvatar()
end
function UIPVPRankDialog:OnClickRewardBtn()
  UIManager.OpenUI(UIDef.UIPVPRankRewardDialog)
end
function UIPVPRankDialog:SeasonCountdown()
  local curTimestamp = CGameTime:GetTimestamp()
  local lastTime = self.seasonCloseTime - curTimestamp
  if lastTime <= 0 then
    if self.closeTimer ~= nil then
      self.closeTimer:Stop()
      self.closeTimer = nil
    end
    self:OnSeasonEnd()
    return
  end
  self.ui.mText_Time.text = TableData.GetHintReplaceById(120160, NetCmdPVPData:ConvertPvpTime(curTimestamp, self.seasonCloseTime))
  self.closeTimer = TimerSys:UnscaledDelayCall(1, function()
    UIPVPRankDialog:Tick()
  end, nil, lastTime)
end
function UIPVPRankDialog:Tick()
end
function UIPVPRankDialog:OnSeasonEnd()
end
