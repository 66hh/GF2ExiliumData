require("UI.UIBasePanel")
require("UI.MonopolyActivity.ActivityTourGlobal")
require("UI.ActivityTour.Btn_ActivityTourEnemyHeadItem")
require("UI.ActivityTour.Btn_ActivityTourMapMarkSelectItem")
require("UI.ActivityTour.ActivityTourMapMarkItem")
ActivityTourMapInfoDialog = class("ActivityTourMapInfoDialog", UIBasePanel)
ActivityTourMapInfoDialog.__index = ActivityTourMapInfoDialog
function ActivityTourMapInfoDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function ActivityTourMapInfoDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:ManualUI()
  self.currOpenIndex = 1
  self.titleUIList = {}
  self.funcUIList = {}
  self.terrainUIList = {}
  self.occupyUIList = {}
  self.playerOccupyList = {}
  self.enemyOccupyList = {}
  self:AddBtnListen()
end
function ActivityTourMapInfoDialog:ManualUI()
  self.gridPosList = {}
  self.mapGridUIList = {}
  local width = self.ui.mTrans_Map.sizeDelta.x - self.ui.mTrans_Map.anchoredPosition.x
  local height = self.ui.mTrans_Map.sizeDelta.y - self.ui.mTrans_Map.anchoredPosition.y
  local startX = self.ui.mTrans_Map.anchoredPosition.x - 86
  local startY = self.ui.mTrans_Map.anchoredPosition.y - 196
  local posX, posY
  for i = 1, 15 do
    for j = 1, 15 do
      local item = instantiate(self.ui.mImg_Event, self.ui.mTrans_Content3)
      item.transform:SetAsLastSibling()
      posX = (i - 1) * 24 + startX - 18
      if i % 2 == 0 then
        posY = (j - 1) * 27 + startY + 13
      else
        posY = (j - 1) * 27 + startY
      end
      item.transform.localPosition = Vector3(posX, posY, 0)
      setactive(item.gameObject, true)
      local grid = {}
      grid.posX = posX
      grid.posY = posY
      table.insert(self.gridPosList, grid)
      table.insert(self.mapGridUIList, item)
    end
  end
  self.imageMaterial = ResSys:GetUIMaterial("UIEffect/UILight/UI_Light_01")
