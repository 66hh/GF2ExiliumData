require("UI.BattlePass.UIBattlePassGlobal")
require("UI.BattlePass.Item.BpMainRewardListItem")
UIBattleMainPanel = class("UIBattleMainPanel", UIBaseCtrl)
UIBattleMainPanel.__index = UIBattleMainPanel
function UIBattleMainPanel:ctor()
  self.itemList = {}
end
function UIBattleMainPanel:__InitCtrl()
end
function UIBattleMainPanel:InitCtrl(prefab, parent)
  self.obj = instantiate(prefab, parent)
  CS.LuaUIUtils.SetParent(self.obj.gameObject, parent.gameObject)
  self:SetRoot(self.obj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  self:__InitCtrl()
  UIUtils.GetButtonListener(self.ui.mBtn_Unlock.transform).onClick = function()
    UIManager.OpenUI(UIDef.UIBattlePassUnlockPanel)
    self:MoveAsset()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Promote.transform).onClick = function()
    UIManager.OpenUI(UIDef.UIBattlePassUnlockPanel)
    self:MoveAsset()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Add.transform).onClick = function()
    UIManager.OpenUI(UIDef.UIBattlePassBoughtDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GetAll.transform).onClick = function()
    if NetCmdBattlePassData.BattlePassStatus ~= CS.ProtoObject.BattlepassType.Base then
      NetCmdBattlePassData:SendGetBattlepassReward(NetCmdBattlePassData.BattlePassStatus, 0, CS.ProtoCsmsg.BpRewardGetType.GetTypeAll, function()
        MessageSys:SendMessage(UIEvent.BpGetReward, nil)
        UIManager.OpenUI(UIDef.UICommonReceivePanel)
      end)
    else
      UIManager.OpenUI(UIDef.UIBattlePassReceiveDialog)
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Paid.transform).onClick = function()
    UIManager.OpenUI(UIDef.UIBattlePassUnlockPanel)
    self:MoveAsset()
  end
  self.virtualList = self.ui.mVList_GrpRightList
  function self.virtualList.itemProvider()
    local item = self:ItemProvider()
    return item
  end
  function self.virtualList.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  self.mOldIndex = 0
  self.mNewIndex = 0
  self.mIsRise = true
  self.mMaxIndex = 0
  function self.OnBattlePassLevelUp()
    setactive(self.ui.mBtn_GetAll.gameObject, NetCmdBattlePassData.CanOneKeyReceive)
    self:RefreshExp()
  end
  function self.OnBpGetReward()
    self:RefreshSpecial(self.mIndex)
    setactive(self.ui.mBtn_GetAll.gameObject, NetCmdBattlePassData.CanOneKeyReceive)
    if NetCmdBattlePassData.CurSeason.max_level ~= NetCmdBattlePassData.BattlePassLevel then
      if NetCmdBattlePassData.BattlePassOldExp < NetCmdBattlePassData.CurSeason.upgrade_exp then
        CS.UITweenManager.PlayImageFillAmount(self.ui.mImg_ExpBar, NetCmdBattlePassData.BattlePassOldExp / NetCmdBattlePassData.CurSeason.upgrade_exp, NetCmdBattlePassData.BattlePassOverflowExp / NetCmdBattlePassData.CurSeason.upgrade_exp, 0.5, 1, function()
          NetCmdBattlePassData.BattlePassOldExp = NetCmdBattlePassData.BattlePassOverflowExp
        end)
      else
        self:RefreshExp()
      end
    else
      self:RefreshExp()
    end
  end
  function self.OnBPScrollRefresh()
    if self.virtualList == nil then
      return
    end
    self.virtualList.numItems = NetCmdBattlePassData.CurSeason.max_level + 1
    self.virtualList.moveDuation = 1.5
    self:RefreshSpecial(self.mIndex)
    self:RefreshExp()
    self.virtualList:ScrollTo(NetCmdBattlePassData.BattlePassLevel - 3, true)
  end
  MessageSys:AddListener(UIEvent.BattlePassLevelUp, self.OnBattlePassLevelUp)
  MessageSys:AddListener(UIEvent.BpGetReward, self.OnBpGetReward)
  MessageSys:AddListener(UIEvent.BPScrollRefresh, self.OnBPScrollRefresh)
