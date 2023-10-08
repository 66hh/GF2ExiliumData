require("UI.SimCombatPanel.ResourcesCombat.UISimCombatResourceTopBar")
require("UI.SimCombatPanel.ResourcesCombat.UISimCombatResourceTabList")
require("UI.SimCombatPanel.ResourcesCombat.UISimCombatResourceStageList")
require("UI.SimCombatPanel.ResourcesCombat.UISimCombatResourceStageDesc")
UISimCombatResourcePanelBase = class("UISimCombatResourcePanelBase", UIBasePanel)
function UISimCombatResourcePanelBase:ctor(csPanel)
  self.super.super.ctor(self, csPanel)
  csPanel.UsePool = false
end
function UISimCombatResourcePanelBase:OnAwake(root, data)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnBack.gameObject, function()
    self:onClickBack()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnHome.gameObject, function()
    self:onClickHome()
  end)
  self.topBar = UISimCombatResourceTopBar.New(self.ui.mTrans_Title)
  self.tabList = UISimCombatResourceTabList.New(self.ui.mTrans_TabList)
  self.tabList:AddClickTabListener(function(simTypeId, isOpenDay, fromState)
    self:onClickTab(simTypeId, isOpenDay, fromState)
  end)
  self.stageList = UISimCombatResourceStageList.New(self.ui.mTrans_StageList)
  self.stageList:AddSelectSlotListener(function(simResourceData, isOpenDay)
    self:onSelectStageSlot(simResourceData, isOpenDay)
  end)
  self.stageDesc = UISimCombatResourceStageDesc.New(self.ui.mTrans_Desc)
end
function UISimCombatResourcePanelBase:OnInit(root, data, behaviourId)
  if type(data) == "userdata" then
    local jumpData = data
    if jumpData.Length == 2 then
      self.jumpTabTypeId = tonumber(jumpData[0])
      self.jumpSlotResourceId = tonumber(jumpData[1])
    elseif jumpData.Length == 1 then
      self.jumpSlotResourceId = tonumber(jumpData[0])
    end
  end
  function self.onRaidDuringEndCallback(msg)
    TimerSys:DelayFrameCall(5, function()
      setactivewithcheck(self.ui.mTrans_Mask, false)
    end)
    self.topBar:Refresh()
    self.stageDesc:Refresh()
  end
  function self.queueClearMessageCallBack()
    self:OnTop()
  end
  MessageSys:AddListener(UIEvent.OnRaidDuringEnd, self.onRaidDuringEndCallback)
  MessageSys:AddListener(UIEvent.UISimCombatResourcePanelBaseRefresh, self.queueClearMessageCallBack)
end
function UISimCombatResourcePanelBase:OnShowStart()
  self:refresh()
end
function UISimCombatResourcePanelBase:OnBackFrom()
  self.topBar:Refresh()
  self.tabList:Refresh()
  self.stageDesc:Refresh()
end
function UISimCombatResourcePanelBase:OnTop()
  self.topBar:Refresh()
  self.tabList:Refresh()
  self.stageDesc:Refresh()
end
function UISimCombatResourcePanelBase:OnSave()
  UISimCombatGlobal.CachedTabSimTypeId = self.tabList:GetCurTabSimTypeId()
  UISimCombatGlobal.CachedSlotStageId = self.stageList:getCurSlot().stageData.id
end
function UISimCombatResourcePanelBase:OnRecover()
  self:refresh(UISimCombatGlobal.FromState.OnRecover)
end
function UISimCombatResourcePanelBase:OnClose()
  MessageSys:RemoveListener(UIEvent.OnRaidDuringEnd, self.onRaidDuringEndCallback)
  MessageSys:RemoveListener(UIEvent.UISimCombatResourcePanelBaseRefresh, self.queueClearMessageCallBack)
  self.topBar:OnClose()
  self.tabList:OnClose()
  self.stageList:OnClose()
  self.stageDesc:OnClose()
  ResourceManager:DestroyInstance(self.goBg)
end
function UISimCombatResourcePanelBase:OnRelease()
  self.topBar:OnRelease()
  self.tabList:OnRelease()
  self.stageList:OnRelease()
  self.stageDesc:OnRelease()
end
function UISimCombatResourcePanelBase:OnRefresh()
  self.topBar:Refresh()
