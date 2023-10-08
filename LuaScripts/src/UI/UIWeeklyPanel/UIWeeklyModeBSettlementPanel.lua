require("UI.UIBasePanel")
require("UI.UIWeeklyPanel.UIWeeklyDefine")
require("UI.Common.UICommonItem")
UIWeeklyModeBSettlementPanel = class("UIWeeklyModeBSettlementPanel", UIBasePanel)
UIWeeklyModeBSettlementPanel.__index = UIWeeklyModeBSettlementPanel
UIWeeklyModeBSettlementPanel.mItemTable = {}
function UIWeeklyModeBSettlementPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
end
function UIWeeklyModeBSettlementPanel.Close()
  UIManager.CloseUI(UIDef.UIWeeklyModeBSettlementPanel)
end
function UIWeeklyModeBSettlementPanel:OnInit(root)
  UIWeeklyModeBSettlementPanel.super.SetRoot(UIWeeklyModeBSettlementPanel, root)
  self.mUIRoot = root
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.mData = NetCmdSimulateBattleData:GetSimCombatWeeklyData()
  self.mMaxScore = self.mData:GetBMaxPoint()
  self.mCurrentScore = self.mData.gameBLastScore
  self.mData.gameBLastScore = 0
  self.mIsMax = self.mCurrentScore > self.mMaxScore
  if self.mIsMax then
    self.mMaxScore = self.mCurrentScore
    self.mData:SetBMaxPoint(self.mCurrentScore)
  end
  self:RegisterEvent()
end
function UIWeeklyModeBSettlementPanel:RegisterEvent()
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    if SceneSys.CurSceneType ~= CS.EnumSceneType.CommandCenter then
      SceneSys:ReturnMain(false)
    else
      self.Close()
    end
  end
end
function UIWeeklyModeBSettlementPanel:OnShowStart()
  self:UpdatePanel()
end
function UIWeeklyModeBSettlementPanel:UpdatePanel()
  local scoreData = self.mData:GetGameBRankDataByScore(self.mCurrentScore)
  if scoreData then
    self.ui.mText_Rank.text = scoreData.name.str
  end
  self.ui.mText_Score.text = tostring(self.mCurrentScore)
  self.ui.mText_OldMax.text = string_format(TableData.GetHintById(108119), self.mMaxScore)
  setactive(self.ui.mTrans_IsMax, self.mIsMax)
  local rewardList = UIUtils.GetKVSortItemTable(scoreData.reward)
  local index = 1
  for _, data in ipairs(rewardList) do
    local item
    if not self.mItemTable[index] then
      item = UICommonItem.New()
      item:InitCtrl(self.ui.mTrans_ItemList.transform)
      table.insert(self.mItemTable, item)
    else
      item = self.mItemTable[index]
    end
    index = index + 1
    if item then
      item:SetItemData(data.id, data.num)
    end
  end
end
function UIWeeklyModeBSettlementPanel:OnRelease()
  UIWeeklyModeBSettlementPanel.mItemTable = {}
end
function UIWeeklyModeBSettlementPanel:OnClose()
  self:ReleaseCtrlTable(self.mItemTable, true)
end
