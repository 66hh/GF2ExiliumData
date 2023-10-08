require("UI.UniTopbar.UITopResourceBar")
require("UI.BattlePass.UIBattlePassGlobal")
require("UI.BattlePass.Item.BpTopBarItem")
require("UI.BattlePass.BattleMain.UICollectionPanel")
require("UI.BattlePass.BattleMain.UIBattleMainPanel")
require("UI.UIBasePanel")
require("UI.BattlePass.BattleMain.UIBpMissionPanel")
require("UI.BattlePass.BattleMain.UIBpShopPanel")
require("UI.BattlePass.UIBattlePassGlobal")
require("UI.FacilityBarrackPanel.FacilityBarrackGlobal")
UIBattlePassPanel = class("UIBattlePassPanel", UIBasePanel)
UIBattlePassPanel.__index = UIBattlePassPanel
function UIBattlePassPanel:ctor(csPanel)
  UIBattlePassPanel.super.ctor(UIBattlePassPanel, csPanel)
  self.mCSPanel = csPanel
  csPanel.Is3DPanel = true
end
function UIBattlePassPanel:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBack.transform).onClick = function()
    self:Close()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnHome.gameObject).onClick = function()
    self:OnCommanderCenter()
  end
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_BtnBack)
end
function UIBattlePassPanel:OnInit(root, data)
  self.mIsFirstShow = true
  self.mHasEnterMainPanel = false
  self.mIsShowForceCommand = false
  self.RedPointType = {
    RedPointConst.BattlePass
  }
  self.mTabItems = {}
  self.mTabPanels = {}
  self.mCurItemPanel = nil
  local mainPanel = UIBattleMainPanel.New()
  mainPanel:InitCtrl(self.ui.mScrollListChild_Main.childItem, self.ui.mScrollListChild_Main.transform)
  table.insert(self.mTabPanels, mainPanel)
  table.insert(self.mTabItems, self.ui.mScrollListChild_Main)
  local bpMissionPanel = UIBpMissionPanel.New()
  bpMissionPanel:InitCtrl(self.ui.mScrollListChild_Mission.childItem, self.ui.mScrollListChild_Mission.transform)
  table.insert(self.mTabPanels, bpMissionPanel)
  table.insert(self.mTabItems, self.ui.mScrollListChild_Mission)
  local collectionPanel = UICollectionPanel.New()
  collectionPanel:InitCtrl(self.ui.mScrollListChild_Collection.childItem, self.ui.mScrollListChild_Collection.transform)
  table.insert(self.mTabPanels, collectionPanel)
  table.insert(self.mTabItems, self.ui.mScrollListChild_Collection)
  local bpShopPanel = UIBpShopPanel.New()
  bpShopPanel:InitCtrl(self.ui.mScrollListChild_Shop.childItem, self.ui.mScrollListChild_Shop.transform)
  table.insert(self.mTabPanels, bpShopPanel)
  table.insert(self.mTabItems, self.ui.mScrollListChild_Shop)
  if data ~= nil and data.Length > 0 then
    self.mIndex = data[0]
  else
    self.mIndex = UIBattlePassGlobal.ButtonType.MainPanel
  end
  self:ShowInfo()
  setactive(self.mTabBtns[UIBattlePassGlobal.ButtonType.Collection]:GetRoot(), collectionPanel:GetCollectNum() ~= 0)
  self.mCSPanel.m_ExitAnimators = CS.LuaUIUtils.GetExitAllAnimator(self.ui.mUIRoot.transform)
  bpMissionPanel:SetTopBtnRedPointFun(function()
    self.mTabBtns[UIBattlePassGlobal.ButtonType.Mission]:UpdateRedPoint(NetCmdBattlePassData:UpdateRedPointCount() > 0)
  end)
  function self.OnBattlePassResfresh()
    if self.mCSPanel.UIGroup:GetTopUI() ~= self.mCSPanel then
      return
    end
    UIManager.OpenUI(UIDef.UIBattlePassLevelUpDialog)
  end
  function self.RefreshFun2()
    if self.mTabBtns[UIBattlePassGlobal.ButtonType.Mission] then
      self.mTabBtns[UIBattlePassGlobal.ButtonType.Mission]:UpdateRedPoint(NetCmdBattlePassData:UpdateRedPointCount() > 0)
    end
  end
  function self.BpResfresh()
    if self.mCurItemPanel ~= nil then
      self.mCurItemPanel:OnRefresh()
    end
  end
  function self.UserTapScreen()
    if self.mIsOpen == false and self.mIsShowForceCommand == false and self.mCSPanel.UIGroup:GetTopUI() == self.mCSPanel then
      self.mIsShowForceCommand = true
      local title = TableData.GetHintById(208)
      MessageBox.ShowMidBtn(title, TableData.GetHintById(192095), nil, nil, function()
        self:OnCommanderCenter()
      end)
    end
  end
  function self.OnUpdateItem()
    if self.topRes ~= nil then
      self.topRes:OnUpdateItemData()
    end
  end
  MessageSys:AddListener(UIEvent.BattlePassLevelUp, self.OnBattlePassResfresh)
  MessageSys:AddListener(UIEvent.BpResfresh, self.BpResfresh)
  MessageSys:AddListener(UIEvent.BpOnLookClick, self.RefreshFun2)
  MessageSys:AddListener(UIEvent.UserTapScreen, self.UserTapScreen)
  RedPointSystem:GetInstance():UpdateRedPointByType(RedPointConst.BattlePass)
  MessageSys:AddListener(CS.GF2.Message.CampaignEvent.ResInfoUpdate, self.OnUpdateItem)
  self.lastSceneType = SceneSys.CurSceneType
