require("UI.UIDarkZoneMapSelectPanel.MapSelectUtils")
require("UI.DarkZonePanel.UIDarkZoneQuestPanel.UIDarkZoneQuestPanelView")
require("UI.UIBasePanel")
require("UI.Common.UICommonItem")
require("UI.CombatLauncherPanel.Item.UICommonEnemyItem")
require("UI.SimpleMessageBox.SimpleMessageBoxPanel")
require("UI.DarkZonePanel.UIDarkZoneModePanel.DarkZoneGlobal")
UIDarkZoneQuestPanel = class("UIDarkZoneQuestPanel", UIBasePanel)
UIDarkZoneQuestPanel.__index = UIDarkZoneQuestPanel
function UIDarkZoneQuestPanel:ctor(csPanel)
  UIDarkZoneQuestPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
  csPanel.Is3DPanel = false
end
function UIDarkZoneQuestPanel:OnAwake(root, data)
end
function UIDarkZoneQuestPanel:OnSave()
  self.hasCache = false
end
function UIDarkZoneQuestPanel:OnInit(root, data)
  self:SetRoot(root)
  self.mView = UIDarkZoneQuestPanelView.New()
  self.ui = {}
  self.mView:InitCtrl(root, self.ui)
  self.mData = {}
  self.darkZoneMode = data[0]
  if self.darkZoneMode == 1 then
    self.mData.id = data[1]
  elseif self.darkZoneMode == 2 then
    self.mData.endlessId = data[1]
    self.mData.rewardId = data[2]
  end
  self.EventGroup = {}
  for i = DarkZoneGlobal.EventType.Start, DarkZoneGlobal.EventType.End do
    self.EventGroup[i] = false
  end
  self.chestPrefab = nil
  self.chestUI = {}
  self.rewardConditionList = {}
  self:InitBaseData()
  self.ui.mAnimator_RaidBtn = self.ui.mBtn_Raid.transform:GetComponent(typeof(CS.UnityEngine.Animator))
  setactive(self.ui.mTrans_TextNum, false)
  self:AddEventListener()
  self:AddBtnListen()
end
function UIDarkZoneQuestPanel:OnShowStart()
  if self.darkZoneMode == 1 then
    if self.mData.id and self.mData.id > 0 then
      self.questData = TableData.listDarkzoneSystemQuestDatas:GetDataById(self.mData.id)
    elseif self.mData[0] == 1 then
      self.questData = TableData.listDarkzoneSystemQuestDatas:GetDataById(self.mData[1])
    end
    self.darkZoneMode = 1
    self:ReFreshChestNum()
    self:FreshQuestDetail()
    self:SetBtnState()
    self:ShowUnlockReward()
  end
  if self.darkZoneMode == 2 then
    self.endlessData = TableData.listDarkzoneSystemEndlessDatas:GetDataById(self.mData.endlessId)
    self.endLessRewardData = TableData.listDarkzoneSystemEndlessRewardDatas:GetDataById(self.mData.rewardId)
    self:FreshQuestDetailByEndLessData()
  end
  setactive(self.ui.mTrans_QuestText, self.darkZoneMode == 1)
  setactive(self.ui.mTrans_Explore, false)
end
function UIDarkZoneQuestPanel:ShowChest()
  self.chestPrefab = instantiate(self.ui.mTrans_Chest, self.ui.mTrasn_Content)
  self:LuaUIBindTable(self.chestPrefab, self.chestUI)
  setactive(self.chestPrefab, true)
  setactive(self.chestUI.mTrans_Explore.gameObject, true)
  setactive(self.chestUI.mTrans_Item.gameObject, false)
  self.chestUI.mText_ChestTitle.text = TableData.GetHintById(903385)
  local hasNum = DarkNetCmdStoreData:GetDZQuestReceivedChest(self.mData.id)
  local totalNum = DarkNetCmdStoreData:GetDZQuestTotalChest(self.mData.id)
  local state = NetCmdDarkZoneSeasonData:IsQuestFinish(self.mData.id)
  if state and hasNum == totalNum then
    setactive(self.chestUI.mTrans_Finish, true)
  else
    setactive(self.chestUI.mTrans_Finish, false)
  end
  self.chestUI.mText_Chest.text = string_format(TableData.GetHintById(240139), hasNum, totalNum)
  setactive(self.chestUI.mTrans_Icon, true)
  setactive(self.chestUI.mTrans_lock, false)
  self.chestPrefab:SetSiblingIndex(1)
