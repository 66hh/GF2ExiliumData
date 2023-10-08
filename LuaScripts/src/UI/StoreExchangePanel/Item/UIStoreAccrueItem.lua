require("UI.UIBaseCtrl")
UIStoreAccrueItem = class("UIStoreAccrueItem", UIBaseCtrl)
function UIStoreAccrueItem:ctor(parent)
  local go = instantiate(UIUtils.GetGizmosPrefab("StoreExchange/StoreAccrueItemV2.prefab", self), parent)
  self:SetRoot(go.transform)
  self.ui = UIUtils.GetUIBindTable(go)
  setactive(self:GetRoot(), true)
  UIUtils.GetButtonListener(self.ui.mBtn_BtnReceive.transform).onClick = function()
    NetCmdStoreData:SendStoreGetRechargeReward(self.mAccumulateRechargeId, function(ret)
      if ret == ErrorCodeSuc then
        MessageSys:SendMessage(UIEvent.GetAccumulateRechargeReaward, self.mAccumulateRechargeId)
        UIManager.OpenUIByParam(UIDef.UICommonReceivePanel)
      end
    end)
  end
  function self.OnGetAccumulateRechargeReaward(msg)
    local accumulateRechargeReawardIndex = msg.Sender
    if accumulateRechargeReawardIndex == self.mAccumulateRechargeId then
      self:Refresh()
    end
  end
  MessageSys:AddListener(UIEvent.GetAccumulateRechargeReaward, self.OnGetAccumulateRechargeReaward)
  self.mRewardList = {}
end
function UIStoreAccrueItem:SetData(accumulateRechargeId)
  if accumulateRechargeId == 0 then
    return
  end
  self.mAccumulateRechargeId = accumulateRechargeId
  self.mAccumulateRechargeData = TableData.listAccumulateRechargeDatas:GetDataById(accumulateRechargeId)
  if self.mAccumulateRechargeData == nil then
    return
  end
  local rewardItems = {}
  for item_id, item_num in pairs(self.mAccumulateRechargeData.reward_item) do
    local item = {}
    item.item_id = item_id
    item.item_num = item_num
    table.insert(rewardItems, item)
  end
  table.sort(rewardItems, function(a, b)
    local data1 = TableData.GetItemData(a.item_id)
    local data2 = TableData.GetItemData(b.item_id)
    if data1.rank == data2.rank then
      return a.item_id > b.item_id
    else
      return data1.rank > data2.rank
    end
  end)
  for i, v in pairs(self.mRewardList) do
    setactive(v:GetRoot(), false)
  end
  local index = 1
  for k, v in pairs(rewardItems) do
    local itemView = self.mRewardList[index]
    if itemView == nil then
      itemView = UICommonItem.New()
      itemView:InitCtrl(self.ui.mScrollListChild_GrpItem.transform, true)
      table.insert(self.mRewardList, itemView)
    end
    itemView:SetItemData(v.item_id, v.item_num)
    setactive(itemView:GetRoot(), true)
    index = index + 1
  end
  self:Refresh()
end
function UIStoreAccrueItem:AddBtnClickListener(callback)
end
function UIStoreAccrueItem:Refresh()
  local isGet = NetCmdStoreData:GetRechargedByIndex(self.mAccumulateRechargeId)
  local isCanGet = self.mAccumulateRechargeData.Sum <= NetCmdStoreData:GetAccumulateRecharge()
  if CS.LuaUtils.IsNullOrDestroyed(self.ui.mTrans_Finished) then
    return
  end
  setactive(self.ui.mTrans_Finished, isGet)
  setactive(self.ui.mBtn_BtnReceive.transform.parent, not isGet and isCanGet)
  setactive(self.ui.mTrans_Unfinish, not isCanGet)
  self.ui.mText_Num.text = self.mAccumulateRechargeData.Sum
end
function UIStoreAccrueItem:OnRelease()
  self.ui = nil
  gfdestroy(self:GetRoot())
  self.super.OnRelease(self)
  MessageSys:RemoveListener(UIEvent.GetAccumulateRechargeReaward, self.OnGetAccumulateRechargeReaward)
end
function UIStoreAccrueItem:OnClickSelf()
end