end
function UIBattlePassPanel:InitTopBar()
  self.mTopBarIds = {
    TableDataBase.GlobalSystemData.BattlepassResourcesMain,
    TableDataBase.GlobalSystemData.BattlepassResourcesTask,
    TableDataBase.GlobalSystemData.BattlepassResourcesCollection,
    TableDataBase.GlobalSystemData.BattlepassResourcesShop
  }
end
function UIBattlePassPanel:InitTabBtn()
  self.mTabBtns = {}
  for i = 1, UIBattlePassGlobal.ButtonType.Shop do
    local item = BpTopBarItem.New()
    item:InitCtrl(self.ui.mScrollListChild_GrpTopMidBtn.transform)
    item:SetData(i, function()
      UIBattlePassGlobal.CurBpMainpanelRefreshType = UIBattlePassGlobal.BpMainpanelRefreshType.ClickTab
      self:OnClickTab(i)
    end)
    if i == UIBattlePassGlobal.ButtonType.MainPanel then
      item:SetGlobalTab(71)
    elseif i == UIBattlePassGlobal.ButtonType.Mission then
      item:UpdateRedPoint(NetCmdBattlePassData:UpdateRedPointCount() > 0)
      item:SetGlobalTab(72)
    elseif i == UIBattlePassGlobal.ButtonType.Collection then
      item:SetGlobalTab(73)
    elseif i == UIBattlePassGlobal.ButtonType.Shop then
      item:SetGlobalTab(74)
    end
    item:SetInteractable(true)
    table.insert(self.mTabBtns, item)
  end
  self.mTabBtns[UIBattlePassGlobal.ButtonType.MainPanel]:SetInteractable(false)
