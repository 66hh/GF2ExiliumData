UISimCombatWeaponModWishDescItem = class("UISimCombatWeaponModWishDescItem", UIBaseCtrl)
UISimCombatWeaponModWishDescItem.__index = UISimCombatWeaponModWishDescItem
function UISimCombatWeaponModWishDescItem:__InitCtrl()
end
function UISimCombatWeaponModWishDescItem:InitCtrl(itemPrefab)
  if itemPrefab == nil then
    return
  end
  local obj = instantiate(itemPrefab.childItem, itemPrefab.transform)
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
end
function UISimCombatWeaponModWishDescItem:SetData(suitID)
  local tbData = TableData.listModPowerDatas:GetDataById(suitID)
  local modData = TableData.listModPowerEffectDatas:GetDataById(tbData.power_id)
  self.ui.mText_Name.text = modData.name.str
  self.ui.mImg_WeponPart.sprite = IconUtils.GetIconV2("WeaponPart", modData.image)
  local maxValue = {}
  local minValue = {}
  local skillDescStr
  local formatStr = "{0}-{1}"
  for _, v in pairs(modData.power_skill) do
    local valueDataList = TableData.listPowerSkillCsByPowerSkillDatas:GetDataById(v).Id
    local valueListCount = valueDataList.Count
    for i = 0, valueListCount - 1 do
      local skillID = valueDataList[i]
      local skillValueData = TableData.listPowerSkillCsDatas:GetDataById(skillID)
      local basicValue = skillValueData.basic_value[0]
      if maxValue[v] == nil then
        maxValue[v] = basicValue
      else
        maxValue[v] = math.max(maxValue[v], basicValue)
      end
      if minValue[v] == nil then
        minValue[v] = basicValue
      else
        minValue[v] = math.min(minValue[v], basicValue)
      end
    end
    local battleSkillData = TableData.listBattleSkillDisplayDatas:GetDataById(v)
    local str = battleSkillData.description.str
    if minValue[v] ~= maxValue[v] then
      local str1 = string_format(formatStr, minValue[v], maxValue[v])
      skillDescStr = string_format(str, str1)
    else
      skillDescStr = string_format(str, minValue[v])
    end
  end
  self.ui.mText_Description.text = skillDescStr
end
