require("UI.UIBaseCtrl")
SimCombatMythicModeSelItem = class("SimCombatMythicModeSelItem", UIBaseCtrl)
local self = SimCombatMythicModeSelItem
function SimCombatMythicModeSelItem:ctor()
end
function SimCombatMythicModeSelItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  self.rogueStageCofig = nil
  self.stageCofig = nil
end
function SimCombatMythicModeSelItem:SetData(rogueStageId)
  self.rogueStageCofig = TableData.listRogueStageCofigDatas:GetDataById(rogueStageId)
  self.stageCofig = TableData.listStageDatas:GetDataById(rogueStageId)
  local difficultyData = TableData.listRogueStageDifficultyDatas:GetDataById(self.rogueStageCofig.Difficulty)
  self.ui.mText_Mode.text = difficultyData.Name
  self.ui.mImg_Bg.sprite = UISimCombatRogueGlobal.GetRogueIcon(UISimCombatRogueGlobal.IconType.ModeSel, difficultyData.IconPath)
  self.ui.mText_StageName.text = self.stageCofig.Name.str
end
function SimCombatMythicModeSelItem:SetSelect(boolean)
  self.ui.mBtn_Self.interactable = not boolean
end
function SimCombatMythicModeSelItem:OnRelease()
end