end
function UIBattlePassPanel:OnClickTab(index)
  if self.mHasEnterMainPanel == false and index == UIBattlePassGlobal.ButtonType.MainPanel then
    UIBattlePassGlobal.CurBpMainpanelRefreshType = UIBattlePassGlobal.BpMainpanelRefreshType.FristShow
    self.mHasEnterMainPanel = true
  end
  self.mIndex = index
  UIBattlePassGlobal.TabIndx = self.mIndex
  for i = 1, #self.mTabItems do
    setactive(self.mTabItems[i], false)
  end
  if index <= #self.mTabItems then
    setactive(self.mTabItems[index], true)
  end
  for _, item in pairs(self.mTabPanels) do
    item:Hide()
  end
  if self.mTabPanels[index] ~= nil then
    self.mCurItemPanel = self.mTabPanels[index]
    self.mCurItemPanel:Show()
  end
  for i = 1, #self.mTabBtns do
    local tabBtn = self.mTabBtns[i]
    tabBtn:SetInteractable(true)
  end
  if self.mTabBtns[index] ~= nil then
    self.mTabBtns[index]:SetInteractable(false)
  end
  if self.topRes == nil then
    self.topRes = UITopResourceBar.New()
    self.topRes:Init(self.mUIRoot, TableDataBase.GlobalSystemData.BattlepassResourcesMain, true)
  end
  if UIBattlePassGlobal.ShowModel ~= nil then
    if self.mIndex == UIBattlePassGlobal.ButtonType.MainPanel then
      UIBattlePassGlobal.ShowModel:Show(true)
      local bpRewardShow = TableData.listBpRerardShowDatas:GetDataById(NetCmdBattlePassData.CurSeason.MaxReward)
      if bpRewardShow ~= nil then
        local pos = string.split(bpRewardShow.position1, ",")
        local rotation = string.split(bpRewardShow.rotation1, ",")
        if not CS.LuaUtils.IsNullOrDestroyed(UIBattlePassGlobal.ShowModel.gameObject) then
          setposition(UIBattlePassGlobal.ShowModel.transform, Vector3(tonumber(pos[1]), tonumber(pos[2]), tonumber(pos[3])))
          setrotation(UIBattlePassGlobal.ShowModel.transform, CS.UnityEngine.Quaternion.Euler(Vector3(tonumber(rotation[1]), tonumber(rotation[2]), tonumber(rotation[3]))))
          local canvas = UISystem.BpCharacterCanvas
          local bpLight = canvas:GetComponent(typeof(CS.BPLight))
          if bpLight ~= nil then
            bpLight:SetGun(self.mIsGun)
            local light_rocation = string.split(bpRewardShow.light_rocation1, ",")
            bpLight:SetRation(tonumber(light_rocation[1]), tonumber(light_rocation[2]), tonumber(light_rocation[3]))
            bpLight:SetLightColAnIntensity(bpRewardShow.light_colour1, bpRewardShow.light_intensity1)
          end
          local effectPos = string.split(bpRewardShow.button_position1, ",")
          setposition(UIBattlePassGlobal.EffectNumObj.transform, Vector3(tonumber(effectPos[1]), tonumber(effectPos[2]), tonumber(effectPos[3])))
        else
          self:UpdateModel()
        end
      end
      if not CS.LuaUtils.IsNullOrDestroyed(UIBattlePassGlobal.ShowModel) then
        UIBattlePassGlobal.ShowModel:PlayEffect()
      end
    else
      UIBattlePassGlobal.ShowModel:Show(false)
    end
  end
  local currencyParent = CS.TransformUtils.DeepFindChild(self.mUIRoot, "GrpCurrency/TopResourceBarRoot(Clone)")
  if currencyParent ~= nil then
    self.topRes:Close()
    self.topRes:Release()
    self.topRes:UpdateCurrencyContent(currencyParent, self.mTopBarIds[index])
  end
  MessageSys:SendMessage(GuideEvent.OnTabSwitched, UIDef.UIBattlePassPanel, self.mTabBtns[index]:GetGlobalTab())
end
function UIBattlePassPanel:IsReadyToStartTutorial()
  return UIBattlePassGlobal.IsVideoPlay == false
end
function UIBattlePassPanel:OnShowStart()
  self:UpdateModel()
  local status = NetCmdBattlePassData.BattlePassStatus
  if status ~= CS.ProtoObject.BattlepassType.None then
    self.ui.mAni_Root:SetTrigger("FadeIn")
  end
end
function UIBattlePassPanel:OnBackFrom()
  self.ui.mAni_Root:Rebind()
  self.lastSceneType = SceneSys.CurSceneType
  self.mCurItemPanel:OnBackFrom()
  self.ui.mAni_Root:SetTrigger("FadeIn")
end
function UIBattlePassPanel:OnHide()
  if self.mCSPanel.UIGroup:GetTopUI() ~= nil and self.mCSPanel.UIGroup:GetTopUI().UIDefine.UIType == UIDef.UIStorePanel then
    UIManager.EnableBattlePass(false)
  end
  if self.mCSPanel.UIGroup:GetTopUI().UIDefine.UIType ~= UIDef.UIBattlePassUnlockPanel and self.mCSPanel.UIGroup:GetTopUI().UIDefine.UIType ~= UIDef.UIChrWeaponPowerUpPanelV4 then
    self.lastSceneType = SceneSys.CurSceneType
  end
