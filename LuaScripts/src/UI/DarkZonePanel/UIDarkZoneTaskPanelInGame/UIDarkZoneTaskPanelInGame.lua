require("UI.DarkZonePanel.UIDarkZoneTaskPanelInGame.UIDarkZoneTaskPanelInGameView")
require("UI.UIBasePanel")
require("UI.DarkZonePanel.UIDarkZoneTaskPanelInGame.item.DarkZoneMapQuestTargetItem")
require("UI.DarkZonePanel.UIDarkZoneTaskPanelInGame.item.DarkZoneMapRoomTabItem")
require("UI.DarkZonePanel.UIDarkZoneBigMap.UIDarkZoneBigMapPanel")
UIDarkZoneTaskPanelInGame = class("UIDarkZoneTaskPanelInGame", UIBasePanel)
UIDarkZoneTaskPanelInGame.__index = UIDarkZoneTaskPanelInGame
function UIDarkZoneTaskPanelInGame:ctor(csPanel)
  UIDarkZoneTaskPanelInGame.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneTaskPanelInGame:OnInit(root, data)
  self:SetRoot(root)
  self:InitBaseData()
  self.mView:InitCtrl(root, self.ui)
  self.bigMapView = UIDarkZoneBigMapPanel.New()
  self.bigMapView:InitCtrl(self.ui.mTrans_Map)
  self.bigMapView:SetMapCloseBtnActive(false)
  setactive(self.ui.mTrans_ExtraQuest, false)
  self:AddBtnListen()
end
function UIDarkZoneTaskPanelInGame:OnShowStart()
  self:InitQuestData()
  local grid = CS.SysMgr.dzPlayerMgr.MainPlayerData.serverTrans.BigGrid
  self.currentRoomID = CS.DarkUnitWorld.DzGridUtils.GetDzAreaID(grid)
  if self.currentRoomID then
    if self.roomTargetItem == nil then
      self.roomTargetItem = DarkZoneMapRoomTabItem.New()
      self.roomTargetItem:InitCtrl(self.ui.mTrans_ExtraQuest.gameObject)
    end
    self.roomTargetItem:SetData(self.currentRoomID)
  end
  self.bigMapView:OnShowStart()
end
function UIDarkZoneTaskPanelInGame:OnClose()
  self.ui = nil
  self.mView = nil
  self.mData = nil
  self.bigMapView = nil
  self.mapManage = nil
  self:ReleaseCtrlTable(self.taskItem, true)
  self.taskItem = nil
  self.isSelectItem = nil
  self.isFocusTargetItem = nil
  self.formatStr = nil
  self.questID = nil
  if self.roomTargetItem then
    self.roomTargetItem:OnRelease()
  end
  self.roomTargetItem = nil
  self.currentRoomID = nil
  self:UnRegistrationKeyboard(nil)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.GoToDarkSLGView, self.closeFunction)
  self.closeFunction = nil
end
function UIDarkZoneTaskPanelInGame:OnRelease()
  self.super.OnRelease(self)
end
function UIDarkZoneTaskPanelInGame:CloseFunction()
  self.bigMapView:CloseSelf()
  self.bigMapView:CloseFunction()
  UIManager.CloseUI(UIDef.UIDarkZoneTaskPanelInGame)
end
function UIDarkZoneTaskPanelInGame:InitBaseData()
  self.mView = UIDarkZoneTaskPanelInGameView.New()
  self.ui = {}
  self.mapManage = CS.SysMgr.dzMiniMapDataMgr
  function self.closeFunction()
    self:CloseFunction()
  end
  self.taskItem = {}
  self.currentRoomID = 0
  self.questID = CS.SysMgr.dzMatchGameMgr.questId
  self.formatStr = "{0}/{1}"
end
function UIDarkZoneTaskPanelInGame:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = self.closeFunction
  self:RegistrationKeyboard(KeyCode.X, self.bigMapView.ui.mBtn_Location)
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Back)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.GoToDarkSLGView, self.closeFunction)
end
function UIDarkZoneTaskPanelInGame:InitQuestData()
  local questID = DarkNetCmdStoreData.currentMapID
  local showTaskItem
  if 0 < questID then
    local index = 1
    local isNotLastQuest = false
    local data = TableData.listDarkzoneMapV2Datas:GetDataById(questID)
    local groupCount = data.target_group_id.Count
    for i = 0, groupCount - 1 do
      local num = data.target_group_id[i]
      if self:CheckQuestIsFinish(num) == false then
        if self.taskItem[index] == nil then
          self.taskItem[index] = DarkZoneMapQuestTargetItem.New()
          self.taskItem[index]:InitCtrl(self.ui.mTrans_Content)
        end
        self.taskItem[index]:SetData(data, num)
        self.taskItem[index]:SetIsFinalQuest(false)
        isNotLastQuest = index < data.target_group_id.Count
        index = index + 1
        break
      end
    end
  end
  self:ReFreshChestNum()
end
function UIDarkZoneTaskPanelInGame:CheckQuestIsFinish(targetGroupID)
  local isFinish = false
  local questData = TableData.listDarkzoneQuestTargetGroupDatas:GetDataById(targetGroupID)
  for i = 0, questData.target_list.Count - 1 do
    local id = questData.target_list[i]
    local curNum = 0
    local needNum = 1
    local countData = DarkNetCmdStoreData:GetCountByID(1, targetGroupID, id)
    if countData and 0 < countData.Count then
      local d = countData[0]
      curNum = d.Num or 0
      needNum = d.NeedNum or 1
    end
    isFinish = curNum >= needNum
  end
  return isFinish
end
function UIDarkZoneTaskPanelInGame:OnClickTabFunc(item)
  if self.isSelectItem and self.isSelectItem ~= item then
    self.isSelectItem:SetItemIsOpen(false)
  end
  self.isSelectItem = item
end
function UIDarkZoneTaskPanelInGame:OnClickTargetFunc(item)
  if self.isFocusTargetItem and self.isFocusTargetItem ~= item then
    self.isFocusTargetItem:RemoveSelect()
  end
  self.isFocusTargetItem = item
  DZStoreUtils.selectQuestGroupId = self.isFocusTargetItem.mData.Id
  DZStoreUtils.selectQuestTargetId = self.isFocusTargetItem.selectTargetItem.targetData.TargetId
  self.mapManage:GetMonsterTargetByID(self.isFocusTargetItem.selectTargetItem.targetData.quest_args[0])
end
function UIDarkZoneTaskPanelInGame:ReFreshChestNum()
  for i = 1, 3 do
    local index = 4 - i
    local canvasGroup = self.ui["mCanvasGroup_Box" .. index]
    local numText = self.ui["mText_Num" .. index]
    local totalNum = DarkNetCmdStoreData:GetDZQuestTotalChestByType(self.questID, i)
    setactive(canvasGroup, 0 < totalNum)
    local curNum = CS.SysMgr.dzGameMapMgr:GetBoxNumByType(i)
    local a = totalNum <= curNum and 0.2 or 1
    canvasGroup.alpha = a
    numText.text = string_format(self.formatStr, curNum, totalNum)
  end
end
