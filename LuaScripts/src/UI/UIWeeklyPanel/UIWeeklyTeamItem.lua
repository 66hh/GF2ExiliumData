require("UI.UIBaseCtrl")
require("UI.UIWeeklyPanel.UIWeeklyChrAvatarItem")
require("UI.UIWeeklyPanel.UIWeeklyDefine")
UIWeeklyTeamItem = class("UIWeeklyTeamItem", UIBaseCtrl)
UIWeeklyTeamItem.__index = UIWeeklyTeamItem
function UIWeeklyTeamItem:ctor()
  self.super.ctor(self)
end
function UIWeeklyTeamItem:InitCtrl(itemPrefab, parent)
  local instObj = instantiate(itemPrefab, parent)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(instObj.transform, self.ui)
  self.mUIGunList = {}
end
function UIWeeklyTeamItem:SetData(weeklyData, index, teamIds)
  self.mWeeklyData = weeklyData
  self.mIndex = index
  self.mTeamIds = teamIds
  self.ui.mText_Num.text = UIUtils.StringFormat("{0:d2}", index)
  setactive(self.ui.mTrans_Complete, index < self.mWeeklyData.bStageIndex + 1)
  self:UpdateTeam()
end
function UIWeeklyTeamItem:UpdateTeam()
  if self.mTeamIds == nil then
    return
  end
  local serverCount = self.mTeamIds.Count
  local teamRootTransform = self.ui.mScrollChild_Item.transform
  for i = 1, UIWeeklyDefine.TeamMaxGunCount do
    local item
    if self.mUIGunList[i] then
      item = self.mUIGunList[i]
    else
      item = UIWeeklyChrAvatarItem.New()
      item:InitCtrl(teamRootTransform, function(gunCmdData)
        self:OnTeamAvatarClick(gunCmdData)
      end)
      table.insert(self.mUIGunList, item)
    end
    local gunData
    if i <= serverCount then
      gunData = self.mTeamIds[i - 1]
      item:SetData(gunData)
    else
      item:SetNoneItem(self.ui.mTrans_None, teamRootTransform)
      item:EnableNone(true)
    end
    item.mUIRoot:SetAsLastSibling()
  end
end
function UIWeeklyTeamItem:OnTeamAvatarClick(gunCmdData)
  CS.RoleInfoCtrlHelper.Instance:InitSysPlayerAttrData(gunCmdData)
end
function UIWeeklyTeamItem:Release()
  self:ReleaseCtrlTable(self.mUIGunList, true)
end
