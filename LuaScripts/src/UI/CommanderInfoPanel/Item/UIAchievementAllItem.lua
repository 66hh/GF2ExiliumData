require("UI.UIBaseCtrl")
UIAchievementAllItem = class("UIAchievementAllItem", UIBaseCtrl)
UIAchievementAllItem.__index = UIAchievementAllItem
UIAchievementAllItem.mImg_Icon = nil
UIAchievementAllItem.mMask_ProgressBar = nil
UIAchievementAllItem.mText_ = nil
UIAchievementAllItem.mText_ = nil
UIAchievementAllItem.mText_Lv = nil
UIAchievementAllItem.mText_Progress = nil
UIAchievementAllItem.mTrans_RedPoint = nil
function UIAchievementAllItem:__InitCtrl()
end
function UIAchievementAllItem:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("CommanderInfo/AchievementAllItemV2.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
  end
  self.ui = {}
  self:SetRoot(obj.transform)
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:__InitCtrl()
end
function UIAchievementAllItem:SetData(data)
  self.mData = data
  self.ui.mText_Content.text = data.tag_name.str
  self.ui.mImg_Icon.sprite = IconUtils.GetAchievementIcon(data.icon, true)
  self:RefreshData()
end
function UIAchievementAllItem:RefreshData()
  local rewardId = NetCmdAchieveData:GetCurrentTagRewardId(self.mData.id)
  local rewardNotReceivedId = NetCmdAchieveData:GetCurrentNotReceivedTagRewardId(self.mData.id)
  local count = 0
  local rewardData, nextRewardData
  if rewardNotReceivedId == -1 then
    rewardData = TableData.listAchievementRewardDatas:GetDataById(rewardId)
    count = NetCmdAchieveData:GetCurrentTagRewardLevelProgress(self.mData)
    nextRewardData = TableData.listAchievementRewardDatas:GetDataById(rewardId + 1)
    if nextRewardData ~= nil and nextRewardData.lv_exp > NetCmdItemData:GetResCount(self.mData.point_item) then
      self.ui.mText_Progress.text = count .. "/" .. nextRewardData.lv_exp - rewardData.lv_exp
      self.ui.mMask_ProgressBar.FillAmount = count / (nextRewardData.lv_exp - rewardData.lv_exp)
    else
      local prevRewardData = TableData.listAchievementRewardDatas:GetDataById(rewardId - 1)
      self.ui.mText_Progress.text = count .. "/" .. rewardData.lv_exp - prevRewardData.lv_exp
      self.ui.mMask_ProgressBar.FillAmount = count / (rewardData.lv_exp - prevRewardData.lv_exp)
    end
    self.ui.mText_Lv.text = "Lv." .. rewardData.tag_lv
  else
    rewardId = rewardNotReceivedId
    rewardData = TableData.listAchievementRewardDatas:GetDataById(rewardNotReceivedId)
    local prevRewardData = TableData.listAchievementRewardDatas:GetDataById(rewardId - 1)
    count = rewardData.lv_exp - prevRewardData.lv_exp
    self.ui.mText_Progress.text = count .. "/" .. rewardData.lv_exp - prevRewardData.lv_exp
    self.ui.mMask_ProgressBar.FillAmount = count / (rewardData.lv_exp - prevRewardData.lv_exp)
    self.ui.mText_Lv.text = "Lv." .. prevRewardData.tag_lv
  end
  setactive(self.ui.mTrans_RedPoint, NetCmdAchieveData:TagRewardCanReceive(self.mData.id) or NetCmdAchieveData:CanReceiveByTagId(self.mData.id))
end
