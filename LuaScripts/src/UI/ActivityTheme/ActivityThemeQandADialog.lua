require("UI.UIBasePanel")
require("UI.ActivityTheme.Btn_ActivityThemeOptionItem")
ActivityThemeQandADialog = class("ActivityThemeQandADialog", UIBasePanel)
ActivityThemeQandADialog.__index = ActivityThemeQandADialog
function ActivityThemeQandADialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function ActivityThemeQandADialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.optionList = {}
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:OnClickClose()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close1.gameObject).onClick = function()
    self:OnClickClose()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Next.gameObject).onClick = function()
    setactive(self.ui.mTrans_Tip.gameObject, true)
    setactive(self.ui.mBtn_Next.gameObject, false)
    setactive(self.ui.mBtn_Complete.gameObject, false)
    self:UpdateInfo()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Complete.gameObject).onClick = function()
    NetCmdThemeData:SendThemeAnswerQuestion(self.entraId, function(ret)
      UIManager.CloseUI(UIDef.ActivityThemeQandADialog)
    end)
  end
end
function ActivityThemeQandADialog:OnClickClose()
  if self.currQuestIndex == self.questIdList.Count then
    NetCmdThemeData:SendThemeAnswerQuestion(self.entraId, function(ret)
      UIManager.CloseUI(UIDef.ActivityThemeQandADialog)
    end)
  else
    UIManager.CloseUI(UIDef.ActivityThemeQandADialog)
  end
end
function ActivityThemeQandADialog:OnInit(root, data)
  self.entraId = data.entraId
  self.groupId = data.groupId
  self.currQuestIndex = NetCmdThemeData:GetQuestAnswerCount()
  self.isQuestedList = {}
  self.questIdList = NetCmdThemeData:GetQuestions()
  self:UpdateInfo()
  if self.currQuestIndex == 0 then
    self:UpdateBtnState()
  else
    setactive(self.ui.mTrans_Tip.gameObject, true)
    setactive(self.ui.mBtn_Next.gameObject, false)
    setactive(self.ui.mBtn_Complete.gameObject, false)
  end
end
function ActivityThemeQandADialog:UpdateInfo()
  self.ui.mTextFit_Detail.text = ""
  if self.questIdList.Count <= self.currQuestIndex then
    CS.PopupMessageManager.PopupString("没有随机出来题")
    return
  end
  local questId = self.questIdList[self.currQuestIndex]
  self.currQuestConfig = TableData.listWarmUpQuestionDatas:GetDataById(questId)
  if self.currQuestConfig then
    local title = string_format(TableData.GetHintById(270134), self.currQuestIndex + 1, self.questIdList.Count)
    self.ui.mText_Question.text = title .. self.currQuestConfig.question_txt.str
    local randomBool = math.random(1, 100) % 2 == 0
    local questList = {
      randomBool,
      not randomBool
    }
    for i = 1, 2 do
      if self.optionList[i] then
        self.optionList[i]:SetData(self.currQuestConfig, questList[i], i - 1, self)
      else
        local cell = Btn_ActivityThemeOptionItem.New()
        cell:InitCtrl(self.ui.mTrans_Option)
        cell:SetData(self.currQuestConfig, questList[i], i - 1, self)
        table.insert(self.optionList, cell)
      end
    end
  end
end
function ActivityThemeQandADialog:UpdateBtnState()
  setactive(self.ui.mTrans_Tip.gameObject, self.currQuestIndex == 0)
  setactive(self.ui.mBtn_Next.gameObject, self.currQuestIndex > 0 and self.currQuestIndex < self.questIdList.Count)
  setactive(self.ui.mBtn_Complete.gameObject, self.currQuestIndex == self.questIdList.Count)
end
function ActivityThemeQandADialog:UpdateAnswerDetail()
  self.ui.mTextFit_Detail.text = self.currQuestConfig.analysis.str
end
function ActivityThemeQandADialog:OnQuestIndexAdd(answer)
  local questId = self.questIdList[self.currQuestIndex]
  NetCmdThemeData:SetQuestAnswer(questId, answer)
  self.currQuestIndex = self.currQuestIndex + 1
  self:UpdateBtnState()
end
function ActivityThemeQandADialog:OnShowStart()
  self.ui.mTrans_Content.anchoredPosition = vector2zero
end
function ActivityThemeQandADialog:OnShowFinish()
end
function ActivityThemeQandADialog:OnTop()
end
function ActivityThemeQandADialog:OnBackFrom()
end
function ActivityThemeQandADialog:OnClose()
  self.isQuestedList = {}
end
function ActivityThemeQandADialog:OnHide()
  self.isQuestedList = {}
end
function ActivityThemeQandADialog:OnHideFinish()
end
function ActivityThemeQandADialog:OnRelease()
end
