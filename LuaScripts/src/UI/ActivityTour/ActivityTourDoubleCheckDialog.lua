require("UI.UIBasePanel")
require("UI.Common.UICommonItem")
require("UI.MonopolyActivity.ActivityTourGlobal")
ActivityTourDoubleCheckDialog = class("ActivityTourDoubleCheckDialog", UIBasePanel)
ActivityTourDoubleCheckDialog.__index = ActivityTourDoubleCheckDialog
function ActivityTourDoubleCheckDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function ActivityTourDoubleCheckDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:ManualUI()
end
function ActivityTourDoubleCheckDialog:ManualUI()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ActivityTourDoubleCheckDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close1.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ActivityTourDoubleCheckDialog)
  end
  UIUtils.GetButtonListener(self.ui.mTrans_BtnLeave.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ActivityTourDoubleCheckDialog)
    if SceneSys.CurSceneType == CS.EnumSceneType.Monopoly then
      NetCmdMonopolyData:ReturnToMainPanel()
    end
  end
  UIUtils.GetButtonListener(self.ui.mTrans_BtnEnd.gameObject).onClick = function()
    NetCmdMonopolyData:SendStopMonopoly(self.themeId, function(errorCode)
      if errorCode == ErrorCodeSuc then
        UIManager.CloseUI(UIDef.ActivityTourDoubleCheckDialog)
        MonopolyWorld:ChangeGameEnd(self.themeId)
      end
    end)
  end
  self.rewardUILits = {}
  self.ui.mText_Title.text = TableData.GetHintById(270090)
  self.ui.mText_Content.text = TableData.GetHintById(270218) .. "\n" .. TableData.GetHintById(270219)
end
function ActivityTourDoubleCheckDialog:ItemProvider()
  local itemView = UICommonItem.New()
  itemView:InitCtrl(self.ui.mTrans_Content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function ActivityTourDoubleCheckDialog:ItemRenderer(index, renderData)
  local itemData = self.rewardDataList[index]
  local item = renderData.data
  item:SetItemData(itemData.Id, itemData.Num, nil, nil, nil, nil, nil, function()
    UITipsPanel.Open(TableData.GetItemData(itemData.Id))
  end)
end
function ActivityTourDoubleCheckDialog:UpdateReward()
  for i = 1, self.rewardDataList.Count do
    do
      local itemView = self.rewardUILits[i]
      if itemView == nil then
        itemView = UICommonItem.New()
        itemView:InitCtrl(self.ui.mTrans_Content)
        setactive(itemView.ui.mBtn_Select.gameObject, true)
        table.insert(self.rewardUILits, itemView)
      end
      local itemData = self.rewardDataList[i - 1]
      itemView:SetItemData(itemData.Id, itemData.Num, nil, nil, nil, nil, nil, function()
        UITipsPanel.Open(TableData.GetItemData(itemData.Id))
      end)
    end
  end
  if #self.rewardUILits > self.rewardDataList.Count then
    for i = self.rewardDataList.Count + 1, #self.rewardUILits do
      setactive(self.rewardUILits[i].ui.mBtn_Select.gameObject, false)
    end
  end
end
function ActivityTourDoubleCheckDialog:OnInit(root, data)
  self.themeId = data.themeId
  self.rewardDataList = NetCmdThemeData:GetCollections()
  self:UpdateReward()
  setactive(self.ui.mTrans_Empty.gameObject, self.rewardDataList.Count == 0)
  setactive(self.ui.mTrans_RewardList.gameObject, self.rewardDataList.Count > 0)
  ActivityTourGlobal.ReplaceAllColor(self.mUIRoot)
end
function ActivityTourDoubleCheckDialog:OnShowStart()
end
function ActivityTourDoubleCheckDialog:OnShowFinish()
end
function ActivityTourDoubleCheckDialog:OnTop()
end
function ActivityTourDoubleCheckDialog:OnBackFrom()
end
function ActivityTourDoubleCheckDialog:OnClose()
  self.themeId = nil
end
function ActivityTourDoubleCheckDialog:OnHide()
end
function ActivityTourDoubleCheckDialog:OnHideFinish()
end
function ActivityTourDoubleCheckDialog:OnRelease()
end
