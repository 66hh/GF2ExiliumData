UISkillContent = class("UISkillContent", UIBarrackContentBase)
UISkillContent.__index = UISkillContent
UISkillContent.PrefabPath = "Character/ChrSkillInfoDialog.prefab"
local self = UISkillContent
function UISkillContent:ctor(obj)
  self.skillList = {}
  self.attrList = {}
  self.curSkill = nil
  self.upgradeDetailList = {}
  self.skillDetailList = {}
  self.upgradeItemList = {}
  self.skillDetail = nil
  self.skillUpgradeEffectDuration = 0
  self.skillUpgradeTimers = {}
  self.costItem = nil
  self.isItemEnough = false
  UISkillContent.super.ctor(self, obj)
end
function UISkillContent:__InitCtrl()
  self.mBtn_Goto = UIUtils.GetTempBtn(self.ui.mTrans_BtnGoTo)
  UIUtils.GetText(self.mBtn_Goto.transform:Find("Root/GrpText/Text_Name")).text = TableData.GetHintById(102247)
  self.mBtn_Left = UIUtils.GetTempBtn(self.ui.mTrans_BtnLeft)
  self.mBtn_Right = UIUtils.GetTempBtn(self.ui.mTrans_BtnRight)
  self.mBtn_LevelInfo = UIUtils.GetTempBtn(self.ui.mTrans_GrpOff)
  self.mBtn_Close = UIUtils.GetTempBtn(self.ui.mTrans_GrpClose)
  self.mBtn_BgClose = self.ui.mBtn_Close
  self.mBtn_LevelInfoClose = self.ui.mBtn_Close1
  self.mBtn_LevelInfoBgClose = self.ui.mBtn_Close1
  self.mImage_Icon = self.ui.mImg_Icon
  self.mText_Name = self.ui.mText_Name
  self.mText_Level = self.ui.mText_Level
  self.mItem_DeepUse = self:InitAttribute("Root/GrpDialog/GrpCenter/GrpSkillInfo/GrpNumInfo/GrpRange", 1)
  self.mItem_DeepUse = self:InitAttribute("Root/GrpDialog/GrpCenter/GrpSkillInfo/GrpNumInfo/GrpDeep", 2)
  self.mItem_DeepUse = self:InitAttribute("Root/GrpDialog/GrpCenter/GrpSkillInfo/GrpNumInfo/GrpCd", 3)
  self.mItem_DeepUse = self:InitAttribute("Root/GrpDialog/GrpCenter/GrpSkillInfo/GrpNumInfo/GrpPoint", 4)
  self.mText_Desc = self.ui.mText_Describe
  self.mTrans_LevelInfo = self.ui.mTrans_GrpOn
  self.mTrans_LockUpgrade = UIUtils.GetTempBtn(self.ui.mTrans_BtnGoTo)
  self.mTrans_MaxLevel = self.ui.mTrans_GrpUnLocked
  self.mTrans_SkillInfoList = self.ui.mTrans_GrpLevelDescription
  self.mGridLayouts = {}
  table.insert(self.mGridLayouts, getchildcomponent(self.mUIRoot, "Root/GrpDialog/GrpCenter/GrpSkillDescription/GrpSkillDiagram/Img_SkillDiagram_9x9", typeof(CS.GridLayout)))
  table.insert(self.mGridLayouts, getchildcomponent(self.mUIRoot, "Root/GrpDialog/GrpCenter/GrpSkillDescription/GrpSkillDiagram/Img_SkillDiagram_17x17", typeof(CS.GridLayout)))
  table.insert(self.mGridLayouts, getchildcomponent(self.mUIRoot, "Root/GrpDialog/GrpCenter/GrpSkillDescription/GrpSkillDiagram/Img_SkillDiagram_21x21", typeof(CS.GridLayout)))
  UIUtils.GetButtonListener(self.mBtn_LevelInfoClose.gameObject).onClick = function()
    self:OnCloseLevelInfo()
  end
  UIUtils.GetButtonListener(self.mBtn_Goto.gameObject).onClick = function()
    self:OnClickGoto()
  end
  UIUtils.GetButtonListener(self.mBtn_LevelInfo.gameObject).onClick = function()
    self:OnClickLevelInfo()
  end
  UIUtils.GetButtonListener(self.mBtn_Close.gameObject).onClick = function()
    self:OnCloseContent()
  end
  UIUtils.GetButtonListener(self.mBtn_BgClose.gameObject).onClick = function()
    self:OnCloseContent()
  end
  UIUtils.GetButtonListener(self.mBtn_Left.gameObject).onClick = function()
    self:OnClickSkillChange(-1)
  end
  UIUtils.GetButtonListener(self.mBtn_Right.gameObject).onClick = function()
    self:OnClickSkillChange(1)
  end
  UIUtils.GetButtonListener(self.mBtn_LevelInfoBgClose.gameObject).onClick = function()
    self:OnCloseLevelInfo()
  end
