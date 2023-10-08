require("UI.UIBaseView")
UIChapterRewardPanelView = class("UIChapterRewardPanelView", UIBaseView)
UIChapterRewardPanelView.__index = UIChapterRewardPanelView
function UIChapterRewardPanelView:ctor()
  self.rewardList = {}
end
function UIChapterRewardPanelView:__InitCtrl()
  for i = 1, 3 do
    local obj = self:GetRectTransform("Root/GrpDialog/GrpCenter/TargetList/StoryChapterRewardItemV2" .. i)
    local item = self:InitReward(obj)
    table.insert(self.rewardList, item)
  end
end
function UIChapterRewardPanelView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
function UIChapterRewardPanelView:InitReward(obj)
  if obj then
    local reward = {}
    reward.obj = obj
    local LuaUIBindScript = obj:GetComponent(UIBaseCtrl.LuaBindUi)
    local vars = LuaUIBindScript.BindingNameList
    for i = 0, vars.Count - 1 do
      reward[vars[i]] = LuaUIBindScript:GetBindingComponent(vars[i])
    end
    reward.itemList = {}
    return reward
  end
end
