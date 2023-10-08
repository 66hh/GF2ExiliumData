UIBattleIndexHardSubPanel = class("UIBattleIndexHardSubPanel", UIBaseView)
UIBattleIndexHardSubPanel.__index = UIBattleIndexHardSubPanel
UIBattleIndexHardSubPanel.curIndex = -1
UIBattleIndexHardSubPanel.tabList = {}
function UIBattleIndexHardSubPanel:__InitCtrl()
end
function UIBattleIndexHardSubPanel:InitCtrl(root, parent)
  self.ui = {}
  self:SetRoot(root)
  self:LuaUIBindTable(root, self.ui)
  self:__InitCtrl()
  self.mParent = parent
  self.chapterList = TableData.GetHardChapterList()
  self:InitTabs()
  if UIBattleIndexHardSubPanel.curIndex > 0 then
    for i = 0, self.chapterList.Count - 1 do
      if UIBattleIndexHardSubPanel.curIndex == self.chapterList[i].id then
        self:OnClickTab(self.chapterList[i], true)
      end
    end
  else
    self:OnClickTab(self.chapterList[0], true)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Ok.gameObject).onClick = function()
    self:EnterHard()
  end
end
function UIBattleIndexHardSubPanel:InitTabs()
  for i = 0, self.chapterList.Count - 1 do
    do
      local data = self.chapterList[i]
      local item
      if self.tabList[data.id] == nil then
        item = UIBattleIndexTabHardItem.New()
        item:InitCtrl(self.ui.mTrans_Content)
        self.tabList[data.id] = item
      else
        item = self.tabList[data.id]
      end
      item:SetData(data)
      UIUtils.GetButtonListener(item.ui.mBtn_Root.gameObject).onClick = function()
        self:OnClickTab(data)
      end
    end
  end
end
function UIBattleIndexHardSubPanel:RefreshTabs()
  for i = 0, self.chapterList.Count - 1 do
    local data = self.chapterList[i]
    if self.tabList[data.id] ~= nil then
      self.tabList[data.id]:SetData(data)
    end
  end
end
function UIBattleIndexHardSubPanel:OnClickTab(data, fromInit)
  local id = data.id
  if self.tabList[id].isUnLock == false then
    if not fromInit then
      CS.PopupMessageManager.PopupString(data.unlock_hint)
    end
    return
  elseif self.tabList[id].levelUnlocked == false then
    if not fromInit then
      local preData = TableData.listChapterDatas:GetDataById(self.tabList[id].mData.pre_chapter)
      local hint = string_format(TableData.GetHintById(103031), preData.level)
      CS.PopupMessageManager.PopupString(hint)
    end
    return
  end
  UIBattleIndexHardSubPanel.curIndex = id
  for i, tab in pairs(self.tabList) do
    if i == id then
      self.curItem = tab
    end
    tab.ui.mBtn_Root.interactable = i ~= id
  end
  self:CalculatePercent()
  if self.mParent ~= nil then
    self.mParent:RefreshHardBg(self.curItem.mData)
  end
end
function UIBattleIndexHardSubPanel:EnterHard()
  local item = self.curItem
  if item.mData.id and item.isUnLock then
    local chapterId = item.mData.id
    UIBattleIndexHardSubPanel.curChapterId = item.mData.id
    if item.isNew then
      AccountNetCmdHandler:UpdateWatchedChapter(item.mData.id)
      item.isNew = false
    end
    UIManager.OpenUIByParam(UIDef.UIChapterHardPanel, chapterId)
  end
end
function UIBattleIndexHardSubPanel:CalculatePercent()
  local chapter = NetCmdDungeonData:GetCurrentChapterByType(3)
  local stories = TableData.GetUnlockStorysByChapterID(chapter)
  local data = TableData.GetStorysByChapterID(self.curItem.mData.id, false)
  local total = data.Count * 3
  local stars = NetCmdDungeonData:GetCurStarsByChapterID(self.curItem.mData.id) + NetCmdDungeonData:GetFinishChapterStoryCountByChapterID(self.curItem.mData.id) * 3
  self.ui.mText_Num.text = stories[stories.Count - 1].name.str
  self.ui.mText_Percentage.text = tostring(math.ceil(stars / total * 100)) .. "%"
end
function UIBattleIndexHardSubPanel:OnRelease()
  for _, obj in pairs(UIBattleIndexHardSubPanel.tabList) do
    gfdestroy(obj:GetRoot())
  end
  UIBattleIndexHardSubPanel.tabList = {}
end
function UIBattleIndexHardSubPanel.OnClose()
  UIBattleIndexHardSubPanel.curIndex = -1
end
