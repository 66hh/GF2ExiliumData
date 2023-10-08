require("UI.UIBasePanel")
require("UI.UIWeeklyPanel.UIWeeklyTeamItem")
UIWeeklyTeamDetailsDialog = class("UIWeeklyTeamDetailsDialog", UIBasePanel)
UIWeeklyTeamDetailsDialog.__index = UIWeeklyTeamDetailsDialog
function UIWeeklyTeamDetailsDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIWeeklyTeamDetailsDialog:OnInit(root)
  self.super.SetRoot(self, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:RegisterEvent()
  self.mData = NetCmdSimulateBattleData:GetSimCombatWeeklyData()
  self.mMaxTeamCount = self.mData.degreeData.b_id.Length
  self.mUITeamList = {}
  self:UpdateAll()
end
function UIWeeklyTeamDetailsDialog:CloseSelf()
  UIManager.CloseUI(UIDef.UIWeeklyTeamDetailsDialog)
end
function UIWeeklyTeamDetailsDialog:RegisterEvent()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self.CloseSelf()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BgClose.gameObject).onClick = function()
    self.CloseSelf()
  end
end
function UIWeeklyTeamDetailsDialog:UpdateAll()
  local teamIds = self.mData.BTeamIds
  if teamIds == nil or teamIds.Count < self.mMaxTeamCount then
    print_error("周常本 编队数据异常")
    return
  end
  local teamListRoot = self.ui.mScrollChild_Item.transform
  local teamItemTemplate = self.ui.mScrollChild_Item.childItem
  for i = 1, self.mMaxTeamCount do
    local item
    if self.mUITeamList[i] then
      item = self.mUITeamList[i]
    else
      item = UIWeeklyTeamItem.New()
      item:InitCtrl(teamItemTemplate, teamListRoot)
      table.insert(self.mUITeamList, item)
    end
    local ids = teamIds[i - 1]
    if item then
      item:SetData(self.mData, i, ids)
    end
  end
end
function UIWeeklyTeamDetailsDialog:OnClose()
  self.super.OnClose(self)
  self:ReleaseCtrlTable(self.mUITeamList, true)
  self.mUITeamList = nil
end
