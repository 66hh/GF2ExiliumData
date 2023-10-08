require("UI.UIBaseCtrl")
UIActivityItemBase = class("UIActivityItemBase", UIBaseCtrl)
UIActivityItemBase.__index = UIActivityItemBase
function UIActivityItemBase:InitCtrl(parent, uiConfig)
  self.mUIConfig = uiConfig
  local instObj = self:Instantiate(self.mUIConfig.prefabPath, parent)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(instObj.transform, self.ui)
  self:OnInit()
end
function UIActivityItemBase:SetData(activityData)
  self.mActivityData = activityData
  self.mActivityID = activityData.activityID
  self.mOpenTime = activityData.openTime
  self.mCloseTime = activityData.closeTime
  self.mActivityTableData = activityData.tableData
  self:OnShow()
end
function UIActivityItemBase:IsActivityOpen()
  return NetCmdOperationActivityData:IsActivityOpen(self.mActivityID)
end
function UIActivityItemBase:CloseActivityPanel()
  UIManager.CloseUI(UIDef.UIActivityDialog)
end
function UIActivityItemBase:OnInit()
end
function UIActivityItemBase:OnShow()
end
function UIActivityItemBase:OnHide()
end
function UIActivityItemBase:OnTop()
end
function UIActivityItemBase:OnClose()
end
