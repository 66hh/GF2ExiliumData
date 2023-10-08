require("UI.Common.UICommonSimpleView")
require("UI.DarkZonePanel.UIDarkZoneSeasonQuestPanel.Item.UIDarkZoneSeasonSettlementItem")
require("UI.DarkZonePanel.UIDarkZoneSeasonQuestPanel.Item.UIDarkZoneSeasonQuestRewardItem")
require("UI.Common.UICommonItem")
require("UI.UIBasePanel")
UIDarkZoneSeasonSettlementDialog = class("UIDarkZoneSeasonSettlementDialog", UIBasePanel)
UIDarkZoneSeasonSettlementDialog.__index = UIDarkZoneSeasonSettlementDialog
function UIDarkZoneSeasonSettlementDialog:ctor(csPanel)
  UIDarkZoneSeasonSettlementDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneSeasonSettlementDialog:OnInit(root, data)
  self:SetRoot(root)
  NetCmdDarkZoneSeasonData:SendHasSeeSettlement()
  self:InitBaseData(root)
  self:AddBtnListen()
  self:AddMsgListener()
  self.planID = NetCmdDarkZoneSeasonData.FinishPlanID
  self:InitUI()
  setactive(self.ui.mTrans_Settlement, true)
  setactive(self.ui.mTrans_Reward, false)
end
function UIDarkZoneSeasonSettlementDialog:InitBaseData(root)
  self.mView = UICommonSimpleView.New()
  self.ui = {}
  self.mView:InitCtrl(root, self.ui)
  self.itemList = {}
  self.settlementItemList = {}
  self.canClose = false
  self.canCloseUI = false
  self.curPlayIndex = 0
  self.rewardItemList = {}
end
function UIDarkZoneSeasonSettlementDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    if self.canClose then
      self.ui.mAnimator_Settlement:SetTrigger("FadeOut")
      self:DelayCall(0.33, function()
        setactive(self.ui.mTrans_Settlement, false)
        setactive(self.ui.mTrans_Reward, true)
        self:DelayCall(2.5, function()
          self.canCloseUI = true
        end)
      end)
    end
    if self.canCloseUI == true then
      self.ui.mAnimator_Reward:SetTrigger("FadeOut")
      UIManager.CloseUI(UIDef.UIDarkZoneSeasonSettlementDialog)
    end
    NetCmdDarkZoneSeasonData:CleanSeasonReward()
  end
end
function UIDarkZoneSeasonSettlementDialog:AddMsgListener()
end
function UIDarkZoneSeasonSettlementDialog:InitUI()
  local planData = TableData.listPlanDatas:GetDataById(self.planID)
  if not planData then
    return
  end
  local seasonId = planData.args[0]
  self.seasonData = TableData.listDarkzoneSeasonDatas:GetDataById(seasonId)
  self.ui.mText_Title.text = self.seasonData.name.str
  local openTime = CS.CGameTime.ConvertLongToDateTime(planData.open_time):ToString("yyyy/MM/dd")
  local closeTime = CS.CGameTime.ConvertLongToDateTime(planData.close_time):ToString("yyyy/MM/dd")
  self.ui.mText_Time.text = openTime .. "-" .. closeTime
  self.ui.mText_RewardTime.text = openTime .. "-" .. closeTime
  self.ui.mText_RewardTitle.text = self.seasonData.name.str
