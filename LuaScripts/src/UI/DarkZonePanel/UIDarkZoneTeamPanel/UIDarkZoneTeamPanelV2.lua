require("UI.DarkZonePanel.UIDarkZoneTeamPanel.DarkZoneTeamItemV2")
require("UI.DarkZonePanel.UIDarkZoneTeamPanel.UIDarkZoneTeamPanelView")
require("UI.DarkZonePanel.UIDarkZoneTeamPanel.UIDarkZoneFleetAvatarItem")
require("UI.UIBasePanel")
UIDarkZoneTeamPanelV2 = class("UIDarkZoneTeamPanelV2", UIBasePanel)
UIDarkZoneTeamPanelV2.__index = UIDarkZoneTeamPanelV2
function UIDarkZoneTeamPanelV2:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
  csPanel.Is3DPanel = true
  self.mCSPanel = csPanel
end
function UIDarkZoneTeamPanelV2:OnInit(root, data)
  if SceneSys.CurSceneType ~= EnumSceneType.DarkZoneTeam then
    SceneSys:SwitchVisible(EnumSceneType.DarkZoneTeam)
  end
  self:SetRoot(root)
  self:InitBaseData()
  self.mData = data
  self.mView:InitCtrl(root, self.ui)
  self:AddBtnListen()
  self:AddEventListener()
  self.closeTime = self.mData == nil and 0.01 or 0
  self.DarkZoneTeamCameraCtrl = CS.DarkZoneTeamCameraCtrl.Instance
  self.Camera = UISystem.CharacterCamera
  self.Camera.transform.position = Vector3(0, 0, 0)
  local itemPrefab = self.ui.mTrans_Chrchange:GetComponent(typeof(CS.ScrollListChild))
  local prefab = instantiate(itemPrefab.childItem)
  self.gunListItem = CS.UICommonEmbattleChrItem(prefab.transform)
  setactive(self.gunListItem.mTrans_BtnChange.transform.parent, true)
  function self.gunListItem.GunList.itemProvider()
    return self:GunItemProvider()
  end
  function self.gunListItem.GunList.itemRenderer(index, renderData)
    self:GunItemRenderer(index, renderData)
  end
  function self.gunListItem.mRefreshAction(dutyID)
    self:ReFreshListByDutyID(dutyID)
  end
  self.gunListItem:SetParent(self.ui.mTrans_Chrchange)
  self.gunListItem:InitDarkTeamGunDataList()
  self.gunListItem.mTxt_Tittle.text = TableData.GetHintById(903009)
  function self.gunListItem.mConfirmCallBack()
    self:GoWar()
  end
  function self.gunListItem.mChangeCallBack()
    self:RePlace()
  end
  setactive(self.ui.mBtn_Confirm, self.mData ~= nil)
  self.comScreenItem = ComScreenItemHelper:InitGun(self.gunListItem.mCommonGunScreenItem, self.ItemDataList, function()
    self:UpdateGunList()
  end, nil, true)
  self.comScreenItem:ResetSort()
  self.roleDetailItem = CS.RoleDetailPanel(self.ui.mTrans_ChrInfo)
  self.changeGunEffect = ResSys:GetEffect("Effect_sum/Other/EFF_Command_Character_Switch")
  setactive(self.changeGunEffect, false)
  self.gunListItem:SetActive(false)
end
function UIDarkZoneTeamPanelV2:OnCameraStart()
  return 0.01
end
function UIDarkZoneTeamPanelV2:OnCameraBack()
  return self.closeTime
end
function UIDarkZoneTeamPanelV2:OnShowStart()
  if self.mData then
    self:UpdateTeamCamera()
  end
  setactive(self.gunListItem.mTrans_Action, false)
  setactive(self.gunListItem.mTrans_None, false)
  setactive(self.gunListItem.mTrans_Screen, self.mData ~= nil)
  self:DelayCall(0.3, function()
    if self.mData == nil then
      self.gunListItem:Show(true)
      self:DelayCall(0.3, function()
        setactive(self.gunListItem.mTrans_Screen, true)
        self.fleetAvatarItemList[1]:OnClickGunCard()
      end)
    end
  end)