end
function ActivityTourMapInfoDialog:OnInitUI()
  if SceneSys.CurSceneType == CS.EnumSceneType.Monopoly then
    self.funcDataList = NetCmdThemeData:GetMapFunList(self.levelStageData.MapId, 1)
    self.terrainDataList = NetCmdThemeData:GetMapFunList(self.levelStageData.MapId, 2)
  else
    self.funcDataList = NetCmdThemeData:GetMapFuncByMapID(self.levelStageData.MapId)
    self.terrainDataList = NetCmdThemeData:GetMapTerrainByMapID(self.levelStageData.MapId)
  end
  self.funcLegendDataList = {}
  self.terrainLegendDataList = {}
  self.terrainLegendUIList = {}
  self.funcLegendUIList = {}
  self.playerHeadList = {}
  local funDataList = {}
  local terraDataList = {}
  for i = 0, self.terrainDataList.Count - 1 do
    local data = self.terrainDataList[i]
    local item = instantiate(self.ui.mImg_Event, self.ui.mTrans_Content3)
    item.transform:SetAsLastSibling()
    if self.gridPosList[data.point_id] then
      item.transform.localPosition = Vector3(self.gridPosList[data.point_id].posX, self.gridPosList[data.point_id].posY, 0)
    end
    if terraDataList[data.terrain] == nil then
      terraDataList[data.terrain] = data
    end
    local funcData = TableData.listMonopolyMapTerrainDatas:GetDataById(data.terrain, true)
    if funcData == nil then
      funcData = NetCmdThemeData:GetTerrainDataById(data.point_id)
    end
    if funcData then
      local resourceData = TableData.listMonopolyPointResourcesDatas:GetDataById(funcData.map_image)
      if resourceData and resourceData.point_icon ~= "" then
        item.sprite = IconUtils.GetActivityTourIcon(resourceData.point_icon)
      end
    end
    table.insert(self.terrainLegendUIList, item)
  end
  self.playerPrefab = UIUtils.GetGizmosPrefab("ActivityTour/ActivityTourMapHeadItem.prefab", self)
  for i = 0, self.funcDataList.Count - 1 do
    local data = self.funcDataList[i]
    local item = instantiate(self.ui.mImg_Event, self.ui.mTrans_Content3)
    item.transform:SetAsLastSibling()
    if self.gridPosList[data.point_id] then
      item.transform.localPosition = Vector3(self.gridPosList[data.point_id].posX, self.gridPosList[data.point_id].posY, 0)
    end
    local funcData = TableData.listMonopolyMapFunctionDatas:GetDataById(data.Function, true)
    if funcData then
      local resourceData = TableData.listMonopolyPointResourcesDatas:GetDataById(funcData.map_image)
      if resourceData and resourceData.point_icon ~= "" then
        item.sprite = IconUtils.GetActivityTourIcon(resourceData.point_icon)
      end
      if funcData.is_show == 1 and funDataList[data.Function] == nil then
        funDataList[data.Function] = data
      end
      if funcData.type ~= 1 and funcData.type ~= 8 then
        item.material = self.imageMaterial
        item.color = ColorUtils.StringToColor("ABABAB")
        item.transform.sizeDelta = Vector2(26, 26)
      end
    end
    local mapFunctionData = TableData.listMonopolyMapFunctionDatas:GetDataById(data.Function, true)
    if mapFunctionData and mapFunctionData.type == 1 then
      self:CreataPlayer(data)
    end
    table.insert(self.funcLegendUIList, item)
  end
  for k, v in pairs(self.levelStageData.EnemyList) do
    self:CreateEnemy(k, v)
  end
  for k, v in pairs(funDataList) do
    table.insert(self.funcLegendDataList, v)
  end
  for k, v in pairs(terraDataList) do
    table.insert(self.terrainLegendDataList, v)
  end
  table.sort(self.funcLegendDataList, function(a, b)
    local dataA = TableData.listMonopolyMapFunctionDatas:GetDataById(a.Function, true)
    local dataB = TableData.listMonopolyMapFunctionDatas:GetDataById(b.Function, true)
    return dataA.sort_id > dataB.sort_id
  end)
  table.sort(self.terrainLegendDataList, function(a, b)
    local dataA = TableData.listMonopolyMapTerrainDatas:GetDataById(a.terrain, true)
    local dataB = TableData.listMonopolyMapTerrainDatas:GetDataById(b.terrain, true)
    if dataA and dataB then
      return dataA.sort_id > dataB.sort_id
    end
  end)
end
function ActivityTourMapInfoDialog:GetCell(point, isPlayer)
  local cell = {}
  local go = instantiate(self.playerPrefab, self.ui.mTrans_Content3)
  go.transform:SetAsLastSibling()
  go.transform.localPosition = Vector3(self.gridPosList[point].posX, self.gridPosList[point].posY, 0)
  setactive(go, false)
  cell.isPlayer = isPlayer
  cell.go = go
  cell.headIcon = go.transform:Find("GrpHead/Img_Head"):GetComponent(typeof(CS.UnityEngine.UI.Image))
  cell.headBg = go.transform:Find("Img_TeamColor"):GetComponent(typeof(CS.UnityEngine.UI.Image))
  cell.pointId = point
  return cell
end
function ActivityTourMapInfoDialog:CreataPlayer(data)
  local cell = self:GetCell(data.point_id, true)
  cell.headIcon.sprite = IconUtils.GetPlayerAvatar(AccountNetCmdHandler:GetAvatar())
  cell.headBg.color = ColorUtils.StringToColor("1DA8E7")
  table.insert(self.playerHeadList, cell)
