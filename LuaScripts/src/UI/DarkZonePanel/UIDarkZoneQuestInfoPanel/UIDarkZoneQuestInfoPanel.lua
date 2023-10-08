require("UI.DarkZonePanel.UIDarkZoneQuestInfoPanel.Item.UIDarkZoneQuestInfoBtnItem")
require("UI.DarkZonePanel.UIDarkZoneQuestInfoPanel.Item.UIDarkZoneQuestInfoPanelItem")
require("UI.DarkZonePanel.UIDarkZoneQuestInfoPanel.Item.UIDarkZoneQuestInfoRootItem")
require("UI.DarkZonePanel.UIDarkZoneQuestInfoPanel.UIDarkZoneQuestInfoPanelView")
require("UI.UIBasePanel")
UIDarkZoneQuestInfoPanel = class("UIDarkZoneQuestInfoPanel", UIBasePanel)
UIDarkZoneQuestInfoPanel.__index = UIDarkZoneQuestInfoPanel
function UIDarkZoneQuestInfoPanel:ctor(csPanel)
end
UIDarkZoneQuestInfoPanel.EPlayerFirstClick = {
  nextQuestGroupID = "nextQuestGroupID",
  firstOpenQuest = "firstOpenQuest",
  cachePos = "cachePos"
}
function UIDarkZoneQuestInfoPanel:OnInit(root)
  self:SetRoot(root)
  self.mview = UIDarkZoneQuestInfoPanelView.New()
  self.ui = {}
  self.mview:InitCtrl(root, self.ui)
  self.mData = DarkNetCmdStoreData.seriesQuest
  self.allQuestList = {}
  self.questItemList = {}
  self.simpleList = {}
  self.difficultyList = {}
  self.nightmareList = {}
  self.lockList = {}
  self.finishList = {}
  self.questbundleList = {}
  self.uid = PlayerPrefs.GetString("uid")
  self.infoRootItemList = {}
  self.infoBtnItemList = {}
  self:InitData()
  self:AddBtnListener()
end
function UIDarkZoneQuestInfoPanel:InitData()
  if not PlayerPrefs.HasKey(self.uid .. UIDarkZoneQuestInfoPanel.EPlayerFirstClick.nextQuestGroupID) then
    PlayerPrefs.SetInt(self.uid .. UIDarkZoneQuestInfoPanel.EPlayerFirstClick.nextQuestGroupID, 101)
  end
  local showQuestList = {}
  self.hasFinishQuestList = {}
  self.questSeriesGroup = {}
  local currentGroup = self.mData.CurrGroup == 0 and 101 or self.mData.CurrGroup
  local allQuestBundle = TableData.listDarkzoneQuestBundleDatas.Count
  for i = 0, allQuestBundle - 1 do
    local questBundle = TableData.listDarkzoneQuestBundleDatas:GetDataByIndex(i)
    if showQuestList[questBundle.quest_group] == nil then
      showQuestList[questBundle.quest_group] = {}
    end
    local list = showQuestList[questBundle.quest_group]
    table.insert(self.questbundleList, questBundle)
    for m = 0, questBundle.quest_series_id.Count - 1 do
      local seriesID = questBundle.quest_series_id[m]
      local seriesQuestData = TableData.listDarkzoneSeriesQuestDatas:GetDataById(seriesID)
      local v
      if self.mData.Quest:TryGetValue(seriesQuestData.id) == true then
        v = self.mData.Quest[seriesQuestData.id]
      end
      if v and 0 < v then
        for i = 0, seriesQuestData.in_group_id.Count - 1 do
          local num = seriesQuestData.in_group_id[i]
          local data = TableData.listDarkzoneQuestDatas:GetDataById(num)
          table.insert(list, data)
          self.questSeriesGroup[num] = seriesID
          self.hasFinishQuestList[num] = true
          if v == num then
            break
          end
        end
      elseif 0 < seriesQuestData.in_group_id.Count then
        if currentGroup > questBundle.quest_group then
          for i = 0, seriesQuestData.in_group_id.Count - 1 do
            local num = seriesQuestData.in_group_id[i]
            local data = TableData.listDarkzoneQuestDatas:GetDataById(num)
            table.insert(list, data)
            self.questSeriesGroup[num] = seriesID
            self.hasFinishQuestList[num] = true
          end
        else
          local num = seriesQuestData.in_group_id[0]
          local data = TableData.listDarkzoneQuestDatas:GetDataById(num)
          table.insert(list, data)
          self.questSeriesGroup[num] = seriesID
        end
      end
    end
  end
  self.allQuestList = showQuestList
  self:LoadQuest()
  self.ui.mVirtualList_ValueChange.onValueChanged:AddListener(function()
    self:OnValueChange()
  end)
