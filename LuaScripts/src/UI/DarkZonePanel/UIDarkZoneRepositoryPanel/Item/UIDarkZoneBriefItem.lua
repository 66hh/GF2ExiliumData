require("UI.UIBaseCtrl")
UIDarkZoneBriefItem = class("UIDarkZoneBriefItem", UIBaseCtrl)
UIDarkZoneBriefItem.__index = UIDarkZoneBriefItem
UIDarkZoneBriefItem.ShowType = {
  RepoEquip = 1,
  RepoItem = 2,
  EquipEquipment = 3,
  EquipReplacement = 4,
  EquipUninstall = 5
}
function UIDarkZoneBriefItem:ctor()
  self.gunId = 0
  self.lockCallback = nil
  self.lvUpCallback = nil
  self.changeCallback = nil
  self.curContent = nil
end
function UIDarkZoneBriefItem:__InitCtrl()
end
function UIDarkZoneBriefItem:InitEquipContent(obj)
  local content = {}
  content.obj = obj
  content.attributeList = {}
  content.skillList = {}
  local LuaUIBindScript = self.ui.mTrans_EquipContent:GetComponent(UIBaseCtrl.LuaBindUi)
  local vars = LuaUIBindScript.BindingNameList
  for i = 0, vars.Count - 1 do
    content[vars[i]] = LuaUIBindScript:GetBindingComponent(vars[i])
  end
  content.itemContent = UICommonItem.New()
  content.itemContent:InitObj(content.mBtn_Select)
  content.itemContent:EnableButton(false)
  UIUtils.GetButtonListener(self.ui.mBtn_Exist.gameObject).onClick = function()
    if self.data.IsItem and self.data.ItemCount > 1 then
      UIManager.OpenUIByParam(UIDef.UIDarkZoneRepositoryExistDialog, {
        self.data,
        false
      })
    else
      DarkZoneNetRepoCmdData:StorageMove(false, self.data, function()
        self:SetData(nil)
      end)
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Equiped.gameObject).onClick = function()
    DarkZoneNetRepoCmdData:SendCS_DarkZoneEquip(self.data, function()
      CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(903104))
      self:SetData(nil)
    end)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Take.gameObject).onClick = function()
    if self.data.IsItem and self.data.ItemCount > 1 then
      UIManager.OpenUIByParam(UIDef.UIDarkZoneRepositoryExistDialog, {
        self.data,
        true
      })
    else
      DarkZoneNetRepoCmdData:StorageMove(true, self.data, function()
        self:SetData(nil)
      end)
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Uninstall.gameObject).onClick = function()
    DarkZoneNetRepoCmdData:SendCS_DarkZoneTake(self.data, function()
      CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(903106))
      self:SetData(nil)
    end)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Replace.gameObject).onClick = function()
    DarkZoneNetRepoCmdData:SendCS_DarkZoneEquip(self.data, function()
      CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(903105))
      self:SetData(nil)
    end)
  end
  return content
end
function UIDarkZoneBriefItem:InitItemContent(obj)
  local content = {}
  content.obj = obj
  local LuaUIBindScript = self.ui.mTrans_ItemContent:GetComponent(UIBaseCtrl.LuaBindUi)
  local vars = LuaUIBindScript.BindingNameList
  for i = 0, vars.Count - 1 do
    content[vars[i]] = LuaUIBindScript:GetBindingComponent(vars[i])
  end
  content.itemContent = UICommonItem.New()
  content.itemContent:InitCtrl(content.mTrans_Item)
  content.itemContent:EnableButton(false)
  return content
end
function UIDarkZoneBriefItem:InitUpgrade(obj)
  if obj then
    local item = {}
    item.obj = obj
    item.transOn = UIUtils.GetRectTransform(obj, "Trans_On")
    item.transOff = UIUtils.GetRectTransform(obj, "Trans_Off")
    return item
  end
end
function UIDarkZoneBriefItem:InitSkill(obj)
  if obj then
    local skill = {}
    skill.obj = obj
    skill.imageIcon = UIUtils.GetImage(obj, "GrpNameInfo/Trans_GrpIcon/Img_Icon")
    skill.txtName = UIUtils.GetText(obj, "GrpNameInfo/GrpTextName/Text_SkillName")
    skill.txtDesc = UIUtils.GetText(obj, "Text_Describe")
    skill.txtLevel = UIUtils.GetText(obj, "GrpNameInfo/GrpTextName/Trans_Text_Lv")
    setactive(skill.txtLevel.gameObject, true)
    return skill
  end
