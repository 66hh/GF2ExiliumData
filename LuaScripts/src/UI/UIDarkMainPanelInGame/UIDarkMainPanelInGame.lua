require("UI.DarkZonePanel.UIDarkZoneNPCSelectPanel.UIDarkZoneStorePanel.DZStoreUtils")
require("UI.UIDarkMainPanelInGame.UIDarkMainPanelInGameView")
require("UI.UIBasePanel")
require("UI.UIDarkMainPanelInGame.DarkMainPanelInGameChrListItem")
require("UI.UIDarkMainPanelInGame.VigilantDesItem")
require("UI.UIDarkMainPanelInGame.DarkMainPanelInGameSlotItem")
require("UI.UIDarkMainPanelInGame.DarkMainPanelInGameBuffItem")
require("UI.UIDarkMainPanelInGame.EnergyDetailItem")
require("UI.UIDarkMainPanelInGame.DarkMainPanelInGameChrNameItem")
require("UI.UIDarkMainPanelInGame.DarkGetItem")
require("UI.UIDarkMainPanelInGame.DarkTargetAvatar")
require("UI.UIDarkMainPanelInGame.DarkzoneInteractiveItem")
require("UI.UIDarkMainPanelInGame.DarkzoneInteractiveTipsItem")
require("UI.UIDarkMainPanelInGame.DarkzoneGrassWarningTipsItem")
require("UI.UIDarkMainPanelInGame.AttackBenefitInfoItem")
require("UI.UIDarkMainPanelInGame.DarkZoneGlobalEventItem")
require("UI.UIDarkMainPanelInGame.UIDarkZoneRoomQuestItem")
require("UI.UIDarkMainPanelInGame.UIDarkBubbleMsgCtrl")
require("UI.UIDarkMainPanelInGame.DarkzoneAirValueDialog")
local EnumDarkzoneProperty = require("UI.UIDarkMainPanelInGame.DarkzoneProperty")
local DzTypeEnum = {
  DzDefault = 0,
  DzQuest = 1,
  DzInfinity = 2,
  DzExplore = 3
}
local DzBtnFunEnum = {
  None = 0,
  BigMap = 1,
  Setting = 2,
  Guide = 3,
  Wish = 4,
  Bag = 5,
  BuffDetail = 6,
  Pick = 7
}
local DzWindowEnum = {
  None = 0,
  GlobalVigilant = 1,
  GlobalEvent = 2,
  AirDetail = 3,
  EnergyDetail = 4
}
UIDarkMainPanelInGame = class("UIDarkMainPanelInGame", UIBasePanel)
UIDarkMainPanelInGame.__index = UIDarkMainPanelInGame
local self = UIDarkMainPanelInGame
function UIDarkMainPanelInGame:ctor(csPanel)
  UIDarkMainPanelInGame.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
  csPanel.Is3DPanel = true
end
function UIDarkMainPanelInGame:OnCameraStart()
  return 0.01
end
function UIDarkMainPanelInGame:OnShowFinish()
  self:UpdateHeadIcon()
end
function UIDarkMainPanelInGame:OnHide()
end
function UIDarkMainPanelInGame:OnInit(root, data)
  UIDarkMainPanelInGame.super.SetRoot(UIDarkMainPanelInGame, root)
  self:InitBaseData(root, data)
  self:InitUI(data)
  self:AddBtnListen()
  self:AddMsgListener()
  local needShowBtn = self.dzType == DzTypeEnum.DzInfinity
  if needShowBtn then
    local endlessData = TableData.listDarkzoneSystemEndlessDatas:GetDataById(self.questId)
    needShowBtn = endlessData.wish
  end
  setactive(self.ui.mBtn_Wish.transform.parent, needShowBtn)
  MessageSys:SendMessage(CS.GF2.Message.DarkMsg.MainPanelStart, self.mUIRoot.gameObject)
end
function UIDarkMainPanelInGame:InitBaseData(root, data)
  self.mview = UIDarkMainPanelInGameView.New()
  self.ui = {}
  self.mview:InitCtrl(root, self.ui)
  self.NameLs = {}
  self.roleViewLs = {}
  self.slotViewLs = {}
  self.BuffViewLs = {}
  self.BuffBusyDic = {}
  self.BuffFreeLs = {}
  self.greenColor = CS.GF2.UI.UITool.StringToColor("3AE134")
  self.targetAvatarLs = {}
  self.AttackBenefitInfoItemLs = {}
  DZStoreUtils.selectQuestGroupId = nil
  DZStoreUtils.selectQuestTargetId = nil
  self.questItemList = {}
  self.changeCountdownColor = true
  self.BagMgr = CS.SysMgr.dzPlayerMgr.MainPlayer.DarkPlayerBag
  self.mapMgr = CS.SysMgr.dzMiniMapDataMgr
  self.mTran_BoxBool = false
  self.GoodsDataList = nil
  self.GetItemTbl = {}
  self.EnergyUI = {}
  self.EventUI = {}
  self.EventUI.EventDesUILS = {}
  self.curShowGlobalEvent = nil
  self.VigilantUI = {}
  self.VigilantUI.DesItemLs = {}
  self.InteractiveLsUI = {}
  self.InteractiveFreeLs = {}
  self.AimUI = {}
  self.ui.InteractiveProgressUI = {}
  self.ui.AirUI = {}
  self.ui.ExploreUI = {}
  self.ui.MiniMapUI = {}
  self:LuaUIBindTable(self.ui.mBind_Energy.gameObject, self.EnergyUI)
  self:LuaUIBindTable(self.ui.mBind_Event.gameObject, self.EventUI)
  self:LuaUIBindTable(self.ui.mBind_Vigilant.gameObject, self.VigilantUI)
  self:LuaUIBindTable(self.ui.mBind_AimUI.gameObject, self.AimUI)
  self:LuaUIBindTable(self.ui.mTran_InteractiveRoot.gameObject, self.ui.InteractiveProgressUI)
  self:LuaUIBindTable(self.ui.mBind_Air.gameObject, self.ui.AirUI)
  self:LuaUIBindTable(self.ui.mBind_Explore.gameObject, self.ui.ExploreUI)
  self:LuaUIBindTable(self.ui.mBind_MiniMap.gameObject, self.ui.MiniMapUI)
  self.interactiveObjs = {}
  self.grassWarningObj = {}
  self.playerReceiveInputComp = CS.SysMgr.dzPlayerMgr.MainPlayer.receiveInputComp
  self.questId = data.questId
  self.dzType = data.dzType.value__
  if self.dzType == DzTypeEnum.DzExplore then
    self.exploreIndex = CS.SysMgr.dzMatchGameMgr.exploreMapIndex
    self.beaconNumMax = CS.SysMgr.dzUIControlMgr.beaconNumMax
  end
  self.window2GameObject = {}
  self.window2GameObject[DzWindowEnum.GlobalVigilant] = self.VigilantUI.mTran_VigilantDes.gameObject
  self.window2GameObject[DzWindowEnum.GlobalEvent] = self.EventUI.mTran_EventDes.gameObject
  self.window2GameObject[DzWindowEnum.AirDetail] = self.ui.AirUI.mTran_ItemRoot.gameObject
  self.window2GameObject[DzWindowEnum.EnergyDetail] = self.EnergyUI.mTran_DesRoot.gameObject
  self.showWindow = DzWindowEnum.None
  self.openPickPanel = false
  self.Darkzone_BunkerIn = IconUtils.GetDarkzoneBtnIcon("Icon_Darkzone_BunkerIn")
  self.Darkzone_BunkerOut = IconUtils.GetDarkzoneBtnIcon("Icon_Darkzone_BunkerOut")
end
function UIDarkMainPanelInGame:InitUI(data)
  self.ui.mAni_CoverState = self.ui.mBtn_CoverState:GetComponent(typeof(CS.UnityEngine.Animator))
  self.ui.mAin_Aim = self.ui.mBtn_Aim:GetComponent(typeof(CS.UnityEngine.Animator))
  setactive(self.ui.mBtn_CoverChange.transform.parent.gameObject, false)
  self.ui.mText_BagNumMain.text = self.BagMgr:ItemNumInBag() .. "/" .. CS.SysMgr.dzPlayerMgr.MainPlayer.Chequer:ToString()
  self:InitRoleList()
  self:SetRoleList()
  self:InitSlotList()
  self:MainPlayerInitBuffIcon()
  self:SetBuffLsView(CS.SysMgr.dzPlayerMgr.MainPlayerData.PlayerShowHelper.ShowBuffLs)
  self:InitEnergyDetail(data.mapId)
  CS.LuaUIUtils.GetUIPCKey(self.ui.mKey_PcAim).text = TableData.listHintDatas:GetDataById(903303).Chars.str
  CS.LuaUIUtils.GetUIPCKeyInChildren(self.ui.mBtn_CoverState.transform).text = TableData.listHintDatas:GetDataById(903305).Chars.str
  CS.LuaUIUtils.GetUIPCKeyInChildren(self.ui.mBtn_CoverChange.transform).text = TableData.listHintDatas:GetDataById(903310).Chars.str
  self.mapMgr:OnInit(self.mUIRoot)
  setactive(self.ui.mBtn_Quest.transform.parent, self.dzType == DzTypeEnum.DzExplore)
  self.ui.mTran_Box.gameObject:SetActive(false)
  local HUDNameplateAsset = ResSys:GetCombatUIRes("HUDNameplate.prefab", false)
  local HUDNameplateObj = instantiate(HUDNameplateAsset.gameObject, self.ui.mTran_NameRoot.transform, false)
  self.ui.mTran_Nameplate = HUDNameplateObj.gameObject:GetComponent(typeof(CS.UnityEngine.RectTransform))
  self.ui.self_mComp_Nameplate_Follow = nil
  self.ui.mComp_Nameplate = self.ui.mTran_Nameplate.gameObject:GetComponent(typeof(CS.Nameplate))
  self.ui.mAniTime_Nameplate = self.ui.mTran_Nameplate.gameObject:GetComponent(typeof(CS.AniTime))
  self.ui.mAni_Nameplate = self.ui.mTran_Nameplate.gameObject:GetComponent(typeof(CS.UnityEngine.Animator))
  setactive(self.ui.mTran_Nameplate.gameObject, true)
  ResourceManager:UnloadAssetFromLua(HUDNameplateAsset)
  HUDNameplateAsset = nil
  setactive(self.ui.mBtn_Aim.gameObject, false)
  setactive(self.ui.mBtn_CoverState.transform.parent.gameObject, false)
  setactive(self.ui.mBind_Explore.gameObject, CS.SysMgr.dzMatchGameMgr.UnlockBeacon)
  setactive(self.ui.mBind_Air.gameObject, self.dzType == DzTypeEnum.DzInfinity)
  self.roomQuestItem = UIDarkZoneRoomQuestItem.New(self.ui.mTrans_Extra)
  UIUtils.GetButtonListener(self.roomQuestItem.ui.mBtn_Extra.gameObject).onClick = function()
    if self.playerReceiveInputComp:UIClick(CS.DarkUnitWorld.UIClickType.OpenQuest) then
      UIManager.OpenUI(UIDef.UIDarkZoneTaskPanelInGame)
    end
  end
  self:InitQuest()
  if self.dzType == DzTypeEnum.DzQuest then
    DarkNetCmdStoreData.currentTaskID = CS.SysMgr.dzMatchGameMgr.questId
  elseif self.dzType == DzTypeEnum.DzInfinity then
  elseif self.dzType == DzTypeEnum.DzExplore then
    self:InitExplore()
  end
  local bubbleMsgTemplate = self.ui.mScrollChild_BubbleMsgRoot.childItem
  local bubbleMsgRoot = instantiate(bubbleMsgTemplate, self.ui.mScrollChild_BubbleMsgRoot.transform)
  self.bubbleMsgCtrl = UIDarkBubbleMsgCtrl.New()
  self.bubbleMsgCtrl:SetRoot(bubbleMsgRoot)
  setactivewithcheck(self.ui.mScrollChild_BubbleMsgRoot.transform, true)
  setactivewithcheck(bubbleMsgRoot, false)
