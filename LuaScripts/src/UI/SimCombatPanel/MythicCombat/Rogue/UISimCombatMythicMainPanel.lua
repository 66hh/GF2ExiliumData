require("UI.SimCombatPanel.Item.Rogue.SimCombatMythicChapterItem")
require("UI.UIBasePanel")
UISimCombatMythicMainPanel = class("UISimCombatMythicMainPanel", UIBasePanel)
UISimCombatMythicMainPanel.__index = UISimCombatMythicMainPanel
local self = UISimCombatMythicMainPanel
function UISimCombatMythicMainPanel:ctor(obj)
  UISimCombatMythicMainPanel.super.ctor(self)
end
function UISimCombatMythicMainPanel:OnInit(root)
  self.super.SetRoot(UISimCombatMythicMainPanel, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.chapterItemList = {}
  self.chapterTextItemList = {}
  self.chapterItemDataList = {}
  self.curChapterItem = nil
  for i = 1, TableData.listRogueLevelCofigDatas.Count do
    table.insert(self.chapterItemDataList, TableData.listRogueLevelCofigDatas:GetDataById(i))
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBack.gameObject).onClick = function()
    self:CloseMainPanel()
    UIManager.CloseUI(UIDef.UISimCombatMythicMainPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnHome.gameObject).onClick = function()
    self:CloseMainPanel()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_TargetContent.gameObject).onClick = function()
    UIManager.OpenUI(UIDef.UISimCombatMythicTargetDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnLeft.gameObject).onClick = function()
    if self.curChapterItem.ItemIndex ~= 1 then
      self:OnClickChapterItem(self.chapterItemList[self.curChapterItem.ItemIndex - 1])
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnRight.gameObject).onClick = function()
    if self.curChapterItem.ItemIndex ~= #self.chapterItemList then
      self:OnClickChapterItem(self.chapterItemList[self.curChapterItem.ItemIndex + 1])
    end
  end
  self:AddListener()
end
function UISimCombatMythicMainPanel:OnShowFinish()
  TimerSys:DelayFrameCall(1, function()
    self:ResetContentPandding()
  end)
  self:InitChapterList()
  if NetCmdSimCombatRogueData.FinishRogueTier ~= 0 then
    CS.GF2.Message.MessageSys.Instance:SendMessage(CS.GF2.Message.RogueEvent.SetReleaseCallback, function()
      UIManager.OpenUI(UIDef.UISimCombatMythicSettlementDialog)
    end)
  end
  NetCmdSimCombatRogueData:InitRogueTarget()
  NetCmdSimCombatRogueData:GetSimRogueStageRecord(function(ret)
    if ret == ErrorCodeSuc then
      NetCmdSimCombatRogueData:GetRogueEnemies()
    end
  end)
  setactive(self.ui.mTrans_RedPoint.gameObject, UISimCombatRogueGlobal.HasCanReceiveTarget())
  CS.GF2.Message.MessageSys.Instance:SendMessage(CS.GF2.Message.RogueEvent.SetTargetBtnShow, true)
end
function UISimCombatMythicMainPanel:InitChapterList()
  self.ui.mVirtualListEx_ChapterList:AddOnEndDrag(self.OnEndDrag)
  local curTier = NetCmdSimCombatRogueData.RogueStage.Tier
  for i, v in ipairs(self.chapterItemDataList) do
    local item
    if self.chapterItemList[i] == nil then
      item = SimCombatMythicChapterItem.New()
      item:InitCtrl(self.ui.mTrans_Content)
      table.insert(self.chapterItemList, item)
    else
      item = self.chapterItemList[i]
    end
    item:SetData(v)
    UIUtils.GetButtonListener(item.ui.mBtn_ChapterInfo_S.gameObject).onClick = function()
      self:OnClickChapterItem(item)
    end
    if i == curTier and self.curChapterItem == nil then
      self.curChapterItem = item
    end
    local textItem
    if self.chapterTextItemList[i] == nil then
      textItem = SimCombatMythicChapterNumText.New()
      textItem:InitCtrl(self.ui.mTrans_NumContent)
      table.insert(self.chapterTextItemList, textItem)
    else
      textItem = self.chapterTextItemList[i]
    end
    textItem:SetData(i)
  end
  if UISimCombatRogueGlobal.CurItemTier ~= 0 then
    self.curChapterItem = self.chapterItemList[UISimCombatRogueGlobal.CurItemTier]
    UISimCombatRogueGlobal.CurItem = self.curChapterItem
  elseif self.curChapterItem == nil then
    self.curChapterItem = self.chapterItemList[1]
  end
  self:OnClickChapterItem(self.curChapterItem)
