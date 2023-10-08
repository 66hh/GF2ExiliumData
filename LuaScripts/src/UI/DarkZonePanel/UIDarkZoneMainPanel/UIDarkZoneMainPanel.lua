require("UI.DarkZonePanel.UIDarkZoneQuestInfoPanel.UIDarkZoneQuestInfoPanel")
require("UI.DarkZonePanel.UIDarkZoneNPCSelectPanel.UIDarkZoneStorePanel.DZStoreUtils")
require("UI.DarkZonePanel.UIDarkZoneMainPanel.item.DZMainEnterFunctionItem")
require("UI.DarkZonePanel.UIDarkZoneMainPanel.UIDarkZoneMainPanelView")
require("UI.DarkZonePanel.UIDarkZoneModePanel.DarkZoneGlobal")
require("UI.DarkZonePanel.UIDarkZoneModePanel.UIDarkZoneModePanel")
require("UI.UIBasePanel")
UIDarkZoneMainPanel = class("UIDarkZoneMainPanel", UIBasePanel)
UIDarkZoneMainPanel.__index = UIDarkZoneMainPanel
function UIDarkZoneMainPanel:ctor(csPanel)
  UIDarkZoneMainPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
  csPanel.Is3DPanel = true
  self.mCSPanel = csPanel
end
function UIDarkZoneMainPanel:OnAwake(root, data)
end
function UIDarkZoneMainPanel:OnSave()
  self.hasCache = false
end
function UIDarkZoneMainPanel:OnInit(root, data)
  self:SetRoot(root)
  self.mview = UIDarkZoneMainPanelView.New()
  self.ui = {}
  self.mview:InitCtrl(root, self.ui)
  self.questItem = nil
  self.exploreItem = nil
  self:InitDarkZoneGlobalLevel()
  self:AddBtnListen()
  self:InitBaseData()
  self:AutoToBattle()
  self:AddEventListener()
  self:SendNetData()
  self.closeTime = 0
  UIManager.EnableDarkZoneTeam(true)
  self.DarkZoneTeamCameraCtrl = CS.DarkZoneTeamCameraCtrl.Instance
  SceneSys:SwitchVisible(EnumSceneType.DarkZoneTeam)
  self:UpdateTeamList()
  if self.isFirstIn == true then
    self.isFirstIn = false
  end
  self.planID = NetCmdRecentActivityData:GetCurDarkZonePlanActivityData()
  self:InitDarkZoneGlobalLevel()
  RedPointSystem:GetInstance():UpdateRedPointByType(RedPointConst.DarkZoneQuest)
  self.questItem:RefreshRedDot(self:UpdateQuestRedPoint())
  if 0 < self.planID then
    self:InitSeasonData()
  end
end
function UIDarkZoneMainPanel:OnCameraStart()
  return self.closeTime
end
function UIDarkZoneMainPanel:OnCameraBack()
  return self.closeTime
end
function UIDarkZoneMainPanel:AutoToBattle()
  local teamData = DarkNetCmdTeamData.Teams[0]
  local realCount = 0
  local gunCount = DarkNetCmdTeamData.Teams[0].Guns.Count
  for i = 0, gunCount - 1 do
    local gunID = teamData.Guns[i]
    if 0 < gunID then
      realCount = realCount + 1
    end
  end
  if teamData.Leader == 0 or realCount ~= 4 then
    local list = DarkNetCmdTeamData:AutoToBattle()
    local listCount = list.Count - 1
    local gunlist = DarkNetCmdTeamData:ConstructData()
    local gunsCount = teamData.Guns.Count
    for i = 0, listCount do
      local id = list[i].GunId
      gunlist:Add(id)
      if i < gunsCount then
        DarkNetCmdTeamData.Teams[0].Guns[i] = id
      else
        DarkNetCmdTeamData.Teams[0].Guns:Add(id)
      end
    end
    local data = DarkZoneTeamData(0, gunlist, gunlist[0])
    DarkNetCmdTeamData.Teams[0].Leader = gunlist[0]
    DarkNetCmdTeamData:SetTeamInfo(data)
  end