end
function UIDarkZoneQuestPanel:OnShowFinish()
  self:EventAnimator()
end
function UIDarkZoneQuestPanel:OnBackFrom()
end
function UIDarkZoneQuestPanel:OnHide()
end
function UIDarkZoneQuestPanel:OnUpdate(deltatime)
end
function UIDarkZoneQuestPanel:OnClose()
  self.ui.mAnimator_begin:SetBool("Bool", false)
  self.ui.mAnimator_Time:SetBool("Bool", false)
  self.ui.mAnimator_Random:SetBool("Bool", false)
  self.ui.mAnimator_End:SetBool("Bool", false)
  self.ui = nil
  self.mView = nil
  self.mData = nil
  self.questData = nil
  self.endlessData = nil
  self.costItemNumIsEnough = nil
  self.costItem = nil
  self.formatStr = nil
  for i = 1, #self.costItemList do
    gfdestroy(self.costItemList[i].mUIRoot.gameObject)
  end
  if self.endLessItemList then
    for i = 1, #self.endLessItemList do
      gfdestroy(self.endLessItemList[i].obj)
    end
  end
  if self.rewardConditionList then
    for i = 1, #self.rewardConditionList do
      gfdestroy(self.rewardConditionList[i].gameObject)
    end
  end
  self.costItemList = nil
  self.endLessItemList = nil
  self:ReleaseCtrlTable(self.rewardItemList, true)
  self.rewardItemList = nil
  self.eventItemList = nil
  self:ReleaseCtrlTable(self.enemyItemList, true)
  self.enemyItemList = nil
  for i = 1, #self.mapIconItemList do
    gfdestroy(self.mapIconItemList[i].mUIRoot.gameObject)
  end
  self.mapIconItemList = nil
  MapSelectUtils.currentQuestGroupID = nil
  MapSelectUtils.currentQuestID = nil
  gfdestroy(self.chestPrefab)
  self.chestUI = nil
end
function UIDarkZoneQuestPanel:OnRelease()
  self.hasCache = false
end
function UIDarkZoneQuestPanel:InitBaseData()
  self.costItemList = {}
  self.rewardItemList = {}
  self.eventItemList = {}
  self.enemyItemList = {}
  self.mapIconItemList = {}
  self.formatStr = "{0}/{1}"
end
function UIDarkZoneQuestPanel:ResetQuestShow()
  setactive(self.ui.mTrans_Seat, false)
  setactive(self.ui.mTrans_GrpQuest, false)
  setactive(self.ui.mTrans_BtnQuery, false)
  setactive(self.ui.mTrans_EndlessText, false)
  setactive(self.ui.mTrans_EndlessInfo, false)
