UIComBtn2ItemV2 = class("UIComBtn2ItemV2", UIBaseCtrl)
function UIComBtn2ItemV2:ctor()
end
function UIComBtn2ItemV2:InitByPrefab(prefab, parent)
  local go = instantiate(prefab, parent)
  self:init(go)
end
function UIComBtn2ItemV2:InitByGo(go)
  self:init(go)
end
function UIComBtn2ItemV2:Init(parent)
  local go = self:Instantiate("UICommonFramework/ComBtn2ItemV2.prefab", parent)
  self:init(go)
end
function UIComBtn2ItemV2:OnRelease()
  self.redPoint = nil
  self.ui = nil
  self.super.OnRelease(self)
end
function UIComBtn2ItemV2:AddClickListener(action)
  self.onClickCallback = action
end
function UIComBtn2ItemV2:OnClick()
  if self.onClickCallback then
    self.onClickCallback()
  end
end
function UIComBtn2ItemV2:SetName(name)
  self.ui.mText_Name.text = name
end
function UIComBtn2ItemV2:SetRedPointVisible(visible)
  setactive(self.ui.mScrollItem_RedPoint, visible)
end
function UIComBtn2ItemV2:init(go)
  self.ui = UIUtils.GetUIBindTable(go)
  self:SetRoot(go.transform)
  UIUtils.AddBtnClickListener(self.ui.mBtn_ComBtn2ItemV2.gameObject, function()
    self:OnClick()
  end)
  instantiate(self.ui.mScrollItem_RedPoint.childItem, self.ui.mScrollItem_RedPoint.transform)
  setactive(self.ui.mScrollItem_RedPoint, false)
end
