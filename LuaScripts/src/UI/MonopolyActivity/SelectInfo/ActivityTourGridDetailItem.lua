require("UI.UIBaseCtrl")
require("UI.MonopolyActivity.ActivityTourGlobal")
require("UI.MonopolyActivity.SelectInfo.Item.ActivityTourGridEventInfo")
ActivityTourGridDetailItem = class("ActivityTourGridDetailItem", UIBaseCtrl)
ActivityTourGridDetailItem.__index = ActivityTourGridDetailItem
function ActivityTourGridDetailItem:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function ActivityTourGridDetailItem:InitCtrl(parent)
  local com = parent:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem, parent)
  self:SetRoot(obj.transform)
  self.ui = {}
  self.mData = nil
  self:LuaUIBindTable(obj, self.ui)
  self.gridId = 0
  self.detailList = {}
  if not self.oriColor then
    self.oriColor = self.ui.mImg_TeamBg.color
  end
end
function ActivityTourGridDetailItem:Refresh(gridId)
  local grid = MpGridManager:GetGrid(gridId)
  if not grid then
    return
  end
  local data = grid.Config
  if not data then
    return
  end
  self.gridId = gridId
  self.ui.mText_Name.text = string_format(TableData.GetHintById(270252), gridId)
  self.ui.mImg_PointsIcon.sprite = IconUtils.GetActivityTourIcon(MonopolyWorld.MpData.levelData.token_icon)
  local cost = MpGridManager:GetOccupyCost(MonopolyWorld.mainPlayer, gridId)
  self.ui.mText_Num.text = 0 < cost and cost or ""
  setactive(self.ui.mTrans_Consume.gameObject, 0 < cost)
  self.ui.mText_GridDesc.text = MpGridManager.BasicGridDesc
  local monsterOccupy = MpGridManager:HaveOccupyGrid(ActivityTourGlobal.MonsterCamp_Int, gridId)
  local playerOccupy = MpGridManager:HaveOccupyGrid(ActivityTourGlobal.PlayerCamp_Int, gridId)
  local haveCampOccupy = MpGridManager:HaveCampOccupyGrid(gridId)
  setactive(self.ui.mTrans_UnOccupy.gameObject, not grid.CanOccupy)
  setactive(self.ui.mTrans_Empty.gameObject, not haveCampOccupy and grid.CanOccupy)
  setactive(self.ui.mTrans_Occupy.gameObject, haveCampOccupy)
  if playerOccupy then
    self.ui.mImg_TeamBg.color = ColorUtils.BlueColor2
    self.ui.mText_Team.text = TableData.GetHintById(270300)
  elseif monsterOccupy then
    self.ui.mImg_TeamBg.color = ColorUtils.RedColor4
    self.ui.mText_Team.text = TableData.GetHintById(270299)
  end
  self:RefreshTerrainOrFunction()
end
function ActivityTourGridDetailItem:OnRelease()
  self.ui = nil
  self.mData = nil
  if self.detailList then
    for i = 1, #self.detailList do
      self.detailList[i]:OnRelease(true)
    end
  end
  self.detailList = nil
  self.super.OnRelease(self, true)
end
function ActivityTourGridDetailItem:RefreshTerrainOrFunction()
  setactive(self.ui.mTrans_EventInfo.gameObject, false)
  local grid = MpGridManager:GetGrid(self.gridId)
  if not grid then
    return
  end
  self.detailNum = 0
  self:RefreshGridFunction(grid.FunctionId)
  self:RefreshGridTerrain(grid.TerrainIds)
  for i = self.detailNum + 1, #self.detailList do
    setactive(self.detailList[i]:GetRoot(), false)
  end
  setactive(self.ui.mTrans_Event.gameObject, self.detailNum > 0)
end
function ActivityTourGridDetailItem:RefreshGridTerrain(listId)
  if listId.Count <= 0 then
    return
  end
  for i = 0, listId.Count - 1 do
    local data = TableData.listMonopolyMapTerrainDatas:GetDataById(listId[i])
    self:RefreshInternal(data)
  end
end
function ActivityTourGridDetailItem:RefreshGridFunction(id)
  if id <= 0 then
    return
  end
  local data = TableData.listMonopolyMapFunctionDatas:GetDataById(id)
  self:RefreshInternal(data)
end
function ActivityTourGridDetailItem:RefreshInternal(data)
  if not data then
    return
  end
  local index = self.detailNum + 1
  if not self.detailList[index] then
    self.detailList[index] = ActivityTourGridEventInfo.New()
    self.detailList[index]:InitCtrl(self.ui.mTrans_EventInfo.gameObject, self.ui.mTrans_EventInfo.transform.parent)
  end
  if not self.detailList[index] then
    return
  end
  self.detailNum = self.detailNum + 1
  setactive(self.detailList[index]:GetRoot(), true)
  self.detailList[index]:Refresh(data)
end