end
function UIBattleMainPanel:SetData(data)
end
function UIBattleMainPanel:Show()
  local battlePassPlan = NetCmdSimulateBattleData:GetPlanByType(CS.GF2.Data.PlanType.PlanFunctionBattlepass)
  if battlePassPlan == nil then
    return
  end
  local seasonId = NetCmdBattlePassData.BattlePassId
  local seasonData = TableData.listBpSeasonDatas:GetDataById(seasonId)
  if seasonData == nil then
    return
  end
  RedPointSystem:GetInstance():UpdateRedPointByType(RedPointConst.BattlePass)
  RedPointSystem:GetInstance():UpdateRedPointByType(RedPointConst.BattlePassMain)
  self.mCurPlanOverTime = battlePassPlan.CloseTime
  self:RefreshExp()
  self.ui.mText_Name.text = seasonData.name.str
  if UIBattlePassGlobal.BpMainpanelRefreshType.FristShow == UIBattlePassGlobal.CurBpMainpanelRefreshType then
    self.virtualList.numItems = seasonData.max_level + 1
    self.virtualList:Refresh()
  end
  local toNum = NetCmdBattlePassData.BattlePassLevel == seasonData.max_level and NetCmdBattlePassData.BattlePassLevel or NetCmdBattlePassData.BattlePassLevel - 3
  if NetCmdBattlePassData.BattlePassLevel == seasonData.max_level then
    local isGetBase = NetCmdBattlePassData:CheckHasReward(false, NetCmdBattlePassData.BattlePassLevel)
    local isGetPlus = NetCmdBattlePassData:CheckHasReward(true, NetCmdBattlePassData.BattlePassLevel)
    if isGetBase == true and isGetPlus == true then
      toNum = NetCmdBattlePassData.BattlePassLevel + 1
    end
  end
  toNum = math.max(toNum, 0)
  toNum = math.min(NetCmdBattlePassData.CurSeason.max_level, toNum)
  toNum = FormatNum(toNum)
  if UIBattlePassGlobal.BpMainpanelRefreshType.FristShow == UIBattlePassGlobal.CurBpMainpanelRefreshType or UIBattlePassGlobal.BpMainpanelRefreshType.ClickTab == UIBattlePassGlobal.CurBpMainpanelRefreshType or UIBattlePassGlobal.BpMainpanelRefreshType.OnTop == UIBattlePassGlobal.CurBpMainpanelRefreshType then
    self.virtualList:ScrollTo(toNum, false)
    if UIBattlePassGlobal.CurBpMainpanelRefreshType == UIBattlePassGlobal.BpMainpanelRefreshType.FristShow then
      UIBattlePassGlobal.CurBpMainpanelRefreshType = UIBattlePassGlobal.BpMainpanelRefreshType.None
    end
  end
  local status = NetCmdBattlePassData.BattlePassStatus
  setactive(self.ui.mTrans_GrpLocked, status == CS.ProtoObject.BattlepassType.Base)
  setactive(self.ui.mBtn_Promote.gameObject, status == CS.ProtoObject.BattlepassType.AdvanceOne)
  setactive(self.ui.mBtn_Unlock.gameObject, status == CS.ProtoObject.BattlepassType.Base)
  setactive(self.ui.mBtn_GetAll.gameObject, NetCmdBattlePassData.CanOneKeyReceive)
  self.ui.mBtn_Paid.interactable = status == CS.ProtoObject.BattlepassType.Base
end
function UIBattleMainPanel:OnRefresh()
  self:Show(false)
end
function UIBattleMainPanel:OnBackFrom()
  self:Show(false)
  setactive(self.ui.mSListChild_Content, false)
  setactive(self.ui.mSListChild_Content, true)
end
function UIBattleMainPanel:OnUpdate()
  if self.ui ~= nil and self.ui.mText_LastTime ~= nil and CS.LuaUtils.IsNullOrDestroyed(self.ui.mText_LastTime) == false then
    self.ui.mText_LastTime.text = string_format(TableData.GetHintById(192026), CS.TimeUtils.GetLeftTime(self.mCurPlanOverTime))
  end
end
function UIBattleMainPanel:EnterPanelRefreshScroll()
  self.virtualList.numItems = NetCmdBattlePassData.CurSeason.max_level + 1
  self.virtualList:Refresh()
