require("UI.UIBaseCtrl")
require("UI.ActivityPanel.Item.UIActivityItemBase")
require("UI.ActivityPanel.Item.SignIn.UIActivitySignInRewardItem")
UIActivitySignInItem = class("UIActivitySignInItem", UIActivityItemBase)
UIActivitySignInItem.__index = UIActivitySignInItem
function UIActivitySignInItem:OnInit()
  self.mUIRewardList = {}
end
function UIActivitySignInItem:OnShow()
  self.ui.mText_Name.text = self.mActivityTableData.name.str
  self.ui.mText_Time:StartCountdown(self.mCloseTime)
  self:RefreshList()
end
function UIActivitySignInItem:OnHide()
end
function UIActivitySignInItem:RefreshList()
  local todayIsCheck, alreadyCheckDays = NetCmdOperationActivity_SignInData:GetSignData(self.mActivityID)
  local rewards = TableDataBase.listEventSigninRewardByActivityIdDatas:GetDataById(self.mActivityID).Id
  self.ui.mScroll_Reward.enabled = rewards.Count > 7
  for i = 1, rewards.Count do
    local rewardId = rewards[i - 1]
    local rewardData = TableDataBase.listEventSigninRewardDatas:GetDataById(rewardId)
    local rewardItem = self.mUIRewardList[i]
    if not rewardItem then
      rewardItem = UIActivitySignInRewardItem.New()
      rewardItem:InitCtrl(self.ui.mTrans_RewardList.childItem, self.ui.mTrans_RewardList.transform, function(dayIndex)
        self:OnClickSignIn()
      end)
      table.insert(self.mUIRewardList, rewardItem)
    end
    rewardItem:SetData(self.mActivityID, rewardData, todayIsCheck, alreadyCheckDays)
  end
  table.sort(self.mUIRewardList, function(a, b)
    return a.mDayIndex < b.mDayIndex
  end)
  for i = 1, #self.mUIRewardList do
    local item = self.mUIRewardList[i]
    if item and item.mUIRoot then
      item.mUIRoot:SetAsLastSibling()
    end
  end
end
function UIActivitySignInItem:OnClickSignIn()
  NetCmdOperationActivity_SignInData:SignIn(self.mActivityID, function(ret)
    if ret == ErrorCodeSuc then
      UIManager.OpenUI(UIDef.UICommonReceivePanel)
    end
  end)
end
function UIActivitySignInItem:OnTop()
  self:OnShow()
end
function UIActivitySignInItem:OnClose()
end