end
function UIDarkZoneMainPanel:InitDarkZoneGlobalLevel()
  DarkZoneGlobal.DepartList = {}
  DarkZoneGlobal.DepartToLevel = {}
  DarkZoneGlobal.LevelToStcID = {}
  DarkZoneGlobal.StcIDToLevel = {}
  DarkZoneGlobal.LevelType = {}
  local questBundleList = NetCmdDarkZoneSeasonData.SeasonGroupToQuestList
  for index, key in pairs(questBundleList.Keys) do
    if DarkZoneGlobal.LevelTypeMin == 0 then
      DarkZoneGlobal.LevelTypeMin = index + 1
    end
    DarkZoneGlobal.LevelTypeMax = index + 1
    DarkZoneGlobal.LevelToStcID[index + 1] = key
    DarkZoneGlobal.StcIDToLevel[key] = index + 1
  end
  local departToGroup = NetCmdDarkZoneSeasonData.SeasonDepartToGroupList
  for index, key in pairs(departToGroup.Keys) do
    DarkZoneGlobal.DepartToLevel[key] = {}
    table.insert(DarkZoneGlobal.DepartList, key)
    for i = 0, departToGroup[key].Count - 1 do
      table.insert(DarkZoneGlobal.DepartToLevel[key], departToGroup[key][i])
    end
  end
end
function UIDarkZoneMainPanel:SendNetData()
  DarkZoneNetRepositoryData:SendCS_DarkZoneStorage()
end
function UIDarkZoneMainPanel:OnBackFrom()
  if SceneSys.CurSceneType ~= EnumSceneType.DarkZoneTeam then
    SceneSys:SwitchVisible(EnumSceneType.DarkZoneTeam)
  end
  self:UpdateTeamList()
  self:ResetCameraPos()
  self:RefreshSeasonData()
end
function UIDarkZoneMainPanel:OnShowStart()
  self:UpdateAllModel()
  self:RefreshSeasonData()
end
function UIDarkZoneMainPanel:OnShowFinish()
  RedPointSystem:GetInstance():UpdateRedPointByType(RedPointConst.DarkZoneQuest)
  self.questItem:RefreshRedDot(self:UpdateQuestRedPoint())
  for i = 1, #self.itemList do
    self.itemList[i]:RefreshLockState()
  end
  NetCmdRecentActivityData:RecordEnterRecentActivityDarkZonePanel()
end
function UIDarkZoneMainPanel:OnHide()
end
function UIDarkZoneMainPanel:OnUpdate(deltatime)
end
function UIDarkZoneMainPanel:OnRecover()
  self:OnShowStart()
end
function UIDarkZoneMainPanel:OnClose()
  self:ReleaseTimers()
  self.starttimeArr = nil
  self.endtimeArr = nil
  self.IsInEditor = nil
  self.NpcStoreItemDic = nil
  self.IsJudgeRedPointByItemLimit = nil
  self.craftHasUnlock = nil
  self.unLockTips = nil
  self.questItem = nil
  self.exploreItem = nil
  self.TeamDataDic = nil
  for i = 0, 3 do
    local obj = self.changeGunEffect[i]
    ResourceDestroy(obj)
  end
  self.changeGunEffect = nil
  MessageSys:RemoveListener(UIEvent.OnDarkZonePlanUpdate, self.InitDarkZoneGlobalLevel)
  self.favorChangeFunc = nil
  self.ui = nil
  self.mview = nil
  self.super.OnRelease(self)
  for i = 1, #self.itemList do
    self.itemList[i]:OnClose()
  end
  self.itemList = nil
  self.formatStr = nil
  self.isFirstIn = nil
  UIManager.EnableDarkZoneTeam(false)
  UIDarkZoneTeamModelManager:Release()
  DarkNetCmdTeamData:UnloadTeamAssets()
  self.DarkZoneTeamCameraCtrl = nil
end
function UIDarkZoneMainPanel:OnRelease()
  self.hasCache = false