end
function UIDarkZoneSeasonSettlementDialog:OnShowStart()
  self.itemWidth = self.ui.mGridLayoutGroup_Content.cellSize.x
  self.itemOffset = self.ui.mGridLayoutGroup_Content.padding.left + self.ui.mGridLayoutGroup_Content.padding.right
  self.itemSpacing = self.ui.mGridLayoutGroup_Content.spacing.x
  self.itemContentWidth = 0
  local finishTaskList = NetCmdDarkZoneSeasonData.finishQuestList
  local planData = TableData.listPlanDatas:GetDataById(self.planID)
  if not planData then
    return
  end
  local seasonId = planData.args[0]
  self.dataList = {}
  self.questDataList = {}
  local seasonDatas = TableData.listDarkzoneSeasonQuestBySeasonDatas:GetDataById(0).Id
  local dList = {}
  for i = 0, seasonDatas.Count - 1 do
    local id = seasonDatas[i]
    table.insert(dList, id)
  end
  seasonDatas = TableData.listDarkzoneSeasonQuestBySeasonDatas:GetDataById(seasonId).Id
  for i = 0, seasonDatas.Count - 1 do
    local id = seasonDatas[i]
    table.insert(dList, id)
  end
  local tbSeasonData = TableData.listDarkzoneSeasonDatas:GetDataById(seasonId)
  local iconSprite = IconUtils.GetAtlasV2("DarkzoneSeasonLogo", tbSeasonData.icon)
  self.ui.mImg_Logo.sprite = iconSprite
  self.ui.mImg_Logo2.sprite = iconSprite
  self.ui.mImg_RewordLogo.sprite = iconSprite
  self.ui.mImg_RewardLogo1.sprite = iconSprite
  self.ui.mImg_RewardLogo2.sprite = iconSprite
  local allQuestData = {}
  for j = 1, #dList do
    local id = dList[j]
    local td = TableData.listDarkzoneSeasonQuestDatas:GetDataById(id)
    local questState = finishTaskList:Contains(id)
    if questState then
      if self.questDataList[td.type] == nil then
        self.questDataList[td.type] = {}
      end
      table.insert(self.questDataList[td.type], td)
    end
    if td.change ~= 0 or NetCmdDarkZoneSeasonData:CheckRewardStateByID(td) ~= true or questState then
      if allQuestData[td.type] == nil then
        allQuestData[td.type] = 0
      end
      allQuestData[td.type] = allQuestData[td.type] + 1
      local sortList = UIUtils.GetKVSortItemTable(td.reward_list)
      for _, v in ipairs(sortList) do
        local id = v, id
        local num = v.num
        if tbSeasonData.goods:Contains(id) then
          if self.dataList[id] == nil then
            local t = {}
            t.curNum = 0
            t.maxNum = 0
            self.dataList[id] = t
          end
          self.dataList[id].maxNum = self.dataList[id].maxNum + num
          if questState then
            self.dataList[id].curNum = self.dataList[id].curNum + num
          end
        end
      end
    end
  end
  for i = 1, #self.itemList do
    self.itemList[i]:SetActive(false)
  end
  local index = 1
  for i, v in pairs(self.dataList) do
    if self.itemList[index] == nil then
      self.itemList[index] = UIDarkZoneSeasonQuestRewardItem.New()
      local obj = instantiate(self.ui.mTrans_Item, self.ui.mTrans_ItemList)
      self.itemList[index]:InitCtrl(obj)
    end
    self.itemList[index]:SetData(i)
    self.itemList[index]:SetGetNum(0, v.maxNum)
    index = index + 1
  end
  local questIndex = 1
  for i, v in pairs(self.questDataList) do
    if self.settlementItemList[questIndex] == nil then
      self.settlementItemList[questIndex] = UIDarkZoneSeasonSettlementItem.New()
      self.settlementItemList[questIndex]:InitCtrl(self.ui.mTrans_Content)
    end
    local item = self.settlementItemList[questIndex]
    item:SetData(v, i)
    item:SetStartFunction(function()
      self:ChangeScroll()
    end)
    item:SetFunction(function(param)
      self:PlayRewardAnim(param)
    end)
    item:SetFinishFunction(function()
      self:StartPlaySettlementItem()
    end)
    item.maxNum = allQuestData[i]
    item:SetActive(false)
    questIndex = questIndex + 1
  end
  local itemNum = #self.settlementItemList
  self.itemContentWidth = itemNum * self.itemWidth + (itemNum - 1) * self.itemSpacing + self.itemOffset
  self.ui.mVirtualListEx_List.DragEnabled = false
  self.time1 = TimerSys:DelayFrameCall(1, function()
    self.itemContentShowWidth = self.ui.mTrans_List.rect.width
    self.ui.mCanvasGroup_List.blocksRaycasts = self.itemContentWidth >= self.itemContentShowWidth
    self.ui.mHorizontalLayoutGroup_Viewport.enabled = self.itemContentWidth <= self.itemContentShowWidth
    self.ui.mTrans_Content.sizeDelta = Vector2(self.itemContentWidth, self.ui.mTrans_List.rect.height)
    self.ui.mTrans_Content.anchoredPosition = Vector2(self.ui.mTrans_Content.anchoredPosition.x, -1 * self.ui.mTrans_List.rect.height / 2)
  end)
  self.time2 = TimerSys:DelayFrameCall(10, function()
    self.ui.mVirtualListEx_List.horizontalNormalizedPosition = 0
  end)
  self:DelayCall(1.5, function()
    self:StartPlaySettlementItem()
  end)
  self.rewardDataList = {}
  for i = 0, finishTaskList.Count - 1 do
    local id = finishTaskList[i]
    local td = TableData.listDarkzoneSeasonQuestDatas:GetDataById(id)
    local sortList = UIUtils.GetKVSortItemTable(td.reward_list)
    for _, v in ipairs(sortList) do
      local id = v.id
      local num = v.num
      if self.rewardDataList[id] == nil then
        self.rewardDataList[id] = 0
      end
      self.rewardDataList[id] = self.rewardDataList[id] + num
    end
  end
  for i = 1, #self.rewardItemList do
    self.rewardItemList[i]:SetActive(false)
  end
  local index = 1
  for i, v in pairs(self.rewardDataList) do
    if self.rewardItemList[index] == nil then
      self.rewardItemList[index] = UICommonItem.New()
      self.rewardItemList[index]:InitCtrl(self.ui.mTrans_RewardItemList)
    end
    self.rewardItemList[index]:SetItemData(i, v)
    index = index + 1
  end
