require("UI.UIBaseCtrl")
require("UI.MonopolyActivity.ActivityTourGlobal")
Btn_ActivityTourStoreTopItem = class("Btn_ActivityTourStoreTopItem", UIBaseCtrl)
Btn_ActivityTourStoreTopItem.__index = Btn_ActivityTourStoreTopItem
Btn_ActivityTourStoreTopItem.ui = nil
Btn_ActivityTourStoreTopItem.mData = nil
function Btn_ActivityTourStoreTopItem:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function Btn_ActivityTourStoreTopItem:InitCtrl(parent)
  local com = parent:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem, parent)
  self:SetRoot(obj.transform)
  self.ui = {}
  self.mData = nil
  self:LuaUIBindTable(obj, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Root.gameObject).onClick = function()
    self:OnBtnClick()
  end
end
function Btn_ActivityTourStoreTopItem:SetData(tabType, clickCallBack)
  self.tabType = tabType
  self.clickCallBack = clickCallBack
  self.ui.mText_Name.text = self.tabType == ActivityTourGlobal.StoreTabType_Buy and TableData.GetHintById(270250) or TableData.GetHintById(270251)
end
function Btn_ActivityTourStoreTopItem:OnBtnClick()
  self.ui.mBtn_Root.interactable = false
  if self.clickCallBack then
    self.clickCallBack(self.tabType)
  end
end
function Btn_ActivityTourStoreTopItem:SetSelectTablType(selTabType)
  self.ui.mBtn_Root.interactable = self.tabType ~= selTabType
end
