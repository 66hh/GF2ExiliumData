require("UI.MessageBox.MessageBoxPanel")
require("UI.BattlePass.UIBattlePassGlobal")
require("UI.Common.UICommonItem")
UIBattlePassBoughtDialog = class("UIBattlePassBoughtDialog", UIBasePanel)
UIBattlePassBoughtDialog.__index = UIBattlePassBoughtDialog
function UIBattlePassBoughtDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  csPanel.UsePool = false
end
function UIBattlePassBoughtDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListen()
end
function UIBattlePassBoughtDialog:OnInit(root, data)
  self.mExtraRewardItemsTab = {}
  self.mBaseRewardItemsTab = {}
  self.mAdvanceRewardItemsTab = {}
end
function UIBattlePassBoughtDialog:OnShowStart()
  self.mIsBuyLevel = true
  local tempLevel = NetCmdBattlePassData.BattlePassLevel
  if tempLevel >= NetCmdBattlePassData.CurSeason.max_level then
    self:ShowExpPanel()
    return
  end
  self:ShowLevelPanel()
end
function UIBattlePassBoughtDialog:OnShowFinish()
end
function UIBattlePassBoughtDialog:OnTop()
  UIManager.EnableBattlePass(true)
  if UIBattlePassGlobal.ShowModel ~= nil then
    UIBattlePassGlobal.ShowModel:Show(true)
  end
end
function UIBattlePassBoughtDialog:ShowExpPanel()
  self.mIsBuyLevel = false
  self.mCurBuyExpNum = 1
  self.ui.mText_Title.text = TableData.GetHintById(192013)
  setactive(self.ui.mTrans_PaidReward, false)
  self.ui.mText_MinNum.text = 1
  self.mStoreGoodData = TableData.listStoreGoodDatas:GetDataById(TableData.GlobalConfigData.BattlepassExperience)
  if self.mStoreGoodData ~= nil and self.mStoreGoodData.price_type > 0 then
    local stcData = TableData.GetItemData(self.mStoreGoodData.price_type)
    local costItemNum = NetCmdItemData:GetItemCountById(self.mStoreGoodData.price_type)
    self.ui.mImg_Icon.sprite = IconUtils.GetItemIcon(stcData.icon)
    self.mMaxNum = math.floor(costItemNum / self.mStoreGoodData.price)
    self.mMaxNum = self.mMaxNum > 99 and 99 or self.mMaxNum
    if 1 > self.mMaxNum then
      self.mMaxNum = 1
    end
    self.ui.mText_MaxNum.text = self.mMaxNum
  end
  self.ui.mSlider_GrpSlider.maxValue = self.mMaxNum
  self.ui.mSlider_GrpSlider.minValue = 1
  self:SetExpReward(self.mCurBuyExpNum)
end
function UIBattlePassBoughtDialog:ShowLevelPanel()
  self.mCurSelectLevel = NetCmdBattlePassData.BattlePassLevel
  local tempLevel = NetCmdBattlePassData.BattlePassLevel
  self.ui.mText_Title.text = TableData.GetHintById(192012)
  self.mMaxNum = NetCmdBattlePassData.CurSeason.max_level - NetCmdBattlePassData.BattlePassLevel
  self.ui.mSlider_GrpSlider.maxValue = self.mMaxNum
  self.ui.mSlider_GrpSlider.minValue = 1
  self.ui.mText_MinNum.text = 1
  self.ui.mText_MaxNum.text = self.mMaxNum
  tempLevel = tempLevel + 1
  self.mSpecialRewardData = TableData.listBpRewardDescDatas:GetDataById(NetCmdBattlePassData.CurSeason.reward_id * 1000 + tempLevel, true)
  while (self.mSpecialRewardData == nil or self.mSpecialRewardData ~= nil and self.mSpecialRewardData.type_reward == 1) and tempLevel <= NetCmdBattlePassData.CurSeason.max_level do
    tempLevel = tempLevel + 1
    self.mSpecialRewardData = TableData.listBpRewardDescDatas:GetDataById(NetCmdBattlePassData.CurSeason.reward_id * 1000 + tempLevel)
  end
  local status = NetCmdBattlePassData.BattlePassStatus
  self.mIsBase = status == CS.ProtoObject.BattlepassType.Base
  setactive(self.ui.mTrans_PaidReward, self.mIsBase)
  self:SetLevelReward(tempLevel - NetCmdBattlePassData.BattlePassLevel, self.mIsBase)
  self.ui.mText_Tip.text = string_format(TableData.GetHintById(192030), tostring(tempLevel))
