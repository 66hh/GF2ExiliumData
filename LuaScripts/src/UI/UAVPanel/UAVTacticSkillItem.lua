UAVTacticSkillItem = class("UAVTacticSkillItem", UIBaseCtrl)
function UAVTacticSkillItem:__InitCtrl()
  self.mImage_Icon = self:GetImage("GrpIcon/ImgIcon")
  self.mText_OilCost = self:GetText("GrpText/Text_Num")
  self.mText_OilCostBg = self:GetImage("GrpText/ImgBg")
  self.mBtn_SKill = self:GetSelfButton()
  self.mAnimator = getcomponent(self.mBtn_SKill.transform, typeof(CS.UnityEngine.Animator))
  self.mAnimator:SetLayerWeight(1, 0)
  self.tabledata = TableData.GetUavArmsData()
  self.originCostColor = self.mText_OilCostBg.color
end
function UAVTacticSkillItem:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
function UAVTacticSkillItem:InitData(armid, maxFuelPerLevel)
  if armid == 0 then
    return
  end
  self.maxFuelPerLevel = maxFuelPerLevel
  self.deltaTime = 0
  local smallicondata = TableData.GetUarArmRevelantData(tonumber(self.tabledata[armid].SkillSet))
  self.TeCost = smallicondata.TeCost
  for i = 0, self.tabledata.Count - 1 do
    if armid == self.tabledata[armid].Id then
      self.mImage_Icon.sprite = UIUtils.GetIconSprite("Icon/Skill", smallicondata.Icon)
      self.mText_OilCost.text = smallicondata.TeCost
      UIUtils.GetButtonListener(self.mBtn_SKill.gameObject).onClick = function()
        self:OnClickIcon(armid)
      end
      break
    end
  end
end
function UAVTacticSkillItem:OnUpdate(deltaTime)
  if self.deltaTime and self.deltaTime < 3 then
    self.deltaTime = self.deltaTime + deltaTime
    self.mAnimator:SetBool("UnlockStated", self.maxFuelPerLevel > self.TeCost)
  end
end
function UAVTacticSkillItem:OnClickIcon(armid)
  UIManager.OpenUIByParam(UIDef.UIUAVSkillInfoPanel, armid)
end
function UAVTacticSkillItem:OnRelease()
  self.deltaTime = 0
end
