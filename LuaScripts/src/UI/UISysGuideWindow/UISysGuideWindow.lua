require("UI.UIGuideWindows.UIGuideIndicatorItemV2")
require("UI.UIBasePanel")
UISysGuideWindow = class("UISysGuideWindow", UIBasePanel)
UISysGuideWindow.__index = UISysGuideWindow
UISysGuideWindow.mSysId = 0
UISysGuideWindow.pageList = {}
UISysGuideWindow.pageDataList = nil
UISysGuideWindow.mShowConfirm = false
UISysGuideWindow.mCurIndex = 0
UISysGuideWindow.mTags = nil
UISysGuideWindow.OnPageCloseCallback = nil
function UISysGuideWindow:ctor(csPanel)
  UISysGuideWindow.super.ctor(self)
  self.mCSPanel = csPanel
  csPanel.Type = UIBasePanelType.Dialog
  csPanel.UsePool = false
end
function UISysGuideWindow:Close()
  MessageSys:SendMessage(CS.GF2.Message.UIEvent.CloseAISign, nil, true)
  UIManager.CloseUI(self.mCSPanel)
end
function UISysGuideWindow:OnRelease()
  self.mShowConfirm = false
  self.mSysId = 0
  self.mTags = nil
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.TutorialInfoCallback, self.tutorialCallback)
end
function UISysGuideWindow:OnInit(root, data)
  UISysGuideWindow.super.SetRoot(UISysGuideWindow, root)
  self.mIsPop = true
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  if data.Count ~= nil and data.Count > 0 then
    self.pageDataList = data
  elseif data[1] ~= nil and data[1].Count ~= nil and 0 < data[1].Count and data[2] ~= nil then
    self.pageDataList = data[1]
    self.pageNo = data[2]
  else
    self.mSysId = data[1]
  end
  self.mTags = {}
  UIUtils.GetButtonListener(self.ui.mBtn_FinishBtn.gameObject).onClick = function()
    if self.OnPageCloseCallback ~= nil then
      self:OnPageCloseCallback()
    end
    self.OnPageCloseCallback = nil
    UISysGuideWindow:Close()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_PreviousPageBtn.gameObject).onClick = function()
    self:OnBtnPreviousPage()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_NextPageBtn.gameObject).onClick = function()
    self:OnBtnNextPage()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BgNextPage.gameObject).onClick = function()
    self:OnBtnNextPage()
  end
  function self.tutorialCallback(msg)
    self:OnSetTutorialInfoCallback(msg)
  end
  MessageSys:AddListener(CS.GF2.Message.UIEvent.TutorialInfoCallback, self.tutorialCallback)
  MessageSys:SendMessage(CS.GF2.Message.UIEvent.CloseAISign, nil, false)
  self:InitPanel()
end
function UISysGuideWindow:OnShowStart()
  if self.pageNo ~= nil then
    self.mCurIndex = self.pageNo
    setactive(self.ui.mBtn_FinishBtn.gameObject, self.mCurIndex == self.pageDataList.Count - 1)
    setactive(self.ui.mBtn_NextPageBtn.gameObject, self.mCurIndex < self.pageDataList.Count - 1)
    setactive(self.ui.mBtn_PreviousPageBtn.gameObject, self.mCurIndex > 0)
    self:UpdatePage(self.mCurIndex, self.pageDataList[self.mCurIndex])
  end
end
function UISysGuideWindow:InitPanel()
  setactive(self.mUIRoot, true)
  self.mCurIndex = 0
  self.mShowConfirm = true
  if self.mSysId and self.mSysId ~= 0 or self.pageDataList ~= nil then
    if self.mSysId and self.mSysId ~= 0 then
      local sysData = TableData.listTutorialSystemDatas:GetDataById(self.mSysId)
      if sysData.id and sysData.id ~= 0 then
        self.pageDataList = TableData.GetSysGuidePagesByGroupId(sysData.id)
        if self.pageDataList == nil or self.pageDataList.Count == 0 then
          gferror(" systemPages 找不到  id  " .. sysData.id)
          return
        end
      end
    end
    for i = 1, self.pageDataList.Count do
      local simpleTag = UIGuideIndicatorItemV2:New()
      simpleTag:InitCtrl(self.ui.mProgressBarLayout)
      table.insert(self.mTags, simpleTag)
    end
    self.mBtn_y = self.ui.mBtn_NextPageBtn.transform.anchoredPosition.y
    self:UpdatePage(0, self.pageDataList[0])
    setactive(self.ui.mBtn_PreviousPageBtn.gameObject, false)
    setactive(self.ui.mBtn_NextPageBtn.gameObject, self.pageDataList.Count ~= 1)
    if self.pageDataList.Count == 1 then
      setactive(self.ui.mProgressBarLayout, false)
    end
    setactive(self.ui.mBtn_FinishBtn.gameObject, self.mShowConfirm)
  else
    self:Close()
  end
end
function UISysGuideWindow:UpdatePage(index, data)
  for i = 1, #self.mTags do
    if i == index + 1 then
      self.mTags[i]:SetOn(true)
    else
      self.mTags[i]:SetOn(false)
    end
  end
  self.ui.mImage_GuideImage.sprite = ResSys:GetSpriteByFullPath(data.media)
  self.ui.mText_GuideText.text = data.text.str
end
function UISysGuideWindow:OnBtnPreviousPage()
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
function UISysGuideWindow:OnBtnNextPage()
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
function UISysGuideWindow:OnSetTutorialInfoCallback(msg)
  self.OnPageCloseCallback = msg.Content
end
function UISysGuideWindow:OnClose()
  for i, tag in ipairs(self.mTags) do
    gfdestroy(tag:GetRoot())
  end
end
