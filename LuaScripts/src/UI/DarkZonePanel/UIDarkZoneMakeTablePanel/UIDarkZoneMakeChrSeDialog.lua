require("UI.UIBasePanel")
require("UI.DarkZonePanel.UIDarkZoneMakeTablePanel.UIDarkZoneMakeChrSelItem")
require("UI.DarkZonePanel.UIDarkZoneMakeTablePanel.UIDarkZoneMakeTablePanel")
require("UI.DarkZonePanel.UIDarkZoneModePanel.DarkZoneGlobal")
UIDarkZoneMakeChrSeDialog = class(UIDarkZoneMakeChrSeDialog, UIBasePanel)
UIDarkZoneMakeChrSeDialog.__index = UIDarkZoneMakeChrSeDialog
function UIDarkZoneMakeChrSeDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneMakeChrSeDialog:OnAwake(root, data)
end
function UIDarkZoneMakeChrSeDialog:OnInit(root, data)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root)
  self.mData = data.listGunId
  self.formulaId = data.formulaId
  self.selectId = data.selectGunId
  self.callback = data.callback
  self.ui.mVirtualListEx_List.verticalNormalizedPosition = 1
  function self.ui.mVirtualListEx_List.itemProvider()
    local item = self:ItemProvider()
    return item
  end
  function self.ui.mVirtualListEx_List.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  self:AddBtnListen()
  self:RefreshContent()
end
function UIDarkZoneMakeChrSeDialog:AddBtnListen()
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnBack.gameObject, function()
    self:OnBtnClose()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Close.gameObject, function()
    self:OnBtnClose()
  end)
end
function UIDarkZoneMakeChrSeDialog:OnShowStart()
end
function UIDarkZoneMakeChrSeDialog:OnShowFinish()
end
function UIDarkZoneMakeChrSeDialog:OnBackFrom()
end
function UIDarkZoneMakeChrSeDialog:OnClose()
  self.ui = nil
  self.mData = nil
end
function UIDarkZoneMakeChrSeDialog:OnHide()
end
function UIDarkZoneMakeChrSeDialog:OnHideFinish()
end
function UIDarkZoneMakeChrSeDialog:OnRelease()
end
function UIDarkZoneMakeChrSeDialog:OnRecover()
end
function UIDarkZoneMakeChrSeDialog:OnSave()
end
function UIDarkZoneMakeChrSeDialog:OnBtnClose()
  UIManager.CloseUI(UIDef.UIDarkZoneMakeChrSeDialog)
  self.callback(self.selectId)
end
function UIDarkZoneMakeChrSeDialog:RefreshContent()
  if not self.mData then
    return
  end
  self.ui.mVirtualListEx_List.numItems = #self.mData
  self.ui.mVirtualListEx_List:Refresh()
end
function UIDarkZoneMakeChrSeDialog.SelectRoleItem(id)
  self = UIDarkZoneMakeChrSeDialog
  if not id or self.selectId == id then
    return
  end
  self.selectId = id
  self:OnBtnClose()
end
function UIDarkZoneMakeChrSeDialog:ItemProvider()
  local itemView = UIDarkZoneMakeChrSelItem.New()
  itemView:InitCtrl(self.ui.mScrollListChild_Content.transform, false)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIDarkZoneMakeChrSeDialog:ItemRenderer(index, renderData)
  if index + 1 > #self.mData then
    return
  end
  local item = renderData.data
  item:SetData(self.formulaId, self.mData[index + 1], UIDarkZoneMakeChrSeDialog.SelectRoleItem)
  item:SetSelect(self.selectId)
end
