require("UI.FacilityBarrackPanel.Item.UISkillDetailItem")
require("UI.FacilityBarrackPanel.Item.ComChrUAVSkillInfoItem")
require("UI.FacilityBarrackPanel.FacilityBarrackGlobal")
UIChrSkillInfoDialog = class("UIChrSkillInfoDialog", UIBasePanel)
UIChrSkillInfoDialog.__index = UIChrSkillInfoDialog
local self = UIChrSkillInfoDialog
function UIChrSkillInfoDialog:ctor(obj)
  UIChrSkillInfoDialog.super.ctor(self, obj)
  obj.Type = UIBasePanelType.Dialog
end
function UIChrSkillInfoDialog:OnInit(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.attrList = {}
  self.skillDetailList = {}
  self.skillData = data.skillData
  self.skillDisplayData = TableData.listBattleSkillDisplayDatas:GetDataById(self.skillData.Id)
  self.gunCmdData = data.gunCmdData
  self.isGunLock = data.isGunLock
  self.pos = data.pos
  self.showBottomBtn = data.showBottomBtn
  self.showTag = data.showTag
  self.ispvpType = data.ispvpType or false
  self.isGachaPreview = data.isGachaPreview or false
  self.curTabItem = nil
  self.curTabIndex = 0
  self.openFromTypeId = data.openFromTypeId
  self.skillInfoItems = {}
  self:__InitCtrl()
  self:InitTabItem()
end
function UIChrSkillInfoDialog:__InitCtrl()
  self:InitAttribute()
  self.mGridLayouts = {}
  table.insert(self.mGridLayouts, getchildcomponent(self.mUIRoot, "Root/GrpDialog/GrpCenter/GrpSkillDescription/GrpRight/GrpSkillDiagram/Img_SkillDiagram_9x9", typeof(CS.GridLayout)))
  table.insert(self.mGridLayouts, getchildcomponent(self.mUIRoot, "Root/GrpDialog/GrpCenter/GrpSkillDescription/GrpRight/GrpSkillDiagram/Img_SkillDiagram_17x17", typeof(CS.GridLayout)))
  table.insert(self.mGridLayouts, getchildcomponent(self.mUIRoot, "Root/GrpDialog/GrpCenter/GrpSkillDescription/GrpRight/GrpSkillDiagram/Img_SkillDiagram_21x21", typeof(CS.GridLayout)))
  setactive(self.ui.mBtn_BtnLeft.gameObject, self.pos ~= nil)
  setactive(self.ui.mBtn_BtnRight.gameObject, self.pos ~= nil)
  UIUtils.GetButtonListener(self.ui.mBtn_BtnGoTo.gameObject).onClick = function()
    self:OnClickGoto()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    self:OnCloseContent()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:OnCloseContent()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnLeft.gameObject).onClick = function()
    self:OnClickSkillChange(-1)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnRight.gameObject).onClick = function()
    self:OnClickSkillChange(1)
  end
end
function UIChrSkillInfoDialog:InitAttribute()
  local tmpAttributeTrans = self.ui.mTrans_SkillAttribute.transform
  setactive(tmpAttributeTrans:GetChild(1).gameObject, false)
  for i = 0, tmpAttributeTrans.childCount - 1 do
    local obj = tmpAttributeTrans:GetChild(i).gameObject
    local index = i + 1
    if obj then
      local attr = {}
      attr.obj = obj
      attr.index = index
      attr.attrName = FacilityBarrackGlobal.ShowSKillAttr[index]
      attr.txtName = UIUtils.GetText(obj, "Text_Name")
      attr.txtNum = UIUtils.GetText(obj, "Text_Num")
      table.insert(self.attrList, attr)
    end
  end
