require("UI.UIBasePanel")
require("UI.WeaponPanel.UIWeaponPanelView")
UIWeaponEvolutionContent = class("UIWeaponEvolutionContent", UIBasePanel)
UIWeaponEvolutionContent.__index = UIWeaponEvolutionContent
function UIWeaponEvolutionContent:ctor(data, weaponPanel)
  self.mView = nil
  self.weaponListContent = nil
  self.mData = data
  self.weaponPanel = weaponPanel
  self.propertyList = {}
  self.isCompareMode = false
  self.curEvolution = 0
end
function UIWeaponEvolutionContent:InitCtrl(root)
  self.mView = UIWeaponEvolutionContentView.New()
  self.mView:InitCtrl(root)
  self.mView.mToggle_DetailCompare.onValueChanged:AddListener(function(isOn)
    self:OnClickCompare()
  end)
  UIUtils.GetButtonListener(self.mView.mBtn_LevelUp.gameObject).onClick = function()
    self:OnClickLevelUp()
  end
end
function UIWeaponEvolutionContent:OnClose()
  self:ReleaseCtrlTable(self.propertyList)
end
function UIWeaponEvolutionContent:OnRelease()
  ComPropsDetailsHelper:Close()
  self:ReleaseTimers()
end
function UIWeaponEvolutionContent:UpdateEvolutionWeapon(weaponId)
  self.curEvolution = weaponId
  local data = TableData.listGunWeaponDatas:GetDataById(weaponId)
  local typeData = TableData.listGunWeaponTypeDatas:GetDataById(data.Type)
  local skillData
  if data.skill ~= 0 then
    skillData = TableData.GetSkillData(data.skill)
  end
  self.mView.mText_Name.text = data.Name.str
  self.mView.mText_Type.text = typeData.name.str
  self.mView.mText_Level.text = GlobalConfig.SetLvTextWithMax(data.default_maxlv, data.default_maxlv)
  self.mView.mImg_Line.color = TableData.GetGlobalGun_Quality_Color2(data.rank)
  self:UpdatePropertyList(weaponId, data.default_maxlv, 0)
  self:UpdateSkill(skillData)
  self:UpdateStar(0, data.max_break)
  UIWeaponGlobal:UpdateWeaponModelByConfig(NetCmdWeaponData:GetWeaponByStcId(self.curEvolution))
end
function UIWeaponEvolutionContent:UpdateStar(star, maxStar)
  self.mView.stageItem:ResetMaxNum(maxStar)
  self.mView.stageItem:SetData(star)
end
function UIWeaponEvolutionContent:UpdateSkill(skill1)
  local skill = self.mView.skillItem
  if skill1 then
    skill.data = skill1
    skill.txtName.text = skill1.name.str
    skill.txtLv.text = GlobalConfig.SetLvText(skill1.level)
    skill.txtDesc.text = skill1.description.str
    setactive(skill.obj, true)
  else
    skill.data = nil
    setactive(skill.obj, false)
  end
end
function UIWeaponEvolutionContent:UpdatePropertyList(weaponId, level, breakTime)
  local attrList = {}
  local expandList = TableData.GetPropertyExpandList()
  for i = 0, expandList.Count - 1 do
    local lanData = expandList[i]
    if lanData.type == 1 then
      local value = NetCmdWeaponData:GetPropertyByLevelAndSysName(weaponId, lanData.sys_name, level, breakTime)
      if 0 < value then
        local attr = {}
        attr.propData = lanData
        attr.value = value
        table.insert(attrList, attr)
      end
    end
  end
  table.sort(attrList, function(a, b)
    return a.propData.order < b.propData.order
  end)
  for _, item in ipairs(self.propertyList) do
    item:SetData(nil)
  end
  for i = 1, #attrList do
    local item
    if i <= #self.propertyList then
      item = self.propertyList[i]
    else
      item = UICommonPropertyItem.New()
      item:InitCtrl(self.mView.mTrans_PropList)
      table.insert(self.propertyList, item)
    end
    item:SetData(attrList[i].propData, attrList[i].value, true, false, false, false)
    item:SetTextColor(attrList[i].propData.statue == 2 and ColorUtils.OrangeColor or ColorUtils.BlackColor)
  end
end
function UIWeaponEvolutionContent:OnClickLevelUp()
  if self.mData.IsLocked then
    UIUtils.PopupHintMessage(40049)
    return
  end
  UIManager.OpenUIByParam(UIDef.UIWeaponEvolutionPanel, {
    self.mData.id,
    self.curEvolution
  })
end
function UIWeaponEvolutionContent:UpdateItemBrief(id, type)
  local lockCallback = function(id, isLock)
    self:UpdateWeaponLock(id, isLock)
  end
  self.pointer.isInSelf = true
  if type == UIWeaponGlobal.MaterialType.Item then
    ComPropsDetailsHelper:InitItemData(self.mView.mTrans_CompareDetail.transform, id, lockCallback)
  elseif type == UIWeaponGlobal.MaterialType.Weapon then
    ComPropsDetailsHelper:InitWeaponData(self.mView.mTrans_CompareDetail.transform, id, lockCallback, false)
  end
end
function UIWeaponEvolutionContent:CloseItemBrief()
  if self.itemBrief ~= nil then
    ComPropsDetailsHelper:Close()
  end
end
function UIWeaponEvolutionContent:OnClickCompare(isOn)
  self.isCompareMode = not self.isCompareMode
  setactive(self.mView.mTrans_CompareDetail, self.isCompareMode)
  if self.isCompareMode then
    self:UpdateCompareDetail()
    ComPropsDetailsHelper:InitWeaponData(self.mView.mTrans_CompareDetail.transform, self.mData.id)
  else
    ComPropsDetailsHelper:Close()
  end
end
function UIWeaponEvolutionContent:UpdateCompareDetail()
  if self.mData then
    ComPropsDetailsHelper:InitWeaponData(self.mView.mTrans_CompareDetail.transform, self.mData.id)
  end
end
