require("UI.UIBasePanel")
UIAchievementSubPanel = class("UIAchievementSubPanel", UIBaseCtrl)
UIAchievementSubPanel.__index = UIAchievementSubPanel
UIAchievementSubPanel.mView = nil
UIAchievementSubPanel.mLeftTabViewList = {}
function UIAchievementSubPanel:ctor()
  UIAchievementSubPanel.super.ctor(self)
end
function UIAchievementSubPanel:InitCtrl(root)
  self.mUIRoot = root
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:InitAllList()
end
function UIAchievementSubPanel:Show()
  for _, item in ipairs(self.mLeftTabViewList) do
    item:RefreshData()
  end
  self.ui.mText_Num.text = NetCmdAchieveData:GetTotalPoints()
end
function UIAchievementSubPanel:InitAllList()
  self.ui.mText_Num.text = NetCmdAchieveData:GetTotalPoints()
  for i = 0, TableData.listAchievementTagDatas.Count - 1 do
    do
      local data = TableData.listAchievementTagDatas[i]
      local item
      if self.mLeftTabViewList[i + 1] == nil then
        item = UIAchievementAllItem.New()
        item:InitCtrl(self.ui.mContent_AchievementAll)
        table.insert(self.mLeftTabViewList, item)
      else
        item = self.mLeftTabViewList[i + 1]
      end
      item:SetData(data)
      UIUtils.GetButtonListener(item.ui.mBtn.gameObject).onClick = function()
        UIManager.OpenUIByParam(UIDef.UIAchievementPanel, data.id)
      end
    end
  end
end
function UIAchievementSubPanel:Release()
  for i, view in ipairs(UIAchievementSubPanel.mLeftTabViewList) do
    gfdestroy(view:GetRoot())
  end
  UIAchievementSubPanel.mLeftTabViewList = {}
end