end
function UIChrSkillInfoDialog:UpdateSkillInfo()
  setactive(self.ui.mTextFit_Talking.gameObject, true)
  setactive(self.ui.mScrollListChild_LevelList.gameObject, false)
  setactive(self.ui.mTextFit_Steay.gameObject, true)
  self.ui.mImg_SkillIcon.sprite = IconUtils.GetSkillIconByAttr(self.skillData.icon, self.skillData.icon_attr_type)
  local defaultLevel = self.skillData.level == 0 and 1 or self.skillData.level
  self.ui.mText_SkillLevel.text = defaultLevel
  if self.ispvpType then
    self.ui.mText_SkillName.text = self.skillData.name.str
  else
    local skillNameTxt = string_format(TableData.GetHintById(160040), self.skillData.name.str, defaultLevel)
    self.ui.mText_SkillName.text = skillNameTxt
  end
  local tmpDesc = CS.GF2.Battle.SkillUtils.GetSkillDes(self.skillData.id, false, self.gunCmdData.gunGradeId, self.gunCmdData.TalentSkillIds)
  tmpDesc = self.skillData.description.str .. "\n"
  local tmpDescTips = CS.GF2.Battle.SkillUtils.GetSkillDesTips(self.skillData.id, self.gunCmdData.gunGradeId, self.gunCmdData.TalentSkillIds)
  tmpDesc = tmpDesc .. tmpDescTips
  self.ui.mTextFit_Describe.text = tmpDesc
  self.ui.mTextFit_Talking.text = self.skillDisplayData.DescriptionLiterary.str
  self:UpdateAttribute()
  CS.SkillRangeUIHelper.SetSkillRange(self.mGridLayouts, 1, self.skillData, true)
  setactive(self.ui.mTrans_AttackType.gameObject, true)
  if self.skillData.SkillType == 1 then
  end
  if not self.ispvpType then
    if self.gunCmdData.NormalAttackSkill.Id == self.skillData.Id then
    end
    local isMaxLevel = self.gunCmdData:CheckIsMaxSkillLevel(self.skillData.id)
    if not self.showBottomBtn then
      setactive(self.ui.mBtn_BtnGoTo.gameObject, false)
      setactive(self.ui.mTrans_UnLocked, false)
      setactive(self.ui.mTrans_Preview.gameObject, true)
    else
      setactive(self.ui.mBtn_BtnGoTo.gameObject, not self.isGunLock and not isMaxLevel)
      setactive(self.ui.mTrans_UnLocked, not self.isGunLock and isMaxLevel)
      setactive(self.ui.mTrans_Preview.gameObject, false)
    end
  else
    setactive(self.ui.mBtn_BtnGoTo.gameObject, false)
    setactive(self.ui.mTrans_UnLocked, true)
    setactive(self.ui.mTrans_Preview.gameObject, false)
  end
  self:ShowTabBtn(1)
  local elementTag = CS.GF2.Battle.SkillUtils.GetDisplaySkillElement(self.skillData.id)
  if elementTag < 0 then
    elementTag = CS.GF2.Battle.SkillUtils.GetSkillElement(self.skillData.id)
  end
  setactive(self.ui.mImg_Element, 0 < elementTag)
  if 0 < elementTag then
    local elementData = TableData.listLanguageElementDatas:GetDataById(elementTag)
    self.ui.mImg_Element.sprite = IconUtils.GetElementIcon(elementData.icon)
  end
  self.ui.mText_Type.text = self.skillDisplayData.skill_tag.str
  self:CheckSkillDataResult()
  CS.GF2.Battle.SkillUtils.ShowSkillRangeText(self.ui.mText_Range2, self.ui.mText_RangeWide, self.skillData)
end
function UIChrSkillInfoDialog:CheckSkillDataResult()
  if self.gunCmdData == nil then
    setactive(self.ui.mTextFit_Steay.gameObject, false)
    return
  end
  local str = CS.GF2.Battle.SkillUtils.GetSkillSuppress(self.skillData, self.gunCmdData.stc_id)
  if str == nil or str == "" then
    setactive(self.ui.mTextFit_Steay.gameObject, false)
  else
    setactive(self.ui.mTextFit_Steay.gameObject, true)
    self.ui.mTextFit_Steay.text = TableData.GetHintById(80344) .. str
  end
end
function UIChrSkillInfoDialog:UpdateAttribute()
  for i, attr in ipairs(self.attrList) do
    local num = self.skillData[attr.attrName]
    if attr.attrName == "skill_points" then
      if num ~= "" then
        num = tonumber(string.split(num, ",")[1])
      else
        num = 0
      end
    end
    if num == nil then
      num = 0
    end
    attr.txtNum.text = num
    setactive(attr.obj, 0 < num)
  end
