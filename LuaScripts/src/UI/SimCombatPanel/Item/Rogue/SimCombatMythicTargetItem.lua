require("UI.UIBaseCtrl")
SimCombatMythicTargetItem = class("SimCombatMythicTargetItem", UIBaseCtrl)
local self = SimCombatMythicTargetItem
function SimCombatMythicTargetItem:ctor()
  self.rogueTaskData = nil
  self.targetState = nil
  self.rogueRewardList = {}
  self.rogueRewardObjList = {}
end
function SimCombatMythicTargetItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
end
function SimCombatMythicTargetItem:SetData(rogueTaskData, state)
  self.rogueTaskData = rogueTaskData
  self.targetState = state
  self:ShowRogueTargetItem()
end
function SimCombatMythicTargetItem:ShowRogueTargetItem()
  setactive(self.ui.mTrans_ImgNormal, self.rogueTaskData.type == 1)
  setactive(self.ui.mTrans_ImgChallenge, self.rogueTaskData.type == 2)
  self.ui.mText_Tittle.text = self.rogueTaskData.Name.str
  self.ui.mText_Target.text = self.rogueTaskData.Description.str
  local value = NetCmdQuestData:GetSimCombatRogueProgressCount(self.rogueTaskData)
  local percent = value / self.rogueTaskData.ConditionNum
  if 1 < percent then
    percent = 1
  end
  self.ui.mSlider_ProgressBar.FillAmount = percent
  self.ui.mText_Percent.text = tostring(math.ceil(percent * 100)) .. "%"
  setactive(self.ui.mTrans_Unfinish, self.targetState == UISimCombatRogueGlobal.RogueTargetState.Unfinish)
  setactive(self.ui.mTrans_Finished, self.targetState == UISimCombatRogueGlobal.RogueTargetState.Finished)
  setactive(self.ui.mBtn_Receive.gameObject, self.targetState == UISimCombatRogueGlobal.RogueTargetState.Receive)
  if self.targetState == UISimCombatRogueGlobal.RogueTargetState.Receive or self.targetState == UISimCombatRogueGlobal.RogueTargetState.Finished then
    self.ui.mText_Percent.text = "100%"
  end
  self:SetRewards()
  UIUtils.GetButtonListener(self.ui.mBtn_Receive.gameObject).onClick = function()
    if TipsManager.CheckItemIsOverflowAndStopByList(self.rogueRewardList) then
      return
    end
    CS.GF2.Message.MessageSys.Instance:SendMessage(CS.GF2.Message.RogueEvent.OnClickReceiveTarget, true)
    NetCmdSimCombatRogueData:ReqGetReward(self.rogueTaskData.Id, function()
      CS.GF2.Message.MessageSys.Instance:SendMessage(CS.GF2.Message.RogueEvent.SetTargetList, nil)
      CS.GF2.Message.MessageSys.Instance:SendMessage(CS.GF2.Message.RogueEvent.OnClickReceiveTarget, false)
      UIManager.OpenUIByParam(UIDef.UICommonReceivePanel, {
        nil,
        function()
        end
      })
    end)
  end
end
function SimCombatMythicTargetItem:SetRewards()
  for i, v in ipairs(self.rogueRewardObjList) do
    v:SetItemData()
  end
  local index = 0
  local rewardList = {}
  for i, v in pairs(self.rogueTaskData.RewardList) do
    table.insert(rewardList, {id = i, rogueTaskData = v})
  end
  table.sort(rewardList, function(a, b)
    return a.id < b.id
  end)
  for i, v in ipairs(rewardList) do
    index = index + 1
    local item
    if index <= #self.rogueRewardObjList then
      item = self.rogueRewardObjList[index]
    else
      item = UICommonItem.New()
      item:InitCtrl(self.ui.mScrollListChild_Item)
      table.insert(self.rogueRewardObjList, item)
    end
    item:SetItemData(v.id, v.rogueTaskData)
    self.rogueRewardList[v.id] = v.rogueTaskData
  end
end
function SimCombatMythicTargetItem:OnRelease()
  self:DestroySelf()
end