end
function UIDarkZoneQuestPanel:FreshQuestDetail()
  setactive(self.ui.mTrans_EndlessType, false)
  setactive(self.ui.mTrans_EndlessInfo, false)
  setactive(self.ui.mBtn_Raid, false)
  self.ui.mText_TaskName.text = self.questData.quest_name.str
  self.ui.mText_TaskLevelNum.text = string_format(TableData.GetHintById(200002), self.questData.quest_level)
  self.ui.mText_TaskTarget.text = self.questData.quest_target.str
  self.ui.mText_TodayFinishTime.text = string_format(TableData.GetHintById(240067), NetCmdItemData:GetNetItemCount(DarkZoneGlobal.TimeLimitID), TableDataBase.listItemLimitDatas:GetDataById(DarkZoneGlobal.TimeLimitID).max_limit)
  self:ResetQuestShow()
  local questType = TableData.listDarkzoneSeriesQuestTypeDatas:GetDataById(self.questData.quest_type)
  local mapdata = TableData.listDarkzoneMapV2Datas:GetDataById(self.questData.quest_struct_scene_id)
  local miniMapData = TableData.listDarkzoneMinimapV2Datas:GetDataById(mapdata.minimap_id)
  self.ui.mImg_MapBg.sprite = IconUtils.GetAtlasV2("DarkzoneMapPic", miniMapData.background)
  self.ui.mText_TaskTypeName.text = questType.name.str
  self.ui.mImg_TaskType.sprite = IconUtils.GetDarkZoneModelIcon(questType.icon)
  self.ui.mText_TaskDesc.text = self.questData.quest_desc.str
  self.ui.mText_TargetText.text = TableData.GetHintById(240142)
  setactive(self.ui.mTrans_Seat, false)
  if self.questData.dz_mode == DarkZoneGlobal.PanelType.Quest then
    setactive(self.ui.mTrans_GrpQuest, true)
    self.ui.mText_MapName.text = mapdata.name.str
  end
  local useItem = self.questData.quest_cost
  self.costItem = useItem
  self:RefreshCostItem(useItem)
  local dataList = {}
  local kvSortList = self.questData.quest_rewarddetailshow
  local count = kvSortList.Key.Count
  for i = 0, count - 1 do
    local t = {}
    t.id = kvSortList.Key[i]
    t.num = kvSortList.Value[i]
    table.insert(dataList, t)
  end
  self:SetRewardItem(dataList)
  self:SetEnemyList(mapdata)
  local rect = self.ui.mTrans_Map.rect
  for i = 0, self.questData.quest_mapmark.Count - 1 do
    do
      local data = string.split(self.questData.quest_mapmark[i], ":")
      local Tabdata = TableData.listDarkzoneMinimapIconDatas:GetDataById(tonumber(data[3]))
      if self.mapIconItemList[i + 1] == nil then
        local obj = instantiate(self.ui.mImg_MapDot.gameObject, self.ui.mTrans_Dot)
        setactive(obj, true)
        local item = {}
        item.mUIRoot = obj.transform
        item.mImg_MapItem = item.mUIRoot:Find("Img_MapPoint"):GetComponent(typeof(CS.UnityEngine.UI.Image))
        self.mapIconItemList[i + 1] = item
      end
      local item = self.mapIconItemList[i + 1]
      local rectTransform = item.mUIRoot:GetComponent(typeof(CS.UnityEngine.RectTransform))
      local width, height
      local tmp = UISystem.UICanvas.transform:GetComponent("CanvasScaler").referenceResolution
      local tmpWidth = tmp.x / 1280
      local tmpHeight = tmp.y / 720
      width = tmpWidth * tonumber(data[1]) / 2
      height = tmpHeight * tonumber(data[2]) / 2
      rectTransform.anchoredPosition = Vector2(width, height)
      UIUtils.GetButtonListener(item.mUIRoot.gameObject).onClick = function()
        SimpleMessageBoxPanel.ShowByParam(Tabdata.icon_name.str, Tabdata.icon_desc.str)
      end
      item.mImg_MapItem.sprite = IconUtils.GetDarkzoneIcon(Tabdata.icon)
    end
  end
  self:SetEventData(self.questData.result_show)
end
function UIDarkZoneQuestPanel:ShowUnlockReward()
  local questunlock = self.questData.quest_unlock.str
  if questunlock ~= "" then
    questunlock = string.split(questunlock, ";")
    for i = 1, #questunlock do
      local item = self.rewardConditionList[i]
      if item == nil then
        item = instantiate(self.ui.mTrans_Explore, self.ui.mTrans_Reward)
        item:SetSiblingIndex(1)
        setactive(item, true)
        table.insert(self.rewardConditionList, item)
      end
      local textCom = item.transform:Find("GrpText/Text_Explore"):GetComponent(typeof(CS.UnityEngine.UI.Text))
      textCom.text = questunlock[i]
    end
  end
end
function UIDarkZoneQuestPanel:SetEventData(eventData)
  local eventQuest = {}
  if eventData ~= nil then
    for i = 0, eventData.Count - 1 do
      local questGroup = eventData[i]
      eventQuest = string.split(questGroup, ":")
      for j = 2, #eventQuest do
        self.EventGroup[tonumber(eventQuest[1])] = true
        local eventTable = {
          stcDataId = tonumber(eventQuest[j]),
          type = tonumber(eventQuest[1])
        }
        table.insert(self.eventItemList, eventTable)
      end
    end
  end
end
function UIDarkZoneQuestPanel:SetBtnState()
  setactive(self.ui.mTrans_Complete, false)
  setactive(self.ui.mTrans_Quest, false)
  setactive(self.ui.mTrans_Lv, false)
  setactive(self.ui.mTrans_Action, false)
  local state = NetCmdDarkZoneSeasonData:IsQuestFinish(self.mData.id)
  setactive(self.ui.mTrans_Action, true)
  if state then
    setactive(self.ui.mTrans_Chest, false)
  else
    setactive(self.ui.mTrans_Chest, true)
  end
