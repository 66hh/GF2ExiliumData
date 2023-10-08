require("UI.UIBaseCtrl")
SimCombatMythicTeamItem = class("SimCombatMythicTeamItem", UIBaseCtrl)
local self = SimCombatMythicTeamItem
function SimCombatMythicTeamItem:ctor()
end
function SimCombatMythicTeamItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  self.gunPresetData = nil
  self.preGunId = 0
  self.gunData = nil
end
function SimCombatMythicTeamItem:SetData(id)
  self.preGunId = id
  self.gunPresetData = TableDataBase.listGunPresetDatas:GetDataById(self.preGunId)
  self.gunData = TableData.listGunDatas:GetDataById(self.gunPresetData.SourceId)
  UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
    local maxHp = 0
    if self.gunPresetData.property_preset_id ~= 0 then
      maxHp = TableData.listPropertyDatas:GetDataById(self.gunPresetData.property_preset_id).max_hp
    else
      local gunLevelExpData = TableData.listGunLevelExpDatas:GetDataById(self.gunPresetData.Level)
      maxHp = PropertyUtils.GetBasePropertyValue(self.gunData, gunLevelExpData, CS.GF2.Data.DevelopProperty.MaxHp)
    end
    CS.RoleInfoCtrlHelper.Instance:InitBattlePresetData(self.preGunId, maxHp)
  end
  local avatar = IconUtils.GetCharacterBustSprite(self.gunData.Code)
  local color = TableData.GetGlobalGun_Quality_Color2(self.gunData.Rank)
  self.ui.mImg_Rank.color = color
  self.ui.mImage_Rank2.color = color
  self.ui.mImg_Icon.sprite = avatar
  self.ui.mText_LevelNum.text = self.gunPresetData.Level
  local dutyData = TableData.listGunDutyDatas:GetDataById(self.gunData.Duty)
  local tmpDutyParent = self.ui.mTrans_Duty.transform
  local tmpScrollListChild = tmpDutyparent:GetComponent(typeof(CS.ScrollListChild))
  local tmpDutyObj = instantiate(tmpScrollListChild.childItem.gameObject, tmpDutyParent)
  tmpDutyObj.transform:Find("Img_DutyIcon").transform:GetComponent("Image").sprite = IconUtils.GetGunTypeIcon(dutyData.icon)
end
function SimCombatMythicTeamItem:OnRelease()
end
