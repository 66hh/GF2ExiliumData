UICharacterBreakSuccPanel = class("UICharacterBreakSuccPanel", UIBasePanel)
function UICharacterBreakSuccPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UICharacterBreakSuccPanel:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:SetPosZ()
end
function UICharacterBreakSuccPanel:OnInit(root, data)
  self.gunList = {}
  self.gunData = NetCmdTeamData:GetGunByID(data)
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = nil
  TimerSys:DelayCall(2, function()
    UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
      UIManager.CloseUISelf(self)
    end
  end)
  self:UpdatePanel()
end
function UICharacterBreakSuccPanel:OnClose()
  self:ReleaseCtrlTable(self.gunList, true)
end
function UICharacterBreakSuccPanel:OnRelease()
  self.gunList = nil
  self.gunData = nil
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = nil
  self.ui = nil
end
function UICharacterBreakSuccPanel:UpdatePanel()
  if self.gunData then
    self:UpdateGunList()
    self:UpdateBreakInfo()
  end
end
function UICharacterBreakSuccPanel:UpdateGunList()
  local list = {}
  local characterData = TableData.listGunCharacterDatas:GetDataById(self.gunData.TabGunData.character_id)
  for i = 0, characterData.unit_id.Length - 1 do
    local gunData = NetCmdTeamData:GetGunByID(characterData.unit_id[i])
    if gunData then
      table.insert(list, gunData)
    end
  end
  for i, gunData in ipairs(list) do
    if self.gunList[i] == nil then
      self.gunList[i] = UIBarrackChrCardItem.New()
      self.gunList[i]:InitCtrl(self.ui.mTrans_GrpChrInfo)
      self.gunList[i].mBtn_Gun.enabled = false
    end
    self.gunList[i]:SetData(gunData.id, false)
  end
end
function UICharacterBreakSuccPanel:UpdateBreakInfo()
  self.ui.mText_LevelUp.text = self.gunData.curGunClass.gun_level_max
  self.ui.mImg_Level.sprite = IconUtils.GetMentalIcon(self.gunData.curGunClass.icon)
end
