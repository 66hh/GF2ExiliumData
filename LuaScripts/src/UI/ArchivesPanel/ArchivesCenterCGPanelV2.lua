require("UI.UIBasePanel")
require("UI.ArchivesPanel.Item.ArchivesCenterCGPicturesItemV2")
ArchivesCenterCGPanelV2 = class("ArchivesCenterCGPanelV2", UIBasePanel)
ArchivesCenterCGPanelV2.__index = ArchivesCenterCGPanelV2
function ArchivesCenterCGPanelV2:ctor(root)
  self.super.ctor(self, root)
end
function ArchivesCenterCGPanelV2:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.cgDataList = NetCmdArchivesData:GetCGDataList()
  self:OnBtnClick()
end
function ArchivesCenterCGPanelV2:UpdateRightView()
  function self.ui.mVirtualListEx_Content.itemProvider()
    return self:ItemProvider()
  end
  function self.ui.mVirtualListEx_Content.itemRenderer(...)
    self:ItemRenderer(...)
  end
  self.ui.mVirtualListEx_Content.numItems = self.cgDataList.Count
  self.ui.mVirtualListEx_Content:Refresh()
end
function ArchivesCenterCGPanelV2:ItemProvider()
  local itemView = ArchivesCenterCGPicturesItemV2.New()
  itemView:InitCtrl(self.ui.mTrans_Content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function ArchivesCenterCGPanelV2:ItemRenderer(index, renderData)
  local data = self.cgDataList[index]
  if data then
    local item = renderData.data
    item:SetData(data)
  end
end
function ArchivesCenterCGPanelV2:OnBtnClick()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ArchivesCenterCGPanelV2)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
end
function ArchivesCenterCGPanelV2:OnInit(root, data)
  self:UpdateRightView()
end
function ArchivesCenterCGPanelV2:OnShowStart()
end
function ArchivesCenterCGPanelV2:OnShowFinish()
end
function ArchivesCenterCGPanelV2:OnBackFrom()
  self:UpdateRightView()
end
function ArchivesCenterCGPanelV2:OnClose()
end
function ArchivesCenterCGPanelV2:OnHide()
end
function ArchivesCenterCGPanelV2:OnHideFinish()
end
function ArchivesCenterCGPanelV2:OnRelease()
end
