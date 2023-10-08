require("UI.StoryChapterPanel.UIBatHardAnalysisDialogView")
require("UI.UIBasePanel")
UIBatHardAnalysisDialog = class("UIBatHardAnalysisDialog", UIBasePanel)
UIBatHardAnalysisDialog.__index = UIBatHardAnalysisDialog
function UIBatHardAnalysisDialog:ctor(csPanel)
  UIBatHardAnalysisDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIBatHardAnalysisDialog:OnRelease()
end
function UIBatHardAnalysisDialog:OnClose()
  self:ReleaseTimers()
  if self.callback then
    self.callback()
    self.callback = nil
  end
  self.curIndex = nil
  self.tipsList = nil
end
function UIBatHardAnalysisDialog:OnInit(root, data)
  self:SetRoot(root)
  self.mView = UIBatHardAnalysisDialogView.New()
  self.ui = {}
  self.mView:InitCtrl(root, self.ui)
  self.mData = data.storyData
  self.callback = data.callBack
  self.showCallBack = data.showCallBack
  self.maxAnalysisNum = data.storyData.unlock_num
  self.isChapterLastStory = false
  self.isLastStory = data.isLast
  self.curIndex = 0
  self.tipsList = {}
  self.showString = TableData.GetHintById(193004)
  self.formatString = TableData.GetHintById(193005)
  self:SetTipList()
end
function UIBatHardAnalysisDialog:SetTipList()
  for i = 1, self.mData.unlock_num do
    local data = {}
    data.index = i
    table.insert(self.tipsList, data)
  end
  self.changeTime = 2.03 / #self.tipsList
  self.closeTime = 0.8700000000000001
  self.ui.mText_Tittle.text = self.showString
  self:ShowTipList()
end
function UIBatHardAnalysisDialog:ShowTipList()
  self.curIndex = self.curIndex + 1
  if self.curIndex <= #self.tipsList then
    local d = self.tipsList[self.curIndex]
    self.ui.mText_TipText.text = string_format(self.formatString, d.index, self.maxAnalysisNum)
    self:DelayCall(self.changeTime, function()
      if self.showCallBack then
        self.showCallBack()
        self.showCallBack = nil
      end
      self:ShowTipList()
    end)
  else
    local str = ""
    if self.isLastStory then
      str = TableData.GetHintById(193006)
    elseif self.isChapterLastStory then
      str = "下一章节已解锁（程序所写）"
    else
      str = TableData.GetHintById(193007)
    end
    self.ui.mText_Tittle.text = str
    self:DelayCall(self.closeTime, function()
      UIManager.CloseUI(UIDef.UIBatHardAnalysisDialog)
    end)
  end
end
