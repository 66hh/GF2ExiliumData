require("UI.UIBaseCtrl")
require("UI.Common.UICommonItem")
UIChapterRewardListItem = class("UIChapterRewardListItem", UIBaseCtrl)
UIChapterRewardListItem.__index = UIChapterRewardListItem
function UIChapterRewardListItem:ctor()
  self.itemList = {}
end
function UIChapterRewardListItem:__InitCtrl()
end
function UIChapterRewardListItem:InitCtrl(parent)
  local instObj = instantiate(UIUtils.GetGizmosPrefab("story/StoryChapterRewardItemV2.prefab", self))
  CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:__InitCtrl()
end
function UIChapterRewardListItem:SetData(chapterData, stars, state, i, rewardList, isDifficult)
  local hitNum1, hitNum2, hitNum3
  if isDifficult == true then
    hitNum1 = 193019
    hitNum2 = 193021
    hitNum3 = 193020
  else
    hitNum1 = 103100
    hitNum2 = 901002
    hitNum3 = 901001
  end
  self.ui.mText_UnFinish.text = TableData.GetHintById(hitNum2)
  UIUtils.GetText(self.ui.transReceive.transform, "Root/GrpText/Text_Name").text = TableData.GetHintById(hitNum3)
  local limit = 0
  limit = chapterData.chapter_reward_value[i - 1]
  local canShow = rewardList ~= nil and 0 < #rewardList
  setactive(self.mUIRoot, canShow == true)
  if canShow then
    self.ui.txtNum.text = (stars > limit and limit or stars) .. "<color=#b5b8bf> /" .. limit .. "</color>"
    setactive(self.ui.transUnFinish, state == UIChapterGlobal.RewardState.UnFinish)
    setactive(self.ui.transReceive, state == UIChapterGlobal.RewardState.Receive)
    setactive(self.ui.transFinish, state == UIChapterGlobal.RewardState.Finish)
    for _, item in ipairs(self.itemList) do
      item:SetItemData(nil)
    end
    local items = {}
    for _, value in ipairs(rewardList) do
      local item = {}
      item.id = value.itemId
      item.num = value.itemNum
      item.itemData = TableData.listItemDatas:GetDataById(item.id)
      table.insert(items, item)
    end
    for i = 1, #items do
      if i <= #self.itemList then
        self.itemList[i]:SetItemData(items[i].id, items[i].num)
      else
        local item = UICommonItem.New()
        item:InitCtrl(self.ui.transItemList)
        item:SetItemData(items[i].id, items[i].num)
        table.insert(self.itemList, item)
      end
    end
  end
end