end
function UIBattlePassBoughtDialog:SetExpReward(buyNum)
  self.mCurBuyExpNum = buyNum
  local index = 0
  for k, v in pairs(NetCmdBattlePassData.CurSeason.ExtraReward) do
    index = index + 1
    local rewardItem = self.mExtraRewardItemsTab[index]
    if rewardItem == nil then
      rewardItem = UICommonItem.New()
      rewardItem:InitCtrl(self.ui.mSListChild_Content, true)
      table.insert(self.mExtraRewardItemsTab, rewardItem)
    end
    rewardItem:SetItemData(k, FormatNum(v * buyNum))
  end
  self.ui.mSlider_GrpSlider.value = buyNum
  self.ui.mBtn_GrpBtnReduce.interactable = buyNum ~= 1
  self.ui.mBtn_GrpBtnIncrease.interactable = buyNum ~= self.mMaxNum
  self.mStoreGoodData = TableData.listStoreGoodDatas:GetDataById(TableData.GlobalConfigData.BattlepassExperience)
  self.ui.mText_BuyLv.text = string_format(TableData.GetHintById(192038), tostring(FormatNum(buyNum * NetCmdBattlePassData.CurSeason.ExtraExp)))
  self.ui.mText_Num.text = FormatNum(self.mStoreGoodData.price * buyNum)
  self.ui.mText_Tip.text = string_format(TableData.GetHintById(192032), FormatNum(buyNum * NetCmdBattlePassData.CurSeason.ExtraExp))
  if self.mStoreGoodData ~= nil and 0 < self.mStoreGoodData.price_type then
    local costItemNum = NetCmdItemData:GetItemCountById(self.mStoreGoodData.price_type)
    self.ui.mText_Num.color = costItemNum < self.mStoreGoodData.price * buyNum and ColorUtils.RedColor or ColorUtils.BlackColor
  end
end
function UIBattlePassBoughtDialog:SetLevelReward(deltaLevel, isBase)
  self.mCurSelectLevel = deltaLevel + NetCmdBattlePassData.BattlePassLevel
  self.mBaseRewardTab = {}
  self.mAdvanceRewardTab = {}
  for i = deltaLevel + NetCmdBattlePassData.BattlePassLevel, NetCmdBattlePassData.BattlePassLevel + 1, -1 do
    local levelReward = TableData.listBpRewardDescDatas:GetDataById(NetCmdBattlePassData.CurSeason.reward_id * 1000 + i, true)
    if levelReward ~= nil and levelReward.type_reward == 2 then
      for k, v in pairs(levelReward.advanced_reward) do
        self:RewardItemTabHasContain(self.mAdvanceRewardTab, k, v)
      end
    end
  end
  for i = deltaLevel + NetCmdBattlePassData.BattlePassLevel, NetCmdBattlePassData.BattlePassLevel + 1, -1 do
    local levelReward = TableData.listBpRewardDescDatas:GetDataById(NetCmdBattlePassData.CurSeason.reward_id * 1000 + i, true)
    if levelReward ~= nil and levelReward.type_reward == 1 then
      for k, v in pairs(levelReward.advanced_reward) do
        self:RewardItemTabHasContain(self.mAdvanceRewardTab, k, v)
      end
    end
  end
  for i = deltaLevel + NetCmdBattlePassData.BattlePassLevel, NetCmdBattlePassData.BattlePassLevel + 1, -1 do
    local levelReward = TableData.listBpRewardDescDatas:GetDataById(NetCmdBattlePassData.CurSeason.reward_id * 1000 + i, true)
    if levelReward ~= nil and levelReward.type_reward == 2 then
      for k, v in pairs(levelReward.base_reward) do
        self:RewardItemTabHasContain(self.mBaseRewardTab, k, v)
      end
    end
  end
  for i = deltaLevel + NetCmdBattlePassData.BattlePassLevel, NetCmdBattlePassData.BattlePassLevel + 1, -1 do
    local levelReward = TableData.listBpRewardDescDatas:GetDataById(NetCmdBattlePassData.CurSeason.reward_id * 1000 + i, true)
    if levelReward ~= nil and levelReward.type_reward == 1 then
      for k, v in pairs(levelReward.base_reward) do
        self:RewardItemTabHasContain(self.mBaseRewardTab, k, v)
      end
    end
  end
  for k, v in pairs(self.mAdvanceRewardTab) do
  end
  if isBase == true then
    self.virtualListBase.numItems = #self.mBaseRewardTab
    self.virtualListAdvance.numItems = #self.mAdvanceRewardTab
    self.virtualListAdvance:Refresh()
  else
    for k, v in pairs(self.mBaseRewardTab) do
      self:RewardItemTabHasContain(self.mAdvanceRewardTab, v.itemId, v.itemNum)
    end
    self.virtualListBase.numItems = #self.mAdvanceRewardTab
    self.virtualListBase:Refresh()
  end
  self.ui.mSlider_GrpSlider.value = deltaLevel
  self.mStoreGoodData = TableData.listStoreGoodDatas:GetDataById(TableData.GlobalConfigData.BattlepassGrade)
  self.ui.mText_BuyLv.text = string_format(TableData.GetHintById(192033), tostring(formatnum(deltaLevel)))
  self.ui.mText_Num.text = formatnum(self.mStoreGoodData.price * deltaLevel)
  if self.mStoreGoodData ~= nil and self.mStoreGoodData.price_type > 0 then
    local stcData = TableData.GetItemData(self.mStoreGoodData.price_type)
    self.ui.mImg_Icon.sprite = IconUtils.GetItemIcon(stcData.icon)
    local costItemNum = NetCmdItemData:GetItemCountById(self.mStoreGoodData.price_type)
    self.ui.mText_Num.color = costItemNum < self.mStoreGoodData.price * deltaLevel and ColorUtils.RedColor or ColorUtils.BlackColor
  end
  self.ui.mBtn_GrpBtnReduce.interactable = 1 ~= deltaLevel
  self.ui.mBtn_GrpBtnIncrease.interactable = NetCmdBattlePassData.BattlePassLevel ~= NetCmdBattlePassData.CurSeason.max_level - deltaLevel
  self.ui.mText_Tip.text = string_format(TableData.GetHintById(192030), tostring(FormatNum(deltaLevel + NetCmdBattlePassData.BattlePassLevel)))
