require("UI.UIBaseCtrl")
UIBattleIndexModeListItem = class("UIBattleIndexModeListItem", UIBaseCtrl)
UIBattleIndexModeListItem.__index = UIBattleIndexModeListItem
UIBattleIndexModeListItem.mBtn_BattleIndexModeItem = nil
UIBattleIndexModeListItem.mText_ = nil
function UIBattleIndexModeListItem:__InitCtrl()
end
function UIBattleIndexModeListItem:InitCtrl(parent, child)
  local instObj = instantiate(child)
  CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:__InitCtrl()
end
function UIBattleIndexModeListItem:SetData(data)
  self.mData = data
  self.ui.mText_Text.text = data.name.str
  self.mIsLock = false
  self.globalTab = GetOrAddComponent(self:GetRoot().gameObject, (typeof(GlobalTab)))
  self.globalTab:SetGlobalTabId(data.GlobalTab, data.unlock)
  if data.unlock > 0 then
    self.mIsLock = not AccountNetCmdHandler:CheckSystemIsUnLock(data.unlock)
  end
  if self.mData.id == 2 then
    local hasReward = false
    local hardList = TableData.GetHardChapterListV2()
    for i = 0, hardList.Count - 1 do
      local id = hardList[i].id
      hasReward = hasReward or 0 < NetCmdDungeonData:UpdateDifficultChapterRewardRedPoint(id) or NetCmdSimulateBattleData:CheckCanAnalysisByChapterID(id) or NetCmdDungeonData:CheckNewChapterUnlockByID(id)
    end
    local systemHasLook = NetCmdDungeonData:CheckDifficultChapterSystemHasLook()
    local simBattleRedPoint = NetCmdSimulateBattleData:CheckSimBattleHasRedPoint()
    local mythicRedPoint = NetCmdSimCombatMythicData:CheckRedPoint()
    setactive(self.ui.mTrans_RedPoint, not self.mIsLock and NetCmdPVPData:CheckPvpRedPoint() ~= 0 or mythicRedPoint or hasReward or simBattleRedPoint or systemHasLook == false)
  elseif self.mData.id == 3 then
    local hasReward = false
    local hardList = TableData.GetHardChapterList()
    for i = 0, hardList.Count - 1 do
      hasReward = hasReward or 0 < NetCmdDungeonData:UpdateChatperRewardRedPoint(hardList[i].id)
    end
    setactive(self.ui.mTrans_RedPoint, hasReward)
  elseif self.mData.id == 1 then
    local hasReward = false
    local storyList = TableData.GetNormalChapterList()
    for i = 0, storyList.Count - 1 do
      hasReward = hasReward or 0 < NetCmdDungeonData:UpdateChatperRewardRedPoint(storyList[i].id)
    end
    local isNeedRedPoint = NetCmdSimulateBattleData:CheckTeachingUnlockRedPoint() or NetCmdSimulateBattleData:CheckTeachingRewardRedPoint() or NetCmdSimulateBattleData:CheckTeachingNoteReadRedPoint() or NetCmdSimulateBattleData:CheckTeachingNoteProgressRedPoint()
    setactive(self.ui.mTrans_RedPoint, hasReward or isNeedRedPoint)
  elseif self.mData.id == 4 then
    local isNeedRedPoint = NetCmdSimulateBattleData:CheckSimStageIndexRedPoint(self.mData.id)
    setactive(self.ui.mTrans_RedPoint, isNeedRedPoint)
  elseif self.mData.id == 5 then
    for i = 0, self.mData.detail_id.Count - 1 do
      local chapterData = TableData.listChapterDatas:GetDataById(self.mData.detail_id[i])
      if chapterData then
        local planActivity = TableData.listPlanDatas:GetDataById(chapterData.plan_id)
        if planActivity and (CGameTime:GetTimestamp() < planActivity.open_time or CGameTime:GetTimestamp() > planActivity.close_time) then
          self.mIsLock = true
          break
        end
      end
    end
    if not AccountNetCmdHandler:CheckSystemIsUnLock(NetCmdThemeData:GetRecentActivityUnlockid()) then
      self.mIsLock = true
    end
    setactive(self.ui.mTrans_RedPoint, not self.mIsLock and NetCmdThemeData:ThemeBattleRed())
  end
  setactive(self.ui.mTrans_Locked, self.mIsLock)
end
function UIBattleIndexModeListItem:GetGlobalTab()
  return self.globalTab
end
function UIBattleIndexModeListItem:OnRelease()
  gfdestroy(self.mUIRoot.gameObject)
  self.globalTab = nil
  self.super.OnRelease(self)
end