end
function UIBattleMainPanel:RefreshExp()
  self.ui.mText_ExpHint.text = TableData.GetHintById(192087)
  setactive(self.ui.mText_Exp, true)
  self.ui.mText_Exp.text = NetCmdBattlePassData.BattlePassOverflowExp .. "/" .. NetCmdBattlePassData.CurSeason.upgrade_exp
  self.ui.mImg_ExpBar.fillAmount = NetCmdBattlePassData.BattlePassOverflowExp / NetCmdBattlePassData.CurSeason.upgrade_exp
  if NetCmdBattlePassData.BattlePassLevel == NetCmdBattlePassData.CurSeason.max_level then
    self.ui.mText_ExpHint.text = TableData.GetHintById(102224)
    setactive(self.ui.mText_Exp, false)
    self.ui.mImg_ExpBar.fillAmount = 1
  end
  if NetCmdBattlePassData.BattlePassLevel > 0 then
    self.ui.mText_Lv.text = TableData.GetHintById(192088) .. string.format("-", tostring(NetCmdBattlePassData.BattlePassLevel))
  else
    self.ui.mText_Lv.text = TableData.GetHintById(192088) .. NetCmdBattlePassData.BattlePassLevel
  end
  NetCmdBattlePassData.BattlePassOldExp = NetCmdBattlePassData.BattlePassOverflowExp
