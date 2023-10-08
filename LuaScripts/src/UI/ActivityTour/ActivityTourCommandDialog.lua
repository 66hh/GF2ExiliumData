require("UI.UIBasePanel")
require("UI.MonopolyActivity.ActivityTourGlobal")
require("UI.ActivityTour.ActivityTourCommandItem")
ActivityTourCommandDialog = class("ActivityTourCommandDialog", UIBasePanel)
ActivityTourCommandDialog.__index = ActivityTourCommandDialog
function ActivityTourCommandDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function ActivityTourCommandDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListen()
end
function ActivityTourCommandDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ActivityTourCommandDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close1.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ActivityTourCommandDialog)
  end
end
function ActivityTourCommandDialog:UpdateInfo()
  self.autoDataList = NetCmdThemeData:GetOrderList()
  local unlockTourCount = NetCmdThemeData:GetTourUnlockCount()
  self.ui.mText_OverView.text = string_format(TableData.GetHintById(270197), unlockTourCount, self.autoDataList.Count)
  function self.ui.mVirtualListExNew_CommandList.itemProvider()
    return self:ItemProvider()
  end
  function self.ui.mVirtualListExNew_CommandList.itemRenderer(...)
    self:ItemRenderer(...)
  end
  self.ui.mVirtualListExNew_CommandList.numItems = self.autoDataList.Count
  self.ui.mVirtualListExNew_CommandList:Refresh()
end
function ActivityTourCommandDialog:ItemProvider()
  local itemView = ActivityTourCommandItem.New()
  itemView:InitCtrl(self.ui.mTrans_Content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function ActivityTourCommandDialog:ItemRenderer(index, renderData)
  local data = self.autoDataList[index]
  if data then
    local item = renderData.data
    item:SetData(data)
  end
end
function ActivityTourCommandDialog:OnInit(root, data)
  self:UpdateInfo()
  ActivityTourGlobal.ReplaceAllColor(self.mUIRoot)
end
function ActivityTourCommandDialog:OnShowStart()
end
function ActivityTourCommandDialog:OnShowFinish()
end
function ActivityTourCommandDialog:OnTop()
end
function ActivityTourCommandDialog:OnBackFrom()
end
function ActivityTourCommandDialog:OnClose()
end
function ActivityTourCommandDialog:OnHide()
end
function ActivityTourCommandDialog:OnHideFinish()
end
function ActivityTourCommandDialog:OnRelease()
end