end
function UISimCombatResourcePanelBase:refresh(fromState)
  self.topBar:SetVisible(false)
  self.tabList:SetVisible(false)
  self.stageList:SetVisible(false)
  self.stageDesc:SetVisible(false)
  NetCmdSimulateBattleData:ReqPlanData(PlanType.PlanFunctionSimDailyopen.value__, function()
    local simType = StageType.__CastFrom(self.simEntranceId)
    NetCmdStageRecordData:RequestStageRecordByType(simType, function(ret)
      if ret ~= ErrorCodeSuc then
        return
      end
      NetCmdSimulateBattleData:RecordEnterSimResourcesPanel(self.simEntranceId)
      self.tabList:SetData(self.simEntranceId, UISimCombatGlobal.CachedTabSimTypeId or self.jumpTabTypeId, fromState)
      self.topBar:SetData(self.simEntranceId, self.tabList:GetCurTabSimTypeId())
      self.topBar:SetVisible(true)
      self.stageList:SetVisible(true)
      self.stageDesc:SetVisible(true)
      self.topBar:Refresh()
      self.tabList:Refresh()
      self.stageDesc:Refresh(fromState)
      local simCombatEntranceData = TableDataBase.listSimCombatEntranceDatas:GetDataById(self.simEntranceId)
      if not simCombatEntranceData then
        return
      end
      if self.goBg then
        ResourceManager:DestroyInstance(self.goBg)
      end
      self.goBg = ResSys:GetSimCombatInstantiate(simCombatEntranceData.bg_path, self.ui.mTrans_Bg)
    end)
  end)
end
function UISimCombatResourcePanelBase:OnLoadingEndOnTop()
  self:checkShowRaidOpenHint()
end
function UISimCombatResourcePanelBase:checkShowRaidOpenHint()
  if self.simEntranceId ~= StageType.CashStage.value__ then
    return
  end
  if UISimCombatGlobal.CachedSlotStageId == nil then
    return
  end
  local stageData = TableDataBase.listStageDatas:GetDataById(UISimCombatGlobal.CachedSlotStageId)
  local simCombatResourceData = TableDataBase.listSimCombatResourceDatas:GetDataById(UISimCombatGlobal.CachedSlotStageId)
  local prevPoint = NetCmdStageRatingData:GetPrevCashPoint(stageData.id)
  local currPoint = NetCmdStageRatingData:GetCashPoint(stageData.id)
  local prevRatingType = NetCmdStageRatingData:GetPrevCashRating(stageData.id)
  local currRatingType = NetCmdStageRatingData:GetCashRating(stageData.id)
  local gradeGroupId = self.stageDesc:getGradeGroupId()
  local prevCashGradeData = NetCmdStageRatingData:GetCashGradeData(gradeGroupId, prevRatingType)
  local currCashGradeData = NetCmdStageRatingData:GetCashGradeData(gradeGroupId, currRatingType)
  if prevPoint == 0 and 0 < currPoint and currCashGradeData ~= nil and currCashGradeData.auto_open then
    local hint = TableData.GetHintById(103137, simCombatResourceData.Name.str, stageData.name.str)
    PopupMessageManager.PopupDZStateChangeString(hint, function()
      MessageSys:SendMessage(UIEvent.UISimCombatResourcePanelBaseRefresh, nil)
      self.stageList:AutoSelectLastActiveSlot(UISimCombatGlobal.FromState.OnBack)
      self.stageList:Refresh()
    end, nil)
    return
  end
  if prevCashGradeData ~= nil and currCashGradeData ~= nil and not prevCashGradeData.auto_open and currCashGradeData.auto_open then
    local hint = TableData.GetHintById(103137, simCombatResourceData.Name.str, stageData.name.str)
    PopupMessageManager.PopupDZStateChangeString(hint, function()
      MessageSys:SendMessage(UIEvent.UISimCombatResourcePanelBaseRefresh, nil)
      self.stageList:AutoSelectLastActiveSlot(UISimCombatGlobal.FromState.OnBack)
      self.stageList:Refresh()
    end, nil)
  end
end
function UISimCombatResourcePanelBase:onClickTab(simTypeId, isOpenDay, fromState)
  self.stageList:SetData(simTypeId, nil, isOpenDay, fromState)
  self.stageList:AutoSelectLastActiveSlot(fromState)
  self.stageList:Refresh()
end
function UISimCombatResourcePanelBase:onSelectStageSlot(simResourceData, isOpenDay)
  self.stageDesc:SetData(self.simEntranceId, simResourceData, isOpenDay)
  self.stageDesc:Refresh()
end
function UISimCombatResourcePanelBase:onClickBack()
  UISimCombatGlobal.CachedTabSimTypeId = nil
  UISimCombatGlobal.CachedSlotStageId = nil
  UIManager.CloseUI(self.mCSPanel)
end
function UISimCombatResourcePanelBase:onClickHome()
  UISimCombatGlobal.CachedTabSimTypeId = nil
  UISimCombatGlobal.CachedSlotStageId = nil
  UIManager.JumpToMainPanel()
end
