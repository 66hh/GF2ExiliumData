require("UI.SimCombatPanel.Tutorial.Item.UISimCombatNoteItem")
require("UI.UIBasePanel")
require("UI.SimCombatPanel.Tutorial.UISimCombatNotePanelView")
UISimCombatNotePanel = class("UISimCombatNotePanel", UIBasePanel)
UISimCombatNotePanel.__index = UISimCombatNotePanel
function UISimCombatNotePanel:ctor()
  UISimCombatNotePanel.super.ctor(self)
end
function UISimCombatNotePanel.Open()
end
function UISimCombatNotePanel.Hide()
end
function UISimCombatNotePanel:OnInit(root, data)
  self.RedPointType = {
    RedPointConst.ChapterReward
  }
  self:SetRoot(root)
  self.mData = data
  self.mView = UISimCombatNotePanelView.New()
  self.ui = {}
  self.mView:InitCtrl(root, self.ui)
  self.ui.mTrans_RedPoint = self.ui.mBtn_Reward.transform:Find("Root/Trans_RedPoint")
  self.chapterList = {}
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function(gObj)
    UIManager.CloseUI(UIDef.UISimCombatNotePanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Reward.gameObject).onClick = function()
    UIManager.OpenUI(UIDef.UISimCombatNoteRewardDialog)
  end
end
function UISimCombatNotePanel:OnShowStart()
  self:InitData()
end
function UISimCombatNotePanel:InitData()
  self:InitChapterData()
  self:UpdateRewardRedPoint()
end
function UISimCombatNotePanel:InitChapterData()
  local chapterDataList = NetCmdSimulateBattleData:GetSimBattleTeachingChapterList(1)
  for i = 0, chapterDataList.Count - 1 do
    local data = chapterDataList[i]
    local item
    if self.chapterList[i + 1] == nil then
      item = UISimCombatNoteItem.New()
      item:InitCtrl(self.ui.mTrans_Content)
      table.insert(self.chapterList, item)
    else
      item = self.chapterList[i + 1]
    end
    item:SetData(data)
  end
end
function UISimCombatNotePanel:OnClose()
  self:ReleaseCtrlTable(self.chapterList, true)
  self.chapterList = nil
  self.mView = nil
end
function UISimCombatNotePanel:OnRelease()
end
function UISimCombatNotePanel:OnTop()
  self:OnShowStart()
end
function UISimCombatNotePanel:UpdateRewardRedPoint()
  setactive(self.ui.mTrans_RedPoint, NetCmdSimulateBattleData:CheckTeachingNoteProgressRedPoint())
end
