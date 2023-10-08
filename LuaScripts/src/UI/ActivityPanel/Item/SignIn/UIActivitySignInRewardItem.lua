require("UI.UIBaseCtrl")
UIActivitySignInRewardItem = class("UIActivitySignInRewardItem", UIBaseCtrl)
UIActivitySignInRewardItem.__index = UIActivitySignInRewardItem
function UIActivitySignInRewardItem:ctor()
  self.super.ctor(self)
end
function UIActivitySignInRewardItem:InitCtrl(itemPrefab, parent, onClick)
  local instObj = instantiate(itemPrefab, parent)
  self:SetRoot(instObj.transform)
  self.mOnClick = onClick
  self.ui = {}
  self:LuaUIBindTable(instObj.transform, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_SignIn.gameObject).onClick = function()
    if not NetCmdOperationActivityData:IsActivityOpen(self.mActivityId) then
      UIManager.CloseUI(UIDef.UIActivityDialog)
      UIUtils.PopupErrorWithHint(260007)
      return
    end
    if not self.mIsCanSign then
      UITipsPanel.Open(self.itemData)
      return
    end
    self.mOnClick(self.mDayIndex)
  end
end
function UIActivitySignInRewardItem:SetData(activityId, rewardData, todayIsCheck, alreadyCheckDays)
  self.mActivityId = activityId
  self.mDayIndex = rewardData.days
  local isAlreadySignIn = alreadyCheckDays >= self.mDayIndex
  self.mIsCanSign = not todayIsCheck and alreadyCheckDays + 1 == self.mDayIndex
  local isShowTomorrowCanGet = todayIsCheck and alreadyCheckDays + 1 == self.mDayIndex
  setactive(self.ui.mTrans_AlreadySignIn, isAlreadySignIn)
  setactive(self.ui.mTrans_CanSignIn, self.mIsCanSign)
  setactive(self.ui.mTrans_TomorrowCanGet, isShowTomorrowCanGet)
  self.ui.mText_Day.text = UIUtils.StringFormat("{0:D2}", self.mDayIndex)
  local itemId, itemCount
  for id, count in pairs(rewardData.rewards) do
    itemId = id
    itemCount = count
    self.itemData = TableData.GetItemData(itemId)
  end
  if not itemId then
    print_cyan("SignIn Activity Reward CanNot Is NUll")
    return
  end
  self.ui.mImage_ItemIcon.sprite = UIUtils.GetItemIcon(itemId)
  self.ui.mText_ItemName.text = UIUtils.GetItemName(itemId)
  self.ui.mText_RewardCount.text = UIUtils.StringFormatWithHintId(260005, itemCount)
end