end
function UIDarkMainPanelInGame:InitRoleList()
  local roleTable = CS.SysMgr.dzPlayerMgr.MainPlayerData.nowPropertyDataLs
  for i = 0, roleTable.Count - 1 do
    local roleView = DarkMainPanelInGameChrListItem.New()
    roleView:InitCtrl(self.ui.mTran_CharacterRoot, self)
    local index = i + 1
    self.roleViewLs[index] = roleView
  end
end
function UIDarkMainPanelInGame:InitSlotList()
  local slots = {
    EnumDarkzoneProperty.Property.DzFirePropCurrentVal,
    EnumDarkzoneProperty.Property.DzWaterPropCurrentVal,
    EnumDarkzoneProperty.Property.DzPoisonPropCurrentVal,
    EnumDarkzoneProperty.Property.DzIcePropCurrentVal,
    EnumDarkzoneProperty.Property.DzElectricPropCurrentVal
  }
  for i = 1, #slots do
    local slotView = DarkMainPanelInGameSlotItem.New()
    local keySlot = slots[i]
    slotView:InitCtrl(self.ui.mTran_SlotRoot, keySlot)
    self.slotViewLs[keySlot] = slotView
  end
end
function UIDarkMainPanelInGame:MainPlayerInitBuffIcon()
  for i = 1, CS.DarkUnitWorld.DarkPlayerData.showBuffMax do
    local buffView = DarkMainPanelInGameBuffItem.New()
    buffView:InitCtrl(self.ui.mScroll_BuffRoot)
    local index = #self.BuffViewLs + 1
    self.BuffViewLs[index] = buffView
    self.BuffFreeLs[index] = buffView
  end
end
function UIDarkMainPanelInGame:InitEnergyDetail(mapId)
  local show = CS.DarkUnitWorld.DarkTool.IsShowEnergyUI(mapId)
  setactive(self.EnergyUI.mUIRoot.gameObject, show)
  self.EnergyUI.mText_DesTitle.text = TableData.GetHintById(903483)
  self.EnergyUI.mText_DesDetail.text = TableData.GetHintById(903484)
  self.EnergyUI.EnergyItemLs = {}
  local energyIds = {1103}
  local count = #energyIds
  for i = 1, count do
    local energyDetailItem = EnergyDetailItem.New()
    energyDetailItem:InitCtrl(self.EnergyUI.mTran_DesItemRoot, energyIds[i], i == count)
    self.EnergyUI.EnergyItemLs[energyIds[i]] = energyDetailItem
  end
end
function UIDarkMainPanelInGame:InitAirDetail(cur)
  if cur == nil then
    cur = CS.SysMgr.dzPlayerMgr.MainPlayer:GetProperty(EnumDarkzoneProperty.Property.DzOxygen)
  end
  self:SetAirDetail(cur)
end
function UIDarkMainPanelInGame:SetAirDetail(cur)
  if self.oxygenGameplayId == nil then
    return
  end
  local max = self.airMax
  local preAir = 0
  if self.ui.AirUI.curAir ~= nil then
    preAir = self.ui.AirUI.curAir
  end
  if cur > preAir and preAir ~= 0 then
    local addValue = cur - preAir
    self.ui.AirUI.mText_AirAdd.text = "+" .. addValue
    setactive(self.ui.AirUI.mAni_Full.gameObject, true)
    self.ui.AirUI.mAni_Full:Play()
    if self.delayAirFadeOut ~= nil then
      self.delayAirFadeOut:Stop()
    end
    self.delayAirFadeOut = TimerSys:DelayCall(1, function()
      setactive(self.ui.AirUI.mAni_Full.gameObject, false)
      self.delayAirFadeOut = nil
    end)
  end
  self.ui.AirUI.mText_AirValue.text = cur .. "/" .. max
  self.ui.AirUI.mComp_Fill.FillAmount = cur / max
  self.ui.AirUI.curAir = cur
  local index = 0
  for i = 1, #self.segmentAirLs do
    if cur <= self.segmentAirLs[i] then
      index = i
      break
    end
  end
  if self.ui.AirUI.curValueIndex ~= nil and index < self.ui.AirUI.curValueIndex then
    local showData = {}
    showData[0] = 2
    showData[1] = 903487
    local uiCommand = CS.DarkUnitWorld.MainTipsDialogPerform(CS.DarkUnitWorld.MainTipsDialogType.UnlockNew, showData)
    CS.SysMgr.dzPerformMgr:PushNode(CS.DarkUnitWorld.DzPerformType.DzMainTipsDialog, uiCommand)
  end
  self.ui.AirUI.curValueIndex = index
  if cur <= self.airSegmentRed then
    self.ui.AirUI.mImg_AirBar.color = self.airSegmentRedColor
    self.ui.AirUI.mImg_AirBarBg.color = self.airSegmentRedColor
  elseif cur > self.airSegmentBlue then
    self.ui.AirUI.mImg_AirBar.color = self.airSegmentBlueColor
    self.ui.AirUI.mImg_AirBarBg.color = self.airSegmentBlueColor
  else
    self.ui.AirUI.mImg_AirBar.color = self.airSegmentYellowColor
    self.ui.AirUI.mImg_AirBarBg.color = self.airSegmentYellowColor
  end
end
function UIDarkMainPanelInGame:InitExplore()
  self.ui.ExploreUI.mCom_Effect:SetSignalIntensity(0)
  local cur = CS.SysMgr.dzPlayerMgr.MainPlayerData.BeaconNum
  if CS.SysMgr.dzUIControlMgr:IsBeaconComplete(cur) then
    setactive(self.ui.mBind_Explore.gameObject, false)
  end
  self:SetExploreProgress(cur)
end
function UIDarkMainPanelInGame:SetExploreProgress(cur)
  if self.dzType ~= DzTypeEnum.DzExplore then
    return
  end
  self.ui.ExploreUI.mText_ExploreProgress.text = cur .. "/" .. self.beaconNumMax
end
function UIDarkMainPanelInGame:InitMiniMapDetail()
  setactive(self.ui.MiniMapUI.mTran_ExploreNumRoot.gameObject, false)
  if self.dzType == DzTypeEnum.DzExplore then
    local exploreData = TableData.listDzExploreModeDatas:GetDataById(self.questId)
    setactive(self.ui.MiniMapUI.mTran_ExploreNumRoot.gameObject, exploreData.is_noob ~= 1)
  end
  self.ui.MiniMapUI.mAin_Map1.keepAnimatorControllerStateOnDisable = true
  self.ui.MiniMapUI.mAin_Map2.keepAnimatorControllerStateOnDisable = true
  self.ui.MiniMapUI.mAin_Map3.keepAnimatorControllerStateOnDisable = true
  self.ui.MiniMapUI.mAin_Map1:SetBool("Bool", self.exploreIndex == 0)
  self.ui.MiniMapUI.mAin_Map2:SetBool("Bool", self.exploreIndex == 1)
  self.ui.MiniMapUI.mAin_Map3:SetBool("Bool", self.exploreIndex == 2)
end
function UIDarkMainPanelInGame:InitQuest()
  local hasTask = CS.SysMgr.dzMatchGameMgr.questId > 0
  local hasSceneID = 0 < CS.SysMgr.dzMatchGameMgr.selectSceneId
  local hasEndlessDataId = 0 < CS.SysMgr.dzMatchGameMgr.endlessDataId
  if self.dzType == DzTypeEnum.DzQuest then
    if hasTask then
      local questData = TableData.listDarkzoneSystemQuestDatas:GetDataById(CS.SysMgr.dzMatchGameMgr.questId)
      DarkNetCmdStoreData.currentMapID = questData.quest_struct_scene_id
    end
  elseif self.dzType == DzTypeEnum.DzInfinity then
    if hasEndlessDataId then
      local dataId = CS.SysMgr.dzMatchGameMgr.endlessDataId
      local tbData = TableData.listDarkzoneSystemEndlessDatas:GetDataById(dataId)
      DarkNetCmdStoreData.currentMapID = tbData.map
    end
  elseif self.dzType == DzTypeEnum.DzExplore and hasSceneID then
    DarkNetCmdStoreData.currentMapID = CS.SysMgr.dzMatchGameMgr.selectSceneId
  end
  if hasTask then
    local targetGroup = TableData.listDarkzoneMapV2Datas:GetDataById(DarkNetCmdStoreData.currentMapID).target_group_id
    local item = {}
    local com = self.ui.mTrans_StepList:GetComponent(typeof(CS.ScrollListChild))
    local obj = instantiate(com.childItem, self.ui.mTrans_StepList)
    item.mUIRoot = obj.transform
    item.mText_Target = item.mUIRoot:Find("Root/Text_Target"):GetComponent(typeof(CS.UnityEngine.UI.Text))
    item.mBtn_Self = item.mUIRoot:Find("Root"):GetComponent(typeof(CS.UnityEngine.UI.GFButton))
    item.curTargetID = nil
    item.mAnimator_Self = item.mUIRoot:Find("Root"):GetComponent(typeof(CS.UnityEngine.Animator))
    item.mAnimator_Self.keepAnimatorControllerStateOnDisable = true
    function item.RefreshQuest()
      local needCheck = true
      item.hasData = false
      for i = 0, targetGroup.Count - 1 do
        if needCheck == false then
          break
        end
        local num = targetGroup[i]
        local data = TableData.listDarkzoneQuestTargetGroupDatas:GetDataById(num)
        for i = 0, data.target_list.Count - 1 do
          local id = data.target_list[i]
          if DarkNetCmdStoreData:CheckQuestIsFinishByID(1, num, id) == false and (item.curTargetID == nil or item.curTargetID ~= id) then
            item.mText_Target.text = data.target_group_desc.str
            item.curTargetID = id
            needCheck = false
            break
          end
        end
      end
    end
    item.mBtn_Self.gameObject:GetComponent(typeof(CS.UnityEngine.UI.GFButton)).onClick:AddListener(self.OnClickMapBtn)
    self.questItemList[1] = item
    self.questItemList[1].mAnimator_Self:SetInteger("Switch", 0)
    self.questItemList[1].RefreshQuest()
  end