end
function UIBattleMainPanel:ItemProvider()
  local itemView = BpMainRewardListItem.New()
  itemView:InitCtrl(self.ui.mSListChild_Content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIBattleMainPanel:ItemRenderer(index, renderData)
  local item = renderData.data
  item:SetData(index, 1)
  local strs = string.split(item.obj.name, "_")
  self.mNewIndex = tonumber(strs[2])
  self.mIsRise = self.mNewIndex > self.mOldIndex and true or false
  self:SetSpecialReward(index)
  self.mOldIndex = tonumber(strs[2])
end
function UIBattleMainPanel:SetSpecialReward(index)
  local showMaxLevel = 0
  if self.mIsRise then
    showMaxLevel = self.mNewIndex
  else
    showMaxLevel = self.mNewIndex + self.ui.mSListChild_Content.transform.childCount - 1
  end
  UIBattlePassGlobal.CurMaxItemIndex = showMaxLevel
  self.mSpecialRewardData = TableData.listBpRewardDescDatas:GetDataById(NetCmdBattlePassData.CurSeason.reward_id * 1000 + showMaxLevel, true)
  while (self.mSpecialRewardData == nil or self.mSpecialRewardData ~= nil and self.mSpecialRewardData.type_reward == 1) and showMaxLevel <= NetCmdBattlePassData.CurSeason.max_level do
    showMaxLevel = showMaxLevel + 1
    self.mSpecialRewardData = TableData.listBpRewardDescDatas:GetDataById(NetCmdBattlePassData.CurSeason.reward_id * 1000 + showMaxLevel)
  end
  self.mShowMaxLevel = showMaxLevel
  if self.mShowMaxLevel > NetCmdBattlePassData.CurSeason.max_level then
    self.mShowMaxLevel = NetCmdBattlePassData.CurSeason.max_level
    self.mSpecialRewardData = TableData.listBpRewardDescDatas:GetDataById(NetCmdBattlePassData.CurSeason.reward_id * 1000 + self.mShowMaxLevel, true)
  end
  setactive(self.ui.mTrans_SpecailRewardRoot, true)
  self:RefreshSpecial(index)
end
function UIBattleMainPanel:RefreshSpecial(index)
  self.mIndex = index
  local showMaxLevel = self.mShowMaxLevel
  if index >= NetCmdBattlePassData.CurSeason.max_level - 2 then
    setactive(self.ui.mTrans_SpecailRewardRoot, false)
  end
  local bpRewardData = TableData.listBpRewardDescDatas:GetDataById(NetCmdBattlePassData.CurSeason.reward_id * 1000 + showMaxLevel)
  if bpRewardData == nil then
    return
  end
  local isShowEffect = bpRewardData.special_effects_reward == "1"
  self.ui.mText_Num.text = string_format(TableData.GetHintById(80057), string.format("-", tostring(showMaxLevel)))
  local SetRewardItem = function(parent, itemView, reward, isBase)
    if itemView == nil then
      itemView = UICommonItem.New()
      itemView:InitCtrl(parent, true)
    end
    local status = NetCmdBattlePassData.BattlePassStatus
    local hasRewardLevelInfo = NetCmdBattlePassData.Reward:TryGetValue(showMaxLevel)
    local isGet = NetCmdBattlePassData:CheckHasReward(isBase, showMaxLevel)
    for item_id, item_num in pairs(reward) do
      if isBase == false then
        hasRewardLevelInfo = hasRewardLevelInfo == true and status ~= CS.ProtoObject.BattlepassType.Base
      end
      itemView:SetItemData(item_id, item_num, false, false, item_num, nil, nil, function(tempItem)
        self:OnClickItem(tempItem, isBase, hasRewardLevelInfo, isGet)
      end, nil, true)
      itemView:SetRedPoint(false)
      if hasRewardLevelInfo == true then
        itemView:SetRedPoint(isGet == false)
      else
        itemView:SetLock(true)
        itemView:SetLockColor()
      end
      itemView:SetRewardEffect(isShowEffect)
      if isShowEffect then
        itemView:SetImageMaterial(ResSys:GetUIMaterial("BattlePass/Effect/UI_BpMainRewardItemV3_RewardEffect_Fx_Item"))
      else
        itemView:SetImageMaterial(nil)
      end
      itemView:SetReceivedIcon(isGet)
      itemView:SetRedPointAni(false)
    end
    return itemView
  end
  if self.mSpecialRewardData ~= nil then
    self.mNormalItemView = SetRewardItem(self.ui.mSListChild_GrpItem, self.mNormalItemView, self.mSpecialRewardData.base_reward, true)
    self.mPaidItemView = SetRewardItem(self.ui.mSListChild_GrpItem1, self.mPaidItemView, self.mSpecialRewardData.advanced_reward, false)
  end
end
function UIBattleMainPanel:OnClickItem(tempItem, isBase, isUnLock, isGet)
  if isUnLock == false or isGet == true then
    UITipsPanel.Open(TableData.GetItemData(tempItem.itemId))
    return
  end
  if isBase == true then
    NetCmdBattlePassData:SendGetBattlepassReward(CS.ProtoObject.BattlepassType.Base, self.mShowMaxLevel, CS.ProtoCsmsg.BpRewardGetType.GetTypeNone, function()
      TimerSys:DelayCall(0.5, function()
        MessageSys:SendMessage(UIEvent.BpGetReward, nil)
      end)
      UIManager.OpenUI(UIDef.UICommonReceivePanel)
    end)
  else
    NetCmdBattlePassData:SendGetBattlepassReward(NetCmdBattlePassData.BattlePassStatus, self.mShowMaxLevel, CS.ProtoCsmsg.BpRewardGetType.GetTypeNone, function()
      UIManager.OpenUI(UIDef.UICommonReceivePanel)
      TimerSys:DelayCall(0.5, function()
        MessageSys:SendMessage(UIEvent.BpGetReward, nil)
      end)
    end)
  end
end
function UIBattleMainPanel:MoveAsset()
  if UIBattlePassGlobal.ShowModel == nil then
    return
  end
  local bpRewardShow = TableData.listBpRerardShowDatas:GetDataById(NetCmdBattlePassData.CurSeason.MaxReward)
  if bpRewardShow ~= nil then
    local pos = string.split(bpRewardShow.position3, ",")
    local rotation = string.split(bpRewardShow.rotation3, ",")
    local startRotaion = UIBattlePassGlobal.ShowModel.transform.rotation.eulerAngles
    self.mBattlePassTargetController = UIBattlePassGlobal.MoveAssetObj.gameObject:GetComponent(typeof(CS.BattlePassTargetController))
    if not CS.LuaUtils.IsNullOrDestroyed(self.mBattlePassTargetController) then
      self.mBattlePassTargetController:MoveAsset(UIBattlePassGlobal.ShowModel.transform.position, CS.UnityEngine.Quaternion.Euler(Vector3(startRotaion.x, startRotaion.y, startRotaion.z)), Vector3(tonumber(pos[1]), tonumber(pos[2]), tonumber(pos[3])), CS.UnityEngine.Quaternion.Euler(Vector3(tonumber(rotation[1]), tonumber(rotation[2]), tonumber(rotation[3]))), 0.5, 0.2, true)
    end
    setactive(UIBattlePassGlobal.EffectNumObj, false)
    TimerSys:DelayCall(0.7, function()
      local effectPos = string.split(bpRewardShow.button_position3, ",")
      setactive(UIBattlePassGlobal.EffectNumObj, true)
      setposition(UIBattlePassGlobal.EffectNumObj.transform, Vector3(tonumber(effectPos[1]), tonumber(effectPos[2]), tonumber(effectPos[3])))
    end)
  end
end
function UIBattleMainPanel:Hide()
end
function UIBattleMainPanel:Release()
  gfdestroy(self.obj)
  MessageSys:RemoveListener(UIEvent.BpGetReward, self.OnBpGetReward)
  MessageSys:RemoveListener(UIEvent.BattlePassLevelUp, self.OnBattlePassLevelUp)
  MessageSys:RemoveListener(UIEvent.BPScrollRefresh, self.OnBPScrollRefresh)
end
