require("UI.UIBasePanel")
require("UI.MonopolyActivity.ActivityTourGlobal")
ActivityTourEncounterDialog = class("ActivityTourEncounterDialog", UIBasePanel)
ActivityTourEncounterDialog.__index = ActivityTourEncounterDialog
function ActivityTourEncounterDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function ActivityTourEncounterDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListener()
end
function ActivityTourEncounterDialog:OnInit(root, args)
  self.args = args
  self.monsterId = args:GetMonsterId()
  self.spine = nil
  self.staminCost = nil
  self.stageData = nil
  self.region = nil
  self.enemyHeadList = {}
  self.listItem = {}
  self.oriColor = self.ui.mText_CostNum.color
  ActivityTourGlobal.ReplaceAllColor(self.mUIRoot)
end
function ActivityTourEncounterDialog:OnShowStart()
end
function ActivityTourEncounterDialog:OnShowFinish()
  self:RefreshSpine()
  self:RefreshStageInfo()
  self:RefreshActionOrder()
end
function ActivityTourEncounterDialog:OnClose()
  for i = 1, #self.enemyHeadList do
    self.enemyHeadList[i]:OnRelease()
  end
  self:ReleaseCtrlTable(self.listItem, true)
  self.enemyHeadList = nil
  self.oriColor = nil
  self.stageData = nil
  self.region = nil
  if self.spine then
    ResourceDestroy(self.spine)
  end
  self.spine = nil
end
function ActivityTourEncounterDialog:OnRelease()
  self.ui = nil
  self.mData = nil
end
function ActivityTourEncounterDialog:OnBtnClose()
  if MonopolyWorld.IsGmMode then
    UIManager.CloseUI(UIDef.ActivityTourEncounterDialog)
  else
    UIManager.OpenUIByParam(UIDef.ActivityTourDoubleCheckDialog, {
      themeId = NetCmdMonopolyData.themID
    })
  end
end
function ActivityTourEncounterDialog:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_RightTopClose.gameObject).onClick = function()
    self:OnBtnClose()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Start.gameObject).onClick = function()
    if not TipsManager.CheckStaminaIsEnough(self.staminCost, false) then
      return
    end
    if MonopolyWorld.IsGmMode then
      UIManager.CloseUI(UIDef.ActivityTourEncounterDialog)
    elseif NetCmdRecentActivityData:ThemeActivityIsOpen(NetCmdMonopolyData.themID) then
      local record = NetCmdStageRecordData:GetStageRecordById(self.stageData.id)
      NetCmdMonopolyData.IsEnterSlgBattle = true
      SceneSys:OpenBattleSceneForMonopoly(self.stageData, record, NetCmdMonopolyData.themID)
      UIManager.CloseUI(UIDef.ActivityTourEncounterDialog)
    else
      NetCmdMonopolyData:ShowMonopolyEnd()
    end
  end
end
function ActivityTourEncounterDialog:RefreshStageInfo()
  local monsterActor = MonopolyWorld:GetMonsterActor(self.monsterId)
  if monsterActor == nil then
    return
  end
  local mpEnemyData = TableData.listMonopolyEnemyDatas:GetDataById(monsterActor.Data.Id)
  if mpEnemyData == nil then
    return
  end
  self.region = mpEnemyData.region
  local stageData = TableData.listStageDatas:GetDataById(mpEnemyData.region)
  if MonopolyWorld.IsGmMode then
    stageData = TableData.listStageDatas:GetDataById(6071)
  end
  if stageData == nil then
    return
  end
  self.stageData = stageData
  local stageConfig = TableData.listStageConfigDatas:GetDataById(stageData.stage_config)
  if stageConfig == nil then
    return
  end
  self.ui.mImg_Bg.sprite = IconUtils.GetAtlasV2(ActivityTourGlobal.EncounterBgDir, mpEnemyData.SlgBgPic)
  self.ui.mText_Title.text = stageData.name.str
  self.ui.mImg_CostItem.sprite = IconUtils.GetItemIconSprite(stageData.cost_item)
  local itemNum = NetCmdItemData:GetItemCountById(stageData.cost_item)
  self.ui.mText_CostNum.text = itemNum
  if itemNum < stageData.stamina_cost then
    self.ui.mText_CostNum.text = "<color=#FF5E41>" .. itemNum .. "/" .. stageData.stamina_cost .. "</color>"
  else
    self.ui.mText_CostNum.text = itemNum .. "/" .. stageData.stamina_cost
  end
  self.staminCost = stageData.stamina_cost
  self:RefreshEnemey(stageData, stageConfig)
  self:RefreshDropList(stageData)
