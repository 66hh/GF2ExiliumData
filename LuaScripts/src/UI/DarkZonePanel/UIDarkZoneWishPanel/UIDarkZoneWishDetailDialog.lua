require("UI.Common.UICommonSimpleView")
require("UI.DarkZonePanel.UIDarkZoneWishPanel.Item.UIDarkZoneWishDetailItem")
require("UI.UIBasePanel")
UIDarkZoneWishDetailDialog = class("UIDarkZoneWishDetailDialog", UIBasePanel)
UIDarkZoneWishDetailDialog.__index = UIDarkZoneWishDetailDialog
function UIDarkZoneWishDetailDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneWishDetailDialog:OnInit(root, data)
  self:SetRoot(root)
  self.endlessData = TableData.listDarkzoneSystemEndlessDatas:GetDataById(data.endlessId)
  self.callback = data.callback
  self.dataList = data.dataList
  self.limitTime = self.endlessData.limit_time
  self:InitBaseData()
  self.mView:InitCtrl(root, self.ui)
  self:AddBtnListen()
  self:UpdateData()
end
function UIDarkZoneWishDetailDialog:CloseFunction()
  UIManager.CloseUISelf(self)
end
function UIDarkZoneWishDetailDialog:OnClose()
  self.ui = nil
  self.mView = nil
  self:ReleaseCtrlTable(self.itemList, true)
  self.itemList = nil
end
function UIDarkZoneWishDetailDialog:InitBaseData()
  self.mView = UICommonSimpleView.New()
  self.ui = {}
  self.itemList = {}
end
function UIDarkZoneWishDetailDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:CloseFunction()
  end
end
function UIDarkZoneWishDetailDialog:UpdateData()
  local list = TableData.listDarkzoneWishDatas:GetList()
  for i = 0, list.Count - 1 do
    do
      local index = i + 1
      if self.itemList[index] == nil then
        self.itemList[index] = UIDarkZoneWishDetailItem.New()
        self.itemList[index]:InitCtrl(self.ui.mTrans_Content)
      end
      local item = self.itemList[index]
      item:SetData(list[i])
      item:SetClickFunction(function()
        self:ItemClickFunction(item)
      end)
    end
  end
end
function UIDarkZoneWishDetailDialog:ItemClickFunction(item)
  if self.curSelectItem then
    self.curSelectItem:SetSelect(false)
  end
  self.curSelectItem = item
  if item and item.mData then
    self.curSelectItem:SetSelect(true)
    self.ui.mText_Name.text = self.curSelectItem.mData.name.str
    self.ui.mTextFit_Description.text = self.curSelectItem.mData.des.str
  else
    self.ui.mText_Name.text = "不选择道具（程序写的）"
    self.ui.mTextFit_Description.text = "没有额外效果（程序写的）"
  end
end
function UIDarkZoneWishDetailDialog:OnClickConFirmBtn()
  local data
  if self.curSelectItem then
    data = self.curSelectItem.mData
  end
  if self.callback then
    self.callback(data)
    self:CloseFunction()
  end
end
