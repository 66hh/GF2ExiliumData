require("UI.UIDarkMainPanelInGame.UIComEquipmentInfo")
require("UI.UIBaseCtrl")
UIDarkPlayerInfoPanel = class("UIDarkPlayerInfoPanel", UIBasePanel)
function UIDarkPlayerInfoPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkPlayerInfoPanel:OnAwake(root)
  self:SetRoot(root)
  self.ui = UIUtils.GetUIBindTable(root)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Close.gameObject, function()
    self:onClickClose()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_GrpClose.gameObject, function()
    self:onClickClose()
  end)
  self.virtualList = self.ui.mVirtualList
  function self.virtualList.itemProvider()
    self:itemProvider()
  end
  function self.virtualList.itemRenderer()
    self:itemRenderer()
  end
  self.equipmentInfoPanel = UIComEquipmentInfo.New(self.ui.mScrollItem_EquipInfoItem.transform)
end
function UIDarkPlayerInfoPanel:OnInit(root)
  self.infoBarTable = {}
end
function UIDarkPlayerInfoPanel:OnShowStart()
  self.darkPlayerDataTable = self:getAllDarkPlayer()
  self.virtualList.numItems = #self.darkPlayerDataTable
  self.virtualList:Refresh()
end
function UIDarkPlayerInfoPanel:OnRelease()
  self:ReleaseCtrlTable(self.infoBarTable)
  self.equipmentInfoPanel:OnRelease()
  self.darkPlayerDataTable = nil
  self.virtualList = nil
  self.ui = nil
end
function UIDarkPlayerInfoPanel:itemProvider()
  local template = self.ui.mScrollItem_InfoItem.childItem
  local itemView = UIDarkPlayerInfoBar.New(instantiate(template, self.ui.mScrollItem_InfoItem.transform))
  local renderDataItem = RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIDarkPlayerInfoPanel:itemRenderer(index, renderData)
  local data = self.darkPlayerDataTable[index + 1]
  local item = renderData.data
  item:SetData(data, index + 1, function(darkEquipItem)
    self:onClickEquipment(darkEquipItem)
  end)
  item:Refresh()
  table.insert(self.infoBarTable, item)
end
function UIDarkPlayerInfoPanel:onClickEquipment(darkEquipItem)
  if not darkEquipItem then
    return
  end
  setactive(self.ui.mScrollItem_EquipInfoItem, true)
  self.equipmentInfoPanel:InitByDarkEquipItem(darkEquipItem)
  self.equipmentInfoPanel:Refresh()
  self.equipmentInfoPanel:SetGrpActionVisible(false)
  self.equipmentInfoPanel:SetGrpEquipVisible(true)
  local blockHelper = UIUtils.GetUIBlockHelper(self.mUIRoot.transform, self.ui.mScrollItem_EquipInfoItem.transform, function()
    setactive(self.ui.mScrollItem_EquipInfoItem, false)
  end)
  blockHelper:OnEnable()
end
function UIDarkPlayerInfoPanel:onClickClose()
  UIManager.CloseUI(UIDef.UIDarkPlayerInfoPanel)
end
function UIDarkPlayerInfoPanel:getAllDarkPlayer()
  local darkPlayerManager = CS.SysMgr.dzPlayerMgr
  local darkPlayerTable = {}
  for i, darkPlayer in pairs(darkPlayerManager.AllPlayer.Values) do
    table.insert(darkPlayerTable, darkPlayer)
  end
  table.sort(darkPlayerTable, function(l, r)
    if l.DarkResult ~= r.DarkResult then
      return l.DarkResult.value__ < r.DarkResult.value__
    end
    if l.IsMainPlayer ~= r.IsMainPlayer then
      if l.IsMainPlayer then
        return false
      elseif l.IsMainPlayer then
        return true
      end
    end
  end)
  return darkPlayerTable
end
