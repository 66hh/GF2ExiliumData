require("UI.DarkZonePanel.UIDarkZoneModePanel.DarkZoneGlobal")
require("UI.DarkZonePanel.UIDarkZoneQuestPanel.UIDarkZoneQuestPanelV2")
require("UI.DarkZonePanel.UIDarkZoneModePanel.DarkZoneModeTopItem")
require("UI.DarkZonePanel.UIDarkZoneExplorePanel.UIDarkZoneExplorePanel")
require("UI.DarkZonePanel.UIDarkZoneModePanel.UIDarkZoneEndlessPanel.UIDarkZoneEndlessItem")
UIDarkZoneModePanel = class("UIDarkZoneModePanel", UIBasePanel)
UIDarkZoneModePanel.__index = UIDarkZoneModePanel
function UIDarkZoneModePanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
  csPanel.Is3DPanel = true
  self.mCSPanel = csPanel
end
function UIDarkZoneModePanel:OnAwake(root, data)
end
function UIDarkZoneModePanel:OnInit(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.animator = UIUtils.GetAnimator(self.mUIRoot, "Root")
  self.mTabPanels = {}
  self.mTopTab = {}
  self.topRes = nil
  self.mCurItemPanel = nil
  self.isBackFrom = false
  self.isOnRecover = false
  self.isTop = false
  self.mData = data
  self.hasFinishGroupList = {}
  self.mIsFirstShowQuest = true
  self.mIsFirstShow = data.panelType
  self.uid = AccountNetCmdHandler:GetUID()
  self.finishSeriesQuest = DarkNetCmdStoreData.seriesQuest.FinishQuest
  self.moveFinishFunc = nil
  self.planData = nil
  self.moveFlag = true
  self.initShow = true
  for i = DarkZoneGlobal.LevelTypeMin, DarkZoneGlobal.LevelTypeMax do
    self.hasFinishGroupList[i] = false
    if self.finishSeriesQuest:ContainsKey(i) and self.finishSeriesQuest[i].Ids.Count == 4 then
      self.hasFinishGroupList[i] = true
    end
  end
  setactive(self.ui.mTrans_QuestMode.gameObject, true)
  self.selectTab = self.selectTab and self.selectTab or DarkZoneGlobal.PanelType.Quest
  if data ~= nil then
    if type(data) == "userdata" then
      self:SetTabType(data[0])
    else
      self:SetTabType(data.panelType)
    end
  end
  self:AddBtnListen()
  local questPanel = UIDarkZoneQuestPanelV2.New()
  questPanel:InitCtrl(self.ui.mScrollChild_Quest.childItem, self.ui.mScrollChild_Quest.transform, self)
  table.insert(self.mTabPanels, questPanel)
  setactive(self.ui.mScrollChild_Quest.transform, true)
  UIDarkZoneQuestPanelV2.DarkZoneModelType = DarkZoneGlobal.PanelType.Quest
  local explorePanel = UIDarkZoneExplorePanel.New()
  explorePanel:InitCtrl(self.ui.mScrollChild_Mode.childItem, self.ui.mScrollChild_Mode.transform, self)
  table.insert(self.mTabPanels, explorePanel)
  setactive(self.ui.mScrollChild_Mode.gameObject, false)
  UIDarkZoneExplorePanel.DarkZoneModelType = DarkZoneGlobal.PanelType.Explore
  local endlessPanel = UIDarkZoneEndlessItem.New()
  endlessPanel:InitCtrl(self.ui.mScrollChild_Endless.transform, self)
  self.mTabPanels[DarkZoneGlobal.PanelType.EndLess] = endlessPanel
  setactive(self.ui.mScrollChild_Endless.transform, false)
  UIDarkZoneEndlessItem.DarkZoneModelType = DarkZoneGlobal.PanelType.EndLess
  self.seasonID = 0
  self.planID = NetCmdRecentActivityData:GetCurDarkZonePlanActivityData()
  if 0 < self.planID then
    self:InitSeasonData()
  end
  setactive(self.ui.mScrollChild_TopRight, false)
end
function UIDarkZoneModePanel:IsExploreUnlock()
  local season = TableData.listDarkzoneSeasonDatas:GetDataById(NetCmdDarkZoneSeasonData.SeasonID)
  for finsih, id in pairs(self.finishSeriesQuest.Keys) do
    for i = 0, self.finishSeriesQuest[id].Ids.Count - 1 do
      if self.finishSeriesQuest[id].Ids[i] ~= 0 and self.finishSeriesQuest[id].Ids[i] == season.explore_unlock then
        return true
      end
    end
  end
  return false
end
function UIDarkZoneModePanel:IsEndlessUnlock()
  local season = TableData.listDarkzoneSeasonDatas:GetDataById(NetCmdDarkZoneSeasonData.SeasonID)
  for finsih, id in pairs(self.finishSeriesQuest.Keys) do
    for i = 0, self.finishSeriesQuest[id].Ids.Count - 1 do
      if self.finishSeriesQuest[id].Ids[i] ~= 0 and self.finishSeriesQuest[id].Ids[i] == season.endless_unlock then
        return true
      end
    end
  end
  return false
end
function UIDarkZoneModePanel:SetTabType(tabType)
  self.selectTab = tabType
  if self.mData and type(self.mData) ~= "userdata" then
    self.mData.panelType = self.selectTab
  end
  if self.hasFinishGroupList and self.selectTab == DarkZoneGlobal.PanelType.Explore and not self:IsExploreUnlock() then
    self.selectTab = DarkZoneGlobal.PanelType.Quest
    CS.PopupMessageManager.PopupString(TableData.listDarkzoneSeasonDatas:GetDataById(NetCmdDarkZoneSeasonData.SeasonID).explore_unlock_des)
  elseif self.hasFinishGroupList and self.selectTab == DarkZoneGlobal.PanelType.EndLess and not self:IsEndlessUnlock() then
    self.selectTab = DarkZoneGlobal.PanelType.Quest
    CS.PopupMessageManager.PopupString(TableData.listDarkzoneSeasonDatas:GetDataById(NetCmdDarkZoneSeasonData.SeasonID).endless_unlock_des)
  end
end
function UIDarkZoneModePanel:OnShowStart()
  if self.mCurItemPanel then
    self.mCurItemPanel:OnShowStart()
  end
end
function UIDarkZoneModePanel:InitSeasonData()
  self.seasonID = NetCmdDarkZoneSeasonData.SeasonID
  self.planData = TableData.listPlanDatas:GetDataById(self.planID)
  local seasonData = TableData.listDarkzoneSeasonDatas:GetDataById(self.seasonID)
  self.ui.mText_SeasonName.text = seasonData.name.str
end
function UIDarkZoneModePanel:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    for i = 1, #self.mTabPanels do
      if self.mTabPanels[i]:GetRoot().gameObject.activeSelf then
        setactive(self.mTabPanels[i]:GetRoot().gameObject, false)
        UIManager.CloseUI(UIDef.UIDarkZoneModePanel)
        return
      end
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    for i = 1, #self.mTabPanels do
      if self.mTabPanels[i]:GetRoot().gameObject.activeSelf then
        setactive(self.mTabPanels[i]:GetRoot().gameObject, false)
        UIManager.JumpToMainPanel()
        return
      end
    end
  end
end
function UIDarkZoneModePanel:OnClickTab(index, isBackFrom, isOnRecover)
  if not self.selectTab and self.selectTab == index and not self.initShow then
    return
  end
  self.initShow = false
  self:SetTabType(index)
  for i, item in pairs(self.mTabPanels) do
    item:Hide()
    if self["enableTimer" .. i] then
      self["enableTimer" .. i]:Stop()
      self["enableTimer" .. i] = nil
    end
    local ani = UIUtils.GetAnimator(item:GetRoot())
    if item:GetRoot().gameObject.activeSelf and item.DarkZoneModelType ~= index then
      ani:ResetTrigger("FadeIn")
      ani:SetTrigger("FadeOut")
      local length = CSUIUtils.GetClipLengthByEndsWith(ani, "FadeOut")
      self["enableTimer" .. i] = TimerSys:DelayCall(length, function()
        setactive(item:GetRoot().gameObject, false)
      end)
    end
  end
  setactivewithcheck(self.ui.mTrans_GrpTitle, false)
  local time = 0
  if index ~= DarkZoneGlobal.PanelType.Quest and self.mIsFirstShowQuest == true then
    self.mTabPanels[DarkZoneGlobal.PanelType.Quest]:SetAllAnimatorEmpty()
    self.mIsFirstShowQuest = false
    self.ui.mMoveController:MoveAssetExplore(self.ui.mAnimator_Map.transform.anchoredPosition, DarkZoneGlobal.QuestMapPos.Center, 0.833)
    self.moveFlag = false
    if index == DarkZoneGlobal.PanelType.Explore then
      time = 0.2
    end
  elseif index ~= DarkZoneGlobal.PanelType.Quest and self.isTop == false then
    self.mTabPanels[DarkZoneGlobal.PanelType.Quest]:SetAnimatorEmpty()
    self.mTabPanels[DarkZoneGlobal.PanelType.Quest]:RemoveTimeFunc()
    self.ui.mMoveController:MoveAssetExplore(self.ui.mAnimator_Map.transform.anchoredPosition, DarkZoneGlobal.QuestMapPos.Center, 0.833)
    self.moveFlag = false
    if index == DarkZoneGlobal.PanelType.Explore then
      time = 0.4
    end
  elseif index == DarkZoneGlobal.PanelType.Quest and self.isBackFrom == false then
    self.mTabPanels[DarkZoneGlobal.PanelType.Quest]:SetAnimatorFadeIn()
    time = 0.4
  end
  function self.moveFinishFunc(isNeedDelayFadein)
    setactive(self.ui.mTrans_ExploreMode.gameObject, index == DarkZoneGlobal.PanelType.Explore)
    if self.showTimer then
      TimerSys:RemoveTimer(self.showTimer)
    end
    if self.mIsFirstShow == DarkZoneGlobal.PanelType.Explore then
      self.mIsFirstShow = 0
      setactive(self.ui.mScrollChild_Quest.transform, index == DarkZoneGlobal.PanelType.Quest)
      setactive(self.ui.mScrollChild_Mode.gameObject, index == DarkZoneGlobal.PanelType.Explore)
      setactive(self.ui.mScrollChild_Endless.gameObject, index == DarkZoneGlobal.PanelType.EndLess)
    else
      self.showTimer = TimerSys:DelayCall(time, function()
        setactive(self.ui.mScrollChild_Quest.transform, index == DarkZoneGlobal.PanelType.Quest)
        setactive(self.ui.mScrollChild_Mode.gameObject, index == DarkZoneGlobal.PanelType.Explore)
        setactive(self.ui.mScrollChild_Endless.gameObject, index == DarkZoneGlobal.PanelType.EndLess)
        self.showTimer = nil
      end)
    end
    self:ResetMapColor()
    self:RefreshExploreMap(index)
    for i = DarkZoneGlobal.PanelType.Quest, DarkZoneGlobal.PanelType.EndLess do
      self.mTopTab[i].ui.mBtn_TopItem.interactable = true
    end
    self.mTopTab[index].ui.mBtn_TopItem.interactable = false
    if self.mTabPanels[index] ~= nil then
      self.mCurItemPanel = self.mTabPanels[index]
      setactive(self.mCurItemPanel:GetRoot().gameObject, true)
      self.mCurItemPanel:Show(self.mIsFirstShowQuest, isBackFrom, isNeedDelayFadein, isOnRecover)
      if self.mIsFirstShowQuest == true and index == DarkZoneGlobal.PanelType.Quest then
        self.mIsFirstShowQuest = false
      end
      local ani = UIUtils.GetAnimator(self.mCurItemPanel:GetRoot())
      ani:ResetTrigger("FadeOut")
      ani:SetTrigger("FadeIn")
    end
  end
  if self.moveFlag then
    self.moveFinishFunc()
  else
    self.moveFinishFunc(true)
  end
end
function UIDarkZoneModePanel:OnShowFinish()
  self:SetUnlock()
  if not self.isTop then
    self.mTopTab[self.selectTab]:OnClick(self.isBackFrom, self.isOnRecover)
  end
  self.isBackFrom = false
  self.isTop = false
  self.isOnRecover = false
  if self.mCurItemPanel then
    self.mCurItemPanel:OnShowFinish()
  end
end
function UIDarkZoneModePanel:SetUnlock()
  for i = DarkZoneGlobal.PanelType.Quest, DarkZoneGlobal.PanelType.EndLess do
    do
      local topItem = self.mTopTab[i]
      if topItem == nil then
        topItem = DarkZoneModeTopItem.New()
        topItem:InitCtrl(self.ui.mScrollChild_TopRight.childItem, self.ui.mScrollChild_TopRight.transform)
        table.insert(self.mTopTab, topItem)
      end
      topItem:SetData(i, function(index, isBackFrom, isOnRecover)
        if i == DarkZoneGlobal.PanelType.Explore then
          if self:IsExploreUnlock() then
            self:OnClickTab(index, isBackFrom, isOnRecover)
            MessageSys:SendMessage(GuideEvent.OnTabSwitched, UIDef.UIDarkZoneModePanel, topItem:GetGlobalTab())
          else
            CS.PopupMessageManager.PopupString(TableData.listDarkzoneSeasonDatas:GetDataById(NetCmdDarkZoneSeasonData.SeasonID).explore_unlock_des)
            MessageSys:SendMessage(GuideEvent.OnTabSwitchFail, nil)
          end
        elseif i == DarkZoneGlobal.PanelType.EndLess then
          if self:IsEndlessUnlock() then
            self:OnClickTab(index, isBackFrom, isOnRecover)
            MessageSys:SendMessage(GuideEvent.OnTabSwitched, UIDef.UIDarkZoneModePanel, topItem:GetGlobalTab())
          else
            CS.PopupMessageManager.PopupString(TableData.listDarkzoneSeasonDatas:GetDataById(NetCmdDarkZoneSeasonData.SeasonID).endless_unlock_des)
            MessageSys:SendMessage(GuideEvent.OnTabSwitchFail, nil)
          end
        else
          self:OnClickTab(index, isBackFrom, isOnRecover)
          MessageSys:SendMessage(GuideEvent.OnTabSwitched, UIDef.UIDarkZoneModePanel, topItem:GetGlobalTab())
        end
      end, TableData.GetHintById(903357 + i))
      if i == DarkZoneGlobal.PanelType.Quest then
        topItem:SetUnLock(AccountNetCmdHandler:CheckSystemIsUnLock(DarkZoneGlobal.ModeUnlockId[DarkZoneGlobal.PanelType.Quest]))
        topItem:SetRedPoint(self:UpdateQuestRedPoint())
        topItem:SetGlobalTabId(61)
      elseif i == DarkZoneGlobal.PanelType.Explore then
        if self:IsExploreUnlock() then
          topItem:SetUnLock(true)
        end
        topItem:SetRedPoint(self:UpdateExploreRedPoint())
        topItem:SetGlobalTabId(62)
      elseif i == DarkZoneGlobal.PanelType.EndLess then
        if self:IsEndlessUnlock() then
          topItem:SetUnLock(true)
        end
        topItem:SetRedPoint(self:UpdateEndlessRedPoint())
        topItem:SetGlobalTabId(63)
      end
    end
  end
end
function UIDarkZoneModePanel:OnBackFrom()
  self.isBackFrom = true
  if self.mCurItemPanel then
    self.mCurItemPanel:OnBackFrom()
  end
end
function UIDarkZoneModePanel:OnTop()
  self.isTop = true
  for i = 1, #self.mTabPanels do
    if self.mTabPanels[i].OnTop then
      self.mTabPanels[i]:OnTop()
    end
  end
end
function UIDarkZoneModePanel:OnClose()
  self:ReleaseTimers()
  for i = 1, #self.mTopTab do
    self.mTopTab[i]:Release()
    gfdestroy(self.mTopTab[i]:GetRoot())
  end
  for i = 1, #self.mTabPanels do
    self.mTabPanels[i]:Release()
    gfdestroy(self.mTabPanels[i]:GetRoot())
  end
  for i = 1, 3 do
    if self["enableTimer" .. i] then
      self["enableTimer" .. i]:Stop()
      self["enableTimer" .. i] = nil
    end
  end
end
function UIDarkZoneModePanel:UpdateQuestRedPoint()
  return NetCmdDarkZoneSeasonData:UpdateQuestRedPoint() > 0
end
function UIDarkZoneModePanel:UpdateExploreRedPoint()
  return NetCmdDarkZoneSeasonData:UpdateExploreRedPoint() > 0
end
function UIDarkZoneModePanel:UpdateEndlessRedPoint()
  return NetCmdDarkZoneSeasonData:UpdateEndlessRedPoint() > 0
end
function UIDarkZoneModePanel:OnHide()
  if self.mCurItemPanel and self.selectTab == DarkZoneGlobal.PanelType.Explore then
    self.mCurItemPanel:OnHide()
  end
end
function UIDarkZoneModePanel:OnHideFinish()
end
function UIDarkZoneModePanel:OnRecover()
  self.isOnRecover = true
  self.mTabPanels[DarkZoneGlobal.PanelType.EndLess]:OnRecover()
end
function UIDarkZoneModePanel:OnRelease()
end
function UIDarkZoneModePanel:OnUpdate(deltatime)
  if self.mTabPanels then
    for _, item in pairs(self.mTabPanels) do
      if item and not UIUtils.IsNullOrDestroyed(item:GetRoot()) and item:GetRoot().gameObject.activeSelf and item.OnUpdate then
        item:OnUpdate(deltatime)
      end
    end
  end
  if not self.moveFlag and self.ui then
    self.moveFlag = self.ui.mMoveController:UpdateTime(CS.UnityEngine.Time.deltaTime, self.moveFlag)
  end
end
function UIDarkZoneModePanel:SetMapColor(index, integer)
  if index == 1 then
    self.animator:SetInteger("MapEasy", integer)
  elseif index == 2 then
    self.animator:SetInteger("MapHard", integer)
  elseif index == 3 then
    self.animator:SetInteger("MapVeryHard", integer)
  end
end
function UIDarkZoneModePanel:ResetMapColor()
  self.animator:SetInteger("MapEasy", 0)
  self.animator:SetInteger("MapHard", 0)
  self.animator:SetInteger("MapVeryHard", 0)
end
function UIDarkZoneModePanel:RefreshExploreMap(panelType)
  setactive(self.ui.mTrans_MapImitateFrame.gameObject, false)
  setactive(self.ui.mTrans_MapImitateContent.gameObject, false)
  if panelType ~= DarkZoneGlobal.PanelType.Explore then
    return
  end
  local visible = true
  for i = 0, 3 do
    local tmpData = UIDarkZoneExplorePanel.GetExploreData(i)
    if tmpData then
      if i == 0 then
        self.ui.mText_NewExploreTitle.text = tmpData.map_title.str
        self.ui.mText_NewExploreSubTitle.text = tmpData.map_sub_title.str
      else
        local isUnlock = true
        for j = 0, tmpData.unlock.Count - 1 do
          if not NetCmdAchieveData:CheckComplete(tmpData.unlock[j]) then
            isUnlock = false
            break
          end
        end
        if i == 3 then
          local showNotOpen = self.ui.mTrans_ExploreMapUnLock1.gameObject.activeSelf and not self.ui.mTrans_ExploreMapUnLock2.gameObject.activeSelf and not isUnlock
          setactive(self.ui["mTrans_NotOpen" .. i].gameObject, showNotOpen)
          setactive(self.ui["mTrans_ExploreMapLock" .. i].gameObject, not isUnlock and not showNotOpen)
          setactive(self.ui["mTrans_ExploreMapUnLock" .. i].gameObject, isUnlock and not showNotOpen)
        else
          setactive(self.ui["mTrans_ExploreMapLock" .. i].gameObject, not isUnlock)
          setactive(self.ui["mTrans_ExploreMapUnLock" .. i].gameObject, isUnlock)
        end
        self.ui["mText_ExploreCondition" .. i].text = isUnlock and "" or tmpData.unlock_des.str
        self.ui["mText_ExploreMap" .. i].text = tmpData.map_title.str
        self.ui["mText_ExploreSubTitle" .. i].text = tmpData.map_sub_title.str
        self:SetMapColor(i, isUnlock and 1 or 0)
        if isUnlock then
          visible = false
        end
      end
    end
  end
  setactive(self.ui.mTrans_ExploreLock, false)
  if visible then
    setactive(self.ui["mTrans_ExploreMapLock" .. 2].gameObject, false)
    setactive(self.ui["mTrans_ExploreMapLock" .. 3].gameObject, false)
    setactive(self.ui["mTrans_NotOpen" .. 3].gameObject, true)
  end
  setactive(self.ui["mTrans_NotOpen" .. 1].gameObject, false)
  setactive(self.ui["mTrans_NotOpen" .. 2].gameObject, visible)
  setactive(self.ui.mTrans_MapImitateFrame.gameObject, visible)
  setactive(self.ui.mTrans_MapImitateContent.gameObject, visible)
  if not self.isTop then
    self.animator:ResetTrigger("GrpExploreMode_TabFadeIn")
    self.animator:SetTrigger("GrpExploreMode_TabFadeIn")
  end
end
