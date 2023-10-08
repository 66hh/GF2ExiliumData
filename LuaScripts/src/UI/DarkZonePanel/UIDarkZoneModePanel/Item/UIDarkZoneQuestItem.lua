UIDarkZoneQuestItem = class("UIDarkZoneQuestItem", UIBaseCtrl)
UIDarkZoneQuestItem.__index = UIDarkZoneQuestItem
function UIDarkZoneQuestItem:ctor()
end
function UIDarkZoneQuestItem:InitCtrl(prefab, parent)
  local obj = instantiate(prefab, parent)
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self.index = 0
  self.callBack = nil
  self.mData = nil
  self.ui.mAni_QuestItem.keepAnimatorControllerStateOnDisable = true
  self.ShowFlag = true
  UIUtils.GetButtonListener(self.ui.mBtn_Room.gameObject).onClick = function()
    if self.state == DarkZoneGlobal.QuestState.UnLocked or self.state == DarkZoneGlobal.QuestState.Finished then
      local t = {}
      t[0] = 1
      t[1] = self.mData.id
      if not pcall(function()
        DarkNetCmdStoreData.questCacheGroupId = self.GroupId
      end) then
        gfwarning("UIDarkZoneQuestInfoPanelItem位置缓存出现异常")
      end
      UIManager.OpenUIByParam(UIDef.UIDarkZoneQuestPanel, t)
    elseif self.state == DarkZoneGlobal.QuestState.Locked then
      local reason = ""
      local level = self.mData.unlock1
      local userLevel = AccountNetCmdHandler:GetLevel()
      if level > userLevel then
        reason = string_format(TableData.GetHintById(240066), level)
      end
      local questID = self.mData.Id
      local reasonUnlock2 = self:CheckLevelUnlockMinLevelUnlock2(questID)
      if reasonUnlock2 ~= "" then
        reasonUnlock2 = string_format(TableData.GetHintById(240087), reasonUnlock2)
        if reason ~= "" then
          reasonUnlock2 = string_format(TableData.GetHintById(240121), reason, reasonUnlock2)
        end
      end
      if reason ~= "" and reasonUnlock2 ~= "" then
        PopupMessageManager.PopupString(reasonUnlock2)
      elseif reason ~= "" then
        reason = string_format(TableData.GetHintById(240133), reason)
        PopupMessageManager.PopupString(reason)
      elseif reasonUnlock2 ~= "" then
        reasonUnlock2 = string_format(TableData.GetHintById(240133), reasonUnlock2)
        PopupMessageManager.PopupString(reasonUnlock2)
      end
    end
  end
