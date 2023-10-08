require("UI.UIBasePanel")
UISimCombatMythicModeSelDialog = class("UISimCombatMythicModeSelDialog", UIBasePanel)
UISimCombatMythicModeSelDialog.__index = UISimCombatMythicModeSelDialog
local self = UISimCombatMythicModeSelDialog
function UISimCombatMythicModeSelDialog:ctor(obj)
  UISimCombatMythicModeSelDialog.super.ctor(self)
  obj.Type = UIBasePanelType.Dialog
end
function UISimCombatMythicModeSelDialog:OnInit(root, data)
  self.super.SetRoot(UISimCombatMythicModeSelDialog, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.mTittle_Name = data
  self.curSelModeItem = nil
  UIUtils.GetButtonListener(self.ui.mBtn_Select.gameObject).onClick = function()
    NetCmdSimCombatRogueData:GetCS_SimCombatRogueSelectGroupId(NetCmdSimCombatRogueData.NextGroupId)
    UIManager.CloseUI(UIDef.UISimCombatMythicModeSelDialog)
  end
  self.ui.mText_Tittle.text = self.mTittle_Name
  self:SetModeList()
end
function UISimCombatMythicModeSelDialog:OnHide()
  self.isHide = true
end
function UISimCombatMythicModeSelDialog:OnClose()
  UISimCombatRogueGlobal.ExcuteChallengeFuncList()
end
function UISimCombatMythicModeSelDialog:SetModeList()
  setactive(self.ui.mBtn_Select.gameObject, false)
  local curGroupIds = NetCmdSimCombatRogueData.RogueStage.NextGroupId
  for i = 0, curGroupIds.Count - 1 do
    local item = SimCombatMythicModeSelItem.New()
    item:InitCtrl(self.ui.mScrollListChild_Content)
    item:SetData(curGroupIds[i])
    UIUtils.GetButtonListener(item.ui.mBtn_Self.gameObject).onClick = function()
      NetCmdSimCombatRogueData.NextGroupId = curGroupIds[i]
      self:OnClickModeSelItem(item)
    end
  end
end
function UISimCombatMythicModeSelDialog:OnClickModeSelItem(item)
  setactive(self.ui.mBtn_Select.gameObject, true)
  if self.curSelModeItem ~= nil then
    self.curSelModeItem:SetSelect(false)
  end
  item:SetSelect(true)
  self.curSelModeItem = item
end