end
function UIDarkMainPanelInGame:AddBtnListen()
  self.ui.mBtn_Map.onClick:AddListener(self.OnClickMapBtn)
  self:RegistrationKeyboard(KeyCode.M, self.ui.mBtn_Map)
  self.ui.mBtn_Back.onClick:AddListener(self.OnClickSettingBtn)
  self.ui.mBtn_Guide.onClick:AddListener(self.OnGuideBtn)
  self.ui.mBtn_Wish.onClick:AddListener(self.OnClickWishBtn)
  self.ui.mBtn_Package.onClick:AddListener(self.OnClickPackageBtn)
  self:RegistrationKeyboard(KeyCode.B, self.ui.mBtn_Package)
  self.ui.mScroll_BuffRoot:GetComponent(typeof(CS.UnityEngine.UI.GFButton)).onClick:AddListener(self.OnClickBuffBtn)
  self.ui.mBtn_Quest.onClick:AddListener(self.OnClickDoubleCheckBtn)
  self.EventUI.mBtn_Event.onClick:AddListener(self.OnClickGlobalEventBtn)
  self.EventUI.mBtn_EventClose.onClick:AddListener(self.OnClickGlobalEventBtn)
  self.ui.AirUI.mBtn_Air.onClick:AddListener(self.OnClickAirBtn)
  self.VigilantUI.mBtn_Vigilant.onClick:AddListener(self.OnClickVigilantBtn)
  self.VigilantUI.mBtn_VigilantClose.onClick:AddListener(self.OnClickVigilantBtn)
  self.EnergyUI.mBtn_Energy.onClick:AddListener(self.OnClickEnergyBtn)
  self.EnergyUI.mBtn_EnergyClose.onClick:AddListener(self.OnClickEnergyBtn)
  self:RegistrationKeyboard(KeyCode.Alpha1, self.roleViewLs[1].ui.mBtn_Change)
  self:RegistrationKeyboard(KeyCode.Alpha2, self.roleViewLs[2].ui.mBtn_Change)
  self:RegistrationKeyboard(KeyCode.Alpha3, self.roleViewLs[3].ui.mBtn_Change)
  self:RegistrationKeyboard(KeyCode.Alpha4, self.roleViewLs[4].ui.mBtn_Change)
  self.ui.mBtn_CoverState.onClick:AddListener(self.OnClickCoverBtn)
  self.ui.mBtn_Aim.onClick:AddListener(self.OnClickAimBtn)
  self.AimUI.mBtn_BtnCancelAim.onClick:AddListener(self.OnClickCancelAimBtn)
  self.AimUI.mBtn_BtnConfirmAttack.onClick:AddListener(self.OnClickAttackBtn)
  self.AimUI.mBtn_BtnLeft.onClick:AddListener(self.OnClickLeftTargetBtn)
  self.AimUI.mBtn_BtnRight.onClick:AddListener(self.OnClickRightTargetBtn)
end
function UIDarkMainPanelInGame.OnClickMapBtn()
  if self.playerReceiveInputComp:UIClick(CS.DarkUnitWorld.UIClickType.OpenQuest) then
    self:ShowWindow(DzWindowEnum.None)
    UIManager.OpenUI(UIDef.UIDarkZoneTaskPanelInGame)
  end
end
function UIDarkMainPanelInGame.OnClickSettingBtn()
  if self.playerReceiveInputComp:UIClick(CS.DarkUnitWorld.UIClickType.OpenSetting) then
    self:ShowWindow(DzWindowEnum.None)
    CS.SysMgr.dzUIControlMgr:MainPanelOpenSetting()
  end
end
function UIDarkMainPanelInGame.OnGuideBtn()
  if self.playerReceiveInputComp:UIClick(CS.DarkUnitWorld.UIClickType.OpenGuide) then
    self:ShowWindow(DzWindowEnum.None)
    local param = {
      TableDataBase.GlobalDarkzoneData.DarkzoneSLGStageId,
      nil
    }
    UIManager.OpenUIByParam(UIDef.UIGuideWindows, param)
  end
end
function UIDarkMainPanelInGame.OnClickWishBtn()
  self:ShowWindow(DzWindowEnum.None)
  local t = {}
  t[0] = self.questId
  t[1] = false
  t[2] = false
  t[3] = false
  t[4] = true
  t[5] = {}
  t[6] = DarkNetCmdStoreData.currentEndLessRewardID
  local list = DarkNetCmdStoreData.mWishItemList
  for i = 0, list.Length - 1 do
    table.insert(t[5], list[i])
  end
  UIManager.OpenUIByParam(UIDef.UIDarkZoneWishDialog, t)
end
function UIDarkMainPanelInGame.OnClickPackageBtn()
  if self.playerReceiveInputComp:UIClick(CS.DarkUnitWorld.UIClickType.OpenPackage) then
    self:ShowWindow(DzWindowEnum.None)
    UIManager.OpenUI(UIDef.UIDarkBagPanel)
  end
end
function UIDarkMainPanelInGame.OnClickBuffBtn()
  self:ShowWindow(DzWindowEnum.None)
  UIManager.OpenUIByParam(UIDef.DarkzoneBuffDialog, CS.SysMgr.dzPlayerMgr.MainPlayerData.GunsId)
end
function UIDarkMainPanelInGame.OnClickDoubleCheckBtn()
  self:ShowWindow(DzWindowEnum.None)
  local hint
  local allBagGoodsDict = CS.SysMgr.dzPlayerMgr.MainPlayer.DarkPlayerBag:GetAllGoods()
  local allBagGoods = {}
  for i = 0, allBagGoodsDict.Count - 1 do
    local d = allBagGoodsDict[i]
    local t = {}
    t.itemId = d.itemID
    t.itemNum = d.num
    table.insert(allBagGoods, t)
  end
  table.sort(allBagGoods, function(a, b)
    local data1 = TableData.GetItemData(a.itemId)
    local data2 = TableData.GetItemData(b.itemId)
    if data1.rank == data2.rank then
      if data1.type == data2.type then
        return data1.id < data2.id
      end
      return data1.type > data2.type
    end
    return data1.rank > data2.rank
  end)
  local confirmFunc = function()
    CS.PbProxyMgr.dzMatchProxy:SendExitCS_DarkZoneOp()
  end
  local cancelFunc
  if 0 < #allBagGoods then
    hint = TableData.GetHintById(903534)
    function cancelFunc()
      UIManager.CloseUI(UIDef.UIComDoubleCheckDialog)
    end
    local param = {
      title = TableData.GetHintById(903533),
      contentText = hint,
      customData = allBagGoods,
      isDouble = true,
      dialogType = 4,
      confirmCallback = confirmFunc,
      cancelCallback = cancelFunc
    }
    UIManager.OpenUIByParam(UIDef.UIComDoubleCheckDialog, param)
  else
    hint = TableData.GetHintById(240126)
    function cancelFunc()
      UIManager.CloseUI(UIDef.MessageBoxPanel)
    end
    local content = MessageContent.New(hint, MessageContent.MessageType.DoubleBtn, confirmFunc, cancelFunc)
    MessageBoxPanel.Show(content)
  end
end
function UIDarkMainPanelInGame.OnClickGlobalEventBtn()
  self:ShowWindow(DzWindowEnum.GlobalEvent)
end
function UIDarkMainPanelInGame.OnClickAirBtn()
  if self.ui.AirUI.Detail == nil then
    self.ui.AirUI.Detail = DarkzoneAirValueDialog.New()
    self.ui.AirUI.Detail:InitCtrl(self.ui.AirUI.mTran_ItemRoot.gameObject)
    local airData = {
      self.oxygenGameplayId,
      self.airMax
    }
    self.ui.AirUI.Detail:SetData(airData, function()
      self:ShowWindow(DzWindowEnum.AirDetail)
    end)
  end
  self:ShowWindow(DzWindowEnum.AirDetail)
end
function UIDarkMainPanelInGame.OnClickVigilantBtn()
  self:ShowWindow(DzWindowEnum.GlobalVigilant)
end
function UIDarkMainPanelInGame.OnClickEnergyBtn()
  self:ShowWindow(DzWindowEnum.EnergyDetail)
end
function UIDarkMainPanelInGame.OnClickCoverBtn()
  self:ShowWindow(DzWindowEnum.None)
  self.playerReceiveInputComp:UIClick(CS.DarkUnitWorld.UIClickType.UnderCoverDoOrNot)
end
function UIDarkMainPanelInGame.OnClickAimBtn()
  self:ShowWindow(DzWindowEnum.None)
  self.playerReceiveInputComp:UIClick(CS.DarkUnitWorld.UIClickType.OpenAim)
end
function UIDarkMainPanelInGame.OnClickCancelAimBtn()
  self.playerReceiveInputComp:UIClick(CS.DarkUnitWorld.UIClickType.CloseAim)
end
function UIDarkMainPanelInGame.OnClickAttackBtn()
  self.playerReceiveInputComp:UIClick(CS.DarkUnitWorld.UIClickType.AttackTarget)
end
function UIDarkMainPanelInGame.OnClickLeftTargetBtn()
  self.playerReceiveInputComp:UIClick(CS.DarkUnitWorld.UIClickType.ChangeAttackTargetLeft)
end
function UIDarkMainPanelInGame.OnClickRightTargetBtn()
  self.playerReceiveInputComp:UIClick(CS.DarkUnitWorld.UIClickType.ChangeAttackTargetRight)
end
function UIDarkMainPanelInGame:ShowWindow(type)
  if type == DzWindowEnum.None and self.showWindow == DzWindowEnum.None then
    return
  end
  if type == self.showWindow then
    setactive(self.window2GameObject[type], false)
    self.showWindow = DzWindowEnum.None
  else
    if type ~= DzWindowEnum.None then
      setactive(self.window2GameObject[type], true)
    end
    if self.showWindow ~= DzWindowEnum.None then
      setactive(self.window2GameObject[self.showWindow], false)
    end
    self.showWindow = type
  end