end
function UIDarkZoneMainPanel:IsReadyToStartTutorial()
  if NetCmdDarkZoneSeasonData.FinishPlanID > 0 then
    return false
  end
  if self.planID and 0 < self.planID and PlayerPrefs.GetInt(AccountNetCmdHandler:GetUID() .. "PlanID") ~= self.planID and self.seasonData.season_reset == true then
    return false
  end
  return true
end
function UIDarkZoneMainPanel:InitBaseData()
  self.NpcStoreItemDic = {}
  self.IsJudgeRedPointByItemLimit = false
  local unlockData = TableData.listUnlockDatas:GetDataById(28001)
  local str = UIUtils.CheckUnlockPopupStr(unlockData)
  self.unLockTips = str
  self.formatStr = TableData.GetHintById(240010)
  self.TeamDataDic = {}
  self.ui.mUICountdown_LeftTime:AddFinishCallback(function(succ)
    if succ == true then
      self:DelayCall(0.5, function()
        NetCmdRecentActivityData:ReqPlanActivityData(PlanType.PlanFunctionDarkzone, function(ret)
          self:InitSeasonData()
        end)
      end)
    end
  end)
  self.isFirstIn = true
  self.changeGunEffect = {}
  for i = 0, 3 do
    self.changeGunEffect[i] = ResSys:GetEffect("Effect_sum/Other/EFF_Command_Character_Switch")
    self.changeGunEffect[i]:SetActive(false)
  end
end
function UIDarkZoneMainPanel:InitSeasonData()
  self.seasonID = NetCmdDarkZoneSeasonData.SeasonID
  local planData = TableData.listPlanDatas:GetDataById(self.planID)
  local openTime = CS.CGameTime.ConvertLongToDateTime(planData.open_time):ToString("yyyy.M.d")
  local closeTime = CS.CGameTime.ConvertLongToDateTime(planData.close_time):ToString("yyyy.M.d")
  self.ui.mText_SeasonTime.text = openTime .. "-" .. closeTime
  self.seasonData = TableData.listDarkzoneSeasonDatas:GetDataById(self.seasonID)
  self.ui.mText_SeasonName.text = self.seasonData.name.str
  self.ui.mUICountdown_LeftTime:StartCountdown(planData.close_time)
  self.ui.mImg_SeasonIcon.sprite = IconUtils.GetAtlasV2("DarkzoneSeasonLogo", self.seasonData.icon)
  self.ui.mImg_SeasonIcon2.sprite = IconUtils.GetAtlasV2("DarkzoneSeasonLogo", self.seasonData.icon)
  setactive(self.ui.mBtn_Season, self.seasonData.season_reset == true)
end
function UIDarkZoneMainPanel:SetItemList()
  self.itemList = {}
  local item
  item = DZMainEnterFunctionItem.New()
  item:InitCtrl(self.ui.mTrans_Bottom)
  item:SetData(240131, nil, function()
    self:EnterTeam()
    self.closeTime = 0.01
  end, 28003)
  item:SetImage("Icon_DarkzoneEnter_Fleet")
  table.insert(self.itemList, item)
  local season = TableData.listDarkzoneSeasonDatas:GetDataById(NetCmdDarkZoneSeasonData.SeasonID)
  item = DZMainEnterFunctionItem.New()
  item:InitCtrl(self.ui.mTrans_ModeList)
  item:SetData(903358, nil, function()
    self.closeTime = 0
    UIManager.OpenUIByParam(UIDef.UIDarkZoneModePanel, {
      panelType = DarkZoneGlobal.PanelType.Quest
    })
  end, DarkZoneGlobal.ModeUnlockId[DarkZoneGlobal.PanelType.Quest])
  self.questItem = item
  table.insert(self.itemList, item)
end
function UIDarkZoneMainPanel:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self.closeTime = 0
    UISystem:SetMainCamera(false)
    UIManager.CloseUI(UIDef.UIDarkZoneMainPanel)
    self:CallWithAniDelay(function()
      SceneSys:SwitchVisible(EnumSceneType.CommandCenter)
    end)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Season.gameObject).onClick = function()
    UIManager.OpenUI(UIDef.UIDarkZoneSeasonQuestPanel)
  end
  self:SetItemList()
