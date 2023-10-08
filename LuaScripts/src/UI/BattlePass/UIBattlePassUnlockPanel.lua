require("UI.BattlePass.Item.BpUnlockRewardItem")
require("UI.BattlePass.UIBattlePassGlobal")
require("UI.UIBasePanel")
require("UI.BattlePass.UIBattlePassGlobal")
UIBattlePassUnlockPanel = class("UIBattlePassUnlockPanel", UIBasePanel)
UIBattlePassUnlockPanel.__index = UIBattlePassUnlockPanel
function UIBattlePassUnlockPanel:ctor(csPanel)
  UIBattlePassUnlockPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
  self.mCSPanel = csPanel
  csPanel.Is3DPanel = true
end
function UIBattlePassUnlockPanel:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBack.transform).onClick = function()
    self:Close()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnHome.gameObject).onClick = function()
    self:OnCommanderCenter()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnCostBuy.gameObject).onClick = function()
    NetCmdBattlePassData:SendBattlePassExpStoreBuy(CS.ProtoObject.BattlepassType.AdvanceOne, function(ret)
      if CS.UnityEngine.Application.isEditor and ret ~= ErrorCodeSuc then
        return
      end
      if CS.UnityEngine.Application.isEditor == false and ret ~= 0 then
        return
      end
      local topUI = UISystem:GetTopUI(UIGroupType.Default)
      if topUI ~= nil and topUI.UIDefine.UIType ~= UIDef.UIBattlePassUnlockPanel then
        return
      end
      local hint = TableData.GetHintById(106013)
      CS.PopupMessageManager.PopupPositiveString(hint)
      NetCmdBattlePassData.BattlePassStatus = CS.ProtoObject.BattlepassType.AdvanceOne
      self:RefreshBuyBtnStatus()
      self:Close()
      MessageSys:SendMessage(UIEvent.BpGetReward, nil)
      MessageSys:SendMessage(UIEvent.BPScrollRefresh, nil)
      UIBattlePassGlobal.BpBuyPromote2 = true
    end)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnCostBuy1.gameObject).onClick = function()
    local beforeType = NetCmdBattlePassData.BattlePassStatus
    NetCmdBattlePassData:SendBattlePassExpStoreBuy(CS.ProtoObject.BattlepassType.AdvanceTwo, function(ret)
      if CS.UnityEngine.Application.isEditor and ret ~= ErrorCodeSuc then
        return
      end
      if CS.UnityEngine.Application.isEditor == false and ret ~= 0 then
        return
      end
      local topUI = UISystem:GetTopUI(UIGroupType.Default)
      if topUI ~= nil and topUI.UIDefine.UIType ~= UIDef.UIBattlePassUnlockPanel then
        return
      end
      local hint = TableData.GetHintById(106013)
      CS.PopupMessageManager.PopupPositiveString(hint)
      NetCmdBattlePassData.BattlePassStatus = CS.ProtoObject.BattlepassType.AdvanceTwo
      self:RefreshBuyBtnStatus()
      UIManager.OpenUIByParam(UIDef.UICommonReceivePanel, {
        nil,
        function()
          MessageSys:SendMessage(UIEvent.BpResfresh, nil)
          MessageSys:SendMessage(UIEvent.BpGetReward, nil)
          MessageSys:SendMessage(UIEvent.BPScrollRefresh, nil)
          if beforeType ~= CS.ProtoObject.BattlepassType.AdvanceOne then
            UIBattlePassGlobal.BpBuyPromote2 = true
          end
          self:Close()
        end
      })
    end)
  end
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_BtnBack)
end
function UIBattlePassUnlockPanel:OnInit(root, data)
end
function UIBattlePassUnlockPanel:OnShowStart()
  self:ShowInfo()
end
function UIBattlePassUnlockPanel:OnCameraStart()
  if UIBattlePassGlobal.ShowModel ~= nil and UIBattlePassGlobal.UnlockPanelBlackTime ~= 0 then
    UIBattlePassGlobal.ShowModel:Show(true)
  end
  return UIBattlePassGlobal.UnlockPanelBlackTime
