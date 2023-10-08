require("UI.FacilityBarrackPanel.Item.ComChrUAVSkillInfoItem")
UIUAVSkillInfoPanel = class("UIUAVSkillInfoPanel", UIBasePanel)
function UIUAVSkillInfoPanel:ctor(csPanel)
  UIUAVSkillInfoPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIUAVSkillInfoPanel:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = UIUtils.GetUIBindTable(root)
  UIUtils.GetButtonListener(self.ui.mUIContainer_BtnClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIUAVSkillInfoPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BgClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIUAVSkillInfoPanel)
  end
  UIUtils.GetButtonListener(self.ui.mContainer_LeftArrow.gameObject).onClick = function()
    self:onClickLeftArrow()
  end
  UIUtils.GetButtonListener(self.ui.mContainer_RightArrow.gameObject).onClick = function()
    self:onClickRightArrow()
  end
  setactive(self.ui.mText_SkillDes, false)
  self.tabTable = {}
  self.curTabIndex = nil
  self:initTab()
end
function UIUAVSkillInfoPanel:OnInit(root, data)
  self.armId = data
  self:onClickTab(1)
end
function UIUAVSkillInfoPanel:OnShowStart()
  self:Refresh()
end
function UIUAVSkillInfoPanel:OnHide()
end
function UIUAVSkillInfoPanel:OnRelease()
  self.tabTable = nil
  self.curTabIndex = nil
  self.armId = nil
  self.ui = nil
end
function UIUAVSkillInfoPanel:Refresh()
  self:refreshTop()
  self:refreshRight()
  self:refreshArrow()
  self:onClickTabAfter(self.curTabIndex)
end
function UIUAVSkillInfoPanel:initTab()
  for i = 1, 2 do
    local item = ComChrUAVSkillInfoItem.New()
    item:InitCtrl(self.ui.mScrollListChild_InfoSelBtn)
    item:SetItemName(TableData.GetHintById(80006 + i))
    UIUtils.GetButtonListener(item.ui.mBtn_ComChrUAVSkillInfoItem.gameObject).onClick = function()
      self:onClickTab(i)
    end
    table.insert(self.tabTable, item)
  end
  self.tabTable[1]:SetItemName(TableData.GetHintById(102066))
  self.tabTable[2]:SetItemName(TableData.GetHintById(102248))
end
function UIUAVSkillInfoPanel:onClickTab(index)
  if index < 1 or index > #self.tabTable then
    return
  end
  if self.curTabIndex == index then
    return
  end
  if self.curTabIndex then
    local tab = self.tabTable[self.curTabIndex]
    tab:SetSelected(false)
  end
  self.curTabIndex = index
  local tab = self.tabTable[self.curTabIndex]
  tab:SetSelected(true)
  self:onClickTabAfter(index)
end
function UIUAVSkillInfoPanel:onClickTabAfter(index)
  for i = 0, self.ui.mTrans_DetailSkillLeveDes.childCount - 1 do
    gfdestroy(self.ui.mTrans_DetailSkillLeveDes:GetChild(i))
  end
  if index == 1 then
    self:refreshSkillEffect()
  elseif index == 2 then
    self:refreshLevelUpDetail()
  end
end
function UIUAVSkillInfoPanel:refreshTop()
  local armId = self.armId
  local armData = TableData.GetUavArmsData()
  local uavArmDict = NetCmdUavData:GetUavArmData()
  local subId = string.sub(armData[armId].SkillSet, 1, 3)
  local battleTacticSkillData = TableData.GetUarArmRevelantData(subId .. uavArmDict[armId].Level)
  self.ui.mImage_Icon.sprite = UIUtils.GetIconSprite("Icon/Skill", battleTacticSkillData.Icon)
  self.ui.mText_SkillName.text = TableData.GetUarArmRevelantData(subId .. uavArmDict[armId].Level).Name.str
  self.ui.mText_OilCostNum.text = battleTacticSkillData.TeCost
  self.ui.mText_LevelNum.text = uavArmDict[armId].Level
