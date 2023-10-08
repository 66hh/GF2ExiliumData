UIComTabBtn1ItemV2 = class("UIComTabBtn1ItemV2", UIBaseCtrl)
function UIComTabBtn1ItemV2:ctor()
end
function UIComTabBtn1ItemV2:InitCtrl(root, data)
  local instObj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComTabBtn1ItemV2.prefab", self))
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  UIUtils.AddListItem(instObj.gameObject, root)
  self:SetRoot(instObj.transform)
  self.index = data.index
  self.ui.mText_Name.text = data.name
  self.clickAction = nil
  UIUtils.GetButtonListener(self.ui.mBtn_ComTab1ItemV2.gameObject).onClick = function()
    if self.clickAction then
      self.clickAction()
    end
  end
end
function UIComTabBtn1ItemV2:AddClickListener(callback)
  self.clickAction = callback
end
function UIComTabBtn1ItemV2:SetBtnInteractable(interactable)
  self.ui.mBtn_ComTab1ItemV2.interactable = interactable
end
function UIComTabBtn1ItemV2:SetLockVisible(visible)
  setactive(self.ui.mTrans_Locked, visible)
end
function UIComTabBtn1ItemV2:SetRedPointVisible(visible)
  setactive(self.ui.mTrans_RedPoint, visible)
end
function UIComTabBtn1ItemV2:SetCheckVisible(visible)
  setactive(self.ui.mTrans_Check, visible)
end
function UIComTabBtn1ItemV2:OnRelease()
  gfdestroy(self.mUIRoot)
  UIUtils.GetButtonListener(self.ui.mBtn_ComTab1ItemV2.gameObject).onClick = nil
  self.ui = nil
  self.clickAction = nil
end