end
function UIDarkZoneMainPanel:AddEventListener()
  MessageSys:AddListener(UIEvent.OnDarkZonePlanUpdate, self.InitDarkZoneGlobalLevel)
end
function UIDarkZoneMainPanel:EnterStorage()
  DarkZoneNetRepoCmdData:SendCS_DarkZoneStorage(function()
    UIManager.OpenUI(UIDef.UIDarkZoneRepositoryPanel)
  end)
end
function UIDarkZoneMainPanel:EnterNpcSelect()
  DarkNetCmdStoreData:SendCS_DarkZoneStorage(function()
    UIManager.OpenUI(UIDef.UIDarkZoneStorePanel)
  end)
end
function UIDarkZoneMainPanel:EnterMakeTable()
  DarkNetCmdMakeTableData:SendCS_DarkZoneWishExp(function()
    UIManager.OpenUI(UIDef.UIDarkZoneMakeTablePanel)
  end)
end
function UIDarkZoneMainPanel:EnterTeam()
  local TeamIndex = DarkNetCmdTeamData.CurTeamIndex
  local TeamData = self.TeamDataDic[TeamIndex + 1]
  if 0 < TeamData.guns[0] then
    self.DarkZoneTeamCameraCtrl.cameraBlendFinished:AddListener(function(c)
      self.DarkZoneTeamCameraCtrl:SetCharacterColor(0)
    end)
    local model = UIDarkZoneTeamModelManager:GetCaCheModel(TeamData.guns[0])
    self.DarkZoneTeamCameraCtrl:ChangeCameraStand(model.tableId, CS.DarkZoneTeamCameraPosType.Position1, model.gameObject)
  end
  UIManager.OpenUI(UIDef.UIDarkZoneTeamPanelV2)
end
function UIDarkZoneMainPanel:RefreshSeasonData()
  NetCmdRecentActivityData:ReqPlanActivityData(PlanType.PlanFunctionDarkzone, function(ret)
    self:RefreshSeasonUI()
  end)
end
function UIDarkZoneMainPanel:RefreshSeasonUI()
  self.planID = NetCmdRecentActivityData:GetCurDarkZonePlanActivityData()
  self:InitDarkZoneGlobalLevel()
  RedPointSystem:GetInstance():UpdateRedPointByType(RedPointConst.DarkZoneQuest)
  self.questItem:RefreshRedDot(self:UpdateQuestRedPoint())
  if self.planID > 0 then
    self:InitSeasonData()
  end
  if 0 < NetCmdDarkZoneSeasonData.FinishPlanID then
    UIManager.OpenUI(UIDef.UIDarkZoneSeasonSettlementDialog)
  elseif self.planID and self.planID > 0 and PlayerPrefs.GetInt(AccountNetCmdHandler:GetUID() .. "PlanID") ~= self.planID then
    if self.seasonData.season_reset == true then
      UIManager.OpenUI(UIDef.UIDarkZoneNewSeasonOpenDialog)
    else
      PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. "PlanID", self.planID)
    end
  end
end
function UIDarkZoneMainPanel:EnterDarkZone()
  if not self.IsInEditor then
    local nowtime = CS.CGameTime.ConvertUintToDateTime(CGameTime:GetTimestamp())
    local StartDatetime = DateTime(nowtime.Year, nowtime.Month, nowtime.Day, System.Int32.Parse(self.starttimeArr[1]), System.Int32.Parse(self.starttimeArr[2]), nowtime.Second)
    local EndDatetime = DateTime(nowtime.Year, nowtime.Month, nowtime.Day, System.Int32.Parse(self.endtimeArr[1]), System.Int32.Parse(self.endtimeArr[2]), 0)
    if 0 <= DateTime.Compare(nowtime, StartDatetime) and 0 > DateTime.Compare(nowtime, EndDatetime) then
      DarkZoneNetRepoCmdData:SendCS_DarkZoneStorage(function()
        UIManager.OpenUI(UIDef.UIDarkZoneMapSelectPanel)
      end)
    else
      UIUtils.PopupPositiveHintMessage(903001)
    end
  else
    DarkZoneNetRepoCmdData:SendCS_DarkZoneStorage(function()
      UIManager.OpenUI(UIDef.UIDarkZoneMapSelectPanel)
    end)
  end
