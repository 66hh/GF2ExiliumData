require("UI.UIBasePanel")
UISimCombatMythicFindExDialog = class("UISimCombatMythicFindExDialog", UIBasePanel)
UISimCombatMythicFindExDialog.__index = UISimCombatMythicFindExDialog
local self = UISimCombatMythicFindExDialog
function UISimCombatMythicFindExDialog:ctor(obj)
  UISimCombatMythicFindExDialog.super.ctor(self)
  obj.Type = UIBasePanelType.Dialog
end
function UISimCombatMythicFindExDialog:OnInit(root, data)
  self.super.SetRoot(UISimCombatMythicFindExDialog, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    NetCmdSimCombatRogueData.NextGroupId = NetCmdSimCombatRogueData.ExId
    self:CloseRogueEx()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    local hint = TableData.GetHintById(111062)
    local content = MessageContent.New(hint, MessageContent.MessageType.DoubleBtn, function()
      self:CloseRogueEx()
    end)
    MessageBoxPanel.Show(content)
  end
end
function UISimCombatMythicFindExDialog:CloseRogueEx()
  NetCmdSimCombatRogueData.ExId = 0
  if NetCmdSimCombatRogueData.ExNum >= 1 then
    NetCmdSimCombatRogueData.ExNum = NetCmdSimCombatRogueData.ExNum - 1
  end
  UIManager.CloseUI(UIDef.UISimCombatMythicFindExDialog)
end
function UISimCombatMythicFindExDialog:OnHide()
  self.isHide = true
end
function UISimCombatMythicFindExDialog:OnClose()
  UISimCombatRogueGlobal.ExcuteChallengeFuncList()
end
