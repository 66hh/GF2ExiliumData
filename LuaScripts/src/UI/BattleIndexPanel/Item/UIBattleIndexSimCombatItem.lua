require("UI.UIBaseCtrl")
UIBattleIndexSimCombatItem = class("UIBattleIndexSimCombatItem", UIBaseCtrl)
UIBattleIndexSimCombatItem.__index = UIBattleIndexSimCombatItem
UIBattleIndexSimCombatItem.mText_Tips = nil
UIBattleIndexSimCombatItem.mText_Title = nil
UIBattleIndexSimCombatItem.mText_ = nil
UIBattleIndexSimCombatItem.mText_BattleIndexSimbatItem1 = nil
function UIBattleIndexSimCombatItem:__InitCtrl()
end
function UIBattleIndexSimCombatItem:InitCtrl(parent)
  local instObj = instantiate(UIUtils.GetGizmosPrefab("BattleIndex/Btn_BattleIndexSimCombatItem.prefab", self))
  CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  setactive(self.ui.mText_TitleName, false)
  self:__InitCtrl()
end
function UIBattleIndexSimCombatItem:SetData(data)
  self.mData = data
  self.mSimType = StageType.__CastFrom(data.id)
  self.ui.mText_Text.text = self:GetSimCombatName(data)
  self.ui.mText_Open.text = data.open_time.str
  self.ui.mImg_Pic.sprite = IconUtils.GetStageIcon(data.image)
  self.ui.mImg_Icon.sprite = IconUtils.GetStageIcon(data.icon)
  self:CheckSimCombatIsUnLock()
  self:CheckExtraTimesAndItems()
  self:CheckDuty()
  setactive(self.ui.mTrans_RedPoint, self:CheckHasRedPoint())
  if self.mData.id == 26 then
    setactive(self.ui.mTrans_RedPoint, NetCmdSimulateBattleData:CheckTeachingUnlockRedPoint() or NetCmdSimulateBattleData:CheckTeachingRewardRedPoint() or NetCmdSimulateBattleData:CheckTeachingNoteReadRedPoint() or NetCmdSimulateBattleData:CheckTeachingNoteProgressRedPoint())
  elseif self.mData.id == 30 then
    local timeCount = NetCmdPVPData.PVPLastTime
    if timeCount <= 0 then
      self.ui.mText_Open.text = TableData.GetHintById(150001)
      setactive(self.ui.mTrans_RedPoint, false)
    else
      local deltaTimeStr = NetCmdPVPData:ConvertPvpTime(CGameTime:GetTimestamp(), NetCmdPVPData.PVPCloseTime)
      self.ui.mText_Open.text = string_format(TableData.GetHintById(103129), deltaTimeStr)
      setactive(self.ui.mTrans_RedPoint, NetCmdPVPData:CheckPvpRedPoint() ~= 0)
    end
  elseif self.mData.id == 25 then
    local hasReceiveTarget = NetCmdSimCombatMythicData:CheckRedPoint()
    setactive(self.ui.mTrans_RedPoint, hasReceiveTarget)
    setactive(self.ui.mText_TitleName, true)
    self.ui.mText_TitleName.text = NetCmdSimCombatMythicData:GetEntranceLevelName()
  elseif self.mData.id == CS.GF2.Data.StageType.DifficultStage:GetHashCode() then
    local hasReward = false
    local hardList = TableData.GetHardChapterListV2()
    local systemHasLook = NetCmdDungeonData:CheckDifficultChapterSystemHasLook()
    for i = 0, hardList.Count - 1 do
      local id = hardList[i].id
      hasReward = hasReward or 0 < NetCmdDungeonData:UpdateDifficultChapterRewardRedPoint(id) or NetCmdSimulateBattleData:CheckCanAnalysisByChapterID(id) or NetCmdDungeonData:CheckNewChapterUnlockByID(id)
    end
    setactive(self.ui.mTrans_RedPoint, hasReward or systemHasLook == false)
  elseif self.mSimType == StageType.WeeklyStage then
    local weeklyData = NetCmdSimulateBattleData:GetSimCombatWeeklyData()
    if weeklyData then
      local time = weeklyData:GetLastTime()
      local timeStr = CS.TimeUtils.LeftTimeToShowFormat(time)
      if 0 < time then
        self.ui.mText_Open.text = string_format(TableData.GetHintById(103130), timeStr)
      else
        self.ui.mText_Open.text = string_format("{0}{1}", CS.TimeUtils.LeftTimeToShowFormat(weeklyData:LastOpenTime()), TableData.GetHintById(180168))
      end
      local isStart = weeklyData.isStartA or weeklyData.isStartB
      setactive(self.ui.mText_TitleName, isStart)
      if isStart then
        self.ui.mText_TitleName.text = UIUtils.GetHintStr(108155)
      end
    end
  end
end
function UIBattleIndexSimCombatItem:GetSimCombatName(data)
  if self.mSimType == StageType.WeeklyStage then
    local weeklyData = NetCmdSimulateBattleData:GetSimCombatWeeklyData()
    if weeklyData and weeklyData.degreeData then
      return weeklyData.degreeData.name.str
    end
  end
  return data.name.str
end
function UIBattleIndexSimCombatItem:CheckSimCombatIsUnLock()
  local isUnLock = AccountNetCmdHandler:CheckSystemIsUnLock(self.mData.unlock)
  setactive(self.ui.mTrans_GrpLocked, not isUnLock)
  setactive(self.ui.mTrans_GrpOpen, isUnLock)
  if not isUnLock then
    self.ui.mText_Locked.text = self.mData.unlock_describe.str
  end
end
function UIBattleIndexSimCombatItem:CheckExtraTimesAndItems()
end
function UIBattleIndexSimCombatItem:CheckDuty()
  if self.mData.id == 22 or self.mData.id == StageType.DutyStage.value__ then
    NetCmdSimulateBattleData:ReqPlanData(CS.GF2.Data.PlanType.PlanFunctionSimDailyopen:GetHashCode(), function()
      setactive(self.ui.mTrans_GrpDuty, AccountNetCmdHandler:CheckSystemIsUnLock(self.mData.unlock))
      local args = NetCmdSimulateBattleData.PlanData.Args
      local list = self.mData.label_id
      for i = 0, list.Count - 1 do
        for j = 0, args.Count - 1 do
          if list[i] == args[j] then
            setactive(self.ui.mTrans_GrpDuty:GetChild(i):Find("Off"), false)
            setactive(self.ui.mTrans_GrpDuty:GetChild(i):Find("On"), true)
            break
          else
            setactive(self.ui.mTrans_GrpDuty:GetChild(i):Find("Off"), true)
            setactive(self.ui.mTrans_GrpDuty:GetChild(i):Find("On"), false)
          end
        end
      end
    end)
  end
end
function UIBattleIndexSimCombatItem:CheckHasRedPoint()
  if self.mSimType == StageType.WeeklyStage then
    return NetCmdSimulateBattleData:CheckSimWeeklyRedPoint()
  end
  return false
end