end
function UIDarkZoneTeamPanelV2:OnShowFinish()
  self:ShowCurTeamGunList()
  if self.mData == nil and #self.fleetAvatarItemList > 0 then
    self.needChangeCameraPos = true
  end
end
function UIDarkZoneTeamPanelV2:OnHide()
end
function UIDarkZoneTeamPanelV2:OnBackFrom()
  self:UpdateTeamCamera()
end
function UIDarkZoneTeamPanelV2:OnUpdate(deltatime)
  self.uiLoopTime = self.uiLoopTime + deltatime
end
function UIDarkZoneTeamPanelV2:OnRecover()
  self:OnShowStart()
end
function UIDarkZoneTeamPanelV2:CloseFunction()
  if self.mData and self.isShowGunList == true then
    self:ExitChangeTeamMember()
  else
    if self.mData == nil then
      self:SetAllModelWhite()
    end
    local TeamIndex = DarkNetCmdTeamData.CurTeamIndex
    local TeamData = self.TeamDataDic[TeamIndex + 1]
    if 0 < TeamData.guns[0] then
      local model = UIDarkZoneTeamModelManager:GetCaCheModel(TeamData.guns[0])
      self.DarkZoneTeamCameraCtrl:ChangeCameraStand(model.tableId, CS.DarkZoneTeamCameraPosType.Captain, model.gameObject)
    end
    UIManager.CloseUI(UIDef.UIDarkZoneTeamPanelV2)
    self.gunListItem:Hide()
    setactive(self.gunListItem.mTrans_Action, false)
  end
end
function UIDarkZoneTeamPanelV2:OnClose()
  self:ReleaseTimers()
  self.mCSPanel.FadeOutTime = self.FadeOutTime
  local i = self.curTeam + 1
  local data = DarkZoneTeamData(i - 1, self.TeamDataDic[i].guns, self.TeamDataDic[i].Leader)
  DarkNetCmdTeamData.Teams[i - 1].Leader = self.TeamDataDic[i].Leader
  DarkNetCmdTeamData:SetTeamInfo(data)
  self.DarkZoneTeamCameraCtrl.cameraBlendFinished:RemoveAllListeners()
  self.DarkZoneTeamCameraCtrl = nil
  self.ui = nil
  self.mView = nil
  self.mData = nil
  self.isShowGunList = nil
  self.curTeam = nil
  self.Camera = nil
  self.uiCamera = nil
  self.uiLoopTime = nil
  self.TeamDataDic = nil
  self.closeTime = nil
  self.ItemDataList = nil
  self:ReleaseCtrlTable(self.fleetAvatarItemList, true)
  self.fleetAvatarItemList = nil
  self.curGunItem = nil
  self.isFocusModel = nil
  self.focusModel = nil
  self.selectGunItemIndex = nil
  self:UnRegistrationKeyboard(nil)
  self.comScreenItem:OnRelease()
  self.comScreenItem = nil
  self.gunListItem:OnRelease()
  self.gunListItem = nil
  self.hasChange = nil
  self.roleDetailItem:OnRelease()
  self.roleDetailItem = nil
  ResourceDestroy(self.changeGunEffect)
  self.changeGunEffect = nil
  self.isShowChrList = nil
  self.sortList = nil
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.OnClickDetailEvent, self.roleDetailEventFunc)
  self.roleDetailEventFunc = nil
end
function UIDarkZoneTeamPanelV2:InitBaseData()
  self.mView = UIDarkZoneTeamPanelView.New()
  self.ui = {}
  self.curTeam = 0
  self.uiLoopTime = 0
  self.firstInIt = true
  self.TeamDataDic = {}
  self.ItemDataList = {}
  self.fleetAvatarItemList = {}
  self.isFocusModel = false
  self.CurBtn = nil
  self.isShowGunList = false
  self.selectGunItemIndex = nil
  self.isShowChrList = true
  self.needChangeCameraPos = true
  self:InitData()