end
function UIBattlePassPanel:OnShowFinish()
  if self.mIsFirstShow == true then
    self:OnClickTab(self.mIndex)
  elseif self.mIndex == UIBattlePassGlobal.ButtonType.Collection and self.mCurItemPanel ~= nil then
    self.mCurItemPanel:OnRefresh()
  end
  self.mIsFirstShow = false
  SceneSys:SwitchVisible(EnumSceneType.BattlePass)
  UIManager.EnableBattlePass(true)
  if self.mIndex == UIBattlePassGlobal.ButtonType.MainPanel and UIBattlePassGlobal.ShowModel ~= nil then
    UIBattlePassGlobal.ShowModel:Show(true)
  end
  if not CS.LuaUtils.IsNullOrDestroyed(UIBattlePassGlobal.EffectNumObj) then
    setactive(UIBattlePassGlobal.EffectNumObj, true)
    setactive(UIBattlePassGlobal.EffectNumObjRoot, true)
    if UIBattlePassGlobal.IsVideoPlay then
      setactive(UIBattlePassGlobal.EffectNumObjRoot, false)
    end
  end
  self.mTabBtns[UIBattlePassGlobal.ButtonType.MainPanel]:UpdateRedPoint(NetCmdBattlePassData:UpdateMainPanelRedPointCount() > 0)
  if UIBattlePassGlobal.ShowModel ~= nil then
    if self.mIndex == UIBattlePassGlobal.ButtonType.MainPanel then
      UIBattlePassGlobal.ShowModel:Show(true)
    else
      UIBattlePassGlobal.ShowModel:Show(false)
    end
  end
  if NetCmdBattlePassData.PlayLevelUpEffect == true then
    UIManager.OpenUI(UIDef.UIBattlePassLevelUpDialog)
  end
  UIBattlePassGlobal.UnlockPanelBlackTime = 0.1
  UIBattlePassGlobal.BpShowSourceType = UIBattlePassGlobal.BpShowSource.MainPanel
  if UIBattlePassGlobal.BpBuyPromote2 == true then
    UIBattlePassGlobal.BpBuyPromote2 = false
    MessageSys:SendMessage(UIEvent.BpPromt2, nil)
  end
end
function UIBattlePassPanel:OnRecover()
  UIBattlePassGlobal.CurBpMainpanelRefreshType = UIBattlePassGlobal.BpMainpanelRefreshType.OnTop
  self:OnClickTab(self.mIndex)
end
function UIBattlePassPanel:OnTop()
  UIManager.EnableBattlePass(true)
  if self.mIndex == UIBattlePassGlobal.ButtonType.MainPanel then
    UIBattlePassGlobal.ShowModel:Show(true)
    local bpRewardShow = TableData.listBpRerardShowDatas:GetDataById(NetCmdBattlePassData.CurSeason.MaxReward)
    if bpRewardShow ~= nil then
      local pos = string.split(bpRewardShow.position1, ",")
      local rotation = string.split(bpRewardShow.rotation1, ",")
      setposition(UIBattlePassGlobal.ShowModel.transform, Vector3(tonumber(pos[1]), tonumber(pos[2]), tonumber(pos[3])))
      setrotation(UIBattlePassGlobal.ShowModel.transform, CS.UnityEngine.Quaternion.Euler(Vector3(tonumber(rotation[1]), tonumber(rotation[2]), tonumber(rotation[3]))))
      local canvas = UISystem.BpCharacterCanvas
      local bpLight = canvas:GetComponent(typeof(CS.BPLight))
      if bpLight ~= nil then
        bpLight:SetGun(self.mIsGun)
        local light_rocation = string.split(bpRewardShow.light_rocation1, ",")
        bpLight:SetRation(tonumber(light_rocation[1]), tonumber(light_rocation[2]), tonumber(light_rocation[3]))
        bpLight:SetLightColAnIntensity(bpRewardShow.light_colour1, bpRewardShow.light_intensity1)
      end
      local effectPos = string.split(bpRewardShow.button_position1, ",")
      setposition(UIBattlePassGlobal.EffectNumObj.transform, Vector3(tonumber(effectPos[1]), tonumber(effectPos[2]), tonumber(effectPos[3])))
    end
  end
  if self.mIndex == UIBattlePassGlobal.ButtonType.Mission then
    self.mTabPanels[self.mIndex]:Refresh(true)
  end
  local currencyParent = CS.TransformUtils.DeepFindChild(self.mUIRoot, "GrpCurrency/TopResourceBarRoot(Clone)")
  if currencyParent ~= nil then
    self.topRes:Release()
    self.topRes:UpdateCurrencyContent(currencyParent, self.mTopBarIds[self.mIndex])
  end