end
function UIDarkZoneQuestInfoPanel:LoadQuest()
  local currentGroup = self.mData.CurrGroup == 0 and 101 or self.mData.CurrGroup
  local playerLevel = AccountNetCmdHandler:GetLevel()
  local isLock, lockType = false
  local lockNum = 0
  local tmpWidth = 0
  for k, v in pairs(self.allQuestList) do
    local quest_complex = k - 100
    for m, n in pairs(v) do
      if self.infoRootItemList[quest_complex] == nil then
        self.infoRootItemList[quest_complex] = UIDarkZoneQuestInfoRootItem.New()
        local rootItem = self.infoRootItemList[quest_complex]
        local obj = instantiate(self.ui.mTrans_Simple.gameObject)
        rootItem:InitCtrl(obj, self.ui.mTrans_InfoRootItemContent)
        local questBundle = TableData.listDarkzoneQuestBundleDatas:GetDataById(k)
        local str = "Img_DarkzoneQuest_Line" .. quest_complex
        rootItem:SetData(questBundle.name.str, str)
        lockType = playerLevel < questBundle.quest_need_lv
        if lockType == true then
          lockNum = questBundle.quest_need_lv
        else
          lockNum = 0
        end
        isLock = lockType
        if isLock then
          rootItem:SetLock()
        end
      end
      local item1 = self.infoRootItemList[quest_complex]
      local item
      item = UIDarkZoneQuestInfoPanelItem.New()
      item:InitCtrl(item1.ui.mTrans_Content, self)
      if tmpWidth == 0 then
        tmpWidth = 284
      end
      item:SetData(n, k, self.questSeriesGroup[n.id])
      if self.questItemList[quest_complex] == nil then
        self.questItemList[quest_complex] = {}
      end
      table.insert(self.questItemList[quest_complex], item)
      if isLock then
        item:SetLock(lockNum)
      end
      if self.hasFinishQuestList[n.id] == true then
        item:OnFinish()
      end
    end
  end
  local hasRed = false
  for i, v in pairs(self.questItemList) do
    self.infoRootItemList[i].mUIRoot:SetSiblingIndex(i - 1)
    setactive(self.infoRootItemList[i].mUIRoot, 0 < #v)
    local item = UIDarkZoneQuestInfoBtnItem.New()
    item:InitCtrl(self.ui.mScrollList_Content.childItem.gameObject, self.ui.mScrollList_Content.transform, self.ui.mTrans_SimpleContent)
    table.insert(self.infoBtnItemList, item)
    local isLockFlag = true
    local isFinishFlag = true
    for j = 1, #self.questItemList[i] do
      if self.questItemList[i][j].isFinish == false then
        isFinishFlag = false
      end
      if self.questItemList[i][j].isLock == false then
        isLockFlag = false
      end
    end
    self.finishList[i] = isFinishFlag
    self.lockList[i] = isLockFlag
  end
  local pos = 0
  local totalPos = 0
  self.posList = {}
  for i = 1, #self.questItemList do
    local oneNum = math.ceil(#self.questItemList[i] / self.ui.mGrp_Layout.constraintCount)
    pos = oneNum * self.ui.mGrp_Layout.cellSize.x + (oneNum - 1) * self.ui.mGrp_Layout.spacing.x + self.ui.mGrpTask_Layout.padding.left + self.ui.mGrpTask_Layout.padding.right
    self.posList[i] = pos
    totalPos = totalPos + pos
  end
  totalPos = totalPos / 2 + self.ui.mGrpContent_Layout.padding.right
  for i = 1, #self.infoBtnItemList do
    if i == 1 then
      pos = totalPos
      self.infoBtnItemList[i]:SetBtnData(pos, i, self.infoBtnItemList, self.posList[i], self.lockList[i], self.ui.mVirtualList_ValueChange)
    else
      pos = pos - self.posList[i - 1]
      self.infoBtnItemList[i]:SetBtnData(pos, i, self.infoBtnItemList, self.posList[i], self.lockList[i], self.ui.mVirtualList_ValueChange)
    end
  end
  self.infoBtnItemList[1].ui.mBtn_Item.interactable = false
  self:OnShowStart()
end
function UIDarkZoneQuestInfoPanel:OnShowFinish()
  for i = 1, #self.infoBtnItemList do
    if self.lockList[i] then
      self.infoBtnItemList[i].ui.mAnimator_QuestList:SetBool("Unlock", false)
      self.infoBtnItemList[i].ui.mAnimator_QuestList:SetLayerWeight(self.infoBtnItemList[i].ui.mAnimator_QuestList:GetLayerIndex("Unlock"), 1)
    else
      self.infoBtnItemList[i].ui.mAnimator_QuestList:SetBool("Unlock", true)
      self.infoBtnItemList[i].ui.mAnimator_QuestList:SetLayerWeight(self.infoBtnItemList[i].ui.mAnimator_QuestList:GetLayerIndex("Unlock"), 0)
    end
  end
  DarkNetCmdTeamData:PreloadTeamAssets()
end
function UIDarkZoneQuestInfoPanel:ReturnCachePos()
  local cachePos = DarkNetCmdStoreData.questCachePos
  if cachePos then
    LuaDOTweenUtils.SetTransformSlide(self.ui.mTrans_SimpleContent, cachePos)
  end
  DarkNetCmdStoreData.questCachePos = nil
end
function UIDarkZoneQuestInfoPanel:OnShowStart()
  for i = 1, #self.infoBtnItemList do
    if self.lockList[i] then
      self.infoBtnItemList[i].ui.mAnimator_QuestList:SetBool("Unlock", false)
      self.infoBtnItemList[i].ui.mAnimator_QuestList:SetLayerWeight(self.infoBtnItemList[i].ui.mAnimator_QuestList:GetLayerIndex("Unlock"), 1)
    else
      self.infoBtnItemList[i].ui.mAnimator_QuestList:SetBool("Unlock", true)
      self.infoBtnItemList[i].ui.mAnimator_QuestList:SetLayerWeight(self.infoBtnItemList[i].ui.mAnimator_QuestList:GetLayerIndex("Unlock"), 0)
    end
  end
  local cachePos = DarkNetCmdStoreData.questCachePos
  local level = AccountNetCmdHandler:GetLevel()
  local needlvId = PlayerPrefs.GetInt(self.uid .. UIDarkZoneQuestInfoPanel.EPlayerFirstClick.nextQuestGroupID)
  if needlvId > TableData.listDarkzoneQuestBundleDatas.Count + 100 then
    if cachePos then
      self:ReturnCachePos()
    else
      for i = 1, #self.finishList do
        if not self.finishList[i] then
          TimerSys:DelayCall(0.5, function()
            self.infoBtnItemList[i]:TransSlide()
          end)
          return
        end
      end
    end
    return
  end
  local needlv = TableData.listDarkzoneQuestBundleDatas:GetDataById(needlvId).quest_need_lv
  local notFirstOpen = PlayerPrefs.GetInt(self.uid .. UIDarkZoneQuestInfoPanel.EPlayerFirstClick.firstOpenQuest) == 1
  if level >= needlv then
    if notFirstOpen then
      if cachePos then
        self:ReturnCachePos()
      end
      TimerSys:DelayCall(0.5, function()
        self.infoBtnItemList[needlvId - 100]:TransSlide()
        CS.PopupMessageManager.PopupStateChangeString(TableData.GetHintById(903476))
      end)
    else
      PlayerPrefs.SetInt(self.uid .. UIDarkZoneQuestInfoPanel.EPlayerFirstClick.firstOpenQuest, 1)
    end
    PlayerPrefs.SetInt(self.uid .. UIDarkZoneQuestInfoPanel.EPlayerFirstClick.nextQuestGroupID, needlvId + 1)
  elseif cachePos then
    self:ReturnCachePos()
  else
    for i = 1, #self.finishList do
      if not self.finishList[i] then
        TimerSys:DelayCall(0.5, function()
          self.infoBtnItemList[i]:TransSlide()
        end)
        return
      end
    end
  end
end
function UIDarkZoneQuestInfoPanel:OnValueChange()
  local moveDir = self.ui.mTrans_SimpleContent.anchoredPosition.x
  if self.lastPos == nil then
    self.lastPos = 0
  end
  moveDir = moveDir - self.lastPos
  self.lastPos = self.ui.mTrans_SimpleContent.anchoredPosition.x
  for i = 1, #self.infoBtnItemList do
    if not self.infoBtnItemList[i].isFinish or LuaUtils.IsNullOrDestroyed(self.infoBtnItemList[i].ui.mBtn_Item) then
      return
    end
  end
  local posX = self.ui.mTrans_SimpleContent.anchoredPosition.x
  for i = 1, #self.infoBtnItemList do
    if i == 1 then
      if posX > self.infoBtnItemList[i + 1].pos + self.infoBtnItemList[i].Distance * 0.75 then
        self:SetInteractable(i)
      end
    elseif i == 6 then
      if posX <= self.infoBtnItemList[i].pos + self.infoBtnItemList[i].Distance * 0.5 then
        self:SetInteractable(i)
      end
    elseif moveDir < 0 then
      if posX < self.infoBtnItemList[i].pos and posX > self.infoBtnItemList[i + 1].pos + self.infoBtnItemList[i].Distance * 0.75 then
        self:SetInteractable(i)
      end
    elseif posX < self.infoBtnItemList[i].pos and posX > self.infoBtnItemList[i + 1].pos + self.infoBtnItemList[i].Distance * 0.75 then
      self:SetInteractable(i)
    end
  end
end
function UIDarkZoneQuestInfoPanel:SetInteractable(index)
  for i = 1, #self.infoBtnItemList do
    self.infoBtnItemList[i].ui.mBtn_Item.interactable = true
  end
  self.infoBtnItemList[index].ui.mBtn_Item.interactable = false
end
function UIDarkZoneQuestInfoPanel:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBack.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIDarkZoneQuestInfoPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Guide.gameObject).onClick = function()
    local param = {
      0,
      nil,
      9001
    }
    UIManager.OpenUIByParam(UIDef.UIGuideWindows, param)
  end
end
function UIDarkZoneQuestInfoPanel:OnClose()
  self.allQuestList = nil
  for i, v in pairs(self.questItemList) do
    self:ReleaseCtrlTable(v, true)
  end
  for i, v in pairs(self.infoBtnItemList) do
    self.infoBtnItemList[i]:DestroySelf()
  end
  if self.popString then
    gfdestroy(self.popString)
  end
  self.questItemList = nil
  self:ReleaseCtrlTable(self.infoRootItemList, true)
  DarkNetCmdTeamData:UnloadTeamAssets()
  self.infoRootItemList = nil
  self.simpleList = nil
  self.difficultyList = nil
  self.nightmareList = nil
  self.mData = nil
  self.hasFinishQuestList = nil
  self.questSeriesGroup = nil
  self.lockList = nil
end
function UIDarkZoneQuestInfoPanel:OnRelease()
end
