require("UI.PVP.Item.UIPVPRankRewardItem")
require("UI.Common.UIComTabBtn1ItemV2")
UIPVPRankRewardDialog = class("UIPVPRankRewardDialog", UIBasePanel)
function UIPVPRankRewardDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIPVPRankRewardDialog:OnInit(root)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.topTabTable = {}
  self.curRewardDataTable = {}
  self.notRewardCount = 0
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIPVPRankRewardDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIPVPRankRewardDialog)
  end
  function self.ui.mVirtualListEx_RewardList.itemProvider()
    return self:ItemProvider()
  end
  function self.ui.mVirtualListEx_RewardList.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
end
function UIPVPRankRewardDialog:OnShowStart()
  self:InitTopTabs()
  self:ChangeTab2Next(self.topTabTable[1])
end
function UIPVPRankRewardDialog:OnShowFinish()
end
function UIPVPRankRewardDialog:OnHide()
end
function UIPVPRankRewardDialog:OnClose()
  self.ui = nil
  self:ReleaseCtrlTable(self.topTabTable)
  self.topTabTable = nil
  self.curTabItem = nil
  self.curRewardDataTable = nil
end
function UIPVPRankRewardDialog:InitTopTabs()
  local hintIdList = {120062, 120063}
  if NetCmdPVPData.seasonData.season_id == 1 then
    hintIdList = {120147, 120063}
  end
  for i = 1, 2 do
    do
      local tabItem = UIComTabBtn1ItemV2.New()
      table.insert(self.topTabTable, tabItem)
      local data = {
        index = i,
        name = TableData.GetHintById(hintIdList[i])
      }
      tabItem:InitCtrl(self.ui.mScrollListChild_GrpTabBtn.gameObject, data)
      tabItem:AddClickListener(function()
        self:ChangeTab2Next(tabItem)
      end)
    end
  end
end
function UIPVPRankRewardDialog:ChangeTab2Next(tabItem)
  if tabItem == self.curTabItem then
    return
  end
  if self.curTabItem ~= nil then
    self.curTabItem:SetBtnInteractable(true)
  end
  self.curTabItem = tabItem
  self.curTabItem:SetBtnInteractable(false)
  self:RefreshRewardContents(tabItem.index)
end
function UIPVPRankRewardDialog:RefreshRewardContents()
  self.curRewardDataTable = self:GetPvpRewardByParameter()
  self.ui.mVirtualListEx_RewardList.numItems = #self.curRewardDataTable
  self.ui.mVirtualListEx_RewardList:SetConstraintCount(1)
  self.ui.mVirtualListEx_RewardList:Refresh()
  self.ui.mScrollListChild_Content.transform:GetComponent(typeof(CS.MonoScrollerFadeManager)).enabled = false
  self.ui.mScrollListChild_Content.transform:GetComponent(typeof(CS.MonoScrollerFadeManager)).enabled = true
  self:ScrollToPosByIndex(NetCmdPVPData.CurrSeasonMaxLevel - self.notRewardCount)
end
function UIPVPRankRewardDialog:GetPvpRewardByParameter()
  local temp = {}
  local nrtPvpLevelIds = UIPVPGlobal.GetCurSeasonLevelDataIdList()
  local nrtpvpLevelData
  self.notRewardCount = 0
  for i = 0, nrtPvpLevelIds.Count - 1 do
    nrtpvpLevelData = TableData.listNrtpvpLevelDatas:GetDataById(nrtPvpLevelIds[i])
    local param
    if self.curTabItem.index == 1 then
      param = "season_reward"
    else
      param = "upgrade_reward"
    end
    if nrtpvpLevelData[param] == nil or nrtpvpLevelData[param].Count == 0 then
      self.notRewardCount = self.notRewardCount + 1
    else
      table.insert(temp, nrtpvpLevelData)
    end
  end
  return temp
end
function UIPVPRankRewardDialog:ItemProvider()
  local itemView = UIPVPRankRewardItem.New()
  itemView:InitCtrl(self.ui.mScrollListChild_Content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIPVPRankRewardDialog:ItemRenderer(index, renderData)
  if self.curRewardDataTable == nil or #self.curRewardDataTable == 0 then
    return
  end
  local data = self.curRewardDataTable[index + 1]
  local item = renderData.data
  item:SetData(data, self.curTabItem.index)
end
function UIPVPRankRewardDialog:ScrollToPosByIndex(index, needAni)
  local content = self.ui.mScrollListChild_Content:GetComponent("RectTransform")
  local gridLayoutGroup = content.transform:GetComponent("GridLayoutGroup")
  local offset = gridLayoutGroup.spacing.y + gridLayoutGroup.cellSize.y
  local moveY = offset * (index - 1)
  if needAni then
    content:DOAnchorPosY(moveY, 0.5)
  else
    content.anchoredPosition = Vector2(content.anchoredPosition.x, moveY)
  end
end