end
function ActivityTourMapInfoDialog:CreateEnemy(point, resourceId)
  local cell = self:GetCell(point, false)
  cell.headBg.color = ColorUtils.StringToColor("E75432")
  local enemyData = TableData.listMonopolyEnemyDatas:GetDataById(resourceId)
  if enemyData then
    cell.headIcon.sprite = IconUtils.GetPlayerAvatar(enemyData.chess_icon)
  end
  table.insert(self.playerHeadList, cell)
end
function ActivityTourMapInfoDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ActivityTourMapInfoDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close1.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ActivityTourMapInfoDialog)
  end
end
function ActivityTourMapInfoDialog:CleanItem()
  for i = 1, #self.terrainLegendUIList do
    gfdestroy(self.terrainLegendUIList[i].gameObject)
  end
  for i = 1, #self.funcLegendUIList do
    gfdestroy(self.funcLegendUIList[i].gameObject)
  end
  for i = 1, #self.playerHeadList do
    gfdestroy(self.playerHeadList[i].go.gameObject)
  end
  self.funcDataList = nil
  self.terrainDataList = nil
end
function ActivityTourMapInfoDialog:OnInit(root, data)
  self.levelStageData = data.levelStageData
  self.currOpenIndex = data.openIndex
  self:OnInitUI()
  function self.ui.mVirtualListExNew_List.itemProvider()
    return self:ItemProvider()
  end
  function self.ui.mVirtualListExNew_List.itemRenderer(...)
    self:ItemRenderer(...)
  end
  ActivityTourGlobal.ReplaceAllColor(self.mUIRoot)
end
function ActivityTourMapInfoDialog:UpdateMapInfo()
  local mapData = TableData.listMonopolyMapDatas:GetDataById(self.levelStageData.MapId)
  if mapData then
    self.ui.mTextFit_Describe.text = mapData.map_des
  end
end
function ActivityTourMapInfoDialog:UpdateEnemyInfo()
  self.ui.mText_Round.text = string_format(TableData.GetHintById(270192), NetCmdMonopolyData.currentRound .. "/" .. NetCmdMonopolyData.levelData.max_round)
  self.ui.mText_Team.text = TableData.GetHintById(270300)
  self.ui.mText_Team2.text = TableData.GetHintById(270299)
  self.ui.mText_ChrTeam.text = string_format(TableData.GetHintById(270189), self.playerList.Count)
  self.ui.mText_EnemyTeam.text = string_format(TableData.GetHintById(270189), self.enemyList.Count)
  if self.teamPlayer == nil then
    self.teamPlayer = Btn_ActivityTourEnemyHeadItem.New()
    self.teamPlayer:InitCtrl(self.ui.mTrans_PlayerHead.gameObject)
    self.teamPlayer:SetBtnEnable(false)
    self.teamPlayer:SetPlayerData(NetCmdMonopolyData.teamInfo[0])
  end
  self.enemyDataList = NetCmdThemeData:GetEnemyList(self.levelStageData.EnemyList)
  self.ui.mVirtualListExNew_List.numItems = self.enemyDataList.Count
  self.ui.mVirtualListExNew_List:Refresh()