end
function UIDarkMainPanelInGame:AddMsgListener()
  MessageSys:AddListener(CS.GF2.Message.SystemEvent.NetDelayTime, self.UpdateNetDelayTime)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.HideOrShowMirror, self.HideOrShowMirror)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.UpdateBox, self.UpdateBox)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.ClosePickPanel, self.ClosePickPanel)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.INeedNameTip, self.INeedNameTip)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.AllNameTipChangeActive, self.AllNameTipChangeActive)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.IDontNeedNameTip, self.IDontNeedNameTip)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.MainPlayerChangeInvencible, self.MainPlayerChangeInvencible)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.MainPlayerRefreshInvencible, self.MainPlayerRefreshInvencible)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.DarkGameEnd, self.DarkGameEnd)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.ChangeLeader, self.ChangeLeader)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.EnterPrepareBattle, self.EnterPrepareBattle)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.ExitPrepareBattle, self.ExitPrepareBattle)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.CanUnderCover, self.CanUnderCover)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.UnderStateChange, self.UnderStateChange)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.ChangeUnderBtnInteractable, self.ChangeUnderBtnInteractable)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.DarkGetItem, self.AddGetItem)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.PlayerVisible, self.SetChrNameVisible)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.MainPlayerEnterGrass, self.MainPlayerEnterGrass)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.MainPlayerExitGrass, self.MainPlayerExitGrass)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.OnLateUpdate, self.OnLateUpdate)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.RefreshDarkzoneProperty, self.UpdateBagBearing)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.ChangeBagCurrentNum, self.ShowBagNum)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.AddAttackTarget, self.AddAttackTarget)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.RemoveAttackTatget, self.RemoveAttackTatget)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.ChangeAttackTatget, self.ChangeAttackTatget)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.CloseUIDzWindows, self.CloseUIDzWindows)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.GoToDarkSLGView, self.GoToDarkSLGView)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.MainPlayerBuffChange, self.MainPlayerBuffChange)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.ShowInteractiveProgress, self.ShowInteractiveProgress)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.RefreshInteractiveProgress, self.RefreshInteractiveProgress)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.ShowInteractiveButton, self.ShowInteractiveButton)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.HideInteractiveButton, self.HideInteractiveButton)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.VigilantChange, self.VigilantChange)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.PlayVigilantLevelAnimation, self.PlayVigilantLevelAnimation)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.RefreshInteractive, self.RefreshInteractive)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.RefreshGlobalEvent, self.RefreshGlobalEvent)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.DzAttackEnterBattle, self.DzAttackEnterBattle)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.MonsterReduceProperty, self.MonsterReduceProperty)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.ChangeSlotUIActive, self.ChangeSlotUIActive)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.RefreshSlotUIProgress, self.RefreshSlotUIProgress)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.INeedTips, self.INeedTips)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.GrassWarningHide, self.GrassWarningHide)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.GrassWarningShow, self.GrassWarningShow)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.INotNeedTips, self.INotNeedTips)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.AddBeaconNum, self.AddBeaconNum)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.SetBeaconNum, self.SetBeaconNum)
  MessageSys:AddListener(CS.GF2.Message.BattleEventBase.ChangeUIState, self.ShowOrHideUI)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.SearchBeaconResult, self.SearchBeaconResult)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.ActiveDzOxygen, self.ActiveDzOxygen)
  MessageSys:AddListener(GuideEvent.OnDzAttacked, self.OnDzAttacked)
  MessageSys:AddListener(GuideEvent.OnDzBeAttacked, self.OnDzBeAttacked)
  MessageSys:AddListener(GuideEvent.OnDzWin, self.OnDzWin)
  MessageSys:AddListener(GuideEvent.OnDzLose, self.OnDzLose)
  MessageSys:AddListener(GuideEvent.ShowBubbleMsg, self.OnShowBubbleMsg)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.DarkZoneHideMainPanel, self.OnHideMainPanelFunc)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.DzStartEvacuateDialogShowFinish, self.ShowMapTask)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.OpenSettingBtn, self.OpenSettingBtn)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.CloseSettingBtn, self.CloseSettingBtn)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.MainPanelFadeOut, self.MainPanelFadeOut)
  function self.darkzoneQuestCountChangeFunc(msg)
    self:RefreshDarkZoneQuest(msg)
  end
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.DarkZoneQuestCountChange, self.darkzoneQuestCountChangeFunc)
  function self.areaChangeFunc(msg)
    self:ChangeRoomQuest(msg)
  end
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.AreaIDChange, self.areaChangeFunc)
  function self.roomQuestCountChangeFunc(msg)
    self:RefreshRoomQuest(msg)
  end
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.RoomQuestCountChange, self.roomQuestCountChangeFunc)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.DzHighRiskEventChange, self.DzHighRiskEventChange)
end
function UIDarkMainPanelInGame:OnShowStart()
  self.ui.mComp_Nameplate:SetActive(false)
  self:SetGlobalVigilant(CS.SysMgr.dzUIElemMgr.globalVigilant)
  local blueValue = CS.SysMgr.dzPlayerMgr.MainPlayer:GetProperty(EnumDarkzoneProperty.Property.DzEnergy2Now)
  self:SetBlueEnergyValue(blueValue)
  self:InitMiniMapDetail()
  self:SetGlobalEvent(CS.SysMgr.dzGlobalEventManager.events)
  self:ShowInteractiveButton(nil)
  self.Gameing = true
end
function UIDarkMainPanelInGame.UpdateNetDelayTime(msg)
  local number
  delay = msg.Sender
  self.ui.mText_Wifi.text = string.format("%dms", delay)
  if delay > 100 then
    self.ui.mImg_Wifi.color = ColorUtils.RedColor
    self.ui.mText_Wifi.color = ColorUtils.RedColor
  else
    self.ui.mImg_Wifi.color = self.greenColor
    self.ui.mText_Wifi.color = self.greenColor
  end
end
function UIDarkMainPanelInGame.HideOrShowMirror(msg)
  local show = msg.Sender
  if show then
    if self.delayAimBtnFadeOut ~= nil then
      self.delayAimBtnFadeOut:Stop()
      setactive(self.ui.mBtn_Aim.gameObject, false)
      self.delayAimBtnFadeOut = nil
    end
    self.ui.mBtn_Aim.interactable = true
    setactive(self.ui.mBtn_Aim.gameObject, true)
    self:RegistrationKeyboard(KeyCode.Q, self.ui.mBtn_Aim)
  else
    self.ui.mAin_Aim:SetTrigger("FadeOut")
    self.ui.mBtn_Aim.interactable = false
    self:UnRegistrationKeyboard(KeyCode.Q)
    self.delayAimBtnFadeOut = TimerSys:DelayCall(0.33, function()
      setactive(self.ui.mBtn_Aim.gameObject, false)
      self.delayAimBtnFadeOut = nil
    end)
  end
end
function UIDarkMainPanelInGame.UpdateBox(msg)
  if self.openPickPanel then
    return
  end
  local result = UIManager.OpenUIByParam(UIDef.DarkzoneBoxDialog, msg.Sender)
  self.openPickPanel = true
end
function UIDarkMainPanelInGame.ClosePickPanel(msg)
  if not self.openPickPanel then
    return
  end
  self.openPickPanel = false
  UIManager.CloseUI(UIDef.DarkzoneBoxDialog)
end
function UIDarkMainPanelInGame.INeedNameTip(msg)
  local host = msg.Sender
  if host == nil then
    return
  end
  local type = msg.Content
  local nameView
  if self.NameLs[host.ClientID] ~= nil then
    nameView = self.NameLs[host.ClientID]
    nameView:SetHost(host, type)
    setactive(nameView.obj, true)
    return
  end
  local hostId
  for i, v in pairs(self.NameLs) do
    if v.hasHost == false then
      hostId = i
      nameView = v
      break
    end
  end
  if nameView == nil then
    nameView = DarkMainPanelInGameChrNameItem.New()
    nameView:InitCtrl(self.ui.mTran_NameRoot)
  end
  self.NameLs[host.ClientID] = nameView
  if hostId ~= nil then
    self.NameLs[hostId] = nil
  end
  nameView:SetHost(host, type)
  setactive(nameView.obj, true)
end
function UIDarkMainPanelInGame.AllNameTipChangeActive(msg)
  local show = msg.Sender
  for i, v in pairs(self.NameLs) do
    setactive(v.obj, show)
  end
end
function UIDarkMainPanelInGame.IDontNeedNameTip(msg)
  local host = msg.Sender
  if self.NameLs[host.ClientID] ~= nil then
    self.NameLs[host.ClientID]:SetNull()
  end
end
function UIDarkMainPanelInGame.MainPlayerChangeInvencible(msg)
  local show = msg.Sender
  if show then
    self.InvencibleCount = msg.Content
    self.ui.mText_Invincible.text = string.format("%.1f", self.InvencibleCount)
    self.ui.mImg_Invincible.fillAmount = 1
  end
  setactive(self.ui.mTran_Invincible.gameObject, show)
end
function UIDarkMainPanelInGame.MainPlayerRefreshInvencible(msg)
  local time = msg.Sender
  self.ui.mImg_Invincible.fillAmount = time / self.InvencibleCount
  self.ui.mText_Invincible.text = string.format("%.1f", time)
end
function UIDarkMainPanelInGame.DarkGameEnd(msg)
  self.Gameing = false
end
function UIDarkMainPanelInGame.ChangeLeader(msg)
  local leaderId = msg.Sender
  for i = 1, #self.roleViewLs do
    self.roleViewLs[i]:SetLeader(self.roleViewLs[i].mData.Id == leaderId)
  end
end
function UIDarkMainPanelInGame.EnterPrepareBattle(msg)
  if self.aimFadeDelay ~= nil then
    self.aimFadeDelay:Stop()
    setactive(self.ui.mBind_AimUI.gameObject, false)
    self.aimFadeDelay = nil
  end
  setactive(self.ui.mBind_AimUI.gameObject, true)
  self.ui.mAni_Root:SetTrigger("FadeOut")
  self.aimFadeDelay = TimerSys:DelayCall(0.34, function()
    setactive(self.ui.mTran_MainUI.gameObject, false)
    self.aimFadeDelay = nil
  end)
  self.ui.mBtn_Map.interactable = false
  self:UnRegistrationKeyboard(KeyCode.M)
  self:UnRegistrationKeyboard(KeyCode.Escape)
  self:RegistrationKeyboard(KeyCode.Escape, self.AimUI.mBtn_BtnCancelAim)
  self.ui.mBtn_Aim.gameObject:GetComponent(typeof(CS.UnityEngine.Animator)):SetBool("On", true)
  self:EnterTargetLs()
  for i, v in pairs(self.NameLs) do
    if v.hasHost then
      v:EnterAim(true)
    end
  end
end
function UIDarkMainPanelInGame.ExitPrepareBattle(msg)
  if self.aimFadeDelay ~= nil then
    self.aimFadeDelay:Stop()
    setactive(self.ui.mTran_MainUI.gameObject, false)
    self.aimFadeDelay = nil
  end
  setactive(self.ui.mTran_MainUI.gameObject, true)
  self.ui.mAni_Root:SetTrigger("FadeIn")
  self.AimUI.mAni_AimRoot:SetTrigger("FadeOut")
  self.aimFadeDelay = TimerSys:DelayCall(0.34, function()
    setactive(self.ui.mBind_AimUI.gameObject, false)
    self.aimFadeDelay = nil
  end)
  self.ui.mBtn_Map.interactable = true
  self:RegistrationKeyboard(KeyCode.M, self.ui.mBtn_Map)
  self:UnRegistrationKeyboard(KeyCode.Escape)
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Back)
  self.ui.mBtn_Aim.gameObject:GetComponent(typeof(CS.UnityEngine.Animator)):SetBool("On", false)
  self:ExitTargetLs()
  for i, v in pairs(self.NameLs) do
    if v.hasHost then
      v:EnterAim(false)
    end
  end
end
function UIDarkMainPanelInGame.CanUnderCover(msg)
  local cover = msg.Sender
  if cover == nil then
    if self.delayCoverStateBtnFadeOut ~= nil then
      return
    end
    self.ui.mAni_CoverState:SetTrigger("FadeOut")
    self:UnRegistrationKeyboard(KeyCode.E)
    self.ui.mBtn_CoverState.interactable = false
    self.delayCoverStateBtnFadeOut = TimerSys:DelayCall(0.24, function()
      setactive(self.ui.mBtn_CoverState.transform.parent.gameObject, false)
      self.delayCoverStateBtnFadeOut = nil
    end)
  else
    if self.delayCoverStateBtnFadeOut ~= nil then
      self.delayCoverStateBtnFadeOut:Stop()
      self.delayCoverStateBtnFadeOut = nil
    else
      self.ui.mAni_CoverState:SetTrigger("FadeIn")
    end
    self.ui.mBtn_CoverState.interactable = true
    setactive(self.ui.mBtn_CoverState.transform.parent.gameObject, false)
    setactive(self.ui.mBtn_CoverState.transform.parent.gameObject, true)
    self:RegistrationKeyboard(KeyCode.E, self.ui.mBtn_CoverState)
  end