end
function UIChrSkillInfoDialog:UpdateSkillListInfo()
  setactive(self.ui.mTextFit_Talking.gameObject, false)
  setactive(self.ui.mScrollListChild_LevelList.gameObject, true)
  setactive(self.ui.mTextFit_Steay.gameObject, false)
  local gunCmdData = self.gunCmdData
  local skillList = gunCmdData:GetAllSameSkill(self.skillData.id)
  local curSkillLevel = self.skillData.level == 0 and 1 or self.skillData.level
  for i, skill in ipairs(self.skillDetailList) do
    skill:SetData(nil)
  end
  local isMaxLevel = self.gunCmdData:CheckIsMaxSkillLevel(self.skillData.id)
  if isMaxLevel and self.skillData.Level == 1 then
    self.ui.mTextFit_Describe.text = TableData.GetHintById(102249)
  else
    self.ui.mTextFit_Describe.text = self.skillDisplayData.DescriptionBrief.str
  end
  local tmpList = {}
  for i = 0, skillList.Count - 1 do
    local item
    if i + 1 <= #self.skillDetailList then
      item = self.skillDetailList[i + 1]
    else
      item = UISkillDetailItem.New()
      item:InitCtrl(self.ui.mScrollListChild_LevelList)
      table.insert(self.skillDetailList, item)
    end
    local skillData = TableData.listBattleSkillDatas:GetDataById(skillList[i])
    if tmpList[skillList[i]] == nil and skillData.level ~= 1 then
      item:SetData(skillData, curSkillLevel, nil, self.showBottomBtn)
      tmpList[skillList[i]] = skillData.level
    end
  end
  self:ShowTabBtn(2)
end
function UIChrSkillInfoDialog:OnClickSkillChange(pos)
  self.pos = self.pos + pos
  if self.pos < 1 then
    self.pos = 5
  elseif self.pos > 5 then
    self.pos = 1
  end
  self.skillData = FacilityBarrackGlobal.CurBattleSkillDataList[self.pos].mBattleSkillData
  self.skillDisplayData = TableData.listBattleSkillDisplayDatas:GetDataById(self.skillData.Id)
  self:UpdateSkillInfo()
  self:OnClickTabBtn(self.curTabIndex)
end
function UIChrSkillInfoDialog:OnCloseContent()
  UIManager.CloseUI(UIDef.UIChrSkillInfoDialog)
end
function UIChrSkillInfoDialog:OnClickGoto()
  FacilityBarrackGlobal.SetTargetContentType(FacilityBarrackGlobal.ContentType.UIChrStageUpPanel)
  UIManager.CloseUI(UIDef.UIChrSkillInfoDialog)
  if self.openFromTypeId ~= nil and self.openFromTypeId == UIDef.UIChrScreenPanel then
    UIManager.CloseUI(UIDef.UIChrScreenPanel)
  end
end
function UIChrSkillInfoDialog:InitTabItem()
  for i = 1, 2 do
    do
      local item
      if i <= #self.skillInfoItems then
        item = self.skillInfoItems[i]
      else
        item = ComChrUAVSkillInfoItem.New()
      end
      item:InitCtrl(self.ui.mScrollListChild_InfoSelBtn)
      UIUtils.GetButtonListener(item.ui.mBtn_ComChrUAVSkillInfoItem.gameObject).onClick = function()
        self:OnClickTabBtn(i)
      end
      table.insert(self.skillInfoItems, item)
      if self.showTag ~= nil and self.showTag == i then
        self:OnClickTabBtn(i)
      elseif i == 1 then
        self:OnClickTabBtn(i)
      end
    end
  end
  self.skillInfoItems[1]:SetItemName(TableData.GetHintById(102066))
  self.skillInfoItems[2]:SetItemName(TableData.GetHintById(102248))
  setactive(self.skillInfoItems[2].ui.mBtn_ComChrUAVSkillInfoItem.gameObject, not self.ispvpType and not self.isGachaPreview)
end
function UIChrSkillInfoDialog:OnClickTabBtn(index)
  if index == 1 then
    self:UpdateSkillInfo()
  elseif index == 2 and not self.ispvpType then
    self:UpdateSkillListInfo()
  end
  self.curTabIndex = index
end
function UIChrSkillInfoDialog:ShowTabBtn(index)
  if self.curTabItem ~= nil then
    self.curTabItem:SetSelected(false)
  end
  self.curTabItem = self.skillInfoItems[index]
  self.curTabItem:SetSelected(true)
end
function UIChrSkillInfoDialog:OnClose()
  self:ReleaseTable(self.skillInfoItems)
  self:ReleaseTable(self.skillDetailList)
end
