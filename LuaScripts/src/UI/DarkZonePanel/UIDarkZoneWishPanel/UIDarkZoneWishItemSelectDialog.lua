require("UI.Common.UICommonSimpleView")
require("UI.DarkZonePanel.UIDarkZoneWishPanel.Item.UIDarkZoneWishSelectItem")
require("UI.UIBasePanel")
UIDarkZoneWishItemSelectDialog = class("UIDarkZoneWishItemSelectDialog", UIBasePanel)
UIDarkZoneWishItemSelectDialog.__index = UIDarkZoneWishItemSelectDialog
function UIDarkZoneWishItemSelectDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneWishItemSelectDialog:OnInit(root, data)
  self:SetRoot(root)
  self.endlessData = TableData.listDarkzoneSystemEndlessDatas:GetDataById(data.endlessId)
  self.callback = data.callback
  self.selectIndex = data.index
  self.selectItem = data.selectItem
  self.limitTime = data.limitTime
  self.selectType = data.typeID
  self:InitBaseData()
  self.mView:InitCtrl(root, self.ui)
  self:AddBtnListen()
  self:UpdateData()
end
function UIDarkZoneWishItemSelectDialog:CloseFunction()
  UIManager.CloseUISelf(self)
end
function UIDarkZoneWishItemSelectDialog:OnClose()
  if self.limitTime then
    self.ui.mUICountdown_TitleText:CleanFinishCallback()
  end
  self.ui = nil
  self.mView = nil
  self:ReleaseCtrlTable(self.itemList, true)
  self.itemList = nil
  self.curSelectItem = nil
  self.selectItem = nil
  self.endlessData = nil
  self.callback = nil
  self.selectIndex = nil
  self.selectItem = nil
  self.limitTime = nil
end
function UIDarkZoneWishItemSelectDialog:OnRelease()
  self.super.OnRelease(self)
end
function UIDarkZoneWishItemSelectDialog:InitBaseData()
  self.mView = UICommonSimpleView.New()
  self.ui = {}
  self.itemList = {}
end
function UIDarkZoneWishItemSelectDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BGClose.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_None.gameObject).onClick = function()
    self:ItemClickFunction(nil)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    self:OnClickConFirmBtn()
  end
  self.ui.mText_Title.text = TableData.GetHintById(240134)
  if self.limitTime then
    self.ui.mUICountdown_TitleText:SetHitID(240080)
    self.ui.mUICountdown_TitleText:SetShowType(1)
    self.ui.mUICountdown_TitleText:StartCountdown(self.limitTime)
    self.ui.mUICountdown_TitleText:AddFinishCallback(function(suc)
      self:CloseFunction()
    end)
  end
  self.ui.mUICountdown_TitleText.enabled = self.limitTime ~= nil
end
function UIDarkZoneWishItemSelectDialog:UpdateData()
  local list = TableData.listDarkzoneWishDatas:GetList()
  local showList = {}
  local r = self.selectIndex or 0
  for i = 0, list.Count - 1 do
    local d = list[i]
    local itemNum = DarkZoneNetRepositoryData:GetItemNum(d.id)
    if (r == 0 or d.type == r) and 0 < itemNum then
      table.insert(showList, d)
    end
  end
  table.sort(showList, function(a, b)
    local aItemData = TableData.GetItemData(a.id)
    local bItemData = TableData.GetItemData(b.id)
    if aItemData.rank == bItemData.rank then
      return aItemData.id < bItemData.id
    end
    return aItemData.rank > bItemData.rank
  end)
  for i = 1, #showList do
    local index = i
    if self.itemList[index] == nil then
      self.itemList[index] = UIDarkZoneWishSelectItem.New()
      self.itemList[index]:InitCtrl(self.ui.mTrans_Content)
    end
    local item = self.itemList[index]
    item:SetData(showList[i])
    item:SetClickFunction(function()
      self:ItemClickFunction(item)
    end)
    if self.selectItem and self.selectItem.id == showList[i].id then
      self:ItemClickFunction(item)
    end
  end
  if self.curSelectItem == nil then
    self:ItemClickFunction(nil)
  end
end
function UIDarkZoneWishItemSelectDialog:ItemClickFunction(item)
  if self.curSelectItem then
    self.curSelectItem:SetSelect(false)
  end
  self.curSelectItem = item
  if item and item.mData then
    self.curSelectItem:SetSelect(true)
    self.ui.mText_Name.text = self.curSelectItem.mData.name.str
    self.ui.mTextFit_Description.text = self.curSelectItem.mData.des.str
  else
    self.ui.mText_Name.text = TableData.GetHintById(240083)
    self.ui.mTextFit_Description.text = TableData.GetHintById(240084)
  end
  setactive(self.ui.mTrans_ImgNoneSel, self.curSelectItem == nil)
  setactive(self.ui.mTrans_ChooseIcon, self.curSelectItem == nil)
end
function UIDarkZoneWishItemSelectDialog:OnClickConFirmBtn()
  local data
  if self.curSelectItem then
    data = self.curSelectItem.mData
    if self.curSelectItem.itemOwn <= 0 then
      PopupMessageManager.PopupPositiveString(TableData.GetHintById(102238))
      return
    end
  end
  if self.callback then
    self.callback(data)
  end
  self:CloseFunction()
end