end
function UIBattlePassUnlockPanel:OnCameraBack()
  if UIBattlePassGlobal.ShowModel ~= nil then
    UIBattlePassGlobal.ShowModel:Show(false)
  end
  return UIBattlePassGlobal.UnlockPanelBlackTime
end
function UIBattlePassUnlockPanel:OnShowFinish()
  if UIBattlePassGlobal.EffectNumObj ~= nil then
    setactive(UIBattlePassGlobal.EffectNumObj, true)
  end
  if UIBattlePassGlobal.ShowModel ~= nil then
    UIBattlePassGlobal.ShowModel:Show(true)
  end
  UIBattlePassGlobal.UnlockPanelBlackTime = 0.1
  UIBattlePassGlobal.BpShowSourceType = UIBattlePassGlobal.BpShowSource.UnlockPanel
  SceneSys:SwitchVisible(EnumSceneType.BattlePass)
  UIManager.EnableBattlePass(true)
  setactive(self.ui.mSListChild_Content, true)
  setactive(self.ui.mSListChild_Content1, true)
end
function UIBattlePassUnlockPanel:ShowInfo()
  self.mNormalUnlockBpReward = {}
  self.mPlusUnlockBpReward = {}
  self.mNormalUnlockBpRewardItems = {}
  self.mNormalUnlockBpRewardGrpItems = {}
  self.mPlusUnlockBpRewardItems = {}
  local seasonId = NetCmdBattlePassData.BattlePassId
  local seasonData = TableData.listBpSeasonDatas:GetDataById(seasonId)
  if seasonData == nil then
    return
  end
  local battlePassPlan = NetCmdSimulateBattleData:GetPlanByType(CS.GF2.Data.PlanType.PlanFunctionBattlepass)
  if battlePassPlan == nil then
    return
  end
  self.mIsGun = false
  local storeGoodData = TableData.listStoreGoodDatas:GetDataById(NetCmdBattlePassData.CurSeason.MaxReward)
  if storeGoodData ~= nil and storeGoodData.Itemtype == GlobalConfig.ItemType.GunType then
    self.mIsGun = true
  end
  self.ui.mText_Name.text = seasonData.advanced1_name
  local status = NetCmdBattlePassData.BattlePassStatus
  if status == CS.ProtoObject.BattlepassType.AdvanceOne then
    self.ui.mText_PlusName.text = seasonData.levelup_advanced2_name
  else
    self.ui.mText_PlusName.text = seasonData.advanced2_name
  end
  local openTime = CS.CGameTime.ConvertLongToDateTime(battlePassPlan.OpenTime):ToString("yyyy/MM/dd")
  local closeTime = CS.CGameTime.ConvertLongToDateTime(battlePassPlan.CloseTime):ToString("yyyy/MM/dd")
  self.ui.mText_Time.text = string_format(TableData.GetHintById(192036), openTime, closeTime)
  self:ShowReward()
  local bpRewardShow = TableData.listBpRerardShowDatas:GetDataById(NetCmdBattlePassData.CurSeason.MaxReward)
  if bpRewardShow ~= nil then
    local canvas = UISystem.BpCharacterCanvas
    local bpLight = canvas:GetComponent(typeof(CS.BPLight))
    if bpLight ~= nil then
      bpLight:SetGun(self.mIsGun)
      local light_rocation = string.split(bpRewardShow.light_rocation3, ",")
      bpLight:SetRation(tonumber(light_rocation[1]), tonumber(light_rocation[2]), tonumber(light_rocation[3]))
      bpLight:SetLightColAnIntensity(bpRewardShow.light_colour3, bpRewardShow.light_intensity3)
    end
  end
  local storeGoodData = TableData.listStoreGoodDatas:GetDataById(NetCmdBattlePassData.CurSeason.MaxReward)
  if storeGoodData ~= nil then
    self.ui.mText_ChrName.text = storeGoodData.name.str
  end
  self:RefreshBuyBtnStatus()