end
function ActivityTourMapInfoDialog:UpdateRightInfo()
  if self.titleUIList[1] == nil then
    self.titleUIList[1] = Btn_ActivityTourMapMarkSelectItem.New()
    self.titleUIList[1]:InitCtrl(self.ui.mTrans_Title4)
  end
  self.titleUIList[1]:SetData(1, self, true)
  if self.titleUIList[2] == nil then
    self.titleUIList[2] = Btn_ActivityTourMapMarkSelectItem.New()
    self.titleUIList[2]:InitCtrl(self.ui.mTrans_Title)
  end
  self.titleUIList[2]:SetData(2, self, true)
  if self.titleUIList[3] == nil then
    self.titleUIList[3] = Btn_ActivityTourMapMarkSelectItem.New()
    self.titleUIList[3]:InitCtrl(self.ui.mTrans_Title1)
  end
  self.titleUIList[3]:SetData(3, self, false)
  if self.titleUIList[4] == nil then
    self.titleUIList[4] = Btn_ActivityTourMapMarkSelectItem.New()
    self.titleUIList[4]:InitCtrl(self.ui.mTrans_Conditions)
  end
  self.titleUIList[4]:SetData(4, self, false)
  for i = 1, 2 do
    local item = self.occupyUIList[i]
    if item == nil then
      item = ActivityTourMapMarkItem.New()
      item:InitCtrl(self.ui.mTrans_Content2)
      table.insert(self.occupyUIList, item)
    end
    setactive(item.ui.mTrans_ActivityTourMapMarkItem.gameObject, true)
    item:SetOccupyData(i)
  end
  for i = 1, #self.funcLegendDataList do
    local item = self.funcUIList[i]
    if item == nil then
      item = ActivityTourMapMarkItem.New()
      item:InitCtrl(self.ui.mTrans_Content1)
      table.insert(self.funcUIList, item)
    end
    setactive(item.ui.mTrans_ActivityTourMapMarkItem.gameObject, true)
    local funcData = TableData.listMonopolyMapFunctionDatas:GetDataById(self.funcLegendDataList[i].Function, true)
    item:SetData(self.funcLegendDataList[i], funcData)
  end
  if #self.funcUIList > #self.funcLegendDataList then
    for j = #self.funcLegendDataList + 1, #self.funcUIList do
      setactive(self.funcUIList[j].ui.mTrans_ActivityTourMapMarkItem.gameObject, false)
    end
  end
  for i = 1, #self.terrainLegendDataList do
    local terrainData = TableData.listMonopolyMapTerrainDatas:GetDataById(self.terrainLegendDataList[i].terrain, true)
    if terrainData then
      local item = self.terrainUIList[i]
      if item == nil then
        item = ActivityTourMapMarkItem.New()
        item:InitCtrl(self.ui.mTrans_Content4)
        table.insert(self.terrainUIList, item)
      end
      setactive(item.ui.mTrans_ActivityTourMapMarkItem.gameObject, true)
      item:SetData(self.terrainLegendDataList[i], terrainData)
    end
  end
  if #self.terrainUIList > #self.terrainLegendDataList then
    for j = #self.terrainLegendDataList + 1, #self.terrainUIList do
      setactive(self.terrainUIList[j].ui.mTrans_ActivityTourMapMarkItem.gameObject, false)
    end
  end
end
function ActivityTourMapInfoDialog:UpdateToggleState(index, isShow)
  if index == 2 then
    for k, v in ipairs(self.funcLegendUIList) do
      setactive(v.gameObject, isShow)
    end
  elseif index == 1 then
    for k, v in ipairs(self.terrainLegendUIList) do
      setactive(v.gameObject, isShow)
    end
  elseif index == 4 then
    for k, v in pairs(self.playerHeadList) do
      setactive(v.go, isShow)
    end
  elseif index == 3 then
    for k, v in ipairs(self.playerOccupyList) do
      setactive(v.gameObject, isShow)
    end
    for k, v in ipairs(self.enemyOccupyList) do
      setactive(v.gameObject, isShow)
    end
  end