end
function UIBattlePassPanel:OnBattlePassLevelUp()
  if self.mCurItemPanel ~= nil then
    self.mCurItemPanel:Show()
  end
end
function UIBattlePassPanel:ShowInfo()
  UIBattlePassGlobal.IsVideoPlay = false
  self:InitTopBar()
  self:InitTabBtn()
  self:FirstEnterPlayVideo()
end
function UIBattlePassPanel:OnCameraStart()
  if UIBattlePassGlobal.ShowModel ~= nil and self.mIndex == UIBattlePassGlobal.ButtonType.MainPanel and UIBattlePassGlobal.IsBpOutSide == UIBattlePassGlobal.BpOutSideType.bp then
    UIBattlePassGlobal.ShowModel:Show(true)
  end
  UIBattlePassGlobal.IsBpOutSide = UIBattlePassGlobal.BpOutSideType.bp
  return 0
end
function UIBattlePassPanel:OnCameraBack()
  return 0
end
function UIBattlePassPanel:OnUpdate()
  if self.mCurItemPanel ~= nil then
    self.mCurItemPanel:OnUpdate()
  end
  self.mIsOpen = NetCmdSimulateBattleData:CheckPlanIsOpen(CS.GF2.Data.PlanType.PlanFunctionBattlepass)
end
function UIBattlePassPanel:Close()
  UIManager.CloseUISelf(self)
end
function UIBattlePassPanel:OnClose()
  self:UnRegistrationAllKeyboard()
  for i = 1, #self.mTabPanels do
    self.mTabPanels[i]:Release()
  end
  if self.mGunModelObj ~= nil then
    self.mGunModelObj:Destroy()
  end
  for _, item in pairs(self.mTabBtns) do
    gfdestroy(item:GetRoot())
  end
  for _, item in pairs(self.mTabPanels) do
    gfdestroy(item:Release())
  end
  if self.lastSceneType ~= nil then
    SceneSys:SwitchVisible(self.lastSceneType or EnumSceneType.CommandCenter)
  end
  for i = 1, #self.mTabItems do
    setactive(self.mTabItems[i], false)
  end
  self.lastSceneType = nil
  UIManager.EnableBattlePass(false)
  if UIBattlePassGlobal.ShowModel ~= nil then
    UIBattlePassGlobal.ShowModel:Destroy()
  end
  MessageSys:RemoveListener(UIEvent.BpResfresh, self.BpResfresh)
  MessageSys:RemoveListener(UIEvent.BattlePassLevelUp, self.OnBattlePassResfresh)
  MessageSys:RemoveListener(UIEvent.BpOnLookClick, self.RefreshFun2)
  MessageSys:RemoveListener(UIEvent.UserTapScreen, self.UserTapScreen)
  MessageSys:RemoveListener(CS.GF2.Message.CampaignEvent.ResInfoUpdate, self.OnUpdateItem)
  ResourceManager:DestroyInstance(UIBattlePassGlobal.EffectNumObj)
  ResourceManager:DestroyInstance(UIBattlePassGlobal.MoveAssetObj)
  ResourceManager:DestroyInstance(UISystem.BpCharacterCanvas)
