require("UI.UIBaseCtrl")
SimCombatMythicBuffSelItem = class("SimCombatMythicBuffSelItem", UIBaseCtrl)
local self = SimCombatMythicBuffSelItem
function SimCombatMythicBuffSelItem:ctor()
end
function SimCombatMythicBuffSelItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  self.rogueBuffData = nil
  self.nextLevelRogueBuffData = nil
end
function SimCombatMythicBuffSelItem:SetData(rogueBuffData)
  self.rogueBuffData = rogueBuffData
  local curBuffs = NetCmdSimCombatRogueData.RogueStage.Buffs
  local hasSameBuff = false
  local tmpTargetBuffData
  for i = 0, curBuffs.Count - 1 do
    if curBuffs[i].GroupId == rogueBuffData.GroupId then
      hasSameBuff = true
      tmpTargetBuffData = NetCmdSimCombatRogueData:GetMaxBuff(curBuffs[i].GroupId, curBuffs[i].Level + self.rogueBuffData.Level)
      break
    end
  end
  setactive(self.ui.mTrans_LevelUpTip, hasSameBuff)
  if tmpTargetBuffData ~= nil then
    self.nextLevelRogueBuffData = tmpTargetBuffData
    self.ui.mText_Levelup.text = string_format(TableData.GetHintById(111028), tmpTargetBuffData.Level)
  end
  if tmpTargetBuffData ~= nil then
    self.rogueBuffData = tmpTargetBuffData
  end
  self.ui.mImg_Icon.sprite = IconUtils.GetRogueBuffIcon(self.rogueBuffData.IconPath)
  self.ui.mText_Name.text = self.rogueBuffData.Name
  self.ui.mText_Level.text = "Lv." .. tostring(self.rogueBuffData.Level)
  self.ui.mTextFit_TextDescribe.text = self.rogueBuffData.BuffDescription
  self.ui.mImg_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(self.rogueBuffData.Quality)
  self.ui.mImg_QualityColor.color = self.ui.mImg_QualityLine.color
end
function SimCombatMythicBuffSelItem:GetRogueBuff()
  local hint
  if self.nextLevelRogueBuffData ~= nil then
    hint = string_format(TableData.GetHintById(111031), self.nextLevelRogueBuffData.Name)
    CS.PopupMessageManager.PopupStateChangeString(hint)
  else
    hint = string_format(TableData.GetHintById(111030), self.rogueBuffData.Name)
    CS.PopupMessageManager.PopupStateChangeString(hint)
  end
end
function SimCombatMythicBuffSelItem:OnRelease()
end
function SimCombatMythicBuffSelItem:SetSelect(boolean)
  self.ui.mBtn_Self.interactable = not boolean
end