end
function UIDarkZoneQuestPanel:EventAnimator()
  local showNoText = true
  for i = DarkZoneGlobal.EventType.Start, DarkZoneGlobal.EventType.End do
    showNoText = showNoText and not self.EventGroup[i]
  end
  setactive(self.ui.mTrans_Text, showNoText)
  if showNoText then
    for i = DarkZoneGlobal.EventType.Start, DarkZoneGlobal.EventType.End do
      setactive(self.ui["mEventText" .. i], false)
    end
    setactive(self.ui.mQuestBtn_Query, false)
  else
    for i = DarkZoneGlobal.EventType.Start, DarkZoneGlobal.EventType.End do
      setactive(self.ui["mEventText" .. i], true)
    end
    setactive(self.ui.mQuestBtn_Query, true)
  end
  for i = DarkZoneGlobal.EventType.Start, DarkZoneGlobal.EventType.End do
    self.ui["mBtn_Event" .. i].interactable = self.EventGroup[i]
  end
  self.ui.mAnimator_begin:SetBool("Bool", self.EventGroup[DarkZoneGlobal.EventType.Start])
  self.ui.mAnimator_Time:SetBool("Bool", self.EventGroup[DarkZoneGlobal.EventType.Time])
  self.ui.mAnimator_Random:SetBool("Bool", self.EventGroup[DarkZoneGlobal.EventType.Random])
  self.ui.mAnimator_End:SetBool("Bool", self.EventGroup[DarkZoneGlobal.EventType.End])
end
function UIDarkZoneQuestPanel:FreshQuestDetailByEndLessData()
  self:ResetQuestShow()
  setactive(self.ui.mTrans_BtnQuery, true)
  setactive(self.ui.mTrans_Lv, false)
  setactive(self.ui.mTrans_GrpQuest, false)
  setactive(self.ui.mTrans_EndlessType, true)
  setactive(self.ui.mTrans_EndlessInfo, true)
  setactive(self.ui.mBtn_Raid, true)
  self.ui.mText_TaskName.text = self.endlessData.quest.str
  self.ui.mText_TaskLevelNum.text = string_format(TableData.GetHintById(200002), self.endlessData.level)
  setactive(self.ui.mText_TaskTarget, false)
  self.ui.mText_TargetText.text = TableData.GetHintById(240085)
  self.raidPopupStr = CS.LuaUIUtils.CheckUnlockPopupStrByRepeatedList(self.endlessData.raid_unlock)
  self.canRaid = string.len(self.raidPopupStr) == 0
  self.ui.mAnimator_RaidBtn:SetBool("Lock", self.canRaid == false)
  local mapdata = TableData.listDarkzoneMapV2Datas:GetDataById(self.endlessData.map)
  local miniMapData = TableData.listDarkzoneMinimapV2Datas:GetDataById(mapdata.minimap_id)
  self.ui.mImg_MapBg.sprite = IconUtils.GetAtlasV2("DarkzoneMapPic", miniMapData.background)
  self.ui.mText_TaskDesc.text = self.endlessData.quest_des.str
  self.ui.mText_MapName.text = mapdata.name.str
  local useItem = self.endlessData.use_item
  self.costItem = useItem
  self:RefreshCostItem(useItem)
  local endLessPlayData = TableData.listDzEndlessModeDatas:GetDataById(self.endlessData.map)
  self.endLessItemList = {}
  for i = 1, 3 do
    if self.endLessItemList[i] == nil then
      local parent = self.ui.mTrans_EndlessText.parent
      local obj = instantiate(self.ui.mTrans_EndlessText.gameObject, parent)
      local item = {}
      item.obj = obj
      setactive(obj, true)
      item.ui = {}
      UIUtils.OutUIBindTable(obj, item.ui)
      self.endLessItemList[i] = item
    end
    local item = self.endLessItemList[i]
    local nameStr, numStr
    if i == 1 then
      nameStr = TableData.GetHintById(240029)
      for i, v in pairs(endLessPlayData.default_val) do
        numStr = v
      end
    elseif i == 2 then
      nameStr = TableData.GetHintById(240030)
      numStr = endLessPlayData.oxygen_down_show
    elseif i == 3 then
      nameStr = TableData.GetHintById(240031)
      local count = endLessPlayData.result_divide_num.Count
      numStr = endLessPlayData.result_divide_num[count - 2]
    end
    item.ui.mText_Name.text = nameStr
    item.ui.mText_Num.text = numStr
  end
  local dataList = {}
  for i = 0, self.endLessRewardData.reward.Count - 1 do
    local t = {}
    t.id = self.endLessRewardData.reward[i]
    t.num = 1
    table.insert(dataList, t)
  end
  self:SetRewardItem(dataList)
  self:SetEnemyList(mapdata)
  self:SetEventData(self.endlessData.result_show)
