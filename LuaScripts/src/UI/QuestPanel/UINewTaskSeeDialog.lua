require("UI.UIBasePanel")
UINewTaskSeeDialog = class("UINewTaskSeeDialog", UIBasePanel)
UINewTaskSeeDialog.__index = UINewTaskSeeDialog
function UINewTaskSeeDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UINewTaskSeeDialog:OnInit(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.questData = data
  self.rewardShowList = {}
  UIUtils.AddBtnClickListener(self.ui.mBtn_Goto.gameObject, function()
    self:onClickGoto()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Close.gameObject, function()
    UIManager.CloseUI(UIDef.UINewTaskSeeDialog)
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_CloseDialog.gameObject, function()
    UIManager.CloseUI(UIDef.UINewTaskSeeDialog)
  end)
  self:Refresh()
end
function UINewTaskSeeDialog:Refresh()
  self.ui.mText_Name.text = TableData.GetHintById(20)
  self.ui.mText_QuestName.text = self.questData.name
  self.ui.mText_DescContent.text = self.questData.description
  self.ui.mText_TargetNum.text = self.questData:GetProgressStr()
  self.rewardShowList = self:UpdateRewardList()
end
function UINewTaskSeeDialog:UpdateRewardList()
  local tempTable = {}
  local guideQuestPhaseData = TableData.listGuideQuestDatas:GetDataById(self.questData.Id)
  for itemId, num in pairs(guideQuestPhaseData.reward_list) do
    local itemView = UICommonItem.New()
    itemView:InitCtrl(self.ui.mScrollChild_Item.transform)
    itemView:SetItemData(itemId, num)
    table.insert(tempTable, itemView)
  end
  return tempTable
end
function UINewTaskSeeDialog:onClickGoto()
  local jumpID = tonumber(self.questData.link)
  local result = UIUtils.CheckIsUnLock(jumpID)
  if result ~= 0 then
    local str = ""
    if 0 < result then
      local unlockData = TableData.listUnlockDatas:GetDataById(result)
      str = UIUtils.CheckUnlockPopupStr(unlockData)
    elseif result == -2 then
      str = TableData.GetHintById(103070)
    elseif result == -1 then
      local jumpData = TableData.listJumpListContentnewDatas:GetDataById(tonumber(jumpID))
      str = string_format(TableData.GetHintById(jumpData.plan_open_hint), TableData.GetHintById(103054))
    end
    PopupMessageManager.PopupString(str)
  else
    SceneSwitch:SwitchByID(jumpID)
  end
end
function UINewTaskSeeDialog:OnClose()
  self:ReleaseCtrlTable(self.rewardShowList, true)
end