end
function UIBattlePassPanel:FirstEnterPlayVideo()
  local StartSeason = function()
    NetCmdBattlePassData:SendBattlepassFirstIn(function()
      NetCmdBattlePassData.BattlePassStatus = CS.ProtoObject.BattlepassType.Base
      RedPointSystem:GetInstance():UpdateRedPointByType(RedPointConst.BattlePass)
      if self.mCurItemPanel ~= nil then
        self.mCurItemPanel:OnRefresh()
        if self.mIndex == UIBattlePassGlobal.ButtonType.MainPanel then
          self.mCurItemPanel:EnterPanelRefreshScroll()
        end
      end
      self.ui.mAni_Root:SetTrigger("FadeIn_Black")
      TimerSys:DelayCall(0.5, function()
        setactive(self.ui.mTran_Black, false)
        UIBattlePassGlobal.IsVideoPlay = false
        MessageSys:SendMessage(UIEvent.UIBpCanStartGuide, nil)
      end)
      if self.mIndex == UIBattlePassGlobal.ButtonType.MainPanel then
        TimerSys:DelayFrameCall(10, function(data)
          setactive(self.ui.mScrollListChild_Main.transform, false)
          setactive(self.ui.mScrollListChild_Main.transform, true)
          setactive(UIBattlePassGlobal.EffectNumObjRoot, true)
        end)
      end
    end)
  end
  local PlayVideo = function()
    if NetCmdBattlePassData.CurSeason.EntryAnimationResource == "" then
      StartSeason()
    else
      setactive(self.ui.mTran_Black, true)
      UIBattlePassGlobal.IsVideoPlay = true
      CS.CriWareVideoController.StartPlay(NetCmdBattlePassData.CurSeason.EntryAnimationResource, CS.CriWareVideoType.eVideoPath, function()
        StartSeason()
      end, true)
    end
  end
  local status = NetCmdBattlePassData.BattlePassStatus
  if status == CS.ProtoObject.BattlepassType.None then
    PlayVideo()
  end
end
function UIBattlePassPanel:OnCommanderCenter()
  UIManager.JumpToMainPanel()
end
function UIBattlePassPanel:UpdateModel()
  UIManager.EnableBattlePass(true)
  UIBattlePassGlobal.ModelRoot = UISystem.BpCharacterCanvas
  self.ui.mCanvas_Root.blocksRaycasts = false
  UIBattlePassGlobal.ShowModel = nil
  local storeGoodData = TableData.listStoreGoodDatas:GetDataById(NetCmdBattlePassData.CurSeason.MaxReward)
  if storeGoodData ~= nil and storeGoodData.Itemtype == GlobalConfig.ItemType.GunType then
    CS.UIBattlePassGunModelManager.Instance:GetBattlePassGunModel(storeGoodData.Frame, storeGoodData.Frame, true, function(model)
      self:SetGunAndLightPos(model, true)
    end, false)
  end
  if storeGoodData ~= nil and storeGoodData.Itemtype == GlobalConfig.ItemType.Weapon then
    CS.UIBattlePassGunModelManager.Instance:GetBattlePassWeaponModel(storeGoodData.Frame, true, function(model)
      self:SetGunAndLightPos(model, false)
    end, false)
  end
  if storeGoodData ~= nil and storeGoodData.Itemtype == GlobalConfig.ItemType.Costume then
    local clothesData = TableDataBase.listClothesDatas:GetDataById(storeGoodData.Frame)
    if clothesData ~= nil then
      CS.UIBattlePassGunModelManager.Instance:GetBattlePassGunModel(clothesData.gun, clothesData.model_id, true, function(model)
        self:SetGunAndLightPos(model, false)
      end, false)
    end
  end
  local bgImage = UISystem.BGImage
  bgImage.sprite = IconUtils.GetBpBgIcon(NetCmdBattlePassData.CurSeason.SeasonBgResource)
