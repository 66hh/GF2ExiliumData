UIComScreenItemV2 = class("UIComScreenItemV2", UIBaseCtrl)
function UIComScreenItemV2:ctor(parentRoot)
  local goComBtn3ItemR = self:Instantiate("UICommonFramework/ComScreenItemV2.prefab", parentRoot)
  self.ui = UIUtils.GetUIBindTable(goComBtn3ItemR)
  self.ui.mBtn_TypeScreen.onClick:AddListener(function()
    self:OnClickSuit()
  end)
  self.TypeBtnVisible = self.ui.mBtn_TypeScreen.gameObject.activeSelf
  self.ui.mBtn_Dropdown.onClick:AddListener(function()
    self:OnClickSortType()
  end)
  self.ui.mBtn_Screen.onClick:AddListener(function()
    self:OnClickReverseSort()
  end)
end
function UIComScreenItemV2:Refresh()
end
function UIComScreenItemV2:OnRelease(isDestroyRoot)
  self.ui.mBtn_TypeScreen.onClick = nil
  self.ui.mBtn_Dropdown.onClick = nil
  self.ui.mBtn_Screen.onClick = nil
  self.ui = nil
  self.super.OnRelease(self, isDestroyRoot)
end
function UIComScreenItemV2:SetSuitName(name)
  self.ui.mText_SuitName.text = name
end
function UIComScreenItemV2:SetMainIcon(fileName)
end
function UIComScreenItemV2:SetBtnSuitVisible(visible)
  setactive(self.ui.mBtn_TypeScreen, visible)
end
function UIComScreenItemV2:AddSuitClickListener(action)
  self.onClickSuitCallback = action
end
function UIComScreenItemV2:AddSortTypeClickListener(action)
  self.onClickSortTypeCallback = action
end
function UIComScreenItemV2:AddReverseSortClickListener(action)
  self.onClickReverseSortCallback = action
end
function UIComScreenItemV2:OnClickSuit()
  if self.onClickSuitCallback then
    self.onClickSuitCallback()
  end
end
function UIComScreenItemV2:OnClickSortType()
  if self.onClickSortTypeCallback then
    self.onClickSortTypeCallback()
  end
end
function UIComScreenItemV2:OnClickReverseSort()
  if self.onClickReverseSortCallback then
    self.onClickReverseSortCallback()
  end
end
function UIComScreenItemV2:ActiveSortBtn(isActive)
  setactive(self.ui.mBtn_Screen.gameObject, isActive)
end