end
function UIDarkZoneBriefItem:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("Character/ChrWeaponEquipInfoItemV2.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, true)
  end
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(obj.transform, self.ui)
  self:__InitCtrl()
  self.mItem_Equip = self:InitEquipContent(self.ui.mTrans_EquipContent)
  self.mItem_Item = self:InitItemContent(self.ui.mTrans_ItemContent)
  setactive(self.ui.mBtn_WeaponAccess, true)
  setactive(self.ui.mBtn_ConsumeAccess, true)
  setactive(self.ui.mBtn_EquipAccess, true)
  self.ui.mBtn_WeaponAccess.onClick:AddListener(function()
    self:ShowItemDetail()
  end)
  self.ui.mBtn_ConsumeAccess.onClick:AddListener(function()
    self:ShowItemDetail()
  end)
  self.ui.mBtn_EquipAccess.onClick:AddListener(function()
    self:ShowItemDetail()
  end)
end
function UIDarkZoneBriefItem:SetChangeCallback(cb)
  self.changeCallback = cb
end
function UIDarkZoneBriefItem:SetLevelUpCallback(cb)
  self.lvUpCallback = cb
end
function UIDarkZoneBriefItem:SetData(type, data)
  if self.data == data and self.type == UIDarkZoneBriefItem.ShowType.RepoItem then
    setactive(self.mUIRoot, true)
    return
  end
  if type then
    self.type = type
    if self.type == UIDarkZoneBriefItem.ShowType.RepoEquip or self.type == UIDarkZoneBriefItem.ShowType.EquipEquipment or self.type == UIDarkZoneBriefItem.ShowType.EquipReplacement or self.type == UIDarkZoneBriefItem.ShowType.EquipUninstall then
      self.curContent = self.mItem_Equip
      self.data = data
      self:UpdateEquip()
    elseif self.type == UIDarkZoneBriefItem.ShowType.RepoItem then
      self.curContent = self.mItem_Item
      self.data = data
      self:UpdateItemContent()
    end
    setactive(self.ui.mTrans_EquipContent.gameObject, self.type == UIDarkZoneBriefItem.ShowType.RepoEquip or self.type == UIDarkZoneBriefItem.ShowType.EquipEquipment or self.type == UIDarkZoneBriefItem.ShowType.EquipReplacement or self.type == UIDarkZoneBriefItem.ShowType.EquipUninstall)
    setactive(self.ui.mTrans_WeaponContent.gameObject, false)
    setactive(self.ui.mTrans_WeaponPartContent.gameObject, false)
    setactive(self.ui.mTrans_ItemContent.gameObject, self.type == UIDarkZoneBriefItem.ShowType.RepoItem)
    setactive(self.ui.mTrans_BtnExist.gameObject, self.data.InBag and (self.type == UIDarkZoneBriefItem.ShowType.RepoEquip or self.type == UIDarkZoneBriefItem.ShowType.RepoItem))
    setactive(self.ui.mTrans_BtnTake.gameObject, self.data.InRepo and (self.type == UIDarkZoneBriefItem.ShowType.RepoEquip or self.type == UIDarkZoneBriefItem.ShowType.RepoItem))
    setactive(self.ui.mTrans_BtnEquip.gameObject, self.type == UIDarkZoneBriefItem.ShowType.EquipEquipment and not data.Equipped)
    setactive(self.ui.mTrans_BtnReplace.gameObject, self.type == UIDarkZoneBriefItem.ShowType.EquipReplacement)
    setactive(self.ui.mTrans_BtnUninstall.gameObject, self.type == UIDarkZoneBriefItem.ShowType.EquipUninstall)
    setactive(self.ui.mTran_Equip, data.Equipped and self.type == UIDarkZoneBriefItem.ShowType.EquipEquipment)
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UIDarkZoneBriefItem:SetGunId(gunId)
  self.gunId = gunId
end
function UIDarkZoneBriefItem:UpdateEquip()
  if self.data then
    local equipData = self.data.ItemData
    self.mItem_Equip.itemContent:SetDarkZoneEquipData(equipData.id)
    self.mItem_Equip.mText_Name.text = equipData.name.str
    self.mItem_Equip.mText_Class.text = TableData.GetHintById(903031)
    self:UpdateEquipAttribute(self.data)
    self:UpdateEquipSkill()
  end
end
function UIDarkZoneBriefItem:UpdateEquipSkill()
  if self.data.EquipData.battle_skill_id == 0 then
    if self.skillItem then
      setactive(self.skillItem.mUIRoot, false)
    end
    return
  end
  local skillData = TableData.listBattleSkillDatas:GetDataById(self.data.EquipData.battle_skill_id)
  if self.skillItem == nil then
    self.skillItem = UIDarkZoneEquipSkillItem.New()
    self.skillItem:InitCtrl(self.mItem_Equip.mTrans_AttributeList)
  end
  setactive(self.skillItem.mUIRoot, true)
  self.skillItem:SetData(skillData)
end
function UIDarkZoneBriefItem:UpdateEquipAttribute(data)
  local attrList = {}
  if data.MainAffix then
    local tableData = TableData.listDarkzoneEquipAffixEffectDatas:GetDataById(data.MainAffix.Id)
    local propData = TableData.GetPropertyDataByName(tableData.effect, 0)
    self.mItem_Equip.mText_MainAttrName.text = propData.ShowName.str
    if tableData.buff_base_type == 2 then
      self.mItem_Equip.mText_MainAttrValue.text = data.MainAffix.Value / 10 .. "%"
    else
      self.mItem_Equip.mText_MainAttrValue.text = data.MainAffix.Value
    end
  end
  if data.SubAffix then
    for i = 0, data.SubAffix.Count - 1 do
      table.insert(attrList, data.SubAffix[i])
    end
  end
  if attrList then
    local item
    for _, item in ipairs(self.mItem_Equip.attributeList) do
      item:SetData(nil)
    end
    for i = 1, #attrList do
      local prop = attrList[i]
      local tableData = TableData.listDarkzoneEquipAffixEffectDatas:GetDataById(prop.Id)
      local propData = TableData.GetPropertyDataByName(tableData.effect, 0)
      if i <= #self.mItem_Equip.attributeList then
        item = self.mItem_Equip.attributeList[i]
      else
        item = UICommonPropertyItem.New()
        item:InitCtrl(self.mItem_Equip.mTrans_AttributeList)
        table.insert(self.mItem_Equip.attributeList, item)
      end
      item:SetData(propData, prop.Value, false, false, i % 2 == 0, false)
    end
  end
end
function UIDarkZoneBriefItem:OnClickSkillInfo(skillId, curLevel)
  UIManager.OpenUIByParam(UIDef.UIWeaponSkillInfoPanel, {skillId, curLevel})
end
function UIDarkZoneBriefItem:UpdateItemContent()
  self.mItem_Item.itemContent:SetDarkZoneItemData(self.data.ItemData.id)
  self.mItem_Item.mText_Name.text = self.data.ItemData.name.str
  local typeData = TableData.listItemTypeDescDatas:GetDataById(self.data.ItemData.type)
  self.mItem_Item.mText_Type.text = typeData.name.str
end
function UIDarkZoneBriefItem:UpdateStar(star, maxStar)
  self.curContent.stageItem:ResetMaxNum(maxStar)
  self.curContent.stageItem:SetData(star)
end
function UIDarkZoneBriefItem:UpdateLockStatue(isLock)
  if self.curContent then
    setactive(self.curContent.transUnlock, not isLock)
    setactive(self.curContent.transLock, isLock)
  end
end
function UIDarkZoneBriefItem:EnableLock(enable)
  setactive(self.mItem_Weapon.btnLock.gameObject, enable)
end
function UIDarkZoneBriefItem:EnableButtonGroup(enable)
  setactive(self.ui.mTrans_ButtonGroup.gameObject, enable)
end
function UIDarkZoneBriefItem:ShowItemDetail()
  UITipsPanel.Open(self.data.ItemData, 0, true)
end
