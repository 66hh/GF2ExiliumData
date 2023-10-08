require("UI.SimCombatPanel.Tutorial.Item.UISimCombatTutorialItem")
require("UI.UIBasePanel")
require("UI.SimCombatPanel.Tutorial.UISimCombatTutorialPanelView")
UISimCombatTutorialPanel = class("UISimCombatTutorialPanel", UIBasePanel)
UISimCombatTutorialPanel.__index = UISimCombatTutorialPanel
UISimCombatTutorialPanel.mView = nil
UISimCombatTutorialPanel.chapterList = {}
UISimCombatTutorialPanel.READ_LEVEL_KEY = nil
function UISimCombatTutorialPanel:ctor()
  UISimCombatTutorialPanel.super.ctor(self)
  UISimCombatTutorialPanel.READ_LEVEL_KEY = AccountNetCmdHandler:GetUID() .. "_SimCombatNoteRead"
end
function UISimCombatTutorialPanel.Open()
end
function UISimCombatTutorialPanel.Close()
  UIManager.CloseUI(UIDef.UISimCombatTutorialPanel)
end
function UISimCombatTutorialPanel.Hide()
end
function UISimCombatTutorialPanel:OnInit(root, data)
  self.RedPointType = {
    RedPointConst.ChapterReward
  }
  UISimCombatTutorialPanel.super.SetRoot(UISimCombatTutorialPanel, root)
  UISimCombatTutorialPanel.mData = data
  UISimCombatTutorialPanel.mView = UISimCombatTutorialPanelView
  self.ui = {}
  UISimCombatTutorialPanel.mView:InitCtrl(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function(gObj)
    UISimCombatTutorialPanel.Close()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Guide.gameObject).onClick = function()
    UIManager.OpenUI(UIDef.UISimCombatNotePanel)
  end
  local chapterDataList = NetCmdSimulateBattleData:GetSimBattleTeachingChapterList(1)
  for i = 0, chapterDataList.Count - 1 do
    local chapterData = chapterDataList[i]
    local item
    if self.chapterList[i + 1] == nil then
      item = UISimCombatTutorialItem.New()
      item:InitCtrl(self.ui.mTrans_Content)
      table.insert(self.chapterList, item)
      UIUtils.GetButtonListener(item.ui.mBtn_Root.gameObject).onClick = function()
        if not chapterData.IsUnlocked or not chapterData.IsPrevCompleted then
          CS.PopupMessageManager.PopupString(TableData.GetHintById(103039))
          return
        end
        if chapterData:CheckRedPoint() then
          chapterData:RemoveRedPoint()
        end
        UIManager.OpenUIByParam(UIDef.UISimCombatTutorialChapterPanel, chapterData)
      end
    end
  end
  function self.OnItemShow(index)
    self.chapterList[index + 1]:SetData(chapterDataList[index])
  end
  self.ui.mFade_Content:onShow("+", self.OnItemShow)
end
function UISimCombatTutorialPanel:OnRecover()
  self:OnShowStart()
end
function UISimCombatTutorialPanel:OnBackFrom()
  self:OnShowStart()
end
function UISimCombatTutorialPanel:OnShowStart()
  self.ui.mFade_Content:InitFade()
  self:UpdateRewardRedPoint()
end
function UISimCombatTutorialPanel:OnClose()
  self.ui.mFade_Content:onShow("-", self.OnItemShow)
end
function UISimCombatTutorialPanel:OnRelease()
  self.chapterList = {}
end
function UISimCombatTutorialPanel:OnSave()
  self.chapterList = {}
end
function UISimCombatTutorialPanel:UpdateRewardRedPoint()
  setactive(self.ui.mTrans_RedPoint, NetCmdSimulateBattleData:CheckTeachingNoteReadRedPoint() or NetCmdSimulateBattleData:CheckTeachingNoteProgressRedPoint())
end
function UISimCombatTutorialPanel.GetReadLevels()
  local readNote = PlayerPrefs.GetString(AccountNetCmdHandler:GetUID() .. "_SimCombatNoteRead")
  local readNotes = string.split(readNote, ",")
  local readLevels = {}
  local finished = 0
  for i = 1, #readNotes do
    local levelId = tonumber(readNotes[i])
    if levelId ~= nil and 0 < levelId then
      local levelData = TableData.listSimCombatTutorialLevelsDatas:GetDataById(levelId)
      table.insert(readLevels, levelId)
      finished = finished + levelData.tutorials_mark
    end
  end
  return readLevels, finished
end
