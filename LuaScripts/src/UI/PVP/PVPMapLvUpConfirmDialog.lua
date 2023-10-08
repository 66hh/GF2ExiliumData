require("UI.UIBasePanel")
PVPMapLvUpConfirmDialog = class("PVPMapLvUpConfirmDialog", UIBasePanel)
PVPMapLvUpConfirmDialog.__index = PVPMapLvUpConfirmDialog
function PVPMapLvUpConfirmDialog:ctor(obj)
  PVPMapLvUpConfirmDialog.super.ctor(self)
  obj.Type = UIBasePanelType.Dialog
end
function PVPMapLvUpConfirmDialog:OnInit(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.curTeam = data[1]
  self.selectMap = data[2]
  UIUtils.GetButtonListener(self.ui.mTrans_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.PVPMapLvUpConfirmDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Left.gameObject).onClick = function()
    if self.clickTime ~= nil then
      if CGameTime:GetTimestamp() - self.clickTime <= 1 then
        return
      end
    else
      self.clickTime = CGameTime:GetTimestamp()
    end
    self:OnClicUpMapBtn()
  end
  self:RefreshLevelAttr()
end
function PVPMapLvUpConfirmDialog:RefreshLevelAttr()
  local currMapData = TableData.listNrtpvpMapDatas:GetDataById(self.selectMap)
  if currMapData == nil then
    return
  end
  self.nextMapData = TableData.listNrtpvpMapDatas:GetDataById(currMapData.map_upgrade_id)
  if self.nextMapData == nil then
    return
  end
  if NetCmdPVPData.PvpInfo.level < self.nextMapData.MapOpenLevel then
    setactive(self.ui.mTrans_BtnConfirm.gameObject, false)
    self.ui.mText_Desc.text = string_format(TableData.GetHintById(120040), NetCmdPVPData:GetLevel(self.nextMapData.MapOpenLevel))
    setactive(self.ui.mTrans_Condition.gameObject, true)
    setactive(self.ui.mTrans_GoldConsume.gameObject, false)
  else
    setactive(self.ui.mTrans_BtnConfirm.gameObject, true)
    setactive(self.ui.mTrans_Condition.gameObject, false)
    setactive(self.ui.mTrans_GoldConsume.gameObject, true)
  end
  if currMapData.map_type == 2 then
    if currMapData.map_level == 1 then
      self.ui.mText_Before.text = TableData.GetHintById(120131)
      self.ui.mText_After.text = TableData.GetHintById(120132)
    elseif currMapData.map_level == 2 then
      self.ui.mText_Before.text = TableData.GetHintById(120132)
      self.ui.mText_After.text = TableData.GetHintById(120133)
    end
  end
  self.storeData = TableDataBase.listStoreGoodDatas:GetDataById(self.nextMapData.map_num)
  if self.storeData then
    self.ui.mText_CostNum.text = math.ceil(self.storeData.Price)
    if NetCmdItemData:GetResItemCount(self.storeData.price_type) < self.storeData.Price then
      self.ui.mText_CostNum.color = ColorUtils.RedColor
    else
      self.ui.mText_CostNum.color = ColorUtils.UpMapColor
    end
    local itemData = TableDataBase.listItemDatas:GetDataById(self.storeData.price_type)
    if itemData then
      self.ui.mImg_Icon.sprite = IconUtils.GetItemIcon(itemData.icon)
    end
  end
  local currLevelId, nextLevelId
  if 1 < currMapData.BarrierId.Count then
    currLevelId = currMapData.BarrierId[self.curTeam]
    nextLevelId = self.nextMapData.BarrierId[self.curTeam]
  end
  if currLevelId == nil or nextLevelId == nil then
    return
  end
  local currStageData = TableData.listStageConfigDatas:GetDataById(currLevelId)
  local nextStageData = TableData.listStageConfigDatas:GetDataById(nextLevelId)
  if currStageData == nil or nextStageData == nil then
    return
  end
  local currRobotCount, nextRobotCount, currHumanCount, nextHumanCount = 0, 0, 0, 0
  local currStageList = string.split(currStageData.defend_birth_points, "|")
  for k, v in ipairs(currStageList) do
    local infoList = string.split(v, ":")
    if infoList[3] == "0" then
      currHumanCount = currHumanCount + 1
    elseif infoList[3] <= tostring(currMapData.map_level) then
      currRobotCount = currRobotCount + 1
    end
  end
  local nextStageList = string.split(nextStageData.defend_birth_points, "|")
  for k, v in ipairs(nextStageList) do
    local infoList = string.split(v, ":")
    if infoList[3] == "0" then
      nextHumanCount = nextHumanCount + 1
    elseif infoList[3] <= tostring(self.nextMapData.map_level) then
      nextRobotCount = nextRobotCount + 1
    end
  end
  local attrList = {
    [1] = {
      name = TableData.GetHintById(120134),
      before = currRobotCount,
      after = nextRobotCount
    },
    [2] = {
      name = TableData.GetHintById(120135),
      before = currHumanCount,
      after = nextHumanCount
    },
    [3] = {
      name = TableData.GetHintById(120136),
      before = currMapData.map_robotnum,
      after = self.nextMapData.map_robotnum
    }
  }
  local detailPrefab = UIUtils.GetGizmosPrefab("PVP/PVPMapLvUpAtrributeItem.prefab", self)
  UIUtils:CloneGo(detailPrefab, self.ui.mTrans_Content, 3, function(item, index)
    local Text_Name = item.transform:Find("Root/Text_Name"):GetComponent("Text")
    local Text_NumBefore = item.transform:Find("Root/GrpNumRight/Text_NumBefore"):GetComponent("Text")
    local Text_NumNow = item.transform:Find("Root/GrpNumRight/Text_NumNow"):GetComponent("Text")
    Text_Name.text = attrList[index].name
    Text_NumBefore.text = attrList[index].before
    Text_NumNow.text = attrList[index].after
  end)
end
function PVPMapLvUpConfirmDialog:OnClicUpMapBtn()
  local resNum = NetCmdItemData:GetResItemCount(self.storeData.price_type)
  local pvpCoinItem = TableData.listItemDatas:GetDataById(self.storeData.price_type)
  if resNum < self.storeData.Price then
    PopupMessageManager.PopupString(string_format(TableData.GetHintById(120079), pvpCoinItem.name.str))
    return
  elseif NetCmdPVPData.PvpInfo.level < self.nextMapData.MapOpenLevel then
    local content = string_format(TableData.GetHintById(120040), NetCmdPVPData:GetLevel(self.nextMapData.MapOpenLevel))
    CS.PopupMessageManager.PopupPositiveString(content)
  else
    local hint = string_format(TableData.GetHintById(120068), math.ceil(self.storeData.Price), pvpCoinItem.name.str, self.storeData.Name.str)
    local content = MessageContent.New(hint, MessageContent.MessageType.DoubleBtn, function()
      NetCmdPVPData:SendStoreBuyPvpMap(self.storeData.Id, self.storeData.Price, function(ret)
        if ret == ErrorCodeSuc then
          UIManager.CloseUI(UIDef.PVPMapLvUpConfirmDialog)
          NetCmdPVPData:RequestPVPInfo(function()
            local mapData = TableData.listNrtpvpMapDatas:GetDataById(self.selectMap)
            if mapData then
              UIManager.OpenUIByParam(UIDef.PVPMapLvUpDialog, mapData)
            end
          end)
        end
      end)
    end)
    MessageBoxPanel.Show(content)
  end
end
function PVPMapLvUpConfirmDialog:OnHide()
  self.clickTime = nil
end
function PVPMapLvUpConfirmDialog:OnClose()
  self.clickTime = nil
end
function PVPMapLvUpConfirmDialog:OnRelease()
  self.clickTime = nil
end
