UISevenQuestTabItem = class("UISevenQuestTabItem", UIBaseCtrl)
function UISevenQuestTabItem:ctor()
end
function UISevenQuestTabItem:InitCtrl(root, data)
  local instObj = instantiate(UIUtils.GetGizmosPrefab("Activity/SevenQuest/Btn_SevenQuestTabItem.prefab", self))
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
function UISevenQuestTabItem:AddClickListener(callback)
  self.clickAction = callback
end
function UISevenQuestTabItem:SetBtnInteractable(interactable)
  self.ui.mBtn_ComTab1ItemV2.interactable = interactable
end
function UISevenQuestTabItem:SetLockVisible(visible)
  setactive(self.ui.mTrans_Locked, visible)
  setactive(self.ui.mTrans_Check, not visible)
  setactive(self.ui.mTrans_Normal, not visible)
  self.ui.mCanvasGroup_Text.alpha = 0.2
end
function UISevenQuestTabItem:SetRedPointVisible(visible)
  setactive(self.ui.mTrans_RedPoint, visible)
end
function UISevenQuestTabItem:SetCheckVisible(visible)
  setactive(self.ui.mTrans_Check, visible)
  setactive(self.ui.mTrans_Normal, not visible)
  setactive(self.ui.mTrans_Locked, false)
  self.ui.mCanvasGroup_Text.alpha = 1
end
function UISevenQuestTabItem:OnRelease()
  gfdestroy(self.mUIRoot)
  UIUtils.GetButtonListener(self.ui.mBtn_ComTab1ItemV2.gameObject).onClick = nil
  self.ui = nil
  self.clickAction = nil
end