end
function ActivityTourEncounterDialog:RefreshEnemey(stageData, stageConfig)
  for i = 1, stageConfig.enemies.Count do
    do
      local item = self.enemyHeadList[i]
      if item == nil then
        item = UICommonEnemyItem.New()
        item:InitCtrl(self.ui.mTrans_EnemyRoot.gameObject)
        self.enemyHeadList[i] = item
      end
      setactive(item:GetRoot(), true)
      local enemyId = stageConfig.enemies[i - 1]
      local enemyData = TableData.GetEnemyData(enemyId)
      item:SetData(enemyData, stageData.stage_class)
      item:EnableLv(true)
      UIUtils.GetButtonListener(item.mBtn_OpenDetail.gameObject).onClick = function()
        CS.RoleInfoCtrlHelper.Instance:InitSysEnemyData(enemyData, stageData.stage_class)
      end
    end
  end
  for i = stageConfig.enemies.Count + 1, #self.enemyHeadList do
    setactive(self.enemyHeadList[i]:GetRoot(), false)
  end
end
function ActivityTourEncounterDialog:RefreshDropList(stageData)
  local dropList = {}
  local normalDropList = stageData.normal_drop_view_list
  if normalDropList.Count > 0 then
    local itemList = UIUtils.SortStageNormalDrop(normalDropList)
    for _, value in ipairs(itemList) do
      table.insert(dropList, {
        item_id = value,
        item_num = normalDropList[value]
      })
    end
  end
  local index = 1
  for i = 1, #dropList do
    local itemId = dropList[i].item_id
    local itemData = TableData.GetItemData(itemId)
    if itemData then
      local rewardItem = self.listItem[index]
      if rewardItem == nil then
        rewardItem = UICommonItem.New()
        rewardItem:InitCtrl(self.ui.mTrans_RewardRoot, true)
        table.insert(self.listItem, rewardItem)
      end
      setactive(rewardItem:GetRoot(), true)
      rewardItem:SetItemData(itemId, dropList[i].item_num, false)
      index = index + 1
    end
  end
  for i = index, #self.listItem do
    setactive(self.listItem[i]:GetRoot(), false)
  end
end
function ActivityTourEncounterDialog:GetSortItemList(list)
  local itemIdList = {}
  if list then
    for _, v in pairs(list) do
      table.insert(itemIdList, v)
    end
    table.sort(itemIdList, function(a, b)
      local data1 = TableData.listItemDatas:GetDataById(a.item_id)
      local data2 = TableData.listItemDatas:GetDataById(b.item_id)
      if data1.rank == data2.rank then
        return data1.id > data2.id
      end
      return data1.rank > data2.rank
    end)
  end
  return itemIdList
end
function ActivityTourEncounterDialog:RefreshSpine()
  if self.spine then
    return
  end
  local gunId = MonopolyWorld.mainPlayer.ConfigID
  local data = TableData.GetGunCharacterData(gunId)
  if not data then
    return
  end
  ResSys:GetSpineUIObjectAsync(data.spine, function(path, go, data)
    if go ~= nil then
      self.spine = go
      UIUtils.SetParent(go, self.ui.mTrans_SpineRoot)
    end
  end)
end
function ActivityTourEncounterDialog:RefreshActionOrder()
  setactive(self.ui.mTrans_GrpOur.gameObject, false)
  setactive(self.ui.mTrans_GrpEnemy.gameObject, false)
  if not self.args then
    return
  end
  if self.args.attackerId == MonopolyWorld.mainPlayer.id then
    if MpGridManager:HaveOccupyGrid(ActivityTourGlobal.MonsterCamp_Int, MonopolyWorld.mainPlayer.currentGrid.Id) then
      setactive(self.ui.mTrans_GrpEnemy.gameObject, true)
    else
      setactive(self.ui.mTrans_GrpOur.gameObject, true)
    end
  elseif MpGridManager:HaveOccupyGrid(ActivityTourGlobal.PlayerCamp_Int, MonopolyWorld.mainPlayer.currentGrid.Id) then
    setactive(self.ui.mTrans_GrpOur.gameObject, true)
  else
    setactive(self.ui.mTrans_GrpEnemy.gameObject, true)
  end
end
