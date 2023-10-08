require("UI.UIBaseCtrl")
require("UI.Common.UICommonItem")
UIWeeklyChallengeProgressDialogItem = class("UIWeeklyChallengeProgressDialogItem", UIBaseCtrl)
UIWeeklyChallengeProgressDialogItem.__index = UIWeeklyChallengeProgressDialogItem
function UIWeeklyChallengeProgressDialogItem:ctor()
  self.super.ctor(self)
  self.itemTable = {}
end
function UIWeeklyChallengeProgressDialogItem:InitCtrl(parent, itemPrefab, onclick)
  local instObj = instantiate(itemPrefab, parent)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(instObj.transform, self.ui)
  UIUtils.GetButtonListener(self.ui.mTrans_Receive.gameObject).onClick = function()
    onclick(self.mData)
  end
end
function UIWeeklyChallengeProgressDialogItem:SetData(data)
  self.mData = data
  self:UpdateItem()
end
function UIWeeklyChallengeProgressDialogItem:UpdateItem()
  self.ui.mText_Tittle.text = self.mData.name
  self.ui.mText_Progress.text = UIUtils.StringFormatWithHintId(112016, UIUtils.ChangeNumByDigit(self.mData.currentCount), UIUtils.ChangeNumByDigit(self.mData.targetCount))
  self.ui.mText_Progress.color = self.mData.isComplete and ColorUtils.OrangeColor or ColorUtils.UpMapColor
  self.ui.mImage_Progress.fillAmount = self.mData:GetProgressPercent()
  setactive(self.ui.mTrans_Unfinished, not self.mData.isComplete)
  setactive(self.ui.mTrans_Receive.transform, self.mData.isComplete and not self.mData.isReceived)
  setactive(self.ui.mTrans_RedPoint.transform, self.mData.isComplete and not self.mData.isReceived)
  setactive(self.ui.mTrans_Finished, self.mData.isComplete and self.mData.isReceived)
  local sortReward = UIUtils.GetKVSortItemTable(self.mData.reward)
  local index = 1
  for __, itemData in ipairs(sortReward) do
    local item
    if not self.itemTable[index] then
      item = UICommonItem.New()
      item:InitCtrl(self.ui.mScrollItem_Atom.transform)
      table.insert(self.itemTable, item)
    else
      item = self.itemTable[index]
    end
    index = index + 1
    if item then
      item:SetItemData(itemData.id, itemData.num)
    end
  end
  local rewardCount = #sortReward
  setactive(self.ui.mTrans_EmptyRewardSlot1, rewardCount <= 0)
  setactive(self.ui.mTrans_EmptyRewardSlot2, rewardCount <= 1)
  self.ui.mTrans_EmptyRewardSlot1:SetAsLastSibling()
  self.ui.mTrans_EmptyRewardSlot2:SetAsLastSibling()
end
