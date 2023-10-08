require("UI.Common.UICommonItem")
require("UI.UIBaseCtrl")
UIRepositoryBoxSelectItem = class("UIRepositoryBoxSelectItem", UIBaseCtrl)
UIRepositoryBoxSelectItem.__index = UIRepositoryBoxSelectItem
function UIRepositoryBoxSelectItem:ctor()
end
function UIRepositoryBoxSelectItem:__InitCtrl()
end
function UIRepositoryBoxSelectItem:InitCtrl(parent)
  local instantObj = instantiate(parent.childItem, parent.transform)
  self:__InitCtrl()
  self.ui = {}
  self:SetRoot(instantObj.transform)
  self:LuaUIBindTable(instantObj, self.ui)
  self.comItem = UICommonItem.New()
  self.comItem:InitCtrl(self.ui.mTrans_ImgItem)
end
function UIRepositoryBoxSelectItem:SetData(itemId, num, itemTableData)
  self.ui.mText_Name.text = itemTableData.name.str
  self.comItem:SetItemData(itemId, num)
end
function UIRepositoryBoxSelectItem:OnRelease()
  self.comItem:OnRelease(true)
  self.super.OnRelease(self, true)
end