end
function UISkillContent:InitAttribute(path, index)
  local obj = self:GetRectTransform(path)
  if obj then
    local attr = {}
    attr.obj = obj
    attr.index = index
    attr.attrName = FacilityBarrackGlobal.ShowSKillAttr[index]
    attr.txtName = UIUtils.GetText(obj, "Text_Name")
    attr.txtNum = UIUtils.GetText(obj, "Text_Num")
    attr.txtName.text = TableData.GetHintById(102061 + index)
    table.insert(self.attrList, attr)
  end
end
function UISkillContent:SetData(data, parent)
  UISkillContent.super.SetData(self, data, parent)
  self:UpdateContent()
  self:OnEnable(true)
end
function UISkillContent:UpdateContent()
  self.curSkill = self:GetSkillDataByType(self.mData)
  self:UpdateSkillInfo()
  local gunCmdData = self.mParent.mData
  local skillList = gunCmdData:GetAllSameSkill(self.curSkill.data.id)
  setactive(self.mBtn_LevelInfo.gameObject, skillList.Count ~= 0)
end
function UISkillContent:UpdateSkillInfo()
  local skillData = self.curSkill
  if skillData then
    self.mImage_Icon.sprite = IconUtils.GetSkillIconByAttr(skillData.data.icon, skillData.data.icon_attr_type)
    self.mText_Level.text = skillData.data.level
    self.mText_Name.text = skillData.data.name.str
    self.mText_Desc.text = skillData.data.description.str
    self:UpdateAttribute()
    CS.SkillRangeUIHelper.SetSkillRange(self.mGridLayouts, 1, skillData.data)
    local isMaxLevel = self.mParent.mData:CheckIsMaxSkillLevel(skillData.data.id)
    setactive(self.mBtn_Goto.gameObject, not self.mParent.isGunLock and not isMaxLevel)
    setactive(self.mTrans_MaxLevel, not self.mParent.isGunLock and isMaxLevel)
    setactive(self.mTrans_LockUpgrade, false)
  end
end
function UISkillContent:UpdateAttribute()
  for i, attr in ipairs(self.attrList) do
    local num = self.curSkill.data[attr.attrName]
    if attr.attrName == "skill_points" then
      if num ~= "" then
        num = tonumber(string.split(num, ",")[1])
      else
        num = 0
      end
    end
    attr.txtNum.text = num
    setactive(attr.obj, 0 < num)
  end
end
function UISkillContent:OnUpgradeEffectEnd(targetObj)
  setactive(targetObj, false)
end
function UISkillContent:UpdateSkillUpConfirm()
  if self.curSkill then
    self.mConfirmView.mImage_ConfirmIcon.sprite = UIUtils.GetIconSprite("Icon/Skill", self.curSkill.data.icon)
    self.mConfirmView.mText_ConfirmName.text = self.curSkill.data.name.str
    if self.curSkill.data.level < self.curSkill.maxLevel then
      local nextLevel = self.curSkill.data.level + 1
      local nextSkillData = TableData.GetGroupSkill(self.curSkill.skillGroup.group_id, nextLevel)
      self.mConfirmView.mText_ConfirmDesc.text = nextSkillData.upgrade_description.str
      self.mConfirmView.mText_ConfirmCurLevel.text = self.curSkill.data.level
      self.mConfirmView.mText_ConfirmNextLevel.text = nextLevel
    end
    self:UpdateCostItem(self.curSkill.skillGroup)
  end
