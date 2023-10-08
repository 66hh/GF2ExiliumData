require("UI.UIBaseCtrl")
DarkZoneTaskItem = class("DarkZoneTeamItem", UIBaseCtrl)
DarkZoneTaskItem.__index = DarkZoneTaskItem
function DarkZoneTaskItem:__InitCtrl()
end
function DarkZoneTaskItem:InitCtrl(root)
  local com = ResSys:GetUIGizmos("Darkzone/DarkzoneQuestLeftTabItem.prefab", false)
  local obj = instantiate(com)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self.ui.mBtn_Self.onClick:AddListener(function()
    self:OnClickBtn()
  end)
end
function DarkZoneTaskItem:SetData(Data, callback)
  self:SetActive(true)
  self.mData = Data
  if callback then
    self.clickFunc = callback
  end
  self.mData.canReceive = false
  self.stepNum = 1
  if self.mData.serverData then
    self.stepNum = self.mData.serverData.Accepted.Count + 1
  end
  local str = string_format("({0}/3)", self.stepNum)
  self.ui.mText_TargetName.text = TableData.listDarkzoneQuestGroupDatas:GetDataById(self.mData.GroupId).GroupName.str .. str
  self:FreshServeData()
end
function DarkZoneTaskItem:FreshServeData()
  local taskStatus = 0
  if self.mData.isFinish == true then
    taskStatus = 2
  elseif self.mData.serverData then
    taskStatus = self.mData.serverData.Status.value__
  end
  setactive(self.ui.mTrans_CanAccept, taskStatus == 0)
  setactive(self.ui.mText_Progress, taskStatus == 1)
  if taskStatus == 1 then
    local dataList, dataType
    if 0 < self.mData.taskData.AndTaget.Count then
      dataList = self.mData.taskData.AndTaget
      dataType = 0
    else
      dataList = self.mData.taskData.OrTarget
      dataType = 1
    end
    for i = 0, dataList.Count - 1 do
      local targetData = TableData.listDarkzoneQuestTargetDatas:GetDataById(dataList[i])
      local currentNum = 0
      if self.mData.serverData.Counter:ContainsKey(targetData.TargetId) then
        currentNum = self.mData.serverData.Counter[targetData.TargetId]
      end
      local needNum = targetData.QuestNum
      if currentNum >= needNum then
        self.mData.canReceive = true
        if dataType == 1 then
          break
        end
      else
        self.mData.canReceive = false
        if dataType == 0 then
          break
        end
      end
    end
  end
  setactive(self.ui.mTrans_Finished, taskStatus == 2)
  setactive(self.ui.mTrans_RedPoint, self.mData.canReceive == true)
end
function DarkZoneTaskItem:OnClickBtn()
  if self.clickFunc then
    self.clickFunc()
  end
end
function DarkZoneTaskItem:OnClose()
  self:DestroySelf()
  self.ui = nil
  self.mData = nil
  self.clickFunc = nil
  self.stepNum = nil
end
