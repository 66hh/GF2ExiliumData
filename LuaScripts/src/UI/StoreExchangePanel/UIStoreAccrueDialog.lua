require("UI.UIBasePanel")
require("UI.StoreExchangePanel.Item.UIStoreAccrueItem")
UIStoreAccrueDialog = class("UIStoreAccrueDialog", UIBasePanel)
UIStoreAccrueDialog.__index = UIStoreAccrueDialog
function UIStoreAccrueDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIStoreAccrueDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListen()
end
function UIStoreAccrueDialog:OnInit(root, data)
  self.mStoreAccrueItemList = {}
  self.virtualList = self.ui.mVList_GrpList
  function self.virtualList.itemProvider()
    local item = self:ItemProvider()
    return item
  end
  function self.virtualList.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  self.mAccumulateRechargeList = TableData.listAccumulateRechargeDatas:GetList()
  local index = 0
  for k, v in pairs(self.mAccumulateRechargeList) do
    if index ~= 0 and v.id ~= 0 then
      local item = self.mStoreAccrueItemList[index]
      if item == nil then
        table.insert(self.mStoreAccrueItemList, v)
      end
    end
    index = index + 1
  end
  self.virtualList.numItems = #self.mStoreAccrueItemList
  self.virtualList:Refresh()
end
function UIStoreAccrueDialog:OnShowStart()
  self.ui.mText_Money.text = string_format(TableData.GetHintById(106062), formatnum(NetCmdStoreData:GetAccumulateRecharge()))
end
function UIStoreAccrueDialog:ItemProvider()
  local slot = UIStoreAccrueItem.New(self.ui.mScrollListChild_Content.transform)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = slot:GetRoot().gameObject
  renderDataItem.data = slot
  return renderDataItem
end
function UIStoreAccrueDialog:ItemRenderer(index, renderData)
  local item = renderData.data
  item:SetData(index + 1)
end
function UIStoreAccrueDialog:OnHide()
end
function UIStoreAccrueDialog:OnClose()
end
function UIStoreAccrueDialog:OnRelease()
  self.ui = nil
  self.mData = nil
end
function UIStoreAccrueDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.transform).onClick = function()
    UIManager.CloseUI(UIDef.UIStoreAccrueDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.transform).onClick = function()
    UIManager.CloseUI(UIDef.UIStoreAccrueDialog)
  end
end
