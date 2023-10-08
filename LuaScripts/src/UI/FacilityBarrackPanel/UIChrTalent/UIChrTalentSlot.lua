UIChrTalentSlot = class("UIChrTalentSlot", UIBaseCtrl)
function UIChrTalentSlot:ctor(root, onClickCallback)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root)
  self.onClickCallback = onClickCallback
  UIUtils.AddBtnClickListener(self.ui.mBtn_ChrTalentItemV3.gameObject, function()
    self:onClickSlot()
  end)
  local randomNum = math.random(1, 20009)
  self.ui.mText_RandomNum.text = "00：" .. UIUtils.AddZeroFrontNum(5, randomNum)
end
function UIChrTalentSlot:InitData(gunId, treeId, groupId, groupIndex, slotIndex)
  self.gunId = gunId
  self.treeId = treeId
  self.groupId = groupId
  self.groupIndex = groupIndex
  self.slotIndex = slotIndex
  self.preLevel = NetCmdTalentData:GetGunTalentLevel(self.gunId, self.groupId)
  self:LoseFocus()
end
function UIChrTalentSlot:OnShow()
  self.ui.mAnimator:SetTrigger("FadeIn")
  self:Refresh()
end
function UIChrTalentSlot:Refresh()
  if self.gunId == nil then
    setactivewithcheck(self.ui.mTrans_Empty, true)
    setactivewithcheck(self.ui.mTrans_GrpComItem, false)
    setactivewithcheck(self.ui.mTrans_GrpSkillItem, false)
    setactivewithcheck(self.ui.mTrans_GrpTab, false)
    setactivewithcheck(self.ui.mObj_RedPoint, false)
    setactivewithcheck(self.ui.mTrans_Lock, false)
    setactivewithcheck(self.ui.mTrans_ImgLine, false)
    setactivewithcheck(self.ui.mTrans_GrpSel, false)
    setactivewithcheck(self.ui.mTrans_Activated, false)
    setactivewithcheck(self.ui.mTrans_GrpLocked, false)
    setactivewithcheck(self.ui.mTrans_Cast, false)
    setactivewithcheck(self.ui.mTrans_Audio, false)
    return
  end
  setactivewithcheck(self.ui.mTrans_ImgConnectLineB, false)
  setactivewithcheck(self.ui.mTrans_ImgActivatedLineB, false)
  setactivewithcheck(self.ui.mTrans_ImgConnectLineT, false)
  setactivewithcheck(self.ui.mTrans_ImgActivatedLineT, false)
  setactivewithcheck(self.ui.mTrans_Empty, false)
  if self.slotIndex == 1 then
    setactivewithcheck(self.ui.mTrans_ImgConnectLineB, true)
    setactivewithcheck(self.ui.mTrans_ImgActivatedLineB, true)
  elseif self.slotIndex == 3 then
    setactivewithcheck(self.ui.mTrans_ImgConnectLineT, true)
    setactivewithcheck(self.ui.mTrans_ImgActivatedLineT, true)
  end
  self.level = NetCmdTalentData:GetGunTalentLevel(self.gunId, self.groupId)
  self.state = UITalentGlobal.GetGunTalentState(self.gunId, self.groupId)
  self.type = UITalentGlobal.GetTalentType(self.groupId)
  setactivewithcheck(self.ui.mTrans_Lock, self.state == UITalentGlobal.TalentState.Lock or self.state == UITalentGlobal.TalentState.PrevConditionLock)
  if self.level == 1 and self.level > self.preLevel then
    self.ui.mAnimator:SetTrigger("Active_Fx")
    self.preLevel = self.level
  end
  local suffix
  if self.slotIndex < 10 then
    suffix = "0" .. tostring(self.slotIndex)
  else
    suffix = tostring(self.slotIndex)
  end
  self.ui.mText_SequenceNum.text = self.groupIndex .. "-" .. suffix
  self.ui.mText_SkillSequenceNum.text = self.groupIndex .. "-" .. suffix
  self.ui.mAnimator:SetBool("Bool", self.state > UITalentGlobal.TalentState.Unauthorized)
  local geneData = UITalentGlobal.GetTargetGeneData(self.groupId, self.level)
  if self.type == UITalentGlobal.TalentType.NormalAttribute then
    self.ui.mAnimator:SetInteger("State", 0)
    if self.state == UITalentGlobal.TalentState.Authorized then
      self.ui.mGroupCanvas_GrpComItem.alpha = 1
    else
      self.ui.mGroupCanvas_GrpComItem.alpha = 0.3
    end
    self.ui.mGroupCanvas_GrpTab.alpha = 0
    self.ui.mGroupCanvas_GrpSkillItem.alpha = 0
    self.ui.mImage_PropertyIcon.sprite = self:getPropertyIcon(geneData.PropertyId)
  elseif self.type == UITalentGlobal.TalentType.AdvancedAttribute then
    self.ui.mAnimator:SetInteger("State", 1)
    if self.state == UITalentGlobal.TalentState.Authorized then
      self.ui.mGroupCanvas_GrpComItem.alpha = 1
    else
      self.ui.mGroupCanvas_GrpComItem.alpha = 0.3
    end
    self.ui.mGroupCanvas_GrpTab.alpha = 0
    self.ui.mGroupCanvas_GrpSkillItem.alpha = 0
    self.ui.mImage_PropertyIcon.sprite = self:getPropertyIcon(geneData.PropertyId)
  elseif self.type == UITalentGlobal.TalentType.PrivateTalentKey then
    if self.state > UITalentGlobal.TalentState.Unauthorized then
      self.ui.mGroupCanvas_GrpTab.alpha = 1
    end
    self.ui.mGroupCanvas_GrpSkillItem.alpha = 1
    self.ui.mGroupCanvas_GrpComItem.alpha = 0
    self.ui.mImage_SkillItemIcon.sprite = IconUtils.GetItemIconSprite(geneData.ItemId)
  end
  if NetCmdTalentData:IsCanAuthorizePoint(self.gunId, self.groupId) then
    self.ui.mGroupCanvas_RedPoint.alpha = 1
  else
    self.ui.mGroupCanvas_RedPoint.alpha = 0
  end