end
function UIDarkZoneQuestPanel:RefreshCostItem(useItem)
  self.costItemNumIsEnough = true
  setactive(self.ui.mTrans_CostItem, useItem.Count > 0)
  for k, v in pairs(useItem) do
    local itemOwn = NetCmdItemData:GetItemCountById(k)
    if v > itemOwn then
      self.costItemNumIsEnough = false
      self.ui.mText_CostNum.color = ColorUtils.RedColor3
    else
      self.ui.mText_CostNum.color = ColorUtils.GrayColor
    end
    self.ui.mImg_CostItem.sprite = IconUtils.GetItemIconSprite(k)
    self.ui.mText_CostNum.text = v
  end
end
function UIDarkZoneQuestPanel:IsShowTarget(listString, enemy)
  local enemyList = string.split(listString, ",")
  for i = 1, #enemyList do
    if enemyList[i] == enemy then
      return true
    elseif enemyList[i] == enemy .. ";" then
      return true
    end
  end
  return false
end
function UIDarkZoneQuestPanel:SetRewardItem(dataList)
  for i, v in ipairs(dataList) do
    if self.rewardItemList[i] == nil then
      local item = UICommonItem.New()
      item:InitCtrl(self.ui.mTrans_ItemRoot)
      self.rewardItemList[i] = item
    end
    local item = self.rewardItemList[i]
    local num = v.num > 1 and v.num or nil
    item:SetItemData(v.id, num)
  end
end
function UIDarkZoneQuestPanel:SetEnemyList(mapData)
  local enemyList = mapData.darkzone_enemies
  local count = enemyList.Count
  for i = 0, count - 1 do
    do
      local data = string.split(enemyList[i], ":")
      local Tabdata = TableData.GetEnemyData(tonumber(data[1]))
      if self.enemyItemList[i + 1] == nil then
        local item = UICommonEnemyItem.New()
        item:InitCtrl(self.ui.mTrans_EnemyInfoRoot)
        self.enemyItemList[i + 1] = item
      end
      local item = self.enemyItemList[i + 1]
      local level = tonumber(data[2])
      item:SetData(Tabdata, level)
      if self.darkZoneMode == 1 then
        item:SetDarkzoneTargetIcon(self:IsShowTarget(self.questData.targetenemy_show, data[1]))
      end
      UIUtils.GetButtonListener(item.mBtn_OpenDetail.gameObject).onClick = function()
        CS.RoleInfoCtrlHelper.Instance:InitSysEnemyData(Tabdata, level)
      end
    end
  end