end
function UIBattlePassPanel:SetGunAndLightPos(model, isGun)
  self.mIsGun = isGun
  UIBattlePassGlobal.ShowModel = model
  CS.LuaUIUtils.SetParent(UIBattlePassGlobal.ShowModel.gameObject, UIBattlePassGlobal.ModelRoot.gameObject, true)
  UIBattlePassGlobal.InitEffectNum(function()
    self:OnEffectNumClick()
  end)
  self.ui.mCanvas_Root.blocksRaycasts = true
  self.mBattlePassTargetController = UIBattlePassGlobal.MoveAssetObj.gameObject:GetComponent(typeof(CS.BattlePassTargetController))
  local bpRewardShow = TableData.listBpRerardShowDatas:GetDataById(NetCmdBattlePassData.CurSeason.MaxReward)
  if bpRewardShow ~= nil then
    local pos = string.split(bpRewardShow.position1, ",")
    local rotation = string.split(bpRewardShow.rotation1, ",")
    setposition(UIBattlePassGlobal.ShowModel.transform, Vector3(tonumber(pos[1]), tonumber(pos[2]), tonumber(pos[3])))
    setrotation(UIBattlePassGlobal.ShowModel.transform, CS.UnityEngine.Quaternion.Euler(Vector3(tonumber(rotation[1]), tonumber(rotation[2]), tonumber(rotation[3]))))
    local canvas = UISystem.BpCharacterCanvas
    local bpLight = canvas:GetComponent(typeof(CS.BPLight))
    if bpLight ~= nil then
      bpLight:SetGun(isGun)
      local light_rocation = string.split(bpRewardShow.light_rocation1, ",")
      bpLight:SetRation(tonumber(light_rocation[1]), tonumber(light_rocation[2]), tonumber(light_rocation[3]))
      bpLight:SetLightColAnIntensity(bpRewardShow.light_colour1, bpRewardShow.light_intensity1)
    end
    setscale(UIBattlePassGlobal.EffectNumObj.transform, Vector3(tonumber(bpRewardShow.button_scale1), tonumber(bpRewardShow.button_scale1), tonumber(bpRewardShow.button_scale1)))
    local effectPos = string.split(bpRewardShow.button_position1, ",")
    setposition(UIBattlePassGlobal.EffectNumObj.transform, Vector3(tonumber(effectPos[1]), tonumber(effectPos[2]), tonumber(effectPos[3])))
  end
  if UIBattlePassGlobal.TabIndx ~= UIBattlePassGlobal.ButtonType.MainPanel then
    UIBattlePassGlobal.ShowModel:Show(false)
  end
end
function UIBattlePassPanel:OnEffectNumClick()
  local storeGoodData = TableData.listStoreGoodDatas:GetDataById(NetCmdBattlePassData.CurSeason.MaxReward)
  if storeGoodData == nil then
    return
  end
  if storeGoodData.Itemtype == GlobalConfig.ItemType.GunType then
    local parm = {}
    local gunCmdData = NetCmdTeamData:GetLockGunData(storeGoodData.Frame, true)
    parm[1] = gunCmdData
    parm[2] = FacilityBarrackGlobal.ShowContentType.UIChrBattlePass
    UIManager.OpenUIByParam(UIDef.UIChrPowerUpPanel, parm)
    BarrackHelper.CameraMgr:ChangeCameraStand(BarrackCameraStand.Base, false)
  elseif storeGoodData.Itemtype == GlobalConfig.ItemType.Weapon then
    local weaponCmdData = NetCmdWeaponData:GetWeaponByStcId(storeGoodData.Frame)
    local param = {
      weaponCmdData.stc_id,
      UIWeaponGlobal.WeaponPanelTab.Info,
      true,
      UIWeaponPanel.OpenFromType.BattlePassCollection,
      needReplaceBtn = false
    }
    UIManager.OpenUIByParam(UIDef.UIWeaponPanel, param)
  elseif storeGoodData.Itemtype == GlobalConfig.ItemType.Costume then
    self:JumpSkin(storeGoodData)
  end
  TimerSys:DelayCall(0.5, function()
    if UIBattlePassGlobal.ShowModel ~= nil then
      UIBattlePassGlobal.ShowModel:Show(false)
    end
    UIManager.EnableBattlePass(false)
    TimerSys:DelayCall(0.5, function()
      MessageSys:SendMessage(UIEvent.BpResfresh, nil)
    end)
  end)
  UIBattlePassGlobal.IsBpOutSide = UIBattlePassGlobal.BpOutSideType.bpOutSide
  UIBattlePassGlobal.UnlockPanelBlackTime = 0
end
function UIBattlePassPanel:JumpSkin(storeGoodData)
  local clothesData = TableDataBase.listClothesDatas:GetDataById(storeGoodData.Frame)
  if clothesData ~= nil then
    FacilityBarrackGlobal.CurSkinShowContentType = FacilityBarrackGlobal.ShowContentType.UIBpClothes
    local list = new_array(typeof(CS.System.Int32), 3)
    list[0] = clothesData.gun
    list[1] = FacilityBarrackGlobal.ShowContentType.UIBpClothes
    list[2] = clothesData.id
    local jumpParam = CS.BarrackPresetJumpParam(1, clothesData.gun, clothesData.id, list)
    JumpSystem:Jump(EnumSceneType.Barrack, jumpParam)
  end
end
