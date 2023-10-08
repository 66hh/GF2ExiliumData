require("UI.UIBaseCtrl")
UIAchievementLeftTabItemV2 = class("UIAchievementLeftTabItemV2", UIBaseCtrl)
UIAchievementLeftTabItemV2.__index = UIAchievementLeftTabItemV2
function UIAchievementLeftTabItemV2:__InitCtrl()
end
function UIAchievementLeftTabItemV2:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("CommanderInfo/AchievementLeftTabItemV2.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
  end
  self.ui = {}
  self:SetRoot(obj.transform)
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:__InitCtrl()
end
function UIAchievementLeftTabItemV2:SetData(data)
  self.tagId = data.id
  self.tagName = data.tag_name
  self.mData = data
  self.ui.mText_Tittle.text = self.tagName.str
  self.ui.mImg_Icon.sprite = IconUtils.GetAchievementIconW(data.icon)
  self:RefreshData()
end
function UIAchievementLeftTabItemV2:RefreshData()
  local rewardId = NetCmdAchieveData:GetCurrentTagRewardId(self.mData.id)
  local rewardNotReceivedId = NetCmdAchieveData:GetCurrentNotReceivedTagRewardId(self.mData.id)
  local nextRewardData
  local count = 0
  local rewardData
  if rewardNotReceivedId == -1 then
    count = NetCmdAchieveData:GetCurrentTagRewardLevelProgress(self.mData)
    rewardData = TableData.listAchievementRewardDatas:GetDataById(rewardId)
    nextRewardData = TableData.listAchievementRewardDatas:GetDataById(rewardId + 1)
    if nextRewardData ~= nil and nextRewardData.lv_exp > NetCmdItemData:GetResCount(self.mData.point_item) then
      self.ui.mText_Progress.text = string.format("%d", math.floor(math.min(count / (nextRewardData.lv_exp - rewardData.lv_exp), 1) * 100)) .. "%"
    else
      local prevRewardData = TableData.listAchievementRewardDatas:GetDataById(rewardId - 1)
      self.ui.mText_Progress.text = string.format("%d", math.floor(math.min(count / (rewardData.lv_exp - prevRewardData.lv_exp), 1) * 100)) .. "%"
    end
  else
    rewardId = rewardNotReceivedId
    rewardData = TableData.listAchievementRewardDatas:GetDataById(rewardNotReceivedId)
    local prevRewardData = TableData.listAchievementRewardDatas:GetDataById(rewardId - 1)
    count = rewardData.lv_exp - prevRewardData.lv_exp
    self.ui.mText_Progress.text = string.format("%d", math.floor(math.min(count / (rewardData.lv_exp - prevRewardData.lv_exp), 1) * 100)) .. "%"
  end
  setactive(self.ui.mTrans_RedPoint, NetCmdAchieveData:TagRewardCanReceive(self.mData.id) or NetCmdAchieveData:CanReceiveByTagId(self.mData.id))
end
function UIAchievementLeftTabItemV2:SetItemState(isChoose)
  self.isChoose = isChoose
  UIUtils.SetInteractive(self.ui.mUIRoot, not isChoose)
end
