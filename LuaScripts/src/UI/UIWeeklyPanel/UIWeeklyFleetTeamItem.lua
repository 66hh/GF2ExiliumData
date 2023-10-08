require("UI.UIBaseCtrl")
require("UI.UIWeeklyPanel.UIWeeklyChrAvatarItem")
require("UI.UIWeeklyPanel.UIWeeklyDefine")
UIWeeklyFleetTeamItem = class("UIWeeklyFleetTeamItem", UIBaseCtrl)
UIWeeklyFleetTeamItem.__index = UIWeeklyFleetTeamItem
function UIWeeklyFleetTeamItem:ctor()
  self.super.ctor(self)
  self.mUIGunList = {}
end
function UIWeeklyFleetTeamItem:InitCtrl(parent, itemPrefab, onClick, fleetPanel)
  local instObj = instantiate(itemPrefab, parent)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(instObj.transform, self.ui)
  self.mFleetPanel = fleetPanel
  UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
    onClick(self.mIndex)
  end
end
function UIWeeklyFleetTeamItem:SetData(weeklyData, index, teamList, isSelect)
  self.mWeeklyData = weeklyData
  self.mIndex = index
  self.mTeamList = teamList or {}
  self.ui.mText_TeamNum.text = string.format("-", index)
  self:EnableSelect(isSelect)
  self:UpdateTeam()
end
function UIWeeklyFleetTeamItem:EnableSelect(isSelect)
  self.mISelect = isSelect
  self.ui.mBtn_Self.interactable = not isSelect
  for i = 1, #self.mUIGunList do
    local gunItem = self.mUIGunList[i]
    if gunItem then
      gunItem:EnableBtn(isSelect)
    end
  end
end
function UIWeeklyFleetTeamItem:UpdateTeam()
  local teamRootTransform = self.ui.mTrans_TeamList.transform
  for i = 1, UIWeeklyDefine.TeamMaxGunCount do
    local item
    if self.mUIGunList[i] then
      item = self.mUIGunList[i]
    else
      item = UIWeeklyChrAvatarItem.New()
      item:InitCtrl(teamRootTransform, function(gunData)
        self:OnTeamAvatarClick(gunData)
      end)
      item:SetNoneItem(self.ui.mTrans_CharNone, teamRootTransform)
      table.insert(self.mUIGunList, item)
    end
    local gunData
    if self.mTeamList[i] then
      gunData = NetCmdTeamData:GetGunByID(self.mTeamList[i])
    end
    if item then
      item:SetAsLastSibling()
      if gunData == nil then
        item:EnableNone(gunData == nil)
      else
        item:SetData(gunData)
      end
    end
  end
end
function UIWeeklyFleetTeamItem:OnTeamAvatarClick(gunData)
  self.mFleetPanel:EquipToCurrentSelectTeam(gunData.id)
end