end
function UISimCombatMythicMainPanel:OnClickChapterItem(item)
  if item == nil then
    return
  end
  UISimCombatRogueGlobal.CurItemTier = item.ItemIndex
  UISimCombatRogueGlobal.CurItem = item
  if self.curChapterItem ~= nil then
    self.curChapterItem:SetSelected(false)
  end
  item:SetSelected(true)
  self.curChapterItem = item
  self:ChangeModeAnimator(item.chapterItemRogueMode)
  self:ScrollToPosByIndex(item.ItemIndex, function()
    self:SetMaxProgress(item)
    setactive(self.ui.mTrans_ImgNormalBg, item.chapterItemRogueMode == UISimCombatRogueGlobal.RogueMode.Normal)
    setactive(self.ui.mTrans_ImgChallengeBg, item.chapterItemRogueMode == UISimCombatRogueGlobal.RogueMode.Challenge)
    setactive(self.ui.mBtn_BtnLeft.gameObject, self.curChapterItem.ItemIndex ~= 1)
    setactive(self.ui.mBtn_BtnRight.gameObject, self.curChapterItem.ItemIndex ~= #self.chapterItemDataList)
  end)
end
function UISimCombatMythicMainPanel:ScrollToPosByIndex(index, callback)
  self.ui.mVirtualListEx_ChapterList:StopMovement()
  local targetX = -self.ui.mTrans_Content.rect.x - (index - 1) * UISimCombatRogueGlobal.ChapterItemWidth
  CS.UITweenManager.PlayAnchoredPositionXTween(self.ui.mTrans_Content, targetX, UISimCombatRogueGlobal.ChapterItemMoveDuration, callback)
  local targetX2 = -self.ui.mTrans_NumContent.rect.x - (index - 3) * UISimCombatRogueGlobal.ChapterNumWidth
  CS.UITweenManager.PlayAnchoredPositionXTween(self.ui.mTrans_NumContent, targetX2, UISimCombatRogueGlobal.ChapterItemMoveDuration, callback)
end
function UISimCombatMythicMainPanel.OnEndDrag(eventData)
  local endX = self.ui.mTrans_Content.anchoredPosition.x
  local endIndex = math.ceil(-endX / UISimCombatRogueGlobal.ChapterItemWidth - 0.5) + 1
  if endIndex > #self.chapterItemList then
    endIndex = #self.chapterItemList
  end
  if endIndex <= 0 then
    endIndex = 1
  end
  self:OnClickChapterItem(self.chapterItemList[endIndex])
end
function UISimCombatMythicMainPanel:SetMaxProgress(item)
  local progressNum = item.maxPhase
  if progressNum == nil then
    setactive(self.ui.mTrans_MaxProgress.gameObject, false)
    return
  end
  setactive(self.ui.mTrans_MaxProgress.gameObject, false)
  if progressNum == 100 then
    self.ui.mText_MaxProgress.text = TableData.GetHintById(111059)
  else
    local tmpStr = "{0} <color=#F26C1C>{1}%</color>"
    local rogueChapterCofigData = NetCmdSimCombatRogueData:GetRogueChapterCofig(item.chapterItemRogueMode, item.ItemIndex, item.maxProgressNum + 1)
    tmpStr = string_format(tmpStr, rogueChapterCofigData.Name, tostring(progressNum))
    self.ui.mText_MaxProgress.text = tmpStr
  end
end
function UISimCombatMythicMainPanel:ChangeModeAnimator(rogueMode)
  if rogueMode == UISimCombatRogueGlobal.RogueMode.Normal then
    self.ui.mAnimator_ChangeMode:SetInteger("DifficultySwitch", 0)
  else
    self.ui.mAnimator_ChangeMode:SetInteger("DifficultySwitch", 1)
  end
  local isNormal = self.curChapterItem.chapterItemRogueMode == UISimCombatRogueGlobal.RogueMode.Normal
  for _, v in ipairs(self.chapterItemList) do
    v:SetTextColor(isNormal)
  end
end
function UISimCombatMythicMainPanel.SetTargetBtnShow(message)
  local boolean = message.Sender
  setactive(self.ui.mBtn_TargetContent.gameObject, boolean)
  if boolean then
    self.ui.mAnimator_Root:SetTrigger("Bottom_FadeIn")
  else
    self.ui.mAnimator_Root:SetTrigger("Bottom_FadeOut")
  end
  self:HideOtherRogueChapterItem(boolean)
  if not boolean then
    self.SetCurItemCenterPos()
  end
end
function UISimCombatMythicMainPanel:HideOtherRogueChapterItem(boolean)
end
function UISimCombatMythicMainPanel.SetCurItemCenterPos()
  local layoutGroup = self.ui.mGridLayoutGroup_Content
  local tmpRect = CS.LuaUIUtils.GetRectTransform(self.ui.mGridLayoutGroup_Content.transform)
  local tmpPadding = layoutGroup.padding
  tmpPadding.right = tmpPadding.right + UISimCombatRogueGlobal.BattleDetailWidth / 2
  layoutGroup.padding = tmpPadding
  CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(tmpRect)
  local targetX = -self.ui.mTrans_Content.rect.x - (self.curChapterItem.ItemIndex - 1) * UISimCombatRogueGlobal.ChapterItemWidth
  targetX = targetX - UISimCombatRogueGlobal.BattleDetailWidth / 2
  CS.UITweenManager.PlayAnchoredPositionXTween(self.ui.mTrans_Content, targetX, UISimCombatRogueGlobal.ChapterItemMoveDuration)
end
function UISimCombatMythicMainPanel:ResetContentPandding()
  local layoutGroup = self.ui.mGridLayoutGroup_Content
  local tmpRect = CS.LuaUIUtils.GetRectTransform(self.ui.mVirtualListEx_ChapterList.transform)
  local width = (tmpRect.rect.width - UISimCombatRogueGlobal.ChapterItemWidth) / 2
  local rightPadding = math.ceil(width)
  layoutGroup.padding = RectOffset(rightPadding, rightPadding, 0, 0)
end
function UISimCombatMythicMainPanel:OnHide()
  self.curChapterItem = nil
  self.ui.mAnimator_Root:SetTrigger("FadeOut")
  self.ui.mVirtualListEx_ChapterList:RemoveOnEndDrag(self.OnEndDrag)
  self.isHide = true
end
function UISimCombatMythicMainPanel:OnClose()
  self:ReleaseCtrlTable(self.chapterItemList)
  self:ReleaseCtrlTable(self.chapterTextItemList)
  self:RemoveListener()
end
function UISimCombatMythicMainPanel:CloseMainPanel()
  UISimCombatRogueGlobal.CurItemTier = 0
  UISimCombatRogueGlobal.CurItem = nil
end
function UISimCombatMythicMainPanel:AddListener()
  CS.GF2.Message.MessageSys.Instance:AddListener(CS.GF2.Message.RogueEvent.InitChapterList, function()
    self:InitChapterList()
  end)
  CS.GF2.Message.MessageSys.Instance:AddListener(CS.GF2.Message.RogueEvent.SetCurItemCenterPos, self.SetCurItemCenterPos)
  CS.GF2.Message.MessageSys.Instance:AddListener(CS.GF2.Message.RogueEvent.SetTargetBtnShow, self.SetTargetBtnShow)
end
function UISimCombatMythicMainPanel:RemoveListener()
  CS.GF2.Message.MessageSys.Instance:RemoveListener(CS.GF2.Message.RogueEvent.InitChapterList, function()
    self:InitChapterList()
  end)
  CS.GF2.Message.MessageSys.Instance:RemoveListener(CS.GF2.Message.RogueEvent.SetCurItemCenterPos, self.SetCurItemCenterPos)
  CS.GF2.Message.MessageSys.Instance:RemoveListener(CS.GF2.Message.RogueEvent.SetTargetBtnShow, self.SetTargetBtnShow)
end
