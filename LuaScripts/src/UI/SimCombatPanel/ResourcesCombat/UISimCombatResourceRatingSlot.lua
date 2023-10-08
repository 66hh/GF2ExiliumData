require("UI.SimCombatPanel.ResourcesCombat.UISimCombatGlobal")
UISimCombatResourceRatingSlot = class("UISimCombatResourceRatingSlot", UIBaseCtrl)
function UISimCombatResourceRatingSlot:SetRoot(root)
  self.ui = UIUtils.GetUIBindTable(root)
  self.super.SetRoot(self, root.transform)
  self.isFinish = false
end
function UISimCombatResourceRatingSlot:SetData(cashGradeData, stageId, index)
  self.cashGradeData = cashGradeData
  self.stageId = stageId
  self.index = index
  self.hasData = true
end
function UISimCombatResourceRatingSlot:Refresh(isRecover)
  local historicalHighScore = NetCmdStageRatingData:GetCashPoint(self.stageId)
  local isFinish = historicalHighScore >= self.cashGradeData.min_score
  local point = self.cashGradeData.min_score
  local gradeShowData = TableDataBase.listGradeShowDatas:GetDataById(self.cashGradeData.grade_id)
  local param1 = TableData.GetHintById(103151, gradeShowData.grade_name.str)
  local key = AccountNetCmdHandler:GetUID() .. UISimCombatGlobal.PopupSliderPoint .. self.cashGradeData.Id
  local hisPoint = PlayerPrefs.GetInt(key)
  if isFinish then
    local colorHex
    if self.index - 1 < TableDataBase.GlobalSystemData.GoldGradeColor.Count then
      colorHex = TableDataBase.GlobalSystemData.GoldGradeColor[self.index - 1]
    end
    if colorHex then
      param1 = TableData.ToRichText(colorHex, param1)
    end
  end
  self.ui.mText_Description.text = TableData.GetHintById(103148, param1, point)
  self.ui.mImage_Rating.sprite = IconUtils.GetSimCombatGoldSprite(self.cashGradeData.grade_id)
  self.ui.mAnimator:SetBool("Finish", isFinish)
end
function UISimCombatResourceRatingSlot:OnTop()
end
function UISimCombatResourceRatingSlot:OnBackFrom()
end
function UISimCombatResourceRatingSlot:SetFinish()
  local point = self.cashGradeData.min_score
  local param1 = TableData.GetHintById(103151, gradeShowData.grade_name.str)
  local colorHex
  if self.index - 1 < TableDataBase.GlobalSystemData.GoldGradeColor.Count then
    colorHex = TableDataBase.GlobalSystemData.GoldGradeColor[self.index - 1]
  end
  if colorHex then
    param1 = TableData.ToRichText(colorHex, param1)
  end
  self.ui.mText_Description.text = TableData.GetHintById(103148, param1, point)
end
function UISimCombatResourceRatingSlot:GetSlotPointState(curPoint)
  local key = AccountNetCmdHandler:GetUID() .. UISimCombatGlobal.PopupSliderPoint .. self.cashGradeData.Id
  local hisPoint = PlayerPrefs.GetInt(key)
  hisPoint = hisPoint or 0
  if curPoint > hisPoint and curPoint >= self.cashGradeData.min_score and hisPoint < self.cashGradeData.min_score then
    PlayerPrefs.SetInt(key, curPoint)
    return 1
  elseif hisPoint >= self.cashGradeData.min_score then
    return 2
  end
  return 0
end
function UISimCombatResourceRatingSlot:ClearData()
  self.cashGradeData = nil
  self.stageId = nil
  self.index = nil
  self.hasData = false
end
function UISimCombatResourceRatingSlot:HasData()
  return self.hasData
end
function UISimCombatResourceRatingSlot:OnRelease(isDestroy)
  self.cashGradeData = nil
  self.stageId = nil
  self.index = nil
  self.ui = nil
  self.super.OnRelease(self, isDestroy)
end
