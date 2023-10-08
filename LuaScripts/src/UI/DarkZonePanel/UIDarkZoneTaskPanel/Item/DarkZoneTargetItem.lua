require("UI.UIBaseCtrl")
DarkZoneTargetItem = class("DarkZoneTeamItem", UIBaseCtrl)
DarkZoneTargetItem.__index = DarkZoneTargetItem
function DarkZoneTargetItem:__InitCtrl()
end
function DarkZoneTargetItem:InitCtrl(root, obj)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
function DarkZoneTargetItem:SetData(dataID, serverData, isFinish, index)
  setactive(self.mUIRoot, true)
  setactive(self.ui.mTrans_Bg, index % 2 ~= 0)
  self.isFinish = isFinish
  self.targetData = TableData.listDarkzoneQuestTargetDatas:GetDataById(dataID)
  self:FreshServeData(serverData)
  self.ui.mText_Name.text = self.targetData.TargetName.str
end
function DarkZoneTargetItem:FreshServeData(serverData)
  local currentNum
  if serverData then
    if serverData.Counter:ContainsKey(self.targetData.TargetId) then
      currentNum = serverData.Counter[self.targetData.TargetId]
    else
      currentNum = 0
    end
  elseif self.isFinish == true then
    currentNum = self.targetData.QuestNum
  else
    currentNum = 0
  end
  self.ui.mText_Num.text = currentNum .. "/" .. tostring(self.targetData.QuestNum)
  setactive(self.ui.mTrans_CompleteIcon, currentNum == self.targetData.QuestNum)
  local switch = 0
  if currentNum == self.targetData.QuestNum then
    switch = 1
  end
  self.ui.mAnimator_Self:SetInteger("Switch", switch)
end
function DarkZoneTargetItem:CloseFunction()
  self.mData = nil
  self:SetActive(false)
end
function DarkZoneTargetItem:OnClose()
  self:DestroySelf()
  self.ui = nil
  self.mData = nil
  self.isFinish = nil
  self.targetData = nil
end
