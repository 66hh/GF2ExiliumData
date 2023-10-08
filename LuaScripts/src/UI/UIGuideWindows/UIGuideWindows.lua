require("UI.UIGuideWindows.UIGuideIndicatorItemV2")
UIGuideWindows = class("UIGuideWindows", UIBasePanel)
function UIGuideWindows:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.HideSceneBackground = false
  csPanel.Type = UIBasePanelType.Dialog
  csPanel.UsePool = false
end
function UIGuideWindows:Close()
  UISystem:CloseUI(self.mCSPanel, not TutorialSystem.IsInTutorial)
end
function UIGuideWindows:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_FinishBtn.gameObject).onClick = function()
    UIGuideWindows:Close()
    if UIGuideWindows.OnPageCloseCallback ~= nil then
      UIGuideWindows.OnPageCloseCallback()
    end
    UIGuideWindows.OnPageCloseCallback = nil
  end
  UIUtils.GetButtonListener(self.ui.mBtn_PreviousPageBtn.gameObject).onClick = function()
    UIGuideWindows:OnBtnPreviousPage()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_NextPageBtn.gameObject).onClick = function()
    UIGuideWindows:OnBtnNextPage()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BgNextPage.gameObject).onClick = function()
    UIGuideWindows:OnBtnNextPage()
  end
  function self.onSetTutorialInfoCallback()
    self:OnSetTutorialInfoCallback()
  end
  MessageSys:AddListener(CS.GF2.Message.UIEvent.TutorialInfoCallback, self.onSetTutorialInfoCallback)
  setactivewithcheck(self.ui.mTrans_PicRoot, false)
  setactivewithcheck(self.ui.mTrans_VideoRoot, false)
  self.ui.mCriMovieCtrl:SetLoop(true)
end
function UIGuideWindows:OnInit(root, data)
  self.OnPageCloseCallback = nil
  self.mIsPop = true
  self.mIsGuidePanel = true
  self.mStageId = 0
  self.tutorialGroupId = 0
  self.mStageId = data[1] or self.mStageId
  self.OnPageCloseCallback = data[2]
  if type(data) == "table" and #data == 3 then
    self.tutorialGroupId = data[3] or self.tutorialGroupId
  elseif self.mStageId == 0 then
    self.tutorialGroupId = data[3] or self.tutorialGroupId
  end
  self.mTags = {}
  setactive(self.ui.mBtn_FinishBtn.gameObject, false)
  self.mShowConfirm = true
  self.mCurIndex = 0
  if self.mStageId ~= 0 then
    if TutorialSystem.IsInTutorial then
      self.mShowConfirm = NetCmdStageRecordData:IsRecorded(self.mStageId)
    end
    self:InitWithStageId()
  elseif self.tutorialGroupId ~= 0 then
    self:InitWithTutorialGroupId(self.tutorialGroupId)
  end
end
function UIGuideWindows:OnShowStart()
  self.ui.mCanvasGroup.blocksRaycasts = true
  self.ui.mCanvasGroup.interactable = false
  TimerSys:DelayCall(0.15, function()
    self.ui.mCanvasGroup.interactable = true
  end)
end
function UIGuideWindows:OnClose()
  self.pageDataList = nil
  self.ui.mCanvasGroup.interactable = false
  for i, tag in ipairs(self.mTags) do
    gfdestroy(tag:GetRoot())
  end
  self.ui.mCriMovieCtrl:Stop()
end
function UIGuideWindows:OnRelease()
  self.mShowConfirm = false
  self.mStageId = 0
  self.tutorialGroupId = 0
  self.mTags = nil
  self.OnPageCloseCallback = nil
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.TutorialInfoCallback, self.onSetTutorialInfoCallback)
end
function UIGuideWindows:InitWithStageId()
  if self.mStageId == 0 then
    self:Close()
  end
  local stageData = TableData.listStageDatas:GetDataById(self.mStageId)
  if stageData ~= nil and stageData.stage_guide_groupid and stageData.stage_guide_groupid ~= 0 then
    self:InitWithTutorialGroupId(stageData.stage_guide_groupid)
  end