end
function UIDarkZoneTeamPanelV2:InitData()
  local Data = DarkNetCmdTeamData.Teams
  for i = 0, Data.Count - 1 do
    local data = {}
    data.name = Data[i].Name
    data.guns = Data[i].Guns
    data.Leader = Data[i].Leader
    for j = data.guns.Count, 3 do
      data.guns:Add(0)
    end
    table.insert(self.TeamDataDic, data)
  end
  self.ItemDataList = NetCmdTeamData.GunList
end
function UIDarkZoneTeamPanelV2:UpdateTeamList(TeamIndex)
  DarkNetCmdTeamData.CurTeamIndex = TeamIndex
  local TeamData = self.TeamDataDic[TeamIndex + 1]
  UIDarkZoneTeamModelManager.gunlist = TeamData.guns
  DarkNetCmdTeamData.QuicklyTeamList:Clear()
  for i = 0, 3 do
    DarkNetCmdTeamData.QuicklyTeamList:Add(TeamData.guns[i])
  end
  UIDarkZoneTeamModelManager:HideOrShowModel(false)
  local TeamIndex = DarkNetCmdTeamData.CurTeamIndex
  local TeamData = self.TeamDataDic[TeamIndex + 1]
  for i = 0, 3 do
    if TeamData.guns[i] ~= 0 then
      self:UpdateModel(TeamData.guns[i], i)
    end
  end
end
function UIDarkZoneTeamPanelV2:ShowGunList()
  self.gunListItem:ClickTabCallBack(0)
end
function UIDarkZoneTeamPanelV2:ShowCurTeamGunList()
  local gunList = self.TeamDataDic[self.curTeam + 1].guns
  for i = 0, gunList.Count - 1 do
    if 0 < gunList[i] then
      local index = i + 1
      if self.fleetAvatarItemList[index] == nil then
        self.fleetAvatarItemList[index] = UIDarkZoneFleetAvatarItem.New()
        self.fleetAvatarItemList[index]:InitCtrl(self.ui.mTrans_ChrList)
      end
      local item = self.fleetAvatarItemList[index]
      local cmdData = NetCmdTeamData:GetGunByID(gunList[i])
      item:SetData(cmdData, index)
      item:SetClickFunction(function(item)
        self:OnClickGunAvatarItem(item)
      end)
    end
  end
  setactive(self.ui.mTrans_ChrList, self.isShowChrList)
end
function UIDarkZoneTeamPanelV2:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    for i = 0, self.TeamDataDic[self.curTeam + 1].guns.Count - 1 do
      if self.TeamDataDic[self.curTeam + 1].guns[i] == 0 then
        UIUtils.PopupHintMessage(903108)
        return
      end
    end
    self.mCurMapId = self.mData.MapId
    if SupplyHelper:CheckSupplyRepeated(self.TeamDataDic[self.curTeam + 1].guns) == true then
      self:EnterDarkZone()
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    if not pcall(function()
      DarkNetCmdStoreData.questCacheGroupId = 0
    end) then
      gfwarning("UIDarkZoneQuestInfoPanelItem位置缓存出现异常")
    end
    if self.mData == nil then
      self:SetAllModelWhite()
    end
    self.gunListItem:Hide()
    setactive(self.gunListItem.mTrans_Action, false)
    UIManager.JumpToMainPanel()
  end
end
function UIDarkZoneTeamPanelV2:AddEventListener()
  function self.roleDetailEventFunc(msg)
    self.isShowChrList = msg.Sender == false
    setactive(self.ui.mTrans_ChrList, self.isShowChrList)
  end
  MessageSys:AddListener(CS.GF2.Message.UIEvent.OnClickDetailEvent, self.roleDetailEventFunc)
