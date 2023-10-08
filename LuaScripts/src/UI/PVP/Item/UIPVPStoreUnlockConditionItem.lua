require("UI.UIBaseCtrl")
UIPVPStoreUnlockConditionItem = class("UIPVPStoreUnlockConditionItem", UIBaseCtrl)
UIPVPStoreUnlockConditionItem.__index = UIPVPStoreUnlockConditionItem
local self = UIPVPStoreUnlockConditionItem
function UIPVPStoreUnlockConditionItem:ctor()
  self.leftTab = UIPVPGlobal.LeftTabList.Rank
end
function UIPVPStoreUnlockConditionItem:InitCtrl(obj, parent)
  local objIns = instantiate(obj, parent)
  self.ui = {}
  self:LuaUIBindTable(objIns, self.ui)
  setactive(objIns, true)
  self:SetRoot(objIns.transform)
end
function UIPVPStoreUnlockConditionItem:SetData(data)
  self.mData = data
  self.ui.mText_Condition.text = data
end
function UIPVPStoreUnlockConditionItem:SetLock()
  self.ui.mAnimator_Bought:SetBool("Unlock", false)
end
function UIPVPStoreUnlockConditionItem:SetComplete()
  self.ui.mAnimator_Bought:SetBool("Unlock", true)
end