end
function UIDarkMainPanelInGame.UnderStateChange(msg)
  local curDZCover = msg.Sender
  if curDZCover == nil then
    self.ui.mBtn_CoverState:GetComponent(typeof(CS.UITemplate)).Images[0].sprite = self.Darkzone_BunkerIn
  else
    self.ui.mBtn_CoverState:GetComponent(typeof(CS.UITemplate)).Images[0].sprite = self.Darkzone_BunkerOut
  end
end
function UIDarkMainPanelInGame.ChangeUnderBtnInteractable(msg)
  local underFindNext = msg.Sender
  if underFindNext == nil then
    setactive(self.ui.mBtn_CoverChange.transform.parent.gameObject, false)
    self:UnRegistrationKeyboard(KeyCode.Space)
  else
    setactive(self.ui.mBtn_CoverChange.transform.parent.gameObject, true)
    self:RegistrationKeyboard(KeyCode.Space, self.ui.mBtn_CoverChange)
  end
end
function UIDarkMainPanelInGame.AddGetItem(msg)
  local GetItemData = msg.Sender
  local getitem = DarkGetItem.New()
  if getitem == nil then
    return
  end
  getitem:InitCtrl(self.ui.mTran_GetContent)
  getitem:SetData(GetItemData)
  table.insert(self.GetItemTbl, getitem)
end
function UIDarkMainPanelInGame.SetChrNameVisible(msg)
  local id = msg.Sender
  local visible = msg.Content
  self:SetNameTipsVisible(id, visible)
end
function UIDarkMainPanelInGame:SetNameTipsVisible(clientId, visible)
  local nameItem = self.NameLs[clientId]
  if nameItem ~= nil then
    nameItem:SetVisible(visible)
  end
end
function UIDarkMainPanelInGame.MainPlayerEnterGrass(msg)
  UIDarkMainPanelInGame.ui.mGrassEffect.gameObject:SetActive(true)
end
function UIDarkMainPanelInGame.MainPlayerExitGrass(msg)
  UIDarkMainPanelInGame.ui.mGrassEffect.gameObject:SetActive(false)
end
function UIDarkMainPanelInGame.OnLateUpdate(msg)
  if self.Gameing then
    for i, v in pairs(self.NameLs) do
      if v.hasHost then
        v:UpdatePos()
      end
    end
    for i, v in pairs(self.interactiveObjs) do
      if v.hasHost then
        v:UpdatePos()
      end
    end
    for i = 1, #self.BuffViewLs do
      if self.BuffViewLs[i].hasHost then
        self.BuffViewLs[i]:OnUpdate()
      end
    end
    for i = 1, #self.EventUI.EventDesUILS do
      if self.EventUI.EventDesUILS[i].show then
        self.EventUI.EventDesUILS[i]:Update()
      end
    end
    if self.curShowGlobalEvent ~= nil and not self.curShowGlobalEvent.forever then
      self.EventUI.mText_ShowEventTime.text = self.curShowGlobalEvent:TimeStr()
    end
    local countdownTimeSpan = CS.SysMgr.dzGameMapMgr:GetCountdown()
    local leftTime = countdownTimeSpan.TotalSeconds
    if self.changeCountdownColor and leftTime < 30 and 0 < leftTime then
      self.changeCountdownColor = false
      self.ui.mText_Countdown.color = ColorUtils.RedColor
    end
    self.ui.mText_Countdown.text = CS.SysMgr.dzGameMapMgr:GetPlayerCountdownStr()
    if self.ui.self_mComp_Nameplate_Follow then
      local pos = CS.SysMgr.dzGameMapMgr:NameTipPosByHostPos(self.ui.self_mComp_Nameplate_Follow, self.ui.mTran_Nameplate.transform.parent)
      self.ui.mTran_Nameplate.anchoredPosition = pos
    end
  end
end
function UIDarkMainPanelInGame.UpdateBagBearing(msg)
  local type = msg.Sender
  local value = type.value__
  local additon = math.floor(msg.Content)
  if value == EnumDarkzoneProperty.Property.DarkzoneChequer then
    self.ui.mText_BagNumMain.text = self.BagMgr:ItemNumInBag() .. "/" .. additon
  elseif value == EnumDarkzoneProperty.Property.DzEnergy2Now then
    self:SetBlueEnergyValue(additon)
    self.EnergyUI.EnergyItemLs[value]:SetValue(additon)
  elseif value == EnumDarkzoneProperty.Property.DzOxygen then
    self:SetAirDetail(additon)
  end
end
function UIDarkMainPanelInGame.ShowBagNum(msg)
  local num = msg.Sender
  self.ui.mText_BagNumMain.text = num:ItemNumInBag() .. "/" .. CS.SysMgr.dzPlayerMgr.MainPlayer.Chequer:ToString()