end
function UIDarkZoneMainPanel:Instruction()
end
function UIDarkZoneMainPanel:UpdateQuestRedPoint()
  return NetCmdDarkZoneSeasonData:UpdateQuestRedPoint() > 0
end
function UIDarkZoneMainPanel:UpdateEndlessRedPoint()
  return NetCmdDarkZoneSeasonData:UpdateEndlessRedPoint() > 0
end
function UIDarkZoneMainPanel:UpdateMakeTableRedPoint()
  return NetCmdDarkZoneSeasonData:UpdateMakeTableRedPoint() > 0
end
function UIDarkZoneMainPanel:UpdateExploreRedPoint()
  return NetCmdDarkZoneSeasonData:UpdateExploreRedPoint() > 0
end
function UIDarkZoneMainPanel:UpdateNpcRedPoint()
  local needShow = self:UpdateNpcRedPointByStore()
  self.itemList[2]:RefreshRedDot(needShow)
end
function UIDarkZoneMainPanel:UpdateNpcRedPointByStore()
  local result = false
  self.NpcStoreItemDic = {}
  DZStoreUtils.NpcStoreStateDic = {}
  local NPCDatas = TableData.listDarkzoneNpcDatas:GetList()
  for j = 0, NPCDatas.Count - 1 do
    local NPCId = NPCDatas[j].id
    local list = DarkNetCmdStoreData:GetStoreDataByTag(NPCId)
    for i = 0, list.Count - 1 do
      local data = list[i]
      if self.NpcStoreItemDic[NPCId] == nil then
        self.NpcStoreItemDic[NPCId] = {}
      end
      table.insert(self.NpcStoreItemDic[NPCId], data)
    end
  end
  for NpcId, NpcStoreList in pairs(self.NpcStoreItemDic) do
    self.IsJudgeRedPointByItemLimit = true
    local NpcFavorData = DarkNetCmdStoreData:GetNpcDataById(NpcId)
    local NpcFavor = 0
    if NpcFavorData ~= nil then
      NpcFavor = NpcFavorData.Favor
    end
    local data = {}
    data.UnlockList = {}
    data.LockList = {}
    DZStoreUtils.NpcStoreStateDic[NpcId] = data
    for i = 1, #NpcStoreList do
      local unlockNum = tonumber(NpcStoreList[i].spec_args) or 0
      if NpcFavor >= unlockNum then
        if 0 < NpcStoreList[i].refresh_type then
          local refreshTime = NetCmdStoreData:GetGoodsRefreshById(NpcStoreList[i].id)
          local uid = AccountNetCmdHandler.Uid
          local key = uid .. NpcStoreList[i].id .. "LatestFreshTime"
          local value = tonumber(PlayerPrefs.GetString(key)) or 0
          if value ~= 0 and refreshTime > value then
            DZStoreUtils.redDotList[NpcId] = 1
            result = true
          end
        end
        table.insert(DZStoreUtils.NpcStoreStateDic[NpcId].UnlockList, NpcStoreList[i])
      elseif NpcFavor < unlockNum then
        table.insert(DZStoreUtils.NpcStoreStateDic[NpcId].LockList, NpcStoreList[i])
      end
    end
  end
  return result
end
function UIDarkZoneMainPanel:UpdateTeamList()
  local Data = DarkNetCmdTeamData.Teams
  for i = 0, Data.Count - 1 do
    local data = {}
    data.name = Data[i].Name
    data.guns = Data[i].Guns
    data.leader = Data[i].Leader
    for j = data.guns.Count, 3 do
      data.guns:Add(0)
    end
    table.insert(self.TeamDataDic, data)
  end
