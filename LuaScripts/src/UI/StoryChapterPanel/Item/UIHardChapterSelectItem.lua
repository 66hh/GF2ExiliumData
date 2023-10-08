require("UI.UIBaseCtrl")
UIHardChapterSelectItem = class("UIHardChapterSelectItem", UIBaseCtrl)
UIHardChapterSelectItem.__index = UIHardChapterSelectItem
function UIHardChapterSelectItem:__InitCtrl()
end
function UIHardChapterSelectItem:InitCtrl(instObj)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.challengeList = {}
  self.isUnLock = false
  self.canShowRedDot = false
  self.isComplete = nil
  self.ui.mText_RaidNum = self.ui.mBtn_Raid.transform:Find("Text_Num"):GetComponent("Text")
  self.ui.mTrans_RaidRedPoint = self.ui.mBtn_Raid.transform:Find("Trans_RedPoint"):GetComponent("RectTransform")
  self.ui.mAnimator_Root.keepAnimatorControllerStateOnDisable = true
  self.ui.mAnimator_NowArrow.keepAnimatorControllerStateOnDisable = true
  self.totalRaidNum = 0
  self.picString = "Img_SimComBatHard_Photo{0}-{1}"
end
function UIHardChapterSelectItem:SetData(data)
  self.mData = data
  if data == nil then
    self.ui.mAnimator_NowArrow:SetTrigger("FadeOut")
  end
  if data ~= nil then
    setactive(self.mUIRoot, true)
    self.isUnLock = true
    for i = 0, data.unlock.Count - 1 do
      if not NetCmdAchieveData:CheckComplete(data.unlock[i]) then
        self.isUnLock = false
      end
    end
    self.levelUnlocked = AccountNetCmdHandler:GetLevel() >= data.level
    self.isNew = not AccountNetCmdHandler:IsWatchedChapter(data.id)
    local canReceive = 0 < NetCmdDungeonData:UpdateDifficultChapterRewardRedPoint(data.id)
    local canAnalysis = NetCmdSimulateBattleData:CheckCanAnalysisByChapterID(data.id)
    self.isNewChapter = NetCmdDungeonData:CheckNewChapterUnlockByID(data.id)
    setactive(self.ui.mTrans_RedPoint, (canReceive or canAnalysis or self.isNewChapter) and self.isUnLock == true and self.levelUnlocked == true)
    self:UpdateChapterItem()
  else
    setactive(self.mUIRoot, false)
  end
end
function UIHardChapterSelectItem:UpdateChapterItem()
  self.chapterNum = self.mData.id > 100 and self.mData.id % 100 or self.mData.id
  self.ui.mText_StageNum.text = string.format("-", self.chapterNum)
  self.ui.mText_StageName.text = self.mData.name.str
end
function UIHardChapterSelectItem:UpDateRaidInfo()
  local tableDataCanRaid = self.mData.chapter_sweeps_switch == 1
  if tableDataCanRaid then
    self.MaxRaidNum = self.mData.sweeps_times > 0 and self.mData.sweeps_times or 99
    local raidNum = NetCmdSimulateBattleData:GetDifficultRaidTime(self.mData.id)
    self.canRaidNum = self.MaxRaidNum
    if 0 <= raidNum and self.mData.sweeps_times > 0 then
      self.canRaidNum = self.MaxRaidNum - raidNum
    end
    local str = "-"
    if self.canRaid == true then
      str = string_format(TableData.GetHintById(112016), self.canRaidNum, self.MaxRaidNum)
    end
    self.ui.mText_RaidNum.text = str
    setactive(self.ui.mText_RaidNum, self.mData.sweeps_times > 0)
  end
  setactive(self.ui.mBtn_Raid.transform.parent, tableDataCanRaid == true)
end
function UIHardChapterSelectItem:OnRelease(isDestroy)
  if self.lineItem then
    self.lineItem:OnRelease()
  end
  self.lineItem = nil
  self.super.OnRelease(self)
end
function UIHardChapterSelectItem:IsNowSelect(active)
  if active then
    self.ui.mAnimator_NowArrow:SetTrigger("FadeIn")
  else
    self.ui.mAnimator_NowArrow:SetTrigger("FadeOut")
  end
end
function UIHardChapterSelectItem:SetTotalRaidNum(num)
  self.totalRaidNum = num
end
function UIHardChapterSelectItem:SetComplete(isComplete)
  if self.isComplete ~= isComplete then
    self.isComplete = isComplete
    local str = "T"
    if self.isComplete == false then
      str = "F"
    end
    str = string_format(self.picString, self.chapterNum, str)
    self.ui.mImg_Bg2.sprite = IconUtils.GetAtlasV2("SimComBatHard", str)
  end
  self.canRaid = isComplete
  self:UpDateRaidInfo()
end
function UIHardChapterSelectItem:SetAnimState()
  local isNotUnlock = not self.isUnLock or not self.levelUnlocked
  local isAllAnalysis = NetCmdSimulateBattleData:IsAnalysisAllDifficultChapterStory(self.mData.id)
  local switchNum = 0
  if isNotUnlock == false then
    switchNum = 1
    if isAllAnalysis == true then
      switchNum = 2
    end
  end
  self.ui.mAnimator_Root:SetInteger("Switch", switchNum)
end
function UIHardChapterSelectItem:SetLine(startPos, endPos)
  if self.lineItem then
    self.lineItem:EnableLine(true)
    self.lineItem:SetLinePos(startPos, endPos)
  end
end
function UIHardChapterSelectItem:UpdatePoint(isUnlock)
  if self.lineItem then
    self.lineItem:UpdateLineColor(isUnlock)
  end
end
