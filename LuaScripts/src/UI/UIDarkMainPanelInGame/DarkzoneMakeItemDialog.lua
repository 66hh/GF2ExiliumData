require("UI.UIDarkMainPanelInGame.DarkzoneMakeItemDialogView")
require("UI.UIBasePanel")
DarkzoneMakeItemDialog = class("DarkzoneMakeItemDialog", UIBasePanel)
DarkzoneMakeItemDialog.__index = DarkzoneMakeItemDialog
function DarkzoneMakeItemDialog:ctor(csPanel)
  DarkzoneMakeItemDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function DarkzoneMakeItemDialog:OnInit(root, data)
  DarkzoneMakeItemDialog.super.SetRoot(DarkzoneMakeItemDialog, root)
  self:InitBaseData(root)
  self:AddBtnListen()
  self:AddMsgListener()
  self:InitUI(data)
end
function DarkzoneMakeItemDialog:InitBaseData(root)
  self.mview = DarkzoneMakeItemDialogView.New()
  self.ui = {}
  self.mview:InitCtrl(root, self.ui)
  function self.CloseFun()
    UIManager.CloseUI(UIDef.DarkzoneMakeItemDialog)
  end
end
function DarkzoneMakeItemDialog:AddBtnListen()
  self.ui.mBtn_Close.onClick:AddListener(self.CloseFun)
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Close)
end
function DarkzoneMakeItemDialog:AddMsgListener()
end
function DarkzoneMakeItemDialog:InitUI(data)
  self.context = data
  self.MakeItemData = data.Data.boxDatas
  function self.ui.mVir_MakeItemLs.itemProvider()
    local item = self:MakeItemProvider()
    return item
  end
  function self.ui.mVir_MakeItemLs.itemRenderer(index, renderData)
    self:MakeItemRenderer(index, renderData)
  end
  self.ui.mVir_MakeItemLs.numItems = self.MakeItemData.Count
  self.ui.mVir_MakeItemLs:Refresh()
end
function DarkzoneMakeItemDialog:OnShowStart()
  if not self.context.VM:HasPickInterest() then
    UIManager.CloseUI(UIDef.DarkzoneMakeItemDialog)
    return
  end
end
function DarkzoneMakeItemDialog:OnClose()
  self:UnRegistrationKeyboard(nil)
  self.ui.mBtn_Close.onClick:RemoveListener(self.CloseFun)
  self.CloseFun = nil
  self.ui = nil
  self.mview = nil
  self.context = nil
  self.MakeItemData = nil
end
function DarkzoneMakeItemDialog:MakeItemProvider()
  local makeItem = MakeBoxItem.New()
  makeItem:InitCtrl(self.ui.mTran_ItemRoot)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = makeItem:GetRoot().gameObject
  renderDataItem.data = makeItem
  return renderDataItem
end
function DarkzoneMakeItemDialog:MakeItemRenderer(index, renderdata)
  local data = self.MakeItemData[index]
  local item = renderdata.data
  item:SetData(data, index, self.context)
end