end
function UIUAVSkillInfoPanel:refreshRight()
  local armId = self.armId
  local armData = TableData.GetUavArmsData()
  local uavArmDict = NetCmdUavData:GetUavArmData()
  local subId = string.sub(armData[armId].SkillSet, 1, 3)
  local battleTacticSkillData = TableData.GetUarArmRevelantData(subId .. uavArmDict[armId].Level)
  local battleSkillData = TableData.GetSkillData(battleTacticSkillData.SkillList[0])
  local layoutTable = {}
  table.insert(layoutTable, self.ui.mGridLayout_1)
  table.insert(layoutTable, self.ui.mGridLayout_2)
  table.insert(layoutTable, self.ui.mGridLayout_3)
  CS.SkillRangeUIHelper.SetSkillRange(layoutTable, 1, battleSkillData)
  local isMaxRange = battleSkillData.SkillRange == 8
  setactive(self.ui.mTrans_Range, isMaxRange)
end
function UIUAVSkillInfoPanel:refreshSkillEffect()
  local armId = self.armId
  local armData = TableData.GetUavArmsData()
  local uavArmDict = NetCmdUavData:GetUavArmData()
  local subId = string.sub(armData[armId].SkillSet, 1, 3)
  local battleTacticSkillData = TableData.GetUarArmRevelantData(subId .. uavArmDict[armId].Level)
  self.ui.mText_DetailSkillDes.text = battleTacticSkillData.Detail.str
end
function UIUAVSkillInfoPanel:refreshLevelUpDetail()
  local armId = self.armId
  local armData = TableData.GetUavArmsData()
  local uavArmDict = NetCmdUavData:GetUavArmData()
  local subId = string.sub(armData[armId].SkillSet, 1, 3)
  local battleTacticSkillData = TableData.GetUarArmRevelantData(armData[armId].SkillSet)
  self.ui.mText_DetailSkillDes.text = battleTacticSkillData.description_brief.str
  local skillIdTable = List:New()
  for i = 2, 6 do
    skillIdTable:Add(tonumber(subId .. i))
  end
  for i = 0, skillIdTable:Count() - 1 do
    local item = UISkillDetailItem.New()
    item:InitCtrl(self.ui.mTrans_DetailSkillLeveDes)
    local skillId = skillIdTable[i + 1]
    local tempBattleTacticSkillData = TableData.listBattleTacticSkillDatas:GetDataById(skillId)
    local strDesc = tempBattleTacticSkillData.upgrade_description.str
    local skillLevel = string.sub(skillId, 4, 4)
    item:InitData(uavArmDict[armId].Level, tonumber(skillLevel), strDesc)
  end
end
function UIUAVSkillInfoPanel:refreshArrow()
  local leftArmId = self:getLeftArmId()
  setactive(self.ui.mContainer_LeftArrow, leftArmId ~= 0)
  local rightArmId = self:getRightArmId()
  setactive(self.ui.mContainer_RightArrow, rightArmId ~= 0)
end
function UIUAVSkillInfoPanel:onClickLeftArrow()
  local armId = self:getLeftArmId()
  if armId == 0 then
    return
  end
  self.armId = armId
  self:Refresh()
end
function UIUAVSkillInfoPanel:onClickRightArrow()
  local armId = self:getRightArmId()
  if armId == 0 then
    return
  end
  self.armId = armId
  self:Refresh()
end
function UIUAVSkillInfoPanel:getLeftArmId()
  local armIdList = NetCmdUavData:GetArmEquipState()
  local leftArmId = 0
  for i = 0, armIdList.Count - 1 do
    if armIdList[i] == self.armId then
      return leftArmId
    else
      leftArmId = armIdList[i]
    end
  end
  return 0
end
function UIUAVSkillInfoPanel:getRightArmId()
  local armIdList = NetCmdUavData:GetArmEquipState()
  for i = 0, armIdList.Count - 1 do
    if armIdList[i] == self.armId then
      local rightArmIdIndex = i + 1
      if rightArmIdIndex <= armIdList.Count - 1 then
        return armIdList[rightArmIdIndex]
      else
        return 0
      end
    end
  end
  return 0
end
