require("UI.UIBasePanel")
UIUnitInfoPanel = class("UIUnitInfoPanel", UIBasePanel)
UIUnitInfoPanel.__index = UIUnitInfoPanel
UIUnitInfoPanel.ShowType = {
  Enemy = 1,
  Gun = 2,
  GunItem = 3
}
UIUnitInfoPanel.mSortLayer = 0
UIUnitInfoPanel.mUIGroupType = nil
function UIUnitInfoPanel.Open(type, data, level)
  if type == UIUnitInfoPanel.ShowType.GunItem then
    CS.RoleInfoCtrlHelper.Instance:InitSysPlayerDataById(data)
  elseif type == UIUnitInfoPanel.ShowType.Gun then
    CS.RoleInfoCtrlHelper.Instance:InitData(data)
  else
    CS.RoleInfoCtrlHelper.Instance:InitSysEnemyData(TableData.GetEnemyData(tonumber(data)), level)
  end
end
function UIUnitInfoPanel:ctor(csPanel)
  UIUnitInfoPanel.super:ctor(csPanel)
  UIUnitInfoPanel.mUIGroupType = csPanel.UIGroupType
  csPanel.Type = UIBasePanelType.Dialog
end
function UIUnitInfoPanel.Close()
  UIManager.CloseUI(self.super.mCSPanel)
end
function UIUnitInfoPanel:OnClose()
end
function UIUnitInfoPanel:OnInit(root, data)
  UIUnitInfoPanel.super.SetRoot(UIUnitInfoPanel, root)
  UIUnitInfoPanel.mView = UIUnitInfoPanelView.New()
  UIUnitInfoPanel.mView:InitCtrl(root)
  if type(data) == "userdata" and data.Length >= 4 then
    UIUtils.AddSubCanvas(self.mUIRoot.gameObject, data[3], false)
    self.mSortLayer = data[3]
  end
  if type(data) == "userdata" then
    data = {
      data[0],
      data[1],
      data[2]
    }
  end
  self.type = data[1]
  if self.type == UIUnitInfoPanel.ShowType.Enemy then
    self.data = TableData.GetEnemyData(data[2])
    self.stageLevel = data[3]
  elseif self.type == UIUnitInfoPanel.ShowType.Gun then
    self.data = data[2]
  elseif self.type == UIUnitInfoPanel.ShowType.GunItem then
    self.data = data[2]
  end
end
function UIUnitInfoPanel.OnInit()
  UIUtils.GetButtonListener(self.mView.mBtn_Close.gameObject).onClick = self.OnCloseClick
  self:UpdatePanel()
end
function UIUnitInfoPanel:UpdatePanel()
  local infoItem = UICharacterInfoItem:New()
  infoItem:InitCtrl(self.mView.mTrans_GrpInfo, self.mUIGroupType)
  if self.type == UIUnitInfoPanel.ShowType.Enemy then
    infoItem:UpdateEnemyPanel(self.data, self.stageLevel, self.mSortLayer)
  elseif self.type == UIUnitInfoPanel.ShowType.Gun then
    infoItem:UpdateGunPanel(self.data)
  elseif self.type == UIUnitInfoPanel.ShowType.GunItem then
    infoItem:UpdateGunItemPanel(self.data)
  end
end
function UIUnitInfoPanel.OnCloseClick()
  UIUnitInfoPanel.Close()
end