end
function UIChrTalentSlot:OnHide()
end
function UIChrTalentSlot:OnRelease(isDestroy)
  self.gunId = nil
  self.groupId = nil
  self.groupIndex = nil
  self.slotIndex = nil
  self.onClickCallback = nil
  self.treeId = nil
  self.level = nil
  self.type = nil
  self.ui = nil
  self.super.OnRelease(self, isDestroy)
end
function UIChrTalentSlot:GetTreeId()
  return self.treeId
end
function UIChrTalentSlot:GetGroupId()
  return self.groupId
end
function UIChrTalentSlot:GetGroupIndex()
  return self.groupIndex
end
function UIChrTalentSlot:GetSlotIndex()
  return self.slotIndex
end
function UIChrTalentSlot:GetLevel()
  return self.level
end
function UIChrTalentSlot:GetState()
  return self.state
end
function UIChrTalentSlot:GetType()
  return self.type
end
function UIChrTalentSlot:GetTalentId()
  return self.gunId
end
function UIChrTalentSlot:IsMaxLevel()
  local groupData = TableDataBase.listSquadTalentGroupDatas:GetDataById(self.groupId)
  return self:GetLevel() == groupData.max_level
end
function UIChrTalentSlot:Focus()
  self.ui.mBtn_ChrTalentItemV3.interactable = false
end
function UIChrTalentSlot:LoseFocus()
  self.ui.mBtn_ChrTalentItemV3.interactable = true
end
function UIChrTalentSlot:SetAlpha(value)
  self.ui.mCanvasGroup.alpha = value
end
function UIChrTalentSlot:GetAnimLength(animName)
  return CS.LuaUtils.GetAnimationClipLength(self.ui.mAnimator, animName)
end
function UIChrTalentSlot:getPropertyIcon(propertyId)
  local propertyTypeName = PropertyHelper.GetOnlyOnePropty(propertyId)
  local propertyData = TableData.GetPropertyDataByName(propertyTypeName)
  return IconUtils.GetAttributeIcon(propertyData.icon)
end
function UIChrTalentSlot:onClickSlot()
  if self.gunId == nil then
    gfdebug("当前是空天赋点!")
    return
  end
  gfdebug(tostring("GroupIndex: " .. self.groupIndex) .. "   SlotIndex: " .. tostring(self.slotIndex))
  local talentPoint = NetCmdTalentData:GetTalentPoint(self.gunId, self.groupId)
  gfdebug(talentPoint:ToString())
  if self.onClickCallback then
    self.onClickCallback(self.groupIndex, self.slotIndex)
  end
end
