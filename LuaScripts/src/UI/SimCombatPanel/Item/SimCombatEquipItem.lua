require("UI.UIBaseCtrl")
SimCombatEquipItem = class("SimCombatEquipItem", UIBaseCtrl)
SimCombatEquipItem.__index = SimCombatEquipItem
function SimCombatEquipItem:__InitCtrl()
  self.mText_Name = self:GetText("Root/GrpTopLeft/Text")
  self.mText_Chapter = self:GetText("Root/GrpSimCombatLine/Trans_Text_Chapter")
  self.mText_1 = self:GetText("Root/GrpBottomLeft/Text1")
  self.mBtn_Equip = self:GetSelfButton()
  self.mTrans_Lock = self:GetRectTransform("Root/GrpState/Trans_GrpLocked")
  self.mTrans_UnLock = self:GetRectTransform("Root/GrpState/Trans_GrpUnlocked")
  self.mTrans_challenge1 = self:GetRectTransform("Root/GrpStage/GrpStage1/Trans_On")
  self.mTrans_challenge2 = self:GetRectTransform("Root/GrpStage/GrpStage2/Trans_On")
  self.mTrans_challenge3 = self:GetRectTransform("Root/GrpStage/GrpStage3/Trans_On")
  self.mTrans_Root = self:GetRectTransform("Root")
end
SimCombatEquipItem.mData = nil
SimCombatEquipItem.stageData = nil
SimCombatEquipItem.isUnLock = false
SimCombatEquipItem.OrangeColor = Color(0.9647058823529412, 0.44313725490196076, 0.09803921568627451, 1.0)
SimCombatEquipItem.WhiteColor = Color(1, 1, 1, 0.6)
function SimCombatEquipItem:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
function SimCombatEquipItem:InitLineImage()
  self.lineList = {}
  for i = 1, self.mTrans_RightLine.childCount do
    local obj = UIUtils.GetImage(self.mTrans_RightLine, "Image_RightLine" .. i)
    table.insert(self.lineList, obj)
  end
  for i = 1, self.mTrans_LeftLine.childCount do
    local obj = UIUtils.GetImage(self.mTrans_LeftLine, "Image_RightLine" .. i)
    table.insert(self.lineList, obj)
  end
end
function SimCombatEquipItem:SetData(data, icon, isLastItem)
  if data then
    self.mData = data
    self.recordData = NetCmdStageRecordData:GetStageRecordById(data.Id)
    self.stageData = TableData.listStageDatas:GetDataById(data.Id)
    self.SimCombatDailyData = TableData.listSimCombatResourceDatas:GetDataById(self.stageData.Id)
    self.mText_Name.text = self.stageData.name.str
    self.mText_Chapter.text = self.SimCombatDailyData.name.str
    self:UpdateState(false)
    self.mText_1.text = UIChapterGlobal:GetRandomNumWithOutIDStr()
    self.isUnLock = self:UpdateLockState()
    setactive(self.mTrans_Lock.gameObject, not self.isUnLock)
    setactive(self.mTrans_UnLock.gameObject, self.isUnLock)
    local isDone = NetCmdSimulateBattleData:CheckStageIsUnLock(self.mData.id)
    self:UpdateChallenge()
    setactive(self.mUIRoot.gameObject, true)
  else
    setactive(self.mUIRoot.gameObject, false)
  end
end
function SimCombatEquipItem:UpdateState(isChoose)
  self.mBtn_Equip.interactable = not isChoose
end
function SimCombatEquipItem:SetLineColor(isComplete)
  local color = isComplete and SimCombatEquipItem.OrangeColor or SimCombatEquipItem.WhiteColor
  for _, v in ipairs(self.lineList) do
    v.color = color
  end
end
function SimCombatEquipItem:UpdateLockState()
  local SimCombatDailyData = TableData.listSimCombatResourceDatas:GetDataById(self.mData.Id)
  return NetCmdDungeonData:IsUnLockSimCombatDaily(SimCombatDailyData)
end
function SimCombatEquipItem:InitLine(isLastItem)
  setactive(self.mTrans_RightLine.gameObject, not isLastItem)
end
function SimCombatEquipItem:UpdateChallenge()
  for i = 1, GlobalConfig.MaxChallenge do
    setactive(self["mTrans_challenge" .. i], self.recordData ~= nil and i <= self.recordData.ChallengeNum)
  end
end
