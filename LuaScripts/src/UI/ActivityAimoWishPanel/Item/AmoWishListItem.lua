require("UI.UIBaseCtrl")
AmoWishListItem = class("AmoWishListItem", UIBaseCtrl)
AmoWishListItem.__index = AmoWishListItem
function AmoWishListItem:__InitCtrl()
end
function AmoWishListItem:InitCtrl(parent)
  self.obj = instantiate(UIUtils.GetGizmosPrefab("Activity/AmoWish/Btn_AmoWishListItem.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(self.obj.gameObject, parent.gameObject, false)
  end
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  self:SetRoot(self.obj.transform)
  self:__InitCtrl()
  UIUtils.GetButtonListener(self.ui.mBtn_Root.transform).onClick = function()
    if self.mActivityAmo == nil then
      CS.PopupMessageManager.PopupString(self.mLockStr)
      return
    end
    MessageSys:SendMessage(UIEvent.RefreshAimoWish, self.mData.id)
  end
  function self.mGetAimoWishReward(sender)
    self:SetData(self.mData.id, self.mIsLast, self.mPlanActivityData)
  end
  MessageSys:AddListener(UIEvent.GetAimoWishReward, self.mGetAimoWishReward)
end
function AmoWishListItem:SetData(id, isLast, planActivityData)
  local data = TableData.listAmoActivitySubDatas:GetDataById(id)
  self.mIsLast = isLast
  self.mData = data
  self.mPlanActivityData = planActivityData
  self.ui.mImg_ChrHead.sprite = IconUtils.GetCharacterHeadSprite(data.theme_icon)
  self.ui.mText_Name.text = data.name_gun
  self.ui.mText_Name1.text = data.name_gun
  if string.len(data.theme_short_description) > 21 then
    local newstr = string.sub(data.theme_short_description, 1, 21)
    self.ui.mText_Chr.text = newstr .. "..."
  else
    self.ui.mText_Chr.text = data.theme_short_description
  end
  self.mActivityAmo = NetCmdActivityAmoData:GetActivityAmo(self.mPlanActivityData.id, data.id)
  setactive(self.ui.mTrans_Line, not isLast)
  if self.mActivityAmo == nil then
    local unlockDays = NetCmdActivityAmoData:GetUnlockDays(self.mPlanActivityData.id, data.id)
    self.mLockStr = string_format(TableData.GetHintById(260019), CS.TimeUtils.GetLeftTimeToRefreshDate(unlockDays))
    self.ui.mText_Name1.text = self.mLockStr
  end
  self.ui.mAni_Root:SetBool("Locked", self.mActivityAmo ~= nil)
  local isMainQuestRewardGet = NetCmdActivityAmoData:HasMainQuestRewardGet(data.id)
  local isUnlock = NetCmdActivityAmoData:GetMainQuestUnlock(data.id)
  setactive(self.ui.mTrans_RedPoint, isUnlock and not isMainQuestRewardGet)
end
function AmoWishListItem:SetInteractable(interactable)
  self.ui.mBtn_Root.interactable = interactable
end
function AmoWishListItem:OnRelease()
  MessageSys:RemoveListener(UIEvent.GetAimoWishReward, self.mGetAimoWishReward)
  self.super.OnRelease(self, true)
end
function AmoWishListItem:UpdateRedPoint(show)
end
