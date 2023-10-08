require("UI.UIBasePanel")
require("UI.Common.UICommonArrowBtnItem")
require("UI.ArchivesPanel.Item.Btn_ArchivesCenterDarkzoneItemV2")
ArchivesCenterDarkzonePanelV2 = class("ArchivesCenterDarkzonePanelV2", UIBasePanel)
ArchivesCenterDarkzonePanelV2.__index = ArchivesCenterDarkzonePanelV2
function ArchivesCenterDarkzonePanelV2:ctor(root)
  self.super.ctor(self, root)
  root.Type = UIBasePanelType.Panel
end
function ArchivesCenterDarkzonePanelV2:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:InitDataAndAddListener()
  self:InitCell()
end
function ArchivesCenterDarkzonePanelV2:InitDataAndAddListener()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ArchivesCenterDarkzonePanelV2)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Display.gameObject).onClick = function()
    self.isOnlyMeData = not self.isOnlyMeData
    setactive(self.ui.mTrans_Have.gameObject, self.isOnlyMeData)
    self:UpdateCell()
  end
end
function ArchivesCenterDarkzonePanelV2:OnInit(root, data)
end
function ArchivesCenterDarkzonePanelV2:InitCell()
  self.darkReportItemList = {}
  self.isOnlyMeData = false
  for i = 1, 5 do
    local item = Btn_ArchivesCenterDarkzoneItemV2.New()
    item:InitCtrl(self.ui.mTrans_Content)
    self.darkReportItemList[i] = item
  end
end
function ArchivesCenterDarkzonePanelV2:UpdateData()
  self.allMonthReportList = NetCmdArchivesData:GetDarkReportList(false)
  self.onlyMeReportList = NetCmdArchivesData:GetDarkReportList(true)
  setactive(self.ui.mTrans_Have.gameObject, self.isOnlyMeData)
  self.currIndex = 0
  if self.isOnlyMeData then
    self.maxIndex = self.onlyMeReportList.Count
  else
    self.maxIndex = self.allMonthReportList.Count
  end
  self.arrowBtn = UICommonArrowBtnItem.New()
  self.arrowBtn:InitObj(self.ui.mObj_ViewSwitch)
  self:UpdateCell()
  self.arrowBtn:RefreshArrowActive()
end
function ArchivesCenterDarkzonePanelV2:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_PreGun.gameObject).onClick = function()
    self:OnClickArrow(-1)
    self:RefreshBtnState()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_NextGun.gameObject).onClick = function()
    self:OnClickArrow(1)
    self:RefreshBtnState()
  end
  self.arrowBtn:SetLeftArrowActiveFunction(function()
    return self.currIndex > 0
  end)
  self.arrowBtn:SetRightArrowActiveFunction(function()
    return self.currIndex < self.maxIndex - 1
  end)
end
function ArchivesCenterDarkzonePanelV2:OnClickArrow(changeNum)
  self.currIndex = self.currIndex + changeNum
  if self.currIndex < 0 then
    self.currIndex = 0
  end
  if self.currIndex > self.maxIndex - 1 then
    self.currIndex = self.maxIndex - 1
  end
  self:UpdateCell()
end
function ArchivesCenterDarkzonePanelV2:RefreshBtnState()
  setactive(self.ui.mBtn_PreGun.gameObject, self.currIndex > 0)
  setactive(self.ui.mBtn_NextGun.gameObject, self.currIndex < self.maxIndex - 1)
end
function ArchivesCenterDarkzonePanelV2:UpdateCell()
  if self.isOnlyMeData then
    for i = 1, 5 do
      local index = self.currIndex * 5 + i - 1
      if index < self.onlyMeReportList.Count then
        self.darkReportItemList[i]:SetData(self.onlyMeReportList[index])
      else
        self.darkReportItemList[i]:SetData()
      end
    end
  else
    for i = 1, 5 do
      local index = self.currIndex * 5 + i - 1
      if index < self.allMonthReportList.Count then
        self.darkReportItemList[i]:SetData(self.allMonthReportList[index])
      else
        self.darkReportItemList[i]:SetData()
      end
    end
  end
end
function ArchivesCenterDarkzonePanelV2:OnShowStart()
  self:UpdateData()
end
function ArchivesCenterDarkzonePanelV2:OnShowFinish()
end
function ArchivesCenterDarkzonePanelV2:OnBackFrom()
  self:UpdateData()
end
function ArchivesCenterDarkzonePanelV2:OnClose()
  self.isOnlyMeData = false
end
function ArchivesCenterDarkzonePanelV2:OnHide()
end
function ArchivesCenterDarkzonePanelV2:OnHideFinish()
end
function ArchivesCenterDarkzonePanelV2:OnRelease()
end