end
function ActivityTourMapInfoDialog:ItemProvider()
  local itemView = Btn_ActivityTourEnemyHeadItem.New()
  itemView:InitCtrl(self.ui.mTrans_Content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function ActivityTourMapInfoDialog:ItemRenderer(index, renderData)
  local data = self.enemyDataList[index]
  local item = renderData.data
  item:SetBtnEnable(false)
  item:SetData(data)
end
function ActivityTourMapInfoDialog:OnShowStart()
  setactive(self.ui.mTrans_MapInfo.gameObject, self.currOpenIndex == 1)
  setactive(self.ui.mTrans_Process.gameObject, self.currOpenIndex ~= 1)
  if self.currOpenIndex == 1 then
    self:UpdateMapInfo()
    self:UpdateOutsideOccupyInfo()
  else
    self.playerList = MpGridManager:GetCampOccupyGridIds(ActivityTourGlobal.PlayerCamp_Int)
    self.enemyList = MpGridManager:GetCampOccupyGridIds(ActivityTourGlobal.MonsterCamp_Int)
    self:UpdateOccupyInfo()
    self:UpdateEnemyInfo()
  end
  self:UpdatePlayEnemyInfo()
  self:UpdateMapColor()
  self:UpdateRightInfo()
end
function ActivityTourMapInfoDialog:UpdateOutsideOccupyInfo()
  for k, v in ipairs(self.playerOccupyList) do
    setactive(v.gameObject, false)
  end
  for k, v in ipairs(self.enemyOccupyList) do
    setactive(v.gameObject, false)
  end
  local playerList = NetCmdThemeData:GetMapOccupyByTpye(self.levelStageData.MapId, 1)
  local enemyList = NetCmdThemeData:GetMapOccupyByTpye(self.levelStageData.MapId, 2)
  for i = 0, playerList.Count - 1 do
    local item = self.playerOccupyList[i + 1]
    if item == nil then
      item = instantiate(self.ui.mImg_Event, self.ui.mTrans_Content3)
      item.transform:SetAsLastSibling()
      item:GetComponent(typeof(CS.UnityEngine.UI.Image)).sprite = IconUtils.GetActivityTourIcon("Icon_ActivityTour_Occupy_1")
      setactive(item.gameObject, false)
      table.insert(self.playerOccupyList, item)
    end
    if self.gridPosList[playerList[i].point_id] then
      item.transform.localPosition = Vector3(self.gridPosList[playerList[i].point_id].posX, self.gridPosList[playerList[i].point_id].posY, 0)
    end
  end
  for i = 0, enemyList.Count - 1 do
    local item = self.enemyOccupyList[i + 1]
    if item == nil then
      item = instantiate(self.ui.mImg_Event, self.ui.mTrans_Content3)
      item.transform:SetAsLastSibling()
      item:GetComponent(typeof(CS.UnityEngine.UI.Image)).sprite = IconUtils.GetActivityTourIcon("Icon_ActivityTour_Occupy_2")
      setactive(item.gameObject, false)
      table.insert(self.enemyOccupyList, item)
    end
    if self.gridPosList[enemyList[i].point_id] then
      item.transform.localPosition = Vector3(self.gridPosList[enemyList[i].point_id].posX, self.gridPosList[enemyList[i].point_id].posY, 0)
    end
  end
end
function ActivityTourMapInfoDialog:UpdatePlayEnemyInfo()
  local playerPrefab = UIUtils.GetGizmosPrefab("ActivityTour/ActivityTourMapHeadItem.prefab", self)
  if self.currOpenIndex == 1 then
    for i = 1, #self.playerHeadList do
      local cell = self.playerHeadList[i]
      cell.go.transform.localPosition = Vector3(self.gridPosList[cell.pointId].posX, self.gridPosList[cell.pointId].posY, 0)
    end
  else
    local actorList = MonopolyWorld:GetActorList()
    for i = 1, actorList.Count do
      local cell = self.playerHeadList[i]
      local data = actorList[i - 1]
      if i <= actorList.Count and cell == nil then
        cell = {}
        local go = instantiate(playerPrefab, self.ui.mTrans_Content3)
        go.transform:SetAsLastSibling()
        setactive(go, false)
        cell.go = go
        cell.headIcon = go.transform:Find("GrpHead/Img_Head"):GetComponent(typeof(CS.UnityEngine.UI.Image))
        cell.headBg = go.transform:Find("Img_TeamColor"):GetComponent(typeof(CS.UnityEngine.UI.Image))
        cell.pointId = data.currentGrid.Id
        table.insert(self.playerHeadList, cell)
      end
      if data.actorType == ActivityTourGlobal.ActorType.MainPlayer then
        cell.headBg.color = ColorUtils.StringToColor("1DA8E7")
        local playerData = TableData.listGunDatas:GetDataById(NetCmdMonopolyData.teamInfo[0].Id)
        if playerData then
          self.playerHeadList[i].headIcon.sprite = IconUtils.GetTourCharacterSprite("Avatar_Head_" .. playerData.en_name.str)
        end
      elseif data.actorType == ActivityTourGlobal.ActorType.OtherPlayer then
        cell.headBg.color = ColorUtils.StringToColor("1DA8E7")
        local gunData = TableData.listGunCharacterDatas:GetDataById(data.ConfigID)
        if gunData then
          cell.headIcon.sprite = IconUtils.GetPlayerAvatar(gunData.uien_name)
        end
      else
        cell.headBg.color = ColorUtils.StringToColor("E75432")
        local enemyData = TableData.listMonopolyEnemyDatas:GetDataById(data.ConfigID)
        if enemyData then
          cell.headIcon.sprite = IconUtils.GetPlayerAvatar(enemyData.chess_icon)
        end
      end
      cell.go.transform.localPosition = Vector3(self.gridPosList[data.currentGrid.Id].posX, self.gridPosList[data.currentGrid.Id].posY, 0)
    end
    if #self.playerHeadList > actorList.Count then
      for k = actorList.Count + 1, #self.playerHeadList do
        gfdestroy(self.playerHeadList[k].go.gameObject)
        self.playerHeadList[k] = nil
      end
    end
  end
end
function ActivityTourMapInfoDialog:UpdateMapColor()
  for k, v in ipairs(self.mapGridUIList) do
    local color = NetCmdThemeData:GetMapColor(k)
    if color then
      v.color = ColorUtils.StringToColor(color)
    else
      v.color = ColorUtils.StringToColor("333839")
    end
  end
end
function ActivityTourMapInfoDialog:UpdateOccupyInfo()
  local playCount, enemyCount = 1, 1
  for k, v in ipairs(self.playerOccupyList) do
    setactive(v.gameObject, false)
  end
  for k, v in pairs(self.playerList) do
    local item = self.playerOccupyList[playCount]
    if item == nil then
      item = instantiate(self.ui.mImg_Event, self.ui.mTrans_Content3)
      item.transform:SetAsLastSibling()
      item:GetComponent(typeof(CS.UnityEngine.UI.Image)).sprite = IconUtils.GetActivityTourIcon("Icon_ActivityTour_Occupy_1")
      setactive(item.gameObject, false)
      table.insert(self.playerOccupyList, item)
    end
    if self.gridPosList[v] then
      item.transform.localPosition = Vector3(self.gridPosList[v].posX, self.gridPosList[v].posY, 0)
    end
    playCount = playCount + 1
  end
  for k, v in ipairs(self.enemyOccupyList) do
    setactive(v.gameObject, false)
  end
  for k, v in pairs(self.enemyList) do
    local item = self.enemyOccupyList[enemyCount]
    if item == nil then
      item = instantiate(self.ui.mImg_Event, self.ui.mTrans_Content3)
      item.transform:SetAsLastSibling()
      item:GetComponent(typeof(CS.UnityEngine.UI.Image)).sprite = IconUtils.GetActivityTourIcon("Icon_ActivityTour_Occupy_2")
      setactive(item.gameObject, false)
      table.insert(self.enemyOccupyList, item)
    end
    if self.gridPosList[v] then
      item.transform.localPosition = Vector3(self.gridPosList[v].posX, self.gridPosList[v].posY, 0)
    end
    enemyCount = enemyCount + 1
  end
end
function ActivityTourMapInfoDialog:ResetPlayer()
  for k, v in ipairs(self.playerHeadList) do
    v.go.transform:SetAsLastSibling()
  end
end
function ActivityTourMapInfoDialog:OnShowFinish()
  self:ResetPlayer()
end
function ActivityTourMapInfoDialog:OnTop()
end
function ActivityTourMapInfoDialog:OnBackFrom()
end
function ActivityTourMapInfoDialog:OnClose()
  self:CleanItem()
end
function ActivityTourMapInfoDialog:OnHide()
end
function ActivityTourMapInfoDialog:OnHideFinish()
end
function ActivityTourMapInfoDialog:OnRelease()
end
