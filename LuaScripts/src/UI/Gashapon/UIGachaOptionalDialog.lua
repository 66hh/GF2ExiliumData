require("UI.UIBasePanel")
require("UI.Gashapon.UIGachaOptionalDialogView")
require("UI.Gashapon.UIGachaOptionItem")
UIGachaOptionalDialog = class("UIGachaOptionalDialog", UIBasePanel)
UIGachaOptionalDialog.__index = UIGachaOptionalDialog
UIGachaOptionalDialog.mView = nil
UIGachaOptionalDialog.selectedItem = nil
function UIGachaOptionalDialog:ctor(csPanel)
  UIGachaOptionalDialog.super:ctor(csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIGachaOptionalDialog:OnInit(root, data)
  UIGachaOptionalDialog.super.SetRoot(UIGachaOptionalDialog, root)
  self.mView = UIGachaOptionalDialogView.New()
  self.ui = {}
  self.mView:LuaUIBindTable(self.mUIRoot, self.ui)
  self.mView:InitCtrl(self.mUIRoot)
  UIUtils.GetButtonListener(self.ui.mBtn_BgClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIGachaOptionalDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIGachaOptionalDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    local gunData = TableDataBase.listGunDatas:GetDataById(self.selectedId)
    MessageBoxPanel.ShowDoubleType(string_format(TableData.GetHintById(107067), gunData.name.str), function()
      GashaponNetCmdHandler:SendReqGetGachaOptionalReward(self.selectedId, function(ret)
        local gun = {}
        gun.ItemId = self.selectedId
        local gunList = {gun}
        UICommonGetGunPanel.OpenGetGunPanel(gunList, function()
          UIManager.CloseUI(UIDef.UIGachaOptionalDialog)
        end, nil, true)
      end)
    end)
  end
  self.selectedId = 0
  self.selectedItem = nil
  self:InitOptionItems()
end
function UIGachaOptionalDialog:UpdateInfo()
  self.ui.mText_Num.text = string_format(TableData.GetHintById(107062), GashaponNetCmdHandler.GachaOptionalTimes, TableData.GlobalSystemData.GachaSelfSelectedProcess)
  setactive(self.ui.mText_Num, GashaponNetCmdHandler.GachaOptionalTimes < TableData.GlobalSystemData.GachaSelfSelectedProcess)
  setactive(self.ui.mText_TextInfo, self.selectedId == 0 and GashaponNetCmdHandler.GachaOptionalTimes >= TableData.GlobalSystemData.GachaSelfSelectedProcess)
  setactive(self.ui.mBtn_Confirm, self.selectedId ~= 0 and GashaponNetCmdHandler.GachaOptionalTimes >= TableData.GlobalSystemData.GachaSelfSelectedProcess)
end
function UIGachaOptionalDialog:InitOptionItems()
  function self.ui.mScrollerController.itemCreated(renderData)
    local item = self:ItemProvider(renderData)
    return item
  end
  function self.ui.mScrollerController.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  self.ui.mScrollerController.numItems = TableData.GlobalSystemData.GachaSelfSelectedRoleId.Count
  self:UpdateInfo()
end
function UIGachaOptionalDialog:ItemProvider(renderData)
  local itemView = UIGachaOptionItem.New()
  itemView:InitCtrlWithoutInstantiate(renderData.gameObject, false)
  renderData.data = itemView
end
function UIGachaOptionalDialog:ItemRenderer(index, renderData)
  local id = TableData.GlobalSystemData.GachaSelfSelectedRoleId[index]
  local item = renderData.data
  item:SetData(id)
  item:SetClickFunction(function(item)
    if UIGachaOptionalDialog.selectedItem ~= nil then
      UIGachaOptionalDialog.selectedItem:SetSelected(false)
    end
    if self.selectedId == id then
      self.selectedId = 0
      UIGachaOptionalDialog.selectedItem = nil
    else
      self.selectedId = id
      UIGachaOptionalDialog.selectedItem = item
      item:SetSelected(true)
    end
    self:UpdateInfo()
  end)
end
function UIGachaOptionalDialog:OnClose()
  self.mView = nil
  self.selectedId = 0
  if self.selectedItem ~= nil then
    self.selectedItem:SetSelected(false)
  end
  self.ui.mScrollerController.numItems = 0
end
