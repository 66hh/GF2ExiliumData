require("UI.UIBaseCtrl")
UIBannerTextItem = class("UIBannerTextItem", UIBaseCtrl)
UIBannerTextItem.__index = UIBannerTextItem
UIBannerTextItem.mText_MainText = nil
function UIBannerTextItem:__InitCtrl()
  self.mText_MainText = self:GetText("Text_MainText")
end
UIBannerTextItem.mData = nil
UIBannerTextItem.ItemPath = "TopBanner/UIBannerTextItem.prefab"
function UIBannerTextItem:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab(UIBannerTextItem.ItemPath, self))
  self:SetRoot(obj.transform)
  setparent(parent, obj.transform)
  obj.transform.localPosition = vectorzero
  obj.transform.localScale = vectorone
  self:__InitCtrl()
end
function UIBannerTextItem:SetData(data)
  self.mData = data
  self.mText_MainText.text = data.content
end
