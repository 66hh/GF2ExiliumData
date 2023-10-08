require("UI.UIDarkMainPanelInGame.DarkzoneBoxDialogView")
require("UI.UIBasePanel")
require("UI.UIDarkMainPanelInGame.UIDarkBoxItem")
DarkzoneBoxDialog = class("DarkzoneBoxDialog", UIBasePanel)
DarkzoneBoxDialog.__index = DarkzoneBoxDialog
function DarkzoneBoxDialog:ctor(csPanel)
  DarkzoneBoxDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function DarkzoneBoxDialog:OnInit(root, data)
  DarkzoneBoxDialog.super.SetRoot(DarkzoneBoxDialog, root)
  self:InitBaseData(root)
  self:AddBtnListen()
  self:AddMsgListener()
  self:InitUI(data)
end
function DarkzoneBoxDialog:InitBaseData(root)
  self.mview = DarkzoneBoxDialogView.New()
  self.ui = {}
  self.mview:InitCtrl(root, self.ui)
  function self.CloseFun()
    UIManager.CloseUI(UIDef.DarkzoneBoxDialog)
  end
  self.boxItemTbl = {}
  self.curSelectItem = nil
  self.comItemPrefab = ResSys:GetUICommon("ComItem")
end
function DarkzoneBoxDialog:AddBtnListen()
  self.ui.mBtn_Close.onClick:AddListener(self.CloseFun)
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Close)
end
function DarkzoneBoxDialog:AddMsgListener()
  function self.UpdateBox(msg)
    for i = 0, #self.boxItemTbl - 1 do
      self.boxItemTbl[i] = nil
    end
    self.GoodsDataList = msg.Sender.GoodsList
    self.ui.mVir_MakeItemLs.numItems = self.GoodsDataList.Count
    self.ui.mVir_MakeItemLs:Refresh()
  end
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.UpdateBox, self.UpdateBox)
end
function DarkzoneBoxDialog:InitUI(data)
  self.context = data
  self.GoodsDataList = data.GoodsList
  self.ui.mVir_MakeItemLs.verticalNormalizedPosition = 0
  function self.ui.mVir_MakeItemLs.itemProvider()
    local item = self:ItemProvider()
    return item
  end
  function self.ui.mVir_MakeItemLs.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  self.ui.mVir_MakeItemLs.numItems = self.GoodsDataList.Count
  self.ui.mVir_MakeItemLs:Refresh()
end
function DarkzoneBoxDialog:OnShowStart()
  if not self.context.VM:HasPickInterest() then
    UIManager.CloseUI(UIDef.DarkzoneBoxDialog)
    return
  end
end
function DarkzoneBoxDialog:OnClose()
  if self.comItemPrefab ~= nil then
    ResourceManager:UnloadAssetFromLua(self.comItemPrefab)
    self.comItemPrefab = nil
  end
  self.ui.mVir_MakeItemLs.numItems = 0
  self.ui.mVir_MakeItemLs:Refresh()
  for i = 0, #self.boxItemTbl - 1 do
    if self.boxItemTbl[i] ~= nil then
      self.boxItemTbl[i]:OnRelease()
    end
  end
  self.boxItemTbl = nil
  self.curSelectItem = nil
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.UpdateBox, self.UpdateBox)
  self.UpdateBox = nil
  self:UnRegistrationKeyboard(nil)
  self.ui.mBtn_Close.onClick:RemoveListener(self.CloseFun)
  self.CloseFun = nil
  self.ui = nil
  self.mview = nil
  self.context = nil
  self.GoodsDataList = nil
  MessageSys:SendMessage(CS.GF2.Message.DarkMsg.ClosePickPanel, nil)
end
function DarkzoneBoxDialog:ItemProvider()
  local boxItem = UIDarkBoxItem.New()
  boxItem:InitCtrl(self.ui.mTran_ItemRoot, self, self.comItemPrefab)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = boxItem:GetRoot().gameObject
  renderDataItem.data = boxItem
  return renderDataItem
end
function DarkzoneBoxDialog:ItemRenderer(index, renderdata)
  local data = self.GoodsDataList[index]
  local item = renderdata.data
  item:SetData(data, index)
  item:SetOffset()
  self.boxItemTbl[index] = item
end
function DarkzoneBoxDialog:PointEnterItem(boxItem)
  self:SelectItem(boxItem)
end
function DarkzoneBoxDialog:PointExitItem(boxItem)
  if self.curSelectItem ~= boxItem then
    return
  end
  self:SelectItem(self.boxItemTbl[0])
end
function DarkzoneBoxDialog:InitSelectItem(boxItem)
  if self.curSelectItem ~= nil then
    return
  end
  self:SelectItem(boxItem)
end
function DarkzoneBoxDialog:ClickItem(boxItem)
  if self.curSelectItem ~= boxItem then
    return
  end
  self:SelectItem(nil)
end
function DarkzoneBoxDialog:SelectItem(boxItem)
  if self.curSelectItem ~= nil then
    self.curSelectItem:Enter(false)
  end
  self.curSelectItem = boxItem
  if self.curSelectItem ~= nil then
    self.curSelectItem:Enter(true)
  end
end
function DarkzoneBoxDialog:OnRelease()
end
