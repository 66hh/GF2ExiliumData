require("UI.UIBaseCtrl")
SimCombatRuneItem = class("SimCombatRuneItem", UIBaseCtrl)
SimCombatRuneItem.__index = SimCombatRuneItem
function SimCombatRuneItem:__InitCtrl()
  self.mText_Name = self:GetText("Root/GrpTopLeft/Text")
  self.mText_Chapter = self:GetText("Root/GrpSimCombatLine/Trans_Text_Chapter")
  self.mImageElement = self:GetImage("Root/GrpState/Trans_GrpUnlocked/Img_Element")
  self.mImageElementColor = self:GetImage("Root/GrpBg/Img_Element")
  self.mBtn_Equip = self:GetSelfButton()
  self.mTrans_Lock = self:GetRectTransform("Root/GrpState/Trans_GrpLocked")
  self.mTrans_UnLock = self:GetRectTransform("Root/GrpState/Trans_GrpUnlocked")
  self.mTrans_challenge1 = self:GetRectTransform("Root/GrpStage/GrpStage1/Trans_On")
  self.mTrans_challenge2 = self:GetRectTransform("Root/GrpStage/GrpStage2/Trans_On")
  self.mTrans_challenge3 = self:GetRectTransform("Root/GrpStage/GrpStage3/Trans_On")
  self.mTrans_Root = self:GetRectTransform("Root")
end
SimCombatRuneItem.mData = nil
SimCombatRuneItem.stageData = nil
SimCombatRuneItem.isUnLock = false
SimCombatRuneItem.OrangeColor = Color(0.9647058823529412, 0.44313725490196076, 0.09803921568627451, 1.0)
SimCombatRuneItem.WhiteColor = Color(1, 1, 1, 0.6)
function SimCombatRuneItem:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
function SimCombatRuneItem:InitLineImage()
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
function SimCombatRuneItem:SetData(data, lableData, isLastItem)
  if data then
    self.mData = data
    self.recordData = NetCmdStageRecordData:GetStageRecordById(data.stage_id)
    self.stageData = TableData.listStageDatas:GetDataById(data.stage_id)
    local index = tonumber(data.sequence)
    self.mText_Name.text = self.stageData.name.str
    self.mText_Chapter.text = self.stageData.code.str
    self:UpdateState(false)
    local elementData = TableData.listLanguageElementDatas:GetDataById(lableData.element_id)
    self.mImageElement.sprite = IconUtils.GetElementIcon(elementData.icon .. "_M_W")
    self.mImageElementColor.color = ColorUtils.StringToColor(elementData.color)
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
function SimCombatRuneItem:UpdateState(isChoose)
  self.mBtn_Equip.interactable = not isChoose
end
function SimCombatRuneItem:SetLineColor(isComplete)
  local color = isComplete and SimCombatRuneItem.OrangeColor or SimCombatRuneItem.WhiteColor
  for _, v in ipairs(self.lineList) do
    v.color = color
  end
end
function SimCombatRuneItem:UpdateLockState()
  if self.mData.unlock == 1 then
    return true
  elseif self.mData.unlock == 2 then
    return NetCmdSimulateBattleData:CheckStageIsUnLock(self.mData.unlock_detail)
  elseif self.mData.unlock == 3 then
  end
end
function SimCombatRuneItem:InitLine(isLastItem)
  setactive(self.mTrans_RightLine.gameObject, not isLastItem)
end
function SimCombatRuneItem:UpdateChallenge()
  for i = 1, GlobalConfig.MaxChallenge do
    setactive(self["mTrans_challenge" .. i], self.recordData ~= nil and i <= self.recordData.ChallengeNum)
  end
end
