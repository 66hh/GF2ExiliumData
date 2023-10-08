require("UI.UIBaseCtrl")
require("UI.Common.UICommonItem")
ActivityThemeRewardItem = class("ActivityThemeRewardItem", UIBaseCtrl)
ActivityThemeRewardItem.__index = ActivityThemeRewardItem
function ActivityThemeRewardItem:ctor()
end
function ActivityThemeRewardItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  self.ui.itemUIList = {}
end
function ActivityThemeRewardItem:SetData(data)
  self.ui.mText_Num.text = data.point
  local sortedItemList = UIUtils.GetKVSortItemTable(data.reward_item)
  for i = 1, #sortedItemList do
    if self.ui.itemUIList[i] then
      self.ui.itemUIList[i]:SetItemData(sortedItemList[i].id, sortedItemList[i].num)
    else
      do
        local item = UICommonItem.New()
        item:InitCtrl(self.ui.mTrans_Content)
        item:SetItemData(sortedItemList[i].id, sortedItemList[i].num, nil, nil, nil, nil, nil, function()
          UITipsPanel.Open(TableData.GetItemData(sortedItemList[i].id))
        end)
        table.insert(self.ui.itemUIList, item)
      end
    end
  end
  local state = NetCmdThemeData:GetPhaseRewardState(data.id)
  setactive(self.ui.mTrans_TextUnCompleted, state < 1)
  setactive(self.ui.mTrans_TextCompleted, 0 < state)
end
