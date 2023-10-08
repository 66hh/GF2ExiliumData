require("UI.UIBaseCtrl")
require("UI.Common.UICommonItem")
require("UI.ActivityPanel.Item.UIActivityItemBase")
require("UI.SimpleMessageBox.SimpleMessageBoxPanel")
UIActivityAmoWishItem = class("UIActivityAmoWishItem", UIActivityItemBase)
UIActivityAmoWishItem.__index = UIActivityAmoWishItem
function UIActivityAmoWishItem:OnInit()
  self.mUIRewardList = {}
  self.mRedPointObj = self:InstanceUIPrefab("UICommonFramework/ComRedPointItemV2.prefab", self.ui.mScrollItem_RedPoint, true)
end
function UIActivityAmoWishItem:OnShow()
  self.ui.mText_TextAcName.text = self.mActivityTableData.name.str
  local amoActivityMainData = TableData.listAmoActivityMainDatas:GetDataById(self.mActivityTableData.id)
  if amoActivityMainData == nil then
    return
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Detail.gameObject).onClick = function()
    SimpleMessageBoxPanel.ShowByParam(TableData.GetHintById(64), amoActivityMainData.long_description)
  end
  local planActivityData = TableData.listActivityListDatas:GetDataById(self.mActivityTableData.id)
  if planActivityData == nil then
    return
  end
  self.ui.mText_Time:StartCountdown(planActivityData.close_time)
  self.ui.mTextFit_Info.text = amoActivityMainData.short_description
  if self.mRewardTable ~= nil then
    for _, v in pairs(self.mRewardTable) do
      gfdestroy(v:GetRoot())
    end
  end
  self.mRewardTable = {}
  local index = 1
  local rewards = string.split(amoActivityMainData.reward_show, ",")
  for k, v in pairs(rewards) do
    local item = self.mRewardTable[index]
    if item == nil then
      item = UICommonItem.New()
      item:InitCtrl(self.ui.mSListChild_Content)
      table.insert(self.mRewardTable, item)
    end
    local itemData = TableData.GetItemData(tonumber(v))
    item:SetItemByStcData(itemData, 0)
    index = index + 1
  end
  local amoActivityId = self.mActivityID
  UIUtils.GetButtonListener(self.ui.mBtn_Goto.gameObject).onClick = function()
    if planActivityData.close_time < CGameTime:GetTimestamp() then
      UIUtils.PopupHintMessage(260044)
      return
    end
    NetCmdActivityAmoData:SendActivityAmoStart(amoActivityId, function(ret)
      if ret == ErrorCodeSuc then
        NetCmdActivityAmoData:SendGetActivityAmo(function(ret)
          if ret ~= ErrorCodeSuc then
            return
          end
          UIManager.OpenUIByParam(UIDef.UIActivityAimoWishPanel, planActivityData)
        end)
      end
    end)
  end
  local redPoint = NetCmdActivityAmoData:CheckHasRedPoint(amoActivityId)
  setactive(self.ui.mScrollItem_RedPoint, 0 < redPoint)
end
function UIActivityAmoWishItem:OnHide()
  for _, v in pairs(self.mRewardTable) do
    gfdestroy(v:GetRoot())
  end
  gfdestroy(self.mRedPointObj)
end
function UIActivityAmoWishItem:RefreshList()
end
function UIActivityAmoWishItem:OnTop()
  local redPoint = NetCmdActivityAmoData:CheckHasRedPoint(self.mActivityID)
  setactive(self.ui.mScrollItem_RedPoint, 0 < redPoint)
end
function UIActivityAmoWishItem:OnClose()
  for _, v in pairs(self.mRewardTable) do
    gfdestroy(v:GetRoot())
  end
end