end
function UIGuideWindows:InitWithTutorialGroupId(tutorialGroupId)
  self.pageDataList = TableData.GetSysGuidePagesByGroupId(tutorialGroupId)
  if self.pageDataList == nil or self.pageDataList.Count == 0 then
    gferror(" guidePages 找不到  tutorialGroupId  " .. tutorialGroupId)
    self:Close()
    return
  end
  for i = 1, self.pageDataList.Count do
    local simpleTag = UIGuideIndicatorItemV2:New()
    simpleTag:InitCtrl(self.ui.mProgressBarLayout)
    table.insert(self.mTags, simpleTag)
  end
  self:UpdatePage(0, self.pageDataList[0])
  setactive(self.ui.mBtn_PreviousPageBtn.gameObject, false)
  setactive(self.ui.mBtn_NextPageBtn.gameObject, self.pageDataList.Count ~= 1)
  setactive(self.ui.mBtn_FinishBtn.gameObject, self.mShowConfirm or self.pageDataList.Count == 1)
end
function UIGuideWindows:UpdatePage(index, data)
  for i = 1, #self.mTags do
    if i == index + 1 then
      self.mTags[i]:SetOn(true)
    else
      self.mTags[i]:SetOn(false)
    end
  end
  setactivewithcheck(self.ui.mTrans_PicRoot, false)
  setactivewithcheck(self.ui.mTrans_VideoRoot, false)
  if data.type == 1 then
    self:ShowSprite(data)
  elseif data.type == 2 then
    self:ShowVideo(data)
  else
    gferror("为定义的类型!   " .. tostring(data.type))
  end
end
function UIGuideWindows:ShowSprite(data)
  setactivewithcheck(self.ui.mTrans_PicRoot, true)
  self.ui.mImage_GuideImage.sprite = ResSys:GetSpriteByFullPath(data.media)
  self.ui.mText_GuideText.text = data.text.str
end
function UIGuideWindows:ShowVideo(data)
  setactivewithcheck(self.ui.mTrans_VideoRoot, true)
  self.ui.mCriMovieCtrl:SetFileAndPrepare(data.media)
  self.ui.mCriMovieCtrl:RestartAsync()
  self.ui.mText_GuideText.text = data.text.str
end
function UIGuideWindows:OnBtnPreviousPage()
  if self.mCurIndex == 0 then
    return
  end
  self.mCurIndex = self.mCurIndex - 1
  if self.mCurIndex <= 0 then
    self.mCurIndex = 0
    setactive(self.ui.mBtn_PreviousPageBtn.gameObject, false)
  end
  setactive(self.ui.mBtn_NextPageBtn.gameObject, true)
  self:UpdatePage(self.mCurIndex, self.pageDataList[self.mCurIndex])
  self.ui.mAnimator:SetBool("Previous", true)
end
function UIGuideWindows:OnBtnNextPage()
  if self.mCurIndex == self.pageDataList.Count - 1 then
    return
  end
  self.mCurIndex = self.mCurIndex + 1
  if self.mCurIndex >= self.pageDataList.Count - 1 then
    self.mCurIndex = self.pageDataList.Count - 1
    setactive(self.ui.mBtn_FinishBtn.gameObject, true)
    setactive(self.ui.mBtn_NextPageBtn.gameObject, false)
  end
  setactive(self.ui.mBtn_PreviousPageBtn.gameObject, true)
  self:UpdatePage(self.mCurIndex, self.pageDataList[self.mCurIndex])
  self.ui.mAnimator:SetBool("Next", true)
end
function UIGuideWindows:OnSetTutorialInfoCallback(msg)
  self.OnPageCloseCallback = msg.Content
end