end
function UIDarkZoneSeasonSettlementDialog:ChangeScroll()
  if self.curPlayIndex == 1 then
    self.itemContentShowWidth = self.ui.mTrans_List.rect.width
  end
  local startValue = self.ui.mVirtualListEx_List.horizontalNormalizedPosition
  local endValue = startValue
  local itemNum = self.curPlayIndex
  local currentWidth = itemNum * self.itemWidth + (itemNum - 1) * self.itemSpacing + self.itemOffset
  if currentWidth > self.itemContentShowWidth then
    endValue = (currentWidth - self.itemContentShowWidth) / (self.itemContentWidth - self.itemContentShowWidth)
  end
  if self.progressTween then
    LuaDOTweenUtils.Kill(self.progressTween, false)
  end
  local getter = function(tempSelf)
    return startValue
  end
  local setter = function(tempSelf, value)
    tempSelf.ui.mVirtualListEx_List.horizontalNormalizedPosition = value
  end
  self.progressTween = LuaDOTweenUtils.ToOfFloat(self, getter, setter, endValue, 0.3, function()
    self.settlementItemList[self.curPlayIndex]:StartPlay()
  end)
end
function UIDarkZoneSeasonSettlementDialog:StartPlaySettlementItem()
  self.curPlayIndex = self.curPlayIndex + 1
  if self.curPlayIndex <= #self.settlementItemList then
    self:ChangeScroll()
  else
    self.ui.mVirtualListEx_List.DragEnabled = true
    self.canClose = true
  end
end
function UIDarkZoneSeasonSettlementDialog:PlayRewardAnim(data)
  if data then
    local sortList = UIUtils.GetKVSortItemTable(data.reward_list)
    for _, v in ipairs(sortList) do
      local id = v.id
      local num = v.num
      local item = self:GetItemByItemId(id)
      if item then
        item:SetCurNum(num)
        item:PlayAnim()
      end
    end
  end
end
function UIDarkZoneSeasonSettlementDialog:GetItemByItemId(id)
  local result
  for i = 1, #self.itemList do
    if self.itemList[i].mData == id then
      result = self.itemList[i]
    end
  end
  return result
end
function UIDarkZoneSeasonSettlementDialog:OnClose()
  self:ReleaseTimers()
  self:ReleaseCtrlTable(self.itemList, true)
  self.itemList = nil
  self:ReleaseCtrlTable(self.settlementItemList, true)
  self.settlementItemList = nil
  self.ui = nil
  self.mView = nil
  self.canClose = nil
  self.canCloseUI = nil
  self.curPlayIndex = nil
  if self.progressTween then
    LuaDOTweenUtils.Kill(self.progressTween, false)
    self.progressTween = nil
  end
  self:ReleaseCtrlTable(self.rewardItemList, true)
  self.rewardItemList = nil
  UIManager.OpenUI(UIDef.UIDarkZoneNewSeasonOpenDialog)
  if self.time1 then
    self.time1:Stop()
    self.time1 = nil
  end
  if self.time2 then
    self.time2:Stop()
    self.time2 = nil
  end
end
