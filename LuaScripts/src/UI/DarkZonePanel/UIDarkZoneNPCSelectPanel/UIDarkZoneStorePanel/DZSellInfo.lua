require("UI.UIBaseCtrl")
DZSellInfo = class("DZSellInfoItem", UIBaseCtrl)
DZSellInfo.__index = DZSellInfo
function DZSellInfo:__InitCtrl()
end
function DZSellInfo:InitCtrl(root)
  local obj = instantiate(UIUtils.GetGizmosPrefab("Character/ChrWeaponEquipInfoItemV2.prefab", self))
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self.go = obj
end
function DZSellInfo:SetData(Data, Type)
  self.data = Data
  setactive(self.ui.mTrans_EquipContent, false)
  setactive(self.ui.mTrans_ItemContent, false)
  setactive(self.ui.mTrans_WeaponContent, false)
  setactive(self.ui.mTrans_WeaponPartContent, false)
  if Data.ItemData.type == 90 then
    setactive(self.ui.mTrans_EquipContent, true)
    if self.Equipcontent == nil then
      self.Equipcontent = {}
      local LuaUIBindScript = self.ui.mTrans_EquipContent:GetComponent(UIBaseCtrl.LuaBindUi)
      local vars = LuaUIBindScript.BindingNameList
      for i = 0, vars.Count - 1 do
        self.Equipcontent[vars[i]] = LuaUIBindScript:GetBindingComponent(vars[i])
      end
    end
    if self.GrpEquipItem == nil then
      self.GrpEquipItem = {}
      self.GrpEquipItem = UICommonItem.New()
      self.GrpEquipItem:InitCtrl(self.Equipcontent.mTrans_GrpItem)
    end
    self.GrpEquipItem:SetItemByStcData(Data.ItemData, 1)
    self:UpdateEquipData()
  else
    setactive(self.ui.mTrans_ItemContent, true)
    if self.Comcontent == nil then
      self.Comcontent = {}
      local LuaUIBindScript = self.ui.mTrans_ItemContent:GetComponent(UIBaseCtrl.LuaBindUi)
      local vars = LuaUIBindScript.BindingNameList
      for i = 0, vars.Count - 1 do
        self.Comcontent[vars[i]] = LuaUIBindScript:GetBindingComponent(vars[i])
      end
      if self.GrpComItem == nil then
        self.GrpComItem = UICommonItem.New()
        self.GrpComItem:InitCtrl(self.Comcontent.mTrans_Item)
        self.GrpComItem:SetItemByStcData(Data.ItemData, 1)
      end
      self:UpdateComItemData(Data)
    else
      self:UpdateComItemData(Data)
      self.GrpComItem:SetData(Data.ItemData, 1)
    end
  end
  local btncontent = self.ui.mTrans_EquipContent:Find("GrpEquipInfo/GrpItem/Btn_Content")
  if btncontent ~= nil then
    setactive(btncontent, false)
  end
end
function DZSellInfo:UpdateComItemData()
  self.Comcontent.mText_Name.text = self.data.ItemData.name.str
  self.Comcontent.mText_Type.text = TableData.listItemTypeDescDatas:GetDataById(self.data.ItemData.type).name.str
  self.Comcontent.mText_Desc.text = self.data.ItemData.introduction.str
  self.Comcontent.mText_SelNum.text = self.data.SellPrice
  self.Comcontent.mImg_SellIcon.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. TableData.listItemDatas:GetDataById(18).Icon)
  setactive(self.Comcontent.mTrans_GrpSelNum, true)
end
function DZSellInfo:UpdateEquipData()
  self.Equipcontent.mText_Name.text = self.data.ItemData.name.str
  self.Equipcontent.mText_Class.text = TableData.listItemTypeDescDatas:GetDataById(self.data.ItemData.type).name.str
  self.Equipcontent.mText_SelNum.text = self.data.SellPrice
  self.Equipcontent.mImg_SellIcon.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. TableData.listItemDatas:GetDataById(18).Icon)
  self:UpdateEquipAttribute(self.data)
  self:UpdateEquipSkill()
end
function DZSellInfo:UpdateEquipSkill()
  if self.data.EquipData.battle_skill_id == 0 then
    if self.skillItem then
      setactive(self.skillItem.mUIRoot, false)
    end
    return
  end
  local skillData = TableData.listBattleSkillDatas:GetDataById(self.data.EquipData.battle_skill_id)
  if self.skillItem == nil then
    self.skillItem = UIDarkZoneEquipSkillItem.New()
    self.skillItem:InitCtrl(self.Equipcontent.mTrans_AttributeList)
  end
  setactive(self.skillItem.mUIRoot, true)
  self.skillItem:SetData(skillData)
end
function DZSellInfo:UpdateEquipAttribute(data)
  local attrList = {}
  if data.MainAffix then
    local tableData = TableData.listDarkzoneEquipAffixEffectDatas:GetDataById(data.MainAffix.Id)
    local propData = TableData.GetPropertyDataByName(tableData.effect, 0)
    if propData ~= nil then
      self.Equipcontent.mText_MainAttrName.text = propData.ShowName.str
    end
    if tableData.buff_base_type == 2 then
      self.Equipcontent.mText_MainAttrValue.text = data.MainAffix.Value / 10 .. "%"
    else
      self.Equipcontent.mText_MainAttrValue.text = data.MainAffix.Value
    end
  end
  if data.SubAffix then
    for i = 0, data.SubAffix.Count - 1 do
      table.insert(attrList, data.SubAffix[i])
    end
  end
  if attrList then
    local item
    for i = 0, self.Equipcontent.mTrans_AttributeList.childCount - 1 do
      gfdestroy(self.Equipcontent.mTrans_AttributeList:GetChild(i))
    end
    for i = 1, #attrList do
      local prop = attrList[i]
      local tableData = TableData.listDarkzoneEquipAffixEffectDatas:GetDataById(prop.Id)
      local propData = TableData.GetPropertyDataByName(tableData.effect, 0)
      item = UICommonPropertyItem.New()
      item:InitCtrl(self.Equipcontent.mTrans_AttributeList)
      item:SetData(propData, prop.Value, false, false, i % 2 == 0, false)
    end
  end
end