end
function UIDarkZoneQuestItem:SetData(data, questBundleList, state, curLevelType, frontFinish, enoughLevel)
  self.mData = data
  self.state = state
  self.GroupId = 0
  self.frontFinish = frontFinish
  self.enoughLevel = enoughLevel
  self.curLevelType = curLevelType
  self.ui.mText_QuestName.text = self.mData.quest_name.str
  for i = 1, #questBundleList do
    for j = 0, questBundleList[i].quest_series_id.Count - 1 do
      if self.mData.id == questBundleList[i].quest_series_id[j] then
        self.GroupId = questBundleList[i].quest_group
        break
      end
    end
  end
  local hasNum = DarkNetCmdStoreData:GetDZQuestReceivedChest(data.id)
  local totalNum = DarkNetCmdStoreData:GetDZQuestTotalChest(data.id)
  if self.state == DarkZoneGlobal.QuestState.UnLocked or self.state == DarkZoneGlobal.QuestState.Finished and hasNum ~= totalNum then
    setactive(self.ui.mTrans_GrpProgress, true)
    if totalNum == 0 then
      self.ui.mImg_ChestProcess.fillAmount = 0
    else
      self.ui.mImg_ChestProcess.fillAmount = hasNum / totalNum
    end
  else
    self.ui.mImg_ChestProcess.fillAmount = 0
    setactive(self.ui.mTrans_GrpProgress, false)
  end
  if self.state == DarkZoneGlobal.QuestState.Finished and hasNum == totalNum then
    setactive(self.ui.mTrans_GrpProgress, false)
    self.ui.mImg_ChestProcess.fillAmount = 0
  end
  self.ui.mText_ChestNum.text = string_format(TableData.GetHintById(112016), hasNum, totalNum)
  self.ui.mText_Type.text = data.quest_tag.str
  local level = self:IsNewBieQuestType()
  if level then
    if level == 0 then
      self.ui.mImg_icon.color = DarkZoneGlobal.ColorType.newBie
      self.ui.mImg_TypeBg.color = DarkZoneGlobal.ColorType.newBie
      self.ui.mImg_ChestProcess.color = DarkZoneGlobal.ColorType.newBie
    elseif level == 1 then
      self.ui.mImg_icon.color = DarkZoneGlobal.ColorType.newBie2
      self.ui.mImg_TypeBg.color = DarkZoneGlobal.ColorType.newBie2
      self.ui.mImg_ChestProcess.color = DarkZoneGlobal.ColorType.newBie2
    end
  else
    local index = self:CheckIndex(curLevelType)
    if index == 1 then
      self.ui.mImg_icon.color = DarkZoneGlobal.ColorType.normal
      self.ui.mImg_TypeBg.color = DarkZoneGlobal.ColorType.normal
      self.ui.mImg_ChestProcess.color = DarkZoneGlobal.ColorType.normal
    elseif index == 2 then
      self.ui.mImg_icon.color = DarkZoneGlobal.ColorType.hard
      self.ui.mImg_TypeBg.color = DarkZoneGlobal.ColorType.hard
      self.ui.mImg_ChestProcess.color = DarkZoneGlobal.ColorType.hard
    elseif index == 3 then
      self.ui.mImg_icon.color = DarkZoneGlobal.ColorType.veryHard
      self.ui.mImg_TypeBg.color = DarkZoneGlobal.ColorType.veryHard
      self.ui.mImg_ChestProcess.color = DarkZoneGlobal.ColorType.veryHard
    end
  end
  local questType = TableData.listDarkzoneSeriesQuestTypeDatas:GetDataById(data.quest_type)
  self.ui.mImg_icon.sprite = IconUtils.GetDarkZoneModelIcon(questType.icon)
  setactive(self.ui.mImg_TypeBg, true)
  setactive(self.ui.mText_Type, true)
  setactive(self.ui.mImg_Special, self.mData.recommend_show and state ~= DarkZoneGlobal.QuestState.Finished)
  if hasNum ~= totalNum and state == DarkZoneGlobal.QuestState.Finished then
    state = DarkZoneGlobal.QuestState.UnLocked
  end
  TimerSys:DelayFrameCall(3, function()
    self.ui.mAni_QuestItem:SetInteger("State", state)
  end)
end
function UIDarkZoneQuestItem:IsNewBieQuestType()
  for i = 0, TableData.GlobalSystemData.DarkzoneBeginnerQuestGroup.Count - 1 do
    local id = TableData.GlobalSystemData.DarkzoneBeginnerQuestGroup[i]
    if self.curLevelType >= DarkZoneGlobal.StcIDToLevel[DarkZoneGlobal.DepartToLevel[id][1]] and self.curLevelType <= DarkZoneGlobal.StcIDToLevel[DarkZoneGlobal.DepartToLevel[id][3]] then
      return i
    end
  end
  return false
end
function UIDarkZoneQuestItem:CheckIndex(curLevelType)
  for k, v in pairs(DarkZoneGlobal.DepartToLevel) do
    for i = 1, #v do
      if curLevelType == DarkZoneGlobal.StcIDToLevel[v[i]] then
        return i
      end
    end
  end
end
function UIDarkZoneQuestItem:CheckLevelUnlockMinLevelUnlock2(questID)
  local reason = ""
  local quest = TableData.listDarkzoneSystemQuestDatas:GetDataById(questID)
  for i = 0, quest.unlock2.Count - 1 do
    if NetCmdDarkZoneSeasonData:IsQuestFinish(quest.unlock2[i]) ~= true then
      reason = reason .. TableData.listDarkzoneSystemQuestDatas:GetDataById(quest.unlock2[i]).QuestName.str
    end
  end
  return reason
end
function UIDarkZoneQuestItem:OnClose()
end
function UIDarkZoneQuestItem:CloseSelf()
  setactive(self.ui.mUIRoot, false)
end
function UIDarkZoneQuestItem:SetShowFlag(flag)
  if flag ~= nil then
    self.ShowFlag = flag
  end
end
function UIDarkZoneQuestItem:OpenSelf()
  if not self.ShowFlag then
    return
  end
  setactive(self.ui.mUIRoot, true)
end
function UIDarkZoneQuestItem:OnRelease()
  gfdestroy(self:GetRoot())
end