end
function UIBattlePassBoughtDialog:RewardItemTabHasContain(rewardItemTab, itemId, itemNum)
  local tempValue = 0
  for key, value in pairs(rewardItemTab) do
    if value.itemId == itemId then
      tempValue = value.itemNum
      value.itemNum = tempValue + itemNum
      rewardItemTab[key] = value
    end
  end
  if tempValue == 0 then
    local insertItem = {itemId = itemId, itemNum = itemNum}
    table.insert(rewardItemTab, insertItem)
  end
end
function UIBattlePassBoughtDialog:MoveAsset()
  local bpRewardShow = TableData.listBpRerardShowDatas:GetDataById(NetCmdBattlePassData.CurSeason.MaxReward)
  if bpRewardShow ~= nil then
    local pos = string.split(bpRewardShow.position3, ",")
    local rotation = string.split(bpRewardShow.rotation3, ",")
    local startRotaion = UIBattlePassGlobal.ShowModel.transform.rotation.eulerAngles
    self.mBattlePassTargetController = UIBattlePassGlobal.MoveAssetObj.gameObject:GetComponent(typeof(CS.BattlePassTargetController))
    if not CS.LuaUtils.IsNullOrDestroyed(self.mBattlePassTargetController) then
      self.mBattlePassTargetController:MoveAsset(UIBattlePassGlobal.ShowModel.transform.position, CS.UnityEngine.Quaternion.Euler(Vector3(startRotaion.x, startRotaion.y, startRotaion.z)), Vector3(tonumber(pos[1]), tonumber(pos[2]), tonumber(pos[3])), CS.UnityEngine.Quaternion.Euler(Vector3(tonumber(rotation[1]), tonumber(rotation[2]), tonumber(rotation[3]))), 0.5, 0.2, true)
    end
    TimerSys:DelayCall(0.2, function()
      local effectPos = string.split(bpRewardShow.button_position3, ",")
      local fromPos = UIBattlePassGlobal.EffectNumObj.transform.localPosition
      CS.UITweenManager.PlayLocalPositionTween(UIBattlePassGlobal.EffectNumObj.transform, fromPos, Vector3(tonumber(effectPos[1]), tonumber(effectPos[2]), tonumber(effectPos[3])), 0.5)
    end)
  end
end
function UIBattlePassBoughtDialog:Temp2(aaa, bbb)
  self.mBaseRewardItemsTab = {}
  self.mAdvanceRewardItemsTab = {}
end
function UIBattlePassBoughtDialog:OnClose()
  for _, item in pairs(self.mBaseRewardItemsTab) do
    gfdestroy(item:GetRoot())
  end
  for _, item in pairs(self.mAdvanceRewardItemsTab) do
    gfdestroy(item:GetRoot())
  end
  for _, item in pairs(self.mExtraRewardItemsTab) do
    gfdestroy(item:GetRoot())
  end
