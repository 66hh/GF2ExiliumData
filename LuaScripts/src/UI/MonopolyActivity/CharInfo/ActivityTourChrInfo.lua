require("UI.UIBaseCtrl")
require("UI.MonopolyActivity.CharInfo.Btn_ActivityTourChrInfoListItem")
ActivityTourChrInfo = class("ActivityTourChrInfo", UIBaseCtrl)
ActivityTourChrInfo.__index = ActivityTourChrInfo
function ActivityTourChrInfo:ctor()
  self.super.ctor(self)
end
function ActivityTourChrInfo:InitCtrl(ui)
  self.ui = ui
  self.mUICharItems = {}
  self.mShowChar = false
  self.mIsFadeIn = false
  UIUtils.GetButtonListener(self.ui.mBtn_ChrInfo.gameObject).onClick = function()
    self.mShowChar = not self.mShowChar
    self:ShowChr()
  end
  self:RefreshAll()
end
function ActivityTourChrInfo:RegisterMessage()
end
function ActivityTourChrInfo:UnRegisterMessage()
end
function ActivityTourChrInfo:RefreshAll()
  self:ShowChr()
end
function ActivityTourChrInfo:ShowChr()
  self.ui.mAnimator_Open:SetBool("Lock", self.mShowChar)
  if not self.mShowChar then
    self:FadeInOut(false)
    return
  end
  self:RefreshAllTeamInfo(false)
  self:FadeInOut(true)
end
function ActivityTourChrInfo:RefreshPropChange()
  if self.mShowChar then
    self:RefreshAllTeamInfo(true)
  end
end
function ActivityTourChrInfo:RefreshAllTeamInfo(isAnim)
  local teamInfo = MonopolyWorld.MpData.teamInfo
  for i = 1, teamInfo.Count do
    local gunItem = self.mUICharItems[i]
    if not gunItem then
      gunItem = Btn_ActivityTourChrInfoListItem.New()
      gunItem:InitCtrl(self.ui.mScrollListChild_Chr.childItem, self.ui.mScrollListChild_Chr.transform)
      self.mUICharItems[i] = gunItem
    end
    gunItem:SetData(teamInfo[i - 1], isAnim)
  end
end
function ActivityTourChrInfo:FadeInOut(isFadeIn)
  if self.mIsFadeIn == isFadeIn then
    if isFadeIn == false then
      setactive(self.ui.mScrollListChild_Chr.transform, false)
    end
    return
  end
  self.mIsFadeIn = isFadeIn
  self.ui.mCVG_Char.blocksRaycasts = isFadeIn
  if isFadeIn then
    setactive(self.ui.mScrollListChild_Chr.transform, true)
    self:ResetAllItemAnim()
    self.ui.mACF_Char:DoScrollFade()
    return
  else
    self.ui.mACF_Char:StopScrollFade()
  end
  for i = 1, #self.mUICharItems do
    local item = self.mUICharItems[i]
    if item then
      item:FadeInOut(isFadeIn)
    end
  end
end
function ActivityTourChrInfo:ResetAllItemAnim()
  for i = 1, #self.mUICharItems do
    local item = self.mUICharItems[i]
    if item then
      item:ResetAnim()
    end
  end
end
function ActivityTourChrInfo:Release()
  self:UnRegisterMessage()
  self:ReleaseCtrlTable(self.mUICharItems, true)
  self.mUICharItems = nil
  self:OnRelease(true)
end