end
function UIDarkMainPanelInGame.AddAttackTarget(msg)
  local darkUnit = msg.Sender
  local notFree = true
  local itemView
  for i = 1, #self.targetAvatarLs do
    if self.targetAvatarLs[i].mData == nil then
      notFree = false
      itemView = self.targetAvatarLs[i]
      itemView:SetData(darkUnit)
      itemView.obj.transform:SetAsLastSibling()
      break
    end
  end
  if notFree then
    itemView = DarkTargetAvatar.New()
    itemView:InitCtrl(self.AimUI.mTran_TargetRoot, self)
    itemView:SetData(darkUnit)
    self.targetAvatarLs[#self.targetAvatarLs + 1] = itemView
  end
  setactive(itemView.obj, true)
end
function UIDarkMainPanelInGame.RemoveAttackTatget(msg)
  local darkUnit = msg.Sender
  for i = 1, #self.targetAvatarLs do
    if self.targetAvatarLs[i].mData == darkUnit then
      self.targetAvatarLs[i]:Close()
      break
    end
  end
end
function UIDarkMainPanelInGame.ChangeAttackTatget(msg)
  local pre = msg.Sender
  local next = msg.Content
  for i = 1, #self.targetAvatarLs do
    if self.targetAvatarLs[i].mData == pre then
      self.targetAvatarLs[i]:SetTarget(false)
    elseif self.targetAvatarLs[i].mData == next then
      self.targetAvatarLs[i]:SetTarget(true)
    end
  end
  if pre ~= nil and self.NameLs[pre.ClientID] ~= nil then
    self.NameLs[pre.ClientID]:SetTarget(false)
  end
  if next ~= nil and self.NameLs[next.ClientID] ~= nil then
    self.NameLs[next.ClientID]:SetTarget(true)
  end
  self:ShowTargetAttackInfoItem(next)
end
function UIDarkMainPanelInGame.CloseUIDzWindows(msg)
  self:ShowWindow(DzWindowEnum.None)
end
function UIDarkMainPanelInGame.GoToDarkSLGView(msg)
  UIManager.CloseUI(CS.GF2.UI.enumUIPanel.BattleSettingPanel, CS.UISystem.UIGroupType.Default)
  UIManager.CloseUI(UIDef.UIDarkZoneBigMapDialog)
end
function UIDarkMainPanelInGame.MainPlayerBuffChange(msg)
  local showBuffLs = msg.Sender
  self:SetBuffLsView(showBuffLs)
end
function UIDarkMainPanelInGame.ShowInteractiveProgress(msg)
  local show = msg.Sender
  if show == true then
    if self.delayInteractiveProgressFadeOut ~= nil then
      self.delayInteractiveProgressFadeOut:Stop()
      self.delayInteractiveProgressFadeOut = nil
    end
    if self.delayInteractiveProgressHide ~= nil then
      self.delayInteractiveProgressHide:Stop()
      self.delayInteractiveProgressHide = nil
    end
    local fillAmount = msg.Content
    setactive(self.ui.InteractiveProgressUI.mAni_Root.gameObject, false)
    setactive(self.ui.InteractiveProgressUI.mAni_Root.gameObject, true)
    setactive(self.ui.InteractiveProgressUI.mImg_Icon.transform.parent.gameObject, true)
    local pickTarget = CS.SysMgr.dzPlayerMgr.MainPlayer.pickHandler.panddingTarget
    if pickTarget ~= nil then
      self.ui.InteractiveProgressUI.mImg_Icon.sprite = pickTarget:GetInteractiveItemIcon()
    end
    self.ui.InteractiveProgressUI.mMask_Bar.FillAmount = fillAmount
    self.ui.InteractiveProgressUI.mImg_Bg.color = ColorUtils.StringToColor("EFEFEF")
    self.ui.InteractiveProgressUI.mText_Progress.text = TableData.listHintDatas:GetDataById(903342).Chars.str
  else
    setactive(self.ui.InteractiveProgressUI.mImg_Icon.transform.parent.gameObject, false)
    local interrupt = msg.Content
    if interrupt == true then
      self.ui.InteractiveProgressUI.mImg_Bg.color = Color(0.807843137254902, 0.2823529411764706, 0.2823529411764706)
      self.ui.InteractiveProgressUI.mText_Progress.text = TableData.listHintDatas:GetDataById(903341).Chars.str
      self.delayInteractiveProgressFadeOut = TimerSys:DelayCall(1, function()
        self.ui.InteractiveProgressUI.mAni_Root:SetTrigger("FadeOut")
        self.delayInteractiveProgressFadeOut = nil
      end)
      self.delayInteractiveProgressHide = TimerSys:DelayCall(1.17, function()
        setactive(self.ui.InteractiveProgressUI.mAni_Root.gameObject, false)
        self.delayInteractiveProgressHide = nil
      end)
    else
      self.ui.InteractiveProgressUI.mAni_Root:SetTrigger("FadeOut")
      self.delayInteractiveProgressHide = TimerSys:DelayCall(0.17, function()
        setactive(self.ui.InteractiveProgressUI.mAni_Root.gameObject, false)
        self.delayInteractiveProgressHide = nil
      end)
    end
  end
end
function UIDarkMainPanelInGame.RefreshInteractiveProgress(msg)
  local fillAmount = msg.Sender
  self.ui.InteractiveProgressUI.mMask_Bar.FillAmount = fillAmount
end
function UIDarkMainPanelInGame.ShowInteractiveButton(msg)
  setactive(self.ui.mVir_InteractiveUI.gameObject, true)
  if self.InteractiveLsUI ~= nil then
    for i, v in pairs(self.InteractiveLsUI) do
      if v.useful and self.ui.CurSelectInteractiveItem == nil then
        self.ui.CurSelectInteractiveItem = v
      end
      v:RootVisible()
    end
  end
  self:SelectInteractive(self.ui.CurSelectInteractiveItem)
end
function UIDarkMainPanelInGame.HideInteractiveButton(msg)
  self:SelectInteractive(nil)
  setactive(self.ui.mVir_InteractiveUI.gameObject, false)
end
function UIDarkMainPanelInGame.VigilantChange(msg)
  local vigilant = msg.Sender
  self:SetGlobalVigilant(vigilant)
end
function UIDarkMainPanelInGame.PlayVigilantLevelAnimation(msg)
  local vigilant = msg.Sender
  self.VigilantUI.mAin_VigiLevel:SetInteger("Switch", vigilant.CurAniSwitch)
end
function UIDarkMainPanelInGame.RefreshInteractive(msg)
  local sortInteractiveBase = msg.Sender
  local InteractiveLs = sortInteractiveBase.items
  local showCount = InteractiveLs.Count - 1
  if self.InteractiveLsUI ~= nil then
    for i, v in pairs(self.InteractiveLsUI) do
      v:CheckUseful(false)
    end
  end
  local index = 0
  for i = 0, showCount do
    local clientId = InteractiveLs[i].PickID
    local interactiveItem = self.InteractiveLsUI[clientId]
    if interactiveItem ~= nil then
      interactiveItem:CheckUseful(true)
    else
      local freeCount = #self.InteractiveFreeLs
      if 0 < freeCount then
        interactiveItem = self.InteractiveFreeLs[freeCount]
        table.remove(self.InteractiveFreeLs, freeCount)
      else
        interactiveItem = DarkzoneInteractiveItem.New()
        interactiveItem:InitCtrl(self.ui.mTran_InteractiveItemRoot, self, self.ui.mTran_Pool)
      end
      self.InteractiveLsUI[clientId] = interactiveItem
      interactiveItem:SetDetail(InteractiveLs[i], self.ui.mVir_InteractiveUI.gameObject.activeSelf, index)
    end
    index = index + 1
  end
  local freeLs = {}
  local usefulIndex = 0
  local nextSelect
  if self.InteractiveLsUI ~= nil then
    for i, v in pairs(self.InteractiveLsUI) do
      if v.useful then
        usefulIndex = usefulIndex + 1
        if usefulIndex == 1 then
          nextSelect = v
        end
      else
        v:Close(self.ui.mVir_InteractiveUI.gameObject.activeSelf)
        table.insert(freeLs, #freeLs + 1, i)
        table.insert(self.InteractiveFreeLs, #self.InteractiveFreeLs + 1, v)
      end
    end
  end
  if self.ui.CurSelectInteractiveItem == nil then
    self:SelectInteractive(nextSelect)
  end
  for i = 1, #freeLs do
    self.InteractiveLsUI[freeLs[i]] = nil
  end
end
function UIDarkMainPanelInGame:SelectInteractive(InteractiveItem)
  local parentActive = self.ui.mVir_InteractiveUI.gameObject.activeSelf
  if self.ui.CurSelectInteractiveItem ~= nil then
    self.ui.CurSelectInteractiveItem:Select(false, parentActive)
  end
  self.ui.CurSelectInteractiveItem = InteractiveItem
  if InteractiveItem ~= nil then
    self.ui.CurSelectInteractiveItem:Select(true, parentActive)
  end
end
function UIDarkMainPanelInGame.RefreshGlobalEvent(msg)
  local globalEventLS = msg.Sender
  self:SetGlobalEvent(globalEventLS)
end
function UIDarkMainPanelInGame.ShowMapTask(msg)
  if #self.questItemList > 0 then
    if self.questTimer then
      self.questTimer:Stop()
      self.questTimer = nil
    end
    self.questItemList[1].mAnimator_Self:SetInteger("Switch", 1)
    self.questTimer = TimerSys:DelayFrameCall(3, function()
      self.questItemList[1].mAnimator_Self:SetInteger("Switch", 2)
    end)
  end
  if self.roomQuestItem then
    local grid = CS.SysMgr.dzPlayerMgr.MainPlayerData.serverTrans.BigGrid
    local currentRoomID = CS.DarkUnitWorld.DzGridUtils.GetDzAreaID(grid)
  end
end
function UIDarkMainPanelInGame:ChangeRoomQuest(msg)
  if self.roomQuestItem then
  end
end
function UIDarkMainPanelInGame:RefreshRoomQuest(msg)
  if self.roomQuestItem then
  end
end
function UIDarkMainPanelInGame:RefreshDarkZoneQuest(msg)
  if self.questItemList and #self.questItemList > 0 then
    self.questItemList[1].RefreshQuest()
  end
end
function UIDarkMainPanelInGame.INeedTips(msg)
  local host = msg.Sender
  local keyId = host.KeyId
  if self.interactiveObjs[keyId] ~= nil then
    self.interactiveObjs[keyId]:SetHost(host)
    setactive(self.interactiveObjs[keyId].obj, true)
    return
  end
  local key, tipsView
  for i, v in pairs(self.interactiveObjs) do
    if v.hasHost == false then
      key = i
      tipsView = v
      break
    end
  end
  if tipsView == nil then
    tipsView = DarkzoneInteractiveTipsItem.New()
    tipsView:InitCtrl(self.ui.mTran_PickTips, self.ui.mTrans_InterTipRoot)
  end
  self.interactiveObjs[keyId] = tipsView
  tipsView:SetHost(host)
  if key ~= nil then
    self.interactiveObjs[key] = nil
  end
  setactive(tipsView.obj, true)
end
function UIDarkMainPanelInGame.INotNeedTips(msg)
  local host = msg.Sender
  local keyId = host.KeyId
  if self.interactiveObjs[keyId] ~= nil then
    self.interactiveObjs[keyId]:SetNull()
  end
end
function UIDarkMainPanelInGame.GrassWarningShow(msg)
  local host = msg.Sender
  if host == nil then
    return
  end
  if self.grassWarningObj[host.ClientID] ~= nil then
    self.grassWarningObj[host.ClientID]:SetHost(host)
    setactive(self.grassWarningObj[host.ClientID].obj, true)
    return
  end
  local key, tipsView
  for i, v in pairs(self.grassWarningObj) do
    if v.hasHost == false then
      key = i
      tipsView = v
      break
    end
  end
  if tipsView == nil then
    tipsView = DarkzoneGrassWarningTipsItem.New()
    tipsView:InitCtrl(self.ui.mTran_InteractWarn, self.ui.mTrans_InterTipRoot)
  end
  self.grassWarningObj[host.ClientID] = tipsView
  tipsView:SetHost(host)
  if key ~= nil then
    self.grassWarningObj[key] = nil
  end
  setactive(tipsView.obj, true)
end
function UIDarkMainPanelInGame.GrassWarningHide(msg)
  local host = msg.Sender
  if self.grassWarningObj[host.ClientID] ~= nil then
    self.grassWarningObj[host.ClientID]:SetNull()
  end
end
function UIDarkMainPanelInGame.AddBeaconNum(msg)
  local cur = msg.Sender
  if CS.SysMgr.dzUIControlMgr:IsBeaconComplete(cur) then
    self.ui.ExploreUI.mCom_Effect:BeginShowComplete()
  end
  self:SetExploreProgress(cur)
end
function UIDarkMainPanelInGame.SetBeaconNum(msg)
  local cur = msg.Sender
  if CS.SysMgr.dzUIControlMgr:IsBeaconComplete(cur) then
    setactive(self.ui.mBind_Explore.gameObject, false)
  end
  self:SetExploreProgress(cur)
end
function UIDarkMainPanelInGame.SearchBeaconResult(msg)
  local searchResult = msg.Sender
  self.ui.ExploreUI.mCom_Effect:SetSignalIntensity(searchResult.Strength)
end
function UIDarkMainPanelInGame.ActiveDzOxygen(msg)
  if self.activeOxygen then
    return
  end
  self.oxygenGameplayId = msg.Sender
  local value = msg.Content
  self.activeOxygen = true
  self.airSegmentRedColor = CS.GF2.UI.UITool.StringToColor("cc3647")
  self.airSegmentYellowColor = CS.GF2.UI.UITool.StringToColor("cd993c")
  self.airSegmentBlueColor = CS.GF2.UI.UITool.StringToColor("3882af")
  local endlessData = TableData.listDzEndlessModeDatas:GetDataById(self.oxygenGameplayId)
  local count = endlessData.result_divide_num.Count
  self.airMax = endlessData.property_up_limit[EnumDarkzoneProperty.Property.DzOxygenMax]
  self.airSegmentRed = endlessData.result_divide_num[0]
  self.airSegmentBlue = endlessData.result_divide_num[count - 2]
  self.segmentAirLs = {}
  for i = 0, endlessData.result_divide - 1 do
    local segmentAir = endlessData.result_divide_num[i]
    self.segmentAirLs[i + 1] = segmentAir
  end
  setactive(self.ui.mBind_Air.gameObject, true)
  self:InitAirDetail(value)
end
function UIDarkMainPanelInGame.DzAttackEnterBattle(msg)
  local show = msg.Sender.Item1
  if show then
    local monster = msg.Sender.Item2
    if monster == nil then
      return
    end
    self.ui.mComp_Nameplate:SetActive(true)
    self:SetNameTipsVisible(monster.ClientID, false)
    self.ui.self_mComp_Nameplate_Follow = monster
    self.ui.mComp_Nameplate:DzSetTarget(monster, msg.Sender.Item3, msg.Sender.Item4)
  else
    self.ui.mComp_Nameplate:SetActive(false)
    self.ui.self_mComp_Nameplate_Follow = nil
    self.ui.mComp_Nameplate:DzClearTarget()
  end
end
function UIDarkMainPanelInGame.MonsterReduceProperty(msg)
  local damage = msg.Sender
  self.ui.mComp_Nameplate:DzPlayDamage(damage.Item1)
  self.ui.mComp_Nameplate:DzPlayWillDamage(damage.Item2)
end
function UIDarkMainPanelInGame.ChangeSlotUIActive(msg)
  local slotUIActive = msg.Sender
  self.slotViewLs[slotUIActive.Item1]:SetEnable(slotUIActive.Item2)
end
function UIDarkMainPanelInGame.RefreshSlotUIProgress(msg)
  local slotUIProgress = msg.Sender
  self.slotViewLs[slotUIProgress.Item1]:SetFill(slotUIProgress.Item2)
end
function UIDarkMainPanelInGame.ShowOrHideUI(msg)
  local boolean = msg.Sender
  boolean = boolean == nil and true or boolean
  if boolean then
    self.ui.mTran_Root.localScale = vectorone
  else
    self.ui.mTran_Root.localScale = vectorzero
  end
end
function UIDarkMainPanelInGame.OpenSettingBtn(msg)
  setactive(self.ui.mBtn_Back.transform.parent.gameObject, true)
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Back)
end
function UIDarkMainPanelInGame.CloseSettingBtn(msg)
  setactive(self.ui.mBtn_Back.transform.parent.gameObject, false)
  self:UnRegistrationKeyboard(KeyCode.Escape)
end
function UIDarkMainPanelInGame.MainPanelFadeOut(msg)
  self.ui.mAni_Root:SetTrigger("FadeOut")
end
function UIDarkMainPanelInGame.DzHighRiskEventChange(msg)
  local curHighRisk = msg.Sender
  local showAni = curHighRisk.Count > 0
  setactive(self.VigilantUI.mTran_SpeedUp.gameObject, showAni)
end
function UIDarkMainPanelInGame:UpdateHeadIcon()
  local roleTable = CS.SysMgr.dzPlayerMgr.MainPlayerData.nowPropertyDataLs
  local leaderId = CS.SysMgr.dzPlayerMgr.MainPlayerData.leader
  if #self.roleViewLs ~= 0 then
    for i = 1, #self.roleViewLs do
      self.roleViewLs[i]:UpdateData(roleTable[i - 1])
    end
  end
end
function UIDarkMainPanelInGame:OnClose()
  self:RemoveMsgListener()
  self:RemoveBtnListen()
  self:ReleaseBaseData()
end
function UIDarkMainPanelInGame:RemoveMsgListener()
  MessageSys:RemoveListener(CS.GF2.Message.SystemEvent.NetDelayTime, self.UpdateNetDelayTime)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.HideOrShowMirror, self.HideOrShowMirror)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.INeedNameTip, self.INeedNameTip)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.AllNameTipChangeActive, self.AllNameTipChangeActive)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.IDontNeedNameTip, self.IDontNeedNameTip)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.MainPlayerChangeInvencible, self.MainPlayerChangeInvencible)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.MainPlayerRefreshInvencible, self.MainPlayerRefreshInvencible)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.DarkGameEnd, self.DarkGameEnd)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.ChangeLeader, self.ChangeLeader)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.EnterPrepareBattle, self.EnterPrepareBattle)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.ExitPrepareBattle, self.ExitPrepareBattle)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.CanUnderCover, self.CanUnderCover)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.UnderStateChange, self.UnderStateChange)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.ChangeUnderBtnInteractable, self.ChangeUnderBtnInteractable)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.UpdateBox, self.UpdateBox)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.ClosePickPanel, self.ClosePickPanel)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.DarkGetItem, self.AddGetItem)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.PlayerVisible, self.SetChrNameVisible)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.MainPlayerEnterGrass, self.MainPlayerEnterGrass)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.MainPlayerExitGrass, self.MainPlayerExitGrass)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.OnLateUpdate, self.OnLateUpdate)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.RefreshDarkzoneProperty, self.UpdateBagBearing)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.ChangeBagCurrentNum, self.ShowBagNum)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.AddAttackTarget, self.AddAttackTarget)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.RemoveAttackTatget, self.RemoveAttackTatget)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.ChangeAttackTatget, self.ChangeAttackTatget)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.CloseUIDzWindows, self.CloseUIDzWindows)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.GoToDarkSLGView, self.GoToDarkSLGView)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.MainPlayerBuffChange, self.MainPlayerBuffChange)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.ShowInteractiveProgress, self.ShowInteractiveProgress)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.RefreshInteractiveProgress, self.RefreshInteractiveProgress)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.ShowInteractiveButton, self.ShowInteractiveButton)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.HideInteractiveButton, self.HideInteractiveButton)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.VigilantChange, self.VigilantChange)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.PlayVigilantLevelAnimation, self.PlayVigilantLevelAnimation)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.RefreshInteractive, self.RefreshInteractive)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.RefreshGlobalEvent, self.RefreshGlobalEvent)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.DzAttackEnterBattle, self.DzAttackEnterBattle)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.MonsterReduceProperty, self.MonsterReduceProperty)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.ChangeSlotUIActive, self.ChangeSlotUIActive)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.RefreshSlotUIProgress, self.RefreshSlotUIProgress)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.INeedTips, self.INeedTips)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.INotNeedTips, self.INotNeedTips)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.GrassWarningHide, self.GrassWarningHide)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.GrassWarningShow, self.GrassWarningShow)
  MessageSys:RemoveListener(CS.GF2.Message.BattleEventBase.ChangeUIState, self.ShowOrHideUI)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.SearchBeaconResult, self.SearchBeaconResult)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.ActiveDzOxygen, self.ActiveDzOxygen)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.AreaIDChange, self.areaChangeFunc)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.RoomQuestCountChange, self.roomQuestCountChangeFunc)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.AddBeaconNum, self.AddBeaconNum)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.SetBeaconNum, self.SetBeaconNum)
  MessageSys:RemoveListener(GuideEvent.OnDzAttacked, self.OnDzAttacked)
  MessageSys:RemoveListener(GuideEvent.OnDzBeAttacked, self.OnDzBeAttacked)
  MessageSys:RemoveListener(GuideEvent.OnDzWin, self.OnDzWin)
  MessageSys:RemoveListener(GuideEvent.OnDzLose, self.OnDzLose)
  MessageSys:RemoveListener(GuideEvent.ShowBubbleMsg, self.OnShowBubbleMsg)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.DarkZoneHideMainPanel, self.OnHideMainPanelFunc)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.DzStartEvacuateDialogShowFinish, self.ShowMapTask)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.OpenSettingBtn, self.OpenSettingBtn)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.CloseSettingBtn, self.CloseSettingBtn)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.MainPanelFadeOut, self.MainPanelFadeOut)
  self.areaChangeFunc = nil
  self.roomQuestCountChangeFunc = nil
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.DarkZoneQuestCountChange, self.darkzoneQuestCountChangeFunc)
  self.darkzoneQuestCountChangeFunc = nil
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.DzHighRiskEventChange, self.DzHighRiskEventChange)
end
function UIDarkMainPanelInGame:RemoveBtnListen()
  self:UnRegistrationAllKeyboard()
  self:UnRegistrationKeyboard(nil)
  self.ui.mBtn_Map.onClick:RemoveListener(self.OnClickMapBtn)
  self.ui.mBtn_Back.onClick:RemoveListener(self.OnClickSettingBtn)
  self.ui.mBtn_Guide.onClick:RemoveListener(self.OnGuideBtn)
  self.ui.mBtn_Wish.onClick:RemoveListener(self.OnClickWishBtn)
  self.ui.mBtn_Package.onClick:RemoveListener(self.OnClickPackageBtn)
  self.ui.mScroll_BuffRoot:GetComponent(typeof(CS.UnityEngine.UI.GFButton)).onClick:RemoveListener(self.OnClickBuffBtn)
  self.ui.mBtn_Quest.onClick:RemoveListener(self.OnClickDoubleCheckBtn)
  self.EventUI.mBtn_Event.onClick:RemoveListener(self.OnClickGlobalEventBtn)
  self.EventUI.mBtn_EventClose.onClick:RemoveListener(self.OnClickGlobalEventBtn)
  self.ui.AirUI.mBtn_Air.onClick:RemoveListener(self.OnClickAirBtn)
  self.VigilantUI.mBtn_Vigilant.onClick:RemoveListener(self.OnClickVigilantBtn)
  self.VigilantUI.mBtn_VigilantClose.onClick:RemoveListener(self.OnClickVigilantBtn)
  self.EnergyUI.mBtn_Energy.onClick:RemoveListener(self.OnClickEnergyBtn)
  self.EnergyUI.mBtn_EnergyClose.onClick:RemoveListener(self.OnClickEnergyBtn)
  self.ui.mBtn_CoverState.onClick:RemoveListener(self.OnClickCoverBtn)
  self.ui.mBtn_Aim.onClick:RemoveListener(self.OnClickAimBtn)
  self.AimUI.mBtn_BtnCancelAim.onClick:RemoveListener(self.OnClickCancelAimBtn)
  self.AimUI.mBtn_BtnConfirmAttack.onClick:RemoveListener(self.OnClickAttackBtn)
  self.AimUI.mBtn_BtnLeft.onClick:RemoveListener(self.OnClickLeftTargetBtn)
  self.AimUI.mBtn_BtnRight.onClick:RemoveListener(self.OnClickRightTargetBtn)
