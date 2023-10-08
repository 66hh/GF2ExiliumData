require("UI.UIBaseCtrl")
UIBattleIndexTabStoryItem = class("UIBattleIndexTabStoryItem", UIBaseCtrl)
UIBattleIndexTabStoryItem.__index = UIBattleIndexTabStoryItem
UIBattleIndexTabStoryItem.mText_BattleIndexTabStoryItem = nil
UIBattleIndexTabStoryItem.mText_1 = nil
UIBattleIndexTabStoryItem.mText_2 = nil
UIBattleIndexTabStoryItem.mText_Title = nil
UIBattleIndexTabStoryItem.mTrans_RedPoint = nil
function UIBattleIndexTabStoryItem:__InitCtrl()
end
function UIBattleIndexTabStoryItem:InitCtrl(parent)
  local instObj = instantiate(UIUtils.GetGizmosPrefab("BattleIndex/Btn_BattleIndexTabStoryItem.prefab", self))
  CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:__InitCtrl()
  self.ui.mAnimator_State.keepAnimatorControllerStateOnDisable = true
  function self.showUnlock()
    if NetCmdDungeonData.NewChapterID == self.mData.Id then
      self.isUnLock = true
      self.ui.mAnimator_State:SetBool("Bool", not self.isUnLock)
      self.isNext = self.isUnLock and NetCmdDungeonData:UpdateChapterRedPoint(self.mData.id) > 0
      setactive(self.ui.mTrans_NowProgress, self.isNext)
      MessageSys:SendMessage(UIEvent.UINewChapterItemFinish, nil)
      NetCmdDungeonData.NewChapterID = -1
    end
  end
  MessageSys:AddListener(UIEvent.UINewChapterShowFinish, self.showUnlock)
end
function UIBattleIndexTabStoryItem:SetData(data)
  if data ~= nil then
    setactive(self.mUIRoot, true)
    self.mData = data
    self.isUnLock = true
    for i = 0, data.unlock.Count - 1 do
      if not NetCmdAchieveData:CheckComplete(data.unlock[i]) then
        self.isUnLock = false
      end
    end
    if NetCmdDungeonData.NewChapterID == self.mData.Id then
      self.isUnLock = false
      self.isNext = self.isUnLock and 0 < NetCmdDungeonData:UpdateChapterRedPoint(data.id)
      setactive(self.ui.mTrans_NowProgress, self.isNext)
    end
    local story = TableData.GetFirstStoryByChapterID(data.id)
    self.isNew = not AccountNetCmdHandler:IsWatchedChapter(story.stage_id * 100 + 10)
    self.isNext = self.isUnLock and 0 < NetCmdDungeonData:UpdateChapterRedPoint(data.id)
    self:UpdateChapterItem()
  else
    setactive(self.mUIRoot, false)
  end
end
function UIBattleIndexTabStoryItem:SetNowProcess(isShow)
  setactive(self.ui.mTrans_NowProgress, isShow)
end
function UIBattleIndexTabStoryItem:GetUnlock()
  return self.isUnLock
end
function UIBattleIndexTabStoryItem:UpdateChapterItem()
  local chapterNum = self.mData.id > 100 and self.mData.id - 100 or self.mData.id
  self.ui.mText_1.text = string.format("-", chapterNum)
  self.ui.mText_2.text = string.format("-", chapterNum)
  self.ui.mText_Text.text = self.mData.name.str
  self.ui.mAnimator_State:SetBool("Bool", not self.isUnLock)
  setactive(self.ui.mTrans_NowProgress, self.isNext)
  setactive(self.ui.mTrans_RedPoint, self.isUnLock and NetCmdDungeonData:UpdateChatperRewardRedPoint(self.mData.id) + NetCmdDungeonData:UpdateChatperNewUnlockRedPoint(self.mData.id) > 0)
end
function UIBattleIndexTabStoryItem:SetIndexText(index)
  self.ui.mText_Index.text = string.format(string_format(TableData.GetHintById(615), "-"), index)
  self.ui.mText_noSel.text = string.format(string_format(TableData.GetHintById(615), "-"), index)
end
function UIBattleIndexTabStoryItem:RemoveListener()
  MessageSys:RemoveListener(UIEvent.UINewChapterShowFinish, self.showUnlock)
end
function UIBattleIndexTabStoryItem:SetGlobalTabId(globalTabId)
  self.globalTab = GetOrAddComponent(self:GetRoot().gameObject, (typeof(GlobalTab)))
  self.globalTab:SetGlobalTabId(globalTabId)
end
function UIBattleIndexTabStoryItem:GetGlobalTab()
  return self.globalTab
end
