require("UI.DarkZonePanel.UIDarkZoneSeasonQuestPanel.Item.UIDarkZoneSeasonQuestItem")
require("UI.DarkZonePanel.UIDarkZoneSeasonQuestPanel.Item.UIDarkZoneSeasonQuestRewardItem")
require("UI.DarkZonePanel.UIDarkZoneSeasonQuestPanel.Item.UIDarkZoneSeasonQuestTabItem")
require("UI.DarkZonePanel.UIDarkZoneSeasonQuestPanel.UIDarkZoneSeasonQuestPanelView")
require("UI.UIBasePanel")
UIDarkZoneSeasonQuestPanel = class("UIDarkZoneSeasonQuestPanel", UIBasePanel)
UIDarkZoneSeasonQuestPanel.__index = UIDarkZoneSeasonQuestPanel
function UIDarkZoneSeasonQuestPanel:ctor(csPanel)
  UIDarkZoneSeasonQuestPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
end
function UIDarkZoneSeasonQuestPanel:OnAwake(root, data)
end
function UIDarkZoneSeasonQuestPanel:OnSave()
end
function UIDarkZoneSeasonQuestPanel:OnInit(root, data)
  self:SetRoot(root)
  self.mView = UIDarkZoneSeasonQuestPanelView.New()
  self.ui = {}
  self.mView:InitCtrl(root, self.ui)
  self.questItem = nil
  self:AddBtnListen()
  self:InitBaseData()
  self:AddEventListener()
  self:InitSeasonData()
  function self.ui.mVirtualListEx_List.itemProvider()
    return self:ItemProvider()
  end
  function self.ui.mVirtualListEx_List.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
end
function UIDarkZoneSeasonQuestPanel:OnShowFinish()
end
function UIDarkZoneSeasonQuestPanel:OnHide()
end
function UIDarkZoneSeasonQuestPanel:OnUpdate(deltatime)
end
function UIDarkZoneSeasonQuestPanel:OnClose()
  self:ReleaseCtrlTable(self.tabItemList, true)
  self:ReleaseCtrlTable(self.rewardItemList, true)
  self.tabItemList = nil
  self.rewardItemList = nil
  self.ui = nil
  self.mView = nil
  self.curItem = nil
  self.super.OnRelease(self)
  self.showDataList = nil
  self.formatStr = nil
end
function UIDarkZoneSeasonQuestPanel:OnRelease()
  self.hasCache = false
end
function UIDarkZoneSeasonQuestPanel:InitBaseData()
  self.time = 0
  local str = TableData.GlobalDarkzoneData.DarkzoneOpentime
  local strarrs = string.split(str, ",")
  self.starttimeArr = string.split(strarrs[1], ":")
  self.endtimeArr = string.split(strarrs[2], ":")
  self.enter = true
  self.NpcStoreItemDic = {}
  self.IsJudgeRedPointByItemLimit = false
  self.questItemList = {}
  self.tabItemList = {}
  self.rewardItemList = {}
  self.curItem = nil
end
function UIDarkZoneSeasonQuestPanel:InitSeasonData()
  self.planID = NetCmdRecentActivityData:GetCurDarkZonePlanActivityData()
  self.planData = TableData.listPlanDatas:GetDataById(self.planID)
  self.ui.mUICountdown_LeftTime:StartCountdown(self.planData.close_time)
  local seasonId = NetCmdDarkZoneSeasonData.SeasonID
  self.seasonData = TableData.listDarkzoneSeasonDatas:GetDataById(seasonId)
  self.ui.mText_Title.text = self.seasonData.name.str
  self.ui.mImg_Logo.sprite = IconUtils.GetAtlasV2("DarkzoneSeasonLogo", self.seasonData.icon)
  self.ui.mImg_Logo2.sprite = IconUtils.GetAtlasV2("DarkzoneSeasonLogo", self.seasonData.icon)
  local tabDataList = {}
  self.dataList = {}
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
  for i = 1, #dList do
    local id = dList[i]
    local td = TableData.listDarkzoneSeasonQuestDatas:GetDataById(id)
    if td.change ~= 0 or NetCmdDarkZoneSeasonData:CheckRewardStateByID(td) ~= true then
      tabDataList[td.type] = 1
      if self.dataList[td.type] == nil then
        self.dataList[td.type] = {}
      end
      table.insert(self.dataList[td.type], td)
    end
  end
  for i, v in pairs(self.dataList) do
    table.sort(v, function(a, b)
      local af = NetCmdDarkZoneSeasonData:CheckQuestCounterByID(a) >= a.condition_num
      local bf = NetCmdDarkZoneSeasonData:CheckQuestCounterByID(b) >= b.condition_num
      if af then
        return false
      elseif bf then
        return true
      end
      return a.id < b.id
    end)
  end
  self.tabData = {}
  for i, v in pairs(tabDataList) do
    table.insert(self.tabData, i)
  end
  table.sort(self.tabData, function(a, b)
    return a < b
  end)
  self:SetItemList()
  self:InitSeasonRewardCmdData()