end
function UIDarkZoneMainPanel:UpdateAllModel()
  local TeamIndex = DarkNetCmdTeamData.CurTeamIndex
  local TeamData = self.TeamDataDic[TeamIndex + 1]
  self.needWait = true
  self.cacheIndex = 0
  self.gunModelCacheList = {}
  self.maxCacheIndex = 0
  for i = 0, 3 do
    if TeamData.guns[i] ~= 0 then
      self.maxCacheIndex = self.maxCacheIndex + 1
    end
  end
  for i = 0, 3 do
    if TeamData.guns[i] ~= 0 then
      self:UpdateModel(TeamData.guns[i], i)
    end
  end
end
function UIDarkZoneMainPanel:UpdateModel(GunId, Index)
  local Tabledata = TableData.listGunDatas:GetDataById(GunId)
  local GunCmdData = NetCmdTeamData:GetGunByID(GunId)
  local modelId = GunId
  local weaponModelId = GunCmdData.WeaponData ~= nil and GunCmdData.WeaponData.stc_id or Tabledata.weapon_default or Tabledata.weapon_default
  if UIDarkZoneTeamModelManager:IsCacheLoadedContains(modelId) >= 0 then
    local model = UIDarkZoneTeamModelManager:GetCaCheModel(modelId)
    model.Index = Index
    self:SetGunModel(model, Index)
    return
  end
  UIUtils.GetDarkZoneTeamUIModelAsyn(modelId, weaponModelId, Index, function(go)
    self:UpdateModelCallback(go, Index)
  end)
end
function UIDarkZoneMainPanel:UpdateModelCallback(obj, index)
  obj.transform.parent = nil
  if obj ~= nil and obj.gameObject ~= nil then
    self:SetGunModel(obj, index)
    if self.needWait then
      self.cacheIndex = self.cacheIndex + 1
      self.gunModelCacheList[index] = obj
      if self.cacheIndex >= self.maxCacheIndex then
        self:ShowAllGunModelByIndex(0)
      end
    end
  end
end
function UIDarkZoneMainPanel:ShowAllGunModelByIndex(index)
  if index >= self.maxCacheIndex then
    return
  end
  local model = self.gunModelCacheList[index]
  if model then
    model.gameObject:SetActive(true)
    self.changeGunEffect[index].transform.position = model.gameObject.transform.position
    setactive(self.changeGunEffect[index], true)
    self:DelayCall(0.1, function()
      self:ShowAllGunModelByIndex(index + 1)
    end)
  else
    self:ShowAllGunModelByIndex(index + 1)
  end
end
function UIDarkZoneMainPanel:SetGunModel(model, index)
  model:Show(self.needWait ~= true)
  local num = index + 1
  local str1 = string.format("unit_character_%d_position", num)
  local str2 = string.format("unit_character_%d_rotation", num)
  local data1 = TableData.listGunGlobalConfigDatas:GetDataById(model.tableId)
  local data2 = TableData.listDarkzoneUnitCameraDatas:GetDataById(data1.darkzone_unit_camera)
  local positionList = data2[str1]
  local rotationList = data2[str2]
  model.transform.localScale = Vector3.one
  model.transform.position = Vector3(positionList[0], positionList[1], positionList[2])
  model.transform.localEulerAngles = Vector3(rotationList[0], rotationList[1], rotationList[2])
  GFUtils.MoveToLayer(model.transform, CS.UnityEngine.LayerMask.NameToLayer("Friend"))
  if index == 0 then
    self.DarkZoneTeamCameraCtrl:ChangeCameraStand(model.tableId, CS.DarkZoneTeamCameraPosType.Captain, model.gameObject)
  end
  self.DarkZoneTeamCameraCtrl:UpdateMateriaList(model.gameObject, index)
  self.DarkZoneTeamCameraCtrl:SetBaseColorByBool(index, true)
end
function UIDarkZoneMainPanel:ResetCameraPos()
  local TeamIndex = DarkNetCmdTeamData.CurTeamIndex
  local TeamData = self.TeamDataDic[TeamIndex + 1]
  local id = TeamData.guns[0]
  if 0 < id then
    local model = UIDarkZoneTeamModelManager:GetCaCheModel(TeamData.guns[0])
    self.DarkZoneTeamCameraCtrl:ChangeCameraStand(model.tableId, CS.DarkZoneTeamCameraPosType.Captain, model.gameObject)
  end
end
