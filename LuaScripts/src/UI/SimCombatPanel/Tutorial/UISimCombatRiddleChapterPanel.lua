require("UI.UIBasePanel")
require("UI.SimCombatPanel.Tutorial.UISimCombatRiddleChapterPanelView")
require("UI.SimCombatPanel.Tutorial.Item.UISimCombatRiddleChapterItem")
require("UI.BattleIndexPanel.UIBattleDetailDialog")
UISimCombatRiddleChapterPanel = class("UISimCombatRiddleChapterPanel", UIBasePanel)
UISimCombatRiddleChapterPanel.__index = UISimCombatRiddleChapterPanel
UISimCombatRiddleChapterPanel.mView = nil
UISimCombatRiddleChapterPanel.levelItemList = {}
UISimCombatRiddleChapterPanel.mLastSelectItem = nil
function UISimCombatRiddleChapterPanel:ctor()
  UISimCombatRiddleChapterPanel.super.ctor(self)
end
function UISimCombatRiddleChapterPanel.Open()
end
function UISimCombatRiddleChapterPanel.Close()
  UIManager.CloseUI(UIDef.UISimCombatRiddleChapterPanel)
end
function UISimCombatRiddleChapterPanel.Hide()
end
function UISimCombatRiddleChapterPanel:OnInit(root, data)
  UISimCombatRiddleChapterPanel.super.SetRoot(UISimCombatRiddleChapterPanel, root)
  UISimCombatRiddleChapterPanel.mData = data
  UISimCombatRiddleChapterPanel.mView = UISimCombatRiddleChapterPanelView
  self.ui = {}
  UISimCombatRiddleChapterPanel.mView:InitCtrl(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function(gObj)
    UISimCombatRiddleChapterPanel.Close()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  self.panelWidth = UISystem.UICanvas.transform.sizeDelta.x
  self.ui.mText_Title.text = data.StcData.chapter_name.str
  self.ui.mText_ChapterNum.text = string.format("-", data.StcData.id % 10)
  self.rewardItem = UICommonItem.New()
  self.rewardItem:InitCtrl(self.ui.mTrans_IconItem)
  for itemId, num in pairs(data.StcData.chapter_reward) do
    self.rewardItem:SetItemData(itemId, num)
  end
  UIUtils.GetButtonListener(self.rewardItem.ui.mBtn_Select.gameObject).onClick = function()
    self:OnReceiveItem(self.rewardItem)
  end
  self.ui.mImg_Icon.sprite = IconUtils.GetAtlasV2("SimCombatTeaching", data.StcData.chapter_icon)
  self.data = data
  local levelDataList = data.LevelDataList
  for i = 0, levelDataList.Count - 1 do
    local item
    if self.levelItemList[i + 1] == nil then
      item = UISimCombatRiddleChapterItem.New()
      item:InitCtrl(self.ui.mTrans_Content)
      table.insert(self.levelItemList, item)
      UIUtils.GetButtonListener(item.ui.mBtn_Self.gameObject).onClick = function(gObj)
        self:OnClickLevel(item)
      end
    else
      item = self.levelItemList[i + 1]
    end
  end
  function self.OnItemShow(index)
    self.levelItemList[index + 1]:SetData(levelDataList[index])
  end
  self.ui.mFade_Content:onShow("+", self.OnItemShow)
end
function UISimCombatRiddleChapterPanel:OnReceiveItem(item)
  self.skipFade = true
  if not self.data.IsCompleted or self.data.IsReceived then
    UITipsPanel.Open(TableData.GetItemData(item.itemId), item.itemNum)
    return
  end
  for itemId, num in pairs(self.data.StcData.chapter_reward) do
    if TipsManager.CheckItemIsOverflowAndStop(itemId, num) then
      return
    end
  end
  NetCmdSimulateBattleData:ReqSimCombatTutorialTakeChapterReward(self.data.StcData.id, function()
    self:TakeQuestRewardCallBack()
  end)
end
function UISimCombatRiddleChapterPanel:TakeQuestRewardCallBack()
  UIManager.OpenUIByParam(UIDef.UICommonReceivePanel)
  MessageSys:SendMessage(CS.GF2.Message.UIEvent.RefreshChapterInfo, nil)
end
function UISimCombatRiddleChapterPanel:OnShowStart()
  if self.skipFade == true then
    self.skipFade = nil
  else
    self.ui.mFade_Content:InitFade()
  end
  if self.data.IsReceived then
    self.ui.mText_ItemState.text = TableData.GetHintById(103085)
  else
    if self.data.IsCompleted then
    end
    self.ui.mText_ItemState.text = TableData.GetHintById(103076)
  end
  self.ui.mText_Progress.text = TableData.GetHintReplaceById(103094, self.data.Progress .. "%")
  self.rewardItem:SetRedPoint(self.data.IsCompleted and not self.data.IsReceived)
end
function UISimCombatRiddleChapterPanel:OnClickLevel(item)
  local record = NetCmdStageRecordData:GetStageRecordById(item.mData.StageData.id)
  UIBattleDetailDialog.OpenBySimTeachingData(UIDef.UISimCombatRiddleChapterPanel, item.mData, record, true, function()
    self.skipFade = true
    self:ResetScroll()
    if self.mLastSelectItem ~= nil then
      self.mLastSelectItem:SetSelected(false)
    end
  end)
  self:ScrollMoveToMid(item.mUIRoot.transform.anchoredPosition.x, true)
  if self.mLastSelectItem ~= nil then
    self.mLastSelectItem:SetSelected(false)
  end
  item:SetSelected(true)
  self.mLastSelectItem = item
end
function UISimCombatRiddleChapterPanel:ScrollMoveToMid(toPosX, needSlide)
  local toX = (self.panelWidth - 420) / 2 - toPosX
  local toPos = Vector3(toX, self.ui.mTrans_List.localPosition.y, 0)
  if needSlide then
    CS.UITweenManager.PlayLocalPositionTween(self.ui.mTrans_List, self.ui.mTrans_List.localPosition, toPos, 0.3)
  else
    self.ui.mTrans_List.localPosition = toPos
  end
end
function UISimCombatRiddleChapterPanel:ResetScroll()
  local toPos = Vector3(0, self.ui.mTrans_List.anchoredPosition.y, 0)
  CS.UITweenManager.PlayLocalPositionTween(self.ui.mTrans_List.transform, self.ui.mTrans_List.transform.localPosition, toPos, 0.3)
end
function UISimCombatRiddleChapterPanel:OnClose()
  self.mLastSelectItem = nil
  self.ui.mFade_Content:onShow("-", self.OnItemShow)
  for i = 1, #self.levelItemList do
    gfdestroy(self.levelItemList[i]:GetRoot())
  end
  gfdestroy(self.rewardItem:GetRoot())
  self.levelItemList = {}
end
function UISimCombatRiddleChapterPanel:OnRelease()
  self.levelItemList = {}
end
function UISimCombatRiddleChapterPanel:OnSave()
  self.levelItemList = {}
end
function UISimCombatRiddleChapterPanel:OnTop()
  self:OnShowStart()
end
function UISimCombatRiddleChapterPanel:OnBackFrom()
  self:OnShowStart()
end
function UISimCombatRiddleChapterPanel:OnRecover()
  self:OnShowStart()
end
function UISimCombatRiddleChapterPanel:UpdateRewardRedPoint()
  setactive(self.ui.mObj_RedPoint, NetCmdSimulateBattleData:CheckTeachingRewardRedPoint())
end