end
function UIDarkZoneSeasonQuestPanel:InitSeasonRewardCmdData()
  self.showRewardCmdData = {}
  for i = 0, self.seasonData.goods.Count - 1 do
    local t = {}
    t.curNum = 0
    t.maxNum = 0
    self.showRewardCmdData[self.seasonData.goods[i]] = t
  end
  for i, v in pairs(self.dataList) do
    for j = 1, #v do
      local tData = v[j]
      local questCountNum = NetCmdDarkZoneSeasonData:CheckQuestCounterByID(tData)
      local questHasFinish = questCountNum >= tData.condition_num
      local tb = UIUtils.GetKVSortItemTable(tData.reward_list)
      for _, n in ipairs(tb) do
        local id = n.id
        local num = n.num
        if self.showRewardCmdData[id] then
          self.showRewardCmdData[id].maxNum = self.showRewardCmdData[id].maxNum + num
          if questHasFinish then
            self.showRewardCmdData[id].curNum = self.showRewardCmdData[id].curNum + num
          end
        end
      end
    end
  end
  self:SetSeasonRewardList()
end
function UIDarkZoneSeasonQuestPanel:SetItemList()
  for i = 1, #self.tabItemList do
    self.tabItemList[i]:SetActive(false)
  end
  local f = function(item)
    self:ReFreshQuestDataByType(item)
  end
  for i = 1, #self.tabData do
    if self.tabItemList[i] == nil then
      self.tabItemList[i] = UIDarkZoneSeasonQuestTabItem.New()
      self.tabItemList[i]:InitCtrl(self.ui.mTrans_TabBtn)
    end
    local tData = TableData.listDarkzoneSeasonQuestTypeDatas:GetDataById(self.tabData[i])
    self.tabItemList[i]:SetData(tData)
    self.tabItemList[i]:SetClickFunction(f)
  end
  self.tabItemList[1]:OnClick()
end
function UIDarkZoneSeasonQuestPanel:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIDarkZoneSeasonQuestPanel)
  end
end
function UIDarkZoneSeasonQuestPanel:AddEventListener()
end
function UIDarkZoneSeasonQuestPanel:Instruction()
end
function UIDarkZoneSeasonQuestPanel:ReFreshQuestDataByType(item)
  self.showDataList = self.dataList[item.mData.id]
  if self.ui.mVirtualListEx_List.numItems == #self.showDataList then
    self.ui.mVirtualListEx_List:Refresh()
  else
    self.ui.mVirtualListEx_List.numItems = #self.showDataList
  end
  if self.curItem then
    self.curItem.ui.mBtn_Root.interactable = true
  end
  self.ui.mFadeManager_Content.enabled = false
  self.ui.mFadeManager_Content.enabled = true
  self.ui.mVirtualListEx_List.verticalNormalizedPosition = 1
  self.curItem = item
  self.curItem.ui.mBtn_Root.interactable = false
end
function UIDarkZoneSeasonQuestPanel:SetSeasonRewardList()
  for i = 1, #self.rewardItemList do
    self.rewardItemList[i]:SetActive(false)
  end
  for i = 0, self.seasonData.goods.Count - 1 do
    local index = i + 1
    if self.rewardItemList[index] == nil then
      self.rewardItemList[index] = UIDarkZoneSeasonQuestRewardItem.New()
      local obj = instantiate(self.ui.mTrans_Item, self.ui.mTrans_ItemList)
      self.rewardItemList[index]:InitCtrl(obj)
    end
    self.rewardItemList[index]:SetData(self.seasonData.goods[i])
    local cmdData = self.showRewardCmdData[self.seasonData.goods[i]]
    self.rewardItemList[index]:SetGetNum(cmdData.curNum, cmdData.maxNum)
  end
end
function UIDarkZoneSeasonQuestPanel:ItemProvider()
  local itemView = UIDarkZoneSeasonQuestItem.New()
  itemView:InitCtrl(self.ui.mTrans_Content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIDarkZoneSeasonQuestPanel:ItemRenderer(index, renderData)
  local data = self.showDataList[index + 1]
  local item = renderData.data
  item:SetData(data)
end
function UIDarkZoneSeasonQuestPanel:UpdateQuestRedPoint()
  local level = AccountNetCmdHandler:GetLevel()
  local needlvId = PlayerPrefs.GetInt(PlayerPrefs.GetString("uid") .. UIDarkZoneQuestInfoPanel.EPlayerFirstClick.nextQuestGroupID)
  if needlvId > TableData.listDarkzoneQuestBundleDatas.Count + 100 then
    return false
  end
  if not PlayerPrefs.HasKey(PlayerPrefs.GetString("uid") .. UIDarkZoneQuestInfoPanel.EPlayerFirstClick.nextQuestGroupID) then
    return true
  end
  local needlv = TableData.listDarkzoneQuestBundleDatas:GetDataById(needlvId).quest_need_lv
  if level >= needlv then
    return true
  end
  return false
end
