UICommanderInfoAchievementItem = class("UICommanderInfoAchievementItem", UIBaseCtrl)
UICommanderInfoAchievementItem.__index = UICommanderInfoAchievementItem
UICommanderInfoAchievementItem.RankType = {
  Gold = CS.ProtoObject.AchieveRank.Gold.value__,
  Silver = CS.ProtoObject.AchieveRank.Silver.value__,
  Copper = CS.ProtoObject.AchieveRank.Copper.value__,
  Iron = CS.ProtoObject.AchieveRank.Iron.value__,
  Plastics = CS.ProtoObject.AchieveRank.Plastics.value__
}
function UICommanderInfoAchievementItem:ctor()
end
function UICommanderInfoAchievementItem:InitCtrl(prefab, parent)
  local obj = instantiate(prefab, parent)
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self.mData = nil
end
function UICommanderInfoAchievementItem:SetData(achieveNum, icon)
  self.ui.mImg_Icon.sprite = IconUtils.GetAchievementIcon(icon, true)
  self.ui.mText_Num.text = achieveNum
end
function UICommanderInfoAchievementItem:OnRelease()
  gfdestroy(self:GetRoot())
end
