require("UI.UIBaseCtrl")
ActivityTourMissionItem = class("ActivityTourMissionItem", UIBaseCtrl)
ActivityTourMissionItem.__index = ActivityTourMissionItem
function ActivityTourMissionItem:ctor()
end
function ActivityTourMissionItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  self.itemUIList = {}
  self.emptyItemList = {}
end
function ActivityTourMissionItem:SetData(data, index)
  self.ui.mText_Tittle.text = data.des
  setactive(self.ui.mTrans_RedPoint.gameObject, false)
  setactive(self.ui.mTrans_Received.gameObject, false)
  setactive(self.ui.mTrans_Finished.gameObject, false)
  self.emptyItemList[1] = self.ui.mScrollItem_Atom:GetChild(0)
  self.emptyItemList[2] = self.ui.mScrollItem_Atom:GetChild(1)
  for i = 0, data.reward_list.Count - 1 do
    local itemview
    local rewardStr = string.split(data.reward_list[i], ":")
    local itemId = tonumber(rewardStr[1])
    local itemNum = tonumber(rewardStr[2])
    if i < #self.itemUIList then
      self.itemUIList[i + 1]:SetItemData(itemId, itemNum)
    else
      itemview = UICommonItem.New()
      itemview:InitCtrl(self.ui.mScrollItem_Atom)
      itemview:SetItemData(itemId, itemNum)
      itemview.mUIRoot:SetAsLastSibling()
      table.insert(self.itemUIList, itemview)
    end
    setactive(self.itemUIList[i + 1].ui.mBtn_Select.gameObject, true)
    local stcData = TableData.GetItemData(itemId)
    TipsManager.Add(self.itemUIList[i + 1].mUIRoot, stcData)
  end
  if #self.itemUIList > data.reward_list.Count then
    for i = data.reward_list.Count + 1, #self.itemUIList do
      setactive(self.itemUIList[i].ui.mBtn_Select.gameObject, false)
    end
  end
  setactive(self.emptyItemList[1].gameObject, 2 > data.reward_list.Count)
  setactive(self.emptyItemList[2].gameObject, 1 > data.reward_list.Count)
  local type = 17
  if index == 2 then
    type = 18
  end
  local currCount = NetCmdCommonQuestData:GetQuestProgressCount(type, data.id)
  local state = NetCmdCommonQuestData:GetReceivedRewardState(type, data.id)
  local isCompleted = state == 1
  local isReceived = state == 2
  setactive(self.ui.mTrans_Unfinished.gameObject, state == 0)
  if isCompleted then
    self.ui.mText_Progress.text = "<color=#f26c1c>" .. data.condition_num .. "/" .. data.condition_num .. "</color>"
    setactive(self.ui.mTrans_Received.gameObject, true)
    self.ui.mSmoothMask_Progress.FillAmount = 1
  elseif isReceived then
    self.ui.mText_Progress.text = "<color=#384B52>" .. data.condition_num .. "/" .. data.condition_num .. "</color>"
    setactive(self.ui.mTrans_Finished.gameObject, true)
    self.ui.mSmoothMask_Progress.FillAmount = 1
  else
    self.ui.mText_Progress.text = "<color=#384B52>" .. currCount .. "/" .. data.condition_num .. "</color>"
    self.ui.mSmoothMask_Progress.FillAmount = currCount / data.condition_num
  end
end