end
function UIDarkMainPanelInGame:ReleaseBaseData()
  self.isOpenBigMap = nil
  if self.NameLs ~= nil then
    for i, v in pairs(self.NameLs) do
      v:OnRelease()
    end
  end
  self.NameLs = nil
  if self.interactiveObjs ~= nil then
    for i = 1, #self.interactiveObjs do
      if self.interactiveObjs[i] ~= nil then
        self.interactiveObjs[i]:OnRelease()
      end
    end
  end
  self.interactiveObjs = nil
  self.grassWarningObj = nil
  self.InvencibleCount = nil
  if self.roleViewLs ~= nil then
    for i = 1, #self.roleViewLs do
      if self.roleViewLs[i] ~= nil then
        self.roleViewLs[i]:OnRelease()
      end
    end
  end
  self.roleViewLs = nil
  if self.targetAvatarLs ~= nil then
    for i = 1, #self.targetAvatarLs do
      if self.targetAvatarLs[i] ~= nil then
        self.targetAvatarLs[i]:OnRelease()
      end
    end
  end
  self.targetAvatarLs = nil
  if self.slotViewL ~= nil then
    self.slotViewLs = nil
  end
  if self.BuffViewLs ~= nil then
    for i = 1, #self.BuffViewLs do
      if self.BuffViewLs[i] ~= nil then
        self.BuffViewLs[i]:OnRelease()
      end
    end
  end
  self.BuffViewLs = nil
  self.BuffBusyDic = nil
  self.BuffFreeLs = nil
  self.greenColor = nil
  self.Gameing = nil
  self.BagMgr = nil
  self.mapMgr = nil
  self.goodsdata = nil
  if self.EnergyUI.EnergyItemLs ~= nil then
    for i, v in pairs(self.EnergyUI.EnergyItemLs) do
      v:OnRelease()
    end
  end
  self.EnergyUI = nil
  if self.EventUI.EventDesUILS ~= nil then
    for i = 1, #self.EventUI.EventDesUILS do
      if self.EventUI.EventDesUILS[i] ~= nil then
        self.EventUI.EventDesUILS[i]:OnRelease()
      end
    end
  end
  self.EventUI.EventDesUILS = nil
  self.curShowGlobalEvent = nil
  self.EventUI = nil
  if self.VigilantUI.tweenVigiBar ~= nil then
    LuaDOTweenUtils.Kill(self.VigilantUI.tweenVigiBar)
    self.VigilantUI.tweenVigiBar = nil
  end
  if self.VigilantUI.DesItemLs ~= nil then
    for i = 1, #self.VigilantUI.DesItemLs do
      if self.VigilantUI.DesItemLs[i] ~= nil then
        self.VigilantUI.DesItemLs[i]:OnRelease()
      end
    end
  end
  self.VigilantUI.DesItemLs = nil
  self.VigilantUI = nil
  if self.InteractiveFreeLs ~= nil then
    for i = 1, #self.InteractiveFreeLs do
      if self.InteractiveFreeLs[i] ~= nil then
        self.InteractiveFreeLs[i]:OnRelease()
      end
    end
  end
  self.InteractiveFreeLs = nil
  if self.InteractiveLsUI ~= nil then
    for i, v in pairs(self.InteractiveLsUI) do
      v:OnRelease()
    end
  end
  self.InteractiveLsUI = nil
  if self.AttackBenefitInfoItemLs ~= nil then
    for i = 1, #self.AttackBenefitInfoItemLs do
      if self.AttackBenefitInfoItemLs[i] ~= nil then
        self.AttackBenefitInfoItemLs[i]:OnRelease()
      end
    end
  end
  self.AimUI = nil
  DZStoreUtils.selectQuestGroupId = nil
  DZStoreUtils.selectQuestTargetId = nil
  self.changeCountdownColor = nil
  for i, v in pairs(self.questItemList) do
    gfdestroy(v.mUIRoot.gameObject)
  end
  self.questItemList = nil
  self.playerReceiveInputComp = nil
  if self.roomQuestItem ~= nil then
    self.roomQuestItem:OnRelease()
    self.roomQuestItem = nil
  end
  if self.ui.AirUI.Detail ~= nil then
    self.ui.AirUI.Detail:OnRelease()
  end
  if self.activeOxygen then
    self.oxygenGameplayId = nil
    self.airMax = nil
    self.airSegmentRed = nil
    self.airSegmentBlue = nil
    self.airSegmentRedColor = nil
    self.airSegmentYellowColor = nil
    self.airSegmentBlueColor = nil
  end
  self.activeOxygen = nil
  self.questId = nil
  if self.dzType == DzTypeEnum.DzExplore then
    self.exploreIndex = nil
    self.beaconNumMax = nil
  end
  self.dzType = nil
  self.window2GameObject = nil
  self.showWindow = nil
  self.openPickPanel = nil
  self.ui = nil
  self.mview = nil