end
function UIBattlePassBoughtDialog:OnRelease()
  self.ui = nil
  self.mData = nil
end
function UIBattlePassBoughtDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.transform).onClick = function()
    UIManager.CloseUI(UIDef.UIBattlePassBoughtDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.transform).onClick = function()
    UIManager.CloseUI(UIDef.UIBattlePassBoughtDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnCancel.transform).onClick = function()
    UIManager.CloseUI(UIDef.UIBattlePassBoughtDialog)
  end
  local OnBuyClick = function()
    local buyNum = 0
    if self.mIsBuyLevel then
      buyNum = self.mCurSelectLevel - NetCmdBattlePassData.BattlePassLevel
    else
      buyNum = self.mCurBuyExpNum
    end
    if self.mStoreGoodData ~= nil and 0 < self.mStoreGoodData.price_type then
      local costItemNum = NetCmdItemData:GetItemCountById(self.mStoreGoodData.price_type)
      if costItemNum < self.mStoreGoodData.price * buyNum then
        local itemData = TableData.GetItemData(self.mStoreGoodData.price_type)
        local hint = TableData.GetHintById(225)
        CS.PopupMessageManager.PopupString(string_format(hint, itemData.name))
        return
      end
    end
    NetCmdBattlePassData:SendBattlePassLevelStoreBuy(buyNum, self.mIsBuyLevel, function(ret)
      if ret == ErrorCodeSuc and self.mIsBuyLevel then
      elseif ret == ErrorCodeSuc then
        local hint = string_format(TableData.GetHintById(192068), FormatNum(buyNum * NetCmdBattlePassData.CurSeason.ExtraExp))
        CS.PopupMessageManager.PopupPositiveString(hint)
        MessageSys:SendMessage(UIEvent.BpGetReward, nil)
      end
    end)
    UIManager.CloseUI(UIDef.UIBattlePassBoughtDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnConfirm.transform).onClick = OnBuyClick
  UIUtils.GetButtonListener(self.ui.mBtn_Unlock.transform).onClick = function()
    UIManager.OpenUI(UIDef.UIBattlePassUnlockPanel)
    self:MoveAsset()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpBtnIncrease.transform).onClick = function()
    if self.mIsBuyLevel then
      self:SetLevelReward(self.mCurSelectLevel - NetCmdBattlePassData.BattlePassLevel + 1, self.mIsBase)
    else
      self:SetExpReward(self.mCurBuyExpNum + 1)
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpBtnReduce.transform).onClick = function()
    if self.mIsBuyLevel then
      self:SetLevelReward(self.mCurSelectLevel - NetCmdBattlePassData.BattlePassLevel - 1, self.mIsBase)
    else
      self:SetExpReward(self.mCurBuyExpNum - 1)
    end
  end
  self.ui.mSlider_GrpSlider.onValueChanged:AddListener(function(ptc)
    if self.mIsBuyLevel then
      self:SetLevelReward(ptc, self.mIsBase)
    else
      self:SetExpReward(ptc)
    end
  end)
  self.virtualListBase = self.ui.mVList_GrpLvUpRewardList
  function self.virtualListBase.itemProvider()
    local item = self:ItemBaseProvider()
    return item
  end
  function self.virtualListBase.itemRenderer(index, renderData)
    self:ItemBaseRenderer(index, renderData)
  end
  self.virtualListAdvance = self.ui.mVList_GrpPaidRewardList
  function self.virtualListAdvance.itemProvider()
    local item = self:ItemAdvanceProvider()
    return item
  end
  function self.virtualListAdvance.itemRenderer(index, renderData)
    self:ItemAdvanceRenderer(index, renderData)
  end
end
function UIBattlePassBoughtDialog:ItemBaseProvider()
  local itemView = UICommonItem.New()
  itemView:InitCtrl(self.ui.mSListChild_Content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIBattlePassBoughtDialog:ItemBaseRenderer(index, renderData)
  local item = renderData.data
  local itemData
  if self.mIsBase == true then
    itemData = self.mBaseRewardTab[index + 1]
  else
    itemData = self.mAdvanceRewardTab[index + 1]
  end
  item:SetItemData(itemData.itemId, itemData.itemNum)
end
function UIBattlePassBoughtDialog:ItemAdvanceProvider()
  local itemView = UICommonItem.New()
  itemView:InitCtrl(self.ui.mSListChild_Content1)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIBattlePassBoughtDialog:ItemAdvanceRenderer(index, renderData)
  local item = renderData.data
  local v = self.mAdvanceRewardTab[index + 1]
  item:SetItemData(v.itemId, v.itemNum)
  item:SetLock(true)
  item:SetLockColor()
end
