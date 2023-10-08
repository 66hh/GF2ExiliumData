require("UI.UIBasePanel")
require("UI.ActivityTour.Btn_ActivityMuseDialogItem")
ActivityMuseAddDialog = class("ActivityMuseAddDialog", UIBasePanel)
ActivityMuseAddDialog.__index = ActivityMuseAddDialog
function ActivityMuseAddDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function ActivityMuseAddDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:ManualUI()
  self:AddBtnListener()
end
function ActivityMuseAddDialog:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ActivityMuseAddDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close1.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ActivityMuseAddDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Left.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ActivityMuseAddDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Right.gameObject).onClick = function()
    self.themeId = NetCmdRecentActivityData:GetNowOpenThemeId(self.themeId)
    if not NetCmdRecentActivityData:ThemeActivityIsOpen(self.themeId) then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(260007))
      UIManager.CloseUI(UIDef.ActivityMuseAddDialog)
      UIManager.CloseUI(UIDef.ActivityMusePanel)
      return
    end
    if self.rightSelectID < 0 then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(270200))
      return
    end
    if 0 > self.leftSelectID then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(270201))
      return
    end
    if NetCmdItemData:GetItemCount(self.leftSelectID) < 1 then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(270185))
      return
    end
    NetCmdThemeData:SendAddInspirationOrder(self.themeId, self.leftSelectID, self.rightSelectID, function(ret)
      if ret == ErrorCodeSuc then
        UIManager.CloseUI(UIDef.ActivityMuseAddDialog)
        CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(270203))
      end
    end)
  end
end
function ActivityMuseAddDialog:ManualUI()
  self.sendUIList = {}
  self.needUIList = {}
  self.leftSelectID = -1
  self.rightSelectID = -1
  self.sendDataList = NetCmdThemeData:GetCollectDataList(101)
  for i = 1, self.sendDataList.Count do
    local index = i - 1
    local sendItem = Btn_ActivityMuseDialogItem.New()
    sendItem:InitCtrl(self.ui.mTrans_Content)
    sendItem:SetData(self.sendDataList[index], 1, self, i, true)
    table.insert(self.sendUIList, sendItem)
    local needItem = Btn_ActivityMuseDialogItem.New()
    needItem:InitCtrl(self.ui.mTrans_Content1)
    needItem:SetData(self.sendDataList[index], 2, self, i, true)
    table.insert(self.needUIList, needItem)
  end
end
function ActivityMuseAddDialog:UpdateItemCount()
  for i = 1, #self.sendUIList do
    self.sendUIList[i]:SetData(self.sendDataList[i - 1], 1, self, i, true)
    self.needUIList[i]:SetData(self.sendDataList[i - 1], 2, self, i, true)
    self.sendUIList[i]:UpdateCount(self.sendDataList[i - 1])
    self.needUIList[i]:UpdateCount(self.sendDataList[i - 1])
  end
end
function ActivityMuseAddDialog:OnSelectLeft(index)
  self.leftSelectID = self.sendDataList[index - 1].id
  for i = 1, #self.sendUIList do
    self.sendUIList[i]:SetSelect(index == i)
  end
  for i = 1, #self.needUIList do
    self.needUIList[i]:SetDisable(index == i)
  end
end
function ActivityMuseAddDialog:OnSelectRight(index)
  self.rightSelectID = self.sendDataList[index - 1].id
  for i = 1, #self.needUIList do
    self.needUIList[i]:SetSelect(index == i)
  end
  for i = 1, #self.sendUIList do
    self.sendUIList[i]:SetDisable(index == i)
  end
end
function ActivityMuseAddDialog:OnInit(root, data)
  self.themeId = data.themeId
end
function ActivityMuseAddDialog:OnShowStart()
end
function ActivityMuseAddDialog:UpdateState()
  for i = 1, #self.sendUIList do
    self.sendUIList[i]:CleanState()
  end
  for i = 1, #self.needUIList do
    self.needUIList[i]:CleanState()
  end
end
function ActivityMuseAddDialog:OnShowFinish()
  self:UpdateItemCount()
end
function ActivityMuseAddDialog:OnTop()
end
function ActivityMuseAddDialog:OnBackFrom()
end
function ActivityMuseAddDialog:OnClose()
  self.leftSelectID = -1
  self.rightSelectID = -1
  self:UpdateState()
end
function ActivityMuseAddDialog:OnHide()
end
function ActivityMuseAddDialog:OnHideFinish()
end
function ActivityMuseAddDialog:OnRelease()
  self.leftSelectID = -1
  self.rightSelectID = -1
  self:UpdateState()
end