end
function UIDarkZoneQuestPanel:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIDarkZoneQuestPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Next.gameObject).onClick = function()
    local time = NetCmdItemData:GetNetItemCount(DarkZoneGlobal.TimeLimitID)
    if self.costItemNumIsEnough == false then
      TipsManager.ShowBuyStamina()
    else
      local rewardList = {}
      for _, v in ipairs(self.rewardItemList) do
        rewardList[v.itemId] = v.itemNum == nil and 1 or v.itemNum
      end
      if TipsManager.CheckItemIsOverflowAndStopByList(rewardList) then
        return
      end
      local data = {}
      data.enterType = self.darkZoneMode
      if self.darkZoneMode == 1 then
        data.MapId = self.questData.quest_struct_scene_id
        data.QuestID = self.questData.id
        MapSelectUtils.currentQuestGroupID = NetCmdDarkZoneSeasonData:GetQuestGroupID(self.questData.id)
      elseif self.darkZoneMode == 2 then
        data.QuestID = self.endLessRewardData.id
        data.MapId = self.endlessData.map
      end
      DarkZoneNetRepoCmdData:SendCS_DarkZoneStorage(UIManager.OpenUIByParam(UIDef.UIDarkZoneTeamPanelV2, data))
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    if not pcall(function()
      DarkNetCmdStoreData.questCacheGroupId = 0
    end) then
      gfwarning("UIDarkZoneQuestInfoPanelItem位置缓存出现异常")
    end
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Guide.gameObject).onClick = function()
    local param = {
      0,
      nil,
      9001
    }
    UIManager.OpenUIByParam(UIDef.UIGuideWindows, param)
  end
  UIUtils.GetButtonListener(self.ui.mQuestBtn_Query.gameObject).onClick = function()
    local data = {}
    data[0] = true
    data[1] = self.eventItemList
    UIManager.OpenUIByParam(UIDef.UIDarkZoneEventDetailDialog, data)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnQuery.gameObject).onClick = function()
    local data = {}
    data.endlessId = self.endlessData.id
    UIManager.OpenUIByParam(UIDef.UIDarkZoneAirValueDialog, data)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Raid.gameObject).onClick = function()
    if self.costItemNumIsEnough == false then
      SceneSwitch:SwitchByID(2)
      return
    end
    if self.canRaid == true then
      local rewardList = {}
      for _, v in ipairs(self.rewardItemList) do
        rewardList[v.itemId] = v.itemNum == nil and 1 or v.itemNum
      end
      if TipsManager.CheckItemIsOverflowAndStopByList(rewardList) then
        return
      end
      local wishItemIsEnough = false
      local wishItemList = TableData.listDarkzoneWishDatas:GetList()
      for i = 0, wishItemList.Count - 1 do
        local id = wishItemList[i].id
        local num = DarkZoneNetRepositoryData:GetItemNum(id)
        if 0 < num then
          wishItemIsEnough = true
          break
        end
      end
      local func
      if self.endlessData.wish == true and wishItemIsEnough == true then
        function func()
          local t = {}
          t[0] = self.endlessData.id
          t[1] = true
          t[2] = true
          t[3] = false
          t[6] = self.endLessRewardData.id
          UIManager.OpenUIByParam(UIDef.UIDarkZoneWishDialog, t)
        end
      else
        function func()
          local param = {
            OnDuringEndCallback = function()
              if self.endlessData.wish == true and wishItemIsEnough == true then
                UIManager.CloseUI(UIDef.UIDarkZoneWishDialog)
              end
              UIManager.OpenUI(UIDef.UICommonReceivePanel)
            end
          }
          local list = CS.LuaUtils.CreateArrayInstance(typeof(CS.System.UInt32), 4)
          DarkNetCmdStoreData:SendCS_DarkZoneEndLessRaid(self.endlessData.id, self.endLessRewardData.id, list, function()
            UIManager.OpenUIByParam(UIDef.UIRaidDuringPanel, param)
          end)
        end
      end
      MessageBox.Show(TableData.GetHintById(103081), TableData.GetHintById(240127), nil, func)
    else
      PopupMessageManager.PopupString(self.raidPopupStr)
    end
  end
  for i = DarkZoneGlobal.EventType.Start, DarkZoneGlobal.EventType.End do
    UIUtils.GetButtonListener(self.ui["mBtn_Event" .. i].gameObject).onClick = function()
      local data = {}
      data[0] = true
      data[1] = self.eventItemList
      data[2] = i
      UIManager.OpenUIByParam(UIDef.UIDarkZoneEventDetailDialog, data)
    end
  end
end
function UIDarkZoneQuestPanel:AddEventListener()
  function self.OnUpdateItem()
    if self.costItem then
      self:RefreshCostItem(self.costItem)
    end
  end
  MessageSys:AddListener(CS.GF2.Message.CommonEvent.ItemUpdate, self.OnUpdateItem)
  MessageSys:AddListener(CS.GF2.Message.ModelDataEvent.StaminaUpdate, self.OnUpdateItem)
  MessageSys:AddListener(CS.GF2.Message.CampaignEvent.ResInfoUpdate, self.OnUpdateItem)
end
function UIDarkZoneQuestPanel:RemoveEventListener()
  MessageSys:RemoveListener(CS.GF2.Message.CommonEvent.ItemUpdate, self.OnUpdateItem)
  MessageSys:RemoveListener(CS.GF2.Message.ModelDataEvent.StaminaUpdate, self.OnUpdateItem)
  MessageSys:RemoveListener(CS.GF2.Message.CampaignEvent.ResInfoUpdate, self.OnUpdateItem)
end
function UIDarkZoneQuestPanel:ReFreshChestNum()
  for i = 1, 3 do
    local index = 4 - i
    local canvasGroup = self.ui["mCanvasGroup_Box" .. index]
    local numText = self.ui["mText_ChestNum" .. index]
    local totalNum = DarkNetCmdStoreData:GetDZQuestTotalChestByType(self.mData.id, i)
    setactive(canvasGroup, 0 < totalNum)
    local curNum = DarkNetCmdStoreData:GetDZQuestReceivedChest(self.mData.id, i)
    local a = totalNum <= curNum and 0.2 or 1
    canvasGroup.alpha = a
    numText.text = string_format(self.formatStr, curNum, totalNum)
  end
end