end
function UIDarkZoneTeamPanelV2:GunItemProvider()
  local itemView = DarkZoneTeamItemV2.New()
  itemView:InitCtrl(self.gunListItem.GunList.content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  itemView:SetTable(self)
  return renderDataItem
end
function UIDarkZoneTeamPanelV2:GunItemRenderer(index, renderData)
  local data = self.showItemDataList[index + 1]
  local item = renderData.data
  item:SetData(data, index)
  item:SetIsSelect(self.CurGunId)
  local id = 0
  if self.curGunItem then
    id = self.curGunItem.mData.id
  end
  item:SetIsSelectTeamGun(id)
  item:SetClickFunction(function()
    self:RefreshCurGunDetail(item.mData.id, item.mIndex)
    self.gunListItem.GunList:Refresh()
  end)
  if self.IsDefaultChose == true and data.id == self.tempId then
    item:OnClickGunCard()
    self.IsDefaultChose = false
  end
end
function UIDarkZoneTeamPanelV2:ReFreshListByDutyID(dutyID)
  if self.sortList == nil then
    self.sortList = new_list(typeof(CS.GunCmdData))
  end
  self.sortList:Clear()
  for _, v in pairs(self.ItemDataList) do
    local tData = v.TabGunData
    if dutyID == 0 or tData.duty == dutyID then
      self.sortList:Add(v)
    end
  end
  self.comScreenItem:SetList(self.sortList)
  self.comScreenItem:DoFilter()
end
function UIDarkZoneTeamPanelV2:RefreshGunList()
  local count = #self.showItemDataList
  setactive(self.gunListItem.GunList, 0 < count)
  setactive(self.gunListItem.mTrans_ChrNone, count <= 0)
  setactive(self.gunListItem.mTrans_None, count <= 0)
  setactive(self.gunListItem.mTrans_Action, 0 < count)
  self:ClickCurGun()
  if 0 < count then
    if self.gunListItem.GunList.numItems == count then
      self.gunListItem.GunList:Refresh()
    else
      self.gunListItem.GunList.numItems = count
    end
  end
end
function UIDarkZoneTeamPanelV2:UpdateGunList()
  self:GunItemCancelSelect()
  self.gunListItem:SetDutyTabListActive(self.comScreenItem.FilterId == 0)
  self:SortGunResultList()
  self:RefreshGunList()
end
function UIDarkZoneTeamPanelV2:SortGunResultList()
  local tmpResultList = self.comScreenItem:GetResultList()
  self.showItemDataList = {}
  for i = 0, tmpResultList.Count - 1 do
    local d = tmpResultList[i]
    table.insert(self.showItemDataList, d)
  end
  local r = {}
  local r2 = {}
  for i, v in ipairs(self.showItemDataList) do
    local teamIndex = self:CheckInTeam(v.id)
    if teamIndex == nil then
      table.insert(r, v)
    else
      local t = {}
      t.index = teamIndex
      t.data = v
      table.insert(r2, t)
    end
  end
  table.sort(r2, function(a, b)
    return a.index < b.index
  end)
  for i = #r2, 1, -1 do
    local v = r2[i].data
    table.insert(r, 1, v)
  end
  self.showItemDataList = r
end
function UIDarkZoneTeamPanelV2:CheckInTeam(GunId)
  if self.TeamDataDic[self.curTeam + 1] == nil then
    return nil
  end
  local guns = self.TeamDataDic[self.curTeam + 1].guns
  for i = 0, guns.Count - 1 do
    if GunId == guns[i] then
      return i + 1
    end
  end
  return nil
end
function UIDarkZoneTeamPanelV2:UpdateTeamCamera()
  local TeamIndex = DarkNetCmdTeamData.CurTeamIndex
  local TeamData = self.TeamDataDic[TeamIndex + 1]
  if 0 < TeamData.guns[0] then
    local model = UIDarkZoneTeamModelManager:GetCaCheModel(TeamData.guns[0])
    self.DarkZoneTeamCameraCtrl:ChangeCameraStand(model.tableId, CS.DarkZoneTeamCameraPosType.TeamPanel, model.gameObject)
  end
end
function UIDarkZoneTeamPanelV2:UpdateModel(GunId, Index)
  local GunCmdData = NetCmdTeamData:GetGunByID(GunId)
  local TableData = GunCmdData.TabGunData
  local modelId = GunId
  local weaponModelId = GunCmdData.WeaponData ~= nil and GunCmdData.WeaponData.stc_id or TableData.weapon_default or TableData.weapon_default
  if UIDarkZoneTeamModelManager:IsCacheLoadedContains(modelId) >= 0 then
    local model = UIDarkZoneTeamModelManager:GetCaCheModel(modelId)
    model.Index = Index
    self.focusModel = model
    self:SetGunModel(model, Index)
    return
  end
  UIUtils.GetDarkZoneTeamUIModelAsyn(modelId, weaponModelId, Index, function(go)
    self:UpdateModelCallback(go, Index)
  end)
end
function UIDarkZoneTeamPanelV2:UpdateModelCallback(obj, index)
  self.focusModel = obj
  obj.transform.parent = nil
  if obj ~= nil and obj.gameObject ~= nil then
    self:SetGunModel(obj, index)
  end
end
function UIDarkZoneTeamPanelV2:GetDarkZoneUnitCameraDataByID(id)
  local data1 = TableData.listGunGlobalConfigDatas:GetDataById(id)
  local data2 = TableData.listDarkzoneUnitCameraDatas:GetDataById(data1.darkzone_unit_camera)
  return data2
end
function UIDarkZoneTeamPanelV2:SetGunModel(model, index)
  model:Show(true)
  local num = index + 1
  local str1 = string.format("unit_character_%d_position", num)
  local str2 = string.format("unit_character_%d_rotation", num)
  local data2 = self:GetDarkZoneUnitCameraDataByID(model.tableId)
  local positionList = data2[str1]
  local rotationList = data2[str2]
  local pos = Vector3(positionList[0], positionList[1], positionList[2])
  model.transform.localScale = Vector3.one
  model.transform.position = pos
  model.transform.localEulerAngles = Vector3(rotationList[0], rotationList[1], rotationList[2])
  GFUtils.MoveToLayer(model.transform, CS.UnityEngine.LayerMask.NameToLayer("Friend"))
  self.DarkZoneTeamCameraCtrl:UpdateMateriaList(model.gameObject, index)
  local isChange = self.isShowGunList and index + 1 == self.CurBtn
  if isChange then
    str1 = string.format("Position%d", num)
    self.DarkZoneTeamCameraCtrl:ChangeCameraStand(model.tableId, CS.DarkZoneTeamCameraPosType[str1], model.gameObject)
  end
  self.DarkZoneTeamCameraCtrl:SetBaseColorByBool(index, isChange == true)
  self.changeGunEffect.transform.position = pos
  setactive(self.changeGunEffect, false)
  setactive(self.changeGunEffect, true)
end
function UIDarkZoneTeamPanelV2:GoWar()
  if self.CurGunId == nil then
    UIUtils.PopupHintMessage(903011)
    return
  end
  if self:CheckGunIDHasInTeam(self.CurGunId) then
    UIUtils.PopupHintMessage(903136)
    return
  end
  local temp = self.TeamDataDic[self.curTeam + 1].guns
  local setleader
  for i = 0, temp.Count - 1 do
    if temp[i] ~= 0 then
      setleader = 1
    end
  end
  if setleader == nil then
    self.TeamDataDic[self.curTeam + 1].guns[0] = self.CurGunId
    self.TeamDataDic[self.curTeam + 1].Leader = self.CurGunId
  else
    local index = self:CheckInTeam(self.CurGunId)
    if index ~= nil then
      if self.TeamDataDic[self.curTeam + 1].Leader == self.TeamDataDic[self.curTeam + 1].guns[index - 1] then
        self.TeamDataDic[self.curTeam + 1].Leader = self.CurGunId
      end
      self.TeamDataDic[self.curTeam + 1].guns[index - 1] = 0
      self.TeamDataDic[self.curTeam + 1].guns[self.CurBtn - 1] = self.CurGunId
    else
      self.TeamDataDic[self.curTeam + 1].guns[self.CurBtn - 1] = self.CurGunId
    end
  end
  self.TeamDataDic[self.curTeam + 1].Leader = self.TeamDataDic[self.curTeam + 1].guns[0]
  self.hasChange = true
  self:UpdateTeamList(self.curTeam)
  if self.isShowChrList == false then
    self.roleDetailItem:OnClickOpenRoleDetail()
  end
  self:ShowCurTeamGunList()
  self:SortGunResultList()
  self:ClickCurGun()
  self.gunListItem.GunList:Refresh()
  UIUtils.PopupPositiveHintMessage(903012)
end
function UIDarkZoneTeamPanelV2:RePlace()
  if self.CurGunId == nil then
    UIUtils.PopupHintMessage(903011)
    return
  end
  if self.CurBtn == nil then
    UIUtils.PopupHintMessage(903011)
    return
  end
  local index = self:CheckInTeam(self.CurGunId)
  if index ~= nil then
    local temp = self.TeamDataDic[self.curTeam + 1].guns[self.CurBtn - 1]
    self.TeamDataDic[self.curTeam + 1].guns[self.CurBtn - 1] = self.CurGunId
    self.TeamDataDic[self.curTeam + 1].guns[index - 1] = temp
    self.TeamDataDic[self.curTeam + 1].Leader = self.TeamDataDic[self.curTeam + 1].guns[0]
  else
    if self:CheckGunIDHasInTeam(self.CurGunId) then
      UIUtils.PopupHintMessage(903136)
      return
    end
    self.TeamDataDic[self.curTeam + 1].guns[self.CurBtn - 1] = self.CurGunId
    self.TeamDataDic[self.curTeam + 1].Leader = self.TeamDataDic[self.curTeam + 1].guns[0]
  end
  self.hasChange = true
  self:UpdateTeamList(self.curTeam)
  if self.isShowChrList == false then
    self.roleDetailItem:OnClickOpenRoleDetail()
  end
  self:ShowCurTeamGunList()
  self:SortGunResultList()
  self:ClickCurGun()
  self.gunListItem.GunList:Refresh()
  UIUtils.PopupPositiveHintMessage(903013)
end
function UIDarkZoneTeamPanelV2:EnterDarkZone()
  local Ddata = DarkZoneTeamData(self.curTeam, self.TeamDataDic[self.curTeam + 1].guns, self.TeamDataDic[self.curTeam + 1].Leader)
  DarkNetCmdTeamData.Teams[self.curTeam].Leader = self.TeamDataDic[self.curTeam + 1].Leader
  DarkNetCmdTeamData:SetTeamInfo(Ddata, function()
    if self.mData and self.mData.enterExplore then
      CS.DzMatchUtils.RequireDarkMatchExplore()
    elseif self.mData and self.mData.enterType == 2 then
      local questId = TableData.listDarkzoneSystemEndlessRewardDatas:GetDataById(self.mData.QuestID).group
      DarkNetCmdStoreData.currentEndLessRewardID = self.mData.QuestID
      CS.DzMatchUtils.RequireDarkMatchEndless(questId, self.mData.MapId, self.mData.QuestID)
    elseif self.mData and self.mData.enterType == 1 then
      CS.DzMatchUtils.RequireDarkMatchQuest(self.mData.QuestID, self.mCurMapId, MapSelectUtils.currentQuestGroupID)
    else
      CS.DzMatchUtils.RequireDarkMatchDefault(self.mCurMapId)
    end
  end)
end
function UIDarkZoneTeamPanelV2:OnClickGunAvatarItem(item)
  if self.isShowGunList == false then
    self.gunListItem:Show(true)
    if self.mData ~= nil then
      setactive(self.ui.mBtn_Confirm, false)
    end
    self:ShowGunList()
  end
  self.isFocusModel = true
  self.isShowGunList = true
  self.CurGunId = nil
  if self.curGunItem then
    self.curGunItem.ui.mBtn_Self.interactable = true
  end
  self.curGunItem = item
  self.curGunItem.ui.mBtn_Self.interactable = false
  self.CurBtn = item.mIndex
  self.focusModel = UIDarkZoneTeamModelManager:GetCaCheModel(item.mData.stc_gun_id)
  if self.needChangeCameraPos == true then
    local str1 = string.format("Position%d", item.mIndex)
    self.DarkZoneTeamCameraCtrl:ChangeCameraStand(self.focusModel.tableId, CS.DarkZoneTeamCameraPosType[str1], self.focusModel.gameObject)
    self.DarkZoneTeamCameraCtrl.cameraBlendFinished:AddListener(function(c)
      self.DarkZoneTeamCameraCtrl:SetCharacterColor(item.mIndex - 1)
    end)
  end
  self:ClickCurGun()
  self.gunListItem.GunList:Refresh()
end
function UIDarkZoneTeamPanelV2:SetDarkenDoTween(startValue, endValue)
  if self.progressTween then
    LuaDOTweenUtils.Kill(self.progressTween, false)
    self.progressTween = nil
  end
  local getter = function(tempSelf)
    return tempSelf.darkenComponent.lerp
  end
  local setter = function(tempSelf, value)
    tempSelf.darkenComponent.lerp = value
  end
  self.progressTween = LuaDOTweenUtils.ToOfFloat(self, getter, setter, endValue, 0.7, nil)
end
function UIDarkZoneTeamPanelV2:SetAllModelWhite()
  self.DarkZoneTeamCameraCtrl:SetAllChapterHighLight()
  if self.roleDetailItem.m_RolePanelState ~= CS.RolePanelState.Info then
    self.roleDetailItem:OnClickOpenRoleDetail()
  end
  self.roleDetailItem:SetActive(false)
end
function UIDarkZoneTeamPanelV2:ClickCurGun()
  self:GunItemCancelSelect()
  local isSelect = false
  if self.curGunItem then
    for i = 1, #self.showItemDataList do
      local d = self.showItemDataList[i]
      if d.id == self.curGunItem.mData.id then
        isSelect = true
        self:RefreshCurGunDetail(self.curGunItem.mData.id)
      end
    end
  end
  if isSelect == false and #self.showItemDataList > 0 then
    self:RefreshCurGunDetail(self.showItemDataList[1].id)
  end
end
function UIDarkZoneTeamPanelV2:ExitChangeTeamMember()
  if self.isShowGunList == true then
    if self.curGunItem then
      self.curGunItem.ui.mBtn_Self.interactable = true
      self.curGunItem = nil
    end
    self.gunListItem:Hide()
    setactive(self.gunListItem.mTrans_Action, false)
    if self.mData ~= nil then
      setactive(self.ui.mBtn_Confirm, true)
    end
    self:UpdateTeamCamera()
  end
  if self.isShowChrList == false then
    self.isShowChrList = true
  end
  self:ShowCurTeamGunList()
  self:SetAllModelWhite()
  self.CurBtn = nil
  self.isShowGunList = false
end
function UIDarkZoneTeamPanelV2:RefreshCurGunDetail(gunID, itemIndex)
  self.CurGunId = gunID
  local isSameGun = false
  if self.curGunItem then
    isSameGun = self.curGunItem.mData.id == self.CurGunId
  end
  local canNotClick = self:CheckGunIDHasInTeam(gunID, true) or isSameGun
  setactive(self.gunListItem.mTrans_None, canNotClick)
  setactive(self.gunListItem.mTrans_Action, canNotClick == false)
  local showStr = ""
  if canNotClick then
    showStr = TableData.GetHintById(903136)
  elseif isSameGun then
    showStr = TableData.GetHintById(903136)
  end
  self.gunListItem.mTxt_Tips.text = showStr
  local cmdData = NetCmdTeamData:GetGunByID(gunID)
  self.roleDetailItem:SetRoleDetailDataByGunCmdData(cmdData)
  self.roleDetailItem:SetActive(true)
end
function UIDarkZoneTeamPanelV2:GunItemCancelSelect()
  self.CurGunId = nil
  setactive(self.gunListItem.mTrans_None, true)
  setactive(self.gunListItem.mTrans_Action, false)
  self.gunListItem.mTxt_Tips.text = TableData.GetHintById(80086)
  self.gunListItem.GunList:Refresh()
end
function UIDarkZoneTeamPanelV2:CheckGunIDHasInTeam(gunID, needExceptID)
  local exceptID = -1
  if needExceptID then
    exceptID = self.tempId
  end
  local twoCharId = TableData.listGunDatas:GetDataById(gunID).character_id
  for i = 0, DarkNetCmdTeamData.QuicklyTeamList.Count - 1 do
    local gunId = DarkNetCmdTeamData.QuicklyTeamList[i]
    if gunId ~= 0 and gunId ~= exceptID then
      local charId = TableData.listGunDatas:GetDataById(gunId).character_id
      if charId == twoCharId and DarkNetCmdTeamData.QuicklyTeamList[i] ~= gunID then
        return true
      end
    end
  end
  return false
end