end
function UIDarkMainPanelInGame:SetBox()
  self.ui.mAnim_BoxAnim:SetTrigger("FadeOut")
  self.mTran_BoxBool = true
end
function UIDarkMainPanelInGame:EnterTargetLs()
  local itemtable = CS.SysMgr.dzPlayerMgr.MainPlayer.AttackTargetLs
  if itemtable.Count > 0 then
    for i = 0, itemtable.Count - 1 do
      local index = i + 1
      local itemView
      if self.targetAvatarLs[index] == nil then
        itemView = DarkTargetAvatar.New()
        itemView:InitCtrl(self.AimUI.mTran_TargetRoot, self)
        self.targetAvatarLs[index] = itemView
      else
        itemView = self.targetAvatarLs[index]
      end
      local isTarget = CS.SysMgr.dzPlayerMgr.MainPlayer.TargetAttack == itemtable[i]
      itemView:SetData(itemtable[i], isTarget)
      if isTarget then
        self:ShowTargetAttackInfoItem(itemtable[i])
      end
    end
  end
end
function UIDarkMainPanelInGame:ShowTargetAttackInfoItem(target)
  if target == nil then
    return
  end
  if CS.DarkUnitWorld.AttackHelper.CanAttack(target) then
    setactive(self.AimUI.mTran_AttackRoot.gameObject, true)
    local bestDis = CS.DarkUnitWorld.AttackHelper.IsOptimumRange(target)
    local isUnder = CS.DarkUnitWorld.AttackHelper.IsUnderBattle()
    local isBehind = CS.DarkUnitWorld.AttackHelper.IsSneakAttack(target)
    self:AddAttackItem(1, isBehind, target)
    self:AddAttackItem(2, isUnder, target)
    self:AddAttackItem(3, bestDis, target)
  else
    setactive(self.AimUI.mTran_AttackRoot.gameObject, false)
  end
end
function UIDarkMainPanelInGame:AddAttackItem(index, show, target)
  local itemUI
  if self.AttackBenefitInfoItemLs[index] == nil then
    itemUI = AttackBenefitInfoItem.New()
    itemUI:InitCtrl(self.AimUI.mTran_AttackRoot, 1)
    self.AttackBenefitInfoItemLs[index] = itemUI
  else
    itemUI = self.AttackBenefitInfoItemLs[index]
  end
  if show then
    itemUI:SetDetail(index, target)
  else
    itemUI:Close()
  end
end
function UIDarkMainPanelInGame:ExitTargetLs()
  for i = 1, #self.targetAvatarLs do
    self.targetAvatarLs[i]:Close()
  end
end
function UIDarkMainPanelInGame:SetGlobalVigilant(vigilant)
  if vigilant == nil then
    return
  end
  self.VigilantUI.mText_VigilantValue.text = vigilant.level
  self.VigilantUI.mText_VigiLevel.text = vigilant.level
  self.VigilantUI.mText_VigiPrecent.text = vigilant.value .. "/" .. vigilant.maxValue
  local afterPcr = vigilant.CurLevelProgress
  local beforePcr = self.VigilantUI.mImg_VigiBarValue.fillAmount
  if self.VigilantUI.tweenVigiBar ~= nil then
    LuaDOTweenUtils.Kill(self.VigilantUI.tweenVigiBar)
    self.VigilantUI.tweenVigiBar = nil
  end
  if afterPcr > beforePcr then
    self.VigilantUI.mImg_VigiBarAddValue.fillAmount = afterPcr
    self.VigilantUI.tweenVigiBar = LuaDOTweenUtils.DoImageFillAmount(self.VigilantUI.mImg_VigiBarValue, beforePcr, afterPcr, 0.6)
  else
    self.VigilantUI.mImg_VigiBarValue.fillAmount = afterPcr
    self.VigilantUI.tweenVigiBar = LuaDOTweenUtils.DoImageFillAmount(self.VigilantUI.mImg_VigiBarAddValue, beforePcr, afterPcr, 0.6)
  end
  for i = 1, #self.VigilantUI.DesItemLs do
    self.VigilantUI.DesItemLs[i]:Close()
  end
  local showDesItem = 0
  local showCount = vigilant.desDetailItemNameLs.Count - 1
  for i = 0, showCount do
    showDesItem = showDesItem + 1
    if self.VigilantUI.DesItemLs[showDesItem] == nil then
      local buffView = VigilantDesItem.New()
      buffView:InitCtrl(self.VigilantUI.mTran_VigilantDes, self.VigilantUI.mTran_InfoChild)
      self.VigilantUI.DesItemLs[showDesItem] = buffView
    end
    self.VigilantUI.DesItemLs[showDesItem]:SetDetail(vigilant.desDetailItemNameLs[i])
  end
end
function UIDarkMainPanelInGame:SetBlueEnergyValue(value)
  self.EnergyUI.mText_BlueEnergy.text = value
  if value == 0 then
    self.EnergyUI.mImg_BlueEnergy.fillAmount = 0
  else
    local max = TableData.listDarkzonePropertyDescDatas:GetDataById(EnumDarkzoneProperty.Property.DzEnergy2).maximum_effect
    self.EnergyUI.mImg_BlueEnergy.fillAmount = value / max
  end
end
function UIDarkMainPanelInGame:SetGlobalEvent(globalEventLS)
  if globalEventLS.Count == 0 then
    self.curShowGlobalEvent = nil
    setactive(self.ui.mBind_Event.gameObject, false)
  else
    setactive(self.ui.mBind_Event.gameObject, true)
    self.EventUI.mAni_Event:SetTrigger("FadeIn")
    if globalEventLS.Count == 1 then
      setactive(self.EventUI.mText_ShowEventTime.gameObject, true)
      setactive(self.EventUI.mText_ShowEventCount.transform.parent.gameObject, false)
      self.curShowGlobalEvent = globalEventLS[0]
      if self.curShowGlobalEvent.forever then
        self.EventUI.mText_ShowEventTime.text = TableData.GetHintById(903470)
      else
        self.EventUI.mText_ShowEventTime.text = self.curShowGlobalEvent:TimeStr()
      end
    else
      self.curShowGlobalEvent = nil
      setactive(self.EventUI.mText_ShowEventTime.gameObject, false)
      setactive(self.EventUI.mText_ShowEventCount.transform.parent.gameObject, true)
      self.EventUI.mText_ShowEventCount.text = globalEventLS.Count
    end
    for i = 1, #self.EventUI.EventDesUILS do
      self.EventUI.EventDesUILS[i]:Close()
    end
    local showDesItem = 0
    local showCount = globalEventLS.Count - 1
    for i = 0, showCount do
      showDesItem = i + 1
      if self.EventUI.EventDesUILS[showDesItem] == nil then
        local buffView = DarkZoneGlobalEventItem.New()
        buffView:InitCtrl(self.EventUI.mTran_EventDes, self.EventUI.mTran_DesItem.gameObject)
        self.EventUI.EventDesUILS[showDesItem] = buffView
      end
      self.EventUI.EventDesUILS[showDesItem]:SetDetail(globalEventLS[i])
    end
  end
end
function UIDarkMainPanelInGame:SetBuffLsView(showBuffLs)
  for k, v in pairs(self.BuffBusyDic) do
    v:Mark(false)
  end
  local viewIndex = 1
  for i = showBuffLs.Count - 1, 0, -1 do
    if viewIndex > CS.DarkUnitWorld.DarkPlayerData.showBuffMax then
      break
    end
    local buffIndex = showBuffLs[i]:GetBuffIndex()
    local buffView = self.BuffBusyDic[buffIndex]
    if buffView ~= nil then
      buffView:Mark(true)
    end
    viewIndex = viewIndex + 1
  end
  for i = 1, #self.BuffViewLs do
    local buffView = self.BuffViewLs[i]
    buffView:CheckMark()
  end
  viewIndex = 1
  for i = showBuffLs.Count - 1, 0, -1 do
    if viewIndex > CS.DarkUnitWorld.DarkPlayerData.showBuffMax then
      break
    end
    local host = showBuffLs[i]
    local buffIndex = showBuffLs[i]:GetBuffIndex()
    local buffView = self.BuffBusyDic[buffIndex]
    if buffView == nil then
      local freeCount = #self.BuffFreeLs
      buffView = self.BuffFreeLs[freeCount]
      self.BuffFreeLs[freeCount] = nil
      self.BuffBusyDic[buffIndex] = buffView
      buffView:SetHost(host, self.BuffBusyDic, self.BuffFreeLs)
    end
    buffView.obj.transform:SetSiblingIndex(viewIndex - 1)
    buffView:Mark(true)
    viewIndex = viewIndex + 1
  end
end
function UIDarkMainPanelInGame:SetRoleList()
  local roleTable = CS.SysMgr.dzPlayerMgr.MainPlayerData.nowPropertyDataLs
  local leaderId = CS.SysMgr.dzPlayerMgr.MainPlayerData.Leader
  for i = 0, roleTable.Count - 1 do
    local index = i + 1
    local roleView = self.roleViewLs[index]
    roleView:SetData(roleTable[i], roleTable[i].Id == leaderId, index)
  end
end
function UIDarkMainPanelInGame.OnHideMainPanelFunc()
  setactive(self.ui.mTran_Root, false)
end
function UIDarkMainPanelInGame.OnShowBubbleMsg(msg)
  local hintId = msg.Sender
  local showTime = msg.Content
  local text = TableData.GetHintById(hintId)
  self:ShowBubbleMsg(text, showTime)
end
function UIDarkMainPanelInGame:ShowBubbleMsg(text, showTime)
  self.bubbleMsgCtrl:Show(text, showTime)
end
function UIDarkMainPanelInGame:HideBubbleMsg()
  self.bubbleMsgCtrl:Hide()
end
function UIDarkMainPanelInGame.OnDzAttacked()
  self:HideBubbleMsg()
end
function UIDarkMainPanelInGame.OnDzBeAttacked()
  self:HideBubbleMsg()
end
function UIDarkMainPanelInGame.OnDzWin()
  self:HideBubbleMsg()
end
function UIDarkMainPanelInGame.OnDzLose()
  self:HideBubbleMsg()
end
function UIDarkMainPanelInGame:OnRelease()
  self.Darkzone_BunkerIn = nil
  self.Darkzone_BunkerOut = nil
  if self.aimFadeDelay ~= nil then
    self.aimFadeDelay:Stop()
    self.aimFadeDelay = nil
  end
  if self.delayAirFadeOut ~= nil then
    self.delayAirFadeOut:Stop()
    self.delayAirFadeOut = nil
  end
  if self.delayInteractiveProgressFadeOut ~= nil then
    self.delayInteractiveProgressFadeOut:Stop()
    self.delayInteractiveProgressFadeOut = nil
  end
  if self.delayInteractiveProgressHide ~= nil then
    self.delayInteractiveProgressHide:Stop()
    self.delayInteractiveProgressHide = nil
  end
  self.interactiveObjs = nil
  self.grassWarningObj = nil
  if self.delayAimBtnFadeOut ~= nil then
    self.delayAimBtnFadeOut:Stop()
    self.delayAimBtnFadeOut = nil
  end
  if self.delayCoverStateBtnFadeOut ~= nil then
    self.delayCoverStateBtnFadeOut:Stop()
    self.delayCoverStateBtnFadeOut = nil
  end
  self.bubbleMsgCtrl:Release()
  self.bubbleMsgCtrl = nil
end
