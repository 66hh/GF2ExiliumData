require("UI.UIBasePanel")
require("UI.WeaponPanel.UIWeaponPanelView")
UIWeaponEvolutionPreviewPanel = class("UIWeaponEvolutionPreviewPanel", UIBasePanel)
UIWeaponEvolutionPreviewPanel.__index = UIWeaponEvolutionPreviewPanel
function UIWeaponEvolutionPreviewPanel:ctor()
  UIWeaponEvolutionPreviewPanel.super.ctor(self)
  UIWeaponEvolutionPreviewPanel.mView = {}
  UIWeaponEvolutionPreviewPanel.weaponData = nil
  UIWeaponEvolutionPreviewPanel.curEvolution = 0
  UIWeaponEvolutionPreviewPanel.curIndex = 0
  UIWeaponEvolutionPreviewPanel.propertyList = {}
end
function UIWeaponEvolutionPreviewPanel:Close()
  UIWeaponGlobal:UpdateWeaponModelByConfig(self.weaponData)
  UIManager.CloseUI(UIDef.UIWeaponEvolutionPreviewPanel)
end
function UIWeaponEvolutionPreviewPanel:OnInit(root, data)
  self = UIWeaponEvolutionPreviewPanel
  UIWeaponEvolutionPreviewPanel.super.SetRoot(UIWeaponEvolutionPreviewPanel, root)
  self:LuaUIBindTable(root, self.mView)
  self.weaponData = NetCmdWeaponData:GetWeaponById(data)
  local obj = self:InstanceUIPrefab("Character/ChrWeaponSkillItemV2.prefab", self.mView.mTrans_GrpSkill, true)
  self.skillItem = self:InitSkillItem(obj)
  self.stageItem = self:InitStageItem()
  self:InitEvolutionVirtualList()
  UIUtils.GetButtonListener(self.mView.mBtn_Close.gameObject).onClick = function()
    self:Close()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  self:UpdatePanel()
end
function UIWeaponEvolutionPreviewPanel:OnShowFinish()
  UIWeaponGlobal:EnableWeaponModel(true)
end
function UIWeaponEvolutionPreviewPanel:InitSkillItem(obj)
  if obj then
    local skill = {}
    skill.obj = obj
    skill.txtName = UIUtils.GetText(obj, "GrpNameInfo/GrpTextName/Text_SkillName")
    skill.txtLv = UIUtils.GetText(obj, "GrpNameInfo/GrpTextName/Trans_Text_Lv")
    skill.txtNum = UIUtils.GetText(obj, "GrpNameInfo/GrpTextName/Trans_Text_Num")
    skill.txtDesc = UIUtils.GetText(obj, "Text_Describe")
    return skill
  end
end
function UIWeaponEvolutionPreviewPanel:InitStageItem(obj)
  local stageItem = UICommonStageItem.New(UIWeaponGlobal.MaxStar)
  stageItem:InitCtrl(self.mView.mTrans_GrpStage)
  return stageItem
end
function UIWeaponEvolutionPreviewPanel:UpdatePanel()
  self:UpdateWeaponEvolution()
  self:UpdateEvolutionWeapon(self.curEvolution)
end
function UIWeaponEvolutionPreviewPanel:UpdateWeaponEvolution()
  self.evolutionList = {}
  for i = 0, self.weaponData.AdvanceWeapon.Count - 1 do
    local itemData = {}
    itemData.data = self.weaponData.AdvanceWeapon[i]
    itemData.index = i
    table.insert(self.evolutionList, itemData)
  end
  self.curEvolution = self.evolutionList[1].data
  self.mView.mVirtualList.numItems = #self.evolutionList
  self.mView.mVirtualList:Refresh()
end
function UIWeaponEvolutionPreviewPanel:InitEvolutionVirtualList()
  function self.mView.mVirtualList.itemProvider()
    local item = self:EvolutionItemProvider()
    return item
  end
  function self.mView.mVirtualList.itemRenderer(index, rendererData)
    self:EvolutionItemRenderer(index, rendererData)
  end
end
function UIWeaponEvolutionPreviewPanel:EvolutionItemProvider()
  local itemView = UICommonItem.New()
  itemView:InitCtrl()
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIWeaponEvolutionPreviewPanel:EvolutionItemRenderer(index, rendererData)
  local itemData = self.evolutionList[index + 1]
  local item = rendererData.data
  local data = TableData.listGunWeaponDatas:GetDataById(itemData.data)
  item:SetData(itemData.data, data.default_maxlv, function(data)
    self:OnClickEvolutionWeapon(data, itemData.index)
  end)
  setactive(item.mTrans_Select, self.curEvolution == item.mData.id)
end
function UIWeaponEvolutionPreviewPanel:OnClickEvolutionWeapon(item, index)
  self.curEvolution = item.mData.id
  if self.curIndex ~= index then
    self.mView.mVirtualList:RefreshItem(self.curIndex)
    self.curIndex = index
  end
  setactive(item.mTrans_Select, true)
  self:UpdateEvolutionWeapon(item.mData.id)
end
function UIWeaponEvolutionPreviewPanel:UpdateEvolutionWeapon(weaponId)
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
  if 0 < data.character_id then
    local characterData = TableData.listGunCharacterDatas:GetDataById(data.character_id)
    self.mView.mText_Gun.text = string_format(TableData.GetHintById(40039), characterData.name.str)
    setactive(self.mView.mTrans_Use, true)
  else
    setactive(self.mView.mTrans_Use, false)
  end
  self:UpdatePropertyList(weaponId, data.default_maxlv, 0)
  self:UpdateSkill(skillData)
  self:UpdateStar(0, data.max_break)
  UIWeaponGlobal:UpdateWeaponModelByConfig(NetCmdWeaponData:GetWeaponByStcId(weaponId))
end
function UIWeaponEvolutionPreviewPanel:UpdateStar(star, maxStar)
  self.stageItem:ResetMaxNum(maxStar)
  self.stageItem:SetData(star)
end
function UIWeaponEvolutionPreviewPanel:UpdateSkill(skill1)
  local skill = self.skillItem
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
function UIWeaponEvolutionPreviewPanel:UpdatePropertyList(weaponId, level, breakTime)
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
      item:InitCtrl(self.mView.mTrans_GrpAttribute)
      table.insert(self.propertyList, item)
    end
    item:SetData(attrList[i].propData, attrList[i].value, true, false, false, false)
    item:SetTextColor(attrList[i].propData.statue == 2 and ColorUtils.OrangeColor or ColorUtils.BlackColor)
  end
end
