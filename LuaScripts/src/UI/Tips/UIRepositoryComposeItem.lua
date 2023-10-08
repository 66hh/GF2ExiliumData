require("UI.UIBaseCtrl")
UIRepositoryComposeItem = class("UIRepositoryComposeItem", UIBaseCtrl)
UIRepositoryComposeItem.__index = UIRepositoryComposeItem
function UIRepositoryComposeItem:__InitCtrl()
  self.mText_Name = self:GetText("Text_Name")
  self.mTrans_Select = self:FindChild("Icon_Equiped")
  self.mTrans_SelectFrame = self:FindChild("ImgSel")
  self.mTrans_ItemContent = self:FindChild("ImgItem")
  UIUtils.GetButtonListener(self.mUIRoot.gameObject).onClick = function(gameObj)
    self:OnClickSelect()
  end
end
function UIRepositoryComposeItem:InitCtrl(root)
  local obj = instantiate(UIUtils.GetGizmosPrefab("Repository/Btn_RepositoryComposeItem.prefab", self))
  self:SetRoot(obj.transform)
  obj.transform:SetParent(root, false)
  obj.transform.localScale = vectorone
  self:__InitCtrl()
end
function UIRepositoryComposeItem:SetData(data, index, parent)
  self.mData = data
  self.mIndex = index
  self.mParent = parent
  self.mTableData = TableData.GetItemData(data.itemId)
  self.mText_Name.text = self.mTableData.name.str
  self.targetItem = UICommonItem.New()
  self.targetItem:InitCtrl(self.mTrans_ItemContent)
end
function UIRepositoryComposeItem:UpdateCount()
  self.targetItem:SetComposeData(self.mTableData, self.mData.count)
end
function UIRepositoryComposeItem:SetSelected(index)
  setactive(self.mTrans_Select, self.mIndex == index)
  setactive(self.mTrans_SelectFrame, self.mIndex == index)
end
function UIRepositoryComposeItem:OnClickSelect()
  self.mParent:OnSelectItem(self.mIndex)
end
