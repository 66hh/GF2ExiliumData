require("UI.UIBaseCtrl")
UIBarrackWeaponInfoItem = class("UIBarrackWeaponInfoItem", UIBaseCtrl)
UIBarrackWeaponInfoItem.__index = UIBarrackWeaponInfoItem
function UIBarrackWeaponInfoItem:ctor()
  UIBarrackWeaponInfoItem.super.ctor(self)
  self.data = nil
  self.lockCallback = nil
  self.skillList = {}
  self.attributeList = {}
  self.stageItem = nil
  self.suitList = {}
  self.lockItem = nil
  self.ui = {}
end
function UIBarrackWeaponInfoItem:__InitCtrl()
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.skillList = UIWeaponSkillItem.New()
  local template = self.ui.mScrollItem_WeaponSkill.childItem
  self.skillList:InitObj(instantiate(template, self.ui.mScrollItem_WeaponSkill.transform))
  self:InitStageItem()
  self:InitLockItem()
end
function UIBarrackWeaponInfoItem:InitStageItem()
  if self.stageItem == nil then
    local parent = self.ui.mTrans_Stage
    self.stageItem = UICommonStageItem.New(GlobalConfig.MaxStar)
    self.stageItem:InitCtrl(parent, true)
  end
end
function UIBarrackWeaponInfoItem:InitLockItem()
  self.lockItem = UICommonLockItem.New()
  self.lockItem:InitCtrl(self.ui.mTrans_Lock)
  UIUtils.GetButtonListener(self.lockItem.ui.btnLock.gameObject).onClick = function()
    self:OnClickLock()
  end
end
function UIBarrackWeaponInfoItem:OnClickLock()
  NetCmdWeaponData:SendGunWeaponLockUnlock(self.data.id, function()
    if self.lockCallback ~= nil then
      self.lockCallback(self.data.id, self.data.IsLocked)
    end
    self:UpdateLockStatue()
  end)
end
function UIBarrackWeaponInfoItem:UpdateLockStatue()
  setactive(self.lockItem.ui.transUnlock, not self.data.IsLocked)
  setactive(self.lockItem.ui.transLock, self.data.IsLocked)
end
function UIBarrackWeaponInfoItem:InitCtrl(root, lockCallback)
  self:SetRoot(root)
  self:__InitCtrl()
  self.lockCallback = lockCallback
end
function UIBarrackWeaponInfoItem:SetData(data)
  if data == nil then
    return
  end
  self.data = data
  local typeData = TableData.listGunWeaponTypeDatas:GetDataById(data.Type)
  self.ui.mText_Name.text = data.Name
  self.ui.mText_Type.text = typeData.name.str
  self.ui.mText_Level.text = GlobalConfig.SetLvTextWithMax(data.Level, data.DefaultMaxLevel)
  self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(data.Rank)
  self.ui.mText_Power.text = self.data:GetPower()
  self:UpdateStar(data.BreakTimes, data.MaxBreakTime)
  self:UpdateAttribute(data)
  self:UpdateLockStatue()
  self:UpdateSkill(self.skillList, data.Skill, UIWeaponGlobal.SkillType.NormalSkill)
  self:UpdateSuitInfo()
end
function UIBarrackWeaponInfoItem:UpdateSkill(skill, data, type)
  setactive(skill.mUIRoot, data ~= nil)
  if data then
    skill:SetDataBySkillData(data, true)
    if type == UIWeaponGlobal.SkillType.BuffSkill then
      local value = 0.5
      if self.data.slotList.Length == self.data.PartsCount then
        value = 1
      end
      skill:SetNum(self.data.PartsCount, self.data.slotList.Length)
      UIUtils.SetCanvasGroupValue(skill.mUIRoot.gameObject, value)
    else
      skill:SetLevel(data.level)
    end
  end
  setactive(self.ui.mTrans_Skill, data ~= nil)
end
function UIBarrackWeaponInfoItem:UpdateSuitInfo()
  for i, item in ipairs(self.suitList) do
    item:SetData(nil)
  end
  local list = self.data:GetSuitList()
  for i = 0, list.Count - 1 do
    local item = self.suitList[i + 1]
    if item == nil then
      item = UIWeaponModSuitItem.New()
      item:InitCtrl(self.ui.mTrans_Skill, false, true)
      table.insert(self.suitList, item)
    end
    local count = self.data:GetSuitCountById(list[i])
    item:SetData(list[i], count, true)
  end
end
function UIBarrackWeaponInfoItem:UpdateStar(star, maxStar)
  self.stageItem:ResetMaxNum(maxStar)
  self.stageItem:SetData(star)
end
function UIBarrackWeaponInfoItem:UpdateAttribute(data)
  local attrList = {}
  local expandList = TableData.GetPropertyExpandList()
  for i = 0, expandList.Count - 1 do
    local lanData = expandList[i]
    if lanData.type == 1 then
      local value = data:GetPropertyByLevelAndSysName(lanData.sys_name, data.Level, data.BreakTimes)
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
  for _, item in ipairs(self.attributeList) do
    item:SetData(nil)
  end
  local template = self.ui.mScrollItem_Attr.childItem
  for i = 1, #attrList do
    local item
    if i <= #self.attributeList then
      item = self.attributeList[i]
    else
      item = UICommonPropertyItem.New()
      local go = instantiate(template, self.ui.mScrollItem_Attr.transform)
      item:InitObj(go)
      table.insert(self.attributeList, item)
    end
    item:SetData(attrList[i].propData, attrList[i].value, true, false, false, false)
  end
end
function UIBarrackWeaponInfoItem:SetWeaponInfoVisible(visible)
  if visible then
    if not self.data then
      setactive(self.ui.mText_WeaponInfo, false)
      return
    end
    self.ui.mText_WeaponInfo.text = self.data.StcData.description.str
  end
  setactive(self.ui.mText_WeaponInfo, visible)
end
function UIBarrackWeaponInfoItem:SetWeaponInfoRootActive(enable)
  setactive(self.mUIRoot, enable)
end
function UIBarrackWeaponInfoItem:OnClose()
  if self.skillList then
    self.skillList:OnRelease(true)
  end
  if self.lockItem then
    self.lockItem:OnRelease(true)
  end
  self:ReleaseCtrlTable(self.suitList, true)
  self:ReleaseCtrlTable(self.attributeList, true)
end
