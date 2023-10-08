require("UI.UIBaseCtrl")
ArchivesCenterAchievementLeftTabItemV2 = class("ArchivesCenterAchievementLeftTabItemV2", UIBaseCtrl)
ArchivesCenterAchievementLeftTabItemV2.__index = ArchivesCenterAchievementLeftTabItemV2
function ArchivesCenterAchievementLeftTabItemV2:ctor()
end
function ArchivesCenterAchievementLeftTabItemV2:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
end
function ArchivesCenterAchievementLeftTabItemV2:SetData(data)
  self.tagId = data.id
  self.mData = data
  self.ui.mText_Name.text = data.tag_name.str
  self.ui.mImg_Icon.sprite = IconUtils.GetAchievementIconW(data.icon)
  self.total = NetCmdAchieveData:GetDataCountByTag(self.mData.id)
  self:RefreshData()
end
function ArchivesCenterAchievementLeftTabItemV2:RefreshData()
  local count = NetCmdAchieveData:GetDataProcessByTag(self.mData.id)
  self.ui.mText_Num.text = count .. "<color=#8D9398>/" .. self.total .. "</color>"
  setactive(self.ui.mTrans_RedPoint, NetCmdAchieveData:TagRewardCanReceive(self.mData.id) or NetCmdAchieveData:CanReceiveByTagId(self.mData.id))
end
function ArchivesCenterAchievementLeftTabItemV2:SetItemState(isChoose)
  self.ui.mBtn_Root.interactable = not isChoose
  local count = NetCmdAchieveData:GetDataProcessByTag(self.mData.id)
  if isChoose then
    self.ui.mText_Num.text = count .. "<color=#838B90>/" .. self.total .. "</color>"
  else
    self.ui.mText_Num.text = count .. "<color=#8D9398>/" .. self.total .. "</color>"
  end
end
