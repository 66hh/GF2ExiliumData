require("UI.UIBaseCtrl")
BpUnlockRewardItem = class("BpUnlockRewardItem", UIBaseCtrl)
BpUnlockRewardItem.__index = BpUnlockRewardItem
function BpUnlockRewardItem:__InitCtrl()
end
function BpUnlockRewardItem:InitCtrl(parent)
  self.obj = instantiate(UIUtils.GetGizmosPrefab("BattlePass/BpUnlockRewardItemV3.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(self.obj.gameObject, parent.gameObject, false)
  end
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  self:SetRoot(self.obj.transform)
  self:__InitCtrl()
  self.ui.mAni_Root.keepAnimatorControllerStateOnDisable = true
  self.mRewardItem = UICommonItem.New()
  self.mRewardItem:InitCtrl(self.ui.mSListChild_ComItem.transform, true)
end
function BpUnlockRewardItem:SetData(bpUnlockRewardData, isPlus)
  if bpUnlockRewardData ~= nil then
    self.ui.mText_Name.text = bpUnlockRewardData.item_explain
    self.mRewardItem:SetItemData(bpUnlockRewardData.ShowItemId, nil)
    self.ui.mText_Reward.text = bpUnlockRewardData.item_explain
  end
  self.ui.mAni_Root:SetBool("Promote", isPlus)
end
function BpUnlockRewardItem:OnRelease()
  gfdestroy(self.obj)
end
