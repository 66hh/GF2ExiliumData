require("UI.SimCombatPanelV2.SimCombatMythicConfig")
require("UI.SimCombatPanel.Item.Rogue.SimCombatMythicChapterNumText")
require("UI.SimCombatPanel.MythicCombat.Rogue.UISimCombatMythicMainPanel")
require("UI.UIBasePanel")
require("UI.SimCombatPanelV2.Items.SimCombatMythicStageGroupItemV2")
UISimCombatMythicMainPanelV2 = class("UISimCombatMythicMainPanelV2", UIBasePanel)
UISimCombatMythicMainPanelV2.__index = UISimCombatMythicMainPanelV2
local self = UISimCombatMythicMainPanelV2
function UISimCombatMythicMainPanelV2:ctor(obj)
  UISimCombatMythicMainPanelV2.super.ctor(self)
end
function UISimCombatMythicMainPanelV2:OnInit(root, param)
  self.super.SetRoot(UISimCombatMythicMainPanelV2, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.updateFromOnTop = false
  self.stageGroupItemList = {}
  self.chapterTextItemList = {}
  self.chapterItemDataList = {}
  self.curChapterItem = nil
  if CS.GameRoot.Instance.AdapterPlatform == CS.PlatformSetting.PlatformType.PC then
    SimCombatMythicConfig.ChapterItemSpace = -47
  else
    SimCombatMythicConfig.ChapterItemSpace = -110
  end
  SimCombatMythicConfig.IsReadyToStartTutorial = not isShowWeeklyStart
  for i = 1, TableData.listSimCombatMythicGroupDatas.Count do
    table.insert(self.chapterItemDataList, TableData.listSimCombatMythicGroupDatas:GetDataById(i))
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBack.gameObject).onClick = function()
    self:CloseMainPanel()
    SimCombatMythicConfig.CurSelectedStageGroupIndex = 0
    UIManager.CloseUI(UIDef.UISimCombatMythicMainPanelV2)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnHome.gameObject).onClick = function()
    self:CloseMainPanel()
    SimCombatMythicConfig.CurSelectedStageGroupIndex = 0
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnLeft.gameObject).onClick = function()
    if self.curChapterItem.itemIndex ~= 1 then
      self:OnClickChapterItem(self.stageGroupItemList[self.curChapterItem.itemIndex - 1])
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnRight.gameObject).onClick = function()
    if self.curChapterItem.itemIndex ~= #self.stageGroupItemList then
      self:OnClickChapterItem(self.stageGroupItemList[self.curChapterItem.itemIndex + 1])
    end
  end
  function self.refreshInfoFunc()
    self:RefreshInfo()
  end
  self:InitTopTitle()
  self:AddListener()
  self.isRecover = false
end
function UISimCombatMythicMainPanelV2:InitTopTitle()
  local config = TableData.listSimCombatEntranceDatas:GetDataById(25)
  self.ui.mText_Title.text = config.name.str
end
function UISimCombatMythicMainPanelV2:OnShowFinish()
  if self.updateFromOnTop then
    self.updateFromOnTop = false
    return
  end
  if not self.isRecover then
    self:CheckShowUnLockDialog()
  end
  self.isRecover = false
  TimerSys:DelayFrameCall(1, function()
    self:ResetContentPandding()
  end)
  self:InitChapterList()
end
function UISimCombatMythicMainPanelV2:RefreshInfo()
  self:InitChapterList()
end
function UISimCombatMythicMainPanelV2:CheckShowUnLockDialog()
  local unlockState = NetCmdSimCombatMythicData:GetStageGroupUnLockType()
  if unlockState == 3 then
    local message = NetCmdSimCombatMythicData:GetUnLockMessage()
    UIManager.OpenUIByParam(UIDef.UISimCombatMythicUnlockDialog, message)
    NetCmdSimCombatMythicData:ClearGroupStageLevelUnLockType()
  end
end
function UISimCombatMythicMainPanelV2:OnTop()
  self.updateFromOnTop = true
end
function UISimCombatMythicMainPanelV2:OnRecover()
  self.isRecover = true
end
function UISimCombatMythicMainPanelV2:InitChapterList()
  self.ui.mVirtualListEx_ChapterList:RemoveOnEndDrag(self.OnEndDrag)
  self.ui.mVirtualListEx_ChapterList:AddOnEndDrag(self.OnEndDrag)
  for i, v in ipairs(self.chapterItemDataList) do
    local item
    if self.stageGroupItemList[i] == nil then
      item = SimCombatMythicStageGroupItemV2.New()
      item:InitCtrl(self.ui.mTrans_Content)
      table.insert(self.stageGroupItemList, item)
    else
      item = self.stageGroupItemList[i]
    end
    item:SetData(v)
    UIUtils.GetButtonListener(item.ui.mBtn_Item_Normal.gameObject).onClick = function()
      self:OnClickChapterItem(item)
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
  self:SetDefaultSelectGroup()
end
function UISimCombatMythicMainPanelV2:SetDefaultSelectGroup()
  TimerSys:DelayFrameCall(2, function()
    local autoSlcGroupIndex = NetCmdSimCombatMythicData:GetAutoSelectedGroupIndex()
    local defaultItem = self.stageGroupItemList[autoSlcGroupIndex]
    self:OnClickChapterItem(defaultItem)
  end)
