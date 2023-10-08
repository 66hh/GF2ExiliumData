require("UI.UIBasePanel")
require("UI.UIWeeklyPanel.UIWeeklyChallengeProgressDialogItem")
require("UI.UIWeeklyPanel.UIWeeklyDefine")
UIWeeklyChallengeProgressDialog = class("UIWeeklyChallengeProgressDialog", UIBasePanel)
UIWeeklyChallengeProgressDialog.__index = UIWeeklyChallengeProgressDialog
function UIWeeklyChallengeProgressDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIWeeklyChallengeProgressDialog:OnInit(root, data)
  self.super.SetRoot(UIWeeklyChallengeProgressDialog, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.mData = data.data
  self.mOnClose = data.onClose
  self:RegisterEvent()
  function self.ui.mVirtualListEx_QuestList.itemProvider()
    local item = self:ItemProvider()
    return item
  end
  function self.ui.mVirtualListEx_QuestList.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  function self.NotOpenTipCheck()
    UIWeeklyDefine.NotOpenTipCheck(self.NotOpenTipCheck)
  end
  MessageSys:AddListener(UIEvent.UserTapScreen, self.NotOpenTipCheck)
end
function UIWeeklyChallengeProgressDialog:RegisterEvent()
  UIUtils.GetButtonListener(self.ui.mBtn_BgClose.gameObject).onClick = function()
    if self.mOnClose then
      self.mOnClose(false)
    end
    UIManager.CloseUI(UIDef.UIWeeklyChallengeProgressDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    if self.mOnClose then
      self.mOnClose(false)
    end
    UIManager.CloseUI(UIDef.UIWeeklyChallengeProgressDialog)
  end
end
function UIWeeklyChallengeProgressDialog:ItemProvider()
  local itemView = UIWeeklyChallengeProgressDialogItem.New()
  itemView:InitCtrl(self.ui.mVirtualListEx_ChildItem.transform, self.ui.mVirtualListEx_ChildItem.childItem, function(questData)
    self:GetReward(questData)
  end)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIWeeklyChallengeProgressDialog:GetReward(questData)
  NetCmdSimulateBattleData:ReqWeeklySimCombatChallengeQuestTakeReward(questData.Id, function(ret)
    if ret ~= ErrorCodeSuc then
      return
    end
    local onclick = function()
      self:UpdatePanel()
    end
    UIManager.OpenUIByParam(UIDef.UICommonReceivePanel, {nil, onclick})
  end)
end
function UIWeeklyChallengeProgressDialog:IsCanEnterNextChallengeLevel()
  for i = 1, #self.questList do
    local questData = self.questList[i]
    if not questData.isReceived then
      return false
    end
  end
  local currentLevel = self.mData.currentChallengeLevel
  local maxLevel = self.mData.cycleData.max_level
  return currentLevel < maxLevel
end
function UIWeeklyChallengeProgressDialog:ItemRenderer(index, renderData)
  local data = self.questList[index + 1]
  local item = renderData.data
  item:SetData(data)
end
function UIWeeklyChallengeProgressDialog:OnShowStart()
  self:UpdatePanel()
  if self:IsCanEnterNextChallengeLevel() then
    self:EnterNextChallengeLevel()
  end
end
function UIWeeklyChallengeProgressDialog:UpdatePanel()
  local questList = NetCmdSimulateBattleData:GetWeeklyQuestListByType(self.mData.degreeData.quest_challenge_type)
  if not questList then
    return
  end
  self.questList = {}
  for i = 0, questList.Count - 1 do
    table.insert(self.questList, questList[i])
  end
  self.ui.mText_Title.text = string_format(TableData.GetHintById(108099), self.mData.currentChallengeLevel)
  self.ui.mVirtualListEx_QuestList.numItems = self.questList and #self.questList or 0
  self.ui.mVirtualListEx_QuestList:Refresh()
end
function UIWeeklyChallengeProgressDialog:EnterNextChallengeLevel()
  local currentChallengeLevel = self.mData.currentChallengeLevel
  local maxLevel = self.mData.cycleData.max_level
  if currentChallengeLevel >= maxLevel then
    return
  end
  NetCmdSimulateBattleData:ReqSimCombatWeekEnterNextLevel(function()
    UIManager.CloseUI(UIDef.UIWeeklyChallengeProgressDialog)
  end)
end
function UIWeeklyChallengeProgressDialog:OnClose()
  MessageSys:RemoveListener(UIEvent.UserTapScreen, self.NotOpenTipCheck)
end
