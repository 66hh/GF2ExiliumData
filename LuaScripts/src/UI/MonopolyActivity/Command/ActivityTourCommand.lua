require("UI.UIBaseCtrl")
require("UI.MonopolyActivity.Command.Btn_ActivityTourCommandItem")
require("UI.MonopolyActivity.Command.ActivityTourCommand_Move")
require("UI.MonopolyActivity.Command.ActivityTourCommand_SelectEntity")
ActivityTourCommand = class("ActivityTourCommand", UIBaseCtrl)
ActivityTourCommand.__index = ActivityTourCommand
local CommandUseConfig = {
  [ActivityTourGlobal.CommandType_RandomMovePoint] = ActivityTourCommandSelectEntity,
  [ActivityTourGlobal.CommandType_ManualMovePoint] = ActivityTourCommandMove
}
function ActivityTourCommand:ctor()
  self.super.ctor(self)
end
function ActivityTourCommand:InitCtrl(parentUI, parentPanel)
  self.parentUI = parentUI
  self.parentPanel = parentPanel
  self.ui = {}
  self:LuaUIBindTable(self.parentUI.mTrans_CommandInfoRoot, self.ui)
  self.mCommandItems = {}
  self.mUICommandInfo = {}
  self:RegisterEvent()
  self:RegisterMessage()
  self:HideCommandInfo()
  self:RefreshAllCommand()
end
function ActivityTourCommand:RegisterEvent()
  UIUtils.AddBtnClickListener(self.ui.mBtn_Cancel, function()
    self:HideCommandInfo()
    self:OnClickCommand(-1)
  end)
end
function ActivityTourCommand:RegisterMessage()
end
function ActivityTourCommand:UnRegisterMessage()
end
function ActivityTourCommand:DeleteCommand(data, slotIndex)
  if MonopolyWorld.MpData.commandList.Count == 1 then
    UIUtils.PopupErrorWithHint(270220)
    return
  end
  local content = UIUtils.StringFormatWithHintId(270167, data.sold)
  MessageBox.Show(TableData.GetHintById(208), content, nil, function()
    MonopolyWorld.MpData:DeleteCommand(ActivityTourGlobal.DeleteCommandType.Bag, slotIndex, function(ret)
      if ret == ErrorCodeSuc then
        self:HideCommandInfo()
        self:RefreshAllCommand(false)
        NetCmdMonopolyData:CheckShowPoints(ActivityTourGlobal.PointChangeReason.DeleteInstruction)
      end
    end)
  end)
end
function ActivityTourCommand:HideCommandInfo()
  self:HideAllCommandUI()
  self.parentPanel:ShowCommandAnimator(false)
  MonopolySelectManager:CancelAllSelect(true)
  MonopolySelectManager:EnableMultiSelect(false)
end
function ActivityTourCommand:HideAllCommandUI()
  for i, v in pairs(CommandUseConfig) do
    local useItem = self:GetCommandCtrl(i)
    useItem:Hide()
  end
end
function ActivityTourCommand:RefreshAllCommand(isRefresh)
  for i = 1, ActivityTourGlobal.MaxCommandNum do
    local commandItem = self:RefreshCommandItem(i, isRefresh)
    commandItem.mUIRoot:SetAsFirstSibling()
  end
end
function ActivityTourCommand:RefreshCommandItem(index, isRefresh)
  local commandItem = self.mCommandItems[index]
  if not commandItem then
    commandItem = Btn_ActivityTourCommandItem.New()
    commandItem:InitCtrl(self.parentUI.mScrollListChild_Command.childItem, self.parentUI.mScrollListChild_Command.transform, function()
      self:OnClickCommand(index)
    end)
    self.mCommandItems[index] = commandItem
  end
  if index - 1 < MonopolyWorld.MpData.commandList.Count then
    commandItem:SetData(MonopolyWorld.MpData.commandList[index - 1], isRefresh)
  else
    commandItem:ShowNone()
  end
  return commandItem
end
function ActivityTourCommand:RefreshCommand(slotIndex)
  if slotIndex == nil then
    self:RefreshAllCommand(false)
    return
  end
  self:RefreshCommandItem(slotIndex + 1)
end
function ActivityTourCommand:OnClickCommand(index)
  for i = 1, #self.mCommandItems do
    local commandItem = self.mCommandItems[i]
    local isSelect = i == index and not commandItem.isEmpty
    commandItem:EnableBtn(not isSelect)
  end
  local data = self.mCommandItems[index]
  if not data or data.isEmpty then
    return
  end
  self:ShowCommandInfo(data, index)
end
function ActivityTourCommand:ShowCommandInfo(data, index)
  self.parentPanel:ShowCommandAnimator(true)
  self:HideAllCommandUI()
  setactive(self.ui.mBtn_Delete, true)
  setactive(self.ui.mBtn_Confirm, true)
  setactive(self.ui.mBtn_Cancel, true)
  local tableData = data.data
  local useType = CS.LuaUtils.EnumToInt(tableData.order_type)
  local useItem = self:GetCommandCtrl(useType)
  useItem:SetData(tableData, index - 1)
end
function ActivityTourCommand:GetCommandCtrl(useType)
  local useItem = self.mUICommandInfo[useType]
  if not useItem then
    useItem = CommandUseConfig[useType].New()
    useItem:InitCtrl(self, self.ui)
    self.mUICommandInfo[useType] = useItem
  end
  return useItem
end
function ActivityTourCommand:Release()
  self:UnRegisterMessage()
  for i, ctrlTable in pairs(self.mCommandItems) do
    ctrlTable:OnRelease(true)
  end
  self.mCommandItems = nil
  for i, ctrlTable in pairs(self.mUICommandInfo) do
    ctrlTable:OnRelease(true)
  end
  self.mUICommandInfo = nil
  self:OnRelease(true)
end