end
function UISimCombatMythicMainPanelV2:OnClickChapterItem(item)
  if item == nil then
    return
  end
  if self.curChapterItem ~= nil then
    self.curChapterItem:SetSelected(false)
  end
  item:SetSelected(true)
  self.curChapterItem = item
  SimCombatMythicConfig.CurSelectedStageGroupIndex = item.itemIndex
  self:ScrollToPosByIndex(item.itemIndex, function()
    setactive(self.ui.mBtn_BtnLeft.gameObject, self.curChapterItem.itemIndex ~= 1)
    setactive(self.ui.mBtn_BtnRight.gameObject, self.curChapterItem.itemIndex ~= #self.chapterItemDataList)
  end)
end
function UISimCombatMythicMainPanelV2:ScrollToPosByIndex(index, callback)
  self.ui.mVirtualListEx_ChapterList:StopMovement()
  local itemCount = #self.stageGroupItemList
  local realIndex = itemCount - index + 1
  local centerX = LuaUtils.GetRectTransformSize(self.ui.mTrans_VirtualListEx.gameObject).x / 2
  local targetX = (realIndex - 1 + 0.5) * SimCombatMythicConfig.ChapterItemWidth - centerX + (realIndex - 1) * SimCombatMythicConfig.ChapterItemSpace + SimCombatMythicConfig.ChapterItemPadding
  local sizeDeltaX = LuaUtils.GetRectTransformDeltaSize(self.ui.mTrans_Content.gameObject).x
  if targetX < 0 then
    targetX = 0
  elseif sizeDeltaX < targetX then
    targetX = sizeDeltaX
  end
  CS.UITweenManager.PlayAnchoredPositionXTween(self.ui.mTrans_Content, targetX, SimCombatMythicConfig.ChapterItemMoveDuration, callback)
  local targetX2 = -self.ui.mTrans_NumContent.rect.x - (index - 2) * SimCombatMythicConfig.ChapterNumWidth
  CS.UITweenManager.PlayAnchoredPositionXTween(self.ui.mTrans_NumContent, targetX2, SimCombatMythicConfig.ChapterItemMoveDuration, callback)
end
function UISimCombatMythicMainPanelV2.OnEndDrag(eventData)
  local centerX = LuaUtils.GetRectTransformSize(self.ui.mTrans_VirtualListEx.gameObject).x / 2
  local endX = self.ui.mTrans_Content.anchoredPosition.x + centerX - SimCombatMythicConfig.ChapterItemPadding
  local itemCount = #self.stageGroupItemList
  local index = 1
  local minDis = 9999999
  for i = 1, itemCount do
    local itemPosx = SimCombatMythicConfig.ChapterItemWidth * (i - 1 + 0.5) + (i - 1) * SimCombatMythicConfig.ChapterItemSpace
    local offset = math.abs(endX - itemPosx)
    if minDis > offset then
      index = i
      minDis = offset
    end
  end
  index = #self.stageGroupItemList - index + 1
  self:OnClickChapterItem(self.stageGroupItemList[index])
end
function UISimCombatMythicMainPanelV2.SetCurItemCenterPos()
  local layoutGroup = self.ui.mGridLayoutGroup_Content
  local tmpRect = CS.LuaUIUtils.GetRectTransform(self.ui.mGridLayoutGroup_Content.transform)
  local tmpPadding = layoutGroup.padding
  tmpPadding.right = tmpPadding.right + SimCombatMythicConfig.BattleDetailWidth / 2
  layoutGroup.padding = tmpPadding
  CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(tmpRect)
  local targetX = -self.ui.mTrans_Content.rect.x - (self.curChapterItem.itemIndex - 1) * SimCombatMythicConfig.ChapterItemWidth
  targetX = targetX - SimCombatMythicConfig.BattleDetailWidth / 2
  CS.UITweenManager.PlayAnchoredPositionXTween(self.ui.mTrans_Content, targetX, SimCombatMythicConfig.ChapterItemMoveDuration)
end
function UISimCombatMythicMainPanelV2:ResetContentPandding()
  local layoutGroup = self.ui.mGridLayoutGroup_Content
  local rectSize = LuaUtils.GetRectTransformSize(self.ui.mTrans_VirtualListEx.gameObject)
  local width = (rectSize.x - SimCombatMythicConfig.ChapterItemWidth) / 2
  local rightPadding = math.ceil(width)
  layoutGroup.padding = RectOffset(rightPadding, rightPadding, 0, 0)
  layoutGroup.spacing = Vector2(SimCombatMythicConfig.ChapterItemSpace, 0)
  SimCombatMythicConfig.ChapterItemPadding = rightPadding
end
function UISimCombatMythicMainPanelV2:OnHide()
  self.curChapterItem = nil
  self.ui.mAnimator_Root:SetTrigger("FadeOut")
  self.ui.mVirtualListEx_ChapterList:RemoveOnEndDrag(self.OnEndDrag)
  self.isHide = true
  self.updateFromOnTop = false
end
function UISimCombatMythicMainPanelV2:OnClose()
  self:ReleaseCtrlTable(self.stageGroupItemList)
  self:ReleaseCtrlTable(self.chapterTextItemList)
  self:RemoveListener()
  self.updateFromOnTop = false
end
function UISimCombatMythicMainPanelV2:CloseMainPanel()
end
function UISimCombatMythicMainPanelV2:AddListener()
end
function UISimCombatMythicMainPanelV2:RemoveListener()
end
