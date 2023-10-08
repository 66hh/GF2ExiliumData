require("UI.Common.UICommonItem")
require("UI.UIBaseCtrl")
BpMainRewardListItem = class("BpMainRewardListItem", UIBaseCtrl)
BpMainRewardListItem.__index = BpMainRewardListItem
function BpMainRewardListItem:__InitCtrl()
end
function BpMainRewardListItem:InitCtrl(parent)
  self.obj = instantiate(UIUtils.GetGizmosPrefab("BattlePass/BpMainRewardListItemV3.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(self.obj.gameObject, parent.gameObject, false)
  end
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  self:SetRoot(self.obj.transform)
  self:__InitCtrl()
  if self.mNormalItemView == nil then
    self.mNormalItemView = UICommonItem.New()
    self.mNormalItemView:InitCtrl(self.ui.mSListChild_GrpItem, true)
    self.mNormalItemView:SetRedPointAni(false)
  end
  if self.mPaidItemView == nil then
    self.mPaidItemView = UICommonItem.New()
    self.mPaidItemView:InitCtrl(self.ui.mSListChild_GrpItem1, true)
    self.mPaidItemView:SetRedPointAni(false)
  end
  function self.OnBpGetReward()
    if not CS.LuaUtils.IsNullOrDestroyed(self.obj) then
      self:SetData(self.mCurLevel - 1, 0)
    end
  end
  function self.OnBPScrollRefresh()
    if not CS.LuaUtils.IsNullOrDestroyed(self.obj) then
      self:SetData(self.mCurLevel - 1, 0)
    end
  end
  function self.OnBpPromt2()
    if self.mCurLevel <= NetCmdBattlePassData.CurSeason.max_level then
      TimerSys:DelayCall((self.mCurLevel - (UIBattlePassGlobal.CurMaxItemIndex - 10)) * 0.05, function()
        if not CS.LuaUtils.IsNullOrDestroyed(self.mPaidItemView:GetRoot()) then
          self.mPaidItemView:SetAniFadein()
        end
      end)
    end
  end
  function self.OnRefreshAddExp()
    if not CS.LuaUtils.IsNullOrDestroyed(self.ui.mText_Consume) and self.mCurLevel > NetCmdBattlePassData.CurSeason.max_level then
      self:ExtraGroup()
    end
  end
  MessageSys:AddListener(UIEvent.BPScrollRefresh, self.OnBPScrollRefresh)
  MessageSys:AddListener(UIEvent.BpGetReward, self.OnBpGetReward)
  MessageSys:AddListener(UIEvent.BpExpRefreah, self.OnRefreshAddExp)
  MessageSys:AddListener(UIEvent.BpPromt2, self.OnBpPromt2)
end
function BpMainRewardListItem:SetData(index, level)
  self.mCurLevel = index + 1
  local seasonId = NetCmdBattlePassData.BattlePassId
  local seasonData = TableData.listBpSeasonDatas:GetDataById(seasonId)
  if seasonData == nil then
    return
  end
  local curSeasonRewardId = seasonData.reward_id
  setactive(self.ui.Trans_NormalRoot, true)
  if self.mCurLevel <= seasonData.max_level then
    self:NormalGroup()
  else
    self:ExtraGroup()
  end
end
function BpMainRewardListItem:NormalGroup()
  local seasonId = NetCmdBattlePassData.BattlePassId
  local seasonData = TableData.listBpSeasonDatas:GetDataById(seasonId)
  if seasonData == nil then
    return
  end
  local curSeasonRewardId = seasonData.reward_id
  local bpRewardData = TableData.listBpRewardDescDatas:GetDataById(curSeasonRewardId * 1000 + self.mCurLevel)
  if bpRewardData == nil then
    return
  end
  self.ui.mAni_Root:SetBool("CurrentLevel", NetCmdBattlePassData.Reward.Count == self.mCurLevel)
  self.ui.mText_Num.text = string.format("-", tostring(self.mCurLevel))
  local isShowEffect = bpRewardData.special_effects_reward == "1"
  local hasRewardLevelInfo = NetCmdBattlePassData.Reward:TryGetValue(self.mCurLevel)
  for item_id, item_num in pairs(bpRewardData.base_reward) do
    local isGet = NetCmdBattlePassData:CheckHasReward(true, self.mCurLevel)
    self.mNormalItemView:SetItemData(item_id, item_num, false, false, item_num, nil, nil, function(tempItem)
      self:OnClickItem(tempItem, true, hasRewardLevelInfo, isGet)
    end, nil, true)
    self.mNormalItemView:SetRewardEffect(isShowEffect)
    self.mNormalItemView:SetRedPoint(false)
    if hasRewardLevelInfo == true then
      self.mNormalItemView:SetRedPoint(isGet == false)
    else
      self.mNormalItemView:SetLock(true)
      self.mNormalItemView:SetLockColor()
    end
    self.mNormalItemView:SetRedPointAni(false)
    self.mNormalItemView:SetReceivedIcon(isGet)
    if isShowEffect then
      self.mNormalItemView:SetImageMaterial(ResSys:GetUIMaterial("BattlePass/Effect/UI_BpMainRewardItemV3_RewardEffect_Fx_Item"))
    else
      self.mNormalItemView:SetImageMaterial(nil)
    end
  end
  local status = NetCmdBattlePassData.BattlePassStatus
  for item_id, item_num in pairs(bpRewardData.advanced_reward) do
    local isGet = NetCmdBattlePassData:CheckHasReward(false, self.mCurLevel)
    local hasPaidRewardLevelInfo = hasRewardLevelInfo == true and status ~= CS.ProtoObject.BattlepassType.Base
    self.mPaidItemView:SetItemData(item_id, item_num, false, false, item_num, nil, nil, function(tempItem)
      self:OnClickItem(tempItem, false, hasPaidRewardLevelInfo, isGet)
    end, nil, true)
    self.mPaidItemView:SetRedPoint(false)
    self.mPaidItemView:SetRewardEffect(isShowEffect)
    if hasPaidRewardLevelInfo then
      self.mPaidItemView:SetRedPoint(isGet == false)
    else
      self.mPaidItemView:SetLock(true)
      self.mPaidItemView:SetLockColor()
    end
    self.mPaidItemView:SetRedPointAni(false)
    self.mPaidItemView:SetReceivedIcon(isGet)
    if isShowEffect then
      self.mPaidItemView:SetImageMaterial(ResSys:GetUIMaterial("BattlePass/Effect/UI_BpMainRewardItemV3_RewardEffect_Fx_Item"))
    else
      self.mPaidItemView:SetImageMaterial(nil)
    end
  end
  setactive(self.ui.mTrans_Empty, bpRewardData.base_reward.Count == 0)
  setactive(self.mNormalItemView:GetRoot(), bpRewardData.base_reward.Count ~= 0)
  setactive(self.ui.mTrans_ConsumeExp, false)
end
function BpMainRewardListItem:ExtraGroup()
  local seasonId = NetCmdBattlePassData.BattlePassId
  local seasonData = TableData.listBpSeasonDatas:GetDataById(seasonId)
  if seasonData == nil then
    return
  end
  setactive(self.ui.mTrans_ConsumeExp, NetCmdBattlePassData.CurSeason.max_level == NetCmdBattlePassData.BattlePassLevel)
  setactive(self.ui.Trans_NormalRoot, false)
  self.ui.mText_Consume.text = NetCmdBattlePassData.BattlePassOverflowExp .. "/" .. NetCmdBattlePassData.CurSeason.upgrade_exp
  self.ui.mText_Num.text = TableData.GetHintById(192004)
  for item_id, item_num in pairs(seasonData.extra_reward) do
    local itemNum = NetCmdBattlePassData.BattlePassOverflowExp / NetCmdBattlePassData.CurSeason.upgrade_exp
    itemNum = math.floor(itemNum)
    itemNum = itemNum ~= 0 and itemNum or nil
    self.mPaidItemView:SetItemData(item_id, itemNum, false, false, itemNum, nil, nil, function(tempItem)
      self:OnClickExtraItem(tempItem, item_id)
    end, nil, true)
    self.mPaidItemView:SetLock(NetCmdBattlePassData.BattlePassLevel < seasonData.max_level)
    self.mPaidItemView:SetLockColor()
    self.mPaidItemView:SetReceivedIcon(false)
    self.mPaidItemView:SetRedPoint(NetCmdBattlePassData.BattlePassOverflowExp / seasonData.upgrade_exp >= 1)
    self.mPaidItemView:SetImageMaterial(nil)
  end
end
function BpMainRewardListItem:SetInteractable(interactable)
end
function BpMainRewardListItem:OnClickItem(tempItem, isBase, isUnLock, isGet)
  if isUnLock == false or isGet == true then
    UITipsPanel.Open(TableData.GetItemData(tempItem.itemId))
    return
  end
  if isBase == true then
    NetCmdBattlePassData:SendGetBattlepassReward(CS.ProtoObject.BattlepassType.Base, self.mCurLevel, CS.ProtoCsmsg.BpRewardGetType.GetTypeNone, function(ret)
      if ret == ErrorCodeSuc then
        UIManager.OpenUIByParam(UIDef.UICommonReceivePanel)
        TimerSys:DelayCall(0.5, function()
          MessageSys:SendMessage(UIEvent.BpGetReward, nil)
        end)
      end
    end)
  else
    NetCmdBattlePassData:SendGetBattlepassReward(NetCmdBattlePassData.BattlePassStatus, self.mCurLevel, CS.ProtoCsmsg.BpRewardGetType.GetTypeNone, function(ret)
      if ret == ErrorCodeSuc then
        UIManager.OpenUIByParam(UIDef.UICommonReceivePanel)
        TimerSys:DelayCall(0.5, function()
          MessageSys:SendMessage(UIEvent.BpGetReward, nil)
        end)
      end
    end)
  end
end
function BpMainRewardListItem:OnClickExtraItem(tempItem, item_id)
  local seasonId = NetCmdBattlePassData.BattlePassId
  local seasonData = TableData.listBpSeasonDatas:GetDataById(seasonId)
  if seasonData == nil then
    return
  end
  if NetCmdBattlePassData.BattlePassOverflowExp / seasonData.upgrade_exp >= 1 then
    NetCmdBattlePassData:SendGetBattlepassReward(NetCmdBattlePassData.BattlePassStatus, self.mCurLevel, CS.ProtoCsmsg.BpRewardGetType.GetTypeExtra, function()
      UIManager.OpenUI(UIDef.UICommonReceivePanel)
      MessageSys:SendMessage(UIEvent.BpGetReward, nil)
      MessageSys:SendMessage(UIEvent.BpResfresh, nil)
    end)
  else
    local stcData = TableData.GetItemData(item_id)
    UITipsPanel.Open(stcData)
  end
end
function BpMainRewardListItem:OnRelease()
  self.super.OnRelease(self, true)
  MessageSys:RemoveListener(UIEvent.BpGetReward, self.OnBpGetReward)
  MessageSys:RemoveListener(UIEvent.BPScrollRefresh, self.OnBPScrollRefresh)
  MessageSys:RemoveListener(UIEvent.BpPromt2, self.OnBpPromt2)
  MessageSys:RemoveListener(UIEvent.BpExpRefreah, self.OnRefreshAddExp)
end
