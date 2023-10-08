UIComBtn3ItemR = class("UIComBtn3ItemR", UIBaseCtrl)
function UIComBtn3ItemR:ctor(parent, go)
  go = go or self:Instantiate("UICommonFramework/ComBtn3ItemR.prefab", parent)
  self.ui = UIUtils.GetUIBindTable(go)
  self.ui.mBtn_ComBtn3ItemR.onClick:AddListener(function()
    self:OnClick()
  end)
end
function UIComBtn3ItemR:Refresh()
end
function UIComBtn3ItemR:OnRelease()
  self.ui.mBtn_ComBtn3ItemR.onClick = nil
  self.ui = nil
  self.onClickCallback = nil
  self.super.OnRelease(self)
end
function UIComBtn3ItemR:AddClickListener(action)
  self.onClickCallback = action
end
function UIComBtn3ItemR:OnClick()
  if self.onClickCallback then
    self.onClickCallback()
  end
end
function UIComBtn3ItemR:SetName(name)
  self.ui.mText_Name.text = name
end
function UIComBtn3ItemR:SetRedPointVisible(visible)
  setactive(self.ui.mTrans_RedPoint, visible)
end
