require("UI.BattlePass.UIBattlePassGlobal")
UIBattlePassLevelUpDialog = class("UIBattlePassLevelUpDialog", UIBasePanel)
UIBattlePassLevelUpDialog.__index = UIBattlePassLevelUpDialog
function UIBattlePassLevelUpDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIBattlePassLevelUpDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
end
function UIBattlePassLevelUpDialog:OnInit(root, data)
  TimerSys:DelayCall(3, function()
    UIManager.CloseUI(UIDef.UIBattlePassLevelUpDialog)
  end)
  self.ui.mText_Lv.text = tostring(NetCmdBattlePassData.BattlePassLevel)
  self.ui.mText_Lv_1.text = NetCmdBattlePassData.BattlePassOldLevel % 10
  self.ui.mText_BeforeLv_1.text = NetCmdBattlePassData.BattlePassOldLevel % 10
  local before = math.floor(NetCmdBattlePassData.BattlePassOldLevel / 10)
  local after = math.floor(NetCmdBattlePassData.BattlePassLevel / 10)
  if NetCmdBattlePassData.BattlePassLevel == NetCmdBattlePassData.CurSeason.MaxLevel and NetCmdBattlePassData.CurSeason.MaxLevel >= 100 then
    after = 0
  end
  self.ui.mAnimText_1:Rebind()
  self.ui.mAnimText_2:Rebind()
  self.ui.mText_Lv_2.text = before
  self.ui.mText_BeforeLv_2.text = before
  setactive(self.ui.mTrans_Text3, false)
  if NetCmdBattlePassData.BattlePassLevel == NetCmdBattlePassData.CurSeason.MaxLevel and NetCmdBattlePassData.CurSeason.MaxLevel >= 100 then
    self.ui.mText_Lv_1.text = 0
    self.ui.mText_Lv_2.text = 0
    self.ui.mText_BeforeLv_2.text = 0
    self.ui.mText_BeforeLv_1.text = 0
    setactive(self.ui.mTrans_Text3, true)
  else
    self.ui.mText_Lv_2.text = after
    self.ui.mText_Lv_1.text = NetCmdBattlePassData.BattlePassLevel % 10
    TimerSys:DelayCall(1.7, function()
      TimerSys:DelayCall(0.15, function()
        self.ui.mAnimText_1:SetTrigger("NumUp")
      end)
      if after > before then
        self.ui.mAnimText_2:SetTrigger("NumUp")
      end
    end)
  end
end
function UIBattlePassLevelUpDialog:OnShowStart()
end
function UIBattlePassLevelUpDialog:OnHide()
end
function UIBattlePassLevelUpDialog:OnClose()
  self.ui.mAnimText_2:SetTrigger("nor")
  self.ui.mAnimText_1:SetTrigger("nor")
  NetCmdBattlePassData.OrginLevel = NetCmdBattlePassData.BattlePassLevel
  MessageSys:SendMessage(UIEvent.BPScrollRefresh, nil)
  NetCmdBattlePassData.PlayLevelUpEffect = false
  UIUtils.GetButtonListener(self.ui.mBtn_Close.transform).onClick = nil
end
function UIBattlePassLevelUpDialog:OnRelease()
  self.ui = nil
  self.mData = nil
end
function UIBattlePassLevelUpDialog:AddBtnListen()
end
