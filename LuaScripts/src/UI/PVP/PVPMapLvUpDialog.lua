require("UI.UIBasePanel")
PVPMapLvUpDialog = class("PVPMapLvUpDialog", UIBasePanel)
PVPMapLvUpDialog.__index = PVPMapLvUpDialog
function PVPMapLvUpDialog:ctor(obj)
  PVPMapLvUpDialog.super.ctor(self)
  obj.Type = UIBasePanelType.Dialog
end
function PVPMapLvUpDialog:OnInit(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  local currMapData = data
  if currMapData then
    if currMapData.map_type == 1 then
      if currMapData.map_level == 1 then
        self.ui.mText_Before.text = TableData.GetHintById(120127)
        self.ui.mText_After.text = TableData.GetHintById(120128)
      elseif currMapData.map_level == 2 then
        self.ui.mText_Before.text = TableData.GetHintById(120127)
        self.ui.mText_After.text = TableData.GetHintById(120128)
      elseif currMapData.map_level == 3 then
        self.ui.mText_Before.text = TableData.GetHintById(120128)
        self.ui.mText_After.text = TableData.GetHintById(120129)
      elseif currMapData.map_level == 4 then
        self.ui.mText_Before.text = TableData.GetHintById(120129)
        self.ui.mText_After.text = TableData.GetHintById(120130)
      end
    elseif currMapData.map_level == 1 then
      self.ui.mText_Before.text = TableData.GetHintById(120131)
      self.ui.mText_After.text = TableData.GetHintById(120132)
    elseif currMapData.map_level == 2 then
      self.ui.mText_Before.text = TableData.GetHintById(120132)
      self.ui.mText_After.text = TableData.GetHintById(120133)
    elseif currMapData.map_level == 3 then
      self.ui.mText_Before.text = TableData.GetHintById(120132)
      self.ui.mText_After.text = TableData.GetHintById(120133)
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    MessageSys:SendMessage(UIEvent.PvpMapUpLevel, nil)
    UIManager.CloseUI(UIDef.PVPMapLvUpDialog)
  end
end
