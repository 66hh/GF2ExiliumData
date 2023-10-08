require("UI.ArchivesPanel.Item.GunFileItem")
require("UI.ArchivesPanel.UIRoleFilePanelView")
require("UI.UIBasePanel")
UIRoleFilePanel = class("UIRoleFilePanel", UIBasePanel)
UIRoleFilePanel.__index = UIRoleFilePanel
function UIRoleFilePanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
end
function UIRoleFilePanel:OnAwake(root, data)
  self:SetRoot(root)
  self:InitBaseData()
  self.mview:InitCtrl(root, self.ui)
  self:AddBtnListen()
  function self.ui.mVirtualListEx.itemProvider()
    return self:ItemProvider()
  end
  function self.ui.mVirtualListEx.itemRenderer(...)
    self:ItemRenderer(...)
  end
  ArchivesUtils.EnterWay = 0
end
function UIRoleFilePanel:OnInit(root, data)
end
function UIRoleFilePanel:OnShowStart()
  self.IsPanelOpen = true
  self:UpdateItemList()
end
function UIRoleFilePanel:OnHide()
  self.IsPanelOpen = false
end
function UIRoleFilePanel:OnClickClose()
  UIManager.CloseUI(UIDef.UIRoleFilePanel)
end
function UIRoleFilePanel:OnRelease()
  self.ui = nil
  self.mview = nil
  self.ItemDataList = nil
  self.IsPanelOpen = nil
end
function UIRoleFilePanel:InitBaseData()
  self.mview = UIRoleFilePanelView.New()
  self.ui = {}
  self.ItemDataList = {}
  self.IsPanelOpen = false
end
function UIRoleFilePanel:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    self:OnClickClose()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
end
function UIRoleFilePanel:UpdateItemList()
  if #self.ItemDataList == 0 then
    self.ItemDataList = {}
    for i = 0, TableData.listGunCharacterDatas.Count - 1 do
      local data = TableData.listGunCharacterDatas[i]
      table.insert(self.ItemDataList, data)
    end
    table.sort(self.ItemDataList, function(a, b)
      if a.Sort == nil or b.Sort == nil then
        return false
      end
      if a.Sort == b.Sort then
        return false
      end
      return a.Sort < b.Sort
    end)
  end
  self.ui.mVirtualListEx:Refresh()
  self.ui.mVirtualListEx.numItems = #self.ItemDataList
end
function UIRoleFilePanel:ItemProvider()
  local itemView = GunFileItem.New()
  itemView:InitCtrl(self.ui.mTrans_Content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIRoleFilePanel:ItemRenderer(index, renderData)
  local data = self.ItemDataList[index + 1]
  local item = renderData.data
  item:SetData(data)
end
