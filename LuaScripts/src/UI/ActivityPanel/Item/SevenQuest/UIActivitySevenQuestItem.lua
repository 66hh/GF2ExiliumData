require("UI.UIBaseCtrl")
require("UI.ActivityPanel.Item.UIActivityItemBase")
require("UI.Common.UICommonItem")
require("UI.ActivitySevenQuestPanel.UISevenQuestPanel")
UIActivitySevenQuestItem = class("UIActivitySevenQuestItem", UIActivityItemBase)
UIActivitySevenQuestItem.__index = UIActivitySevenQuestItem
function UIActivitySevenQuestItem:OnInit()
end
function UIActivitySevenQuestItem:OnShow()
  self.ui.mText_Name.text = self.mActivityTableData.name.str
  self.ui.mText_Time:StartCountdown(self.mCloseTime)
  self.ui.mTextFit_Info.text = self.mActivityTableData.desc.str
  local rewards = NetCmdOperationActivityData:GetRewarShow(self.mActivityID)
  if self.UICommonItems ~= nil then
    self:ReleaseCtrlTable(self.UICommonItems, true)
  end
  self.UICommonItems = {}
  for i = 0, rewards.Length - 1 do
    local item = UICommonItem.New()
    item:InitCtrl(self.ui.mTrans_Content)
    table.insert(self.UICommonItems, item)
    local itemData = TableData.GetItemData(rewards[i])
    item:SetItemByStcData(itemData, 0)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Goto.gameObject).onClick = function()
    UIManager.OpenUIByParam(UIDef.UISevenQuestPanel, {
      closeTime = self.mCloseTime
    })
  end
  NetCmdActivitySevenQuestData:SendGetActivityNewbie(function(ret)
    if ret == ErrorCodeSuc then
      local redPoint = self.ui.mBtn_Goto.transform:Find("Root/Trans_RedPoint")
      setactive(redPoint.gameObject, NetCmdActivitySevenQuestData:UpdateRedPoint() > 0)
    end
  end)
end
function UIActivitySevenQuestItem:OnHide()
end
function UIActivitySevenQuestItem:OnTop()
  self:OnShow()
end
function UIActivitySevenQuestItem:OnClose()
  self:ReleaseCtrlTable(self.UICommonItems, true)
end