end
function UISkillContent:UpdateCostItem(skillGroup)
  if skillGroup then
    local itemList = skillGroup:GetItemConsumptionDict()
    local tempList = {}
    for id, num in pairs(itemList) do
      local item = {}
      item.id = id
      item.num = num
      table.insert(tempList, item)
    end
    table.sort(tempList, function(a, b)
      return a.id < b.id
    end)
    local itemIsEnough = false
    for i = 1, #tempList do
      if tempList[i].id == GlobalConfig.CoinId then
        local count = NetCmdItemData:GetItemCountById(tempList[i].id)
        self.mConfirmView.mImage_CoinIcon.sprite = IconUtils.GetItemIconSprite(tempList[i].id)
        local text = count >= tempList[i].num and FacilityBarrackGlobal.ItemCountRichText or FacilityBarrackGlobal.ItemCountNotEnoughText
        self.mConfirmView.mText_CoinCost.text = string_format(text, count, tempList[i].num)
        itemIsEnough = count >= tempList[i].num
      else
        if self.costItem == nil then
          self.costItem = UICommonItem.New()
          self.costItem:InitObj(self.mConfirmView.mTrans_CostItem)
        end
        self.costItem:SetItemData(tempList[i].id, tempList[i].num, true, true)
        itemIsEnough = self.costItem:IsItemEnough()
      end
    end
    self.isItemEnough = itemIsEnough
  end
end
function UISkillContent:OnClickLevelInfo()
  self:UpdateSkillListInfo()
  setactive(self.mTrans_LevelInfo, true)
end
function UISkillContent:OnCloseLevelInfo()
  setactive(self.mTrans_LevelInfo, false)
end
function UISkillContent:UpdateSkillListInfo()
  local gunCmdData = self.mParent.mData
  local skillList = gunCmdData:GetAllSameSkill(self.curSkill.data.id)
  local curSkillLevel = self.curSkill.data.level
  for i, skill in ipairs(self.skillDetailList) do
    skill:SetData(nil)
  end
  local tmpList = {}
  for i = 0, skillList.Count - 1 do
    local item
    if i + 1 <= #self.skillDetailList then
      item = self.skillDetailList[i + 1]
    else
      item = UISkillDetailItem.New()
      item:InitCtrl(self.mTrans_SkillInfoList)
      table.insert(self.skillDetailList, item)
    end
    local skillData = TableData.listBattleSkillDatas:GetDataById(skillList[i])
    if tmpList[skillList[i]] == nil and skillData.level ~= 1 then
      item:SetData(skillData, curSkillLevel)
      tmpList[skillList[i]] = skillData.level
    end
  end
end
function UISkillContent:GetSkillDataByType(id)
  for _, skill in ipairs(self.mParent.skillList) do
    if skill.type == id then
      return skill
    end
  end
  return nil
end
function UISkillContent:OnClickSkillChange(step)
  local curType = self.curSkill.type + step
  if curType < 1 then
    curType = 4
  elseif 4 < curType then
    curType = 1
  end
  self.mData = curType
  self.curSkill = self:GetSkillDataByType(curType)
  self:UpdateSkillInfo()
  self:UpdateContent()
end
function UISkillContent:OnCloseContent()
  self:OnEnableEffect(false)
  self:OnEnable(false)
end
function UISkillContent:OnClickGoto()
  self:OnCloseContent()
  self.mParent:ChangeTab(FacilityBarrackGlobal.PowerUpType.Upgrade)
end
function UISkillContent:OnEnableEffect(enable)
end
