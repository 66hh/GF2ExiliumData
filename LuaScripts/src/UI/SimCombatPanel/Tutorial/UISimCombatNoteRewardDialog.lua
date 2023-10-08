require("UI.SimCombatPanel.Tutorial.Item.UISimCombatNoteRewardItem")
require("UI.UIBasePanel")
require("UI.SimCombatPanel.Tutorial.UISimCombatNoteRewardDialogView")
UISimCombatNoteRewardDialog = class("UISimCombatNoteRewardDialog", UIBasePanel)
UISimCombatNoteRewardDialog.__index = UISimCombatNoteRewardDialog
UISimCombatNoteRewardDialog.mView = nil
UISimCombatNoteRewardDialog.progressList = {}
function UISimCombatNoteRewardDialog:ctor(csPanel)
  UISimCombatNoteRewardDialog.super.ctor(UISimCombatNoteRewardDialog, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UISimCombatNoteRewardDialog.Open()
end
function UISimCombatNoteRewardDialog.Close()
  UIManager.CloseUI(UIDef.UISimCombatNoteRewardDialog)
end
function UISimCombatNoteRewardDialog.Hide()
end
function UISimCombatNoteRewardDialog:OnInit(root, data)
  UISimCombatNoteRewardDialog.super.SetRoot(UISimCombatNoteRewardDialog, root)
  UISimCombatNoteRewardDialog.mData = data
  UISimCombatNoteRewardDialog.mView = UISimCombatNoteRewardDialogView
  self.ui = {}
  UISimCombatNoteRewardDialog.mView:InitCtrl(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function(gObj)
    UISimCombatNoteRewardDialog.Close()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_TitleClose.gameObject).onClick = function(gObj)
    UISimCombatNoteRewardDialog.Close()
  end
end
function UISimCombatNoteRewardDialog:OnShowStart()
  self:InitData()
end
function UISimCombatNoteRewardDialog:OnTop()
  self:InitData()
end
function UISimCombatNoteRewardDialog:InitData()
  local readNote = PlayerPrefs.GetString(AccountNetCmdHandler:GetUID() .. "_SimCombatNoteRead")
  local readNotes = string.split(readNote, ",")
  self.readLevels = {}
  local finished = 0
  for i = 1, #readNotes do
    local levelId = tonumber(readNotes[i])
    if levelId ~= nil and levelId ~= 0 then
      local levelData = TableData.listSimCombatTutorialLevelsDatas:GetDataById(levelId)
      table.insert(self.readLevels, levelData)
      finished = finished + levelData.tutorials_mark
    end
  end
  self.ui.mText_Progress.text = TableData.GetHintReplaceById(103089, finished)
  local progressDataList = TableData.listSimCombatTutorialProgressDatas:GetList()
  for i = 0, progressDataList.Count - 1 do
    do
      local data = progressDataList[i]
      local item
      if self.progressList[i + 1] == nil then
        item = UISimCombatNoteRewardItem.New()
        item:InitCtrl(self.ui.mTrans_Content)
        table.insert(self.progressList, item)
      else
        item = self.progressList[i + 1]
      end
      item:SetData(data)
      local isReceived = NetCmdSimulateBattleData:SimCombatTutorialMarkReward(data.id)
      local completed = finished >= data.ppt_progress
      local canGet = not isReceived and completed
      if canGet then
        UIUtils.GetButtonListener(item.rewardItem.ui.mBtn_Select.gameObject).onClick = function()
          self:OnReceiveItem(item)
        end
      end
      item.rewardItem:SetRedPoint(canGet)
      item.rewardItem:SetReceivedIcon(isReceived)
      item:SetComplete(completed and isReceived)
      item:SetLocked(not completed)
    end
  end
end
function UISimCombatNoteRewardDialog:OnReceiveItem(item)
  NetCmdSimulateBattleData:ReqSimCombatTutorialTakeNoteReward(item.mData.id, function()
    self:TakeQuestRewardCallBack()
  end)
end
function UISimCombatNoteRewardDialog:TakeQuestRewardCallBack()
  UIManager.OpenUIByParam(UIDef.UICommonReceivePanel)
end
function UISimCombatNoteRewardDialog:OnClose()
  for i, progress in ipairs(self.progressList) do
    gfdestroy(progress:GetRoot())
  end
  self.progressList = {}
end
function UISimCombatNoteRewardDialog:OnRelease()
  self.progressList = {}
end
