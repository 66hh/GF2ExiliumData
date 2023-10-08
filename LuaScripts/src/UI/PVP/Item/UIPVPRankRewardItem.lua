UIPVPRankRewardItem = class("UIPVPRankRewardItem", UIBaseCtrl)
function UIPVPRankRewardItem:ctor()
end
function UIPVPRankRewardItem:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("PVP/PVPRankRewardItem.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, true)
  end
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(obj.transform, self.ui)
  self.rewardItemList = {}
  self.tabIndex = 1
  self.nrtpvpLevelData = nil
end
function UIPVPRankRewardItem:SetData(data, index)
  self.tabIndex = index
  self.nrtpvpLevelData = data
  UIPVPGlobal.GetRankImage(data.LevelId, self.ui.mImg_Rank, self.ui.mImg_RankBg)
  self.ui.mText_RankNum.text = data.Name.str
  print(TableData.GetHintById(120210))
  self.ui.mText_Score.text = TableData.GetHintById(120210) .. " " .. data.lower_limit_points
  local param = ""
  if index == 1 then
    param = "season_reward"
  elseif index == 2 then
    param = "upgrade_reward"
  end
  local rewardList = data[param]
  self:SetRewards(rewardList)
end
function UIPVPRankRewardItem:SetRewards(rewardList)
  local tmpRewardList = UIUtils.GetKVSortItemTable(rewardList)
  local tmpContent = self.ui.mTrans_Content
  for i = 0, tmpContent.childCount - 1 do
    setactive(tmpContent:GetChild(i).gameObject, true)
  end
  for i, v in ipairs(self.rewardItemList) do
    v:SetItemData(nil)
  end
  for i, v in ipairs(tmpRewardList) do
    local item
    if i <= #self.rewardItemList then
      item = self.rewardItemList[i]
    else
      item = UICommonItem.New()
      item:InitCtrl(self.ui.mTrans_Content)
      table.insert(self.rewardItemList, item)
    end
    item.mUIRoot:SetSiblingIndex(i - 1)
    setactive(tmpContent:GetChild(tmpContent.childCount - i).gameObject, false)
    item:SetItemData(v.id, v.num)
  end
  self:SetRewardState()
end
function UIPVPRankRewardItem:SetRewardState()
  setactive(self.ui.mTrans_RankNow.gameObject, false)
  setactive(self.ui.mTrans_Finished.gameObject, false)
  setactive(self.ui.mTrans_Unfinish.gameObject, false)
  setactive(self.ui.mTrans_Sel.gameObject, false)
  if self.tabIndex == 1 then
    setactive(self.ui.mTrans_RankNow.gameObject, self.nrtpvpLevelData.LevelId == NetCmdPVPData.PvpInfo.level)
    setactive(self.ui.mTrans_Sel.gameObject, self.nrtpvpLevelData.LevelId == NetCmdPVPData.PvpInfo.level)
  elseif self.tabIndex == 2 then
    setactive(self.ui.mTrans_RankNow.gameObject, self.nrtpvpLevelData.LevelId == NetCmdPVPData.PvpInfo.level)
    setactive(self.ui.mTrans_Sel.gameObject, self.nrtpvpLevelData.LevelId == NetCmdPVPData.PvpInfo.level)
  elseif self.tabIndex == 3 then
    local isFinish = self.nrtpvpLevelData.LevelId <= NetCmdPVPData.CurrSeasonMaxLevel
    setactive(self.ui.mTrans_Unfinish.gameObject, not isFinish)
    setactive(self.ui.mTrans_Finished.gameObject, isFinish)
  end
end
function UIPVPRankRewardItem:OnRelease()
  self.ui = nil
  self.rewardItemList = nil
end