end
function UIBattlePassUnlockPanel:RefreshBuyBtnStatus()
  local status = NetCmdBattlePassData.BattlePassStatus
  setactive(self.ui.mTrans_Unlocked, status == CS.ProtoObject.BattlepassType.AdvanceOne or status == CS.ProtoObject.BattlepassType.AdvanceTwo)
  setactive(self.ui.mTrans_Unlocked1, status == CS.ProtoObject.BattlepassType.AdvanceTwo)
  setactive(self.ui.mTrans_BtnCostBuy, status == CS.ProtoObject.BattlepassType.Base or status == CS.ProtoObject.BattlepassType.None)
  setactive(self.ui.mTrans_BtnCostBuy1, status ~= CS.ProtoObject.BattlepassType.AdvanceTwo)
end
function UIBattlePassUnlockPanel:ShowReward()
  local baseStoreGoodData = TableData.listStoreGoodDatas:GetDataById(TableData.GlobalConfigData.BattlepassBase)
  if baseStoreGoodData ~= nil then
    self.ui.mText_CostNum.text = TableData.GetHintById(192037) .. string.format("%.2f", baseStoreGoodData.price)
  end
  local status = NetCmdBattlePassData.BattlePassStatus
  if status == CS.ProtoObject.BattlepassType.AdvanceOne then
    local plusStoreGoodData = TableData.listStoreGoodDatas:GetDataById(TableData.GlobalConfigData.BattlepassUpgradation)
    if plusStoreGoodData ~= nil then
      self.ui.mText_CostNum1.text = TableData.GetHintById(192037) .. string.format("%.2f", plusStoreGoodData.price)
    end
  else
    local plusStoreGoodData = TableData.listStoreGoodDatas:GetDataById(TableData.GlobalConfigData.BattlepassSenior)
    if plusStoreGoodData ~= nil then
      self.ui.mText_CostNum1.text = TableData.GetHintById(192037) .. string.format("%.2f", plusStoreGoodData.price)
    end
  end
  local bpUnlockRewardDatas = TableData.GetBpUnlockRewardByGroupId(NetCmdBattlePassData.CurSeason.Id)
  for i = 0, bpUnlockRewardDatas.Count - 1 do
    local bpUnlockRewardData = bpUnlockRewardDatas[i]
    if bpUnlockRewardData.reward_id == UIBattlePassGlobal.BpUnlockType.Normal then
      table.insert(self.mNormalUnlockBpReward, bpUnlockRewardData)
    else
      table.insert(self.mPlusUnlockBpReward, bpUnlockRewardData)
    end
  end
  setactive(self.ui.mSListChild_Content, false)
  setactive(self.ui.mSListChild_Content1, false)
  for i, item in pairs(self.mNormalUnlockBpReward) do
    local bpUnlockRewardData = self.mNormalUnlockBpReward[i]
    if bpUnlockRewardData.item_display ~= 0 then
      local bpUnlockRewardItem = BpUnlockRewardItem.New()
      bpUnlockRewardItem:InitCtrl(self.ui.mSListChild_Content)
      bpUnlockRewardItem:SetData(bpUnlockRewardData, false)
      table.insert(self.mNormalUnlockBpRewardItems, bpUnlockRewardItem)
      local instItem = instantiate(self.ui.mTrans_instItem, self.ui.mTrans_instItemRoot)
      setactive(instItem, true)
      local itemUI = {}
      self:LuaUIBindTable(instItem, itemUI)
      local stcData = TableData.GetItemData(bpUnlockRewardData.ShowItemId)
      itemUI.mImg_Icon.sprite = IconUtils.GetItemIcon(stcData.icon)
      setactive(itemUI.mTrans_ImgLine, i ~= #self.mNormalUnlockBpReward)
      table.insert(self.mNormalUnlockBpRewardGrpItems, instItem)
    end
  end
  for i, item in pairs(self.mPlusUnlockBpReward) do
    local bpUnlockRewardData = self.mPlusUnlockBpReward[i]
    if bpUnlockRewardData.item_display ~= 0 then
      local bpUnlockRewardItem = BpUnlockRewardItem.New()
      bpUnlockRewardItem:InitCtrl(self.ui.mSListChild_Content1)
      bpUnlockRewardItem:SetData(bpUnlockRewardData, true)
      table.insert(self.mPlusUnlockBpRewardItems, bpUnlockRewardItem)
    end
  end
  setactive(self.ui.mTrans_instItem, false)
end
function UIBattlePassUnlockPanel:OnUpdate()
end
function UIBattlePassUnlockPanel:Close()
  UIManager.CloseUISelf(self)
  if UIBattlePassGlobal.ShowModel ~= nil then
    local bpRewardShow = TableData.listBpRerardShowDatas:GetDataById(NetCmdBattlePassData.CurSeason.MaxReward)
    if bpRewardShow ~= nil then
      local pos = string.split(bpRewardShow.position1, ",")
      local rotation = string.split(bpRewardShow.rotation1, ",")
      local startRotaion = UIBattlePassGlobal.ShowModel.transform.rotation.eulerAngles
      self.mBattlePassTargetController = UIBattlePassGlobal.MoveAssetObj.gameObject:GetComponent(typeof(CS.BattlePassTargetController))
      if not CS.LuaUtils.IsNullOrDestroyed(self.mBattlePassTargetController) then
        self.mBattlePassTargetController:MoveAsset(UIBattlePassGlobal.ShowModel.transform.position, CS.UnityEngine.Quaternion.Euler(Vector3(startRotaion.x, startRotaion.y, startRotaion.z)), Vector3(tonumber(pos[1]), tonumber(pos[2]), tonumber(pos[3])), CS.UnityEngine.Quaternion.Euler(Vector3(tonumber(rotation[1]), tonumber(rotation[2]), tonumber(rotation[3]))), 0.5, 0.1, false)
      end
      local canvas = UISystem.BpCharacterCanvas
      local bpLight = canvas:GetComponent(typeof(CS.BPLight))
      if bpLight ~= nil then
        bpLight:SetGun(self.mIsGun)
        local light_rocation = string.split(bpRewardShow.light_rocation1, ",")
        bpLight:SetRation(tonumber(light_rocation[1]), tonumber(light_rocation[2]), tonumber(light_rocation[3]))
        bpLight:SetLightColAnIntensity(bpRewardShow.light_colour1, bpRewardShow.light_intensity1)
      end
    end
    setactive(UIBattlePassGlobal.EffectNumObj, false)
    TimerSys:DelayCall(0.6, function()
      setactive(UIBattlePassGlobal.EffectNumObj, true)
      local effectPos = string.split(bpRewardShow.button_position1, ",")
      setposition(UIBattlePassGlobal.EffectNumObj.transform, Vector3(tonumber(effectPos[1]), tonumber(effectPos[2]), tonumber(effectPos[3])))
    end)
  end
end
function UIBattlePassUnlockPanel:OnClose()
  for _, item in pairs(self.mNormalUnlockBpRewardItems) do
    gfdestroy(item:GetRoot())
  end
  for _, item in pairs(self.mPlusUnlockBpRewardItems) do
    gfdestroy(item:GetRoot())
  end
  for _, item in pairs(self.mNormalUnlockBpRewardGrpItems) do
    gfdestroy(item)
  end
  MessageSys:SendMessage(UIEvent.BpResfresh, nil)
  self:UnRegistrationAllKeyboard()
  if UIBattlePassGlobal.EffectNumObj ~= nil then
    setactive(UIBattlePassGlobal.EffectNumObj, false)
  end
  if UIBattlePassGlobal.ShowModel ~= nil and UIBattlePassGlobal.IsBpOutSide == UIBattlePassGlobal.BpOutSideType.bpOutSide then
    UIBattlePassGlobal.ShowModel:Show(false)
  end
end
function UIBattlePassUnlockPanel:OnCommanderCenter()
  UIManager.JumpToMainPanel()
end
function UIBattlePassUnlockPanel:TempFun(temp1, temp2)
end
